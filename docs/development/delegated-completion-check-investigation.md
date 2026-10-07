# Delegated completion-check investigation

This is an investigation handoff, not a selected implementation plan.

Retry24 ends Completed with37 requests/37 usage records and48 successful tools,
but public tests and acceptance fail. Help passes; requested application/tests exist,
README is absent. Actual generated contents and diagnostics remain unread by the
parent, so the semantic defect is unknown. Initial progress aligns the first tools
with writes; it does not establish correctness or a causal performance improvement.

Verified source boundaries:

- `bench/compare-pi-rupi.ps1::Invoke-AgentCase` calls `Invoke-Verification` only after
  the agent process returns. `Invoke-Verification` runs public project tests, the
  independent oracle and help checks; `resolved` reflects oracle exit/timeout only.
- `crates/rupi-runtime/src/turn.rs` accepts an ordinary text answer after progress
  and optional one-shot review, then finishes Completed. File-tool status and review
  guidance supply no independent public-check outcome during that turn.
- `TurnProgress` and CLI `CliProgress` in `src/run.rs` are possible adapter boundaries.
  CLI options live in `src/cli.rs`; inspect existing hooks/extensions before adding
  another mechanism. Keep domain workflows outside core and lazy by default.

After the subscription reset, first inspect these owned interfaces and existing
verification helpers, then produce a bounded, decision-complete plan. Consider a
generic caller-selected completion gate with public-check feedback before accepted
closure, on the same model within ordinary request/time budgets. Reuse existing
interfaces when sufficient. No arbitrary commands chosen by the model, extra model,
case artifact enforcement in core, or weakened immutable acceptance criteria.

Resolve before implementation:

- Explicit caller authority and structured recipe/configuration; model file-tool
  policy remains read/write/edit/grep, and the model cannot run tests/servers itself.
- Domain public tests/help/deliverable checks live in the benchmark/host adapter.
  Never supply oracle source/diagnostics or parent-inspected generated content.
  Acceptance remains independent after the turn; any new parity gap is null for Pi.
- Verification effects, isolation/ownership, child cleanup, cancellation, timeout and
  Unknown semantics must be explicit. Never blindly replay an uncertain mutation.
- Bound check invocations, feedback bytes and repairs by the same turn budgets;
  distinguish observed check results from native answers and task correctness.
  Preserve canonical/projected provenance, durable restore, no-tools assessment,
  approval, single-model execution and lazy startup.
- Owned fixtures establish behavior and failure semantics. Required Rust/performance
  checks, guards, parent invariant review and pushed exact-head CI precede another
  frozen single-turn screen. No unchanged retry follows this failure.

Risk: high, because execution/effect boundaries and durable closure are involved.
Do not implement until these choices are resolved in the plan. No acceptance benefit,
semantic root cause or paired Case10 win is established. Broad gates stay active.

Budget handoff: parent observed92% five-hour/80% weekly against repository95%/99%
soft stops. Preserve remote state and wait until2026-10-06 04:50ET (reset04:48 plus
two-minute grace) before substantial investigation/implementation. Goal stays active.
