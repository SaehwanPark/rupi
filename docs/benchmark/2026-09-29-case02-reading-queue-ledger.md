# Case 02 reading queue comparison ledger

This ledger records matched runs for the `02-reading-queue` case. The case gate
remains open until Rupi resolves the acceptance oracle against the pinned Pi
0.86.1 target.

## Case-specific-prompt matched run — `bench-20260929-case02-readqueue-low-matched4`

The run used Pi 0.86.1 from the isolated temporary prefix, low reasoning, four
300-second turns, an eight-request cap, and project-test/help feedback only.
Both saved initial prompts named the `readqueue` package and emphasized the
case's HTTP and SQLite contracts. The Case 02 prompts contained no Case 01
instructions. Recovery feedback contained no acceptance output.

Checks are project tests / oracle / `--help` / `serve --help`; `1` means the
command failed.

| Rupi turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 39,189 ms | 6,347 / 229 | read x2, exec x2 | 1 / 1 / 1 / 1 | needs reconciliation |
| 2 | 78 ms | 0 / 0 | none | 1 / 1 / 1 / 1 | needs reconciliation |
| 3 | 55 ms | 0 / 0 | none | 1 / 1 / 1 / 1 | needs reconciliation |
| 4 | 60 ms | 0 / 0 | none | 1 / 1 / 1 / 1 | needs reconciliation |

Rupi used 6,347 input and 229 output tokens (6,576 inference-work tokens). The
runtime ended turn 1 as `needs_reconciliation` after an `exec` command chaining
`python --version` with an inline `python -c` check failed with
`SyntaxError: unterminated string literal`. A following read was not executed
because the earlier mutating tool effect was unresolved. Turns 2–4 recorded no
model requests or tools. Rupi created no project source, README, or tests; the
oracle, help commands, and project test discovery all failed.

| Pi 0.86.1 turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,352 ms | 4,381 / 5,150 | read x3, bash x2, write x2 | 1 / 1 / 1 / 1 | timeout |
| 2 | 300,379 ms | 1,865 / 2,400 | bash, read x2, write | 1 / 1 / 1 / 1 | timeout |
| 3 | 300,253 ms | 765 / 3,065 | write x3, bash | 1 / 0 / 0 / 0 | timeout |

Pi used 7,011 input and 10,615 output tokens (17,626 inference-work tokens)
over 900,984 ms. It passed the oracle and both help commands in turn 3. It
created `readqueue/__init__.py`, `__main__.py`, `cli.py`, `server.py`,
`store.py`, and `validation.py`, but no README or project tests. Its project
test discovery failed in all turns because `tests/` was not created.

Pi won this matched comparison. Rupi's lower token count and short elapsed time
reflect its early reconciliation stop, not a successful implementation.

## Windows-command diagnostic retry — `bench-20260929-case02-argv-safe-low-matched4`

The retry used the same Pi 0.86.1 prefix, model, reasoning level, four 300-second
turns, eight-request cap, and project-test/help-only recovery feedback. Both
agents received Windows guidance to avoid inline Python and chained shell
commands. Recovery prompts did not include acceptance output or Case 01 task
guidance.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | End |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| 1 | 293,200 ms | 5,810 / 5,762 | 11,572 | 3 | 6 (4 ok, 2 failed) | needs reconciliation |
| 2 | 835 ms | 0 / 0 | 0 | 0 | 0 | needs reconciliation |
| 3 | 850 ms | 0 / 0 | 0 | 0 | 0 | needs reconciliation |
| 4 | 823 ms | 0 / 0 | 0 | 0 | 0 | needs reconciliation |

