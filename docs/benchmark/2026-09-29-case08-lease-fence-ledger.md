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

## Retry03 Pi turn 3 verified (October 4)

Pi turn 3 reached its 600,261 ms outer timeout with 10,746 recorded work tokens
(3,641 input, 7,105 output), three requests/usage records and three completed tools
(read and two writes). Project tests and the oracle failed; all help checks passed.
Failure/Unknown counters remain unavailable. Across three turns, Pi recorded 27,616
work tokens and 1,025,141 ms call time, excluding verification.

Pi turn 4 is live (node PID 17648 under runner 8524; exec session 12652). Its saved
repair prompt preserves the full specification and excludes the prepared 100-line
bound, confirming the launch definitions stayed fixed after the on-disk edit.
Neither agent has resolved the oracle. Finish this final turn before reference hash
checks, terminal outcome recording and a fresh bounded-repair candidate pair.

## Retry03 terminal audit (2026-10-04 04:07 UTC)

Pi turn 4 reached its 600,226 ms outer timeout with 14,896 recorded work tokens
(5,144 input, 9,752 output), 11 requests/usage records and 11 completed tools.
Project tests and oracle failed without verification timeouts; all help checks
passed. Failure/Unknown counters remain unavailable. The entry point is 23,599
bytes, foundation tests 1,198, workflow tests 13,666 and README 2,549. Contents and
diagnostics remain unread; file sizes do not establish coverage or completeness.

Neither agent resolved in four turns. Rupi recorded 33,909 work tokens,
1,963,422 ms call time and 14 completed tools; Pi recorded 42,512 work tokens,
1,625,367 ms and 20 completed tools. Call time excludes verification. Unrecorded
Rupi inference is unknown, so lower recorded work is not an actual total-work
claim. Both final project-test gates fail and help gates pass. This is an
inconclusive comparison, not a win or full public-spec completion.

All eight saved prompts retain the full public specification and exclude the
future repair bound, proving the loaded retry03 definitions stayed fixed. Both
copied specifications and both two-file acceptance sets match reference hashes.
Every turn records low effort, budget 2,048, endpoint 8001 and native reasoning
replay. Rupi's request cap is 12; Pi retains its native policy. Both selected model
configs name qwen3.8-flash-next. The binary still matches the corrected SHA256.
Exec session 12652 exited 0 and runner 8524 is gone; no live attempt is restarted.

The next fresh pair will load candidate 5ecff6f's shared one-edit/100-line repair
guidance. Its all-case low/budget and off/no-budget dry runs already pass, and no
runtime source changed after verified main 4174c1e. Usage at 04:06 UTC is 16%
five-hour and 81% weekly, below both soft stops. Cases 08 through 10 remain open.

## Bounded-repair retry04 launched (2026-10-04 04:08 UTC)

Fresh matched run:
`bench-20261004-case08-bounded-repair-budget2048-low-retry04-rupi12-matched4-600s`.
Launch source is d32b865, loading candidate 5ecff6f's shared bounded-repair guidance.
No runtime source differs from verified main 4174c1e; binary hash and help smoke
check pass. Relay health confirms budget 2,048, upstream 8000 and no content logging.
There is no other live comparison pair or build.

Rupi turn 1 is live (PID 10472 under runner 35136, wrapper 38316; exec session
54053). Its config selects local qwen3.8-flash-next, low effort, endpoint 8001,
594,000 ms provider timeout, native replay on declared exposure, request cap 12 and
file tools only. The saved foundation prompt contains the full specification and
matches retry03's initial prompt byte-for-byte. Four 600-second turns/six-second
grace and Pi's native request policy remain fixed. Verify the new bound in saved
repair prompts when that phase occurs. No outcome exists yet; Pi has not started.

## Retry04 Rupi foundation verified (2026-10-04 04:15 UTC)

