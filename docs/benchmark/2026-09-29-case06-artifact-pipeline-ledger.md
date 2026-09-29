# Case 06 artifact pipeline comparison ledger

This ledger records the matched `06-artifact-pipeline` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

## Matched baseline

Run: `bench-20260929-case06-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,361 ms | 9,250 / 10,263 | 19,513 | 3 | 3 | outer timeout |
| 2 | 448,205 ms | 24,760 / 7,026 | 31,786 | 8 | 9 | completed; unresolved |
| 3 | 600,220 ms | 2,425 / 10,236 | 12,661 | 2 | 2 | outer timeout |
| 4 | 565,647 ms | 1,023 / 4,568 | 5,591 | 2 | 2 | completed; unresolved |

Rupi did not resolve in four turns. It used 69,551 work tokens over 2,214,433 ms, with 15
requests and 16 tools. Every turn failed the acceptance oracle, project-test discovery, and
all three help checks. The server never became healthy during oracle checks. Python could not
import the `tests` start directory for project-test discovery.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,327 ms | 5,953 / 2,646 | 8,599 | 5 | 5 | outer timeout |
| 2 | 600,180 ms | 1,930 / 10,533 | 12,463 | 17 | 17 | outer timeout |
| 3 | 600,362 ms | 1,248 / 10,154 | 11,402 | 16 | 16 | outer timeout |
| 4 | 600,216 ms | 7,854 / 5,314 | 13,168 | 8 | 8 | outer timeout; resolved after verification |

Pi resolved on turn 4 after the outer timeout. The final turn passed the acceptance oracle, all
61 project tests, and all three help checks. Pi used 45,632 work tokens over 2,401,085 ms,
with 46 requests and 46 tools.

## Outcome

Pi resolved where Rupi did not, a strict oracle win. Pi used 23,919 fewer work tokens but took
186,652 ms longer. Rupi failed to start a healthy HTTP service and did not pass project-test
discovery or help checks. Case 07 is next.
