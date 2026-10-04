# Case 07 Lease Cascade Completion Record

Updated: 2026-10-03

## Status: completed and merged

The authorized objective was a strict Rupi oracle win against pinned Pi 0.86.1.
Retry 29 achieved it: Rupi passed on turn 3; Pi failed all four oracle checks.
[PR #139](https://github.com/SaehwanPark/rupi/pull/139) merged on
2026-10-03 at 22:33:31 UTC (6:33:31 PM ET), at commit
`64c9ada05d637d603b1c3ac11b2c28cd25b9ae53`.

There is no remaining Case07 run, quota wait, user decision, or merge step to resume.
For subsequent development, use [ROADMAP.md](../../ROADMAP.md) and the current user task.
Broader series/runtime gates remain active. Case08 was outside this completed slice.

## Winning comparison

Run: `bench-20261003-case07-budget2048-low-retry29-rupi12-matched4-600s`.
Harness revision: `c4980be`; launch documentation revision: `c9d30e1`.

| Agent | Turns | Recorded work tokens | Tools | Agent call time | Oracle |
| --- | ---: | ---: | ---: | ---: | --- |
| Rupi | 3 | 89,208 | 22 | 1,494,500 ms | Passed turn 3 |
| Pi 0.86.1 | 4 | 61,382 | 21 | 1,795,363 ms | Failed all four turns |

Project tests and all three CLI help checks passed on every recorded turn for both agents.
Rupi resolved after its turn 3 outer timeout and stopped without a turn 4.
Rupi recorded zero tool failures or Unknown outcomes; Pi's corresponding metrics were null.

Configuration:

- Local model `qwen3.8-flash-next`, low thinking effort for both agents.
- Shared configured thinking budget of 2,048 tokens through the benchmark-only local relay.
- At most four turns, 600-second outer agent-call limits, six-second provider grace,
  and 16,384 output tokens.
- Rupi model-request cap of 12 per turn; Pi retained its native request policy.
- Native tool sets: Rupi `read/write/edit/grep`; Pi `read/write/edit/grep/find/ls`.
- Explicit Native reasoning exposure and configured native reasoning replay for Case07.
- Isolated Rupi global skill discovery; Pi retained its discovery-disabling flags.
- Existing Rupi binary; no Rust source changes or binary rebuilds in this slice.

Only Rupi's request cap changed from 8 to 12 relative to retry28. One configured comparison
establishes the oracle outcome; it does not establish default-runtime superiority,
causation by that setting, or conformance to every public requirement.
Recorded work tokens sum inference input and output; unrecorded inference is unknown.
Timing totals sum `call.elapsed_ms` and exclude verification/harness time.
Configured reasoning controls and relay counters do not prove actual past model-visible
reasoning, template enforcement, or total inference.

## Delivery and process closeout

[Final PR139 CI](https://github.com/SaehwanPark/rupi/actions/runs/37158459841) passed on
Ubuntu, macOS, and Windows at evidence head
`ba72a8c03612974ea2a697a817f184c09cfcdf9e` before merge.
The runner exited successfully; runner, wrapper, and direct children were verified gone.
The task-owned relay was stopped and verified gone after merge; the shared model server
was preserved. Those are closeout observations, not current process identities or commands.

## Historical evidence and audit boundaries

The [comparison ledger](2026-09-29-case07-lease-cascade-ledger.md) preserves the baseline,
retries, incomplete attempts, and verified per-turn results. Its launch/status/usage entries
are dated observations. They do not direct a new launch or a wait for an old reset window.
The [full pre-cleanup handoff snapshot][prior-handoff] preserves detailed source reviews
and earlier session checkpoints in version control.

Local run artifacts, where retained, are under `.benchmark/runs/` followed by the run ID.
For any subsequent audit, preserve the original evidence restrictions:

- Permitted: per-turn `summary.json` and `files.json`, generated help stdout/stderr,
  selected configuration fields, repository/harness source, public specifications,
  parent-authored drafts, selected numeric process/server/relay metadata, native CLI help,
  and numeric skill-listing counts/lengths.
- Keep unread: acceptance source, runner/agent output, session traces, actual generated
  prompts or model-request payloads, aggregate `results.json`/`partial.json`, project-test
  or oracle diagnostics, and generated application/test/README contents.
- Do not run standalone project tests or oracles as part of auditing these results.

[prior-handoff]: https://github.com/SaehwanPark/rupi/blob/64c9ada05d637d603b1c3ac11b2c28cd25b9ae53/docs/benchmark/2026-10-02-case07-handoff.md