Turn 1 completed in 339,783 ms with 16,998 recorded work tokens (10,962 input,
6,036 output), nine requests/completions/usage records and 13 completed tools.
Zero failed or Unknown tools were recorded. Project tests and all help commands
pass; oracle fails. Manifest sizes are entry point 2,372 bytes, server 2,362,
worker 363, foundation tests 1,335 and README 7,223. Contents remain unread;
foundation validation and file presence do not prove workflow completeness.

Turn 2 is live (PID 31788 under runner 35136; exec session 54053). Its saved
workflow-test-first prompt contains the full specification and matches retry03's
turn-2 prompt byte-for-byte. The repair-only bound is absent from this phase as
intended. Verify its presence when repair is selected. Pi has not started, and
no matched outcome exists. Keep the binary, model, controls and references fixed.

## Reasoning-budget protocol audit (2026-10-04 04:18 UTC)

The local llama executable reports 0.4.0-dev, build 10909, commit a2878d30d;
its serve help exposes the reasoning-budget control. The corresponding upstream
[chat parser source][budget]
reads request reasoning_budget_tokens before the alias and server default. It
passes the budget to sampling when the chat template exposes thinking end tags.
This confirms that the relay's canonical field is supported in that source;
it does not prove this model template's detected tags or actual reasoning length.
No model trace, generated code or acceptance diagnostics were inspected. The
relay, model process, configured budget and active pair remain unchanged.

[budget]: https://github.com/ggml-org/llama.cpp/blob/a2878d30d/tools/server/server-common.cpp

## Retry04 Rupi workflow-test delivery verified (2026-10-04 04:25 UTC)

Turn 2 reached the 600,302 ms outer timeout after one completed write. It recorded
13,452 work tokens (3,386 input, 10,066 output), two started requests and one
completion/usage record. Inference on the unfinished request remains unknown,
not zero. No failed or Unknown tools were recorded. The workflow-test module is
30,573 bytes; prior application, foundation tests and README sizes are unchanged.
Contents remain unread, and module presence does not prove complete coverage.
Project tests and oracle fail without verification timeouts; all help checks pass.

Across two turns, Rupi recorded 30,450 work tokens, 940,085 ms call time excluding
verification and 14 completed tools. No comparison result exists; Pi has not started.

Turn 3 is live (PID 30516 under runner 35136; exec session 54053). The saved prompt
selects repair and confirms the candidate's one focused application edit per
response, at most 100 new lines. It retains the full specification, CLI/workflow
test preservation and the instruction against large replacement/helper modules.
The bound is now verified as active. Model, binary, relay and controls remain fixed.
Parent usage is 23% five-hour and 82% weekly, below both soft stops.

## Retry04 Rupi bounded-repair delivery verified (2026-10-04 04:36 UTC)

Turn 3 reached its 600,248 ms outer timeout with 29,588 recorded work tokens
(21,298 input, 8,290 output), 12 started/completion counters and 11 usage records.
Completion counters include an abandoned prior request; they do not prove 12
successful current requests. It completed 13 tools: two edits, one write and ten
reads, with zero failed/Unknown. Application changes were delivered: entry point
11,983 bytes, server 178 and worker 188. Foundation/workflow test and README sizes
remain unchanged. Contents remain unread; neither bound compliance nor complete
workflow behavior can be inferred from the manifest. Tests/oracle fail, help passes.

Across three turns, Rupi recorded 60,038 work tokens, 1,540,333 ms call time
excluding verification and 27 completed tools. Unrecorded inference remains unknown.
Turn 4 is live (PID 38812 under runner 35136; exec session 54053). Its saved prompt
confirms repair, the full specification, bounded edit guidance and preservation of
both test sets. Pi has not started; no comparison result exists.

All-platform CI passed at c819fb0. Remote audit confirms only main and the active
Case08 branch remain, with root main's unrelated usage-policy edit preserved.
Read-only source inspection explains the post-write reads: the existing opt-in
progress boundary is intentionally one-shot per turn; a Changed mutating result
satisfies it for the rest of that turn. This is documented behavior, not a runtime
bug. No enforcement mode or binary changed during the pair.

