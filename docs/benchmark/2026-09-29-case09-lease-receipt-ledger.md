# Case 09 lease receipt comparison ledger

This ledger records the matched `09-lease-receipt` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

## Matched baseline

Run: `bench-20260929-case09-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,547 ms | 12,907 / 9,680 | 22,587 | 4 | 4 | outer timeout |
| 2 | 600,150 ms | 13,863 / 8,763 | 22,626 | 4 | 3 | outer timeout |
| 3 | 600,221 ms | 5,244 / 8,940 | 14,184 | 3 | 2 | outer timeout |
| 4 | 600,339 ms | 8,903 / 9,474 | 18,377 | 8 | 7 | outer timeout; unresolved |

Rupi did not resolve in four turns. It used 77,774 work tokens over 2,401,257 ms, with 19
requests and 16 tools. All oracle, project-test, and help checks failed on turns 1 through 3.
All help checks passed on turn 4, but the oracle and project-test checks still failed. The
oracle's four service tests failed with SQLite's `no such column: rowid` error. Project-test discovery could not import the `tests` start directory.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,213 ms | 6,487 / 11,890 | 18,377 | 5 | 5 | outer timeout |
| 2 | 600,235 ms | 1,369 / 9,072 | 10,441 | 8 | 8 | outer timeout |
| 3 | 600,201 ms | 2,801 / 9,795 | 12,596 | 11 | 11 | outer timeout |
| 4 | 600,203 ms | 4,802 / 7,217 | 12,019 | 13 | 13 | outer timeout; unresolved |

Pi did not resolve in four turns. It used 53,433 work tokens over 2,400,852 ms, with 37
requests and 37 tools. All oracle, project-test, and help checks failed on turns 1 through 3.
All help checks passed on turn 4, but the oracle and project-test checks still failed. The
oracle's four service tests ended with remote disconnects. Project-test discovery could not
import the `tests` start directory.

## Outcome

The result is inconclusive because neither agent resolved the oracle. Pi used 24,341 fewer work
tokens and finished 405 ms sooner, while making more model requests and tool calls. Rupi's
service could not initialize its SQLite schema; Pi's oracle requests ended in remote
disconnects. Case 10 is next.

## Active improvement slice (2026-10-04)

Cases01 through08 already have configured comparison wins and are skipped. Case09's
baseline per-turn summaries confirm neither agent resolved in four turns. This new
slice starts from mainf150e39, after Case08 PR141's exact-head three-platform CI/merge.
The completed Case08 branch is removed locally/remotely; its detached artifacts remain.

Boundary: benchmark adapter in `bench/compare-pi-rupi.ps1`, this ledger and ROADMAP.
Generate all application/tests/README only through the same local Qwen model in fresh
workspaces. Preserve the actual public SPEC and untouched acceptance files. The parent
does not inspect generated source/model output/oracle diagnostics/aggregate results.
Historical diagnostic descriptions above are not supplied to the new authoring prompts.

Plan:

1. Add Case09 shared initial/repair prompts embedding the complete public SPEC. Request
   complete authenticated graph/worker behavior from the first source write, including
   stable `pipeline_id + ":" + job_id` delivery keys, distinct private claim tokens,
   matching receipts and lost-ack retry/recovery. Preserve public assertions and cleanup.
2. Add optional Case09 reasoning-budget/progress-mode/request-window selectors with
   defaults0/one_shot/1. Reuse existing endpoint/progress/tool/discovery adapters, isolated
   to Case09. Record actual selected controls; Pi cap/mode/window remain null.
3. Add guards for full SPEC, receipt/fencing requirements and hidden-oracle sentinel
   isolation on initial/repair/help failure paths. Verify all non-Case09 profiles/prompts
   retain their behavior. Run default/off and selected all-case dry runs and diff checks.
4. Author invariant review, then push before a fresh matched six-turn-maximum pair:
   local `qwen3.8-flash-next`, Pi0.86.1, low/configured budget2,048/native replay,
   600s turns/grace6s, Rupi Recurring/window12/cap12/four file tools versus native
   uncapped Pi/six file tools. Reuse verified binary39829D0D...D1C9; no parallel inference/build.
5. Audit saved prompts, selected controls, copied SPEC/acceptance hashes and model/binary
   identity. Win requires acceptance in fewer turns or fewer recorded work tokens at the
   same resolution turn. Report tests/help/docs, unavailable metrics and unknown inference
   separately. Both unresolved is inconclusive; no default/full-task/causal speedup claim.
6. Merge only after a verified Rupi win, required local checks/performance budgets,
   author review and exact-final-head three-platform CI. Keep draft until then; then
   remove the completed branch and proceed to Case10.

No runtime/schema/provider changes, new dependencies, manual solution, hidden-oracle
prompt feedback, weakened tests or speculative orchestration are part of this slice.
Plan and WIP handoff are prepared; implementation and comparison remain pending.

## First candidate prepared and verified (2026-10-04)

Draft PR144 is opened before implementation on `fix/case09-receipt-recovery`. The
harness now supplies shared Case09 initial/repair prompts with full public SPEC and
receipt/fencing/lost-ack requirements. New Case09 selectors default to budget0,
one_shot mode/window1; the candidate explicitly selects low/budget2,048/Recurring12.
Existing benchmark adapters provide file tools, isolated Rupi discovery, native
reasoning replay and nullable Pi progress/cap metadata. Core/runtime defaults stay intact.

Verified before launch:

- All ten cases pass default/off and selected low/budget2,048/Recurring/window12,
  six-turn/600s/grace6/cap12 dry-run guards. Case09 guards cover full SPEC, receipt/
  fencing assertions, initial/repair/help failures and oracle diagnostic sentinel isolation.
- Distinct Case08 recurring/window3 versus Case09 one_shot/window12 guards pass;
  Case09 window0 is rejected. All18 non-Case09 initial/recovery prompt hashes remain
  equal to pre-edit snapshots, including already-winning Case08 guidance.
- A synthetic fresh workspace verifies Qwen/low/native replay, cap12/window12,
  four tools, endpoint8001/deadline594,000 ms/output16,384 and untouched copied
  SPEC/two acceptance-file hashes. No inference or oracle execution occurs in this probe.
- Diff/100-column checks pass after wrapping two long helper declarations. Author
  invariant review passes: case isolation, public-spec-only guidance, native exposure
  validation before mutation, hidden oracle diagnostics and unknown/null measurements.
  No independent-agent review is claimed. Rust/source/acceptance fixtures are unchanged.
- Shared debug binary SHA256 is
  39829D0D62129F4138C449EC4FC913DE4EF81B028527B649EEDFEA1D3EE3D1C9.
  Singular Qwen server27356 and content-free budget relay33028 remain live.

Push the candidate before inference. No comparison win is claimed; the matched pair,
per-turn/terminal audits and final required checks/CI remain pending.

## Retry01 launched (2026-10-04)

Run: `bench-20261004-case09-receipt-guidance-budget2048-low-retry01-rupi12-matched6-600s`.
Launch source5637c80 is pushed before inference. Exec47054, runner19500/wrapper22280
and Rupi turn1 PID24748 are confirmed live. No observation timeout triggers a restart.
Six-turn maximum,600s/grace6s, low/configured budget2,048/native replay, Rupi
Recurring/window12/cap12/four file tools versus native uncapped Pi/six file tools.

The actual Rupi workspace config verifies selected mode/window/cap, four tools, low,
endpoint8001/deadline594,000 ms and native replay. Saved initial prompt retains the
complete public SPEC, stable delivery identity, private fencing, lost-ack retry,
public assertions and no external-oracle access. Binary/model/relay checks pass before
launch. Runtime source remains unchanged; no local builds or parallel comparisons run.
Pi has not started and no per-turn verification is available yet. Keep PR144 draft;
the Case09 comparison result remains pending and Case10 has not begun.

## Retry01 Rupi first attempt verified (2026-10-04)

Turn1 reaches the600,510 ms watchdog with27,928 recorded work tokens (18,111 uncached
input,9,817 output), seven requests started/six completions and six usage records.
Eight tools complete: two greps/two reads/four writes; recorded failed/Unknown are zero.
Unfinished unrecorded inference remains unknown. Project tests, independent acceptance
and all three help checks fail without verification timeouts. This is not a resolution.

Manifest lists initializer264 bytes, entry point356, store22,419 and validation7,652.
No server/worker files, tests or README are listed. Generated contents/diagnostics
remain unread; file presence/sizes do not establish workflow behavior or the failure cause.
Selected per-turn controls remain low/budget2,048/native replay/endpoint8001 and
Recurring/window12/cap12/four tools/isolated discovery. Harness source SHA256 remains
F2F6A528F3203EAB21D4CFA926812BB99D7CD0BFC0445007C5B7A57D48B54AD0.

Rupi turn2 is live under PID22716, runner19500/exec47054. Its saved repair prompt
retains full SPEC, assertions, stable delivery key, private fencing, lost-ack retry
and no external-oracle access. Let the same six-turn-maximum pair continue without
source/configuration changes, local builds or parallel inference. Pi has not started;
no matched outcome is available. PR144 stays draft and Cases09 through10 remain open.

## Retry01 Rupi second attempt exhausts its request budget (2026-10-04)

Turn2 exits0 after508,238 ms with recorded status `budget_exhausted`; the outer watchdog
does not expire. Work43,517 tokens (37,687 uncached input,5,830 output), twelve usage
records, twelve requests started and thirteen completion events including an earlier
abandoned request. Thirteen tools complete: twelve reads and one write; recorded
failed/Unknown are zero. Unfinished unrecorded inference remains unknown. Acceptance
and project tests fail without verification timeouts; all help checks now pass. Exit0
and lower call time do not establish successful task completion.

Manifest adds cli3,296 bytes; other sizes match turn1. No tests or README are listed.
Generated contents/diagnostics remain unread; sizes do not establish unchanged content,
edit targets or complete service/worker behavior. Cumulative through two turns:
71,445 recorded work tokens,1,108,748 ms call time excluding verification,21 completed
tools, zero recorded failed/Unknown. One watchdog expiry and one budget-exhausted attempt.

Selected controls persist. Rupi turn3 is live under PID20016, runner19500/exec47054.
Its saved repair prompt retains full SPEC/assertions/stable key/private fencing/lost-ack
retry/oracle isolation. No code/config changes or builds/concurrent inference during
the original pair. Pi has not started; no matched outcome yet. PR144 stays draft;
Cases09 through10 remain open.

## Retry01 Rupi third attempt verified (2026-10-04)

Turn3 reaches the600,302 ms watchdog with27,502 recorded work tokens (18,500 uncached
input,9,002 output), eight starts/seven completions and seven usage records. Ten tools
are requested: four greps/five reads/one write; nine complete, one fails and zero are
Unknown. The individual failed target/cause remains unread. Unfinished unrecorded
inference remains unknown. Acceptance and tests fail, all help checks pass, with no
verification timeouts. No acceptance resolution is established.

Manifest adds server5,954 bytes; other sizes match turn2. No worker file, tests or
README are listed. Generated contents/diagnostics remain unread; presence/sizes do
not establish complete behavior, unchanged content or the failure cause. Cumulative
through three turns:98,947 recorded work tokens,1,709,050 ms call time excluding
verification,30 completed tools, one failed/zero Unknown. Two watchdog expiries and
one request-budget-exhausted attempt.

Selected controls persist. Turn4 is live under Rupi PID31072, runner19500/exec47054;
saved full-SPEC/assertion/stable-key/private-fencing/lost-ack repair requirements pass.
No source/config changes, local builds or concurrent inference during this original
pair. Pi has not started; no matched result yet. PR144 stays draft and Cases09/10 open.
Before this evidence update, headc90dfcd passes Linux/macOS/Windows CI; this proves
repository checks rather than a model-comparison win. Fetch/prune confirms only main
and the active Case09 branch locally/remotely; detached prior artifacts are preserved.

## Retry01 Rupi fourth attempt exhausts budget without recorded mutation (2026-10-04)

Turn4 exits0 after198,008 ms with status `budget_exhausted`, no outer watchdog expiry.
Recorded work16,768 tokens (15,284 uncached input,1,484 output), eleven usage records,
eleven requests started and twelve completion events including an earlier abandoned
request. Eleven tools complete: nine greps/two reads, no recorded mutating tool;
failed/Unknown are zero. Unfinished unrecorded inference remains unknown. Tests and
acceptance fail, all help checks pass, with no verification timeouts. Shorter call
time/lower recorded work and exit0 are not task completion or a comparison improvement.

Manifest sizes match turn3; no worker file, tests or README are listed. Generated
contents/diagnostics remain unread; sizes do not prove unchanged content or complete
behavior. Cumulative through four turns:115,715 recorded work tokens,1,907,058 ms
call time excluding verification,41 completed tools, one failed/zero Unknown. Two
authoring watchdog expiries and two request-budget-exhausted attempts.

Selected controls persist. Rupi turn5 is live under PID23972, runner19500/exec47054.
Its saved prompt retains full SPEC/assertions/stable key/private fencing/lost-ack
retry/oracle isolation. Continue the original matched pair without source/config
changes, local builds or parallel inference. Pi has not started; matched outcome
remains pending, PR144 draft and Cases09 through10 open.

## Retry01 Rupi fifth attempt ends without acceptance resolution (2026-10-04)

Turn5 exits0 after508,913 ms with runtime status `completed`, not budget exhaustion
or outer watchdog expiry. Recorded work25,986 tokens (18,751 uncached input,7,235
output), eight starts/completions/usage records. Seven tools complete: write/three
edits/three reads, zero failed/Unknown. Tests and acceptance fail, all help checks
pass, without verification timeouts. A completed runtime turn is not project-task
completion; unfinished inference from prior attempts remains unknown.

Manifest adds worker6,896 bytes and lists store22,752. Other sizes match turn4;
no tests or README are listed. Contents/diagnostics remain unread; presence/sizes
do not establish complete behavior, exact edit targets or unchanged content.
Cumulative through five turns:141,701 recorded work tokens,2,415,971 ms call time
excluding verification,48 completed tools, one failed/zero Unknown. Two watchdog
expiries, two budget-exhausted attempts and one completed runtime turn.

Selected controls persist. Rupi turn6 is live under PID14644, runner19500/exec47054.
Saved full-SPEC/assertion/stable-key/private-fencing/lost-ack repair requirements pass.
No source/config changes, local builds or concurrent inference during this original
pair. Pi has not started; matched result remains pending and PR144 stays draft.
Before this update, headf0d8c90 passes Linux/macOS/Windows CI. Cases09/10 remain open.

## Retry01 Rupi unresolved after six; Pi first attempt verified (2026-10-04)

Rupi6 exits0 after280,870 ms with status `completed`, seven requests/completions/
usage records and24,663 recorded work tokens (21,599 uncached input,3,064 output).
Nine tools complete: grep/seven reads/edit, zero failed/Unknown. Acceptance and tests
fail, all help checks pass, without verification timeouts. Manifest lists store23,130
bytes; other sizes match turn5 and no tests/README are listed. Contents/diagnostics
remain unread; sizes do not establish exact edits, unchanged content or full behavior.

Rupi's half is terminal and unresolved after all six attempts:166,364 recorded work
tokens,2,696,841 ms call time excluding verification,57 completed tools, one failed/
zero Unknown. Two watchdog expiries, two budget-exhausted attempts and two completed
runtime turns. Unfinished unrecorded inference remains unknown. This candidate cannot
meet the Rupi win criterion; the final Pi outcome is still pending.

Pi1 exits0 after196,736 ms with status `stop`, six requests/completions/usage records,
12,221 recorded work tokens (9,311 uncached input,2,910 output) and five completed
native events: two writes/three reads. Failed/Unknown counts remain unavailable, not
zero; completed events do not establish successful effects. Tests, acceptance and all
help checks fail without verification timeouts. Manifest lists only initializer70
bytes among application files; no entry point/tests/README are listed. Contents and
diagnostics remain unread; presence/sizes do not establish behavior or the failure cause.

Pi2 is observed live under node PID26392, runner19500/exec47054. Its saved repair
prompt preserves full SPEC/assertions/stable key/private fencing/lost-ack/oracle
isolation. Interim audit passes all seven completed-turn controls/prompts, copied
SPEC/two acceptance-file hashes/no extra non-cache files and initial prompt equality.
Binary/model/relay remain unchanged. The audit helper initially retained Case08's
lowercase repair check; it now checks the exact Case09 instruction and passes. No
benchmark prompt, configuration, gate or reference file was changed by that correction.

Next candidate selects existing Recurring/window3/cap12 after retry01 is terminal.
Window12 permitted a complete read-only budget-exhausted attempt; the smaller window
narrows available tools earlier under the already-verified runtime contract. All other
controls, shared full-spec prompts and complete gates stay unchanged. All-case selected
window3 dry-run guards and actual fresh-workspace configuration/reference-hash probe
pass. No inference or source change occurs in these probes, and no benefit is proven.
Do not launch this candidate concurrently or change the active window12 pair.
PR144 stays draft; Case09 remains unresolved and Case10 has not begun.

## Retry01 Pi second attempt verified (2026-10-04)

Pi2 reaches the600,228 ms watchdog with15,749 recorded work tokens (4,634 uncached
input,11,115 output), five requests/completions/usage records and five completed
native events: two writes/three edits. Failed/Unknown remain unavailable, not zero;
completed events do not establish successful effects. Unrecorded unfinished inference
remains unknown. Tests exit5, acceptance exits1 and all help checks pass without
verification timeouts. Manifest adds entry point27,226 bytes/test initializer16;
no test module or README is listed. Generated contents/diagnostics remain unread;
sizes do not establish unchanged content, complete behavior or the test failure cause.

Pi cumulative through two turns:27,970 recorded work tokens,796,964 ms call time
excluding verification,10 completed native events and one watchdog expiry; failed/
Unknown unavailable. All eight completed-turn prompt/control/reference audits pass;
initial equality and binary/model/relay remain unchanged. Selected Pi controls remain
native uncapped/six tools/null progress mode/window, low/budget2,048/native replay.

Pi3 is observed live under node PID38056, runner19500/exec47054; saved full-SPEC/
assertion/stable-key/private-fencing/lost-ack repair requirements pass. Let retry01
finish unchanged. Rupi remains unresolved after six; this candidate cannot win, but
the final Pi classification is pending. Validated window3 trial waits until terminal;
no source/config changes, local builds or concurrent inference. PR144 stays draft.
## Retry01 Pi third and fourth attempts verified (2026-10-04)

Pi3 exits0 after193,752 ms with status `stop`, six requests/completions/usage records
and8,487 recorded work tokens (5,971 uncached input,2,516 output). Five native events
complete: ls/three reads/edit. Tests exit5 and acceptance exits1; all help checks pass
without verification timeouts. Manifest lists entry point27,178 bytes/test initializer16;
no test module or README is listed. Generated contents and diagnostics remain unread.

Pi4 exits0 after239,960 ms with status `stop`, six requests/completions/usage records
and7,584 recorded work tokens (4,369 uncached input,3,215 output). Six native events
complete: two ls/two reads/grep/write. Tests and all help checks pass; acceptance fails,
without verification timeouts. Manifest adds tests/test_http.py7,235 bytes; other sizes
match turn3 and no README is listed. Sizes/presence do not establish unchanged contents,
complete behavior, exact edit targets or the acceptance failure cause. Native completion
events do not establish successful effects; failed/Unknown remain unavailable, not zero.
Unrecorded unfinished inference remains unknown.

Pi cumulative through four turns:44,041 recorded work tokens,1,230,676 ms call time
excluding verification,21 completed native events and one watchdog expiry. Rupi remains
unresolved after six and this candidate cannot win; the final Pi classification is pending.
Pi5 is observed live under node PID26784, original runner19500/exec47054. Its saved
full-SPEC/assertion/stable-key/private-fencing/lost-ack repair requirements pass. Keep
retry01 unchanged until terminal; validated window3 waits. No local builds or concurrent
inference. PR144 remains draft and Cases09/10 open. Branch inventory remains main plus
this active Case09 branch locally/remotely; detached earlier artifacts are preserved.
## Retry01 Pi fifth attempt verified (2026-10-04)

Pi5 exits0 after265,352 ms with status `stop`, six requests/completions/usage records
and11,279 recorded work tokens (8,337 uncached input,2,942 output). Five native read
events complete; no recorded mutation. Tests and help checks pass; acceptance fails,
without verification timeouts. Manifest sizes match turn4, with no README listed;
contents/diagnostics remain unread and sizes do not prove unchanged content. Failed/
Unknown remain unavailable, not zero; events do not establish successful effects and
unrecorded unfinished inference remains unknown. Pi cumulative through five turns:
55,320 recorded work tokens,1,496,028 ms call time excluding verification,26 completed
native events and one watchdog expiry. Neither agent has resolved acceptance.

Pi6 is observed live under node PID18332, original runner19500/exec47054. Saved full
SPEC/assertion/stable-key/private-fencing/lost-ack repair requirements pass. Preserve
this pair unchanged until terminal, then consider the already-validated window3 profile.
Rupi's six attempts remain unresolved; final matched classification is pending. PR144
stays draft, Cases09/10 open, no source/config changes, builds or parallel inference.
## Retry01 terminal: neither resolves acceptance in six turns (2026-10-04)

Pi6 exits0 after469,771 ms with status `stop`, eight requests/completions/usage records
and19,051 recorded work tokens (14,264 uncached input,4,787 output). Seven native events
complete: six reads/ls, no recorded mutation. Tests and help pass; acceptance fails,
without verification timeouts. Manifest sizes match turn5, no README listed. Contents/
diagnostics remain unread; sizes do not establish unchanged contents or failure cause.
Failed/Unknown remain unavailable, not zero; completion events do not establish effects.
Unrecorded unfinished inference remains unknown.

Both halves are terminal with no acceptance resolution after six attempts. Classification:
**inconclusive**, not a Rupi win or token/speed improvement. Rupi records166,364 work
tokens,2,696,841 ms authoring time,57 completed tools/one failed/zero Unknown; two
watchdogs/two budget-exhausted/two completed runtime turns. Pi records74,371 work tokens,
1,965,799 ms authoring time,33 native completion events/failed and Unknown unavailable;
one watchdog. Authoring time excludes verification. Final Rupi tests fail/help passes;
Pi tests/help pass. Neither manifest lists README; Rupi lists no tests. Full public-task
completion and default-runtime superiority are not established.

Exec47054 exits0; runner19500/wrapper22280/final Pi18332 are gone. Terminal audit passes
all twelve saved prompts/selected controls, initial prompt equality, copied SPEC/two
acceptance-file hashes/no extra non-cache files, actual Rupi configuration and unchanged
binary/model/relay. Source harness SHA F2F6A528...B54AD0 remains unchanged throughout.
No local builds or parallel model inference occurred in this pair.

Proceed with existing Recurring/window3/cap12 in a fresh sequential matched pair:
`bench-20261004-case09-window3-budget2048-low-retry02-rupi12-matched6-600s`.
All other settings and full shared prompts/gates remain unchanged. All-case selected3
guards and actual workspace/reference-hash probe already pass; this trial changes only
the existing Rupi progress window and establishes no causal benefit in advance.
PR144 stays draft; Cases09/10 remain open. Cases01 through08 configured wins are skipped.
