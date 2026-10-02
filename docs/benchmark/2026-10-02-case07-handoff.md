# Case 07 Lease Cascade Handoff

Updated: 2026-10-02

## Goal

Continue the authorized Case 07 effort in
`C:\Users\saehwan\repos\rupi-case07-lease-cascade` until Rupi strictly beats
pinned Pi 0.86.1 on the oracle.

## Current state

- Worktree: `C:\Users\saehwan\repos\rupi-case07-lease-cascade`
- Branch: `fix/case07-lease-cascade`
- Draft PR: [#139](https://github.com/SaehwanPark/rupi/pull/139)
- Prompt revision commit before this handoff: `3cabcde`.
- Case 07 remains active. No retry after the baseline produced a strict oracle winner;
  the baseline Pi strict oracle win remains the last resolved result.
- The root checkout has an unrelated user change in `docs/ai-usage-policy.md`; leave it
  untouched. The benchmark worktree is separate.
- No Rust source changes were made. The benchmark uses the existing
  `target/debug/rupi.exe`; the installed Rust toolchain lacks the Cargo component.

## Latest completed comparison: retry 12

Run: `bench-20261002-case07-workflow-write-retry12-matched4-600s`.

| Agent | Work tokens | Tools | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: |
| Rupi | 26,511 | 8 | Failed all turns | Passed all turns | Failed all turns |
| Pi | 40,175 | 5 | Failed all turns | Passed all turns | Failed all turns |

Neither agent resolved the oracle. The per-turn results and timings are in
[the Case 07 ledger](2026-09-29-case07-lease-cascade-ledger.md).

## Retry 13: interrupted, incomplete

Run ID: `bench-20261002-case07-integrated-workflow-write-retry13-matched4-600s`.

- Rupi turn 1 reached the 600,255 ms turn limit: 16,965 work tokens, three `write`
  calls, tests exit 1, all three help checks exit 0, and oracle exit 1.
- Its turn 1 snapshot had the entry point and both test files, with no separate storage,
  server, or worker source.
- Turn 2 started but was interrupted during this wrap-up. Only its `files.json`
  snapshot exists; no turn 2 `summary.json` exists. The snapshot still lists nine files
  and shows no additional application modules.
- The runner and its child processes were stopped and verified gone. Pi did not run.
  This is not a matched comparison and has no winner.

The run artifacts are under
`.benchmark/runs/bench-20261002-case07-integrated-workflow-write-retry13-matched4-600s/`.
Only per-turn `summary.json` and `files.json` were inspected. Do not inspect acceptance
source, runner or agent output, session traces, or aggregate `results.json`.

Usage after stopping retry 13: 14% five-hour and 2% weekly. Before retry 13: 12% and 2%.

## Resume steps

1. Start in the benchmark worktree and confirm branch `fix/case07-lease-cascade`.
2. Make a fresh Codex usage check before launching another benchmark.
3. Treat retry 13 as incomplete; do not combine its partial Rupi turns with later Pi turns.
   For the next comparison, start a fresh matched run (retry 14) with the current prompt.
4. Use pinned Pi at
   `..\rupi\.benchmark\tools\pi-0.86.1\pi.ps1` and the standard settings:
   Case 07, four turns, 600 seconds per turn, 6-second provider grace, eight requests per
   turn, thinking off.
5. Inspect only per-turn `summary.json` and `files.json`, plus generated help output.
   Do not read acceptance-test source, runner stdout/stderr, agent logs, session traces, or
   aggregate `results.json`. Do not run standalone tests.
6. Append verified results to the ledger and update PR #139. Keep ROADMAP active until
   evidence supports a change. Merge only after a strict Rupi oracle win.

The current prompt revision is in `bench/compare-pi-rupi.ps1`. Its all-case
`-DryRun` passed before retry 13. Prior runs used the existing Rupi binary because this
machine's installed Rust toolchain lacks the Cargo component.
