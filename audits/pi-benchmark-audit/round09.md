## Round 9 audit

I re-audited current `main` at **`33c70fd9d631bcaeb792396f1843a89855bada6c`**, the merge of PR **#129 — `fix(runtime): address round 8 benchmark audit`**. The current Pi comparison baseline remains `earendil-works/pi` at **`2b0a123de98318c2ff8069661721ce0c3794c34e`**.

Round 8 landed well. In particular, the previous P0 live tool-replacement race is genuinely closed: Rupi now holds the exact request binding through the durable `ToolStarted` boundary and then executes the already-selected `Arc`. The duplicate-ID OpenAI decoder fix, causal replay identity, mutation-budget classification, semantic message origins, and rejected-reason bounds are also substantial rather than cosmetic.

Round 9 exposes several second-order effects of those fixes:

| Priority | Finding | Main impact |
|---|---|---|
| **P0/P1** | Exact tool-definition identity is lost across process restart | A changed same-name/same-risk tool can reconcile an operation performed by an older implementation |
| **P1** | `MessageOrigin` is not authoritative in the canonical trace | Runtime/external text can still be reconstructed or tampered into genuine user authority |
| **P1** | Recursive compaction cannot reliably ingest its own summaries | Long sessions can silently forget earlier objective, constraints, and progress |
| **P1** | Unique tool-call IDs are enforced by the OpenAI adapter, not the runtime contract | Custom/local providers can still inject ambiguous duplicate invocation IDs |
| **P1** | Schema-v4 migration marks old messages `ImportedLegacy` without recovering their real origins | Genuine pre-v4 user intent can disappear at the next compaction |
| **P2** | A stale binding that becomes unavailable after admission still consumes mutation budget | Dynamic catalogs can reduce useful mutation capacity despite zero execution |

### 1. P0/P1 — the new tool binding is exact only until the process dies

Within one process, the Round-8 solution is strong. `ToolBinding` contains a process-specific `registry_id`, registration `generation`, name, and risk class. `dispatch()` validates it while holding the registry read lock through `ToolStarted`.

The problem is that none of this exact identity is durable.

`ToolRequested` still persists only:

```rust
pub struct ToolRequested {
  pub call_id: ToolCallId,
  pub name: String,
  pub arguments: serde_json::Value,
  pub read_only: bool,
}
```

Likewise, an `InterruptedToolCall` reconstructed after restart contains the tool request and its `read_only` classification, but not the definition that actually crossed the start boundary.

On resume, Rupi therefore does:

```rust
self.tools
  .reconcile_with_risk(&call.request, Some(call.read_only))
```

and `reconcile_with_risk()` accepts the currently registered tool whenever its name and `read_only` value are compatible.

That permits this:

```text
process A
  write_like v1 advertised
  write_like v1 starts
  process crashes

process B
  write_like v2 registered
  same name
  same read_only=false
  different implementation / schema / reconciliation semantics

resume
  v2.reconcile(v1_request)
```

If v2 interprets the request differently and reports `Committed` or `Unmodified`, Rupi can clear a side-effect uncertainty that actually belongs to v1.

This matters especially for extensions and MCP tools, whose implementation can change independently of Rupi. Built-ins are less exposed, but upgrading Rupi between crash and resume creates the same conceptual boundary.

The durable identity should therefore be a **stable definition fingerprint**, not the process-local registry generation. For example:

```rust
pub struct ToolDefinitionFingerprint {
  pub source: String,
  pub definition_id: String,
  pub definition_version: String,
  pub schema_hash: String,
  pub read_only: bool,
  pub idempotent: bool,
}
```

Built-ins can explicitly declare `builtin/write/v1`, `builtin/edit/v2`, etc. Extension APIs should require or strongly encourage a stable reconciliation-contract version. MCP tools could include configured server identity plus normalized schema hash; if no stable implementation/version identity exists, resumed uncertain mutations should conservatively require manual inspection.

