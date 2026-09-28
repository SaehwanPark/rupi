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
| Pi 2 | in progress | — | — | — | — |

Both agents' project/oracle failures after the first turn establish that the
initial attempt is incomplete. Rupi has not yet reached a write call in this
run; all six recorded tool calls completed without a tool failure. Pi's three
files are partial progress, not resolution. Do not attribute the gap to a
runtime defect until Pi's recovery completes and the request/tool traces are
compared. Full turn artifacts remain in ignored `.benchmark/` storage.
