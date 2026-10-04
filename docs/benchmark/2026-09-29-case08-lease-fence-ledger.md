# Case 08 lease fence comparison ledger

This ledger records the matched `08-lease-fence` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

## Matched baseline

Run: `bench-20260929-case08-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,291 ms | 12,690 / 1,048 | 13,738 | 4 | 4 | outer timeout |
| 2 | 600,195 ms | 26,139 / 8,108 | 34,247 | 5 | 5 | outer timeout |
| 3 | 600,307 ms | 1,024 / 579 | 1,603 | 2 | 1 | outer timeout |
| 4 | 600,261 ms | 3,268 / 3,562 | 6,830 | 3 | 2 | outer timeout |

Rupi did not resolve in four turns. It used 56,418 work tokens over 2,401,054 ms, with 14
requests and 12 tools. All oracle, project-test, and help checks failed on every turn. The
service could not start because `leasefence.__main__` was missing. Project-test discovery
could not import the `tests` start directory.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,239 ms | 6,165 / 11,461 | 17,626 | 13 | 15 | outer timeout |
| 2 | 600,228 ms | 9,750 / 8,839 | 18,589 | 12 | 19 | outer timeout |
| 3 | 600,230 ms | 4,098 / 6,477 | 10,575 | 9 | 9 | outer timeout |
| 4 | 600,215 ms | 9,229 / 5,477 | 14,706 | 14 | 14 | outer timeout; unresolved |

Pi did not resolve in four turns. It used 61,496 work tokens over 2,400,912 ms, with 48
requests and 57 tools. All help checks passed. Project tests passed on turns 1 and 4; the turn
2 test check timed out after 180 seconds, and turn 3 had one failure among 47 tests. The oracle
failed on every turn. On turn 4, its stale-worker claim did not appear before the timeout.

## Outcome

The result is inconclusive because neither agent resolved the oracle. Pi used 5,078 more work
tokens and finished 142 ms sooner. Pi passed help throughout and project tests on its final
turn, but its acceptance oracle still failed. Case 09 is next.

## Active improvement slice (October 3)

Cases 01 through 07 already have verified Rupi comparison wins and are skipped.
Case 08 remains unresolved for both agents in the pinned baseline. This slice improves
the shared Case 08 authoring and recovery guidance, then repeats the comparison with
local `qwen3.8-flash-next` and pinned Pi 0.86.1. Reference source and acceptance fixtures
remain unchanged; generated code must come from the local model in fresh workspaces.

The target is an independently verified oracle resolution with fewer turns than Pi,
or fewer recorded work tokens when both resolve in the same turn. Project tests,
help, README completeness, failures, and unrecorded inference are reported separately.
Preserve the full public specification, especially conditional finalization with a
private token, expired-lease reclaim, and stale-worker rejection across fresh processes.
Recovery may use public-spec project tests and help diagnostics; oracle diagnostics
must remain hidden from both model runs. No case is complete based on timing alone.

Next: prepare shared bounded prompts, verify harness dry runs, and run the matched
four-turn comparison. Keep this slice open until current evidence establishes a win.

## First retry preparation

The shared prompt embeds the full public specification in initial and recovery turns.
It starts with a compact CLI/health entry point, help tests, and honest README, then
adds signed admission, durable ordered jobs, direct-argv worker execution, and private
claim-token fencing in the existing entry point. Local test/help failures select repair
rather than more workflow expansion. All oracle details remain hidden; only status is
included. The reference implementation and acceptance suite are unchanged.

Both agents use file tools, explicit low reasoning, and the same 2,048-token thinking
budget through the existing content-free loopback relay. Native reasoning replay is
enabled only for an endpoint explicitly declaring native exposure. Rupi receives an
empty child discovery profile; Pi retains disabled context/skill/extension flags.
Rupi's request cap is 12; Pi retains its native request policy. These are configured
comparison controls, not proof of default-runtime superiority or equal request policies.
Use four 600-second turns and six seconds of provider timeout grace with Pi 0.86.1.

Verified before launch:

- All ten cases passed `bench/compare-pi-rupi.ps1 -DryRun` with low reasoning and
  Case 08 budget 2,048, and again with reasoning off and no budget relay.
- Dry-run checks cover Case 08 foundation, workflow, and local-repair selection,
  preservation of the complete specification, and exclusion of an oracle diagnostic
  sentinel from model-visible recovery. Existing Case 07 guards also passed.
- `git diff --check` passed. Case 08 changes stay in the benchmark adapter.
- `cargo +stable build --bin rupi --target-dir C:/Users/saehwan/repos/rupi/target`
  passed. The installed stable route reports the exact pinned Rust and Cargo 1.98.1;
  the named 1.98.1 route lacks its cargo component on this machine.
- Author invariant review: no blocking findings. Workflow policy stays outside core;
  no uncertain tools are replayed, no hidden reasoning is inferred, and no acceptance
  diagnostics or reference implementation are added to authoring context.

The run result is pending. Keep the Case 08 comparison objective active.

## First retry in progress (2026-10-04 00:47 UTC)

Run: `bench-20261003-case08-budget2048-low-retry01-rupi12-matched4-600s`.
Source and launch head: `465ef6c`; settings remain fixed for the complete pair.
The configured local model is `qwen3.8-flash-next`; Pi version check reported 0.86.1.

Rupi turn 1 completed in 261,665 ms with 8,651 recorded work tokens (5,156 input,
3,495 output). Five model requests started/completed; six tools were requested,
five completed, one failed, and zero were Unknown. Project tests and all three
help checks passed; oracle failed. The file snapshot contains the entry point,
package/test initializers, one test module, and README. Contents and coverage
were not inspected; presence and passing help tests do not prove the workflow.

Turn 2 selected workflow recovery from the passing local gates. Its prompt embeds
the complete specification and includes only oracle pass/fail, not diagnostic output.
The runner remains live; Pi has not started. There is no matched result or winner yet.

All local checks passed using the installed stable route reporting pinned 1.98.1:
formatting, independent core compilation, workspace Clippy with warnings denied,
workspace tests, and workspace documentation. The startup script passed against the
same unchanged Rust sources: cold 197.31 ms, warm median 10.20 ms, maximum 13.22 ms,
within the 250/100 ms budgets. CI passed on Ubuntu, macOS, and Windows at `465ef6c`:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37165656761).

Continuation handles: execution session 32004; runner PID 2844; wrapper PID 17976;
task-owned budget relay PID 33028; shared model server PID 27356. Revalidate those
handles and process command lines before relying on this historical observation.
Worktree: `C:/Users/saehwan/repos/rupi-case10-receipt-ledger`, branch
`fix/case08-lease-fence`. The worktree directory name predates selecting Case 08.
Artifacts are under `.benchmark/runs/<run-id>/08-lease-fence/`; read per-turn
`summary.json` and `files.json`, not model logs, generated code, or oracle details.
Do not restart a live pair or change its prompts/settings mid-run. Finish the matched
pair, record the result, and merge PR #141 only after a verified win and final checks.
Cases 09 and 10 remain in scope afterward. The main checkout is current with the
user's usage-policy edit intact; only main and the active slice branches remain.

## Skip audit (October 4)

The parent rechecked each winning run's per-turn `summary.json` and selected model
configurations from the retained case worktrees. Every pair configured the same
`qwen3.8-flash-next`. This confirms the skip decisions from current local evidence;
no new model calls or source inspection were used. Turn counts below are oracle
resolution counts, not assertions of complete public-spec coverage.

| Case | Rupi resolution | Pi resolution | Recorded work tokens Rupi / Pi | Evidence |
| --- | --- | --- | ---: | --- |
| 01 | turn 4 | none in 4 | 13,590 / 9,631 | [ledger](2026-09-28-case01-task-ledger.md) |
| 02 | turn 1 | turn 2 | 22,020 / 30,974 | [ledger](2026-09-29-case02-reading-queue-ledger.md) |
| 03 | turn 2 | none in 4 | 25,140 / 59,136 | [ledger](2026-09-29-case03-event-outbox-ledger.md) |
| 04 | turn 2 | none in 2 | 24,126 / 5,366 | [run](2026-09-29-case04-webhook-inbox-ledger.md) |
| 05 | turn 4 | none in 4 | 87,534 / 48,570 | [ledger](2026-09-29-case05-batch-relay-ledger.md) |
| 06 | turn 2 | none in 4 | 31,406 / 25,848 | [run](2026-09-29-case06-artifact-pipeline-ledger.md) |
| 07 | turn 3 | none in 4 | 89,208 / 61,382 | [ledger](2026-09-29-case07-lease-cascade-ledger.md) |

Cases 01, 02, 03, and 06 have failing final Rupi project-test checks despite
oracle wins. Case 04's Pi run stopped once its earliest possible resolution would
require more turns than Rupi. Recorded work excludes unknown or unrecorded inference.
These are configured comparison wins, not a claim of default-runtime superiority.
Cases 08, 09, and 10 remain incomplete; do not close the full objective yet.

## First retry: Rupi turn 2 verified (2026-10-04 00:57 UTC)

Turn 2 reached its 600,251 ms outer timeout with 28,366 recorded work tokens
(19,251 input, 9,115 output), 11 started/10 completed model requests, and ten
usage records. Its read and nine edits completed with zero failed or Unknown tools.
Project tests and all three help checks passed; the oracle failed.

The entry point grew from 2,702 to 23,239 bytes; other snapshot sizes remained
unchanged, including the 1,267-byte test module. File sizes do not establish
implementation or test coverage. No source, model logs, or oracle diagnostics
were inspected. Unrecorded inference from the interrupted request remains unknown.

Rupi turn 3 is live (PID 25936 under runner 2844). The saved recovery prompt selects
workflow, preserves the full specification and fencing guidance, and includes only
oracle status. Source/settings remain fixed at `465ef6c`; Pi has not started.
There is no matched result yet. CI also passed on all three platforms at docs head
`0acb3c3`: [CI run](https://github.com/SaehwanPark/rupi/actions/runs/37166190348).

## First retry: Rupi turn 3 verified (2026-10-04 01:06 UTC)

Turn 3 reached its 600,192 ms outer timeout with 33,298 recorded work tokens
(27,611 input, 5,687 output). Counters record ten started/completed requests,
nine usage records, and nine completed tools with zero failures or Unknown.
Completion counters do not establish successful current-turn inference when usage
is absent. Project tests and all help checks passed; the oracle failed again.

The entry point is 23,360 bytes. Two sink fixtures appeared under `tests/sinks/`,
while `tests/test_leasefence.py` remains 1,267 bytes and README remains 4,146 bytes.
Fixture presence does not prove discovered workflow-test coverage. Source contents,
model output, and oracle details remain unread. Across three turns, Rupi recorded
70,315 work tokens and 1,462,108 ms call time, excluding verification.

Turn 4 is live (PID 33212 under runner 2844) with the same fixed source/settings.
Pi has not started; no matched result exists yet. The full Case 08 gate remains
open. CI passed all platforms at `550aaf3`:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37166549179).

## First retry: Rupi terminal, Pi active (October 4)

Rupi turn 4 exited 1 after 496,429 ms with a provider-timeout status rather than
an outer watchdog timeout. It recorded 3,479 work tokens (3,399 input, 80 output),
two started/three completion counters, one usage record, and two completed reads.
There were no failed or Unknown tools. Completion counters include `abandoned`;
they are not successful current-turn request counts. The file snapshot was unchanged.
Tests and all help commands passed; the oracle failed in every Rupi turn.

Rupi's terminal totals are 73,794 recorded work tokens and 1,958,537 ms call time,
27 requested/26 completed tools, one failed tool, and zero Unknown. Verification
time and unrecorded inference are excluded. Rupi did not resolve in four turns.

Pi began at 2026-10-04 01:13:58 UTC (node PID 9676 under runner 2844).
The two saved initial prompts have identical SHA-256 hashes. The run remains fixed
at launch source `465ef6c`; no full comparison outcome exists until Pi finishes.
All-platform CI passed at docs head `803a03d`:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37167171934).

## Next-retry candidate: discoverable workflow tests before repair

Rupi added only sink fixtures after its implementation grew to 23,360 bytes, while
the discovered test module stayed unchanged. The next shared recovery revision
requires `tests/test_workflow.py` after foundation checks pass. Its first write must
contain real public-command/HTTP tests; tiny sink fixtures live inside that module's
temporary directory, preventing fixture-only writes from consuming the attempt.
Tests cover signed admission, declared data flow, ordered fan-in, retry/blocking,
restart persistence, and a bounded fresh-process stale-worker race. Local failures
then route to implementation repair without weakening the failing workflow tests.

This is a prepared candidate, not the code running retry01. The live PowerShell
interpreter already loaded its launch functions and does not reload this script;
only public specs, configs, local verification output, and metric files are read
from disk. Those inputs remain unchanged. Confirm the old recovery guidance in
Pi's saved prompts before reporting retry01 as a matched comparison.

The candidate passed all-case low/budget-2,048 and off/no-budget dry runs. Checks
cover missing workflow-test routing, later workflow routing, repair routing, full
spec preservation, and oracle-diagnostic exclusion. Diff/column checks passed.
File presence selects a phase; it does not prove test coverage or case completion.
The oracle remains unchanged and no acceptance diagnostics were used to design
this revision. Launch a fresh pair only after retry01 is terminal and usage is checked.

## Retry01 control integrity and Pi turn 1

Pi turn 1 completed in 135,906 ms with 7,789 recorded work tokens, five model
requests, and four tools. Project tests and all three help commands passed;
the oracle failed. Pi turn 2 is live (node PID 36868 under runner 2844).
Its summary confirms budget 2,048 and the shared loopback relay endpoint.

The saved initial prompts are byte-identical, as are the two turn-2 recovery
prompts (SHA-256 `A528CF27D2F65734CC9CCC7AEAFD67688382406DDB5DB28C07C09D2CC93E23B0`).
Pi's turn-2 prompt retains the original complete-workflow guidance, excludes the
new test-module-first candidate, and preserves the full specification. Thus the
on-disk next-retry revision did not change this live control's recovery behavior.
Recheck later saved prompts when the pair finishes; no matched winner exists yet.

## Retry01 Pi turn 2 verified (2026-10-04 01:30 UTC)

Pi turn 2 reached its 600,213 ms outer timeout with 15,946 recorded work tokens
(4,241 input, 11,705 output), four requests/usage records, and four completed tools.
Project tests and the oracle failed; all three help checks passed. Pi failure and
Unknown counters are unavailable, not zero. Across two turns it recorded 23,735
work tokens and 736,119 ms call time, excluding verification.

Pi's snapshot contains a 20,588-byte entry point and a new 21,945-byte
`tests/test_workflow.py`, alongside the 1,221-byte foundation tests and 2,275-byte
README. Coverage and failure cause remain unproven; neither source nor diagnostics
were inspected. This contrasts with Rupi's unchanged discovered test module and
supports requiring a discoverable workflow-test write in the next shared retry.

Pi turn 3 is live (node PID 37364 under runner 2844). Its saved prompt selects the
original local-repair guidance, retains the full specification, and excludes both
candidate repair wording and the new test-authoring phase. The fixed control remains
valid. Both agents are still unresolved; finish Pi before starting the next pair.

## Retry01 Pi turn 3 verified (2026-10-04 01:38 UTC)

Pi turn 3 reached its 600,238 ms outer timeout with 18,497 recorded work tokens
(9,065 input, 9,432 output), 13 requests/usage records, and 13 completed tools.
Project tests and the oracle failed; all three help checks passed. Failure and
Unknown counters remain unavailable. Across three turns, Pi recorded 42,232 work
tokens and 1,336,357 ms call time, excluding verification.

The entry point is 21,139 bytes, workflow tests 21,701 bytes; foundation tests and
README remain unchanged. Contents and diagnostics remain unread. Both agents'
copied acceptance directories contain the same two reference files with matching
SHA-256 hashes, excluding Python caches. Their copied public specifications also
match the source. This is an integrity check, not an oracle success claim.

Pi turn 4 is live (node PID 37840 under runner 2844). Its saved prompt preserves
the complete specification and original repair guidance, excluding the candidate
workflow-test-first phase and new repair wording. Retry01 remains fixed at launch
source 465ef6c. There is no matched winner yet. All-platform CI passed at 13413e0:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37168385097).

## Retry01 terminal comparison (2026-10-04 01:48 UTC)

Pi turn 4 reached its 600,257 ms outer timeout with 17,368 recorded work tokens
(9,953 input, 7,415 output), 19 requests/usage records, and 19 completed tools.
Project tests and all help checks passed; the oracle failed. Its entry point is
20,755 bytes; workflow tests, foundation tests, and README are unchanged from turn 3.

The runner exited successfully and its model child is gone. Per-turn evidence gives:

| Agent | Oracle resolution | Work tokens | Call time | Final tests / help |
| --- | --- | ---: | ---: | --- |
| Rupi | none in 4 turns | 73,794 | 1,958,537 ms | pass / all pass |
| Pi | none in 4 turns | 59,600 | 1,936,614 ms | pass / all pass |

The comparison is inconclusive; lower Pi work and call time do not establish a
resolution win. Call time excludes verification; unrecorded inference is unknown.
Pi requested/completed 40 tools; its failure and Unknown counts are unavailable.
Rupi requested 27 tools, completing 26 with one failure and zero Unknown.

Final hashes still match both copied specifications and both two-file acceptance
suites. Every saved prompt preserves the complete specification and excludes the
prepared test-authoring candidate. Initial and turn-2 recovery prompts match across
agents. Neither generated code, model traces, nor oracle diagnostics were inspected.
CI passed all platforms at d59a38d:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37168839828).

Next: launch retry02 from the current committed workflow-test-first candidate in
fresh workspaces, retaining the same local model, pinned Pi, low/budget 2,048, four
600-second turns, six-second grace, and Rupi cap 12/Pi native request policy. The
parent's usage check at 01:48 UTC reported 51% five-hour and 73% weekly usage.
The relay remains task-owned and healthy; no other comparison is running.

## Retry02 launched (2026-10-04 01:49 UTC)

Run: `bench-20261003-case08-workflow-tests-budget2048-low-retry02-rupi12-matched4-600s`.
Launch source: `3f478a5`, including candidate `82b0b12`. Fresh workspaces were created.
Pinned Pi reports 0.86.1. The active Rupi config confirms local `qwen3.8-flash-next`,
relay endpoint 8001, low effort, native reasoning replay on declared native exposure,
request cap 12, timeout 594,000 ms, and read/write/edit/grep only. The relay is healthy
with budget 2,048 and content logging disabled. Four 600-second turns/six-second grace
remain unchanged. Pi retains its native request policy and file-tool allowlist.

Rupi turn 1 is live (PID 37440 under runner 24108; exec session 76232).
Its saved prompt preserves the complete specification and selects foundation.
Pi has not started. No result exists yet. Finish this pair before changing live inputs
or launching another comparison. Earlier retry01 artifacts remain untouched.

## Retry02 Rupi turn 1 verified (2026-10-04 01:55 UTC)

Turn 1 completed with exit 0 after 259,694 ms. It recorded 9,497 work tokens
(4,591 input, 4,906 output), four requests/usage records, and four completed writes.
There were no failed or Unknown tools. Project tests and all three help checks
passed; the oracle failed. The entry point is 2,874 bytes, foundation tests 1,568,
README 4,647, and test package marker 42. Contents remain unread.

Turn 2 is live (PID 20600 under runner 24108; exec session 76232). Its saved prompt
selects the new workflow-test-first phase, preserves the complete specification,
includes the bounded stale-worker race, and asks the model to yield for feedback.
Oracle diagnostics remain hidden. Pi has not started; no matched result exists.
CI passed all three platforms at f9c619f:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37169245011).

## Retry02 Rupi turn 2 verified (2026-10-04 02:02 UTC)

Turn 2 exited 1 after 407,412 ms with a provider-timeout status; the outer watchdog
did not fire. It records one started/completed request counter, no usage records,
and no tools. Recorded work is zero because usage is absent; actual inference is
unknown, not zero. No failed or Unknown tools were recorded. The file snapshot hash
matches turn 1, so no workflow test module was delivered. Tests and all help checks
passed; the oracle failed again. Completion counters do not prove inference success.

Turn 3 is live (PID 30164 under runner 24108; exec session 76232). Its saved prompt
again selects workflow-test-first and preserves the full specification. No input or
settings changed. Pi has not started; keep the pair running before evaluating the
candidate. All-platform CI passed at fdae641:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37169486236).

## Retry02 Rupi turn 3 verified (2026-10-04 02:09 UTC)

Turn 3 completed after 474,196 ms with 19,350 recorded work tokens (10,983 input,
8,367 output), three requests/usage records, and two completed tools (write/edit).
There were no failed or Unknown tools. The new discovered workflow test module is
19,971 bytes; the entry point, foundation tests, and README are unchanged. This
establishes module delivery, not complete coverage. Project tests and the oracle
failed; all three help commands passed. Code and diagnostics remain unread.

Turn 4 is live (PID 17732 under runner 24108; exec session 76232). Its saved prompt
selects local repair, preserves both CLI/workflow tests and the full specification.
Pi has not started. The launch binary/settings remain fixed. A separate isolated
provider transport investigation is reproducing whether active buffered tool
arguments can trigger the decoded-event idle timer; it does not change this trial.

## Retry02 Rupi terminal, Pi turn 1 verified (2026-10-04 02:22 UTC)

Rupi turn 4 exited 1 with provider-timeout status after 474,533 ms; no outer
watchdog fired. Recorded work is 5,911 tokens (3,550 input, 2,361 output), with two
started/completed request counters but one usage record, and one completed edit.
There were no failed or Unknown tools. Workflow tests grew to 20,019 bytes; all
other named project files are unchanged. Project tests/oracle fail; help all passes.
Missing usage and completion counters do not establish successful inference.

Rupi is unresolved in four turns: 34,758 recorded work tokens, 1,615,835 ms call time,
and seven completed tools with zero failures/Unknown. Turn 2 has no usage record;
its actual inference work is unknown, not zero. Verification time is excluded.

Pi turn 1 completed after 248,440 ms with 10,436 work tokens (5,845 input, 4,591
output), seven requests/usage records, and six completed tools. Failure/Unknown
counters are unavailable. Project tests/help pass; the oracle fails. Pi turn 2 is
live (node PID 12644 under runner 24108; exec session 76232), selecting the new test
phase. Initial prompts and turn-2 recovery prompts match byte-for-byte across agents.
The full specification remains in both. No matched comparison result exists yet.

Local Rust verification/builds ran alongside parts of Rupi's later turns and Pi's
early turns. Call time is therefore an observation on this host, not an isolated
performance measurement. Finish provider PR #142 and all builds before launching
any fresh corrected-binary pair. This live pair's binary and controls stay fixed.

## Retry02 Pi turn 2 and provider-fix handoff (2026-10-04 02:32 UTC)

Pi turn 2 reached its 600,267 ms outer timeout with 22,928 recorded work tokens
(12,329 input, 10,599 output), four requests/usage records and four completed tools
(write and three edits). Project tests and the oracle failed; all help checks
passed. Failure/Unknown counters remain unavailable. Its snapshot contains a
24,111-byte workflow test module, 3,157-byte entry point, 1,493-byte foundation tests
and 4,620-byte README. Code and diagnostics remain unread. Across two turns, Pi
recorded 33,364 work tokens and 848,707 ms call time, excluding verification.

Pi turn 3 is live (node PID 11116 under runner 24108; exec session 76232). Its saved
prompt selects repair, preserves both discovered test modules and the full spec.
The pair is still unresolved, with no matched winner. Launch source remains 3f478a5.

Provider PR #142 merged as 4174c1e after final-head CI passed on all platforms,
required local checks, 29 transport fixtures, startup budgets and author invariant
review. Its completed local/remote branch was removed. Root main is synchronized;
the user's uncommitted usage-policy edit is preserved. Only main and this active
Case 08 branch remain. See the merged provider ledger for evidence:
[provider idle fix](https://github.com/SaehwanPark/rupi/pull/142).

Continue this fixed original-binary pair to terminal state. Then verify all saved
prompts and reference hashes, record the outcome, integrate main into this branch,
check usage, rebuild/copy the corrected binary, and launch a fresh matched pair.
Do all local checks/builds before that launch. Cases 08 through 10 remain open.

## Retry02 Pi turn 3 verified (2026-10-04 02:43 UTC)

Pi turn 3 reached its 600,252 ms outer timeout with 12,506 recorded work tokens
(3,530 input, 8,976 output), one request/usage record and one completed write.
Project tests and the oracle failed; all help commands passed. Failure/Unknown
counters are unavailable. The entry point grew to 28,242 bytes; workflow tests,
foundation tests and README are unchanged. Contents/diagnostics remain unread.
Across three turns, Pi recorded 45,870 work tokens and 1,448,959 ms call time,
excluding verification. No oracle resolution exists for either agent.

Pi turn 4 is live (node PID 24148 under runner 24108; exec session 76232), selecting
repair with preserved CLI/workflow tests and the complete specification. The run
remains fixed on its original launch controls and copied binary. Wait for this
final turn before integrating the merged provider fix and launching a fresh pair.
All-platform CI passed at 752459f:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37171496578).

## Retry02 terminal comparison (2026-10-04 02:56 UTC)

Pi turn 4 reached its 600,242 ms outer timeout with 16,350 recorded work tokens
(7,719 input, 8,631 output), six requests/usage records and six completed tools.
Project tests timed out at the harness limit; the oracle failed without timing out.
All help checks passed. Its entry point is 28,373 bytes, workflow tests 25,290;
foundation tests/README remain unchanged. Contents and diagnostics remain unread.
The runner exited 0 and its process/verification children are gone.

| Agent | Oracle resolution | Recorded work | Call time | Final tests / help |
| --- | --- | ---: | ---: | --- |
| Rupi | none in 4 turns | 34,758 | 1,615,835 ms | failed / all pass |
| Pi | none in 4 turns | 62,220 | 2,049,201 ms | timed out / all pass |

This is inconclusive. Lower recorded Rupi work/call time does not establish a
resolution win. Missing Rupi usage means actual inference work remains unknown;
call time excludes verification and was not isolated from earlier local builds.
Rupi requested/completed seven tools with zero failures/Unknown. Pi requested and
completed 17; its failure and Unknown counters remain unavailable.

Both copied two-file acceptance suites and public specs still match source hashes.
All eight saved prompts preserve the complete spec; every turn retains low effort,
budget 2,048 and relay endpoint 8001. Rupi cap remains 12, Pi native policy uncapped.
Selected configs identify the same qwen3.8-flash-next model. Initial and turn-2
recovery prompts match across agents. Launch source/binary stayed fixed throughout.
All-platform CI passed at a10e913:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37171952325).

Next: integrate main's merged provider idle fix, rebuild the binary and verify the
unchanged adapter prompts/controls. Check usage, then launch retry03 in fresh
workspaces with the same model, prompts and matched settings. Finish all local
checks/builds first. Cases 08 through 10 remain open; keep this PR draft.

## Retry03 corrected-binary preparation (2026-10-04 03:00 UTC)

Main's provider fix was integrated as a04beec after retry02 was terminal. The
adapter script is byte-unchanged from retry02 source 3f478a5. Rust sources match
verified main 4174c1e; PR #142's required checks, transport tests, startup and CI
therefore apply to this unchanged Rust tree. All-case low/budget-2,048 and off/no-
budget dry runs passed again, including phase routing and oracle exclusion.

The corrected binary was rebuilt with stable 1.98.1 in this checkout, copied and
hash-verified. CLI help passed. Its SHA-256 is:

`081F516E12BF0BC349A36891AF1733AC0B98EF3B06A9856CDA61D37D7390BA11`

Retry02's original executable is preserved in its ignored run root as
rupi-original.exe, with SHA-256:

`48DC29D1F089DAFB1FDE7CEF607705CBF2831F0A6E04CD7D1C3D63F351489858`

No local build/check remains running. The shared relay is healthy with budget
2,048 and content logging disabled; the local model server is unchanged. Parent
usage at 03:00 UTC is 79% five-hour and 77% weekly, below the active soft stops.
Launch a fresh four-turn pair with the same low effort, 600-second limits,
six-second grace and Rupi cap 12/Pi native policy. Prompts, model and fixtures stay
fixed; the provider idle correction is the runtime change being tested.

## Retry03 launched (2026-10-04 03:02 UTC)

Run: `bench-20261003-case08-provider-idle-fix-budget2048-low-retry03-rupi12-matched4-600s`.
Launch source: 7178f5d, incorporating merged provider fix 4174c1e. Fresh workspaces
were created. Pinned Pi reports 0.86.1. The corrected selected binary has the hash
recorded above; no local check/build overlaps this pair's launch.

Rupi turn 1 is live (PID 6740 under runner 8524; exec session 12652). Its selected
config confirms local qwen3.8-flash-next, low effort, endpoint 8001, 594,000 ms
request timeout, native replay on declared exposure, request cap 12 and file tools
only. The saved prompt selects foundation, preserves the full specification and
matches retry02's initial prompt byte-for-byte. Budget remains 2,048 through the
unchanged relay; four 600-second turns/six-second grace and Pi native request policy
remain fixed. Pi has not started. No resolution or comparison outcome exists yet.

## Retry03 Rupi turn 1 verified (2026-10-04 03:06 UTC)

Turn 1 completed after 235,378 ms with 9,098 recorded work tokens (4,706 input,
4,392 output), four requests/usage records and five completed tools (four writes
and one edit). No failed or Unknown tools were recorded. Project tests and all
help commands passed; the oracle failed. The entry point is 2,307 bytes, foundation
tests 1,059 and README 3,818. Contents remain unread. This is foundation validation,
not full workflow completion or evidence of a comparison win.

Turn 2 is live (PID 15012 under runner 8524; exec session 12652). Its saved prompt
selects workflow-test-first, preserves the full specification and matches retry02's
turn-2 recovery prompt byte-for-byte. The corrected binary and fixed controls remain
unchanged. Pi has not started; the matched result is pending.

## Retry03 Rupi turn 2 verified (2026-10-04 03:17 UTC)

Turn 2 completed after 532,413 ms without either timeout. It recorded 21,105 work
tokens (11,454 input, 9,651 output), five requests/usage records and eight completed
tools (one write/seven edits), with zero failures/Unknown. The workflow test module
is 19,106 bytes; entry point, foundation tests and README remain unchanged. Contents
and diagnostics remain unread. Tests and oracle fail; all three help checks pass.
Module presence proves delivery, not complete coverage or oracle resolution.

Across two turns, Rupi recorded 30,203 work tokens and 767,791 ms call time,
excluding verification, with 13 completed tools and zero failures/Unknown. Unlike
retry02's second-turn provider timeout with no usage or tools, this turn delivered
the discovered test module with complete usage records. This observed difference
is not a standalone causal or comparison-win claim; the independent transport
fixture established the idle-timer bug, and this matched pair remains unfinished.

Turn 3 is live (PID 12884 under runner 8524; exec session 12652), selecting local
repair with preserved CLI/workflow tests and the full specification. Pi has not
started. Binary and controls remain fixed. Parent usage at 03:17 UTC is 86% five-hour
and 78% weekly, below soft stops; the five-hour window resets shortly.
All-platform CI passed at d9e560a:
[CI run](https://github.com/SaehwanPark/rupi/actions/runs/37173170972).

## Retry03 Rupi turn 3 and next-retry repair bound (2026-10-04 03:34 UTC)

Turn 3 reached its 600,201 ms outer timeout. It records 3,706 work tokens
(3,531 input, 175 output), two started requests, one completion/usage record and
one completed read. No failed or Unknown tools were recorded. The second request's
actual inference is unrecorded, not zero. The project snapshot hash matches turn 2:
no application change was delivered. Tests/oracle fail; all help checks pass.
Across three turns, recorded work is 33,909 tokens and call time 1,367,992 ms,
excluding verification. Pi has not started; no matched outcome exists.

Turn 4 is live (PID 35812 under runner 8524; exec session 12652). The selected
binary still matches the corrected hash above. Its saved prompt preserves the full
specification and original repair guidance, excluding the candidate bound below.

The next-retry candidate extends repair's vague small-edit instruction with the
100-line bound already used by workflow guidance: one focused application edit per
response, no whole-file replacement or helper modules, then continue editing in the
same attempt. Necessary bounded reads and test-helper repair remain permitted;
failing workflow assertions must still be preserved. This addresses missing source
delivery without inspecting generated code, model traces or oracle diagnostics.

All-case low/budget and off/no-budget dry runs pass, including repair bounds, full
spec preservation, test preservation and oracle-sentinel exclusion. Diff/column
checks pass. Author invariant review finds no blocking issue: policy stays in the
adapter, shared across agents, with no runtime, fixture or provenance changes.
This candidate is not active in retry03: its interpreter loaded launch definitions
once and does not reload the script. Recheck Pi's saved prompts before reporting the
pair. Launch a fresh candidate pair only after retry03 is terminal and usage checked.
At 03:34 UTC, usage is 4% five-hour after reset and 79% weekly, below soft stops.

## Retry03 Rupi terminal, Pi foundation verified (October 4)

Rupi turn 4 exited 1 after 595,430 ms with a provider-timeout status, not an outer
watchdog timeout. One request started, two completion counters include abandonment,
and no usage record or tool was delivered. Recorded work is zero because usage is
absent; actual inference is unknown. Snapshot hash matches turn 3. Tests/oracle
fail; all help checks pass. No failed or Unknown tools were recorded.

Rupi is unresolved in four turns: 33,909 recorded work tokens and 1,963,422 ms call
time, excluding verification, with 14 completed tools and zero failures/Unknown.
Unrecorded inference on turns 3 and 4 prevents an actual total-work claim. Completion
counters include prior abandoned requests and are not successful current-turn counts.

Pi turn 1 completed in 161,418 ms with 8,264 work tokens (5,450 input, 2,814 output),
six requests/usage records and five completed writes. Failure/Unknown counters are
unavailable. Tests/help pass; oracle fails. Pi turn 2 is live (node PID 33704 under
runner 8524; exec session 12652). Its prompt selects workflow-test-first and retains
the full specification. Initial and turn-2 recovery prompts match across agents;
the future repair bound is absent. Recheck later repair prompts to establish that
on-disk candidate 5ecff6f did not alter the loaded launch definitions.

No matched result exists yet. Keep the binary, copied specs/fixtures and selected
configs fixed. Finish Pi before selecting a new pair. The prepared bounded-repair
candidate is shared across agents only when a fresh interpreter is launched.

## Retry03 Pi turn 2 verified (2026-10-04 03:48 UTC)

Pi turn 2 completed in 263,462 ms with 8,606 recorded work tokens (3,409 input,
5,197 output), two requests/usage records and one completed write. Project tests and
the oracle failed; all help checks passed. Failure/Unknown counters are unavailable.
Its workflow test module is 15,807 bytes, entry point 3,270, foundation tests 2,283
and README 2,549. Contents and diagnostics remain unread. Across two turns, Pi
recorded 16,870 work tokens and 424,880 ms call time, excluding verification.

Pi turn 3 is live (node PID 3492 under runner 8524; exec session 12652). Its saved
repair prompt preserves CLI/workflow tests and the full specification, but excludes
the candidate's one-edit/100-line bound. This confirms that the on-disk candidate
did not replace the live interpreter's launch definitions. Recheck the final saved
prompt and reference hashes when terminal. Neither agent has resolved yet.
