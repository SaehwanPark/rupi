# Recurring progress boundary

Status: verified runtime contract, merged in PR #143 as ab3dc33.

Final head a8edd208 passed CI on Linux, macOS and Windows before merge.

Case08 retry04 delivered two edits and a write, then ten reads in Rupi turn 3.
Turn 4 completed without any tool call while independent project checks still failed.
These are per-turn counters, not evidence that generated code or model reasoning was
inspected. The current one-shot progress contract permits both behaviors. This slice
adds an optional stronger runtime contract; it does not label the existing behavior a bug.

## Contract

Add a typed `ProgressBoundaryMode` to runtime configuration and `TurnLoop`:
`one_shot` remains the default; `recurring` requires an explicit progress limit.
Keep the existing builder compatible and add a mode setter. The CLI passes the
validated configuration. No case-specific policy, dependency or new event is needed.

| Observation | One-shot mode | Recurring mode |
| --- | --- | --- |
| Tool-bearing requests without progress reach the limit | Activate | Activate |
| Successful configured mutation has `Changed` effect | Satisfy for turn | Reset window |
| Later inspection reaches the limit | Remain satisfied | Activate again |
| Text completion before any observed progress | Existing behavior | Activate and correct |
| Text completion after progress with no active boundary | Complete | Complete |
| Text completion while boundary active | Retain/correct | Retain/correct |
| Failed or unchanged mutation | Does not satisfy | Does not satisfy |
| Unknown mutation | Stop for reconciliation | Stop for reconciliation |
| No effective executable progress tools | Semantic failure | Semantic failure |

The existing mutation registry, admission, approval and effect evidence remain
authoritative. Neither mode retries uncertain mutations. Required tool choice stays
a provider hint. Rejected completions remain canonical evidence but are omitted from
model-visible history and final report text. Recurring activation uses the same
runtime-owned control events, deterministic ordering and capability checks.

Default/read-only behavior, one-model execution, failover replay safety and lazy
startup remain unchanged. The caller chooses whether repeated implementation progress
is appropriate. Completing a runtime turn still does not prove project/oracle success.

## Owned implementation and verification

Owner: parent agent, single writer in the `rupi-recurring-progress` checkout.
Base: main 4174c1e. Paths: core config, runtime turn loop, CLI adapter, existing
behavioral fixtures, canonical design, architecture and roadmap.

Verify omitted-field/default compatibility, round trips and invalid mode/limit
combinations. Use fake providers/tools to cover read/change/read/change, initial
text-only correction, repeated text-only budget exhaustion, unchanged/failed tools,
Unknown mutation and loss of effective tool availability. Assert canonical versus
projected completion handling and retain existing one-shot regression expectations.

Before merge: required repository Rust checks, startup budget measurement and author
invariant review. Independent-agent review is not claimed. No model-backed child is
needed. Test evidence and residual risks must replace this pending status.

The draft implements the enum/config/CLI path, recurring reactivation and rejection
of an unearned initial completion. It preserves default one-shot guidance verbatim.
Fixtures cover repeated windows, canonical versus projected text, failed/unchanged/
Unknown tools, unavailable tools, exhausted mutation capacity, finalization bypass,
explicit no-tool assessment and disabled enforcement. A fake-server CLI fixture
checks that configuration reaches the live runtime and narrows subsequent schemas.
All these fixtures pass locally on the verified Rust sources.

The active Case08 retry04 retains its original binary, relay and loaded definitions.
Prepare source in this isolated checkout; defer builds until that pair is terminal.
Only a later fresh comparison may select recurring mode. Benchmark benefit and
Case08 resolution are unverified; Cases08 through 10 remain open.

## Verification and author invariant review (2026-10-04)

Source head fdbdb79 passed all-platform CI:
[run 37178770766](https://github.com/SaehwanPark/rupi/actions/runs/37178770766).
Local exact Rust/Cargo 1.98.1 via the installed stable route passed formatting,
core all-features check, workspace all-target clippy with warnings denied,
workspace tests and workspace docs without dependencies. All new config/runtime/
CLI fixtures pass. Logs remain in the ignored change workspace; no model-backed
child or independent-agent review was used.

Startup from the source checkout's release build measured 143.305 ms cold,
8.118 ms warm median and 9.712 ms warm maximum over ten warm runs, within the
250/100 ms budgets. The initial default Bash call selected WSL and could not find
native Cargo. Explicit Git Bash passed the benchmark; its existing script selects
native Python, so a Python wrapper was unnecessary. The verified prevention is in
LESSONS.md. No runtime, benchmark or latency-budget workaround was introduced.

Author invariant review: pass, no blocking finding. Reviewed config defaults and
validation, CLI propagation, canonical retention versus model-visible projection,
Changed effect evidence, Unknown reconciliation, tool/approval availability,
request/mutation budget endings, no-tool assessment and startup behavior. Existing
one-shot regression fixtures pass and their model-visible guidance is unchanged.
Recurring activation uses existing runtime-owned events and retains single-model
execution; unavailable tools fail semantically without a provider retry loop.

Residual scope: callers explicitly choose recurring enforcement for implementation
turns and still verify artifacts independently. It does not establish full project
completion, Pi parity for new settings or a Case08 comparison win. Retry04 is now
terminal and inconclusive; no local build overlapped that pair. This slice is now
integrated into the Case08 branch and explicitly selected for fresh retry05.
That live pair has no verified outcome yet.