Rupi's first turn was unresolved after it tried to read a global skill file
outside the workspace, then ran `process python --version` through its shell
tool. The read was rejected as out of scope and `process` was not recognized as
a command. The runtime stopped with `needs_reconciliation`. Rupi made no project
source files, README, or tests; its project tests, oracle, and help checks all
failed. The four turn records total 295,708 ms; turns 2–4 had no model requests
or tool calls.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | End |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 300,244 ms | 4,122 / 278 | 4,400 | 3 | 4 | timeout |
| 2 | 300,216 ms | 754 / 96 | 850 | 1 | 1 | timeout |
| 3 | 300,269 ms | 1,893 / 6,255 | 8,148 | 2 | 3 | timeout |
| 4 | 300,216 ms | 826 / 4,540 | 5,366 | 3 | 5 | timeout |

Pi used 7,595 input and 11,169 output tokens (18,764 inference-work tokens)
over 1,200,945 ms. Neither agent passed the acceptance oracle or help checks.
Pi created `readqueue/__init__.py`, `errors.py`, `service.py`, and `store.py`,
but no README or tests. Both project test-discovery checks failed because no
`tests/` directory existed. This diagnostic retry is inconclusive and does not
change the earlier matched Pi win; Case 02 remains open.

The retry exposed ambiguity in "direct process invocation": Rupi interpreted
`process` as a shell prefix even though no process tool was listed. The next
prompt clarified that only listed process tools should be used, with direct
shell/exec calls as the fallback. The following retry tests that clarification
and adds an entrypoint-first implementation order.

## Explicit-tool diagnostic retry — `bench-20260929-case02-tool-listed-low-matched4`

This matched run used the same Pi 0.86.1 prefix, model, low reasoning, four
300-second turns, eight-request cap, and project-test/help-only feedback.
Initial and recovery prompts both had the clarified process-tool fallback,
prohibited inline Python and command chaining, and kept recovery output free of
oracle results and Case 01 instructions.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Outcome |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 300,293 ms | 6,946 / 4,700 | 11,646 | 5 | 7 succeeded | timeout |
| 2 | 300,244 ms | 1,417 / 4,208 | 5,625 | 3 | 1 ok, 1 failed | timeout |
| 3 | 271,540 ms | 0 / 0 | 0 | 1 timed out | 0 | provider timeout |
| 4 | 272,062 ms | 0 / 0 | 0 | 1 timed out | 0 | provider timeout |

Rupi used 17,271 inference-work tokens over 1,144,139 ms. It invoked
`python --version & python -c "print(1)"` despite the prompt's single-command
and no-inline-source guidance; the tool call succeeded. It then wrote only
`readqueue/__init__.py` and `readqueue/__main__.py`. A later read of the Python
installation's `unittest/loader.py` was rejected as outside the workspace.
Turns 3 and 4 ended after provider timeouts with no output tokens or tools.
Project tests, oracle, and both help checks failed; no README or tests were
created.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Outcome |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 300,239 ms | 4,161 / 280 | 4,441 | 3 | 4 | timeout |
| 2 | 300,227 ms | 0 / 0 | 0 | 0 | 0 | timeout |
| 3 | 300,206 ms | 793 / 5,839 | 6,632 | 1 | 1 | timeout |
| 4 | 300,307 ms | 1,301 / 4,576 | 5,877 | 5 | 6 | timeout |

Pi used 16,950 inference-work tokens over 1,200,979 ms. It created
`readqueue/__init__.py`, `store.py`, and `validation.py`, but no README or tests.
Neither agent passed the oracle or help checks, and both failed project test
discovery. Rupi was 56.8 seconds faster but used 321 more work tokens; this is
an inconclusive retry, not a Case 02 win.

The next prompt will keep the service implementation in
`readqueue/__main__.py` until the routes, persistence, and help commands work,
then add README and tests. It will prohibit all shell chaining characters
(`&`, `&&`, `;`, and `|`), inline Python, and reads outside the project; one
executable will run per command-tool call. Case 02 remains open.

## Entrypoint-first matched retry — `bench-20260929-case02-entrypoint-first-low-matched4`

