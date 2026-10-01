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

## Ninth prompt iteration: HTTP contract before worker

Run: `bench-20260930-case05-http-contract-first-r9-grace6-cap8-pi0861-low-matched4-600s`.
Settings matched the eighth run: Pi 0.86.1, low reasoning, four turns, 600-second outer timeouts,
eight requests per turn, and a 594-second Rupi provider timeout. Check values are exit codes
(0 means pass). Help codes list top-level, serve, and worker in that order.

| Turn | ms | Input / output | Work | Req. | Tools | Oracle / tests | Help exits | Result |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 573,198 ms | 28,426 / 9,543 | 37,969 | 8 | 10 | 1 / 1 | 1 / 1 / 1 | budget exhausted |
| 2 | 600,320 ms | 13,060 / 1,528 | 14,588 | 3 | 2 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,271 ms | 9,291 / 5,026 | 14,317 | 5 | 7 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 4 | 600,259 ms | 9,297 / 4,095 | 13,392 | 3 | 3 | 1 / 1 | 1 / 1 / 1 | outer timeout |

Rupi remained unresolved and no oracle, project-test, or help check passed. It used 80,266 work
tokens over 2,374,048 ms, 60,074 input tokens, 20,192 output tokens, 19 requests, and 22 tool
requests.

| Turn | ms | Input / output | Work | Req. | Tools | Oracle / tests | Help exits | Result |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,372 ms | 7,039 / 11,949 | 18,988 | 5 | 11 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,321 ms | 3,334 / 10,211 | 13,545 | 6 | 7 | 1 / 1 | 1 / 1 / 1 | outer timeout |
| 3 | 600,298 ms | 8,644 / 8,431 | 17,075 | 4 | 5 | 1 / 5 | 0 / 0 / 0 | outer timeout |
| 4 | 600,334 ms | 1,216 / 8,493 | 9,709 | 2 | 2 | 1 / 1 | 0 / 0 / 0 | outer timeout |

Pi also remained unresolved. It used 59,317 work tokens over 2,401,325 ms, with 20,233 input
tokens, 39,084 output tokens, 17 requests, and 25 tool requests. The oracle and project tests
failed every turn; help passed on turns 3–4. Rupi was 27,277 ms faster but used 20,949 more work
tokens, so this run is inconclusive.

The prompt did not bring Rupi to passing local checks: its CLI help, project tests, and oracle all
failed on every turn. Turn 4 diagnostics show `batchrelay/__main__.py` imports a missing
`batchrelay.worker` before parsing arguments, so all help commands fail. The generated project has
no `tests` package, so unittest discovery fails. The next prompt will establish an importable CLI
and test package before adding HTTP behavior. PR #137 remains draft.

## Tenth prompt iteration — complete; inconclusive

Run: `bench-20260930-case05-cli-importable-first-r10-grace6-cap8-pi0861-low-matched4-600s`.

This prompt responds to the R9 help-import and test-discovery failures. Its first phase creates an
import-safe argparse CLI with lazy command imports, `tests/__init__.py`, and subprocess help checks
for the package, `serve`, and `worker`. Recovery advances through health, HTTP, and worker only
after local project tests and all help commands pass. Oracle diagnostics remain hidden.

The all-case benchmark dry run and `git diff --check` passed.

### Rupi result

Rupi remained unresolved after four turns, using 42,629 work tokens over 1,990,405 ms. It used
23,155 input tokens, 19,474 output tokens, 17 model requests, and 17 tool requests. Its oracle
failed every turn; all three help commands passed every turn. Project tests ran zero tests on turn
1, then passed on turns 2–4.

| Turn | Elapsed | In / out | Work | Req / tools | Oracle / tests | Help | Call |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 470,865 ms | 9,475 / 2,100 | 11,575 | 3 / 3 | failed / exit 5 | 0 / 0 / 0 | exit 1 |
| 2 | 319,031 ms | 3,108 / 5,836 | 8,944 | 6 / 7 | failed / 0 | 0 / 0 / 0 | complete |
| 3 | 600,316 ms | 9,839 / 11,112 | 20,951 | 6 / 6 | failed / 0 | 0 / 0 / 0 | outer timeout |
| 4 | 600,193 ms | 733 / 426 | 1,159 | 2 / 1 | failed / 0 | 0 / 0 / 0 | outer timeout |

