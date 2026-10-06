# Anticipate a slow cycle before spending the review reserve

Retry22 injects one review but still reaches the native deadline with missing delivery
files and failed acceptance/help/tests. Injection is measured; its position and model
use are not. No generated contents or oracle diagnostics were inspected, so no semantic
application cause is established. Source shows an independent scheduling limitation:
the reserve check observes only current remaining time, allowing another slow provider
and tool cycle to consume the desired review time before the next check.

## Bounded change (medium risk)

1. In `TurnLoop::run_turn`, retain the start of the last ordinary cycle only while
   configured review/reserve is eligible. At the next safe boundary, subtract that
   observed cycle duration from remaining time using saturating arithmetic. Trigger
   the existing one-shot review if the projected remainder is within the reserve.
   With no prior cycle, use zero. This is an estimate, not a guaranteed reservation.
2. Retain existing default behavior, first-answer review, request/time limits,
   cancellation, admission, and Unknown barriers. Reset the observation each turn;
   no new configuration/event kind, timer, model, or domain workflow is introduced.
3. Extend benchmark metrics with review positions expressed as counts of started
   requests at injection. Preserve SkipLines scoping, whitelist content exclusion,
   and native Pi null. Use owned fixtures only; do not backfill actual old traces.
4. Update architecture/canonical contract, changelog, roadmap, and evidence ledger.
   Required Rust checks/debug build, startup and session/context budgets, owned
   metrics/config/reference guards, parent invariant review, push/CI precede screening.

An owned fixture must fail before the change: a slow permitted tool cycle leaves more
than the literal reserve but less than reserve plus its observed cost. Review must
appear in the next request rather than after its text answer. Verify a fresh turn
renews the observation/one-shot review, and a fast cycle does not trigger early.
Existing no-reserve, no-tools, cap, cancellation, provenance, and Unknown tests remain
authoritative. No application artifact enforcement or benchmark acceptance change.

Stop if source contradicts this boundary ordering; report the conflict. Freeze the
verified source/binary/harness before one fresh development turn with the same selected
profile. A failed screen requires further analysis and a verified enhancement before
another attempt. Fresh matched Pi follows only Rupi acceptance. Final exact-head CI
and honest paired evidence remain necessary for delivery.

Implement exactly this plan. Do not broaden scope. If the plan conflicts with the
codebase, stop and report the conflict instead of improvising. Report files changed,
checks, deviations, and unresolved risks. An observed cycle cannot predict all future
latency, and this change does not prove an acceptance benefit.
