# Case 04 webhook inbox comparison ledger

This ledger records the initial run with an unrecorded Pi version and the later Pi 0.86.1
rerun for `04-webhook-inbox` using local `qwen3.8-flash-next`.

## Scope and win criterion

Case 04 resolves only when the independent oracle exits zero. Rupi wins a matched comparison if
it resolves in fewer turns than Pi, or if both resolve in the same turn and Rupi uses fewer
inference-work tokens with no more agent wall time. Project-test and help results are recorded
separately from oracle resolution.

## First matched run (Pi version not recorded)

Run: `bench-20260929-case04-baseline-low-matched4-600s`.

This run used low reasoning, four turns, 600-second outer turn timeouts, the eight-request
setting, and project-test/help recovery feedback. The harness did not record Pi's version;
the current default on `PATH` reports 0.87.1. Treat this result as provisional for the 0.86.1
target. Requests below count model requests started; work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,232 ms | 13,366 / 10,874 | 24,240 | 6 | 5 | outer timeout |
| 2 | 506,210 ms | 1,032 / 45 | 1,077 | 2 | 1 | provider idle timeout |
| 3 | 600,296 ms | 7,907 / 10,057 | 17,964 | 4 | 3 | outer timeout |
| 4 | 445,908 ms | 30,088 / 6,045 | 36,133 | 8 | 7 | resolved |

Rupi resolved in turn 4, using 79,414 work tokens over 2,152,646 ms. The resolving turn passed
the acceptance oracle and all three help checks. Project test discovery exited 1 because the
generated project had no importable `tests/` directory.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,201 ms | 5,244 / 196 | 5,440 | 3 | 3 | outer timeout |
| 2 | 600,220 ms | 1,308 / 11,087 | 12,395 | 4 | 4 | outer timeout |
| 3 | 600,248 ms | 1,511 / 8,959 | 10,470 | 10 | 10 | resolved after timeout |

Pi resolved in turn 3, using 28,305 work tokens over 1,800,669 ms. It passed the acceptance
oracle and all three help checks. Project test discovery also exited 1 because the generated
project had no importable `tests/` directory. Since the Pi version was not recorded, this apparent
Pi win does not establish the target-version comparison.

## Pinned Pi 0.86.1 rerun

Run: `bench-20260929-case04-pi0861-low-matched4-600s`. The run summary recorded
`pi_version: 0.86.1`. It used the same low reasoning, four turns, eight-request setting,
600-second outer timeout, and project-test/help recovery feedback. Rupi's provider deadline was
570 seconds.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,257 ms | 13,108 / 10,386 | 23,494 | 4 | 5 | outer timeout |
| 2 | 600,231 ms | 1,443 / 10,216 | 11,659 | 2 | 1 | outer timeout |
| 3 | 600,260 ms | 2,161 / 9,486 | 11,647 | 3 | 2 | outer timeout |
| 4 | 600,420 ms | 5,586 / 9,905 | 15,491 | 8 | 7 | outer timeout |

Rupi did not resolve in four turns. It used 62,291 work tokens over 2,401,168 ms. The oracle
and project-test checks failed in every turn. All three help checks passed on turn 4.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,229 ms | 4,971 / 221 | 5,192 | 3 | 3 | outer timeout |
| 2 | 600,211 ms | 984 / 108 | 1,092 | 1 | 1 | outer timeout |
| 3 | 600,292 ms | 0 / 0 | 0 | 0 | 0 | outer timeout |
| 4 | 600,301 ms | 0 / 0 | 0 | 0 | 0 | outer timeout |

Pi did not resolve in four turns. It used 6,284 work tokens over 2,401,033 ms. Its oracle,
project-test, and help checks failed in every turn. Turns 3 and 4 made no model requests or tool
calls. Test discovery exited 1 in both projects because Python could not import the
`tests` start directory.

## Outcome of the initial pinned comparison

