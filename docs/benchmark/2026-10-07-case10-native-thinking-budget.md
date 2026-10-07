# Case10: opt-in native reasoning budget

## Frozen Retry44 evidence

Run `bench-20261007-case10-inspection-retry44-rupi40-turns4-2400s` uses runtime source
`8540d45d369d87d4a8d876e7a0dd2d7ffe8a914b`, frozen checkout
`bcef12e7b103120648faa028cd6c56cefcd7fad8`, and debug binary SHA256
`0307EAFFE6C687843994C4A5F448BF91F41E047A74711DDF5F626D4CD0738ADE`.
All four recovery turns fail independent acceptance. No Pi comparison is launched.

| Turn | Call ms | Native outcome | Starts / closures / usage | Known work | Acceptance |
| --- | ---: | --- | --- | ---: | --- |
| 1 | 2,370,138 | TimeBudgetExhausted | 4 / 4 / 3 | 82,297 | Fail |
| 2 | 1,985,923 | Completed | 26 / 26 / 26 | 174,708 | Fail |
| 3 | 2,400,281 | Outer timeout; no native terminal status | 39 / 38 / 38 | 209,315 | Fail |
| 4 | 698,804 | Completed | 10 / 11 / 10 | 88,213 | Fail |

The snapshots total 7,455,146ms and 554,533 known work tokens: 464,600 uncached input
plus 89,933 output. Two started requests lack usage; their work remains unknown. The extra
closure in Turn4 does not supply missing usage. Snapshot tool counts total 91 requested,
89 ToolCompleted plus two ToolFailed terminal events, and zero recorded Unknown.
The completion metric counts successful results, not all terminal categories. Aggregate
equality does not establish distinct pairing or prove None effects; subtracting only
successful completions from requests does not establish unfinished operations.

Turn1 lacks required README/tests by safe filename/size metadata. Later project tests and
all four help checks pass, but independent oracle exit1 remains. Turn3 has one outer
timeout; no post-run verification timeout is reported. Public observations pass after
requests8/30 in Turn3 and8/9/10 in Turn4. Public passes are not independent acceptance.
ProgressCorrection is zero in Turns1-3 and one in Turn4: inspection guidance is reached,
without a configured win or inspection-specific acceptance attribution.

Completed summaries, known enums, filename/size metadata and process/model scalars are the
only actual-case evidence inspected. Generated application/tests/README content, model
output, traces, caller feedback, private oracle source/diagnostics and aggregate comparison
artifacts remain uninspected. Semantic failure causes and output/reasoning composition
remain unknown. The fixed recovery turns are one predefined attempt; they are not fresh
unchanged-runtime retries.

Before any production changes or owned inference probes, terminal audits verify the frozen
source/binary, harness/caller/helper, selected controls, shared prompts, full public SPEC,
three reference hashes, original physical model identity and context262144. Exact checkout
and tracked cleanliness, unchanged user usage-policy hash and helper identities also pass.

An owned PowerShell fixture finds an operator idle-check defect: `@(Invoke-RestMethod ...)`
can retain a nested response array, causing the simple property filter to report zero for
an active slot. Direct response assignment fixes the check; owned active-refusal/all-idle
tests pass. The prepared probe and terminal operator audit are corrected before use; the
future Pi launch already iterates the direct response correctly. Prior wrapped-array
assertions alone do not establish historical idleness. The corrected terminal audit confirms
four idle slots, unchanged model PID27356/parent33820 and the original helper processes.

## Root-cause analysis and owned verification

Turn1 makes only four requests within its native time budget. The current explicitly selected
`chat_template_enable_thinking` mapping encodes every enabled level as a boolean. It does not
provide a numerical native budget, so requested Low is not numerical Low enforcement.
This is an independently reproduced request-contract gap, not proof of the actual failure's
hidden reasoning composition or a semantic explanation for the independent oracle result.

The installed llama.cpp executable reports build10909, commit `a2878d30d`. Matching primary
sources accept `reasoning_budget_tokens` (with `thinking_budget_tokens` as an alias) and wire
it to sampling when the applied template supplies thinking markers:

