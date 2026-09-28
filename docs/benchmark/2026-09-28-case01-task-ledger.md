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

The smallest candidate change is to strengthen the runtime's implementation
guidance so a model writes a runnable end-to-end slice immediately after reading
the governing spec, before exploratory shell calls or extended planning. The
matched post-change run must show whether that prompt-level change improves the
oracle result. Full turn artifacts remain in ignored `.benchmark/` storage.
