# Case 10 comparison ledger: receipt ledger

This ledger records the matched `10-receipt-ledger` run with local `qwen3.8-flash-next` and
Pi 0.86.1. The case tests the capstone pipeline's same-transaction, append-only SHA-256 audit
chain.

## Matched baseline

Run: `bench-20260929-case10-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,250 ms | 16,835 / 3,932 | 20,767 | 6 | 6 | outer timeout |
| 2 | 600,295 ms | 17,318 / 8,471 | 25,789 | 8 | 7 | outer timeout |
| 3 | 600,266 ms | 5,742 / 8,304 | 14,046 | 8 | 7 | outer timeout |
| 4 | 536,590 ms | 23,083 / 5,440 | 28,523 | 8 | 7 | completed; unresolved |

Rupi did not resolve in four turns. It used 89,125 work tokens over 2,337,401 ms, with 30
requests and 27 tools. The first three calls timed out; the fourth completed before its outer
limit. All oracle, project-test, and help checks failed on every turn. The service and help
commands could not run because Python reported that `receiptledger.__main__` was missing.
Project-test discovery could not import the `tests` start directory.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,301 ms | 7,413 / 548 | 7,961 | 6 | 6 | outer timeout |
| 2 | 600,306 ms | 0 / 0 | 0 | 0 | 0 | outer timeout; no model request |
| 3 | 600,311 ms | 1,053 / 188 | 1,241 | 2 | 2 | outer timeout |
| 4 | 600,232 ms | 0 / 0 | 0 | 0 | 0 | outer timeout; no model request |

Pi did not resolve in four turns. It used 9,202 work tokens over 2,401,150 ms, with eight
requests and eight tools. Every turn timed out. All oracle, project-test, and help checks failed
on every turn. On turns 2 and 4, the recorded request and tool counts were zero. On the final
turn, Python could not import `receiptledger`, so the service and help commands failed.
Project-test discovery could not import the `tests` start directory.

## Outcome

The result is inconclusive because neither agent resolved the oracle. Rupi used 79,923 more work
tokens and finished 63,749 ms sooner. Both attempts failed to provide an importable service, and
both failed project-test discovery and all help checks. This completes the ten-case comparison.
