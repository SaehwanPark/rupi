# Case10: reserve caller checks for one-shot review

Retry37 reaches initial checking8 and Failed repairs11/14/17/20/23/26/29. All eight
observations fail; check exhaustion stops after29, before request-reserved review31.
All29 usage records known; all deliverables listed, tests/acceptance fail/help passes.
No provider/verification timeout, frozen audits/all3 source+checkout CI pass and model
slots idle before changes. Semantic diagnostics remain uninspected.
Verified control interaction: review never runs while639,093ms and11 request slots remain.

Selected reliability slice: optional completion_review_check_reserve, defaultNone/omitted.
Requires enabled review, at least two caller checks and positive reserve below their cap.
After a fresh repairable Failed observation, if remaining checks are within this reserve,
activate the existing one-shot review before further ordinary model work.
Reuse the just-observed failure; do not issue a duplicate observation on that boundary.
Time/request/accepted-answer/check-reserve triggers share the same review-used flag.
A Passed/Unavailable/last Failed result cannot activate this trigger. Keep fresh final
checking, original check/request/tool/time allowances, same active model and all effect/
progress/approval/Unknown/cancel/deadline/no-tools/finalization barriers.
Invalid direct builders skip, and per-turn counters/review state renew.

Ownership: core config/validation; bounded runtime helper called at both observation
sites; CLI adapter; Case10 scalar/harness helpers and owned tests; contract/docs/roadmap.
Caller commands/domain policy remain outside core. No new execution authority, timer,
event, retry, model/helper restart, generated application change or acceptance weakening.

Owned comparison: repeated tool work with failures exhausts the check cap before the
later request-review threshold. With check reserve, fresh failure plus review guidance
enables repair and a fresh final pass under identical caps. Cover shared trigger/renewal,
both observation sites, Passed/Unavailable/last Failed/oversized/cancel/deadline/Unknown
and no-tools/invalid cases; extend the real CLI mailbox without weakening existing modes.
Required full local Rust/debug gates, harness/profile/prompt/SPEC/reference guards,
performance budgets, parent author review and source/exact-head all3 CI precede inference.

Next intended screen adds check reserve2 to unchanged Retry37 profile (checks8,
initialWindow8/repairWindow3/requestReserve8/timeReserve300s, request40/native2370s/
read2394s/provider2394s/outer2400s, same physical direct model/global and initialOff).
This predicts review after the sixth Failed observation if still unused, while two checks
remain. Injection does not prove model use/correctness; actual benefit and win unproven.
PR145 remains draft; no blind inference retry.