The generated project includes `batchrelay/server.py` and `tests/test_server.py`; its 16 tests and
all help commands pass. It has no `tests/test_http.py` or `batchrelay/worker.py`, so it did not
complete the HTTP slice assigned on turn 4.

### Pi result

Pi remained unresolved after four turns, using 31,162 work tokens over 2,401,242 ms. It used
10,366 input tokens, 20,796 output tokens, 20 model requests, and 20 tool requests. Its oracle
failed every turn; project tests failed on turn 1 and passed on turns 2–4; all help commands
passed every turn.

| Turn | Elapsed | In / out | Work | Req / tools | Oracle / tests | Help | Call |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,284 ms | 6,110 / 10,443 | 16,553 | 9 / 9 | failed / exit 1 | 0 / 0 / 0 | outer timeout |
| 2 | 600,306 ms | 4,256 / 10,353 | 14,609 | 11 / 11 | failed / 0 | 0 / 0 / 0 | outer timeout |
| 3 | 600,368 ms | 0 / 0 | 0 | 0 / 0 | failed / 0 | 0 / 0 / 0 | outer timeout |
| 4 | 600,284 ms | 0 / 0 | 0 | 0 / 0 | failed / 0 | 0 / 0 / 0 | outer timeout |

Pi created no server module. It passed the CLI checks but did not reach the health behavior.

Neither agent resolved the oracle. Rupi finished 410,837 ms sooner, while Pi used 11,467 fewer
work tokens, so this run is inconclusive. The next prompt should target one signed batch HTTP path
after the health gate passes. PR #137 remains draft.

## Eleventh prompt iteration — complete; inconclusive

Run: `bench-20260930-case05-cli-health-admission-r11-grace6-cap8-pi0861-low-matched4-600s`.

R10 showed Rupi needed separate turns for CLI/test discovery and server health, leaving no turn to
complete HTTP behavior. R11 asks for an import-safe CLI, discoverable tests, and persistent
`/healthz` in the first focused slice. Recovery gates signed admission, validation/status, and
worker behavior on passing project tests and help checks. The all-case benchmark dry run and
`git diff --check` passed. CI for prompt commit `3ab603c` passed on Ubuntu, macOS, and Windows.
The matched run finished; PR #137 remains draft.

### Rupi result

Rupi remained unresolved after four timed-out turns, using 84,259 work tokens over 2,401,520 ms.
It used 47,899 input tokens, 36,360 output tokens, 22 started (21 completed) model requests, and
18 tool requests. Its oracle failed every turn. All help commands passed every turn; project test
discovery ran zero tests on turn 1, tests passed on turns 2–3, then failed on turn 4.

| Turn | Elapsed | In / out | Work | Req / tools | Oracle / tests | Help | Call |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,412 ms | 17,039 / 9,156 | 26,195 | 7 / 6 | failed / exit 5 | 0 / 0 / 0 | outer timeout |
| 2 | 600,412 ms | 4,464 / 10,503 | 14,967 | 5 / 4 | failed / 0 | 0 / 0 / 0 | outer timeout |
| 3 | 600,317 ms | 19,511 / 8,345 | 27,856 | 4 / 3 | failed / 0 | 0 / 0 / 0 | outer timeout |
| 4 | 600,379 ms | 6,885 / 8,356 | 15,241 | 6 / 5 | failed / exit 1 | 0 / 0 / 0 | outer timeout |

The final snapshot includes CLI, server, storage, admission, and signing modules, plus CLI and
server tests. It has no HTTP test module or worker. The turn-4 suite ran 17 tests with two failures
and three errors in the server health path; local diagnostics identify `RelayHandler.connection` as
a read-only property that conflicts with `BaseHTTPRequestHandler` setup.

### Pi result

Pi remained unresolved after four turns, using 41,193 work tokens over 2,149,483 ms. It used 8,761
input tokens, 32,432 output tokens, 12 model requests, and 18 tool requests. Its oracle failed every
turn. Project tests passed only on turn 4; all help commands passed on turns 2–4.

