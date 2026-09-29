# Case 05 batch relay comparison ledger

This ledger records the matched `05-batch-relay` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

## Matched baseline

Run: `bench-20260929-case05-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer turn timeouts, and project-test/help recovery feedback. Rupi's
provider deadline was 570 seconds. Requests count model requests started; work tokens are inference
input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 585,409 ms | 15,082 / 864 | 15,946 | 5 | 4 | exit 1 |
| 2 | 600,231 ms | 19,899 / 9,012 | 28,911 | 6 | 5 | outer timeout |
| 3 | 600,225 ms | 6,581 / 9,949 | 16,530 | 6 | 5 | resolved after timeout |

Rupi resolved in turn 3, using 61,387 work tokens over 1,785,865 ms. The final turn passed the
acceptance oracle and all three help checks. Project-test discovery exited 5; it ran no tests and
reported that the `tests` start directory was not importable.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,245 ms | 5,635 / 11,822 | 17,457 | 5 | 5 | outer timeout |
| 2 | 600,266 ms | 1,160 / 10,985 | 12,145 | 4 | 4 | outer timeout |
| 3 | 600,223 ms | 1,151 / 6,454 | 7,605 | 6 | 6 | resolved after timeout |

Pi resolved in turn 3, using 37,207 work tokens over 1,800,734 ms. The final turn passed the
acceptance oracle and all three help checks. Project-test discovery exited 1 because Python could
not import the `tests` start directory.

## Outcome

Both agents resolved the acceptance oracle in turn 3, so this is not a strict oracle win. Rupi
finished 14,869 ms sooner but used 24,180 more work tokens. Neither generated a discoverable
project test suite. The result is mixed; Case 06 is next.