## Retry04 Rupi terminal, Pi foundation live (2026-10-04 04:40 UTC)

Rupi turn 4 completed in 108,923 ms with 8,299 recorded work tokens (6,811 input,
1,488 output), one started request and one usage record. Two completion counters
include a prior abandoned request, not two successful current requests. No tools
or failed/Unknown tools were recorded. The manifest matches turn 3 byte-for-byte;
no file change was delivered. Tests/oracle fail without verification timeouts;
all help checks pass. Completed runtime status does not establish project completion.

Rupi remains unresolved after four turns: 68,337 recorded work tokens,
1,649,256 ms call time excluding verification and 27 completed tools. Unrecorded
inference remains unknown. The corrected binary hash is unchanged.

Pi turn 1 is live (node PID 28748 under runner 35136; exec session 54053). Its saved
initial prompt retains the full specification and matches Rupi byte-for-byte.
The selected model config names qwen3.8-flash-next and endpoint 8001. No comparison
result exists until Pi finishes; verify its later saved repair guidance and final
reference hashes. The candidate remains active only in this fresh interpreter.

## Retry04 Pi foundation verified (2026-10-04 04:43 UTC)

Pi turn 1 completed in 158,246 ms with 8,420 recorded work tokens (5,444 input,
2,976 output), three requests/completions/usage records and seven completed writes.
Failed/Unknown counters are unavailable. Project tests and all help checks pass;
oracle fails. Manifest sizes are entry point 2,114 bytes, server 1,408, worker 393,
foundation tests 1,176 and README 2,048. Contents remain unread; foundation validation
does not establish full workflow or README completeness.

Turn 2 is live (node PID 16668 under runner 35136; exec session 54053). The saved
workflow-test-first prompt retains the full specification and matches Rupi's turn-2
prompt byte-for-byte. Recheck the shared bound when Pi enters repair. Rupi remains
unresolved in four turns; the matched result is pending.

Separate draft PR #143 prepares an opt-in recurring progress-boundary contract from
main 4174c1e in an isolated checkout. Its default stays one-shot; implementation,
fixtures and verification are pending. Local builds are deferred until this pair is
terminal. No runtime mode, model, relay, fixture or binary changes during retry04.
The design is a future candidate, not proof of a Case08 win or an existing runtime bug.

## Retry04 Pi workflow-test delivery verified (2026-10-04 04:56 UTC)

Pi turn 2 completed in 586,899 ms without an authoring timeout. It recorded 21,186
work tokens (10,031 input, 11,155 output), eight requests/completions/usage records
and seven completed tools: one write, four edits and two reads. Failure/Unknown
counters remain unavailable. Tests/oracle fail without verification timeouts;
all help checks pass. The workflow-test module is 18,538 bytes; prior application,
foundation tests and README sizes remain unchanged. Contents remain unread.

Across two turns, Pi recorded 29,606 work tokens and 745,145 ms call time excluding
verification. Turn 3 is live (node PID 26316 under runner 35136; exec session 54053).
Its saved prompt confirms repair, the full specification, one focused application
edit per response/100-line guidance and preservation of both test sets. Both agents
therefore received the candidate in the repair phase. The result remains pending.

PR #143's implementation and fixtures are now drafted in the isolated checkout.
Formatting/diff checks pass at 2b06e63; compilation, runtime tests, startup budgets
and author invariant review remain pending. No local build has overlapped retry04.
Its source preparation does not alter this interpreter or the corrected benchmark
binary. Future recurring mode is not active in this pair.

## Retry04 Pi repair delivery verified (2026-10-04 05:04 UTC)

Pi turn 3 reached its 600,300 ms outer timeout with 15,468 recorded work tokens
(7,289 input, 8,179 output), five requests/completions/usage records and five
completed edits. Failure/Unknown counters remain unavailable. Entry point size is
14,375 bytes; prior helper, test and README sizes remain unchanged. Contents remain
unread. Tests/oracle fail without verification timeouts; all help checks pass.

