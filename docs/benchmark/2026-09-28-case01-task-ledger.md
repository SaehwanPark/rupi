# Case 01: Task Ledger — Pi comparison slice

Status: in progress
Branch: `bench/case01-rupi-over-pi`
Target model: local llama.cpp `qwen3.8-flash-next` (UD-IQ4_XS)

## Scope and gate

This slice evaluates and improves only `01-task-ledger`. It compares the current
`rupi` build with Pi 0.86.1 using `bench/compare-pi-rupi.ps1`, clean isolated
workspaces, the same model endpoint, the same two-turn limit, and the unchanged
fresh-process acceptance oracle. Keep the generated workspaces and raw traces in
ignored `.benchmark/` storage.

The case is resolved only when the independent acceptance oracle exits zero.
The slice is a `rupi` win if it resolves in fewer turns than Pi, or if both resolve
in the same turn and `rupi` uses fewer measured inference-work tokens and no more
agent wall time. A single local-model run is empirical evidence for this case,
not a general claim about all models or environments.

## Prior evidence

The original matched run, `bench-20260920-01-05`, recorded two unsuccessful
turns for each client on this case. `rupi` and Pi both ended with oracle exit code
1; the raw inputs, outputs, traces, snapshots, and verification logs remain under
the local ignored benchmark run directory. The broader original benchmark also
recorded 0/10 resolved cases for each client. Those results predate the current
runtime and must be treated as historical baseline only.

## Current matched run

- Run ID: `bench-20260928-case01-main`
- Command: `pwsh -NoProfile -File bench/compare-pi-rupi.ps1 -RunId
  bench-20260928-case01-main -CaseId 01-task-ledger -Agent all -MaxTurns 2
  -TurnTimeoutSeconds 300 -MaxModelRequestsPerTurn 8`
- Server: llama.cpp `0.4.0-dev` build `10909`, `qwen3.8-flash-next`, 262,144
  context, `xhigh` server default; both clients request `low` thinking.
- Current build: merged `main` at PR #132 (`6e8a1e6`).

| Agent / turn | Result | Requests | Input / output tokens | Tools | Project / oracle |
| --- | --- | ---: | ---: | ---: | --- |
| `rupi` 1 | timeout, 300,311 ms; no generated files | 4 started, 3 completed | 6,683 / 4,901 | 5, all completed | 1 / 1 |
| `rupi` 2 | timeout, 300,321 ms; no generated files | 2 completed | 149 / 107 | 1, completed | 1 / 1 |
| Pi 1 | timeout, 300,330 ms; wrote three package files | 5 | 3,740 / 4,603 | 5 | 1 / 1 |
| Pi 2 | timeout, 300,310 ms; wrote the package, README, and test initializer | 8 | 954 / 4,682 | 8 | 5 / 1 |

Both agents' project/oracle failures after the first turn establish that the
initial attempt is incomplete. Both remained unresolved after the full two-turn
budget. `rupi` used 6,832 input and 5,008 output tokens over 600,632 ms; all six
tool calls completed without a tool failure, but none wrote project files. Pi
used 4,694 input and 9,285 output tokens over 600,640 ms and created the package
modules, README, and an empty test initializer; its second project test command
exited 5 (no tests discovered), and its acceptance oracle still failed. This is
more visible implementation progress for Pi, but not a resolved case.

## Prompt iteration v1 (reverted)

A temporary `src/run.rs` prompt change asked new-project implementation tasks to
create a runnable end-to-end slice after reading the governing specification.
`cargo fmt --all --check` and `cargo build --bin rupi` passed with that change,
but it did not produce an early write or improve the oracle result. The change
was reverted; the final branch keeps the existing general prompt.

Post-change run ID: `bench-20260928-case01-prompt-v1`. Both turns timed out;
neither created project files, and both oracle checks exited 1. Turn 1 timed out
at 300,632 ms after 5 model requests and 5 successful tools. Turn 2 timed out at
300,247 ms before a request completed or any tool ran. The llama.cpp log shows
generation was active until the client timeout cancelled it, and the endpoint
remained healthy. The prompt-only change did not improve resolution or produce
an early write; the prompt change has been removed.

## Progress-boundary iteration v1

The Case 01 `rupi.config.json` now opts into the existing progress boundary:
after one tool-bearing request without a successful change, the next request is
restricted to `write` and `edit`. The runtime's enforced tool choice and effect
evidence still determine whether progress occurred. This configuration keeps the
behavior scoped to this coding case.

Run ID: `bench-20260928-case01-progress-v1`. The Rupi-only run used the same
two-turn, 300-second protocol as the matched baseline:

| Turn | Result | Requests | Input / output tokens | Tools | Project / oracle |
| --- | --- | ---: | ---: | ---: | --- |
| 1 | timeout, 300,552 ms | 4 started, 3 completed | 11,182 / 4,950 | 1 `read`, 4 `write` | 1 / 1 |
| 2 | timeout, 300,323 ms | 4 completed | 18,121 / 2,571 | `exec`, `read`, 2 `write`, 2 `edit` | 5 / 1 |

The first write occurred after the runtime injected the boundary, and both turns
completed all tool calls without a tool failure. Rupi used 29,303 input and
7,521 output tokens, 36,824 inference-work tokens, and 600,875 ms total. It
created `tasklog/{__init__,__main__,cli,ledger}.py`, `README.md`, and
`tests/helpers.py`, but no `test_*.py` file. The second project test command
reported `Ran 0 tests` (exit 5); the oracle failed both after turn 1 and turn 2.
Two representative oracle mismatches were the empty-list text (`No matching
open tasks.` rather than the required `No open tasks`) and the invalid-ID text
(`not a valid id` rather than containing `invalid id`).

This demonstrates better early file progress, but no oracle resolution. The
matched Pi baseline remained unresolved after two turns and produced more
implementation files, so Case 01 is not a `rupi` win. Keep the boundary
configuration at one request for the next iteration, which needs to carry the
work through tests and fresh-process acceptance.

