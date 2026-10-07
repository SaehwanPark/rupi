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

## Verified implementation and Retry38 freeze

Runtime/sourcec8367a507a62a0d918222326ca86b4b835bc2aa9 is pushed. Required local
fmt/core-check-all-features/Clippy/workspace tests/docs/debug build pass:
230 runtime/140 core/100 provider/25 CLI, with28 event roundtrip tests.
Owned comparison exhausts4 checks before later request-reserved review when omitted;
reserve2 enables review after two fresh Failed observations, repair, checkpoint pass
and a fresh final pass with identical4 requests/4 checks. Invalid raw builders skip.
Renewal, both observation sites and shared one-shot triggers pass; Passed/Unavailable/
last Failed/no-tools/no ordinary work/cancel/deadline/Unknown retain existing barriers.
The real CLI mailbox covers six modes, preserving prior branches and assertions;
check-reserve mode observes actual owned files, two failures, repair/checkpoint/final
passes with4 requests/4 checks and no exec tool. On-review does not duplicate this check.

All12 owned harness guards and full selected workspace config pass. Shared prompt stays
230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270;
all18 other prompt hashes and public SPEC/three copied reference hashes unchanged.
Startup146.931ms cold/8.347ms warm median/9.975ms max passes; five restores
97.20/613.30/2674.65/2555.60/5045.40us and contexts.4/.1/0/0/.3us meet budgets.

Parent author invariant review: pass, no blocking findings; no independent reviewer.
The helper uses existing fresh caller evidence, typed status and turn-local shared
review flag at both safe observation sites, after terminal guards. It creates no new
callback, event kind, timer, request, command, allowance, dependency or domain knowledge.
Existing external evidence and runtime-control provenance remain separate. Fresh final
checking, same-model execution, approvals, Unknown/no replay, cancellation/deadline,
no-tools and tool/progress limits remain. Defaults omit the new setting; invalid config
rejects while invalid direct builders skip. Per-turn counters/review renew. CLI/harness
consumers and serializers are wired; native Pi metadata is null. Canonical/architecture/
compatibility/roadmap updated. Actual semantic cause/model use/acceptance remain unknown.

Frozen intended run:
bench-20261006-case10-check-reserve2-initial8-idle2394-repair3-request8-template-off-args2048-first8192-check8-mut32-review300-turn2370-retry38-rupi40-screen1-2400s.
Add only caller-check review reserve2 to Retry37's unchanged profile: same physical
model PID27356/direct8000, maxTurns1/request40, outer2400s/provider2394s/read2394000ms/
native2370s, global/initialOff/templatefalse, first8192/args2048/output32768, initial
progress/recurring3, mutation32, checks8/on-review, initialWindow8/repairWindow3,
timeReserve300s/requestReserve8. Pi native reserve selection remains null.
SourceCI37529332167 and exact frozen-head all3 CI must pass before inference.

Debug binary SHAC46E08485431112E71BEA61AE62454D752B4619030F6202AF2453D368A23503E.
Harness SHA971680D930BE5F5C57AB154D11175085A317C06842C0D989C7CB709F9F79C429.
Callerfa68218/SHAEB7829961FC2AB93AC36E8FE4971F5EA18F07C8DE6136019110373775DF1E6AC
and original helper SHAA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7 unchanged.
Fetch/prune shows only main and active Case10 branches; root user-policy SHA
3CEE11E5D4D8C8CA7CCF34F87A64B18BB183D4AF9AF79AB964AE19D4EF39B496 remains intact.
Actual benefit, acceptance and paired win remain unproven; PR145 stays draft.