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
