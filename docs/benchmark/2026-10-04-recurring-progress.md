# Recurring progress boundary

Status: design draft; implementation and verification pending.

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

The active Case08 retry04 retains its original binary, relay and loaded definitions.
Prepare source in this isolated checkout; defer builds until that pair is terminal.
Only a later fresh comparison may select recurring mode. Benchmark benefit and
Case08 resolution are unverified; Cases08 through 10 remain open.
