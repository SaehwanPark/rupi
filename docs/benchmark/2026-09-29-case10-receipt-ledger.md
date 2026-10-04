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
| 2 | 600,306 ms | 0 / 0 | 0 | 0 | 0 | outer timeout; no model request |
| 3 | 600,311 ms | 1,053 / 188 | 1,241 | 2 | 2 | outer timeout |
| 4 | 600,232 ms | 0 / 0 | 0 | 0 | 0 | outer timeout; no model request |

Pi did not resolve in four turns. It used 9,202 work tokens over 2,401,150 ms, with eight
requests and eight tools. Every turn timed out. All oracle, project-test, and help checks failed
on every turn. On turns 2 and 4, the recorded request and tool counts were zero. On the final
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
