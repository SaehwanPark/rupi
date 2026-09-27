## Round 6 audit

I re-audited current `main` at **`5ceb029`**, including merged PR #125. The Round-5 work is implemented substantially as intended: streamed truncation is no longer retried after irreversible output, desired/effective output budgets are separated, endpoint caps reach backup providers, reasoning provenance is conservative and persisted, aggregate provider output is bounded, and impossible progress boundaries fail before another request.

Round 6 has one issue I consider **P0**, plus several P1 hardening gaps that are particularly relevant to Rupi's intended weak/quantized local-model use case.

| Priority | Finding | Main risk |
|---|---|---|
| **P0** | A mutating `Unknown` tool outcome does not stop later mutations | Rupi can keep modifying an environment whose state it explicitly cannot determine |
| **P1** | Internal response-limit aborts reuse the user cancellation token | Provider/protocol faults can be misreported as user cancellation |
| **P1** | No turn-level tool-execution budget | Hallucinating models can execute thousands of tool calls in one user turn |
| **P1** | No configured output ceiling means no response-headroom reservation | Common local config bypasses much of Round-5 output budgeting |
| **P1** | `bytes/4` estimation is now safety-critical and still uncalibrated | Wrong wire output caps / unnecessary or late overflow on CJK, code, small contexts |
| **P1** | Runtime budgets the pre-adapter request, not the actual mapped request | Strict-schema normalization can enlarge the request after budgeting |
| **P1** | User config silently accepts unknown keys | Typos in safety/compatibility settings silently fall back to defaults |
| **P2** | Reduced tool output still cannot be re-read by the model | Avoidable reruns and lost evidence |

### 1. P0 — a mutating `Unknown` outcome does not establish a side-effect barrier

This is the strongest issue I found.

Rupi's core contract correctly defines `Unknown` as:

```rust
ToolExecutionState::Unknown
```

where:

> the side effect may or may not have happened.

It also correctly defines a mutating `Unknown` as requiring:

```rust
ReplayDecision::ReconcileFirst
```

But the live execution loop does not enforce the equivalent invariant.

`execute_calls()` executes the assistant's batch sequentially:

```text
call 1
record outcome
call 2
record outcome
call 3
...
```

After each call it records the result and simply proceeds. There is no branch equivalent to:

```rust
if execution.state == ToolExecutionState::Unknown && !read_only {
  stop_batch();
}
```

This matters because `Unknown` does **not** require the user cancellation token to be set. For example, a mutating tool can return:

```rust
ToolError::after_start(...)
```

which the registry intentionally maps to `Unknown`.

Likewise, a tool-specific execution deadline can expire after execution begins while the outer user cancellation token remains unset.

A model could therefore generate:

```text
1. edit(file A) → Unknown
2. edit(file A again) → Succeeded
3. exec(cargo fmt) → Succeeded
```

and Rupi can execute 2 and 3 despite explicitly not knowing what call 1 did.

Worse, once the batch ends, the `Unknown` result is a terminal history record. `recovery_blocked` protects **interrupted/open calls on resume**, but I don't see it being activated for a live terminal `ToolUnknown`. The model can therefore receive another inference round and perform still more mutations.

That cuts directly across Rupi's otherwise strong lifecycle semantics.

#### Implementation approach

Introduce an explicit **uncertain-side-effect barrier**.

Immediately after recording the outcome:

```rust
let uncertain_mutation =
  !read_only && execution.state.side_effect_uncertain();
```

If true:

1. Do **not** execute any later call from that assistant batch.
2. Close every remaining call with model-visible terminal results such as:

```text
not executed: an earlier mutating tool has an unresolved side effect
```

3. Do **not** issue another model request automatically.
4. Persist a durable unresolved-side-effect marker so this survives session restoration.
5. Reconcile before any later mutation is allowed.

I would model the state explicitly rather than overload `recovery_blocked`, for example:

```rust
struct UnresolvedSideEffect {
  call_id: ToolCallId,
  tool_name: String,
  turn_id: TurnId,
}
```

Then, before the next model/tool phase:

```text
Committed
  → side effect happened; continue with that fact

Unmodified
  → side effect did not happen; continue with that fact

Diverged
RequiresManualInspection
  → stop autonomous execution and require user resolution
```

For arbitrary `exec`, reconciliation will often be impossible. That is precisely when continuing automatically is least defensible.

A dedicated terminal status such as:

```rust
TurnStatus::NeedsReconciliation
```

would be clearer than pretending this is a model `Failed` result.

Regression tests should cover `ToolError::after_start`, tool deadline expiry, a two-mutation batch, a following read-only call, resume after `Unknown`, and a second user turn before reconciliation. The crucial assertion is that **nothing after the uncertain mutation crosses `ToolStarted`**.

