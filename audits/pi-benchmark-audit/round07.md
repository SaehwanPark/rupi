## Round 7 audit

I audited current `main` at **`b19d902d22dcfe56d95128bf23fc3a8ab3c5fef3`**, including the Round-6 implementation in PR #126 and the reconciliation/replay follow-up tests in PR #127.

Round 6 was implemented broadly and carefully. The cancellation split, mutating-`Unknown` barrier, per-turn tool budgets, output-headroom reservation, provider-aware prompt estimation, estimator calibration, strict config parsing, and `payload_read` are all genuinely present rather than papered over with tests.

Round 7 nevertheless exposes one **P0 recovery dead-end** and several P1 cross-layer problems.

| Priority | Finding | Consequence |
|---|---|---|
| **P0** | Interrupted mutation requiring manual inspection has no resolution path | A crash during an arbitrary mutation can permanently brick the resumable session |
| **P1** | Blocked prompts are persisted before the reconciliation gate | Stale/duplicate user instructions execute after the barrier is cleared |
| **P1** | Reconciliation reopens an already-completed turn | Violates the event model's `TurnCompleted` finality invariant |
| **P1** | Length recovery compares against effective instead of desired output | Context-clamped truncations that could be fixed by compaction are abandoned |
| **P1** | Tool exposure ignores remaining per-turn tool budget | Models are advertised tools Rupi already knows cannot run |
| **P1/P2** | `payload_read` capability drifts from current model-visible context | Stale refs survive compaction; visible refs can expire unexpectedly |
| **P2** | One implausible usage report can poison calibration for eight requests | Fragile local-server accounting can cause excessive compaction/refusal |

---

## P0 — interrupted mutating calls can enter a permanent reconciliation dead-end

The Round-6 live `Unknown` path is good. A live mutating call ending `Unknown` becomes an `UnresolvedSideEffect`, the rest of its batch is closed without execution, and `/reconcile` can eventually clear it.

The **crash/resume path is different**.

For an interrupted call reconstructed as:

```rust
InterruptedToolCall {
  state: Started,
  read_only: false,
  ...
}
```

`reconcile_interrupted_tools()` invokes the tool-specific reconciler. If it returns:

```rust
ReconciliationStatus::RequiresManualInspection { .. }
```

or `Diverged`, the runtime currently does essentially:

```rust
self.recovery_blocked = true;
return Err(TurnError::Sink(
  "cannot continue session: interrupted mutating tool ... requires manual inspection"
));
```

That creates three problems simultaneously.

First, the interrupted call is **not converted into the same resolvable `UnresolvedSideEffect` representation** used for live `Unknown` outcomes.

Second, `/reconcile list` only exposes:

```rust
session.unresolved_side_effects()
```

and `/reconcile ... committed|unmodified` only calls `confirm_side_effect_resolution()` over that collection. The interrupted call therefore cannot be manually resolved through the UI.

Third, `TurnError::Sink` is explicitly non-recoverable:

```rust
pub fn session_recoverable(&self) -> bool {
  !matches!(self, Self::Sink(_))
}
```

and interactive mode classifies it as `AfterTurn::Failed`, exits the interactive path, and does not treat it as `NeedsReconciliation`.

This is especially important for `exec`: after a process starts and the harness crashes or loses its completion boundary, automatic reconciliation will often be impossible by nature. That should be a normal safety-barrier case, not a permanently unusable session.

PR #127 actually strengthens my confidence that this is real: the test `resumed_manual_tool_reconciliation_blocks_provider_contact` verifies that the session remains blocked on subsequent turns, but there is no corresponding path demonstrating that the operator can ever unblock that interrupted lifecycle.

### Recommended implementation

Unify these two states conceptually:

```text
live mutating ToolUnknown
            \
             → UnresolvedSideEffect → reconciliation → continue
            /
resumed mutating Started/Unknown
```

When resume discovers that an interrupted mutation cannot be automatically reconciled, durably settle its open lifecycle into an explicit uncertain terminal state instead of returning `Sink`.

Conceptually:

```rust
let status = tools.reconcile_with_risk(...)?;

match status {
  Committed => settle_succeeded(...),
  Unmodified => settle_failed_no_effect(...),

  Diverged | RequiresManualInspection => {
    let unknown = settle_interrupted_as_unknown(...)?;
    unresolved_side_effects.push(
      UnresolvedSideEffect::from_interrupted(call, unknown)
    );
    return NeedsReconciliation;
  }
}
```

The emitted `ToolUnknown` should retain the exact original request/start identities. The operator can then use the same `/reconcile <request-event-id> committed|unmodified` command as for a live unknown.

Only an actual inability to durably record that transition should remain `TurnError::Sink`.

