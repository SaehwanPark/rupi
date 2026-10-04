# Case 08 lease fence comparison ledger

This ledger records the matched `08-lease-fence` run with local `qwen3.8-flash-next` and
Pi 0.86.1.

## Matched baseline

Run: `bench-20260929-case08-pi0861-low-matched4-600s`.

The run summary recorded `pi_version: 0.86.1`. Settings were low reasoning, four turns, eight
requests per turn, 600-second outer timeouts, and project-test/help recovery feedback. Rupi
used a 570-second provider deadline. Work tokens are inference input plus output.

| Rupi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,291 ms | 12,690 / 1,048 | 13,738 | 4 | 4 | outer timeout |
| 2 | 600,195 ms | 26,139 / 8,108 | 34,247 | 5 | 5 | outer timeout |
| 3 | 600,307 ms | 1,024 / 579 | 1,603 | 2 | 1 | outer timeout |
| 4 | 600,261 ms | 3,268 / 3,562 | 6,830 | 3 | 2 | outer timeout |

Rupi did not resolve in four turns. It used 56,418 work tokens over 2,401,054 ms, with 14
requests and 12 tools. All oracle, project-test, and help checks failed on every turn. The
service could not start because `leasefence.__main__` was missing. Project-test discovery
could not import the `tests` start directory.

| Pi turn | Elapsed | Input / output | Work tokens | Requests | Tools | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 600,239 ms | 6,165 / 11,461 | 17,626 | 13 | 15 | outer timeout |
| 2 | 600,228 ms | 9,750 / 8,839 | 18,589 | 12 | 19 | outer timeout |
| 3 | 600,230 ms | 4,098 / 6,477 | 10,575 | 9 | 9 | outer timeout |
| 4 | 600,215 ms | 9,229 / 5,477 | 14,706 | 14 | 14 | outer timeout; unresolved |

Pi did not resolve in four turns. It used 61,496 work tokens over 2,400,912 ms, with 48
requests and 57 tools. All help checks passed. Project tests passed on turns 1 and 4; the turn
2 test check timed out after 180 seconds, and turn 3 had one failure among 47 tests. The oracle
failed on every turn. On turn 4, its stale-worker claim did not appear before the timeout.

## Outcome

The result is inconclusive because neither agent resolved the oracle. Pi used 5,078 more work
tokens and finished 142 ms sooner. Pi passed help throughout and project tests on its final
turn, but its acceptance oracle still failed. Case 09 is next.

## Active improvement slice (October 3)

Cases 01 through 07 already have verified Rupi comparison wins and are skipped.
Case 08 remains unresolved for both agents in the pinned baseline. This slice improves
the shared Case 08 authoring and recovery guidance, then repeats the comparison with
local `qwen3.8-flash-next` and pinned Pi 0.86.1. Reference source and acceptance fixtures
remain unchanged; generated code must come from the local model in fresh workspaces.

The target is an independently verified oracle resolution with fewer turns than Pi,
or fewer recorded work tokens when both resolve in the same turn. Project tests,
help, README completeness, failures, and unrecorded inference are reported separately.
Preserve the full public specification, especially conditional finalization with a
private token, expired-lease reclaim, and stale-worker rejection across fresh processes.
Recovery may use public-spec project tests and help diagnostics; oracle diagnostics
must remain hidden from both model runs. No case is complete based on timing alone.

Next: prepare shared bounded prompts, verify harness dry runs, and run the matched
four-turn comparison. Keep this slice open until current evidence establishes a win.

## First retry preparation

The shared prompt embeds the full public specification in initial and recovery turns.
It starts with a compact CLI/health entry point, help tests, and honest README, then
adds signed admission, durable ordered jobs, direct-argv worker execution, and private
claim-token fencing in the existing entry point. Local test/help failures select repair
rather than more workflow expansion. All oracle details remain hidden; only status is
included. The reference implementation and acceptance suite are unchanged.

Both agents use file tools, explicit low reasoning, and the same 2,048-token thinking
budget through the existing content-free loopback relay. Native reasoning replay is
enabled only for an endpoint explicitly declaring native exposure. Rupi receives an
empty child discovery profile; Pi retains disabled context/skill/extension flags.
Rupi's request cap is 12; Pi retains its native request policy. These are configured
comparison controls, not proof of default-runtime superiority or equal request policies.
Use four 600-second turns and six seconds of provider timeout grace with Pi 0.86.1.

Verified before launch:

- All ten cases passed `bench/compare-pi-rupi.ps1 -DryRun` with low reasoning and
  Case 08 budget 2,048, and again with reasoning off and no budget relay.
- Dry-run checks cover Case 08 foundation, workflow, and local-repair selection,
  preservation of the complete specification, and exclusion of an oracle diagnostic
  sentinel from model-visible recovery. Existing Case 07 guards also passed.
- `git diff --check` passed. Case 08 changes stay in the benchmark adapter.
- `cargo +stable build --bin rupi --target-dir C:/Users/saehwan/repos/rupi/target`
  passed. The installed stable route reports the exact pinned Rust and Cargo 1.98.1;
  the named 1.98.1 route lacks its cargo component on this machine.
- Author invariant review: no blocking findings. Workflow policy stays outside core;
  no uncertain tools are replayed, no hidden reasoning is inferred, and no acceptance
  diagnostics or reference implementation are added to authoring context.

The run result is pending. Keep the Case 08 comparison objective active.
