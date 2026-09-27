# Round 10 audit

I re-audited current `main` at **`c01e3826f12816d69e79dd71711bd6a1eff686ae`**, including merged PR **#130**, which addresses Round 9. The Pi reference is still `earendil-works/pi` at **`2b0a123de98318c2ff8069661721ce0c3794c34e`**.

Round 9 landed well. Durable tool fingerprints, schema-v5 message authority, canonical runtime-control events, typed recursive compaction, runtime-level duplicate-ID normalization, legacy-origin handling, and stale-binding rejection are all materially implemented.

I do **not** see a new P0 this round. I do see three P1 issues worth fixing before moving fully into empirical weak-model benchmarking.

| Priority | Finding | Main consequence |
|---|---|---|
| **P1** | Schema migration re-redacts old semantic projections using today's policy, but not their canonical trace | A config change can make migration permanently brick session resume |
| **P1** | Projection validation still detects `ToolStarted` globally by provider `call_id` | Reused `call_1` IDs can make a valid session appear corrupt |
| **P1** | Mutation budget advertised as started-call budget is spent by denied/preflight-rejected calls | Zero-start attempts can exhaust mutation capacity |
| **P1/P2** | Emergency overflow recovery permits an empty rendered summary | Runtime retains semantic history that the model doing the recovery cannot see |
| **P2** | Duplicate-ID normalization can expand rejected reasons beyond the aggregate response bound | Custom providers can amplify bounded rejection metadata after normalization |
| **P2** | Event format gained new semantics while `EVENT_SCHEMA_VERSION` remains 1 | Trace compatibility/versioning contract is becoming ambiguous |

## 1. P1 — session-schema migration can corrupt an otherwise valid session when redaction settings changed

This is the most consequential Round-10 durability issue.

`Store::resume()` correctly notices an older semantic-session version and loads the canonical trace so that origins can be migrated safely. It then calls:

```rust
SessionLog::migrate_to_current_with_trace(
  ...,
  self.policy.redaction.clone(),
  ...
)
```

Inside the migration, however, every historical semantic record is passed through the **currently configured** policy:

```rust
migrated.push(sanitize_record(&record, &redaction)?);
```

That is not merely structural schema migration. `RedactionPolicy::apply_json()` can actively rewrite arbitrary historical strings according to today's:

```text
redaction.enabled
redaction.literals
redaction.min_secret_len
redaction.scan_environment
current process environment
```

Meanwhile the canonical trace is not rewritten.

Consider a v4 session originally written with:

```text
User: deploy using project-token-abcdef123456
```

Later the operator adds that literal to the redaction configuration and upgrades/resumes:

```text
semantic v4:
  deploy using project-token-abcdef123456

canonical trace:
  deploy using project-token-abcdef123456
```

Migration rewrites only the semantic side:

```text
semantic v5:
  deploy using [redacted:field]

canonical trace:
  deploy using project-token-abcdef123456
```

Then the new, stronger projection validator correctly observes:

```text
semantic UserInput != canonical UserInput
```

and refuses restore.

Worse, migration has already atomically replaced the semantic log and stamped its header as v5. The next startup therefore no longer considers the session eligible for migration. The session can remain stuck until manually repaired.

### Implementation approach

Schema migration should be **semantics-preserving**. Do not apply the current redaction policy to historical values while performing a schema upgrade.

Transform only the fields actually required by the migration:

```text
v4 origin → v5 canonical origin
legacy summary → typed summary, when provable
header version → 5
```

but preserve already-durable text byte-for-byte.

Current redaction policy should apply only to **new durable writes**.

If historical re-redaction is eventually wanted, make it a separate explicit operation that transactionally rewrites all coupled state:

```text
trace
session projection
externalized blobs
summary blobs
checkpoint capsules
WAL/recovery metadata
```

and validates the complete replacement before publishing it.

The regression test should create a v4 session under one redaction policy, reopen under a stricter policy containing a literal from the old user message, migrate, and verify both that resume succeeds and the old projection still agrees with canonical history. Then append a new message containing that literal and verify that the **new** record uses the stricter policy.

