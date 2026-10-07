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