## Progress-boundary iteration v2

The first boundary request was triggered after the initial spec read. That made
Rupi write implementation files earlier, but its two-turn run still ended with
no project test modules. The exploratory v2 variant raised the inspection
allowance to two model requests before requiring a write. It used the same
two-turn, 300-second Rupi-only budget.

Run ID: `bench-20260928-case01-progress-v2`.

| Turn | Result | Requests | Input / output tokens | Tools | Project / oracle |
| --- | --- | ---: | ---: | --- | --- |
| 1 | timeout, 300,359 ms | 3 started, 2 completed | 4,509 / 122 | `read`, failed `exec`, `read` | 1 / 1 |
| 2 | timeout, 300,341 ms | 1 abandoned, no usage | 0 / 0 | none | 1 / 1 |

Rupi used 4,631 inference-work tokens over 600,700 ms and created no
implementation files. The first turn completed a `read`, a failed `exec`, and a
second `read`; its third model request hit the time limit before producing tools.
The second turn was cancelled before producing output or tools. This is worse
than v1, which created source and a README under the same budget.
The case configuration is restored to one request before the boundary; the v2
setting is discarded. No matched Pi run is warranted because the oracle
remained unresolved.

## Matched recovery comparison: `bench-20260928-case01-progress-v1-matched3`

This matched run gave both clients three turns of 300 seconds each with the
one-request progress boundary enabled for Rupi. The server's global reasoning
effort was `xhigh`; both clients requested `low`.

| Agent / turn | Result | Requests | Input / output tokens | Tools | Project / oracle / help |
| --- | --- | ---: | ---: | --- | --- |
| `rupi` 1 | timeout, 300,775 ms | 2 started, 1 completed | 3,275 / 41 | `read` | 1 / 1 / 1 |
| `rupi` 2 | timeout, 300,377 ms | 3 / 3 | 3,143 / 1,326 | `exec`, 2 `write` | 1 / 1 / 1 |
| `rupi` 3 | timeout, 300,363 ms | 1 / 1, abandoned | 0 / 0 | none | 1 / 1 / 1 |
| Pi 1 | timeout, 300,373 ms | 3 / 3 | 3,694 / 146 | `read`, 2 `bash` | 1 / 1 / 1 |
| Pi 2 | timeout, 300,367 ms | 1 / 1 | 149 / 141 | `bash` | 1 / 1 / 1 |
| Pi 3 | timeout, 300,363 ms | 0 / 0 | 0 / 0 | none | 1 / 1 / 1 |

Neither client created a project that passed tests or the fresh-process oracle.
Rupi used 6,418 input and 1,367 output tokens (7,785 inference-work tokens)
over 901,515 ms. Pi used 3,843 input and 287 output tokens (4,130
inference-work tokens) over 901,103 ms. The equal-turn result is not a Rupi win:
both remain unresolved, and Rupi used more measured inference work. Keep the
Case 01 slice open.

## Matched low-default comparison: `bench-20260928-case01-progress-v1-low`

The two-turn run kept the one-request progress boundary. The llama.cpp server
used `--reasoning-effort low`; both clients also requested `low`.

| Agent / turn | Result | Requests | Input / output tokens | Tools | Project / oracle / help |
| --- | --- | ---: | ---: | --- | --- |
| `rupi` 1 | timeout, 300,333 ms | 2 started, 1 completed | 3,273 / 41 | `read` | 1 / 1 / 1 |
| `rupi` 2 | timeout, 300,336 ms | 2 / 2 | 1,445 / 48 | `exec` | 1 / 1 / 1 |
| Pi 1 | timeout, 300,381 ms | 5 / 5 | 3,492 / 5,891 | `read`, 2 `ls`, 2 `write` | 1 / 1 / 1 |
| Pi 2 | timeout, 300,352 ms | 7 / 7 | 490 / 5,265 | 2 `read`, `find`, `ls`, 4 `write` | 5 / 1 / 0 |

Rupi created no project files and used 4,718 input and 89 output tokens (4,807
inference-work tokens) over 600,669 ms. Pi created package modules, README, and
an empty test initializer; its second project test discovery exited 5 because
there were no test cases. Pi used 3,982 input and 11,156 output tokens (15,138
inference-work tokens) over 600,733 ms. Neither agent passed the oracle. The
global `low` setting increased Pi's implementation activity but did not change
Rupi's one-read/one-exec behavior, so Case 01 remains unresolved and is not a
Rupi win.

## Write-only progress boundary

The Case 01 config restricts the progress allowlist from `write` and `edit` to
`write` only. The exploratory Rupi-only run used the same low-default, two-turn
budget.

Run ID: `bench-20260928-case01-write-only-low`.

| Turn | Result | Requests | Input / output tokens | Tools | Project / oracle / help |
| --- | --- | ---: | ---: | --- | --- |
| 1 | timeout, 300,374 ms | 3 started, 2 completed | 6,854 / 4,838 | `read`, 3 `write` | 1 / 1 / 1 |
| 2 | timeout, 300,276 ms | 3 / 3 | 7,091 / 2,370 | `exec`, `read`, 2 `write` | 1 / 1 / 0 |

Rupi used 13,945 input and 7,208 output tokens (21,153 inference-work tokens)
over 600,650 ms. It created `tasklog/{__init__,__main__,cli,ledger,storage}.py`
but no README or `tests/` directory. The turn-two `--help` check passed, but
project test discovery failed because `tests/` was absent. The acceptance oracle
reported that `add` rejected multiword task text as extra arguments, and the
empty-ledger output did not contain the required `No open tasks` text. This is
earlier implementation progress than the `write`/`edit` configuration, but it
does not resolve Case 01.

## Three-turn write-only exploration: `bench-20260928-case01-write-only-low3`

