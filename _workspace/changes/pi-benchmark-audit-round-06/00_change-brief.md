# Round 6 audit remediation

Change: pi-benchmark-audit-round-06
Owner: change owner
Status: verified; PR #126 merge pending
Inputs: `audits/pi-benchmark-audit/round06.md`, `ROADMAP.md`, `ARCHITECTURE.md`, `COMPATIBILITY.md`, canonical design

## Bound slice

Address the Round 6 audit findings in order of risk: (1) prevent further autonomous mutations after a mutating `Unknown`; (2) separate internal response rejection from user cancellation; (3) bound per-turn tool calls; (4) reserve answer headroom without a configured wire output limit; (5) calibrate token estimates by model; (6) budget provider-mapped request shape; (7) reject unknown fixed-schema config keys; (8) allow bounded model-readable recovery of reduced tool payloads.

## Acceptance criteria

- An uncertain mutating outcome forms a durable barrier: later batch calls and automatic model requests do not proceed; restored sessions and later turns cannot mutate until reconciled.
- Internal response-bound rejection remains a protocol failure and does not mutate user cancellation state.
- Per-turn requested total and mutating tool calls are bounded before dispatch, with terminal results for denied calls.
- Hard context-fit checks reserve useful completion room even without an explicit wire output cap.
- Successful provider usage updates bounded high-side estimation calibration scoped to provider/model/request dialect; calibration never reuses stale actual counts as current estimates.
- Context budgeting measures the provider-mapped request shape, including strict-schema normalization.
- Fixed-schema user config rejects unknown keys with useful parse errors.
- Reduced payload recovery is read-only, session-scoped, opaque-reference-only, bounded to 4 KiB ranges/16 MiB decoded payloads, and re-exposes only reduced-output references still visible after resume.
- Focused regression tests and the repository's relevant checks pass; architecture and roadmap claims match verified behavior.

## Non-goals

- No automatic execution or replay of uncertain mutations; no claim that arbitrary `exec` can be reconciled automatically.
- No change to provider wire output caps when none were explicitly configured.
- No tokenizer service or cross-model calibration.
- No unrestricted filesystem path access for payload recovery.
- No local-model benchmark claim without actual measured evidence.

## Ownership and verification

One writer (change owner) for all code and docs in this checkout. The independent read-only invariant review findings were addressed before the remaining implementation. Focused regressions and full verification passed: `cargo fmt --all --check`, `cargo check -p rupi-core --all-features`, `cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, `cargo doc --workspace --no-deps`, `bash bench/startup.sh --json bench/results/startup-ci.json` (cold 136.49 ms; warm mean 6.33 ms), and `bash bench/context_prefill.sh` (all five budgets passed). No local-model benchmark claim is made.