A resumed arbitrary `exec` should therefore behave like:

```text
resume
→ inspect interrupted exec
→ cannot determine effect
→ durable ToolUnknown / reconciliation barrier
→ UI remains open
→ /reconcile list shows it
→ human inspects environment
→ /reconcile ... committed
→ next turn proceeds
```

I would treat this as the Round-7 merge blocker.

---

## P1 — prompts submitted while reconciliation is blocked are silently queued

For the newer `unresolved_side_effects` path, the ordering in `run_turn_with_external_context()` is currently:

```text
create turn
reconcile interrupted lifecycles
append external context
append UserMessage
progress.on_user_message(...)
reconcile unresolved side effects
if unresolved → NeedsReconciliation
```

So consider:

```text
Turn 1:
  write → Unknown
  NeedsReconciliation

User types:
  "continue implementing the parser"

Rupi:
  persists that UserMessage
  discovers reconciliation remains manual
  performs zero model requests
  returns NeedsReconciliation

User runs /reconcile ...

User then types:
  "now run the tests"
```

The next provider request can receive both:

```text
continue implementing the parser
now run the tests
```

even though the first instruction was presented to the user as a turn that **did not run**.

Repeated attempts while blocked make this worse:

```text
continue
please continue
try again
okay continue now
```

All can accumulate in canonical/model-visible history and become active simultaneously after reconciliation.

For weak models, this is particularly undesirable. Multiple stale imperatives are exactly the kind of context ambiguity that produces duplicated mutations or confused sequencing.

### Recommended implementation

Reconciliation admission needs to precede user-turn admission:

```text
begin candidate turn
reconcile safety barriers
  ↓
manual resolution needed?
  yes → return NeedsReconciliation WITHOUT accepting input
  no  → accept external context + UserMessage
        → provider work
```

Do the same for external context; don't silently queue connected/retrieved evidence for a turn that was never allowed to begin.

If explicit queuing is desirable eventually, model it explicitly as something like `PendingTurn`, show it in the UI, and resume exactly that request after reconciliation. Don't get queue semantics accidentally from appending a normal `UserMessage`.

A critical regression test is:

```text
Unknown mutation
→ run_turn("stale instruction") => NeedsReconciliation
→ resolve
→ run_turn("fresh instruction")
→ first provider request after resolution contains "fresh instruction"
→ does NOT contain "stale instruction"
```

---

## P1 — reconciliation events violate `TurnCompleted` finality

The core event documentation says:

```text
TurnCompleted
Ordering: last event of that turn.
```

But `record_side_effect_reconciliation()` currently creates the later observation with:

```rust
Some(side_effect.turn_id.clone())
```

where `side_effect.turn_id` belongs to the **old turn that already emitted `TurnCompleted(NeedsReconciliation)`**.

The resulting journal can conceptually be:

```text
turn A / ToolUnknown
turn A / TurnCompleted(NeedsReconciliation)

... later ...

turn A / ToolReconciliationObserved
```

This means `TurnCompleted` is no longer the last event belonging to turn A.

The `parent_event_id` already provides the correct causal relationship:

```text
ToolReconciliationObserved
    parent → original ToolUnknown
```

Reusing the old turn identity adds no information and weakens an otherwise very useful event invariant.

This can eventually affect trace grouping, branch calculations, UI rendering, metrics such as per-turn activity, and any consumer reasonably assuming that a completed turn never resumes producing events.

### Recommended implementation

Treat reconciliation as a **session-level follow-up observation**, not another event inside the old turn:

```rust
let mut envelope = self.new_envelope_with_parent(
  None,
  AgentEvent::ToolReconciliationObserved(observed),
  Some(side_effect.unknown_event_id.clone()),
);
```

If later you decide automatic reconciliation itself deserves a first-class operation identity, give it a separate reconciliation/operation ID. Don't reuse the closed generation turn.

A strong generic test would enforce:

```text
for every TurnCompleted(T):
  no later event has turn_id == T
```

That invariant is valuable well beyond reconciliation.

---

## P1 — context-clamped length stops still use the wrong recovery ceiling

Round 6 now correctly retains both:

```rust
desired_output_tokens
max_output_tokens // effective wire ceiling
```

but output-truncation recovery still checks only:

```rust
let requested = request.max_output_tokens?;
let actual = usage.output_tokens?;

usage.stopped_at_output_limit() && actual < requested
```

Suppose:

```text
model desired maximum     = 8,192
current context permits   = 2,048
wire max_output_tokens    = 2,048

provider output           = 2,048
finish_reason             = length
```

Then:

```text
actual < effective
2048 < 2048
→ false
```

so Rupi declares the response unrecoverable.