This fresh Rupi-only run used the same write-only boundary and low server
default, with three 300-second turns.

| Turn | Result | Requests | Input / output tokens | Tools | Project / oracle / help |
| --- | --- | ---: | ---: | --- | --- |
| 1 | timeout, 300,208 ms | 4 started, 3 completed | 8,558 / 5,615 | `read`, 2 `write` | 1 / 1 / 1 |
| 2 | timeout, 300,401 ms | 8 / 8 | 14,394 / 4,005 | `exec`, `read`, 3 `edit`, 3 `write` | 5 / 1 / 0 |
| 3 | timeout, 300,171 ms | 4 started, 5 completion records | 13,488 / 4,322 | `read`, 2 `write`, 2 `exec` | 1 / 1 / 0 |

Rupi used 36,440 input and 13,942 output tokens (50,382 inference-work tokens)
over 900,780 ms. It created `tests/test_cli.py` and `tests/test_ledger.py` by
turn 3; 39 tests ran and 8 failed. Test discovery had reported no tests in turn
2. The oracle still failed: multiword `add` input was rejected, and the empty
ledger printed `No matching tasks.` rather than containing `No open tasks`.
`--help` passed in turns 2 and 3.

Turn 3 ended in `needs_reconciliation` after an `exec` result remained an
unresolved mutating side effect. The runtime stopped the session instead of
replaying it. Case 01 remains unresolved and this is not a Rupi win.

## Matched three-turn write-only comparison: `bench-20260928-case01-write-only-low-matched3`

Both clients received up to three 300-second turns under the low server
default, with fresh-process verification after each. Rupi used the write-only
progress boundary. All six turns timed out at approximately 300 seconds.

| Agent / turn | Requests | Input / output | Tools | Project / oracle / help |
| --- | ---: | ---: | --- | --- |
| Rupi 1 | 2 started, 1 completed | 3,275 / 41 | `read` | 1 / 1 / 1 |
| Rupi 2 | 3 / 3 | 4,387 / 4,227 | `exec`, `read`, 3 `write` | 1 / 1 / 1 |
| Rupi 3 | 3 / 3 | 1,805 / 5,321 | 2 `write` | 1 / 1 / 1 |
| Pi 1 | 5 / 5 | 3,753 / 5,854 | `read`, 2 `bash`, 3 `write` | 1 / 1 / 1 |
| Pi 2 | 8 / 8 | 569 / 6,138 | `bash`, `write`, 2 `edit`, `write`, 3 `bash` | 1 / 1 / 0 |
| Pi 3 | 5 / 5 | 751 / 4,206 | `read`, 2 `write`, 2 `edit` | 5 / 1 / 0 |

Rupi used 9,467 input and 9,589 output tokens (19,056 inference-work tokens)
over 900,722 ms. Pi used 5,073 input and 16,198 output tokens (21,271
inference-work tokens) over 900,685 ms. Rupi used 10.4% fewer inference-work
tokens, but both remain unresolved, so Case 01 has no winner. Rupi's project test discovery
failed because it never wrote `tasklog/__main__.py` or a `tests/` package. Its
oracle's three failures all came from `python -m tasklog` being unavailable.
Pi wrote a runnable module and a test helper, but no test cases; its project
test command therefore exited 5. Its oracle still failed because multiword task
text was parsed as extra arguments. Rupi's `--help` check failed on every turn;
Pi's passed on turns 2 and 3.

Keep the Case 01 slice open. The recurring acceptance gaps are now concrete:
the package entry point and test package are missing from Rupi's output, and
multiword descriptions remain unhandled by Pi. The next iteration should
target a verified Rupi behavior change before another matched comparison.

## Matched five-turn recovery-depth diagnostic: `bench-20260928-case01-write-only-low-matched5`

This run held the low server default, write-only Rupi boundary, prompts, and
300-second timeout constant, extending both agents from three to five turns.
Project, oracle, and help columns contain exit codes in that order.

| Agent / turn | Elapsed | Requests | Input / output | Project / oracle / help |
| --- | ---: | ---: | ---: | ---: |
| Rupi 1 | 300,262 ms | 3 / 2 | 6,860 / 3,519 | 1 / 1 / 1 |
| Rupi 2 | 13,667 ms | 1 / 2 | 149 / 179 | 1 / 1 / 1 |
| Rupi 3 | 854 ms | 0 / 0 | 0 / 0 | 1 / 1 / 1 |
| Rupi 4 | 854 ms | 0 / 0 | 0 / 0 | 1 / 1 / 1 |
| Rupi 5 | 846 ms | 0 / 0 | 0 / 0 | 1 / 1 / 1 |
| Pi 1 | 300,250 ms | 4 / 4 | 3,525 / 5,948 | 1 / 1 / 1 |
| Pi 2 | 300,292 ms | 6 / 6 | 821 / 5,950 | 1 / 1 / 0 |
| Pi 3 | 300,225 ms | 4 / 4 | 225 / 5,717 | 0 / 1 / 0 |
| Pi 4 | 300,253 ms | 6 / 6 | 2,127 / 4,400 | 0 / 1 / 0 |
| Pi 5 | 300,230 ms | 3 / 3 | 1,905 / 4,844 | 1 / 1 / 0 |

Rupi used 7,009 input and 3,698 output tokens (10,707 inference-work tokens)
over 316,483 ms. It wrote two files in turn 1. In turn 2, it prefixed a shell
command with `cmd.exe /C`; that command failed, and the following read in the
same batch was deferred. The runtime stopped with `needs_reconciliation` because
the `exec` effect remained unresolved. Turns 3–5 made no model requests.

Pi used 8,603 input and 26,859 output tokens (35,462 inference-work tokens)
over 1,501,250 ms. Its project tests passed in turns 3 and 4, then failed in
turn 5. The fresh-process oracle failed in every turn, so five turns gave
neither client a win. The result narrows the next runtime experiment to clearer
Windows `exec` guidance: `exec` already chooses `cmd.exe /C`, so a command must
not include that shell prefix. Preserve the unresolved-effect stop and measure
the guidance change in a fresh matched comparison.

