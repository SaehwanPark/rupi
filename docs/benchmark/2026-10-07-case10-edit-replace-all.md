# Case10: preserve valid single-pass replace-all edits

Retry42 fails independent acceptance in all four turns. Turn2 exits101 without native
terminal status after9 completed requests/all usage known and an unfinished edit
lifecycle in scalar counts. Exit101 is consistent with a Rust panic, but actual stderr
and generated arguments remain uninspected. Exact actual causality is unproven.

Owned source inspection finds edit.rs:173 asserts that replace_all leaves no occurrence
of find. This is not a valid postcondition of single-pass replacement. A replacement
may retain the needle; replacing an original match may also create a new match against
an unmatched suffix. Repeatedly replacing newly inserted text would violate the contract
and can fail to terminate.

The ignored owned driver .benchmark/owned-edit-probe/main.rs invokes the actual cached
debug ToolRegistry/EditTool on sample.txt:token + token, find token, replacement
token_safe, replace_all=true. It reproduces the assertion panic after the start observer
and before any filesystem write; catch_unwind confirms the owned file is unchanged.
Driver SHA C01FA2B225B5E8523CAE2657E17089201842D2FEF4FACE0012DB096BF71AC5C8.
The first standalone link omitted Cargo's native Windows library search path; adding
the cached path fixed the driver only. No Cargo rebuild, new inference, supervisor or
frozen source/binary change occurred. Frozen Retry42 audits subsequently pass.

Parent owns this bounded builtin fix and author review. Remove the false debug assertion
and explain why residual/new matches are legitimate. Add actual EditTool fixtures for
replacement containing find and a match formed across an unmatched suffix; assert exact
output, successful Changed state, and single-pass behavior. Retain identical-argument
refusal, ambiguity rules, cancellation checks, atomic write and Unknown reconciliation.
No edit argument schema, budget, model or caller change.

Verify focused edit/registry tests, full workspace delivery gates and startup budget.
Existing unchanged Store/context and harness/profile gates remain applicable; verify
new binary/source and exact source/frozen-head all3 CI before another attempt. Keep the
next fresh four-turn profile identical to42 so the edit fix is the only new variable.
No manual modification of generated case work or oracle visibility/acceptance changes.
PR145 remains draft until independent acceptance and a fresh matched Pi comparison win.

## Implementation and focused evidence

New actual EditTool regression fails on the unchanged implementation at edit.rs:173,
then passes after removing only that false postcondition. It covers token->token_safe
at multiple original matches and aaa/aa->a yielding aa across an unmatched suffix.
Both assert exact single-pass output, Succeeded and Changed. All83 tools unit tests and
focused all-target Clippy pass, including ambiguity/refusal, cancellation, atomic-write,
exact diagnostics and no-replay/reconciliation fixtures.

Parent author invariant review: pass, no blocking findings. Original match counting,
the valid uniqueness assertion, replacement algorithm, prewrite cancellation and atomic
write remain unchanged. No event or provenance change, catch/replay shortcut, new model,
budget, provider, schema or dependency. Debug behavior now follows the existing release
behavior for valid retained/new matches. Actual turn2 causality remains unproven.
Full workspace/debug/startup gates and source CI are pending at this commit.

## Verified gates and Retry43 freeze

Source297ec094775fb6914584ce93004ed9b1dbb9a73a passes full workspace fmt,
core all-features check, all-target Clippy, tests, docs and debug build. Startup133.335ms
cold/8.064ms warm median/8.778ms max passes existing budgets. Store/context performance,
all13 harness guards, profile/prompt/SPEC/reference and owned four-turn protocol checks
from unchanged c50a2d2 remain applicable; this leaf edit correction changes none of those
interfaces or algorithms. No new inference has occurred since Retry42.

The patched owned registry driver verifies retained-needle and boundary cases with one
start observer, no panic, Succeeded/Changed and exact single-pass file bytes. SHA
A95D6EB05D5AA2F4A7D11ADDC35E0441FD1556882F5A8D00A55B5AB1EF2ED207.
The original driver/executable remains the before-change evidence; neither driver reads
or edits any actual case artifact. Actual turn2 attribution remains unproven.