This run used the isolated Pi 0.86.1 prefix, low reasoning, four 300-second
turns, eight requests per turn, and project-test/help-only recovery feedback.
Both agents received the single-file `readqueue/__main__.py` order and the
stricter Windows command and workspace rules. Recovery prompts contained no
acceptance output or Case 01 guidance.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 300,322 ms | 5,459 / 163 | 5,622 | 4 (3 completed) | 4 | outer timeout |
| 2 | 279,563 ms | 820 / 52 | 872 | 2 | 1 | provider timeout |
| 3 | 271,850 ms | 0 / 0 | 0 | 1 timed out | 0 | provider timeout |
| 4 | 272,669 ms | 0 / 0 | 0 | 1 timed out | 0 | provider timeout |

Rupi used 6,494 inference-work tokens over 1,124,404 ms and created no project
source, README, or tests. Its first turn followed the one-command rule and ran
`python --version` by itself, but timed out before writing. The next turn's
local help feedback reported that `readqueue` did not exist. Turns 2–4 ended
with provider timeouts; the trace shows the configured 270,000 ms request
deadline. Rupi's project tests, oracle, and both help checks failed in all four
turns.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 300,215 ms | 4,259 / 319 | 4,578 | 3 | 3 | timeout |
| 2 | 300,218 ms | 882 / 4,347 | 5,229 | 2 | 2 | timeout |
| 3 | 300,243 ms | 1,148 / 5,410 | 6,558 | 5 | 5 | timeout; oracle passed |

Pi used 16,365 inference-work tokens over 900,676 ms. It passed the acceptance
oracle and both help checks in turn 3; project test discovery failed because
there was no `tests/` directory. It created `readqueue/__init__.py`,
`readqueue/__main__.py`, and `readqueue/validation.py`, but no README or tests.
Pi won this matched run. Case 02 remains open.

The 270-second provider deadline ended Rupi's last three active requests before
it produced source. The next matched diagnostic will use 600-second turns and
the corresponding 570-second Rupi request deadline, leaving reasoning level,
prompt, request cap, and pinned Pi version unchanged.

## Extended entrypoint-first retry — `bench-20260929-case02-entrypoint-first-low-matched4-600s`

This matched run preserved the previous entrypoint-first prompt, Pi 0.86.1,
low reasoning, the eight-request cap, and project-test/help-only recovery
feedback. Both agents received four turns of up to 600 seconds; Rupi's provider
deadline was 570 seconds. The initial and recovery prompts still contained no
acceptance-oracle output.

| Rupi turn | Elapsed | Input / output | Work tokens | Tools | Result |
| --- | ---: | ---: | ---: | --- | --- |
| 1 | 600,273 ms | 5,937 / 4,248 | 10,185 | 5 succeeded | timeout |
| 2 | 600,256 ms | 2,969 / 9,718 | 12,687 | 2 succeeded | timeout |
| 3 | 263,067 ms | 1,574 / 5,055 | 6,629 | 3 succeeded, 1 failed | needs reconciliation |
| 4 | 2,683 ms | 0 / 0 | 0 | none | needs reconciliation |

Rupi used 29,501 inference-work tokens over 1,466,279 ms. It created
`readqueue/__init__.py` and `readqueue/__main__.py`. Its help commands passed
in turns 3 and 4, but the acceptance oracle returned HTTP 500 and project test
discovery failed because there was no `tests/` directory. The final entrypoint
defines `Store._session`, while its CRUD methods still call the missing
`Store._connect`; that leaves the POST handler failing. During turn 3, Rupi's
`findstr` exec call failed after the storage edit, leaving the session in
`needs_reconciliation`. Turn 4 made no model request.

| Pi turn | Elapsed | Input / output | Work tokens | Tools | Result |
| --- | ---: | ---: | ---: | --- | --- |
| 1 | 600,210 ms | 4,559 / 12,238 | 16,797 | 5 succeeded | timeout |
| 2 | 600,249 ms | 2,101 / 6,099 | 8,200 | 7 succeeded | timeout; resolved |

