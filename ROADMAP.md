# ROADMAP

## Roadmap conventions

- `[ ]` not started
- `[-]` in progress
- `[x]` complete
- `[!]` blocked or requires architectural decision

Each stage has a **stage gate**. Do not advance merely because some tasks are complete; the gate must be satisfied.

---

## Phase 0 — Repository and architecture foundation

### Project setup

- [x] Create Cargo workspace.
- [x] Add pinned Rust toolchain.
- [x] Add formatting, clippy, test, and documentation CI.
- [x] Add `README.md`.
- [x] Add `ARCHITECTURE.md`.
- [x] Add `COMPATIBILITY.md`.
- [x] Add `ROADMAP.md`.
- [x] Add `AGENTS.md`.
- [x] Add canonical project design under `docs/`.
- [x] Define contribution and issue templates.
- [x] Add benchmark harness directory.

### Core contracts

- [x] Define provider trait.
- [x] Define model capability schema.
- [x] Define typed provider failure classes.
- [x] Define `AgentEvent`.
- [x] Define event identity/order metadata.
- [x] Define session ID / turn ID / tool-call ID types.
- [x] Define tool lifecycle state.
- [x] Define reasoning provenance enum.
- [x] Define model epoch schema.
- [x] Define initial session storage schema.
- [x] Define initial trace storage schema.
- [x] Define redaction boundary.
- [x] Define project-trust boundary.

### Performance baseline

- [x] Add cold-start benchmark (`bench/cold_start.sh` and integrated `bench/startup.sh --cold` benchmark
      first-exec-of-a-fresh-inode vs execs #2-#3 across iterations; limitations and requirement for root
      `drop_caches` or fresh-VM boot harness documented per `docs/archive/slices/SLICE_COLD_START.md`).
- [x] Add warm-start benchmark (`bench/startup.sh` reports min/mean/median/max over N warm runs;
      `bench/warm_start.sh` benchmarks relaunching a process that continues a stored session).
- [x] Add TUI render benchmark (`bench/render.sh`; cases in
      `crates/rupi-tui/benches/render.rs`).
- [x] Add slash-completion benchmark (`tab_completion` in `bench/keystroke.sh`: Tab cycling
      a command word against 64 candidates, budgeted per press alongside the other keystrokes).
- [x] Record initial latency budgets. They are the budgets in the bench source, which exits
      non-zero when a case exceeds one; the recorded baseline, its date, and the machine that
      produced it are in the same file, so the enforcement point and the number cannot drift
      apart.

### Stage gate

- [x] Core contracts compile independently of provider/TUI implementation (`rupi-core` has zero
      dependencies on provider, runtime, store, or TUI crates).
- [x] Event/session/provenance schemas are documented (`crates/rupi-core/src/`, `ARCHITECTURE.md`,
      and canonical design docs).
- [x] CI is green on supported platforms.
- [x] Startup benchmark can run reproducibly (`bench/startup.sh`).

---

## Phase 1 — Minimal usable coding agent

### CLI and TUI

- [x] Implement executable entry point (`rupi run` one-shot headless turn).
- [x] Implement minimal terminal editor, and the loop that feeds it (`rupi interactive`:
      raw mode, key events mapped through `rupi-tui::keys`, `rupi-tui::editor` buffer,
      one turn per submit on a single open session, so context carries across turns).
      Turn interruption is still its own item below.
- [x] Implement streamed assistant rendering for the one-shot command.
- [x] Implement cancel/interrupt (`interrupt::TurnInterruptGuard` catches `SIGINT` during in-flight
      turns and flags `CancelToken`, safely aborting model streaming or tool calls without
      session corruption).
- [x] Implement compact status line (the projection in `rupi-tui::statusline` is rendered
      by the interactive session frame, tested across narrow fallback and idle/working states).
- [x] Render the streamed transcript through a semantic layer (`rupi-tui`: roles,
      provenance-labelled reasoning, spelled-out tool state, calm-by-default diagnostics)
      and wire it into `rupi run` behind `--color/--no-color`, `--width`, `--no-reasoning`,
      `--verbose`, `--quiet`, `--silent`.
- [x] Implement syntax-aware command parsing (parser in `rupi-tui::command` is consumed in
      interactive routing via `Input::parse` and prompt template argument parsing).
- [x] Implement syntax highlighting for operation vs arguments (`rupi-tui::highlight::tokens`
      wired into `interactive` buffer rows and painted across terminal palettes).
- [x] Implement path-aware rendering (`rupi-tui::command` path shapes, `Role::Path`).
- [x] Ensure narrow-terminal fallback (`MIN_COLUMN` drops decoration, keeps word alignment).
- [x] Measure keystroke/render latency. Keystroke latency is measured and budgeted in
      `bench/keystroke.sh` (`crates/rupi-tui/benches/keystroke.rs`: eleven cases); render and
      command-parse latency are measured and budgeted in `bench/render.sh` (`crates/rupi-tui/benches/render.rs`).

### Providers

> `rupi-provider` implements one OpenAI-compatible adapter (`OpenAiCompat`) used
> against local llama.cpp and remote cloud endpoints (OpenAI, Groq, OpenRouter).
> Streaming, tool-call, exposed-reasoning, and failure normalization are covered by
> unit tests plus wire-level integration tests against a fake OpenAI server
> (`crates/rupi-provider/tests/transport.rs`), and verified against the real local
> endpoint: reasoning arrived as a separate typed event with `Native` provenance,
> the visible answer stayed separate, and the turn reported `finish_reason=stop` with
> usage. Remote cloud provider paths (`ModelEndpoint::remote`, `ProviderConfig::remote`,
> `OpenAiCompat::remote`) support Bearer authorization via environment variables
> (`api_key_env`), custom headers (e.g. `HTTP-Referer`, `X-Title`), default base URL
> fallback (`DEFAULT_OPENAI_BASE_URL`), and cloud error classification.

- [x] Implement one local/OpenAI-compatible provider.
- [x] Implement one remote/cloud-compatible provider.
- [x] Normalize streaming output.
- [x] Normalize tool-call output.
- [x] Normalize exposed reasoning.
- [x] Normalize provider failures.

### Basic tools

> `rupi-tools` provides the built-in set (`read`, `write`, `edit`, `grep`,
> `exec`) behind a `ToolRegistry`. Every path is confined to an explicit
> workspace root; every result passes one reduction boundary; every call lands in
> a typed lifecycle state. Two invariants carry the safety weight and are tested
> directly: a mutating tool that claims success while cancellation was observed
> is coerced to `Unknown`, and an approval question that nobody answers is a
> refusal rather than a permission.

- [x] Implement file read.
- [x] Implement file write/edit.
- [x] Implement shell command execution.
- [x] Implement grep/search.
- [x] Emit tool lifecycle events.
- [x] Mark read-only vs mutating tools.
- [x] Confine tools to an explicit workspace root.
- [x] Bound tool output before it reaches context.
- [x] Gate mutating tools behind policy and approval.

### Sessions

> The one-shot `rupi run --config <file> --cwd <workspace> --prompt <text>`
> composition root now drives the provider/tool loop and writes attributed
> messages plus the store-sequenced canonical trace. Interactive resume UX
> remains outside this slice.

- [x] Persist user/assistant/tool messages.
- [x] Resume a recorded session by id or unique prefix.
- [x] Create new session.
- [x] Preserve model identity per turn.
- [x] Avoid deep trace loading during startup.

### Stage gate

- [x] User can start `rupi`, issue a coding request, inspect files, edit files, run
      tests, and continue the session (`tests/run_cli.rs`, `tests/resume_cli.rs`, and
      `src/interactive.rs`).
- [x] Startup is within an acceptable baseline (latest recorded run: cold 222.06 ms,
      warm median 3.02 ms; see
      `docs/archive/proposals/MVP_VALIDATION.md`; aspirational
      targets remain documented in README and the canonical design).
- [x] Optional integrations are not required for basic use (runs fully standalone without Node, MCP, or external tools).
- [x] All tool actions produce durable lifecycle events (`Requested`, `Started`, `Completed`, `Failed` recorded in `trace.jsonl` and session logs).

---

## Phase 2 — Trace and provenance

### Event store

- [x] Persist typed event stream.
- [x] Guarantee stable event ordering.
- [x] Add model request start/end events.
- [x] Add native reasoning events.
- [x] Add tool request/start/completion events.
- [x] Add provider failure/retry events.
- [x] Add model epoch events.

### Trace storage

- [x] Add `trace.jsonl`.
- [x] Add blob storage for large payloads.
- [x] Add content hashing for stored payloads.
- [x] Add optional compression (opt-in raw Deflate for content-addressed blob payloads; `trace.jsonl` remains plain, references retain logical hash/size and encoding, and old raw references remain readable).
- [x] Add trace retention configuration.
- [x] Keep raw provider payload capture disabled by default.

### Provenance

- [x] Render native reasoning distinctly.
- [x] Render provider summaries distinctly.
- [x] Add declared-rationale representation.
- [x] Add reconstructed-rationale representation (typed `Reconstructed` provenance, `ReasoningChunk` serialization, and distinct TUI role/label; no producer is enabled until an explicit evidence-scoped analysis contract exists).
- [x] Prevent provenance loss during serialization.

> Provenance is decided by the endpoint's declared `exposed_reasoning` rather than by
> the response field it was decoded from, and `Declared` is therefore now produced:
> an endpoint declaring `declared` exposure yields declared rationale end to end.
> `crates/rupi-provider/tests/transport.rs` sends the same thinking field under three
> declarations and reads back three different claims; `tests/run_cli.rs` checks the
> claim through the journal and the rendered transcript line. A folded reasoning run
> still never merges across a provenance boundary.
>
> `Reconstructed` keeps a distinct role and label in the rendering layer and no
> producer: nothing in `rupi` infers reasoning after the fact, and it should not
> acquire that ability casually.
>
> Serialization is pinned instead of trusted. `tests/provenance_roundtrip.rs` walks all
> four claims through provider event, `trace.jsonl`, the session log, and the renderer,
> and asserts that a trace line which lost its claim is refused as malformed rather than
> read back as `Native`.

### Inspection

- [x] Implement `rupi trace`.
- [x] Implement trace filtering by tools.
- [x] Implement trace filtering by reasoning.
- [x] Implement model-epoch inspection.
- [x] Name the stored-out reference for an externalized field when rendering a recorded line. The transcript budgets a long argument value to keep one request on one line, which cuts the reference off; the marker is in the line and the typed `externalized` record carries the path. (Verified in `crates/rupi-tui/src/trace.rs` unit tests and `tests/trace_cli.rs`)

### Stage gate

> Model attribution is now per event: the envelope names the model in charge when the
> event was written, and a transition event keeps the epoch it *describes* separate from
> the epoch that recorded it. `tests/failover_cli.rs` reads the journal back and checks
> both. Provenance serialization is pinned rather than assumed, and the production
> path decides a claim from the endpoint's declaration, not from the wire field.

- [x] A completed session can answer which model produced each major event.
- [x] Native reasoning remains distinguishable from all inferred/summarized forms.
- [x] Large payloads do not require full inline duplication in trace JSONL.
  - Every journal line carries an inline budget (`WritePolicy::inline_threshold_bytes`,
    8 KiB by default). Above it, whole fields go to the session's blob store once —
    content addressing means two lines about the same payload share one copy — and
    the line keeps a bounded preview naming the reference and the original size,
    plus a typed `externalized` record so the sizes need no prose parsing.
  - Envelope bookkeeping and pointer-shaped fields are excluded on purpose: an
    elided identifier or `blob` record cannot be followed, so the alternative to a
    long line would be an unreadable one.
  - Bounding runs after redaction, never before, so bytes that leave the line are
    already the sanitized ones.

---

## Phase 3 — Pi compatibility foundation

### Skills and prompts

- [x] Implement Pi-style skill discovery.
- [x] Implement `SKILL.md` loading.
- [x] Implement prompt-template discovery.
- [x] Add package-local skill support.
- [x] Add project-local skill support.
- [x] Add compatibility fixtures.

