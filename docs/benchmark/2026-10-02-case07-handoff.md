# Case 07 Lease Cascade Handoff

Updated: 2026-10-03

## Goal

Continue the authorized Case 07 effort in
`C:\Users\saehwan\repos\rupi-case07-lease-cascade` until Rupi strictly beats
pinned Pi 0.86.1 on the oracle.

## Current state

- Worktree: `C:\Users\saehwan\repos\rupi-case07-lease-cascade`
- Branch: `fix/case07-lease-cascade`
- Draft PR: [#139](https://github.com/SaehwanPark/rupi/pull/139)
- Latest benchmark change aligns early workflow-test guidance with recovery priority,
  completion, and file-read instructions in `bench/compare-pi-rupi.ps1`. It also clarifies
  project-relative paths. Bounded edits, native file tools, and request policies remain.
  Retry 19 is complete; retry 20 has not started.
- Case 07 remains active. No retry after the baseline produced a strict oracle winner;
  the baseline Pi strict oracle win remains the last resolved result.
- Request-budget clarification: the eight-request parameter caps Rupi. Pi retains its
  native request policy; retry 18 Pi turn 3 recorded nine completed model requests.
  Model, thinking, turn count, and outer time limits are shared across each pair.
- The root checkout is detached at `04b229c` and retains an unrelated user change in
  `docs/ai-usage-policy.md`; leave it untouched. The task branch is now attached to the
  benchmark worktree, which started clean at the same commit.
- No Rust source changes were made. The benchmark uses the existing
  `target/debug/rupi.exe`; the installed Rust toolchain lacks the Cargo component.

## Latest completed comparison: retry 19

Run: `bench-20261003-case07-workflow-fixtures-retry19-matched4-600s`.

| Agent | Work tokens | Tools | Tests | Help | Oracle |
| --- | ---: | ---: | ---: | --- | ---: |
| Rupi | 81,170 | 19 | Passed all turns | Passed all turns | Failed all turns |
| Pi | 37,096 | 22 | Passed turns 3-4 | Passed turns 3-4 | Failed all turns |

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

## Retry 15: complete

Run: `bench-20261002-case07-foundation-repair-retry15-matched4-600s`.

- Started with prompt revision `26dcff1` after usage check: 14% five-hour and 7% weekly.
- Uses the standard matched Case 07 settings and existing binary, with pinned Pi 0.86.1.
- Rupi turn 1 had zero work or tools and no application files; all checks failed.
  Turn 2 used 2,403 work tokens and one write, creating a 2,511-byte entry point.
  Help passed all three checks; tests and oracle failed. No test files exist in its snapshot.
- Rupi turn 3 added both tests and the package initializer with 7,860 work tokens and
  three writes; tests and help passed, but the oracle failed. Turn 4 had zero work and
  tools, timeout status, and an unchanged snapshot. Tests/help passed; oracle failed.
- Rupi totals: 10,263 work tokens, four writes, and 2,318,078 ms. No oracle resolution.
- Pi totals: 26,062 work tokens, 14 tools, and 2,183,079 ms. Help passed from turn 2 and
  tests from turn 3, but the oracle failed every turn. Turn 4 had zero work/tools and an
  unchanged snapshot. Its turn 2 metrics include one `bash`; output was not inspected.
- Runner exit 0; the runner tree is gone. Output remains unread in
  `.benchmark/retry15-runner-unread.log`.
- Both agents passed foundations but made no workflow write in turn 4. Repeat the current
  revision in retry 16 before inferring the workflow directive's effectiveness.
- Post-run usage: 50% five-hour and 13% weekly.
- Artifacts are under `.benchmark/runs/` followed by the run ID above.

## Retry 16: complete

Run: `bench-20261003-case07-foundation-repair-retry16-matched4-600s`.

- Prompt unchanged at `26dcff1`; usage before launch: 51% five-hour and 13% weekly.
- Uses the standard matched settings and existing binary, with pinned Pi 0.86.1.
- Rupi turns 1-2 recorded zero work/tools and no application files. Turn 3 used 1,246
  work tokens and one `exec`, creating no application files; all checks failed.
- Rupi turn 4 wrote a 5,013-byte entry point with 12,239 work tokens, but help failed on
  its import of the absent `__version__` symbol from the package. No test files exist.
- Rupi totals: 13,485 work tokens, two tools, and 2,153,627 ms. All checks failed every turn.
- Pi turns 1-3 timed out without application files; turns 1 and 3 recorded zero work/tools.
  Turn 2 used 3,622 work tokens and seven inspection tools. All checks failed.
- Pi turn 4 used 12,902 work tokens and six file tools. Its snapshot has an entry point,
  initializer, storage, and validation, but no tests. Help reports a missing worker module.
- Pi totals: 16,524 work tokens, 13 tools, and 2,400,865 ms. All checks failed every turn.
- Runner exit 0; its process tree is gone. No strict winner. Rupi used 3,039 fewer work
  tokens and took 247,238 ms less. Post-run usage: 84% five-hour and 18% weekly.
- Runner output remains unread in `.benchmark/retry16-runner-unread.log`.
- Artifacts are under `.benchmark/runs/` followed by the run ID above.

The next revision enforces the no-command instruction through Case 07 tool allowlists.
Use Rupi `read,write,edit,grep` and Pi `read,write,edit,grep,find,ls`. Rupi filename search
is `grep` with `glob=true`, not a separate `glob` tool; source review corrected the proposal.
Per-turn summaries record `configured_tool_allowlist`; this is configuration evidence, not
an observation of offered tools. Other cases and matched budgets retain their existing settings.
Entrypoint recovery now requests compact, self-contained CLI/health code and local constants,
then separate test-module and initializer writes. Evaluate the revision as a fresh matched pair.

## Resume steps

1. Start in the benchmark worktree and confirm branch `fix/case07-lease-cascade`.
2. Make a fresh Codex usage check before launching another benchmark.
3. Retry 19 is complete; retry 20 is running for the aligned recovery and relative-path
   revision. Treat retry 13 as incomplete; do not combine different runs.
4. Use pinned Pi at
   `..\rupi\.benchmark\tools\pi-0.86.1\pi.ps1` and the standard settings:
   Case 07, four turns, 600 seconds per turn, 6-second provider grace, eight requests per
   Rupi turn, thinking off. Pi uses its native request policy under the same outer limits.
5. Inspect only per-turn `summary.json` and `files.json`, plus generated help output.
   Do not read acceptance-test source, runner stdout/stderr, agent logs, session traces, or
   aggregate `results.json`. Do not run standalone tests.
6. Append verified results to the ledger and update PR #139. Keep ROADMAP active until
   evidence supports a change. Merge only after a strict Rupi oracle win.

The current prompt revision is in `bench/compare-pi-rupi.ps1`. Its all-case `-DryRun`,
`git diff --check`, changed-line 100-column, and CRLF checks pass. Runs use the existing
Rupi binary because this machine's installed Rust toolchain lacks the Cargo component.

## Retry 17: complete

Run: `bench-20261003-case07-file-tools-retry17-matched4-600s`.

- Revision `e3fdefa`; pre-run usage: 86% five-hour and 19% weekly.
- New native file-tool configuration for both agents; standard matched budgets unchanged.
- Rupi turn 1 timed out after 600,296 ms with 16,286 work tokens and three writes.
  Turns 2-4 reported runtime timeout with zero recorded work/tools and unchanged snapshots.
- Rupi totals: 16,286 work tokens, three writes, 2,256,391 ms. Tests and help passed every
  turn; oracle failed every turn.
- Pi totals: 28,969 work tokens, 11 tools, 2,175,549 ms. Tests and all help passed from
  turn 2; oracle failed every turn. Turns 3-4 recorded zero work/tools and unchanged snapshots.
- Configured allowlists match the native file-tool profiles in every summary.
- Runner exit 0; process tree gone. No strict winner. Rupi used 12,683 fewer work tokens
  and took 80,842 ms longer. The baseline Pi win remains the last resolved comparison.
- Runner output is redirected to `.benchmark/retry17-runner-unread.log` and stays unread.
- Artifacts are under `.benchmark/runs/` followed by the run ID above.
- Parent usage reached 96% five-hour and 20% weekly at the Rupi checkpoint. Per the root
  checkout's user-edited usage policy, wait through the 03:12 AM ET reset plus two minutes
  (2026-10-03 03:14 AM ET) before resuming. Do not poll usage during the wait. The bounded
  Pi runner continues independently. Runner PID: 27524; tool session: 98191.
- Wait completed at 03:14 AM ET; fresh usage: 0% five-hour and 20% weekly. Pi completed
  independently during the wait. Acceptance source, runner/agent output, and traces stay unread.

Next revision ends the foundation attempt after three writes and waits for harness feedback.
Workflow recovery advances admission, retrieval, worker, and data flow via small edits of at
most 80 new lines. It permits one __main__.py read when an exact edit anchor is unknown.
This is a measured prompt hypothesis; timeout causes remain unknown from permitted evidence.

## Retry 18: complete

Run: `bench-20261003-case07-bounded-edits-retry18-matched4-600s`, revision `8cb9a78`.
Pre-run usage: 3% five-hour and 21% weekly. Standard matched settings, existing binary,
and native file tools unchanged. Rupi turn 1 finished in 208,058 ms with 13,740 work tokens
and four tools: tests and all help passed; oracle failed. Turn 2 ended after 538,470 ms
with 31,527 work tokens and seven tools; tests/help passed, oracle failed.
Turn 3 ended in 493,556 ms with 39,667 work tokens and seven tools; tests/help passed,
oracle failed. Turn 4 reported runtime timeout at 549,232 ms with zero work/tools.
Rupi totals: 84,934 work tokens, 18 tools, 1,789,316 ms. Tests/help passed every turn;
oracle failed every turn. Pi turns 1-3 passed tests/help but failed the oracle. Its entry
point grew to 29,469 bytes on turn 3; tests remained unchanged until turn 4.
Pi turn 4 completed four edits and one read, growing the entry point to 30,819 bytes
and tests to 11,695 bytes. Tests/help passed; oracle failed.
Pi totals: 45,643 work tokens, 20 tools, 1,970,888 ms. Every oracle check failed.
Runner exit 0; process tree gone. No strict winner. Rupi used 39,291 more work tokens and
took 181,572 ms less. Post-run usage: 27% five-hour and 24% weekly.
Post-Rupi usage: 14% five-hour and 23% weekly. Runner PID: 31568; tool session: 47775.
Runner output remains unread in
`.benchmark/retry18-runner-unread.log`. Artifacts are under `.benchmark/runs/` and this run ID.

Next revision requests small workflow tests as soon as worker code exists, covering signed
admission/retrieval, declared inputs, reversed dependency fan-in order, exclusion of private
output fields, and missing-field failure/blocking. These derive from the public specification.
Then yield for harness feedback and repair implementation. No standalone tests are added or run
by the parent. New per-turn summaries record `harness_model_request_cap`: eight for Rupi,
null for Pi, meaning the harness sets no Pi request cap. Existing policies remain unchanged.

## Retry 19: complete

Run: `bench-20261003-case07-workflow-fixtures-retry19-matched4-600s`, revision `34ff2cf`.
Pre-run usage: 29% five-hour and 25% weekly. Standard shared settings and native request
policies unchanged. Rupi turn 1 finished in 198,140 ms with 11,653 work tokens and three
tools; tests/help passed, oracle failed. Its summary records request cap eight.
Rupi completed all four turns: 81,170 work tokens, 19 tool requests, 1,944,223 ms.
Tests/help passed every turn; oracle failed every turn. Final entry point: 22,149 bytes;
test module: 1,746 bytes. One tool failed on turn 2; other recorded calls completed.
Pi used 37,096 work tokens, 22 tools, 1,987,797 ms. Tests/help passed only on turns 3-4;
oracle failed every turn. Turn 1 wrote files under an extra project/ directory; help reported
no leasecascade module. Turn 2 had zero work/tools and the same snapshot. Turn 3 created
the correct root-level files. Turn 4 grew the entry point to 10,576 bytes with two edits.
Runner exit 0; process tree gone. No strict winner. Rupi used 44,074 more work tokens and
took 43,574 ms less. Post-run usage: 58% five-hour and 29% weekly.
Runner output stays unread in
`.benchmark/retry19-runner-unread.log`; artifacts are under `.benchmark/runs/` and this run ID.

The next revision aligns workflow priority and completion with early tests after worker
delivery is implemented. A single read may target the intended source or test file before
editing. Initial and entrypoint recovery clarify that leasecascade/ and tests/ are relative
to the current directory containing SPEC.md. DryRun now checks the assembled workflow
prompt using temporary file markers, which are removed without recursive deletion.

## Retry 20: running

Run: `bench-20261003-case07-coherent-recovery-retry20-matched4-600s`, revision `46fa839`.
Pre-run usage: 63% five-hour and 30% weekly. Existing binary, native file tools/request
policies, and standard shared turn/time/model/thinking settings. Rupi turn 1 is running.
Runner PID: 19252; tool session: 93754. Runner output stays unread in
`.benchmark/retry20-runner-unread.log`. Inspect only the permitted per-turn evidence.
Rupi turn 1 finished in 535,635 ms with 20,744 work tokens and four completed writes.
Tests and all help passed; oracle failed. Files are at the correct root paths.
Turn 2 is running; no matched outcome yet.
Turn 2 timed out at 600,204 ms with 13,998 work tokens and two completed edits.
Tests/help passed; oracle failed. Turn 3 is running; entry point is now 9,417 bytes.
Turn 3 ended at its request budget in 426,767 ms with 32,156 work tokens and seven
completed tools. Tests/help passed; oracle failed. Turn 4 is running; entry point is
25,257 bytes and test-file sizes remain unchanged.
Rupi is complete: 78,598 work tokens, 19 completed tools, 2,162,900 ms. Tests/help passed
every turn; oracle failed every turn. Turn 4 timed out at 600,294 ms with 11,700 work
tokens and six completed edits. Final entry point is 29,723 bytes; test module stays
2,497 bytes. Pi turn 1 is running. Parent usage: 71% five-hour and 31% weekly.
