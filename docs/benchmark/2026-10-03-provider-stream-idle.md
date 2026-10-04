# Provider stream idle accounting

## Bounded slice

Case 08 retry02 exposed a provider timeout during test-module authoring. Its model
traces and generated code remain unread. An independent fake-server fixture proves
that the outer provider idle timer can expire while valid SSE tool-argument
fragments arrive every 80 ms: the decoder emits no complete tool call until finish.
The live comparison continues with its original binary and fixed controls.

Owner: current single agent. Boundary: rupi-provider transport, not core or domain
workflow policy. Owned source paths are openai.rs and transport.rs. Update verified
architecture/roadmap notes after implementation; no public/durable schema changes.

## Contract and plan

| Condition | Required behavior |
| --- | --- |
| Active response input, no decoded event yet | Refresh transport idle activity |
| Complete valid tool call | Emit it once after decoding/validation |
| Quiet transport | Expire at configured logical idle timeout |
| Continuous input exceeding total deadline | Expire at configured total deadline |
| Cancellation or ambiguous POST failure | Stop relay; preserve quarantine/replay rules |
| Transport activity | No invented model output, usage, reasoning, or journal events |

1. Reproduce using valid buffered tool-argument fragments over loopback HTTP.
2. Keep transport inactivity enforcement in the existing HTTP/SSE reader; remove
   the duplicate decoded-event idle timer and retain absolute request deadlines.
3. Verify buffered arguments and partial framing, quiet streams, total deadlines,
   cancellation and ambiguous request quarantine; run required repository checks.
4. Apply the invariant-reviewer role, push/reconcile docs, merge when verified, and
   delete the completed branch. Only use the corrected binary in a fresh trial
   after Case 08 retry02 finishes; never change an in-flight comparison.

## Verified reproduction (2026-10-04)

Command: `cargo +stable test -p rupi-provider --test transport
active_tool_argument_fragments_do_not_expire_as_idle --target-dir
C:/Users/saehwan/repos/rupi/target -- --exact --nocapture` (one command).

The fixture sends valid SSE fragments every 80 ms for over a second, with a 500 ms
idle budget and a 5,000 ms total budget. It fails on unmodified provider code with
`Timeout`, `WaitingForResponse`, and `AmbiguousPostBoundary`, message
`provider response exceeded its configured idle timeout`, after 0.60 seconds.
No tool was emitted. This proves a transport bug, not the exact cause of the
Case 08 model failure; that attribution remains unproven without additional evidence.

Implementation removes only the redundant outer decoded-event idle timer. The
existing HTTP read timeout and SSE logical idle handling remain, as do the outer
total deadline, cancellation, quarantine and replay rules. No new activity events
or state are introduced. All 29 transport tests pass, including the regression,
quiet-stream expiry, total timeout, cancellation and delayed headers. Formatting
passes. Active partial SSE frames and one-shot bodies preserve exact output; active
input still expires at the total deadline without synthetic model events. Core
check, Clippy, workspace tests and documentation passed before these extra fixtures.
All required local checks and author invariant review now pass. CI and merge remain
pending; the Case 08 comparison objective is not completed by this runtime fix.

## Final verification and author invariant review

Passed on the final Rust sources using the installed exact Rust/Cargo 1.98.1 stable
route: formatting, core all-features check, workspace all-target Clippy with warnings
denied, workspace tests, and workspace documentation without dependencies. After
adding framing/body fixtures, formatting, Clippy and workspace tests passed again.
All 29 transport cases pass. Startup from this checkout's release build measured
188.58 ms cold, 11.98 ms warm median and 16.00 ms warm maximum, within 250/100 ms.
The release target was shared through a checkout-local junction; no executable was
copied into the live Case 08 worktree. Its selected binary remains unchanged.

Author invariant-review verdict: pass, no blocking findings. Review checked actual
HTTP timeout configuration, blocking SSE/one-shot reads, worker result handling,
cancellation relay shutdown, quarantine and request replay-safety classification,
and decoder buffering/completion. The change removes only event-based idle expiry.
Transport quiet expiry still fails with an ambiguous POST boundary and quarantines
the adapter; continuous active input still fails the absolute total deadline.
No decoded tool is dispatched early, no unknown operation is replayed, and no new
model/usage/reasoning/journal event or core schema is introduced. Startup remains
lazy with no added allocation, dependency or subsystem activation.

No model-backed child or independent-agent review was used. The exact cause of
Case 08's model timeout remains unproven; this is a fixture-backed runtime fix.
A fresh corrected-binary comparison is still required after retry02 is terminal.
