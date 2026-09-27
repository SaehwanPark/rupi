# Reconciliation resume/replay review follow-up

Change: reconciliation-resume-replay-review
Status: regression coverage added; PR #127 review/merge pending
Base: `main` at `305706e` (Round 6 PR #126 merged)

## Scope

Verify and close two review claims about durable mutating-Unknown reconciliation: model-visible confirmation across process restart, and replay branch planning after a durable safe resolution. The current StoreTrace implementation already persists the reconciliation message and the replay fold already applies matching safe observations; focused regression tests now verify the process-restart path and mismatched-observation safety.

## Acceptance criteria

- After an operator confirms `Committed` or `Unmodified`, a process restart before the next user turn restores the reconciliation notice into model-visible context and does not restore the unresolved barrier.
- A historical branch at an unresolved `ToolUnknown` is blocked; a branch including its matching durable safe reconciliation observation is not blocked. `RequiresManualInspection` remains blocked.
- Observation matching uses the same request and unknown event identities; stale or mismatched observations must not clear the barrier.
- Add deterministic regression tests for any uncovered path and run workspace tests, clippy, fmt, and docs as needed.

## Review context

The current main branch already contains `StoreTrace::emit_message` persistence and a replay reconciliation fold. The end-to-end restart test passes through `StoreTrace`, `Store::restore`, and a resumed provider request with no intervening user turn. Replay tests cover blocked branches before resolution, unblocking after a matching safe resolution, and ignoring a mismatched request identity.