Freeze fresh run bench-20261007-case10-editfix-retry43-rupi40-turns4-2400s with
runtime297ec09 and callerfa6821860f6a2e94d4e5d1ecd86170e3eb00e072. Binary
D25F0D7FF5E0CB09402E66E21130422DF5B41639E6233E93D352B76F2D6F0B04;
harness91CED3EF27C50DDD31BA08CFBD3338E42D8B6CA319BD4CC051543835DC5F1D16,
callerEB7829961FC2AB93AC36E8FE4971F5EA18F07C8DE6136019110373775DF1E6AC,
helperA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7.
Same physical PID27356/direct8000/globalLow/initialOff; all42 four-turn/per-turn limits,
shared prompt, public SPEC, acceptance, native-only Pi-null controls and public caller
protocol remain unchanged. No helper/model restart or allowance increase.
SourceCI37602883681 and exact freeze-head all3 CI must pass before launch. A fresh matched
pinned Pi run remains conditional on independent rupi acceptance; no configured win yet.

## Prelaunch contract correction

Source297ec09/frozend36f150 CI each passes all3; no inference was launched. Author review
then identified a related false risk claim: edit metadata promises idempotence, while
valid retained/new matches can make an identical invocation change external state again.
The core contract defines idempotent as guaranteed convergence to the same external state.
Correct edit metadata to mutating/non-idempotent, demonstrate two distinct explicit calls
produce different states, and retain Never for a committed result/ReconcileFirst for
Unknown. Update the header/comment rather than claiming all redeliveries are refused.

| Boundary | Required behavior |
| --- | --- |
| Fresh valid edit | Single-pass success with Changed effect |
| Explicit distinct call retaining find | May change again; metadata must not promise convergence |
| Reuse of committed result | Never execute again |
| Uncertain edit | Reconcile first; no automatic replay |
| Prior fingerprint with idempotent=true | Definition mismatch requires manual inspection |

The durable fingerprint already includes idempotent, so this correction changes its risk
identity without a schema or stable implementation-version change. Existing old uncertain
calls must not be silently treated as the new definition. Add actual registry coverage.
This supersedes the prelaunch source/binary freeze above; keep the same Retry43 run id and
all comparison controls, but require new source/frozen-head CI and fresh delivery evidence.

Corrected metadata now declares mutating/non-idempotent. All85 tools tests and focused
Clippy pass. Actual repeated-call fixture produces token_safe then token_safe_safe,
demonstrating the false convergence claim. Committed results remain Never and Unknown
remains ReconcileFirst. Actual registry fixture rejects the prior idempotent=true
fingerprint as RequiresManualInspection while matching current identity can report
Unmodified without changing bytes. Architecture records the verified risk/migration
boundary. Parent author review now passes for both execution and risk semantics; no
independent-review claim. Source/freeze hashes above are superseded before any inference.

## Final corrected-source verification and Retry43 freeze

Runtime source953328e26f5a0887d6eaee26aad7f491d6418f54 passes workspace fmt,
core all-features check, all-target Clippy, tests, docs and debug build. All85 tools unit
tests pass, including repeated explicit calls and old-fingerprint reconciliation.
Startup141.518ms cold/8.386ms warm median/8.643ms max passes the existing budgets.
All13 harness guards, full selected profile/SPEC/three reference-file hash guards,
owned four-turn recovery protocol and18 unchanged non-Case10 prompt hashes pass again.
The current actual-registry owned driver confirms both retained/new-match cases succeed
once with Changed, exact single-pass bytes and no panic. No actual case content was used.

SourceCI37604846978 succeeds on Windows, macOS and Linux. Parent author invariant review
passes; no independent-review claim. Store/context algorithms remain unchanged from the
verified c50a2d2 performance evidence. Actual Retry42 turn2 causality remains unproven.

