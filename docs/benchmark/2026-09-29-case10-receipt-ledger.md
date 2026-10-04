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
