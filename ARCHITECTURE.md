# ARCHITECTURE

## 1. Purpose

This document defines the implementation-facing architecture for `rupi`.

The project should remain small at the user-facing layer while providing explicit runtime primitives for:

- provider normalization;
- session state;
- typed events;
- tools;
- context lifecycle;
- reasoning provenance;
- failover;
- interoperability;
- Pi compatibility.

The canonical rule is:

> Context is a cache, not the record.

## 2. System boundaries

```text
CLI/TUI
  |
  v
Agent Runtime
  |
  +--> Provider Adapter
  |
  +--> Tool Runtime
  |
  +--> Event Bus
         |
         +--> Session Store
         +--> Trace Store
         +--> Context Engine
         +--> UI Renderer
         +--> Optional exporters
```

External boundaries:

```text
Pi packages/extensions --> compatibility layer
MCP servers -----------> MCP client
Higher-level agents ----> MCP server / worker API
External KBs -----------> external-context refs
```

## 3. Recommended crate layout

Initial crate boundaries may be:

```text
crates/
  rupi-core/
  rupi-provider/
  rupi-session/
  rupi-context/
  rupi-trace/
  rupi-tools/
  rupi-mcp/
  rupi-pi-compat/
  rupi-extension/
  rupi-tui/

src/
  main.rs
```

Avoid premature crate proliferation.

Split only when a boundary has independent semantics or dependency pressure.

## 4. Agent runtime

The core agent loop owns:

- user turn intake;
- provider invocation;
- streamed output handling;
- tool dispatch;
- event emission;
- retry/failover coordination;
- handoff to context policy at safe boundaries.

The agent loop must not own:

- domain-specific workflows;
- MCP-specific business logic;
- Pi extension implementation details;
- rendering policy;
- storage formatting.

The CLI supplies a short native coding-agent system prompt on every session and appends
the discovered skill-control prompt when skills are available. A headless turn that ends
at its model-request budget is durably completed with `TurnStatus::BudgetExhausted` and a
flushed trace. `rupi run` exits successfully for that resumable partial outcome; the exit
status does not claim the requested task is complete. Provider and persistence failures
remain errors. Budget exhaustion ends the one-shot session as `Interrupted`; a completed
one-shot run and an explicit interactive exit remain `UserExit`.

## 5. Provider abstraction

Provider adapters normalize:

- model identity;
- capabilities;
- context window;
- max output;
- text/image support;
- tool-call support;
- reasoning exposure;
- provider-specific streaming;
- retry-relevant errors.

Conceptual capability model:

```rust
pub struct ModelCapabilities {
  pub text: bool,
  pub images: bool,
  pub tools: bool,
  pub exposed_reasoning: bool,
  pub context_window: u64,
  pub max_output_tokens: Option<u64>,
}
```

Provider errors should normalize into typed failure classes.

Conceptual categories:

```rust
pub enum ModelFailureKind {
  Transport,
  Timeout,
  RateLimited,
  ProviderUnavailable,
  Authentication,
  Protocol,
  ContextOverflow,
  Semantic,
  Cancelled,
}
```

Only explicit categories should qualify for automatic failover.

OpenAI-compatible idle timeouts are enforced by the HTTP/SSE reader. Active transport input
may remain buffered as tool arguments, a partial SSE frame, or a one-shot body without emitting
a normalized model event. Event silence therefore does not establish transport inactivity.
The outer request loop still enforces the total deadline and cancellation; ambiguous failures
retain adapter quarantine and replay-safety classification. Transport activity creates no
synthetic model output, usage, reasoning, or journal events.

Each failed model request closes with optional typed `ModelRequestFailure` metadata on
`ModelRequestCompleted`: category, lifecycle phase, replay safety and partial-output status.
It copies the already classified runtime failure and excludes provider messages and payloads.
Usage remains independent and may be unknown. Older records and Pi imports omit the field;
absence alone proves no success. The metadata does not change retry, failover, quarantine,
projection or replay behavior, and is not added to model context or normal rendering.

OpenAI-compatible endpoint quirks travel through `ModelEndpoint.openai_compat`, not provider
adapter defaults that the CLI cannot reach. Streaming, usage inclusion, token-limit field,
thinking-control dialect and safe extra headers are endpoint-scoped. An explicit thinking-off
encoding is opt-in; adapters do not assume that every compatible server accepts
`reasoning_effort: "none"`. Prior assistant reasoning is omitted by default and can only be
replayed for an opted-in endpoint when its provenance is `Native`; provider summaries,
declared rationale and reconstructed rationale are never relabeled as native reasoning.
Built-in tools prefer strict schema sampling only when the endpoint explicitly declares
support. A required constraint refuses before dispatch when unsupported or not safely
normalizable; the registry's pre-execution argument validator remains authoritative. Header
values are redacted from config serialization and debug output.

Generic local and remote endpoint constructors conservatively declare
`ReasoningExposure::None`; native exposure must be configured from endpoint evidence. Reasoning-
shaped response fields are discarded from the semantic stream while exposure is undeclared rather
than promoted to `Native` from their names. Enabling reasoning replay requires that explicit native
declaration. Successfully completed assistant messages retain exposed reasoning chunks with their
original provenance, independently of the endpoint's opt-in replay policy; only native chunks are
eligible for replay.

When an endpoint declares an output ceiling, each request keeps that desired value separate
from its exact effective wire ceiling. After assembling the system prompt, messages, and tools,
the runtime estimates prompt tokens, reserves a safety margin, clamps to a useful output
allowance, and evicts only safe pre-turn history when more headroom is needed. If a useful
request still cannot fit, it refuses before dispatch. With no declared ceiling, the runtime does
not invent an untracked wire limit. The provider's capability snapshot includes endpoint output
overrides, and the wire mapper sends only the ceiling recorded in `ModelRequest`.

