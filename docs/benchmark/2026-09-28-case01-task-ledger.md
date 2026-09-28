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
remaining acceptance output shows that multiword `add` text is rejected, but
`SPEC.md` only says `add TEXT` and does not say whether unquoted multiple words
form one description. Clarify that contract against the intended CLI behavior
before the next matched run; keep the external oracle unchanged.