Pi used 24,997 inference-work tokens over 1,200,459 ms. It passed the
acceptance oracle and both help commands in turn 2, so the harness marked the
case resolved despite that turn reaching its outer timeout. Project test
discovery returned exit code 5 because no tests were found. The generated
project included `readqueue/__init__.py`, `readqueue/__main__.py`,
`scripts/smoke.py`, and `tests/__init__.py`, but no README or test module.

Pi won this matched run by using 4,504 fewer work tokens and finishing 265,820
ms sooner under the oracle/help resolution criteria. The generated Pi project
still missed the requested README and discoverable tests. Case 02 remains open.
The next bounded diagnostic should focus on Rupi's failed storage-helper edit
and safe source inspection, then use a matched run before recording any Rupi
win.

## Read-tool and recovery-guidance retry — `bench-20260929-case02-read-tool-low-matched4-600s`

This matched run preserved the Pi 0.86.1 target, low reasoning, four 600-second
turns, eight requests per turn, and project-test/help-only recovery feedback.
The shared prompt now directs source inspection through `read`, repeats
case-specific guidance during recovery, asks for consistent SQLite helper
call sites, and requests an HTTP POST-to-GET smoke check.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,264 ms | 10,394 / 10,735 | 21,129 | 8 | 7 | outer timeout |
| 2 | 568,820 ms | 12,720 / 10,044 | 22,764 | 6 | 5 | completed |
| 3 | 485,582 ms | 34,813 / 6,927 | 41,740 | 8 | 9 | budget exhausted |
| 4 | 462,750 ms | 13,074 / 6,427 | 19,501 | 8 | 8 | budget exhausted |

Rupi used 105,134 inference-work tokens over 2,117,416 ms, with no failed tool
calls. It created `readqueue/__init__.py`, `readqueue/__main__.py`, and
`tests/helpers.py`, but no README or test module. Both help commands passed in
all turns; the oracle and project tests did not. Test discovery returned exit
code 5 in turn 4.

The turn-2 oracle failure reported HTTP 500 for POST. In turn 3, Rupi changed
the handler to read the request body before routing, but its reader still uses
`self.r.read(...)`; this makes `/healthz` fail with HTTP 500 as well. The
standard handler input stream is `self.rfile`. Rupi spent 41,740 work tokens in
turn 3 and 19,501 in turn 4 without correcting that call.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,222 ms | 4,597 / 10,786 | 15,383 | 4 | 4 | outer timeout |
| 2 | 600,233 ms | 2,945 / 10,091 | 13,036 | 11 | 11 | timeout; resolved |

Pi used 28,419 inference-work tokens over 1,200,455 ms. It passed the oracle
and both help commands in turn 2, so the harness marked the case resolved
despite the outer timeout. Project test discovery returned exit code 5. Pi
created `readqueue/__init__.py`, `readqueue/__main__.py`, `tests/server_harness.py`,
and `smoke_check.py`, but no README or test module.

Pi won this matched run by using 76,715 fewer work tokens and finishing
916,961 ms sooner under the oracle/help criteria. Neither generated project
met the prompt's README and discoverable-test requirements. Case 02 remains
open. The next matched retry should make the `BaseHTTPRequestHandler.rfile`
contract explicit and verify `GET /healthz` before the POST/GET smoke sequence.

## Explicit request-stream and health-first retry

Run: `bench-20260929-case02-rfile-health-first-low-matched4-600s`.

This matched run used Pi 0.86.1, low reasoning, four turns, 600-second turn
timeouts, and project-test/help recovery feedback. The prompt explicitly named
`BaseHTTPRequestHandler.rfile` and asked for `GET /healthz` before POST/GET
smoke checks.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,254 ms | 6,426 / 7,415 | 13,841 | 4 | 5 | outer timeout |
| 2 | 541,148 ms | 21,333 / 9,576 | 30,909 | 8 | 7 | budget exhausted |
| 3 | 141,345 ms | 5,493 / 2,035 | 7,528 | 3 | 3 | reconciliation; one tool failed |
| 4 | 1,859 ms | 0 / 0 | 0 | 0 | 0 | reconciliation; no work |

