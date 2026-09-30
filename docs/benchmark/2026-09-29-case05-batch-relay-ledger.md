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

## Outcome of the embedded-spec iteration

This prompt did not win Case 05. Rupi's first turn used far fewer tokens than its baseline, but
turns 2–4 made no inference progress and the oracle never passed. The next experiment read the
SPEC once and directed the first runnable implementation into the entrypoint.

## Read-once, entrypoint-first prompt rerun

Run: `bench-20260930-case05-entrypoint-harness-grace6-cap8-pi0861-low-matched4-600s`. This used
Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight requests per turn, and a
594-second Rupi provider timeout. The prompt used the normal initial SPEC read, directed the
agent to keep the runnable service and worker in `batchrelay/__main__.py` until the full flow
worked, and deferred local checks to the harness. Requests count model requests started; work
tokens are inference input plus output. Check values are exit codes (0 means pass).

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,239 ms | 19,023 / 10,665 | 29,688 | 4 | 3 | 1 / 1 | 0 / 0 / 0 | outer timeout |
| 2 | 600,276 ms | 10,594 / 6,406 | 17,000 | 3 | 2 | 1 / 5 | 0 / 0 / 0 | outer timeout |
| 3 | 596,236 ms | 0 / 0 | 0 | 1 | 0 | 1 / 5 | 0 / 0 / 0 | no inference usage |
| 4 | 578,186 ms | 0 / 0 | 0 | 1 | 0 | 1 / 5 | 0 / 0 / 0 | no inference usage |

Rupi did not resolve after four turns. It used 46,688 work tokens over 2,374,937 ms. Its oracle
failed every turn; project tests exited 1 on turn 1 and 5 on turns 2–4. All three help checks
passed in every turn. The entrypoint was created in turn 1, but turns 3–4 made no inference
progress.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,225 ms | 5,749 / 372 | 6,121 | 4 | 4 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,196 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,228 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 4 | 600,289 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | outer timeout |

Pi did not resolve in four turns. It used 6,121 work tokens over 2,400,938 ms. Its oracle, project
tests, and all help checks failed in every turn. Neither agent resolved, so the result is
inconclusive: Rupi was 26,001 ms faster but used 40,567 more work tokens. This run did not
reproduce the prior Pi turn-3 oracle pass.

## Outcome of the read-once, entrypoint-first iteration

Case 05 remained open after this iteration. The entrypoint-first prompt improved Rupi's help
checks, but neither agent resolved and Rupi used more work tokens than Pi. The next experiment
returned to modular behavior code, prioritized a valid signed batch, and provided only the
oracle pass/fail result during recovery.

## Valid-path, oracle-status recovery prompt rerun

Run: `bench-20260930-case05-valid-path-oracle-status-r2-grace6-cap8-pi0861-low-matched4-600s`.
This used the published Pi 0.86.1 package, low reasoning, four turns, 600-second outer timeouts,
eight requests per turn, and a 594-second Rupi provider timeout. Pi ran from an isolated npm
prefix with package install scripts disabled. The prompt used modular behavior code and called
out the SPEC's valid batch status codes: 202 for first acceptance, 200 for exact idempotent
replay, and 409 for conflicting content. Recovery included the oracle pass/fail result, while
leaving oracle diagnostics and source hidden. Requests count model requests started; work tokens
are inference input plus output. Check values are exit codes (0 means pass).

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,351 ms | 13,968 / 9,681 | 23,649 | 5 | 4 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 17,626 ms | 1,319 / 168 | 1,487 | 1 | 1 | 1 / 1 | 1 / 1 / 1 | completed |
| 3 | 1,569 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |
| 4 | 1,479 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |

Rupi did not resolve after four turns. It used 25,136 work tokens over 621,025 ms. Its oracle,
project tests, and all three help checks exited 1 on every turn. It used inference in turns 1–2;
turns 3–4 had no inference requests.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,403 ms | 5,633 / 10,766 | 16,399 | 9 | 9 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,234 ms | 3,018 / 9,156 | 12,174 | 6 | 6 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,320 ms | 3,517 / 9,857 | 13,374 | 6 | 6 | 1 / 5 | 0 / 0 / 0 | outer timeout |
| 4 | 600,302 ms | 977 / 9,046 | 10,023 | 8 | 8 | 1 / 0 | 0 / 0 / 0 | outer timeout |

Pi did not resolve after four turns. It used 51,970 work tokens over 2,401,259 ms. Its oracle
exited 1 every turn; project tests exited 1, 1, 5, and 0, while all help checks passed on turns
3–4. Rupi was 1,780,234 ms faster and used 26,834 fewer work tokens, but neither agent passed
the oracle. This run is not a Case 05 win.

## Current outcome

Case 05 remains open. The valid-path, oracle-status prompt did not resolve the case. Rupi used
less time and fewer work tokens than Pi, but both failed the oracle on every turn. The oracle
diagnostics report connection refused for both generated servers on all turns. On Rupi's final
turn, help failed because `batchrelay.__main__` was missing, and test discovery could not import
`tests`. The next prompt will prioritize a runnable entrypoint, an importable test package, and a
persistent `/healthz` route. PR #137 remains draft.