Across three turns, Pi recorded 45,074 work tokens and 1,345,445 ms call time,
excluding verification. Turn 4 is live (node PID 13268 under runner 35136; exec
session 54053). Its saved prompt preserves the full specification, bounded edit
guidance and both test sets. Rupi is unresolved after four turns. Finish Pi and the
reference/control audit before recording the matched outcome or launching a new pair.

Separate PR #143 is pushed at fdbdb79. Remote CI caught a fake CLI write request
using `content` instead of the built-in's required `contents`; the fixture was
corrected without relaxing runtime validation or assertions. The CLI fixture also
requires a canonical Completed turn after an actual file change. New CI is pending;
local runtime checks and startup verification remain deferred until retry04 is
terminal. Its binary still matches the corrected SHA256; recurring mode is absent.

## Retry04 terminal audit (2026-10-04 05:13 UTC)

Pi turn 4 reached its 600,237 ms outer timeout with 16,306 recorded work tokens
(7,732 input, 8,574 output), 12 requests/completions/usage records and 13 completed
tools. Failure/Unknown counters remain unavailable. Entry point is 23,158 bytes,
server/worker 81 each; test and README sizes remain unchanged. Contents remain unread.
Final project tests and oracle fail without verification timeouts; help passes.

Neither agent resolved in four turns. Rupi recorded 68,337 work tokens,
1,649,256 ms call time and 27 completed tools; Pi recorded 61,380 work tokens,
1,945,682 ms and 32 completed tools. Call time excludes verification. Unrecorded
Rupi inference is unknown; recorded totals are not actual total-work claims.
Both final test gates fail and help gates pass. The comparison is inconclusive.

Both copied specifications and both two-file acceptance sets match reference
hashes, with no extra non-cache acceptance files. All eight saved prompts retain
the full specification; every repair prompt contains the shared bound and preserves
tests. All per-turn metadata retains low effort, budget 2,048, endpoint 8001,
native replay and Rupi cap 12/Pi native policy. The corrected binary hash is unchanged.
Exec session 54053 exited 0 and runner 35136 is gone. The attempt is terminal;
no timeout was treated as proof that an active process had stopped.

PR #143 passed all-platform CI at fdbdb79. Local required checks/startup measurement
can now begin without overlapping this pair. Usage is 46% five-hour and 85% weekly,
below both soft stops. Verify/merge that generic runtime slice before integrating it
into this branch and selecting recurring mode in a fresh matched comparison.
Baseline and four guided retries are inconclusive; Cases08 through 10 remain open.

## Recurring-progress candidate prepared (2026-10-04)

PR #143 passed final-head CI on Linux, macOS and Windows at a8edd208 and was
squash-merged as ab3dc33. Its required local checks, startup budgets and author
invariant review passed; the source tree was unchanged by the final documentation
commit. The merged local and remote branches were removed after exact-head audit.
This Case08 branch integrated main in f134c36 without conflicts.

The harness now accepts `-Case08ProgressBoundaryMode recurring`; its default is
`one_shot`. Only Case08's benchmark Rupi config receives this selector. Workspace
setup writes that config in both agent directories, but only Rupi consumes it;
Pi uses its separate native config and receives no equivalent runtime mode.
Per-turn metadata records null for Pi rather than suggesting parity.
Both agents retain the same public prompts, model, low effort, configured 2,048-token
reasoning budget, tool profiles, native replay and 600-second watchdog. Rupi retains
its request cap of 12; Pi retains its uncapped native policy. These runtime controls
are disclosed asymmetries, not evidence that default Rupi outperforms default Pi.

