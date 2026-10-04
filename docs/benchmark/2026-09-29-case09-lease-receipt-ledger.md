# Case 09 lease receipt comparison ledger

This ledger records the matched `09-lease-receipt` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

## Matched baseline

Run: `bench-20260929-case09-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,547 ms | 12,907 / 9,680 | 22,587 | 4 | 4 | outer timeout |
| 2 | 600,150 ms | 13,863 / 8,763 | 22,626 | 4 | 3 | outer timeout |
| 3 | 600,221 ms | 5,244 / 8,940 | 14,184 | 3 | 2 | outer timeout |
| 4 | 600,339 ms | 8,903 / 9,474 | 18,377 | 8 | 7 | outer timeout; unresolved |

Rupi did not resolve in four turns. It used 77,774 work tokens over 2,401,257 ms, with 19
requests and 16 tools. All oracle, project-test, and help checks failed on turns 1 through 3.
All help checks passed on turn 4, but the oracle and project-test checks still failed. The
oracle's four service tests failed with SQLite's `no such column: rowid` error. Project-test discovery could not import the `tests` start directory.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,213 ms | 6,487 / 11,890 | 18,377 | 5 | 5 | outer timeout |
| 2 | 600,235 ms | 1,369 / 9,072 | 10,441 | 8 | 8 | outer timeout |
| 3 | 600,201 ms | 2,801 / 9,795 | 12,596 | 11 | 11 | outer timeout |
| 4 | 600,203 ms | 4,802 / 7,217 | 12,019 | 13 | 13 | outer timeout; unresolved |

Pi did not resolve in four turns. It used 53,433 work tokens over 2,400,852 ms, with 37
requests and 37 tools. All oracle, project-test, and help checks failed on turns 1 through 3.
All help checks passed on turn 4, but the oracle and project-test checks still failed. The
oracle's four service tests ended with remote disconnects. Project-test discovery could not
import the `tests` start directory.

## Outcome

The result is inconclusive because neither agent resolved the oracle. Pi used 24,341 fewer work
tokens and finished 405 ms sooner, while making more model requests and tool calls. Rupi's
service could not initialize its SQLite schema; Pi's oracle requests ended in remote
disconnects. Case 10 is next.

## Active improvement slice (2026-10-04)

Cases01 through08 already have configured comparison wins and are skipped. Case09's
baseline per-turn summaries confirm neither agent resolved in four turns. This new
slice starts from mainf150e39, after Case08 PR141's exact-head three-platform CI/merge.
The completed Case08 branch is removed locally/remotely; its detached artifacts remain.

Boundary: benchmark adapter in `bench/compare-pi-rupi.ps1`, this ledger and ROADMAP.
Generate all application/tests/README only through the same local Qwen model in fresh
workspaces. Preserve the actual public SPEC and untouched acceptance files. The parent
does not inspect generated source/model output/oracle diagnostics/aggregate results.
Historical diagnostic descriptions above are not supplied to the new authoring prompts.

Plan:

1. Add Case09 shared initial/repair prompts embedding the complete public SPEC. Request
   complete authenticated graph/worker behavior from the first source write, including
   stable `pipeline_id + ":" + job_id` delivery keys, distinct private claim tokens,
   matching receipts and lost-ack retry/recovery. Preserve public assertions and cleanup.
2. Add optional Case09 reasoning-budget/progress-mode/request-window selectors with
   defaults0/one_shot/1. Reuse existing endpoint/progress/tool/discovery adapters, isolated
   to Case09. Record actual selected controls; Pi cap/mode/window remain null.
3. Add guards for full SPEC, receipt/fencing requirements and hidden-oracle sentinel
   isolation on initial/repair/help failure paths. Verify all non-Case09 profiles/prompts
   retain their behavior. Run default/off and selected all-case dry runs and diff checks.
4. Author invariant review, then push before a fresh matched six-turn-maximum pair:
   local `qwen3.8-flash-next`, Pi0.86.1, low/configured budget2,048/native replay,
   600s turns/grace6s, Rupi Recurring/window12/cap12/four file tools versus native
   uncapped Pi/six file tools. Reuse verified binary39829D0D...D1C9; no parallel inference/build.
5. Audit saved prompts, selected controls, copied SPEC/acceptance hashes and model/binary
   identity. Win requires acceptance in fewer turns or fewer recorded work tokens at the
   same resolution turn. Report tests/help/docs, unavailable metrics and unknown inference
   separately. Both unresolved is inconclusive; no default/full-task/causal speedup claim.
6. Merge only after a verified Rupi win, required local checks/performance budgets,
   author review and exact-final-head three-platform CI. Keep draft until then; then
   remove the completed branch and proceed to Case10.

No runtime/schema/provider changes, new dependencies, manual solution, hidden-oracle
prompt feedback, weakened tests or speculative orchestration are part of this slice.
Plan and WIP handoff are prepared; implementation and comparison remain pending.

## First candidate prepared and verified (2026-10-04)

Draft PR144 is opened before implementation on `fix/case09-receipt-recovery`. The
harness now supplies shared Case09 initial/repair prompts with full public SPEC and
receipt/fencing/lost-ack requirements. New Case09 selectors default to budget0,
one_shot mode/window1; the candidate explicitly selects low/budget2,048/Recurring12.
Existing benchmark adapters provide file tools, isolated Rupi discovery, native
reasoning replay and nullable Pi progress/cap metadata. Core/runtime defaults stay intact.

Verified before launch:

- All ten cases pass default/off and selected low/budget2,048/Recurring/window12,
  six-turn/600s/grace6/cap12 dry-run guards. Case09 guards cover full SPEC, receipt/
  fencing assertions, initial/repair/help failures and oracle diagnostic sentinel isolation.
- Distinct Case08 recurring/window3 versus Case09 one_shot/window12 guards pass;
  Case09 window0 is rejected. All18 non-Case09 initial/recovery prompt hashes remain
  equal to pre-edit snapshots, including already-winning Case08 guidance.
- A synthetic fresh workspace verifies Qwen/low/native replay, cap12/window12,
  four tools, endpoint8001/deadline594,000 ms/output16,384 and untouched copied
  SPEC/two acceptance-file hashes. No inference or oracle execution occurs in this probe.
- Diff/100-column checks pass after wrapping two long helper declarations. Author
  invariant review passes: case isolation, public-spec-only guidance, native exposure
  validation before mutation, hidden oracle diagnostics and unknown/null measurements.
  No independent-agent review is claimed. Rust/source/acceptance fixtures are unchanged.
- Shared debug binary SHA256 is
  39829D0D62129F4138C449EC4FC913DE4EF81B028527B649EEDFEA1D3EE3D1C9.
  Singular Qwen server27356 and content-free budget relay33028 remain live.

Push the candidate before inference. No comparison win is claimed; the matched pair,
per-turn/terminal audits and final required checks/CI remain pending.

## Retry01 launched (2026-10-04)

Run: `bench-20261004-case09-receipt-guidance-budget2048-low-retry01-rupi12-matched6-600s`.
Launch source5637c80 is pushed before inference. Exec47054, runner19500/wrapper22280
and Rupi turn1 PID24748 are confirmed live. No observation timeout triggers a restart.
Six-turn maximum,600s/grace6s, low/configured budget2,048/native replay, Rupi
Recurring/window12/cap12/four file tools versus native uncapped Pi/six file tools.

The actual Rupi workspace config verifies selected mode/window/cap, four tools, low,
endpoint8001/deadline594,000 ms and native replay. Saved initial prompt retains the
complete public SPEC, stable delivery identity, private fencing, lost-ack retry,
public assertions and no external-oracle access. Binary/model/relay checks pass before
launch. Runtime source remains unchanged; no local builds or parallel comparisons run.
Pi has not started and no per-turn verification is available yet. Keep PR144 draft;
the Case09 comparison result remains pending and Case10 has not begun.

## Retry01 Rupi first attempt verified (2026-10-04)

Turn1 reaches the600,510 ms watchdog with27,928 recorded work tokens (18,111 uncached
input,9,817 output), seven requests started/six completions and six usage records.
Eight tools complete: two greps/two reads/four writes; recorded failed/Unknown are zero.
Unfinished unrecorded inference remains unknown. Project tests, independent acceptance
and all three help checks fail without verification timeouts. This is not a resolution.

Manifest lists initializer264 bytes, entry point356, store22,419 and validation7,652.
No server/worker files, tests or README are listed. Generated contents/diagnostics
remain unread; file presence/sizes do not establish workflow behavior or the failure cause.
Selected per-turn controls remain low/budget2,048/native replay/endpoint8001 and
Recurring/window12/cap12/four tools/isolated discovery. Harness source SHA256 remains
F2F6A528F3203EAB21D4CFA926812BB99D7CD0BFC0445007C5B7A57D48B54AD0.

Rupi turn2 is live under PID22716, runner19500/exec47054. Its saved repair prompt
retains full SPEC, assertions, stable delivery key, private fencing, lost-ack retry
and no external-oracle access. Let the same six-turn-maximum pair continue without
source/configuration changes, local builds or parallel inference. Pi has not started;
no matched outcome is available. PR144 stays draft and Cases09 through10 remain open.