Skill discovery (`rupi-compat::skill`, surfaced by `rupi skills`) reads the two file
families Pi documents — per-user and per-project — including the rule that a root `*.md`
counts as a skill in `.pi/` locations and is ignored in the shared `.agents/` ones, the
ancestor walk that stops at the git root, and the frontmatter subset (`name`,
`description`, `license`, `compatibility`, `allowed-tools`, `disable-model-invocation`)
with quoted scalars and `|`/`>` block scalars. Package-local skills from discovered
packages (global and project, gated on trust) and explicit `--skill` paths are supported.
Project locations are gated on trust, and frontmatter declares the trust question as an
input rather than answering it.

Prompt-template discovery (`rupi-compat::prompt`, surfaced by `rupi prompts`) reads
Pi's two template locations non-recursively, takes the command name from the filename, and
falls back to the body's first line for a missing `description` while recording that the
description was not authored. `rupi prompt <name> [args…]` applies Pi's substitution
grammar (`rupi-compat::substitute`) and prints the prompt alone, which is what makes a
template reusable before any session knows how to invoke one.

Open in this area, in order:

- [x] Load `SKILL.md` bodies and honour `disable-model-invocation` when activating.
- [x] Present loaded skills to the model as a skill-control prompt listing/template.
- [x] Add package-local skills (`manifest.skill_paths`, conventional `skills/` and `SKILL.md`),
      and `--skill` CLI paths. (Settings array remains deferred).
- [x] Invoke a prompt template from inside a session (`/name`), and wire `rupi run` to
      accept one; `rupi prompt` expands a template today, nothing sends it.
- [x] Split one typed string into template arguments the way Pi's editor does, quotes
      included.
- [x] Add package-local prompts (`manifest.prompt_paths`, conventional `prompts/`),
      `--prompt-template`, and `--no-prompt-templates`. (Settings array remains deferred).
- [x] Decide trust somewhere other than the file reader, then pass its answer in (`--project` is an explicit caller-owned one-shot grant; `--trust-store <dir>` resolves durable exact canonical project scopes, with denial winning over the one-shot flag; durable high-risk decisions are recorded by `rupi trust` in `FileTrustStore`, while runtime once/always prompting remains deferred).
- [x] Add the compatibility fixture suite (`tests/compat/` holds skill, prompt, and package
      fixtures; session import/export has targeted CLI coverage; TypeScript extension
      execution is covered by the Phase 8 host fixtures).

### Packages

- [x] Parse compatible package manifests (`crates/rupi-compat/src/package.rs`: hand-rolled
      zero-dependency JSON reader; extracts `name`, `version`, `description`, `pi.skills`,
      `pi.prompts`; produces typed `Warning::UnsupportedSurface` for `extensions`,
      `Warning::UnknownSurface` for unknown `pi`-namespace keys; `tests/compat_packages.rs`:
      9 fixture-driven integration tests pass; 25 unit tests pass).
- [x] Report unsupported package surfaces (per-surface `Warning` variants with counts;
      does not reject the whole package when only one optional feature is unrecognised;
      `extensions` is the documented Phase-8 surface, recorded with entry count).
- [x] Implement package discovery (`crates/rupi-compat/src/package.rs`: `discover(&Discovery)`
      scans `$HOME/.pi/agent/packages`, `$HOME/.pi/packages`, and `<ancestor>/.pi/packages`
      when trusted; deterministic lexicographical sort; first-found-wins duplicate resolution;
      subdirectories missing `package.json` flagged with `Warning::MissingManifest`;
      exposes contained `skill_locations` and `prompt_locations` via manifest or convention;
      `rupi packages [--project] [--trust-store <dir>] [--show <name>]` CLI command;
      `tests/compat_packages.rs`:
      9 passing fixture-driven tests; `tests/packages_cli.rs`: 6 passing CLI tests).
- [x] Implement package install path (explicit local-directory copy to global/project package roots with atomic staging, symlink/path checks, and no dependency/script execution; npm/git/HTTP/update support remains deferred and compatibility stays Partial).
- [x] Add `rupi compat` prototype (`crates/rupi-compat/src/compat.rs`: `inspect_target` inspects
      package manifests, skills, prompts, and extension files with static analysis of `registerTool`,
      `registerCommand`, context hooks, and internal imports; `rupi compat [options] <path-or-package>`
      with `--project` and `--json` support; `tests/compat_cli.rs`: 8 passing integration tests;
      `crates/rupi-compat/src/compat.rs`: 5 passing unit tests).

### Sessions

- [x] Implement Pi session import prototype.
- [x] Carry imported conversation messages into the session message log.
- [x] Import a whole Pi session directory: `import-pi <dir>` files every `*.jsonl` directly
      inside it, each as its own session; cross-file lineage is named, not reconstructed.
- [x] Implement Pi session export prototype.
- [x] Document non-round-trippable metadata. (Documented in `COMPATIBILITY.md` §10.3 and `docs/SESSION_COMPATIBILITY.md`; verified against import/export CLI loss reporting)

### Stage gate

> Skills, prompts, and package discovery gates are passed. The bounded local package-install path is covered; `--trust-store` resolves durable project grants/denials for compatibility discovery; remote source resolution, dependency installation, and automatic extension discovery remain deferred. The selected explicit TypeScript host surface is verified in Phase 8.
> `tests/compat_skills.rs` drives fixture skills (discovery, body loading, `disable-model-invocation`,
> `SKILL.md` frontmatter, project trust gate) — all 8 tests pass.
> `tests/compat_prompts.rs` drives fixture templates (Pi substitution grammar, argument splitting,
> description fallback, duplicate/malformed warnings) — all 9 tests pass.
> `tests/compat_packages.rs` drives fixture manifests and discovery (minimal, full, extensions, malformed, missing, home/project discovery)
> — all 9 fixture tests pass; 25 unit tests in `package.rs` pass;
> `tests/packages_cli.rs`: 6 CLI tests pass.
> Selected TypeScript extension compatibility is complete in Phase 8; full custom UI, dependency installation, and automatic project extension discovery remain deferred.

- [x] Representative Pi skills run unchanged (`tests/compat_skills.rs`: 8 passing fixture
      tests cover discovery, frontmatter, body loading, and project-trust gate).
- [x] Prompt templates are reusable (`tests/compat_prompts.rs`: 9 passing fixture tests cover
      Pi substitution grammar, argument splitting, and description fallback).
- [x] Package compatibility diagnostics are useful and explicit (`tests/compat_packages.rs`: 9 fixture-driven integration tests; `package.rs`: per-surface `Warning` variants; no whole-package rejection for a single unsupported surface).
- [x] Compatibility tests run in CI (`cargo test` includes `compat_skills`, `compat_prompts`, `compat_packages`, and `packages_cli` integration tests).

---

## Phase 4 — Context lifecycle

### Context state

- [x] Define `ContextState`.
- [x] Define `ContextPolicy`.
- [x] Define context-action enum.
- [x] Track token estimates/measurements.
- [x] Track recent-context target.
- [x] Track context compaction epochs.

### Profiles

- [x] Implement `balanced`.
- [x] Implement `aggressive`.
- [x] Implement `relaxed`.
- [x] Lower thresholds for constrained windows.
- [x] Do not auto-scale upward for large advertised windows.
- [x] Expose advanced numeric overrides.

### L0 reduction

> Evidenced by the oversized-tool-output path: `rupi-runtime` reads the journal back and
> asserts that a reduced result carries a `context_reduced` event whose recovery
> reference resolves to a blob holding the full, redacted output. A reduction that
> cannot be stored still logs the event, with no reference, rather than logging nothing.

- [x] Detect oversized new tool output.
- [x] Archive full output.
- [x] Replace with bounded model-visible representation.
- [x] Preserve recovery reference.
- [x] Log reduction event.

### L1 ordinary compaction

- [x] Implement ordinary compaction (`TurnLoop::compact` in `crates/rupi-runtime/src/turn.rs`).
- [x] Retain recent context (retained tail kept alongside canonical summary).
- [x] Persist compaction event (`ContextCompactionStarted`, `ContextSummary`, `ContextCompactionEpoch`, `ContextCompactionCompleted`).
- [x] Preserve original trace (original events remain in `trace.jsonl` with epoch tracking).
- [x] Recover once from an uncommitted provider `ContextOverflow` by compacting only
      pre-turn history and reissuing the exact normal request shape; committed output,
      no prehistory, a second refusal, or an unfit candidate remains terminal.

### L2 semantic phase compaction

- [x] Implement phase-boundary request (`TurnLoop::compact_phase` in `crates/rupi-runtime/src/turn.rs` creates structured phase summary epoch).
- [x] Add `/compact-phase` (interactive slash command with Tab completion and optional `--force` override).
- [x] Allow model-facing semantic compaction recommendation (`ContextAction::Compact` with `ContextLevel::L2Phase` routes to phase compaction).
- [x] Restrict execution to safe idle boundaries (phase compaction executed between turn requests or via interactive command when idle).
- [x] Add cooldown/rearm gate (5-second default cooldown interval between phase compactions, bypassable via `force: true` / `--force`).

### L3 checkpoint/reset

- [x] Define structured capsule schema (`ContextCapsule`, `CapsuleDecision`, `CapsuleArtifact`, `CAPSULE_SCHEMA_VERSION`).
- [x] Implement checkpoint archive (`Store::list_checkpoints`, `StoreTrace::create_checkpoint`, `sessions/<id>/checkpoints/<cp>.json`).
- [x] Implement reviewed reset workflow (`TurnLoop::checkpoint` resets visible messages to formatted capsule, advances context epoch).
- [x] Add `/checkpoints` (interactive command lists capsules with objectives, completion status, and artifacts; Tab completed).
- [x] Preserve unresolved constraints and next actions (`ContextCapsule` fields).
- [x] Keep reset user-reviewable (capsule contents viewable via `/checkpoints` and formatted structured block).

### Session resume optimization

- [x] Resume from latest checkpoint + post-checkpoint events (`continue_state` in `src/run.rs` restores the checkpoint capsule and reduced message window).
- [x] Restore active model epochs, context epochs, cited sequence bounds, and resumed lifecycle state without duplicating epoch 0 (`StoreTrace`, `ResumeState`, and `tests/resume_cli.rs`).
- [x] Apply durable compaction projections, retain post-checkpoint capsules as impermeable floors, and preserve canonical replacement ranges across resume (`SessionLog::restore` and runtime regression tests).
- [x] Avoid full historical trace hydration (checkpoint and compaction projections act as barriers for model context reconstruction).
- [x] Benchmark large-session restore (`bench/large_session.sh` and `crates/rupi-store/benches/restore.rs` measure 10, 100, 500, and 1,000 turns with and without checkpoint barriers).

### Stage gate

> Compaction-without-canonical-loss is evidenced by `tests/trace_cli.rs::a_compaction_epoch_record_drops_no_canonical_record`,
> which reads the trace journal after a compaction epoch and asserts every record remains addressable.
> Profile-based context requires no manual numeric tuning: `balanced`/`aggressive`/`relaxed` profiles work
> out of the box without per-session numeric overrides. Checkpoint is reviewable via `/checkpoints` command.
> Large-session resume benchmark is verified via `bench/large_session.sh` (1,000-turn historical restore runs in ~2.2 ms).

- [x] Long sessions can compact without losing canonical trace (`tests/trace_cli.rs::a_compaction_epoch_record_drops_no_canonical_record` asserts all records remain addressable after epoch).
- [x] Context profile requires no manual numeric tuning for normal use (`balanced`, `aggressive`, `relaxed` profiles work out of the box via `ContextPolicy` defaults).
- [x] Checkpoint/reset is reviewable and recoverable (`ContextCapsule` viewable via `/checkpoints`, checkpoint barrier recorded in trace with formatted structured block).
- [x] Resume time remains low for large historical sessions (`bench/large_session.sh` verifies 1,000 turns with checkpoint barriers restores in ~2.2 ms, bounding active message hydration to 200 messages).

---

## Phase 5 — Model failover

### Failure classification

