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

### Retry18 attempt4: watchdog and known tool failures, no acceptance
Attempt4 reached the1,200,197 ms runner watchdog. Configured acceptance and
project tests failed (exit1); all four help checks passed (exit0), with no
verification timeout. Recorded work63,885 tokens (47,267 uncached input,
16,618 output),25 model starts/completion events,24 usage records,32 tool
requests,28 completed tools,four known failures,and zero Unknown calls.
Completion counts can include prior abandoned-request closure.
Filtered metadata lists README702bytes,app init554bytes/main48,929bytes,
undo289bytes/util224bytes,tests init0bytes,and test_receiptledger.py15,462bytes.
Contents remain unread; sizes establish neither correctness nor assertions.
Frozen-input audit passes. Four-attempt totals314,811 recorded work tokens,
4,801,268 ms,133 completed tools,six known failures,zero Unknown calls.
Two attempts remain; Pi remains unrun and Case10 remains unresolved.

### Retry18 attempt5: acceptance still failing after continued repairs
Attempt5 reached the1,200,181 ms runner watchdog. Configured acceptance and
project tests failed (exit1); all four help checks passed (exit0), with no
verification timeout. Recorded work85,948 tokens (72,478 uncached input,
13,470 output),29 model starts/completion events,28 usage records,35 tool
requests,34 completed tools,one known failure,and zero Unknown calls.
Completion events may include prior abandoned-request closure.
Filtered metadata lists README702bytes,app init554bytes/main49,066bytes,
undo224bytes/util224bytes,tests init0bytes,and test_receiptledger.py19,024bytes.
Contents remain unread; sizes do not establish correctness or assertions.
Frozen-input audit passes. Five-attempt totals400,759 recorded work tokens,
6,001,449 ms,167 completed tools,seven known failures,zero Unknown calls.
The final attempt is confirmed running; Pi remains unrun and Case10 unresolved.

### Delivery policy clarified: enhancements before new retry screens
The owner clarified that rupi code/runtime may and should change: after failure,
perform root cause analysis and implement an enhancement addressing the failure.
Control-only retries require a specific evidence-based justification. This
supersedes the prior control-search workflow for new screens.
Retry18 attempt6 was already running when clarification arrived. Letting this
bounded existing attempt finish preserves terminal evidence and avoids creating
an additional abandoned inference; no new screen is authorized by elapsed time.
Next work is source/owned-fixture diagnosis before any new inference screen.
Source review found a missed-edit diagnostic candidate at
crates/rupi-tools/src/edit.rs:266: it compares a full trimmed current file line
against only20 characters of the requested first line, after an initial40-char
truncation. Long matching first lines can therefore fail to receive the intended
similar-line hint. This is source evidence, not yet a reproduced fixture or a
proven cause of any Case10 failure. Reproduce before fixing; preserve exact-match,
no-change, ambiguity refusal, and Unknown reconciliation semantics.
Future evaluation of changed code must remain frozen across the evaluated
recovery turns and fresh matched Pi half. Such recovery turns assess one candidate
rather than constitute new control-only candidate screens. Any further new
candidate must carry a verified enhancement or explicit evidence justification.

### Retry18 terminal: six acceptance failures; runtime diagnosis next
Attempt6 reached the1,200,373 ms runner watchdog. Acceptance and project tests
failed (exit1); all help checks passed (exit0), no verification timeout.
Recorded work67,647 tokens (51,838 uncached input,15,809 output),15 starts/
completion events,14 usage records,and17 completed tools; no failed/Unknown
calls. Filtered app main41,781bytes/public test19,024bytes; other inventory
sizes unchanged. Contents remain unread; correctness/assertions unverified.
All six acceptance/project-test checks failed and all help checks passed.
Totals468,406 recorded work tokens,7,201,822 ms,184 completed tools,seven
known failures,zero Unknown calls; six runner watchdogs. Unfinished inference
remains unknown. No request-cap exhaustion was recorded. Frozen inputs,
native profile, full SPEC/three reference hashes, source/bin/model audits pass.
Pi was not run; this is not a paired win. Model slots are now idle and runner
4512/children have exited. Usage18% five-hour/63% weekly is below thresholds.
Failure analysis: this profile has working help paths but no configured
acceptance or passing public project tests. More cap headroom alone is unsupported;
known failed file-tool operations and many reads/edits indicate a recovery path
worth investigating, without proving the underlying task defect. No model code,
actual trace, or oracle diagnostics were inspected.
Before new inference, reproduce and repair the source-observed long-line edit
diagnostic defect using an owned fixture; verify no mutation on rejected edits,
honest location hints, and unchanged Unknown/ambiguity semantics. Required Rust
checks/startup verification and a new frozen binary are prerequisites.
A subsequent fixed-code screen should retain retry18 profile/prompt/references
to assess the enhancement; no control-only candidate is planned.

### Verified enhancement: missed-edit hints for complete long first lines
An owned synthetic fixture against the old edit implementation failed (exit101):
the file had the requested long function-signature line at line2, but the
missed-edit diagnostic supplied no location. Root cause is the full-current-line
versus truncated20-character requested-head comparison in edit_failure_text.
The fix compares complete trimmed first lines, skips empty heads, and supplies a
bounded re-read location. Prefix-only matches do not claim that line exists.
No approximate replacement is applied. Exact matching, unique-match refusal,
replace_all, effect/state classification, and interrupted-call reconciliation
are unchanged; their stable reconciliation identity remains valid.
The module contract now describes execution refusal and separate reconciliation
truthfully, replacing an inaccurate claim that normal execution says already
applied. ARCHITECTURE/CHANGELOG/ROADMAP reflect verified behavior and active gates.
Owned tests cover stale body text and whitespace mismatch with a long first line:
failure remains Failed/None, original bytes unchanged, no file-content dump,
and a corrected exact edit succeeds. A distinct same-prefix line gets no location
claim. All82 unit and31 integration tool tests pass, including existing ambiguity,
double-application, cancellation, and uncertain-edit reconciliation coverage.
Required fmt/core check/workspace Clippy/workspace tests/docs/debug build pass;
final formatted test-source Clippy/tools also pass. Startup verification is
running. Debug binary C58EF706433D326FD47317A33612726EA6AC6DD0DBE0D46E3B56C8BECADF6BBE.
Separate parent invariant review passes; no independent child review is claimed.
This repairs a verified generic failed-edit diagnostic defect. Its contribution
to the Case10 failures and its acceptance benefit remain unproven. A new screen
requires startup completion and frozen source/binary/profile preflight.

### Enhancement verification complete; same-profile evaluation prerequisites
The required fmt/core all-features check/workspace Clippy/tests/docs/debug build
all pass for the missed-edit enhancement (runtime source 9ac88a7). Final Clippy
and all 113 tool tests also pass after formatting the new fixture source.
Startup passes: cold 139.493 ms; warm median 8.018 ms, mean 8.207 ms,
maximum 9.2 ms over ten iterations, within 250/100 ms budgets.
Debug SHA256 C58EF706433D326FD47317A33612726EA6AC6DD0DBE0D46E3B56C8BECADF6BBE.
The store and resume implementation are unchanged from the separately verified
6a2e531 fix; its five session-log restore budgets remain applicable, without a
claim about full canonical-validation latency. Rendering is unchanged.
Next evaluation must use retry18 profile, unchanged shared prompt/harness/helper/
SPEC/references/model, and this frozen runtime source and binary. The changed
code addresses a reproduced failed-edit recovery defect; acceptance benefit
remains unproven. No source changes or builds during its recovery turns or a
fresh matched Pi half. Pi remains conditional on Rupi acceptance.

### Retry19 pinned: evaluate verified edit recovery with retry18 controls
Run bench-20261005-case10-edit-hint-window3-budget4096-relay1194-low-output32768-retry19-rupi40-screen6-1200s.
Runtime source 9ac88a7290e7b2286d8e2427b4d41e2654ce2fbf; fixed debug binary
C58EF706433D326FD47317A33612726EA6AC6DD0DBE0D46E3B56C8BECADF6BBE.
This candidate follows reproduced failed-edit diagnostic analysis, a production
fix, passing required checks/startup, and separate parent invariant review.
Controls match retry18: low thinking/budget 4,096 via relay 23732/8003,
response deadline 1,194 s, provider 1,194,000 ms, outer 1,200 s/grace 6,
output 32,768, Rupi cap 40, recurring window 3, up to six recovery turns.
No prompt or harness/helper change: shared prompt 230589C5, harness D4CA3482
(source 9d0de2a), helper A0BCAE68, full SPEC and three reference hashes unchanged,
all 18 other-case prompt hashes unchanged. Same model PID 27356/alias
qwen3.8-flash-next. Selected native-config/reference/prompt guards pass.
Six recovery turns evaluate this one changed implementation and must keep it
frozen to support a fair first-acceptance-turn comparison. They do not constitute
new control-only candidates. If the screen fails, analyze its evidence and implement
another justified enhancement before a new screen; no unchanged-code retry planned.
Fresh Pi 0.86.1 is conditional on Rupi acceptance and uses a matched profile.
Pi native cap/progress remain unavailable/null. No source changes or builds
during this evaluation or its Pi half. Acceptance benefit and causality remain
unproven. Branches remain main plus active Case10; root policy edit SHA preserved.

### Retry19 stopped after first failure; diagnosis before another attempt
Attempt1 reached the 1,200,549 ms watchdog. Acceptance/project tests failed
(exit1); all help checks passed (exit0), no verification timeout. Work 70,702
recorded tokens (54,148 uncached input/16,554 output), 16 model starts,
15 completions/usage records, 18 completed tools, zero failed/Unknown calls.
Tool names show 15 read/grep calls and three write/edit calls. Filtered inventory
contains app init31bytes/main48,614bytes; no tests or README listed. Contents
remain unread. Frozen source 9ac88a7/binary C58EF706/profile/prompt/SPEC/reference/
model audit passes. This turn does not establish a benefit from the hint fix;
no failed tool operation was recorded and whether the fix was exercised is unknown.
Following the owner's stronger updated objective, automatic continuation was
stopped for diagnosis before another attempt. Owned runner26760 (pwsh,parent25564,
created2026-10-05T23:02:33.8817080-04:00) and already-started child27000
(rupi,parent26760,created2026-10-05T23:22:40.1254040-04:00) were revalidated by PID,
name,parent,and creation timestamp before stopping. Session exit-1; model27356
and all three existing relays preserved; all model slots idle.
Attempt2 is abandoned/unverified and its work is unknown. This screen is incomplete,
not six failed attempts and not a paired win. Pi remains unrun.
Further development will diagnose this watchdog/inspection-heavy failure and
apply a verified runtime enhancement before any new attempt. Development screens
must avoid automatic continuation that bypasses this analysis; a frozen fresh
paired verification must still support any eventual win claim.