## Matched shell-guidance comparison: `bench-20260928-case01-exec-guidance-low-matched3`

This matched three-turn run used the tool descriptions from commit `268a24f`.
The low server default, write-only Rupi boundary, prompts, and 300-second turn
timeout stayed fixed.

| Agent / turn | Requests | Input / output | Project / oracle / help |
| --- | ---: | ---: | ---: |
| Rupi 1 | 4 / 3 | 9,930 / 4,590 | 1 / 1 / 1 |
| Rupi 2 | 4 / 4 | 10,514 / 4,234 | 0 / 1 / 0 |
| Rupi 3 | 3 / 3 | 3,896 / 5,667 | 1 / 1 / 0 |
| Pi 1 | 5 / 5 | 3,574 / 6,219 | 1 / 1 / 1 |
| Pi 2 | 4 / 4 | 537 / 5,127 | 1 / 1 / 1 |
| Pi 3 | 7 / 7 | 1,554 / 5,141 | 1 / 1 / 0 |

Rupi used 24,340 input and 14,491 output tokens (38,831 inference-work tokens)
over 901,040 ms. Pi used 5,665 input and 16,487 output tokens (22,152
inference-work tokens) over 900,699 ms. Rupi's turn-two project tests and help
passed; Pi's project tests failed in all three turns. Rupi then regressed its
project tests in turn three. Both agents failed the fresh-process oracle in all
turns, so this is not a Case 01 win.

Rupi's turn-two `exec` was followed by four writes with no tool failure,
unknown-effect record, or `needs_reconciliation` status. This confirms useful
progress from the clearer shell guidance while preserving effect safety. The
oracle rejected multiword `add` text, and `SPEC.md` did not say whether
unquoted trailing words form one description. Commit `4609c94` added that
contract; the matched run below used the updated spec and left the oracle intact.

## Matched explicit-text spec comparison: `bench-20260928-case01-multiword-spec-low-matched3`

This run used the clarified shared `add TEXT` contract from commit `4609c94`.
The model, low server default, prompts, write-only Rupi boundary, and three
300-second turns stayed fixed.

| Agent / turn | Requests | Input / output | Project / oracle / help |
| --- | ---: | ---: | ---: |
| Rupi 1 | 2 / 1 | 3,335 / 41 | 1 / 1 / 1 |
| Rupi 2 | 1 / 1 | 0 / 0 | 1 / 1 / 1 |
| Rupi 3 | 3 / 3 | 2,029 / 3,811 | 1 / 1 / 1 |
| Pi 1 | 5 / 5 | 3,800 / 5,513 | 1 / 1 / 1 |
| Pi 2 | 4 / 4 | 876 / 5,041 | 1 / 1 / 1 |
| Pi 3 | 5 / 5 | 1,447 / 4,610 | 1 / 1 / 0 |

Rupi used 5,364 input and 3,852 output tokens (9,216 inference-work tokens)
over 900,732 ms. It read in turn 1, produced no output or tools in turn 2, and
used `exec` plus two writes in turn 3. Project test discovery still failed
because no `tests/` package was created. Pi used 6,123 input and 15,164 output
tokens (21,287 inference-work tokens) over 900,848 ms. Neither client created a
project test package or passed the oracle in any turn; the clarified text
requirement did not produce a Case 01 win.

The run config showed Rupi's provider `request_timeout_ms` at 600,000 while the
benchmark killed each turn after 300 seconds. That left the harness able to kill
Rupi before its provider deadline. The next comparison sets the provider timeout
below the turn budget with a 30-second grace and checks whether the runtime records
the provider timeout before the outer watchdog intervenes.

## Matched provider-deadline comparison: `bench-20260928-case01-provider-deadline-low-matched3`

This run used `request_timeout_ms=270,000` inside each 300-second Rupi turn. The
model, low server default, prompts, write-only Rupi boundary, and three-turn
budget stayed fixed.

| Agent / turn | Elapsed | Requests | Input / output | Project / oracle / help |
| --- | ---: | ---: | ---: | ---: |
| Rupi 1 | 288,816 ms | 2 / 2 | 3,336 / 42 | 1 / 1 / 1 |
| Rupi 2 | 219,112 ms | 3 / 3 | 8,605 / 3,986 | 1 / 1 / 0 |
| Rupi 3 | 293,225 ms | 3 / 3 | 10,728 / 4,936 | 1 / 1 / 0 |
| Pi 1 | 300,277 ms | 2 / 2 | 3,729 / 148 | 1 / 1 / 1 |
| Pi 2 | 300,234 ms | 1 / 1 | 149 / 121 | 1 / 1 / 1 |
| Pi 3 | 300,226 ms | 0 / 0 | 0 / 0 | 1 / 1 / 1 |

Rupi used 22,669 input and 8,964 output tokens (31,633 inference-work tokens)
over 801,153 ms. Turn 1 returned the configured provider timeout after 288,816 ms;
the child process was not killed by the 300-second outer watchdog. This confirms
that the internal deadline is now reported first. Turns 2 and 3 wrote the package,
README, and tests. The project test command still failed in turns 1 and 2 because
`tests/` was absent, then ran 47 tests with one failure in turn 3. Turn 3's batched
`exec` failed and left a mutating effect unresolved, so Rupi stopped with
`needs_reconciliation`. The oracle failed every turn: the CLI printed
`[1] (open) write the docs` where the acceptance check expected `Added task 1`.

