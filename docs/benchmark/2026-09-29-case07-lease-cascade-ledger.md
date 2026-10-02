# Case 07 lease cascade comparison ledger

This ledger records the matched `07-lease-cascade` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

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