---

## 2. P1 — one remaining store check still treats tool-call IDs as session-global

Most of Rupi now correctly understands that provider tool-call IDs are response-scoped. Replay was fixed in Round 8 and the lifecycle scanner uses causal request-event identity.

One store integrity check has not made the same transition.

For a `ToolFailed` without semantic ToolResult projection, it asks:

```rust
let started = entries.iter().any(|candidate| {
  candidate.envelope.meta.seq < entry.envelope.meta.seq
    && matches!(
      &candidate.envelope.event,
      AgentEvent::ToolStarted(started)
        if started.call_id == failed.call_id
    )
});
```

`ToolUnknown` uses the same pattern.

The intent is sensible: Rupi permits a never-executed tool fragment from an incomplete model response to remain trace-only, whereas a tool that actually crossed `ToolStarted` needs a model-visible terminal result.

But the query means:

> Has any earlier invocation anywhere in this session with this provider ID ever started?

rather than:

> Did this specific invocation start?

A local provider that emits the simple ID `call_1` on every round creates:

```text
Round A:
  ToolRequested call_1
  ToolStarted   call_1
  ToolCompleted call_1

Round B:
  ToolRequested call_1
  response truncates before execution
  ToolFailed call_1
    trace-only, correctly never started
```

During restoration, Round A's start satisfies the Round B search. Rupi then concludes Round B's failure is illegally missing its ToolResult projection and rejects an otherwise valid session.

This is particularly relevant for the weak/local-server target because simple monotonically reset IDs such as `call_1` are entirely plausible.

### Implementation approach

Use the causal lifecycle Rupi already has.

A terminal tool event should resolve to its exact `ToolRequested` event via:

```text
ToolFailed.parent
       │
       ├─ ToolStarted event → ToolStarted.parent → ToolRequested
       │
       └─ ToolRequested event directly, for proven no-start terminalization
```

Then:

```rust
let invocation_started =
  terminal_parent_is_tool_started
  || request_has_child_tool_started;
```

Do not scan historical events merely by provider call ID.

For legacy parentless events, retain the existing conservative policy used elsewhere: use call ID only when exactly one currently open candidate can match; ambiguity is a recovery error.

The key paired tests are:

```text
earlier call_1 starts
later call_1 never starts + trace-only failure
→ restore succeeds
```

and:

```text
later call_1 really starts
later terminal projection removed
→ restore fails
```

That will eliminate one of the final places where provider correlation identity is accidentally treated as Rupi invocation identity.

---

## 3. P1 — mutation budget still counts calls that provably never started

Round 9 improved this considerably. Mutation accounting no longer happens as soon as a model merely requests a mutating tool, and stale tool-definition replacement refunds its reservation.

However, the implementation currently reserves a slot before actual dispatch:

```rust
if reserve_mutation_budget {
  self.mutating_tool_calls_seen =
    self.mutating_tool_calls_seen.saturating_add(1);
}
```

It later refunds only:

```rust
if reserve_mutation_budget && execution.stale_binding {
  self.mutating_tool_calls_seen =
    self.mutating_tool_calls_seen.saturating_sub(1);
}
```

Between those two points, `ToolRegistry::dispatch()` can prove a call never started for several other reasons:

```text
argument validation failure
tool-specific preflight failure
interactive user denial
approval gate refusal
cancellation before execution
```

Those return `started == false`, but their mutation reservation survives.

That contradicts Rupi's own user-facing error text:

> per-turn mutating-tool budget of N **started calls**

For example, with a mutation budget of 1:

```text
model requests valid mutation A
human denies A
ToolStarted count = 0
mutation budget = 1/1

model later requests mutation B
human would approve B
→ B refused as budget-exhausted
```

For a fragile model, malformed/preflight-invalid calls can produce the same effect even without a human denial.

### Implementation approach

The cleanest definition is:

> Mutating-tool budget counts durable `ToolStarted` boundaries.

Therefore increment it in the start callback, alongside the existing `tool_calls_started` handling, rather than reserving before dispatch.

