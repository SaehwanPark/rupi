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

## Outcome

Pi resolved where Rupi did not, a strict oracle win. Pi used 7,477 fewer work tokens but took
112,263 ms longer. Rupi project-test discovery could not import `tests`; oracle requests were
disconnected, and worker help still failed on turn 4. Case 08 is next.
