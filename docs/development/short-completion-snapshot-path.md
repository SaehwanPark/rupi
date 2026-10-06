# Short caller completion snapshot paths

Retry28 safely stops on first Unavailable caller check186ms, after37 requests;
generated app/init exist but tests/README absent. Exact actual exception is unread.
Owned missing-deliverable check at short path returns Failed. The same owned check
under a long path throws Windows Process.Start invalid working-directory error.
Retry28's derived snapshot path is longer than that reproduced failure boundary.
This is a verified host defect consistent with the terminal failure, not proof from
actual diagnostics or a license to replay the unavailable observation.

Parent owns a bounded caller-harness fix: add optional ScratchRoot to
New-CompletionFeedbackHost. Preserve run-local UUID mailbox, but put public snapshots
and verification artifacts under a distinct UUID below the short selected scratch root.
Validate both roots outside the canonical workspace and retain all artifacts. Benchmark
selects repo .benchmark/completion-scratch; default omitted behavior remains unchanged.
CLI/core/check limits, copied public roots, oracle isolation, publication and once-only
handling remain intact. No model/helper restart, snapshot effect in canonical workspace,
automatic observation replay or changed public/acceptance assertions.

Extend owned host fixture with long run root plus short scratch: baseline fails at
Process.Start; fixed public missing files yield Failed and later fresh complete public
files yield Passed. Check canonical effects absent, outside-root guard, retained artifacts
and live callback. No actual generated/caller diagnostics are read. Run all owned harness
fixtures and required checks/performance budgets proportionate to unchanged runtime.

Separately strengthen existing CLI mailbox fixture:60s native budget/75s host guard,
child-finished notification and child status/stderr asserted before host join failure.
Keep two observations, repair, exact wire and no-exec assertions. Exact previous child
failure remains unknown because join panic hid it. Verify focused/full tests, then fresh
CI after the fixture change; do not rerun the failed CI unchanged.

Update contracts/ledger/roadmap and author invariant review, commit/push/freeze before
Retry29. Select only the short snapshot root, preserving all Retry28 model/runtime
controls, prompts/SPEC/reference hashes. One fresh Rupi turn, no replay of Retry28's
check. Fresh Pi only after acceptance. Any failure requires new analysis and enhancement.
