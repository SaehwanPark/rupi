# Bounded initial tool arguments

Retry27 exhausts initial8192 output with length before the first write completes.
Root-cause evidence and frozen audits are in the Case10 ledger. A smaller output
ceiling plus qualitative guidance does not ensure a complete mutation payload.

Parent owns this medium-risk bounded slice; no delegation. Add optional
`limits.initial_progress_max_argument_chars` (None/omitted, 1..65536), requiring
initial progress and its output ceiling. Apply only to string values of mutating
tools in the first ordinary request of the active initial boundary, renewed per turn.

Expose request-local JSON Schema maxLength constraints, respecting smaller existing
constraints. Keep registry identities unchanged. Capture the selected limit with the
request so accounting changes cannot affect enforcement. A completed over-limit call
is rejected before dispatch with known no effect through the existing rejected-call
lifecycle; it spends total request/call capacity and must not release progress.
Incomplete responses remain undispatched and unreplayed. Later calls are unrestricted
by this initial selection; generic limits, approval/cancel/Unknown remain authoritative.

Use Unicode scalar counts consistently with JSON Schema maxLength, including nested
string values/arrays. Static initial control states the numeric bound, one small
coherent completed first mutation and incremental later calls. It selects no artifacts
and promises neither correctness nor latency. Add no timer, event, automatic retry or
tool authority. Default omission preserves the previous contract.

Owned fixtures must cover before/after request schema and no-effect rejection, smaller
existing schema limits, Unicode/nesting, first-only/fresh turns, disabled paths, safe
incomplete-response behavior and real CLI wire. Add isolated Case10 argument selection
and native scalar/Pi null, preserving all Retry27 controls and shared prompts/references.
Run required Rust/debug/startup/session/context checks and parent invariant review,
update documents, commit/push/freeze before Retry28. Select2048 characters for the first
request while first8192/later32768 remains unchanged. Any failure requires new analysis
and verified enhancement. Fresh Pi remains conditional on Rupi acceptance.