Provider decoders and the runtime collector enforce finite per-response text, reasoning, semantic
event, raw SSE-frame, tool-count, tool-identity, and tool-argument limits. Empty/usage-only SSE
frames count toward the independent raw-frame bound. Fragmented tool arguments are bounded before
append; no partial or oversized call is executable. Exceeding visible-text limits yields an
incomplete protocol response, and the runtime never automatically retries it after irreversible
assistant output has reached the live surface.

## 6. Event model

Important runtime behavior must emit typed events.

Conceptual event families:

```rust
pub enum AgentEvent {
  SessionStarted,
  UserInput,
  RuntimeControlInjected,
  UserMessage, // legacy/imported user-role event; never proves authorship
  ModelRequestStarted,
  ReasoningDelta,
  AssistantDelta,
  ModelRequestCompleted,
  ToolRequested,
  ToolStarted,
  ToolCompleted,
  ToolFailed,
  ToolReconciliationObserved,
  ExternalContextRetrieved,
  ContextReduced,
  ContextCompactionStarted,
  ContextCompactionCompleted,
  CheckpointCreated,
  ModelRetry,
  ModelFailover,
  SessionEnded,
}
```

Each event should carry stable identity and ordering metadata where meaningful:

```text
event_id
session_id
turn_id
timestamp
model_epoch
provider
model
tool_call_id
parent_event_id
trace_id
span_id
```

The event stream should be the shared source for:

- durable trace;
- UI updates;
- replay;
- session state reconstruction;
- failover continuity;
- diagnostics.

## 7. Session and trace separation

Maintain two logical representations.

### Session state

Semantic state needed for:

- active context;
- resumption;
- branching;
- Pi-compatible import/export.

### Trace

High-resolution historical execution.

A journal line carries an inline budget. Above it, whole fields move to the session's content-addressed blob store and the line keeps a bounded preview naming the reference and the original size, plus an `externalized` record beside it so a program can follow the pointer without parsing prose. Envelope bookkeeping and pointer-shaped fields (`*_id`, `*_ref`, `hash`, a `blob` record) are never elided: a line that cannot be attributed, or a pointer that cannot be followed, is worse than a long line. Redaction runs first, so the bytes that leave the line are already sanitized.

Blob payload compression is optional and disabled by default. When enabled, the store prefers raw Deflate only when it reduces the logical payload; the persisted `BlobRef` records the encoding suffix while its hash and size remain those of the redacted uncompressed bytes. Existing raw references remain readable, and the append-only JSONL journal itself is never compressed so tail recovery, inspection, and export remain plain-file operations.

Durable layout (the session files are kept flat so listing only reads headers):

```text
.rupi/
  sessions/
    <session-id>.jsonl              semantic resume projection
    <session-id>.trace.jsonl        canonical ordered trace
    <session-id>.wal.jsonl          crash-recovery projection intents
    <session-id>/
      blobs/
      checkpoints/
  leases/
    <session-id>.lease                 exclusive session ownership
  artifacts/
```

Exact paths remain configurable. A committed WAL is compacted; an incomplete
intent blocks read-only continuation until resume repairs it or fails closed.
Output-limited responses (`length` or `max_tokens`) keep their deltas and unexecuted calls
in the canonical trace, without requiring an assistant projection on close/reopen/resume.
Completed responses still require their semantic projection; incomplete calls never dispatch
or replay when a session continues.
Message-bearing runtime events use one WAL transaction with an exact redacted
message payload: small messages stay inline, while larger messages keep a verified
session-blob reference. `begin` and `resume` hold the per-session lease for the
handle lifetime, and retention acquires the same lease before deleting a victim.
Trace envelope v3 identifies the current event format; readers accept v1 and v2
entries (including mixed append-only histories) and reject unsupported versions before
decoding event variants. Resuming an old trace appends v3 records without rewriting prior
lines. Journal tail, open, and sequence-recovery paths perform the same schema preflight.

Reduced tool output can be re-read only through the runtime's read-only
`payload_read` tool. The model receives an opaque recovery reference in the reduced
result; a bounded typed capability list carries trusted references through recursive
L1/L2/L3 compaction and resume. The active turn advertises only references present in
that session's blob directory; reads verify the referenced blob hash. Reads are byte-ranged
(at most 4 KiB per call), and decoded payloads are capped at 16 MiB. The tool accepts no
paths and is unavailable for references that were not exposed in the current session.

## 8. Reasoning provenance

Reasoning-like information must use explicit provenance.

```rust
pub enum ReasoningProvenance {
  Native,
  ProviderSummary,
  Declared,
  Reconstructed,
}
```

Rules:

- `Native` means actually emitted by the model/provider.
- `ProviderSummary` is provider-generated transformed reasoning.
- `Declared` is intentionally requested explanation.
- `Reconstructed` is post-hoc inference.

Where the claim comes from:

- Provenance is decided by what the endpoint *declares* it exposes, never by which
  response field the text arrived in. The same `reasoning_content` field carries the
  model's own thinking on one server and a provider-authored summary on another, and
  a claim of `Native` for the latter reports hidden chain of thought as recovered.
- An endpoint that declares nothing provides no defensible provenance claim. The
  adapter discards reasoning-shaped fields rather than promoting their names to
  evidence of native thinking; raw provider payload retention remains opt-in.
- The claim travels unchanged: provider event, journal record, rendered line.

Never serialize or render these as equivalent.

That rule is pinned at every hop a claim crosses, in `tests/provenance_roundtrip.rs`:

- the claim is a required field, on the provider event, on the trace line, and inside a
  session message's reasoning chunk. There is no `Default` for `ReasoningProvenance`, so
  a producer states one or does not compile;
- a trace line that has lost its claim is a malformed line. The journal counts it as
  damaged and refuses it; it is never read back as `Native`, which is the one weakening
  that would turn someone else's summary into reported model thought;
- each claim renders under its own label and its own style role, and a resumed session
  reports the same claim the run recorded, including the optional source detail;