But old pre-turn history might be safely removable. After compacting it, the next request could support, for example:

```text
effective output = 7,000
```

The very reason Rupi now stores the desired and effective limits separately is to distinguish those cases.

Pi explicitly encodes this distinction. Its `isRecoverableLength()` documentation says that `desiredMaxOutput` must be the **original limit before context-based clamping**, and recovery checks output against that desired value rather than the clamped request ceiling.

### Recommended implementation

Classify recoverability against the original desired output:

```rust
let desired = request.desired_output_tokens?;
let effective = request.max_output_tokens?;
let actual = usage.output_tokens?;

if usage.stopped_at_output_limit() && actual < desired {
  // one bounded compact-and-retry opportunity
}
```

Keep `effective` as evidence and diagnostics:

```text
output stopped at 2048 tokens;
request was context-clamped from desired 8192 to effective 2048
```

Then compact pre-turn history once and rebuild the request. Recovery remains subject to all the protections already added:

```text
same model
one recovery maximum
no irreversible text/reasoning surfaced
no truncated tool execution
only safe prior history removed
```

If:

```text
desired = effective = actual = 8192
```

there is still no recovery.

This is a relatively small code change with disproportionately useful behavior on small-context local models.

---

## P1 — the advertised tool set ignores the remaining tool budget

Round 6 correctly enforces budgets at admission time. However `exposed_tools_for()` currently looks at:

```text
model tool capability
tools_enabled
allow/deny policy
approval availability
progress boundary
payload_read
```

but not:

```text
tool_calls_seen
max_tool_calls
mutating_tool_calls_seen
max_mutating_tool_calls
```

That creates several avoidable contradictions.

The most obvious one is configuration:

```json
{
  "max_mutating_tool_calls_per_turn": 0
}
```

whose field documentation explicitly says:

> Zero disables mutations.

Yet a mutating tool can still be advertised in the very first model request. Rupi invites the model to call it, then deterministically refuses it.

Likewise:

```json
"max_tool_calls_per_turn": 0
```

still allows tool schemas to be advertised.

There is also a dynamic version. If a model successfully consumes exactly all 16 mutating slots, no denial has happened yet, so the loop may issue another model request. That request still exposes mutation tools even though the runtime already knows every such call must fail.

This also intersects with the progress-boundary fix. `effective_progress_tools()` derives from this same exposed set. An active progress boundary can therefore believe:

```text
"write is an executable progress tool"
```

when the remaining mutation budget is actually zero.

That partially reintroduces the Round-5 “known impossible boundary” problem.

### Recommended implementation

Tool exposure should represent **what can execute now**, with admission-time validation remaining a second safety layer.

Conceptually:

```rust
let total_remaining =
  self.tool_calls_seen < self.max_tool_calls;

let mutations_remaining =
  self.mutating_tool_calls_seen < self.max_mutating_tool_calls;
```

Then:

```text
total remaining == 0
→ expose no tools

total remains, mutation remaining == 0
→ expose only read-only tools (+ eligible payload_read)

both remain
→ normal policy
```

This naturally fixes progress-boundary satisfiability because `effective_progress_tools()` will no longer find mutation tools whose budget is exhausted.

If a progress boundary becomes impossible specifically because its mutation budget has been spent, I would terminate as `ToolBudgetExhausted` rather than generic semantic failure.

Keep `admit_tool_calls()` unchanged as the authoritative backstop because models/providers can still return unexpected calls.

---

## P1/P2 — `payload_read` references are not synchronized with live model context

The new `payload_read` mechanism is useful and nicely constrained: opaque session refs, bounded 4 KiB reads, a 16 MiB payload ceiling, read-only execution, and resume reconstruction from visible reduced tool results.

The resume behavior is actually stronger than the live behavior.

On resume, Rupi deliberately reconstructs available refs only from:

```rust
ContentBlock::ToolResult(result)
  if result.reduced
```

still present in the model-visible window.

The test even expresses the intended behavior clearly:

```text
resume_reexposes_only_reduced_payload_refs_still_in_model_context
```

During a live session, however, `payload_read_refs` is an independent FIFO. A newly archived result calls:

```rust
remember_payload_ref(...)
```

but ordinary eviction, summarizing compaction, and checkpoint transitions do not appear to prune the deque when the corresponding ToolResult leaves model-visible history.

So:

```text
large tool result
→ ref ABC exposed

later compaction removes that result from context

payload_read_refs still contains ABC
→ payload_read still exposed
→ ABC can still be fetched
```

This weakens the semantic meaning of context reduction. The model can rehydrate evidence that its current context no longer contains merely because it retained or reproduced the opaque identifier.