The pinned comparison is inconclusive: neither agent resolved the case. Rupi used 56,007 more
work tokens, while elapsed time was nearly even (Rupi took 135 ms longer). Rupi passed help only
on turn 4; Pi did not pass help. Case 04 remained open after this initial pinned run.

## Full-spec first-write prompt rerun

Run: `bench-20260930-case04-full-write-grace6-cap8-pi0861-low-matched4-600s`. This used
Pi 0.86.1, low reasoning, four turns, 600-second outer turn timeouts, eight model requests per
turn, and a 594-second Rupi provider timeout. The revised Case 04 guidance embedded the full
SPEC and asked for a complete `webhookinbox/__main__.py` write before inspecting the workspace.
Request columns show started / completed counts. Work tokens are inference input plus output; check columns show exit codes (0 means pass).

| Rupi turn | Elapsed | Input / output | Work tokens | Requests started / completed | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 594,454 ms | 0 / 0 | 0 | 1 / 1 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |
| 2 | 595,815 ms | 0 / 0 | 0 | 1 / 1 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |
| 3 | 597,536 ms | 0 / 0 | 0 | 1 / 1 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |
| 4 | 600,370 ms | 1,268 / 10,226 | 11,494 | 2 / 1 | 1 | 1 / 1 | 0 / 2 / 2 | outer timeout after one write |

Rupi did not resolve after four turns. It used 11,494 work tokens over 2,388,175 ms. The
acceptance oracle and project tests exited 1 on every turn. Top-level help passed only on turn 4;
`serve --help` and `worker --help` exited 2 then.

| Pi turn | Elapsed | Input / output | Work tokens | Requests started / completed | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,159 ms | 5,224 / 12,407 | 17,631 | 4 / 4 | 6 | 0 / 1 | 0 / 0 / 0 | outer timeout; oracle resolved |

Pi resolved in turn 1 and passed the acceptance oracle and all help checks. Its project tests
exited 1. It used 17,631 work tokens over 600,159 ms. The benchmark win criterion is oracle
resolution, so Pi won this comparison despite using 6,137 more work tokens. Rupi took
1,788,016 ms longer and did not resolve. Project-test status remains separate from the oracle
result for both agents.

## Incremental admission-first prompt rerun (R2)

Run: `bench-20261001-case04-incremental-admission-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight model requests
per turn, and a 594-second Rupi provider timeout. The prompt retained the complete SPEC and asked
for signed HTTP admission in the first entrypoint write, followed by worker, README, and tests.

| Agent | T | Elapsed ms | Work tokens | Req | Tools | Oracle/tests | Help T/S/W | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| Rupi | 1 | 600,746 | 19,548 | 3 | 4 | 1 / 1 | 0 / 0 / 2 | outer timeout |
| Rupi | 2 | 600,227 | 12,118 | 2 | 1 | 1 / 1 | 0 / 0 / 2 | outer timeout |
| Rupi | 3 | 596,816 | 0 | 2 | 0 | 1 / 1 | 0 / 0 / 2 | no inference/tools |
| Rupi | 4 | 598,556 | 0 | 1 | 0 | 1 / 1 | 0 / 0 / 2 | no inference/tools |
| Pi | 1 | 600,420 | 15,824 | 4 | 6 | 0 / 0 | 0 / 0 / 0 | outer timeout; resolved |

Rupi did not resolve after four turns. It used 31,666 work tokens over 2,396,345 ms; Pi resolved
the oracle in turn 1 with 15,824 work tokens over 600,420 ms. Pi passed project tests and all help
checks. Rupi's oracle and project tests failed in every turn; top-level and serve help passed, but
worker help failed. Rupi took 1,795,925 ms longer and used 15,842 more work tokens, so Pi won this
comparison by the oracle criterion.

The local checks showed test discovery failed because `tests` was not importable. Worker help
failed because the parser exposed only `serve`. The next prompt iteration will use those check
results to prioritize the complete CLI surface and an importable tests package before worker
implementation. The oracle remains hidden from recovery feedback.

## Recovery-gated prompt rerun (R3)

Run: `bench-20261001-case04-recovery-gated-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight model requests
per turn, and a 594-second Rupi provider timeout. Recovery selected an interface phase until
help and test discovery passed.