- [x] Implement retryable transport failures (`ModelFailureKind::Transport` in `crates/rupi-core/src/failure.rs`).
- [x] Implement timeout classification (`ModelFailureKind::Timeout`, 408 / socket timeout).
- [x] Keep idle expiry at the HTTP/SSE transport boundary while tool arguments or response
      bodies are buffered. The reproduced false timeout is fixed; 29 transport fixtures pass,
      including quiet expiry, active partial frames/bodies, total deadlines and cancellation.
      Required local checks and author invariant review pass for PR #142; startup measures
      188.58 ms cold and 11.98 ms warm median. Case 08's live retry retains its original binary
      and settings; comparison gates remain open.
- [x] Implement rate-limit classification (`ModelFailureKind::RateLimited`, 429 with retry-after header parsing).
- [x] Implement provider-unavailable classification (`ModelFailureKind::ProviderUnavailable`, 5xx, missing endpoint).
- [x] Implement authentication classification (`ModelFailureKind::Authentication`, 401/403).
- [x] Implement protocol-failure classification (`ModelFailureKind::Protocol`, malformed SSE/JSON/schema).
- [x] Implement context-overflow classification (`ModelFailureKind::ContextOverflow`, context window error parsing).
- [x] Separate semantic/quality failures from availability failures (`ModelFailureKind::Semantic` is non-availability and never retried or failed over).

### Retry

- [x] Add bounded retry policy.
- [x] Add backoff (exponential backoff with server retry-after honoring).
- [x] Emit retry events.
- [x] Support cancellation during retry (cancellation checked during backoff sleep).

### Backup model

- [x] Add primary/backup configuration.
- [x] Validate backup config without eagerly initializing it.
- [x] Add manual `/failover` (`SessionHandle::failover_manual`, interactive `/failover` command).
- [x] Add model epoch transition (`EpochReason::ManualSwitch`).

### Capability gate

> The gate compares declared capability snapshots, so it decides before any adapter is
> built. `FailoverPolicy::decide` is covered by `crates/rupi-runtime/src/failover.rs`
> tests for each gap kind, and the two decisions that reach a user — refusal by name,
> and a narrowed takeover that names the window it lost — are covered end to end in
> `tests/failover_cli.rs`.

- [x] Compare primary and backup capabilities.
- [x] Detect missing image support.
- [x] Detect missing tool support.
- [x] Detect smaller context window.
- [x] Rebudget/compact before takeover when possible.
- [x] Refuse impossible failover explicitly.
- [x] Preserve required capability gates when retry policy tuning replaces a failover policy (`with_required_capabilities` and runtime regression coverage).

### Side-effect continuity

- [x] Preserve committed tool results across failover.
- [x] Detect `Unknown` tool completion (`ToolExecutionState::Unknown` and `AgentEvent::ToolUnknown`).
- [x] Prevent blind replay of mutating operations (cancelled/uncertain mutating calls coerced to `Unknown`).
- [x] Add reconciliation path for uncertain state (`ReconciliationStatus` on `Tool` trait, `ToolRegistry::reconcile`, and `TurnEngine::reconcile_tool_call` disambiguate `write`/`edit` side effects into `Committed`, `Unmodified`, `Diverged`, or `RequiresManualInspection`; verified in `crates/rupi-tools/tests/registry.rs`).

### Recovery policy

- [x] Keep backup active after failover (active model persists across subsequent turns).
- [x] Add explicit switch-back command (`SessionHandle::switch_back_manual`, interactive `/switch-back`).
- [x] Avoid automatic ping-pong.

### Stage gate

> The checked lines below are evidenced by `tests/failover_cli.rs`, which drives the
> real CLI against loopback HTTP endpoints: a 503 twice, then a backup whose endpoint
> declares different capabilities from the primary's. A text-only backup is refused by
> name and never contacted; a smaller-window backup takes over and the transcript names
> the window it lost.

- [x] Simulated provider failure can continue on backup without replaying committed side effects.
- [x] Smaller backup context is handled through compaction or explicit refusal.
- [x] Failover provenance is visible in trace and UI.
- [x] Backup initialization does not slow normal startup.

---

## Phase 6 — MCP client

### Protocol

- [x] Implement MCP transport abstraction (`McpTransport` trait).
- [x] Implement stdio transport (`StdioTransport` with child process and JSON-RPC 2.0).
- [x] Implement supported network transport (lazy Streamable HTTP POST with bounded JSON/SSE responses, session headers, status/id validation, and config redaction; long-lived push/cancellation remains deferred).
- [x] Add protocol negotiation (`initialize` handshake and version agreement).
- [x] Add selected older-version compatibility (`2024-11-05`, `2024-10-07`).
- [x] Normalize tool schemas (`McpToolDefinition` input schema mapped to tool JSON schema).

### Lazy discovery

- [x] Do not connect all configured servers at startup (startup verified at ~3.2 ms).
- [x] Add server activation API (`McpManager::enable_server`, `SessionHandle::mcp_enable`, `/mcp enable`).
- [x] Add capability filtering (`read_only_tools`, selective server activation).
- [x] Add lazy schema discovery (`tools/list` on activation).
- [x] Cache discovered capabilities (`McpManager::active_tools`).
- [x] Measure first-use latency (`first_use_latencies` reported in `/mcp`).

### Tool integration

- [x] Normalize MCP tools into internal tool abstraction (`McpTool` implementing `Tool`).
- [x] Preserve provenance/source metadata (`[MCP:{server}]` description, namespaced identifier).
- [x] Emit MCP tool lifecycle events (participates in `ToolRegistry` lifecycle, preserving `Unknown` on uncertain mutation).

### Stage gate

- [x] A configured MCP server can be used without delaying startup (warm startup ~3.2 ms vs <100 ms budget; HTTP construction performs no I/O).
- [x] Large MCP catalogs do not all enter model context by default (activation is lazy and filtered).
- [x] MCP tools participate in the same trace/tool lifecycle as native tools (verified via `mcp_integration.rs`).
- [x] A configured HTTP MCP endpoint is selected lazily and passes initialize/tools-list through the same client (`rupi-mcp` manager/transport wire tests); JSON and bounded SSE responses, session headers, notification 202/204, status/id failures, reserved headers, and response limits are covered.

---

## Phase 7 — `rkb-rs` first-party integration

### Integration package

- [x] Create `rupi-rkb` package/extension (`crates/rupi-rkb` is a downstream adapter;
      its bundled `package.json`/`SKILL.md` are inspectable without linking the external
      `rkb-rs` crate).
- [x] Add setup/discovery (`RkbSetup::discover` recognizes caller-provided `rkb`/`rkb-rs`
      MCP configurations without process or network I/O; `normalize_configs` preserves
      the endpoint while marking all known retrieval tools read-only before manager use).
- [x] Add RKB skill (bundled citation and rehydration instructions are offered only when
      an RKB server is configured, with explicit `/mcp enable` guidance for lazy activation).
- [x] Add MCP connection path (`RkbAdapter` activates the existing lazy manager only on
      explicit activation and normalizes read-only RKB retrieval tools).
- [x] Add citation-aware rendering (`RkbContextEntry` retains citation, URL, document,
      page, and record metadata; generic TUI rendering displays source metadata).

### External-context model

- [x] Implement `ExternalContextRef` (provider-neutral, serializable identity plus
      provider-owned metadata).
- [x] Preserve durable RKB resource IDs (`record_id` is retained in the reference and
      session projection).
- [x] Preserve source/citation metadata (retrieval events and `SessionMessage.external_context`
      retain citation, provenance, URL/document/page, and RKB record fields).
- [x] Allow compaction from inline evidence to reference (`compact_to_reference` and
      `RkbContext::compact_to_references` preserve identity without inline bytes).
- [x] Allow rehydration on demand (`RkbConnection::resolve_external_ref` performs an exact
      `search_chunks` lookup and fails closed when the resource is unavailable).
- [x] Emit external-context retrieval events (`TurnLoop::run_turn_with_external_context`
      emits and durably records the associated model-visible message).

### Stage gate

- [x] RKB evidence can enter context, be compacted to references, and later rehydrate
      (`tests/rkb_integration.rs` gate fixture).
- [x] Source provenance survives all context transformations (core reference round trip,
      runtime/store resume fixture, and RKB citation metadata tests).
- [x] RKB remains an independent project with no core dependency (`rupi-rkb` depends on
      generic core/MCP contracts; `rupi-core` has no RKB dependency).

---

## Phase 8 — TypeScript extension compatibility host

### Host runtime

- [x] Define host RPC protocol (`rupi-extension` uses typed request/response values over
      a private JSON-lines Node boundary; process loss and extension errors are distinct).
- [x] Spawn Node host lazily (construction and an empty module list perform no process I/O;
      `start` is the explicit activation boundary).
- [x] Implement extension process lifecycle (module validation, load, ready/failed/stopped
      status, lifecycle dispatch, explicit shutdown, and process cleanup).
- [x] Isolate extension failures from core process (typed boundary errors; a mutating
      extension tool reports `Unknown` when completion is not observed).

### Extension APIs

- [x] Support tool registration (`pi.registerTool` metadata/schema plus async execution,
      progress events, and a `rupi-core::Tool` wrapper).
- [x] Support slash-command registration (`pi.registerCommand` and command dispatch).
- [x] Support selected lifecycle events (`session_start`, `session_shutdown`, `turn_start`,
      `turn_end`, `tool_call`, and `tool_result`).
- [x] Support context hooks (`context` message transformation).
- [x] Support selected TUI hooks (`ctx.ui.notify`, `setStatus`, and `setWidget` as typed
      UI events; full custom widgets remain deferred).
- [x] Add representative compatibility fixtures (`tests/compat/extensions/*.ts` uses the
      documented Pi default factory shape and type-only package import).

### Stage gate

- [x] Representative Pi TypeScript extensions run with minimal/no changes
      (`tests/extension_host.rs`: tool, command, lifecycle, context, and UI dispatch).
- [x] Node is not launched when no compatible extension requires it (empty-host test and
      construction-only API; CI pins/verifies Node 22.x separately).
- [x] Extension failure does not corrupt the core session (hook error remains a typed host
      error, process loss is distinct, host stays usable, mutating tool failure is `Unknown`,
      and a core registry can still be constructed; `tests/extension_host.rs`).

---

## Phase 9 — MCP server / worker mode

### Agent API

- [x] Implement `agent.start` (`rupi-mcp::worker::WorkerService` returns a stable session/run
      handle and accepts an optional bounded wait).
- [x] Implement `agent.continue` against the same worker session.
- [x] Implement `agent.cancel` with a per-run cancellation token and terminal cancellation state.
- [x] Implement `agent.branch` for current-state branches; checkpoint/event branch requests are
      explicitly unsupported until an engine supplies historical snapshots (Phase 10).
- [x] Implement `agent.compact` with conversation/phase/checkpoint modes and a context epoch.

### Resources

- [x] Expose session state.
- [x] Expose external summary.
- [x] Expose model-visible messages with bounded sequence pagination.
- [x] Expose a coarse trace projection with ordering, attribution, and provenance only.
- [x] Expose diff availability and typed diff entries when an engine supplies them.
- [x] Expose artifact references and explicit unavailable state.
- [x] Expose latest checkpoint metadata/capsule when an engine supplies one.

### Orchestration semantics

- [x] Support long-running execution semantics (asynchronous run handles, bounded `wait_ms`,
      per-run cancellation, and resource polling).
- [x] Keep internal trace separate from external summaries; no hidden reasoning is inferred.
- [x] Preserve model epochs and failover history in the typed worker state projection supplied
      by the headless engine.
- [x] Keep API coarse and stable (`agent.*` tools and `session://` JSON resources); the stdio
      dispatcher exposes no implementation paths or raw event payloads.

### Stage gate

- [x] External orchestrator can run and inspect a `rupi` worker without scraping terminal output
      (`rupi-mcp::worker::serve_stdio` and MCP handshake/tools/resources fixtures).
- [x] Worker API does not expose unnecessary internal implementation details (bounded resource
      projections, explicit diff/artifact availability, and typed domain errors).

---

## Phase 10 — Replay and research tooling

### Replay