All-case dry-run guards passed with low effort/budget 2,048/recurring mode and with
off/no budget/default mode. They verify mode scope, specification preservation,
repair test preservation and exclusion of oracle diagnostic sentinels. Author review
found no blocking invariant issue: the selector changes runtime configuration only,
adds no diagnostic feedback, leaves shared guidance unchanged and preserves the
default. This is an author review, not an independent agent review.

A fresh debug binary built from the integrated Rust source passed its `--help`
smoke check. Its SHA256 is
`39829D0D62129F4138C449EC4FC913DE4EF81B028527B649EEDFEA1D3EE3D1C9`.
The source agrees with merged ab3dc33; this branch changes harness and evidence only.
Usage before launch was 58% five-hour and 87% weekly, below both soft stops.
Run matched retry05 before evaluating this candidate.
No Case08 win or broader stage gate is established by these runtime checks.

Retry05 launched from ddb5e89 as
`bench-20261004-case08-recurring-progress-budget2048-low-retry05-rupi12-matched4-600s`.
Continuation: exec session 85505, runner PID 14912 under wrapper 32740; first Rupi
PID 7332. Model PID 27356 and content-free relay PID 33028 were preserved. The
written Rupi config confirms recurring mode, progress limit 1, request cap 12,
low effort and endpoint 8001. The pair is live and no result is claimed.

## Retry05 Rupi foundation verified (2026-10-04 05:45 UTC)

Turn 1 completed in 264,547 ms with 9,736 recorded work tokens (4,580 uncached
input, 5,156 output), three requests/completions/usage records and four successful
writes. Failed and Unknown tool counts are zero. Project tests and all help checks
pass without timeouts; the oracle fails without a timeout. The entry point is
2,870 bytes, foundation test 1,511, test initializer 35 and README 4,267. Generated
contents remain unread. Turn 1 metadata confirms the selected controls and recurring
mode; saved turns 1 and 2 both contain the full specification. Turn 2 contains the
public workflow-test path and is live under Rupi PID 22688, runner 14912/session 85505.
There is no comparison result yet.

## Retry05 Rupi workflow tests delivered (2026-10-04)

Turn 2 completed in 454,367 ms, without authoring timeout, with 19,851 recorded
work tokens (11,357 uncached input, 8,494 output), two requests/completions/usage
records and one successful write. Failed/Unknown tool counts are zero. Project tests
and the oracle fail without verification timeouts; all help checks pass. Across two
turns, Rupi recorded 29,587 work tokens and 718,914 ms call time excluding verification.
The comparison remains pending. Turn 3 is live under Rupi PID 37700; continue runner
14912/exec session 85505 rather than launching another pair.

The workflow-test module is 21,145 bytes; prior application, foundation tests and
README sizes are unchanged. Contents remain unread. Turn 3's saved prompt retains
the full specification, shared 100-line focused-edit bound and instruction to preserve
both CLI and workflow tests. Literal test paths are not required by that instruction.

## Retry05 Rupi first repair verified (2026-10-04)

Turn 3 completed in 302,050 ms with 11,309 recorded work tokens (6,212 uncached
input, 5,097 output), three requests/completions/usage records and two successful
edits. Failed/Unknown tool counts are zero. Tests and the oracle fail without
verification timeouts; all help checks pass. The workflow-test module changed to
21,484 bytes; application, foundation tests and README sizes remain unchanged.
Generated contents remain unread. The manifest shows a test-module size change;
unchanged application sizes do not prove unchanged contents or identify edit targets.
Application implementation progress remains unverified. Across three turns,
Rupi recorded 40,896 work tokens and
1,020,964 ms call time excluding verification.

Turn 4 is live under Rupi PID 18940, runner 14912/session 85505. Its saved prompt
retains the full specification, shared focused-edit bound and preservation of both
test sets. The oracle remains unresolved and the paired result is pending.

## Retry05 Rupi terminal, Pi live (2026-10-04 06:08 UTC)

