# Initial progress thinking selection

Retry29 exhausts8192 output with length and no decoded tool call. Actual failed contents
and reasoning/text composition remain unread. Frozen audits and three-platform CI pass.
An upstream report of required tool choice ignored on reasoning-preserving templates may
match local capability metadata, but the exact local generation defect is unproved.

Parent owns this bounded runtime request-budget slice. Add optional
`limits.initial_progress_thinking: Option<ThinkingLevel>` (None/omitted, requires initial
progress selection). Only the first ordinary request of an active initial boundary uses
the selected level; later requests inherit normal thinking even without Changed progress,
and fresh turns renew it. Disabled/no-tools/no-window paths skip it. Explicit runtime
control describes requested selection, never claims hidden reasoning or effective backend
enforcement. Model identity, endpoint, caps, admission, approval/cancel/Unknown and
incomplete-response no-dispatch/no-replay remain intact. No timer, retry, event or authority.

Owned comparative fixtures must prove Off first/Low later/renewal, default/skipped paths,
config omission/dependency/round-trip and real CLI wire reasoning_effort none/low using
the endpoint's explicit disable encoding. Reasoning preservation remains configured.
Add isolated Case10 option none(default/inherit) or selected thinking level and native
scalar/Pi null. Select Off first, Low/4096 later; all other Retry29 controls unchanged.
Verify shared prompt/18 other prompts/SPEC/three references, required Rust/debug/startup/
restore/context checks and parent invariant review. Commit/push/freeze before Retry30.
No actual latency/acceptance/token/Pi benefit or recovered hidden reasoning is claimed.
Any failure requires new root-cause analysis and verified enhancement before another
attempt. Fresh Pi remains conditional on Rupi acceptance. Check usage before next slice.