- [x] Implement read-only `rupi replay` over canonical trace/session JSONL.
- [x] Filter by tools.
- [x] Filter by reasoning.
- [x] Filter by timing.
- [x] Replay until event (inclusive, ordered by sequence number).
- [x] Reconstruct model-visible context at an event while retaining canonical history separately.

### Branching

- [x] Plan a dry branch from a historical event without executing it.
- [x] Mark any future execution boundary separately from historical replay.
- [x] Compare two continuations structurally from the same historical state.

### Analysis

- [x] Add model-epoch timeline.
- [x] Add compaction timeline.
- [x] Add failover timeline.
- [x] Add provenance summary without inferring hidden reasoning.
- [x] Add redacted trace export that omits raw payload references/content.

### Stage gate

- [x] Historical execution can be inspected deterministically without confusing replay with new generation.
- [x] Model-visible context can be reconstructed for selected events.

---

## Phase 11 — Adaptive optimization experiments

Do not begin until stable baselines exist.

### Context adaptation

- [x] Measure prefill latency vs context size (`rupi-experiments::context`, `bench/context_prefill.sh`, and `ModelRequestCompleted.first_delta_ms`).
- [x] Detect model/runtime-specific performance knees (`KneeDetector::detect_knee`).
- [x] Prototype adaptive context thresholds (`AdaptiveContextPolicy` caps/lowers compact thresholds).
- [x] Compare against static profiles (`AdaptiveContextPolicy::compare_with_static`).
- [x] Keep adaptive mode opt-in initially (`RuntimeConfig.adaptive_context` defaults to disabled).

### Backup optimization

- [x] Evaluate optional warm standby (`rupi-experiments::backup::evaluate_standby_tradeoff`).
- [x] Measure startup/memory trade-offs (`StandbyTradeoffAnalysis` models startup vs takeover delay).
- [x] Keep cold backup as default (retained default via `Deferred` in `src/run.rs`).

### MCP optimization

- [x] Explore predictive/lazy capability prefetch (`rupi-experiments::mcp::evaluate_mcp_exposure`).
- [x] Measure schema exposure vs model performance (evaluated minimal vs predictive vs eager token footprint).
- [x] Keep minimal exposure as default (retained lazy activation in `McpManager`).

### Stage gate

- [x] Experimental optimization demonstrates measurable benefit without degrading predictability (benchmarked in `bench/context_prefill.sh` with sub-microsecond evaluation and verified monotonicity).
- [x] Static/default behavior remains available and stable (zero startup regression, all workspace tests pass).

---

## Current priorities — plan of record

> Updated 2026-09-27 after Round 9 audit implementation and the `rupi` rebrand work. This
> section remains the phase-by-phase record of verified implementation state; release
> evidence belongs in the release notes and CI. The current release target is `v0.2.2`.

### P0 — Next

- [x] Pre-emptive reduction producer: a `Compact` policy recommendation at a safe
      boundary now evicts the oldest model-visible turns to the profile's recent
      target, recorded as `ContextReduced` with the target it reached (the durable
      epoch it does not open stays in the trace untouched).
- [x] Summarizing compaction producer: the durable compaction epoch mechanism is
      implemented (`TurnLoop::compact`); request-size/window-pressure heuristic
      producer triggers compaction during the agent loop via `CompactionStrategy::Summarize`
      or pluggable `Summarizer`, and `/compact [notes]` interactive command enables manual
      compaction with epoch tracking.
- [x] Fold retrieved external context into the turn: `ExternalContextItem` supports
      inline and reference payloads, emits `ExternalContextRetrieved` to the event trace,
      and folds formatted context and citations into the model's message path via
      `TurnLoop::run_turn_with_external_context`.
- [x] Slash-completion for the interactive input line, plus its benchmark: `Tab` walks
      `Completions` in `rupi-tui::complete`, the editor owns the cycle, and the loop answers
      `/help`, `/quit`, and `/exit` itself.

### P1 — Follow-on

- [x] Load `SKILL.md` bodies and honour `disable-model-invocation`; present skills to
      the model as a skill-control prompt: `Skill::body()` reads one on demand, the block
      Pi offers (`skill::control_prompt`) names only visible skills, and `run`/`interactive`
      send it as the system message; `--show` is the explicit invocation, and
      `--control-prompt` shows exactly what a session would send.
- [x] Invoke a prompt template from inside a session (`/name`): `interactive` discovers
      the scan at open, Tab completes the names, and `prompt::parse_arguments` splits the
      typed string by Pi's editor rule — quotes stripped, empty quotes no argument,
      unclosed quote swallows the rest.
- [x] Checkpoint creation driven by the runtime under context pressure, not only the
      explicit path; document what a checkpoint does to compaction policy:
      `ContextAction::SuggestCheckpoint` triggers automatic capsule synthesis and
      checkpoint barrier reset; documented in Canonical Design §15 and ARCHITECTURE.md §10.
- [x] Import a whole Pi session directory: `import-pi <dir>` files every `*.jsonl` it holds
      directly, each as its own session, and names cross-file lineage as the thing it
      deliberately does not reconstruct.
