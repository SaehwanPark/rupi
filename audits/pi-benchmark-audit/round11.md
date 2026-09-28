# Round 11 audit

I re-audited current `main` at **`d6d2c71ae39889025faeaff557c0c7d3a6b7a7a5`**, including merged PR **#131**.

The Round-10 work landed correctly. In particular, migration no longer re-redacts historical records, tool-terminal projection validation now follows causal invocation identity, mutation budget accounting moved to durable `ToolStarted`, emergency summaries retain a non-empty semantic floor, duplicate-ID rejection metadata stays bounded, and traces now use event schema v2 while accepting v1.

This round uncovered one important remaining side-effect invariant problem, plus several reliability issues that are especially relevant to the fragile-local-model target.

| Priority | Finding | Main risk |
|---|---|---|
| **P0** | Mutating tool “failure” can mean partial side effects, but Rupi treats `Failed` as clean/replayable | later mutations can run against unexpectedly changed state |
| **P1** | Progress boundary proves only “a mutating tool succeeded,” not that requested work actually changed | weak models can satisfy the anti-loop guard with no-op actions |
| **P1** | Compaction destroys `payload_read` reachability | archived evidence becomes inaccessible exactly when context is tight |
| **P1** | MCP tool-catalog changes are not consumed | model can operate against stale schemas/implementations |
| **P2** | v2 schema preflight is bypassed on tail/open sequence-recovery paths | low-level callers can append behind a future-format trace |

## 1. P0 — `Failed` currently conflates “nothing changed” with “execution failed after side effects”

This is the most important finding.

Rupi currently defines:

```rust
ToolExecutionState::Failed => ReplayDecision::Replay
```

with the explicit assumption:

> “Observed failure. Uncertainty must be recorded as `Unknown`.”

That invariant holds reasonably well for built-in `write`/`edit`, because failures after their mutation boundary are intentionally converted into `ToolError::after_start()` or `Unknown`.

It does **not** hold for arbitrary shell/process execution.

`exec` and `process` spawn the command, wait for its exit status, and then do:

```rust
if status.success() {
  ToolOutcome::succeeded(...)
} else {
  ToolOutcome::failed(...)
}
```

A completely valid command can therefore do:

```sh
echo first >> important.log
some_other_mutation
exit 1
```

The filesystem was changed, but the lifecycle becomes:

```text
ToolRequested
ToolStarted
ToolFailed
```

`Failed.side_effect_uncertain()` is false.

The current tool batch only stops early for:

```rust
execution.state == ToolExecutionState::Unknown && !read_only
```

so subsequent model-requested mutations in the **same assistant batch** execute before the model has had any opportunity to inspect what the failed command actually changed.

The MCP path has the same conceptual issue. For a mutating MCP tool, Rupi currently maps:

```rust
CallToolResult { isError: true }
```

to `ToolOutcome::failed(...)`.

MCP explicitly distinguishes `isError: true` as a **tool-level failure after the tool execution path was invoked**, versus transport/protocol failures. The protocol does not give the client a rollback guarantee merely because `isError` is true. :chatgpt-content-reference{index="0"}

So this batch is currently possible:

```text
MCP mutation A
  → partially changes remote state
  → returns isError=true
  → Rupi records Failed

mutation B
  → executes immediately
```

This is effectively the Round-6 `Unknown` problem reappearing through an overly coarse state model.

### Recommended fix

Do **not** overload execution status and side-effect status.

Introduce an independent effect disposition, for example:

```rust
enum SideEffectState {
  None,       // proven no externally visible change
  Changed,    // known successful mutation
  Possible,   // execution crossed mutation boundary; partial effect possible
}
```

or equivalent metadata on `ToolOutcome`.

Then you can represent useful distinctions that the current enum cannot:

```text
argument validation failure
  execution = Failed
  effect    = None

write succeeded
  execution = Succeeded
  effect    = Changed

write same bytes
  execution = Succeeded
  effect    = None

exec exits 1 after spawning
  execution = Failed
  effect    = Possible

MCP mutating isError=true
  execution = Failed
  effect    = Possible

cancelled shell
  execution = Unknown
  effect    = Possible
```

The critical runtime rule should become:

```text
if a mutating call has effect == Possible:
    do not start the remaining mutating tail
```

The remaining committed assistant calls must still receive terminal model-visible “not executed” results, preserving protocol validity.

For `exec`/`process`, once the child successfully spawned, a non-zero exit cannot generically prove `None`.

For MCP, mutating `isError=true` should likewise be `Possible` unless Rupi has an explicit tool-specific guarantee that errors are side-effect-free.

I would also change replay semantics to depend on this dimension:

```text
Failed + None      → replay may be safe
Failed + Possible  → reconcile first
Unknown + Possible → reconcile first
```