### Retry19 root-cause boundary and verified turn-time enhancement

The failed first turn used16 of40 requests but reached the1,200s watchdog,
with15 inspection tools out of18 completions and no listed tests/README.
This verifies a budget-observability gap; it does not identify the task's semantic
defect or establish an edit-hint acceptance benefit. Its already-started second
turn was stopped and remains abandoned/unverified. Automatic retries are disabled
during development; each failed one-turn screen requires analysis and a verified
enhancement before another attempt.

The opt-in `limits.max_turn_duration_ms` is now implemented (default omitted,
valid1..86,400,000ms). Each turn receives a fresh monotonic child-token deadline.
Every provider attempt receives canonical, projected `TurnTimeBudget` guidance.
Expiry cancels cooperatively without cancelling the caller/siblings and reports
`TimeBudgetExhausted`. Unknown/Possible mutations retain `NeedsReconciliation`;
explicit caller cancellation keeps its existing classification. Foreign operations
may overrun if they do not cooperate. No partial calls are dispatched or replayed,
no usage is fabricated, and no recovery inference starts after expiry.

Core token/config fixtures, all177 runtime tests, native HTTP deadline/no-repost
fixture, and required fmt/core-all-features-check/workspace-Clippy/workspace-tests/
docs/debug-build pass. Durable close/reopen/resume preserves the runtime control,
excludes partial assistant text, retains honest no-effect refusals, and never replays
the mutation. The default plain-answer fixture confirms no added control guidance.
A separate parent invariant review passes; no independent model review is claimed.

Startup is140.781ms cold/8.047ms warm median/8.771ms warm maximum, within250/100ms.
Rendering medians3.78/3.74/3.22us and command parsing0.28us pass all four budgets.
All five session-log restore cases pass (94.65..4,909.45us); complete canonical
validation latency is not measured by that benchmark. All five context-experiment
budgets also pass. Own logs use `.benchmark/case10-turn-time-*`.

Harness dry-run/config guards pass for an explicit1,170,000ms native Rupi budget
below the1,200s watchdog; Pi control metadata is unavailable/null. All18 other-case
prompt hashes and three acceptance reference hashes remain unchanged. No model
inference occurred during implementation. Only main and the active Case10 branch
remain locally/remotely; the root user's usage-policy modification is preserved.
A fresh pinned one-turn screen is pending. Case10 acceptance benefit, paired win,
and final delivery checks remain unproven; broader roadmap gates remain active.

### Retry20 frozen one-turn development screen

Run `bench-20261006-case10-turn-time1170-window3-budget4096-low-output32768-retry20-rupi40-screen1-1200s` will screen one fresh Rupi turn only. Source/runtime/harness
commitc7b7ed6 contains the verified cooperative time-budget enhancement.
DebugSHA256 `75985E95D0FE8873D8CC44D2B6F219954F955ECC66EA67E42D881D6409C01470`;
harnessSHA256 `C916C9555D374447E9844BD2BEEE5A4A41A3BF31917E9F038BA8602EDE00A374`;
unchanged relay helperA0BCAE68, process23732/port8003, budget4096/deadline1194s.
Model27356/8000 remains the same qwen3.8-flash-next instance; all four slots idle.

Selected controls: low, output32,768, Rupi cap40, recurring progress window3,
provider1194s/outer1200s/grace6, native Rupi turn budget1,170,000ms.
Pi native duration/cap/progress unavailable/null. Shared full-public-SPEC prompt
remainsSHA230589C5; no acceptance assertions, model solution, actual traces,
or oracle diagnostics are read. Three acceptance references and18 other-case
prompt hashes remain unchanged. No builds/source changes during inference.
Fresh matched Pi0.86.1 follows only passing Rupi acceptance. Failed screening
requires root-cause analysis and a verified enhancement before another attempt.
A one-turn failed screen is not a six-turn or paired result. Case10 remains active.

### Retry20 terminal failed one-turn screen

Frozen sourcec7b7ed6/debug75985E95/harnessC916C955/helperA0BCAE68/model27356
and selected native controls/prompt/SPEC/three acceptance reference hashes pass
terminal audit. The runner exits0 and all four model slots are idle; Pi was not run.

One turn:905,693ms, no watchdog,36,161 recorded work (21,940 uncached input/
14,221 output),17 started/completed requests and17 usage records. Twenty tools
complete with zero known failures/Unknown:15 inspections (12grep/threeread) and
five mutations (twowrite/threeedit). Runtime status is `completed`; acceptance
and project tests exit1, all four help checks exit0, no verification timeout.
Filtered inventory lists only app init444bytes/main48,441bytes; no tests/README
are listed. Contents remain unread. This is one failed development turn, not
a paired result or acceptance benefit. Deadline expiry was not exercised.

The screen stopped roughly264s before its native time budget and used17 of40
requests. Verified source closes an ordinary text-only answer immediately, without
a deliverable review. An opt-in bounded same-model completion review is the next
generic runtime enhancement, preserving budgets/provenance/Unknown barriers and
avoiding case-specific artifact enforcement. It must be implemented and verified
before any new benchmark attempt; no control-only retry is launched.

CIcf244735 passes macOS/Linux but fails the new durable deadline fixture on
Windows (zero refusal records where one was expected). The150ms whole-turn budget
can expire before the intended streaming point during slow admission; reproduce
that valid no-request path with owned delayed progress, then make the fixture
establish its provider-start precondition. No unchanged CI rerun is launched.
Usage18% five-hour/68% weekly is below the root policy's95/99% thresholds.

### Windows deadline-fixture precondition correction and next plan

An owned delayed-admission fixture now verifies valid `TimeBudgetExhausted`
before any provider request or refusal, reproducing the failure shape seen in CI.
The durable active-stream fixture no longer assumes admission fits150ms: it allows2s
and explicitly asserts one provider request. Its bounded provider guard is5s; resumed
admission also has2s. Four deadline fixtures, fmt, and workspace Clippy pass locally.
This changes test preconditions, not production behavior; Windows CI verification is
pending. No unchanged benchmark/CI retry is launched.

The next runtime enhancement is specified in
[completion-review plan](../development/completion-review.md): opt-in bounded
same-model review at the first otherwise accepted ordinary text-only completion,
with canonical runtime provenance, normal budgets/admission, one-shot/fresh-turn
state, and unchanged Unknown barriers. It does not enforce case artifact names or
certify external task correctness. Implementation and verification precede any new
benchmark screen. Retry20 inspection-name breakdown is corrected to12grep/three
read, still15 inspections/20 completed tools.

### Verified bounded completion-review enhancement

After Retry20's premature closure, optional `limits.review_completion` now
records one canonical/projected `CompletionReview` after the first otherwise accepted
ordinary answer. The same active model may check requested deliverables and continue
authorized work. Native assistant evidence remains distinct. Default false is omitted
from serialized configuration; no case-specific artifact enforcement or external
correctness certification is added.

Review is at most once per turn and resets on new turns/resume. Normal request/tool/
time budgets, progress rejection, approval, exact admission and Unknown/Possible
barriers remain authoritative. Reserved no-tools finalization cannot perform repairs
or convert exhaustion into completion. Explicit recovery assessment skips ordinary
review. No timer/service or model orchestration is introduced.

Six owned runtime fixtures verify permitted repair, fresh/one-shot review, request caps,
no-tools assessment, durable native/control provenance, deadline cancellation without
partial mutation dispatch or fabricated usage, Unknown barriers, and progress before
review. The progress fixture initially lacked independent Changed effect evidence;
its rejection confirmed existing safety semantics. Correcting the owned fixture to
provide Changed evidence passes without weakening production admission.
All184 runtime tests pass. Config omission/round-trip passes. Required fmt/core
all-features check/workspace Clippy/workspace tests/docs/debug build pass; final fmt,
runtime suite/Clippy/debug build pass after the additional progress fixture.

Startup157.257ms cold/9.995ms warm median/10.650ms max passes250/100ms budgets.
All five session-log restore budgets pass (99.70..4,680.45us), as do all five context
experiments; complete canonical validation latency is not measured. Rendering is
unchanged from the previous four passing measurements. Parent invariant review passes;
no independent model review is claimed. All18 other-case prompt hashes, public SPEC
and three acceptance reference hashes remain unchanged. Native config/dry-run guards
enable review only for the next Case10 screen and record Pi parity as unavailable/null.

Windows deadline-fixture correction commit7717655 passes all three exact-head CI
platforms in run37413256929. New completion-review source CI remains pending.
The final debugSHA is
`A615D45AA0D89F9C7A92268D59F3A9A71D998121107E1CE43A6B0ADFD3220B1A`.
A new frozen one-turn screen is pending; no Case10 acceptance benefit or win is claimed.

### Retry21 frozen one-turn completion-review screen

Run `bench-20261006-case10-completion-review-turn1170-window3-budget4096-low-output32768-retry21-rupi40-screen1-1200s` will use verified source/runtime/harness4626e31.
DebugSHA256 `A615D45AA0D89F9C7A92268D59F3A9A71D998121107E1CE43A6B0ADFD3220B1A`;
harnessSHA256 `573124D0541B5D53370A1CEAFADC5A3C3E9A9F9E7CC74DF06B666702F9E4ED35`.
Explicit native Rupi completion review is enabled after Retry20's verified closure gap.
Other controls remain low/budget4096/relay8003+1194s/output32,768/cap40/window3,
native turn1170s/provider1194s/outer1200s/grace6. Pi duration/review/cap/progress
parity remains unavailable/null. Shared public prompt230589C5, acceptance3hashes,
helperA0BCAE68, and model27356 remain fixed.