- [x] Close the task-ledger recovery slice: freeze the external subprocess oracle,
      expose and surface the bounded model-request budget, reserve no-tools
      finalization with `--finalize` resume support, persist resumable interrupted
      sessions, document Windows shell behavior, add direct argv process execution,
      and verify the toy project plus full workspace on Windows (case remediation
      record and PR #105, 2026-09-20).
- [x] Validate the next live project, Read Queue: a dependency-free Python
      HTTP/SQLite service with fresh-process restart verification. The initial
      bounded run exposed generic reasoning-dialect and Windows tool guidance
      friction; PR #108 normalized `minimal` to the supported low wire value,
      preserved bounded provider diagnostics, and re-ran the case with 67 project
      tests, the HTTP/restart oracle, trace, replay, and all three CI platforms
      green (2026-09-20).
- [x] Validate the next live project, Event Outbox: a dependency-free Python
      HTTP/SQLite outbox with idempotent admission, retryable delivery, and a
      direct-argv NDJSON sink worker. The first bounded run exposed output-limit
      completion ambiguity, a timeout recovery retry, and slow in-flight teardown;
      the runtime now preserves output-limit failures, bounds provider requests,
      and includes recovery in the request budget. Final live evidence recorded
      one typed timeout with no retry/failover, six project tests, the independent
      HTTP/restart/sink oracle, trace, and replay green (PR #110, 2026-09-20).
- [!] Validate the next live project, Webhook Inbox: a dependency-free Python
      HMAC-authenticated HTTP/SQLite inbox with expiring delivery leases,
      crash reclaim, and a direct-argv sink worker. The checked-in project suite
      and independent fresh-process oracle pass after bounded tester repair, and
      the opt-in one-shot progress boundary is verified. The final fresh-model
      retries still produced only partial files and failed both acceptance
      checks, so the model-authoring stopgate remains active; see PR #111 and
      `docs/cases/2026-09-20-webhook-inbox/BUDGET_RETRY_REPORT.md` (2026-09-20).
- [!] Validate the next live project, Batch Relay: a dependency-free Python
      HMAC-authenticated HTTP/SQLite batch worker with atomic dependency DAGs,
      retryable and terminal failures, blocked dependents, lease reclaim, and
      a direct-argv sink. The checked-in project suite and independent
      fresh-process oracle pass after bounded tester repair, but both fresh
      model turns timed out before their first write. The model-authoring
      stopgate remains active; see PR #112 and
      `docs/cases/2026-09-20-batch-relay/FINAL_REPORT.md` (2026-09-20).
- [!] Validate the next live project, Artifact Pipeline: a dependency-free
      Python HMAC-authenticated HTTP/SQLite pipeline worker with declared
      output-to-input data flow, retryable and terminal failures, blocked
      dependents, lease reclaim, and a direct-argv sink. The checked-in project
      suite and independent fresh-process oracle pass after bounded tester
      repair, but the model turns timed out or exhausted their budgets before
      functional completion. The model-authoring stopgate remains active; see
      PR #113 and `docs/cases/2026-09-20-artifact-pipeline/FINAL_REPORT.md`
      (2026-09-20).
- [!] Validate the next live project, Lease Cascade: a dependency-free Python
      HMAC-authenticated HTTP/SQLite pipeline worker with ordered barrier fan-in,
      selected output propagation, retryable and terminal failures, blocked
      cascades, lease reclaim, and a direct-argv sink. The checked-in project
      suite and independent fresh-process oracle pass after bounded tester
      repair, but the model turns timed out before functional completion. The
      model-authoring stopgate remains active; see PR #114 and
      `docs/cases/2026-09-20-lease-cascade/FINAL_REPORT.md` (2026-09-20).
- [!] Validate the next live project, Lease Fence: a dependency-free Python
      HMAC-authenticated HTTP/SQLite pipeline worker with private claim fencing,
      stale-worker rejection, ordered barrier fan-in, retryable and terminal
      failures, blocked dependents, lease reclaim, and a direct-argv sink. The
      checked-in project suite and independent fresh-process oracle pass after
      bounded tester repair, but both model turns stopped before functional
      completion. The model-authoring stopgate remains active; see PR #115 and
      `docs/cases/2026-09-20-lease-fence/FINAL_REPORT.md` (2026-09-20).
- [!] Validate the next live project, Lease Receipt: a dependency-free Python
      HMAC-authenticated HTTP/SQLite pipeline worker with stable delivery keys,
      durable sink receipts, lost-acknowledgement recovery, private lease
      fencing, ordered barrier fan-in, retryable and terminal failures, blocked
      dependents, and a direct-argv sink. The checked-in project suite and
      independent fresh-process oracle pass after bounded tester repair, but
      both model turns timed out before writing implementation files. The
      model-authoring stopgate remains active; see PR #116 and
      `docs/cases/2026-09-20-lease-receipt/FINAL_REPORT.md` (2026-09-20).
- [!] Validate the next live project, Receipt Ledger: a dependency-free Python
      HMAC-authenticated HTTP/SQLite pipeline worker with a same-transaction
      SHA-256 audit chain, read-only verification, tamper detection, stable
      delivery keys, durable sink receipts, private lease fencing, ordered
      barrier fan-in, retryable and terminal failures, blocked dependents, and
      a direct-argv sink. The checked-in project suite and independent
      fresh-process oracle pass after bounded tester repair, but both model
      turns stopped before functional completion. The model-authoring stopgate
      remains active; see PR #117 and
      `docs/cases/2026-09-20-receipt-ledger/FINAL_REPORT.md` (2026-09-20).

### Completed audit follow-up — Round 1 (PR #120)

The 2026-09-22 audit in `audits/2026-09-22/round01.md` identified five
measurement and runtime gaps. All five items are implemented and verified on
2026-09-22. PR #120's Ubuntu, macOS, and Windows checks passed; startup
benchmarks passed on the non-Windows runners, as configured.

- [x] Separate logical prompt tokens from uncached input, cache reads/writes,
      output, and provider totals; verify the Pi comparison metrics.
- [x] Reduce completed known tool cycles within an active user turn while
      retaining safe call/result boundaries and canonical journal records.
- [x] Preserve coding objectives, artifacts, constraints, verification outcomes,
      unresolved work, and next actions in compaction/checkpoint summaries.
- [x] Always supply the native coding-agent prompt and append available skills.
- [x] Return a successful headless status for durably recorded budget exhaustion;
      keep the structured turn status resumable and persistence errors fatal.

### Completed audit follow-up — Round 2 (PR #121)

The 2026-09-22 Round 2 audit identified seven runtime/provider consistency gaps. All seven
fixes have regression coverage and passed workspace verification on 2026-09-22:

- [x] Keep same-turn compaction from crossing an earlier `Unknown` or unresolved tool result.
- [x] Make model-visible tools and guidance match what the active surface can execute.
- [x] Recalculate context thresholds for the active model window and scope adaptive knees by model.
- [x] Return malformed or ambiguously correlated tool calls as failed results for model correction;
      never execute rejected calls and synthesize missing call IDs.
- [x] Size the full assembled request, including system prompt and exposed tool schemas, before
      evaluating context pressure.
- [x] Close one-shot budget exhaustion as `Interrupted` while retaining successful resumable exit.
- [x] Recognize `prompt_cache_hit_tokens` and top-level `cached_tokens` usage aliases.

Evidence: `cargo fmt --all --check`, `cargo check -p rupi-core --all-features`,
`cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, and
`cargo doc --workspace --no-deps` passed. Startup and context-prefill benchmarks also passed
on this Windows host; recorded startup cold/warm means were 122.40/6.34 ms. The audit's
recommended model comparison cases 01, 02, 04, and 06 were not rerun because the configured
local OpenAI-compatible server at `127.0.0.1:8000` was not running.

### Completed audit follow-up — Round 3 (PR #122)

All four findings in `audits/pi-benchmark-audit/round03.md` are implemented with regression
coverage. The changed runtime, provider, and MCP boundaries passed full workspace verification
and the applicable context/startup benchmarks.

- [x] Make context policy use the current request estimate and rebudget failover against the
      backup's assembled prompt, retained messages, and exposed tools.
- [x] Settle every committed assistant tool-call batch with model-visible terminal results,
      including cancellation and no-tool finalization.
- [x] Correlate an unkeyed provider fragment only with one open, unconflicted keyed call;
      fail closed on ambiguity and leave completed calls untouched.
- [x] Admit MCP tools through provider-safe name validation and bounded schema/description,
      per-server, and aggregate capability budgets.
- [x] Complete source review, documentation reconciliation, full checks, and available
      performance-budget verification.

Evidence: `cargo fmt --all --check`, `cargo check -p rupi-core --all-features`,
`cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, and
`cargo doc --workspace --no-deps` passed. `bench/startup.sh --json bench/results/startup-ci.json`
passed (cold 125.25 ms; warm mean 6.82 ms); `bench/context_prefill.sh` passed all five
budgets. The recommended live model comparison cases 01, 02, 04, and 06 were not rerun: the
configured endpoint at `127.0.0.1:8000` was offline, and the documented 88-GB model checkpoint
exceeds this host's approximately 64-GB physical memory. This does not establish Pi parity.

### Completed audit follow-up — Round 4 (PR #123)

`audits/pi-benchmark-audit/round04.md` identified seven runtime/provider gaps. The Round-4
implementation is merged and regression-covered; Round 5 records new boundary cases, not
unfinished Round-4 requirements:

- [x] Validate every supplied tool argument against the registered schema; reject extra fields
      on built-ins before preflight, approval, or execution (`crates/rupi-tools/src/registry.rs`;
      registry regressions cover optional fields, nested arrays/objects, enums, extra properties,
      and the pre-`ToolStarted` boundary).
- [x] Enforce the progress boundary as a runtime postcondition, not only prompt/tool filtering.
      Required tool choice is sent as a provider hint; rejected text-only completion is omitted
      from model-visible history and final report text, and unsatisfied budget ends incomplete.
- [x] Add an explicit recurring progress-boundary mode while keeping one-shot behavior the
      default. Reapply the inspection limit after successful changes and correct text-only
      completion before any observed change. Config/runtime/CLI fixtures, required local checks
      and author invariant review pass. Startup measures 143.30 ms cold and 8.12 ms warm median,
      within 250/100 ms budgets. This proves the runtime contract, not a Case08 win. See
      [the slice brief](docs/benchmark/2026-10-04-recurring-progress.md).
- [x] Make same-model retry eligibility depend on request replay safety as well as failure kind.
      `ModelFailure` distinguishes safe dispatch, ambiguous POST boundaries, and committed output;
      the runtime retries only safe requests. Explicit retry-safe HTTP responses and known
      pre-dispatch failures retain retry behavior, while ambiguous timeouts go directly to
      failover/stop. Provider and CLI regressions assert quarantine, request counts, and no fake
      `ModelRetry` event.
- [x] Expose OpenAI-compatible dialect configuration through `ModelEndpoint`.
      Endpoint options now reach adapter stream/usage mode, token-limit field, thinking input and
      explicit-off dialect, native-reasoning replay, and redacted custom headers. Config parsing,
      validation/redaction, adapter mapping, and fake-server wire regressions cover the path.
- [x] Add capability-gated preferred/required constrained tool sampling.
      Built-ins request `Prefer`; endpoint support is explicit. The adapter normalizes the
      supported strict-schema subset, falls back for preferences, and refuses unsupported or
      unnormalizable `Require` requests before dispatch. Runtime argument validation remains
      authoritative; registry, mapper, and wire regressions cover the contract.
- [x] Add one bounded recovery attempt for eligible output truncation.
      The runtime compares reported output usage with the explicit effective request
      ceiling, compacts only pre-turn history, and retries once on the same model. Failed
      deltas and never-executed tool calls remain trace evidence but are omitted from the
      next request/session projection. Tests cover below-ceiling recovery, full-ceiling
      rejection, no side effects, same-model behavior, one-shot bounds, and request budget.
- [x] Apply context overrides consistently across active windows and adaptive policy.
      Each active model window derives profile thresholds before overrides are applied;
      normalized ordering is enforced, and adjustments emit one durable warning per model
      window. Adaptive knees apply afterward as caps that can only lower those thresholds.
      Core, adaptive-policy, failover, and durable-diagnostic regressions cover precedence.
- [x] Keep P2 tokenizer-estimator calibration and model-readable reduced-output recovery tracked;
      these are outside the Round-4 blocking slice and remain deferred.

The local-model behavior comparisons remain contingent on an available endpoint/model; deterministic
fault-injection tests are the required gate for the runtime contracts in this slice.

### Completed audit follow-up — Round 5 (PR #125)

`audits/pi-benchmark-audit/round05.md` identified seven runtime/provider boundary gaps. The
Round-5 implementation is regression-covered and verified:

- [x] Output-limit recovery is blocked after reasoning or assistant text reaches an irreversible
      live surface. Headless/buffered surfaces retain the one-shot recovery path; incomplete output
      and never-executed tool calls remain out of the next model context.
- [x] Request budgeting includes the assembled prompt and exposed tools, keeps desired and
      effective output ceilings distinct, applies the effective limit exactly on the wire, and
      leaves a safety reserve. Endpoint-only output ceilings are visible to runtime/recovery,
      including lazy backup capability snapshots. When a useful clamp is impossible, only safe
      pre-turn history is reduced before refusing;
      backup rebudgeting uses the same accounting.
- [x] Successfully completed assistant messages persist exposed reasoning in order with original
      provenance. Truncated/failed attempts remain trace-only; undeclared reasoning-shaped fields
      are not promoted to semantic reasoning; only endpoint-opted-in native reasoning is replayed.
- [x] Generic local/remote endpoint constructors default reasoning exposure to `None`; config and
      provider validation reject reasoning replay without an explicit native-exposure declaration.
- [x] Adapter decoding and the runtime collector bound aggregate text/reasoning/semantic events,
      raw SSE frames, tool calls, tool identities, and per-call/aggregate argument bytes before
      accumulation or execution. Regressions exercise empty-frame floods, 2,000 tiny SSE events,
      2,000 tool calls, oversized fragmented arguments, and stream-wide text/reasoning limits.
- [x] Progress boundaries fail with a durable diagnostic before another provider request if no
      executable progress tool remains under model, tool-policy, or live approval constraints.
      Availability is rechecked after activation, including after a capability-changing failover.
- [x] Token-estimator calibration and model-readable reduced-output recovery remain deferred; no
      completion claim is made for either item.

Evidence: `cargo fmt --all --check`, `cargo check -p rupi-core --all-features`,
`cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, and
`cargo doc --workspace --no-deps` passed. `bash bench/startup.sh --json
bench/results/startup-ci.json` passed (cold 122.06 ms; warm mean 5.93 ms), and
`bash bench/context_prefill.sh` passed all five budgets. No local llama.cpp comparison was run;
this Round-5 safety slice relies on deterministic fixtures, and weak-model performance remains a
later empirical focus.

### Completed audit follow-up — Round 6 (PR #126)

`audits/pi-benchmark-audit/round06.md` identified one mutating-`Unknown` safety barrier
and seven hardening/recovery gaps. The implementation is regression-covered:

- [x] A live mutating `Unknown` closes the remaining batch, blocks automatic inference and
      later mutations, and restores as a reconciliation barrier. Durable reconciliation
      facts and model-visible status survive resume; replay lifts the block only for a safe
      committed/unmodified result.
- [x] Internal request aborts use a linked request-local cancellation token and no longer
      mutate user cancellation state.
- [x] Per-turn requested tool calls are bounded (64 total, 16 mutating by default); denied
      calls receive terminal results without `ToolStarted` or execution.
- [x] Hard fit checks reserve bounded answer room without an explicit output cap while
      keeping that implicit reserve off the provider wire.
- [x] Successful logical prompt usage updates a bounded high-side calibration scoped to
      provider/model/request dialect; current requests are never replaced by stale counts.
- [x] The active provider estimates the mapped prompt, including strict-schema expansion,
      before runtime budgeting and output-ceiling resolution.
- [x] Fixed-schema configuration rejects unknown fields with nested path diagnostics.
- [x] Reduced tool output is re-readable through read-only `payload_read`, restricted to
      recently exposed opaque refs for the current session, 4 KiB ranges, and 16 MiB decoded
      payloads.

Evidence: `cargo fmt --all --check`, `cargo check -p rupi-core --all-features`,
`cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, and
`cargo doc --workspace --no-deps` passed. `bash bench/startup.sh --json
bench/results/startup-ci.json` passed (cold 136.49 ms; warm mean 6.33 ms), and
`bash bench/context_prefill.sh` passed all five budgets. No local llama.cpp comparison was
run; this is deterministic runtime-safety evidence, not a weak-model performance claim.

### Implemented audit follow-up — Round 7 (PR #128)

`audits/pi-benchmark-audit/round07.md` findings have regression coverage and passed local
workspace verification and the Ubuntu, macOS, and Windows CI matrix. Independent review
caught a tool-output payload-ref spoof, fixed with typed refs validated against canonical
completion data and a legacy-session migration; focused re-review confirmed the fix:

- [x] Convert resumed interrupted mutations that require inspection into durable,
      operator-resolvable `Unknown` barriers.
- [x] Reject blocked user prompts and external context before persisting them.
- [x] Keep reconciliation observations outside completed turn identities.
- [x] Recover context-clamped length stops against the desired output ceiling.
- [x] Expose only tools within the remaining per-turn total and mutation budgets; fail
      unsatisfiable progress boundaries as `ToolBudgetExhausted` when the budget is spent.
- [x] Bind `payload_read` authorization and visible recovery notices to active context.
- [x] Quarantine implausible usage calibration samples and require confirmation for large
      ratio jumps.

Evidence: `cargo fmt --all --check`, `cargo check -p rupi-core --all-features`,
`cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, and
`cargo doc --workspace --no-deps` passed. `bash bench/startup.sh --json
bench/results/startup-ci.json` passed (cold 128.83 ms; warm mean 6.06 ms), and
`bash bench/context_prefill.sh` passed all five budgets. No local llama.cpp comparison was
run; these tests verify runtime safety, not weak-model task performance. The slow-runner
ambiguous-timeout fixture now allows time for request setup while retaining a delayed response.

### Completed audit follow-up — Round 8 (PR #129)

`audits/pi-benchmark-audit/round08.md` identified six runtime/provider findings. The
implementation and regression coverage are merged on `main`; local verification passed and
PR #129's Ubuntu, macOS, and Windows checks succeeded:

- [x] Bind execution to the exact tool definition and permission snapshot advertised
      for each provider request; replacement/removal fails before `ToolStarted`.
- [x] Preserve semantic message origin separately from provider role through session
      persistence, legacy deserialization, compaction, and eviction.
- [x] Return duplicate provider tool-call IDs as non-executable model-correctable
      rejections instead of provider protocol failure.
- [x] Key replay tool lifecycles by causal request-event identity, not provider call ID,
      with conservative matching for parentless legacy traces.
- [x] Keep unavailable/policy-denied/rejected calls out of mutation-budget accounting
      and approval prompts while retaining total-call limits.
- [x] Bound per-call and aggregate custom-provider rejection-reason bytes.

Evidence: `cargo fmt --all --check`, `cargo check -p rupi-core --all-features`,
`cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, and
`cargo doc --workspace --no-deps` passed. `bash bench/startup.sh --json
bench/results/startup-ci.json` passed (cold 132.51 ms; warm mean 6.25 ms),
`bash bench/context_prefill.sh --json bench/results/context-prefill-ci.json` passed all five
budgets, and `bash bench/large_session.sh --json bench/results/large-session-ci.json` passed
all five session-restore budgets. No local llama.cpp comparison was run; these tests verify
runtime invariants and regression behavior, not weak-model task performance.

### In progress audit follow-up — Round 9 (WIP)

`audits/pi-benchmark-audit/round09.md` identifies five recovery/provenance correctness
findings and one conservative mutation-budget edge. This follow-up is in progress on
`fix/pi-benchmark-audit-round-09`. The independent invariant review's P1 projection-integrity
gap and P3 Pi mapping-doc mismatch were also resolved before final verification:

- [x] Persist stable tool-definition identity and require a compatible definition before
      reconciling an interrupted mutating call.
- [x] Make runtime-control provenance canonical and validate event/message-origin pairs.
- [x] Preserve typed and opaque derived context across recursive compaction; recover legacy
      origins only from unambiguous trace evidence. Canonical compaction events now bind typed
      summary state to its session projection, and restore rejects valid-JSON tampering.
- [x] Enforce unique provider tool-call identities at the runtime boundary.
- [x] Avoid charging mutation budget for stale calls proven not to have started.
- [x] Complete invariant review, workspace verification, and applicable performance checks.

Verification: `cargo fmt --all --check`, `cargo clippy --workspace --all-targets -- -D warnings`,
`cargo test --workspace`, and `cargo doc --workspace --no-deps` pass. Startup, TUI render,
context-prefill, and large-session restore benchmarks pass their budgets; the 1,000-turn
checkpoint restore measured 3.91 ms against a 30 ms budget. No weak-model superiority claim is
made by these deterministic recovery tests. A live llama.cpp comparison remains separate
empirical work.

### Completed audit follow-up — Round 10

`audits/pi-benchmark-audit/round10.md` identified six storage, lifecycle, accounting,
context-visibility, bounded-metadata, and event-versioning findings. All six are implemented
and verified on `fix/pi-benchmark-audit-round-10`:

- [x] Keep schema migration semantics-preserving; apply current redaction only to new writes.
- [x] Resolve failed/unknown tool projections through their causal invocation, not
      session-global call IDs.
- [x] Spend mutation budget only after the durable `ToolStarted` boundary.
- [x] Refuse emergency compaction that hides all prior semantic history from the model.
- [x] Preserve aggregate rejection-reason bounds through duplicate-ID normalization.
- [x] Version new event semantics as schema v2 while continuing to read supported
      v1 records.
- [x] Complete invariant review, workspace verification, and applicable performance checks.

Verification passed: `cargo fmt --all --check`, `cargo check -p rupi-core --all-features`,
workspace clippy/tests/docs, and hosted Ubuntu/macOS/Windows CI. Startup measured 134.14 ms cold
and 6.36 ms warm median; context-prefill cases passed; 1,000-turn checkpointed restore measured
3.96 ms against a 30 ms budget. This correctness slice makes no local-model completion claim;
controlled llama.cpp comparison remains separate empirical work.

### Completed audit follow-up — Round 11

`audits/pi-benchmark-audit/round11.md` identified five runtime reliability gaps across tool-effect
semantics, progress accounting, context recovery, MCP catalog freshness, and trace schema preflight.
All five findings are implemented on `fix/pi-benchmark-audit-round-11` (PR #132):

- [x] Separate tool execution state from effect disposition; stop same-batch mutation tails after
      possible effects and gate replay/progress on positive effect evidence.
- [x] Preserve bounded trusted archived-payload references in typed summaries through recursive
      L1/L2/L3 compaction and validate them against the active session blob store.
- [x] Consume MCP tool-list-change notifications, fail stale bindings closed, and reject dynamic
      catalogs when the transport cannot receive notifications.
- [x] Apply event-schema preflight to JSONL tail reads and journal open/recovery before tail repair.
- [x] Complete invariant review, workspace verification, and applicable performance checks.

Verification passed: `cargo fmt --all --check`, `cargo check --workspace --all-targets`,
`cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, and
`cargo doc --workspace --no-deps`. Startup measured 132.18 ms cold and 6.04 ms warm median;
TUI rendering passed all budgets (3.31–3.90 µs/unit); checkpointed restore measured 3.98 ms for
1,000 turns against a 30 ms budget.

### P2 — Later / deliberately deferred

- [x] Windows CI matrix (hosted CI covers Ubuntu, macOS, and Windows; benchmark execution remains non-Windows only).
- [ ] Telemetry, metrics, and analytics surfaces: deferred; privacy and scope decision.
- [x] GitHub Pages site (mdBook source under `book/`, deployment workflow under
      `.github/workflows/pages.yml`; hosted deployment remains subject to repository
      Pages configuration).
- [x] MCP server/worker mode (Phase 9): the typed `rupi-mcp::worker` adapter is implemented;
      provider/runtime composition remains explicit at its `WorkerEngine` boundary. The selected
      TypeScript extension host (Phase 8) is complete above.

---

## Ongoing cross-cutting work

### Empirical local-model comparison — Case 01 oracle gate passed; series active

- [x] Beat Pi 0.86.1 on the Case 01 acceptance oracle with the local
  `qwen3.8-flash-next` model. Latest matched evidence:
  `bench-20260929-case01-focused-contract-low-matched4`. Rupi passed the oracle
  and help in turn 4 (13,590 inference-work tokens; 1,086,371 ms); Pi did not
  pass after four turns (9,631 tokens; 1,201,171 ms). Rupi was faster but used
  more work tokens. Rupi still lacks a README and `tests/`, accepts a leading
  `+` in task IDs despite the spec, and ended `needs_reconciliation` after a
  failed inline verification command. See the experiment ledger for details.
- Earlier corrected-prompt matched evidence against pinned Pi 0.86.1:
  `bench-20260928-case01-target0861-low-matched4`. Rupi did not pass the oracle
  in four turns (11,328 inference-work tokens; 1,148,608 ms); Pi passed in turn
  3 (20,487 tokens; 901,036 ms). Both failed project-test discovery because
  neither created `tests/`. Help passed only for Rupi in turn 4 and Pi in turn
  3. See `docs/benchmark/2026-09-28-case01-task-ledger.md` for turn data.
- A separate corrected-prompt run against installed Pi 0.87.1 was a provisional
  Rupi oracle win, but does not change the pinned 0.86.1 result.
- The comparison gate is per case. Case 01 now has a target-version oracle win;
  the remaining cases still need matched evidence. The original ten-case
  summary is not evidence of current behavior.
- The successful run's prompt foregrounded both `--state PATH` positions, non-zero
  malformed-input handling, IDs written with ASCII decimal digits that denote
  positive integers, and byte-for-byte state preservation. It keeps the project
  directory as the Windows working directory; prompt rendering passed the
  PowerShell parser, dry run, and direct integrity checks.
- Case 02 matched run `bench-20260929-case02-readqueue-low-matched4` was a Pi
  win: Pi passed the oracle and both help commands in turn 3 (17,626 tokens;
  900,984 ms). Rupi stopped after its first active turn with
  `needs_reconciliation` from a Windows inline `python -c` quoting error; no
  project source was created. Both project test checks failed because no
  `tests/` directory existed. Case 02 remains open; the experiment ledger has
  exact turn data.
- Diagnostic retry `bench-20260929-case02-argv-safe-low-matched4` did not
  resolve for either agent. Rupi used 11,572 inference-work tokens before
  `needs_reconciliation`: it tried `process python --version`, but `process`
  was not a listed tool and was rejected as a shell command. Turns 2–4 had no
  model requests or tools. Pi timed out in all four turns (18,764 tokens;
  1,200,945 ms), passing neither the oracle nor help checks. Both agents failed
  test discovery because no `tests/` directory existed. The ledger records the
  turn metrics and created files; Case 02 remains open.
- The next Case 02 retry will use precise Windows tool guidance: call a
  dedicated process tool only when it is listed, otherwise run the executable
  directly through shell/exec one command per invocation. The prompt also
  prohibits `python -c` and chained commands and directs one-off checks to a
  temporary `.py` file inside the project workspace. Case-specific guidance
  continues to emphasize SQLite restart persistence, deterministic JSON, and
  state-preserving HTTP errors.
- Retry `bench-20260929-case02-tool-listed-low-matched4` still did not resolve
  for either agent. Rupi used 17,271 inference-work tokens over 1,144,139 ms;
  it attempted `python -c` despite the new guidance, wrote only package entry
  points, and ended its last two turns on provider timeouts. Pi used 16,950
  tokens over 1,200,979 ms and timed out in all four turns. Neither passed the
  oracle or help checks; both failed test discovery. Rupi was faster but used
  more tokens, so Case 02 remains open. See the ledger for details.
- The next retry will keep the CLI, handler, and SQLite logic in
  `readqueue/__main__.py` until the service and help work, and defer module
  splitting, README, and tests until then. Windows guidance will require one
  executable per command-tool call, prohibit `&`, `&&`, `;`, `|`, and inline
  Python, and keep file reads inside the project workspace.
- Entrypoint-first retry `bench-20260929-case02-entrypoint-first-low-matched4`
  was another Pi win: Pi passed the oracle and both help commands in turn 3
  (16,365 inference-work tokens; 900,676 ms). Rupi used 6,494 tokens over
  1,124,404 ms, produced no source, and its later calls hit the configured
  270,000 ms provider timeout. Both failed project test discovery. Case 02
  remains open; see the ledger for per-turn evidence.
- The next matched diagnostic will preserve the prompt, low reasoning, request
  cap, and Pi 0.86.1 target, but allow 600 seconds per turn and a 570-second
  Rupi provider deadline. This checks whether the current provider cutoff is
  preventing source output.
- Extended entrypoint-first run `bench-20260929-case02-entrypoint-first-low-matched4-600s`
  still favored Pi: it passed the oracle and both help commands in turn 2
  (24,997 work tokens; 1,200,459 ms). Rupi used 29,501 tokens over 1,466,279
  ms; help passed, but POST returned HTTP 500. Its final source defines
  `Store._session` while CRUD methods call missing `Store._connect`, and a
  failed `findstr` exec left the last turn unable to continue. Pi's generated
  project still lacked a README and discoverable tests. Case 02 remains open;
  see the ledger for the per-turn record and next diagnostic.
- Read-tool-guidance run `bench-20260929-case02-read-tool-low-matched4-600s`
  was another Pi win. Pi passed the oracle and help in turn 2 (28,419 work
  tokens; 1,200,455 ms). Rupi used 105,134 tokens over 2,117,416 ms; its help
  passed, but its request reader used `self.r` instead of `self.rfile`, causing
  HTTP 500 responses. Both generated projects still lacked a README and
  discoverable tests. Case 02 remains open; see the ledger for per-turn data.
- Explicit `rfile` and health-first retry remained a Pi win in
  `bench-20260929-case02-rfile-health-first-low-matched4-600s`. Pi passed the
  oracle, 34 project tests, and both help
  commands using 20,207 work tokens over 600,157 ms. Rupi used 52,278 tokens
  over 1,284,606 ms; its PATCH request disconnected and test discovery failed.
  Neither generated a README. Case 02 remains open; see the ledger.
- PATCH-readback run `bench-20260929-case02-patch-readback-low-matched4-600s`
  favored Pi: it passed oracle/help in one turn (17,117 work tokens; 600,254 ms).
  Rupi passed in turn 2 after 32,357 tokens and 1,200,705 ms. Both missed the
  README and test suite. Rupi's first service command exited 0 without output;
  Case 02 remains open. See the ledger.
- Module-startup retry `bench-20260929-case02-entrypoint-check-low-matched4-600s`
  favored Pi: it passed oracle/help in one turn (17,102 work tokens; 600,302 ms).
  Rupi used 10,705 work tokens over 1,190,317 ms but created no package; an
  outer timeout, provider timeout, and failed `dir /s /b` exec left it unresolved.
  Case 02 remains open. See the ledger.
- One-request `write` progress-boundary trial
  `bench-20260929-case02-progress-write-pi0861-low-matched4-600s` did not resolve
  Case 02. Rupi wrote `__main__.py` before a syntax error and
  an unresolved `exec` left `needs_reconciliation` (20,241 work tokens; 350,746 ms).
  Pi 0.86.1 passed oracle/help (17,044; 600,323 ms) but failed project tests and
  lacked a README/test module. See the ledger.
- Shared harness-verification retry
  `bench-20260929-case02-progress-guidance-pi0861-low-matched4-600s` won Case 02:
  Rupi passed oracle/help in one turn (22,020 work tokens;
  600,291 ms); Pi passed in two (30,974; 1,200,731 ms). Rupi used 8,954 fewer
  work tokens and 600,440 ms less time. Both project-test checks failed, and
  neither generated a README or test module. The benchmark win is verified;
  project-test and README requirements remain incomplete. See the ledger.
- Case 03 baseline `bench-20260929-case03-baseline-low-matched4-600s` was
  inconclusive. Rupi wrote only `outbox/__init__.py` before a failed recursive
  `dir` exec; it used 17,180 work tokens over 614,821 ms. Pi created no source
  after four outer timeouts (6,303 tokens; 2,400,993 ms). Neither resolved.
  Case 03 remains open. See the
  [Case 03 ledger](docs/benchmark/2026-09-29-case03-event-outbox-ledger.md).
- Entrypoint-first retry
  `bench-20260929-case03-entrypoint-first-progress-guidance-pi0861-low-matched4-600s`
  was a Pi win. Pi passed oracle/help in turn 1 (16,717 work tokens; 600,340 ms),
  while Rupi used 100,706 tokens over 2,268,069 ms and failed the oracle because
  SQLite files remained locked during cleanup. Rupi passed help but its final
  project test run had one worker-test error; Pi lacked project tests. Case 03
  remains open. See the ledger.
- Shutdown-guidance, cap-six retry
  `bench-20260930-case03-sqlite-shutdown-cap6-pi0861-low-matched4-600s` was
  inconclusive. Both agents created no source and failed oracle/help/test checks.
  Rupi used 5,308 work tokens over 2,324,631 ms; Pi used 4,938 over 2,401,146 ms.
  Rupi was 76,515 ms faster but used 370 more tokens. Its provider request timed
  out at 570 seconds after the progress boundary required a first `write`. Case
  03 remains open; see the ledger.
- Provider-grace-six, cap-eight retry
  `bench-20260930-case03-provider-grace6-cap8-pi0861-low-matched4-600s` was
  inconclusive. Both agents created no source and failed project tests, oracle,
  and all help checks. Rupi used 3,949 work tokens over 2,392,506 ms; Pi used
  4,964 over 2,400,798 ms. Rupi was 8,292 ms faster and used 1,015 fewer
  tokens, but neither resolved. Rupi read the spec and listed files before the
  progress boundary required its first write; that following provider request
  timed out at 594 seconds. The next retry will require the first tool operation
  to write `outbox/__main__.py`, then read the spec. Case03 and unchanged Case02
  prompt dry-runs passed. Case 03 remains open; see the ledger.
- Write-first, grace-six, cap-eight retry
  `bench-20260930-case03-write-first-grace6-cap8-pi0861-low-matched4-600s` was
  inconclusive. Both agents created only `outbox/__main__.py`; all help checks
  passed, but project-test discovery and the oracle failed. Rupi used 22,661
  work tokens over 2,395,879 ms; Pi used 5,981 over 2,400,936 ms. Rupi was
  5,057 ms faster but used 16,680 more tokens. Neither resolved. Next, embed the
  full spec and require the first write to implement the service and worker, not
  help alone. Dry-runs passed for Case03 and unchanged Case02. Case 03 remains
  open; see the ledger.
- Full-spec, complete-first-write retry
  `bench-20260930-case03-full-write-grace6-cap8-pi0861-low-matched4-600s` was a
  verified Rupi win. Rupi passed the oracle and all three help checks in turn 2
  (25,140 work tokens; 1,194,320 ms); Pi failed the oracle in all four turns
  (59,136; 2,179,607 ms). Rupi was 985,287 ms faster and used 33,996 fewer
  tokens. Rupi's project tests failed, while Pi passed them in its final two
  turns. The Case 03 Pi-comparison objective is met; the project-test failure
  remains separate. See the
  [Case 03 ledger](docs/benchmark/2026-09-29-case03-event-outbox-ledger.md).
- Pinned Case 04 baseline `bench-20260929-case04-pi0861-low-matched4-600s` was inconclusive:
  neither agent resolved in four turns. The full-spec first-write prompt rerun
  `bench-20260930-case04-full-write-grace6-cap8-pi0861-low-matched4-600s` was a Pi win: Pi
  resolved the oracle in turn 1, while Rupi did not resolve after four turns. Rupi used 11,494
  work tokens over 2,388,175 ms; Pi used 17,631 over 600,159 ms. Rupi passed only top-level help
  in turn 4; Pi passed all help checks. Both project-test checks exited 1, separately from oracle
  status. Case 04 remains open. The next iteration embeds the full spec, asks for runnable signed
  admission in the first source write, then continues with the worker and remaining requirements
  through additional writes in the same turn. That R2 rerun,
  `bench-20261001-case04-incremental-admission-grace6-cap8-pi0861-low-matched4-600s`, was also a
  Pi win: Pi resolved in turn 1 with 15,824 work tokens over 600,420 ms; Rupi did not resolve in
  four turns and used 31,666 work tokens over 2,396,345 ms. Rupi's tests failed because the test
  start directory was not importable, and worker help failed because the CLI exposed only serve.
  The recovery-gated rerun
  `bench-20261001-case04-recovery-gated-grace6-cap8-pi0861-low-matched4-600s` was another Pi win:
  Pi resolved in turn 1 with 19,771 work tokens over 600,493 ms, while Rupi did not resolve after
  four turns (26,135 work tokens over 2,007,731 ms). Rupi never passed help or project tests, and
  its final files still lacked `webhookinbox/__main__.py`. The entrypoint-first rerun
  `bench-20261001-case04-entrypoint-first-grace6-cap8-pi0861-low-matched4-600s` was Rupi's first
  oracle resolution, in turn 2 with 17,547 work tokens over 1,022,843 ms. Pi resolved in turn 1
  with 16,035 work tokens over 600,430 ms. Pi won under the fewer-turns or same-turn-fewer-tokens
  criterion; Rupi's project tests found no tests. The one-turn completion rerun
  `bench-20261001-case04-one-turn-completion-grace6-cap8-pi0861-low-matched4-600s` was a fifth Pi
  win. Rupi resolved in turn 3 with 25,525 work tokens over 1,790,693 ms; Pi resolved in turn 1
  with 15,513 tokens over 600,213 ms. Both project-test commands exited 1, while both passed
  help. Rupi's first two turns timed out without work or files. The one-write rerun
  `bench-20261001-case04-one-write-first-grace6-cap8-pi0861-low-matched4-600s` was a sixth Pi win:
  Rupi did not resolve in four turns (7,068 work tokens over 2,090,969 ms), while Pi resolved in
  turn 1 with 16,081 work tokens over 600,501 ms. Rupi made no project files; its help and tests
  failed, while Pi passed help and its project tests exited 1. The matched reasoning-off rerun is a
  verified Rupi win: it passed the oracle in turn 2 and passed project tests and all help checks.
  Pi remained unresolved after turn 2, so its earliest possible resolution was turn 3. This meets
  the recorded fewer-turn criterion. Pi's oracle, tests, and help checks failed; its snapshots had
  no generated application files. Further Pi turns were stopped after the result was decisive.
  Case 04's comparison objective is met. See the
  [Case 04 ledger](docs/benchmark/2026-09-29-case04-webhook-inbox-ledger.md).

  Case 05's pinned baseline was mixed. The embedded-spec prompt rerun was a Pi win, and the
  read-once entrypoint rerun was inconclusive. The valid-path, oracle-status rerun
  `bench-20260930-case05-valid-path-oracle-status-r2-grace6-cap8-pi0861-low-matched4-600s` was
  also inconclusive: neither agent resolved in four turns. Rupi used 25,136 work tokens over
  621,025 ms; Pi used 51,970 over 2,401,259 ms. Rupi was 1,780,234 ms faster and used 26,834
  fewer work tokens, but both failed the oracle every turn. Rupi's tests and help checks failed on
  every turn; Pi passed project tests and help on its final turn. Oracle diagnostics reported
  connection refused for both servers on every turn. Rupi's final help diagnostics reported a
  missing `batchrelay.__main__`, and test discovery could not import `tests`. The next prompt will
  prioritize an executable entrypoint, an importable test package, and persistent `/healthz`.
  The follow-up `bench-20260930-case05-entrypoint-health-tests-first-grace6-cap8-pi0861-low-matched4-600s`
  also did not resolve the case. Rupi used 31,023 work tokens over 2,397,930 ms; Pi used 32,460
  over 2,401,427 ms. Rupi was 3,497 ms faster and used 1,437 fewer work tokens, but both oracles
  failed every turn because neither server became reachable. Rupi passed help on turns 2–4 but
  its project test discovery ran zero tests; Pi's tests and help failed every turn. Case 05
  remains open. The next prompt now pins `serve` to a persistent `batchrelay.server.run` and
  requires a subprocess health check before implementing batch and worker behavior. See the
  [Case 05 ledger](docs/benchmark/2026-09-29-case05-batch-relay-ledger.md).

  The explicit server-wiring rerun `bench-20260930-case05-server-run-health-test-grace6-cap8-pi0861-low-matched4-600s`
  was a Pi win: Pi resolved in turn 3 with 31,586 work tokens over 1,801,019 ms; Rupi remained
  unresolved after four turns with 58,100 work tokens over 2,292,113 ms. Rupi passed help on all
  turns but failed project tests and never exposed a healthy server. Its generated entrypoint
  imported a missing `batchrelay.server`, and `tests/test_server.py` was absent. The next prompt
  will make the server module itself the first deliverable. Case 05 remains open; see the
  [Case 05 ledger](docs/benchmark/2026-09-29-case05-batch-relay-ledger.md).

  The server-module-first rerun
  `bench-20260930-case05-server-module-first-smoke-r6-grace6-cap8-pi0861-low-matched4-600s`
  was also a Pi win. Pi resolved in turn 2 with 31,543 work tokens over 1,200,648 ms; Rupi did
  not resolve after four turns, using 26,694 work tokens over 2,390,898 ms. Rupi's two project
  tests and all help checks passed, but oracle diagnostics reported `404 unknown path` for batch
  admission and invalid-signature requests. The next prompt will prioritize signed batch
  admission in the same first slice as server health. See the
  [Case 05 ledger](docs/benchmark/2026-09-29-case05-batch-relay-ledger.md).

  The signed-admission-first rerun
  `bench-20260930-case05-signed-admission-first-r7-grace6-cap8-pi0861-low-matched4-600s`
  was inconclusive: neither agent resolved or created a reachable server. Rupi was 582,942 ms
  faster than Pi and used 14,858 more work tokens; both agents failed oracle, project-test, and
  help checks on every turn. The next prompt returns to the health-first slice before signed
  admission. See the [Case 05 ledger](docs/benchmark/2026-09-29-case05-batch-relay-ledger.md).

  The health-first rerun
  `bench-20260930-case05-health-first-recover-admission-r8-grace6-cap8-pi0861-low-matched4-600s`
  was a Pi win. Pi resolved in turn 3 with 19,494 work tokens over 1,800,775 ms; Rupi remained
  unresolved after four turns with 74,033 work tokens over 2,401,399 ms. Rupi's project tests and
  help passed on turn 4, but the oracle failed every turn; final diagnostics reported a dropped
  batch-cycle request and a worker that never reached the sink. Pi's oracle passed on turn 3,
  while its project tests failed every turn. Case 05 remains open. The next prompt will focus on
  batch-cycle handling and worker delivery. See the
  [Case 05 ledger](docs/benchmark/2026-09-29-case05-batch-relay-ledger.md).

  The HTTP-contract-first rerun
  `bench-20260930-case05-http-contract-first-r9-grace6-cap8-pi0861-low-matched4-600s` was
  inconclusive: neither agent resolved the oracle. Rupi was 27,277 ms faster than Pi but used
  20,949 more work tokens. Rupi's oracle, project tests, and help checks failed every turn; Pi's
  oracle and project tests also failed every turn. Turn 4 diagnostics show its entrypoint imports
  a missing worker module before parsing arguments, and the generated project has no `tests`
  package. The R10 prompt establishes an importable CLI and test package before adding HTTP
  behavior. R10 was inconclusive: neither agent resolved the oracle. Rupi was 410,837 ms faster,
  while Pi used 11,467 fewer work tokens. Rupi passed CLI, test discovery, and health checks but
  did not implement HTTP behavior; Pi passed CLI checks but did not create a server. Case 05
  remains open. The R11 prompt combined CLI and health, then gated signed admission,
  contract/status, and worker on passing local checks. Its matched run was inconclusive: neither
  agent resolved the oracle. Pi was 252,037 ms faster and used 43,066 fewer work tokens. Rupi's
  local tests failed on turn 4 after the admission changes; Pi passed tests and help on turn 4 but
  did not reach HTTP admission. R12 was inconclusive: neither agent resolved the oracle. Rupi was
  1,306,672 ms faster and used 23,730 fewer work tokens, but a tool failure left its recovery turns
  inactive and all local checks failed. Pi passed project checks on turns 1, 2, and 4 and produced
  an HTTP test module. R13 was inconclusive: neither agent resolved the oracle. Rupi was
  350,998 ms faster but used 15,715 more work tokens. The first-write/no-`exec` prompt avoided
  stalled recovery and passed Rupi's CLI/server checks, but Rupi added no HTTP test module. Pi's
  tests and help passed on turns 3–4, with `tests/test_http.py` present. R14 was inconclusive:
  neither agent resolved the oracle. Rupi was 889,681 ms faster and finished with passing tests,
  help, and `tests/test_http.py`; Pi created no application files. Rupi used 49,278 more work
  tokens. Its prompt combined CLI, health, and one signed POST. R15 was inconclusive: neither agent
  resolved the oracle. Pi was 23,090 ms faster and used 41,170 fewer work tokens. Rupi passed
  health checks but has no `tests/test_http.py`; Pi passed local checks and finished with that test
  module. R16 was also inconclusive: neither agent resolved the oracle. Rupi passed project tests
  on turns 3–4 and help every turn; Pi failed project tests and help every turn. Rupi was 5,211 ms
  faster but used 36,029 more work tokens. Rupi's required CLI, health, and HTTP test files arrived
  by turn 4, but its server stayed in `batchrelay/__main__.py`; Pi produced support modules without
  a runnable entrypoint. The all-case dry run and changed-line checks passed, and CI for docs head
  `e19b1ef` passed on Ubuntu, macOS, and Windows. R17 now requires HTTP routes in
  `batchrelay/server.py` and delays test scaffolding until the service starts; the all-case dry run
  and changed-line checks passed. The first attempt stopped after Pi turn 1 because an internal
  recovery guard still expected the previous wording. Guard fix `cc0c3a2` is pushed, and the matched
  retry completed. Neither agent resolved the oracle. Pi was 750 ms faster and used 28,483 fewer
  work tokens; both passed tests on turns 2–4 and help every turn. Rupi had three tool failures and
  no final HTTP test, while Pi had `tests/test_http.py`. R18 removes the CLI-help prerequisite and
  combines health and signed admission in one recovery slice. The all-case dry run and changed-line
  checks passed. In the matched Pi 0.86.1 run, Rupi resolved the oracle in turn 4; Pi remained
  unresolved. Rupi used 38,964 more work tokens and took 399 ms longer, but the pinned comparison
  objective is met by the oracle result. See the
  [Case 05 ledger](docs/benchmark/2026-09-29-case05-batch-relay-ledger.md).

  Case 06's Sep 29 baseline run with pinned Pi 0.86.1 was a strict Pi oracle win.
  Pi resolved on turn 4 after its outer timeout, passing the oracle, all 61 project tests,
  and every help check. Rupi did not resolve. See the
  [Case 06 ledger](docs/benchmark/2026-09-29-case06-artifact-pipeline-ledger.md).
  The Oct 2 matched retry produced a strict Rupi oracle win: Rupi resolved in turn 2 after
  its outer timeout, while Pi did not resolve in four turns. Rupi used 31,406 work tokens
  over 915,351 ms; Pi used 25,848 over 2,400,909 ms. Rupi finished 1,485,558 ms faster
  but used 5,558 more work tokens. Rupi's project tests still exited 1, so the live-project
  gate above remains active. See PR #138 and the updated Case 06 ledger.

  Case 07 used the pinned Pi 0.86.1 run `bench-20260929-case07-pi0861-low-matched4-600s`. Pi
  resolved on turn 4 after its outer timeout, passing all five oracle tests, 53 project tests, and
  every help check. Rupi did not resolve: project-test discovery could not import `tests`, oracle
  requests disconnected, and `worker` help still failed. Pi used 62,288 work tokens over
  2,401,022 ms; Rupi used 69,765 over 2,288,759 ms. Pi took 112,263 ms longer but used 7,477
  fewer work tokens, a strict oracle win. See the
  [Case 07 ledger](docs/benchmark/2026-09-29-case07-lease-cascade-ledger.md).
  The Oct 3 retry29 produced a strict Rupi oracle win:
  `bench-20261003-case07-budget2048-low-retry29-rupi12-matched4-600s`.
  Rupi resolved on turn 3 after its outer timeout; Pi failed all four oracle checks.
  Both passed project tests and all help checks throughout. Rupi recorded 89,208 work
  tokens, 22 completed tools, zero failures/Unknown, and 1,494,500 ms call time; Pi
  recorded 61,382 tokens, 21 calls, and 1,795,363 ms. Call time excludes verification;
  unrecorded inference remains unknown. Shared low effort, a 2,048-token thinking budget
  through a local relay, and four 600-second turns were used. Rupi's cap was 12; Pi kept
  its native request policy. This closes the Case 07 comparison objective for PR #139;
  the remaining comparison series and broader live-project gates remain active.

  Case 08's baseline and six guided retries remain inconclusive: neither agent resolved
  the stale-worker fencing oracle in four turns. Retry01 recorded 73,794 Rupi work tokens
  versus 59,600 Pi tokens; both passed final project tests and help. The next shared
  recovery revision requires discoverable public workflow tests before implementation
  repair. Retry03 used the verified provider-idle fix and recorded 33,909 Rupi work
  tokens versus 42,512 Pi tokens; both failed final project tests and passed help.
  Unrecorded Rupi inference remains unknown. Retry04 used the shared repair bound
  and recorded 68,337 Rupi work tokens versus 61,380 Pi tokens; both failed final
  tests and passed help. The recurring progress-boundary runtime slice passed local
  checks, startup budgets, author review and final-head CI, then merged in PR #143.
  Retry05 selected recurring mode for Rupi while Pi retained its native runtime policy.
  Neither resolved in four turns: Rupi recorded 96,333 work tokens versus Pi 53,532;
  Rupi failed final tests, Pi passed them, and both passed help. The next shared candidate
  moves workflow implementation before workflow-test authoring and permits compact
  application modules. All-case routing/oracle-isolation guards and author review pass;
  retry06 was inconclusive: Rupi recorded 101,345 work tokens versus Pi 63,660;
  both failed final tests and passed help. Retry07's fresh matched six-turn pair
  from 975470f is terminal: Pi resolved on turn 2 with 31,957 recorded work tokens,
  while Rupi remained unresolved after six with 167,131. Pi's final tests, oracle and
  help pass; Rupi's tests/oracle fail and help passes. Reference/prompt/control audits
  pass; unfinished inference remains unknown. This is a configured Pi win and PR141
  remains draft. The next candidate must improve Rupi without weakening public gates.
  Shared full-workflow-first guidance now removes partial foundation yields and required
  module-name staging. Guards and author review pass; retry08 is terminal and inconclusive:
  neither resolved in six turns. Rupi recorded 176,102 work tokens versus Pi 75,531;
  both failed final tests/oracle and passed help. Reference/prompt/control audits pass;
  unfinished inference remains unknown. The next bounded candidate tests an existing
  recurring progress window of three requests instead of one; no runtime change or
  cache speedup is established. PR141 remains draft.
  The Case08-only selector keeps default1; default/selected3 all-case guards and
  author harness review pass. Retry09 from c52f79e is terminal: Pi resolves acceptance
  on turn2 with 38,151 recorded work tokens; Rupi remains unresolved after six with
  219,122. Rupi final tests/help pass, oracle fails; Pi oracle/help pass, tests exit5.
  Reference/prompt/control audits pass; unfinished inference remains unknown. This is
  a configured Pi win, not inconclusive. Next candidate selects window12 under the
  existing cap12 and first-mutation completion requirement, with other controls kept.
  All-case window12 guards and author configuration review pass. Fresh retry10 from
  39f402f is live; its initial prompt matches retry09, binary/model are unchanged.
  Rupi resolves acceptance on turn4 with 106,173 recorded work tokens; final help
  passes, project tests fail and no README is listed. Pi resolves on turn5 with72,205
  recorded work tokens; its final tests/help pass and a README is listed but unread.
  Retry10 is terminal with a configured Rupi fewer-turn win,4 versus5. All nine saved
  prompts/control/reference audits pass; binary/model remain unchanged. Required local
  Rust checks pass; startup151.749 ms cold/7.801 ms warm median meets250/100 ms budgets.
  Final head2e7e8e7 passes Linux/macOS/Windows CI; PR141 merges asf150e39 after author
  review and all checks. Its completed local/remote branch is removed; artifacts remain.
  Fresh pairs retain the same local
  `qwen3.8-flash-next` and pinned Pi 0.86.1.
  Cases 01 through 08 have verified configured comparison wins and are skipped.
  Cases09 and10 remain open. Case09's new slice adds shared full-spec receipt-recovery
  guidance and explicit isolated benchmark controls, then runs a fresh matched pair.
  Preserve stable public delivery keys, distinct private fencing, lost-ack retry and
  accepted receipt persistence. No acceptance fixtures or manually generated solution
  are changed. See the Case08/Case09 ledgers for evidence; broader project gates remain active.

  Case 10 used the pinned Pi 0.86.1 run `bench-20260929-case10-pi0861-low-matched4-600s`.
  Neither agent resolved in four turns. Rupi used 89,125 work tokens over 2,337,401 ms; Pi used
  9,202 over 2,401,150 ms. Both failed all oracle and project-test checks, and every help check.
  Rupi's launcher could not find `receiptledger.__main__`; Pi's Python could not import
  `receiptledger`. The result is inconclusive: Pi used 79,923 fewer work tokens but finished
  63,749 ms later; neither resolved the oracle. See
  [Case 10 ledger](docs/benchmark/2026-09-29-case10-receipt-ledger.md).

### Performance

- [ ] Track cold startup regression.
- [ ] Track warm startup regression.
- [ ] Track TUI render latency.
- [ ] Track resume latency.
- [ ] Track Node host activation latency.
- [ ] Track MCP first-use latency.
- [ ] Keep startup-path dependency review active.

### Security

- [ ] Maintain redaction tests.
- [ ] Audit file permissions.
- [ ] Audit raw payload opt-in.
- [ ] Audit project-trust handling.
- [ ] Audit extension/MCP subprocess boundaries.

### Compatibility

- [ ] Track upstream Pi changes.
- [ ] Update compatibility matrix.
- [ ] Add fixtures for popular public packages.
- [ ] Document intentional divergences.

### Documentation

- [ ] Keep canonical design current.
- [ ] Keep README concise.
- [ ] Keep architecture invariants current.
- [ ] Keep roadmap statuses current.
- [ ] Keep compatibility limitations explicit.
