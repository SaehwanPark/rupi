# Case10: explicit idle budget and typed failure evidence

Retry35 failed with Timeout after1,295,184ms, before review or caller checking. Only
receiptledger/__main__.py was listed. Sixteen request spans closed but only fifteen had
usage; unfinished work is unknown. Frozen source/binary/harness/host/profile/prompt/SPEC/
reference audits and both three-job CIs passed before this slice.

Owned config inspection verifies request_timeout_ms2394000 but read_timeout_ms omitted.
ProviderConfig resolves omission to300000. The shorter idle limit can terminate a quiet
request while native2370000ms remains. Retry35's existing summaries do not expose phase
or exact timeout mechanism; no actual trace, model output, generated file, caller
diagnostic, or oracle content was inspected. Causal attribution remains unproven.

Bounded changes:
- Record optional typed failure metadata on ModelRequestCompleted: category, phase,
  partial-output flag and replay safety. Exclude message, raw provider content and
  credentials. Old records and Pi imports leave it absent; absence proves no success.
- Populate metadata from the runtime's already classified failure before closing the
  request span. Preserve usage, failed-response isolation, quarantine, retry/failover,
  cancellation and Unknown semantics.
- Add explicit Case10 native idle-timeout selection, default0/omitted, positive and
  no larger than the existing total provider deadline. Leave other cases and Pi unchanged.
  Expose selected timeout and whitelisted failure metadata in per-turn summaries.
- Test failed/successful requests, old/new event serialization, safe metrics and invalid/
  omitted/case-isolated config with owned fixtures. No actual-trace backfill.
- Next screen, only after checks/review/exact-head CI, will select idle2394000ms with
  total2394000/native2370000/outer2400000 and otherwise retain Retry35's profile.
  Native cancellation remains the earlier bound. A longer idle allowance can spend
  more time on a genuinely stuck request; no new retry or latency guarantee is added.

Source ownership: core event and runtime request completion, corresponding constructors/
serialization fixtures; benchmark config/metrics and owned guards; architecture,
compatibility and roadmap notes. No model/helper restart, prompt edit, acceptance
weakening or manual generated implementation. Case10 and PR145 remain active/draft.
Configured acceptance, benefit, and paired win remain unproven.
