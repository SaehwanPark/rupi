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

## Verified implementation and Retry36 freeze

Source/runtime8d046aa7b87683989c0277294b63e98b8dc8f96d is pushed.
Required local fmt/core-check-all-features/Clippy/workspace tests/docs/debug build pass:
225 runtime,138 core,100 provider,25 CLI and28 store event-roundtrip tests. Owned tests
cover ambiguous timeout/no invented usage, cancelled partial output, successful absence,
legacy omission and exact stored failure facts. All ten harness guards, full selected
workspace config, unchanged shared prompt230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270,
18 other prompt hashes and copied public SPEC/three reference hashes pass.
The pinned Pi fake-wire check also passes against the new debug binary.

Parent author invariant review: pass, no blocking findings. Optional failure facts are
copied before the existing request terminal event; failed output/usage isolation, event
ordering, retry/failover/quarantine, fresh-turn cancellation, effect barriers, redaction,
projection, replay and normal rendering retain their contracts. Pi/legacy records do not
invent failure information. Safe metrics retain only allowed categories/phases/replay states,
actual boolean flags and request positions; provider/control/model text stays excluded.
The benchmark idle override is opt-in, Case10-native only and no larger than the existing
total deadline. Native cancellation remains authoritative; there is no extra request,
backup activation, hidden reasoning claim, acceptance change or actual-trace backfill.

Startup139.745ms cold/7.955ms warm median/8.520ms max passes. Five restores
117.50/725.20/2890.00/2780.35/5309.95us and contexts.4/.1/0/0/.3us pass.
No rendering path changed. SourceCI37514973343 and exact freeze CI must both pass all3
platforms before Retry36 starts.

Frozen intended run:
bench-20261006-case10-idle2394-preflight-repair3-reserve8-template-off-args2048-first8192-check8-mut32-review300-turn2370-retry36-rupi40-screen1-2400s.
One Rupi screen, Case10, maxTurns1, request40, outer2400s/provider2394s/native2370s.
Explicit read2394000ms is the sole changed model/runtime control versus Retry35.
Same physical model PID27356/8000, direct endpoint, global/initialOff,
chat_template_enable_thinking:false, maxOutput32768/first8192/firstArgs2048,
initial boundary, recurring progress3, mutation32, checks8/on-review,
timeReserve300000/requestReserve8/repairWindow3. Existing caller preflight remains.
Matched Pi runs only after configured Rupi acceptance; Pi native idle/control fields null.

Debug binary SHA4CDDDFB34B9E23BC71E70951E3EBBE93C7876337D77299C86628F66A1ED22188.
Harness SHABB9071E352A7583D3AC2B0E4F02225A2C047CFAAAD6DB2FD9CD6E7211289F39A.
Caller sourcefa6821860f6a2e94d4e5d1ecd86170e3eb00e072 and
SHAEB7829961FC2AB93AC36E8FE4971F5EA18F07C8DE6136019110373775DF1E6AC unchanged.
Original helper SHAA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7 unchanged.
Fetch/prune verifies only main and active Case10 local/remote branches.
Root user policy SHA3CEE11E5D4D8C8CA7CCF34F87A64B18BB183D4AF9AF79AB964AE19D4EF39B496 preserved.
Acceptance, exact timeout cause, benefit and paired win remain unproven.
