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