- `Native` is the only claim that may be described as emitted reasoning, and only
  `Reconstructed` is described as rupi inference. Those two predicates are what the
  prose is generated from, so they are asserted directly.

### Message source vs protocol role

A canonical `Message` carries a semantic `origin` independently of its provider-facing
`Role`, and its origin/role pairing is validated at construction-sensitive storage
boundaries. Genuine user input and injected runtime control have distinct canonical events
(`UserInput` and `RuntimeControlInjected`); the legacy `UserMessage` event is ambiguous and
never proves human authorship. User input alone can establish user-authored objectives and
constraints. Runtime control, external evidence, reconciliation notices, and derived
compaction/checkpoint summaries retain their own origin even when an endpoint requires them
on the wire as `role=user`. Session schema v6 persists this distinction plus tool-effect evidence
and typed archived-payload summary state. Migration derives
origins only from linked, unambiguous canonical events; legacy user-role messages with no
proof remain `ImportedLegacy` and are carried forward only as opaque unresolved context.
Schema-only migration preserves historically durable content byte-for-byte; the active redaction
policy applies to new durable writes rather than silently changing only the semantic projection.
Context capsules and safe eviction boundaries inspect origin rather than inferring authorship
from wire role.

## 9. Tool runtime

All tool execution should have durable lifecycle state.

```rust
pub enum ToolExecutionState {
  Requested,
  Started,
  Succeeded,
  Failed,
  Unknown,
}
```

Every tool call should have a stable ID.

An adapter that receives a model-authored call with malformed JSON arguments or ambiguous
fragment correlation emits `ProviderEvent::ToolCallRejected` with a stable call ID. Before an
assistant tool-call response is committed, the runtime enforces non-empty unique invocation IDs
across executable and rejected calls for every provider; all members of a collision receive
fresh internal lifecycle IDs and are rejected together for same-model correction. The runtime
records terminal failed results and never dispatches rejected calls. Missing provider IDs are
replaced with internal IDs when a provider index still identifies the call. A fragment
without either key may attach only when exactly one explicitly keyed call without a prior
correlation conflict is open. Otherwise it remains rejected and receives
an internal ID only for failed-lifecycle reporting; ambiguous builders are not guessed. No
argument repair is executed as a tool request.

Once an assistant tool-call message is committed, every call receives exactly one
model-visible terminal tool result before another provider request is allowed. Cancellation
or finalization marks calls proven not to have started as `Failed`; uncertain side-effect
boundaries remain `Unknown`.

Execution lifecycle and world-state effect are independent. `ToolEffectDisposition::None`
is positive evidence of no observable change; `Changed` is a known change; `Possible` is
an uncertain change; legacy missing evidence is `Unverified`. An observed mutating `Failed`
call is replay-safe only with `None` effect evidence. Started mutating failures that lack
no-effect evidence become `Possible`; a mutating `Possible` effect, `Unknown` completion, or
`Failed` completion with non-`None` effect stops the remaining same-batch mutation tail while
recording terminal not-executed results for those calls.

The provider's `ToolCallId` is a response-scoped correlation value, not a session-global
lifecycle key. Durable request-event identity opens each tool lifecycle; `parent_event_id`
links starts and terminal events, and reconciliation names the exact request and unknown
event. Parentless legacy events may fall back to a provider call ID only when exactly one
open request matches.

Each model request captures the exact permitted tool definition binding: registry identity,
registration generation, name, and risk class. Shared replacement/removal advances the
binding generation. Dispatch refuses a stale binding as `Failed` before `ToolStarted`; the
registry holds its read lock across the durable start boundary so replacement cannot race
between the final check and that event. `ToolRequested` also persists a stable definition
fingerprint (declared source, definition and reconciliation version, normalized schema hash,
and risk metadata) when a tool supplies trustworthy identity. Restart reconciliation of a
mutating operation requires an exact fingerprint match; missing or mismatched identity is a
manual-inspection barrier, never a guess based on the current name or risk class. Unknown,
policy-denied, rejected, already-stale, and decoded-but-incomplete calls still spend total-call
budget but do not spend mutation budget; unavailable calls do not prompt for approval. Mutation
budget counts durable `ToolStarted` boundaries: validation, preflight, approval, cancellation, and
stale-binding refusals do not spend a slot, while a started operation consumes one even if it later
fails or becomes `Unknown`.

Read-only tools may use more permissive retry semantics.

Native `edit` requires an exact unique match unless `replace_all` is explicit. A missed
match leaves the file unchanged and reports `Failed` with `None` effect evidence. When
the complete first requested line exists after trimming surrounding whitespace, its
diagnostic supplies a line number for a bounded re-read; a shared prefix alone does not
justify that hint. The diagnostic never applies an approximate replacement or resolves
an interrupted mutation. Reconciliation remains a separate operation.

Tool implementations should declare relevant metadata when possible:

```rust
pub struct ToolMetadata {
  pub name: String,
  pub read_only: bool,
  pub idempotent: bool,
}
```

### Opt-in progress boundary

Coding workflows may configure `RuntimeLimits::max_model_requests_without_progress` and
an optional `progress_tool_names` allowlist. After the configured number of tool-bearing
requests without one of those tools, `TurnLoop` records a runtime-owned model-visible
instruction, exposes only the allowlisted tools on the next request, and requests
`ToolChoice::Required` where supported. That provider hint is not trusted as enforcement:
a text-only completion while the boundary remains active is retained in the canonical trace,
excluded from model-visible history and final report text, and followed by a corrective
request. Exhausting the request budget without a successful configured progress tool ends
as `BudgetExhausted`, never `Completed`. With no allowlist, all permitted mutating tools
are exposed. The normal `Requested`/`Started`/`Succeeded`/`Failed`/`Unknown` lifecycle still
decides whether completion was observed. Progress requires a successful configured
mutating tool with `effect == Changed`; success or mutating metadata alone is not evidence
of progress. A qualifying tool satisfies the default one-shot boundary for the rest of
that turn. Explicit `progress_boundary_mode: recurring` starts a fresh inspection window
after each qualifying change and rejects text-only completion before any change in the
turn. It also prevents the reserved finalization request from bypassing that requirement.
No-tool recovery assessments remain available; callers must verify the workspace
independently. When activating the boundary and before each later request, the runtime resolves
the effective executable mutating-tool set using the active model's tool support, registry policy,
and current approval availability. An empty set emits a durable error diagnostic and fails before
another provider request, including after a failover changes capabilities. The default is disabled
so read-only questions and inspection workflows remain unchanged.