One fresh Rupi turn only; no automatic retries, builds, or source changes during
inference. A failure requires analysis and a verified enhancement before another
attempt. Fresh matched Pi0.86.1 follows only Rupi acceptance. Native controls are
not external correctness certification. No Case10 win or acceptance benefit is
claimed. New exact-head CI and paired/final delivery checks remain pending.

### Retry21 terminal failed one-turn screen

Frozen4626e31/debugA615D45A/harness573124D0/helperA0BCAE68/model27356
audits pass, including native review=true/time1170s/cap40/window3, shared prompt,
SPEC and three acceptance reference hashes. Exact frozen head6663145 passes all
three CI platforms (run37414082403). Runner exits0; all model slots are idle.
Pi was not run.

One turn:1,170,385ms, no outer watchdog,49,474 recorded work (29,821 uncached
input/19,653 output),14 started/completed requests but13 usage records. Unfinished
inference work remains unknown. Runtime status is `time_budget_exhausted`, not
successful task completion. Sixteen completed tools have zero known failures/Unknown:
11 inspections (sixgrep/fiveread), five mutations (onewrite/fouredits).
Acceptance and project tests exit1, all four help checks exit0, no verification
timeout. Filtered inventory lists main43,193bytes only; no init/tests/README listed.
Contents remain unread. No acceptance benefit, causal result, or paired win claimed.

Cooperative deadline closure is observed; review activation is not captured in current
per-turn metadata. Source verifies that completion review can trigger only after an
otherwise accepted text-only answer. The next generic enhancement allows an explicit
remaining-time reserve to trigger one review before the next provider attempt during
a continuing tool loop, while preserving normal budgets/admission/Unknown barriers.
Canonical runtime-control counts will be exposed as safe metadata, without control
text, model outputs, generated code, or oracle diagnostics. Implementation, fixtures,
checks and invariant review precede any new screen; no unchanged/control-only retry.

### Proactive-review plan before another attempt

[Proactive completion-review plan](../development/proactive-completion-review.md)
adds an optional validated remaining-time reserve, using the existing one-shot
review/provenance and normal budgets. Safe canonical control-count metadata will
measure activation on future screens; Retry21 activation remains unmeasured and
actual trace contents are not inspected. Selected future reserve300,000ms sits
inside native1,170,000ms; no code/control retry before implementation/checks/review.
Usage37% five-hour/71% weekly remains below the root95/99% soft-stop thresholds.

### Verified proactive completion-review reserve

Optional `limits.completion_review_reserve_ms` now requires enabled review and
a positive reserve below the configured turn duration. When time is short during
continuing work, it injects the existing one-shot CompletionReview before the next
ordinary provider attempt. An earlier first-answer review consumes the same allowance;
new turns/resume renew it. Defaults remain omitted/disabled. Cancellation, normal
request/tool/time budgets, approval, progress and Unknown/Possible barriers remain intact.

Owned fixtures cross the reserve after a known tool outcome, verify proactive review,
prevent a second trigger after earlier review, renew on another turn, and block inference
after Unknown mutation. Config omission/round-trip and inactive/no-time/zero/equal/
oversized rejection pass. All186 runtime tests and130 core tests pass in workspace
verification. Required fmt/core all-features check/Clippy/workspace tests/docs/debug
build pass; final fmt/docs/debug rebuild after contract-comment correction pass.

Benchmark summaries now count whitelist canonical control kinds, with unknown-kind
count and native Pi unavailable/null. Counts measure injected controls, not proof of
model use. `bench/test-runtime-control-metrics.ps1` verifies counts, SkipLines turn
scope, content exclusion, and no invented requests/usage using owned synthetic records.
No actual trace, model output, generated source, or oracle diagnostic contents are read.
All18 other-case prompt hashes and three acceptance reference hashes are unchanged;
native config/dry-run and invalid-reserve guards pass. The first owned invalid-guard
invocation omitted outer1200s and correctly failed the existing watchdog guard; correcting
that test input verifies the intended inactive/equal-reserve guard without inference.

Startup144.344ms cold/9.194ms warm median/9.727ms max passes250/100ms. Five
session-log restore budgets pass (98.95..4,821.50us), not complete canonical-validation
latency; all five context-experiment budgets pass. Rendering is unchanged from the
previous four passing measurements. Parent invariant review passes, with no independent
model review claimed. DebugSHA256
`C8511B7C9E1509CBEEDAE1FD91CCD787875D3469EB51939C840F0C81518A2751`;
harnessSHA256
`B4FC326E5EBC3CDBEC8A5F9718FC8DB5E04324AA48B1AD75B96F0DB00EE4269D`.
New source CI and a fresh one-turn reserve300,000ms/turn1,170,000ms screen are
pending. Failure still requires analysis and a verified enhancement before another
attempt. Case10 acceptance benefit and paired win remain unproven.

### Retry22 frozen proactive-review screen

Run `bench-20261006-case10-proactive-review300-turn1170-window3-budget4096-low-output32768-retry22-rupi40-screen1-1200s` will screen one fresh turn against verified412cf58.
DebugC8511B7C/harnessB4FC326E (full SHA256 values in the previous verification entry),
helperA0BCAE68 and model27356 unchanged. Explicit review=true/reserve300,000ms
is selected inside native turn1,170,000ms. Other controls stay low/budget4096/
relay8003+1194s/output32,768/cap40/window3/provider1194s/outer1200s/grace6.
Native Pi duration/review/reserve/cap/progress/control-count parity is unavailable/null.
Shared prompt230589C5, public SPEC and three acceptance reference hashes stay fixed.

One fresh Rupi turn only; no automatic retries or source changes/builds during inference.
Control-count metadata measures injection, not proof of model use. Failure requires
analysis and a verified enhancement before another attempt. Fresh matched Pi0.86.1
follows only Rupi acceptance; no Case10 acceptance benefit/win is claimed. New exact-head
CI and paired/final delivery checks remain required.

### Retry22: proactive review injected; one-turn screen still fails

- Run: `bench-20261006-case10-proactive-review300-turn1170-window3-budget4096-low-output32768-retry22-rupi40-screen1-1200s`.
  Frozen runtime/source `412cf58abb269f8c74ce1f53303530ed2d26f734`, checkout
  `5f869592ad32d2c8ac0abad2525f2ca1d666f953`; binary SHA256
  `C8511B7C9E1509CBEEDAE1FD91CCD787875D3469EB51939C840F0C81518A2751`;
  harness `B4FC326E5EBC3CDBEC8A5F9718FC8DB5E04324AA48B1AD75B96F0DB00EE4269D`.
- Same local model PID27356, low thinking/budget4096, output32768, relay8003/1194s,
  request cap40/window3, native turn1,170,000ms, review enabled/reserve300,000ms,
  outer1200s/grace6s. One fresh Rupi turn; no Pi run and no paired win.
- Terminal `time_budget_exhausted` after1,170,377ms; no outer watchdog.
  Acceptance exit1, project tests exit5, all four help checks exit1, no verification timeout.
  Recorded work43,628 (uncached input21,431/output22,197), eight request starts/closed
  requests/seven usage records. Unfinished inference work remains unknown.
- Eight completed tools, zero known failures/Unknown: five inspections (four read/one
  grep), three writes. Filtered inventory lists `receiptledger/__init__.py`40,595bytes
  and empty `tests/__init__.py`; no __main__.py, public test module, or README listed.
  Generated contents, model outputs/traces, and oracle diagnostics remain unread.
- Whitelist control telemetry records eight turn-time guides, one completion review,
  one progress boundary, zero progress corrections/finalization/unknown kinds.
  This proves injection, not model use or semantic correctness. The deadline and
  missing delivery metadata are observed; no application semantic root cause is inferred.
- Frozen binary/source/harness/helper, prompt/control, full SPEC, and three acceptance
  hashes passed before any source edits/builds. Runner exited0; all four model slots
  idle. Exact frozen head passed Linux/macOS/Windows CI:
  https://github.com/SaehwanPark/rupi/actions/runs/37417024915 .
- Failure analysis and a verified code/runtime enhancement are required before the next
  single-turn screen. No unchanged retry is authorized by this result.

### Anticipatory review scheduling verified before Retry23

- Source analysis after Retry22 identifies a generic timing limitation: the reserve
  check considers only current remaining time. Another slow provider/tool cycle can
  spend the desired reserve before the next check. This source gap is distinct from
  the unobserved application semantic cause; Retry22 proves review injection only,
  not its timing/model use or a causal explanation of acceptance failure.
- Plan: `docs/development/anticipatory-completion-review.md` (commit00042d8).
  The ordinary loop now uses the preceding cycle's observed elapsed duration to
  anticipate crossing the reserve with saturating arithmetic. First cycle uses zero;
  fresh turn resets the observation. It triggers the existing one-shot control through
  the same model, budgets, admission/cancellation and Unknown barriers. No new config,
  timer, event kind, artifact enforcement, partial dispatch, or replay is introduced.
  Unconfigured/default turns do not take an extra observation clock.
- Owned slow/fast/fresh-turn runtime fixture fails before (exit101,
  `.benchmark/anticipatory-review-before.log`) and passes after. It verifies that
  slow-cycle review arrives while actual remaining time is above the literal reserve,
  fast work retains first-answer review, and each fresh turn resets timing/one-shot state.
  The estimate cannot guarantee future latency or extend a deadline.
- Safe harness metrics add `completion_review_after_started_requests`: counts of
  started requests at injection, scoped by SkipLines; native Pi null. Synthetic fixture
  verifies positions1,2 and scoped1, counts/unknown kind, no control/model content,
  and no invented usage. No actual old trace is parsed retrospectively.
- Required fmt, core-all-features check, workspace Clippy/tests/docs/debug build pass:
  all187 runtime/130 core tests. A final public-field doc correction is followed by
  fmt/docs/debug rebuild; it changes no runtime semantics. Parent invariant review
  passes; no independent model review is claimed.
