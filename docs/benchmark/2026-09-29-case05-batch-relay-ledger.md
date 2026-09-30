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

## Outcome of the entrypoint, tests, and health prompt

The prompt made Rupi's help checks pass on turns 2–4, but its server remained unreachable and
project test discovery found no tests. Pi's help checks failed on every turn, and its server also
remained unreachable.

## Explicit server-wiring prompt rerun

Run: `bench-20260930-case05-entrypoint-health-tests-first-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight requests per
turn, and a 594-second Rupi provider timeout. The prompt required an entrypoint and test package
in the first turn, followed by a persistent `serve` process and a successful `GET /healthz`
before batch and worker behavior. Recovery included oracle pass/fail status with local test and
help diagnostics. Requests count model requests started; work tokens are inference input plus
output. Check values are exit codes (0 means pass).

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,248 ms | 15,343 / 1,531 | 16,874 | 6 | 5 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,309 ms | 1,804 / 11,388 | 13,192 | 2 | 2 | 1 / 5 | 0 / 0 / 0 | outer timeout |
| 3 | 597,099 ms | 0 / 0 | 0 | 1 | 0 | 1 / 5 | 0 / 0 / 0 | no inference usage |
| 4 | 600,274 ms | 906 / 51 | 957 | 2 | 1 | 1 / 5 | 0 / 0 / 0 | outer timeout |

Rupi did not resolve after four turns. It used 31,023 work tokens over 2,397,930 ms. Its oracle
failed every turn; project tests exited 1, 5, 5, and 5, with no tests discovered. Help checks
failed on turn 1 and passed on turns 2–4.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,373 ms | 5,498 / 124 | 5,622 | 2 | 2 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,421 ms | 1,688 / 12,570 | 14,258 | 2 | 2 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,445 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | no inference usage |
| 4 | 600,188 ms | 1,626 / 10,954 | 12,580 | 9 | 9 | 1 / 1 | 1 / 1 / 1 | outer timeout |

Pi did not resolve after four turns. It used 32,460 work tokens over 2,401,427 ms. Its oracle,
project tests, and help checks exited 1 every turn. Both generated servers refused connections
on every oracle run. Rupi was 3,497 ms faster and used 1,437 fewer work tokens, but neither agent
passed the oracle, so this run is inconclusive and is not a Case 05 win.

## Outcome after fourth prompt

The entrypoint, tests, and health prompt still left both generated servers unreachable. Rupi's
help checks passed on turns 2–4, but its project test discovery found no tests. Pi's tests and
help failed on every turn. The next prompt required an explicit `batchrelay.server.run` path,
`serve_forever()`, and a subprocess health test.

## Fifth prompt iteration: explicit server module and health test

Run: `bench-20260930-case05-server-run-health-test-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight requests per
turn, and a 594-second Rupi provider timeout. Requests count model requests started; work tokens
are inference input plus output. Check values are exit codes (0 means pass).

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 592,511 ms | 25,653 / 9,442 | 35,095 | 8 | 7 | 1 / 1 | 0 / 0 / 0 | budget exhausted |
| 2 | 499,006 ms | 0 / 0 | 0 | 1 | 0 | 1 / 1 | 0 / 0 / 0 | no inference usage |
| 3 | 600,334 ms | 1,380 / 7,906 | 9,286 | 2 | 1 | 1 / 5 | 0 / 0 / 0 | outer timeout |
| 4 | 600,262 ms | 4,110 / 9,609 | 13,719 | 4 | 3 | 1 / 5 | 0 / 0 / 0 | outer timeout |

Rupi remained unresolved after four turns. It used 58,100 work tokens over 2,292,113 ms, with
31,143 input tokens, 26,957 output tokens, 15 requests, and 11 tool requests. Oracle checks
failed every turn, project tests failed every turn, and all help checks passed every turn.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Oracle / tests | Help (top / serve / worker) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,560 ms | 6,462 / 347 | 6,809 | 3 | 6 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,224 ms | 1,497 / 10,711 | 12,208 | 1 | 2 | 1 / 1 | 0 / 0 / 0 | outer timeout |
| 3 | 600,235 ms | 2,124 / 10,445 | 12,569 | 7 | 8 | 0 / 1 | 0 / 0 / 0 | resolved |