| Agent | T | Elapsed ms | Work tokens | Req | Tools | Oracle/tests | Help T/S/W | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| Rupi | 1 | 358,490 | 0 | 1 | 0 | 1 / 1 | 1 / 1 / 1 | no inference/tools |
| Rupi | 2 | 600,233 | 12,764 | 2 | 2 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| Rupi | 3 | 448,784 | 0 | 2 | 0 | 1 / 1 | 1 / 1 / 1 | no inference/tools |
| Rupi | 4 | 600,224 | 13,371 | 2 | 2 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| Pi | 1 | 600,493 | 19,771 | 7 | 7 | 0 / timed out | 0 / 0 / 0 | outer timeout; resolved |

Rupi did not resolve after four turns. It used 26,135 work tokens over 2,007,731 ms; Pi resolved
the oracle in turn 1 with 19,771 work tokens over 600,493 ms. Pi's project-test command timed
out, but the oracle and all help checks passed. Rupi's oracle and tests failed in every turn, as
did all three help commands. It took 1,407,238 ms longer and used 6,364 more work tokens, so Pi
won this comparison by the oracle criterion.

Rupi's final file snapshot contained `webhookinbox/__init__.py`, `db.py`, and `server.py`, but no
`__main__.py` or tests package. The next prompt iteration will select an entrypoint phase when
`__main__.py` is missing and direct the agent to create that single file before support modules.
The all-case dry run passed; oracle status remains hidden from recovery prompts.

## Entrypoint-first prompt rerun (R4)

Run: `bench-20261001-case04-entrypoint-first-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight model requests
per turn, and a 594-second Rupi provider timeout. Recovery required `__main__.py` before support
modules.

| Agent | T | Elapsed ms | Work | Req | Tools | Oracle/tests | Help T/S/W | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| Rupi | 1 | 422,599 | 0 | 1 | 0 | 1 / 1 | 1 / 1 / 1 | no inference/tools |
| Rupi | 2 | 600,244 | 17,547 | 6 | 6 | 0 / 5 | 0 / 0 / 0 | outer timeout; resolved |
| Pi | 1 | 600,430 | 16,035 | 5 | 9 | 0 / 0 | 0 / 0 / 0 | outer timeout; resolved |

Rupi resolved the oracle in turn 2 and passed every help command. Its project-test command exited
5 because no tests were discovered; its snapshot contained only `tests/__init__.py` and a sink
helper, not a `test_*.py` module. Pi resolved in turn 1 and passed project tests and all help
checks. Rupi used 1,512 more work tokens and took 422,413 ms longer, so Pi won under the criterion
above.

## Status after R4

After R4, Case 04 remained open: Rupi resolved in turn 2 but used more work tokens and wall
time than Pi's turn 1 resolution. R5 through R7 are recorded below.

## One-turn completion prompt rerun (R5)

Run: `bench-20261001-case04-one-turn-completion-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight requests per
turn, and a 594-second Rupi provider timeout. R5 asked for a complete one-file service and worker,
plus a discovered unittest and README.

| Agent | T | Elapsed ms | Work | Req | Tools | Oracle/tests | Help T/S/W | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| Rupi | 1 | 594,501 | 0 | 1 / 1 | 0 | 1 / 1 | 1 / 1 / 1 | provider timeout |
| Rupi | 2 | 595,825 | 0 | 1 / 1 | 0 | 1 / 1 | 1 / 1 / 1 | provider timeout |
| Rupi | 3 | 600,367 | 25,525 | 6 / 5 | 5 | 0 / 1 | 0 / 0 / 0 | timeout; resolved |
| Pi | 1 | 600,213 | 15,513 | 1 / 1 | 1 | 0 / 1 | 0 / 0 / 0 | timeout; resolved |