Pi used 3,878 input and 269 output tokens (4,147 inference-work tokens) over
900,737 ms. Its outer watchdog timed out all three turns; it created no project
package, and the project tests, oracle, and help checks failed each time. Neither
agent passed the oracle, so there is no Case 01 win. The adjusted per-request
deadline let Rupi record a provider timeout before the outer watchdog when enough
turn budget remained. A later request can still outlast the remaining turn time,
as the next run's third request did. The implementation also needs clearer task
output requirements and complete, runnable files before verification.

## Matched add-output spec comparison: `bench-20260928-case01-add-output-spec-low-matched3`

Commit `3125fe6` made the successful `add` confirmation explicit after the
previous oracle failure showed that the output must contain `Added task <ID>`.
The run otherwise kept the same model, low server default, prompts, write-only
Rupi boundary, provider timeout, and three 300-second turns.

| Agent / turn | Elapsed | Requests started / completed | Input / output | Project / oracle / help |
| --- | ---: | ---: | ---: | ---: |
| Rupi 1 | 300,247 ms | 3 / 2 | 6,976 / 2,015 | 1 / 1 / 1 |
| Rupi 2 | 276,579 ms | 2 / 3 | 149 / 44 | 1 / 1 / 1 |
| Rupi 3 | 271,399 ms | 1 / 1 | 0 / 0 | 1 / 1 / 1 |
| Pi 1 | 300,244 ms | 3 / 3 | 3,706 / 134 | 1 / 1 / 1 |
| Pi 2 | 300,297 ms | 1 / 1 | 149 / 77 | 1 / 1 / 1 |
| Pi 3 | 300,262 ms | 0 / 0 | 0 / 0 | 1 / 1 / 1 |

Rupi used 7,125 input and 2,059 output tokens (9,184 inference-work tokens) over
848,225 ms. It read the spec and wrote only `tasklog/__init__.py` in turn 1;
that file imports the missing `tasklog.store` module. Turn 1's third request
remained incomplete until the outer watchdog killed the process. Turns 2 and 3
ended with recorded provider timeouts before the outer watchdog. The project test
command failed because `tests/` was absent, and the oracle and help checks failed
because there was no runnable CLI. The added output requirement was not exercised.

Pi used 3,855 input and 211 output tokens (4,066 inference-work tokens) over
900,803 ms. It created no project files, and its project tests, oracle, and help
checks failed in every turn. Neither agent passed the oracle, so this iteration
does not win Case 01. The spec clarification did not get the implementation past
the first write; the next iteration should make that first progress action an
executable package entry point with working task creation, then measure again.
The timeout setting is per provider request, so a request started late in a turn
can still outlast the remaining outer budget; Rupi's first turn hit that case
after starting its third request.

## Matched first-write prompt comparison

Run: `bench-20260928-case01-first-write-code-low-matched3`.

Commit `afa3ccd` strengthened the shared initial prompt: the first write had to
create runnable application code with one persistent command path. Both agents
used the same clarified case spec from `3125fe6`, model, low server default,
write-only Rupi boundary, 270-second provider timeout, and three 300-second turns.

| Agent / turn | Elapsed | Requests started / completed | Input / output | Project / oracle / help |
| --- | ---: | ---: | ---: | ---: |
| Rupi 1 | 291,376 ms | 2 / 2 | 3,391 / 68 | 1 / 1 / 1 |
| Rupi 2 | 300,270 ms | 3 / 2 | 3,304 / 1,803 | 1 / 1 / 1 |
| Rupi 3 | 300,262 ms | 2 / 2 | 149 / 4,038 | 1 / 1 / 1 |
| Pi 1 | 300,318 ms | 3 / 3 | 3,821 / 5,124 | 1 / 1 / 1 |
| Pi 2 | 300,259 ms | 4 / 4 | 319 / 4,423 | 1 / 1 / 1 |
| Pi 3 | 300,283 ms | 8 / 8 | 571 / 5,419 | 1 / 1 / 0 |

Rupi used 6,844 input and 5,909 output tokens (12,753 inference-work tokens)
over 891,908 ms. Its first turn read and inspected, then ended with a recorded
provider timeout before the outer watchdog; it did not write. Turns 2 and 3
were killed by the outer watchdog after writing `tasklog/__init__.py`,
`tasklog/__main__.py`, `tasklog/errors.py`, and `tasklog/model.py`. The entry
point imports the missing `tasklog.cli`, and no storage module, README, or tests
were created. Project test discovery, oracle, and help failed in every turn.

Pi used 4,711 input and 14,966 output tokens (19,677 inference-work tokens) over
900,860 ms. It created `__init__.py`, `__main__.py`, `cli.py`, `errors.py`,
`models.py`, and `store.py`, but no README or tests. Help passed in turn 3. The
oracle reached list output but failed its exact output assertion: Pi emitted
extra spaces and a blank line and printed `2 open tasks` instead of `2 open`.
Project test discovery and the oracle failed in every turn. Neither agent
resolved Case 01. The first-write prompt did not make Rupi write in turn 1 and
helped Pi reach further into the implementation, so it did not improve Rupi's
result against Pi.