Pi resolved the oracle on turn 3. It used 31,586 work tokens over 1,801,019 ms, with 10,083
input tokens, 21,503 output tokens, 11 requests, and 16 tool requests. Its project tests failed
on every turn; help checks failed on turn 1 and passed on turns 2–3. Pi was 491,094 ms faster and
used 26,514 fewer work tokens. This run is a Pi win, not a Case 05 win for Rupi.

The Rupi oracle diagnostics reported a refused connection on all four turns. Its generated
`batchrelay/__main__.py` dispatched `serve` to `batchrelay.server.run`, but the generated project
contained no `batchrelay/server.py` and no `tests/test_server.py`. This source inspection is
consistent with, but does not independently reproduce, the oracle's connection-refused result.
The next prompt will make `batchrelay/server.py` the first deliverable, then wire it to the
existing CLI design and add a focused subprocess health test before batch and worker behavior.
PR #137 remains draft.

## Outcome after fifth prompt

Case 05 remains open. The explicit server-wiring prompt did not produce a runnable Rupi server;
Pi resolved the oracle in turn 3. The next iteration will prioritize a concrete server module
and a discovered health test, based on the missing files found in Rupi's generated project.

## Sixth prompt iteration: server module first

Run: `bench-20260930-case05-server-module-first-smoke-r6-grace6-cap8-pi0861-low-matched4-600s`.
Settings matched the prior run: Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts,
eight requests per turn, and a 594-second Rupi provider timeout. Check values are exit codes
(0 means pass). Help codes list top-level, serve, and worker in that order.

| Turn | ms | Input / output | Work | Req. | Tools | Oracle / tests | Help exits | Result |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,253 ms | 17,899 / 8,795 | 26,694 | 4 | 10 | 1 / 0 | 0 / 0 / 0 | outer timeout |
| 2 | 595,263 ms | 0 / 0 | 0 | 1 | 0 | 1 / 0 | 0 / 0 / 0 | no inference usage |
| 3 | 596,851 ms | 0 / 0 | 0 | 1 | 0 | 1 / 0 | 0 / 0 / 0 | no inference usage |
| 4 | 598,531 ms | 0 / 0 | 0 | 1 | 0 | 1 / 0 | 0 / 0 / 0 | no inference usage |

Rupi did not resolve after four turns. It used 26,694 work tokens over 2,390,898 ms. Its project
tests ran two tests and passed on every turn; all help checks passed. The oracle failed every
turn, but the connection refusal was resolved: diagnostics now report `404 unknown path` for two
signed batch requests that expected 202, and for an invalid-signature request that expected 401.
The generated project now contains both `batchrelay/server.py` and `tests/test_server.py`.

| Turn | ms | Input / output | Work | Req. | Tools | Oracle / tests | Help exits | Result |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,432 ms | 6,897 / 11,172 | 18,069 | 8 | 12 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,216 ms | 2,930 / 10,544 | 13,474 | 13 | 13 | 0 / 0 | 0 / 0 / 0 | resolved |

Pi resolved in turn 2 with 31,543 work tokens over 1,200,648 ms, 9,827 input tokens, 21,716
output tokens, 21 requests, and 25 tool requests. Rupi used 4,849 fewer work tokens but took
1,190,250 ms longer and did not pass the oracle. Pi project tests and help failed on turn 1 and
passed on turn 2. This run is a Pi win, not a Case 05 win for Rupi.

The next prompt will combine the now-working health path with signed `POST /batches` admission
in the first slice. It will require new batches to return 202, exact replays 200, conflicting
replays 409, and invalid signatures 401, before implementing worker behavior. PR #137 remains
draft.

## Outcome after sixth prompt

Case 05 remains open. Rupi's server and focused tests now work, but its batch admission route
still falls through to `404 unknown path`. Pi resolved the oracle in turn 2. The next prompt will
prioritize signed batch admission in the first slice and defer worker behavior.

## Seventh prompt iteration: signed admission first

Run:
`bench-20260930-case05-signed-admission-first-r7-grace6-cap8-pi0861-low-matched4-600s`.
This used Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts, eight requests per
turn, and a 594-second Rupi provider timeout. Check values are exit codes (0 means pass). Help
codes list top-level, serve, and worker in that order.