### Required regression

A particularly useful test is:

```text
assistant response:
  call 1: exec("echo changed >> state.txt; exit 1")
  call 2: write(...)

expected:
  call 1 crosses ToolStarted
  state.txt may be changed
  call 2 never crosses ToolStarted
  terminal status requires reconciliation / effect inspection
```

Mirror it for a mutating MCP tool returning `isError: true`.

---

## 2. P1 — the progress boundary can be satisfied without actual forward progress

The progress stopgate currently asks whether a successful call is:

```rust
binding is mutating
&& name matches progress_tool_names
```

It never asks whether the successful operation **changed anything relevant**.

This is easy to satisfy accidentally with the built-ins.

For example:

```text
write(path, contents already identical)
```

currently rewrites the file and returns `Succeeded`.

Likewise:

```text
append(path, "")
exec("true")
exec("git status")
process("python", ["-c", "print('hello')"])
```

can all be successful calls to tools classified globally as mutating.

If `progress_tool_names` is empty, every permitted mutating tool counts.

So a fragile model can spend its inspection allowance, hit the progress boundary, issue a harmless `exec("git status")`, and Rupi concludes:

```text
progress_succeeded = true
progress boundary cleared
```

although the requested implementation has not advanced at all.

That substantially weakens the mechanism intended specifically to help poorly disciplined models.

### Recommended fix

The effect-state work above provides most of the answer.

Make progress require **positive effect evidence**, not just tool metadata:

```rust
progress_succeeded =
  configured_progress_tool
  && execution.state == Succeeded
  && execution.effect == Changed;
```

For built-ins:

- `edit`: successful edit → `Changed`.
- `append`: non-empty successful append → `Changed`; empty append → `None`.
- `write`: compare existing bytes first; identical target → `None`.
- `exec` / `process`: default to `Unverified`, not progress.
- MCP/extension tools: default `Unverified`; optionally allow a trusted tool definition to declare that successful completion proves progress.

I would resist trying to parse arbitrary shell commands to guess whether they mutate. That will be brittle.

A slightly richer shape could be:

```rust
enum ProgressEvidence {
  None,
  StateChanged,
  ToolAsserted,
}
```

but the important point is that `ToolMetadata.read_only == false` is a **safety classification**, not evidence of productive work.

---

## 3. P1 — L0 archived output becomes unreadable after L1/L2/L3 compaction

`payload_read` is now a genuinely useful weak-model recovery mechanism.

Its authorization currently comes from:

```rust
self.messages
  .iter()
  .filter(|message| message.role == Role::Tool)
  ...
  .filter_map(|ToolResult { recovery_ref, .. }|)
```

That means a payload ref is available only while the original reduced `ToolResult` remains in the live message window.

Suppose the model runs a command with a large result:

```text
ToolResult:
  summary...
  recovery_ref = blob:abc123
```

The model can initially call:

```text
payload_read(blob:abc123, ...)
```

But under context pressure, L1 compaction turns those old messages into a typed `ContextCapsule`.

`ContextCapsule` preserves:

```text
objective
completed_work
decisions
constraints
artifacts
unresolved
next_actions
```

but no archived-payload capability.

After that:

```text
blob still exists durably
canonical trace still knows it
payload_read authorization no longer contains abc123
```

The model loses access to evidence it already generated.

That hurts the exact target population most: a small/quantized model is more likely to need to revisit raw tool evidence and more likely to rerun an expensive command when it cannot.

### Recommended fix

Make archive capabilities part of **typed summary semantics**, not rendered prose.

For example:

```rust
struct ArchivedPayloadRef {
  reference: String,
  tool_name: String,
  note: String,
  total_bytes: Option<u64>,
}
```

and add a bounded collection to `ContextCapsule`.

During compaction:

```text
reduced ToolResult + trusted recovery_ref
→ carry ref into capsule.archived_payloads
```

Recursive compaction should preserve it.

`available_payload_refs()` should authorize refs from either:

1. live typed `ToolResult.recovery_ref`, or
2. trusted typed `ContextCapsule.archived_payloads`.

Do **not** recover capabilities by parsing summary text.

On resume, validate that a carried ref still resolves to a current-session blob before exposing `payload_read`.

This would make the L0/L1 relationship compositional instead of L1 silently disabling L0 recovery.

---

## 4. P1 — MCP tool definitions can change underneath Rupi's frozen registry binding

Rupi has strong **local registry** generation binding now, but the MCP adapter freezes the server's tool definitions only when the server is enabled:

```text
initialize
tools/list
admit tools
create McpTool wrappers
register them
```

There is no handling for MCP tool-list change notifications in the repository.

MCP explicitly supports server-advertised tool-list changes; current SDK documentation exposes `tools.listChanged` and `notifications/tools/list_changed` so clients can refresh their cached tool definitions. :chatgpt-content-reference{index="1"}