There is an inverse inconsistency as well:

```rust
MAX_AVAILABLE_PAYLOAD_REFS = 128
```

If more than 128 recoverable reduced results remain visible, the FIFO drops the oldest reference even though its still-visible ToolResult continues claiming:

```text
Archived output is available through payload_read: ref=...
```

So live history can promise a recovery capability the runtime has silently revoked.

### Recommended implementation

Make authorization derive from the **current semantic context**, not a monotonic side cache.

A helper such as:

```rust
fn available_payload_refs(&self) -> HashSet<&str>
```

can scan current reduced ToolResult blocks, or maintain an indexed side structure that is updated atomically on every message-window mutation.

Execution should validate against that authoritative current set.

If you retain a hard cardinality cap, revocation must be explicit: either stop printing recovery notices after the cap, or alter/remove the notice when a ref becomes unavailable. A visible marker should never lie.

This is P1 if you consider context reduction an access/admission boundary; otherwise it is a strong P2 consistency issue. Given Rupi's deliberate session-scoped recovery semantics, I lean toward fixing it in this round.

---

## P2 — calibration should distrust extreme provider accounting

The new estimator calibration is directionally good:

```text
provider/model/dialect scoped
last 8 observations
high-side maximum
never calibrates downward
maximum ratio capped at 10×
```

That is conservative for honest providers.

Fragile local servers are exactly where usage accounting can occasionally be wrong, though. One response claiming:

```text
raw estimate = 4,000
reported prompt = 39,000
```

causes roughly a 9.75× multiplier to remain active until that sample exits the eight-observation window.

That can make an otherwise usable 32k model refuse nearly every subsequent request.

I would not make this a blocker, but before empirical weak-model benchmarking I would add plausibility checks. Reject or quarantine observations inconsistent with the configured context window or internally inconsistent provider totals, and require additional evidence before adopting very large ratio jumps. A diagnostic such as “ignored implausible prompt-usage calibration sample” would also make troubleshooting much easier.

---

## What Round 6 got right

I specifically **do not** see a need to reopen several earlier findings.

The linked cancellation design works correctly through Rupi's built-in OpenAI-compatible adapter: collector/request aborts no longer mutate the user's parent token, while the adapter consistently polls the linked token via `is_cancelled()`. Provider-specific request estimation now accounts for strict-schema mapping rather than pretending the logical Rupi structure is the exact wire prompt. The mutating-`Unknown` live barrier genuinely prevents the rest of its batch from starting. Tool-budget admission counts malformed/rejected calls conservatively. Unknown config keys now fail rather than silently selecting defaults. And `payload_read` is much better than simply telling the model that unavailable bytes exist somewhere.

PR #127's additional durable reconciliation/replay tests were also useful; the Round-7 findings above are mostly the next layer of state-machine behavior rather than failures of those tests.

## Recommended Round-7 implementation order

1. **Unify interrupted mutations with the resolvable `UnresolvedSideEffect` path.** Eliminate the `RequiresManualInspection → TurnError::Sink` dead-end.
2. **Run reconciliation admission before persisting the new user turn or external context.**
3. **Make reconciliation observations session-level so `TurnCompleted` remains final for its turn.**
4. **Use original `desired_output_tokens` to classify recoverable length stops.**
5. **Filter exposed tools using the remaining total/mutating tool budgets, including progress-boundary checks.**
6. **Bind `payload_read` authorization to refs that remain present in the active model context.**
7. Harden calibration against implausible provider usage reports.

The regression suite I would require for this slice is: resumed interrupted `exec` → manual barrier → `/reconcile` → successful continuation; blocked prompt not appearing after reconciliation; no event for turn `T` after `TurnCompleted(T)`; desired 8192/effective 2048/actual 2048 length stop successfully compacting and retrying once; zero mutation budget exposing no mutating schemas; exactly exhausted mutation budget removing mutations from the next request; progress boundary failing before dispatch when its mutation budget is gone; and compaction immediately revoking an archived ref that is no longer model-visible.

### Round-7 assessment

Rupi is now at the point where the audit is finding **state-transition inconsistencies rather than missing core harness capabilities**. That is a meaningful improvement over the early rounds.

I would still hold off on declaring the safety architecture settled because the interrupted-mutation dead-end is significant for precisely the workload Rupi is targeting: long-running local agents that may be killed, time out, crash, or lose a tool completion boundary. Once that P0 and the adjacent reconciliation semantics are fixed, I would make Round 8 much more empirical: run actual heavily quantized local models and measure malformed-call recovery, redundant tool calls, mutation attempts per successful task, requests-to-completion, context-overflow incidence, strict-sampling benefit, and recovery behavior under deliberately interrupted generations.
