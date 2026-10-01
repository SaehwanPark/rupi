# Case 04 webhook inbox comparison ledger

This ledger records the initial run with an unrecorded Pi version and the later Pi 0.86.1
rerun for `04-webhook-inbox` using local `qwen3.8-flash-next`.

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

## Current outcome

Case 04 remains open after two Pi wins: the full-spec first-write rerun and the R2
admission-first rerun. PR #136 stays draft while the next recovery-guidance iteration is prepared.

## Recovery-gated prompt iteration (R3, pending)

Proposed run:
`bench-20261001-case04-recovery-gated-grace6-cap8-pi0861-low-matched4-600s`.
The initial prompt states the exact `serve` and `worker` command forms, requires all three help
paths, and creates an importable tests package with subprocess help checks before worker logic.
Recovery selects an interface phase when help or test discovery is missing, then advances to the
worker workflow after those local checks pass. Oracle status and diagnostics remain hidden. The
all-case dry run passed; the matched comparison is pending.