### Opt-in turn-time budget

`RuntimeLimits::max_turn_duration_ms` optionally bounds a turn cooperatively; omission
preserves existing behavior. Each turn creates a fresh monotonic deadline in a child
`CancelToken`, including after resume. Expiry reaches provider and tool cancellation
checks without cancelling the caller or sibling tokens. There is no timer thread.
Before each provider attempt, `TurnLoop` records elapsed/remaining time and remaining
request allowance as a `TurnTimeBudget` runtime control with canonical event and
projection provenance. Deadline cancellation ends as `TimeBudgetExhausted`; explicit
caller cancellation retains its existing classification. Unknown/Possible mutating
effects retain `NeedsReconciliation` and block later inference. Cancellation never
dispatches incomplete calls or starts recovery inference after expiry. Operations that
do not cooperate can overrun the deadline; this is not a hard interruption guarantee.

Owned fixtures verify active native HTTP cancellation, no repeated POST or fabricated
completion, caller isolation, fresh-turn renewal, durable control restore, exclusion of
partial assistant text, no mutation replay, and the uncertain-effect safety barrier.

Optional `initial_progress_boundary` requires a configured progress request window.
For an already authorized implementation turn with sufficient context, it activates
the same boundary before the first ordinary provider attempt. Admission, cancellation,
unresolved-effect checks and current approval availability precede activation. Confirmed
Changed progress releases it; no-effect success does not. New turns renew the initial
selection; explicit no-tools assessment skips it. The default remains false. It does
not select artifact names or authorize a mutation that tool policy would otherwise deny.
Owned fixtures cover initial exposure/choice, release/renewal, unavailable/denied tools,
mutation capacity, caller cancellation, no-effect/Unknown barriers, interactive approval,
default/no-limit/no-tools behavior and durable runtime-control provenance.

Optional `initial_progress_max_output_tokens` requires initial progress selection and a
value in 1..=65536. Only the first ordinary request of its active boundary uses this
ceiling, capped by the endpoint limit and normal context admission. Later requests use
the endpoint ceiling even when progress remains unsatisfied; new turns renew selection.
Desired/effective budgeting stays explicit. The initial runtime control guides a small
coherent completed change without claiming delivery or correctness. Omission preserves
existing behavior. Owned runtime and CLI wire fixtures cover renewal, endpoint/context
clamping, skipped paths and incomplete-response no-dispatch/no-replay.

Optional `initial_progress_max_argument_chars` (1..=65536) requires the initial output
ceiling. The first request captures a per-string Unicode scalar limit for mutating
tools: request-local schemas add `maxLength` without enlarging existing constraints or
changing registry identities, and descriptions state the generic restriction. Completed
oversized calls use the existing rejected-call lifecycle before dispatch, with known no
effect and total-call accounting; they cannot release progress. Nested string values
and arrays are checked. Later requests are unrestricted by this selection, and fresh
turns renew it. Initial guidance asks for one small coherent complete mutation followed
by incremental complete calls. It enforces no artifact names or task correctness, and
neither partial responses nor failed mutations are replayed. Omission preserves behavior.

Optional `initial_progress_thinking` requires initial progress selection and overrides
requested thinking only in its first ordinary active-boundary request. Later requests
inherit the normal level even without Changed evidence; new turns renew selection.
Output/argument budgeting and safety gates remain unchanged. The endpoint's explicit
encoding owns the wire request; runtime control describes intent rather than observed
hidden reasoning or guaranteed backend enforcement. Owned fresh/skipped/no-effect and
CLI wire fixtures verify Off first/Low later, including `reasoning_effort: none` when
the endpoint declares that disable encoding. The default inherits normal thinking.

### Endpoint thinking dialects

Endpoint `openai_compat.thinking_input` can explicitly select
`chat_template_enable_thinking`: it sends `chat_template_kwargs.enable_thinking` as a
boolean, false for Off and true for other levels. The legacy `chat_template_thinking`
key and default `reasoning_effort` remain unchanged. This requests a template toggle;
it neither specifies effort intensity nor proves effective backend enforcement or hidden
reasoning composition. First-request thinking selection uses the same endpoint dialect.
Owned config/provider/CLI wire fixtures cover both keys, Off and later inheritance.

### Opt-in completion review

