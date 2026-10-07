# Case10: preserve valid single-pass replace-all edits

Retry42 fails independent acceptance in all four turns. Turn2 exits101 without native
terminal status after9 completed requests/all usage known and an unfinished edit
lifecycle in scalar counts. Exit101 is consistent with a Rust panic, but actual stderr
and generated arguments remain uninspected. Exact actual causality is unproven.

Owned source inspection finds edit.rs:173 asserts that replace_all leaves no occurrence
of find. This is not a valid postcondition of single-pass replacement. A replacement
may retain the needle; replacing an original match may also create a new match against
an unmatched suffix. Repeatedly replacing newly inserted text would violate the contract
and can fail to terminate.

The ignored owned driver .benchmark/owned-edit-probe/main.rs invokes the actual cached
debug ToolRegistry/EditTool on sample.txt:token + token, find token, replacement
token_safe, replace_all=true. It reproduces the assertion panic after the start observer
and before any filesystem write; catch_unwind confirms the owned file is unchanged.
Driver SHA C01FA2B225B5E8523CAE2657E17089201842D2FEF4FACE0012DB096BF71AC5C8.
The first standalone link omitted Cargo's native Windows library search path; adding
the cached path fixed the driver only. No Cargo rebuild, new inference, supervisor or
frozen source/binary change occurred. Frozen Retry42 audits subsequently pass.

Parent owns this bounded builtin fix and author review. Remove the false debug assertion
and explain why residual/new matches are legitimate. Add actual EditTool fixtures for
replacement containing find and a match formed across an unmatched suffix; assert exact
output, successful Changed state, and single-pass behavior. Retain identical-argument
refusal, ambiguity rules, cancellation checks, atomic write and Unknown reconciliation.
No schema, public interface, definition identity, budget, model or caller change.

Verify focused edit/registry tests, full workspace delivery gates and startup budget.
Existing unchanged Store/context and harness/profile gates remain applicable; verify
new binary/source and exact source/frozen-head all3 CI before another attempt. Keep the
next fresh four-turn profile identical to42 so the edit fix is the only new variable.
No manual modification of generated case work or oracle visibility/acceptance changes.
PR145 remains draft until independent acceptance and a fresh matched Pi comparison win.