| Turn | Elapsed | In / out | Work | Req / tools | Oracle / tests | Help | Call |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,427 ms | 5,440 / 9,582 | 15,022 | 2 / 4 | failed / exit 1 | 1 / 1 / 1 | outer timeout |
| 2 | 600,231 ms | 1,154 / 11,416 | 12,570 | 2 / 5 | failed / exit 5 | 0 / 0 / 0 | outer timeout |
| 3 | 600,287 ms | 739 / 5,782 | 6,521 | 4 / 5 | failed / exit 1 | 0 / 0 / 0 | outer timeout |
| 4 | 348,538 ms | 1,428 / 5,652 | 7,080 | 4 / 4 | failed / 0 | 0 / 0 / 0 | complete |

Pi's final snapshot includes CLI, database, and server modules with CLI and server tests. It passed
the local suite and help checks on turn 4 but did not implement HTTP admission.

Neither agent resolved the oracle. Pi was 252,037 ms faster and used 43,066 fewer work tokens; both
made 18 tool requests. The run is inconclusive, with local health checks favoring Pi at the end.
Rupi reached admission code but broke its server health tests. The next prompt should fix the
handler initialization issue, keep health checks passing, then implement one signed POST path before
expanding to status, replay, validation, or worker behavior. PR #137 remains draft.

## Eleventh-run outcome

Case 05 remained open after R11's inconclusive comparison. Pi finished with passing local checks,
but neither agent resolved the oracle. R12 isolates the server handler's reserved socket attribute
and limits admission to one valid signed POST plus signature-failure behavior.

## Twelfth prompt iteration — complete; inconclusive

Run: `bench-20260930-case05-one-signed-post-handler-guard-r12-grace6-cap8-pi0861-low-matched4-600s`.

R11's turn-4 diagnostics showed that `RelayHandler.connection` conflicts with the socket property
managed by `BaseHTTPRequestHandler`. R12 carried that invariant into every Case 05 phase and
narrowed signed admission to one valid batch POST plus missing, malformed, and incorrect signature
behavior. Replay/conflict semantics, full validation, GET status, and worker behavior remained
gated. The all-case benchmark dry run and `git diff --check` passed. CI for prompt commit `3eb791a`
passed on Ubuntu, macOS, and Windows. PR #137 remains draft.

### Rupi result

Rupi remained unresolved after four harness turns, using 19,163 work tokens over 332,916 ms. It
used 13,900 input tokens, 5,263 output tokens, four model requests, and four tool requests. Turn 1
ended in `needs_reconciliation` after one tool failure; turns 2–4 had no model or tool activity.
Project tests and every help command exited 1 on all four turns, and the oracle failed every turn.

| Turn | ms | In / out | Work | Req/tools | Oracle/tests | Help | Result |
| ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 330,610 | 13,900/5,263 | 19,163 | 4/4 | fail/1 | 1/1/1 | needs reconciliation |
| 2 | 784 | 0/0 | 0 | 0/0 | fail/1 | 1/1/1 | no activity |
| 3 | 771 | 0/0 | 0 | 0/0 | fail/1 | 1/1/1 | no activity |
| 4 | 751 | 0/0 | 0 | 0/0 | fail/1 | 1/1/1 | no activity |

The final snapshot contains only `batchrelay/__init__.py`; it has no CLI or server module, so the
handler invariant was not exercised.

### Pi result

Pi remained unresolved after four turns, using 42,893 work tokens over 1,639,588 ms. It used 17,026
input tokens, 25,867 output tokens, 24 model requests, and 24 tool requests. Its oracle failed every
turn; project tests passed on turns 1, 2, and 4, and all help commands passed on every turn.

