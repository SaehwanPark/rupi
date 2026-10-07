# Opt-in bounded completion review

Retry20 ends as `Completed` after 905.693s, with17 of40 model requests and no
failed/Unknown tools. Acceptance and project tests fail; the allowed inventory
lists application files but no tests or README. It leaves264s of native time
allowance unused. This does not establish the semantic task defect. Source review
does establish a separate closure gap: an ordinary text-only response immediately
ends the turn, with no requested-deliverable review.

Add an optional same-model completion review, disabled by default. This is bounded
generic runtime guidance, not case-specific artifact enforcement or a claim that
the runtime can certify task correctness.

## Contract and implementation

- `limits.review_completion: bool`, omitted/false by default; round-trip true.
- `TurnLoop::with_completion_review(bool)` and CLI configuration wiring.
- On the first otherwise accepted text-only response in an ordinary tools-enabled
  turn, preserve the native assistant response and inject a canonical, projected
  `CompletionReview` runtime control. Compare requested deliverables with observed
  actions/results, complete missing authorized work, and report incomplete work or
  unrun verification honestly. Do not manufacture test results or demand mutation.
- Continue on the same model through normal request/tool/time budgets. The review
  happens at most once per turn, including when its response requests more tools.
  A new turn/resume gets a fresh review allowance; no old timer/review flag persists.
- Progress-boundary rejection runs first. Unknown/Possible effects still stop
  inference; incomplete calls remain unexecuted. Cancellation and deadlines retain
  their existing classification. Review does not bypass approval or tool admission.
- With no request allowance, finish budget-exhausted rather than silently skipping
  a configured review. The existing reserved no-tools finalization may assess the
  task, but cannot execute repairs or turn budget exhaustion into completion.
- Explicit no-tools recovery/finalization mode skips this ordinary-turn review.
- Keep default request shape, latency path, Pi behavior claims, and startup lazy.
- Benchmark enables the option explicitly for the next Case10 one-turn development
  screen, records native Rupi metadata and unavailable/null for Pi, and leaves shared
  prompts, acceptance references, and other cases unchanged.

## Verification and delivery

- Owned runtime fixtures: premature first answer followed by a permitted repair;
  canonical/projected control provenance; one-shot bound for repeated text answers;
  fresh review on the next turn; default/no-tools behavior; cap accounting and reserved
  finalization; cancellation and Unknown mutation barriers during the review.
- Config omission/round-trip coverage and durable close/reopen/resume fixture.
- Required fmt/core-all-features-check/Clippy/workspace-tests/docs/debug build;
  startup and session/context budgets; parent invariant review. No rendering contract
  changes are planned; the previous four render-budget checks remain applicable.
- Record the Windows time-fixture correction separately: an owned delayed admission
  reproduces valid expiry with no provider request/refusal. The durable active-stream
  fixture now allows2s for admission and asserts that it actually reached the provider.
- Freeze source/binary/model/profile/prompt/references before the next attempt.
  No builds or source changes during inference. Failure requires analysis and a verified
  enhancement before another attempt. Fresh matched Pi follows only Rupi acceptance.
  Final exact-head CI and paired acceptance evidence remain required before merging.