This creates a split identity:

```text
Rupi registry believes:
  mcp__db__update
  schema A
  generation 7

actual live MCP server:
  update changed to schema B / implementation B
```

Rupi's request binding remains “current” because nothing changed inside `ToolRegistry`.

The model can therefore generate arguments against schema A and Rupi dispatches them into implementation B.

This is exactly the kind of catalog churn that the new `ToolBinding` machinery was designed to prevent locally.

### Recommended fix

Two viable designs:

**Simpler/fail-closed:** freeze MCP tool catalogs for one activation.

If the server declares/supports `listChanged` but Rupi does not implement dynamic refresh, treat a received tool-list-change signal as:

```text
server catalog stale
disable server tools
require explicit re-enable/refresh
```

No existing request binding should suddenly point at new semantics.

**Better:** implement atomic refresh.

On list change:

```text
fetch complete tools/list
validate entire catalog
construct complete replacement
atomically replace the server's namespaced registry slice
```

Every replacement receives new local binding generations, so calls generated against the preceding request are correctly refused as stale before execution.

Do not modify the registry tool-by-tool during refresh; either the complete admitted catalog publishes or none of it does.

Also, if a server advertises a dynamic-catalog capability that the connected transport cannot receive, surface that explicitly rather than silently pretending the initial list is immutable.

---

## 5. P2 — event-schema version checking is not applied consistently to journal tail/open paths

PR #131 correctly added:

```rust
EVENT_SCHEMA_VERSION = 2
MIN_SUPPORTED_EVENT_SCHEMA_VERSION = 1
```

and full trace reads preflight the raw line's `v` before decoding it.

But `TraceJournal::open()` still obtains its tail through:

```rust
read_jsonl_tail(...)
```

without the schema-version preflight.

`last_valid_seq()` similarly does:

```rust
serde_json::from_slice::<TraceEntry>(&line)
```

directly.

So if a future event schema `v:3` happens to remain structurally deserializable by this binary, these low-level paths can accept it for sequence recovery.

The primary `Store::resume()` path is mostly protected because `recover_projection()` performs a full preflighted read before normal runtime work proceeds. So I would **not** call this a mainline session-safety bug.

But `TraceJournal` is a public lower-level API, and its own version contract should be internally consistent.

### Recommended fix

Use the same raw-line schema preflight for:

```text
TraceJournal::open tail recovery
TraceJournal::read_tail
last_valid_seq
```

For the backward scanner, parse only the tiny version/sequence envelope first.

An older binary should never append behind a trace whose latest complete event declares a newer schema version, even if serde happens to understand its current fields.

---

# Round-10 verification

The previous six findings look properly resolved:

- **Historical redaction:** migration is now semantics-preserving; current redaction applies only to new writes.
- **Tool call ID reuse:** projection validation consumes `started_by_terminal` produced by causal lifecycle resolution instead of scanning prior call IDs.
- **Mutation budget:** the counter increments only after durable `ToolStarted`.
- **Emergency summary:** a 512-byte maximum semantic floor is preserved, with high-priority fields rendered first.
- **Duplicate-ID normalization:** newly generated rejection reasons are recomputed under the aggregate limit.
- **Event schema:** new events emit v2; v1 remains supported by the full canonical reader.

I did not find a regression in those fixes.

# Recommended Round-11 implementation order

I would make the first two findings one coherent redesign rather than patching individual tools:

1. **Separate execution outcome from side-effect/effect evidence.**
2. Use that information for:
   - uncertain-side-effect barriers,
   - same-batch tail stopping,
   - replay decisions,
   - mutation-progress determination.
3. Make MCP mutating `isError` conservatively effect-uncertain.
4. Preserve archived payload refs through typed compaction.
5. Add MCP catalog-change handling or explicit catalog freezing.
6. Apply event-version preflight to every journal-read/recovery path.

For the first item, the regression matrix should explicitly include:

```text
Failed + proven no effect
Succeeded + actual change
Succeeded + no-op
Failed + possible partial change
Unknown + possible change
```

That will prevent the codebase from drifting back toward the current single-axis state model.

## Round-11 assessment

The project is now at a different stage than the early audit rounds. I am no longer finding missing basic harness machinery or broad provider/runtime holes.

The remaining important static issue is that **“tool execution result” and “world-state effect” are still represented as though they were the same thing**. Fixing that would close the strongest conceptual gap left in the mutation/recovery architecture and would simultaneously make the progress boundary substantially more meaningful for weak models.

After that fix, I would indeed switch the next major round toward controlled live quantized-model experiments: deliberately malformed calls, repeated no-op actions, context-pressure recovery, large-output rehydration, and local-server tool-ID/catalog oddities.
