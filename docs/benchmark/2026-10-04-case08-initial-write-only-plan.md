# Conditional Case08 initial write-only candidate

Implement only after retry10 is terminal and does not establish a matched Rupi win.
Goal: complete the fresh application's workflow before spending requests inspecting
new files. Retry10 turn1 requested nine reads/four greps/two writes and produced no
entry point; that motivates a candidate, not a proven failure cause or benefit.
Risk: medium, because two agent launchers and per-turn tool restoration are coupled.

Select the existing recurring window3/cap12 for this candidate. Retry10 turn3
exhausts the budget after eleven read/grep tools and no recorded mutation; window12
does not ensure a mutation before that budget ends. Window3 restores earlier narrowing
on recovery, while the selected initial profile offers only writes. No benefit is proven.

Assume a fresh workspace copies SPEC/config inputs and no application/tests/README,
as `New-BenchmarkWorkspace` currently does. Stop this plan if existing application
inputs require inspection, tool restoration cannot be verified, or core changes are needed.

1. In `bench/compare-pi-rupi.ps1`, add optional `-Case08InitialWriteOnly`, default off.
   Extend `Get-BenchmarkTools` with a positive turn argument defaulting to1. Only
   selected Case08 turn1 returns `write` for both agents. Later turns restore Rupi's
   read/write/edit/grep and Pi's read/write/edit/grep/find/ls. Other cases are unchanged.
2. Before each selected Rupi invocation in `Invoke-AgentCase`, set the benchmark
   config's `tools.allow` to that turn's selected list. Preserve all other config fields.
   Pass the turn to Pi's `--tools` argument and per-turn allowlist metadata. Record
   `configured_initial_write_only` for both agents: true only on selected turn1.
   Keep native Pi progress/cap fields null; its copied Rupi config is unused.
3. For the selected initial Case08 prompt only, identify the supplied full SPEC and
   fresh workspace, request complete compact workflow in `leasefence/__main__.py`
   before helper modules, then public workflow tests, initializer and honest README.
   Restore the existing repair guidance on later turns. Preserve full SPEC, assertions,
   private fencing, resource cleanup, no-exec policy and oracle pass/fail-only feedback.
4. Extend dry-run guards for selected turn1 write-only and turn2 normal toolsets for
   both agents. Exercise Rupi policy configuration/restoration on synthetic config,
   asserting all unrelated fields survive. Default and non-Case08 profiles remain exact.
   Check selected initial and recovery prompts for full requirements/oracle isolation.
5. Run all-case dry runs off/default and low/budget2048/recurring/window3/selected
   initial-write-only/six turns/600s/grace6/cap12. Run diff/100-column checks and author
   invariant review. No core/provider/schema changes or new dependencies are expected.
6. Push/update draft PR141 before a fresh matched run. Verify copied per-turn policy,
   saved prompt hashes, binary/model identity and reference hashes. Record full results
   without reading generated source/model output/oracle diagnostics/aggregate results.

The benchmark CLI flag and summary metadata are the only interface additions; no
runtime API, canonical trace, storage migration or normal CLI defaults change.
No manual task implementation, oracle edits, weaker tests, tool-admission bypass,
concurrent model comparisons or local builds during the live pair are in scope.
Candidate acceptance remains oracle resolution in fewer turns, or fewer recorded
work tokens at equal resolution turns; report tests/help/docs and unknown usage separately.
Mark PR141 ready/merge only after a verified Rupi win and required final checks/review/CI.

Implement exactly this plan. Do not broaden scope. If the plan conflicts with the
codebase, stop and report the conflict instead of improvising.
Report files changed, tests run, deviations and unresolved risks in the ledger/PR.