`RuntimeLimits::review_completion` defaults to false. When enabled, the first otherwise
accepted text-only completion in an ordinary tools-enabled turn is retained as native
assistant evidence and followed by a canonical/projected `CompletionReview` control.
The active model compares requested deliverables with observed actions and may continue
authorized work. The review is one-shot per turn, renewed after resume/new turns, and
uses existing request/tool/time budgets. Progress rejection precedes review; unresolved
mutations still stop inference. Reserved no-tools finalization cannot execute repairs or
convert budget exhaustion into completion. Explicit recovery assessment skips ordinary
review. This is generic guidance, not artifact-name enforcement or correctness certification.
Owned fixtures cover permitted repair, bounded/fresh review, durable native/control
provenance, cap/no-tools behavior, deadline cancellation without dispatch, and Unknown barriers.
Optional `completion_review_reserve_ms` requires enabled review and a positive reserve
below the configured turn duration. Before another ordinary provider attempt, subtract
the observed duration of the preceding provider/tool cycle from remaining time; if that
projected remainder is within the reserve, trigger the same one-shot review. The first
cycle uses zero observed cost. This estimate cannot guarantee future latency. An earlier
first-answer review consumes that allowance, and new turns reset the cycle observation.
Cancellation is checked first; no unresolved mutation or budget barrier is bypassed.
Optional `completion_review_request_reserve` requires enabled review and a positive count
strictly below the ordinary request allowance (the cap minus its finalization slot).
At a safe ordinary boundary, remaining ordinary requests at or below that count trigger
the same one-shot review. Either reserve can trigger first; accepted-answer review also
shares the allowance. Request-only selection requires no native timer or cycle estimate.
Direct builders ignore invalid counts; configuration rejects them. No budget is extended.
Benchmark summaries expose whitelist counts of canonical control kinds, an unknown-kind
count, and review positions as counts of started requests at injection, without control
text or model content; native Pi control metrics remain unavailable/null.
These counts measure injected controls, not proof that the model used their guidance.

### Caller completion observations

Optional `limits.max_completion_checks_per_turn` (1–16, omitted by default) requires
fresh caller observations before accepting an ordinary text-only completion. Progress
rejection precedes checking; checking precedes the optional review. Every later candidate,
including after review, needs another check. A failed observation allows same-model repair
within request/tool/time/check budgets; exhausted allowance ends `CompletionCheckExhausted`.
Unavailable observations end a semantic failure without retry or failover. Cancellation
and native deadlines take precedence, no-tools finalization skips checking, and Unknown
mutations stop before either checking or inference. New turns renew the local allowance.

The Case10 caller's bounded public snapshot preflight returns Failed immediately for
missing requested files, explicitly reporting that commands were not run. A known
missing-file failure must not be masked by launching an incomplete suite that times out.
Complete workspaces still require all original public command gates. Snapshot/deadline/
protocol/process uncertainty remains Unavailable; the runtime stop is unchanged.

`TurnProgress::check_completion` supplies typed status/data and receives the current
cancel token plus ordinal/remaining native time. Core does not execute checks. The caller
must isolate effects outside the canonical task workspace.

Optional `limits.completion_check_on_review` defaults to false and requires configured
checks, enabled review and a valid time, request or check reserve. The one-shot reserved review
can request a fresh caller observation before its next model request, even without a final
assistant answer. This shares the ordinary allowance; a pass still proceeds through model review
and a later fresh completion check. A repairable failure permits bounded same-model work;
last failure/exhaustion and unavailable/oversized results retain their existing stops.
Progress/tool-budget and uncertain-effect barriers precede the observation. Observations
do not count as Changed progress. Cancellation or deadline during the callback discards
its result. Disabled review, absent reserve/checks and no-tools paths skip this selection;
fresh turns renew the one-shot boundary and shared allowance. No new events or commands.

Optional `completion_check_repair_request_window` requires at least two checks and a
positive window below the ordinary request allowance. A Failed observation arms a
turn-local request count; at a safe ordinary boundary after that window, obtain another
caller observation through the same helper/allowance. Failed rearms it, Passed disarms it.
Neither a checkpoint pass nor review replaces a fresh final check. Coincident reserved
review/repair triggers make one callback; earlier final text can check before the window.
Direct builders skip invalid windows; no-tools/finalization skips this selection. New
turns reset it. Existing progress/tool-budget/Unknown/cancel/deadline and terminal check
semantics remain. This needs no clock, new event or additional execution authority.

Optional `completion_check_initial_request_window` requires the same positive ordinary
request window and at least two checks. If no caller observation has occurred, the first
safe boundary after that many requests obtains one through the existing helper and cap.
A prior observation disables this trigger. It coalesces with reserved review, never
consumes the one-shot review, and resets each turn. Failed can arm the repair window;
Passed still requires fresh final checking. All progress/tool/Unknown/cancel/deadline,
no-tools/finalization and terminal observation safeguards remain. Domain checks stay
caller-owned; this threshold creates no clock, command, event or additional allowance.

Optional `completion_review_check_reserve` requires enabled review, at least two checks
and a positive reserve below their cap. After fresh, repairable Failed evidence, if
remaining checks are within the reserve and ordinary work remains, activate the same
one-shot review. Reuse the observation just obtained; `completion_check_on_review` does
not create a duplicate callback on this boundary. Time/request/accepted-answer/check
triggers share the review flag. Passed, Unavailable, last Failed, cancellation, exhausted
requests and no-tools paths cannot activate this trigger. Fresh final checks and all
existing budgets/effect barriers remain; counters/review state reset each turn.

Static `CompletionCheck` guidance is a runtime control; bounded UTF-8 feedback (16KiB)
is separate external context
from `delegated_completion_check`, with citation and ordinal/status/elapsed metadata.
Both persist using existing message/event transactions; native assistant evidence stays
distinct. Resume never replays a prior caller check. A pass describes reported observations,
not general correctness or acceptance certification.

Run-only `--completion-feedback-dir` selects a caller-owned, existing absolute directory
outside the workspace. Configured allowance and disabled outside read/write/search access
are validated before provider requests. Interactive/default paths reject configured checks
without a handler. CLI publishes version1 UUID requests atomically and waits at most300s
(or shorter native time) for a matching strict reply: 128KiB JSON, 16KiB feedback. Invalid,
missing, IO-failed or timed-out replies become Unavailable, with no replay. Artifacts remain.
The channel protects against model file tools; it is not an OS sandbox or arbitrary-exec
isolation. CLI/core never choose or run verification commands.

