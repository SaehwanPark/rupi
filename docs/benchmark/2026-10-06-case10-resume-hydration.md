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