Rupi's first two turns had no work tokens, tools, or implementation files. It resolved the oracle
in turn 3; help passed, but project tests exited 1. Its final snapshot contained only
`webhookinbox/__init__.py` and `webhookinbox/__main__.py`, with no tests or README. Pi resolved in
turn 1, passed every help command, and also had project tests exit 1. Rupi used 25,525 work tokens
over 1,790,693 ms; Pi used 15,513 over 600,213 ms. Pi resolved two turns earlier and used 10,012
fewer work tokens over 1,190,480 fewer milliseconds, so Pi won.

## One-write prompt rerun (R6)

Run: `bench-20261001-case04-one-write-first-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight requests per
turn, and a 594-second Rupi provider timeout. R6 required one workspace write containing the
complete application in `webhookinbox/__main__.py`.

| Agent | T | Elapsed ms | Work | Req | Tools | Oracle/tests | Help T/S/W | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| Rupi | 1 | 396,082 | 0 | 1 / 1 | 0 | 1 / 1 | 1 / 1 / 1 | provider timeout |
| Rupi | 2 | 600,250 | 7,068 | 2 / 1 | 1 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| Rupi | 3 | 548,974 | 0 | 1 / 2 | 0 | 1 / 1 | 1 / 1 / 1 | provider timeout |
| Rupi | 4 | 545,663 | 0 | 1 / 1 | 0 | 1 / 1 | 1 / 1 / 1 | provider timeout |
| Pi | 1 | 600,501 | 16,081 | 5 / 5 | 5 | 0 / 1 | 0 / 0 / 0 | timeout; resolved |

Rupi produced no project files and did not resolve after four turns. Turn 2 made one `exec` call;
the other turns had no tool calls or work tokens. Pi resolved the oracle in turn 1 and passed all
help commands; its project tests exited 1. Rupi used 7,068 work tokens over 2,090,969 ms, while
Pi used 16,081 over 600,501 ms. Pi won because Rupi did not resolve.

## Matched reasoning-off prompt rerun (R7)

Run: bench-20261001-case04-one-write-off-grace6-cap8-pi0861-matched4-600s.

This used Pi 0.86.1, thinking off for both agents, a four-turn maximum, eight model requests per
turn, a 600-second turn timeout, and six seconds of provider timeout grace.
Oracle, test, and help cells show command exit codes; zero means pass.

| Agent | T | Elapsed ms | Work | Req start/done | Tools | Oracle | Tests | Help T/S/W |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Rupi | 1 | 594,141 | 0 | 1 / 1 | 0 | 1 | 1 | 1 / 1 / 1 |
| Rupi | 2 | 600,270 | 24,126 | 5 / 4 | 5 | 0 | 0 | 0 / 0 / 0 |
| Pi | 1 | 600,429 | 0 | 0 / 0 | 0 | 1 | 1 | 1 / 1 / 1 |
| Pi | 2 | 600,536 | 5,366 | 4 / 4 | 7 | 1 | 1 | 1 / 1 / 1 |

Rupi's first turn timed out without inference work or tool calls. It resolved the oracle in turn 2,
passed project tests, and passed all three help checks. Across both turns it used 24,126 work
tokens over 1,194,411 ms.

Pi timed out without inference work in turn 1. Its turn 2 used 5,366 work tokens, but it still did
not resolve the oracle. Project tests and all help checks failed in both turns; the snapshots had
no generated application files. Pi had used two turns without resolving, so its earliest possible
resolution was turn 3. Rupi therefore won by resolving in fewer turns. Further Pi turns were
stopped after the fewer-turn result was decisive.

Case 04's comparison objective is met. R1 through R6 remain historical Pi wins.

## Verification

- All ten cases passed the all-case dry run with thinking off:
  pwsh.exe -NoProfile -ExecutionPolicy Bypass -File bench\compare-pi-rupi.ps1 -DryRun
  -ThinkingLevel off.
- R7 per-turn summaries record Rupi's oracle, project-test, and help checks passing in turn 2.
- R7 per-turn summaries record Pi unresolved after turn 2, with its checks failing.
