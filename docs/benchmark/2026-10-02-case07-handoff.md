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
- Current prompt revision: `26dcff1`, retry 15 foundation repair in `bench/compare-pi-rupi.ps1`.
  Retry 14 used `3cabcde` unchanged; its matched comparison is complete.
- Case 07 remains active. No retry after the baseline produced a strict oracle winner;
  the baseline Pi strict oracle win remains the last resolved result.
- The root checkout is detached at `04b229c` and retains an unrelated user change in
  `docs/ai-usage-policy.md`; leave it untouched. The task branch is now attached to the
  benchmark worktree, which started clean at the same commit.
- No Rust source changes were made. The benchmark uses the existing
  `target/debug/rupi.exe`; the installed Rust toolchain lacks the Cargo component.

## Latest completed comparison: retry 14

Run: `bench-20261002-case07-integrated-workflow-write-retry14-matched4-600s`.

| Agent | Work tokens | Tools | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: |
| Rupi | 49,184 | 12 | Passed turn 4 | Passed turn 4 | Failed all turns |
| Pi | 26,318 | 12 | Passed turn 4 | Passed turns 3-4 | Failed all turns |

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

## Retry 14: complete

Run: `bench-20261002-case07-integrated-workflow-write-retry14-matched4-600s`.

- Started a fresh matched comparison with the current prompt after checking usage:
  19% five-hour and 3% weekly.
- Settings: pinned Pi 0.86.1, four turns, 600 seconds per turn, 6-second provider grace,
  eight requests per turn, thinking off, and the existing Rupi binary.
- Rupi completed all four turns: 49,184 work tokens, 12 tools, and 2,398,872 ms.
  Tests and all help checks passed only on turn 4; the oracle failed every turn.
- Pi completed all four turns: 26,318 work tokens, 12 tools, and 2,065,080 ms.
  Tests passed on turn 4 and help on turns 3-4; the oracle failed every turn.
- Runner exit 0. Neither agent resolved; no strict winner. Pi was 333,792 ms faster
  and used 22,866 fewer work tokens. The baseline Pi oracle win remains the last resolved result.
- Rupi's final snapshot has the entry point, package initializer, and both test files,
  without separate storage, server, or worker modules. Turn 4 metrics show one `exec`
  request despite the prompt prohibition; its output was not inspected.
- Turn 1 has the entry point and test initializer but no test module. Generated help output
  reports an import of the missing `server` module.
- Retry 15 revision permits entry-point repairs when help fails and requests separate writes
  for the real test module before its initializer. The first entry point must avoid imports of
  missing local modules. Both agents hit that failure in generated help during retry 14.
- Runner output is redirected to `.benchmark/retry14-runner-unread.log` and stays unread.
- Artifacts are under `.benchmark/runs/` followed by the run ID above.
- Corrected the historical retry 12 handoff table: the ledger records Rupi tests exit 0 on
  every turn, while the prior handoff incorrectly labeled them failed.
- Post-run usage: 12% five-hour and 7% weekly.

## Retry 15: running

Run: `bench-20261002-case07-foundation-repair-retry15-matched4-600s`.

- Started with prompt revision `26dcff1` after usage check: 14% five-hour and 7% weekly.
- Uses the standard matched Case 07 settings and existing binary, with pinned Pi 0.86.1.
- At this checkpoint, Rupi turn 1 is running. Runner output remains unread in
  `.benchmark/retry15-runner-unread.log`.
- Runner PID at launch: 34400. Check liveness and per-turn artifacts before restarting.
- Artifacts are under `.benchmark/runs/` followed by the run ID above.

## Resume steps

1. Start in the benchmark worktree and confirm branch `fix/case07-lease-cascade`.
2. Make a fresh Codex usage check before launching another benchmark.
3. Retry 14 is complete. Retry 15 started; check whether it is still active and finish it if
   running. Treat retry 13 as incomplete; do not combine turns from different runs.
4. Use pinned Pi at
   `..\rupi\.benchmark\tools\pi-0.86.1\pi.ps1` and the standard settings:
   Case 07, four turns, 600 seconds per turn, 6-second provider grace, eight requests per
   turn, thinking off.
5. Inspect only per-turn `summary.json` and `files.json`, plus generated help output.
   Do not read acceptance-test source, runner stdout/stderr, agent logs, session traces, or
   aggregate `results.json`. Do not run standalone tests.
6. Append verified results to the ledger and update PR #139. Keep ROADMAP active until
   evidence supports a change. Merge only after a strict Rupi oracle win.

The current prompt revision is in `bench/compare-pi-rupi.ps1`. Its all-case `-DryRun`,
`git diff --check`, changed-line 100-column, and CRLF checks pass. Runs use the existing
Rupi binary because this machine's installed Rust toolchain lacks the Cargo component.