- Startup134.972ms cold/7.863ms warm median/9.147ms max meets250/100ms.
  All five session-log restore budgets pass (92.10/594.50/2,562.00/2,449.40/4,652.60us);
  this does not measure full canonical validation. All five context-experiment budgets
  pass (0.40/0.10/0/0/0.30us). Rendering remains unchanged from the four passing
  time-budget measurements.
- Selected native profile/SPEC/three acceptance hashes pass; shared Case10 initial
  prompt230589C5 and18 other-case initial/recovery prompt hashes remain unchanged.
  Frozen candidate debug SHA256
  `E435AB3BD081BD660108C078BDE3415DD9F84929A89EAD5A82DA5FBA30399D24`;
  harness `ABC12977210CA2D8D565F4F70ED66EDCE2C9D20641DE72EA99F213A87463243A`;
  helperA0BCAE68 and model27356/relay23732 remain unchanged. Root user policy edit
  hash3CEE11E5 remains preserved; no acceptance fixtures/generated solution are modified.
- Next screen is one fresh Rupi turn with the same Retry22 selected profile. Freeze
  and exact-head CI precede final delivery; fresh matched Pi follows only Rupi acceptance.
  No semantic/acceptance/causal/default/token benefit or paired Case10 win is established.
  Broad project gates remain active.

### Retry23 frozen profile: anticipatory review

- Planned run: `bench-20261006-case10-anticipatory-review300-turn1170-window3-budget4096-low-output32768-retry23-rupi40-screen1-1200s`; source/runtime
  `a938b6ceb5450934d8a5f1a51282a79041312992`. Debug SHA256
  `E435AB3BD081BD660108C078BDE3415DD9F84929A89EAD5A82DA5FBA30399D24`,
  harness `ABC12977210CA2D8D565F4F70ED66EDCE2C9D20641DE72EA99F213A87463243A`,
  unchanged helperA0BCAE68/model27356/relay23732.
- Same selected Retry22 profile: low/budget4096/output32768, relay8003/deadline1194s,
  cap40/window3, native turn1,170,000ms/review=true/reserve300,000ms,
  outer1200s/grace6s. Shared prompt230589C5/full SPEC/three acceptance hashes unchanged.
  Native Pi controls and control-count/position metadata remain unavailable/null.
- One fresh Rupi development turn; no builds or source changes during inference.
  Terminal frozen audits and idle model slots precede changes. Failure requires
  analysis and a verified enhancement before any new attempt. Fresh matched Pi0.86.1
  follows only Rupi acceptance. No result, paired win, or acceptance benefit exists yet.
- Main plus active Case10 are the only actual local/remote branches after fetch/prune.
  Active PR145 is retained; historical detached artifacts and root user policy edit
  remain preserved. Required local checks/performance and parent review pass;
  new exact-head CI and eventual paired delivery evidence remain pending.

### Retry23: early review injected; public tests still absent

- Run: `bench-20261006-case10-anticipatory-review300-turn1170-window3-budget4096-low-output32768-retry23-rupi40-screen1-1200s`.
  Runtime/source `a938b6ceb5450934d8a5f1a51282a79041312992`, frozen checkout
  `896d565bc18f054e748005e4d30e56d58b966603`; debugE435AB3B/harnessABC12977,
  unchanged helperA0/model27356/relay23732. Same selected Retry22 profile.
- One fresh Rupi turn ends `time_budget_exhausted` after1,170,426ms without an
  outer watchdog. Acceptance exit1, project tests exit1, all four help checks exit0;
  no verification timeout. No Pi run or paired win.
- Recorded work53,909 (uncached input35,771/output18,138),13 starts/closed requests/
  12 usage records; unfinished inference work remains unknown.15 tool requests:
  seven grep/five read/three write;12 tools complete, three known failures, zero Unknown.
  Failure-to-tool mapping and semantic cause are unmeasured.
- Filtered filename/size metadata lists README7,565bytes,
  `receiptledger/__init__.py`86bytes and `receiptledger/__main__.py`37,852bytes;
  no public tests listed. The requested application path is __main__.py, not main.py.
  An initial commentary incorrectly called it main.py; corrected after reading the
  own shared prompt. The application was delivered at its requested path and help passes;
  the observed delivery omission is public tests. Generated contents, model outputs/
  actual traces/control text, and oracle diagnostics remain unread.
- Safe telemetry records13 turn-time guides, one completion review after three started
  requests, two progress boundaries, zero correction/finalization/unknown kinds.
  This proves early injection, not trigger cause, model use, or semantic correctness.
  The timing estimate's owned correctness is established; acceptance benefit is not.
- Frozen source/binary/harness/helper, prompt/control/SPEC/three acceptance hashes pass
  before source changes/builds. Runner exits0; all four model slots idle. Exact frozen
  head passes Linux/macOS/Windows:
  https://github.com/SaehwanPark/rupi/actions/runs/37419673142 .
- Analysis must address remaining requested delivery before another attempt. The
  twenty-minute screen reaches its deadline with13/40 requests started; unused request
  allowance cannot supply more wall time. No unchanged retry or paired win is claimed.

### Optional initial progress boundary verified; Retry24 freeze

- Plan `docs/development/initial-progress-boundary.md`, commitbab7525. Retry23's
  first three tool calls are inspections despite a supplied-context first-write request;
  requested public tests remain absent at native expiry. Source starts the progress
  boundary inactive. The enhancement permits an explicitly selected initial boundary,
  independent of the unobserved application semantic/failure-mapping causes.
- Add default-false/omitted `limits.initial_progress_boundary`, requiring a configured
  progress window, TurnLoop builder and CLI wiring. After admission/reconciliation and
  cancellation/current approval checks, activate the existing eligible-progress-tool
  boundary before the first ordinary request. Confirmed Changed evidence releases it;
  no-effect success does not. Fresh turns renew it, explicit no-tools assessment skips
  it, and default/no-limit builder behavior remains unchanged. Initial control wording
  states selection honestly instead of claiming an inspection budget was spent.
- Owned first-request/fresh-turn fixture fails before (Auto vs Required, exit101)
  and passes after. Seven runtime fixtures cover narrowing/release/renewal, no-effect,
  Unknown/no replay, unavailable/denied/unsupported tools, zero mutation capacity,
  cancellation precedence, default/no-limit/no-tools, interactive approval, and durable
  initial-control provenance. Core omission/round-trip/missing-policy rejection passes.
- Required fmt/core-all-features check/workspace Clippy/tests/docs/debug build pass:
  all194 runtime/131 core tests. Parent invariant review passes; no independent model
  review claimed. No new event kind, model, timer, task classifier, artifact enforcement,
  permission bypass, incomplete dispatch, replay, or fabricated usage.
- Startup140.454ms cold/8.051ms warm median/8.608ms max meets250/100ms. Five session-log
  restore budgets pass (74.80/576.75/2,575.65/2,409.00/4,706.25us), without measuring full
  canonical validation; five context budgets pass (0.30/0.10/0/0/0.30us). Rendering
  remains unchanged from four passing time-budget measurements.
- Harness adds selected initial-boundary native config and Rupi boolean/Pi null metadata.
  Selected profile dryrun/config, full SPEC/three acceptance hashes, safe control
  metrics fixture and unchanged shared Case10 prompt230589C5/18 other-case hashes pass.
  No acceptance fixtures, generated solution, actual trace/model output or oracle
  diagnostics are inspected or modified.
- Planned run `bench-20261006-case10-initial-progress-review300-turn2370-window3-budget4096-low-output32768-retry24-rupi40-screen1-2400s`.
  Debug SHA256 `5C330350E6776B6083D9DE695B05712F95D178A7F5462DC582BAACDBFEC18045`;
  harness `65FE78FCD77C6F14306E45879A43B943DE86EB850C35197CE3DD1376E7F777A8`;
  helperA0BCAE68, original model27356 and existing relay23732 remain unchanged.
- Select initial boundary=true, native duration2,370,000ms, review=true/reserve300,000ms,
  cap40/window3, same low/budget4096/output32768/relay8003 response1194s. Matched outer
  2400s/grace6s gives provider timeout2,394,000ms; each relay response still has1194s.
  The larger whole-turn grant addresses repeated wall-time expiry with unused request
  allowance; it is not a semantic fix. Any outcome is configured, not causal attribution.
  Native Pi duration/review/reserve/initial/cap/progress/count/position parity is null.
- One fresh Rupi turn, then terminal frozen audits and idle slots before changes.
  No source/build changes during inference. A failure requires analysis and a verified
  enhancement before another attempt. Fresh matched Pi0.86.1 follows only Rupi acceptance.
  No result/acceptance benefit/paired win exists yet; exact new head CI and eventual
  paired delivery remain pending. Root user policy edit hash3CEE11E5 is preserved.

### Retry24: initial writes and tests delivered; completed turn still fails

- Run: `bench-20261006-case10-initial-progress-review300-turn2370-window3-budget4096-low-output32768-retry24-rupi40-screen1-2400s`; frozen source/checkout
  `057e827643361f39fedbd954554bbae8a909fc86`, debug5C330350/harness65FE78FC,
  unchanged helperA0/model27356/relay23732. Initial=true/native2370s/review=true/
  reserve300s, cap40/window3/low4096/output32768, outer2400s/provider2394s,
  existing relay response1194s. One fresh Rupi turn; no Pi run or paired win.
- Terminal `completed` after2,134,228ms; no native expiry/outer watchdog.
  Acceptance exit1, project tests exit1, all four help checks exit0, no verification timeout.
  Recorded work134,740 (uncached input106,797/output27,943);37 starts/closed requests/
  usage records. Forty-request allowance and2,370s native duration remain authoritative.
- Forty-eight tools complete with zero known failures/Unknown: four write/ten edit/
  eighteen read/sixteen grep. The first three tools are writes. This observes alignment
  with the requested initial action; it does not isolate a causal performance benefit.
- Filtered inventory lists requested `receiptledger/__main__.py`42,215bytes,
  empty `receiptledger/__init__.py`, `tests/test_receiptledger.py`8,966bytes and
  empty `tests/__init__.py`; no README. Presence is not contract correctness.
  Generated contents, actual traces/model output/control text and oracle diagnostics
  remain unread. The public-test semantic failure cause remains unmeasured.