The runtime already narrows the next request to configured progress tools,
marks tool choice as required, and rejects a text-only response until a progress
tool succeeds. Unit coverage exercises those rules. The provider adapter maps
`ToolChoice::Required` to the OpenAI-compatible `tool_choice: "required"` field.
The local llama.cpp endpoint is build `b10909-a2878d30d` and reports
`supports_preserve_reasoning: true`. A minimal direct request returned the
required tool call once with prompt caching disabled and 3/3 times with caching
enabled, at both low and off reasoning levels. This does not reproduce the
long-task timeout. An upstream [llama.cpp issue about required tool choice on
preserve-reasoning templates](https://github.com/ggml-org/llama.cpp/issues/27217)
matches one endpoint capability, but the local smoke calls did not show the
failure. The matched off reasoning run is recorded below.

## Matched off reasoning comparison: `bench-20260928-case01-thinking-off-matched3`

Commit `7c68ce8` made the client thinking level configurable so both agents
could use `off`; it remains `low` by default. This run kept the same model,
prompts, three-turn limit, 300-second outer timeout, eight-request cap, and
Rupi progress-tool configuration. The local endpoint was build
`b10909-a2878d30d`.

Checks are project tests / oracle / help; `1` means the command failed.

| Rupi turn | Elapsed | Input / output | Tools | Checks | Runtime result |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,208 ms (timeout) | 7,084 / 3,065 | read, write, write | 1 / 1 / 1 | timed out |
| 2 | 4,971 ms | 149 / 53 | exec | 1 / 1 / 1 | needs reconciliation |
| 3 | 246 ms | 0 / 0 | none | 1 / 1 / 1 | needs reconciliation |

Rupi used 7,233 input and 3,118 output tokens (10,351 inference-work tokens)
over 305,425 ms. It wrote only `tasklog/__init__.py` and `tasklog/model.py`.
The package had no `__main__.py`, so the oracle reported that `tasklog` could
not be run as a module. The `tests/` directory was also absent. The unresolved
`exec` effect stopped progress in turn 2; turn 3 made no model request.

| Pi turn | Elapsed | Input / output | Tools | Checks | Runtime result |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,279 ms (timeout) | 3,525 / 293 | ls, read, bash | 1 / 1 / 1 | timed out |
| 2 | 300,371 ms (timeout) | 149 / 116 | bash | 1 / 1 / 1 | timed out |
| 3 | 300,232 ms (timeout) | 0 / 0 | none | 1 / 1 / 1 | timed out |

Pi used 3,674 input and 409 output tokens (4,083 inference-work tokens) over
900,882 ms and created no project files. The oracle could not import `tasklog`,
and unittest discovery failed because there was no importable `tests/`
directory. Neither agent resolved Case 01, so this is not a win. Off reasoning
did not get either agent past the first implementation step; Rupi's quick
reconciliation stop accounts for its lower elapsed time than the low run.

## Matched entry-point-first run: `bench-20260928-case01-entrypoint-first-low-matched3`

Commit `a11c982` asked both agents to create `tasklog/__main__.py` first and
keep the commands in that file until persistent task operations worked. The
run used low reasoning, the same model, three 300-second turns, and an
eight-request cap.

Checks are project tests / oracle / help; `1` means the command failed.

| Rupi turn | Elapsed | Input / output | Actions | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,212 ms | 12,708 / 4,876 | read, write, exec, process/edit x2 | 1 / 1 / 0 | outer timeout |
| 2 | 284,366 ms | 443 / 76 | read, exec | 1 / 1 / 0 | provider timeout |
| 3 | 294,029 ms | 3,724 / 50 | read | 1 / 1 / 0 | provider timeout |

Rupi used 16,875 input and 5,002 output tokens (21,877 inference-work tokens)
over 878,607 ms. It created `tasklog/__main__.py` first, and `--help` passed
in all turns. The final oracle invocation passed two of three checks. In the
fresh-process sequence, Rupi printed `[ ] 1: write the docs`; the fixture
expects `   1 [ ] write the docs`. Project tests failed because `tests/` was
absent; Rupi created no README.

| Pi turn | Elapsed | Input / output | Actions | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,397 ms | 3,812 / 4,255 | read, bash x2 | 1 / 1 / 1 | outer timeout |
| 2 | 300,274 ms | 2,169 / 5,374 | bash, write, edit, bash x4 | 1 / 1 / 0 | outer timeout |
| 3 | 300,347 ms | 3,933 / 3,783 | bash, read, edit, write x2 | 1 / 1 / 0 | outer timeout |

Pi used 9,914 input and 13,412 output tokens (23,326 inference-work tokens)
over 901,018 ms. It created `tasklog/__init__.py`, `tasklog/__main__.py`, a
README, and task state, but no project tests. Its final oracle invocation
failed all three checks. `No matching tasks.` fits the existing spec wording
but fails the fixture's `No open tasks` check. The error `invalid task id`
explains the problem but lacks the fixture's exact `invalid id` phrase. Pi's
list rows omit checkboxes, add a blank line, and report `2 open task(s)` rather
than the expected `2 open`. Help passed in turns 2 and 3.

Neither agent passed the oracle, so this remains no Case 01 win. The explicit
entry-point instruction produced more complete first-turn code from Rupi, but
the visible spec does not define the exact row format or phrases required by
acceptance. Align those requirements before the next comparison.

## Matched clarified-contract run: `bench-20260928-case01-contract-clarified-low-matched3`

Commit `0f72012` made the task spec explicit about list rows and summaries,
empty-list text, success messages, and invalid-ID wording. The prompt remained
entry-point-first; both agents used low reasoning, the same model, three
300-second turns, and an eight-request cap.

Checks are project tests / oracle / help; `1` means the command failed.

| Rupi turn | Elapsed | Input / output | Actions | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 293,076 ms | 3,411 / 68 | read, exec | 1 / 1 / 1 | provider timeout |
| 2 | 270,907 ms | 0 / 0 | none | 1 / 1 / 1 | provider timeout |
| 3 | 300,416 ms | 3,682 / 5,502 | write, edit | 1 / 1 / 0 | outer timeout |

Rupi used 7,093 input and 5,570 output tokens (12,663 inference-work tokens)
over 864,399 ms. It wrote no project files until turn 3, when it created
`tasklog/__main__.py`. The oracle then failed all three checks because
`resolve_state_path()` takes one argument but its caller passed two. The
project tests failed because there was no `tests/` directory; help passed only
in turn 3.

| Pi turn | Elapsed | Input / output | Actions | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,332 ms | 3,996 / 446 | read, bash, read | 1 / 1 / 1 | outer timeout |
| 2 | 300,381 ms | 149 / 156 | bash | 1 / 1 / 1 | outer timeout |
| 3 | 300,234 ms | 149 / 3,103 | bash | 1 / 1 / 1 | outer timeout |

Pi used 4,294 input and 3,705 output tokens (7,999 inference-work tokens)
over 900,947 ms and created no project files. Its acceptance checks failed
because Python could not import `tasklog`; project test discovery and help
also failed in every turn.

Neither agent passed the oracle, so this is not a Case 01 win. The clarified
contract did not change Rupi's first-write delay: it wrote code in the final
turn, where a simple argument mismatch made the package unrunnable. Pi again
made no source write. The long first-write stall remains the main open issue.

## Four-turn local-feedback run — `bench-20260928-case01-local-feedback-low-matched4` (invalidated)

This run added local project-test and help diagnostics to recovery prompts and
used low reasoning, four turns, 300-second outer limits, and an eight-request
cap. The run metadata records `project_tests_and_help`; saved recovery prompts
for turns 2–4 contain only those local diagnostics, with no oracle output.

The run exposed a prompt-integrity bug, so it is not valid evidence for the
intended entry-point-first task. `Get-InitialPrompt` used an expandable
PowerShell here-string around Markdown backticks. PowerShell converted the
opening backtick before `tasklog`, `add`, and `remove` into a tab, BEL, and
carriage return, removing each command's first letter in the saved turn-1
prompt. Both agents received the same malformed instruction. The results below
are retained as observations but do not close or advance the Case 01 gate.

Checks are project tests / oracle / help; `1` means the command failed.

| Rupi turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 289,715 ms | 3,408 / 40 | read | 1 / 1 / 1 | timeout |
| 2 | 285,988 ms | 2,167 / 44 | exec | 1 / 1 / 1 | timeout |
| 3 | 271,499 ms | 0 / 0 | none | 1 / 1 / 1 | provider timeout |
| 4 | 272,229 ms | 0 / 0 | none | 1 / 1 / 1 | provider timeout |

Rupi used 5,575 input and 84 output tokens (5,659 inference-work tokens) over
1,119,431 ms and created no project files. Project tests, oracle, and help
failed in every turn.

| Pi turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,280 ms | 3,929 / 129 | read, bash x2 | 1 / 1 / 1 | outer timeout |
| 2 | 300,273 ms | 933 / 5,781 | bash x2 | 1 / 1 / 1 | outer timeout |
| 3 | 300,339 ms | 1,174 / 5,252 | bash x3 | 1 / 1 / 1 | outer timeout |
| 4 | 300,329 ms | 5,188 / 4,993 | write, bash x2 | 1 / 1 / 0 | outer timeout |

Pi used 11,224 input and 16,155 output tokens (27,379 inference-work tokens)
over 1,201,221 ms. It created `tasklog/__main__.py` and `.tasklog.json`, but no
README or tests. Help passed only in turn 4; project tests and oracle failed in
every turn. Neither agent resolved Case 01.

The initial prompt now uses a literal here-string and validates that the
entry-point and command-name instructions survive template expansion. The
PowerShell parser, dry run, and direct prompt-function check pass. The
corrected-prompt comparison below uses installed Pi 0.87.1; the pinned 0.86.1
target-version run remains pending.

## Corrected-prompt matched run — `bench-20260928-case01-literal-prompt-low-matched4`

The saved turn-1 prompts for both agents preserve `tasklog/__main__.py` and all
four command names. The run used low reasoning, four 300-second turns, an
eight-request cap, and local project-test/help feedback on recovery turns.
Recovery prompts contain no acceptance-oracle output.

The installed Pi package was `@earendil-works/pi-coding-agent` 0.87.1. This is
a valid matched result against 0.87.1, but the roadmap's pinned target is
Pi 0.86.1, so this run does not close that gate.

Checks are project tests / oracle / help; `1` means the command failed.

| Rupi turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 291,658 ms | 3,412 / 40 | read | 1 / 1 / 1 | timeout |
| 2 | 282,979 ms | 2,167 / 47 | exec | 1 / 1 / 1 | timeout |
| 3 | 136,117 ms | 4,365 / 2,231 | write, exec | 1 / 0 / 0 | needs reconciliation |

Rupi resolved the acceptance oracle and help checks in turn 3. It used 9,944
input and 2,318 output tokens (12,262 inference-work tokens) over 710,754 ms.
It created only `tasklog/__main__.py` (7,437 bytes); no README or project tests
were created, so project unittest discovery failed in every turn. After the
write, the agent's `exec` attempted `cd /d` to the extended `\\?\C:` workspace
path. `cmd.exe` rejected that current directory, and the runtime stopped with
`needs_reconciliation` instead of replaying the failed mutating tool call.

| Pi turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,384 ms | 6,205 / 2,592 | read, ls, read | 1 / 1 / 1 | outer timeout |
| 2 | 300,300 ms | 625 / 62 | bash | 1 / 1 / 1 | outer timeout |
| 3 | 300,258 ms | 0 / 0 | none | 1 / 1 / 1 | outer timeout |
| 4 | 300,278 ms | 0 / 0 | none | 1 / 1 / 1 | outer timeout |

Pi used 6,830 input and 2,654 output tokens (9,484 inference-work tokens) over
1,201,220 ms. It created no project files and did not pass the oracle or help
in any turn. Rupi therefore won this corrected matched run against installed
Pi 0.87.1 by resolving the oracle in three turns while Pi did not resolve in
four. Rupi's project-test failure and unresolved tool state remain explicit;
the comparison against the roadmap's exact Pi 0.86.1 target is still pending.

## Exact Pi 0.86.1 target-version run — `bench-20260928-case01-target0861-low-matched4`

The run used the published `@earendil-works/pi-coding-agent` 0.86.1 package
installed under an isolated temporary prefix. The prefix's `pi --version`
reported 0.86.1; the global 0.87.1 installation was unchanged. npm blocked
install scripts for three dependencies, but the bundled offline CLI ran with
extensions disabled. This leaves those optional integrations unverified.

The corrected turn-1 prompt names the entry point and CLI verbs literally.
Settings matched the prior run: low reasoning, four 300-second turns, an
eight-request cap, and project-test/help feedback only on recovery turns. No
acceptance-oracle output was included in any recovery prompt.

Checks are project tests / oracle / help; `1` means the command failed.

| Rupi turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 290,720 ms | 3,413 / 42 | read | 1 / 1 / 1 | timeout |
| 2 | 286,451 ms | 2,167 / 58 | exec | 1 / 1 / 1 | timeout |
| 3 | 271,242 ms | 0 / 0 | none | 1 / 1 / 1 | provider timeout |
| 4 | 300,195 ms | 625 / 5,023 | write | 1 / 1 / 0 | outer timeout |

Rupi used 6,205 input and 5,123 output tokens (11,328 inference-work tokens)
over 1,148,608 ms. It created only `tasklog/__main__.py` (8,731 bytes), with
no README or project tests. Help passed in turn 4, but the oracle failed in all
four turns. Rupi did not resolve Case 01 against the pinned Pi version.

| Pi 0.86.1 turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,335 ms | 4,063 / 5,941 | read, bash x2 | 1 / 1 / 1 | outer timeout |
| 2 | 300,355 ms | 2,508 / 1,655 | bash, read, bash x2 | 1 / 1 / 1 | outer timeout |
| 3 | 300,346 ms | 815 / 5,505 | bash, write, bash | 1 / 0 / 0 | outer timeout |

Pi resolved the oracle and help checks in turn 3. It used 7,386 input and
13,101 output tokens (20,487 inference-work tokens) over 901,036 ms and created
only `tasklog/__main__.py` (16,456 bytes). Project test discovery failed in all
turns because no `tests/` directory was created.

Pi 0.86.1 passed the oracle in three turns while Rupi did not pass in four, so
the pinned Case 01 gate remains open. The 0.87.1 run remains a separate
provisional Rupi win against that newer installed version.

## Failure analysis and next prompt

Rupi's turn-4 oracle output reports that the global custom state file was not
created and that an invalid-input subprocess returned status 0. The complete
fresh-process persistence sequence passed. The saved Rupi entry point declares
`--state` on the root parser and again on each subparser with `default=None`.
A direct `argparse` reproduction of that option layout parsed
`['--state', 'custom.json', 'add']` as `Namespace(state=None, command='add')`,
which explains the lost global path. The saved ID validator also accepts an
optional leading `+`, while SPEC.md requires IDs to use ASCII decimal digits
only and represent a positive integer. That could explain the invalid-input
success, but the failure output does not identify the argument. This remains a
likely cause rather than a confirmed test diagnosis.

The next matched prompt now foregrounds both `--state PATH` positions, non-zero
errors for unknown commands and missing arguments, and IDs that use only ASCII
decimal digits and denote a positive integer. It requests byte-for-byte state
preservation after invalid input. It instructs agents to use the already-current
project directory, avoiding the extended-path `cd` error from the separate
0.87.1 run. The prompt change is derived from the visible SPEC and local Windows
execution behavior; acceptance output remains excluded from initial and recovery
prompts.

## Focused-contract matched run — `bench-20260929-case01-focused-contract-low-matched4`

The run used Pi 0.86.1 from the isolated temporary prefix and matched the prior
target run's settings: low reasoning, four 300-second turns, an eight-request
cap, and local project-test/help feedback only. Both saved turn-1 prompts
preserve the new contract emphasis. Recovery prompts contain no acceptance
output.

Checks are project tests / oracle / help; `1` means the command failed.

| Rupi turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 289,909 ms | 3,557 / 41 | read | 1 / 1 / 1 | timeout |
| 2 | 296,547 ms | 2,167 / 291 | exec | 1 / 1 / 1 | timeout |
| 3 | 271,491 ms | 0 / 0 | none | 1 / 1 / 1 | provider timeout |
| 4 | 228,424 ms | 3,762 / 3,772 | write, process x6, exec x3 | 1 / 0 / 0 | needs reconciliation |

Rupi used 9,486 input and 4,104 output tokens (13,590 inference-work tokens)
over 1,086,371 ms. It passed the oracle and help in turn 4. Its only authored
project source was `tasklog/__main__.py` (7,714 bytes), and it left two smoke
state files. It created no README or project tests, so unittest discovery
failed in every turn.

The turn-4 trace records a self-check where `done abc` reported exit status 0.
A following inline Python `-c` verification failed with an unterminated-string
SyntaxError, ending the turn as `needs_reconciliation`. The saved implementation
accepts an optional leading `+` in IDs, contrary to SPEC.md. These remain
implementation gaps even though the external oracle passed.

| Pi 0.86.1 turn | Elapsed | Input / output | Tools | Checks | End |
| --- | ---: | ---: | --- | --- | --- |
| 1 | 300,332 ms | 3,931 / 120 | read, bash | 1 / 1 / 1 | timeout |
| 2 | 300,264 ms | 625 / 73 | bash | 1 / 1 / 1 | timeout |
| 3 | 300,271 ms | 0 / 0 | none | 1 / 1 / 1 | timeout |
| 4 | 300,304 ms | 625 / 4,257 | read | 1 / 1 / 1 | timeout |

Pi used 5,181 input and 4,450 output tokens (9,631 inference-work tokens) over
1,201,171 ms. It did not pass the oracle or help in any turn and created no
project source files, README, or tests. Project-test discovery also failed in
all turns.

Under the oracle-based Case 01 comparison gate, Rupi won this matched run by
passing the oracle while Pi did not resolve in four turns. Rupi finished
114,800 ms sooner but used 3,959 more inference-work tokens (about 41% more).
This closes the target-version oracle comparison gate; the missing README,
tests, strict ID validation, and `needs_reconciliation` status remain visible
limitations. The ten-case comparison remains active.
