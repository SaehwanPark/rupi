# Case 07 lease cascade comparison ledger

This ledger records the matched `07-lease-cascade` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

Request-budget clarification: `MaxModelRequestsPerTurn=8` configures Rupi's runtime.
The harness leaves Pi's native request behavior intact. Historical references to eight
requests per turn in this ledger mean the Rupi cap. These comparisons share model,
thinking, turn count, and outer time limits while retaining different request policies.
Retry 18 Pi turn 3 recorded nine completed model requests; baseline Pi also exceeded eight.

## Matched baseline

Run: `bench-20260929-case07-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,242 ms | 15,635 / 7,218 | 22,853 | 7 | 7 | outer timeout |
| 2 | 600,361 ms | 9,131 / 8,526 | 17,657 | 3 | 2 | outer timeout |
| 3 | 600,222 ms | 6,512 / 8,433 | 14,945 | 4 | 3 | outer timeout |
| 4 | 487,934 ms | 13,492 / 818 | 14,310 | 3 | 2 | completed; unresolved |

Rupi did not resolve in four turns. It used 69,765 work tokens over 2,288,759 ms, with 17
requests and 14 tools. All four acceptance-oracle checks failed. Project-test discovery failed
because Python could not import the `tests` start directory. The three help checks failed on the
first three turns; on turn 4, root and `serve` help passed while `worker` help still failed.
The final oracle run saw four disconnected HTTP requests and a worker-help failure.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,309 ms | 7,526 / 11,092 | 18,618 | 10 | 11 | outer timeout |
| 2 | 600,211 ms | 7,609 / 6,899 | 14,508 | 12 | 17 | outer timeout |
| 3 | 600,274 ms | 6,049 / 8,701 | 14,750 | 12 | 13 | outer timeout |
| 4 | 600,228 ms | 7,171 / 7,241 | 14,412 | 16 | 16 | outer timeout; resolved after verification |

Pi resolved on turn 4 after the outer timeout. Its final turn passed the acceptance oracle, all
53 project tests, and all three help checks. Pi used 62,288 work tokens over 2,401,022 ms, with
50 requests and 57 tools.

## Baseline outcome

Pi resolved where Rupi did not, a strict oracle win. Pi used 7,477 fewer work tokens but took
112,263 ms longer. Rupi project-test discovery could not import `tests`; oracle requests were
disconnected, and worker help still failed on turn 4. Case 08 was next at that checkpoint.

## Prompt-guided retry

Run: `bench-20261002-case07-lease-cascade-guided-retry1-matched4-600s`.

The matched retry used local `qwen3.8-flash-next`, pinned Pi 0.86.1, four turns, 600-second
turn limits, six-second provider grace, eight requests per turn, and thinking off. Recovery
feedback included project tests, help results, and oracle pass/fail status only.

| Agent | Turn | Work tokens | Tool requests | Application files added |
| --- | ---: | ---: | ---: | --- |
| Rupi | 1 | 6,744 | 1 | none |
| Rupi | 2 | 0 | 0 | none |
| Rupi | 3 | 0 | 0 | none |
| Rupi | 4 | 13,621 | 2 | `leasecascade/__init__.py` only |
| Pi | 1 | 0 | 0 | none |
| Pi | 2 | 5,584 | 7 | none |
| Pi | 3 | 0 | 0 | none |
| Pi | 4 | 0 | 0 | none |

Every turn failed project tests with exit code 1, failed the oracle with exit code 1, and failed
all three help commands with exit code 1. Neither agent resolved the oracle. The strict oracle
comparison therefore has no winner in this retry; the baseline Pi win remains the last resolved
comparison. Case 07 remains the active target.

The worktree could not rebuild `rupi.exe`: the installed pinned 1.98.1 toolchain lacks its Cargo
component. The run used the existing root binary; the root and benchmark base had no Rust crate
source differences. Runner stdout/stderr and raw agent output were redirected or retained without
being read. Only per-turn `summary.json` and `files.json` fields were used for this entry.

## Bounded-slice retry

Run: `bench-20261002-case07-lease-cascade-firstwrite-retry2-matched4-600s`.

The matched retry used local `qwen3.8-flash-next`, pinned Pi 0.86.1, four turns, 600-second
turn limits, six-second provider grace, eight requests per turn, and thinking off.

| Agent | Turn | Work tokens | Tool requests | Application files added |
| --- | ---: | ---: | ---: | --- |
| Rupi | 1 | 0 | 0 | none |
| Rupi | 2 | 0 | 0 | none |
| Rupi | 3 | 0 | 0 | none |
| Rupi | 4 | 0 | 0 | none |
| Pi | 1 | 17,456 | 1 | `leasecascade/__main__.py` (45,962 bytes) |
| Pi | 2 | 1,725 | 4 | none |
| Pi | 3 | 0 | 0 | none |
| Pi | 4 | 0 | 0 | none |

Rupi recorded one completed model request per turn, but zero work tokens and zero tool calls
on every turn; no application files were added. Pi used three model requests and five tool calls.
Every turn failed project tests, the oracle, and all three help commands with exit code 1. Pi's
four calls reached the 600-second limit. Neither agent resolved the oracle, so this retry has no
winner. The baseline Pi win remains the last strict result, and Case 07 remains active.

The isolated worktree used the existing root `rupi.exe`; rebuilding remained unavailable because
the installed pinned 1.98.1 toolchain lacks the Cargo component. Runner stdout/stderr and raw agent
output were not read. Only per-turn `summary.json` and `files.json` fields were used here.

For a third attempt, constrain the first write to the runnable CLI/help and health route, add test
discovery before persistence or worker behavior, and keep later writes narrowly scoped. Pi wrote a
45,962-byte entry point without resolving the oracle, while Rupi added no application files.
Case 07 stays active until a matched attempt produces a strict oracle win.

## Bounded-slice retry result

Run: `bench-20261002-case07-bounded-slice-retry3-matched4-600s`.

The matched retry used local `qwen3.8-flash-next`, pinned Pi 0.86.1, four turns, 600-second
turn limits, six-second provider grace, eight requests per turn, and thinking off.

| Agent | Turn | Work tokens | Tool requests | Application files added |
| --- | ---: | ---: | ---: | --- |
| Rupi | 1 | 9,020 | 3 | entry point and test package |
| Rupi | 2 | 12,596 | 1 | none |
| Rupi | 3 | 0 | 0 | none |
| Rupi | 4 | 7,117 | 0 | none |
| Pi | 1 | 18,477 | 6 | four app files and two test files |
| Pi | 2 | 12,149 | 8 | three app files |
| Pi | 3 | 10,065 | 7 | none |
| Pi | 4 | 7,348 | 3 | one test helper |

Rupi added `leasecascade/__main__.py` and `tests/__init__.py`, but no test module. Project tests
exited 5 and all three help checks exited 1 on every turn. Its oracle also exited 1 every turn.

Pi added `leasecascade/__main__.py`, `pipeline.py`, `signing.py`, and `storage.py`, plus
`tests/__init__.py` and `tests/test_leasecascade.py` on turn 1. Turn 2 added `__init__.py`,
`serve_cmd.py`, and `worker_cmd.py`; turn 4 added `tests/sink_program.py`.

Pi project tests and all three help commands passed on every turn, but the oracle exited 1 on
every turn. All four Pi calls reached the 600-second limit. Neither agent resolved the oracle, so
there is no strict winner. The baseline Pi win remains the last resolved comparison, and Case 07
remains active.

The isolated worktree used the existing root `rupi.exe`; rebuilding remained unavailable because
the installed pinned 1.98.1 toolchain lacks the Cargo component. Runner stdout/stderr and raw agent
output were not read. Only per-turn `summary.json` and `files.json` fields were used.

The bounded first slice moved Pi past the local gates, while Rupi still lacked a test module.
For retry 4, require the test package and module as the second workspace write, and direct
foundation recovery to add the test module before persistence or worker behavior. The all-case
`-DryRun` passes, including a prompt check for the foundation phase. Keep Case 07 active; update
ROADMAP only after verified strict oracle progress.

## Explicit test-write retry result

Run: `bench-20261002-case07-explicit-test-write-retry4-matched4-600s`.

The matched settings used local `qwen3.8-flash-next`, pinned Pi 0.86.1, four turns, 600-second
turn limits, six-second provider grace, eight requests per turn, and thinking off.

| Agent | Turn | Work tokens | Tools | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | ---: | --- | ---: |
| Rupi | 1 | 16,719 | 1 | 1 | 0/0/0 | 1 |
| Rupi | 2 | 0 | 0 | 1 | 0/0/0 | 1 |
| Rupi | 3 | 3,828 | 3 | 0 | 0/0/0 | 1 |
| Rupi | 4 | 0 | 0 | 0 | 0/0/0 | 1 |
| Pi | 1 | 17,772 | 1 | 1 | 1/1/1 | 1 |
| Pi | 2 | 12,605 | 14 | 0 | 0/0/0 | 1 |
| Pi | 3 | 0 | 0 | 0 | 0/0/0 | 1 |
| Pi | 4 | 0 | 0 | 0 | 0/0/0 | 1 |

Rupi wrote a 3,001-byte `leasecascade/__main__.py` on turn 1. Turn 3 added
`leasecascade/__init__.py`, `tests/__init__.py`, and `tests/test_leasecascade.py`; the files
remained unchanged on turn 4. Rupi help passed on every turn, and project tests passed on turns
3 and 4. Turns 2 and 4 recorded timeout failures with no work tokens or tool calls.

Pi turn 1 wrote a 5,839-byte entry point, but tests and help failed. By turn 2, its snapshot
included package and test files, and a 5,400-byte entry point. Tests and help passed on turns
2 through 4. Turns 3 and 4 timed out without requests, tokens, or tool calls.

Both agents failed the oracle on all four turns and neither resolved the case. Rupi used 20,547
work tokens and four tools over 2,208,889 ms. Pi used 30,377 work tokens and 15 tools over
2,315,568 ms. There is no strict winner; the baseline Pi oracle win remains the last resolved
comparison. Case 07 stays active.

The prompt moved Rupi past test discovery and help, but no attempt passed the oracle. For retry 5,
when these local gates pass and the oracle still fails, direct the recovery turn to audit and finish
the signed admission, durable ordered state, lease/reclaim, and selected-field barrier workflow.
Do not spend that phase repeating CLI or test-discovery scaffolding. Runner output and logs were
not read; this entry uses only per-turn `summary.json` and `files.json` fields.

## Workflow-focused recovery retry result

Run: `bench-20261002-case07-workflow-recovery-retry5-matched4-600s`.

The matched settings used local `qwen3.8-flash-next`, pinned Pi 0.86.1, four turns, 600-second
turn limits, six-second provider grace, eight requests per turn, and thinking off.

| Agent | Turn | Work tokens | Tools | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | ---: | --- | ---: |
| Rupi | 1 | 19,531 | 3 | 0 | 0/0/0 | 1 |
| Rupi | 2 | 18,209 | 4 | 0 | 0/0/0 | 1 |
| Rupi | 3 | 3,829 | 1 | 0 | 0/0/0 | 1 |
| Rupi | 4 | 10,141 | 1 | 0 | 0/0/0 | 1 |
| Pi | 1 | 0 | 0 | 1 | 1/1/1 | 1 |
| Pi | 2 | 8,609 | 10 | 1 | 1/1/1 | 1 |
| Pi | 3 | 0 | 0 | 1 | 1/1/1 | 1 |
| Pi | 4 | 13,326 | 7 | 0 | 0/0/0 | 1 |

Rupi passed project tests and all three help checks on every turn. Its first snapshot included the
entry point and both test files; later turns added `storage.py`, `serve.py`, and `worker.py` in
sequence. The oracle failed on all four turns.

Pi had no application files on turn 1. Turn 2 added a 355-byte entry point, and turn 3 did not
change the snapshot. Turn 4 added a 9,683-byte `cli.py`, package and test files, and a README.
Project tests and all help checks passed only on turn 4. The oracle failed on every turn.

All eight turns reached the 600-second limit. Rupi used 51,710 work tokens and nine tools over
2,400,970 ms; it started 11 requests and completed 10. Pi used 21,935 work tokens and 17 tools
over 2,400,855 ms, starting and completing 11 requests. Neither agent resolved the case, so there
is no strict winner. The baseline Pi oracle win remains the last resolved comparison. Case 07 stays
active.

Retry 5 moved Rupi into workflow modules but added storage, serving, and worker behavior in
separate turns without an oracle pass. For retry 6, prioritize one end-to-end vertical slice that
wires signed admission, durable ordered state, worker execution, and result transitions together.
Then cover ordered fan-in, selected fields, lease reclaim, and blocked dependents. Do not spend a
recovery turn adding an isolated module without integrating the request-to-worker path. Runner
output and logs were not read; this entry uses only per-turn `summary.json` and `files.json` fields.

## Integrated vertical-slice retry result

Run: `bench-20261002-case07-integrated-vertical-retry6-matched4-600s`.

The matched settings used local `qwen3.8-flash-next`, pinned Pi 0.86.1, four turns, 600-second
turn limits, six-second provider grace, eight requests per turn, and thinking off.

| Agent | Turn | Work tokens | Tools | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | ---: | --- | ---: |
| Rupi | 1 | 0 | 0 | 1 | 1/1/1 | 1 |
| Rupi | 2 | 14,379 | 3 | 5 | 0/0/0 | 1 |
| Rupi | 3 | 10,387 | 3 | 0 | 0/0/0 | 1 |
| Rupi | 4 | 10,996 | 4 | 0 | 0/0/0 | 1 |
| Pi | 1 | 17,336 | 2 | 1 | 0/0/1 | 1 |
| Pi | 2 | 11,327 | 9 | 1 | 0/0/0 | 1 |
| Pi | 3 | 6,923 | 9 | 1 | 0/0/0 | 1 |
| Pi | 4 | 9,188 | 2 | 1 | 0/0/0 | 1 |

Rupi turn 1 recorded zero work and no files. Turn 2 wrote the entry point and test package, but
project test discovery exited 5. Turn 3 added the test module and passed project tests and help.
Turn 4 kept those gates passing but changed only the test file snapshot; no workflow source module
was added. The oracle failed on all four turns.

Pi wrote its entry point on turn 1 and expanded it on turn 2. Turn 3 added the test package and
module; turn 4 kept that snapshot. Its project tests failed on all four turns, while all help
checks passed on turns 2 through 4. The oracle failed on every turn.

Rupi used 35,762 work tokens and ten tools over 1,926,339 ms, starting 11 requests and completing
10. Pi used 44,774 work tokens and 22 tools over 2,060,203 ms, starting and completing 24
requests. Neither agent resolved the oracle, so there is no strict winner. The baseline Pi oracle
win remains the last resolved comparison. Case 07 stays active.

The workflow recovery phase did not produce workflow source in its final turn. For retry 7, move a
bounded end-to-end path into the initial turn: after the compact entry point and both test files,
require signed submission, durable ordered jobs, worker execution, and an observable result before
the initial turn ends. Keep recovery focused on wiring and repairing that path. Runner output and
logs were not read; this entry uses only per-turn `summary.json` and `files.json` fields.

## Initial-turn vertical-path retry result

Run: `bench-20261002-case07-initial-vertical-retry7-matched4-600s`.

The matched settings used local `qwen3.8-flash-next`, pinned Pi 0.86.1, four turns, 600-second
turn limits, six-second provider grace, eight requests per turn, and thinking off.

| Agent | Turn | Work tokens | Tools | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | ---: | --- | ---: |
| Rupi | 1 | 15,265 | 2 | 5 | 0/0/0 | 1 |
| Rupi | 2 | 732 | 1 | 5 | 0/0/0 | 1 |
| Rupi | 3 | 9,507 | 1 | 5 | 0/0/0 | 1 |
| Rupi | 4 | 8,492 | 1 | 1 | 0/0/0 | 1 |
| Pi | 1 | 0 | 0 | 1 | 1/1/1 | 1 |
| Pi | 2 | 5,817 | 8 | 1 | 1/1/1 | 1 |
| Pi | 3 | 0 | 0 | 1 | 1/1/1 | 1 |
| Pi | 4 | 0 | 0 | 1 | 1/1/1 | 1 |

Rupi passed all three help checks on every turn. Test discovery exited 5 on turns 1–3, then the
project tests exited 1 on turn 4. Its snapshots show an entry point and test package from turn 1,
`validation.py` from turn 3, and `tests/test_leasecascade.py` only on turn 4. The oracle failed on
all turns; no integrated workflow path appeared.

Pi added no application files on any turn. Its project tests, help checks, and oracle failed on
every turn. All eight calls timed out at the 600-second limit.

Rupi used 33,996 work tokens and five tools over 2,401,056 ms, starting nine requests and
completing eight. Pi used 5,817 work tokens and eight tools over 2,400,855 ms, starting and
completing five requests. Neither agent resolved the case, so there is no strict winner. The
baseline Pi oracle win remains the last resolved comparison. Case 07 stays active.

Retry 7 requested the test files before workflow code, but Rupi wrote `validation.py` while the
test module was still missing and added the module only on turn 4. For retry 8, make the missing
module the only allowed next write: create both test files together, and prohibit validation,
storage, server, or worker files until test discovery and help pass. Runner output and logs were
not read; this entry uses only per-turn `summary.json` and `files.json` fields.

## Eighth foundation prompt revision

Retry 8 requires both test files together as the next source write after the entry point. During
foundation recovery, a missing test file or test-discovery exit 5 restricts the next write to those
tests. Until test discovery and all three help checks pass, no other source files may be written;
validation, storage, server, and worker files are explicitly deferred. The all-case
`bench/compare-pi-rupi.ps1 -DryRun` passed with the new prompt checks. Start the matched retry
only after a fresh usage check.

## Eighth matched retry result

Run: `bench-20261002-case07-foundation-test-only-retry8-matched4-600s`.

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Rupi | 1 | 19,494 | 2 | 600,213 ms timeout | 5 | 0/0/0 | 1 |
| Rupi | 2 | 19,787 | 4 | 266,833 ms | 0 | 0/0/0 | 1 |
| Rupi | 3 | 11,550 | 1 | 600,408 ms timeout | 0 | 0/0/0 | 1 |
| Rupi | 4 | 20,113 | 6 | 600,490 ms timeout | 0 | 0/0/0 | 1 |
| Pi | 1 | 8,574 | 1 | 600,238 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 2 | 8,047 | 7 | 273,073 ms | 0 | 0/0/0 | 1 |
| Pi | 3 | 0 | 0 | 600,238 ms timeout | 0 | 0/0/0 | 1 |
| Pi | 4 | 0 | 0 | 600,215 ms timeout | 0 | 0/0/0 | 1 |

Rupi passed all three help checks on every turn. Project-test discovery exited 5 on turn 1, then
tests passed on turns 2–4. The first snapshot had `__main__.py` and `tests/__init__.py`; the test
module arrived on turn 2. Turn 3 added the package initializer. Turn 4 added `storage.py` and
`validation.py` after the local gates passed, but no server or worker source appeared. The oracle
failed all four turns.

Pi failed tests and all help checks on turn 1, then passed them on turns 2–4. It added the test
package and module on turn 2; turns 3–4 had no requests or tools and did not change the snapshot.
The oracle failed all four turns.

Rupi used 70,944 work tokens and 13 tools over 2,067,944 ms. Pi used 16,621 work tokens and eight
tools over 2,073,764 ms. Neither resolved the case, so there is no strict winner. The baseline Pi
oracle win remains the last resolved comparison. This entry uses only per-turn `summary.json` and
`files.json`; runner output, agent output, and session traces were not read.

Retry 8 kept workflow modules out until tests and help passed, but Rupi still used its second
source write for `tests/__init__.py` alone and timed out before creating the test module. Retry 9
will explicitly prohibit an initializer-only write: the second write call must create both test
files together, including an importable `TestCase` and `test_` method. Keep the current recovery
restriction on non-test source until test discovery and all help checks pass.

## Ninth initial-write refinement

Retry 8 used Rupi's second write for `tests/__init__.py` alone; the test module arrived only on
turn 2. Retry 9 now says the second workspace write call must create both test files together and
must not spend a separate call on the initializer alone. Foundation recovery repeats the
prohibition. The all-case `-DryRun`, `git diff --check`, 100-column, and CRLF checks pass. Start the
next matched attempt only after a fresh usage check.

## Ninth matched retry result

Run: `bench-20261002-case07-atomic-test-write-retry9-matched4-600s`.

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Rupi | 1 | 0 | 0 | 594,151 ms timeout | 1 | 1/1/1 | 1 |
| Rupi | 2 | 0 | 0 | 595,828 ms timeout | 1 | 1/1/1 | 1 |
| Rupi | 3 | 0 | 0 | 597,634 ms timeout | 1 | 1/1/1 | 1 |
| Rupi | 4 | 0 | 0 | 599,257 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 1 | 16,929 | 2 | 600,235 ms timeout | 5 | 0/0/0 | 1 |
| Pi | 2 | 11,689 | 3 | 600,264 ms timeout | 1 | 0/0/0 | 1 |
| Pi | 3 | 7,679 | 2 | 600,247 ms timeout | 0 | 0/0/0 | 1 |
| Pi | 4 | 5,130 | 1 | 600,314 ms timeout | 0 | 0/0/0 | 1 |

Rupi's four turns each failed with a timeout and show zero usage records, work tokens, and tool
requests. Tests and all three help checks exited 1 on every turn. Its file snapshots contain no
application files, so the new prompt instruction was not meaningfully exercised.

Pi passed all help checks every turn. Its project tests exited 5 on turn 1 and 1 on turn 2, then
passed on turns 3–4. The test module first appeared on turn 2; turn 3 added `validation.py`, and
turn 4 added `storage.py`. No server or worker source appeared. Its oracle failed on every turn.

Pi used 41,427 work tokens and eight tools over 2,401,060 ms. Neither agent resolved the case, so
there is no strict winner. The baseline Pi oracle win remains the last resolved comparison. This
entry uses only per-turn `summary.json` and `files.json`; runner output, agent output, and session
traces were not read.

Retry 9 does not establish whether the prompt refinement helped because Rupi had no metered work or
tool activity. Check current usage, then choose the next matched attempt based on whether the
provider is available; do not infer a prompt regression from these zero-work timeouts.

## Tenth retry plan

The usage check after retry 9 reported 18% in the five-hour window and 77% weekly, below the
stop thresholds. Retry 9 produced no Rupi usage records or tool activity, so keep its prompt
revision unchanged and repeat the same matched four-turn comparison to obtain usable evidence
before tuning further.

## Tenth matched retry status

Run: `bench-20261002-case07-atomic-test-write-retry10-matched4-600s`.

Rupi produced all four turn records. Each started and completed one model request but recorded zero
usage records, work tokens, or tool requests. Each turn summary reports `failed/timeout` and exit
code 1, with elapsed times of 594,185, 406,655, 596,112, and 597,872 ms. Tests, all three help
checks, and the oracle exited 1 on every turn. Each six-file snapshot contained only benchmark
configuration, `.gitignore`, and `SPEC.md`; no application files were created.

Pi produced only turn 1: it timed out after 600,234 ms with 7,482 work tokens and one `write` tool.
Its six-file snapshot contained no application files; tests, all help checks, and the oracle exited
1. After writing that turn record, the runner remained idle with no child process and did not start
Pi turns 2–4. The idle wrapper was stopped, and the per-turn artifacts were preserved.

This is an incomplete run, not a matched comparison; it provides no strict winner. The baseline Pi
oracle win remains the last resolved result. Evidence uses only per-turn `summary.json` and
`files.json`; runner output, agent output, session traces, and aggregate results were not read.

Retry 9 and retry 10 produced no metered Rupi work, so neither evaluates the current prompt. The
post-run usage check reports 3% in the five-hour window and 77% weekly. Retry 11 should repeat the
current prompt with the same matched settings after a fresh usage check to determine whether the
zero-work pattern persists before any further prompt change.

## Eleventh matched retry result

Run: `bench-20261002-case07-atomic-test-write-retry11-matched4-600s`.

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Rupi | 1 | 0 | 0 | 594,150 ms; timeout status | 1 | 1/1/1 | 1 |
| Rupi | 2 | 7,877 | 1 | 600,188 ms timeout | 1 | 1/1/1 | 1 |
| Rupi | 3 | 11,535 | 6 | 600,251 ms timeout | 0 | 0/0/0 | 1 |
| Rupi | 4 | 991 | 1 | 600,355 ms timeout | 0 | 0/0/0 | 1 |
| Pi | 1 | 0 | 0 | 600,265 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 2 | 13,776 | 14 | 600,224 ms timeout | 1 | 0/0/0 | 1 |
| Pi | 3 | 10,235 | 6 | 378,633 ms | 0 | 0/0/0 | 1 |
| Pi | 4 | 0 | 0 | 600,284 ms timeout | 0 | 0/0/0 | 1 |

Rupi started 12 and completed 11 model requests, with eight usage records. It used 20,403 work
tokens and eight tools over 2,394,944 ms. The entry point first appeared in turn 2; both test
files first appeared in turn 3. Tests and all help checks passed on turns 3–4, but the oracle
failed on every turn. Turn 4 made one `grep` call and did not change the snapshot; no separate
storage, server, or worker files appeared.

Pi started and completed 15 requests and used 24,011 work tokens and 20 tools over 2,179,406 ms.
Tests and help passed on turns 3–4; the oracle failed on all four turns. The final snapshot
contains the package, entry point, and tests, but no separate server or worker modules.

Neither agent resolved the case, so there is no strict winner. The baseline Pi oracle win remains
the last resolved comparison. This entry uses only per-turn `summary.json` and `files.json`; raw
runner output, agent output, session traces, and aggregate results were not read.

## Twelfth workflow prompt revision

Retry 11 passed tests and all help checks by turn 3, but Rupi made only one `grep` call in turn 4
and added no workflow source. The workflow-phase recovery now tells the agent to use prior-turn
context and make a source write before any further inspection. It prioritizes the integrated signed
submission, durable ordered jobs, `worker --once`, and result retrieval; each new module must be
wired to `__main__.py` in the same recovery turn. Dependency ordering, selected-field fan-in, lease
reclaim, and blocked dependents remain in scope.

The all-case `bench/compare-pi-rupi.ps1 -DryRun` passed after this prompt change.
`git diff --check`, 100-column, and CRLF checks passed. The post-run usage check reported 12%
five-hour and 79% weekly use. Keep the prompt revision unchanged for retry 12; begin another
matched four-turn comparison only after a fresh usage check.

## Twelfth matched retry result

- Run: `bench-20261002-case07-workflow-write-retry12-matched4-600s`.
- Settings matched: pinned Pi 0.86.1, Case 07, four turns, 600-second turn
  limit, 6-second provider grace, eight requests per turn, thinking off.

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Rupi | 1 | 19,737 | 7 | 600,333 ms timeout | 0 | 0/0/0 | 1 |
| Rupi | 2 | 0 | 0 | 595,800 ms timeout status | 0 | 0/0/0 | 1 |
| Rupi | 3 | 0 | 0 | 596,901 ms timeout status | 0 | 0/0/0 | 1 |
| Rupi | 4 | 6,774 | 1 | 600,211 ms timeout | 0 | 0/0/0 | 1 |
| Pi | 1 | 18,227 | 3 | 600,169 ms timeout | 1 | 0/0/0 | 1 |
| Pi | 2 | 0 | 0 | 600,205 ms timeout | 1 | 0/0/0 | 1 |
| Pi | 3 | 12,584 | 1 | 600,167 ms timeout | 1 | 0/0/0 | 1 |
| Pi | 4 | 9,364 | 1 | 600,258 ms timeout | 1 | 0/0/0 | 1 |

Rupi started 11 requests and completed 10, recording seven usage records. It used 26,511
work tokens and eight tools over 2,393,245 ms. Tests and all help checks passed every turn,
but the oracle failed every turn. The first snapshot contained `__main__.py` and both test files.
Turn 4 added `__init__.py`. No storage, server, or worker source appeared.

Pi started and completed five requests, with five usage records. It used 40,175 work tokens
and five tools over 2,400,799 ms. Help passed every turn; project tests and oracle failed
every turn. Pi created the entry point and tests on turn 1; later snapshots were unchanged.

Neither agent resolved the case, so there was no strict winner. The baseline Pi oracle win
remains the last resolved comparison. This entry uses per-turn `summary.json` and `files.json`
only; raw runner output, agent output, session traces, and aggregate `results.json` were not read.

The post-run usage check reported 9% five-hour and 1% weekly use. Before retry 13, sharpen
workflow recovery so its required next write updates the existing `__main__.py` with an
integrated workflow path. Keep Case 07 active; no strict Rupi oracle win has been verified.

## Thirteenth workflow prompt revision

- Retry 12 added only `__init__.py` in Rupi turn 4 after tests/help already passed.
- Workflow recovery now requires the next write to update existing `__main__.py` with raw-body
  HMAC admission, atomic SQLite state, worker `--once`, direct-argv sink execution, and retrieval.
- It keeps helpers deferred until that path exists, then prioritizes declared inputs, ordered
  selected-field fan-in, dependency blocking, and expired-lease reclaim.
- All-case `bench/compare-pi-rupi.ps1 -DryRun` exited 0. `git diff --check`, the changed-line
  100-column limit, and CRLF checks passed.
- Run retry 13 with the matched settings after a fresh usage check; keep Case 07 active.

## Thirteenth retry status (interrupted, incomplete)

- Run: `bench-20261002-case07-integrated-workflow-write-retry13-matched4-600s`.
- Rupi turn 1 reached 600,255 ms with 16,965 work tokens and three `write` calls.
  Tests exited 1, all help checks exited 0, and the oracle exited 1.
- Turn 1 had the entry point and both test files, but no separate storage, server, or
  worker source.
- Rupi turn 2 was interrupted during wrap-up. A per-turn `files.json` exists with nine
  files and no additional application modules; there is no turn 2 `summary.json`.
- The runner tree was stopped and verified gone. Pi did not run, so retry 13 is not a
  matched comparison and has no winner.
- Evidence is limited to per-turn `summary.json` and `files.json`; raw output, logs,
  traces, and aggregate `results.json` were not read.
- Usage after stopping was 14% five-hour and 2% weekly. Resume with a fresh usage check
  and a new matched run; do not combine retry 13's partial Rupi turns with later Pi turns.

## Fourteenth matched retry plan

- Resume from the Case 07 handoff at `04b229c`; retain the current prompt revision.
- Restored `fix/case07-lease-cascade` in the clean benchmark worktree. The root checkout
  remains at the same commit with its unrelated usage-policy edit preserved.
- Fresh Codex usage: 19% five-hour and 3% weekly, below the current stop thresholds.
- Run: `bench-20261002-case07-integrated-workflow-write-retry14-matched4-600s`.
- Settings: pinned Pi 0.86.1, four turns, 600-second turn limit, 6-second provider grace,
  eight requests per turn, thinking off, and the existing Rupi binary.
- Retry 13 remains incomplete; none of its partial turns will be combined with retry 14.
- Inspect only per-turn `summary.json` and `files.json`, plus generated help output.
  Keep Case 07 active and merge only after a verified strict Rupi oracle win.

## Fourteenth retry progress: Rupi turn 1

- Turn 1 timed out after 600,744 ms: 9,155 work tokens and two completed `write` calls.
- Tests exited 5; all three help checks and the oracle exited 1.
- The eight-file snapshot has a 3,887-byte `leasecascade/__main__.py` and a 37-byte
  `tests/__init__.py`, without the test module or any workflow source module.
- Generated help stderr reports that the entry point imports the missing `server` module.
  This is a concrete runnable-entry-point failure; no application source was inspected.
- Turn 2 started. The comparison is still active and has no outcome yet.
- Evidence: per-turn `summary.json`, `files.json`, and generated help output only.

Prompt review during retry 14 found two actionable issues for the next revision, if needed:
the foundation phase requires help repair but restricts all writes to tests, preventing repair
of the entry point. It also requires two files in one workspace `write`, whereas the actual
tool schema in `crates/rupi-tools/src/write.rs` accepts one path and contents per call.
Use a self-contained entry point, permit its repair when help fails, and request consecutive
single-file writes with the real test module before the initializer. Retry 14 stays unchanged.

## Fourteenth retry progress: Rupi complete, Pi running

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Rupi | 1 | 9,155 | 2 | 600,744 ms timeout | 5 | 1/1/1 | 1 |
| Rupi | 2 | 2,350 | 1 | 597,458 ms; timeout status | 5 | 1/1/1 | 1 |
| Rupi | 3 | 11,915 | 2 | 600,278 ms timeout | 5 | 1/1/1 | 1 |
| Rupi | 4 | 25,764 | 7 | 600,392 ms timeout | 0 | 0/0/0 | 1 |

Rupi used 49,184 work tokens and 12 tools over 2,398,872 ms. Tests and help passed only
on turn 4; the oracle failed every turn. Turn 2 added only the package initializer. Turn 3
changed the two initializers, leaving the entry point unchanged and the test module absent.
Turn 4 added `tests/test_leasecascade.py` and changed the entry point by nine bytes. No
separate storage, server, or worker source appeared in the final ten-file snapshot.

Turn 4 metrics include an `exec` request despite the prompt prohibiting commands. Its output
was not read; do not infer what it ran. The other turn 4 tools were two writes, three edits,
and one read. Generated help passed all three commands. Pi turn 1 has started; the matched
comparison has no outcome yet. Evidence remains per-turn summaries, snapshots, and help only.

## Fourteenth matched retry result

Run: `bench-20261002-case07-integrated-workflow-write-retry14-matched4-600s`.

The matched run completed with runner exit 0. It retained the current prompt, pinned Pi
0.86.1, four turns, 600-second limits, 6-second provider grace, eight requests per turn,
thinking off, and the existing Rupi binary.

Rupi's four-turn table appears immediately above. Pi's completed results:

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Pi | 1 | 0 | 0 | 600,212 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 2 | 7,140 | 7 | 600,302 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 3 | 10,639 | 2 | 600,352 ms timeout | 1 | 0/0/0 | 1 |
| Pi | 4 | 8,539 | 3 | 264,214 ms | 0 | 0/0/0 | 1 |

Pi used 26,318 work tokens and 12 tools over 2,065,080 ms. Turn 1 had no application files.
Turn 2 added a 585-byte entry point; generated help showed an import of the missing `cli`
module. Turn 3 expanded the entry point to 13,834 bytes and added the package initializer.
Turn 4 added both test files, leaving the entry point unchanged. Its final ten-file snapshot
has no separate workflow modules. Turn 2 metrics include one `bash` request despite the
prompt prohibition; its output was not inspected.

Both agents passed tests and help by turn 4, but failed the oracle on every turn. There is
no strict winner. Pi used 22,866 fewer work tokens and finished 333,792 ms faster than Rupi;
these differences do not satisfy the oracle gate. The baseline Pi win remains the last
resolved comparison. Case 07 remains active.

Evidence uses per-turn `summary.json`, `files.json`, and generated help only. Acceptance
source, runner/agent output, session traces, and aggregate results were not inspected.
Post-run Codex usage: 12% five-hour and 7% weekly.

## Fifteenth foundation prompt revision

The actual write tool accepts one file per call. Initial guidance now writes the real test
module second and its initializer third, then updates the entry point with the workflow.
The first entry point must use standard-library imports and a main guard without importing
absent local modules. Foundation recovery now explicitly permits repairing `__main__.py`
when help fails, followed by separate test-file writes. Helpers remain deferred until tests
and help pass. This resolves contradictory and impossible instructions identified in retry 14;
its effect on the oracle remains unverified until another matched comparison completes.

Validation: all-case `bench/compare-pi-rupi.ps1 -DryRun`, `git diff --check`, changed-line
100-column checks, and CRLF checks pass. No Rust source changed and no standalone tests
were run. Start retry 15 with the standard matched settings after a fresh usage check.

## Fifteenth matched retry started

- Run: `bench-20261002-case07-foundation-repair-retry15-matched4-600s`.
- Prompt revision: `26dcff1`; fresh usage was 14% five-hour and 7% weekly.
- Pinned Pi 0.86.1, four turns, 600 seconds per turn, 6-second provider grace,
  eight requests per turn, thinking off, and the existing binary.
- Rupi turn 1 is active. Inspect only per-turn summaries, file snapshots, and help output.
  Record the completed matched result before deciding on another revision or merge.

## Fifteenth retry progress: Rupi turns 1-2

| Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| ---: | ---: | ---: | --- | ---: | --- | ---: |
| 1 | 0 | 0 | 519,493 ms; timeout status | 1 | 1/1/1 | 1 |
| 2 | 2,403 | 1 | 600,329 ms timeout | 1 | 0/0/0 | 1 |

Turn 1 recorded one started/completed request but no metered work or tools, and no application
files. It does not establish a prompt effect. Turn 2 made one completed `write` and created a
2,511-byte entry point, with no test files or other application modules. All help checks passed;
tests and oracle failed. Turn 3 is running. The matched comparison has no outcome yet.
Evidence uses only per-turn `summary.json` and `files.json`.

## Fifteenth retry progress: Rupi complete, Pi running

Rupi turn 3 timed out after 600,246 ms with 7,860 work tokens and three completed writes.
It added both test files and the package initializer; the 2,511-byte entry point remained
unchanged. Project tests and all help checks passed, but the oracle failed.

Turn 4 ended after 598,010 ms with timeout status, no usage
records, no work tokens, and no tools. The final snapshot is unchanged from turn 3. Tests
and help stayed passing; the oracle failed. Workflow recovery was not exercised by a source
write in this turn, so do not infer its effectiveness from that zero-work timeout.

Rupi totals: 10,263 work tokens, four writes, and 2,318,078 ms across four turns. Turns 1
and 4 recorded no metered work. Help passed from turn 2; tests passed from turn 3; the
oracle failed on every turn. Pi turn 1 is running, so the matched run has no outcome yet.
Evidence remains per-turn `summary.json` and `files.json` only.

## Fifteenth matched retry result

Run: `bench-20261002-case07-foundation-repair-retry15-matched4-600s`.

Runner exit 0. Settings remained pinned Pi 0.86.1, four turns, 600-second limits,
6-second provider grace, eight requests per turn, thinking off, and the existing Rupi binary.

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Rupi | 1 | 0 | 0 | 519,493 ms; timeout status | 1 | 1/1/1 | 1 |
| Rupi | 2 | 2,403 | 1 | 600,329 ms timeout | 1 | 0/0/0 | 1 |
| Rupi | 3 | 7,860 | 3 | 600,246 ms timeout | 0 | 0/0/0 | 1 |
| Rupi | 4 | 0 | 0 | 598,010 ms; timeout status | 0 | 0/0/0 | 1 |
| Pi | 1 | 0 | 0 | 600,219 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 2 | 17,402 | 9 | 600,245 ms timeout | 1 | 0/0/0 | 1 |
| Pi | 3 | 8,660 | 5 | 382,381 ms | 0 | 0/0/0 | 1 |
| Pi | 4 | 0 | 0 | 600,234 ms timeout | 0 | 0/0/0 | 1 |

Rupi used 10,263 work tokens and four writes over 2,318,078 ms. Pi used 26,062 work
tokens and 14 tools over 2,183,079 ms. Both passed help from turn 2 and tests from turn 3.
Both final snapshots have the entry point, package initializer, and both tests, with no
separate workflow modules. Pi's entry point expanded to 7,715 bytes on turn 3. Turn 4
recorded zero work and tools and left both snapshots unchanged. Pi turn 2 included one
`bash` request despite the prompt prohibition; its output was not inspected.

The oracle failed every turn for both agents. There is no strict winner. Rupi used 15,799
fewer work tokens but took 134,999 ms longer. The baseline Pi oracle win remains the last
resolved comparison. Case 07 remains active.

Both agents passed the foundation gates, but neither made a workflow recovery write in
turn 4. Repeat the current revision in retry 16 before drawing a conclusion about that
workflow directive. Post-run Codex usage: 50% five-hour and 13% weekly, below the current
stop thresholds. Check usage again before launching the fresh matched comparison.

Evidence is limited to per-turn summaries and file snapshots. Acceptance source, runner
or agent output, session traces, and aggregate results remain unread. The parent did not
run standalone tests.

## Sixteenth matched retry started

- Run: `bench-20261003-case07-foundation-repair-retry16-matched4-600s`.
- Prompt unchanged at `26dcff1`; fresh usage: 51% five-hour and 13% weekly.
- Pinned Pi 0.86.1, four turns, 600 seconds per turn, 6-second provider grace,
  eight requests per turn, thinking off, and the existing Rupi binary.
- Rupi turn 1 is active. Retry 15 ended with zero work and tools in both final turns,
  so repeat before tuning the unexercised workflow write directive.
- Keep evidence restricted to per-turn summaries, snapshots, and generated help.

## Sixteenth retry progress and next tool-policy slice

- Rupi turns 1-2 ended with timeout status at 358,940 and 594,222 ms. Both recorded
  zero work and tools, no application files, and failing tests/help/oracle.
- Turn 3 timed out after 600,277 ms: 1,246 work tokens and one completed `exec` request.
  Its snapshot still has only the six configuration/specification files. Generated help
  reports `No module named leasecascade`. No application source was inspected.
- Turn 4 is running. The matched comparison has no outcome yet.

The lone `exec` violated the prompt's existing no-command instruction. Both runtimes can
enforce the intended boundary without Rust changes: Rupi's `ToolPolicy.allow` filters both
offered definitions and calls (`crates/rupi-core/src/config.rs`,
`crates/rupi-tools/src/registry.rs`); installed pinned Pi accepts an explicit `--tools`
allowlist (`dist/cli/args.js`). The Case 07 base config already has a tools policy.

After retry 16 finishes, restrict Case 07 to equivalent workspace file tools for both
agents: Rupi `read,write,edit,glob,grep`; Pi `read,write,edit,grep,find,ls`. Keep other cases
and the standard matched time/turn/request/thinking settings unchanged. Record the configured
allowlists in permitted per-turn summaries. This changes tool availability relative to earlier
runs, so evaluate it as a new matched pair and do not mix prior turns into its result.

## Sixteenth retry progress: Rupi complete, Pi running

Rupi turn 4 timed out after 600,188 ms with 12,239 work tokens and one completed `write`.
It created a 5,013-byte `leasecascade/__main__.py` but no package initializer or test files.
All help checks failed: generated help stderr reports an import of the missing `__version__`
symbol from `leasecascade`. Project tests and oracle also failed.

Rupi totals: 13,485 work tokens, two tools (one `exec`, one `write`), and 2,153,627 ms.
Tests, help, and oracle failed every turn. Pi turn 1 is running; no matched outcome exists.
Evidence is per-turn `summary.json`, `files.json`, and generated help only.

Source review found that entrypoint recovery uses generic fallback guidance, without the
initial phase's explicit ban on absent local imports. In the next tool-policy slice, give
entrypoint recovery the same compact, self-contained CLI/health instructions and local
constants, then consecutive test writes. Preserve the full specification and oracle gate.

## Sixteenth retry progress: Pi turn 2 complete

Pi turns 1-2 timed out at 600,242 and 600,234 ms; all checks failed in both turns.
Turn 1 recorded zero work/tools. Turn 2 used 3,622 work tokens and seven completed
inspection calls (`ls`, `find`, five `read`), with no writes. Both snapshots contain only
the six configuration/specification files. Generated help reports no `leasecascade` module.
Pi turn 3 is running. Latest parent usage: 79% five-hour and 18% weekly.

## Sixteenth matched retry result

Runner exit 0; the runner process tree is gone. Prompt revision was `26dcff1` with
the standard matched settings and existing Rupi binary. No oracle pass or strict winner.

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Rupi | 1 | 0 | 0 | 358,940 ms; timeout status | 1 | 1/1/1 | 1 |
| Rupi | 2 | 0 | 0 | 594,222 ms; timeout status | 1 | 1/1/1 | 1 |
| Rupi | 3 | 1,246 | 1 | 600,277 ms timeout | 1 | 1/1/1 | 1 |
| Rupi | 4 | 12,239 | 1 | 600,188 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 1 | 0 | 0 | 600,242 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 2 | 3,622 | 7 | 600,234 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 3 | 0 | 0 | 600,175 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 4 | 12,902 | 6 | 600,214 ms timeout | 1 | 1/1/1 | 1 |

Rupi totals: 13,485 work tokens, two tools, 2,153,627 ms. Pi totals: 16,524 work tokens,
13 tools, 2,400,865 ms. All checks failed every turn. Rupi used 3,039 fewer work tokens
and took 247,238 ms less; this does not establish an oracle win.

Pi turn 3 recorded no work/tools and retained the six-file snapshot. Turn 4 completed four
writes and two edits, producing a 5,093-byte entry point, initializer, storage, and validation.
No test files exist. Generated help reports an import of missing `leasecascade.worker`.
Evidence remains per-turn summaries, snapshots, and generated help. Other outputs stay unread.
Post-run usage: 84% five-hour and 18% weekly. Baseline Pi remains the last resolved winner.

## Next revision: native file tools and entrypoint recovery

Case 07 uses Rupi `read,write,edit,grep` and Pi `read,write,edit,grep,find,ls` through
existing native configuration. Review corrected the earlier proposed `glob` name: Rupi
has filename search via `grep` with `glob=true`, without a separate registered `glob` tool.
Configured allowlists are recorded in each turn's `summary.json`; offered-tool observation
is not claimed. Other cases keep their source Rupi policy and existing Pi tools.

Entrypoint recovery now explicitly requests a compact self-contained CLI/health entry point,
standard-library imports, a main guard, local constants, and separate test writes. This fixes
the generic fallback seen in retry 16. The change needs a fresh matched comparison.

Parent invariant-review verdict: pass after correcting the unregistered tool name. Checked
native allowlist filtering of offered definitions and calls, Pi's pinned `--tools` boundary,
Case 07 isolation, unchanged budgets, and honest configured-versus-observed provenance.
No runtime, replay, failover, startup, or roadmap contract changes. All-case `-DryRun`,
`git diff --check`, CRLF, and changed-line 100-column checks pass. No standalone tests or
Rust checks were run; matched performance and oracle evidence are pending.

## Seventeenth matched retry started

Run: `bench-20261003-case07-file-tools-retry17-matched4-600s`, revision `e3fdefa`.
Pre-run usage: 86% five-hour and 19% weekly. New native file-only tool configuration,
standard matched budgets unchanged, pinned Pi 0.86.1, and existing Rupi binary.
Rupi turn 1 is running. The run needs its own complete matched outcome.

## Seventeenth retry progress: Rupi turn 1

Turn 1 timed out after 600,296 ms: 16,286 work tokens, three tools, project tests exit 0,
all three help checks exit 0, and oracle exit 1. Its summary records the configured native
allowlist `read,write,edit,grep`. Rupi turn 2 is running; the matched comparison is incomplete.

## Seventeenth retry progress: Rupi complete, subscription wait

| Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| ---: | ---: | ---: | --- | ---: | --- | ---: |
| 1 | 16,286 | 3 | 600,296 ms timeout | 0 | 0/0/0 | 1 |
| 2 | 0 | 0 | 595,603 ms; timeout status | 0 | 0/0/0 | 1 |
| 3 | 0 | 0 | 463,520 ms; timeout status | 0 | 0/0/0 | 1 |
| 4 | 0 | 0 | 596,972 ms; timeout status | 0 | 0/0/0 | 1 |

Rupi totals: 16,286 work tokens, three completed writes, 2,256,391 ms. The first snapshot
has a 3,913-byte entry point and both test files; turns 2-4 retain it without new source.
Tests and help pass every turn; oracle fails every turn. Every summary records the native
configured allowlist `read,write,edit,grep`. No workflow recovery write was completed.
Pi turn 1 is running; no matched outcome yet.

Parent usage is 96% five-hour and 20% weekly. The user-edited root usage policy requires
waiting until the 2026-10-03 03:12 AM ET reset plus two minutes. Agent work resumes at
03:14 AM ET without checking usage during the wait. The bounded benchmark runner continues.

## Seventeenth matched retry result

Runner exit 0; its process tree is gone. Pi completed independently during the subscription
wait. Resumed at 03:14 AM ET with 0% five-hour and 20% weekly usage.

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Pi | 1 | 17,184 | 5 | 600,250 ms timeout | 1 | 1/0/0 | 1 |
| Pi | 2 | 11,785 | 6 | 374,843 ms | 0 | 0/0/0 | 1 |
| Pi | 3 | 0 | 0 | 600,228 ms timeout | 0 | 0/0/0 | 1 |
| Pi | 4 | 0 | 0 | 600,228 ms timeout | 0 | 0/0/0 | 1 |

Pi totals: 28,969 work tokens, 11 tools, 2,175,549 ms. Rupi totals: 16,286 work tokens,
three writes, 2,256,391 ms. Rupi passed tests/help every turn; Pi passed both from turn 2.
Every oracle check failed, so no strict winner. Rupi used 12,683 fewer work tokens and
took 80,842 ms longer. The baseline Pi oracle win remains the last resolved result.

Pi turn 1 used five writes; its snapshot has the entry point, initializer, validation, and
both tests. Top-level help failed with an argparse metavar formatting error. Turn 2 used
four reads, one edit, and one write; entry point and tests grew, and all foundation checks
passed. Turns 3-4 recorded no work/tools and retained that snapshot without workflow writes.
Configured native file-tool allowlists are recorded in every turn summary. Evidence stays
restricted to per-turn summaries, file snapshots, and generated help.

## Next revision: bounded workflow edits

The first attempt now ends after three foundation writes and waits for harness verification.
Workflow recovery asks for the earliest missing behavior in small edits adding at most 80
lines: admission, retrieval, worker, then declared inputs and barriers. It permits a single
entrypoint read when an exact edit anchor is unknown, followed immediately by a source edit.
Native file tools, full specification, and standard matched budgets remain unchanged.

Both agents recorded zero workflow work in their final turns; permitted evidence does not
establish the timeout cause. Smaller edits are a prompt hypothesis, requiring a fresh pair.
Parent review confirms the harness feedback boundary and unchanged runtime invariants.

## Eighteenth matched retry started

Run: `bench-20261003-case07-bounded-edits-retry18-matched4-600s`, revision `8cb9a78`.
Pre-run usage: 3% five-hour and 21% weekly. Standard matched budgets, native file tools,
and existing Rupi binary unchanged. Rupi turn 1 is running; no matched outcome yet.

## Eighteenth retry progress: Rupi turn 1

Rupi turn 1 finished without outer timeout in 208,058 ms: 13,740 work tokens, four tools,
project tests exit 0, all help checks exit 0, and oracle exit 1. Its summary records the
native file-tool allowlist. Turn 2 is running; no matched outcome yet.

## Eighteenth retry progress: Rupi turn 2

Turn 2 ended after 538,470 ms without outer timeout: 31,527 work tokens, seven tools,
tests exit 0, all help checks exit 0, and oracle exit 1. Turn 3 is running. This turn has
recorded work, unlike the zero-work workflow timeouts in retry 17; a strict win is still absent.

## Eighteenth retry progress: Rupi complete, Pi running

Turn 2 completed seven successful edits and exhausted the eight-request budget, growing the
entry point from 4,707 to 16,971 bytes. Turn 3 ended after 493,556 ms with 39,667 work
tokens and seven successful tools (one read, one grep, five edits), again exhausting the
request budget. Its entry point grew to 22,414 bytes. Tests/help passed; oracle failed.

Turn 4 reported runtime timeout after 549,232 ms with zero work/tools and unchanged files.
Rupi totals: 84,934 work tokens, 18 tools, 1,789,316 ms. Tests/help passed every turn;
oracle failed every turn. Test files stayed unchanged after turn 1. No timeout cause or
workflow correctness is inferred from source size. Pi turn 1 is running; no matched outcome.
Post-Rupi parent usage: 14% five-hour and 23% weekly.

## Eighteenth retry progress: Pi turn 3 complete

| Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| ---: | ---: | ---: | --- | ---: | --- | ---: |
| 1 | 9,387 | 5 | 170,035 ms | 0 | 0/0/0 | 1 |
| 2 | 12,384 | 1 | 600,224 ms timeout | 0 | 0/0/0 | 1 |
| 3 | 13,109 | 9 | 600,363 ms timeout | 0 | 0/0/0 | 1 |

Pi turn 1 has the entry point and both tests. Turn 2 completed one edit and grew the
entry point from 4,398 to 8,179 bytes. Turn 3 completed seven edits and two reads,
growing it to 29,469 bytes. Both test files remain unchanged. Turn 4 is running.
Its turn 3 summary records nine completed model requests. Source review confirms that
the harness's eight-request setting applies to Rupi only; the clarification above makes
the comparison boundary explicit without changing historical results or active settings.

## Eighteenth matched retry result

Runner exit 0; process tree gone. Revision `8cb9a78`, existing binary, native file tools,
and standard shared turn/time/model/thinking settings. Rupi's request cap remained eight.

Pi turn 4 timed out after 600,266 ms: 10,763 work tokens, five tools (four edits, one read),
tests/help exit 0, oracle exit 1. The entry point grew to 30,819 bytes and tests to 11,695
bytes. Both agents passed tests and all three help commands every turn; oracle failed every turn.

| Agent | Work tokens | Tools | Elapsed | Oracle |
| --- | ---: | ---: | ---: | --- |
| Rupi | 84,934 | 18 | 1,789,316 ms | Failed all turns |
| Pi | 45,643 | 20 | 1,970,888 ms | Failed all turns |

No strict winner. Rupi used 39,291 more work tokens and took 181,572 ms less. The baseline
Pi win remains the last resolved comparison. Post-run usage: 27% five-hour and 24% weekly.
Evidence remains per-turn summaries, snapshots, and generated help; other artifacts stay unread.

## Next revision: earlier workflow feedback

Rupi's tests stayed unchanged after turn 1. Pi expanded its tests only in the final turn.
The next prompt requests small workflow tests immediately after worker code exists, then
yields for harness feedback. Tests cover the public signed-admission/retrieval and declared
input contracts, reversed barrier dependency order, selected fields with private extras,
and missing-field failure/blocking without a barrier sink call. These are public-specification
fixtures; coverage of the generated tests is unknown from snapshots and is not inferred.

New summaries record `harness_model_request_cap`: eight for Rupi, null for Pi (the harness
sets no Pi request cap). Native runtime policies and other cases retain their current settings.

Parent invariant-review verdict: pass. Fixtures derive from the public Case 07 specification;
local recovery preserves those assertions and repairs implementation through bounded edits.
The metadata exposes the existing request-budget difference. No runtime, provenance, replay,
failover, startup, or roadmap boundary changes. Fresh matched oracle evidence is pending.

## Nineteenth matched retry started

Run: `bench-20261003-case07-workflow-fixtures-retry19-matched4-600s`, revision `34ff2cf`.
Pre-run usage: 29% five-hour and 25% weekly. Existing binary, native file tools and request
policies, standard shared turn/time/model/thinking settings. Rupi turn 1 is running.

## Nineteenth retry progress: Rupi turn 1

Turn 1 finished without outer timeout in 198,140 ms: 11,653 work tokens, three tools,
tests exit 0, all help checks exit 0, oracle exit 1. Its summary records the configured native
file tools and `harness_model_request_cap: 8`. Turn 2 is running; no matched outcome yet.

## Nineteenth retry progress: Rupi complete

| Turn | Work tokens | Tool requests | Time | Tests | Help | Oracle |
| ---: | ---: | ---: | --- | ---: | --- | ---: |
| 1 | 11,653 | 3 | 198,140 ms | 0 | 0/0/0 | 1 |
| 2 | 27,242 | 7 | 545,506 ms | 0 | 0/0/0 | 1 |
| 3 | 29,541 | 3 | 600,345 ms timeout | 0 | 0/0/0 | 1 |
| 4 | 12,734 | 6 | 600,232 ms timeout | 0 | 0/0/0 | 1 |

Rupi totals: 81,170 work tokens, 19 tool requests, 1,944,223 ms. Turn 2 exhausted the
request budget with six completed tools and one failed request. Its entry point grew to
12,592 bytes, while tests stayed unchanged. Turn 3 completed one read and two edits,
growing the entry point to 16,494 bytes; tests remained unchanged. Turn 4 completed five
edits and one read. Final entry point: 22,149 bytes; test module grew from 1,547 to 1,746
bytes. Coverage is unknown from snapshots. Every turn passed tests/help and failed oracle.
Pi turn 1 is running; no matched result. Parent usage: 44% five-hour and 27% weekly.

Source review found a directive conflict: workflow priority still unconditionally asks for
an application edit, while the new guidance asks for tests once worker delivery exists.
After this pair finishes, align priority/completion text and corresponding guards. Do not
infer that this caused the observed outcome or modify the active runner.

## Nineteenth matched retry result

Runner exit 0; process tree gone. Revision `34ff2cf`, existing binary, unchanged native
file tools/request policies and shared turn/time/model/thinking settings. Every summary
records request cap eight for Rupi and null for Pi, consistent with harness configuration.

| Agent | Turn | Work tokens | Tools | Time | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| Pi | 1 | 17,543 | 9 | 422,187 ms | 1 | 1/1/1 | 1 |
| Pi | 2 | 0 | 0 | 600,308 ms timeout | 1 | 1/1/1 | 1 |
| Pi | 3 | 9,167 | 11 | 365,069 ms | 0 | 0/0/0 | 1 |
| Pi | 4 | 10,386 | 2 | 600,233 ms timeout | 0 | 0/0/0 | 1 |

Pi totals: 37,096 work tokens, 22 tools, 1,987,797 ms. Rupi totals: 81,170 work tokens,
19 tool requests, 1,944,223 ms. Rupi passed tests/help every turn; Pi passed from turn 3.
Every oracle check failed. No strict winner. Rupi used 44,074 more work tokens and took
43,574 ms less. Baseline Pi remains the last resolved oracle winner; Case 07 stays active.

Pi's first snapshot put application/tests under an extra `project/` directory; generated
help reported no leasecascade module. Turn 2 recorded zero work/tools and the same snapshot.
Turn 3 used four writes, three directory listings, two reads, and two edits; correct root
files were created while nested copies remained. Turn 4 completed two edits and grew the
root entry point to 10,576 bytes. Its root test module stayed 4,024 bytes after turn 3.
Post-run usage: 58% five-hour and 29% weekly. Only permitted evidence was inspected.

## Next revision: coherent recovery and explicit relative paths

Workflow priority and completion now match the early-test rule once worker delivery is
implemented. The one-read allowance includes the source or test file selected for editing.
Initial and entrypoint prompts clarify that the current directory already contains SPEC.md;
leasecascade/ and tests/ belong directly beneath it. This addresses the observed nested path.

Existing DryRun now checks the assembled workflow prompt with temporary empty file markers,
then removes those markers and empty directories without recursive deletion. This exercises
the actual classifier and priority/completion composition without running project tests.
Parent invariant-review verdict: pass. Full oracle evidence remains pending for a fresh pair.

The final text makes the test branch conditional on missing workflow coverage. When those
tests already exist, continue remaining implementation edits; yield after adding missing
tests. Guidance, priority, completion, and the one-file read allowance agree on that choice.
All-case DryRun now exercises the assembled workflow prompt; diff, CRLF, and changed-line
100-column checks pass. No standalone project tests were run by the parent.

## Twentieth matched retry started

Run: `bench-20261003-case07-coherent-recovery-retry20-matched4-600s`, revision `46fa839`.
Pre-run usage: 63% five-hour and 30% weekly. Existing binary, native file tools/request
policies, and standard shared turn/time/model/thinking settings. Rupi turn 1 is running.
No oracle outcome yet; runner and agent output remain unread.

## Twentieth retry progress: Rupi turn 1

Turn 1 finished without outer timeout in 535,635 ms: 20,744 work tokens, four completed
writes, tests exit 0, all help exit 0, oracle exit 1. The entry point is 5,068 bytes;
test module 2,497 bytes and initializer 71 bytes, directly beneath the project root.
Turn 2 is running. No matched result yet; only permitted metadata was inspected.

## Twentieth retry progress: Rupi turn 2

Turn 2 hit the outer timeout at 600,204 ms: 13,998 work tokens and two completed edits.
Tests and all help passed; oracle failed. Entry point grew to 9,417 bytes; test-file sizes
are unchanged. Turn 3 is running. No timeout cause is inferred from these observations.

## Twentieth retry progress: Rupi turn 3

Turn 3 ended at the request budget after 426,767 ms: 32,156 work tokens, six completed
edits and one completed read. Tests and all help passed; oracle failed. Entry point is
25,257 bytes; test-file sizes remain unchanged. Turn 4 is running; coverage is unknown.

## Twentieth retry progress: Rupi complete

| Turn | Work tokens | Tool requests | Time | Tests | Help | Oracle |
| ---: | ---: | ---: | --- | ---: | --- | ---: |
| 1 | 20,744 | 4 | 535,635 ms | 0 | 0/0/0 | 1 |
| 2 | 13,998 | 2 | 600,204 ms timeout | 0 | 0/0/0 | 1 |
| 3 | 32,156 | 7 | 426,767 ms | 0 | 0/0/0 | 1 |
| 4 | 11,700 | 6 | 600,294 ms timeout | 0 | 0/0/0 | 1 |

Rupi totals: 78,598 work tokens, 19 completed tools, 2,162,900 ms. All tests/help passed;
every oracle check failed. Turn 4 completed six edits, growing the entry point to 29,723
bytes. Test module remains 2,497 bytes; coverage is unknown from permitted evidence.
Pi turn 1 is running. Parent usage: 71% five-hour and 31% weekly. No matched result yet.

## Twentieth retry progress: Pi turn 1

Pi turn 1 finished in 238,635 ms: 11,252 work tokens and six completed calls (four writes,
one edit, one read). Tests and all help passed; oracle failed. Application and test files
are beneath the actual project root. Entry point is 4,089 bytes; test module 4,321 bytes.
Pi turn 2 is running. Its summary records no harness request cap, as configured.