- Safe telemetry:37 time guides, one review after six started requests, eight progress
  boundaries, zero correction/finalization/unknown kinds. Injection does not prove model
  use or correctness. Generic review does not supply independent public-check feedback.
- Frozen source/binary/harness/helper, prompt/controls/SPEC/three acceptance hashes pass
  before edits/builds. Runner exits0; all four model slots idle. Exact frozen head
  passes Linux/macOS/Windows CI:
  https://github.com/SaehwanPark/rupi/actions/runs/37422823363 .
- New investigation: the harness supplies permitted project-test/help feedback only
  after the turn closes; file-tool success and generic self-review cannot establish
  application correctness. Investigate a bounded delegated completion-check interface,
  with domain verification outside core, explicit caller authority, canonical provenance,
  isolated/owned verification effects, cancellation/budget/Unknown safety, unchanged
  model file-tool restrictions and hidden/immutable acceptance oracle. This is a source
  integration gap, not a diagnosed application defect. No implementation is selected yet.
- Parent usage check:92% of five-hour window/80% weekly. The repository soft stops are
  95%/99%; substantial new interface work cannot fit the remaining headroom. Preserve
  this failure/design handoff remotely, wait for04:48ET reset plus two-minute grace,
  then resume investigation with fresh headroom. Goal remains active; no new screen
  before analysis and a verified enhancement.

### Verified delegated completion feedback before Retry25

Retry24's observed closure gap is addressed by core59994fe, CLI6bceb14, host e658c7a
and cleanup02ecdf9c40a54fa66096197f6735f78dbac44d1d. Core receives typed caller
observations at otherwise accepted ordinary completions; failed observations permit
bounded same-model repair, unavailable observations end semantic failure without
retry/failover, and exhausted check allowance is explicit. Unknown mutation and
cancellation/deadline barriers retain precedence. Static runtime control and external
feedback use distinct durable provenance; no Rust command execution was added.

The owned regression failed before the gate and passes after a Changed repair and later
pass. Required Rust checks pass (203 runtime/132 core tests), alongside CLI protocol,
preflight/no-provider-request and real-binary/fake-provider fixtures. Host public-only
snapshot, required artifacts, nonzero tests, public diagnostics, private exclusion,
stale identity, once-only handling, actual command timeout and live callback fixtures
pass. Summary metadata/content exclusion passes. A PowerShell GetNewClosure function-
scope failure was fixed before model use. Parent invariant review passes; no independent
review agent was used. Outside search is rejected to protect the mailbox from grep.
Host observations reserve12s for existing process cleanup/publication. Caller permissions
are trusted; snapshot copying and file-tool protection do not constitute an OS sandbox.

Performance passes: startup135.965ms cold/7.923ms warm median/8.823ms max; render
3.467/3.638/3.177us, parse0.300us; five restores71.45–4697.55us and five context
0.4/0.1/0/0/0.3us within budgets. Shared Case10 prompt SHA
`230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270`,
18 other prompt hashes, full public SPEC and three immutable acceptance hashes are
unchanged. Profile checks/dryrun pass. Native Pi completion controls remain null.
Source6bceb14 CI passes all three platforms; exact later-head CI is still required.
Only main plus the active Case10 branch remain locally/remotely; root policy SHA is
preserved. Latest direct usage is23% five-hour/84% weekly, below95%/99% soft stops.

Next frozen one-turn screen:
`bench-20261006-case10-feedback8-initial-progress-review300-turn2370-window3-budget4096-low-output32768-retry25-rupi40-screen1-2400s`.
Reuse Retry24's model27356/relay23732:8003, low4096 reasoning/output32768,
outer2400/native2370s, provider2394s/relay1194s, cap40/window3/initial progress,
review/reserve300s; add caller checks8. Debug SHA
`3CE72B74D00322E3E0D263D657094DEEF107DED74625007E97EA078DB28D57B5`, harness
`B9568A1A8C548F994BA66169E05D1099AEC65759C8DA1C62EDE80DD7F271B241`, public-host module
`699C871BE5AA9F141363ECC628AF7CE93A241097EFC9F587E01BE494A613AF69`; relay helper A0BCAE68 is unchanged.
No attempt is yet claimed. No generated content or oracle diagnostics were inspected;
semantic application cause, acceptance benefit, isolated causality and Case10 paired
win remain unestablished. Fresh matched Pi follows only Rupi acceptance.

### Retry25 terminal: mutation allowance stops before completion observations

Frozen run `bench-20261006-case10-feedback8-initial-progress-review300-turn2370-window3-budget4096-low-output32768-retry25-rupi40-screen1-2400s` at checkout
fea3ca896228959f0e130e9219f1ef05be965130/runtime02ecdf9 ends at2,017,297ms,
ToolBudgetExhausted, without outer expiry. Independent acceptance1/project tests1;
all four help exits0, no verification timeouts. Recorded work109,397
(input79,265/output30,132),29 started/29 closed requests/29 usage records.
There are38 requested tools,36 complete,2 known failures and0 Unknown:
1write/15edit/14read/8grep. Only `receiptledger/__main__.py` is listed,48,883bytes;
requested init/test/README artifacts are absent. Generated contents and private
diagnostics remain unread; the two known failure meanings are unmeasured.

Selected checks8 have zero recorded observations/controls: no eligible text-only
candidate reached checking. Safe counts are29 time guides,5 progress boundaries,
zero review/correction/finalization controls. Thus this run supplies no empirical
evidence that delegated feedback helps acceptance. Frozen source/binary/harness/host/
helper, model/prompt/control/SPEC/three-reference audits pass before changes; all
model slots are idle. Frozen fea3ca8 CI passes all three platforms:
https://github.com/SaehwanPark/rupi/actions/runs/37444149563 .
Runner30848/child5856 ended; screen process exits0. No Pi pair or Case10 win exists.

Root-cause evidence: the native config omits tool budgets and inherits64 total/
16 mutating calls. All16 mutating requests consume allowance even when a call fails.
The38 total calls and29 requests are below their64/40 caps, and352.703s native time
remains at closure. Source stops an unsatisfied recurring progress boundary once no
mutation allowance remains; missing artifacts cannot be repaired or checked then.
This is a configured resource barrier, not evidence of an incorrect safety guard.
Next enhancement: explicit bounded Case10 mutation headroom, with defaults and total/
request/time/check safety caps preserved, proved using owned delivery/check fixtures.
Do not retry until that code/config enhancement is implemented and verified.

### Verified explicit mutation headroom before Retry26

Source369c65b0b5b7fc26f49be763b6dde1e6b99c88f1 adds bounded Case10 mutation
selection using the existing runtime limit. Zero/default omits selection; positive1..64
must fit the effective total cap. Native Pi selection is null; general16-mutation/
64-total defaults and other case profiles remain unchanged. No safety guard is bypassed,
no allowance silently renewed, no new tool/event/command/relay/model introduced.

Owned runtime fixture proves the barrier:16 mutations plus3 reads spend19 requests
and stop before later delivery/checking under16; under32,17 mutations/3 reads use21
requests then reach a passing caller check on the same model. Baseline never executes
an excess mutation. Harness fixtures pass default omission, selected32/upper64,
lower-total rejection, case isolation and Pi null. Required Rust checks/debug pass
(204 runtime/132 core tests). Startup141.739ms cold/8.160ms median/8.733ms max passes;
production rendering/session/context behavior is unchanged and prior passing budgets
are retained. Shared Case10 prompt,18 other prompt hashes, full public SPEC/three
reference hashes, selected profile and dryrun pass. Parent invariant review passes;
no independent review agent was used. Exact-head CI remains required.

Next screen `bench-20261006-case10-mutations32-feedback8-review300-turn2370-window3-budget4096-low-output32768-retry26-rupi40-screen1-2400s` selects32 mutations plus checks8.
All remaining Retry25 controls/model/prompt stay unchanged, one development turn,
outer2400/native2370s, cap40/window3/initial progress, review/reserve300s,
low4096/output32768, original model27356 and relay23732:8003 at1194s.
Debug SHA `B246CD1510FB3638319947169599B2C19C260B878F941F4DC2C597885D5E3516`,
harness `8E0D729DA86FC934FB67F8F3D0B8C1B2EEF4595534917B4B4B593F0EDFF40715`; public-host699C871B/helperA0BCAE68 unchanged.
Latest usage46% five-hour/88% weekly is below95%/99% soft stops.
No new attempt or semantic application fix is claimed yet; no generated contents/
private diagnostics were inspected. Acceptance benefit/Case10 paired win remain
unestablished. Fresh matched Pi follows only Rupi acceptance.

### Retry26 terminal: first transport failure before tool dispatch

Frozen run `bench-20261006-case10-mutations32-feedback8-review300-turn2370-window3-budget4096-low-output32768-retry26-rupi40-screen1-2400s` at checkout
f1f4c8d2ae998612e6c8ca656d786947e3d3ef36/runtime369c65b ends at1,196,199ms,
Failed(Transport), without outer watchdog expiry. One request starts/closes, zero usage
records, zero requested/completed/failed/Unknown tools, no generated files listed.
Recorded work is0 because usage is absent; actual unfinished work is unknown, not zero.
Acceptance/tests/four help exits are1; no verification timeout. Checks8 and mutation32
were selected, but no candidate reached completion checking. Safe controls are one
time guide/one initial progress boundary, zero review/check/other controls.

All frozen source/binary/harness/host/helper, model/control/prompt/full SPEC/three-
reference audits pass before changes; all four model slots are idle. Runner28864/
child35232 end, screen process exit0. Frozen f1f4c8d passes all three platforms:
https://github.com/SaehwanPark/rupi/actions/runs/37449315815 .
No Pi comparison or Case10 win exists. Generated/model/control/diagnostic contents
remain unread; output size and exact transport defect are unmeasured.

