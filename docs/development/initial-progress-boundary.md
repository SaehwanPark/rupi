# Optional progress boundary on the first ordinary request

Retry23 fails acceptance/tests at the native deadline despite review after three
started requests. The requested __main__.py and README exist and help passes, but
public tests are absent. Its first three tools are inspection calls although the
shared task supplied the specification and requested a first write. Tool failure
mapping and semantic application causes remain unmeasured. Source confirms that
the configured progress boundary starts inactive and waits for the inspection
window; it cannot honor an explicitly selected immediate-progress policy.

## Bounded change (medium risk)

1. Add `limits.initial_progress_boundary: bool`, omitted/false by default, requiring
   `max_model_requests_without_progress` when true. Expose the corresponding TurnLoop
   builder and CLI wiring. No general task classifier or artifact enforcement.
2. Each admitted ordinary tools-enabled turn may activate the existing progress
   boundary before its first provider attempt. Refresh interactive approval availability
   before activation; cancellation, unresolved effects, admission and budgets remain
   authoritative. Reuse existing eligibility, typed controls, correction and Changed
   effect semantics. After progress, retain configured one-shot/recurring behavior.
   New turns renew the initial selection; explicit no-tools assessment skips it.
3. Add `Case10InitialProgressBoundary` benchmark selection, native config and Rupi
   boolean/Pi null metadata. Other cases, shared prompts and immutable references
   remain unchanged. No real trace/content inspection or manual application solution.
4. Owned fixtures verify initial tool choice/exposure, release after Changed evidence,
   fresh-turn renewal, no-effect and Unknown barriers, unavailable/denied tools,
   mutation capacity, caller cancellation and no-tools/default behavior. Existing
   durable progress fixtures remain applicable; add an initial-control restore check.
   Config omission/round-trip/inactive-policy rejection and selected-profile guards.
5. Required Rust checks/debug build, startup/session/context budgets, parent invariant
   review, architecture/canonical/compatibility/changelog/roadmap updates and durable
   push/CI precede the next screen. Keep broad gates active and claims evidence-limited.

The next single-turn screen selects this policy because the shared task explicitly
requests a first write with supplied context. It also grants a matched outer2400s
instead of1200s: repeated native expiry with unused request allowance establishes the
wall-time bottleneck, although more time is not a semantic fix. Rupi native duration
2370s/review reserve300s, cap40/window3, same model/low/budget4096/output32768 and
existing relay8003/deadline1194s. Native provider timeout2394s; the relay still bounds
each individual response to1194s. Pi receives the same outer/provider allowance,
model/prompt/output/thinking/relay and has no native progress/time/review parity.
Any outcome is a configured result, not a causal attribution to one change.

Stop if activation cannot preserve existing approval/reconciliation ordering; report
the conflict. Freeze verified source/binary/harness before one fresh development turn.
Failure requires analysis and a verified enhancement before another attempt. Fresh
matched Pi follows only Rupi acceptance; final exact-head CI and paired evidence are
required before delivery. No acceptance benefit is established by owned fixtures.

Implement exactly this plan. Do not broaden scope. If the plan conflicts with the
codebase, stop and report the conflict instead of improvising. Report files changed,
checks, deviations and unresolved risks. Callers must select immediate mutation only
for already authorized implementation work with sufficient context.