| Turn | Elapsed | In / out | Work | Req / tools | Oracle / tests | Help | Call |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,389 ms | 6,775 / 9,185 | 15,960 | 10 / 12 | failed / 0 | 0 / 0 / 0 | outer timeout |
| 2 | 600,271 ms | 6,444 / 9,734 | 16,178 | 6 / 6 | failed / 0 | 0 / 0 / 0 | outer timeout |
| 3 | 307,068 ms | 2,579 / 5,082 | 7,661 | 5 / 4 | failed / exit 1 | 0 / 0 / 0 | complete |
| 4 | 131,860 ms | 1,228 / 1,866 | 3,094 | 3 / 2 | failed / 0 | 0 / 0 / 0 | complete |

Pi added `tests/test_http.py` on turn 3 and passed project tests and help on turn 4. Neither agent
resolved the oracle. Rupi was 1,306,672 ms faster and used 23,730 fewer work tokens, but its tool
failure left all local checks failing and no runnable application. This run is inconclusive, with
Pi making substantially more functional progress. The next prompt should require a first workspace
write to a runnable source file and explicitly prohibit agent `exec` calls to avoid another
zero-activity recovery sequence. PR #137 remains draft.

## Twelfth-run outcome

Case 05 remained open after R12's inconclusive comparison. Pi reached passing local checks and an
HTTP test module but failed the oracle; Rupi did not recover from its first-turn tool failure.

## Thirteenth prompt iteration — complete; inconclusive

Run: `bench-20261001-case05-first-source-write-no-exec-r13-grace6-cap8-pi0861-low-matched4-600s`.

R13 required the first source write to create a runnable `batchrelay/__main__.py` before tests or
support modules, and explicitly prohibited `exec` and shell commands so the harness owned
verification. The all-case benchmark dry run and `git diff --check` passed. CI for prompt commit
`b3f5d1f` passed on Ubuntu, macOS, and Windows. PR #137 remains draft.

### Rupi result

Rupi remained unresolved after four turns, using 60,727 work tokens over 1,764,076 ms. It used
31,341 input tokens, 29,386 output tokens, 13 started (12 completed) model requests, and 13 tool
requests. Its oracle failed every turn; all help commands passed on every turn, and project tests
passed on turns 2–4. Turn 2 had one tool failure but completed normally, without calling `exec`.

| Turn | ms | In/out | Work | Req/tools | Oracle/tests | Help | Result |
| ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 406,785 | 13,949/7,121 | 21,070 | 3/2 | fail/1 | 0/0/0 | complete |
| 2 | 192,583 | 6,706/2,813 | 9,519 | 3/4 | fail/0 | 0/0/0 | complete |
| 3 | 564,472 | 6,789/10,455 | 17,244 | 4/4 | fail/0 | 0/0/0 | complete |
| 4 | 600,236 | 3,897/8,997 | 12,894 | 3/3 | fail/0 | 0/0/0 | outer timeout |

The final project includes the CLI, server, store, and signing modules with CLI and server tests.
It has no `tests/test_http.py` or worker.

### Pi result

Pi remained unresolved after four turns, using 45,012 work tokens over 2,115,074 ms. It used 11,863
input tokens, 33,149 output tokens, 27 model requests, and 26 tool requests. Its oracle failed every
turn; help passed every turn, and project tests passed on turns 1, 3, and 4.

| Turn | ms | In/out | Work | Req/tools | Oracle/tests | Help | Result |
| ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,223 | 5,720/8,609 | 14,329 | 10/10 | fail/0 | 0/0/0 | outer timeout |
| 2 | 600,223 | 1,924/10,512 | 12,436 | 6/6 | fail/1 | 0/0/0 | outer timeout |
| 3 | 314,344 | 2,287/5,155 | 7,442 | 6/5 | fail/0 | 0/0/0 | complete |
| 4 | 600,284 | 1,932/8,873 | 10,805 | 5/5 | fail/0 | 0/0/0 | outer timeout |

Pi's final snapshot includes `tests/test_http.py` but no worker. It passed project tests and help on
turn 4, but the oracle still failed.

Neither agent resolved the oracle. Rupi was 350,998 ms faster, while Pi used 15,715 fewer work
tokens and finished with an HTTP test module. This run is inconclusive: Rupi stabilized CLI and
health, but did not complete HTTP admission. The next prompt should focus on one tested signed POST
path while preserving the passing health slice. PR #137 remains draft.

## Thirteenth-run outcome