- [Request mapping](https://github.com/ggml-org/llama.cpp/blob/a2878d30d/tools/server/server-common.cpp#L1272-L1285)
- [Sampling](https://github.com/ggml-org/llama.cpp/blob/a2878d30d/common/sampling.cpp#L310-L323)

Server metadata does not expose default reasoning budgets or those markers. Missing fields
remain unknown. After all four failures and the corrected frozen audits, three tiny owned
arithmetic requests use the original idle physical model, direct endpoint, temperature0 and
total output ceiling256. No helper/proxy/model restart or actual task content is involved.

| Requested native budget | Elapsed ms | Output tokens | Tokenized exposed reasoning | Correct answer |
| --- | ---: | ---: | ---: | --- |
| Omitted | 19,850 | 215 | 140 | Yes |
| 16 | 8,776 | 93 | 15 | Yes |
| 64 | 9,672 | 114 | 63 | Yes |

All finish with stop. Exposed reasoning is retokenized by the server's tokenizer; reported
reasoning-token usage is absent. These owned results are consistent with marker-dependent
enforcement on this installed model/template. They do not measure actual-case reasoning or
establish Case10 benefit.

An unchanged owned request-mapping driver passes existing default boolean/no-budget checks,
then fails because ProviderConfig rejects an explicit `reasoning_budget_tokens` option.
Retain this executable as the baseline for a future unchanged-driver comparison. Driver SHA256:
`1217A3AE88DB0C7624B01BC0E312BC0B2407D9AAECC7830E2A3EECEF286973FA`.
Baseline executable SHA256:
`ABD6502B2926883438151DE02D1A5616F7DC2AF3CC8F864082777C926FEE1BB2`.

Turn4's rupi process accumulates approximately597s CPU by15:25:21UTC, when correctly iterated
metadata reports zero active model slots. Its responsible code path remains unidentified.
A separate owned small-fragment Store fixture reports paired debug resume/restore
677.304ms for2,000 fragments and1,712.861ms for10,000 fragments, each with48 unstarted calls.
It does not reproduce the multi-minute CPU delay or rule out other actual-session costs.
No heavy fixture runs concurrently with the frozen attempt. Standalone fixture setup first
requires matching core/store feature artifacts and the existing Windows native import library;
these operator corrections do not change production or justify a case retry.

## Selected bounded change

Add optional positive `reasoning_budget_tokens` to endpoint compatibility and ProviderConfig.
Accept values1 through i32::MAX, reject zero/out-of-range values at both configuration
boundaries, preserve endpoint derivation/debug/serialization and omit the default None field.
No default endpoint behavior, dependencies, exposure declarations or durable event kind changes.

For an enabled thinking request, emit the exact native field. When an effective output ceiling
exists, cap the requested budget to ceiling minus1,024 answer tokens; omit when no positive
budget fits. Without an output ceiling, retain the configured native budget. Off always omits
the numerical field while preserving the existing declared dialect's disable encoding.
Use the effective wire ceiling, never the desired ceiling. Requested control is not a claim
of observed backend compliance or recovered hidden reasoning.

Add a distinct Case10 native-budget selector, default0, permitting the matched Low value2,048
only with direct template thinking and no old helper-budget routing. Rupi config gets the
native option; pinned Pi0.86.1 gets its existing `supportsThinkingTokenBudget` and
`thinkingTokenBudgetField=reasoning_budget_tokens` compatibility settings. Pi's installed Low
default is2,048 and its answer-room clamp is1,024. No Pi source, immutable caller/helper,
acceptance rule, shared prompt, SPEC, reference, physical model or unrelated case changes.
All other selected Retry44 comparison settings remain unchanged.

Verify the unchanged owned driver, config validation/round trips, default omission, dialects,
Off/Low transitions and fresh-turn initial Off behavior, effective output budgeting and matched
harness configs. Preserve uncertain-effect/approval/cancellation barriers. Run author invariant
review, full required local/CI gates and relevant performance budgets before freezing a fresh
attempt. Keep the PR draft and roadmap gate active. No fresh attempt is authorized by a passing
owned probe alone; the verified production enhancement and delivery gates must come first.

## Implemented contract and focused checks

The selected optional configuration/provider mapping and distinct matched Case10 selector are
implemented. Four new focused tests pass, covering core/provider configuration and wire mapping;
the existing two-fresh-turn initial-thinking fixture now also verifies numerical Off omission
and ordinary Low application. All103 provider unit tests pass. The unchanged owned driver now
passes against the new adapter, with original driver hash retained and after-executable SHA256
`CEAFF162C59DE5DF6275D1EFAEFB1864B7D14CDA157A00C0473BEF9FC85316AB`.

All14 owned harness guards pass. Pinned Pi0.86.1 uses only its existing native compatibility
configuration, with owned fake HTTP verifying Off omission, Low2,048, effective ceiling1,500
to budget476, ceiling1,025 to budget1, and ceiling1,024 omission. Default template fixtures
also pass. No live model endpoint receives these fixture requests. A syntax error in the
new owned PowerShell fixture is corrected before verification; no case retry is involved.
The Windows CI job now runs the native-budget configuration guard.

## Delivery verification and fresh freeze

Source `0b7221d1d9aa971a2198457acaae0f791b5c250f` passes full local formatting, core
all-features compilation, workspace Clippy with warnings denied, normal-scheduling workspace
tests, documentation and debug build. Three-platform source CI37650183033 passes. Parent
author invariant review passes with no blocking findings; no independent review is claimed.

Warm startup median8.97ms and fresh-inode cold median143.66ms pass the100/250ms budgets.
Canonical400-fragment/48-call resume+restore median133.132ms passes500ms. All five Store
restore budgets and all five context benchmark budgets pass. Rendering production is unchanged.
The18 other-case initial/recovery prompt hashes and both owned Case10 prompt variants match
the prior harness. Actual shared initial hash remains230589C5; the case source tree is
unchanged and Case10 has the same three reference files. Caller/helper hashes remain frozen.

One repeated owned Pi HTTP fixture reports an SDK-default connection error after earlier
passing evidence. Its exact connection cause remains unknown. An owned diagnostic using
explicit standard fetch passes; the fixture now restricts every request to its own server
origin and reports underlying fetch errors. Both default and native pinned Pi wire fixtures
pass with this change. This verifies configuration/body mapping, not Pi production transport
reliability. No Pi source or model endpoint is changed or used by these fake HTTP checks.
The operator prompt guard initially normalized source line endings before comparing the
historical actual hash; checking the actual source encoding corrects that guard and passes.
Neither fixture correction is an actual-case retry.

Freeze the fresh Retry45 profile with matched native2,048 and all other Retry44 selections
unchanged. Exact frozen-head CI must pass all three platforms before launch. The physical
model and original helpers remain in place. Fresh independent acceptance and a paired win
remain pending; full delivery checks and owned probes alone do not establish the goal.