Case10's opt-in benchmark host copies public package/tests/README into an owned snapshot,
checks requested public artifacts, runs bounded public unittest/help commands there, and
requires nonzero discovered tests. Private acceptance remains after the turn; no oracle
is copied or supplied. Host scratch effects/cleanup belong to the caller. Safe summaries
retain control counts and check ordinal/status/elapsed/request-position scalars only;
native Pi controls remain null. Counts do not prove that the model acted on feedback.
The run-local mailbox stays associated with its turn. Public snapshots and command
artifacts use an independent UUID below `.benchmark/completion-scratch`, avoiding Windows
Process.Start failure on long run-derived working directories. Both roots are checked
outside the canonical workspace; artifacts remain retained. Caller unavailability stays
distinct from known missing-deliverable failure, and uncertain checks are never replayed.
The harness can explicitly select a bounded Case10 mutation allowance within the total
tool cap. Runtime defaults remain16 mutations/64 total; selecting headroom cannot bypass
Unknown reconciliation, progress authorization, request/time limits or completion checks.

## 10. Context engine

The context engine owns model-visible working memory.

It consumes canonical session/trace state and produces a bounded working set.

Before policy evaluation, request sizing asks the active provider to estimate the assembled
prompt after provider-specific mapping, including strict tool-schema normalization. Successful
logical-prompt usage calibrates future estimates through a bounded high-side ratio scoped by
provider, model, and material request dialect; a prior request's token count never substitutes
for the current request estimate. With a configured output ceiling, the estimate also includes
the effective output allowance; a safety reserve is deducted while resolving that ceiling but is
not itself a model token. Without a configured ceiling, hard-fit checks still reserve bounded
response headroom, but no wire output ceiling is added. If a configured output ceiling cannot be
clamped to the minimum useful allowance, the runtime first evicts only safe pre-turn history and
refuses if that cannot create headroom. The active provider's context window controls threshold
evaluation after failover; adaptive latency observations are scoped to model identity. Backup
rebudgeting assembles that provider's system prompt, retained messages, exposed tools, and output
budget before committing the epoch transition. Same-turn compaction validates every tool
lifecycle in the proposed prefix and stops before any unresolved or `Unknown` result.

Conceptual action enum:

```rust
pub enum ContextAction {
  Keep,
  Warn,
  ReducePayload,
  Compact,
  SuggestCheckpoint,
}
```

Policy should remain separable from mechanism.

Possible interface:

```rust
pub trait ContextPolicy {
  fn evaluate(&self, state: &ContextState) -> ContextAction;
}
```

### Context levels

- L0: payload reduction/eviction.
- L1: ordinary compaction.
- L2: semantic phase compaction.
- L3: checkpoint/reset.

Provider-reported context overflow is a reactive reliability path, not a policy
threshold. If the failed request committed no reasoning, assistant text, or decoded
tool call, the active turn may compact only the message prefix that predates the turn,
using one bounded local summary and the exact normal request shape, then reissue once.
All current-turn messages remain verbatim and in order. A second refusal, an overflow
after committed output, or a candidate that cannot fit is terminal. Emergency recovery renders
semantic capsules with objective, constraints, unresolved work, current state, next action, and
artifacts ahead of completed details. It preserves the complete typed summary for later recursive
compaction but requires a nonempty provider-visible floor (up to 512 UTF-8 bytes, scaled down for
tiny windows); if that floor and the protected current-turn suffix cannot fit, recovery refuses.
Context overflow never activates model failover.

Context thresholds are derived for the active model's window before explicit
`ContextOverrides` are applied. The result is normalized to preserve
`warn <= reduce <= compact < checkpoint < window` and `recent_target < compact`; when
normalization changes operator values, the runtime emits one durable warning per active
model/window. In opt-in adaptive mode, a detected model-specific knee may lower the
normalized static thresholds further, never raise them.

An observed output-limit stop is a separate, bounded recovery case. The runtime permits
one same-model retry only when reported output usage is strictly below the request's
explicit output ceiling, older pre-turn history can be compacted, and no assistant text or
reasoning has escaped to an irreversible live surface. The incomplete attempt remains in
the canonical trace, but its deltas and never-executed tool calls are not projected into
the next request or resumed model context. A response that used its full ceiling, has no
measurable output usage/ceiling, has visible output on a non-transactional surface, or has
no safely compactable prior history remains incomplete; the output-limit path never
invokes failover or executes calls from the truncated response.

### Structured capsules

Prefer typed semantic state over free-form summaries.

Core fields should cover:

- objective;
- completed work;
- decisions;
- constraints;
- current state;
- important artifacts;
- unresolved items;
- next actions.

The capsule schema must be versioned. Runtime compaction carries semantic state as typed
`DerivedSummary` variants (`Capsule`, `Phase`, `Rendered`, or `Opaque`) on the message rather
than reconstructing it from provider-facing prose. Repeated compaction unwraps typed phase and
render wrappers without reclassifying them as user input; custom prose and unattributed legacy
messages survive as bounded opaque unresolved context, never as user-authored constraints. The
canonical `ContextCompactionEpoch` stores the same typed state as the session-message projection;
restore rejects disagreement so edited projection fields cannot silently change recursive
compaction.

### Checkpoint barrier invariant

A checkpoint capsule (L3) forms an impermeable barrier for ordinary compaction (L1/L2):
- Compaction operates only on messages accumulated after the most recent checkpoint.
- Compaction never crosses, mutates, or back-propagates across an established checkpoint capsule.
- When `ContextAction::SuggestCheckpoint` is evaluated under context pressure, the runtime synthesizes a structured capsule, archives it to durable storage (`checkpoints/<id>.json`), logs `CheckpointCreated`, advances the context compaction epoch, and resets model-visible messages to the structured capsule block.
- Session resume across a checkpoint initializes prompt context with the active capsule followed by post-checkpoint turns.

## 11. Context profiles

Built-in modes:

```text
aggressive
balanced
relaxed
```

`balanced` is the default.

Rules:

- lower thresholds automatically for constrained context windows;
- do not scale upward merely because a provider advertises a large window;
- keep numeric thresholds advanced and optional;
- compact only at safe runtime boundaries;
- preserve canonical trace state.

