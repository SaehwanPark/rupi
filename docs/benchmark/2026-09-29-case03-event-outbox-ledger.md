# Case 03 event outbox comparison ledger

This ledger records matched runs for the `03-event-outbox` case in the ten-case
Pi comparison.

## Baseline matched run

Run: `bench-20260929-case03-baseline-low-matched4-600s`.

This baseline used low reasoning, four turns, 600-second turn timeouts, and
project-test/help recovery feedback.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,282 ms | 7,955 / 8,162 | 16,117 | 7 | 6 | outer timeout |
| 2 | 11,115 ms | 1,013 / 50 | 1,063 | 1 | 1 | reconciliation; tool failed |
| 3 | 1,731 ms | 0 / 0 | 0 | 0 | 0 | reconciliation; no work |
| 4 | 1,693 ms | 0 / 0 | 0 | 0 | 0 | reconciliation; no work |

Rupi used 17,180 inference-work tokens over 614,821 ms and did not resolve.
It created only `outbox/__init__.py`. Turn 2 attempted `dir /b /s outbox tests`;
the missing `tests` path made the shell command fail and left an unresolved
mutating tool. Help, test discovery, and oracle checks failed.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,246 ms | 4,783 / 397 | 5,180 | 5 | 5 | outer timeout |
| 2 | 600,250 ms | 968 / 155 | 1,123 | 1 | 1 | outer timeout |
| 3 | 600,210 ms | 0 / 0 | 0 | 0 | 0 | outer timeout |
| 4 | 600,287 ms | 0 / 0 | 0 | 0 | 0 | outer timeout |

Pi used 6,303 inference-work tokens over 2,400,993 ms and created no source.
Neither produced a runnable package, README, or tests. Rupi used 10,877 more
work tokens, but created one file and finished much sooner than Pi's four
turns. Neither agent resolved, so this is inconclusive rather than a case win.
Case 03 remains open. The next retry applies the one-request `write` progress
boundary to Rupi and the matched harness-verification guidance to both agents.

## Shared harness-verification retry

Run: `bench-20260929-case03-progress-guidance-pi0861-low-matched4-600s`.

The retry used byte-matched prompts, Pi 0.86.1, low reasoning, four turns,
600-second turn deadlines, and an eight-request per-turn cap. The harness ran
project tests, all three help commands, and the independent oracle after every
turn.

| Rupi turn | Elapsed | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | --- | --- |
| 1 | 592,179 ms | 3,845 | 2 | `read`, `exec` | call failed; checks failed |
| 2 | 595,182 ms | 3,625 | 2 | `exec` | call failed; checks failed |
| 3 | 594,796 ms | 3,396 | 2 | `exec` | call failed; checks failed |
| 4 | 600,239 ms | 17,773 | 7 | `write`, `edit` | outer timeout; checks failed |

Rupi used 28,639 inference-work tokens over 2,382,396 ms. It created
`outbox/__init__.py`, `service.py`, `storage.py`, and `worker.py`, but omitted
`outbox/__main__.py`, a README, and tests. All help commands failed because the
package had no executable entry point; the oracle failed for the same reason,
and test discovery failed because `tests/` was absent.

| Pi turn | Elapsed | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | --- | --- |
| 1 | 600,307 ms | 4,873 | 2 | `read`, `ls` | outer timeout; checks failed |
| 2 | 600,307 ms | 0 | 0 | — | outer timeout; checks failed |
| 3 | 600,282 ms | 1,218 | 1 | `ls` | outer timeout; checks failed |
| 4 | 600,287 ms | 0 | 0 | — | outer timeout; checks failed |

Pi used 6,091 inference-work tokens over 2,401,183 ms and created no source.
Neither agent resolved the oracle or help checks. Rupi finished 18,787 ms sooner
but used 22,548 more work tokens, so this retry is not a win. Both agents failed
project test discovery, and neither produced the required README and tests.