Rupi used 52,278 inference-work tokens over 1,284,606 ms. Help passed in turns
2 through 4, but the oracle failed on `PATCH /items/1`: the server closed the
connection without a response. Project test discovery failed because no
importable `tests/` directory existed. Rupi created `readqueue/__init__.py`,
`readqueue/__main__.py`, and `smoke_check.py`, but no README or tests.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,157 ms | 8,621 / 11,586 | 20,207 | 12 | 17 | outer timeout; resolved |

Pi used 20,207 inference-work tokens over 600,157 ms. It passed the oracle, all
34 project unittests, and both help commands before the outer timeout. It
created three test modules but no README. Pi won this matched run using 32,071
fewer work tokens and 684,449 ms less elapsed time. Case 02 remains open. The
next retry should smoke-test a valid PATCH followed by GET readback, and keep
server diagnostics visible if a request disconnects.

## PATCH-readback matched retry

Run: `bench-20260929-case02-patch-readback-low-matched4-600s`.

This matched retry kept low reasoning, four turns, 600-second turn timeouts,
and project-test/help recovery feedback. The prompt added valid and invalid
PATCH checks, GET readback, visible server diagnostics, and README sequencing.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,334 ms | 5,421 / 7,519 | 12,940 | 5 | 4 | outer timeout; oracle failed |
| 2 | 600,371 ms | 9,897 / 9,520 | 19,417 | 6 | 5 | outer timeout; resolved |

Rupi used 32,357 inference-work tokens over 1,200,705 ms. It passed the
oracle and both help commands in turn 2. Turn 1's oracle check reported that
the service exited with code 0 and no output. Test discovery failed in both
turns because no importable `tests/` directory existed. Rupi created only
`readqueue/__main__.py`; it created no README or tests.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,254 ms | 4,498 / 12,619 | 17,117 | 5 | 8 | outer timeout; resolved |

Pi passed the oracle and both help commands in turn 1. Test discovery also
failed, and Pi created `readqueue/__init__.py` and `readqueue/__main__.py` but
no README or tests. Both agents resolved only the oracle/help criteria before
the outer timeout. Pi won this retry using 15,240 fewer work tokens and
600,451 ms less elapsed time. Case 02 remains open. The next diagnostic should
check that the module entry point starts and keeps the service running before
route smoke checks begin.

## Module-startup diagnostic retry

Run: `bench-20260929-case02-entrypoint-check-low-matched4-600s`.

This retry kept the prior matched settings and added an explicit
`__main__`-guard and live-server check before route smoke tests.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,591 ms | 5,413 / 3,983 | 9,396 | 4 | 3 | outer timeout; no package |
| 2 | 571,830 ms | 0 / 0 | 0 | 1 | 0 | provider timeout |
| 3 | 14,480 ms | 1,252 / 57 | 1,309 | 1 | 1 | reconciliation; tool failed |
| 4 | 3,416 ms | 0 / 0 | 0 | 0 | 0 | reconciliation; no work |

Rupi used 10,705 inference-work tokens over 1,190,317 ms and did not resolve.
The first two turns produced no `readqueue` package; turn 2 timed out at the
570-second provider deadline. Turn 3 tried `dir /s /b`, which failed as a
shell command and left an unresolved mutating tool. Help and test discovery
failed in every verified turn.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,302 ms | 4,770 / 12,332 | 17,102 | 5 | 5 | outer timeout; resolved |

Pi passed oracle and help in turn 1, though project test discovery failed.
It created `readqueue/__init__.py` and `readqueue/__main__.py`, but no README
or tests. Rupi used 6,397 fewer work tokens, but remained unresolved and took
590,015 ms longer. Pi won this comparison. Case 02 remains open; proceed to
Case 03 and retain the Case 02 findings for later prompt work.