Root-cause inference is bounded:1,196.199s closely matches the existing relay's hard
1,194s response window. Source relays one upstream stream and closes at that deadline
without retry; native2370s/provider2394s budgets are longer. This is consistent with
first-response transport expiry, not demonstrated mutation-headroom efficacy or a
proved output-size defect. A completed mutation never arrived. The original model and
all existing relays remain preserved; previously rejected relay restart/extra-port
actions will not be retried or circumvented.

Next runtime enhancement: opt-in bounded first-response output for an initial progress
turn, with explicit small coherent first-change guidance. Preserve later endpoint
ceiling, ordinary defaults, context admission, complete-response-only tool dispatch,
native/control provenance, caps/cancel/Unknown and no replay of the failed request.
Use owned before/after request-budget fixtures and incomplete-response guards before
another screen. No latency or acceptance benefit is yet established.

### Retry27 runtime enhancement and frozen screen

Source c97d652223963fc92c53e35cfec333367e42d5f0 adds optional initial progress output
bounding. An owned before fixture fails with first32768 instead of8192; after passes.
Five runtime fixtures prove first8192/later32768, renewal, endpoint/context clamping,
disabled/no-limit/no-tools paths, no-effect non-renewal and incomplete-call no-dispatch/
no-replay. Config omission/range/dependency/round-trip and real CLI provider-wire pass.
The CLI fixture initially retained its separate endpoint1024 override; correcting the
owned fixture's endpoint ceiling proves the intended composition without a runtime retry.

Required fmt/core-all-features/clippy/workspace tests/docs/debug checks pass, including
209 runtime/133 core tests and25 CLI tests. Startup145.705ms cold/8.825ms warm median/
9.735ms max is within budget. All five restores pass (109.95–5233.80us); all five context
cases pass (0.4/0.1/0/0/0.3us). Rendering has no changed event/status; prior budgets apply.
All four owned harness fixtures pass. Selected native profile, shared prompt SHA
230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270,
18 other prompts and full public SPEC/three reference hashes remain unchanged.

Parent invariant review: pass, no blocking findings. First-request accounting resets
each turn, subsequent requests use the endpoint maximum even without Changed progress,
normal context admission retains desired/effective budgets, and no new event, timer,
authority, provider retry or partial-call dispatch exists. Native/control provenance,
approval/cancel/Unknown barriers and disabled behavior remain intact. This is an author
review, not an independent review or proof of latency, acceptance or native Pi parity.

Frozen Retry27 selects initial8192/later32768, checks8/mutations32, cap40/window3,
initial progress/recurring mode/review enabled, review reserve300000ms, native2370000ms,
outer2400s/provider2394000ms/grace6s, preserved relay8003 hard1194s/low4096.
Same model PID27356, prompt, sampling, context and tool policies; one fresh development
turn only. Fresh Pi remains conditional on Rupi acceptance. Any failure requires fresh
analysis and another verified enhancement before another attempt.

Debug SHA256 ECBCBA944F87EF2D94323F30ACA82E51EBF11A89EA426E1D439AD455BB2C3EF1;
harness SHA256 2BDABF37229BFDCE9C1371E9B2580CF51986893893B47FF6DF0518BCF88738E8;
host699C871BE5AA9F141363ECC628AF7CE93A241097EFC9F587E01BE494A613AF69 and
relayA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7 unchanged.
No inference was active during implementation/verification. Remote refs pruned; actual
local/remote branches are only main and active Case10, with detached artifacts retained.

### Retry27 terminal failure before mutation

Frozen source c97d652223963fc92c53e35cfec333367e42d5f0 / checkout
8f51674cb1885a1310c823e7238c8e587801c069 ends after404.128s without outer timeout:
Failed(Semantic), finish reason length, output exactly8192. One request starts/closes and
one usage record reports14,297 work (6,105 uncached input +8,192 output). One write is
requested, zero tools complete, one known failure/zero Unknown; files list is empty.
No completion candidate/check/review occurs. Controls: one time guide/one initial
boundary, zero other controls. Acceptance/tests/four help exits are1, no verify timeout.
No Pi or paired win exists.

All frozen binary/harness/host/helper/source, selected controls/config, shared full
prompt/SPEC/three-reference audits pass before changes; all four model slots are idle.
Runner26068/child23500 end, screen process exit0. Exact frozen checkout passes Ubuntu,
macOS and Windows CI: https://github.com/SaehwanPark/rupi/actions/runs/37454055170 .
Parent did not inspect generated/model/diagnostic contents.

Root cause is verified at the response boundary: the selected initial8192 ceiling is
exhausted with length, so the first write cannot be treated as complete. Existing
semantic rejection safely prevents dispatch/replay. This replaces Retry26's unmeasured
first-response Transport with measured output truncation, but does not prove any net
latency, token, tool-progress or acceptance benefit. Smaller coherent-change guidance
did not produce a completed first mutation. The ceiling alone is insufficient.

Before another attempt, investigate a bounded initial tool-payload contract and explicit
incremental complete-call guidance using owned fixtures. Preserve failed-response
no-dispatch/no-replay, canonical provenance, original model/relay and all safety barriers.
Do not merely rerun this configuration or increase its output ceiling without a justified
verified enhancement.

### Retry28 bounded initial arguments enhancement and frozen screen

Source043196bc61d42b9ff47a03a011d7e263257534d6 adds optional
initial_progress_max_argument_chars (omitted/None,1..65536, requires initial output
selection). First-request mutating tool schemas advertise per-string Unicode maxLength,
respect smaller existing constraints and retain registry identities. Captured request
limits reject oversized complete calls before dispatch through existing lifecycle:
Failed with known None effect, total-call accounting, no progress release or replay.
Later requests have ordinary schemas and limits, even without initial Changed progress;
fresh turns renew selection. Runtime guidance asks one small coherent complete mutation
followed by incremental complete calls, without naming domain artifacts.

Owned comparative fixture: omission executes both calls; selection rejects oversized
first and permits larger later call, renewed over two turns. Unicode/nested/schema
minimum/example preservation, disabled/no-limit/no-tools, incomplete-response guards,
config omission/dependency/range/round-trip and CLI provider-wire pass. Explicit durable
effect assertion confirms None for rejected calls. All five owned harness fixtures pass,
and selected profile/shared prompt/full SPEC/18 other prompts/three reference guards pass.

Required fmt/core-all-features/clippy/workspace tests/docs/debug checks pass, including
211 runtime/134 core/25 CLI tests. Startup140.496ms cold/8.711ms median/9.624ms max.
All five restores103.10–4937.90us and context0.3/0.1/0/0/0.3us pass. Rendering events/
status unchanged; prior budgets apply. Parent invariant review passes with no blocking
findings: request snapshot controls enforcement, registry identity/approval/effect safety
remain intact, no execution occurs for rejected/incomplete calls, and no timer, event,
provider replay or authority is added. This is author review, not independent review.
Schema guidance cannot guarantee model compliance or output latency; scalar characters
are not bytes/tokens, and no actual acceptance/Pi benefit is claimed.

Frozen Retry28 adds initial argument2048 characters to Retry27: initial output8192,
later endpoint32768, checks8/mutations32, cap40/window3, initial/recurring/review enabled,
reserve300000ms/native2370000ms/outer2400s/provider2394000ms/grace6/relay1194s,
same preserved model27356/relay8003/low4096, prompt, sampling, context and tools.
One fresh Rupi development turn; fresh matched Pi only after acceptance. Any failure
needs new root-cause analysis and another verified enhancement before a further attempt.

Debug SHA25616C6A138241FE560B00B43173E1DB105E7036B5FD5AC13284042FE9F1711B44A;
harness409DFF55556F062D87FCD92C1109F892A4A3E6B9B8CCE914C7B5E4183B424319;
host699C871BE5AA9F141363ECC628AF7CE93A241097EFC9F587E01BE494A613AF69 and
relayA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7 unchanged.
No inference active during implementation/checks. Root's user policy hash is unchanged.
Generated/model/oracle/diagnostic contents remain unread; broader stage gates remain active.

### Retry28 terminal failure at caller observation

Frozen source043196bc61d42b9ff47a03a011d7e263257534d6 / checkout
47ec4fd5224484fa2c374222a0620b0dac816994 ends Failed(Semantic) after1,928.185s,
no outer timeout. All37 requests close with37 usage records:163,378 work
(142,752 uncached input +20,626 output).40 tools requested,39 complete, one known
failure/zero Unknown. Listed files:receiptledger/__main__.py28,395bytes and
receiptledger/__init__.py29bytes; public tests/README absent. Acceptance/tests1,
all four help exits0, no verification timeout. Safe controls:37 time guides/six
progress boundaries/one completion check/zero review/other. First delegated check
returns unavailable after186ms, after37 started requests. No Pi or paired win.

All frozen source/binary/harness/host/helper/model/config/control/full shared
prompt/SPEC/three-reference audits pass before changes; all four model slots idle.
Runner17976/child32116 end, screen exit0. CI37456020024:Ubuntu/macOS pass, Windows
fails the pre-existing CLI mailbox fixture. Its host panics after15s awaiting two
checks, native fixture budget10s; join unwrap suppresses child status/stderr, so exact
child failure remains unmeasured. New initial schema/wire fixture passes. CI failure
recorded on PR; no blind rerun. Generated/model/caller/oracle diagnostics stay unread.

Initial bounding no longer prevents all tool progress in this screen, but isolated
causality/model compliance/acceptance benefit is unproved. The terminal boundary is
verified: first caller observation is unavailable and core safely stops without replay.
Missing public tests/README should yield known failed public feedback according to
host source, not by themselves unavailable. Exact caller exception is unmeasured:
the host catches failures and deliberately returns generic unavailable. Investigate
missing-deliverable and long-path owned fixtures before selecting an enhancement.
Also strengthen the CLI mailbox fixture's timing/child-exit diagnostics before fresh CI.
Keep unavailable/uncertain checks unreplayed and failures distinct from observation
outages; no model/helper restart or repeated benchmark without verified enhancement.

### Retry29 short isolated snapshot enhancement and frozen screen

