# Opt-in turn-time budget

Case10 retry19 used 16 model requests out of a cap of 40 and still reached the
1,200-second watchdog. Fifteen of its 18 completed tool calls inspected files;
the filtered inventory contained application files but no tests or README.
Acceptance and project tests failed, while help passed. This evidence does not
identify the task's semantic defect. Source review does verify a separate budget
gap: the runtime limits request counts and provider-request durations, but has
no total turn-time deadline or model-visible remaining-time guidance.

The next enhancement adds an optional cooperative turn-time budget. It must be
implemented and verified before another development attempt; automatic retry
continuation is disabled during this diagnosis/fix cycle.

## Contract

- Add optional `limits.max_turn_duration_ms`, disabled when omitted. Validate a
  positive value no greater than 86,400,000 ms. Existing defaults and serialized
  configurations remain unchanged.
- Begin a fresh monotonic deadline for each admitted turn. Resume does not reuse
  an old turn's deadline. Failed reconciliation remains a safety barrier.
- Extend linked cancellation tokens with an optional monotonic deadline. A
  deadline-aware child inherits explicit parent cancellation and cancels provider
  and tool work cooperatively without setting the parent's cancellation flag.
  No timer thread or eager service is required.
- Emit runtime-owned `TurnTimeBudget` control guidance before model requests:
  configured budget, observed elapsed/remaining time, and remaining request count.
  Preserve its canonical event, projection, sequence, and runtime provenance.
  This is policy guidance, not user text or native model reasoning.
- On deadline cancellation, complete the turn as `TimeBudgetExhausted`. Explicit
  caller cancellation keeps `Cancelled`; unresolved mutating effects keep their
  reconciliation barrier. Do not replay uncertain requests or mutations, dispatch
  incomplete calls, fabricate usage, or initiate recovery inference after expiry.
- Cancellation is cooperative, not a guarantee that arbitrary foreign operations
  instantly stop. Side effects crossing interruption remain `Unknown`/`Possible`.
- Keep admission, exact tool matching, fingerprints, single-model execution, and
  lazy adapters intact. No case-specific workflow or artifact-name enforcement.

## Implementation boundary

Core: optional configuration, linked-token deadline, typed control/status variants.
Runtime: per-turn deadline state, guidance, cancellation classification, fresh-turn reset.
CLI: wire the optional configuration and render an honest terminal result.
TUI: render the new typed terminal status with existing state styling.
Benchmark: explicitly configure the Case10 runtime budget below the outer watchdog,
record it as a native Rupi control (Pi unavailable/null), and use one-turn development
screens. A failed screen requires analysis and a verified fix before a new attempt.

## Verification

- Token fixtures: deadline inheritance, parent isolation, and explicit cancellation.
- Config fixtures: omission/default compatibility, round trip, zero/oversized rejection.
- Runtime fixtures: bounded cancellation during an active request, durable guidance
  provenance, no partial mutation dispatch/replay, explicit-cancellation precedence,
  fresh deadline on the next turn, and unchanged Unknown reconciliation behavior.
- Native provider fixture: an active stream obeys deadline cancellation without a
  repeated POST or fabricated completion. Keep existing transport regressions passing.
- Required fmt/check/Clippy/workspace tests/docs, debug build, startup, rendering,
  and session/context performance checks appropriate to the changed boundaries.
- Parent invariant review and updated architecture/changelog/roadmap evidence. Keep
  acceptance benefit and Case10 completion unproven until observed.
- Freeze source/binary/model/profile/prompt/references before a new one-turn screen.
  No source changes/builds during inference. Fresh matched Pi follows only a passing
  frozen Rupi result; any eventual win requires complete paired evidence and final CI.

The verified store-resume and long-line edit-hint fixes remain part of the active
PR145. Retry19 is incomplete: only turn1 is verified; its already-started turn2 was
stopped, abandoned, and unverified. All model/relay processes and artifacts are preserved.
