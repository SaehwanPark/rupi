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
reflect its early reconciliation stop, not a successful implementation. The
next Case 02 experiment will give both agents explicit Windows guidance to use
direct process arguments and avoid inline Python source and shell command chains.