Codebase enhancementa2e156ed1a8a39ef3083cad137fa79889fc8a415 fixes caller snapshot
path layout. Runtime source043196bc61d42b9ff47a03a011d7e263257534d6 and binary stay
unchanged. Owned short-path missing files yield Failed; long-path check throws
Process.Start invalid working-directory on Windows. Actual Retry28 exception is unread;
its longer derived snapshot path and186ms unavailable result are consistent with the
verified defect, not direct proof from generated diagnostics.

Optional caller ScratchRoot keeps the original run-local UUID mailbox and isolates
public snapshots/command artifacts under the same UUID in repo
.benchmark/completion-scratch. Both roots checked outside canonical workspace; all
artifacts retained. Default host omission unchanged. Checks/commands/limits/public roots/
oracle exclusion/atomic publication/once-only handling unchanged; unavailable checks are
not replayed. Fresh owned long-root/short-scratch failure→later repair Passed proves
classification, retained artifacts and no canonical verification effects. All five
owned harness fixtures pass. Full selected profile and original18 other prompt hashes,
shared prompt230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270,
full public SPEC and three reference hashes remain unchanged.

CI mailbox fixture now uses60s native/75s host guard and child-finished notification.
Child status/stdout/stderr survive missing-observation assertion; two observations,
same-model repair, exact file/wire/no-exec assertions remain. Focused and full tests pass;
no rerun of failed CI unchanged. Prior exact child failure remains unknown. Required
fmt/core-all-features/clippy/workspace tests/docs/debug pass (211 runtime/134 core/
25 CLI). Startup139.137ms cold/8.211ms median/8.884ms max passes. Unchanged binary/
production context/render/session code retains prior five restore/five context/render
budget evidence. Parent invariant review passes with no blocking findings: short-root
selection is caller-only, mailbox identity remains run-local, effects and artifacts stay
outside canonical workspace, uncertain observations remain terminal and unreplayed.
This is author review; acceptance/latency/Pi parity remain unproved. LESSONS.md preserves
the verified Windows writable-path versus launchable-working-directory distinction.

Frozen Retry29 changes only caller scratch layout relative to Retry28: first argument2048,
first output8192/later32768, checks8/mutations32, cap40/window3, initial/recurring/review,
reserve300000ms/native2370000ms/outer2400s/provider2394000ms/grace6/relay1194s,
same original model27356/relay8003/low4096, sampling/context/tool policies and prompt.
One fresh Rupi development turn, no replay of Retry28's unavailable check. Fresh Pi only
after acceptance. Any failure requires new analysis and verified enhancement before retry.

Debug16C6A138241FE560B00B43173E1DB105E7036B5FD5AC13284042FE9F1711B44A;
harness8390A2E20DD2C52EB8B99CF5ABADA8B3F73B269E6C2BFCC011E0ECAA6AFCEAC8;
hostDC75BEB0995E0EC00C1D6AFC6AE34FCD53CA18CE5085D85B1C1A7ED70865A8FE;
relayA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7.
Remote refs pruned; only actual main and active Case10 branches remain, detached artifacts
retained. No inference was active during changes/checks, no actual diagnostic content read.
Broader project gates and final paired evidence remain active.

### Retry29 terminal initial-response failure

Frozen codebasea2e156e/runtime043196b/checkout416746314b6a441b0f448062934e2b3eea7521c3
ends Failed(Semantic) after409.515s, no outer timeout: finish reason length and exactly
8192 output tokens. One request starts/closes with usage14,435 work (6,243 uncached
input +8,192 output). No decoded tool requests/completions/failures/Unknown, no files,
no completion checks. Controls:one time guide/one initial boundary/zero other.
Acceptance/tests/four help exits1, no verification timeout. No Pi or configured win.

All frozen runtime/binary/harness/host/helper/model/config/control/full prompt/SPEC/
three-reference audits pass before changes; all four model slots idle. Runner19236/
child22032 end, screen exit0. Exact frozen checkout CI37461082997 passes Ubuntu,
macOS and Windows after the mailbox fixture correction. The short caller snapshot
root is not reached, so no actual caller-fix benefit is measured. Generated/model/
caller/oracle/diagnostic content remains unread.

Verified cause at the response boundary: the first8192 output allowance is exhausted
before a tool call can be decoded. Schema maxLength and post-response validation cannot
by themselves ensure a complete first response. Actual reasoning/text composition and
the precise generation defect remain unknown. Provider mapping requests no strict
sampling unless its explicit constraint/capability contract selects it.

Upstream report https://github.com/ggml-org/llama.cpp/issues/27217 describes required
tool choice ignored on reasoning-preserving templates, with length and no calls.
Read-only local server metadata reports supports_tool_calls=true and
supports_preserve_reasoning=true. This is a possible matching failure family, not a
proved defect in our build; build/version and actual failed contents are unmeasured.
No model/helper restart or unchanged rerun is authorized by this evidence.

Next bounded runtime enhancement: caller-selected thinking override only for the first
active initial progress request, retaining normal thinking on later requests/fresh
renewal and all existing output/argument/approval/Unknown safeguards. Select requested
Off first then Low/4096 later in the next screen, with honest native/Pi metadata.
Verify config/owned runtime/wire/disable encoding before inference. Do not claim hidden
reasoning composition, guaranteed no-reasoning behavior, latency, acceptance or Pi parity.

### Verified initial thinking selection and frozen Retry30

Source 81574edc1bc5e3d6e539056c52a9b0bdc1ec841b adds optional first-active-initial-request thinking selection.
Owned fixtures prove Off first/Low later, renewal, omission and skipped/no-effect paths;
CLI wire verifies reasoning_effort none then low with explicit disable encoding.
Later requests retain normal thinking; no new timer/event/authority, incomplete dispatch
or uncertain-effect replay. Native isolated Case10 scalar; Pi null. Shared prompt
230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270,
18 other prompt hashes, full public SPEC and three reference hashes remain unchanged.

Required fmt/core-all-features/clippy/workspace tests/docs/debug pass:212 runtime/135 core/
25 CLI plus six harness fixtures. Startup143.715ms cold/8.908ms warm median/9.921ms max;
five restore cases89.40/586.95/2618.65/2542.90/4858.55us and five context cases
0.4/0.1/0/0/0.3us pass. Parent author invariant review passes; no independent-review
claim. Exact source81574ed CI37463956750 passes all three platforms.

The previous planned Off-first/Low-later relay profile is superseded before inference:
preserved relay8003 accepts only low, so none would be rejected. Frozen Retry30 instead
uses existing direct8000, global Off for both agents, explicit native first Off,
reasoning-budget selection0/omitted and no relay deadline. This changes the comparison
profile; same physical model27356, all original helpers remain unchanged. Effective
backend no-reasoning enforcement and actual acceptance/latency/Pi benefit remain unproved.

Run bench-20261006-case10-direct-off-firstoff-args2048-first8192-check8-mut32-review300-turn2370-retry30-rupi40-screen1-2400s: one fresh Rupi development turn,
first output8192/later32768/first strings2048/checks8/mutations32/cap40/window3,
initial/recurring/review/reserve300000ms/native2370000ms/provider2394000ms/outer2400s/
grace6; sampling/context/tool policies unchanged. Fresh matched direct-Off Pi only
after Rupi acceptance. Any failure requires analysis and verified enhancement before retry.
DebugB53B6FD42F9E4522F79F99CF38E29968ACCFEDFB14AF69D467B22176418E0107;
harness5D3310C4848BCDD98EAF46970F8F0E294E879606E262495EE2A7780F613378E3;
hostDC75BEB0995E0EC00C1D6AFC6AE34FCD53CA18CE5085D85B1C1A7ED70865A8FE;
helperA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7.
Quota wait completed after reset+2min; provider reports0% five-hour/0% weekly at13:52UTC.
Root user policy remains untouched. Broader gates and final paired evidence remain active.

### Retry30 terminal time-budget failure

Frozen source81574ed/checkout5fba487f19669f23fd523a720de722dcae222a46 ends
TimeBudgetExhausted after2370.112s with no outer timeout.27 requests start/close,26 usage
records;143,756 known work=109,281 uncached input+34,475 output. The unfinished request's
actual work remains unknown, never zero.33 tool requests/32 completions/one known failure/
zero Unknown; one write plus edit/read/grep activity. Only receiptledger/__main__.py
29,883 bytes is listed; init/tests/README absent. Acceptance/tests exits1; four help exits0;
no verification timeout. No completion checks, one completion review after21 started
requests, six progress boundaries/27 time guides. No Pi or configured win.

All frozen binary/runtime/harness/public-host/helper/model/config/control/full prompt/SPEC/
three-reference audits pass before changes. Runner24420/child33940 exit, screen exit0;
all four model slots idle. Exact frozen5fba487 CI37475008449 passes all three platforms.
Generated/model/caller/oracle/diagnostic contents remain unread. The first request
progressed beyond earlier no-tool failure, but direct-global-Off changes are confounded;
no isolated causal thinking or effective backend no-reasoning claim.

Verified feedback gap: caller public observations run only after accepted final assistant
text. This turn reaches a bounded completion review but never reaches a caller check;
runtime safe boundaries therefore have no fresh public observation of missing deliverables.
Application-only artifact progression and time exhaustion are verified; precise model
reasoning and application defects remain unmeasured.

Next bounded enhancement: opt-in caller completion observation at the one-shot completion
review boundary, sharing the existing allowance/mailbox/provenance/remaining-time/cancel/
Unknown safeguards. Failed or Unavailable observations continue bounded same-model review;
Passed does not itself finish the turn. Default omission preserves prior behavior.
Owned comparative tests must prove early failed public feedback permits repair before
final assistant completion, counts once, renews, and respects cancellation/deadline/
Unknown/no-tools/exhaustion. Verify config/CLI/harness/public host/frozen metadata and
required gates before Retry31. Usage before this slice:5% five-hour/1% weekly.

### Verified observation at timed review and frozen Retry31

