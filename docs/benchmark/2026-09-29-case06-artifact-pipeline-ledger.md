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

## Baseline outcome

Pi resolved where Rupi did not, a strict oracle win. Pi used 23,919 fewer work tokens but took
186,652 ms longer. Rupi failed to start a healthy HTTP service and did not pass project-test
discovery or help checks. This was the Sep 29 baseline result; Case 07 followed in the original
sequence.

## Matched retry: strict Rupi oracle win

Run: `bench-20261002-case06-dag-focus-retry-off-grace6-cap8-pi0861-matched4-600s`.
Pi 0.86.1; local `qwen3.8-flash-next`; thinking off; four turns; 600-second outer timeout;
six-second provider grace; eight requests per turn. Work tokens are inference input plus output.

| Agent | Turn | Elapsed | Work tokens | Requests | Oracle | Tests | Help |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| Rupi | 1 | 315,115 ms | 12,475 | 1 | fail | exit 1 | 1/1/1 |
| Rupi | 2 | 600,236 ms | 18,931 | 3 | pass | exit 1 | 0/0/0 |
| Pi | 1 | 600,217 ms | 0 | 0 | fail | exit 1 | 1/1/1 |
| Pi | 2 | 600,221 ms | 2,902 | 5 | fail | exit 1 | 1/1/1 |
| Pi | 3 | 600,254 ms | 12,937 | 1 | fail | exit 1 | 1/1/1 |
| Pi | 4 | 600,217 ms | 10,009 | 5 | fail | exit 1 | 0/0/0 |

Rupi resolved the oracle on turn 2 after the outer timeout; Pi did not resolve in four turns.
Rupi used 31,406 work tokens over 915,351 ms; Pi used 25,848 over 2,400,909 ms. Rupi was
1,485,558 ms faster but used 5,558 more work tokens. The benchmark criterion is a strict
oracle win for Rupi. Rupi's project tests still exited 1, while all three help checks passed
on turn 2. Pi's project tests exited 1 in every turn, and its help checks passed on turn 4.

Attempt 6 was stopped as an unusable control: Rupi produced zero work tokens in all four turns,
and Pi turn 1 started no model request. The local model endpoint later answered a minimal probe.
See [PR #138](https://github.com/SaehwanPark/rupi/pull/138) for the full attempt history.
Case 07 is next.
