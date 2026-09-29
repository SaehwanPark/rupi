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
prompt will say to use a dedicated process tool only when it appears in the
available-tool list; otherwise, run the executable directly through the shell
or exec tool, one command per invocation. It will continue to prohibit
`python -c` and command chaining, and direct one-off Python checks to a
temporary `.py` file inside the project workspace.
