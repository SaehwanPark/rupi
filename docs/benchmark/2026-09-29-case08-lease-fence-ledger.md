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
| 04 | turn 2 | none in first 2 | 24,126 / 5,366 | [ledger](2026-09-29-case04-webhook-inbox-ledger.md) |
| 05 | turn 4 | none in 4 | 87,534 / 48,570 | [ledger](2026-09-29-case05-batch-relay-ledger.md) |
| 06 | turn 2 | none in 4 | 31,406 / 25,848 | [ledger](2026-09-29-case06-artifact-pipeline-ledger.md) |
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