Case 05 remains open after R13's inconclusive comparison. Both agents passed local checks on some
turns, but neither resolved the oracle. Rupi still lacks an HTTP test module.

## Fourteenth prompt iteration — complete; inconclusive

Run: `bench-20261001-case05-signed-post-r14-grace6-cap8-pi0861-low-matched4-600s`.

R14 puts one signed `POST /batches` path in the initial runnable `batchrelay/__main__.py` alongside
CLI and health. It requires a valid one-job batch test and missing, malformed, and incorrect
signature tests that confirm no database mutation. Recovery keeps the same admission slice and
defers broad validation, idempotency, status, and worker behavior. The all-case dry run,
`git diff --check`, and changed-line length check passed. Prompt commit `eb4fa27` is pushed. PR CI
for head `685ea53` passed on Ubuntu, macOS, and Windows. PR #137 remains draft.

### Rupi result

Rupi remained unresolved after four turns, using 56,520 work tokens over 1,511,703 ms (30,814
input, 25,706 output), 18 model requests, and 14 tool requests with no tool failures. Project tests
and all three help commands passed on every turn; the oracle failed every turn.

| Turn | ms | In/out | Work | Req start/done | Tools | Tests | Oracle | Help | Call |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,260 | 17,376/9,807 | 27,183 | 6/5 | 5 | 0 | fail | 0/0/0 | timeout |
| 2 | 392,364 | 5,476/7,222 | 12,698 | 4/5 | 3 | 0 | fail | 0/0/0 | complete |
| 3 | 275,049 | 4,599/4,776 | 9,375 | 3/3 | 2 | 0 | fail | 0/0/0 | complete |
| 4 | 244,030 | 3,363/3,901 | 7,264 | 5/5 | 4 | 0 | fail | 0/0/0 | complete |

The final snapshot contains `batchrelay/__main__.py`, `batchrelay/server.py`, and CLI, server, and
HTTP tests. It has no worker module or worker test.

### Pi result

Pi remained unresolved after four outer timeouts, using 7,242 work tokens over 2,401,384 ms (6,899
input, 343 output), four model requests, and five tool requests. Project tests, all help commands,
and the oracle failed every turn. Its snapshots contain no application source or tests.

| Turn | ms | In/out | Work | Req start/done | Tools | Tests | Oracle | Help | Call |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 600,400 | 5,731/249 | 5,980 | 3/3 | 4 | 1 | fail | 1/1/1 | timeout |
| 2 | 600,463 | 0/0 | 0 | 0/0 | 0 | 1 | fail | 1/1/1 | timeout |
| 3 | 600,230 | 1,168/94 | 1,262 | 1/1 | 1 | 1 | fail | 1/1/1 | timeout |
| 4 | 600,291 | 0/0 | 0 | 0/0 | 0 | 1 | fail | 1/1/1 | timeout |

Rupi was 889,681 ms faster and finished with passing project tests, help, and an HTTP test module,
while Pi produced no application files. Rupi used 49,278 more work tokens. Neither agent resolved
the oracle, so R14 is inconclusive. R15 should target full batch validation and GET status while
preserving the passing health and signed-admission slices. PR #137 remains draft.

## Fourteenth-run outcome

Case 05 remains open after R14's inconclusive comparison. Rupi now passes local checks and has a
tested signed admission path, but the oracle still fails; Pi did not produce a project. R15 should
continue into validation and status without reopening health or admission.

## Fifteenth prompt iteration — pending

Run: `bench-20261001-case05-validation-status-r15-grace6-cap8-pi0861-low-matched4-600s`.

R15 keeps the initial R14 CLI, health, and signed-admission slice. Recovery advances to full batch
validation, idempotency/conflict behavior, and ordered `GET /batches` status while preserving the
passing health and admission behavior; worker work remains deferred. The all-case dry run,
`git diff --check`, and changed-line length check passed. Prompt commit `8c107d5` is pushed; the
matched run and CI are pending. PR #137 remains draft.

## Current outcome

R15's recovery prompt is committed and pushed. The matched run is pending; Case 05 remains open
based on R14's inconclusive result.
