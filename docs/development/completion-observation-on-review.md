# Caller observation at timed completion review

Retry30 reaches one completion review after21 started requests but no accepted final
assistant text and zero caller observations before native2370s exhaustion. Only application
29,883 bytes exists; init/tests/README absent. All frozen audits and three-platform CI pass;
27 requests/26 usage records mean unfinished work unknown. Actual contents remain unread.
This proves a feedback timing gap, not a precise application or reasoning defect.

Parent owns one bounded runtime/config/CLI/harness slice. Add default-false, omitted
limits.completion_check_on_review requiring review_completion, a valid timed review
reserve and a configured check allowance. When the timed one-shot review activates at an
ordinary safe boundary, request one fresh caller observation before the next model request.
Use the same allowance, remaining native time, cancellation token, bounded feedback and
external provenance as ordinary completion checks. Do not add commands to core/CLI,
model/authority/permission, timer, replay, or new events. Initial/recurring progress remains
required; observations do not count as Changed work. Passed does not close the turn;
Failed with allowance left permits the already-authorized bounded review to continue.
Unavailable/oversized observations stop with the existing semantic failure; last Failed
or exhausted allowance stops as CompletionCheckExhausted. This supersedes the terminal
ledger's preliminary suggestion to continue after Unavailable. Ordinary completion still
requires a fresh check; no snapshot result is cached as proof of final state.

Factor the existing observation operation for both call sites without changing default
behavior. No-tools, absent reserve, disabled review/flag/checks skip proactive checks;
fresh turns renew the shared allowance and one-shot boundary. Unknown effects must stop
before review/checks. Cancellation/deadline before or during callbacks takes precedence;
no callback result or tool can cross those barriers.

Owned comparative fixture: a provider without final text receives a missing-deliverable
observation at timed review and repairs before its first text completion; omitted flag
does not receive early evidence. Assert check ordering, ordinal renewal, model identity,
external/static provenance, once-only use, later fresh completion check and budgets.
Cover Failed-last, Unavailable/oversized, Passed-still-review, cancel/deadline, Unknown,
no-tools and request caps. Verify config omission/dependencies/roundtrip and real CLI
mailbox/wire. Add isolated Case10 benchmark switch/metadata (native false or true, Pi null),
owned harness guards and unchanged shared/18 other prompt/SPEC/three reference hashes.

Required Rust checks/debug, startup, five context/five restore budgets, author invariant
review and three-platform CI. No render path/status/event added. Update canonical docs,
commit/push/freeze before one fresh Retry31. Preserve direct8000/globalOff, firstOff,
8192/32768 output,2048 first strings,checks8/mutations32/cap40/window3, timed review300s/
native2370s/provider2394s/outer2400s/grace6 and original model/helpers. Fresh matched Pi
only after actual Rupi acceptance. No actual win or causal improvement claimed.
