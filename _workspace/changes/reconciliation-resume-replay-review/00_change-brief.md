# Reconciliation resume/replay review follow-up

Change: reconciliation-resume-replay-review
Status: investigating; follow-up review findings under verification
Base: `main` at `305706e` (Round 6 PR #126 merged)

## Scope

Verify and close two review claims about durable mutating-Unknown reconciliation: model-visible confirmation across process restart, and replay branch planning after a durable safe resolution. Prefer regression coverage when the current implementation already provides the required behavior; change runtime/store/replay code only if the tests expose a gap.

## Acceptance criteria

- After an operator confirms `Committed` or `Unmodified`, a process restart before the next user turn restores the reconciliation notice into model-visible context and does not restore the unresolved barrier.
- A historical branch at an unresolved `ToolUnknown` is blocked; a branch including its matching durable safe reconciliation observation is not blocked. `RequiresManualInspection` remains blocked.
- Observation matching uses the same request and unknown event identities; stale or mismatched observations must not clear the barrier.
- Add deterministic regression tests for any uncovered path and run workspace tests, clippy, fmt, and docs as needed.

## Review context

The current main branch already contains `StoreTrace::emit_message` persistence and a replay reconciliation fold. Validate these complete paths rather than assuming the forwarded line-level claims reflect current code.
