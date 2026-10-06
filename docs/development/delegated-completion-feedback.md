# Bounded caller-delegated completion feedback

Implement exactly this plan. Do not broaden scope. If the plan conflicts with the
codebase, stop and report the conflict instead of improvising. Report files changed,
checks, deviations and unresolved risks. Risk: high (closure, authority and effects).

Retry24 closes Completed with failed public tests/acceptance despite successful file
tools and a review. Source verifies that permitted check feedback arrives only after
closure. No generated contents/diagnostics were inspected by the parent; the semantic
application defect is unknown. This change supplies caller observations during the same
turn, without moving domain verification or command execution into core.

## Core contract

1. Add optional `limits.max_completion_checks_per_turn` (None/default disabled;
   configured1..16), TurnLoop builder and typed request/result/status interface exported
   by rupi-runtime. A default TurnProgress checker returns Unavailable, never fake pass.
2. For an ordinary otherwise accepted text-only response, after required-progress
   rejection and before optional one-shot review, invoke the configured caller checker.
   Include ordinal and observed remaining native time; pass the current CancelToken.
   Count every invocation, including unavailable results. No tools/finalization skips it.
3. Passed permits existing review/closure; Failed appends feedback and continues normal
   inference/repair only while request/time/check budgets permit. Recheck every later
   accepted candidate, including after review; do not cache a pass across work.
   Failure on the last check ends CompletionCheckExhausted. Unavailable ends semantic
   failure without inference, retry or failover. Cancellation/deadline precede use of a
   result. New turns renew allowance; no old check or timer is automatically replayed.
4. Record a typed CompletionCheck runtime control with static guidance and put bounded
   feedback in a separate ExternalContextRetrieved/message with source
   `delegated_completion_check`, citation/ordinal/status/elapsed metadata. Feedback is
   external data, not user instructions, native rationale or correctness certification.
   Bound UTF-8 feedback to16KiB; oversize becomes Unavailable. Preserve original native
   assistant evidence. No new tool dispatch or execution authority is introduced.
5. Checker implementations only deliver observations and must not mutate the canonical
   task workspace. The host owns/isolate its verification effects. Unknown model-tool
   effects still stop before checking/inference; incomplete calls remain unexecuted.
   An unavailable host observation stops this turn, never blindly replays host work.

## Explicit CLI feedback protocol

- Add run-only `--completion-feedback-dir ABSOLUTE_PATH`. Require configured check
  allowance, a canonical directory outside the workspace, and disabled outside read/
  write access. Validate composition before contacting a provider. Default/interactive
  paths retain no checker and reject configured allowance without a supplied handler.
- A lazy CLI adapter writes atomic request-UUID.json into the caller-owned directory,
  then awaits matching atomic reply-UUID.json. Version1 request: request_id, process_id,
  ordinal, workspace, wait_timeout_ms. Reply: version, request_id, status, feedback.
  Unknown fields/version, mismatched identity, malformed/non-UTF8/oversized payload,
  IO failure or timeout is Unavailable; cancellation cooperates with the current token.
  Hard-bound reply bytes to128KiB, parsed feedback16KiB, wait to300s or the shorter
  remaining native duration. No command is chosen or executed by CLI/core.
- Use fresh UUID correlation, create-new temporary files plus rename, and retain
  mailbox artifacts. Never consume an unrelated/stale reply. The directory is a
  trusted caller channel; it is protected from model file tools, not an OS sandbox.

## Benchmark host adapter

- Add Case10CompletionChecks (0/default disabled, positive1..16). Native Rupi config
  and run flag select a fresh mailbox outside project; native Pi selection is null.
- Extend Invoke-External with an optional bounded while-running callback, preserving
  its default wait path. The Case10 host handles each valid current-process request
  once, snapshots only public project files into an owned directory outside model
  workspace, then runs the existing permitted project tests/help on that snapshot.
  The model still has only read/write/edit/grep; it cannot request check commands.
- Check requested public test/init/README presence in the host, require tests actually
  ran, and report public failures with bounded existing-style diagnostics. Preserve
  assertions and prohibit weakening tests in static guidance. No oracle is copied,
  run or exposed through this callback. Independent acceptance stays after the turn.
- Snapshot effects and subprocess cleanup belong to the host. Bound each public
  command by remaining callback/outer budget. Timeout or uncertain host completion
  replies Unavailable and stops the turn; do not retry that request. No recursive
  artifact deletion or extra relay/model process. Existing model/all relays remain.
- Whitelist summary metrics: control counts and check ordinal/status/elapsed/request
  positions, without feedback/model/control text; Pi null. Never backfill old traces.

## Verification and delivery

Owned before/after runtime fixture: first candidate rejected with supplied fake public
failure, permitted Changed repair, then pass/Completed on the same model. Cover cap and
check exhaustion, review recheck, unconfigured/missing callback, no-tools, fresh turns,
caller cancellation/deadline, Unknown/no replay and durable external/control provenance.
Config omission/round-trip/range; CLI parser and mailbox identity/partial/size/timeout/
cancel/private-directory cases use owned fake data only. Host fake mailbox/snapshot
fixtures prove bounded single handling, missing artifacts, public feedback and oracle
exclusion; metrics fixture proves scalar scope/content exclusion.

Required Rust checks/debug build, startup, rendering (new status), session/context
budgets, profile/hash guards, parent invariant review, canonical/architecture/compat/
changelog/roadmap alignment, incremental push/PR updates and exact-head CI. Then freeze
one fresh Rupi development turn using the Retry24 model/prompt/controls/outer2400s,
with checks8 selected. Any failure requires analysis and a verified enhancement before
another attempt. Fresh matched Pi only after Rupi acceptance. Report configured results
and parity limits honestly; no benefit or semantic fix is established by owned tests.

## Implementation evidence before Retry25

Core59994fe, CLI6bceb14, host e658c7a and cleanup02ecdf9 implement this plan.
The owned before fixture fails because the first candidate closes; after the gate,
supplied public failure permits a Changed repair and later pass on the same model.
All203 runtime/132 core tests and required fmt/core-all-features/clippy/workspace
tests/doc/debug checks pass. CLI protocol/parser/preflight and real binary/fake-provider
repair fixtures pass. Host fixtures cover copied-only effects, requested public artifacts,
nonzero tests, bounded public diagnostics, private-content exclusion, stale identity,
once-only handling, timeout and a live callback; summary scalar/content exclusion passes.
A GetNewClosure function-scope failure was corrected before model use.

Two bounded refinements: reject outside search too (grep could expose the mailbox),
and reserve12s within the host observation window for existing ten-second process-tree
cleanup plus publication. The timeout fixture confirms a public command started and
Unavailable returned, without replay. No Rust check execution or extra model/relay exists.
The parent invariant review passes: single-model execution, semantic no-recovery,
caller-owned snapshot effects, Unknown precedence, external/control/native separation,
fresh bounded allowance, cancellation and lazy disabled paths. No independent review
agent was used. Caller permissions are trusted; this is not an adversarial OS sandbox.

Startup135.96ms cold/7.92ms median/8.82ms max; rendering3.47/3.64/3.18us and parse0.30us;
all five restore71.45–4697.55us and five context0.4/0.1/0/0/0.3us budgets pass.
Selected checks8/profile2400s/native2370s guards, shared Case10 prompt and18 other prompt
hashes, full public SPEC and three unchanged acceptance hashes pass. Source6bceb14 CI
passes all three platforms; exact later-head CI remains required. Retry25 is not yet run.
No application contents or oracle diagnostics were inspected; no semantic cause, configured
acceptance improvement, causal benefit or Case10 paired win is established.
