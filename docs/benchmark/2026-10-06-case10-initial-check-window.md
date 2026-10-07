# Case10: early initial caller-check boundary

Retry36 ends budget_exhausted at1,819,016ms with all40 usage records and all required
deliverables listed, but tests/acceptance fail. First caller check occurs after31,
then Failed repair checks after34/37. No provider failure or verification timeout.
Native time still has550,984ms when the request cap binds. Frozen audits/all3 source
and checkout CI passed; all model slots idle before this change.
Semantic diagnostics remain uninspected and their precise cause is unknown.

Selected core reliability slice: optional completion_check_initial_request_window,
omitted by default, positive and below the ordinary request allowance, requiring at least
two caller checks. At the first safe ordinary boundary after that many model requests,
request a caller observation only if none has happened yet. Share existing allowance/
helper/provenance and coalesce with reserved review or repair checks. Do not consume
the one-shot review, add requests, extend clocks, run tools, or certify completion.
A prior accepted-answer/check already satisfies the initial observation requirement.
Failed can arm the existing repair window; Passed disarms repair but final checking
remains fresh. Unavailable/exhaustion/cancel/deadline/approval/Unknown/no-tools barriers
retain their semantics. State renews each turn; invalid direct builders remain inactive.

| Boundary | Behavior |
| --- | --- |
| Omitted/invalid/no-tools/no remaining ordinary work | No new observation |
| First threshold reached, no prior observation | Existing caller check, once |
| Coincident initial/review/repair trigger | One shared observation |
| Passed initial observation | Continue, fresh final check required |
| Failed initial observation | Bounded repair with existing remaining budgets |
| Unavailable/final Failed/check exhaustion | Existing terminal handling |
| Cancellation/deadline/Unknown | Existing safety precedence, no continuation |

Ownership: RuntimeLimits validation/serialization, TurnLoop builder and safe boundary,
CLI run adapter, Case10 harness scalar selection/metrics, owned config/runtime/mailbox
fixtures and architecture/compatibility/canonical contract/roadmap notes. Domain-specific
public-file requirements and commands remain in the caller; no generated solution edits,
prompt/acceptance changes, helper/model restart, hidden reasoning or automatic replay.

Acceptance evidence: owned model that chunks application work until external feedback;
omitted setting exhausts the fixed cap before tests, selected initial window supplies
early Failed feedback and reaches repaired artifacts plus a fresh final pass within the
same cap. Cover prior observation, renewal, no early certification, invalid/dependency
cases, trigger coalescing, cancellation/deadline/Unavailable/Unknown and real CLI mailbox.
Run required Rust/debug gates, harness/prompt/SPEC/reference guards and performance budgets,
parent author invariant review and all3 source/exact frozen-head CI before inference.

Next intended screen retains Retry36's model and all controls, adding initial window8
with check allowance8 and repair window3. Causal benefit and configured Case10 win remain
unproven. PR145 remains draft; do not repeat inference before verified implementation.

## Verified implementation and Retry37 freeze

Runtime/source0e651e2edeae33749bd1f7e500aa0cd6480e4df3 is pushed. Required local
fmt/core-check-all-features/Clippy/workspace tests/docs/debug build pass:
227 runtime/139 core/100 provider/25 CLI, with28 event roundtrip tests.
Owned comparison retains its original request-review branches and adds initial checking:
omitted selection exhausts cap4 without tests, initial window1 reaches the test artifact
and fresh final pass in3 requests at the same cap, without consuming review.
Renewal/coalescing/later review/fresh final/invalid/prior-observation/no-tools tests pass.
Existing terminal/Unavailable/oversized/cancel/deadline/Unknown tests also exercise the
new initial mode; assertions preserve effects, cancellation precedence and no stale feedback.
Real CLI mailbox now covers five modes, retaining all four original branches/assertions;
initial mode makes a first observation after owned tool work and reaches repair/final pass
with3 requests/2 checks. No exec authority added, mailbox/artifacts preserved.

All11 owned harness guards and full selected workspace config pass. Shared initial prompt
remains230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270,
18 other prompt hashes and public SPEC/three copied reference hashes unchanged.
Startup136.618ms cold/7.790ms warm median/13.290ms max passes; five restores
95.25/633.70/2814.90/2707.15/5230.60us and contexts.4/.1/0/0/.3us meet budgets.

Parent author invariant review: pass, no blocking findings. The trigger runs only at the
existing safe ordinary boundary, after progress/tool-budget checks. Shared observations
remain caller-owned external evidence, consume the same allowance, and never certify an
unfinished turn. First-check state is represented by the per-turn observation count;
earlier observations disable the trigger and fresh turns reset it. One-shot review stays
independent. All clock/cancel/Unknown/approval/projection/quarantine/replay/terminal and
fresh final-check contracts remain. No new event, execution authority, dependency, timer,
startup host, renderer change or domain knowledge enters core. Canonical/architecture/
compatibility/roadmap notes updated; actual semantic failure cause remains uninspected.

Frozen intended run:
bench-20261006-case10-initial-check8-idle2394-repair3-reserve8-template-off-args2048-first8192-check8-mut32-review300-turn2370-retry37-rupi40-screen1-2400s.
Retain Retry36's same physical model PID27356/direct8000, maxTurns1/request40,
outer2400s/provider2394s/read2394000ms/native2370s, global/initialOff/templatefalse,
first8192/args2048/output32768, initial progress, recurring progress3, mutation32,
checks8/on-review, timeReserve300s/requestReserve8/repairWindow3.
Add only initial check window8; Pi native selection remains null.
SourceCI37521853946 and exact frozen-head all3 CI must pass before inference.

Debug binary SHA7AB28BBE11A8A89C50CACF108CD55AD443AD64E337126D4E01252C7BB423ABF0.
Harness SHA4FC407E00DA63AC59C68009AF989DD4CF6CFBE195CE5598338D831EC2C59286D.
Callerfa68218/SHAEB7829961FC2AB93AC36E8FE4971F5EA18F07C8DE6136019110373775DF1E6AC
and original helper SHAA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7 unchanged.
Fetch/prune shows only main and active Case10 branches; root user-policy SHA
3CEE11E5D4D8C8CA7CCF34F87A64B18BB183D4AF9AF79AB964AE19D4EF39B496 remains intact.
Actual benefit, acceptance and paired win remain unproven; PR145 stays draft.
