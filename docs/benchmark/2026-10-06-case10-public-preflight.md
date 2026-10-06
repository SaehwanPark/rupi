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
