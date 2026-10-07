# Case10: bounded Windows relay I/O

## Frozen Retry45

Run `bench-20261007-case10-native-retry45-rupi40-turns4-2400s` uses runtime source
`0b7221d1d9aa971a2198457acaae0f791b5c250f`, checkout
`63bb273eeb94a70f4afafbc2bcc44ac93f6172a2`, binary SHA256
`2D6DB2B4146B13CF0B191D04D3E21603F6CDB4BC3654D0B757510D28C67ABCE9` and harness
SHA256 `442411E29A7A78B576E068C14FCD03DE4D0B25117E3A269326ACEA8593AB7F23`.
Matched native Low2,048 is the only change from Retry44. All four turns fail independent
acceptance; no Pi run/configured win. The four fixed recovery turns are one attempt.

| Turn | Call ms | Native outcome | Starts / closures / usage | Known work | Tests |
| --- | ---: | --- | --- | ---: | --- |
| 1 | 2,370,120 | TimeBudgetExhausted | 29 / 29 / 28 | 117,850 | Exit5 |
| 2 | 2,253,333 | CompletionCheckExhausted | 37 / 37 / 37 | 194,973 | Exit1 |
| 3 | 1,509 | Exit1; no native terminal status | 0 / 0 / 0 | 0 | Exit1 |
| 4 | 1,481 | Exit1; no native terminal status | 0 / 0 / 0 | 0 | Exit1 |

Totals:4,626,443ms and312,823 known work tokens,258,852 input +53,971 output.
Turn1's final cancelled/streamed request has committed partial output but no usage;
its work remains unknown. Turns3/4 have no recorded request/tool events. Their actual
startup cause is unknown, not an established semantic model failure. No outer/verification
timeouts; all four help checks pass and independent oracle exit1 remains in every turn.
Actual task content, outputs, stderr, traces, caller feedback and private oracle remain
uninspected. Both frozen audits pass before source/binary/HEAD changes; original resources,
controls, caller/helper, prompts/SPEC/references and user-policy hash remain unchanged.
Runner exits normally and all four original model slots are idle.

Turn1's seven public observations fail after8/11/14/17/20/23/26 requests; review after23.
Metadata has entry point25,125 bytes and test initializer62 bytes, but no test module/README.
Turn2 uses all8 failed checks after8/11/14/17/20/23/26/37, also reviewing after23. README
2,476 bytes, entry point36,152 bytes and test module5,377 bytes now exist by filename/size.
Inspection guidance count3 reaches the path without acceptance or exact failure attribution.

Tool counts:81 requested,75 ToolCompleted +6 ToolFailed =81 aggregate terminal events,
zero recorded Unknown. The completion metric counts successful results, separately from
Failed/Unknown. Earlier narrative labels undercounted all terminals. Requests minus only
successful completions does not establish unfinished calls; aggregate equality does not
establish distinct pairing/None effects. Historical artifacts are never backfilled.

## Owned RCA and enhancement

A live Turn1 scalar sample records CPU1,765.609s over approximately32min, while one model
slot is active. Actual stack attribution remains uninspected. An owned stdlib loopback
probe finds Windows accepted sockets inherit nonblocking mode: an idle read returns
WouldBlock in6us despite100ms timeout; clearing the mode waits105,275us before TimedOut.
Current relay source immediately repeats WouldBlock on that accepted client's idle pump.

An unchanged owned driver compiles the private production relay source and sends one owned
POST through a fake upstream held idle for three seconds. Exact response/EOF pass, but
CPU3,000ms fails the250ms budget. Driver SHA256:
`EABA2EA82A2100AEBA2D2E407F6B9CB1C86A6149DF402F0120F0B827D0A5DD9E`.
Before executable SHA256:
`585B3F4D1819400001C1C4021461915B2566C77CC5B344627FA17042B3314906`.
Accepted mode normalization makes the unchanged driver pass, reporting0ms CPU subject to
accounting resolution. The tracked benchmark then exposes a distinct teardown race:
waking an already-closed listener spends2,012ms in default connection refusal. An owned
closed-port probe measures2,022,308us default versus31,849us with a25ms bounded connect.
These prove owned transport defects; contribution to actual acceptance/timeouts is unproved.

Normalize accepted mode before header/nonce processing, failing closed on setup error;
retain nonblocking accept and25ms timed I/O. Bound stop's wake connect to the same interval.
No dependency, eager discovery, external helper/model/proxy restart, endpoint/config,
event kind, exposure, domain logic or replay changes. Nonce/single-use routing, configured
upstream proxy/TLS, exact bytes/EOF, cancellation, worker joining and quarantine remain.

The Windows-only `relay_idle` benchmark compiles the private production source unchanged.
Windows accounting samples only its process; its delayed loopback server never calls the
model endpoint. It checks one POST/exact response/EOF, CPU250ms per three-second wait and
stop500ms. Three samples pass: CPU0/0/31.25ms; stop31.638/25.900/32.607ms. Windows CI uses
an absolute JSON output path; other platforms compile a platform skip. Failed measurements
are written before reporting budget failure. Included test-module imports are exempted only
in the standalone benchmark; production warnings remain strict.

All five relay unit tests and all30 transport tests pass: active fragments/one-shot/header
deadlines, cancellation without reposting, uncertain completions, reasoning declarations,
headers/dialects and normal streaming/non-streaming. Workspace all-target Clippy passes.
An owned CLI fixture closes on failed completion-check exhaustion, resumes the same session,
reuses response-scoped tool IDs and reads original state after a started failed/None edit
without replay. It passes; actual Turns3/4 startup failure is not reproduced and stays
unknown. The first fixture excluded mutations by default; explicit owned read/edit policy
then exercises started failure. No identity/effect guard is weakened for an unproved cause.

Author review, full local/CI gates and performance checks precede a fresh attempt. Preserve
all Retry45 controls/native budget and original physical resources. Fresh independent
acceptance and a paired win remain required; owned fixtures alone do not achieve the goal.
