# Request-budget completion review

Status: active; Case10 acceptance and paired improvement remain unproved.

Retry32 exhausted 40 requests before final text or the timed review reserve. All requests
had usage and about 787 seconds remained; no review/check ran and required tests were absent.
Parent inspected scalar metadata only. The terminal ledger records frozen audits and CI.

Add optional limits.completion_review_request_reserve, default omitted. Enabled review and
a positive reserve strictly below max_model_requests_per_turn minus its finalization slot
are required. At an ordinary safe boundary, remaining ordinary requests at or below the
reserve trigger the same one-shot review as the timed reserve. Neither trigger renews or
extends budgets. Earlier ordinary final-answer review consumes that same one-shot allowance.
Direct TurnLoop builders skip invalid reserves. Request-only selection needs no clock.

completion_check_on_review may select either valid reserve, sharing the existing check
allowance. Progress/tool-budget guards precede the callback. Passed still needs review and
a fresh final check; repairable Failed permits bounded work. Last Failed, exhausted checks,
Unavailable and oversized feedback preserve existing terminal stops. Cancellation, native
deadline, Unknown mutations, no-tools finalization and approval barriers remain unchanged.
No new events, timers, model, command authority, artifact policy or acceptance relaxation.

Owned runtime comparison must reproduce tools continuing until the request cap without
feedback, then show reserved public feedback permitting a missing-test repair and fresh
final pass inside the same cap. Cover defaults, invalid/skipped paths, renewal, competing
reserves, terminal feedback and cancel/Unknown ordering. Extend the real CLI mailbox fixture
and isolated harness/native-scalar/Pi-null guards. Preserve all shared prompts/references.

Owner: parent single agent. Sources: config, TurnLoop, run adapter, harness and owned fixtures.
Required local Rust/debug checks, startup and five restore/five context measurements,
author invariant review, durable commits/push and source/frozen three-platform CI precede
Retry33. Proposed screen: request reserve 8 of 39 ordinary requests, existing cap40 and all
Retry32 controls unchanged. One Rupi turn; fresh matched Pi only after Rupi acceptance.
Never read generated content, actual feedback, model output or oracle diagnostics.

Owned implementation evidence: the chunking fake provider reaches cap4 with three distinct
application changes and no tests/checks when the reserve is omitted. With request reserve2
and the same cap, missing-test feedback permits repair and fresh final pass in3 requests.
Request-only observations have no native time budget. Renewed turns, simultaneous time and
request triggers, earlier accepted-answer review, disabled/invalid/no-tools selection,
Unknown mutation barrier, callback cancellation/deadline and terminal feedback fixtures pass.
The real CLI mailbox repair fixture passes ordinary, timed and request-reserve modes while
preserving exactly3 requests, two observations, no exec authority and owned artifacts.

Required local fmt/core-check/clippy/workspace-test/docs/debug-build gates pass, including
220 runtime,137 core,100 provider and25 CLI tests. Eight owned harness fixtures pass;
request-only dependencies, native selection and Pi-null/case isolation are covered. The
selected config/public SPEC/three reference hashes and all18 other prompt hashes pass.
Shared initial prompt hash remains230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270.
An initial Windows PowerShell child rejected script files under its execution policy;
running the owned fixtures through the existing PowerShell tool session resolves the
launcher mismatch without changing machine policy or production code. No inference rerun.

Parent author invariant review: pass, no blocking findings. The predicate only enters at
the existing ordinary boundary; review remains one-shot and the existing check helper
retains external evidence provenance, shared caps and semantic stops. No dispatch/replay,
model activation, provider capability, startup dependency, event or rendering change.
Request-only selection adds no clock measurement; timed cycle observation remains opt-in.
Configuration validation and runtime builder guards preserve an earlier request and caps.
Performance passes: cold143.185ms, warm median8.578ms/max9.034ms; all five restores
(85.30,600.00,2689.50,2586.35,4956.55us) and five context budgets (.4,.1,0,0,.3us) pass.
Runtime/sourcea0e17c63c7040b8a15cad33a71aa7f581ff30ba5 is pushed. Source CI37494871347
and exact frozen-checkout CI must pass all three platforms before inference. Actual
Retry33 acceptance and paired evidence remain pending.