Persist that fingerprint in `ToolRequested` and therefore in reconstructed interrupted/unresolved state. Automatic reconciliation should occur only when the current tool proves compatibility with the durable fingerprint. Missing or mismatched identity on a mutating `Started`/`Unknown` call should become `RequiresManualInspection`, not invoke the replacement's reconciliation code.

The important regression is:

```text
mutating v1 starts
→ crash
→ v2 with same name and same read_only is installed
→ resume
→ v2.reconcile() is never called
→ NeedsReconciliation/manual resolution
```

Then separately prove that a restart with the **same stable definition identity** still auto-reconciles normally.

I would treat this as P0 for dynamically supplied tools and P1 for static built-ins.

---

### 2. P1 — semantic origin now controls authority, but the trace cannot prove it

`MessageOrigin` is the right architectural direction. The problem is that it is currently stronger than the event model beneath it.

For example, genuine user input is persisted as:

```rust
AgentEvent::UserMessage(...)
MessageOrigin::UserInput
```

but runtime-injected control text is also canonically emitted as:

```rust
AgentEvent::UserMessage(...)
MessageOrigin::RuntimeControl { ... }
```

So the canonical trace itself does not tell us whether the human said something or the harness inserted it.

The store validator compounds this. For `AgentEvent::UserMessage`, it verifies the user-role text and attachments, but not:

```rust
message.origin == MessageOrigin::UserInput
```

Similarly, the external-context projection verifies its typed `ExternalContextRef`, but does not require `MessageOrigin::ExternalContext`; context summaries do not require `CompactionSummary`; reconciliation notices do not require `ToolReconciliation`; assistant/tool projections likewise do not enforce their semantic origin.

That means the new authority property is currently **projection metadata that canonical history does not fully authenticate**.

There is also a recovery path that reconstructs a bare canonical `UserMessage` as:

```rust
Message::user(user.text)
```

which produces `MessageOrigin::UserInput`. For an old or partially projected runtime-control event, that can promote harness guidance into human-authored authority.

I would make the distinction canonical. Prefer a dedicated event:

```rust
AgentEvent::RuntimeControl(RuntimeControlInjected {
  kind: RuntimeControlKind,
  text: String,
})
```

rather than representing it as `UserMessage`.

Then make event ↔ semantic-origin validation exact:

```text
UserMessage                  ↔ UserInput
RuntimeControl               ↔ RuntimeControl(kind)
ExternalContextRetrieved     ↔ ExternalContext(exact ref)
ContextSummary               ↔ CompactionSummary
ToolReconciliationObserved   ↔ ToolReconciliation
ModelRequestCompleted/...    ↔ Assistant
ToolCompleted/Failed/Unknown ↔ ToolResult
```

Recovery should derive origin from this canonical event, rather than choosing constructors from the wire role.

I would also add a central invariant such as:

```rust
Message::validate_role_origin()
```

because `with_origin()` currently permits arbitrary role/origin pairings.

A strong test is to deliberately rewrite a persisted external-context message's origin to `UserInput`. `restore()` should reject the semantic projection as inconsistent with its canonical event rather than allowing the next checkpoint to promote it to a user constraint.

---

### 3. P1 — repeated compaction can lose the task that the previous compaction summarized

This is the clearest functional bug I found this round.

After Round 8, `coding_capsule()` correctly distinguishes:

```rust
MessageOrigin::UserInput
MessageOrigin::CheckpointCapsule
MessageOrigin::CompactionSummary
...
```

For a derived capsule/summary it invokes:

```rust
absorb_formatted_capsule(&message.text(), ...)
```

but `absorb_formatted_capsule()` immediately requires:

```rust
if !trimmed.starts_with("[Session Checkpoint Capsule]") {
  return;
}
```

The built-in summarizer does **not** produce that as its first line:

```rust
format!(
  "Summary of earlier conversation:\n{}",
  coding_capsule(...).format_for_model()
)
```

So a normal L1 summary begins:

```text
Summary of earlier conversation:
[Session Checkpoint Capsule]
objective: ...
...
```