Rupi turn 4 reached the 600,333 ms outer watchdog with 55,437 recorded work tokens
(51,921 uncached input, 3,516 output), nine started requests and eight completions/
usage records. Eight tools completed: four reads alternating with four edits;
Failed/Unknown counts are zero. The final unfinished inference has unknown work.
Tests and oracle fail without verification timeouts; all help checks pass.
Entry point size increased to 9,524 bytes; prior test and README sizes remain
unchanged. These manifest sizes do not establish contents or complete implementation.
Generated contents remain unread.

Rupi is unresolved after four turns, with 96,333 recorded work tokens, 1,621,297 ms
call time excluding verification and 15 completed tools. Recorded work excludes
unknown unfinished inference. All four turn records confirm recurring mode,
progress limit configuration/request cap 12, low effort, budget 2,048, endpoint 8001
and native replay. The binary SHA256 still matches the prepared candidate.
All four Rupi saved prompts retain the full specification; repair turns preserve
the shared edit bound and both test sets. Both copied specifications match reference
hashes; initial Rupi/Pi prompts are byte-equal. Both two-file acceptance copies match
source hashes with no extra non-cache files.

Pi turn 1 is live under node PID 10248, runner 14912/exec session 85505.
Finish Pi before recording a matched comparison result or launching another pair.
Recurring enforcement is verified by separate fixtures; this unresolved half-run
does not prove a Case08 win or default-runtime superiority.

## Retry05 Pi foundation verified (2026-10-04)

Pi turn 1 completed in 157,372 ms with 7,905 recorded work tokens (5,423 uncached
input, 2,482 output), five requests/completions/usage records and four completed
writes. Failed/Unknown tool counters are unavailable. Project tests and all help
checks pass without timeouts; the oracle fails without a timeout. Per-turn metadata
confirms low effort, budget 2,048, endpoint 8001 and native replay; recurring mode
and harness request cap are null for Pi, preserving its native policy.
Turn 2 is live under node PID 6592, runner 14912/exec session 85505.
The paired comparison remains pending.

Pi's entry point is 2,563 bytes, foundation test 1,221, empty test initializer and
README 2,169; generated contents remain unread. Turn 2's saved prompt contains the
full specification and public workflow-test instructions, and is byte-equal to Rupi's
turn 2 prompt. The recurring property in Pi's unused copied Rupi config does not
configure Pi; its selected native settings remain separate.

## Retry05 Pi workflow-test attempt verified (2026-10-04)

Pi turn 2 reached the 600,295 ms outer watchdog with 15,000 recorded work tokens
(3,556 uncached input, 11,444 output), eight requests/completions/usage records and
eight completed writes. Failed/Unknown counters remain unavailable. Tests and oracle
fail without verification timeouts; all help checks pass. Across two turns Pi recorded
22,905 work tokens and 757,667 ms call time excluding verification.

Pi turn 3 is live under node PID 9208, runner 14912/exec session 85505. The paired
result remains pending; finish Pi before drawing a matched conclusion or starting
another pair. Generated application/test contents remain unread.

The manifest lists a 13,620-byte workflow-test module and 1,833-byte test helper,
along with application server/store/worker modules and a changed README size.
This differs from the shared instruction to yield after a self-contained test write.
No assertion about their correctness follows from file names or sizes.
Turn 3's saved prompt retains the full specification, shared focused-edit bound and
preservation of both test sets. Pi has not yet resolved the oracle.

## Retry05 Pi first repair verified (2026-10-04)

Pi turn 3 reached the 600,258 ms outer watchdog with 19,545 recorded work tokens
(10,026 uncached input, 9,519 output), seven requests/completions/usage records and
seven completed tools: five reads, one write and one edit. Failed/Unknown counters
remain unavailable. Tests and oracle fail without verification timeouts; all help
checks pass. Store and worker sizes are now 9,018 and 5,430 bytes respectively;
other manifest sizes remain unchanged. Contents remain unread and sizes do not
establish unchanged contents or correct implementation.

