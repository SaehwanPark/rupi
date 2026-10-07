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