## 12. Model failover

One primary and one optional backup model.

Flow:

```text
request
  |
failure
  |
classify
  |
retry if eligible
  |
failover if eligible and retries exhausted
```

Before failover:

1. inspect backup capabilities;
2. ensure required modalities/tools exist;
3. compact/rebudget if context is too large;
4. record failover boundary;
5. continue from committed execution state.

When step 2 fails, failover is refused rather than attempted: the refusal names the
backup and the capability it lacks, and no request reaches that endpoint. An abstention
that is never stated is indistinguishable from a backup that was never configured, and
the operator cannot act on a decision they cannot see.

A context-window shortfall alone is not a refusal. It is a cost, and the takeover records
which gaps remained and whether history was actually shortened — not merely that the
backup's window was smaller.

After failover, the backup remains active until the user explicitly changes model.

Same-model retry requires both a retryable failure kind and `RequestReplaySafety::Safe`.
A pre-dispatch connection failure and an explicit retry-safe HTTP response (429 or 5xx)
may retry. When a POST may have reached the endpoint, skip the same-model retry and go
directly to the configured failover decision. Committed output does not qualify for generic
retry or failover replay; the separately classified, one-shot output-limit recovery above
is the only exception and stays on the same model. This prevents a quarantined adapter
from consuming budget under a fake `ModelRetry` event.

Interactive session control:
- `/failover` triggers manual switch to backup model with `EpochReason::ManualSwitch`.
- `/switch-back` triggers manual return to primary model with `EpochReason::ManualSwitchBack`.
- Safe retries on qualifying availability failures apply exponential backoff (or server `retry-after`) and remain interruptible via `CancelToken`.

Do not auto-ping-pong.

## 13. Model epochs

A session may contain multiple model epochs.

Each epoch records:

- model;
- provider;
- start event;
- reason;
- capabilities snapshot.

Example reasons:

```text
initial
manual-switch
automatic-failover
```

Artifacts and reasoning should remain attributable to the epoch that produced them.

## 14. MCP client

MCP should normalize into the internal tool/resource model.

Rules:

- connection is lazy by default;
- discovery is lazy or filtered;
- do not inject all MCP schemas into every prompt;
- isolate protocol-version handling in the MCP layer;
- prefer semantic resource references over permanent prompt copying;
- stdio and the bounded Streamable HTTP adapter are supported; HTTP POST responses are
  bounded, JSON/SSE response ids are checked, session headers are carried, and protocol-owned
  headers cannot be overridden;
- stdio observes `notifications/tools/list_changed`; a received change freezes the current
  activation and makes its wrappers fail closed until explicit re-enable. Servers advertising
  dynamic tool catalogs are rejected on transports that cannot receive server notifications;
  one-shot HTTP calls remain behind a per-request local relay authenticated by a per-attempt
  nonce, so cancellation closes and joins the in-flight worker without reposting; configured
  HTTP proxy routes are preserved;
- discovery passes through a bounded admission layer before registry/model exposure:
  provider-safe configured/tool name parts, descriptions up to 4 KiB, schemas up to 16 KiB,
  depth 32 and 4,096 nodes, 64 tools per server and 128 active tools overall, with per-server
  and aggregate metadata budgets. Empty schemas normalize to `{"type":"object"}`; invalid or
  over-budget catalogs fail closed instead of entering prompts.

## 15. MCP server / worker mode

`rupi-mcp::worker` exposes a coarse, explicit worker boundary through typed MCP
JSON-RPC. The embedding application supplies a headless [`WorkerEngine`] adapter (normally
composed from `TurnLoop`, `StoreTrace`, `CancelToken`, and `SilentProgress`); the MCP layer
owns run handles, cancellation, bounded waits, and stable resource projections.

The verified operations are:

```text
agent.start
agent.continue
agent.cancel
agent.branch
agent.compact
```

Resources use these stable URIs:

```text
session://<id>/state
session://<id>/summary
session://<id>/messages
session://<id>/trace
session://<id>/diff
session://<id>/artifacts
session://<id>/checkpoint/latest
```

`summary` is an external summary with declared/provider/runtime provenance; it is never
constructed by relabelling reasoning. `trace` is a bounded coarse projection containing
ordering and attribution, not raw event payloads or implementation paths. Diff and artifact
resources report explicit availability rather than fabricating data. The stdio dispatcher
accepts MCP `initialize`, `tools/list`, `tools/call`, `resources/list`, and `resources/read`
without scraping terminal output. Checkpoint and historical-event branching are now owned by
read-only `rupi-replay` plans; the worker still does not execute historical branches itself.

### 15.1 Replay and research tooling

`rupi-replay` is a pure projection boundary over redacted `TraceEntry` values joined with
optional `SessionRecord` messages. `rupi replay` is read-only: it never opens a provider,
executes a tool, or treats historical records as a new generation. Sequence numbers define
ordering; timestamps are used only for timing views. Filters, inclusive replay-until-event,
model-visible context snapshots, epoch/compaction/failover timelines, provenance summaries,
and trace export all derive from the same canonical records.

Historical branch plans carry a `HistoricalEventRef` and a context snapshot, and explicitly
separate copied history from a future generated continuation. A branch plan is not execution.
Tool replay state is keyed by the durable request-event identity, retaining provider call IDs
only as attributes; exact parent-event and reconciliation links survive provider ID reuse.
Parentless imported events use the conservative single-open-invocation fallback. Unknown or
mutating tool states remain marked for reconciliation and are never replayed blindly; reasoning
provenance remains attached and reconstructed rationale is never claimed as hidden model
reasoning.

### 15.2 Optimization experiments and adaptive policies