The next retry will require `outbox/__main__.py` as the first source write and
keep the CLI, HTTP handler, SQLite storage, and worker there until the complete
service and `worker --once` flow work. It will retain the one-request write
progress boundary and shared harness-verification guidance.

## Entrypoint-first retry

Run: `bench-20260929-case03-entrypoint-first-progress-guidance-pi0861-low-matched4-600s`.

This matched run kept byte-identical prompts, Pi 0.86.1, low reasoning, four
turns, 600-second deadlines, and an eight-request per-turn cap.

| Rupi turn | Elapsed | Work tokens | Requests | Project tests | Oracle | Help | Result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,467 ms | 27,910 | 5 | fail | fail | pass | outer timeout |
| 2 | 467,054 ms | 46,608 | 9 | pass | fail | pass | unresolved |
| 3 | 600,252 ms | 13,330 | 4 | fail | fail | pass | outer timeout |
| 4 | 600,296 ms | 12,858 | 3 | fail | fail | pass | outer timeout |

Rupi used 100,706 inference-work tokens over 2,268,069 ms. It created the CLI,
HTTP API, worker, README, and focused tests. Help passed in every turn, but the
oracle failed because SQLite database files remained locked during cleanup.
The final project test run had one worker-test error: the test class overrode
`unittest.TestCase.run` and referenced a missing `db` attribute.

| Pi turn | Elapsed | Work tokens | Project tests | Oracle | Help | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,340 ms | 16,717 | fail | pass | pass | resolved |

Pi's outer call timed out, but its independent oracle and all three help checks
passed in turn 1. It created only `outbox/__init__.py` and `outbox/__main__.py`;
project test discovery failed because `tests/` was absent. Pi used 83,989 fewer
work tokens and was 1,667,729 ms faster than Rupi. This is a Pi win, not a
Case 03 Rupi win. Project tests and README remain separate tracked requirements.

The next retry retains entrypoint-first guidance and adds explicit SQLite
shutdown cleanup guidance. It lowers the matched per-turn request cap to six,
which is enough for Pi's resolving turn in this run, while keeping four turns
and 600-second deadlines.

## Shutdown-guidance, cap-six retry

Run: `bench-20260930-case03-sqlite-shutdown-cap6-pi0861-low-matched4-600s`.

The run retained byte-matched prompts, Pi 0.86.1, low reasoning, four turns,
and 600-second outer deadlines. Both agents produced no source files and failed
project-test, oracle, and help checks.

| Rupi turn | Elapsed | Work tokens | Requests | Result |
| --- | ---: | ---: | ---: | --- |
| 1 | 588,969 ms | 3,926 | 2 | provider timeout; read only |
| 2 | 571,635 ms | 0 | 1 | provider timeout |
| 3 | 573,220 ms | 0 | 1 | provider timeout |
| 4 | 590,807 ms | 1,382 | 2 | provider timeout after `grep` |

Rupi used 5,308 work tokens over 2,324,631 ms. Its request timed out at
570,000 ms on the first turn after the progress boundary required a `write`.
The later turns also hit provider timeouts before creating source.

| Pi turn | Elapsed | Work tokens | Result |
| --- | ---: | ---: | --- |
| 1 | 600,311 ms | 4,938 | outer timeout |
| 2 | 600,263 ms | 0 | outer timeout |
| 3 | 600,341 ms | 0 | outer timeout |
| 4 | 600,231 ms | 0 | outer timeout |

Pi used 4,938 work tokens over 2,401,146 ms and created no source. Neither
agent resolved. Rupi was 76,515 ms faster but used 370 more tokens, so the run
is inconclusive rather than a win. See the turn logs in the run artifacts.

The next retry will restore the eight-request cap and reduce the Rupi provider
timeout grace from 30 seconds to six seconds. This gives each 600-second turn a
594-second provider request before the outer watchdog, while keeping all other
benchmark settings and the prompt unchanged.
