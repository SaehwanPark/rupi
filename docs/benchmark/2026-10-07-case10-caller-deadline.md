# Case10: bounded caller observation waits

## Frozen Retry46b

Run `bench-20261007-case10-relay-retry46b-rupi40-turns4-2400s` uses runtime source
6624c11c1a5a89c03aaeb8c4050db55424e83576, checkout
07bb70c9572255a9ce7152ff3432dede64f779f5 and exact three-platform CI37671194267.
Binary SHA256ED744E700DD46C15FCD808C283534384D8607D5CDE03B683EBE1F55C45C8307C;
harness SHA256442411E29A7A78B576E068C14FCD03DE4D0B25117E3A269326ACEA8593AB7F23.
Every Retry45 control and original physical model/helper remains unchanged.

An initial Retry46 orchestration launch mistakenly used Windows PowerShell5.1.
Owned probes establish its missing ProcessStartInfo.ArgumentList API, accessed before
Process.Start. Prepared artifacts contain no runtime output/state/summary; model slots
are idle. Preserve that abandoned workspace. Correct PowerShell7 and a major-version
guard justify a fresh workspace without another production change: no runtime/model
attempt had started. Actual runner log/stderr remain uninspected.

| Turn | Call ms | Native outcome | Starts / closures / usage | Known work | Checks ms |
| --- | ---: | --- | --- | ---: | ---: |
| 1 | 2,370,093 | TimeBudgetExhausted | 27 / 27 / 26 | 118,225 | 541,194 |
| 2 | 2,370,932 | TimeBudgetExhausted | 39 / 39 / 38 | 177,193 | 257,526 |
| 3 | 2,341,170 | CompletionCheckExhausted | 39 / 39 / 39 | 240,616 | 294,001 |
| 4 | 2,376,120 | TimeBudgetExhausted | 28 / 28 / 27 | 298,088 | 257,419 |

All four turns fail independent acceptance; no Pi run/configured win. All project tests
exit1, four helps exit0, oracle exit1/resolvedfalse, no outer or terminal-verification
timeout. Runner exits0. Both frozen audits pass before source/HEAD/binary changes;
original four slots are idle and root policy/caller/helper/prompt/SPEC/references match.

Totals9,458,315ms and834,122 known work=768,451input+65,671output;133 starts/closures
and130 usage. Final requests in Turns1/2 have streaming cancellation/committed partial
output; Turn4 has pre_request cancellation/ambiguous POST and no partial output.
Their missing usage/work remain unknown.170 tool requests,158 successful ToolCompleted
+12 ToolFailed =170 aggregate terminals,0recordedUnknown; counts do not prove distinct
pairing or effects. Actual content, stderr, traces, caller feedback/private oracle remain
uninspected; no historical artifact backfill.

All public observations fail:7/7/8/7 checks. Positions8/11/14/17/20/23/26, plus39 for
Turn3's final check; review after23 every turn. ProgressCorrection0/2/2/2 reaches the
inspection path without acceptance. Late Turn1 checks take approximately180s each;
Turns2–4 checks take36.7–36.9s. These durations do not identify a generated-test cause
or prove a particular timeout. Turns3/4 start, including after check exhaustion, without
establishing resolution of Retry45's unknown startup cause.

Live scalar sample at19:42:24UTC records CPU10.484s after roughly32min, versus Retry45's
CPU1,765.609s sample at approximately32min. This supports actual idle-CPU improvement;
acceptance benefit and stack attribution remain unproved.

## RCA and runtime enhancement

Caller observations consume1,350,140ms, about22.5min. Source mailbox currently permits
300s per observation or remaining turn time; immutable caller obeys advertised wait
budget. Slow public observations can therefore consume substantial repair time.
Semantic failure details remain unknown. Add an explicit adapter wait ceiling rather
than infer a task-specific fix from uninspected diagnostics.

Run-only `--completion-feedback-timeout-ms` accepts1..300,000ms, requires the mailbox,
and defaults to the existing300s. Publish the lesser of selected cap and remaining
turn time through unchanged version1 wait_timeout_ms. Timeout/invalid reply remains
Unavailable; cancellation, atomic identity, late/stale reply rejection and no replay
stay authoritative. It supplies a cooperative host deadline without check execution
authority. No dependency, model/endpoint/helper, reasoning, core event/effect, approval
or domain-workflow changes.

