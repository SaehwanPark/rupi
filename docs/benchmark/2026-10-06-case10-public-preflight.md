# Preserve known missing-deliverable failures before public commands

Status: active; Case10 acceptance and paired improvement remain unproved.

Retry34 reaches its repair window: Failed after31 starts, Unavailable after34 at180,196ms;
post-run tests time out and required tests/__init__.py is absent. Runtime correctly stops
without replay/failover. Frozen audits/usage/CI pass, slots idle, generated/caller/oracle
contents unread. Precise application hang cause and actual feedback contents are unknown.

Owned host source detects missing required files, then runs commands anyway; a later
timeout throws and masks that known negative observation as Unavailable. Fix at the
caller/orchestration boundary, keeping the runtime unchanged: after bounded safe snapshot
and required-file preflight, return Failed immediately when files are absent. Feedback
must list missing public names and explicitly say command checks were not run. Check the
existing observation deadline before publishing this result. Full workspaces still run
all original public commands, with nonzero tests and same deadlines/diagnostic bounds.
Snapshot/link/size/time/protocol/process uncertainty remains Unavailable; no retry/replay.

Owned comparison should show the original control flow losing missing-init feedback to
an unavailable command, while the new preflight returns Failed with zero command starts.
Repair missing init and issue a fresh request to prove all command gates remain required.
Also preserve genuine timeout/invalid request/once/live callback/short-root/long Windows
working-directory coverage. Move the long-path reproducer to a complete owned workspace
so it still exercises Process.Start rather than this new earlier preflight.

Parent single agent owns host/owned fixture/docs only. Required local Rust/debug checks,
owned harness/config/prompt/reference guards, startup budgets and author invariant review;
ongoing commit/push and source/exact-freeze all3 CI precede Retry35. Runtime/source4cc8425,
all Retry34 model/limits/controls and same physical model/helpers are preserved. One Rupi
screen, fresh matched Pi only after acceptance. No manual solution/acceptance weakening.

Owned preflight comparison against explicit historical4cc8425 passes: baseline launches
one simulated uncertain command and publishes Unavailable for missing init; new host
publishes Failed with zero command starts and explicitly reports skipped commands. Restore
the missing file and a fresh request runs both real public commands and passes. Default
fixture requires no historical commit; optional comparison validates an explicit40-hex
revision. The initial HEAD-dependent comparison was made stable before committing.
Genuine command-timeout/startup, invalid request, once/stale process, short-root isolation
and long-path complete-workspace Process.Start fixtures retain their assertions and pass.
Nine harness fixtures/full config/shared SPEC/reference hashes and18 other prompts pass.
Shared prompt hash remains230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270.

Parent author invariant review: pass after the fixture revision. No blocking findings.
The caller returns a known public missing-file failure only after safe bounded snapshot
and a fresh deadline check; no check is certified as executed or successful. Complete
workspaces retain the original full gates. Handler identity/once marking/atomic reply,
UTF8 bounds, snapshot/link/size/budget safeguards and runtime Unavailable stop are unchanged.
No Rust/runtime/CLI/provider/schema/model/authority/event/storage/rendering change; optional
caller work remains outside startup/core. Required local fmt/core-check/clippy/workspace
tests/docs/debug-build pass (225 runtime/138 core/100 provider/25 CLI). Binary/runtime
source are unchanged. Startup tool reports14.489ms first/cold invocation,8.042ms warm
median/12.964ms max; no runtime speedup is attributed to this caller-only change. Five
restores69.20/504.25/2921.15/2710.20/5293.80us and context .4/.1/0/0/.3us meet all budgets.
Caller sourcefa6821860f6a2e94d4e5d1ecd86170e3eb00e072 is pushed; runtime/source remains
4cc8425ffda7fc5af5eaaae619055748f4cab226 and binary/harness unchanged. Default fixture
passes after the commit. SourceCI37509401285/exact-freeze all3 CI precede Retry35.
Actual acceptance and paired evidence remain pending.