and therefore cannot be parsed by the very routine intended to carry its state into the next summary.

L2 makes the mismatch stronger:

```text
[Phase Compaction: implementation complete]
Summary of earlier conversation:
[Session Checkpoint Capsule]
...
```

This creates a long-session failure mode:

```text
actual user objective
      ↓
L1 compaction
      ↓
CompactionSummary containing objective
      ↓
original user message eventually removed
      ↓
later L1/L2/L3 compaction
      ↓
absorb_formatted_capsule() ignores summary
      ↓
objective / constraints / prior progress disappear
```

The existing regression test does not catch this because its second-level summary includes the original `user` message again:

```rust
structured_summary(&[
  user,
  external,
  Message::compaction_summary(first_level),
])
```

A real recursive-compaction test needs to pass **only the retained first summary plus newer history**.

Custom summarizers make this more fundamental. `with_summarizer()` returns an arbitrary `String`; tagging that as `CompactionSummary` protects it from gaining user authority, but later built-in compaction has no way to preserve its semantics and currently just ignores opaque derived text.

The durable fix is to stop making semantic compaction state depend on parsing rendered prompt text. Store something typed, for example:

```rust
enum DerivedSummary {
  Capsule(ContextCapsule),
  Phase {
    phase: String,
    capsule: ContextCapsule,
  },
  Opaque {
    text: String,
  },
}
```

Rendering to:

```text
Summary of earlier conversation:
...
```

should happen only at the provider boundary.

A lower-impact immediate fix can unwrap known L1/L2 prefixes before parsing, but I would still add a structured summarizer API:

```rust
with_structured_summarizer(
  Fn(&[Message]) -> ContextCapsule
)
```

and eventually treat the free-form `String` summarizer as an opaque derived state that must be carried forward, not silently discarded.

The essential regression sequence is:

```text
user
→ L1 summary
→ original user no longer visible
→ L1 summary again
→ checkpoint
```

At every stage the original objective, actual user constraints, completed work, unresolved work, and artifacts should survive.

---

### 4. P1 — duplicate tool IDs are still possible through the public provider boundary

The OpenAI decoder fix is solid. It now examines the complete batch, assigns unique local lifecycle IDs to collisions, emits `ToolCallRejected`, and never executes either ambiguous call.

But this invariant lives in `rupi-provider`, while `ModelProvider` and `ProviderEvent` form a more general public boundary.

The runtime collector accepts:

```rust
ProviderEvent::ToolCall(call)
```

and, after size checks, simply:

```rust
self.calls.push(call.clone());
```

There is no runtime-wide uniqueness test.

A custom provider can therefore emit:

```text
ToolCall(id="call_1", name="read")
ToolCall(id="call_1", name="edit")
```

and bypass the OpenAI adapter's protection.

That can lead to two live executions sharing one provider/lifecycle identifier, ambiguous tool-result correlation in the next provider request, and broken completed-cycle accounting. `rejected_calls` being keyed by ID also becomes ambiguous if a custom provider mixes a valid call and rejected call sharing one ID.

Because `ProviderEvent` is already the normalized internal provider contract, Rupi should make uniqueness a **runtime invariant**, not a property each adapter must independently remember.

I would add a final batch-normalization step before `Response` is committed:

```rust
normalize_tool_batch(
  Vec<ProviderEvent>
) -> Result<NormalizedToolBatch, ...>
```

It should detect duplicates across both `ToolCall` and `ToolCallRejected`. Every collision should become non-executable, with unique internal lifecycle IDs and one bounded correction opportunity to the same model.

That gives all adapters the same guarantee:

> By the time a tool invocation reaches durable assistant history, every invocation identity in that model response is unique.

Test this using a deliberately broken custom `ModelProvider`, not the OpenAI decoder. Two same-ID calls should produce **zero `ToolStarted` events** and should not activate backup-model failover.

---

### 5. P1 — v4 migration is conservative enough to lose genuine old user intent

