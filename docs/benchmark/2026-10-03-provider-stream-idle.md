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
or state are introduced. All 26 transport tests pass, including the regression,
quiet-stream expiry, total timeout, cancellation and delayed headers. Formatting
passes. Extended framing/body coverage, full checks and final invariant review
remain pending. Keep the PR draft until they pass.
