# Case 09 lease receipt comparison ledger

This ledger records the matched `09-lease-receipt` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

## Matched baseline

Run: `bench-20260929-case09-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,547 ms | 12,907 / 9,680 | 22,587 | 4 | 4 | outer timeout |
| 2 | 600,150 ms | 13,863 / 8,763 | 22,626 | 4 | 3 | outer timeout |
| 3 | 600,221 ms | 5,244 / 8,940 | 14,184 | 3 | 2 | outer timeout |
| 4 | 600,339 ms | 8,903 / 9,474 | 18,377 | 8 | 7 | outer timeout; unresolved |

Rupi did not resolve in four turns. It used 77,774 work tokens over 2,401,257 ms, with 19
requests and 16 tools. All oracle, project-test, and help checks failed on turns 1 through 3.
All help checks passed on turn 4, but the oracle and project-test checks still failed. The
oracle's four service tests failed with SQLite's `no such column: rowid` error. Project-test discovery could not import the `tests` start directory.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,213 ms | 6,487 / 11,890 | 18,377 | 5 | 5 | outer timeout |
| 2 | 600,235 ms | 1,369 / 9,072 | 10,441 | 8 | 8 | outer timeout |
| 3 | 600,201 ms | 2,801 / 9,795 | 12,596 | 11 | 11 | outer timeout |
| 4 | 600,203 ms | 4,802 / 7,217 | 12,019 | 13 | 13 | outer timeout; unresolved |

Pi did not resolve in four turns. It used 53,433 work tokens over 2,400,852 ms, with 37
requests and 37 tools. All oracle, project-test, and help checks failed on turns 1 through 3.
All help checks passed on turn 4, but the oracle and project-test checks still failed. The
oracle's four service tests ended with remote disconnects. Project-test discovery could not
import the `tests` start directory.

## Outcome

The result is inconclusive because neither agent resolved the oracle. Pi used 24,341 fewer work
tokens and finished 405 ms sooner, while making more model requests and tool calls. Rupi's
service could not initialize its SQLite schema; Pi's oracle requests ended in remote
disconnects. Case 10 is next.
