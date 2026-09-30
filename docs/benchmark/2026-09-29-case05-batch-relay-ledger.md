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

## Outcome of the pinned baseline

Both agents resolved the acceptance oracle in turn 3, so this is not a strict oracle win. Rupi
finished 14,869 ms sooner but used 24,180 more work tokens. Neither generated a discoverable
project test suite. The baseline comparison remains mixed; the later Case 05 prompt
experiment is recorded below.

## Embedded-spec, harness-feedback prompt rerun

Run: `bench-20260930-case05-embedded-spec-incremental-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight requests per
turn, and a 594-second Rupi provider timeout. The initial prompt embedded the full SPEC and
emphasized incremental implementation, authentication over raw bytes, atomic DAG admission,
committed leases, direct-argv sink delivery, and bounded worker behavior. Prompts deferred
local checks to the benchmark harness. Requests count model requests started; work tokens are
inference input plus output. Check values are exit codes (0 means pass).

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,660 ms | 6,018 / 123 | 6,141 | 2 | 2 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 595,705 ms | 0 / 0 | 0 | 1 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |
| 3 | 597,195 ms | 0 / 0 | 0 | 1 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |
| 4 | 598,162 ms | 0 / 0 | 0 | 1 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |

Rupi did not resolve after four turns. It used 6,141 work tokens over 2,391,722 ms. The oracle,
project tests, and all help checks exited 1 on every turn. The reduction from the pinned
baseline was 55,246 work tokens, but it did not produce a runnable result.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,226 ms | 6,204 / 12,155 | 18,359 | 11 | 11 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,312 ms | 6,183 / 9,950 | 16,133 | 11 | 12 | 1 / 1 | 0 / 0 / 0 | outer timeout |
| 3 | 404,418 ms | 1,569 / 6,628 | 8,197 | 6 | 5 | 0 / 0 | 0 / 0 / 0 | resolved |

Pi resolved in turn 3, using 42,689 work tokens over 1,604,956 ms. The resolving turn passed the
oracle, project tests, and all help checks. Rupi took 786,766 ms longer and did not resolve.
It used 36,548 fewer work tokens, but the completion and elapsed-time comparison favors Pi.

## Current outcome

This embedded-spec prompt iteration did not win Case 05. Rupi's first turn used far fewer tokens
than its baseline, but turns 2–4 made no inference progress and the oracle never passed. Case 05
remains open; PR #137 stays draft while a narrower prompt iteration is prepared.
