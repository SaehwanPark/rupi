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

## Outcome

The pinned comparison is inconclusive: neither agent resolved the case. Rupi used 56,007 more
work tokens, while elapsed time was nearly even (Rupi took 135 ms longer). Rupi passed help only
on turn 4; Pi did not pass help. Case 04 remains open as an optimization target, and Case 05 is
next.