Freeze Retry43 with source953328e and debug binary
3805153DDD600CA0081E7CCCD1E6E08623524B8BB09FA547A057D4CC1EAA1E70.
Caller, harness, helper and shared-prompt hashes above remain unchanged. This final freeze
supersedes source297/d36 entirely before inference. Same physical model, all Retry42
comparison controls and four-turn recovery protocol; no allowance increase. The exact
new freeze-head CI must also pass all three platforms before launch. A fresh matched
Pi0.86.1 run remains conditional on independent rupi acceptance; Case10 is still active.

## Retry43 terminal evidence and next recovery slice

All four recovery turns fail independent acceptance and project tests; all four help
commands pass on every turn. Native statuses are BudgetExhausted, BudgetExhausted,
CompletionCheckExhausted and TimeBudgetExhausted. Calls total8,699,028ms. Known work is
1,118,758 tokens (1,043,395 uncached input +75,363 output), with156 request starts and
closures but155 usage records. Turn4's last request has unknown work; this is not a
fully known total. Its typed failure is Cancelled/Streaming/CommittedOutput with partial
output after39 starts. No outer or post-run verification timeout is recorded.
There are194 tool requests,178 completed tools,16 Failed and zero recorded Unknown.
These counts do not identify the actual failed tool kinds or effects, and absence of an
Unknown record is not proof of certain effects across interruptions. Failed caller checks
run after8/11/14/17/20/23/26 starts each turn, plus a fresh final check after38 on turn3.
Review runs after23 each turn. No acceptance improvement or configured Pi win is proved;
no Pi run is launched for this failed screen.

Terminal audits pass before any production source/build change: exact2c6153c freeze head,
clean tracked checkout, runtime953328e and binary3805153D, unchanged caller/harness/helper,
all saved controls, full public SPEC/shared prompt and three acceptance reference hashes.
The physical model remains PID27356/parent33820 with qwen3.8-flash-next, health ok and
zero busy slots. All three existing helper PIDs remain present. The user-edited root usage
policy hash remains3CEE11E5D4D8C8CA7CCF34F87A64B18BB183D4AF9AF79AB964AE19D4EF39B496.
An extra owned audit initially required the historical launcher parent to remain alive;
that unsupported condition was removed, retaining the model's recorded parent identity.
No model/helper or inference change resulted from this audit-script correction.

Owned root-cause investigation demonstrates a separate recovery limitation in
TurnLoop::progress_tool_is_exposed: an active opt-in progress boundary hides all reads
even after a durably started selected edit fails with proven None effect. Actual registered
EditTool confirms the owned wrong-anchor failure started and left sample.txt unchanged.
With five request slots, an adaptive deterministic provider can neither inspect nor repair:
four edits fail and the runtime exhausts its budget. A retained repair-before.exe fails its
expected Completed assertion (exit101); driver SHA256
F84C2BA0CCDAF8C3569E8E5A9C513B97A00C00F55C033C98EB690EDFBBAC8D5F.
The frozen source/binary above are used. This proves an owned runtime limitation, not the
semantic cause or contribution of the actual Case10 failures; actual content is uninspected.

The next bounded runtime slice permits one read-only inspection attempt after a started,
known Failed selected mutation with proven None effect, while the opt-in boundary is
active and ordinary inspection-plus-repair capacity remains. Reads cannot satisfy Changed
progress. Advertised bindings, registry/path policy, approval, uncertain-effect barriers,
cancellation and every existing request/tool/mutation/check/time cap retain authority.
Unstarted/refused/stale calls, read failures and Unknown/Possible/Unverified effects cannot
grant inspection. Enforce consumption before validation and across a multi-read batch;
grant only after committed batch results. Clear on Changed progress and new turn/finish.
Default turns stay unchanged. Existing ProgressCorrection provenance carries static guidance.
Owned repair and safety fixtures plus full local/source/freeze checks must pass before
fresh Retry44. Case10 and the broader roadmap gate remain active.
