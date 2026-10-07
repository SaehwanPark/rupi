# Case10: bound repeated trace hydration during resume

Retry41 failed independent acceptance in all four turns. Turns3/4 reached the
2400-second outer timeout; their native outcome and unfinished request usage remain
unknown. Passing cooperative cancellation fixtures do not establish the cause of
those actual timeouts. Generated work, trace contents and oracle diagnostics remain
uninspected.

Owned offline evidence identifies a separate reproducible runtime cost. A canonical
fixture with400 externalized reasoning fragments and48 unstarted assistant tool calls
takes median25,689.462ms for Store::resume and13,270.979ms for subsequent Store::restore
(three samples, debug build). The CLI performs both before starting the native turn
clock. Assistant-call recovery and projection alignment each rehydrate every preceding
trace event for each call. Existing large-session benchmarks measure SessionLog alone.
This reproduces preturn overhead exceeding the30-second outer/native gap; attribution
to Retry41 remains unproven. The first owned probe incorrectly expected one restored
message; correcting it to one assistant plus48 safe Failed results required no runtime
change or inference.

Parent owns this bounded Store implementation and author review. Hydrate externalized
events once per tool-request validation pass, retain only ToolRequested candidates,
and borrow inline requests. Preserve canonical ordering, response-local call identity,
duplicate/mismatch rejection, legacy parentless matching and safe unstarted recovery.
Validate unrelated externalized field paths, uniqueness, sizes, hashes, UTF-8 and event
schema rather than merely filtering on inline event type or call id. No durable schema,
public interface, deadline, model, prompt, tool permission or allowance changes.

| Input | Required behavior |
| --- | --- |
| Matching requests | Same scoped projection and lifecycle validation |
| Missing unstarted call | Explicit requested/Failed closure; no execution |
| Started uncertain mutation | Unknown retained; no replay |
| Corrupt unrelated externalized event | Fail closed before provider admission |
| Externalized request strings/identities | Restore before matching; no inline assumption |
| No projected tool calls | No extra request-hydration pass |

Add owned regression coverage and a committed full Store resume/restore benchmark.
Re-run the identical offline probe for comparable measurements, then all Store tests,
workspace delivery gates, startup/large-session/context budgets and harness guards.
Review changes against provenance, canonical validation and Unknown invariants.
Push source evidence and require source/frozen-head CI before another model attempt.
Keep the next comparison profile unchanged so this enhancement is the only new runtime
variable. A faster fixture is not a configured Case10 win; PR145 remains draft until
independent acceptance and a fresh matched Pi comparison establish that win.

## Implementation and owned verification

Both matching paths now use one pass that borrows inline ToolRequested events and
restores externalized events once, retaining only request candidates. Existing scoped
matching predicates are unchanged. Request argument payloads remain transiently owned
when externalized; reasoning/text payloads are validated and dropped immediately.
Projection validation also rejects malformed fields beyond the first matching request
rather than accepting a corrupt suffix. No provider/effect admission precedes validation.

Store181 unit tests,28 event round trips,9 Pi import tests and3 new history integration
tests pass. New coverage exercises missing/unstarted closures with externalized history,
argument restoration, and unrelated duplicate/missing/schema-invalid fields with no
trace append on rejection. Existing reused-id, duplicate/mismatch, projection failpoint,
Unknown and unresolved-effect fixtures pass. Focused Clippy passes.

The identical ignored offline probe now reports resume1200.048/885.760/958.574ms and
restore470.402/529.403/545.071ms. Medians958.574+529.403=1487.977ms versus the original
38960.441ms sum, about96% lower. The committed release benchmark reports resume93.563ms,
restore50.255ms and paired total145.100ms across five samples, within its500ms budget.
Release and debug results are separate measurements, not a direct before/after pair.

Owned fixture corrections: use ContentBlock::ToolResult (Message has no tool_results
accessor), borrow the TraceJournal path, and test supported externalized arguments.
An identity-externalization fixture was rejected by existing canonical lifecycle checks;
do not weaken those checks to satisfy an invalid fixture. Clippy caught use of a Rust1.87
integer method against MSRV1.85 and a single-element loop; use existing modulo convention
and direct binding. The first release benchmark passed latency but failed output writing
because Cargo runs benches from the package directory; use an absolute JSON path.
These owned test/operator corrections did not justify or launch a model retry.

Parent author invariant review: pass, no blocking findings. Canonical blobs and schema
still verify before admission; response identity/ordering and legacy missing metadata
rules remain unchanged. Recovery synthesizes only proven-unexecuted Failed calls;
Unknown barriers, provenance, redaction and single-model execution remain intact.
Store open/startup remains lazy. Residual risk: retained externalized request arguments
add transient memory proportional to request payloads; no hydrated reasoning is cached.
Actual Retry41 timing attribution and Case10 semantic defects remain unknown.
Workspace gates and existing performance budgets are still running at this commit.

## Verified gates and Retry42 freeze

Final source c50a2d2213688000f981d2281a383e16d8a5813c passes full workspace fmt,
core all-features check, all-target Clippy, tests, docs and debug build. Rechecked final
bench formatting/Clippy and full canonical release benchmark:89.879ms resume,
47.761ms restore,139.456ms paired total within500ms. Startup145.971ms cold/9.300ms
warm median/10.215ms max; five SessionLog cases95.30/619.90/2740.65/2585.00/5227.50us
and five context cases0.5/0.1/0/0/0.3us pass their existing budgets.

All13 harness guards and owned four-turn recovery fixtures pass. Full selected native
profile, copied public SPEC/three acceptance hashes and all18 non-Case10 prompt hashes
remain unchanged. Root user policy3CEE11E5D4D8C8CA7CCF34F87A64B18BB183D4AF9AF79AB964AE19D4EF39B496
is preserved. Fetch/prune finds no merged/outdated branch besides protected main;
the active Case10 branch remains necessary. No new dependency or schema was introduced.

Freeze fresh run bench-20261006-case10-resume-retry42-rupi40-turns4-2400s with sourcec50a2d2,
callerfa6821860f6a2e94d4e5d1ecd86170e3eb00e072 and binary
A22BE9F023D686F36D0A5CA30E29FA3D10F71604DAC26D9CBF41A6FF2430823F.
Harness91CED3EF27C50DDD31BA08CFBD3338E42D8B6CA319BD4CC051543835DC5F1D16,
callerEB7829961FC2AB93AC36E8FE4971F5EA18F07C8DE6136019110373775DF1E6AC and
helperA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7 remain frozen.
Shared initial prompt230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270.
Only canonical resume implementation changes from Retry41; all four-turn/per-turn limits,
model, globalLow/initialOff intent, prompt, acceptance and caller protocol stay identical.
No helper/model restart or oracle visibility change. SourceCI37564263389 and exact
freeze-head all3 CI must both pass before inference. Final timeout/usage facts will be
reported as observed; no backfill of prior traces or causal inference from absent facts.
