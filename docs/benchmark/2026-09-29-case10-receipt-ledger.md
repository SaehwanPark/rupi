# Case 10 comparison ledger: receipt ledger

This ledger records the matched `10-receipt-ledger` run with local `qwen3.8-flash-next` and
Pi 0.86.1. The case tests the capstone pipeline's same-transaction, append-only SHA-256 audit
chain.

## Matched baseline

Run: `bench-20260929-case10-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,250 ms | 16,835 / 3,932 | 20,767 | 6 | 6 | outer timeout |
| 2 | 600,295 ms | 17,318 / 8,471 | 25,789 | 8 | 7 | outer timeout |
| 3 | 600,266 ms | 5,742 / 8,304 | 14,046 | 8 | 7 | outer timeout |
| 4 | 536,590 ms | 23,083 / 5,440 | 28,523 | 8 | 7 | completed; unresolved |

Rupi did not resolve in four turns. It used 89,125 work tokens over 2,337,401 ms, with 30
requests and 27 tools. The first three calls timed out; the fourth completed before its outer
limit. All oracle, project-test, and help checks failed on every turn. The service and help
commands could not run because Python reported that `receiptledger.__main__` was missing.
Project-test discovery could not import the `tests` start directory.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,301 ms | 7,413 / 548 | 7,961 | 6 | 6 | outer timeout |
| 2 | 600,306 ms | 0 / 0 | 0 | 0 | 0 | outer timeout; no recorded model request |
| 3 | 600,311 ms | 1,053 / 188 | 1,241 | 2 | 2 | outer timeout |
| 4 | 600,232 ms | 0 / 0 | 0 | 0 | 0 | outer timeout; no recorded model request |

Pi did not resolve in four turns. It used 9,202 work tokens over 2,401,150 ms, with eight
requests and eight tools. Every turn timed out. All oracle, project-test, and help checks failed
on every turn. On turns 2 and 4, the recorded request and tool counts were zero; unfinished inference usage is unknown.
On the final
turn, Python could not import `receiptledger`, so the service and help commands failed.
Project-test discovery could not import the `tests` start directory.

## Outcome

The result is inconclusive because neither agent resolved the oracle. Rupi used 79,923 more work
tokens and finished 63,749 ms sooner. Both attempts failed to provide an importable service, and
both failed project-test discovery and all help checks. This completes the ten-case comparison.

## Active improvement slice: public audit and receipt guidance

Base: `8ba8010257d9114b9d780ca46b0bb76b9a726931` (merged Case09 PR144).
Branch: `fix/case10-audit-ledger`. Owner: parent agent, single writer; no delegation.
Cases01–09 have recorded configured wins and are skipped. Case10 remains unresolved.

Implement shared initial/repair prompts containing the complete actual Case10 public SPEC.
Preserve authenticated atomic DAG admission, ordered declared data flow, bounded workers,
private claim-token fencing, stable delivery keys and lost-ack receipt recovery. Emphasize
same-transaction audit appends, safe bounded events, the exact public hash expression, and
read-only full-chain verification/tail. Request public command/HTTP tests and an honest README.

Add isolated Case10 reasoning-budget and progress-mode/window selectors using the existing
runtime. Defaults remain zero budget, one_shot and window1; normalize mode capitalization.
Both agents receive the same complete public requirements and oracle pass/fail only. Rupi
uses four file tools and empty discovery; Pi0.86.1 uses six native file tools and disabled
discovery. Pi request/progress limits remain unavailable, never represented as zero.

Verify default/selected guards, non-native rejection before mutation, oracle isolation,
all18 non-Case10 initial/repair prompt hashes, copied SPEC/acceptance hashes, actual configs,
metadata and byte-identical shared initial prompts. Run a fresh same-Qwen paired comparison
with low/configured2048, Recurring/window3/cap12, matched six attempts of600s/grace6. Record
per-turn summaries and file metadata only; no generated source, model output, oracle source,
diagnostics or aggregate comparison results are inspected. No manual solution is supplied.

Acceptance remains unchanged. A failed cheaper run is inconclusive. A win requires fewer
acceptance-resolution turns or less recorded work at equal resolution turns. Recorded work
excludes cache-read tokens; unfinished inference is unknown. Keep public-test/help/README
limitations explicit and do not claim full-task completion or default/causal superiority.

Before delivery, perform author invariant review, required Rust checks and startup budget
verification; wait for exact-head three-platform CI before autonomous merge. Push progress
regularly. Verify the squash tree/remote main, detach artifacts, and delete merged branches.
Broader roadmap gates remain active. Status: plan committed; implementation/verification pending.

### Implementation and preflight

PR145 is draft: https://github.com/SaehwanPark/rupi/pull/145.
Shared full-SPEC initial/repair guidance and isolated selectors/metadata are implemented.
All-case default and selected/capitalized-mode guards pass, including non-native exposure
rejection before endpoint mutation and fake-oracle sentinel isolation. All18 other-case
initial/repair prompt hashes match. Independent Case10 budget/progress isolation and
zero-window rejection pass. Fresh actual config is low/relay2048/native replay/Recurring/
window3/cap12/four file tools, provider594000ms/max-output16384. Copied SPEC and all three
acceptance files match source hashes; the first ignored probe assumed two files and failed
before any inference. Corrected count includes .gitignore; no reference contents inspected.
The ignored selector probe first used helper functions outside their script scope; dot-source
corrected that probe, and isolation passed. Both probe failures caused no inference.

Harness SHA256:
`B601DB6B75DB23D92B990A3367CCD803C1CD97FEE9F4CDCA756015CA39162020`.
Debug binary SHA256:
`8159F875187D28D5DCAF12038AA14709A5B3B9478D392C73E34C9E2915C77F24`.
The binary was rebuilt during the completed Case09 final checks, after its winning pair;
Case10 captures this fresh binary independently. Model27356 and relay33028 retain their
original start times. Relay health confirms2048/upstream8000/content_logging:false; model
alias isqwen3.8-flash-next. No rupi inference process is active before launch.
Author source/consumer review finds no blocking invariant violation; final review/checks
remain pending after comparison. No Rust, startup-path or acceptance changes. Diff check
and added harness100-column check pass. Fresh pair launch is the next action.

### Fresh retry01: active

Run: `bench-20261004-case10-audit-receipt-budget2048-low-retry01-rupi12-window3-matched6-600s`.
Source head: `4246538d584d3d64445d1c412bd09fc0e4707d15`; exec61233/runner33224/wrapper5700.
Actual saved Rupi initial prompt matches the own harness hash; actual selected config passes.

Rupi turn1 reaches its watchdog at600,300ms and remains unresolved:20,105 recorded work
(10,070 uncached input +10,035 output), six usage records, seven request starts/six completions.
Six tool requests: three completed/three failed/zero Unknown; names edit/write/edit/read/read/grep.
Project tests1/all four help1/oracle1; no verification timeouts. Snapshot lists only one
application file, receiptledger/__main__.py27,606 bytes, with no tests or README. Contents
are unread; file presence does not establish complete behavior. Unfinished inference unknown.
Turn2 is active with unchanged harness/shared repair guidance. Pi has not started; no win claim.

Rupi turn2 also reaches its watchdog at600,242ms:23,738 recorded work (13,442 input+
10,296 output), ten request starts/ten completions including earlier abandoned-request
completion, nine usage records. Eleven tools complete/zero fail/zero Unknown (four writes,
four edits, grep and two reads). Project tests1/oracle1, all four help0; no verification
timeouts. Snapshot lists init75/main27,606/http_service4,767/store17,721/validate5,539 bytes,
no tests or README. Main's matching size does not prove unchanged contents. Generated files
remain unread. Turn3 active, Pi not started; cumulative recorded work43,843. No win claim.

Rupi turn3 reaches its watchdog at600,222ms:50,398 recorded work (43,363 input+7,035 output),
eleven starts/eleven completions including abandoned-request completion, ten usage records.
Fourteen tool requests/thirteen complete/one failed/zero Unknown; request names include eight
reads, four grep, one edit and one write. Tests1/oracle1/all four help0, no verification timeouts.
README8,720 bytes and init110 now listed; other four application sizes match turn2, which
proves neither exact edits nor unchanged contents. No tests listed. README/generated content
unread. Cumulative work94,241; turn4 active with unchanged source/controls. Pi not started.

Rupi turn4 exits0 with runtime budget_exhausted at564,085ms, unresolved:75,833 recorded work
(72,642 input+3,191 output), eleven starts/twelve completions including earlier abandoned
request, eleven usage records. Fifteen tools complete/zero fail/zero Unknown (thirteen reads,
two writes). Tests5/oracle1/all four help0; no verification timeouts. tests/__init__.py71
is now listed, but no test_*.py. All six earlier file sizes match, without proving unchanged
contents. No generated content inspected. Cumulative recorded work170,074. Turn5 active;
Pi has not started. Three authoring watchdogs and one budget-exhausted turn so far; no win.

Rupi turn5 reaches its watchdog at600,161ms, unresolved:10,480 recorded work (8,275 input+
2,205 output), two request starts/one completion/one usage record. One read tool completes,
zero failures/Unknown. Tests5/oracle1/all four help0, no verification timeouts. All seven
listed file sizes match turn4, without proving unchanged contents; no test_*.py listed.
Unfinished second-request inference usage remains unknown, not zero. Cumulative recorded
work180,554/authoring2,965,010ms. Turn6 active, the final planned Rupi attempt; Pi not started.

Rupi turn6 reaches its watchdog at600,235ms, unresolved:17,761 recorded work (13,930 input+
3,831 output), five starts/five completions including an earlier abandoned request, four usage
records. Five tools complete/zero fail/zero Unknown (write/read/grep/read/read). Tests5/oracle1/
all four help0, no verification timeouts. Store size changes17,721→4,845; other six sizes match.
No test_*.py listed. Contents unread; metadata proves neither exact edits nor unchanged files.

Retry01 Rupi is terminal non-winning:198,315 recorded work/3,565,245ms authoring/48 completed
four failed/zero Unknown tools; five watchdogs/one budget-exhausted turn. All six saved prompts,
controls, copied SPEC and three acceptance hashes pass; actual config/source/binary/model/relay
match. Initial Rupi/Pi prompt hashes are equal. Rupi failed every acceptance/test gate; final
help passes, README listed but unread. Unrecorded unfinished inference usage remains unknown.

Pi had just begun turn1 when the candidate became unable to yield a configured Rupi win.
Stopped the owned runner33224/tree (Pi30660 and child29908) to avoid spending another six
attempts on an already unsuccessful candidate. Wrapper exec61233 exits1; no Pi turn summary
exists. Pi usage, completion, tool failures/Unknown and acceptance are unavailable, never zero.
This is an incomplete comparison, not a matched terminal pair or a win. Artifacts retained;
no uncertain mutation replayed. All four model slots report is_processing:false after stop.

### Revised guidance and Rupi-first screening

Recorded summaries show repeated reads and no public test cases, including thirteen reads
in turn4. Revise shared Case10 guidance using only those public gates/metadata: read with
explicit offset/limit ≤120 lines; at most one targeted read/grep before the next application
mutation; preserve complete modules with focused edits. When help passes but tests are absent,
first write real public-command/HTTP tests, preserve assertions and never empty placeholders.
All public audit/receipt/fencing requirements and the full SPEC remain unchanged. No private
oracle details or generated content are inspected or supplied. No runtime feature is added.

Revised default/selected guards, fake-oracle/native-exposure isolation, all18 unchanged other
prompt hashes and fresh configuration/SPEC/three reference probes pass. Harness SHA256:
`7D2FB1C85748497850F6BD98BD61F4B01BC90EBA6FEE21A65B7817F140BE519C`.
Binary8159F875...77F24 and model27356/relay33028 remain unchanged. Usage21% five-hour/33% weekly,
below root95/99 soft stops. Screen a fresh Rupi candidate first with unchanged controls and six
maximum600s/grace6 attempts. If Rupi resolves, freeze guidance/binary and run fresh Pi0.86.1
on the same RunId, prompt and public gates. If Rupi does not resolve, do not spend Pi inference
on a candidate that cannot win. Each rejected screen stays explicitly non-winning/incomplete.
Final paired evidence, required checks/startup, review and exact-head CI remain pending.

### Retry02 screen: launched

Run: `bench-20261004-case10-bounded-repair-budget2048-low-retry02-rupi12-window3-screen6-600s`.
Source `a821834fa7e64f63a37374b7ae29d9f9be35971c`; exec35467/runner9740/wrapper34732.
Fresh Rupi-only screen is active, no Pi inference yet. Same selected controls/model/relay/
binary as retry01, revised shared guidance only. All model slots idle before launch; no build
or parallel inference during the screen. Saved initial prompt matches own revised harness.
If this screen resolves acceptance, run fresh Pi with the same frozen guidance/configuration.
No outcome/paired/default/causal claim is available yet.

Retry02 Rupi turn1 reaches its watchdog at600,183ms, unresolved:26,271 recorded work
(16,132 input+10,139 output), eight starts/seven completions/seven usage records. Eight
requested tools/seven complete/one failed/zero Unknown; names write/grep/grep/read/write/
read/read/read. Tests1/all four help1/oracle1, no verification timeouts. Snapshot lists
main835/storage30,722 bytes, no tests or README. File presence does not prove complete
behavior; generated contents remain unread. The complete shared prompt preserves public
requirements and first-write guidance. Turn2 active; no Pi run and no win/causal claim.

Retry02 Rupi turn2 reaches its watchdog at600,257ms, unresolved:45,588 recorded work
(39,521 input+6,067 output), twelve starts/twelve completions including earlier abandoned
request, eleven usage records. Seventeen requested tools/fifteen complete/two fail/zero Unknown;
names include two writes, seven reads, five grep and three edits. Tests5/all four help1/oracle1,
no verification timeouts. Init983/tests-init58 now listed; main835/storage30,722 sizes match
turn1 without proving unchanged content. No test_*.py or README. Contents unread. Cumulative
work71,859. Turn3 active with unchanged revised guidance/controls; no Pi run or win claim.

Retry02 Rupi turn3 reaches its watchdog at600,249ms, unresolved:24,493 recorded work
(15,316 input+9,177 output), four starts/four completions including earlier abandoned
request, three usage records. Two requested tools/one complete/one failed/zero Unknown
(edit/write). Tests5/all four help1/oracle1, no verification timeouts. app.py12,150 now
listed; four earlier file sizes match, without proving unchanged contents. No test_*.py
or README; generated contents unread. Cumulative work96,352. Turn4 active, no Pi run.

Retry02 Rupi turn4 reaches its watchdog at600,199ms, unresolved:21,041 recorded work
(12,529 input+8,512 output), three starts/three completions including earlier abandoned
request, two usage records. Two edit tools complete/zero failed/zero Unknown. Tests5/oracle1,
all four help now0; no verification timeouts. app size12,150→36,984, other four sizes match
without proving unchanged contents or exact edits. No test_*.py or README. Contents unread.
Cumulative work117,393/authoring2,400,888ms. Turn5 active with the shared guidance to write
missing public tests when help passes. No Pi inference or win claim; controls remain unchanged.

Retry02 Rupi turn5 exits0 with runtime budget_exhausted at578,279ms, unresolved:46,056 work
(39,434 input+6,622 output), eleven starts/twelve completions including earlier abandoned
request, eleven usage records. Twelve tools complete/zero fail/zero Unknown (five grep,
five reads, two writes). Tests5/oracle1/all four help0, no verification timeouts. Public
test_receiptledger.py6,298 now listed; package init1,522, other four file sizes match prior
turn without proving unchanged contents. File presence does not establish discovered/passing
tests. No README; generated contents remain unread. Cumulative work163,449/authoring2,979,167ms.
Final Rupi attempt6 active; no Pi inference or win claim. Harness/controls remain unchanged.

Retry02 Rupi turn6 reaches its watchdog at600,229ms, unresolved:16,662 recorded work
(13,593 input+3,069 output), four starts/three completions/three usage records. Four tools
complete/zero fail/zero Unknown (read/grep/read/read). Tests5/oracle1/all four help0, no
verification timeouts. Six generated file sizes match prior turn without proving unchanged
content. No README; generated code/test content unread. Unfinished request usage unknown.

Retry02 is a terminal failed Rupi screen:180,111 recorded work/3,579,396ms authoring/41 complete/
four failed/zero Unknown tools. Five watchdogs/one budget-exhausted turn; no acceptance or
project-test gate passes. Final all-help passes, test file listed, README absent. Exec35467
exits0; runner9740/wrapper34732 gone. All six saved prompt/control/copied SPEC/three acceptance
hash audits pass, actual config/binary/model/relay match. Pi not run; no comparative win,
full-public-task or causal improvement claim. Screening is not a completed paired comparison.

### Single-module and discoverable-test revision

Try one bounded shared-guidance revision from public metadata/gates, without claiming a root
cause: keep CLI/HTTP/SQLite/worker/audit together in receiptledger/__main__.py, with no separate
application modules or local application imports. Then empty package init, public tests,
test init and honest README. Preserve all full-SPEC audit/receipt/fencing/data-flow requirements.
Explicitly require unittest.TestCase subclasses with test_ methods; helper functions alone
are not tests. Repair preserves complete code, public assertions and bounded reads/edits.
No application solution is supplied, and generated/oracle/model contents remain unread.

Default/all-case selected/capitalized guards, native-exposure and fake-oracle isolation,
all18 unchanged non-Case10 prompts, fresh config/SPEC/three reference probes and diff checks
pass. An overlong guard line was wrapped and the final Case10 selected guard passes.
Harness SHA256:
`86F04AA70643CD8020EE348D5CE16A230C037D195B4D655966985EB37745AD98`.
Binary8159F875...77F24 unchanged; same model27356/relay33028/low2048/window3/cap12/six600s/grace6.
Root usage44% five-hour/37% weekly, below95/99 soft stops. Fresh Rupi-first screen next;
Pi remains conditional on Rupi acceptance with frozen guidance/binary/controls. Final paired
win evidence, required Rust checks/startup/review and exact-head CI are still pending.

### Retry03 screen: launched

Run: `bench-20261004-case10-monolith-testcase-budget2048-low-retry03-rupi12-window3-screen6-600s`.
Source `92d2b269f2ace551e38fd1346c8c2115d1cfba8b`; exec41676/runner33728/wrapper36344.
Fresh Rupi-only single-module/discoverable-TestCase screen active. Same controls/model/relay/
binary; all model slots idle before launch. Saved initial prompt matches own current harness.
No builds or parallel inference during the screen. Pi conditional on acceptance; outcome pending.

Retry03 Rupi turn1 reaches its watchdog at600,415ms, unresolved:31,270 recorded work
(21,972 input+9,298 output), six starts/five completions/five usage records. Six requested
and completed tools/zero fail/zero Unknown (grep/read/read/write/read/read). All four help0,
project tests1/oracle1; no verification timeouts. Snapshot lists only application main36,906,
no tests or README. Generated contents unread; file presence/passing help do not prove complete
behavior. Actual first requested tool is grep despite first-write guidance; no compliance or
causal claim is inferred from the prompt. Turn2 active with public-TestCase repair guidance.
No Pi run. Evidence/controls remain frozen; missing test/README requirements are preserved.

Retry03 Rupi turn2 reaches its watchdog at600,307ms, unresolved:40,966 recorded work
(32,985 input+7,981 output), eight starts/eight completions including earlier abandoned
request, seven usage records. Nine requested/completed tools/zero failed/Unknown (three
writes, four grep, two reads). Tests1/oracle1/all four help0, no verification timeouts.
README6,673/tests-init73/test_receiptledger10,399 now listed; main36,906 size matches prior
turn without proving unchanged contents. Package init absent. Generated contents unread;
file presence does not prove discovered/passing tests, documentation completeness or exact edits.
Cumulative work72,236/authoring1,200,722ms. Turn3 active with unchanged public repair guidance;
no Pi inference or acceptance/comparative win claim.

Retry03 Rupi turn3 exits0/runtime completed at409,380ms, unresolved:38,773 recorded work
(34,536 input+4,237 output), nine starts/ten completions including earlier abandoned request,
nine usage records. Nine tools requested/complete/zero failed/Unknown (four reads, three
edits, two grep). Tests1/oracle1/all four help0, no verification timeouts. Main size37,054/
public-test10,387 differ; README6,673/test-init73 match sizes, without proving unchanged
content or exact edits/assertion preservation. Package init absent. Generated contents unread.
Cumulative work111,009/authoring1,610,102ms. Two watchdogs/one runtime completed so far;
turn4 active, no Pi inference. Runtime completion is not acceptance or full-task completion.

Retry03 Rupi turn4 reaches its watchdog at600,266ms, unresolved:34,527 recorded work
(29,243 input+5,284 output), seven starts/six completions/six usage records. Six requested/
completed tools/zero failed/Unknown (two grep, three reads, one edit). Tests1/oracle1/all four
help0, no verification timeouts. Main size37,002 differs; other three generated file sizes
match, without proving unchanged contents or exact edits. Package init absent; contents unread.
Cumulative work145,536/authoring2,210,368ms. Turn5 active with frozen controls/guidance;
no Pi run. Unfinished model request usage unknown, never zero; no win claim.

Retry03 Rupi turn5 exits0/runtime budget_exhausted at594,221ms, unresolved:45,623 work
(38,489 input+7,134 output), eleven starts/twelve completions including earlier abandoned
request, eleven usage records. Eleven requested tools/ten complete/one failed/zero Unknown
(grep, seven reads, write, two edits). Tests1/oracle1/all four help0, no verification timeouts.
Main size37,002→15,944; other three sizes match. Contents unread: size reduction proves neither
exact edits nor retained/lost behavior. Package init absent. Cumulative work191,159/authoring
2,804,589ms. Final Rupi attempt6 active; no Pi run or comparative win. No inference/build overlap.

Retry03 Rupi turn6 reaches its watchdog at600,187ms, unresolved:24,992 recorded work
(15,567 input+9,425 output), eight starts/seven completions/seven usage records. Seven tools
requested/complete/zero failed/Unknown (four edits, three reads). Tests1/oracle1/all four help0,
no verification timeouts. Main size15,944→42,804; other three sizes match. Contents unread;
size changes do not prove exact edits/retained behavior/assertion preservation. Package init
absent. Unfinished inference usage unknown, not zero.

Retry03 terminal failed Rupi screen:216,151 recorded work/3,404,776ms authoring/47 completed/
one failed/zero Unknown tools. Four watchdogs/one runtime completed/one budget-exhausted turn.
Every project-test/acceptance gate fails, all help passes. Public tests and README listed but
unread; full public-task completeness unproven. Exec41676 exits0, runner33728/wrapper36344 gone.
All six saved prompt/control/copied SPEC/three acceptance hash audits pass; actual config/
binary/model/relay unchanged. Pi not run; this is not a paired win or lower-work success.

### Existing window12 control: next screen

Keep shared single-module/discoverable-TestCase prompts, source92d2b269/harness86F04AA7...5AD98,
binary8159F875...77F24 and all selected settings fixed. Change only the existing Case10
progress request window3→12 for a fresh screen, using the control already implemented. This
relaxes the configured interval within cap12; it does not establish a cause or benefit.
All-case selected/capitalized window12 guards and actual fresh config/SPEC/three reference
hash probes pass. Root usage56% five-hour/39% weekly remains below95/99 limits. Six maximum
600s/grace6 Rupi attempts, Pi conditional on acceptance with frozen guidance/configuration.
No new Rust/runtime source, domain policy or solver is added. Final paired evidence, required
checks/startup/review/exact-head CI remain pending. Cases01–09 remain skipped.

### Retry04 window12 screen: launched

Run: `bench-20261004-case10-monolith-window12-budget2048-low-retry04-rupi12-screen6-600s`.
Source code92d2b269/harness86F04AA7...5AD98; control checkpointb65b96b; exec7815/
runner23564/wrapper29924. Same binary/model/relay/low2048/cap12/six600s/grace6. Only existing
window3→12 changes; mode remains Recurring. Slots idle before launch; actual config passes,
initial prompt byte-identical to retry03. No builds or parallel inference during the screen.
Pi conditional on Rupi acceptance with frozen guidance/settings; outcome remains pending.

Retry04 Rupi turn1 reaches its watchdog at600,386ms, unresolved:15,181 recorded work
(10,885 input+4,296 output), four starts/three completions/three usage records. Four requested
tools/two complete/two failed/zero Unknown (grep/read/read/read), no mutating tool request.
Tests1/all four help1/oracle1, no verification timeouts. Complete snapshot lists only SPEC,
.gitignore and four configs; no application/tests/README. Unfinished inference usage unknown.
Lower recorded work on this failed attempt is not a win. No prompt compliance or causal window
benefit claim. Turn2 active with unchanged shared repair guidance/window12 controls; Pi not run.
Retry04 Rupi turn2 reaches its watchdog at600,680ms, unresolved:14,555 recorded work
(5,764 input+8,791 output), three starts/three completions including an earlier abandoned
request, two usage records. Two requested/completed tools (write/edit), zero failed/Unknown.
Project tests1/oracle1/all four help0, no verification timeouts. Main19,999 is listed; tests
and README absent. Generated contents unread; passing help does not prove complete behavior.
Cumulative work29,736/authoring1,201,066ms. Turn3 active with frozen guidance/window12 controls.
Pi not run; unfinished inference usage unknown and no comparative win claimed.
Retry04 Rupi turn3 reaches its watchdog at600,296ms, unresolved:33,406 recorded work
(28,615 input+4,791 output), twelve starts/twelve completions including an earlier abandoned
request, eleven usage records. Twelve requested/completed tools, zero failed/Unknown (two
writes, one edit, four grep, five reads). Tests1/oracle1/all four help0, no verification
timeouts. Main27,737/tests-init0/test_help991 listed; README absent. Contents unread; file
presence does not prove assertion preservation or discovered/passing tests. Cumulative
work63,142/authoring1,801,362ms. Turn4 active, controls frozen; Pi not run. Branch audit after
fetch/prune: only main and active fix/case10-audit-ledger remain locally/remotely; historical
worktrees detached with artifacts retained. No failed-screen win claim.
Retry04 Rupi turn4 reaches its watchdog at600,380ms, unresolved:10,409 recorded work
(8,648 input+1,761 output), two starts/two completions including an earlier abandoned
request, one usage record. Zero tools requested/completed/failed/Unknown. Tests1/oracle1/
all four help0, no verification timeouts. Main27,737/tests-init0/test_help991 sizes match
turn3 without proving unchanged contents; README absent, contents unread. Unfinished
inference usage unknown. Cumulative work73,551/authoring2,401,742ms. Turn5 active; Pi not run.
Lower recorded work on this failed turn is not success or a causal progress-window benefit.
Retry04 Rupi turn5 reaches its watchdog at600,313ms, unresolved:14,546 recorded work
(8,182 input+6,364 output), five starts/five completions including an earlier abandoned
request, four usage records. Four requested/completed tools (edit/write/grep/read), zero
failed/Unknown. Tests1/oracle1/all four help0, no verification timeouts. README4,828 newly
listed/main34,627 differs; tests-init0/test_help991 sizes match without proving unchanged
content. Generated contents unread; file presence is not completeness or passing behavior.
Cumulative work88,097/authoring3,002,055ms. Final turn6 active, controls frozen, Pi not run.
Unfinished inference usage unknown; no comparative or full-public-task win claim.
Retry04 Rupi turn6 exits0/budget_exhausted at420,666ms, unresolved:24,979 recorded work
(21,296 input+3,683 output), eleven starts/twelve completions including an earlier abandoned
request, eleven usage records. Eleven requested/completed tools (eight reads/three grep),
zero failed/Unknown. Tests1/oracle1/all four help0, no verification timeouts. All four listed
generated-file sizes match turn5 without proving unchanged contents; contents unread.

Retry04 terminal failed screen:113,076 recorded work/3,422,721ms authoring/31 completed/
two failed/zero Unknown tools. Five watchdogs/one budget-exhausted turn, no acceptance or
project-test pass. Help passes from turn2. Exec7815 exits0; runner23564/wrapper29924 gone.
All six saved prompt/control/copied SPEC/three acceptance hash audits pass; selected config,
binary/model/relay unchanged. Pi not run, so Pi metrics unavailable and no paired win.
README and tests listed but unread; full public task completeness unproven.

### Existing window1 control: next screen

Use existing Recurring/window1 instead of12 with shared monolith/TestCase guidance unchanged,
source92d2b269/harness86F04AA7...5AD98/debug8159F875...77F24. This selects the more frequent
existing boundary; no causal benefit is assumed. Same low2048/native replay/cap12/max-output
16,384/six600s/grace6. All-case selected/capitalized window1 guards and actual fresh config/
SPEC/three reference hash probes pass; all four model slots idle. Root usage66% five-hour/
40% weekly below95/99 soft stops; root policy edit preserved. Fresh Rupi screen first, same
RunId Pi comparison only if Rupi resolves, with frozen source/settings. No Rust changes,
manual solver or acceptance edits. Paired evidence/final checks/startup/review/CI pending.
### Retry05 window1 screen: launched

Run: `bench-20261004-case10-monolith-window1-budget2048-low-retry05-rupi12-screen6-600s`.
Source92d2b269/harness86F04AA7...5AD98/debug8159F875...77F24; checkpointf411504.
Exec34949/runner4600/wrapper620; same model/relay/low2048/cap12/six600s/grace6.
Only existing window12→1 changes, mode remains recurring; actual run controls pass and
initial prompt is byte-identical to retry04. No builds or parallel inference. Pi conditional
on Rupi acceptance with frozen source/settings; outcome pending.

Retry05 Rupi turn1 reaches watchdog600,492ms unresolved:6,104 recorded work (5,915
input+189 output), two starts/one completion/one usage record. Two requested/completed tools
(grep/read), zero failed/Unknown, no mutating request. Tests1/all four help1/oracle1,
no verification timeouts. Filtered application/test/README metadata empty; no generated
contents inspected. Unfinished inference work unknown, not zero. Lower work is not success.
Turn2 active with frozen recurring/window1 controls; Pi not run, no comparative win.

Retry05 Rupi turn2 exits0/runtime failed(timeout) at594,656ms, unresolved. Recorded work0
with no usage records; this is not zero actual inference work. One model start/two completions
include an earlier abandoned request. Zero tools requested/completed/failed/Unknown. Tests1/
all four help1/oracle1; no verification timeouts (provider timeout is separate). Filtered
application/tests/README entries empty, generated contents unread. Cumulative recorded
work6,104/authoring1,195,148ms; unrecorded inference unknown. Turn3 active; Pi not run.

Retry05 Rupi turn3 exits0/runtime failed(timeout) at594,723ms, unresolved. Recorded work0/
no usage records, actual unfinished inference unknown. One start/one completion, zero tools
requested/completed/failed/Unknown. Tests1/all four help1/oracle1, no verification timeouts.
Filtered application/test/README metadata empty, contents unread. Cumulative recorded
work6,104/authoring1,789,871ms. Turn4 active with unchanged controls; Pi not run. Repeated
provider timeout is recorded separately from harness watchdog and acceptance failure.

Retry05 Rupi turn4 reaches watchdog600,287ms unresolved:6,939 recorded work (5,645
input+1,294 output), two starts/one completion/one usage record. One requested/completed read,
zero failed/Unknown, no mutating request. Tests1/all four help1/oracle1, no verification
timeouts. Filtered application/test/README entries empty, generated contents unread.
Cumulative recorded work13,043/authoring2,390,158ms; unfinished inference unknown. Turn5
active with frozen controls; Pi not run, no comparative win.

Retry05 Rupi turn5 exits0/runtime failed(timeout) at595,571ms, unresolved. Recorded work0/
no usage records; actual unfinished inference unknown. One model start/two completions include
an earlier abandoned request. Zero tools requested/completed/failed/Unknown. Tests1/all four
help1/oracle1, no verification timeouts. Filtered application/test/README entries empty,
contents unread. Cumulative recorded work13,043/authoring2,985,729ms. Final turn6 active with
unchanged controls; Pi not run and no win claim.

Retry05 Rupi turn6 reaches watchdog600,288ms unresolved:25,422 recorded work (16,968
input+8,454 output), seven starts/six completions/six usage records. Six tools requested/five
completed/one failed/zero Unknown (read/write/four edits). Tests1/oracle1/all four help0,
no verification timeouts. Main19,474 listed, tests/README absent; contents unread. Unfinished
inference unknown. Runtime/tool effects are not inferred beyond recorded outcomes.

Retry05 terminal failed screen:38,465 recorded work/3,586,017ms authoring/eight completed/
one failed/zero Unknown tools. Three watchdogs/three provider-timeout failures. Every tests/
acceptance gate fails; help passes only at6. Unrecorded timed-out inference remains unknown.
Exec34949 exits0, runner4600/wrapper620 gone. All six saved prompt/control/copied SPEC/three
acceptance hash audits pass; selected config/binary/model/relay unchanged, all slots idle.
Pi not run, metrics unavailable; no paired win or full-public-task completion claimed.

### Existing window12 with longer matched attempt limit: next screen

Keep current monolith/TestCase guidance/source92d2b269/harness86F04AA7...5AD98/
debug8159F875...77F24.
Select existing recurring/window12/cap12, low2048/native replay/max-output16,384 as retry04.
Change the watchdog600→1,200s and provider deadline594,000→1,194,000ms, same grace6/six attempts.
Repeated deadlines motivate testing more authoring time, without claiming their cause or
that longer time will succeed. All-case selected/capitalized guards and fresh config/SPEC/
three reference hashes pass. Root usage2% five-hour/41% weekly below95/99 stops. Rupi screen
first; same-RunId fresh Pi only on acceptance with identical source/guidance/time controls.
No source/runtime/acceptance changes or manual solver. Final paired evidence/checks/startup/
review/exact-head CI remain pending; Cases01–09 skipped and broad project gates remain active.

### Retry06 window12/1200s screen: launched

Run: `bench-20261004-case10-monolith-window12-budget2048-low-retry06-rupi12-screen6-1200s`.
Source92d2b269/harness86F04AA7...5AD98/debug8159F875...77F24; checkpoint6b1c471.
Exec40371/runner29200/wrapper20372; same model/relay/low2048/window12/cap12 as retry04.
Six attempts1,200s/grace6/provider1,194,000ms. Actual run controls pass; initial prompt
byte-identical to retry04. Slots idle before launch; no builds/parallel inference. Pi
conditional on Rupi acceptance with frozen source/guidance/time controls; outcome pending.

Retry06 Rupi turn1 exits0/budget_exhausted at988,246ms, unresolved:46,612 recorded work
(30,529 input+16,083 output), twelve starts/completions/usage records. Sixteen tool requests/
thirteen completed/three failed/zero Unknown (ten grep, five reads, one write). Tests1/
oracle1/all four help0, no verification timeouts. Main44,366 listed; tests/README absent,
contents unread. First request is grep despite first-write guidance; no compliance claimed.
More authoring time does not establish causal benefit or acceptance. Turn2 active with
frozen source/window12/1200 controls; Pi not run, no paired win.

Retry06 Rupi turn2 exits0/budget_exhausted at392,518ms unresolved:32,840 recorded work
(28,908 input+3,932 output), twelve starts/completions/usage records. Thirteen tool requests/
eleven completed/two failed/zero Unknown (four grep, eight reads, one write). Tests1/oracle1/
all four help0, no verification timeouts. Package init272 newly listed/main44,366 size matches
without proving unchanged contents; tests/README absent, generated contents unread. Prompt
presence does not prove adherence to missing-public-TestCase guidance. Cumulative work79,452/
authoring1,380,764ms. Turn3 active with frozen controls; Pi not run, no win claimed.

Retry06 Rupi turn3 exits0/runtime completed at593,833ms unresolved:25,924 recorded work
(16,652 input+9,272 output), eleven starts/completions/usage records. Eleven requested tools/
ten completed/one failed/zero Unknown (two writes, three reads, four grep, two edits).
Tests1/oracle1/all four help0, no verification timeouts. Tests-init0/test_receiptledger19,836
newly listed; main44,366/package-init272 sizes match without proving unchanged content.
README absent, generated contents unread; file presence does not prove discovered/passing
tests or preserved assertions. Cumulative work105,376/authoring1,974,597ms. Runtime completion
is not acceptance; turn4 active with frozen controls, Pi not run and no win claimed.

Retry06 Rupi turn4 exits0/budget_exhausted at550,091ms unresolved:25,046 recorded work
(16,812 input+8,234 output), twelve starts/completions/usage records. Eleven requested/
completed tools/zero failed/Unknown (five grep, four reads, one edit, one write). Tests1/
oracle1/all four help0, no verification timeouts. README14,069 newly listed/main44,713
differs; package-init272/tests-init0/public-test19,836 sizes match without proving unchanged
content. Generated contents unread; README presence does not prove complete documentation.
Cumulative work130,422/authoring2,524,688ms. Turn5 active with frozen controls; Pi not run,
no acceptance, comparative or full-public-task completion claim.

Retry06 Rupi turn5 exits0/budget_exhausted at236,756ms unresolved:18,596 recorded work
(16,532 input+2,064 output), eleven starts/completions/usage records. Eleven requested/
completed tools (six reads/five grep), zero failed/Unknown, no mutating request. Tests1/
oracle1/all four help0, no verification timeouts. All five listed generated-file sizes
match turn4 without proving unchanged content; generated contents unread. Cumulative
work149,018/authoring2,761,444ms. Final turn6 active with frozen controls; Pi not run.
Request-budget exhaustion is distinct from watchdog/provider timeout; no win claim.

Retry06 Rupi turn6 exits0/runtime completed at365,217ms unresolved:24,556 recorded work
(20,201 input+4,355 output), nine starts/completions/usage records. Eight requested/completed
tools/zero failed/Unknown (six reads, one grep, one write). Tests1/oracle1/all four help0,
no verification timeouts. Five filtered generated-file sizes match turn5 without proving
unchanged contents. Full snapshot also lists CHANGELOG1,882; contents unread, no exact-write
or assertion-preservation claim. Runtime completion is not acceptance.

Retry06 terminal failed screen:173,574 recorded work/3,126,661ms authoring/64 completed/
six failed/zero Unknown tools. Four request-budget-exhausted/two completed turns, no watchdog
or provider-timeout result. Every tests/acceptance gate fails; all help passes. README/tests
listed but unread, full public task completeness unproven. Exec40371 exits0, runner29200/
wrapper20372 gone. All six saved prompt/control/copied SPEC/three acceptance hash audits pass;
selected config/binary/model/relay unchanged and slots idle. Pi not run, metrics unavailable.
No paired win or causal time-limit benefit claimed.

### Existing cap24 with unchanged window12/1200 controls: next screen

Keep shared guidance/source92d2b269/harness86F04AA7...5AD98/debug8159F875...77F24, same model/
relay/low2048/native replay/max-output16,384/six1,200s/grace6/provider1,194,000ms. Select
existing Rupi request cap12→24, retaining recurring/window12. Four exhausted turns motivate
testing additional request headroom; benefit is unproven. All-case selected/capitalized
window12/1200/cap24 guards and actual fresh config/SPEC/three acceptance hashes pass. Root
usage8% five-hour/42% weekly below95/99 limits. Fresh Rupi screen first, Pi conditional on
acceptance with frozen source/guidance/shared time settings; Pi native cap remains unavailable.
No source/runtime/acceptance changes or manual solver. Final paired evidence/checks/startup/
review/exact-head CI pending; Cases01–09 skipped and broad project gates remain active.

### Retry07 existing cap24 screen: launched

Run: `bench-20261004-case10-monolith-window12-budget2048-low-retry07-rupi24-screen6-1200s`.
Source92d2b269/harness86F04AA7...5AD98/debug8159F875...77F24; checkpoint7b566c3.
Exec57069/runner23972/wrapper7188; same model/relay/low2048/window12/six1,200s/grace6.
Only existing Rupi cap12→24 changes from retry06. Actual run controls pass; initial prompt
byte-identical to retry06. Slots idle before launch; no builds or parallel inference.
Fresh Pi conditional on Rupi acceptance, with frozen source/guidance/shared time controls.
Pi native cap remains unavailable; outcome pending, no comparative claim.

Retry07 Rupi turn1 reaches watchdog1,200,316ms unresolved:67,339 recorded work (51,462
input+15,877 output), twenty-four starts/twenty-three completions/usage records. Twenty-four
tool requests/twenty-two completed/two failed/zero Unknown (four grep, seventeen reads,
one write, two edits). Tests1/oracle1/all four help0, no verification timeouts. Main44,778
listed, tests/README absent, generated contents unread. First tool grep despite first-write
guidance; no compliance or causal cap benefit claimed. Unfinished inference unknown.
Turn2 active with frozen recurring/window12/cap24/1200 controls; Pi not run, no paired win.

Retry07 Rupi turn2 exits0/budget_exhausted at1,009,003ms unresolved:91,635 recorded work
(81,787 input+9,848 output), twenty-four starts/twenty-five completions including an earlier
abandoned request, twenty-four usage records. Twenty-five tool requests/twenty-one completed/
four failed/zero Unknown (seven grep, sixteen reads, two writes). Tests5/oracle1/all four
help0, no verification timeouts. README10,182/tests-init37 newly listed/main44,778 size
matches without proving unchanged contents. Public test module/package init absent from
snapshot; contents unread. Cumulative work158,974/authoring2,209,319ms. Turn3 active with
frozen controls, Pi not run; prompt presence does not prove missing-test guidance compliance.

Retry07 Rupi turn3 reaches watchdog1,200,508ms unresolved:69,239 recorded work (55,869
input+13,370 output), nineteen starts/eighteen completions/usage records. Twenty-three tool
requests/twenty-two completed/one failed/zero Unknown (thirteen reads, seven grep, two writes,
one edit). Tests5/oracle1/all four help0, no verification timeouts. Tests/_support8,888 and
tests/README1,595 newly listed/main44,809 differs; README10,182/tests-init37 sizes match
without proving unchanged content. Public test module/package init absent from filtered
snapshot; generated contents unread. Helper/documentation presence does not prove real
public TestCases or preserved assertions. Cumulative work228,213/authoring3,409,827ms.
Turn4 active with frozen controls; unrecorded unfinished inference unknown, Pi not run.

Retry07 Rupi turn4 exits0/budget_exhausted at1,169,915ms unresolved:107,979 recorded work
(95,442 input+12,537 output), twenty-four starts/twenty-five completions including an earlier
abandoned request, twenty-four usage records. Twenty-nine tool requests/twenty-eight completed/
one failed/zero Unknown (seventeen reads, nine grep, two edits, one write). Tests1/oracle1/
all four help0, no verification timeouts. Public test_http_admission10,173 newly listed/
support13,272 differs; other four filtered sizes match without proving unchanged contents.
Generated contents unread; module presence does not prove passing or preserved assertions.
Cumulative work336,192/authoring4,579,742ms. Turn5 active with frozen controls; Pi not run,
no acceptance/comparative/full-public-task completion claimed.

Retry07 Rupi turn5 exits0/runtime failed(timeout) at727,153ms unresolved:10,264 recorded
work (8,308 input+1,956 output), five starts/completions/four usage records. Four tool
requests/three completed/one failed/zero Unknown (edit, two grep, read). Tests1/oracle1/
all four help0, no verification timeouts. Public HTTP-test10,164 differs; other five filtered
sizes match without proving unchanged contents. Generated contents unread; exact edits and
assertion preservation unproven. Unrecorded unfinished inference unknown, not zero. Cumulative
work346,456/authoring5,306,895ms. Final turn6 active with frozen controls; Pi not run.
Runtime timeout does not establish its particular cause or imply an acceptance pass.

Retry07 Rupi turn6 exits0/runtime completed at342,606ms unresolved:12,800 recorded work
(7,866 input+4,934 output), two starts/completions/usage records. One requested/completed
edit, zero failed/Unknown. Tests1/oracle1/all four help0, no verification timeouts. Public
HTTP-test10,377 differs; other five filtered sizes match without proving unchanged contents.
Generated contents unread; assertion preservation and full public-task completeness unproven.

Retry07 terminal failed screen:359,256 recorded work/5,649,501ms authoring/97 completed/
nine failed/zero Unknown tools. Two watchdogs/two budget-exhausted/one runtime-timeout failure/
one completed turn. Every project-test/acceptance gate fails; all help passes. Unrecorded
unfinished inference remains unknown. Exec57069 exits0, runner23972/wrapper7188 gone. All six
saved prompt/control/copied SPEC/three acceptance hash audits pass; selected config/binary/
model/relay unchanged, all slots idle. Pi not run, metrics unavailable; no paired win.

### Existing window3 with unchanged cap24/1200 controls: next screen

Keep current shared guidance/source92d2b269/harness86F04AA7...5AD98/debug8159F875...77F24.
Select existing recurring/window3 instead of12, preserving cap24/low2048/native replay/
max-output16,384/six1,200s/grace6/provider1,194,000ms. This tests the more frequent existing
boundary with additional request headroom; no causal benefit is assumed. All-case selected/
capitalized window3/1200/cap24 guards and fresh config/SPEC/three acceptance hashes pass.
Root usage18% five-hour/44% weekly below95/99 limits. Fresh Rupi screen first, same-RunId
Pi only if Rupi resolves, with frozen source/guidance/shared time settings. Pi cap unavailable.
No runtime/source/acceptance change or manual solver. Paired evidence/final checks/startup/
review/exact-head CI pending; Cases01–09 skipped and broad project gates remain active.

### Retry08 existing window3/cap24/1200 screen: launched

Run: `bench-20261004-case10-monolith-window3-budget2048-low-retry08-rupi24-screen6-1200s`.
Source92d2b269/harness86F04AA7...5AD98/debug8159F875...77F24; checkpointd769483.
Exec10828/runner14364/wrapper30756; same model/relay/low2048/cap24/six1,200s/grace6.
Only existing window12→3 changes from retry07. Actual run controls pass; initial prompt
byte-identical to retry07. Slots idle before launch; no builds or parallel inference.
Fresh Pi conditional on Rupi acceptance with frozen source/guidance/shared time controls;
Pi native cap remains unavailable. Branch inventory after fetch/prune remains main plus
active Case10 locally/remotely; historical worktree artifacts retained. Outcome pending.

Retry08 Rupi turn1 exits0/runtime failed(transport) at829,232ms unresolved:17,319 recorded
work (14,917 input+2,402 output), three starts/completions/two usage records. Four tool
requests/two completed/two failed/zero Unknown (read, three grep), no mutating request.
Tests1/oracle1/all four help1, no verification timeouts. Filtered application/test/README
metadata empty, generated contents unread; unfinished inference work unknown. Transport
failure does not establish its particular cause or a progress-window benefit. Turn2 active
with frozen recurring/window3/cap24/1200 controls; Pi not run, no comparative win.

Retry08 Rupi turn2 reaches watchdog1,200,281ms unresolved:74,267 recorded work (62,516
input+11,751 output), twenty-one starts/twenty completions/usage records. Twenty-three tool
requests/twenty-two completed/one failed/zero Unknown (write, twelve reads, nine edits, grep).
Tests1/oracle1/all four help0, no verification timeouts. Main25,480 listed, tests/README
absent, generated contents unread. First tool is write on this repair; this does not prove
complete behavior, edit bounds, assertion preservation or causal window benefit. Unfinished
inference unknown. Cumulative work91,586/authoring2,029,513ms. Turn3 active with frozen
controls; Pi not run, no paired win.

Retry08 Rupi turn3 exits0/budget_exhausted at1,069,475ms unresolved:69,446 recorded work
(56,847 input+12,599 output), twenty-three starts/twenty-four completions including an
earlier abandoned request, twenty-three usage records. Thirty-one tool requests/twenty-nine
completed/two failed/zero Unknown (ten grep, three writes, eleven reads, seven edits).
Tests1/oracle1/all four help0, no verification timeouts. README9,242/tests-init45/public-test
12,530 newly listed/main25,480 size matches without proving unchanged content. Contents
unread; file presence does not prove passing tests or assertion preservation. Cumulative
work161,032/authoring3,098,988ms. Turn4 active with frozen controls; Pi not run, no win.

Source-only review lead: src/run.rs CLI system text broadly requests inspection before
editing and post-change checks; Case10 user guidance requests direct first writes and
harness-only verification. Get-Case10Prompt initial/repair branches are separate. Review
whether generic clarification of supplied context/new files/delegated verification would
better respect user workflows after terminal evidence. This is not an established cause
of these failures. No source edit or new domain-specific runtime policy during this screen.

Retry08 Rupi turn4 reaches watchdog1,200,174ms unresolved:42,822 recorded work (29,863
input+12,959 output), fifteen starts/fourteen completions/usage records. Nineteen requested/
completed tools/zero failed/Unknown (nine edits, seven grep, three reads); first tool is edit.
Tests1/oracle1/all four help0, no verification timeouts. Main42,237/public-test12,691 differ;
README9,242/tests-init45 sizes match without proving unchanged content. Generated contents
unread; tool completion/size changes do not prove exact edits, assertion preservation or
complete behavior. Unfinished inference unknown. Cumulative work203,854/authoring4,299,162ms.
Turn5 active with frozen controls; Pi not run, no acceptance/comparative win.

Retry08 Rupi turn5 exits0/runtime completed at656,771ms unresolved:53,818 recorded work
(46,974 input+6,844 output), thirteen starts/fourteen completions including an earlier
abandoned request, thirteen usage records. Fourteen requested/completed tools/zero failed/
Unknown (five reads, four grep, five edits). Project tests0/all four help0/oracle1, no
verification timeouts. README9,492/main42,430/public-test12,920 differ; tests-init45 size
matches without proving unchanged content. Generated contents unread; a passing local suite
does not prove preserved assertions or every public requirement. Cumulative work257,672/
authoring4,955,933ms. Final turn6 active with frozen controls; Pi not run. Local gates now
pass but acceptance still fails, so no configured/comparative or full-public-task win.

### Retry08 terminal evidence and next CLI slice

Retry08 turn6 exits0/budget_exhausted at785,730ms unresolved:57,108 recorded work
(50,425 input+6,683 output), twenty-four model starts/completions/usage records.
Twenty-five tool requests/twenty-three completed/two failed/zero Unknown. Project tests0,
all four help0, oracle1, no verification timeout. README9,538/main43,254/public-test15,759
differ; tests-init45 size matches without proving unchanged content. Generated contents unread.

All six attempts fail acceptance. Totals314,780 recorded work/5,741,663ms authoring/
109 completed tools/seven failed/zero Unknown. Two watchdogs; unfinished inference unknown.
All saved prompts/controls/copied SPEC/three acceptance hashes pass terminal audit.
Debug8159F875...77F24/model27356/relay33028 unchanged; no Pi run or comparative win.

Next bounded slice: clarify the generic CLI system prompt in src/run.rs so sufficient
supplied context can support new-file creation and explicitly delegated verification uses
supplied results with truthful attribution. Existing-file/project-instruction inspection,
host permissions and runtime/tool lifecycle remain intact. No case-specific core policy,
manual solver, acceptance change or harness/prompt change. The broad existing system text
is a review lead, not an established cause. Parent is sole writer and performs a separate
invariant-review phase. Required Rust checks/startup and explicit debug build precede a
fresh same-profile Rupi screen; paired Pi conditional on acceptance. Case10 remains active.

Fetch/prune confirms only main and active fix/case10-audit-ledger local/remote branches;
historical benchmark worktrees remain detached with artifacts retained.

### Generic CLI workflow prompt clarification: implemented and reviewed

src/run.rs now permits sufficient supplied context to guide requested new-file creation,
respects delegated verification and distinguishes supplied results from checks actually run.
Existing-file/project-instruction inspection and implementation/repair guidance remain.
Explicit sentence breaks also prevent Rust continuation whitespace from joining words.
The benchmark harness/shared user guidance remain byte-identical (86F04AA7...5AD98).

Parent source-only invariant review: pass, no blocking findings. Scope is static first-party
CLI prompt copy; skills append/runtime.with_system/tool-approval wiring unchanged. No core
state, replay, Unknown handling, provenance serialization, failover, model activation,
trust gate, dependencies, network discovery or hydration changes. No domain-specific
core workflow added. This is not a guarantee of model compliance or acceptance improvement.
Required Cargo/startup verification and updated debug binary remain pending.

### CLI clarification local verification: pass

Runtime source2c8ee6b0a9595192cafa160cbdba1d1819383307; unchanged harness92d2b269/
86F04AA70643CD8020EE348D5CE16A230C037D195B4D655966985EB37745AD98.
cargo fmt --all --check; cargo check -p rupi-core --all-features; cargo clippy --workspace
--all-targets -- -D warnings; cargo test --workspace; cargo doc --workspace --no-deps;
cargo build --bin rupi all exit0. The pinned-name local installation lacks cargo/clippy;
the installed stable route reports exactly rustc1.98.1(48a229cea2026-09-01) and
cargo1.98.1(797e8a9bc2026-08-05), used through process-only RUSTUP_TOOLCHAIN=stable.
Repository toolchain pin unchanged.

Git Bash bench/startup.sh --json bench/results/startup-ci.json exits0:
cold147.176ms/warm median8.091ms/max9.114ms meets250/100ms budgets.
New debugSHA256:7C18C86079B6B801F1F57EFD6C10689926449A4DD3F4EE876D0FB278DC380E46.
All Cargo/release builds complete before inference. Same-profile native configuration,
SPEC/three acceptance hashes and Case10 dry-run guards pass; model slots idle.

Next fresh retry09 keeps shared user guidance and window3/cap24/low2048/6x1200s/grace6/
provider1194000ms fixed. Only intended behavioral variable is generic CLI system text
and its rebuilt binary. Fresh Pi conditional on acceptance, no win or full-task claim yet.

### Retry09 CLI clarification screen: launched

Run: bench-20261005-case10-cli-context-window3-budget2048-low-retry09-rupi24-screen6-1200s.
Runtime source2c8ee6b; harness92d2b269/SHA86F04AA7...5AD98; checkpoint4a9b959.
Exec63276/runner26560/wrapper25564; debug7C18C860...80E46, model27356/relay33028.
Same recurring/window3/cap24/low2048/six1,200s/grace6/provider1194000/maxoutput16384.
Saved initial user prompt hashes match retry08 exactly. Intended behavioral variable is
generic CLI system text/new binary. No builds or parallel inference during this screen.
Fresh Pi conditional on Rupi acceptance with frozen source/binary/guidance/settings.
No acceptance/comparative win yet; broad project gates and Case10 remain active.

Retry09 Rupi turn1 reaches watchdog1,200,270ms unresolved:28,754 recorded work
(14,633 input+14,121 output), seven starts/six completions/usage records.
Seven tool requests/five completed/two failed/zero Unknown (grep, read, grep, write,
read, read, edit). Tests1/all four help0/oracle1, no verification timeout.
Main48,041 listed; tests/README absent in filtered metadata, generated contents unread.
First actual tool is grep despite new generic prompt and shared first-write guidance;
this does not establish the cause. File size and tool completion do not prove behavior.
Saved prompt/controls/SPEC/three acceptance hashes pass, debug7C18C860...80E46 and
model27356/relay33028 unchanged. Unfinished inference unknown. Turn2 active with frozen
settings; Pi not run, no acceptance/comparative win.

Retry09 Rupi turn2 exits0/runtime completed at1,199,026ms unresolved:76,019 recorded
work (58,777 input+17,242 output), eighteen starts/nineteen completions including an
earlier abandoned request/eighteen usage records. Twenty-four requested/completed tools/
zero failed/Unknown; first tool write. Project-test command0/all four help0/oracle1,
no verification timeout. README8,237/public-test9,560/tests-README1,220/sink-support5,888
newly listed; main48,041 size matches without proving unchanged content. Contents unread;
test-command success and file presence do not prove meaningful coverage, preserved
assertions or all public requirements. Local gates pass earlier than retry08 without a
causal/statistical claim. Cumulative work104,773/authoring2,399,296ms/29 completed tools.
Saved prompt/controls/SPEC/three acceptance hashes and debug/model/relay audits pass.
Turn3 active with frozen settings; Pi not run, acceptance/comparative win absent.

Public-SPEC-only follow-up lead during frozen retry09: an owned Python ast.literal_eval
probe of the separator in SPEC.md:312 evaluates to codepoints[92,110]/two UTF-8 bytes.
It is a literal backslash followed by n as the published expression is written. Current
shared guidance already requests the exact public expression. This may support a later
clarification if retry09 fails; it is not an observed implementation defect or a proven
acceptance cause. No generated solution/test/trace or oracle source/diagnostic inspected;
no source/guidance/binary change during the current screen.

Retry09 Rupi turn3 reaches watchdog1,200,174ms unresolved:67,962 recorded work
(55,280 input+12,682 output), eighteen starts/seventeen completions/usage records.
Twenty-two tool requests/twenty-one completed/one failed/zero Unknown; first tool grep.
Project-test command0/all four help0/oracle1, no verification timeout. Main48,616 and
tests-README1,550 sizes differ; README8,237/public-test9,560/sink-support5,888 sizes match
without proving unchanged content or assertion preservation. Generated contents unread.
Cumulative work172,735/authoring3,599,470ms/50 completed tools/three failed/zero Unknown.
Unfinished inference unknown. All saved prompt/control/SPEC/acceptance hashes and
debug7C18C860/model27356/relay33028 audits pass. Turn4 active with frozen settings;
Pi not run, no acceptance/comparative win.

Retry09 Rupi turn4 reaches watchdog1,200,184ms unresolved:56,783 recorded work
(41,131 input+15,652 output), twenty-one starts/completions/twenty usage records.
Twenty-five tool requests/twenty-four completed/one failed/zero Unknown; first tool grep.
Project-test command1/all four help0/oracle1, no verification timeout. Newly listed
tests/test_audit_cli.py6,536/main49,019 differs; README8,237/tests-README1,550/public-test
9,560/sink-support5,888 sizes match without proving unchanged content. Contents unread;
the new test filename does not prove coverage or the particular cause of the test failure.
Cumulative work229,518/authoring4,799,654ms/74 completed tools/four failed/zero Unknown.
Unfinished inference unknown. All saved prompt/control/SPEC/acceptance hashes and
debug7C18C860/model27356/relay33028 audits pass. Turn5 active with frozen settings;
Pi not run, no acceptance/comparative win.

Retry09 Rupi turn5 exits0/runtime completed at322,643ms unresolved:14,805 recorded work
(10,164 input+4,641 output), six starts/seven completions including an earlier abandoned
request/six usage records. Six requested/completed tools/zero failed/Unknown
(write, read, edit, edit, grep, grep). Project-test command1/all four help0/oracle1,
no verification timeout. Audit-test8,036 differs; main49,019/README8,237/tests-README1,550/
public-test9,560/sink-support5,888 sizes match without proving unchanged content. Generated
contents unread; completion/metadata do not establish correctness or assertion preservation.
Cumulative work244,323/authoring5,122,297ms/80 completed tools/four failed/zero Unknown.
Saved prompt/control/SPEC/acceptance hashes and debug/model/relay audits pass.
Final turn6 active with frozen settings; Pi not run, no acceptance/comparative win.

### Retry09 terminal evidence and next public-guidance slice

Retry09 turn6 exits0/budget_exhausted at1,062,346ms unresolved:68,906 recorded work
(57,913 input+10,993 output), twenty-three starts/completions/usage records.
Twenty-four requested/completed tools/zero failed/Unknown; first tool edit.
Project-test command1/all four help0/oracle1, no verification timeout. Main49,446/
audit-test8,128/public-test15,428 sizes differ; README8,237/tests-README1,550/sink-support
5,888 sizes match without proving unchanged content. Generated contents unread.

All six attempts fail acceptance. Total313,229 work/6,184,643ms/104 completed tools/
four failed/zero Unknown; three watchdogs, two runtime completions, final budget exhaustion.
Local-test command passes2–3, fails1/4/5/6; all help passes each attempt. Earlier local
success does not establish full public behavior, assertion preservation or causal benefit.
All six prompt/control/SPEC/three acceptance hashes and debug7C18C860/model27356/relay33028
audits pass. Exec63276 exits0; all model slots idle. Pi not run; no comparative win.

Next bounded slice clarifies the public SPEC hash-separator bytes in shared user guidance
for both agents, derived only from the published expression and owned ast.literal_eval probe
(codepoints92,110/two bytes). No oracle/solution contents inspected or altered. Cause remains
unproven. CLI source2c8ee6b/debug7C18C860 and existing inference controls stay fixed.
Dry-run/reference/prompt-isolation guards precede a fresh same-profile Rupi screen; Pi
conditional on acceptance. Existing Rust/startup checks cover unchanged runtime source.

Fetch/prune again confirms main plus active Case10 local/remote branches; root unrelated
policy SHA3CEE11E5...B496 preserved. Parent usage6%five-hour/48%weekly below soft stops.
Cases01–09 skipped, Case10 and broad project gates remain active.

### Public separator clarification: implemented and guarded

Shared Get-Case10Prompt text now explicitly states the published separator's two UTF-8
bytes0x5c,0x6e (backslash then n), consistently for append, verify and independent public
tests. The same guidance goes to both agents; five assembled initial/recovery variants
require the wording. No acceptance, generated solution, runtime source or inference
control change. The owned public ast probe establishes the byte meaning; cause unproven.

Selected Case10 and all-case/capitalized-Recurring dry-run guards pass, including hidden
oracle sentinel and native-exposure rejection. Fresh native config/SPEC/three acceptance
hashes pass; all18 other-case initial/recovery prompt hashes remain unchanged.
Parent bounded invariant-review phase: pass, no blocking finding; static benchmark-user
guidance only, outside core. Runtime source2c8ee6b/debug7C18C860...80E46 unchanged and
covered by recorded Rust/startup checks. HarnessSHA30A6F9659C6F088E0995B4F84C47693088EDD736FDB214C87EB7C3738CE47840.
Fresh same-profile retry10 Rupi screen precedes conditional matched Pi; no win yet.

### Retry10 public-separator screen: launched

Run: bench-20261005-case10-separator-window3-budget2048-low-retry10-rupi24-screen6-1200s.
Harness sourcef6272212dda3760755f80113f9ee5f55905083eb/SHA30A6F965...47840;
runtime source2c8ee6b/debug7C18C860...80E46. Exec68817/runner14692/wrapper25564.
Same model27356/relay33028/recurring-window3/cap24/low2048/six1,200s/grace6/
provider1194000/maxoutput16384; slots idle before launch. No builds/parallel inference.
Saved initial promptSHAB888E63C...7F7D6 contains the byte clarification. After removing
the two inserted guidance lines, the remainder matches retry09 after newline normalization;
raw equality is false because two existing CRLF endings also became LF (stripped lengths
21,074 vs21,076). This formatting difference is part of the changed prompt, not hidden.
No causal assertion. Fresh Pi conditional on acceptance with exact same new user guidance
and frozen source/binary/settings. Outcome pending, Case10 and broad project gates active.

### Retry10 terminal evidence

The screen completed while the parent was away; fresh metadata replaces the earlier
attempt1 status. All six attempts fail project tests/acceptance; all four help checks pass
throughout. Exec68817 exits0; all slots idle. Pi not run, no comparative win.

| Turn | Authoring ms | Recorded work | Completed tools | Failed | Outcome |
| --- | ---: | ---: | ---: | ---: | --- |
| 1 | 1,200,328 | 66,502 | 16 | 1 | watchdog |
| 2 | 819,205 | 28,918 | 9 | 0 | runtime completed |
| 3 | 820,024 | 21,846 | 6 | 0 | runtime failed(timeout) |
| 4 | 1,200,702 | 53,063 | 19 | 2 | watchdog |
| 5 | 742,945 | 26,405 | 5 | 0 | runtime failed(timeout) |
| 6 | 1,204,147 | 48,815 | 20 | 0 | watchdog |

Totals245,549 recorded work/5,987,351ms/75 completed tools/three failed/zero Unknown;
no verification timeout. Unrecorded unfinished inference remains unknown. Turn6 has
21 starts/20 completions/usage records; final README10,629/app-init870/main47,839/
tests-init84/public-test44,241 listed. Generated contents unread; presence/size/completion
do not establish behavior, coverage or assertion preservation.

All six saved prompt/control/SPEC/three acceptance hashes pass, including explicit public
separator guidance. Debug7C18C860/model27356/relay33028 unchanged. Neither the generic CLI
prompt nor separator clarification has established acceptance benefit.

Next bounded candidate: existing native reasoning budget4,096 instead of2,048, matched
for both agents through a relay with the new cap. Keep same Qwen model, source/binary,
shared public guidance, window3/cap24/six1200s/grace6/time controls. Pin the intentional
relay/budget change, run config/dry-run guards, fresh Rupi screen and conditional matched
Pi. No manual solver or acceptance changes. Case10 and broad project gates remain active.
Parent usage0%five-hour/49%weekly before next slice.

### Bounded relay-port setup for native budget4,096: reviewed and guarded

Automatic approval review rejected the combined command that would stop/replace relay33028
with stated reason "blocked by policy"; no relay mutation occurred. Safer setup leaves
legacy2048/port8001/PID33028 available and starts the same owned relay code with
budget4096/port8002/PID20516, content logging false, upstream same Qwen8000.
Relay sourceSHA1B559700...0833B unchanged; no model reload or parallel inference.

bench/compare-pi-rupi.ps1 adds isolated Case10ReasoningRelayPort, default8001, loopback-only
endpoint, validated1024..65535 excluding main-model8000. Budget0 keeps direct8000;
Cases01–09 routes unchanged. Health validation uses each selected endpoint so Rupi/Pi
must match the explicit budget/upstream/no-content-logging controls. No runtime/binary or
shared user guidance change. This is benchmark transport setup outside core.

Selected/all-case/capitalized-mode dry-runs and fresh native4096/8002 config/reference
guards pass. Three invalid ports reject; other-case endpoint isolation/default-port/
budget-disabled route checks pass. All18 other prompt hashes unchanged; initial Case10
guidance exactly matches retry10. An initial owned guard invocation lacked exported AST
functions; rerun dot-sourced the owned snapshot and all endpoint/prompt checks pass.

Parent separate invariant-review phase: pass, no blocking findings. Explicit endpoint/
budget metadata remain honest; no tool state, Unknown/replay, provenance, trust, failover,
model activation, lazy discovery or startup change. Runtime source2c8ee6b/debug7C18C860
still covered by recorded Rust/startup checks. HarnessSHA27EECA11D646D70E039BBD9B7F40CE08268A816B76642FA8EBB7F41F0704737A.
Fresh retry11 pins the intentional4096 budget/new relay route, same model and other controls.
No acceptance/manual solver change; outcome and fresh matched Pi remain pending.

### Retry11 configured native4,096 screen: launched

Run: bench-20261005-case10-separator-window3-budget4096-low-retry11-rupi24-screen6-1200s.
Harness source287f0ba6bbd7287f12240ba732baf9cda4bea05a/SHA27EECA11...4737A;
runtime source2c8ee6b/debug7C18C860...80E46. Exec90668/runner36608/wrapper25564.
Model27356 unchanged; configured4096 relay20516/port8002 (legacy2048 relay33028/8001 idle).
Shared initial user prompt hashes equal retry10 exactly (B888E63C...7F7D6). Existing
recurring/window3/cap24/six1200s/grace6/provider1194000/maxoutput16384/low controls fixed.
Only intended profile changes are configured reasoning cap and isolated relay route;
actual native-reasoning length is not proven by the configured budget. Source/binary/
servers remain frozen during inference; no builds or parallel inference.

Fetch/prune again shows only main and active Case10 local/remote branches, fully pushed.
Fresh Pi conditional on Rupi acceptance using the exact same guidance/new relay/budget
and common time controls, native Pi request/progress limits unavailable. No win yet;
Case10 and broader project gates remain active.

Retry11 Rupi turn1 exits0/runtime failed(transport) at652,210ms unresolved.
One model start/completion, no usage record or tool request. Recorded work0 is not actual
zero inference; unfinished/unrecorded work unknown. Tests1/all four help1/oracle1, no
verification timeout; filtered app/test/README metadata empty, generated contents unread.
Saved prompt/control/SPEC/three acceptance hashes and debug7C18C860/model27356/relay20516
audits pass; configured4096/window3/cap24/8002/provider1194000ms remain fixed.

Owned relay-source review finds a hard response deadline650s (bench/case07-thinking-budget-
relay.py:96), below the configured provider1194s/outer1200s. This is an additional
transport limit for this and prior same-source profiles; the652,210ms failure is consistent
with that limit but specific causality is unproven without excluded transport/model content.
No source/settings/helper change during this screen. Consider a bounded configurable
relay deadline with explicit health evidence after terminal results, preserving default650s
and aligning a fresh profile with common provider/outer controls. Turn2 active;
Pi not run, no acceptance/comparative win.

Retry11 Rupi turn2 reaches watchdog1,200,259ms unresolved:46,709 recorded work
(27,947 input+18,762 output), seventeen starts/sixteen completions/usage records.
Twenty-one tool requests/twenty completed/one failed/zero Unknown; first tool write.
Tests1/all four help0/oracle1, no verification timeout. Main34,570 and an extra
receiptledger/notes_sink_audit.md454 listed; public tests/README absent in filtered metadata.
Generated contents unread; file/tool metadata do not prove full behavior or bounded edits.
Cumulative recorded work46,709/authoring1,852,469ms/20 completed tools/one failed/zero Unknown;
first-turn and other unfinished inference unknown. All saved prompt/control/SPEC/acceptance
hashes and debug/model4096-relay audits pass. Turn3 active with frozen settings;
Pi not run, no acceptance/comparative win.

Retry11 Rupi turn3 exits0/runtime completed at727,094ms unresolved:54,714 recorded
work (46,469 input+8,245 output), eleven starts/twelve completions including an earlier
abandoned request/eleven usage records. Thirteen tool requests/twelve completed/one failed/
zero Unknown; first tool grep. Project-test command5/all four help0/oracle1, no verification
timeout. Main34,588/notes_sink_audit.md2,403 differ; tests-init54 newly listed; public-test/
README absent in filtered metadata. Generated contents unread; these names/sizes do not
prove behavior, coverage, exact edits or assertion preservation. Cumulative work101,423/
authoring2,579,563ms/32 completed tools/two failed/zero Unknown; unrecorded inference unknown.
All saved prompt/control/SPEC/acceptance hashes and debug/model4096-relay audits pass.
Turn4 active with frozen settings; Pi not run, no acceptance/comparative win.

Retry11 Rupi turn4 reaches watchdog1,200,168ms unresolved:75,643 recorded work
(60,472 input+15,171 output), twenty-one starts/twenty completions/usage records.
Twenty-one requested/completed tools/zero failed/Unknown; first tool grep.
Project-test command1/all four help0/oracle1, no verification timeout. Public-test10,024
newly listed/main35,184 differs; note2,403/tests-init54 sizes match without proving unchanged
content. README absent in filtered metadata. Generated contents unread; a test filename
does not prove coverage or assertion preservation. Cumulative work177,066/authoring
3,779,731ms/53 completed tools/two failed/zero Unknown; unfinished inference unknown.
Saved prompt/control/SPEC/acceptance hashes and debug/model4096-relay audits pass.
Turn5 active with frozen settings; Pi not run, no acceptance/comparative win.

Retry11 Rupi turn5 reaches watchdog1,200,248ms unresolved:66,353 recorded work
(54,674 input+11,679 output), nineteen starts/completions/eighteen usage records.
Twenty-three tool requests/twenty-two completed/one failed/zero Unknown; first tool grep.
Project-test command5/all four help0/oracle1, no verification timeout. Public-test8,329
differs; main35,184/note2,403/tests-init54 sizes match without proving unchanged content.
README absent in filtered metadata. Generated contents unread; size reduction does not
prove removed assertions or a particular defect. Cumulative work243,419/authoring
4,979,979ms/75 completed tools/three failed/zero Unknown; unrecorded inference unknown.
Saved prompt/control/SPEC/acceptance hashes and debug/model4096-relay audits pass.
Final turn6 active with frozen settings; Pi not run, no acceptance/comparative win.

### Retry11 terminal evidence and bounded transport-deadline slice

Retry11 turn6 reaches watchdog1,200,277ms unresolved:64,399 recorded work
(46,957 input+17,442 output), fourteen starts/completions/thirteen usage records.
Seventeen tool requests/fifteen completed/two failed/zero Unknown; first tool edit.
Project-test command5/all four help0/oracle1, no verification timeout. Public-test11,650/
note1,624 sizes differ; main35,184/tests-init54 match without proving unchanged content.
README absent in filtered metadata; generated contents unread.

All six attempts fail acceptance/local tests (codes1,1,5,1,5,5); help fails at1 and passes
2–6. Total307,818 recorded work/6,180,256ms/90 completed tools/five failed/zero Unknown.
Four watchdogs, one runtime completion, one transport failure. Unrecorded inference
unknown, including first-turn work0/no usage. Exec90668 exits0; slots idle.
All six saved prompts/controls/SPEC/three acceptance hashes and debug7C18C860/
model27356/4096-relay20516 audits pass. Pi not run; no comparative win.

Next bounded slice adds configurable response timeout to the owned benchmark relay
(default650s preserved), exposes it in health metadata and requires an explicit Case10
deadline when requested. New separate relay/port8003 will use configured4096/1194s,
matching the existing provider1194s inside outer1200s/grace6. Existing relays untouched.
The source650s cap is proven; its specific contribution to failures remains unproven.
Pin changed helper/transport controls; keep same runtime binary/shared guidance/Qwen/
window3/cap24/time controls. Behavioral relay guards and native config/reference/prompt
checks precede fresh retry12 Rupi screening and conditional matched Pi. No solver/acceptance
change or raw model/oracle-content inspection. Case10 and broad project gates active.
Parent usage11%five-hour/51%weekly below soft stops before next slice.

### Explicit relay deadline: implemented, reviewed and verified

Owned relay accepts --response-timeout-seconds1..3600, preserves default650s, uses the
configured monotonic deadline and reports response_timeout_seconds in health. Source
and controls remain outside core; upstream forwarding still issues one request only.
Case10RelayResponseTimeoutSeconds defaults0/unverified, checks requested deadline fits
provider timeout, requires matching health when explicit, and records nullable per-turn/
aggregate control metadata. Legacy/other-case behavior preserved; unavailable stays null.

python -m unittest discover -s bench/tests -p test_*.py -v passes seven owned transport
behavior tests: short expiry/no replay, delayed response under longer deadline, expiry
after partial bytes without fabricated second response, client disconnect/no replay,
health evidence, default650 compatibility and invalid deadline before socket binding.
No model, generated solution or oracle content used. Ignore standard Python bytecode.

Parent separate invariant-review phase: pass, no blocking findings. No retry/replay added;
partial failure/cancellation semantics preserved. Health contains controls/counters only,
no request/response content. Loopback, model/budget validation and explicit matching
Rupi/Pi controls retained. Core tool Unknown/provenance/single-model/startup wiring unchanged.

Native4096/port8003 config/SPEC/three acceptance hashes, selected/all-case/capitalized
dry-runs and eighteen other prompt hashes pass. Initial Case10 prompt exactly matches
retry11. Mismatched/unreported relay deadline rejects before inference; requested1200s
exceeding provider1194s rejects. Model slots idle throughout guards.

Fresh relayPID23732/port8003 reports4096/1194s/upstream8000/content_loggingfalse; prior
relays33028/8001 and20516/8002 untouched. New helperSHAA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7;
harnessSHA08C69DB214804E0B892345D8E43094E19C5748F87508090D0348F750272FF234.
Runtime source2c8ee6b/debug7C18C860 unchanged, prior Rust/startup checks applicable.
Fresh same-guidance/model/window3/cap24/4096/6x1200s/grace6 screen12 pending; common relay
deadline1194 is an intentional control change. Fresh Pi conditional on acceptance.
No configured/causal/full-public-task win yet; broad project gates and Case10 active.

### Retry12 aligned relay/provider deadline screen: launched

Run: bench-20261005-case10-separator-window3-budget4096-relay1194-low-retry12-rupi24-screen6-1200s.
Harness/relay source4025535abb9885b2818b0d51ef781ab789a7c702; harnessSHA08C69DB2...FF234/
relayA0BCAE68...387C7; runtime source2c8ee6b/debug7C18C860...80E46 unchanged.
Exec49566/runner26544/wrapper25564/model27356/new relay23732/port8003.
Configured4096/low/native replay/recurring-window3/cap24/six1200s/grace6/output16384/
provider1194000ms fixed. Intentional transport changes: new route and health-verified
response deadline1194s (previous source cap650s). Shared initial prompt hashes match
retry11 exactly (B888E63C...7F7D6). Configured caps do not prove actual reasoning length.
No source/binary/helper changes, builds or parallel inference during the screen.

Prior relays33028/8001 and20516/8002 remain untouched. Fetch/prune shows only main and
active Case10 local/remote branches, fully pushed. Fresh Pi conditional on Rupi acceptance
with the same new relay/guidance/common settings; Pi native request/progress caps unavailable.
Outcome pending, no comparative/causal/full-public-task claim. Broader gates and Case10 active.

Retry12 Rupi turn1 reaches watchdog1,200,202ms unresolved:41,780 recorded work
(20,564 input+21,216 output), twelve starts/eleven completions/usage records.
Fourteen tool requests/seven completed/seven failed/zero Unknown; first tool read.
Project-test command1/all four help0/oracle1, no verification timeout.
App-init108/main55,762 listed; tests/README absent in filtered metadata, contents unread.
Failed tool counts do not establish the particular failure cause; presence/size does not
prove completeness, bounded edits or assertion preservation. Unfinished inference unknown.

Saved prompts/controls/SPEC/three acceptance hashes pass; per-turn relay deadline1194
and health1194 explicitly match. Debug7C18C860/model27356/relay23732 unchanged.
No causal improvement inferred from first-turn recorded usage vs retry11's unrecorded
transport failure. Turn2 active with frozen4096/window3/cap24/1194s relay profile;
Pi not run, no acceptance/comparative win.

Source-only follow-up lead during frozen retry12: Get-RecoveryPrompt's Case07 branch
(bench/compare-pi-rupi.ps1 around1800) supplies explicit known-edit-failure reconciliation:
observed file text/native schema, unique anchors without line/truncation markers, preserve
already-applied changes, and inspect/defer Unknown mutations. Case10's early-return prompt
does not include these explicit instructions. Retry12 first-turn failed-tool count7 does
not establish which failures occurred or their cause. Consider shared static reconciliation
guidance for both agents after terminal results if unresolved, without reading/generated
diagnostics, altering tools or adding core workflow policy. No live-source/guidance change.

Retry12 Rupi turn2 exits0/runtime completed at779,954ms unresolved:49,018 recorded work
(39,657 input+9,361 output), eighteen starts/nineteen completions including an earlier
abandoned request/eighteen usage records. Seventeen requested/completed tools/zero failed/
Unknown; first tool grep. Project-test command1/all four help0/oracle1, no verification
timeout. README6,279/tests-init60/public-test7,756 newly listed/main55,854 differs;
app-init108 size matches without proving unchanged content. Contents unread; file presence/
completed tools do not prove requirements, coverage or assertion preservation.
Cumulative work90,798/authoring1,980,156ms/24 completed tools/seven failed/zero Unknown;
unfinished inference unknown. All saved prompt/control/SPEC/acceptance hashes, requested/
health deadline1194 and debug/model/relay audits pass. Turn3 active with frozen settings;
Pi not run, no acceptance/comparative win or causal claim.

Retry12 Rupi turn3 exits0/budget_exhausted at1,140,915ms unresolved:70,046 recorded
work (54,494 input+15,552 output), twenty-four starts/completions/usage records.
Twenty-four tool requests/nineteen completed/five failed/zero Unknown; first tool read.
Project-test command1/all four help0/oracle1, no verification timeout. Public-test17,470
differs; main55,854/README6,279/app-init108/tests-init60 sizes match without proving unchanged
content. Generated contents unread; growth does not prove coverage or assertion preservation.
Cumulative work160,844/authoring3,121,071ms/43 completed tools/twelve failed/zero Unknown.
Saved prompt/control/SPEC/acceptance hashes, requested/health deadline1194 and debug/model/
relay audits pass. Turn4 active with frozen settings; Pi not run, no win or causal claim.

Retry12 Rupi turn4 exits0/runtime completed at842,141ms unresolved:43,377 recorded
work (33,545 input+9,832 output), nine starts/completions/usage records.
Eight requested/completed tools/zero failed/Unknown; first tool grep.
Project-test command1/all four help0/oracle1, no verification timeout. Public-test17,923
differs; main55,854/README6,279/app-init108/tests-init60 sizes match without proving unchanged
content. Generated contents unread; file size and completed edits do not prove assertion
preservation or public completeness. Cumulative work204,221/authoring3,963,212ms/51 completed
tools/twelve failed/zero Unknown. All prompt/control/SPEC/acceptance hashes, requested/
health1194s and debug/model/relay audits pass. Turn5 active with frozen settings;
Pi not run, no acceptance/comparative win or causal claim.

Retry12 Rupi turn5 exits0/runtime completed at287,807ms unresolved:27,651 recorded
work (25,175 input+2,476 output), five starts/completions/usage records.
Four requested/completed tools/zero failed/Unknown (read, grep, read, edit).
Project-test command1/all four help0/oracle1, no verification timeout. Main56,086 differs;
README6,279/app-init108/tests-init60/public-test17,923 sizes match without proving unchanged
content. Generated contents unread; successful edit/completion does not prove correctness.
Cumulative work231,872/authoring4,251,019ms/55 completed tools/twelve failed/zero Unknown.
Saved prompt/control/SPEC/acceptance hashes, requested/health1194s and debug/model/relay
audits pass. Final turn6 active with frozen settings; Pi not run, no win or causal claim.

### Retry12 terminal evidence and bounded file-tool guidance slice

Retry12 turn6 exits0/runtime completed at376,206ms unresolved:23,521 recorded work
(19,227 input+4,294 output), five starts/completions/usage records.
Four requested/completed tools/zero failed/Unknown (grep, read, grep, edit).
Project-test command1/all four help0/oracle1, no verification timeout. Main56,422 differs;
README6,279/app-init108/tests-init60/public-test17,923 sizes match without proving unchanged
content. Generated contents unread.

All six attempts fail project tests/acceptance; all help passes. Total255,393 recorded
work/4,627,225ms/59 completed tools/twelve failed/zero Unknown. One watchdog, four runtime
completions, one request-budget exhaustion. Unrecorded unfinished inference unknown.
Exec49566 exits0; slots idle. All six saved prompts/controls/SPEC/three acceptance hashes,
requested/health1194s and debug7C18C860/model27356/relay23732 audits pass.
Pi not run, no configured/comparative/causal/full-public-task win.

Next bounded candidate: shared static file-tool reconciliation guidance in Get-Case10Prompt,
following already-established Case07 instructions. Require actual diagnostics, observed
current text/native schema, unique anchors without line/truncation markers, preservation
of already-applied changes and inspection/deferment for Unknown mutations. Failed-tool
counts identify no specific cause. No parent inspection of generated source/diagnostics/
traces, new tools, acceptance edits or core workflow policy. Preserve all other prompts,
current CLI/helper binary/source and existing4096/window3/cap24/relay1194/6x1200s controls.
Prompt/reference/config/dry-run guards precede fresh retry13 and conditional matched Pi.
Case10 and broad project gates remain active. Parent usage26%five-hour/53%weekly.

### Retry13 bounded static file-tool reconciliation guidance

Retry12 is a terminal Rupi-only failed screen: all six acceptance and project-test
attempts fail, all four help paths pass, with 255,393 recorded work tokens,
59 completed tools, 12 failed tools and zero recorded Unknown outcomes.
Failed-tool types and causes are unproven; model traces and generated contents remain unread.

The existing Case07 static reconciliation guidance is now supplied in every Case10
initial/recovery variant for both agents. Attempted edits are not completed changes;
explicit no-change failures use bounded current-file reads and observed unique anchors,
already-applied changes are preserved, and Unknown mutations require state reconciliation
before retry. Public-contract repairs continue within remaining requests.
No diagnostic parser, tool/controller, first-write enforcement or core semantics change.

Selected/all-case/capitalized-mode dry-run checks pass, including all five Case10 variants.
Native configuration and copied public SPEC/three acceptance file hashes pass.
All 18 non-Case10 initial/recovery prompt hashes remain unchanged.
Separate parent invariant review finds no blocking issue: unknown mutation replay remains
prohibited, provenance and startup boundaries are unchanged, and acceptance stays private.
Prior Rust/startup and seven relay tests apply to unchanged runtime/helper source.

Fresh retry13 retains low/configured4096, relay23732/8003/deadline1194s,
provider1194s, outer1200s/grace6, recurring/window3/cap24, maxoutput16384,
six attempts and the existing Qwen process/CLI binary. New shared static guidance is
the intended prompt change. Fresh matched Pi0.86.1 is conditional on Rupi acceptance.
Case10 and broader project gates remain active; failed screens are not wins.

### Retry13 launched and frozen controls audited

Run: `bench-20261005-case10-reconcile-window3-budget4096-relay1194-low-retry13-rupi24-screen6-1200s`.
Harness source cd104b0d85aca458fa9c4ff20ea10631d109ba94;
working harness SHA256 A53782C719CB602F49E7EF61FC507C9D0DADD67E181BC4899FA1FFF421574FB6.
Initial shared user prompt SHA256
230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270.
Removing only the inserted reconciliation block matches retry12's prompt byte-for-byte;
newline-normalized comparison also passes. Runtime source2c8ee6b/debug7C18C860,
relay sourceA0BCAE68/process23732/8003 and Qwen process27356 remain unchanged.
Health confirms configured4096, response1194s, upstream8000/v1, content logging false.
Model was idle before launch; runner5504 began Rupi attempt1 with child21032.
All public SPEC/acceptance contents remain inaccessible to benchmark agents except public SPEC.

Fetch/prune confirms only main and active Case10 actual local/remote branches.
Historical artifact worktrees stay detached; active PR145 is retained.
Unrelated root usage-policy edit SHA2563CEE11E5 remains preserved.
Latest parent quota check29% five-hour/54% weekly, below root95%/99% thresholds.
No acceptance or token-efficiency improvement is claimed before terminal evidence.

### Retry13 attempt1 checkpoint

Attempt1 runtime reports failed timeout after943,755ms; outer watchdog did not fire.
Recorded work8,882 (input7,105/output1,777), four model starts/completions but
three usage records; unfinished/unrecorded inference is unknown.
Four completed file tools were grep, grep, read, grep; no recorded failed/Unknown tools.
This does not prove compliance with the first-write instruction.
Project tests, all four help checks and acceptance fail (exit1); no verification timeout.
Filtered application/test/README file metadata is empty; this alone does not establish
a whole-workspace-empty claim. Generated contents and diagnostics remain unread.

Saved prompt/full-SPEC/control/reference audits pass; binary7C18C860, model27356,
relay23732/8003/configured4096/deadline1194s remain unchanged.
Runtime completion and prompt presence are not acceptance or model compliance.
Screen continues to attempt2; Pi is not run before Rupi acceptance.

### Retry13 attempt2 checkpoint

Runtime completed714,010ms with33,211 recorded work (input22,154/output11,057),
nine model starts/completions/usage records and nine completed file tools:
write/read/grep/read/edit/read/edit/edit/read; zero recorded failed/Unknown tools.
Project tests and acceptance fail (exit1), all four help paths pass, no verification timeout.
Filtered generated metadata lists receiptledger/__main__.py21,659bytes only.
Tool completion and file size do not establish implementation or assertion correctness.
Cumulative42,093 recorded work/1,657,765ms/13 completed tools, no acceptance resolution.
Prompt/full-SPEC/native-control/reference/binary/model/relay/deadline audits pass.
Attempt3 continues; Pi remains conditional on Rupi acceptance. Generated contents unread.

### Retry13 attempt3 checkpoint

Outer watchdog fired after1,200,273ms. Recorded work83,826 (input70,301/output13,525),
23 model starts/22 completions/22 usage records; unfinished inference unknown.
25 tool requests/24 completed/one failed/zero recorded Unknown; first tool grep.
Generated metadata shows main35,419bytes, tests/__init__.py75bytes and
tests/test_receiptledger.py11,692bytes; application/test contents remain unread.
Project tests and acceptance fail (exit1), all four help paths pass, no verification timeout.
Neither tool completion nor file metadata establishes correctness or assertion preservation.
Cumulative125,919 recorded work/2,858,038ms/37 completed/one failed/zero Unknown.
All saved full-SPEC/prompt/control/reference/binary/model/relay/deadline audits pass.
Attempt4 continues; no Rupi acceptance resolution and no Pi half.

### Retry13 attempt4 checkpoint

Outer watchdog fired after1,200,226ms. Recorded work69,672 (input52,810/output16,862),
22 model starts/completions but21 usage records; unrecorded inference unknown.
21 requested tools/20 completed/one failed/zero recorded Unknown; first tool write.
Metadata: main35,419bytes, tests/__init__.py75bytes, public test24,548bytes.
Same file size does not prove unchanged content; generated contents remain unread.
Project tests/acceptance fail (exit1), all four help paths pass, no verification timeout.
Cumulative195,591 recorded work/4,058,264ms/57 completed/two failed/zero Unknown.
All full-SPEC/prompt/native-control/reference/binary/model/relay/deadline audits pass.
Attempt5 continues; neither acceptance resolution nor a paired result exists.

### Retry13 attempt5 checkpoint

Outer watchdog fired after1,200,246ms. Recorded work50,662 (input38,566/output12,096),
16 model starts/completions but15 usage records; unrecorded inference unknown.
17 requested/completed file tools, zero failed/recorded Unknown; first tool read.
Generated metadata: main36,419bytes, tests/__init__.py75bytes, public test25,135bytes.
Project tests/acceptance fail (exit1), all four help paths pass, no verification timeout.
Contents unread; no assertion/correctness claims follow from successful tools/file metadata.
Cumulative246,253 recorded work/5,258,510ms/74 completed/two failed/zero Unknown.
Full-SPEC/prompt/control/reference/binary/model/relay/deadline audits all pass.
Attempt6 is the final screen attempt; no acceptance resolution or Pi half exists.

### Retry13 terminal failed screen and bounded retry14 profile

Rupi-only retry13 terminates exit0 with all six acceptance attempts failing.
Attempts1–5 project tests fail; attempt6 project tests time out after180,146ms
(exit unavailable/null). Attempt6 acceptance fails exit1 in2,205ms without timeout,
all four help paths pass, outer watchdog1,200,270ms, recorded work53,918
(input35,302/output18,616), 11 model starts/completions but10 usage records.
Unrecorded inference unknown. Ten completed tools/zero failed/recorded Unknown.
Final filtered metadata: main36,419bytes, tests init75bytes/public test33,276bytes;
contents unread; README/application init absent from filtered records.

Terminal totals300,171 recorded work/6,458,780ms/84 completed tools/two failed/
zero recorded Unknown; four outer watchdogs, one completed runtime, one runtime timeout.
Compared failed screens are not controlled causal evidence; fewer recorded failures
do not establish reconciliation effectiveness. No acceptance win or Pi half exists.
All six prompt/full-SPEC/control/reference/binary/model/relay/deadline audits pass;
server slots0–3 are idle. Sources and binary unchanged, no rebuild during inference.

The next bounded candidate is existing native thinking-off (reasoning_effort:none),
direct8000, no configured relay budget/deadline (metadata null). Cases04/06 have
recorded configured acceptance wins using off; benefit for Case10 remains unproven.
The low-effort relay rejects non-low requests, so off must use the existing direct route.
This profile intentionally changes thinking and bypasses budget injection/relay;
it is not a single-variable or causal comparison with retry13.
Shared prompt, binary/model, recurring/window3/cap24, maxoutput16384, six1200s,
provider1194s/grace6 and verification policy remain fixed for fresh retry14.
Fresh matched Pi0.86.1 remains conditional on Rupi acceptance.

Parent quota1% five-hour/55% weekly, below root95%/99%; reset18:44ET/Oct11 05:45ET.
Case10, paired handoff/exact-head CI and broader project gates remain active.

### Retry14 native-off launch audit

Run: `bench-20261005-case10-reconcile-window3-native-off-retry14-rupi24-screen6-1200s`, runner22328/session63020.
Initial shared prompt230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270
is byte-identical to retry13. Harness sourcecd104b0/harnessSHA A53782C7 and
runtime source2c8ee6b/debugSHA7C18C860 remain unchanged.
Thinking off maps to reasoning_effort:none for both agents; direct8000 uses the same
Qwen3.8 process27356, checked idle before launch. Configured reasoning budget and
relay deadline are unavailable/null; no relay injection/forwarding is used.
Rupi config verifies recurring/window3/cap24/native four filetools/provider1194000ms;
maxoutput16384, six1200s/grace6 remain fixed. Pi native cap/progress unavailable/null.
Selected/all-case off dry-runs, native config/SPEC/three acceptance hashes pass,
all18 other-prompt hashes unchanged; no inference during guards/no new source change.
Parent invariant review has no blocker: existing native thinking-off path,
single model, unchanged permissions/Unknown semantics/provenance/startup.
Existing Rust/startup/helper checks apply to unchanged source.

Fetch/prune again confirms main plus activeCase10 local/remote heads only.
Unrelated root policy SHA3CEE11E5 preserved. All prior relays left intact and unused.
Pi0.86.1 conditional on Rupi acceptance with the same frozen native-off profile.
No win, default benefit or causal comparison claimed.

### Retry14 attempt1 checkpoint

Runtime reports semantic failure after811,437ms; outer watchdog false.
Recorded work23,118 (input6,514/output16,604), two model starts/completions/usage records,
two completed grep calls, no recorded failed/Unknown file tools.
Project tests, all four help paths and acceptance fail exit1, no verification timeout.
Filtered generated metadata empty; no whole-workspace-empty or actual semantic-cause claim.
Large aggregate output alone does not prove a per-request output ceiling was reached,
nor identify a malformed/truncated response. Model output and diagnostics remain unread.
Native-off/full-SPEC/prompt/control/reference/binary/model audits pass.
Attempt2 continues. No acceptance win or Pi half exists.

### Retry14 attempt2 checkpoint

Runtime semantic failure after825,963ms; outer watchdog false.
One model start/completion/usage record with22,246 recorded work
(input5,862/output16,384), zero requested/completed/failed/Unknown file tools.
The single recorded output count equals the configured16,384 output ceiling.
This is a bounded candidate for investigating output capacity, not proof of the
semantic cause, finish reason, response contents or an actual attempted mutation.
Project tests/all four help/acceptance fail exit1; no verification timeout.
Filtered generated metadata empty; contents and diagnostics remain unread.
Cumulative45,364 recorded work/1,637,400ms/two completed tools, no resolution.
All native-off/prompt/full-SPEC/control/reference/binary/model audits pass.
Attempt3 continues; no Pi half exists.

### Retry14 early stopped; three verified failures, incomplete fourth attempt

Attempt3 repeats attempt2: one model start/completion/usage record, semantic runtime
failure873,450ms, work22,246(input5,862/output16,384), zero requested/completed tools.
Tests/all four help/acceptance fail exit1, no verification timeout. Single recorded
response again equals configured16,384 output ceiling. Contents/finish reason unread.
Three verified attempts total67,610 recorded work/2,510,850ms/two completed grep calls/
zero failed or recorded Unknown, all acceptance/project/help fail. Audits pass.

To avoid repeating the same bounded failure pattern, parent stops only owned runner
22328 and its exact child34460 after checking process names/parent IDs/creation timestamps.
Runner session exits-1; attempt4 is abandoned/unverified and its inference work unknown.
This is an incomplete/early-stopped six-attempt screen, not failed6, a win, or a Pi pair.
Artifacts retained; server27356 and all three relays33028/20516/23732 preserved;
all four model slots idle after stop.

Owned runtime source confirms output-limit finish reasons length/max_tokens classify
as semantic (crates/rupi-runtime/src/turn.rs completion_failure), and incomplete tool
calls are not dispatched. Existing native tests assert this contract.
It supports an output-capacity candidate but does not prove these actual finish reasons.
Core truncation/replay/Unknown/provenance/failover semantics must remain unchanged.

Next bounded retry15 will introduce a shared Case10 output-limit control default16,384,
select32,768 for both agents, and outer1800s/provider1794s/grace6 to allow the larger
response. Initial prompt/native-off/model/binary/window3/cap24/six attempts unchanged.
Output allowance and deadline intentionally change together; no causal single-variable
claim. Guards must verify default/selected/Pi config, metadata, invalid limits and
unchanged other-case prompts before fresh Rupi screen; Pi conditional on acceptance.

### Shared Case10 output-limit control verified before retry15

New Case10MaxOutputTokens range1–65,536 defaults16,384; selected32,768.
The same helper sets Rupi endpoint capability and Pi model maxTokens.
Per-turn configured_max_output_tokens records the Case10 request; aggregate records
case10_max_output_tokens. These are configuration claims, not observed finish reasons.
Other cases retain16,384 and their18 prompt hashes; Case10 prompt230589C5 unchanged.

Dry-run now materializes owned native Rupi/Pi configs and compares effective output limits,
catching an explicit endpoint override that would mask the selected capability.
Selected32,768/default16,384/valid boundary1/65,536/capitalized recurring checks pass;
invalid0/65,537 rejected before inference. Fresh selected native config verifies
off/direct8000/window3/cap24/provider1794000/maxoutput32768 and copied full SPEC/
three acceptance hashes. All five Case10 prompt variants/oracle sentinel pass.
Ignored guard workspaces contain copied reference/config artifacts only; no model run.

Parent separate invariant review has no blocker: matched agent output allowances,
default/other-case isolation, no dispatch of incomplete tools, no blind replay,
single Qwen activation and unchanged native exposure/provenance/startup.
No Rust/helper source changed; prior required Rust/startup and seven relay tests apply.
Output allowance32,768 and outer1800/provider1794/grace6 intentionally change together
for retry15. Shared prompt/native-off/binary/model/window3/cap24/six attempts stay fixed.
Fresh Rupi first; Pi0.86.1 conditional on acceptance. Case10 remains unresolved.

### Retry15 launch audit: matched larger output and time allowances

Run: `bench-20261005-case10-reconcile-window3-native-off-output32768-retry15-rupi24-screen6-1800s`, runner37024/session54471.
Harness source9d0de2a9169dd9d16dfbce4be37e1ad542a535ac,
SHA256D4CA3482643AD1B56628533427D2552BA0D028AD447FA162FDBD6DE8DB5E2BB3.
Initial shared prompt230589C5 is byte-identical to retry14.
Native Rupi config verifies off/direct8000/output32,768/provider1794000ms,
recurring/window3/cap24; six attempts/outer1800s/grace6.
No relay budget/deadline injection; summary fields should be null when unavailable.
Qwen27356/debug7C18C860/runtime2c8ee6b/helperA0BCAE68 unchanged.
Four slots idle before launch, prior relays left intact. No rebuild during screen.

Fetch/prune actual branches remain main plus activeCase10 local/remote.
Root policy SHA3CEE11E5 preserved. Latest parent usage9% five-hour/56% weekly.
Initial prompt equality/config/reference guards and parent invariant review pass.
Larger output/time are intentional; no causal or acceptance win claimed.
Fresh Pi0.86.1 uses the same frozen output/native-off/time/prompt/model controls
only after Rupi acceptance; its cap/progress fields remain unavailable/null.

### Retry15 terminal failed screen; bounded durable-resume investigation

Runner exits0; all six acceptance/project-test/all four help checks fail exit1,
no verification timeout or outer watchdog. Attempt1 semantic failure1,643,598ms,
one model start/completion/usage record, work38,976(input6,208/output32,768),
one requested write/zero completed/one failed/zero recorded Unknown.
Observed output equals configured32,768 ceiling; actual finish reason/cause unread.

Attempts2–6 fail rapidly in2,775/2,715/2,677/2,704/2,733ms, with zero recorded
model starts/completions/usage/work/tool requests and absent runtime completion metadata.
Recorded zero is not proof of zero actual inference. Cause/type of these quick failures
remains unproven; runner/model outputs/session traces/diagnostics stay unread.
All generated filtered metadata empty; no whole-workspace or mutation-effect claim.

Terminal total38,976 recorded work/1,657,202ms/zero completed tools/one failed/
zero recorded Unknown; all six full-SPEC/prompt/native-control/output/config/reference/
binary/model audits pass. Model slots0–3 idle, source9d0de2a/harnessD4CA3482,
debug7C18C860/runtime2c8ee6b remain pinned. Pi skipped; no acceptance or token win.

The quick failures after a non-completed tool-shaped response motivate a bounded
source investigation and owned synthetic fixture for durable resume.
No actual benchmark trace, generated application or oracle diagnostics will be read.
Preserve canonical trace vs model context separation, no dispatch of incomplete calls,
explicit Unknown state, no blind replay, native reasoning provenance and single-model execution.
A synthetic reproduction must establish any actual runtime bug before implementation;
otherwise no speculative core change. Broader and Case10 gates remain active.

### Owned synthetic durable-resume bug reproduced and fixed

Source investigation uses no model-generated files/traces or oracle diagnostics.
A synthetic full-ceiling response contains partial text plus a decoded mutating call,
then finishes length. Closing/reopening fails with:
canonical model_request_completed event has no semantic projection; resume requires recovery.
This reproduces for a small16-byte call as well as testing a large200,000-byte argument.
The failure is owned fixture evidence; causality for actual retry15 remains unproven.

Recovery already intentionally excludes length/max_tokens output from model projection,
but validate_projection_alignment demanded it whenever the response had assistant deltas.
The minimal store guard now treats these completions like other trace-only failures.
Canonical lifecycle/payload/sequence checks, completed-response projection joins, Unknown
reconciliation, no mutation dispatch/replay, failover and model activation remain unchanged.

Runtime fixture verifies both length/max_tokens and small/large argument sizes:
semantic failure retained, one request only, no mutation dispatch, close/reopen/restore
succeeds, no interrupted/uncertain tools, no partial assistant/tool history, fresh resumed
request completes, and mutation is never replayed. Negative store fixture checks stop and
tool_calls completions still fail closed when semantic projection is missing.
Both targeted native tests pass; the runtime fixture failed before the store fix.
ARCHITECTURE/CHANGELOG/ROADMAP now reflect verified behavior. Parent invariant review
has no blocking finding; broad required Rust/startup/performance checks remain pending.

Next fresh retry16 retains retry15 native-off/direct8000/output32768/outer1800/provider1794/
grace6/window3/cap24/six attempts/prompt/model, with rebuilt binary containing this fix.
Its acceptance benefit is unproven; a synthetic runtime improvement is not a Case10 win.
Pi0.86.1 conditional on Rupi acceptance. All broader gates remain active.

### Durable-resume fix required checks and defined performance budgets pass

Verified production source6a2e5315847804b5826699c6e270030608c83e81:
cargo fmt --all --check; cargo check -p rupi-core --all-features;
cargo clippy --workspace --all-targets -- -D warnings;
cargo test --workspace; cargo doc --workspace --no-deps; cargo build --bin rupi.
All exit0 on the existing verified Rust/Cargo1.98.1 stable alias; repository pin unchanged.
Owned check JSON/logs .benchmark/case10-resume-checks.json and case10-resume-*.log.
Rebuilt debug SHA256B60ABB5899EE1D3CBC7FBA4F4822DB8599529AA2FA9CAABCCCC3B0A7EEB54B08.

GitBash bench/startup.sh --json bench/results/startup-ci.json passes:
cold135.258ms/warm median8.137ms/max8.917ms, budgets250/100ms.
bench/large_session.sh default50 iterations passes all defined session-log hydration budgets:
small10turns92.650us<=1000; medium100turns666.350<=4000;
large500turns2573.450<=15000; checkpoint500turns2540.750<=15000;
checkpoint1000turns4956.150<=30000. This benchmark measures session_log::restore,
not the entire canonical-validation path; no universal/full-resume latency claim.

Targeted reproduced failure and negative completed-projection fixtures pass.
Seven previously passed relay behavior tests remain applicable to unchanged helperA0BCAE68.
No render/source change requiring render benchmark. Parent separate invariant review
has no blocker; ordinary completed messages/Unknown outcomes/lifecycle/payload/sequence
validation, provenance, single model and lazy startup boundaries stay intact.
No additional build during the next screen or a paired Pi half.

Fresh retry16 will keep retry15 prompt230589C5/native-off/direct8000/output32768/
outer1800/provider1794/grace6/window3/cap24/six attempts and same model27356,
changing only the rebuilt Rupi binary to include the store resume fix.
Synthetic runtime improvement is verified; actual acceptance benefit remains unproven.

### Retry16 fixed-binary launch audit

Run: `bench-20261005-case10-reconcile-window3-native-off-output32768-retry16-rupi24-screen6-1800s`, runner5164/session59723.
Same initial shared prompt230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270
is byte-identical to retry15. Harness9d0de2a/SHA D4CA3482 and helperA0BCAE68 unchanged.
New runtime production source6a2e531/debugSHA
B60ABB5899EE1D3CBC7FBA4F4822DB8599529AA2FA9CAABCCCC3B0A7EEB54B08
contains the reproduced trace-only output-limit resume fix; CLI system copy2c8ee6b unchanged.
Native config verifies off/direct8000/output32768/provider1794000ms/window3/cap24;
six attempts/outer1800s/grace6. No configured relay budget/deadline; unavailable/null.
Model27356/aliasQwen3.8 unchanged, all slots idle before launch. Prior relays retained.
All required Rust/debug/startup/session-log restore checks completed before inference.
No builds during this screen or a paired half.

Fetch/prune confirms only main plus activeCase10 local/remote actual heads.
Root unrelated policy SHA3CEE11E5 preserved. Parent usage22% five-hour/58% weekly,
below root95%/99%; resets18:44ET/Oct11 05:45ET.
Actual retry15 cause and retry16 acceptance benefit remain unproven; synthetic fix is verified.
Fresh same-profile Pi0.86.1 remains conditional on Rupi acceptance; cap/progress unavailable.

### Retry16 attempt1 checkpoint

Outer watchdog fires1,800,211ms. Recorded work60,912(input29,499/output31,413),
five model starts/four completions/four usage records; unfinished inference unknown.
Six requested file tools/five completed/one failed/zero recorded Unknown;
tool sequence read/grep/grep/read/read/write. Individual failed-tool cause/type unproven.
Filtered metadata shows receiptledger/__main__.py59,605bytes. No contents inspected.
All four help paths pass, project tests/acceptance fail exit1, no verification timeout.
Presence/size/tool completion is not contract correctness or instruction compliance.
Same-profile outcome differs from retry15, but one stochastic screen is not causal evidence
for acceptance, token efficiency, output-limit or store-fix benefit.
Saved full-SPEC/prompt/native-output/control/config/reference/binary/model audits pass;
fixed runtime6a2e531/debugB60ABB58 and all frozen sources/settings remain pinned.
Attempt2 continues; no acceptance resolution or Pi half.

### Retry16 attempt2 checkpoint

Outer watchdog1,800,252ms, recorded work76,017(input50,892/output25,125),
13 model starts/completions but12 usage records; unrecorded inference unknown.
20 requested tools/17 completed/three failed/zero recorded Unknown; first tool grep.
Filtered metadata: README5,643bytes, main60,722bytes, tests/__init__.py82bytes;
public test-file entry absent. Generated contents remain unread.
Project tests fail exit5, all four help paths pass, acceptance fails exit1,
no verification timeout. File presence/size/known tool completion does not establish
assertion coverage, correctness or compliance with first-test-file guidance.
Cumulative136,929 recorded work/3,600,463ms/22 completed/four failed/zero Unknown.
Full-SPEC/prompt/native-output/control/config/reference/fixed-binary/model audits pass.
Attempt3 continues; no acceptance resolution or Pi half.

### Retry16 attempt3 checkpoint

Outer watchdog1,800,332ms. Recorded work80,032(input53,981/output26,051),
12 model starts/completions but11 usage records; unrecorded inference unknown.
16 requested/completed file tools, zero failed/recorded Unknown; first tool read.
Metadata now includes tests/test_receiptledger.py51,135bytes, tests init82bytes,
main60,722bytes and README5,643bytes. Same sizes do not prove unchanged contents.
Public test presence/tool success does not establish meaningful assertions or correctness.
Project tests/acceptance fail exit1; all four help paths pass, no verification timeout.
All generated contents and diagnostics remain unread.
Cumulative216,961 recorded work/5,400,795ms/38 completed/four failed/zero Unknown.
All full-SPEC/prompt/native-output/control/config/reference/binary/model audits pass.
Attempt4 continues; no acceptance resolution or Pi half.

### Retry16 attempt4 checkpoint

Runtime budget_exhausted after1,203,020ms; outer watchdog false.
Recorded work86,146(input71,439/output14,707),24 model starts/25 completions/
24 usage records. An extra completion may include prior abandoned-request closure;
unrecorded inference remains unknown, and counts do not imply concurrent models.
25 requested tools/23 completed/two failed/zero recorded Unknown; first tool grep.
Metadata: main62,774bytes, public test51,135bytes, test init82bytes, README5,643bytes.
Same sizes do not prove unchanged contents or preserved assertions; contents unread.
Project tests/acceptance fail exit1, all four help paths pass, no verification timeout.
Cumulative303,107 recorded work/6,603,815ms/61 completed/six failed/zero Unknown.
All prompt/full-SPEC/native-output/control/config/reference/fixed-binary/model audits pass.
Attempt5 continues; no acceptance resolution, causal win or Pi half.

### Retry16 attempt5 checkpoint

Runtime budget_exhausted after1,318,045ms; outer watchdog false.
Recorded work94,153(input77,280/output16,873),23 model starts/completions/usage records.
32 requested/completed tools, zero failed/recorded Unknown; first tool read.
Metadata: main62,983bytes/public test51,577bytes/test init82bytes/README4,111bytes.
Contents remain unread; file changes do not establish correct repairs or preserved assertions.
Project tests/acceptance fail exit1, all four help paths pass, no verification timeout.
Cumulative397,260 recorded work/7,921,860ms/93 completed/six failed/zero Unknown.
All saved full-SPEC/prompt/native-output/control/config/reference/fixed-binary/model audits pass.
Attempt6 is the final screen attempt; no acceptance resolution or Pi half.

### Retry16 terminal failed screen and bounded request-headroom candidate

Runner exits0; all six acceptance/project-test attempts fail (local tests5 on
attempt2,1 otherwise), all four help paths pass throughout. No verification timeout.
Attempt6 runtime completed484,620ms, work37,982(input32,986/output4,996),
12 model starts/completions/usage records,15 completed tools/zero failed/recorded Unknown.
Final metadata: main63,234bytes/public test51,577/test init82/README4,074;
application init entry absent. Contents unread; no public completeness/assertion claim.

Terminal totals435,242 recorded work/8,406,480ms/108 completed/six failed/
zero recorded Unknown; three outer watchdogs, two request-budget exhaustions,
one completed runtime. Unrecorded inference remains unknown. All six full-SPEC/prompt/
native-output/control/config/reference/fixed-binary/model audits pass; four slots idle.
Native-off/output32768/runtime6a2e531/debugB60ABB58/helper/harness/model remain fixed.
Pi skipped; no acceptance, token-efficiency, default or causal win.

Existing cap40 is the next bounded candidate. Attempts4–5 report budget_exhausted
after1,203,020/1,318,045ms under outer1800s, leaving time that additional request
headroom could use. This does not prove cap40 will improve acceptance or other attempts.
Keep recurring/window3/native-off/direct8000/output32768/outer1800/provider1794/
grace6/six attempts, prompt230589C5, binary/model/source unchanged.
The cap changes only Rupi native configuration; Pi native cap remains unavailable/null.
Initial/recovery user prompts do not interpolate this setting and must hash-match.
Dry-run/native config/reference/hash/isolation guards before fresh retry17;
same frozen Pi0.86.1 profile conditional on Rupi acceptance.

Parent usage33% five-hour/60% weekly, below root95%/99%; next reset18:44ET,
weeklyOct11 05:45ET. Case10, paired delivery/exact-head CI and broader gates stay active.

### Retry17 cap40 launch audit

Run: `bench-20261005-case10-reconcile-window3-native-off-output32768-retry17-rupi40-screen6-1800s`, runner38900/session28839.
Initial shared prompt230589C5 is byte-identical to retry16; no cap interpolation.
Native Rupi config cap40 replaces24; recurring/window3/native-off/direct8000/
output32768/provider1794000ms/six1800s/grace6 remain unchanged.
Harness9d0de2a/D4CA3482, runtime6a2e531/debugB60ABB58, helperA0BCAE68,
model27356 and all same-profile controls stay pinned; no new source or build.
Prior native/provenance/file-tool isolation controls remain intact.
Selected/all-case cap40 dry-runs, fresh native config/SPEC/three acceptance hashes,
other18 prompt hashes and initial Case10 prompt hash pass before inference.
Slots idle before launch. Pi native cap/progress remain unavailable/null,
same frozen Pi0.86.1 controls/prompt/output/time conditional on Rupi acceptance.

Fetch/prune confirms only main plus activeCase10 actual local/remote heads.
Root unrelated policy SHA3CEE11E5 preserved. No acceptance or efficiency benefit claimed;
more configured headroom is a bounded candidate, not proof of repaired public behavior.
Parent invariant review passes; required Rust/startup/restore checks apply to unchanged source.

### Retry17 attempt1: request headroom has not yet helped
The cap40, native-thinking-off, output32768 screen completed attempt1 with a
1,800,387 ms runner watchdog. Configured acceptance, project tests, and all four
help commands failed (exit1). Recorded work was18,278 tokens (16,935 uncached input,
1,343 output), with four model starts, three completions and usage records, and
six completed read/grep calls; zero failed or Unknown calls. The filtered
files inventory was empty. These metadata do not establish that the whole
workspace was empty or that unfinished inference used no tokens.
The frozen source/binary/model, prompt, reference, and native configuration audit
passed. This attempt neither reached the cap40 request limit nor demonstrated
an acceptance benefit. Remaining attempts are running; Pi remains unrun.

### Retry17 attempt2: runtime timeout with unmeasured inference
Attempt2 ended after 1,108,628 ms without a runner watchdog; the runtime
reported timeout. Configured acceptance, project tests, and all four help
commands failed (exit1). One model start and two completion events were
recorded, with no usage records or tool requests. Recorded work is zero;
actual inference work is unknown. Completion events may include closure of a
previous abandoned request. The filtered files inventory was empty.
The frozen-input audit still passes. Across two attempts the recorded totals
are18,278 work tokens, 2,909,015 ms, and six completed tools with zero failed
or Unknown tool calls. No acceptance benefit is established; Pi remains unrun.
Current PR145 CI passes on Linux, macOS, and Windows; final-head CI will be
required again before merge.

### Retry17 attempt3: application files present, acceptance still failing
Attempt3 reached the 1,800,288 ms runner watchdog. Configured acceptance and
project tests failed (exit1); all four help commands passed (exit0), with no
verification timeout. Recorded work was74,159 tokens (48,620 uncached input,
25,539 output), with eleven model starts, ten completions/usage records,
and ten completed calls: write, grep, grep, grep, write, and five edits.
No failed or Unknown tool calls were recorded.
Filtered files now include receiptledger/__init__.py (134bytes) and
receiptledger/__main__.py (55,805bytes). Contents remain unread; file presence
and successful help checks do not establish contract correctness.
The frozen-input audit passes. Three-attempt recorded totals are92,437 work
tokens, 4,709,303 ms, sixteen completed tools, and zero failed/Unknown calls.
Remaining attempts continue; Pi remains unrun and Case10 remains unresolved.

### Retry17 attempt4: help passes, test module still absent from filtered inventory
Attempt4 ended after 1,089,478 ms with runtime timeout and no runner watchdog.
Configured acceptance failed (exit1), project tests returned exit5, and all
four help commands passed (exit0); no verification timeout was recorded.
Recorded work was18,524 tokens (12,443 uncached input,6,081 output), with three
model starts, four completion events, two usage records, and four completed
calls (grep,read,write,grep). Zero failed or Unknown tool calls were recorded.
Completion events may include closure of a previous abandoned request.
The filtered files inventory contains the unchanged app init/main sizes and
tests/__init__.py (65bytes); no public test module is listed. Contents remain
unread. Frozen-input audit passes. Four-attempt recorded totals are110,961 work
tokens,5,798,781 ms,and twenty completed tools; zero failed/Unknown calls.
The remaining attempts continue. Pi remains unrun; Case10 is unresolved.

### Retry17 attempt5: watchdog with unmeasured inference
Attempt5 reached the 1,800,302 ms runner watchdog. Configured acceptance failed
(exit1), project tests returned exit5, and all four help checks passed (exit0),
with no verification timeout. One model start, no completion/usage records,
and no tool requests were recorded. Recorded work is zero; actual inference
work is unknown. The filtered three-file inventory and sizes are unchanged.
Frozen-input audit passes. Five-attempt recorded totals are110,961 work tokens,
7,599,083 ms, twenty completed tools, and zero failed/Unknown calls.
One Rupi attempt remains; Pi remains unrun and Case10 remains unresolved.

### Retry17 terminal: six failed attempts, no cap40 benefit demonstrated
Attempt6 ended at670,310 ms with runtime timeout, no runner watchdog. Configured
acceptance failed (exit1), project tests returned exit5, all help checks passed
(exit0), and no verification timeout was recorded. Work was8,202 tokens
(6,913 uncached input,1,289 output), with four starts, five completion events,
three usage records, and five completed grep calls; zero failed/Unknown calls.
Previous abandoned request closures can add completion events. The filtered
three-file inventory and sizes were unchanged. File contents remain unread.
All six acceptance checks failed. Totals:119,163 recorded work tokens,
8,269,393 ms,25 completed tools,zero failed/Unknown calls; three runner
watchdogs and three runtime timeouts. Actual unfinished inference remains
unknown, notably turns2 and5 with no usage records. The cap40 limit was not
reached; no acceptance benefit from additional request headroom is established.
Frozen prompts, full public SPEC, acceptance-reference hashes, source, B60ABB58
binary, D4CA3482 harness, native configuration, and model identity audits pass.
Pi was not run for this failed screen; this is not a paired win.
Source review also verified the distinction between the configured1,794,000 ms
total provider deadline and inherited300,000 ms idle timeout. The metadata
does not identify which timeout mechanism fired; no benchmark-output
diagnostics were read. Case10 and broad roadmap stage gates remain active.

### Retry18 pinned: bounded reasoning with larger output allowance and fixed resume
Next screen: bench-20261005-case10-reconcile-window3-budget4096-relay1194-low-output32768-retry18-rupi40-screen6-1200s.
Same model PID27356, runtime source6a2e531, B60ABB58 debug binary, harness
source9d0de2a/D4CA3482, helper A0BCAE68, shared prompt230589C5, unchanged full SPEC
and three acceptance hashes. Controls: low thinking with4,096-token budget
through existing relay23732/port8003, verified1,194-second response deadline,
provider1,194,000 ms, outer1,200 seconds/grace6, max output32,768, Rupi cap40,
recurring progress window3, up to six Rupi attempts. No source or build changes.
This combines the previously exercised bounded-reasoning profile with the
larger output allowance and verified resume fix; the outcome is unproven and
multiple controls differ from retry17, so no isolated causal benefit is claimed.
Pi0.86.1 remains conditional on Rupi acceptance and must use a fresh matched
profile with frozen source/binary/model; Pi native cap/progress stay null.
Automatic approval review rejected starting an additional relay on port8004,
with reason blocked by policy. That command did not execute. Existing model
and all relays remain untouched; using the healthy existing1194-second relay
keeps the next screen within its verified deadline.
Selected native configuration, copied public SPEC/reference hashes, initial
prompt hash,18 non-Case10 prompt hashes,and dry-run guards pass. All model
slots are idle. Parent usage8% five-hour/61% weekly is below policy thresholds;
only main and the active Case10 branch remain locally/remotely after pruning.

### Retry18 attempt1: application files and README present, acceptance failing
Attempt1 reached the1,200,237 ms runner watchdog. Configured acceptance and
project tests failed (exit1); all four help checks passed (exit0), with no
verification timeout. Recorded work was87,535 tokens (72,526 uncached input,
15,009 output), with28 model starts,27 completions/usage records,28 tool
requests,26 completed tools,two known failures,and zero Unknown calls.
Filtered file metadata lists README.md (702bytes), receiptledger/__init__.py
(331bytes), and receiptledger/__main__.py (44,080bytes); no public test module
is listed. Contents remain unread. File presence and help success do not prove
contract correctness or documentation accuracy. Frozen controls/prompt/SPEC/
reference/source/binary/model audit passes. Cap40 was not reached; unfinished
inference is unmeasured. Remaining attempts continue; Pi remains unrun.

### Retry18 attempt2: public test module present, acceptance still failing
Attempt2 reached the1,200,256 ms runner watchdog. Configured acceptance and
project tests failed (exit1); all four help checks passed (exit0), with no
verification timeout. Recorded work was80,841 tokens (68,765 uncached input,
12,076 output), with37 model starts/completion events,36 usage records,and37
completed tools; zero failed/Unknown calls. Completion counts can include the
closure of a previously abandoned request.
Filtered metadata lists README.md702bytes, app init419bytes/main44,667bytes,
app util.py0bytes, tests init0bytes, and tests/test_receiptledger.py14,250bytes.
Contents remain unread; public test file presence does not establish meaningful
assertions or preserved tests. Frozen-input audit passes. Two-attempt recorded
totals:168,376 work tokens,2,400,493 ms,63 completed tools,two known failures,
zero Unknown calls. Remaining attempts continue; Pi remains unrun.

### Retry18 attempt3: continued edits, acceptance still failing
Attempt3 reached the1,200,578 ms runner watchdog. Configured acceptance and
project tests failed (exit1); all four help checks passed (exit0), with no
verification timeout. Recorded work82,550 tokens (69,162 uncached input,
13,388 output),30 model starts/completion events,29 usage records,and42
completed tools; zero failed/Unknown calls. Previous abandoned request closure
can contribute a completion event.
Filtered metadata lists README702bytes,app init554bytes/main44,912bytes,
util224bytes,tests init0bytes,and test_receiptledger.py14,686bytes. Contents
remain unread; sizes do not verify preserved assertions or contract correctness.
Frozen-input audit passes. Three-attempt totals250,926 recorded work tokens,
3,601,071 ms,105 completed tools,two known failures,zero Unknown calls.
Remaining attempts continue; Pi remains unrun and Case10 remains unresolved.