| Turn | ms | Input / output | Work | Req. | Tools | Oracle / tests | Help exits | Result |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,332 ms | 4,012 / 45 | 4,057 | 2 | 1 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,223 ms | 4,477 / 48 | 4,525 | 2 | 1 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,367 ms | 3,027 / 9,882 | 12,909 | 3 | 3 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 4 | 17,271 ms | 1,693 / 90 | 1,783 | 1 | 1 | 1 / 1 | 1 / 1 / 1 | unresolved |

Rupi remained unresolved after four turns. It used 23,274 work tokens over 1,818,193 ms, with
13,209 input tokens, 10,065 output tokens, eight requests, and six tool requests. Its oracle,
project tests, and help checks failed on every turn.

| Turn | ms | Input / output | Work | Req. | Tools | Oracle / tests | Help exits | Result |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,504 ms | 6,274 / 291 | 6,565 | 4 | 4 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,227 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,221 ms | 1,673 / 178 | 1,851 | 2 | 2 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 4 | 600,183 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | outer timeout |

Pi also remained unresolved. It used 8,416 work tokens over 2,401,135 ms, with 7,947 input
tokens, 469 output tokens, six requests, and six tool requests. Both agents' oracle diagnostics
reported that their servers did not become healthy. Project tests and help checks failed every
turn for both agents. Rupi's generated package contained only `__init__.py` and `validation.py`;
neither agent produced a CLI entrypoint, server module, or tests. Rupi was 582,942 ms faster and
used 14,858 more work tokens. This run is inconclusive.

The first-slice admission prompt did not produce a runnable server for either agent. The next
prompt returns to the health-first slice that previously produced a Rupi server and two passing
project tests; signed admission will be the next recovery priority after the health slice passes.
PR #137 remains draft.

## Current outcome

Case 05 remains open. The seventh prompt regressed server startup for both agents. The next
iteration will focus on the executable health slice before adding signed admission.

## Eighth prompt iteration: health first, then admission

Run: `bench-20260930-case05-health-first-recover-admission-r8-grace6-cap8-pi0861-low-matched4-600s`.
Settings matched the prior run: Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts,
eight requests per turn, and a 594-second Rupi provider timeout. Check values are exit codes
(0 means pass). Help codes list top-level, serve, and worker in that order.

| Turn | ms | Input / output | Work | Req. | Tools | Oracle / tests | Help exits | Result |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,618 ms | 20,273 / 11,008 | 31,281 | 7 | 9 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,214 ms | 1,643 / 6,940 | 8,583 | 2 | 2 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,233 ms | 7,132 / 11,016 | 18,148 | 4 | 4 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 4 | 600,334 ms | 8,674 / 7,347 | 16,021 | 8 | 9 | 1 / 0 | 0 / 0 / 0 | outer timeout |

Rupi remained unresolved after four turns. It used 74,033 work tokens over 2,401,399 ms, with
37,722 input tokens, 36,311 output tokens, 21 requests, and 24 tool requests. Its oracle failed
every turn. Project tests and all help checks failed on turns 1–3 and passed on turn 4. Final
oracle diagnostics included a remote disconnect during a batch-cycle lookup and a crashed-lease
worker that never reached the sink.

| Turn | ms | Input / output | Work | Req. | Tools | Oracle / tests | Help exits | Result |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,222 ms | 5,679 / 221 | 5,900 | 2 | 4 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,249 ms | 0 / 0 | 0 | 0 | 0 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,304 ms | 1,835 / 11,759 | 13,594 | 7 | 9 | 0 / 1 | 0 / 0 / 0 | resolved |

Pi resolved in turn 3 with 19,494 work tokens over 1,800,775 ms, 7,514 input tokens, 11,980
output tokens, nine requests, and 13 tool requests. Its oracle passed on turn 3; project tests
failed every turn, and help passed on turn 3. Pi was 600,624 ms faster and used 54,539 fewer
work tokens. This run is a Pi win, not a Case 05 win for Rupi.

The health-first prompt improved Rupi's local project checks and help output by turn 4, but its
server still dropped a batch-cycle request and its worker did not reach the sink. The next prompt
will target those remaining oracle failures. PR #137 remains draft.

## Current outcome

Case 05 remains open. The eighth health-first rerun was a Pi win: Pi resolved in turn 3, while
Rupi remained unresolved after four turns. The next iteration will focus on batch-cycle handling
and worker delivery.