Across three turns Pi recorded 42,450 work tokens and 1,357,925 ms call time,
excluding verification. Per-turn metadata retains low effort, budget 2,048,
endpoint 8001, native replay and null mode/request cap for Pi's native policy.
Turn 4 is live under node PID 31772, runner 14912/exec session 85505. Its saved
prompt retains full SPEC, shared focused-edit bound and both test-set preservation.
Finish this final attempt and reference/control audit before recording the matched
result or selecting a new candidate. Cases08 through 10 remain open.

## Retry05 terminal matched audit (2026-10-04)

Pi turn 4 completed in 416,126 ms with 11,082 recorded work tokens (5,536 uncached
input, 5,546 output), ten requests/completions/usage records and nine completed tools:
six reads, two edits and one grep. Failed/Unknown counters remain unavailable.
Project tests and all help checks pass without timeouts; the oracle fails without
a timeout. The workflow-test module is 13,496 bytes; other manifest sizes remain
unchanged. Generated contents and diagnostic contents remain unread.

Neither agent resolved in four turns. Rupi recorded 96,333 work tokens and
1,621,297 ms call time; Pi recorded 53,532 tokens and 1,774,051 ms. Times exclude
verification. Tool completions are 15 for Rupi (zero failed/Unknown) and 28 for Pi
(failed/Unknown unavailable). Rupi's final unfinished inference work is unknown.
Final tests fail for Rupi and pass for Pi; both pass help and fail the oracle.
The matched result is inconclusive, not a Rupi win.

Both specifications and both two-file acceptance copies match source hashes with
no extra non-cache files. All eight saved prompts retain full SPEC; every repair
prompt preserves the shared edit bound and both test sets. Initial and turn-2 prompts
match between agents. All per-turn controls retain low effort, budget 2,048, endpoint
8001 and native replay. Rupi records recurring mode/cap 12; Pi records null mode/cap
for its native policy. Selected model configs retain the same qwen3.8-flash-next;
Rupi's provider deadline is 594,000 ms. The candidate binary hash is unchanged.
Exec session 85505 exited 0; runner 14912 and wrapper 32740 are gone.

Baseline and five guided retries remain inconclusive. A next shared candidate can
move implementation before workflow-test authoring and permit bounded application
modules, while retaining all public requirements, oracle isolation and honest gates.
This follows the recorded authoring sequence and public specification; no generated
code or oracle diagnostic inspection is needed. Cases08 through 10 remain open.

## Shared implementation-first candidate verified (2026-10-04)

After terminal retry05, the harness was revised for both agents. A passing compact
foundation now selects workflow implementation before workflow-test authoring.
Guidance writes compact store/worker/server modules, then wires the existing entry
point and updates README honestly. Missing modules remain in implementation phase;
all three module paths plus passing local gates select public workflow tests.
Path presence is a routing heuristic, not proof of implementation or completeness.
Failed local tests/help retain repair priority. Repair permits compact modules,
prefers fixing missing public application behavior, preserves all test assertions
and includes the same detailed transactional fencing/data-flow contract.

All-case dry-run guards pass with low/budget2,048/recurring and with off/no budget/
default mode. Fixtures cover absent, partial and complete modules; workflow-test
discovery; failed tests; failed help despite module markers; full SPEC preservation;
fencing guidance in implementation and repair; and oracle sentinel exclusion.
Whitespace and added-line-width checks pass. Rust source agrees with merged main;
no runtime rebuild or duplicate full Rust checks were needed for this harness change.
The selected binary SHA256 remains
`39829D0D62129F4138C449EC4FC913DE4EF81B028527B649EEDFEA1D3EE3D1C9`.

Author invariant review: pass, no blocking finding. The shared authoring sequence
changes neither the verifier nor its acceptance criteria, does not expose oracle
diagnostics, does not weaken public tests, and stays outside core runtime.
No independent agent review is claimed. A fresh matched retry06 must establish any
comparison improvement; baseline and retries01 through 05 remain inconclusive.
