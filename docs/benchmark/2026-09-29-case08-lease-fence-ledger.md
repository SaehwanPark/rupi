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