If reservation is operationally easier, refund it for every:

```rust
!execution.started
```

not merely `execution.stale_binding`.

Tests should cover interactive denial, argument-validation refusal, preflight rejection, cancellation before start, stale binding, and a started mutation that subsequently fails or becomes `Unknown`. Only the last case should consume a mutation-start slot.

This also makes progress-boundary reasoning cleaner because:

```text
mutating_tool_calls_seen == max
```

would then unambiguously mean actual mutation executions reached their configured limit.

---

## 4. P1/P2 — emergency compaction can reduce prior semantic history to zero visible bytes

The new `DerivedSummary::Rendered` design is otherwise strong. Rupi can shorten the **rendering** while keeping the complete typed `DerivedSummary` attached for future recursive compaction.

The overflow-recovery loop currently keeps halving the rendered summary:

```rust
let mut summary_bytes = source_text.len();

for _ in 0..=64 {
  let text =
    truncate_utf8_to_bytes(&source_text, summary_bytes).to_string();

  let summary = DerivedSummary::Rendered {
    summary: Box::new(source.clone()),
    text,
  };

  if request_fits {
    accepted = Some(summary);
    break;
  }

  ...
}
```

`summary_bytes == 0` is a valid candidate.

Therefore a severely pressured request can become:

```text
durable semantic summary:
  objective = implement parser
  constraint = preserve API
  unresolved = tests not run

provider-visible summary:
  ""
```

Rupi's durable state says history was semantically preserved, but the model being asked to continue the task sees none of it.

For a strong model this is bad continuity. For a small quantized model it is considerably worse because these models benefit disproportionately from explicit task anchors.

### Implementation approach

Do not treat an empty rendering as successful history-preserving recovery.

For `DerivedSummary::Capsule`, create a priority renderer rather than blind byte-prefix truncation. Preserve in order something like:

```text
objective
critical user constraints
unresolved/uncertain side effects
current state
next action
important artifacts
completed details
```

Then establish a small minimum semantic representation. If even that plus the protected current-turn suffix does not fit, return context overflow rather than pretending compaction recovered usable context.

For an opaque custom summary, a bounded prefix may be acceptable, but again there should be a nonzero minimum or an explicit “prior opaque context omitted due hard context limit” marker.

One valuable invariant would be:

> Any successful compaction that claims to replace nonempty semantic history must emit a nonempty model-visible representation of that history.

The hidden typed state should aid future compaction and crash recovery; it cannot substitute for information the **current inference** never receives.

---

## 5. P2 — duplicate-ID normalization bypasses the aggregate rejection-reason limit it follows

Collector ingestion now enforces:

```text
≤ 4 KiB rejection reason per call
≤ 64 KiB rejection reasons per response
```

Good.

But normalization occurs afterward.

Suppose a custom provider produces 128 calls under one reused ID, including one already rejected event carrying a 4 KiB reason. During ingestion, the aggregate reason counter sees approximately 4 KiB.

Then `normalize_tool_call_ids()` does:

```rust
let provider_rejection =
  self.rejected_calls.remove(&provider_id);

for index in indices {
  ...
  let reason = provider_rejection
    .as_ref()
    .map(|reason| {
      format!(
        "{duplicate}; original rejection: {reason}"
      )
    });
  self.rejected_calls.insert(new_id, reason);
}
```

So the same original 4 KiB reason can be copied into every normalized collision.

The effective post-normalization structure can reach roughly:

$$
128 \times 4\text{ KiB} \approx 512\text{ KiB}
$$

despite the intended 64 KiB aggregate bound.

It does not execute anything, so this is not a safety-critical problem, but it reopens an avoidable memory/context amplification path specifically through malformed providers.

### Implementation approach

Normalize against the same aggregate accounting used during collection.

An even simpler answer is not to repeat the original rejection for every collision. Use:

```text
provider reused invocation id 'call_1'; no colliding call executed
```

for every member, and perhaps include the original provider rejection only once.

After normalization, assert:

```rust
sum(rejected_calls.values().map(String::len))
  <= MAX_TOOL_REJECTION_REASON_BYTES_TOTAL
```

as a final invariant.

---

## 6. P2 — the event schema version no longer represents the actual format generation

Session state correctly moved from v4 to **v5** because the persisted semantics changed.

The canonical event stream gained significant new format semantics too:

```text
UserInput
RuntimeControlInjected
ToolRequested.definition_fingerprint
ContextCompactionEpoch.derived_summary
```

but still declares:

```rust
pub const EVENT_SCHEMA_VERSION: u32 = 1;
```

and new events are emitted with:

```json
"v": 1
```

This is mainly a compatibility/design problem today, not a live correctness bug in the current build. Current Rupi correctly validates that every event has its expected version.

The issue is that an older Rupi build sees a claimed v1 record containing enum variants it never knew existed. Instead of being able to say “trace schema v2 is unsupported,” deserialization can simply classify it as malformed.

The reverse compatibility is already effectively versioned behavior: current Rupi has defaults and explicit legacy handling. The file's explicit `v` field should communicate that contract.

### Implementation approach

I would make these new events **event schema v2**.

The reader should accept both supported generations, normalize v1 events into the contemporary internal representation where possible, and reject future versions explicitly.

Because the trace is append-only, a resumed historical file can legitimately contain:

```text
v1
v1
v1
v2
v2
```

so this need not imply rewriting old trace history.

Longer term, decoding the minimal envelope/version before deserializing the event variant would also permit a useful:

```text
unsupported trace schema version 3
```

instead of an opaque unknown-variant JSON decode error.

---

## What I consider closed from Round 9

The core Round-9 concerns themselves are handled convincingly.

The built-in mutating tools now have durable definition identities in addition to schema/risk fingerprints, so a changed implementation cannot silently reconcile an older uncertain call merely because its name matches. MCP and Pi-extension tools currently do **not** declare stable definition identities; that means interrupted mutations from them conservatively fall back to manual inspection after restart. Given that they also lack an automatic tool-specific `reconcile()` implementation, that is the correct safe behavior for now.

Message authority is substantially improved: genuine user input and runtime control now have separate canonical events, semantic role/origin combinations are validated, external context keeps typed attribution, and schema-v5 restoration rejects origin tampering.

The typed `DerivedSummary` architecture also solves the fundamental recursive-compaction problem from Round 9. Built-in capsules can now survive multiple L1/L2/L3 transformations without parsing their rendered prompt prose, and opaque custom summaries remain explicitly untrusted rather than becoming user instructions.

Runtime-wide duplicate tool-ID handling also closes the custom-provider bypass I identified in Round 9.

## Recommended Round-10 implementation order

I would fix the **projection migration + tool lifecycle correctness** together first: stop current-policy re-redaction during schema migration, then replace the remaining call-ID-only start lookup with causal invocation identity. Both affect whether a valid durable session can be resumed at all.

Next, make the mutation budget count actual `ToolStarted` boundaries. Then put a minimum semantic visibility rule on emergency compaction.

The rejection-reason normalization bound and event-schema bump are suitable smaller follow-ups in the same PR.

For tests, the most valuable combined adversarial fixture would deliberately use a provider that emits `call_1` on every round, rejects/malforms some calls, causes one truncated response, and then resumes the persisted session under a changed redaction configuration. That single fixture would exercise several invariants in exactly the sort of degraded local-provider environment Rupi is intended to tolerate.

### Round-10 assessment

There is an important change in the audit signal this round: **I found no new high-concern autonomous side-effect hole**. The major execution barriers now look substantially more mature.

The P1s above are mostly durability and accounting consistency issues—still worth fixing, especially the first two, but narrower than the P0/P1 execution problems from earlier rounds.

After these are resolved, I would make the following round predominantly empirical rather than another broad static audit. The repository has reached the point where the higher-value question is increasingly whether these mechanisms actually improve completion behavior for moderately/severely quantized local models under repeated controlled trials, rather than whether another major safety primitive is absent.