Source06da417b2530136d97582e4e53aa7642d2af8ab8 adds optional limits.completion_check_on_review,
default false/omitted; requires enabled review, valid timed reserve and check allowance.
One fresh caller observation at timed review shares the normal allowance and current
cancel/remaining-time token. Passed still proceeds to model review and a later fresh
final check; Failed with allowance permits repair. Last Failed/exhaustion and Unavailable/
oversized results preserve existing stops. This explicitly supersedes the preliminary
terminal sketch to continue after Unavailable. Progress/tool-budget/Unknown barriers,
approval, model identity and no incomplete dispatch/replay remain unchanged. No new event/
status/render/timer/dependency or core/CLI verification execution authority.

Owned feedback-directed comparison: early external evidence permits repair before the first
final answer in3 requests versus4 with omission. Renewal/fresh final checks, inactive
paths/request caps, last failure/unavailable/oversized and cancellation/deadline/Unknown
fixtures pass; real CLI mailbox tests both ordinary and timed-review paths with no-exec
assertions. Seven owned harness fixtures and full selected profile pass. Required fmt/
core-all-features/clippy/workspace tests/docs/debug pass (216 runtime/136 core/25 CLI).
Startup141.594ms cold/8.317ms median/9.421ms max; five restore cases69.55/469.30/2837.50/
2813.20/5306.00us and five context cases0.4/0.1/0/0/0.3us pass. Parent author invariant
review passes; no independent-review claim. Source CI37482779844 is running at freeze.

Shared prompt230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270,
original18 case/phase/prompt hashes, full public SPEC and three reference hashes unchanged.
Frozen run bench-20261006-case10-review-check-direct-off-firstoff-args2048-first8192-check8-mut32-review300-turn2370-retry31-rupi40-screen1-2400s: one fresh Rupi turn,
adds only timed-review observation to Retry30's direct8000/globalOff/firstOff, first output
8192/later32768/first strings2048/checks8/mutations32/cap40/window3/initial/recurring/
review/reserve300000ms/native2370000ms/provider2394000ms/outer2400s/grace6. No reasoning
budget or relay deadline; same model27356 and original helpers/sampling/context/tools.
Fresh matched direct-Off Pi only after Rupi acceptance. Any failure requires new analysis
and verified enhancement before another attempt. No actual acceptance or paired win.

Debug4B644926DF8E8C27CE6C70BE1E7BB083CF5B078F857CFDFA4771A8C63AE12532;
harnessFD8AB32797BF8F0DF3063F230D88D4B48CE158BD159E280252622149A1A01AF5;
hostDC75BEB0995E0EC00C1D6AFC6AE34FCD53CA18CE5085D85B1C1A7ED70865A8FE;
helperA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7.
Root user policy hash unchanged; headroom15% five-hour/2% weekly before freeze. Fetch/prune
confirms only actual main and active Case10 branches; detached artifacts retained.
Performance/author evidence recorded before launch; exact CI results remain pending.

### Retry31 terminal initial-response failure

Frozen source06da417/checkouta3887e1a5e82f5377c487e5d49c523e96540a076 ends
Failed(Semantic) after404.127s, no outer timeout; finish reason length,8192 output.
One request starts/closes with usage14,482 known work=6290 uncached input+8192 output.
Zero decoded tool requests/completions/failures/Unknown, files or caller checks.
One time guide/one initial boundary, no review or completion-check controls.
Acceptance/tests/four help exits1; no verification timeout. No Pi or configured win.

All frozen runtime/binary/harness/host/helper/model/config/control/full prompt/SPEC/
three-reference audits pass before changes; runner32900/child31424 exit, screen exit0;
all four original model slots idle. Enhancement06da417 and exact frozena3887e1 each
pass all three CI platforms. Timed-review observation is never reached, so its actual
acceptance benefit remains unmeasured. Generated/model/caller/oracle contents stay unread.

Verified cause at response boundary: output ceiling exhausted before a tool can be
decoded, despite requested global/initial Off. Actual reasoning/text composition and
backend enforcement remain unknown. This recurrence removes any claim that Retry30
tool progression demonstrates a reliable or isolated thinking-selection benefit.

Read-only static metadata reports supports_enable_thinking=null (unknown), tool_calls
and preserve_reasoning true. Current upstream server documentation and source support
chat_template_kwargs.enable_thinking boolean; the existing rupi ChatTemplateThinking
dialect emits a different thinking key and its llama.cpp-specific comment is too broad.
This is a verified adapter coverage gap, not proof of the precise local failure or build.
Sources: https://raw.githubusercontent.com/ggml-org/llama.cpp/master/tools/server/README.md
and https://raw.githubusercontent.com/ggml-org/llama.cpp/master/tools/server/server-common.cpp.

Next bounded investigation: add an explicit typed enable_thinking template dialect,
preserving legacy/default behavior and honest requested-versus-effective metadata;
verify firstOff/later inheritance and paired Pi support from pinned adapter code before
selecting a comparison profile. No speculative capability claim, backend restart/helper
replacement, hidden-reasoning claim or unchanged retry. Required verification and freeze
must precede any new screen. Usage before next slice:19% five-hour/3% weekly.

### Verified template dialect and frozen Retry32

Sourcebe0c03268da20106d248f81616c3b7c63f3e40e1 adds explicit typed ChatTemplateEnableThinking;
Off maps to chat_template_kwargs.enable_thinking=false and other levels true.
Legacy thinking-key and default reasoning-effort encodings preserved; no arbitrary payload
map, capability/effort-intensity/backend compliance/hidden-reasoning claim. Isolated
Case10ThinkingInput selection requires direct budget0; both agents record selected dialect/
false off_value. Pinned Pi chat-template thinking.enabled variable emits the exact tested
boolean without adding preserve_thinking or effort. Pi implementation unchanged.

Owned mapping covers all levels; config/derived-provider roundtrips and Rupi real CLI
firstOff/laterLow wire preserve output/string limits and reasoning replay. Pinned Pi fake
HTTP verifies exact Off false/Low true/no effort. Eight harness fixtures/full paired profile/
shared prompt230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270/
original18 case/phase/prompt hashes/full public SPEC/three reference hashes pass.

Initial workspace verification found150ms timed cancel could fire PreRequest instead of
Streaming. The fixture now cancels after the observed first delta, drains the fake POST,
and preserves partial-output/quarantine/no-repost assertions. Caller timeout fixture had
only1.1s after cleanup reserve and failed before command artifacts;18s/10s simulated work
now verifies actual startup and Unavailable timeout. Production deadlines unchanged;
focused and full corrected checks pass, no unchanged failure rerun. LESSONS.md records both.

Required fmt/core-all-features/clippy/workspace tests/docs/debug pass (216 runtime/136 core/
100 provider/25 CLI). Startup158.146ms cold/9.688ms median/11.706ms max; five restores
69.60/432.10/2604.50/2564.30/4949.30us and five context0.4/0.1/0/0/0.3us pass.
Parent author invariant review passes; no new event/status/render/timer/dependency/authority/
startup network work, legacy/default semantics and tool/cancel/Unknown barriers retained.
Source CI37487417266 running at freeze; no independent review or actual win claim.

Run bench-20261006-case10-template-off-review-check-args2048-first8192-check8-mut32-review300-turn2370-retry32-rupi40-screen1-2400s: one fresh Rupi screen.
Only requested template dialect changes from Retry31: direct8000/globalOff/firstOff,
first output8192/later32768/first strings2048/checks8/check-on-review/mutations32/cap40/
window3/initial/recurring/review/reserve300000ms/native2370000ms/provider2394000ms/
outer2400s/grace6; same original model27356/helpers/sampling/context/tool policies.
No budget selection/relay deadline/restart. Fresh matched Pi only after Rupi acceptance.
Any failure requires new analysis and verified enhancement before another attempt.
Debug9C269C404198134B4F7E1387D1E339399EAEAB97C7C493B3C7C80A8BC01C9BE0;
harnessB64E015CAC4B5841BEC214FCD5230057E54E519124BBAFE4B196FEE16DD5DC74;
hostDC75BEB0995E0EC00C1D6AFC6AE34FCD53CA18CE5085D85B1C1A7ED70865A8FE;
helperA0BCAE689139BFD281CB91C209D5D8F6CF9EA42FD7EFF256BE02D97A871387C7.
Root user policy hash unchanged; only main and active Case10 branches remain.
Usage before freeze32% five-hour/5% weekly. Remote CI and final paired evidence pending.

### Retry32 terminal audit and request-cap root cause

Frozen checkout 575129b34f344329bdea549ee1c331a09d7ef882, runtime
be0c03268da20106d248f81616c3b7c63f3e40e1:
bench-20261006-case10-template-off-review-check-args2048-first8192-check8-mut32-review300-turn2370-retry32-rupi40-screen1-2400s.
The single Rupi screen ended budget_exhausted at 1,583,277 ms without an outer timeout.
All 40 started requests closed with usage: 118,092 known work (102,257 uncached input,
15,835 output). There were 44 tool requests, 39 completions, five known failures, and
zero Unknown operations. Requested names: write 7, edit 12, read 10, grep 15.

Filename/byte metadata lists README.md (9,783), receiptledger/__init__.py (300),
receiptledger/__main__.py (40,414), and receiptledger/audit.py (834); both required test
files are absent. Acceptance and tests exited 1; all four public help checks exited 0,
with no verification timeout. There were seven progress boundaries, 40 time-budget
controls, one request finalization, zero reviews and zero caller checks. No acceptance
or configured win is established.

All frozen binary/runtime/harness/host/helper/model/config/control/full-prompt/SPEC/
three-reference audits passed before any subsequent changes. Exact shared prompt hash
remains 230589C5F20B5486CD84216CE5B6A0DB9734CE724C2903D891E4D50D9CFB3270.
All model slots are idle; runner and child ended. Source CI 37487417266 and exact frozen
checkout CI 37487811299 passed all three platforms. Actual generated content, model
outputs, caller diagnostics and oracle content remain unread by the parent.

Verified failure: the 40-request cap bound before ordinary final text or the time reserve
could trigger review/checking; approximately 786,723 ms of native time remained. Tools
were below the selected 32-mutation and 64-total caps. Finalization deliberately cannot
invoke tools or checks. Application-specific defects and hidden reasoning remain
unmeasured. Next slice adds an opt-in request-count review reserve sharing the existing
one-shot review/check machinery, without enlarging any allowance.