---

### 2. P1 — internal response rejection mutates the user's cancellation token

The Round-5 aggregate-limit machinery has a subtle ownership problem.

`Collector::reject_response()` does approximately:

```rust
self.provider_error = Some(
  ModelFailure::new(
    ModelFailureKind::Protocol,
    FailurePhase::Normalizing,
    message,
  )
);

self.cancel.cancel();
```

But the collector was constructed using:

```rust
cancel.clone()
```

where `cancel` is the caller's turn cancellation token.

Later, after recording the request failure, `attempt()` checks:

```rust
if cancel.is_cancelled() {
  return Err(TurnFailure::Cancelled);
}
```

So an internally detected provider violation can become:

```text
provider emits oversized/broken normalized response
        ↓
Collector records Protocol failure
        ↓
Collector cancels shared CancelToken
        ↓
attempt sees cancel.is_cancelled()
        ↓
TurnFailure::Cancelled
```

The user never cancelled anything.

This is partly masked for the built-in OpenAI adapter because the decoder catches many of the same bounds first, but it remains a core runtime problem for alternate/custom `ModelProvider`s and any limit caught only at the collector layer.

It also makes one token mean two very different things:

```text
human requested stop
runtime wants provider transport to stop
```

Those should not share state.

#### Implementation approach

Split cancellation into:

```rust
UserCancel
RequestAbort
```

or make the provider sink itself stoppable:

```rust
enum SinkControl {
  Continue,
  Abort(ModelFailure),
}
```

A cleaner long-term signature would be roughly:

```rust
trait ProviderEventSink {
  fn emit(&mut self, event: &ProviderEvent)
    -> Result<(), ModelFailure>;
}
```

Then the provider stops decoding/reading when the consumer rejects the response, without mutating user intent.

Until that interface changes, create an internal request-local cancellation token:

```text
user_cancel ───────────────┐
                           ├→ provider stop condition
internal_request_abort ────┘
```

but only `user_cancel` determines `TurnStatus::Cancelled`.

Add a deterministic test with a fake provider that emits a delta exceeding the collector bound and returns normally. Assert:

```text
failure.kind == Protocol
turn != Cancelled
user_cancel.is_cancelled() == false
```

---

### 3. P1 — there is a request budget, but no tool-execution budget

The new per-response cap is valuable:

```rust
MAX_RESPONSE_TOOL_CALLS = 128;
```

but that is a parser/resource bound, not an autonomy bound.

`RuntimeLimits` currently limits model requests:

```rust
max_model_requests_per_turn
```

with default 32 and configurable maximum 256.

It does not limit:

```text
tool calls per turn
mutating tool calls per turn
started tool executions per turn
```

Given the response cap, a pathological model could theoretically request **3,968 tool calls across the 31 ordinary requests available before the reserved finalization request under the default 32-request budget**. At the hard 256-request setting, that becomes **32,640 calls**.

The practical number will usually be lower, but the invariant is the problem.

For a fragile model repeatedly emitting:

```text
write
write
write
exec
write
...
```

and an operator who enabled:

```json
"auto_approve_mutating": true
```

the only generic stopgate is the model-request budget.

#### Implementation approach

Add explicit limits:

```rust
pub struct RuntimeLimits {
  pub max_model_requests_per_turn: u32,
  pub max_tool_calls_per_turn: u32,
  pub max_mutating_tool_calls_per_turn: u32,
  ...
}
```

I would count **requested calls**, not only successful or started calls. Otherwise malformed-call spam bypasses the budget.

Track at least:

```rust
tool_calls_seen
mutating_calls_seen
tool_calls_started
```

The first two enforce admission; the last is useful telemetry.

Critically, enforce the remaining budget **before execution begins for a batch**. If only three slots remain and the assistant returned eight calls:

```text
first 3 → normal execution
last 5  → terminal Failed/not-executed results
```

Do not silently drop the excess calls.

For mutation budgets, I would choose a materially smaller default than the total tool budget.

This is not something I would copy from Pi merely for parity—I did not find a directly analogous generic Pi cap. It is especially justified by Rupi's stated target of less-reliable local models.

---

### 4. P1 — `max_output_tokens = None` still means “reserve no explicit response headroom”

Round 5 fixed output budgeting well **when an output ceiling exists**.

But the common quick-start configuration currently omits one:

```json
"capabilities": {
  "context_window": 262144,
  ...
}
```

With no desired output ceiling:

```rust
desired_output_tokens == None
effective_output_tokens == None
```

and `RequestBudget::is_unusable()` specifically does:

```rust
let minimum_prompt_headroom =
  if self.desired_output_tokens.is_some() {
    self.safety_reserve_tokens
  } else {
    0
  };
```