`rupi-experiments` defines pure evaluation and measurement boundaries for adaptive context
policies, standby backup analysis, and MCP capability exposure:
- **Context adaptation**: `KneeDetector` tracks `first_delta_ms` against context token estimates
  to detect non-linear prefill latency knees. `AdaptiveContextPolicy` starts with thresholds
  derived for the active model window, applies explicit `ContextOverrides`, then only lowers or
  caps them when a model-specific knee occurs; adaptive mode remains opt-in
  (`RuntimeConfig.adaptive_context`). Invalid ordering or backup-window overflow is clamped with
  a durable diagnostic, and thresholds always preserve the context ladder.
- **Backup standby evaluation**: `evaluate_standby_tradeoff` models startup latency and RSS memory
  overheads against takeover speedup. Cold lazy backup remains the default execution posture.
- **MCP capability exposure**: `evaluate_mcp_exposure` measures token footprint across minimal,
  predictive prefetch, and eager strategies. Minimal exposure remains the default posture to
  protect model working context.
- **Timing provenance**: Request first-event/TTFT timing is recorded via optional, backward-compatible
  `ModelRequestCompleted.first_delta_ms`.

## 16. External context

Represent external knowledge through durable references.

The core contract is generic and serializable:

```rust
pub struct ExternalContextRef {
  pub provider: String,
  pub resource_id: String,
  pub citation: Option<String>,
  pub provenance: String,
  pub metadata: BTreeMap<String, String>,
}
```

`ExternalContextItem::compact_to_reference` changes only the model-visible working
representation; its provider identity and source metadata remain in the typed reference.
`ExternalContextItem::rehydrate` is a pure boundary helper. The provider-specific resolver
performs I/O and returns a fresh inline item, which the runtime records as another
`ExternalContextRetrieved` event. Retrieval messages are persisted with their typed
reference in `SessionMessage.external_context`, while canonical trace remains authoritative.

External context therefore supports:

- citation-aware prompt/UI rendering;
- compaction to a durable reference;
- later provider-owned rehydration;
- traceable source/provenance metadata;
- fail-closed unavailable-resource handling.

`rupi-rkb` is the first-party reference integration. It depends on generic core/MCP
contracts, while `rupi-core` has no dependency on RKB or its external crate.

## 17. Pi compatibility layer

Compatibility logic should remain isolated from the Rust-native runtime.

That boundary is a crate. `rupi-compat` reads files Pi already understands — skills and
prompt templates today — and returns typed state plus the list of things it did not
understand. Where two formats come from the same places, the *where* is stated once:
`scan` holds `Trust`, `Source`, and `Discovery`, because a trust decision that exists
twice is one that can disagree with itself. Expanding a template is pure text
transformation in `substitute`, with no file, process, or model in sight. It does
not import the runtime, the store, or a provider, and nothing it returns becomes runtime
state, an event, or a capability until the runtime deliberately adopts it. A field in
somebody else's file is evidence about that file, not a fact about this runtime.

Two rules govern the reading. Silence is reserved for what Pi itself skips without a
word; every other decision produces a warning naming the path and the reason, so an
empty result that means "we refused to look" cannot be mistaken for one that means
"there was nothing there". And a skill is instructions for the model — as is a prompt
template — so project-local locations are read only when the caller says the project is
trusted: `Trust` is
an input rather than a filesystem lookup because this runtime has no trust decision to
consult yet, and inventing one inside a file reader would be the worst place to hide it.

Priority order:

1. skills;
2. prompts;
3. package manifests/discovery;
4. package install (bounded explicit local copy; remote/dependency execution deferred);
5. session import/export;
6. extension tools/commands;
7. selected lifecycle events;
8. selected UI compatibility.

`rupi-extension` handles the selected TypeScript extension surface behind a typed
JSON-lines RPC boundary. It accepts trusted module paths, loads Pi-style default factories,
and returns normalized tool/command metadata, lifecycle/context results, and selected UI
notifications. Extension exceptions and process loss remain adapter errors; the core
session does not infer a successful tool result from a failed host call. Mutating extension
tools default to `Unknown` when completion is not observed.

The Node host must be lazy-started: constructing the host, inspecting compatibility
fixtures, and running a session without extension modules perform no process I/O. Project
extensions are never discovered or executed implicitly by the host.

## 18. TUI boundary

The TUI consumes semantic runtime events.

It should not own runtime state.

Visual rules:

- syntax-highlight operation vs argument vs prompt/path;
- visually distinguish reasoning provenance;
- make rare events prominent;
- collapse verbose output;
- avoid permanent dashboards;
- remain keyboard-first;
- keep render latency low.

## 19. Startup and lazy loading

Critical path:

```text
parse minimal config
identify project
restore lightweight metadata
initialize TUI
READY
```

Deferred by default:

- Node extension host (`rupi-extension`);
- MCP connections;
- backup provider connection/loading;
- deep trace hydration;
- external indexes;
- heavy package code;
- non-essential network calls.

Startup-path dependencies require stronger review.

## 20. Security

All durable trace output should pass through redaction policy before persistence.

Raw provider payload storage must be opt-in.

Project-local config must respect trust boundaries. Compatibility readers receive an
explicit caller-owned `Discovery::trust`; `rupi trust` persists exact canonical project
scopes in a private, schema-versioned file, but no reader infers trust from the files it
would activate.

Potentially dangerous behavior includes:

- subprocess spawning;
- extension loading;
- MCP activation;
- external checkpoint paths;
- native plugin activation.

## 21. Architecture invariants

1. Session state belongs to the runtime, not the active model.
2. Context is derived state.
3. Trace and working context are separate.
4. Reasoning provenance is explicit.
5. Tool side effects are never assumed across unknown completion state.
6. Automatic failover is availability-driven, not quality-driven.
7. Only one model is active in a normal execution role.
8. MCP is an adapter boundary, not the internal architecture.
9. Pi compatibility remains isolated and versioned.
10. Domain-specific logic remains outside core.
11. Optional systems do not block startup.
12. Performance-sensitive paths are measured, not guessed.
