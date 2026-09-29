# Case 04 webhook inbox comparison ledger

This ledger records the first matched `04-webhook-inbox` run with the local
`qwen3.8-flash-next` model. Its artifact omitted the Pi version. The harness resolved Pi
from `PATH`; the current default installation reports 0.87.1, so treat this result as
provisional until the case is rerun with an explicit 0.86.1 executable.

## Matched baseline

Run: `bench-20260929-case04-baseline-low-matched4-600s`.

The run used low reasoning, four turns, 600-second outer turn timeouts, the eight-request
setting, and project-test/help recovery feedback. Rupi also used its configured 570-second
provider deadline. Requests below count model requests started; work tokens are inference input
plus output tokens.

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

Pi resolved in turn 3, using 28,305 work tokens over 1,800,669 ms. The resolving turn passed the
acceptance oracle and all three help checks. Project test discovery also exited 1 because the
generated project had no importable `tests/` directory.

## Outcome

This provisional run favors Pi: it resolved one turn earlier with 51,109 fewer work tokens and
351,977 fewer milliseconds. Both agents passed the case oracle and help checks, but neither
produced a discoverable test suite. It does not establish the Pi 0.86.1 comparison gate; a
pinned 0.86.1 rerun will establish Case 04 before Case 05.
