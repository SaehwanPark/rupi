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