Owned parser guard is red before implementation and green afterward. Slow host reports
a Passed reply after a30ms ceiling: CLI returns Unavailable, retains artifacts, ignores
that reply on the next exchange, issues exactly two distinct requests and respects its
shorter10ms remaining-turn time. Composition rejects invalid waits before filesystem
work; disabled behavior performs none. Existing strict identity/UTF8/size/cancellation
guards pass. Owned failed-edit/check-exhaustion/resume uses explicit60s, advertises it,
and reads original state without replay. Focused completion guards and Clippy pass.

Prospective Case10 selector permits0/default or60,000ms with configured rupi checks;
Pi/other-case controls are null. Fresh scalar metadata records the selection. Owned
harness guards cover defaults/range/dependency/isolation and20 prompt hashes/case-tree
guards pass. Caller SHA256EB7829961FC2AB93AC36E8FE4971F5EA18F07C8DE6136019110373775DF1E6AC
and helper SHA256A0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7
remain unchanged. Independent post-turn acceptance and verification timeouts stay intact.

## Final delivery verification

Runtime source37d0e23d616352f9baf8e64f4a1795a5f943e424 includes one author-review
correction: recheck cancellation/deadline after parsing, before accepting any reply.
Focused guards pass, then full local fmt, all-feature core check, workspace all-target
Clippy, normal workspace tests, docs and debug build pass on that final source.
All15 owned harness guards and20 prompt hashes/case-tree guards pass. Parent author
invariant review passes; no independent reviewer/subagent.

Final-source warm median8.384ms passes100ms; fresh-inode cold median167.752ms passes250ms.
Canonical resume/restore133.6922ms passes500ms; all restore/context checks pass on
unchanged store/runtime context code. Rendering is unchanged. Debug binary SHA256:
`A60A9A915D0445EB0172F55FD7042416536C6762A51CE17343E83F0A03F1B71E`.
New harness SHA256:
`36B493DA27142A54A95A4376AE5DB4584AFA2C5F0859470C08825794432E74F3`.

Exact merge-HEAD CI on Windows, macOS and Ubuntu is a premerge gate; its outcome is
recorded in PR145 checks and the final handoff comment. This delivery is independent
of benchmark acceptance: the roadmap remains active and no paired win is established.

## Wrap-up requested by the owner

The owner explicitly requested completing ongoing work, documenting state and merging
into main. Finish delivery verification and merge PR145 under that authorization,
without waiting for a configured Case10 win and without launching Retry47. Keep Case10
and broader benchmark stage gates incomplete. The optional caller cap is owned-fixture
verified; no actual-case result for it exists. Preserve frozen/abandoned artifacts and
leave the original physical model/helpers intact and idle.

Resume only when development is requested again. Cases01–09 already have recorded wins;
Case10 remains the target. Read this ledger and the relay/native-budget predecessors.
Use a fresh branch from main, inspect current policy/usage and verify original physical
resources before inference. Rebuild and freeze exact source/HEAD/binary/harness/caller/
helper hashes, three-platform CI and prompt/SPEC/reference controls. Old Retry46b launch
and audit scripts refer to historical source: do not rerun them against changed HEAD or
reuse their workspaces. Prospective fresh selection adds only60,000ms caller cap to the
previous Retry46b profile; all four prescribed recovery turns remain one frozen attempt.
The source deadline guard and owned fixtures must pass; full independent post-turn
acceptance remains unchanged. Paired Pi follows only independent rupi acceptance.

After any fresh failure/loss, audit before mutations and perform RCA with allowed
scalars/owned fixtures, then verify a bounded runtime enhancement or document a justified
exception before another fresh attempt. Never inspect actual task output, stderr,
traces/caller feedback/private oracle or weaken fixtures to obtain a win. Three Retry46b
request usage gaps remain unknown; same-turn cumulative-work comparison cannot use them
as zero. ToolCompleted counts only successful terminals, separately from ToolFailed.
