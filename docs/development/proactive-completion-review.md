# Proactive completion review within a time reserve

Retry21 ends as TimeBudgetExhausted after1,170.385s with14 closed requests/13
usage records, no failed/Unknown tools, and no listed tests or README. Acceptance
and project tests fail. Review activation is unmeasured; no semantic cause is
established. Source verifies an activation gap: the configured review can occur
only after an otherwise accepted ordinary answer, so ongoing tool work may reach
the deadline without this closeout guidance.

## Bounded enhancement

- Add optional `limits.completion_review_reserve_ms`, omitted by default. It
  requires review_completion=true and a configured max_turn_duration_ms; validate
  1 <= reserve < total duration. No default timer/review behavior changes.
- Add the corresponding TurnLoop builder and CLI wiring. Before the next ordinary
  provider attempt, after cancellation/safety checks, trigger the existing one-shot
  CompletionReview when observed remaining time is at most the reserve. Initial
  first-answer review remains available when the reserve has not triggered it.
- Use the same local per-turn review-used flag, canonical control/projection, active
  model, and normal request/tool/time budgets. Do not interrupt a completed tool batch
  midway or start inference after expiry. Unknown effects still block inference.
- No case artifact enforcement, model orchestration, hard deadline claim, or external
  correctness certification. Existing no-tools assessment/finalization stays bounded.
- Expose whitelist counts of canonical runtime-control kinds in benchmark summaries,
  with unknown-kind count and native Pi unavailable/null. Never expose control text,
  model outputs, generated code, or oracle diagnostics. Prior activation remains
  unmeasured; do not retrospectively inspect actual traces.
- Benchmark selects reserve300,000ms with native turn1,170,000ms and one-turn
  development screening. Shared prompt/references and other cases remain unchanged.

## Verification and delivery

- Config omission/round-trip and inactive/no-time/zero/equal/oversized reserve rejection.
- Owned runtime fixtures: continuing tool work receives proactive review; earlier
  first-answer review prevents a second trigger; fresh turn resets; no reserve keeps
  prior behavior; cancellation, cap/no-tools, and Unknown barriers stay authoritative.
  Use owned delayed progress for a deterministic reserve crossing without slow IO.
- Synthetic metrics fixture verifies control counts, unknown kinds, SkipLines scope,
  and absence of control text/model content in output. No actual trace inspection.
- Required Rust checks/debug build, startup and session/context performance, parent
  invariant review, updated architecture/changelog/roadmap, commit/push/PR status.
  Rendering is unchanged; previous four passing render budgets remain applicable.
- Freeze before a new one-turn screen; no builds/source changes during inference.
  Failure requires analysis and a verified enhancement before another attempt.
  Fresh matched Pi follows only Rupi acceptance; final exact-head CI remains required.