So the 10% reserve does not apply.

That means `None` currently means both:

```text
don't put max_tokens on the wire
```

and effectively:

```text
don't reserve a known completion allowance during hard-fit validation
```

Those are not the same policy.

The context profile may still cause earlier compaction in many cases, but it is not a hard guarantee of completion headroom—particularly for a large current turn that cannot safely be evicted.

#### Implementation approach

Decouple **response reservation** from **wire output ceiling**.

For example:

```rust
struct RequestBudget {
  desired_output_tokens: Option<u64>,
  effective_output_tokens: Option<u64>,
  reserved_output_tokens: u64,
  ...
}
```

Then even when no explicit output limit is sent:

```text
reserved_output_tokens > 0
max_output_tokens = None
```

A conservative model-independent default could be bounded by both an absolute and relative quantity, e.g. conceptually:

```text
reserve = clamp(window × profile_fraction, min, max)
```

rather than always 10% for every model size.

Alternatively, for known local-model profiles, resolve an explicit maximum output from model metadata and send it.

The important invariant is:

> “No configured wire ceiling” must not mean “the model needs zero room to answer.”

Add tests with no `max_output_tokens` and prompts at 85%, 95%, and nearly 100% of a small context. Rupi should compact/refuse before sending a request with effectively no response room.

---

### 5. P1 — `bytes / 4` has become a safety-critical estimator

This was legitimately P2 earlier.

Round 5 changes that.

The estimator now determines:

```text
whether a request fits
how much output may be requested
whether history must be evicted
whether the turn is refused
```

yet it remains:

```rust
(bytes / 4).max(1)
```

Rupi's own source notes that this can underestimate CJK and code-heavy text.

A 10% safety reserve helps, but it isn't an estimator correctness guarantee. This matters particularly for:

- 8k/16k/32k local contexts;
- Korean/Japanese/Chinese prompts;
- large source files;
- JSON/tool schemas;
- quantized models whose advertised context limits may themselves be imperfect.

Pi also uses a rough 4-character estimate for unknown trailing material, so this is not a “Pi solved tokenization perfectly” comparison. The important difference is that current Pi can anchor context estimates on the most recent applicable provider usage and estimate only the trailing portion. Rupi correctly rejected the earlier idea of blindly replacing a current estimate with a stale previous measurement; the right next step is calibration, not regression to that behavior.

#### Implementation approach

Promote the previously deferred **model-scoped calibration** work.

Keep the current request estimate as the base:

```text
raw_current_estimate
```

After successful responses, record:

```text
(raw_prompt_estimate, provider_logical_prompt_tokens)
```

scoped by at least:

```text
provider
model
possibly request dialect / tool-schema mode
```

Then maintain a bounded conservative multiplier:

```text
calibrated_current =
    raw_current × conservative_ratio
```

Use a high-side estimator rather than a simple average. A local model repeatedly showing:

```text
actual/raw = 1.28, 1.31, 1.26
```

should cause subsequent requests to budget around that magnitude, not continue assuming 1.0.

Important invariants:

- never substitute a previous token count directly;
- don't mix calibration between primary and backup models;
- reset/decay when material dialect/tokenizer configuration changes;
- preserve a safety reserve after calibration.

If the provider eventually exposes a tokenizer/counting endpoint reliably, it can become an optional higher-confidence estimator.

---

### 6. P1 — budgeting still occurs before provider-specific request expansion

Round 5 accurately budgets the **normalized Rupi request**, but “exact request” is still slightly too strong a description.

The runtime estimates:

```text
system
messages
ToolSpec.name
ToolSpec.description
ToolSpec.parameters
```

Then the OpenAI adapter transforms that.

For strict tools, for example, it can convert an optional-property schema into the OpenAI strict form by:

```text
making every property required
adding nullability to optional fields
forcing additionalProperties=false
adding strict=true
adding function/tool wrappers
```

That can substantially enlarge a large tool catalog.

The runtime budget decision has already happened before this normalization.

Similar smaller differences come from provider message wrappers and reasoning replay fields.

For a large context this is noise. For the exact constrained local-model cases Rupi wants to support, it can be the difference between:

```text
runtime: fits
provider: context overflow
```

#### Implementation approach

Give the provider a **pre-dispatch preparation/estimation phase**.

For example:

```rust
trait ModelProvider {
  fn prepare_request(
    &self,
    request: &ModelRequest,
  ) -> Result<PreparedRequest, ModelFailure>;
}
```

where:

```rust
struct PreparedRequest {
  logical: ModelRequest,
  prompt_tokens_est: u64,
  // optionally a private/provider-owned serialized representation
}
```

Then the flow becomes:

```text
assemble logical request
        ↓
provider maps/normalizes request
        ↓
estimate mapped request
        ↓
runtime resolves output budget
        ↓
provider serializes/sends exactly that prepared request
```

You don't necessarily need to leak JSON wire bodies into `rupi-core`. A lighter interface could simply be:

```rust
fn estimate_prompt_tokens(&self, request: &ModelRequest) -> u64;
```

where the OpenAI adapter estimates its mapped form.

Longer-term, this and Finding 5 should converge:

```text
provider-aware raw estimate
        +
model-scoped empirical calibration
        +
safety reserve
```

Add a regression with a deliberately large optional-property schema where strict normalization materially inflates it, using an 8k/16k synthetic window.

---

### 7. P1 — config typos still fail open

Rupi now has a nontrivial set of compatibility and safety controls:

```text
strict_tool_schema
preserve_reasoning
thinking_disable
max_model_requests_per_turn
max_model_requests_without_progress
...
```

But the user-facing config structs generally don't use:

```rust
#[serde(deny_unknown_fields)]
```

For example, a typo such as:

```json
"strict_tool_shema": "supported"
```

or:

```json
"preserve_reasonng": true
```

can deserialize while silently leaving the intended setting at its default.

This is especially undesirable because Rupi already has an explicit schema version:

```rust
version: 1
```

and rejects configurations from unsupported future schema versions. That removes much of the usual forward-compatibility justification for silently accepting unknown properties.

For weak local-model setups, many of these compatibility options are exactly the settings a user is likely to hand-edit.

#### Implementation approach

Add:

```rust
#[serde(deny_unknown_fields)]
```

to user-facing fixed-schema objects where there is no intentional extension point, especially:

```text
RuntimeConfig
RuntimeLimits
ModelEndpoint
OpenAiCompatOptions
ToolPolicy
McpServerConfig
```

and similarly for fixed UI/trace/redaction objects where appropriate.

If extensibility becomes necessary, add an explicit namespaced field:

```json
"extensions": { ... }
```

rather than treating every typo as a future extension.

Tests should cover nested typos, not just top-level ones, and should verify the error includes a useful path.

---

## P2 still worth doing: model-readable reduced-output recovery

The previously deferred `payload_read` idea remains worthwhile.

Rupi already does the expensive safety work:

```text
full tool output
→ durable blob
→ opaque recovery reference
→ bounded model-visible summary
```

But the model cannot actually consume the recovery reference.

A read-only tool such as:

```text
payload_read {
  ref,
  offset?,
  limit?
}
```

would let a model recover exactly the part it needs instead of rerunning `exec`, `grep`, or another potentially expensive operation.

The security constraints should be strict:

```text
opaque refs only
current session ownership
bounded offset/length
no arbitrary path access
read-only
```

For weak models, this also reduces the temptation to repeat a command because they didn't receive enough output the first time.

## Recommended Round-6 implementation order

I would make the next slice:

1. **Mutating-`Unknown` barrier and reconciliation first.** This is the only Round-6 item I regard as a clear P0.
2. **Separate user cancellation from internal request abort.**
3. **Add per-turn total and mutating tool-call budgets.**
4. **Reserve output headroom even when no explicit output ceiling is configured.**
5. **Promote model-scoped estimator calibration from P2 to P1.**
6. **Make estimation provider-aware after strict/tool/message normalization.**
7. **Reject unknown config keys.**
8. Then add model-readable payload recovery.

The deterministic adversarial suite for this round should include:

```text
mutating call 1 → after-start Unknown
mutating call 2 → must never start

mutating timeout → Unknown
next user turn → must reconcile before mutation

custom provider → oversized Collector delta
→ Protocol, never Cancelled

31 consecutive 128-call responses
→ bounded by per-turn tool budget

no max_output_tokens + 95%-full 8k context
→ reserve/compact/refuse before dispatch

CJK/code-heavy prompt with provider usage 25–40% above raw estimate
→ calibration raises later estimates

large optional strict schemas near context boundary
→ budget mapped schema, not pre-normalized schema

"strict_tool_shema" typo
→ config parse failure
```

### Round-6 assessment

The project has moved noticeably past the phase where I keep finding missing basic agent mechanisms. PR #125 closes the Round-5 findings well. The remaining important problems are increasingly about **compositional safety**: each subsystem behaves reasonably in isolation, but uncertainty, cancellation, budgeting, provider mapping, and autonomous action need stronger invariants where they meet.

The mutating-`Unknown` case is the one I would fix before doing serious live weak-model benchmarking. Once that and the tool-budget/cancellation boundaries are addressed, I think the audit should shift much more aggressively toward actual quantized-model trials: malformed-call recovery rate, requests/tool calls to completion, context-overflow frequency, redundant action rate, and whether strict sampling measurably improves autonomous task completion.