Schema v4 introduces `MessageOrigin`, and messages without it deserialize to:

```rust
MessageOrigin::ImportedLegacy
```

That is a safe default: old wire-role `user` content should not automatically acquire user authority.

But `SessionLog::migrate_to_current()` currently upgrades an older session essentially by changing:

```rust
header.version = SESSION_SCHEMA_VERSION
```

and rewriting the existing records. It does not reconstruct origins from canonical trace events.

So a genuine v1-v3 user request becomes permanently stored under a v4 header as `ImportedLegacy`.

Later, `coding_capsule()` deliberately ignores `ImportedLegacy` for user objective/constraint extraction.

Therefore a resumed old session can behave correctly while its old messages remain verbatim, but once context pressure compacts them, the historical user's task or constraints may vanish.

The migration should use the event linkage already present in `SessionMessage.event_id` wherever possible. Origins with unambiguous canonical evidence can be upgraded mechanically. External context, context summaries, reconciliation, assistant, and tool results are straightforward.

Old `UserMessage` is harder because previous Rupi versions also used that event for runtime controls. I would not guess. Where actual user provenance can be proved, promote to `UserInput`; where it cannot, retain `ImportedLegacy`.

But an unresolved `ImportedLegacy` message should still be preserved as **opaque derived context** during compaction instead of disappearing completely. “Not trusted as user authority” and “not worth carrying forward at all” are different claims.

Also, I would avoid presenting a simple header bump to v4 as a fully completed semantic migration if origin reconstruction was incomplete. Either record that legacy-origin uncertainty remains, or perform the origin upgrade as part of migration.

---

### 6. P2 — stale executable mutations can still spend budget despite never starting

This is relatively minor.

`admit_tool_calls()` determines whether a call is presently an executable mutation and increments `mutating_tool_calls_seen`. There is then another deliberate binding check immediately before execution.

If the registry changes in between those boundaries, the call correctly fails without `ToolStarted`—good—but its mutation-budget slot remains consumed.

I would not weaken the safety path to reclaim it casually. If you want the weak-model experience to be maximally forgiving, mutation accounting could eventually distinguish:

```text
admitted mutation
started mutation
```

and decrement or avoid final consumption for a binding-stale proven-no-start result.

But the current behavior is conservative and bounded, so I would leave it until the higher-priority items above are resolved.

---

## Round-8 closure assessment

I would mark the six Round-8 findings themselves **substantially fixed**. The first four Round-9 items are not failures to implement those recommendations; they are cross-process/runtime consequences that became visible once the architecture grew more precise.

The most important conceptual shift for the next patch is that two identities now need to become durable rather than merely in-memory:

```text
tool-definition identity
message-authority identity
```

Rupi has good in-memory representations for both, but crash recovery and canonical validation still preserve weaker information.

For compaction, the corresponding lesson is similar: **semantic state should be persisted as semantic state, not recovered later by parsing its rendered prompt text.**

### Recommended implementation order

1. Persist a stable tool-definition/reconciliation fingerprint and require it across crash recovery.
2. Make runtime-control origin canonical in `AgentEvent` and strictly validate every event ↔ `MessageOrigin` pairing.
3. Replace recursive parsing of summary prose with typed compaction state; at minimum fix L1/L2 wrapper ingestion immediately.
4. Enforce unique invocation IDs at the runtime provider boundary, independent of adapter.
5. Upgrade pre-v4 message origins from canonical trace where provable and conservatively retain unresolved legacy content.
6. Optionally refine mutation accounting for proven-no-start stale bindings.

I still would **not claim empirical weak-model superiority yet**. PR #129 explicitly did not rerun a live llama.cpp comparison, so Round 9 remains a deterministic architecture/recovery audit. After the first four items above, however, I think the remaining value from repeated static auditing will decline sharply; the next serious phase should be repeated Rupi-vs-Pi trials on deliberately fragile quantized models, measuring oracle success, malformed-call correction, requests per successful task, productive-tool ratio, and unsafe/uncertain mutation incidence.
