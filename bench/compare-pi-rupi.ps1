[CmdletBinding()]
param(
  [ValidateSet("all", "rupi", "pi")]
  [string]$Agent = "all",
  [string[]]$CaseId = @(),
  [string]$RunId = "",
  [string]$PiExecutable = "",
  [string]$ExpectedPiVersion = "0.86.1",
  [ValidateRange(1, 10)]
  [int]$MaxTurns = 4,
  [ValidateRange(30, 3600)]
  [int]$TurnTimeoutSeconds = 900,
  [ValidateRange(1, 300)]
  [int]$ProviderTimeoutGraceSeconds = 30,
  [ValidateRange(1, 100)]
  [int]$MaxModelRequestsPerTurn = 24,
  [ValidateSet("off", "low")]
  [string]$ThinkingLevel = "low",
  [ValidateRange(0, 16384)]
  [int]$Case07ReasoningBudgetTokens = 0,
  [ValidateRange(0, 16384)]
  [int]$Case08ReasoningBudgetTokens = 0,
  [ValidateSet("one_shot", "recurring")]
  [string]$Case08ProgressBoundaryMode = "one_shot",
  [ValidateRange(1, 100)]
  [int]$Case08ProgressRequestWindow = 1,
  [ValidateRange(0, 16384)]
  [int]$Case09ReasoningBudgetTokens = 0,
  [ValidateSet("one_shot", "recurring")]
  [string]$Case09ProgressBoundaryMode = "one_shot",
  [ValidateRange(1, 100)]
  [int]$Case09ProgressRequestWindow = 1,
  [ValidateRange(0, 16384)]
  [int]$Case10ReasoningBudgetTokens = 0,
  [ValidateRange(1024, 65535)]
  [ValidateScript({ $_ -ne 8000 })]
  [int]$Case10ReasoningRelayPort = 8001,
  [ValidateRange(0, 3600)]
  [int]$Case10RelayResponseTimeoutSeconds = 0,
  [ValidateRange(1, 65536)]
  [int]$Case10MaxOutputTokens = 16384,
  [ValidateRange(0, 86400000)]
  [long]$Case10MaxTurnDurationMs = 0,
  [switch]$Case10ReviewCompletion,
  [ValidateRange(0, 86400000)]
  [long]$Case10CompletionReviewReserveMs = 0,
  [switch]$Case10InitialProgressBoundary,
  [ValidateSet("one_shot", "recurring")]
  [string]$Case10ProgressBoundaryMode = "one_shot",
  [ValidateRange(1, 100)]
  [int]$Case10ProgressRequestWindow = 1,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$Case09ProgressBoundaryMode = $Case09ProgressBoundaryMode.ToLowerInvariant()
$Case10ProgressBoundaryMode = $Case10ProgressBoundaryMode.ToLowerInvariant()
$script:providerTimeoutGraceSeconds = [int][math]::Min(
  $ProviderTimeoutGraceSeconds,
  [math]::Max(1, [math]::Floor($TurnTimeoutSeconds / 10))
)
$script:providerRequestTimeoutMs = [int](
  ($TurnTimeoutSeconds - $script:providerTimeoutGraceSeconds) * 1000
)
if ($Case10MaxTurnDurationMs -ge ($TurnTimeoutSeconds * 1000)) {
  throw "Case10MaxTurnDurationMs must be below the outer turn watchdog."
}
if ($Case10CompletionReviewReserveMs -gt 0 -and
    (-not $Case10ReviewCompletion -or
     $Case10CompletionReviewReserveMs -ge $Case10MaxTurnDurationMs)) {
  throw "Case10CompletionReviewReserveMs requires review and a larger native turn duration."
}
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$artifactRoot = Join-Path $repoRoot ".benchmark\runs"
if ([string]::IsNullOrWhiteSpace($RunId)) {
  $RunId = Get-Date -Format "yyyyMMdd-HHmmss"
}
$runRoot = Join-Path $artifactRoot $RunId
$python = (Get-Command python.exe -ErrorAction Stop).Source
$rupiBinary = Join-Path $repoRoot "target\debug\rupi.exe"

function Get-CaseDefinitions {
  @(
    @{ Id = "01-task-ledger"; Source = "cases\01-task-ledger\toy-project"; ProjectDir = "toy-project"; Package = "tasklog"; Help = @(@("--help")); Focus = "a file-backed CLI ledger with stable IDs, atomic JSON writes, validation, and subprocess smoke behavior" },
    @{ Id = "02-reading-queue"; Source = "cases\02-reading-queue\project"; ProjectDir = "project"; Package = "readqueue"; Help = @(@("--help"), @("serve", "--help")); Focus = "a SQLite-backed HTTP CRUD service with deterministic errors and restart persistence" },
    @{ Id = "03-event-outbox"; Source = "cases\03-event-outbox\project"; ProjectDir = "project"; Package = "outbox"; Help = @(@("--help"), @("serve", "--help"), @("worker", "--help")); Focus = "an HTTP event outbox with idempotency, retry state, and a direct-argv NDJSON sink worker" },
    @{ Id = "04-webhook-inbox"; Source = "cases\04-webhook-inbox\project"; ProjectDir = "project"; Package = "webhookinbox"; Help = @(@("--help"), @("serve", "--help"), @("worker", "--help")); Focus = "an HMAC-authenticated HTTP inbox with leased delivery, crash reclaim, and a direct-argv sink" },
    @{ Id = "05-batch-relay"; Source = "cases\05-batch-relay\project"; ProjectDir = "project"; Package = "batchrelay"; Help = @(@("--help"), @("serve", "--help"), @("worker", "--help")); Focus = "a signed HTTP batch DAG with dependency ordering, retry/terminal failure, blocking, and leases" },
    @{ Id = "06-artifact-pipeline"; Source = "cases\06-artifact-pipeline\project"; ProjectDir = "project"; Package = "artifactpipe"; Help = @(@("--help"), @("serve", "--help"), @("worker", "--help")); Focus = "a signed data-flow DAG whose downstream jobs resolve declared scalar references from upstream JSON output" },
    @{ Id = "07-lease-cascade"; Source = "cases\07-lease-cascade\project"; ProjectDir = "project"; Package = "leasecascade"; Help = @(@("--help"), @("serve", "--help"), @("worker", "--help")); Focus = "a leased pipeline with ordered barrier fan-in, selected output collection, and blocked dependents" },
    @{ Id = "08-lease-fence"; Source = "cases\08-lease-fence\project"; ProjectDir = "project"; Package = "leasefence"; Help = @(@("--help"), @("serve", "--help"), @("worker", "--help")); Focus = "a pipeline with private claim-token fencing that rejects stale worker finalization" },
    @{ Id = "09-lease-receipt"; Source = "cases\09-lease-receipt\project"; ProjectDir = "project"; Package = "leasereceipt"; Help = @(@("--help"), @("serve", "--help"), @("worker", "--help")); Focus = "an idempotent sink pipeline with stable delivery keys and lost-ack receipt recovery" },
    @{ Id = "10-receipt-ledger"; Source = "cases\10-receipt-ledger\project"; ProjectDir = "project"; Package = "receiptledger"; Help = @(@("--help"), @("serve", "--help"), @("worker", "--help"), @("audit", "--help")); Focus = "the capstone pipeline with same-transaction append-only SHA-256 audit-chain verification" }
  )
}

function Get-CaseGuidance([hashtable]$case, [string]$phase = "initial") {
  switch ($case.Id) {
    "01-task-ledger" {
      return (@(
        'Prioritize this SPEC.md detail: `--state PATH` must work both before'
        'the command and after a subcommand.'
        'Unknown commands and missing required arguments return non-zero without changing state.'
        'IDs use ASCII decimal digits only and represent positive integers; `+1` is invalid.'
        ''
        'Make `tasklog/__main__.py` the first source file and keep the CLI there until'
        '`add`, `list`, `done`, and `remove` work with persistent JSON state.'
        'Do not create `__init__.py`, separate model or storage modules, a README,'
        'or tests before that runnable CLI exists.'
        'Then add the README and focused tests for both `--state PATH` positions,'
        'malformed commands, missing arguments, and invalid IDs.'
        'Verify invalid input leaves the existing state file byte-for-byte unchanged.'
      ) -join "`n")
    }
    "02-reading-queue" {
      return (@(
        'The documented service command is'
        '`python -m readqueue serve --db PATH --host HOST --port PORT`.'
        'Start with `readqueue/__main__.py` and keep the CLI, HTTP handler, and'
        'SQLite operations in that file until the complete service and help commands work.'
        'Do not split into `cli.py`, `server.py`, `store.py`, or `validation.py`,'
        'or write the README and tests, before the service is runnable.'
        'Call `main()` under the `__name__ == "__main__"` guard in `readqueue/__main__.py`.'
        'The documented `serve` command prints its address and keeps the service running.'
        'Prioritize the documented HTTP routes, deterministic JSON, and'
        'SQLite persistence across a server restart.'
        'Keep the SQLite connection helper and all CRUD call sites consistent after a rename.'
        'After implementing the service and help behavior, write a readable `README.md`.'
        'Include the run command and examples for documented routes.'
        'Use `self.rfile` to read HTTP request bodies.'
        'It is the input stream provided by `BaseHTTPRequestHandler`.'
        'The harness independently verifies the documented routes after each attempt.'
        'Do not run commands, tests, or help checks, or start the service.'
        'Successful responses use `application/json`; error responses include'
        'an `error` string and a suitable 4xx status.'
        'Duplicate URLs return 409; unknown IDs return 404; invalid requests'
        'leave existing data unchanged.'
        'Add focused tests for the documented routes, failure preservation, and'
        'restart persistence.'
      ) -join "`n")
    }
    "03-event-outbox" {
      return (@(
        'First tool call: workspace write `outbox/__main__.py` with the service and worker.'
        'Implement CLI help, HTTP routes, SQLite persistence, and `worker --once` in that file.'
        'Do not use the first source write for CLI/help only; include the complete workflow.'
        'The full Case 03 specification is embedded in this prompt.'
        'Do not call `read`, `exec`, or another inspection tool before this first write.'
        'Use the workspace write tool for this first source file.'
        'Keep the CLI, HTTP handler, SQLite storage, and worker in `outbox/__main__.py`'
        'until the complete service and `worker --once` flow are runnable.'
        'Do not create `service.py`, `storage.py`, or `worker.py` before `__main__.py` works.'
        'On shutdown, close every SQLite connection so the database is released.'
        'The same database must reopen immediately after the server process exits on Windows.'
        'The service command is `python -m outbox serve --db PATH --host HOST --port PORT`.'
        'The worker command starts with `python -m outbox worker --db PATH --sink PROGRAM`.'
        'Pass repeated `--sink-arg ARG` values directly and use `--once` for a bounded run.'
        'Prioritize idempotent event admission, durable retry state, and restart persistence.'
        'Pass sink arguments directly, without a shell; exchange one JSON line per event.'
        'Keep `worker --once` bounded and process its pending snapshot in insertion order.'
        'Failed deliveries stay pending, increment attempts, and record a non-empty error.'
        'The benchmark harness runs project tests and help commands after each attempt.'
        'Do not run commands, tests, or help checks, or launch the HTTP service or worker.'
        'After the service and worker flow work, add a readable README and focused tests.'
      ) -join "`n")
    }
    "04-webhook-inbox" {
      if ($phase -eq "initial") {
        return (@(
          'First tool call: workspace write the complete webhookinbox/__main__.py implementation.'
          'The full Case 04 specification is embedded in this prompt.'
          'Do not call read, exec, or another inspection tool before this first write.'
          'Use the workspace write tool for the first source file.'
          'Use one workspace write for all CLI, HTTP, SQLite, and worker application code.'
          'Keep the complete standard-library application in __main__.py; do not split modules.'
          'The serve command is python -m webhookinbox serve --db PATH --secret SECRET'
          '--host HOST --port PORT.'
          'The worker command is python -m webhookinbox worker --db PATH --sink PROGRAM'
          '[--sink-arg ARG]... --lease-seconds SECONDS --once.'
          'Include useful top-level, serve, and worker help in the implementation.'
          'Support GET /healthz, GET /deliveries/<id>, and signed POST /deliveries.'
          'Verify HMAC-SHA256 over the exact raw body bytes before any database mutation.'
          'Use constant-time signature comparison; invalid signatures return 401 without writes.'
          'Valid new deliveries return 202; identical repeats return 200; conflicts return 409.'
          'The worker commits each lease before starting its sink and reclaims expired leases.'
          'Pass sink arguments directly without a shell and exchange one JSON line per delivery.'
          'Complete the runnable service before spending additional writes on README or tests.'
          'Do not run commands, tests, help checks, the service, worker, or oracle.'
          'The harness independently runs project tests, three help commands, and the oracle.'
          'Oracle results and diagnostics are not shown in recovery feedback.'
          'Do not call exec for shell commands.'
        ) -join "`n")
      }
      switch ($phase) {
        "entrypoint" {
          return (@(
            'The current file snapshot has no webhookinbox/__main__.py; create that file first.'
            'Use one workspace write for the complete standard-library application in that file.'
            'Implement the HTTP contract, durable SQLite behavior, and worker lease flow.'
            'Implement argparse subcommands for serve and worker so all three help commands work.'
            'Use the exact serve and worker command forms from the embedded specification.'
            'Add the main guard; do not split application behavior into support modules.'
            'Do not call exec or run commands, tests, help checks, the service, worker, or oracle.'
          ) -join "`n")
        }
        "interface" {
          return (@(
            'The entrypoint exists, but CLI help or test discovery is not ready; fix those first.'
            'Preserve any working health route and signed admission behavior.'
            'Make python -m webhookinbox --help succeed, along with serve --help and worker --help.'
            'The worker invocation is python -m webhookinbox worker --db PATH --sink PROGRAM'
            '[--sink-arg ARG]... --lease-seconds SECONDS --once.'
            'Create tests/__init__.py and tests/test_cli.py with subprocess checks for all three'
            'help paths using sys.executable, including at least one unittest method named test_*.'
            'Do not split modules; first make discovery and all help commands succeed.'
            'Use local harness diagnostics, but do not call exec or run commands or tests.'
          ) -join "`n")
        }
        "tests" {
          return (@(
            'All help commands and the test package are present, but unittest discovered no tests.'
            'Create tests/test_cli.py with a unittest.TestCase and at least one test_* method.'
            'Add a useful subprocess check for the top-level, serve, or worker help command.'
            'Keep the existing application behavior intact; do not add only a helper module.'
            'After adding a discovered test, continue any unfinished worker or README requirements.'
            'Do not call exec or run commands, tests, help checks, the service, worker, or oracle.'
          ) -join "`n")
        }
        "workflow" {
          return (@(
            'CLI help and test discovery are ready. Use local project-test diagnostics to repair'
            'failures while implementing the complete worker and remaining Case 04 requirements.'
            'Commit each delivery lease before starting its sink; reclaim expired leases in order.'
            'Handle sink success, failure, malformed response, and crash recovery as specified.'
            'Pass sink arguments directly and preserve the signed admission behavior.'
            'Add focused worker and HTTP tests, then complete the required README.'
            'Do not call exec or run commands, tests, help checks, the service, worker, or oracle.'
          ) -join "`n")
        }
        default {
          return (@(
            'Local project tests, test discovery, and all three help commands pass.'
            'Inspect the existing implementation against the embedded specification.'
            'Finish any missing worker lease, expiry reclaim, crash recovery, sink, README, or test'
            'requirements while preserving passing behavior.'
            'Do not call exec or run commands, tests, help checks, the service, worker, or oracle.'
          ) -join "`n")
        }
      }
    }
    "05-batch-relay" {
      switch ($phase) {
        "initial" {
          return (@(
            'Build an import-safe CLI, health server, and one signed batch admission path.'
            'Create batchrelay/server.py with health and signed POST in the first service slice.'
            'Create a thin __main__.py CLI in the same turn; show top-level argparse help.'
            'Do not wait for CLI help to pass before implementing the HTTP routes.'
            'Keep only argparse and lazy command dispatch in __main__.py; do not put routes there.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Use lazy argparse imports; server.run(db, secret, host, port) starts serve_forever().'
            'Make GET /healthz return HTTP 200 JSON {"ok": true}.'
            'Implement POST /batches for one signed batch containing one valid job.'
            'Read raw body bytes from self.rfile; verify X-Batch-Signature before JSON parsing.'
            'Require sha256=<lowercase HMAC-SHA256 hex> over raw bytes with SECRET as UTF-8 key.'
            'Use hmac.compare_digest; missing, malformed, or wrong signatures return JSON 401.'
            'Invalid signatures must not mutate SQLite; insert the valid batch and job atomically.'
            'The valid one-job POST returns 202 with a pending job and attempts=0.'
            'After route code exists, add tests/__init__.py plus CLI, server, and HTTP tests.'
            'Use subprocess tests with sys.executable for top-level, serve, and worker help.'
            'Subprocess-test serve: poll /healthz, confirm it stays alive, and clean up.'
            'Test valid signed admission; assert bad signatures do not mutate the database.'
            'Keep command imports lazy so all help commands pass before worker.py exists.'
            'Defer validation, idempotency, batch status, and worker behavior.'
            'After the signed POST and focused tests pass, update README only as SPEC.md requires.'
            'Advance only after harness project tests and all three help commands pass.'
            'Never inspect or run the external oracle.'
          ) -join [Environment]::NewLine)
        }
        "foundation" {
          return (@(
            'Repair the argparse CLI and importable tests package first.'
            'If __main__.py is missing or not runnable, write or fix it before support files.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Lazy-import server and worker after command parsing so all help commands work.'
            'Ensure tests/__init__.py and subprocess checks in tests/test_cli.py exist.'
            'Do not work on health, HTTP, or worker until project tests and help pass.'
            'Never inspect or run the external oracle.'
          ) -join [Environment]::NewLine)
        }
        "health" {
          return (@(
            'CLI and test discovery passed; add health and signed admission together.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Create server.py with run(db, secret, host, port); bind and call serve_forever().'
            'Implement GET /healthz as HTTP 200 application/json with {"ok": true}.'
            'Implement POST /batches for one signed batch containing one valid job.'
            'Verify X-Batch-Signature over raw body bytes before JSON parsing.'
            'A valid one-job POST returns 202 with attempts=0; bad signatures return 401.'
            'Add tests/test_server.py and tests/test_http.py for health and focused admission.'
            'Wire serve to server.run lazily; poll health and clean up the subprocess.'
            'Preserve CLI behavior; defer full validation, status, and worker behavior.'
            'Never inspect or run the external oracle.'
          ) -join [Environment]::NewLine)
        }
        "admission" {
          return (@(
            'CLI and server health passed; complete only the first signed POST /batches path.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Add tests/test_http.py for one valid batch with one valid job and signature failures.'
            'Use X-Batch-Signature: sha256=<lowercase HMAC-SHA256 hex> over exact raw body bytes.'
            'Sign with SECRET as a UTF-8 key; verify HMAC before JSON parsing.'
            'Compare the expected and supplied digests in constant time.'
            'A new valid batch returns 202 with its job pending and attempts=0.'
            'Insert the batch and job atomically.'
            'Missing, malformed, or incorrect signatures return HTTP 401 without a database write.'
            'Preserve the passing CLI and /healthz tests.'
            'Defer replay/conflicts, full validation, GET status, and worker behavior.'
            'Never inspect or run the external oracle.'
          ) -join [Environment]::NewLine)
        }
        "contract" {
          return (@(
            'HTTP tests exist; keep routes in batchrelay/server.py and refine signed admission.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Keep tests/test_http.py focused on one valid signed POST and signature failures.'
            'Use raw body bytes, verify HMAC before parsing, and compare digests in constant time.'
            'A valid POST returns 202 with a pending job at attempts=0; the write is atomic.'
            'Missing, malformed, or wrong signatures return 401 without a database write.'
            'Preserve /healthz and all passing CLI/server tests.'
            'Defer full validation, idempotency, batch status, and worker behavior.'
            'Never inspect or run the external oracle.'
          ) -join [Environment]::NewLine)
        }
        "worker" {
          return (@(
            'HTTP passed; implement worker --once with tests/test_worker.py.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Process runnable jobs in dependency order and reclaim expired leases.'
            'Keep retryable failures pending; permanent failures block dependent jobs.'
            'Worker --once attempts each runnable job once and never polls.'
            'Invoke the sink as argv without a shell and send one JSON line for each claimed job.'
            'Preserve every passing CLI and HTTP behavior; do not rewrite a passing slice.'
            'After behavior and tests pass, update README only as SPEC.md requires.'
            'Never inspect or run the external oracle.'
          ) -join [Environment]::NewLine)
        }
        default {
          return (@(
            'All CLI, health, HTTP, and worker test files exist; project tests and help pass.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Use initial SPEC.md notes to fill missing behavior and add regressions.'
            'Preserve passing slices, and update README only as SPEC.md requires.'
            'The harness gives only oracle pass/fail status; never inspect or run the oracle.'
          ) -join [Environment]::NewLine)
        }
      }
    }
    "06-artifact-pipeline" {
      if ($phase -eq "initial") {
        return (@(
          'The complete Case 06 specification is embedded; do not reread SPEC.md.'
          'First tool call: write a runnable vertical slice in artifactpipe/__main__.py.'
          'Do not inspect files or run commands before this first source write.'
          ('Keep CLI, HTTP handler, and SQLite operations in __main__.py until ' +
            'the vertical slice runs.')
          'Use a guarded CLI with top-level, serve, and worker help.'
          'Implement GET /healthz and signed POST /pipelines in this first slice.'
          'Verify HMAC-SHA256 on exact raw bytes before JSON parsing.'
          'Persist accepted pipelines and jobs atomically.'
          'Add tests/__init__.py and tests/test_artifactpipe.py before worker work.'
          'Include an importable unittest.TestCase with at least one test_ method.'
          'Then complete validation, idempotency, status, and worker --once.'
          'Use ordered DAG claims, bounded leases, outputs, retries, and blocking.'
          'Invoke sinks by direct argv; resolve declared input_refs from dependencies.'
          'Finish README last; use only Python standard-library modules.'
          'The harness runs project tests, three help commands, and oracle after every attempt.'
          'Do not run commands, tests, help checks, service, worker, or oracle.'
        ) -join [Environment]::NewLine)
      }
      return (@(
        'Use local project-test and help diagnostics plus oracle pass/fail only.'
        'If no app source exists, write the CLI/health/signed-admission slice first.'
        'If tests/test_artifactpipe.py is absent, create it before feature expansion.'
        ('If project-test discovery exits 5, add tests/test_artifactpipe.py with a ' +
          'TestCase and test_ method.')
        'Fix the first project-test or help failure before adding more behavior.'
        ('If tests/help pass but oracle fails, complete validation, data flow, and ' +
          'worker transitions.')
        'Preserve passing CLI/server behavior while filling the smallest remaining gap.'
        'Keep worker --once bounded; use direct argv and do not poll.'
        'Use standard-library modules; finish README after executable behavior.'
      ) -join [Environment]::NewLine)
    }
    "07-lease-cascade" {
      if ($phase -eq "initial") {
        return (@(
          'The complete Case 07 specification is embedded; do not reread SPEC.md.'
          'The current directory contains SPEC.md and is already the project root.'
          'Use leasecascade/ and tests/ paths directly relative to this current directory.'
          'First tool call: write a compact, runnable CLI in leasecascade/__main__.py.'
          'Review the embedded specification as file inspection before this first source write.'
          'Use the workspace write tool; this first write must create __main__.py.'
          'Keep the first CLI write under 90 lines with top-level, serve, and worker help.'
          'This attempt covers CLI/health, help tests, and README; do not plan workflow code yet.'
          'Implement serve with a standard-library GET /healthz route and valid options.'
          'Defer SQLite, HMAC, pipeline state, and worker execution until the test files exist.'
          'Second write call: create tests/test_leasecascade.py with a real unittest.'
          'Keep initial tests under 60 lines; cover only imports and the three help paths.'
          'Third write call: create tests/__init__.py after the test module exists.'
          'Fourth write: create README.md under 80 lines with the public contract and exact checks.'
          'Cover commands, HMAC, routes, states, collect/fan_in, leases, sink, and persistence.'
          'Document implemented behavior honestly; keep command examples aligned with code.'
          'Each write call creates one file; write the test module before its initializer.'
          'Include an importable unittest.TestCase with at least one test_ method.'
          'Cover the three help paths with subprocess checks using sys.executable.'
          'Use native file tools and delegate all execution and verification to the harness.'
          'After the entry point, write the test module and initializer in consecutive calls.'
          'Keep all workflow code in __main__.py; do not create helper modules.'
          'Complete CLI/health, help tests, and README in this attempt; yield after four writes.'
          'Use the next harness feedback to begin workflow tests and implementation.'
          'Apply subsequent source edits of at most 80 new lines while preserving passing behavior.'
          'Invoke the sink with direct argv and persist output and terminal status.'
          'Expose the result through the documented pipeline/job retrieval route.'
          'Complete workflow behavior in later attempts using public-spec tests and small edits.'
          'Use standard-library imports and a main guard; do not import absent local modules.'
          'Implement signed pipeline admission and durable ordered job state.'
          'Then add worker --once with bounded leases, direct argv, and no polling.'
          'Claim runnable jobs in pipeline and job insertion order.'
          'Resolve only declared input_refs from successful dependency outputs.'
          'Build barrier fan_in in declared dependency order and include only collect.field.'
          'Use depends_on order and omit all other dependency output fields.'
          'Missing selected output fails the barrier without invoking its sink.'
          'Failed or blocked dependencies block dependents; expired leases are reclaimable.'
          'The harness runs tests, three help commands, and oracle after every attempt.'
          'Do not run commands, tests, help checks, service, worker, or oracle.'
          'Keep README commands and implemented behavior aligned during later repairs.'
        ) -join [Environment]::NewLine)
      }
      if ($phase -eq "entrypoint") {
        return (@(
          'The current directory contains SPEC.md and is already the project root.'
          'Use leasecascade/ and tests/ paths directly relative to this current directory.'
          'First tool call: write a compact, runnable CLI in leasecascade/__main__.py.'
          'Review the embedded specification as file inspection before this first source write.'
          'Keep the first CLI write under 90 lines with top-level, serve, and worker help.'
          'This attempt covers CLI/health, help tests, and README; do not plan workflow code yet.'
          'Implement serve with a standard-library GET /healthz route and valid options.'
          'Use standard-library imports and a main guard; do not import absent local modules.'
          'Define needed constants in __main__.py; do not import __version__ from the package.'
          'Defer SQLite, HMAC, pipeline state, and worker execution until the test files exist.'
          'Second write call: create tests/test_leasecascade.py with a real unittest.'
          'Keep initial tests under 60 lines; cover only imports and the three help paths.'
          'Third write call: create tests/__init__.py after the test module exists.'
          'Fourth write: create README.md under 80 lines with the public contract and exact checks.'
          'Cover commands, HMAC, routes, states, collect/fan_in, leases, sink, and persistence.'
          'Document implemented behavior honestly; keep command examples aligned with code.'
          'Cover the three help paths with subprocess checks using sys.executable.'
          'Complete CLI/health, help tests, and README in this attempt; yield after four writes.'
          'Keep all workflow code in __main__.py; do not create helper modules.'
          'Apply subsequent source edits of at most 80 new lines while preserving passing behavior.'
          'Complete workflow behavior in later attempts using public-spec tests and small edits.'
          'Do not run commands, tests, help checks, service, worker, or oracle.'
        ) -join [Environment]::NewLine)
      }
      if ($phase -eq "foundation") {
        return (@(
          'Project tests or help checks still fail; fix both foundation gates before workflow code.'
          'If help fails, repair leasecascade/__main__.py before writing more tests.'
          'Remove imports of missing local modules; keep the foundation self-contained.'
          'Each write call creates one file; write the test module before its initializer.'
          'Missing tests: write tests/test_leasecascade.py then tests/__init__.py separately.'
          'While either gate fails, repair only __main__.py or the two test files.'
          'Define an importable unittest.TestCase with at least one test_ method.'
          'Cover the three help paths with subprocess checks using sys.executable.'
          'Use workspace write tools only; no exec or running checks, services, workers, or oracle.'
          'Do not write validation, storage, server, or worker files until tests and all help pass.'
        ) -join [Environment]::NewLine)
      }
      if ($phase -eq "local") {
        return (@(
          'Repair the project-test failure shown in the diagnostic excerpt before adding features.'
          'Preserve the public-specification assertions and fix the implementation in small edits.'
          'If tests assume an undocumented private API, replace that coupling with public checks.'
          'Preserve every public-spec assertion; never weaken expectations to make tests pass.'
          'Keep application repairs in __main__.py; test helpers belong inside the test module.'
          'Each implementation edit adds at most 80 lines; preserve passing tests and help.'
          'Use the existing source and test context; read only the relevant file when needed.'
          'Repair other failures from the same feedback while the request budget remains.'
          'Then yield for harness feedback; do not run checks, service, worker, or oracle.'
        ) -join [Environment]::NewLine)
      }
      if ($phase -eq "workflow") {
        return (@(
          'Project tests and all help checks pass, but the independent oracle failed.'
          'Keep the passing tests and help paths intact.'
          'Do not repeat CLI, health-route, or test-discovery scaffolding.'
          'After workflow tests exist, advance leasecascade/__main__.py through small edits.'
          'Use prior context; read the intended source or test file once if its anchor is unknown.'
          'After that read, the next tool call must edit the intended file, not inspect more files.'
          'Each edit adds at most 80 lines; apply the first edit before designing later slices.'
          'After workflow tests exist, add signed admission, retrieval, then worker in small edits.'
          'With tests present, add missing raw-body HMAC and atomic SQLite pipeline/job state.'
          'Then connect POST /pipelines and GET /pipelines/<pipeline_id> in small separate edits.'
          'Keep workflow code in that file; do not create __init__.py or helper modules yet.'
          'Then add ordered leased claims, a direct-argv sink, and persisted terminal output.'
          'Use a bounded worker --once; reclaim expired leases without polling.'
          ('If workflow tests are missing, edit ' +
            'tests/test_leasecascade.py next.')
          'Keep workflow tests small; use the real CLI and HTTP contract before implementation.'
          'Use finite HTTP/process timeouts and terminate/wait for the server in finally.'
          'Test signed admission, persisted retrieval, and worker delivery of declared inputs.'
          'Exercise workflow behavior only through documented CLI, HTTP, and sink interfaces.'
          'Use sys.executable -m leasecascade, raw HTTP requests, and bounded sink fixtures.'
          'Keep test helpers in tests/test_leasecascade.py; use only standard-library imports.'
          'Do not import private application modules or assume undocumented function/class names.'
          'Do not create application helper modules just to satisfy test-specific internal imports.'
          'Test a barrier whose depends_on order reverses the two dependency insertion positions.'
          'Assert fan_in contains only collect.field values, with job_id/value items in that order.'
          'Return extra private output fields from dependencies and assert they are excluded.'
          'Missing collect.field test: no barrier sink call, failed barrier, blocked dependent.'
          'Use bounded subprocess fixtures and close every resource in tests.'
          'After adding missing workflow tests, end this attempt for harness feedback.'
          'If those tests fail, repair the implementation using the next harness feedback.'
          'Preserve all passing project tests and the three help paths.'
          'Then implement declared inputs, ordered selected-field fan-in, and dependency blocking.'
          'Reclaim expired leases; do not run a barrier sink when a selected field is missing.'
          'Build fan-in in depends_on order from only the selected collect.field values.'
          'Fail missing selections without running the sink, block dependents, and reclaim leases.'
          'Do not rewrite the whole application in one call or repeat implemented behavior.'
          'Use later attempts to finish small implementation edits while keeping workflow tests.'
          'If README is missing, write it before ending this attempt; retain the public checks.'
          'Do not run commands, tests, help checks, service, worker, or oracle.'
        ) -join [Environment]::NewLine)
      }
      return (@(
        'Use the embedded Case 07 specification, local tests/help, and oracle pass/fail only.'
        'Fix the earliest failing local gate before expanding the worker workflow.'
        'Preserve the existing CLI, HTTP, and durable state behavior.'
        '__main__.py is the application entry point; __init__.py alone is not runnable.'
        'Keep worker --once bounded and invoke the sink with direct argv, never a shell.'
        'Claim only runnable jobs in pipeline/job insertion order; reclaim expired leases.'
        'Use only declared input_refs and successful dependency outputs.'
        'Build barrier fan_in in depends_on order with only the selected collect.field.'
        'Fail a barrier locally if a dependency lacks that field, then block dependents.'
        'Do not run commands, tests, help checks, service, worker, or oracle.'
      ) -join [Environment]::NewLine)
    }
    default {
      return (@(
        "Prioritize the complete $($case.Focus) workflow described in SPEC.md."
        'Preserve its documented persistent state and failure behavior.'
        'Add focused tests for successful workflows and state-preserving failures.'
      ) -join "`n")
    }
  }
}

function Get-WindowsToolGuidance {
  @'
On Windows, use a dedicated process tool only if it is listed in your available
tools, calling it through its actual tool interface. Never type tool names such
as `process` as command prefixes in a shell. If there is no process tool, run
one executable directly through the available shell or exec tool per call.
Do not combine shell commands with `&`, `&&`, `;`, or `|`.
Do not use `python -c` or put Python source inside a shell command. For a one-off
Python check, write a temporary `.py` file inside this project workspace with
the file tool, then run that file in a separate command-tool call.
Keep file inspection inside this workspace; do not read Python installation
files or personal/global skill directories.
Use the available `read` tool for workspace file inspection. Reserve `exec`
for one direct command invocation. Do not use shell commands to list or search
workspace files, including `dir /s`, `find`, `findstr`, `grep`, or `ls`.
'@
}

function Get-Case08Prompt(
  [hashtable]$case,
  [object]$verification = $null
) {
  $spec = [IO.File]::ReadAllText((Join-Path (Join-Path $repoRoot $case.Source) "SPEC.md"))
  $feedback = ""
  if ($null -ne $verification) {
    $feedback = Get-RecoveryFeedback $verification
    $oracleStatus = if ($verification.oracle.timed_out) { "timed out" } elseif (
      $verification.oracle.exit_code -eq 0
    ) { "passed" } else { "failed" }
    $feedback = "Independent acceptance oracle: $oracleStatus (diagnostic details hidden)." +
      [Environment]::NewLine + $feedback
  }
  $guidance = if ($null -eq $verification) {
    @'
First tool call: write leasefence/__main__.py with the complete public workflow.
Use a compact runnable standard-library entry point with a main guard and all three help paths.
Implement authenticated admission, durable graph state, bounded worker delivery and fencing now.
Keep related behavior together; a single module is allowed, or use a few compact modules.
Do not import absent local modules. No placeholder worker or health-only foundation stage.
Use the embedded SPEC instead of rereading it; keep reads bounded.
After implementing the service and worker, write focused public-command/HTTP unittest tests,
tests/__init__.py and an honest README with the exact checks. Complete this in the same attempt.
Do not yield after a partial foundation or wait for a separate workflow-test authoring stage.
'@
  } else {
    @'
Repair the earliest failing local test or help gate using the harness diagnostics.
Preserve existing service and worker behavior. Remove imports of missing local modules.
Use compact application modules; preserve both CLI and workflow tests.
Implement missing public behavior in the application before revising test fixtures.
Change a test fixture only when it misuses the documented public contract; preserve assertions.
For application changes, use one focused edit per response, at most 100 new lines.
Write missing application files compactly; edit existing modules rather than replacing behavior.
Continue the next source edit in the same attempt; use bounded reads only when needed.
If the entry point or tests are missing, create complete runnable behavior and real test_* methods.
Use public commands and HTTP in tests; do not assume private function or class names.
After repairing the local failure, continue missing specification behavior in small edits.
File presence and passing help alone do not establish workflow completeness.
'@
  }
  @"
Implement the complete dependency-free Python 3 leasefence project in the current workspace.
The project root already contains SPEC.md; use leasefence/ and tests/ paths directly.
Use only Python standard-library modules. Create README.md and focused unittest tests.
Work only here; do not edit SPEC.md, any rupi config, or files outside the workspace.
Do not inspect or run the external acceptance oracle. Oracle diagnostics stay hidden.
Do not run commands, tests, help checks, service, worker, or oracle; no exec or shell calls.
Use native read/write/edit tools and delegate execution and verification to the harness.
The harness runs project tests, three help commands, and the independent oracle each attempt.
Report verification only when the harness supplies it; preserve all public requirements.

$feedback

$guidance

Validate the full graph before atomic insertion; persist original pipeline/job order.
Resolve only declared input_refs from successful dependencies. Build barrier fan_in in
depends_on order using only collect.field, with job_id/value items under the declared as key.
Fail missing inputs/selections locally; block dependents and never invoke a failed barrier sink.
Claim in a short transaction, increment attempts, persist a fresh private unguessable token
and lease, then commit BEFORE spawning the sink. Never hold a transaction while it runs.
Every success, retryable failure, and terminal failure finalization must condition its UPDATE
on pipeline_id, job_id, status == leased, and the exact claim token; accept only one updated row.
Reclaim expiry by clearing the old token and returning pending with a diagnostic.
Reject stale completion with non-zero exit, changing no state from the newer claim.
Never expose the private token through HTTP or sink requests. This is not exactly-once delivery.
worker --once attempts each job at most once per invocation and never polls for new work.
Invoke the sink with direct argv; close SQLite and subprocess resources on all paths.
Preserve passing tests and all three help paths; update README truthfully.

Tests must use fresh public commands/HTTP and tiny temporary sink scripts, not private APIs.
Cover raw-body HMAC rejection without mutation, signed/duplicate/conflicting admission,
original job order and restart persistence, declared input_refs, reversed dependency-order
selected-field fan_in, missing selections without a barrier sink call, blocking and later retry.
Add a bounded stale-worker race: block worker A, expire its one-second lease, let B finish,
then release A and require non-zero stale exit without changing B's public job state.
Assert private claim tokens never appear in HTTP or sink requests. Use explicit deadlines,
subprocess timeouts and resource cleanup. Preserve assertions; never replace workflow tests
with help-only checks or use the external oracle to construct fixtures.

The complete Case 08 specification follows:
$spec
"@
}

function Get-Case09Prompt([hashtable]$case, [object]$verification = $null) {
  $spec = [IO.File]::ReadAllText((Join-Path (Join-Path $repoRoot $case.Source) "SPEC.md"))
  $feedback = ""
  if ($null -ne $verification) {
    $oracleStatus = if ($verification.oracle.timed_out) { "timed out" } elseif (
      $verification.oracle.exit_code -eq 0
    ) { "passed" } else { "failed" }
    $feedback = "Independent acceptance oracle: $oracleStatus (diagnostic details hidden)." +
      [Environment]::NewLine + (Get-RecoveryFeedback $verification)
  }
  $guidance = if ($null -eq $verification) {
    @'
First tool call: write leasereceipt/__main__.py with the complete public workflow.
Implement the CLI, authenticated admission, durable graph, worker, fencing and receipts now.
Keep related behavior together; a compact single module or a few compact modules are allowed.
Do not import absent local modules or start a partial health-only foundation stage.
Use the embedded SPEC instead of rereading it; keep reads bounded.
Then write public-command/HTTP unittest tests, tests/__init__.py and an honest README.
Complete service, worker, tests and documentation in the same attempt.
'@
  } else {
    @'
Repair the earliest failing local test or help gate using the harness diagnostics.
Implement missing public behavior before revising test fixtures; remove absent local imports.
Preserve passing service/worker behavior, public assertions and all three help paths.
Change a test fixture only when it misuses the documented public contract; preserve assertions.
Use public commands/HTTP in tests, without assuming private function or class names.
Use one focused application edit per response, at most 100 new lines; keep reads bounded.
Continue the next source edit in the same attempt, then complete missing tests and honest README.
File presence and passing help alone do not establish workflow completeness.
'@
  }
  @"
Implement the complete dependency-free Python 3 leasereceipt project in this workspace.
The root already contains SPEC.md; use leasereceipt/ and tests/ paths directly.
Use only Python standard-library modules. Create README.md and focused unittest tests.
Work only here; do not edit SPEC.md, any rupi config or files outside the workspace.
Do not inspect or run the external acceptance oracle. Oracle diagnostics stay hidden.
Do not run commands, tests, help, service, worker or oracle; no exec or shell calls.
Use native read/write/edit tools; execution and verification belong to the harness.
The harness runs project tests, three help commands and independent acceptance each attempt.
Report verification only when supplied; preserve every public requirement and assertion.

$feedback

$guidance

Validate the full graph before atomic insertion; persist original pipeline/job order.
Resolve only declared input_refs from successful dependencies. For barriers, collect only
the selected top-level field in depends_on order. Missing selections fail locally without
a sink call and block dependents. worker --once attempts each job at most once and never polls.
The public delivery_key is exactly pipeline_id + ":" + job_id, stable across retry/reclaim/restart.
Keep this key distinct from the fresh private unguessable claim token; never expose the token.
Atomically claim, increment attempts and persist token/lease; commit BEFORE spawning the sink.
Every finalization conditions its UPDATE on pipeline/job, status leased and the exact claim token;
accept only one updated row. Reclaim clears the old token. Stale completion exits non-zero and
changes none of the newer claim's status/output/attempts/lease/error/receipt.
Send the stable delivery_key in the sink request. Accept success only with matching job_id/key,
exact ok:true, object output and non-empty receipt_id; persist exact output and matching receipt.
EOF/lost acknowledgement is retryable failure, never success and never an invented receipt.
Clear the lease, leave pending and exit non-zero; a later worker sends the same delivery key.
An idempotent sink replays its original output/receipt without repeating that key's logical effect.
This is not exactly-once delivery. Use direct argv, no shell/network and bounded resource cleanup.

Tests use fresh public commands/HTTP and tiny temporary sinks, never private APIs or the oracle.
Cover HMAC rejection without mutation, atomic/duplicate/conflicting admission, original order,
restart persistence, declared inputs, reversed selected-field fan-in, missing selections,
blocking, later retries and rejected response keys/receipts. Exercise lost-ack recovery with
a durable idempotent sink: one logical effect, two attempts, same key and original receipt/output.
Add a bounded stale-worker race: block A, expire its one-second lease, let B finish, release A,
require stale non-zero exit and no changes to B's public state/receipt. Assert private tokens
never appear in HTTP or sink requests. Use deadlines, subprocess timeouts and resource cleanup.
Preserve workflow assertions, all help paths and honest README commands/contract/exact checks.

The complete Case 09 specification follows:
$spec
"@
}

function Get-Case10Prompt([hashtable]$case, [object]$verification = $null) {
  $spec = [IO.File]::ReadAllText((Join-Path (Join-Path $repoRoot $case.Source) "SPEC.md"))
  $feedback = ""
  if ($null -ne $verification) {
    $oracleStatus = if ($verification.oracle.timed_out) { "timed out" } elseif (
      $verification.oracle.exit_code -eq 0
    ) { "passed" } else { "failed" }
    $feedback = "Independent acceptance oracle: $oracleStatus (diagnostic details hidden)." +
      [Environment]::NewLine + (Get-RecoveryFeedback $verification)
  }
  $guidance = if ($null -eq $verification) {
    @'
First tool call: write receiptledger/__main__.py with the complete public workflow.
Implement the CLI, authenticated admission, durable graph, worker, fencing, receipts and audit now.
Keep CLI, HTTP, SQLite, worker and audit behavior together in receiptledger/__main__.py.
Use a compact complete module; do not create separate app/store/storage/worker modules.
Do not import local application modules or start a partial health-only foundation stage.
Use the embedded SPEC instead of rereading it; read with offset/limit, at most 120 lines.
Then write an empty receiptledger/__init__.py, public-command/HTTP unittest tests,
tests/__init__.py and an honest README. Test helpers may live beside the public tests.
Complete service, worker, audit, tests and documentation in the same attempt.
'@
  } else {
    @'
Repair the earliest failing local test or help gate using the harness diagnostics.
Implement missing public behavior before revising test fixtures; remove absent local imports.
Preserve passing service/worker behavior, public assertions and all four help paths.
Keep the complete application in receiptledger/__main__.py; do not split or add local imports.
Change a test fixture only when it misuses the documented public contract; preserve assertions.
Use public commands/HTTP in tests, without assuming private function or class names.
When help passes but public test cases are absent, first write tests/test_receiptledger.py.
Write real public-command/HTTP workflow assertions, never placeholders or an empty test suite.
Then repair the earliest failing assertion; preserve passing checks and complete audit/receipts.
Use one focused application edit per response, at most 100 new lines; preserve other behavior.
Before the next application mutation, use at most one targeted read or grep.
Read with offset/limit, at most 120 lines; do not reread entire modules or repeatedly inspect them.
Do not replace a complete module with a partial rewrite; edit only the failing behavior.
After a completed change, continue to the next repair instead of inspecting the same region.
Continue the next source edit in the same attempt, then complete missing tests and honest README.
File presence and passing help alone do not establish workflow completeness.
'@
  }
  @"
Implement the complete dependency-free Python 3 receiptledger project in this workspace.
The root already contains SPEC.md; use receiptledger/ and tests/ paths directly.
Use only Python standard-library modules. Create README.md and focused unittest tests.
Work only here; do not edit SPEC.md, any rupi config or files outside the workspace.
Do not inspect or run the external acceptance oracle. Oracle diagnostics stay hidden.
Do not run commands, tests, help, service, worker, audit or oracle; no exec or shell calls.
Use native read/write/edit tools; execution and verification belong to the harness.
The harness runs project tests, four help commands and independent acceptance each attempt.
Report verification only when supplied; preserve every public requirement and assertion.

$feedback

$guidance

Use the actual edit diagnostic; an attempted edit is not a completed change.
If a failed edit explicitly made no change, read its target file before correcting it.
Read a small target region with offset/limit; narrow it if the response is truncated.
Use file text in edit anchors, excluding displayed line numbers and truncation markers.
Then edit the observed current text with a unique anchor and the native tool schema.
Do not guess another stale anchor or rewrite the whole application after a failed edit.
If the diagnostic says already applied, inspect the file and preserve the completed change.
For an Unknown mutation, inspect current state and defer retry until reconciliation.
After a known failure is corrected, continue public contract repairs within this attempt.
Do not end an attempt merely because an edit failed while time and requests remain.

Validate the full graph before atomic insertion; persist original pipeline/job order.
Resolve only declared input_refs from successful dependencies. For barriers, collect only
the selected top-level field in depends_on order. Missing selections fail locally without
a sink call and block dependents. worker --once attempts each job at most once and never polls.
The public delivery_key is exactly pipeline_id + ":" + job_id, stable across retry/reclaim/restart.
Keep this key distinct from the fresh private unguessable claim token; never expose the token.
Atomically claim, increment attempts and persist token/lease; commit BEFORE spawning the sink.
Every finalization conditions its UPDATE on pipeline/job, status leased and the exact claim token;
accept only one updated row. Reclaim clears the old token. Stale completion exits non-zero and
changes none of the newer claim's status/output/attempts/lease/error/receipt.
Send the stable delivery_key in the sink request. Accept success only with matching job_id/key,
exact ok:true, object output and non-empty receipt_id; persist exact output and matching receipt.
EOF/lost acknowledgement is retryable failure, never success and never an invented receipt.
Clear the lease, leave pending and exit non-zero; a later worker sends the same delivery key.
An idempotent sink replays its original output/receipt without repeating that key's logical effect.
This is not exactly-once delivery. Use direct argv, no shell/network and bounded resource cleanup.

Tests use fresh public commands/HTTP and tiny temporary sinks, never private APIs or the oracle.
Cover HMAC rejection without mutation, atomic/duplicate/conflicting admission, original order,
restart persistence, declared inputs, reversed selected-field fan-in, missing selections,
blocking, later retries and rejected response keys/receipts. Exercise lost-ack recovery with
a durable idempotent sink: one logical effect, two attempts, same key and original receipt/output.
Add a bounded stale-worker race: block A, expire its one-second lease, let B finish, release A,
require stale non-zero exit and no changes to B's public state/receipt. Assert private tokens
never appear in HTTP or sink requests. Use deadlines, subprocess timeouts and resource cleanup.
Preserve workflow assertions, all help paths and honest README commands/contract/exact checks.

Write each authoritative mutation and its corresponding audit_events append in the SAME SQLite
transaction. Admission commits pipeline/jobs/first event atomically; duplicate, invalid and
conflicting admission append nothing. Audit rows are evidence, never worker input or job state.
Include claims, reclaims, success, retryable/terminal failure and each blocked transition.
Rejected stale finalization appends only a safe operational event; never modify the newer job.
Allocate seq from1 with no gaps under the transaction; canonical event_json has sorted keys
and compact separators. Use the exact public SPEC hash expression and preserve its separator.
In that published Python literal, use the two UTF-8 bytes 0x5c,0x6e (backslash then n).
Use the same separator bytes when appending, verifying and independently recomputing in tests.
Link prev_hash to the prior event_hash, or64 zeroes for row1. Keep every bounded public kind.
Store safe public identifiers/status/attempts and concise outcomes; never secret, private token,
raw argv or arbitrary sink response bytes. Persist lost-ack observed outcome:unknown when possible.
audit --verify opens SQLite read-only and checks the FULL sequence and recomputed hash chain;
reject missing/reordered/edited rows with an actionable non-zero error, never repair/truncate.
audit --tail COUNT reads only, emits at most COUNT safe canonical objects and does not imply
verification. Neither audit path may mutate jobs/events or invoke a worker/sink.

Tests independently recompute the complete chain from the public SPEC expression and prove
admission/state/event atomicity, duplicate/invalid/conflict preservation, restart verification,
safe fields/no private tokens or raw argv, stable delivery keys across reclaims/retries,
lost-ack outcome:unknown and stale rejection with unchanged newer public state. Tamper one row
in a disposable database and require read-only verify failure without repairing/truncating it.
Test bounded tail output and all four help paths. Preserve all workflow assertions.
Use unittest.TestCase subclasses with test_ methods; helper functions alone are not tests.

The complete Case 10 specification follows:
$spec
"@
}

function Get-InitialPrompt([hashtable]$case) {
  if ($case.Id -eq "10-receipt-ledger") { return Get-Case10Prompt $case }
  if ($case.Id -eq "09-lease-receipt") { return Get-Case09Prompt $case }
  if ($case.Id -eq "08-lease-fence") { return Get-Case08Prompt $case }
  $guidance = Get-CaseGuidance $case
  $toolingGuidance = Get-WindowsToolGuidance
  $embeddedSpec = ""
  $caseSpecBlock = ""
  $specAccessOrder = if ($case.Id -eq "04-webhook-inbox") {
    'Implement the Case 04 project from the complete embedded specification.'
  } elseif ($case.Id -eq "03-event-outbox") {
    'Implement the complete service and worker from the embedded Case 03 specification.'
  } elseif ($case.Id -eq "06-artifact-pipeline") {
    'Implement Case 06 from the complete embedded specification.'
  } elseif ($case.Id -eq "07-lease-cascade") {
    'Implement Case 07 from the complete embedded specification.'
  } else {
    'Read SPEC.md completely before acting.'
  }
  if ($case.Id -in @(
      "03-event-outbox", "04-webhook-inbox", "06-artifact-pipeline", "07-lease-cascade"
    )) {
    $specPath = Join-Path (Join-Path $repoRoot $case.Source) "SPEC.md"
    $embeddedSpec = [IO.File]::ReadAllText($specPath)
    $caseName = if ($case.Id -eq "04-webhook-inbox") {
      "Case 04"
    } elseif ($case.Id -eq "06-artifact-pipeline") {
      "Case 06"
    } elseif ($case.Id -eq "07-lease-cascade") {
      "Case 07"
    } else {
      "Case 03"
    }
    $caseSpecBlock = "`nThe complete $caseName specification follows:`n`n$embeddedSpec`n"
  }
  $verificationGuidance = if ($case.Id -eq "04-webhook-inbox") {
@'
The benchmark harness independently runs project tests, all three help commands, and the
acceptance oracle after each attempt. Oracle results and diagnostics are not shown in recovery
feedback. Do not run commands, tests, help checks, the service, worker, or oracle. Use workspace
read/write tools and rely on local harness feedback for recovery.
'@
  } elseif ($case.Id -eq "02-reading-queue") {
@'
The benchmark harness runs project tests and help commands after each attempt. It also
runs the independent smoke sequence.
Do not run commands, tests, or help checks, or start the service. Use workspace
read/write tools and rely on harness feedback for recovery. Report verification only
when the harness provides its results.
'@
  } elseif ($case.Id -eq "03-event-outbox") {
@'
The benchmark harness runs project tests and help commands after each attempt.
Do not run commands, tests, or help checks, or launch the HTTP service or worker.
Use workspace read/write tools and rely on harness feedback for recovery. Report
verification only when the harness provides its results.
'@
  } elseif ($case.Id -eq "05-batch-relay") {
    (@(
      'The benchmark harness runs project tests, all three help commands, and the independent'
      'oracle after each attempt.'
      'Do not run commands, tests, help checks, or launch the HTTP service or worker.'
      'Do not call `exec` or run shell commands; rely on the harness for verification.'
      'Never inspect or run the external oracle.'
      'Use workspace read/write tools and rely on harness feedback for recovery.'
      'Report verification only when the harness provides its results.'
    ) -join [Environment]::NewLine)
  } else {
@'
Complete the smallest runnable workflow described in SPEC.md first, then add the
README and focused tests. Run the project unittest suite and project-specific help
commands described by SPEC.md, plus a small smoke check. Do not treat your final
summary as proof: report exact commands and statuses only after running them, and
state any incomplete requirement explicitly.
'@
  }
  if ($case.Id -eq "06-artifact-pipeline") {
    $verificationGuidance = @(
      'The harness runs tests, three help commands, and the oracle after every attempt.'
      'Oracle diagnostics stay hidden; recovery receives only pass or fail.'
      'Do not run commands, tests, help checks, the service, worker, or oracle.'
      'Use workspace read/write tools and the harness results.'
    ) -join [Environment]::NewLine
  } elseif ($case.Id -eq "07-lease-cascade") {
    $verificationGuidance = @(
      'The harness runs tests, three help commands, and the oracle after every attempt.'
      'Recovery receives only oracle pass/fail status; oracle diagnostics stay hidden.'
      'Do not run commands, tests, help checks, service, worker, or oracle.'
      'Use workspace read/write tools and the harness results.'
    ) -join [Environment]::NewLine
  }
  $prompt = @'
You are implementing the `{{PACKAGE}}` Python package in the current workspace.
{{SPEC_ACCESS_ORDER}} Build a complete dependency-free Python 3
project for the `{{PACKAGE}}` package described by SPEC.md, including a readable
README.md and focused unittest tests. The project focus is {{PROJECT_FOCUS}}.
{{CASE_SPEC_BLOCK}}
{{CASE_GUIDANCE}}

Work only inside this project workspace. Do not edit SPEC.md, any rupi config,
or files outside this workspace. Do not inspect or run the external acceptance
oracle. Use only Python standard-library modules.

{{WINDOWS_TOOL_GUIDANCE}}
The project directory is already the working directory; do not change
directories to its extended Windows path with `cd` or `cd /d`.

{{VERIFICATION_GUIDANCE}}
'@
  $prompt = $prompt.Replace('{{PACKAGE}}', [string]$case.Package)
  $prompt = $prompt.Replace('{{PROJECT_FOCUS}}', [string]$case.Focus)
  $prompt = $prompt.Replace('{{SPEC_ACCESS_ORDER}}', $specAccessOrder)
  $prompt = $prompt.Replace('{{CASE_SPEC_BLOCK}}', $caseSpecBlock)
  $prompt = $prompt.Replace('{{CASE_GUIDANCE}}', $guidance)
  $prompt = $prompt.Replace('{{WINDOWS_TOOL_GUIDANCE}}', $toolingGuidance)
  $prompt = $prompt.Replace('{{VERIFICATION_GUIDANCE}}', $verificationGuidance)

  $requiredInstructions = @(
    'complete dependency-free Python 3'
    'README.md and focused unittest tests'
    'The project focus is '
    'Do not inspect or run the external acceptance'
    'Use only Python standard-library modules'
    'The project directory is already the working directory'
    'use a dedicated process tool only if it is listed in your available'
    '`process` as command prefixes in a shell'
    'one executable directly through the available shell or exec tool per call'
    'Do not combine shell commands with `&`, `&&`, `;`, or `|`'
    'Do not use `python -c`'
    'write a temporary `.py` file'
    'do not read Python installation'
    'Use the available `read` tool for workspace file inspection'
    'Do not use shell commands to list or search'
    'including `dir /s`, `find`, `findstr`, `grep`, or `ls`.'
  )
  if ($case.Id -eq "04-webhook-inbox") {
    $requiredInstructions += @(
      'Implement the Case 04 project from the complete embedded specification.'
      'The complete Case 04 specification follows:'
      'Do not call read, exec, or another inspection tool before this first write.'
      'The benchmark harness independently runs project tests, all three help commands, and the'
      'acceptance oracle after each attempt.'
      'Do not run commands, tests, help checks, the service, worker, or oracle.'
    )
  } elseif ($case.Id -eq "03-event-outbox") {
    $requiredInstructions += @(
      'Implement the complete service and worker from the embedded Case 03 specification.'
      'The full Case 03 specification is embedded in this prompt.'
      'Do not call `read`, `exec`, or another inspection tool before this first write.'
    )
  } elseif ($case.Id -eq "06-artifact-pipeline") {
    $requiredInstructions += @(
      'Implement Case 06 from the complete embedded specification.'
      'The complete Case 06 specification follows:'
      'First tool call: write a runnable vertical slice in artifactpipe/__main__.py.'
    )
  } elseif ($case.Id -eq "07-lease-cascade") {
    $requiredInstructions += @(
      'Implement Case 07 from the complete embedded specification.'
      'The complete Case 07 specification follows:'
      'First tool call: write a compact, runnable CLI in leasecascade/__main__.py.'
      'Review the embedded specification as file inspection before this first source write.'
      'Use the workspace write tool; this first write must create __main__.py.'
      'Keep the first CLI write under 90 lines with top-level, serve, and worker help.'
      'Implement serve with a standard-library GET /healthz route and valid options.'
      'Defer SQLite, HMAC, pipeline state, and worker execution until the test files exist.'
      'Second write call: create tests/test_leasecascade.py with a real unittest.'
      'Keep initial tests under 60 lines; cover only imports and the three help paths.'
      'Third write call: create tests/__init__.py after the test module exists.'
      'Fourth write: create README.md under 80 lines with the public contract and exact checks.'
      'Cover commands, HMAC, routes, states, collect/fan_in, leases, sink, and persistence.'
      'Document implemented behavior honestly; keep command examples aligned with code.'
      'Each write call creates one file; write the test module before its initializer.'
      'Include an importable unittest.TestCase with at least one test_ method.'
      'Cover the three help paths with subprocess checks using sys.executable.'
      'Use native file tools and delegate all execution and verification to the harness.'
      'After the entry point, write the test module and initializer in consecutive calls.'
      'Keep all workflow code in __main__.py; do not create helper modules.'
      'Complete CLI/health, help tests, and README in this attempt; yield after four writes.'
      'Complete workflow behavior in later attempts using public-spec tests and small edits.'
      'Use standard-library imports and a main guard; do not import absent local modules.'
      'Implement signed pipeline admission and durable ordered job state.'
      'Then add worker --once with bounded leases, direct argv, and no polling.'
      'Claim runnable jobs in pipeline and job insertion order.'
      'Build barrier fan_in in declared dependency order and include only collect.field.'
      'The harness runs tests, three help commands, and the oracle after every attempt.'
      'Recovery receives only oracle pass/fail status; oracle diagnostics stay hidden.'
      'Do not run commands, tests, help checks, service, worker, or oracle.'
    )
  } else {
    $requiredInstructions += 'Read SPEC.md completely before acting'
  }
  if ($case.Id -eq "04-webhook-inbox") {
    $requiredInstructions += @(
      'The benchmark harness independently runs project tests, all three help commands, and the'
      'acceptance oracle after each attempt.'
      'First tool call: workspace write the complete webhookinbox/__main__.py implementation.'
      'Use one workspace write for all CLI, HTTP, SQLite, and worker application code.'
      'Keep the complete standard-library application in __main__.py; do not split modules.'
      'The serve command is python -m webhookinbox serve --db PATH --secret SECRET'
      'The worker command is python -m webhookinbox worker --db PATH --sink PROGRAM'
      'Include useful top-level, serve, and worker help in the implementation.'
      'Support GET /healthz, GET /deliveries/<id>, and signed POST /deliveries.'
      'Complete the runnable service before spending additional writes on README or tests.'
      'Do not call exec for shell commands.'
      'The harness independently runs project tests, three help commands, and the oracle.'
      'Do not run commands, tests, help checks, the service, worker, or oracle.'
    )
  } elseif ($case.Id -eq "02-reading-queue") {
    $requiredInstructions += @(
      'The benchmark harness runs project tests and help commands after each attempt.'
      'Do not run commands, tests, or help checks, or start the service.'
    )
  } elseif ($case.Id -eq "03-event-outbox") {
    $requiredInstructions += @(
      'The benchmark harness runs project tests and help commands after each attempt.'
      'Do not run commands, tests, or help checks, or launch the HTTP service or worker.'
    )
  } elseif ($case.Id -eq "05-batch-relay") {
    $requiredInstructions += @(
      'The benchmark harness runs project tests, all three help commands, and the independent'
      'oracle after each attempt.'
      'Do not run commands, tests, help checks, or launch the HTTP service or worker.'
      'Never inspect or run the external oracle.'
    )
  } elseif ($case.Id -eq "06-artifact-pipeline") {
    $requiredInstructions += @(
      'The harness runs tests, three help commands, and the oracle after every attempt.'
      'Oracle diagnostics stay hidden; recovery receives only pass or fail.'
      'Do not run commands, tests, help checks, the service, worker, or oracle.'
    )
  } elseif ($case.Id -eq "07-lease-cascade") {
    $requiredInstructions += @(
      'The harness runs tests, three help commands, and the oracle after every attempt.'
      'Recovery receives only oracle pass/fail status; oracle diagnostics stay hidden.'
      'Do not run commands, tests, help checks, service, worker, or oracle.'
    )
  } else {
    $requiredInstructions += @(
      'Run the project unittest suite'
      'plus a small smoke check.'
    )
  }
  foreach ($instruction in $requiredInstructions) {
    if (-not $prompt.Contains($instruction)) {
      throw "Initial benchmark prompt is missing an instruction: $instruction"
    }
  }
  if (-not $prompt.Contains([string]$case.Package)) {
    throw "Initial benchmark prompt is missing package $($case.Package)."
  }
  if (-not $prompt.Contains([string]$case.Focus)) {
    throw "Initial benchmark prompt is missing focus for $($case.Id)."
  }
  if (-not $prompt.Contains($guidance)) {
    throw "Initial benchmark prompt is missing case guidance for $($case.Id)."
  }
  if ($case.Id -in @(
      "03-event-outbox", "04-webhook-inbox", "06-artifact-pipeline", "07-lease-cascade"
    ) -and
      -not $prompt.Contains($embeddedSpec)) {
    throw "$caseName initial prompt is missing the complete project specification."
  }
  $templateTokens = @(
    '{{PACKAGE}}'
    '{{PROJECT_FOCUS}}'
    '{{SPEC_ACCESS_ORDER}}'
    '{{CASE_SPEC_BLOCK}}'
    '{{CASE_GUIDANCE}}'
    '{{WINDOWS_TOOL_GUIDANCE}}'
    '{{VERIFICATION_GUIDANCE}}'
  )
  foreach ($templateToken in $templateTokens) {
    if ($prompt.Contains($templateToken)) {
      throw "Initial benchmark prompt has an unresolved template for $($case.Id)."
    }
  }
  $unexpectedControls = @($prompt.ToCharArray() | Where-Object {
      [int]$_ -lt 32 -and [int]$_ -notin @(10, 13)
    })
  if ($unexpectedControls.Count -gt 0) {
    throw "Initial benchmark prompt has a control character for $($case.Id)."
  }

  $caseSpecificInstructions = @()
  if ($case.Id -eq "01-task-ledger") {
    $caseSpecificInstructions = @(
      '`--state PATH` must work both before'
      'the command and after a subcommand.'
      'IDs use ASCII decimal digits only and represent positive integers'
      '`+1` is invalid'
      'Make `tasklog/__main__.py` the first source file'
      '`add`, `list`, `done`, and `remove` work with persistent JSON state.'
      'focused tests for both `--state PATH` positions'
      'byte-for-byte unchanged'
    )
  } elseif ($case.Id -eq "02-reading-queue") {
    $caseSpecificInstructions = @(
      'python -m readqueue serve --db PATH --host HOST --port PORT'
      'SQLite persistence across a server restart.'
      'Call `main()` under the `__name__ == "__main__"` guard in `readqueue/__main__.py`.'
      'The documented `serve` command prints its address and keeps the service running.'
      'Keep the SQLite connection helper and all CRUD call sites consistent after a rename.'
      'After implementing the service and help behavior, write a readable `README.md`.'
      'Include the run command and examples for documented routes.'
      'Use `self.rfile` to read HTTP request bodies.'
      'It is the input stream provided by `BaseHTTPRequestHandler`.'
      'The harness independently verifies the documented routes after each attempt.'
      'Do not run commands, tests, or help checks, or start the service.'
      'Successful responses use `application/json`'
      'error responses include'
      'an `error` string and a suitable 4xx status.'
      'Duplicate URLs return 409; unknown IDs return 404; invalid requests'
      'leave existing data unchanged.'
      'focused tests for the documented routes'
    )
    if ($prompt.Contains('tasklog/__main__.py') -or $prompt.Contains('`--state PATH`')) {
      throw 'Case 02 initial prompt contains Case 01 instructions.'
    }
  } elseif ($case.Id -eq "03-event-outbox") {
    $caseSpecificInstructions = @(
      'First tool call: workspace write `outbox/__main__.py` with the service and worker.'
      'Implement CLI help, HTTP routes, SQLite persistence, and `worker --once` in that file.'
      'Do not use the first source write for CLI/help only; include the complete workflow.'
      'The full Case 03 specification is embedded in this prompt.'
      'Do not call `read`, `exec`, or another inspection tool before this first write.'
      'Use the workspace write tool for this first source file.'
      'Keep the CLI, HTTP handler, SQLite storage, and worker in `outbox/__main__.py`'
      'until the complete service and `worker --once` flow are runnable.'
      'Do not create `service.py`, `storage.py`, or `worker.py` before `__main__.py` works.'
      'On shutdown, close every SQLite connection so the database is released.'
      'The same database must reopen immediately after the server process exits on Windows.'
      'python -m outbox serve --db PATH --host HOST --port PORT'
      'python -m outbox worker --db PATH --sink PROGRAM'
      'Pass sink arguments directly, without a shell'
      'Keep `worker --once` bounded and process its pending snapshot in insertion order.'
      'Failed deliveries stay pending, increment attempts, and record a non-empty error.'
      'The benchmark harness runs project tests and help commands after each attempt.'
      'Do not run commands, tests, or help checks, or launch the HTTP service or worker.'
      'readable README and focused tests'
    )
    if ($prompt.Contains('readqueue') -or $prompt.Contains('tasklog')) {
      throw 'Case 03 initial prompt contains another case instructions.'
    }
  } elseif ($case.Id -eq "04-webhook-inbox") {
    $caseSpecificInstructions = @(
      'First tool call: workspace write the complete webhookinbox/__main__.py implementation.'
      'Use one workspace write for all CLI, HTTP, SQLite, and worker application code.'
      'Keep the complete standard-library application in __main__.py; do not split modules.'
      'The serve command is python -m webhookinbox serve --db PATH --secret SECRET'
      'The worker command is python -m webhookinbox worker --db PATH --sink PROGRAM'
      'Include useful top-level, serve, and worker help in the implementation.'
      'Support GET /healthz, GET /deliveries/<id>, and signed POST /deliveries.'
      'Verify HMAC-SHA256 over the exact raw body bytes before any database mutation.'
      'Use constant-time signature comparison; invalid signatures return 401 without writes.'
      'Valid new deliveries return 202; identical repeats return 200; conflicts return 409.'
      'The worker commits each lease before starting its sink and reclaims expired leases.'
      'Pass sink arguments directly without a shell and exchange one JSON line per delivery.'
      'Complete the runnable service before spending additional writes on README or tests.'
      'Do not call exec for shell commands.'
      'The harness independently runs project tests, three help commands, and the oracle.'
      'Do not run commands, tests, help checks, the service, worker, or oracle.'
    )
    if ($prompt.Contains('The complete Case 03 specification follows:')) {
      throw 'Case 04 initial prompt contains the Case 03 specification label.'
    }
  } elseif ($case.Id -eq "05-batch-relay") {
    $caseSpecificInstructions = @(
      'Build an import-safe CLI, health server, and one signed batch admission path.'
      'Create batchrelay/server.py with health and signed POST in the first service slice.'
      'Create a thin __main__.py CLI in the same turn; show top-level argparse help.'
      'Do not wait for CLI help to pass before implementing the HTTP routes.'
      'Keep only argparse and lazy command dispatch in __main__.py; do not put routes there.'
      'Never store database state as handler attribute `connection`.'
      '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
      'Use lazy argparse imports; server.run(db, secret, host, port) starts serve_forever().'
      'Make GET /healthz return HTTP 200 JSON {"ok": true}.'
      'Implement POST /batches for one signed batch containing one valid job.'
      'Read raw body bytes from self.rfile; verify X-Batch-Signature before JSON parsing.'
      'Require sha256=<lowercase HMAC-SHA256 hex> over raw bytes with SECRET as UTF-8 key.'
      'Use hmac.compare_digest; missing, malformed, or wrong signatures return JSON 401.'
      'Invalid signatures must not mutate SQLite; insert the valid batch and job atomically.'
      'The valid one-job POST returns 202 with a pending job and attempts=0.'
      'After route code exists, add tests/__init__.py plus CLI, server, and HTTP tests.'
      'Use subprocess tests with sys.executable for top-level, serve, and worker help.'
      'Subprocess-test serve: poll /healthz, confirm it stays alive, and clean up.'
      'Test valid signed admission; assert bad signatures do not mutate the database.'
      'Keep command imports lazy so all help commands pass before worker.py exists.'
      'Defer validation, idempotency, batch status, and worker behavior.'
      'After the signed POST and focused tests pass, update README only as SPEC.md requires.'
      'Advance only after harness project tests and all three help commands pass.'
      'Do not call `exec` or run shell commands; rely on the harness for verification.'
      'Never inspect or run the external oracle.'
    )
  } elseif ($case.Id -eq "06-artifact-pipeline") {
    $caseSpecificInstructions = @(
      'The complete Case 06 specification is embedded; do not reread SPEC.md.'
      'First tool call: write a runnable vertical slice in artifactpipe/__main__.py.'
      'Do not inspect files or run commands before this first source write.'
      ('Keep CLI, HTTP handler, and SQLite operations in __main__.py until ' +
        'the vertical slice runs.')
      'Use a guarded CLI with top-level, serve, and worker help.'
      'Implement GET /healthz and signed POST /pipelines in this first slice.'
      'Verify HMAC-SHA256 on exact raw bytes before JSON parsing.'
      'Persist accepted pipelines and jobs atomically.'
      'Add tests/__init__.py and tests/test_artifactpipe.py before worker work.'
      'Include an importable unittest.TestCase with at least one test_ method.'
      'Then complete validation, idempotency, status, and worker --once.'
      'Use ordered DAG claims, bounded leases, outputs, retries, and blocking.'
      'Invoke sinks by direct argv; resolve declared input_refs from dependencies.'
      'Finish README last; use only Python standard-library modules.'
      'The harness runs project tests, three help commands, and oracle after every attempt.'
      'Do not run commands, tests, help checks, service, worker, or oracle.'
    )
  } elseif ($case.Id -eq "07-lease-cascade") {
    $caseSpecificInstructions = @(
      'The complete Case 07 specification is embedded; do not reread SPEC.md.'
      'First tool call: write a compact, runnable CLI in leasecascade/__main__.py.'
      'Review the embedded specification as file inspection before this first source write.'
      'Use the workspace write tool; this first write must create __main__.py.'
      'Keep the first CLI write under 90 lines with top-level, serve, and worker help.'
      'Implement serve with a standard-library GET /healthz route and valid options.'
      'Defer SQLite, HMAC, pipeline state, and worker execution until the test files exist.'
      'Second write call: create tests/test_leasecascade.py with a real unittest.'
      'Keep initial tests under 60 lines; cover only imports and the three help paths.'
      'Third write call: create tests/__init__.py after the test module exists.'
      'Fourth write: create README.md under 80 lines with the public contract and exact checks.'
      'Cover commands, HMAC, routes, states, collect/fan_in, leases, sink, and persistence.'
      'Document implemented behavior honestly; keep command examples aligned with code.'
      'Each write call creates one file; write the test module before its initializer.'
      'Include an importable unittest.TestCase with at least one test_ method.'
      'Cover the three help paths with subprocess checks using sys.executable.'
      'Use native file tools and delegate all execution and verification to the harness.'
      'After the entry point, write the test module and initializer in consecutive calls.'
      'Keep all workflow code in __main__.py; do not create helper modules.'
      'Complete CLI/health, help tests, and README in this attempt; yield after four writes.'
      'Complete workflow behavior in later attempts using public-spec tests and small edits.'
      'Implement signed pipeline admission and durable ordered job state.'
      'Then add worker --once with bounded leases, direct argv, and no polling.'
      'Claim runnable jobs in pipeline and job insertion order.'
      'Build barrier fan_in in declared dependency order and include only collect.field.'
      'The harness runs tests, three help commands, and oracle after every attempt.'
      'Do not run commands, tests, help checks, service, worker, or oracle.'
    )
  }
  foreach ($instruction in $caseSpecificInstructions) {
    if (-not $prompt.Contains($instruction)) {
      throw "Initial benchmark prompt for $($case.Id) is missing: $instruction"
    }
  }
  if (
    $case.Id -in @(
      "03-event-outbox", "04-webhook-inbox", "06-artifact-pipeline", "07-lease-cascade"
    ) -and
    $prompt.Contains('Read SPEC.md completely before acting')
  ) {
    throw 'Embedded-spec prompts must not request a SPEC.md reread before the first write.'
  }
  return $prompt
}

function Get-RecoveryFeedback([object]$verification) {
  $checks = [Collections.Generic.List[object]]::new()
  [void]$checks.Add([pscustomobject]@{
    name = "project tests"
    result = $verification.project_tests
  })
  for ($index = 0; $index -lt $verification.help.Count; $index++) {
    [void]$checks.Add([pscustomobject]@{
      name = "help command {0}" -f ($index + 1)
      result = $verification.help[$index]
    })
  }

  $lines = [Collections.Generic.List[string]]::new()
  foreach ($check in $checks) {
    $result = $check.result
    $status = if ($result.timed_out) {
      "timed out"
    } elseif ($result.exit_code -eq 0) {
      "passed"
    } else {
      "failed with exit code $($result.exit_code)"
    }
    [void]$lines.Add("$($check.name): $status")
    if (-not $result.timed_out -and $result.exit_code -eq 0) { continue }

    $excerpt = ""
    foreach ($path in @($result.stderr_path, $result.stdout_path)) {
      if (-not $path -or -not (Test-Path -LiteralPath $path)) { continue }
      $outputLines = @(Get-Content -LiteralPath $path -Tail 18 -ErrorAction SilentlyContinue)
      if ($outputLines.Count -gt 0) {
        $excerpt = $outputLines -join "`n"
        break
      }
    }
    if ($excerpt.Length -gt 1200) {
      $excerpt = $excerpt.Substring($excerpt.Length - 1200)
    }
    if ($excerpt) { [void]$lines.Add("Diagnostic excerpt:`n$excerpt") }
  }
  $lines -join "`n"
}

function Get-RecoveryPrompt(
  [hashtable]$case,
  [object]$verification,
  [string]$ProjectPath = ""
) {
  if ($case.Id -eq "10-receipt-ledger") {
    return Get-Case10Prompt $case $verification
  }
  if ($case.Id -eq "09-lease-receipt") {
    return Get-Case09Prompt $case $verification
  }
  if ($case.Id -eq "08-lease-fence") {
    return Get-Case08Prompt $case $verification
  }
  $feedback = Get-RecoveryFeedback $verification
  $case04Phase = $null
  $case05Phase = $null
  $case07Phase = $null
  if ($case.Id -eq "04-webhook-inbox") {
    $projectTestsPassed = $false
    if ($verification.project_tests) {
      $projectTestsPassed = -not $verification.project_tests.timed_out -and
        $verification.project_tests.exit_code -eq 0
    }
    $helpChecksPassed = @($verification.help).Count -eq 3
    foreach ($helpCheck in @($verification.help)) {
      if ($helpCheck.timed_out -or $helpCheck.exit_code -ne 0) {
        $helpChecksPassed = $false
      }
    }
    $testsPackagePresent = $false
    $testFilesPresent = $false
    $noTestsDiscovered = $false
    $entrypointPresent = $false
    if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
      $entrypointPresent = Test-Path -LiteralPath (
        Join-Path (Join-Path $ProjectPath "webhookinbox") "__main__.py"
      )
      $testsPath = Join-Path $ProjectPath "tests"
      $testsPackagePresent = Test-Path -LiteralPath (Join-Path $testsPath "__init__.py")
      $testFilesPresent = @(
        Get-ChildItem -LiteralPath $testsPath -Filter "test_*.py" -File -EA SilentlyContinue
      ).Count -gt 0
    }
    if ($verification.project_tests -and -not $verification.project_tests.timed_out) {
      $noTestsDiscovered = $verification.project_tests.exit_code -eq 5
    }
    if (-not $entrypointPresent) {
      $case04Phase = "entrypoint"
    } elseif (-not $testsPackagePresent -or -not $helpChecksPassed) {
      $case04Phase = "interface"
    } elseif (-not $testFilesPresent -or $noTestsDiscovered) {
      $case04Phase = "tests"
    } elseif (-not $projectTestsPassed) {
      $case04Phase = "workflow"
    } else {
      $case04Phase = "finish"
    }
  } elseif ($case.Id -eq "05-batch-relay") {
    $oracleStatus = if ($verification.oracle.timed_out) {
      "timed out"
    } elseif ($verification.oracle.exit_code -eq 0) {
      "passed"
    } else {
      "failed"
    }
    $oracleStatusLine = "Independent acceptance oracle: $oracleStatus (diagnostic details hidden)."
    $feedback = "$oracleStatusLine`n$feedback"

    $projectTestsPassed = $false
    if ($verification.project_tests) {
      $projectTestsPassed = -not $verification.project_tests.timed_out -and
        $verification.project_tests.exit_code -eq 0
    }
    $helpChecksPassed = @($verification.help).Count -eq 3
    foreach ($helpCheck in @($verification.help)) {
      if ($helpCheck.timed_out -or $helpCheck.exit_code -ne 0) {
        $helpChecksPassed = $false
      }
    }

    $cliTestFilesPresent = $false
    $serverTestPresent = $false
    $httpTestPresent = $false
    $contractTestPresent = $false
    $workerTestPresent = $false
    if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
      $testsPath = Join-Path $ProjectPath "tests"
      $cliTestFilesPresent = (Test-Path -LiteralPath (Join-Path $testsPath "__init__.py")) -and
        (Test-Path -LiteralPath (Join-Path $testsPath "test_cli.py"))
      $serverTestPresent = Test-Path -LiteralPath (Join-Path $ProjectPath "tests\test_server.py")
      $httpTestPresent = Test-Path -LiteralPath (Join-Path $ProjectPath "tests\test_http.py")
      $contractTestPresent = Test-Path -LiteralPath (Join-Path $testsPath "test_contract.py")
      $workerTestPresent = Test-Path -LiteralPath (Join-Path $ProjectPath "tests\test_worker.py")
    }

    if (-not $cliTestFilesPresent -or -not $helpChecksPassed) {
      $case05Phase = "foundation"
    } elseif (-not $projectTestsPassed) {
      $case05Phase = if ($workerTestPresent) {
        "worker"
      } elseif ($contractTestPresent) {
        "contract"
      } elseif ($httpTestPresent) {
        "admission"
      } elseif ($serverTestPresent) {
        "health"
      } else {
        "foundation"
      }
    } elseif (-not $serverTestPresent) {
      $case05Phase = "health"
    } elseif (-not $httpTestPresent) {
      $case05Phase = "admission"
    } elseif (-not $contractTestPresent) {
      $case05Phase = "contract"
    } elseif (-not $workerTestPresent) {
      $case05Phase = "worker"
    } else {
      $case05Phase = "finish"
    }
  } elseif ($case.Id -eq "07-lease-cascade") {
    $oracleStatus = if ($verification.oracle.timed_out) {
      "timed out"
    } elseif ($verification.oracle.exit_code -eq 0) {
      "passed"
    } else {
      "failed"
    }
    $feedback = "Independent acceptance oracle: $oracleStatus (diagnostic details hidden)." +
      [Environment]::NewLine + $feedback

    $projectTestsPassed = $verification.project_tests -and
      -not $verification.project_tests.timed_out -and
      $verification.project_tests.exit_code -eq 0
    $helpChecksPassed = @($verification.help).Count -eq 3
    foreach ($helpCheck in @($verification.help)) {
      if ($helpCheck.timed_out -or $helpCheck.exit_code -ne 0) {
        $helpChecksPassed = $false
      }
    }
    $entrypointPresent = $false
    $testPackagePresent = $false
    $testModulePresent = $false
    $noTestsDiscovered = $false
    if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
      $entrypointPresent = Test-Path -LiteralPath (
        Join-Path (Join-Path $ProjectPath "leasecascade") "__main__.py"
      )
      $testsPath = Join-Path $ProjectPath "tests"
      $testPackagePresent = Test-Path -LiteralPath (Join-Path $testsPath "__init__.py")
      $testModulePresent = Test-Path -LiteralPath (Join-Path $testsPath "test_leasecascade.py")
    }
    if ($verification.project_tests -and -not $verification.project_tests.timed_out) {
      $noTestsDiscovered = $verification.project_tests.exit_code -eq 5
    }

    if (-not $entrypointPresent) {
      $case07Phase = "entrypoint"
    } elseif (-not $testPackagePresent -or -not $testModulePresent -or
        $noTestsDiscovered -or -not $helpChecksPassed) {
      $case07Phase = "foundation"
    } elseif (-not $projectTestsPassed) {
      $case07Phase = "local"
    } elseif ($oracleStatus -eq "passed") {
      $case07Phase = "passed"
    } else {
      $case07Phase = "workflow"
    }
  }
  $toolingGuidance = Get-WindowsToolGuidance
  $caseGuidance = if ($case.Id -eq "04-webhook-inbox") {
    Get-CaseGuidance $case $case04Phase
  } elseif ($case.Id -eq "05-batch-relay") {
    Get-CaseGuidance $case $case05Phase
  } elseif ($case.Id -eq "07-lease-cascade") {
    Get-CaseGuidance $case $case07Phase
  } else {
    Get-CaseGuidance $case
  }
  $verificationResultLabel = if ($case.Id -eq "05-batch-relay") {
    'Previous harness results (oracle status, project tests, and help commands):'
  } elseif ($case.Id -eq "07-lease-cascade") {
    'Previous harness results (oracle status, project tests, and three help commands):'
  } else {
    'Previous local verification results (project tests and help commands):'
  }
  $recoveryHeader = if ($case.Id -eq "04-webhook-inbox") {
    'The complete Case 04 specification was embedded in the initial prompt; do not reread it. ' +
      'Inspect existing files and preserve working behavior. Use only local tests and help ' +
      'feedback; do not inspect oracle results. Work only in this workspace.'
  } elseif ($case.Id -eq "05-batch-relay") {
    $phaseHeader = switch ($case05Phase) {
      "foundation" {
        'CLI and test-discovery did not pass. Fix them before server, HTTP, or worker code.'
      }
      "health" {
        'CLI and test discovery passed. Implement health and signed admission together.'
      }
      "admission" {
        'CLI and server health passed. Complete and verify signed batch admission.'
      }
      "contract" {
        'HTTP tests exist; keep server routes in batchrelay/server.py and refine signed admission.'
      }
      "worker" {
        'The HTTP contract passed. Complete worker behavior while preserving prior slices.'
      }
      default {
        'CLI, health, HTTP, and worker tests exist; local tests and help all pass.'
      }
    }
    'Use SPEC.md read in the initial turn; do not reread it. ' +
      'Inspect existing files and preserve passing behavior. ' +
      $phaseHeader + ' ' +
      'Work only in this workspace; do not edit the specification, config, or oracle.'
  } elseif ($case.Id -eq "07-lease-cascade") {
    if ($case07Phase -eq "entrypoint") {
      'The complete Case 07 specification was embedded initially; do not reread it. ' +
        'No runnable entrypoint exists. Write `leasecascade/__main__.py` before inspection. ' +
        'Use oracle pass/fail only; work in this workspace and do not inspect or run the oracle.'
    } elseif ($case07Phase -eq "workflow") {
      'The complete Case 07 specification was embedded initially; do not reread it. ' +
        'Tests and all three help commands pass. Use prior turn context for small source edits. ' +
        'Read the intended source or test file once if an exact edit anchor is unknown. ' +
        'Use oracle pass/fail only; ' +
        'work in this workspace and do not inspect or run the oracle.'
    } else {
      'The complete Case 07 specification was embedded initially; do not reread it. ' +
        'Inspect existing files, preserve working behavior, and use oracle pass/fail only. ' +
        'Work only in this workspace; do not inspect or run the oracle.'
    }
  } else {
    "Read SPEC.md and inspect the files already present. Work only inside this" +
      [Environment]::NewLine +
      "workspace and do not edit the specification, rupi configs, or the external" +
      [Environment]::NewLine + "acceptance oracle."
  }
  $verificationGuidance = if ($case.Id -eq "04-webhook-inbox") {
@'
The benchmark harness reruns project tests and all three help commands after this attempt.
It runs the acceptance oracle independently; its result and diagnostics are not shown here.
Do not run commands, tests, help checks, the service, worker, or oracle. Use local test and help
feedback to edit source files, then rely on the harness for verification.
'@
  } elseif ($case.Id -eq "02-reading-queue") {
@'
The benchmark harness reruns tests, help commands, and the independent smoke sequence
after this attempt. Do not run commands, tests, or help checks, or start the service.
Use the diagnostic excerpts above to inspect and edit source files, then rely on the
harness for verification.
'@
  } elseif ($case.Id -eq "03-event-outbox") {
@'
The benchmark harness reruns project tests and help commands after this attempt.
Do not run commands, tests, or help checks, or launch the HTTP service or worker.
Use the diagnostic excerpts above to inspect and edit source files, then rely on the
harness for verification.
'@
  } elseif ($case.Id -eq "05-batch-relay") {
    (@(
      'The harness reruns project tests, all three help commands, and the independent oracle after'
      'each attempt. Recovery feedback gives only the oracle pass/fail status.'
      'Feedback also includes project-test and help results.'
      'Oracle diagnostics stay hidden; use local diagnostics and the initial SPEC.md read.'
      'Do not run tests or help commands; do not launch service, worker, or oracle.'
      'Do not call `exec` or run shell commands; rely on the harness for verification.'
      'Never inspect or run the oracle. Use workspace read/write tools and harness results.'
    ) -join [Environment]::NewLine)
  } elseif ($case.Id -eq "07-lease-cascade") {
    (@(
      'The harness reruns tests, all three help commands, and the independent oracle after each'
      'attempt. Recovery receives only oracle pass/fail status; diagnostics stay hidden.'
      'Use the local test/help diagnostics and initial embedded specification.'
      'Do not run commands, tests, help checks, service, worker, or oracle.'
      'Use workspace read/write tools and rely on harness feedback for verification.'
    ) -join [Environment]::NewLine)
  } else {
@'
Continue working through the missing items in SPEC.md, then run the complete project
unittest suite, the project-specific help commands, and a smoke sequence.
'@
  }
  $completionDirective = if ($case.Id -eq "04-webhook-inbox") {
    'Complete this phase while preserving working admission and CLI behavior.'
  } elseif ($case.Id -eq "05-batch-relay") {
    'Complete this slice; advance after project tests and help pass.'
  } elseif ($case.Id -eq "07-lease-cascade") {
    switch ($case07Phase) {
      "entrypoint" {
        ('Complete a compact entry point, help tests, and README in this attempt; ' +
          'yield after the four foundation writes.')
      }
      "foundation" {
        'Fix failed help paths and ensure unittest discovery works before worker expansion.'
      }
      "local" { 'Repair the shown project-test failure before expanding behavior.' }
      "passed" { 'The oracle passed; preserve behavior and finish only missing spec items.' }
      default {
        ('If workflow tests are missing, add tests and ' +
          'yield for harness feedback. Otherwise continue small implementation edits; ' +
          'preserve passing tests and help.')
      }
    }
  } else {
    'Finish every missing implementation, README section, and focused test required by the spec.'
  }
  $continuationDirective = if ($case.Id -eq "04-webhook-inbox") {
    'Continue from local test and help feedback; oracle results remain hidden.'
  } elseif ($case.Id -eq "05-batch-relay") {
    'Use failing local checks to repair this slice. Oracle status only; do not inspect or run it.'
  } elseif ($case.Id -eq "07-lease-cascade") {
    'Use local test/help feedback and oracle pass/fail only; never inspect or run the oracle.'
  } else {
    'Continue working through the missing items in SPEC.md.'
  }
  $priorityDirective = if ($case.Id -eq "04-webhook-inbox") {
    if ($case04Phase -eq "entrypoint") {
      'Prioritize one complete __main__.py workspace write.'
    } elseif ($case04Phase -eq "interface") {
      'Prioritize all three help commands and importable test discovery.'
    } elseif ($case04Phase -eq "tests") {
      'Prioritize one real discovered unittest, then continue remaining requirements.'
    } elseif ($case04Phase -eq "workflow") {
      'Prioritize the failing local tests and the complete worker delivery flow.'
    } else {
      'Prioritize any remaining requirements in the embedded specification.'
    }
  } elseif ($case.Id -eq "05-batch-relay") {
    'Prioritize the current gated phase.'
  } elseif ($case.Id -eq "07-lease-cascade") {
    switch ($case07Phase) {
      "entrypoint" {
        ('Write CLI/health in __main__.py, then both test files and README; ' +
          'stop after those four writes and wait for harness feedback.')
      }
      "foundation" {
        ('Fix failed help paths and create tests/__init__.py plus ' +
          'tests/test_leasecascade.py with a discoverable unittest.')
      }
      "local" {
        'Use the shown project-test diagnostic to make the smallest repair.'
      }
      "passed" {
        'Preserve the oracle-passing workflow; finish any missing README or spec requirements.'
      }
      default {
        ('If workflow tests are missing, edit ' +
          'tests/test_leasecascade.py next. Otherwise add the next missing behavior in ' +
          '__main__.py with at most 80 new lines.')
      }
    }
  } else {
    "Prioritize the full reliability contract: $($case.Focus)."
  }
  if ($case.Id -eq "06-artifact-pipeline") {
    $oracleStatus = if ($verification.oracle.timed_out) {
      "timed out"
    } elseif ($verification.oracle.exit_code -eq 0) {
      "passed"
    } else {
      "failed"
    }
    $feedback = "Independent acceptance oracle: $oracleStatus (diagnostic details hidden)." +
      [Environment]::NewLine + $feedback
    $caseGuidance = Get-CaseGuidance $case "recovery"
    $verificationResultLabel =
      'Previous harness results (oracle, project tests, and three help commands):'
    $recoveryHeader =
      'The full Case 06 spec was embedded initially; do not reread it. ' +
      'Preserve working CLI/server behavior. Use local test/help feedback and ' +
      'oracle pass/fail only.'
    $verificationGuidance = @(
      'The harness reruns tests, three help commands, and oracle after every attempt.'
      'Recovery shows oracle pass/fail only and hides diagnostic output.'
      'When the app exists but the test module is missing, make discovery the only task.'
      'Create tests/__init__.py and tests/test_artifactpipe.py in one workspace write.'
      ('Add a unittest.TestCase.test_entrypoint_importable method that imports ' +
        'artifactpipe.__main__ and asserts it is not None.')
      'Do not run commands, tests, help checks, service, worker, or oracle.'
      'Use local test/help feedback to make changes, then rely on the harness.'
    ) -join [Environment]::NewLine
    $appPresent = $false
    $testModulePresent = $false
    $failedHelpChecks = @(
      $verification.help | Where-Object { $_.exit_code -ne 0 }
    )
    $allHelpPassed = $verification.help.Count -eq 3 -and
      $failedHelpChecks.Count -eq 0
    if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
      $appPresent = Test-Path -LiteralPath (Join-Path $ProjectPath "artifactpipe\__main__.py")
      $testModulePresent = Test-Path -LiteralPath (
        Join-Path (Join-Path $ProjectPath "tests") "test_artifactpipe.py"
      )
    }
    if (-not $appPresent) {
      $completionDirective = 'Write the runnable CLI/health/signed-admission slice first.'
      $priorityDirective = 'Prioritize a working entry point and all three help paths.'
    } elseif (-not $testModulePresent) {
      $completionDirective =
        'Complete only test discovery in this recovery turn; do not expand app behavior.'
      $priorityDirective =
        ('Use one write for tests/__init__.py and tests/test_artifactpipe.py; add a ' +
          'discoverable unittest.TestCase test_entrypoint_importable method.')
    } elseif ($verification.project_tests.exit_code -eq 5) {
      $completionDirective =
        ('Project-test discovery exited 5; make test_artifactpipe.py importable ' +
          'with a test_ method.')
      $priorityDirective =
        'Prioritize discoverable tests, then preserve the passing CLI and server.'
    } elseif ($verification.project_tests.exit_code -eq 0 -and
        $allHelpPassed -and -not $verification.resolved) {
      $completionDirective =
        'With tests and help passing, close the remaining end-to-end DAG gap.'
      $priorityDirective =
        ('Implement the signed DAG end to end: admit the declared graph, run jobs in ' +
          'dependency order, and resolve downstream scalar references from upstream JSON output.')
    } else {
      $completionDirective =
        'Continue from project-test/help feedback; implement the smallest missing slice.'
      $priorityDirective =
        'Prioritize signed admission, declared output references, and worker transitions.'
    }
    $continuationDirective =
      'Preserve the passing CLI and server; use oracle pass/fail only, never its diagnostics.'
  }
  $prompt = @"
Continue the incomplete $($case.Package) implementation in this workspace.
$recoveryHeader
$completionDirective $priorityDirective

$caseGuidance

Use only Python standard-library modules.
$toolingGuidance

$verificationResultLabel
$feedback

Use any failing local results above to correct the implementation.
$continuationDirective
$verificationGuidance
If anything remains incomplete, state it instead of claiming success.
"@
  if ($case.Id -eq "07-lease-cascade") {
    $case07SpecPath = Join-Path (Join-Path $repoRoot $case.Source) "SPEC.md"
    $case07Spec = [IO.File]::ReadAllText($case07SpecPath)
    $editRecovery = @(
      'Use the actual edit diagnostic; an attempted edit is not a completed change.'
      'If a failed edit explicitly made no change, read its target file before correcting it.'
      'Read a small target region with offset/limit; narrow it if the response is truncated.'
      'Use file text in edit anchors, excluding displayed line numbers and truncation markers.'
      'Then edit the observed current text with a unique anchor and the native tool schema.'
      'Do not guess another stale anchor or rewrite the whole application after a failed edit.'
      'If the diagnostic says already applied, inspect the file and preserve the completed change.'
      'For an Unknown mutation, inspect current state and defer retry until reconciliation.'
      'After a known failure is corrected, continue public contract repairs within this attempt.'
      'Do not end an attempt merely because an edit failed while time and requests remain.'
    ) -join [Environment]::NewLine
    $prompt = 'The complete Case 07 specification for this recovery follows:' +
      [Environment]::NewLine + [Environment]::NewLine + $case07Spec +
      [Environment]::NewLine + $editRecovery + [Environment]::NewLine + $prompt
  }
  $requiredInstructions = @(
    'use a dedicated process tool only if it is listed in your available'
    '`process` as command prefixes in a shell'
    'one executable directly through the available shell or exec tool per call'
    'Do not combine shell commands with `&`, `&&`, `;`, or `|`'
    'Do not use `python -c`'
    'write a temporary `.py` file'
    'do not read Python installation'
    'Use the available `read` tool for workspace file inspection'
  )
  foreach ($instruction in $requiredInstructions) {
    if (-not $prompt.Contains($instruction)) {
      throw "Recovery benchmark prompt is missing Windows tool guidance: $instruction"
    }
  }
  if (-not $prompt.Contains($caseGuidance)) {
    throw "Recovery benchmark prompt is missing case guidance for $($case.Id)."
  }
  if ($case.Id -eq "02-reading-queue" -and
      -not $prompt.Contains('Do not run commands, tests, or help checks, or start the service.')) {
    throw 'Case 02 recovery prompt must defer execution and verification to the harness.'
  }
  if ($case.Id -eq "03-event-outbox" -and
      -not $prompt.Contains(
        'Do not run commands, tests, or help checks, or launch the HTTP service or worker.')) {
    throw 'Case 03 recovery prompt must defer execution and verification to the harness.'
  }
  if ($case.Id -eq "04-webhook-inbox") {
    $phaseInstructions = switch ($case04Phase) {
      "entrypoint" {
        @(
          'The current file snapshot has no webhookinbox/__main__.py; create that file first.'
          'Use one workspace write for the complete standard-library application in that file.'
          'Implement the HTTP contract, durable SQLite behavior, and worker lease flow.'
          'Implement argparse subcommands for serve and worker so all three help commands work.'
          'Use the exact serve and worker command forms from the embedded specification.'
          'Add the main guard; do not split application behavior into support modules.'
        )
      }
      "interface" {
        @(
          'The entrypoint exists, but CLI help or test discovery is not ready; fix those first.'
          'Make python -m webhookinbox --help succeed, along with serve --help and worker --help.'
          'Create tests/__init__.py and tests/test_cli.py with subprocess checks for all three'
          'help paths using sys.executable, including at least one unittest method named test_*.'
          'Do not split modules; first make discovery and all help commands succeed.'
        )
      }
      "tests" {
        @(
          'All help commands and the test package are present, but unittest discovered no tests.'
          'Create tests/test_cli.py with a unittest.TestCase and at least one test_* method.'
          'Add a useful subprocess check for the top-level, serve, or worker help command.'
          'Keep the existing application behavior intact; do not add only a helper module.'
          'After adding a discovered test, continue any unfinished worker or README requirements.'
        )
      }
      "workflow" {
        @(
          'CLI help and test discovery are ready.'
          'Use local project-test diagnostics to repair'
          'failures while implementing the complete worker and remaining Case 04 requirements.'
          'Commit each delivery lease before starting its sink; reclaim expired leases in order.'
          'Add focused worker and HTTP tests, then complete the required README.'
        )
      }
      default {
        @(
          'Local project tests, test discovery, and all three help commands pass.'
          'Inspect the existing implementation against the embedded specification.'
          'Finish any missing worker lease'
          'requirements while preserving passing behavior.'
        )
      }
    }
    $commonInstructions = @(
      'The complete Case 04 specification was embedded in the initial prompt; do not reread it.'
      'The benchmark harness reruns project tests and all three help commands after this attempt.'
      'It runs the acceptance oracle independently; its result and diagnostics are not shown here.'
      'Do not run commands, tests, help checks, the service, worker, or oracle.'
      'Continue from local test and help feedback; oracle results remain hidden.'
    )
    foreach ($instruction in @($commonInstructions) + @($phaseInstructions)) {
      if (-not $prompt.Contains($instruction)) {
        throw "Case 04 recovery prompt is missing: $instruction"
      }
    }
    if ($prompt.Contains('Read SPEC.md and inspect the files already present.')) {
      throw 'Case 04 recovery prompt must rely on the embedded specification.'
    }
  }
  if ($case.Id -eq "05-batch-relay") {
    $phaseInstruction = switch ($case05Phase) {
      "foundation" { 'CLI and test-discovery did not pass.' }
      "health" { 'CLI and test discovery passed.' }
      "admission" { 'CLI and server health passed.' }
      "contract" { 'HTTP tests exist;' }
      "worker" { 'The HTTP contract passed.' }
      default { 'CLI, health, HTTP, and worker tests exist' }
    }
    if (-not $prompt.Contains('do not reread it.') -or
        -not $prompt.Contains('Recovery feedback gives only the oracle pass/fail status.') -or
        -not $prompt.Contains('Never store database state as handler attribute `connection`.') -or
        -not $prompt.Contains(
          '`BaseHTTPRequestHandler` reserves `connection` for the client socket.') -or
        -not $prompt.Contains($phaseInstruction) -or
        -not $prompt.Contains(
          'Complete this slice; advance after project tests and help pass.') -or
        -not $prompt.Contains(
          'Do not run tests or help commands; do not launch service, worker, or oracle.') -or
        -not $prompt.Contains(
          'Do not call `exec` or run shell commands; rely on the harness for verification.') -or
        $prompt.Contains('Read SPEC.md and inspect the files already present.')) {
      throw 'Case 05 recovery prompt must select a gated slice and defer verification.'
    }
  }
  if ($case.Id -eq "06-artifact-pipeline") {
    $recoveryRequirements = @(
      'Independent acceptance oracle: '
      '(diagnostic details hidden).'
      'The full Case 06 spec was embedded initially; do not reread it.'
      'Recovery shows oracle pass/fail only and hides diagnostic output.'
      'When the app exists but the test module is missing, make discovery the only task.'
      'Create tests/__init__.py and tests/test_artifactpipe.py in one workspace write.'
      ('Add a unittest.TestCase.test_entrypoint_importable method that imports ' +
        'artifactpipe.__main__ and asserts it is not None.')
      ('If project-test discovery exits 5, add tests/test_artifactpipe.py with a ' +
        'TestCase and test_ method.')
      'Do not run commands, tests, help checks, service, worker, or oracle.'
    )
    foreach ($requirement in $recoveryRequirements) {
      if (-not $prompt.Contains($requirement)) {
        throw "Case 06 recovery prompt is missing: $requirement"
      }
    }
  }
  if ($case.Id -eq "07-lease-cascade") {
    $recoveryHeaderRequirement = if ($case07Phase -eq "entrypoint") {
      'No runnable entrypoint exists. Write `leasecascade/__main__.py` before inspection.'
    } elseif ($case07Phase -eq "workflow") {
      'Read the intended source or test file once if an exact edit anchor is unknown.'
    } else {
      'Inspect existing files, preserve working behavior, and use oracle pass/fail only.'
    }
    $recoveryRequirements = @(
      'Independent acceptance oracle: '
      '(diagnostic details hidden).'
      'The complete Case 07 specification was embedded initially; do not reread it.'
      $recoveryHeaderRequirement
      'Recovery receives only oracle pass/fail status; diagnostics stay hidden.'
      'Use local test/help feedback and oracle pass/fail only; never inspect or run the oracle.'
      'Do not run commands, tests, help checks, service, worker, or oracle.'
      $completionDirective
      $priorityDirective
    )
    foreach ($requirement in $recoveryRequirements) {
      if (-not $prompt.Contains($requirement)) {
        throw "Case 07 recovery prompt is missing: $requirement"
      }
    }
    if ($prompt.Contains('Read SPEC.md and inspect the files already present.')) {
      throw 'Case 07 recovery prompt must use the embedded spec and phase guidance.'
    }
  }
  return $prompt
}

function Write-Text([string]$path, [string]$text) {
  $parent = Split-Path -Parent $path
  if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
  [IO.File]::WriteAllText($path, $text, [Text.UTF8Encoding]::new($false))
}

function Write-Json([string]$path, [object]$value) {
  Write-Text $path ($value | ConvertTo-Json -Depth 60)
}

function Invoke-External {
  param(
    [Parameter(Mandatory)] [string]$FileName,
    [Parameter(Mandatory)] [string[]]$Arguments,
    [Parameter(Mandatory)] [string]$WorkingDirectory,
    [Parameter(Mandatory)] [string]$StdoutPath,
    [Parameter(Mandatory)] [string]$StderrPath,
    [int]$TimeoutSeconds = 300,
    [hashtable]$Environment = @{}
  )

  $psi = [Diagnostics.ProcessStartInfo]::new()
  $psi.FileName = $FileName
  $psi.WorkingDirectory = $WorkingDirectory
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true
  $psi.RedirectStandardInput = $true
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  foreach ($argument in $Arguments) {
    [void]$psi.ArgumentList.Add($argument)
  }
  foreach ($entry in $Environment.GetEnumerator()) {
    if ($null -eq $entry.Value) {
      [void]$psi.Environment.Remove($entry.Key)
    } else {
      $psi.Environment[$entry.Key] = [string]$entry.Value
    }
  }

  $process = [Diagnostics.Process]::new()
  $process.StartInfo = $psi
  $started = [Diagnostics.Stopwatch]::StartNew()
  [void]$process.Start()
  $process.StandardInput.Close()
  $stdoutTask = $process.StandardOutput.ReadToEndAsync()
  $stderrTask = $process.StandardError.ReadToEndAsync()
  $timedOut = -not $process.WaitForExit($TimeoutSeconds * 1000)
  if ($timedOut) {
    & taskkill.exe /PID $process.Id /T /F 2>$null | Out-Null
    [void]$process.WaitForExit(10000)
  }
  $stdout = $stdoutTask.GetAwaiter().GetResult()
  $stderr = $stderrTask.GetAwaiter().GetResult()
  $started.Stop()
  Write-Text $StdoutPath $stdout
  Write-Text $StderrPath $stderr
  $exitCode = if ($timedOut) { $null } else { $process.ExitCode }
  $process.Dispose()
  [pscustomobject]@{
    exit_code = $exitCode
    timed_out = $timedOut
    elapsed_ms = $started.ElapsedMilliseconds
    stdout_path = $StdoutPath
    stderr_path = $StderrPath
  }
}

function Get-BenchmarkReasoningBudget([hashtable]$case) {
  if ($case.Id -eq "07-lease-cascade") { return $Case07ReasoningBudgetTokens }
  if ($case.Id -eq "08-lease-fence") { return $Case08ReasoningBudgetTokens }
  if ($case.Id -eq "09-lease-receipt") { return $Case09ReasoningBudgetTokens }
  if ($case.Id -eq "10-receipt-ledger") { return $Case10ReasoningBudgetTokens }
  return 0
}

function Get-BenchmarkMaxOutputTokens([hashtable]$case) {
  if ($case.Id -eq "10-receipt-ledger") { return $Case10MaxOutputTokens }
  return 16384
}

function Get-BenchmarkProgressControl([hashtable]$case) {
  if ($case.Id -eq "10-receipt-ledger") {
    return [pscustomobject]@{
      mode = $Case10ProgressBoundaryMode
      window = $Case10ProgressRequestWindow
    }
  }
  if ($case.Id -eq "08-lease-fence") {
    return [pscustomobject]@{
      mode = $Case08ProgressBoundaryMode
      window = $Case08ProgressRequestWindow
    }
  }
  if ($case.Id -eq "09-lease-receipt") {
    return [pscustomobject]@{
      mode = $Case09ProgressBoundaryMode
      window = $Case09ProgressRequestWindow
    }
  }
  return $null
}

function Set-BenchmarkProgressBoundary([hashtable]$case, [object]$limits) {
  $control = Get-BenchmarkProgressControl $case
  if ($null -eq $control) { return }
  $limits | Add-Member -MemberType NoteProperty -Name progress_boundary_mode -Force `
    -Value $control.mode
  $limits | Add-Member -MemberType NoteProperty -Name max_model_requests_without_progress -Force `
    -Value $control.window
}

function Get-BenchmarkEndpoint([hashtable]$case) {
  if ((Get-BenchmarkReasoningBudget $case) -gt 0) {
    if ($case.Id -eq "10-receipt-ledger") {
      return "http://127.0.0.1:$Case10ReasoningRelayPort/v1"
    }
    return "http://127.0.0.1:8001/v1"
  }
  return "http://127.0.0.1:8000/v1"
}

function Get-BenchmarkTools([hashtable]$case, [string]$agent) {
  if ($case.Id -in @("07-lease-cascade", "08-lease-fence",
      "09-lease-receipt", "10-receipt-ledger")) {
    if ($agent -eq "rupi") { return @("read", "write", "edit", "grep") }
    return @("read", "write", "edit", "grep", "find", "ls")
  }
  if ($agent -eq "pi") {
    return @("read", "write", "edit", "bash", "powershell", "grep", "find", "ls")
  }
  return @()
}

function Get-BenchmarkEnvironment([hashtable]$case, [string]$agent, [string]$agentRoot) {
  if ($case.Id -notin @("07-lease-cascade", "08-lease-fence",
      "09-lease-receipt", "10-receipt-ledger") -or
      $agent -ne "rupi") {
    return @{}
  }
  return @{
    HOME = $null
    USERPROFILE = (Join-Path $agentRoot "discovery-profile")
  }
}

function Set-BenchmarkReasoningCompatibility([hashtable]$case, [object]$endpoint) {
  if ($case.Id -notin @("07-lease-cascade", "08-lease-fence",
      "09-lease-receipt", "10-receipt-ledger")) { return }
  if ($null -eq $endpoint.capabilities -or
      $endpoint.capabilities.exposed_reasoning -cne "native") {
    $caseName = "Case " + $case.Id.Substring(0, 2)
    throw "$caseName reasoning replay requires an explicit native exposure claim."
  }
  if ($null -eq $endpoint.PSObject.Properties["openai_compat"] -or
      $null -eq $endpoint.openai_compat) {
    $endpoint | Add-Member -MemberType NoteProperty -Name openai_compat -Force -Value (
      [pscustomobject]@{}
    )
  }
  $endpoint.openai_compat | Add-Member -MemberType NoteProperty -Name thinking_input -Force `
    -Value "reasoning_effort"
  $endpoint.openai_compat | Add-Member -MemberType NoteProperty -Name thinking_disable -Force `
    -Value "reasoning_effort_none"
  $endpoint.openai_compat | Add-Member -MemberType NoteProperty -Name preserve_reasoning -Force `
    -Value $true
}

function New-BenchmarkWorkspace([hashtable]$case, [string]$agentRoot, [string]$thinkingLevel) {
  $source = Join-Path $repoRoot $case.Source
  $project = Join-Path $agentRoot $case.ProjectDir
  New-Item -ItemType Directory -Force -Path $project | Out-Null
  foreach ($name in @(".gitignore", "SPEC.md")) {
    $sourcePath = Join-Path $source $name
    if (Test-Path $sourcePath) { Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $project $name) }
  }
  Get-ChildItem -LiteralPath $source -File -Filter "rupi*.config.json" | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $project $_.Name)
  }
  $acceptanceSource = Join-Path (Split-Path $source -Parent) "acceptance"
  Copy-Item -LiteralPath $acceptanceSource -Destination (Join-Path $agentRoot "acceptance") -Recurse

  $configPath = Join-Path $project "rupi.benchmark.config.json"
  $configSourcePath = Join-Path $project "rupi.config.json"
  if (Test-Path $configSourcePath) {
    $config = Get-Content -Raw $configSourcePath | ConvertFrom-Json
    $config.thinking = $thinkingLevel
    $config.state_dir = ".rupi-state"
    if ($case.Id -in @("07-lease-cascade", "08-lease-fence",
      "09-lease-receipt", "10-receipt-ledger")) {
      if ($null -eq $config.tools) {
        $config | Add-Member -MemberType NoteProperty -Name tools -Value ([pscustomobject]@{})
      }
      $config.tools | Add-Member -MemberType NoteProperty -Name allow -Force -Value @(
        Get-BenchmarkTools $case "rupi"
      )
    }
    if ($null -eq $config.limits) {
      $config | Add-Member -MemberType NoteProperty -Name limits -Value ([pscustomobject]@{})
    }
    Set-BenchmarkProgressBoundary $case $config.limits
    if ($case.Id -eq "10-receipt-ledger" -and $Case10InitialProgressBoundary) {
      $config.limits | Add-Member -MemberType NoteProperty -Force `
        -Name initial_progress_boundary -Value $true
    }
    if ($case.Id -eq "10-receipt-ledger" -and $Case10MaxTurnDurationMs -gt 0) {
      $config.limits | Add-Member -MemberType NoteProperty -Force `
        -Name max_turn_duration_ms -Value $Case10MaxTurnDurationMs
    }
    if ($case.Id -eq "10-receipt-ledger" -and $Case10ReviewCompletion) {
      $config.limits | Add-Member -MemberType NoteProperty -Force `
        -Name review_completion -Value $true
    }
    if ($case.Id -eq "10-receipt-ledger" -and $Case10CompletionReviewReserveMs -gt 0) {
      $config.limits | Add-Member -MemberType NoteProperty -Force `
        -Name completion_review_reserve_ms -Value $Case10CompletionReviewReserveMs
    }
    if ($null -eq $config.limits.PSObject.Properties["max_model_requests_per_turn"]) {
      $config.limits | Add-Member -MemberType NoteProperty -Name max_model_requests_per_turn -Value $MaxModelRequestsPerTurn
    } else {
      $config.limits.max_model_requests_per_turn = $MaxModelRequestsPerTurn
    }
    if ($config.endpoints -and $config.endpoints.Count -gt 0) {
      Set-BenchmarkReasoningCompatibility $case $config.endpoints[0]
      if ((Get-BenchmarkReasoningBudget $case) -gt 0) {
        $config.endpoints[0].base_url = Get-BenchmarkEndpoint $case
      }
      if ($config.endpoints[0].capabilities) {
        $config.endpoints[0].capabilities.max_output_tokens = Get-BenchmarkMaxOutputTokens $case
      }
      # Let the runtime handle its provider timeout before the outer turn watchdog stops it.
      $reqTimeout = $script:providerRequestTimeoutMs
      if ($null -eq $config.endpoints[0].PSObject.Properties["request_timeout_ms"]) {
        $config.endpoints[0] | Add-Member -MemberType NoteProperty -Name request_timeout_ms -Value $reqTimeout
      } else {
        $config.endpoints[0].request_timeout_ms = $reqTimeout
      }
    }
    Write-Json $configPath $config
  }
  [pscustomobject]@{ project = $project; config = $configPath; acceptance = (Join-Path $agentRoot "acceptance") }
}

function New-PiConfig([string]$agentRoot, [hashtable]$case) {
  $piConfig = Join-Path $agentRoot "pi-config"
  New-Item -ItemType Directory -Force -Path $piConfig | Out-Null
  $models = [ordered]@{
    providers = [ordered]@{
      unsloth = [ordered]@{
        baseUrl = Get-BenchmarkEndpoint $case
        api = "openai-completions"
        apiKey = "local"
        models = @([ordered]@{
          id = "qwen3.8-flash-next"
          name = "Qwen3.8 Flash Next"
          contextWindow = 262144
          maxTokens = Get-BenchmarkMaxOutputTokens $case
          defaultParameters = [ordered]@{
            temperature = 1.0
            top_p = 0.95
            top_k = 20
            min_p = 0.0
            presence_penalty = 0.0
            repetition_penalty = 1.0
          }
          reasoning = $true
          compat = [ordered]@{
            supportsReasoningEffort = $true
            thinkingFormat = "openai"
            maxTokensField = "max_tokens"
          }
          thinkingLevelMap = [ordered]@{
            off = "none"
            minimal = "low"
            low = "low"
            medium = "medium"
            high = "xhigh"
            xhigh = "xhigh"
          }
        })
      }
    }
  }
  Write-Json (Join-Path $piConfig "models.json") $models
  $piConfig
}

function Get-RupiSessionId([string]$project) {
  $state = Join-Path $project ".rupi-state\sessions"
  $trace = Get-ChildItem -LiteralPath $state -File -Filter "*.trace.jsonl" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($trace) { return $trace.Name.Substring(0, $trace.Name.Length - ".trace.jsonl".Length) }
  $null
}

function Read-RupiMetrics([string]$project, [int]$SkipLines = 0) {
  $state = Join-Path $project ".rupi-state\sessions"
  $traceFiles = @(Get-ChildItem -LiteralPath $state -File -Filter "*.trace.jsonl" -ErrorAction SilentlyContinue)
  $started = 0; $completed = 0
  $logical = [int64]0; $uncached = [int64]0; $cacheRead = [int64]0; $cacheWrite = [int64]0
  $output = [int64]0; $providerTotal = [int64]0; $known = 0
  $toolRequested = 0; $toolCompleted = 0; $toolFailed = 0; $toolUnknown = 0
  $controlCounts = [ordered]@{
    turn_time_budget = 0; completion_review = 0; progress_boundary = 0
    progress_correction = 0; request_finalization = 0; unknown = 0
  }
  $reviewPositions = [Collections.Generic.List[int]]::new()
  $toolNames = [Collections.Generic.List[string]]::new(); $status = $null; $finish = [Collections.Generic.List[string]]::new()
  $seenLines = 0
  foreach ($file in $traceFiles) {
    foreach ($line in (Get-Content -LiteralPath $file.FullName)) {
      if ($seenLines -lt $SkipLines) { $seenLines++; continue }
      $seenLines++
      try { $record = $line | ConvertFrom-Json } catch { continue }
      switch ($record.type) {
        "runtime_control_injected" {
          $kind = [string]$record.kind
          if ($controlCounts.Contains($kind)) { $controlCounts[$kind]++ }
          else { $controlCounts["unknown"]++ }
          if ($kind -eq "completion_review") { [void]$reviewPositions.Add($started) }
        }
        "model_request_started" { $started++ }
        "model_request_completed" {
          $completed++
          $hasInput = $null -ne $record.input_tokens
          $hasOutput = $null -ne $record.output_tokens
          $requestLogical = if ($null -ne $record.logical_prompt_tokens) { [int64]$record.logical_prompt_tokens } elseif ($hasInput) { [int64]$record.input_tokens } else { [int64]0 }
          $requestCacheRead = if ($null -ne $record.cache_read_tokens) { [int64]$record.cache_read_tokens } else { [int64]0 }
          $requestCacheWrite = if ($null -ne $record.cache_write_tokens) { [int64]$record.cache_write_tokens } else { [int64]0 }
          $requestUncached = if ($null -ne $record.uncached_input_tokens) { [int64]$record.uncached_input_tokens } else { [math]::Max(0, $requestLogical - $requestCacheRead - $requestCacheWrite) }
          if ($hasInput -or $null -ne $record.logical_prompt_tokens) { $logical += $requestLogical }
          $uncached += $requestUncached
          $cacheRead += $requestCacheRead
          $cacheWrite += $requestCacheWrite
          if ($hasOutput) { $output += [int64]$record.output_tokens }
          if ($null -ne $record.provider_total_tokens) { $providerTotal += [int64]$record.provider_total_tokens }
          elseif ($hasInput -or $hasOutput) {
            $requestOutput = if ($hasOutput) { [int64]$record.output_tokens } else { [int64]0 }
            $providerTotal += $requestLogical + $requestOutput
          }
          if ($hasInput -and $hasOutput) { $known++ }
          if ($record.finish_reason) { [void]$finish.Add([string]$record.finish_reason) }
        }
        "tool_requested" { $toolRequested++; if ($record.name) { [void]$toolNames.Add([string]$record.name) } }
        "tool_completed" { $toolCompleted++ }
        "tool_failed" { $toolFailed++ }
        "tool_unknown" { $toolUnknown++ }
        "turn_completed" { $status = $record.status }
      }
    }
  }
  [pscustomobject]@{
    model_requests_started = $started; model_requests_completed = $completed
    logical_prompt_tokens = $logical; uncached_input_tokens = $uncached
    cache_read_tokens = $cacheRead; cache_write_tokens = $cacheWrite
    output_tokens = $output; provider_total_tokens = $providerTotal
    inference_input_tokens = $uncached + $cacheWrite
    inference_work_tokens = $uncached + $cacheWrite + $output
    input_tokens = $uncached; total_tokens = $providerTotal
    usage_records = $known; tool_requests = $toolRequested; tool_completions = $toolCompleted
    tool_failures = $toolFailed; tool_unknown = $toolUnknown; tool_names = @($toolNames)
    turn_status = $status; finish_reasons = @($finish)
    runtime_control_counts = $controlCounts
    completion_review_after_started_requests = @($reviewPositions)
    measurement_scope = "turn"
  }
}

function Get-RupiTraceLineCount([string]$project) {
  $state = Join-Path $project ".rupi-state\sessions"
  $count = 0
  Get-ChildItem -LiteralPath $state -File -Filter "*.trace.jsonl" -ErrorAction SilentlyContinue | ForEach-Object {
    $count += (Get-Content -LiteralPath $_.FullName | Measure-Object -Line).Lines
  }
  $count
}

function Read-PiMetrics([string]$stdoutPath) {
  $requests = 0; $logical = [int64]0; $input = [int64]0; $cacheRead = [int64]0; $cacheWrite = [int64]0
  $output = [int64]0; $providerTotal = [int64]0; $known = 0; $toolCalls = 0; $toolResults = 0
  $toolNames = [Collections.Generic.List[string]]::new(); $stop = $null; $session = $null
  foreach ($line in (Get-Content -LiteralPath $stdoutPath -ErrorAction SilentlyContinue)) {
    try { $record = $line | ConvertFrom-Json } catch { continue }
    if ($record.type -eq "session") { $session = $record.id }
    if ($record.type -eq "message_end" -and $record.message.role -eq "assistant") {
      $requests++
      $usage = $record.message.usage
      if ($usage) {
        if ($null -ne $usage.input) { $input += [int64]$usage.input }
        if ($null -ne $usage.cacheRead) { $cacheRead += [int64]$usage.cacheRead }
        if ($null -ne $usage.cacheWrite) { $cacheWrite += [int64]$usage.cacheWrite }
        if ($null -ne $usage.output) { $output += [int64]$usage.output }
        if ($null -ne $usage.totalTokens) { $providerTotal += [int64]$usage.totalTokens }
        if ($null -ne $usage.input -and $null -ne $usage.output) { $known++ }
      }
      if ($record.message.stopReason) { $stop = $record.message.stopReason }
      foreach ($content in @($record.message.content)) {
        if ($content.type -eq "toolCall") { $toolCalls++; if ($content.name) { [void]$toolNames.Add([string]$content.name) } }
      }
    }
    if ($record.type -eq "tool_execution_end") { $toolResults++ }
    if ($record.type -eq "turn_end" -and $record.message.stopReason) { $stop = $record.message.stopReason }
  }
  $logical = $input + $cacheRead + $cacheWrite
  if ($providerTotal -eq 0) { $providerTotal = $logical + $output }
  [pscustomobject]@{
    model_requests_started = $requests; model_requests_completed = $requests
    logical_prompt_tokens = $logical; uncached_input_tokens = $input
    cache_read_tokens = $cacheRead; cache_write_tokens = $cacheWrite
    output_tokens = $output; provider_total_tokens = $providerTotal
    inference_input_tokens = $input + $cacheWrite
    inference_work_tokens = $input + $cacheWrite + $output
    input_tokens = $input; total_tokens = $providerTotal
    usage_records = $known; tool_requests = $toolCalls; tool_completions = $toolResults
    tool_failures = $null; tool_unknown = $null; tool_names = @($toolNames)
    runtime_control_counts = $null
    completion_review_after_started_requests = $null
    turn_status = $stop; finish_reasons = @($stop); session_id = $session; measurement_scope = "turn"
  }
}

function Save-FileSnapshot([string]$project, [string]$path) {
  $items = @(Get-ChildItem -LiteralPath $project -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch "\\\.rupi-state(\\|$)" -and $_.FullName -notmatch "\\__pycache__(\\|$)" -and $_.Extension -ne ".pyc" } |
    ForEach-Object { [ordered]@{ path = $_.FullName.Substring($project.Length + 1); bytes = $_.Length } })
  Write-Json $path ([ordered]@{ file_count = $items.Count; total_bytes = (($items | Measure-Object bytes -Sum).Sum); files = $items })
}

function Invoke-Verification([hashtable]$case, [string]$agentRoot, [string]$project, [int]$turn) {
  $verifyRoot = Join-Path $agentRoot "verification\turn-$('{0:D2}' -f $turn)"
  New-Item -ItemType Directory -Force -Path $verifyRoot | Out-Null
  $projectTest = Invoke-External -FileName $python -Arguments @("-W", "error::ResourceWarning", "-m", "unittest", "discover", "-s", "tests", "-p", "test_*.py", "-v") -WorkingDirectory $project -StdoutPath (Join-Path $verifyRoot "project-tests.stdout.txt") -StderrPath (Join-Path $verifyRoot "project-tests.stderr.txt") -TimeoutSeconds 180
  $oracle = Invoke-External -FileName $python -Arguments @("-W", "error::ResourceWarning", "-m", "unittest", "discover", "-s", "acceptance", "-p", "test_*.py", "-v") -WorkingDirectory $agentRoot -StdoutPath (Join-Path $verifyRoot "oracle.stdout.txt") -StderrPath (Join-Path $verifyRoot "oracle.stderr.txt") -TimeoutSeconds 300
  $help = @()
  foreach ($helpArgs in $case.Help) {
    $suffix = ($helpArgs -join "-")
    $help += Invoke-External -FileName $python -Arguments (@("-m", $case.Package) + $helpArgs) -WorkingDirectory $project -StdoutPath (Join-Path $verifyRoot ("help-{0}.stdout.txt" -f $suffix)) -StderrPath (Join-Path $verifyRoot ("help-{0}.stderr.txt" -f $suffix)) -TimeoutSeconds 30
  }
  [pscustomobject]@{ project_tests = $projectTest; oracle = $oracle; help = @($help); resolved = ($oracle.exit_code -eq 0 -and -not $oracle.timed_out) }
}

function Invoke-AgentCase([hashtable]$case, [string]$agent, [string]$root, [string]$thinkingLevel) {
  $agentRoot = Join-Path $root $agent
  New-Item -ItemType Directory -Force -Path $agentRoot | Out-Null
  $workspace = New-BenchmarkWorkspace $case $agentRoot $thinkingLevel
  $piConfig = New-PiConfig $agentRoot $case
  $benchmarkEnvironment = Get-BenchmarkEnvironment $case $agent $agentRoot
  if ($benchmarkEnvironment.ContainsKey("USERPROFILE")) {
    New-Item -ItemType Directory -Path $benchmarkEnvironment.USERPROFILE -Force | Out-Null
  }
  $turns = [Collections.Generic.List[object]]::new()
  $resolved = $false; $sessionId = $null; $lastVerification = $null
  for ($turn = 1; $turn -le $MaxTurns; $turn++) {
    $prompt = if ($turn -eq 1) {
      Get-InitialPrompt $case
    } else {
      Get-RecoveryPrompt $case $lastVerification $workspace.project
    }
    $turnRoot = Join-Path $agentRoot ("turn-{0:D2}" -f $turn)
    New-Item -ItemType Directory -Force -Path $turnRoot | Out-Null
    Set-Content -LiteralPath (Join-Path $turnRoot "prompt.txt") -Value $prompt -NoNewline -Encoding utf8
    $args = [Collections.Generic.List[string]]::new(); $env = @{}
    if ($agent -eq "rupi") {
      $traceLinesBefore = Get-RupiTraceLineCount $workspace.project
      $args.Add("run"); $args.Add("--config"); $args.Add($workspace.config); $args.Add("--cwd"); $args.Add(".")
      if ($sessionId) { $args.Add("--resume"); $args.Add($sessionId) }
      $args.Add("--prompt"); $args.Add($prompt); $args.Add("--no-color"); $args.Add("--no-reasoning"); $args.Add("--verbose")
      $call = Invoke-External -FileName $rupiBinary -Arguments @($args) `
        -WorkingDirectory $workspace.project -StdoutPath (Join-Path $turnRoot "stdout.txt") `
        -StderrPath (Join-Path $turnRoot "stderr.txt") -TimeoutSeconds $TurnTimeoutSeconds `
        -Environment $benchmarkEnvironment
      $metrics = Read-RupiMetrics $workspace.project $traceLinesBefore
      $sessionId = Get-RupiSessionId $workspace.project
    } else {
      $sessionDir = Join-Path $agentRoot "pi-sessions"
      New-Item -ItemType Directory -Force -Path $sessionDir | Out-Null
      $args.Add("--provider"); $args.Add("unsloth")
      $args.Add("--model"); $args.Add("qwen3.8-flash-next")
      $args.Add("--thinking"); $args.Add($thinkingLevel)
      $args.Add("--mode"); $args.Add("json"); $args.Add("--print"); $args.Add("--offline"); $args.Add("--session-dir"); $args.Add($sessionDir)
      $args.Add("--no-context-files"); $args.Add("--no-extensions"); $args.Add("--no-skills"); $args.Add("--no-prompt-templates"); $args.Add("--no-themes")
      $args.Add("--tools"); $args.Add((@(Get-BenchmarkTools $case "pi") -join ","))
      if ($turn -gt 1) { $args.Add("--continue") }
      $args.Add("--"); $args.Add($prompt)
      $env["PI_CODING_AGENT_DIR"] = $piConfig; $env["PI_OFFLINE"] = "1"
      $piLauncher = $script:piLauncher
      $nodeExe = (Get-Command node.exe -ErrorAction SilentlyContinue)
      $piBundle = Join-Path (Split-Path $piLauncher -Parent) "node_modules\@earendil-works\pi-coding-agent\dist\bundle\cli.js"
      if ($nodeExe -and (Test-Path $piBundle)) {
        $piFileName = $nodeExe.Source
        $piArguments = @($piBundle) + @($args)
      } elseif ([IO.Path]::GetExtension($piLauncher) -eq ".ps1") {
        $piFileName = (Get-Command pwsh.exe -ErrorAction Stop).Source
        $piArguments = @("-NoProfile", "-File", $piLauncher) + @($args)
      } else {
        $piFileName = $piLauncher
        $piArguments = @($args)
      }
      $call = Invoke-External -FileName $piFileName -Arguments $piArguments -WorkingDirectory $workspace.project -StdoutPath (Join-Path $turnRoot "stdout.jsonl") -StderrPath (Join-Path $turnRoot "stderr.txt") -TimeoutSeconds $TurnTimeoutSeconds -Environment $env
      $metrics = Read-PiMetrics (Join-Path $turnRoot "stdout.jsonl")
      if ($metrics.session_id) { $sessionId = $metrics.session_id }
    }
    Save-FileSnapshot $workspace.project (Join-Path $turnRoot "files.json")
    $verification = Invoke-Verification $case $agentRoot $workspace.project $turn
    $lastVerification = $verification
    $turnRecord = [ordered]@{ turn = $turn; call = $call; metrics = $metrics; verification = $verification; session_id = $sessionId }
    if ($case.Id -in @("07-lease-cascade", "08-lease-fence",
      "09-lease-receipt", "10-receipt-ledger")) {
      $turnRecord["configured_tool_allowlist"] = @(Get-BenchmarkTools $case $agent)
      $turnRecord["harness_model_request_cap"] = if ($agent -eq "rupi") {
        $MaxModelRequestsPerTurn
      } else { $null }
      $turnRecord["configured_turn_duration_ms"] = if (
        $case.Id -eq "10-receipt-ledger" -and $agent -eq "rupi" -and
        $Case10MaxTurnDurationMs -gt 0
      ) { $Case10MaxTurnDurationMs } else { $null }
      if ($case.Id -eq "10-receipt-ledger") {
        $turnRecord["configured_initial_progress_boundary"] = if ($agent -eq "rupi") {
          $Case10InitialProgressBoundary.IsPresent
        } else { $null }
        $turnRecord["configured_completion_review"] = if ($agent -eq "rupi") {
          $Case10ReviewCompletion.IsPresent
        } else { $null }
        $turnRecord["configured_completion_review_reserve_ms"] = if (
          $agent -eq "rupi" -and $Case10CompletionReviewReserveMs -gt 0
        ) { $Case10CompletionReviewReserveMs } else { $null }
      }
      $progressControl = Get-BenchmarkProgressControl $case
      if ($null -ne $progressControl) {
        $turnRecord["configured_progress_boundary_mode"] = if ($agent -eq "rupi") {
          $progressControl.mode
        } else { $null }
        $turnRecord["configured_progress_request_window"] = if ($agent -eq "rupi") {
          $progressControl.window
        } else { $null }
      }
      $turnRecord["configured_thinking_control"] = [ordered]@{
        level = $thinkingLevel
        dialect = "reasoning_effort"
        off_value = "none"
      }
      $turnRecord["configured_model_endpoint"] = Get-BenchmarkEndpoint $case
      $budget = Get-BenchmarkReasoningBudget $case
      $turnRecord["configured_reasoning_budget_tokens"] = if ($budget -gt 0) {
        $budget
      } else { $null }
      $turnRecord["configured_relay_response_timeout_seconds"] = if (
          $case.Id -eq "10-receipt-ledger" -and $budget -gt 0 -and
          $Case10RelayResponseTimeoutSeconds -gt 0) {
        $Case10RelayResponseTimeoutSeconds
      } else { $null }
      $turnRecord["configured_native_reasoning_replay"] = $true
      if ($case.Id -eq "10-receipt-ledger") {
        $turnRecord["configured_max_output_tokens"] = Get-BenchmarkMaxOutputTokens $case
      }
      $turnRecord["configured_skill_discovery"] = if ($agent -eq "rupi") {
        "empty_child_profile"
      } else { "disabled_flags" }
    }
    Write-Json (Join-Path $turnRoot "summary.json") $turnRecord
    [void]$turns.Add($turnRecord)
    $resolved = $verification.resolved
    if ($resolved) { break }
  }
  [pscustomobject]@{
    case = $case.Id; agent = $agent; resolved = $resolved; turns_to_resolution = if ($resolved) { $turns.Count } else { $null }
    max_turns = $MaxTurns; session_id = $sessionId; turns = @($turns); artifact_root = $agentRoot
  }
}

$cases = @(Get-CaseDefinitions)
if ($CaseId.Count -gt 0) {
  $requestedIds = @($CaseId | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  $cases = @($cases | Where-Object { $requestedIds -contains $_.Id })
  if ($cases.Count -eq 0) { throw "No matching cases: $($requestedIds -join ', ')" }
}
$recoveryFeedbackScope = "project_tests_and_help"
if (@($cases | Where-Object { $_.Id -eq "05-batch-relay" }).Count -gt 0) {
  $recoveryFeedbackScope += ";case05_oracle_status_only"
}
if (@($cases | Where-Object { $_.Id -eq "07-lease-cascade" }).Count -gt 0) {
  $recoveryFeedbackScope += ";case07_oracle_status_only"
}
if (@($cases | Where-Object { $_.Id -eq "08-lease-fence" }).Count -gt 0) {
  $recoveryFeedbackScope += ";case08_oracle_status_only"
}
if (@($cases | Where-Object { $_.Id -eq "09-lease-receipt" }).Count -gt 0) {
  $recoveryFeedbackScope += ";case09_oracle_status_only"
}
if (@($cases | Where-Object { $_.Id -eq "10-receipt-ledger" }).Count -gt 0) {
  $recoveryFeedbackScope += ";case10_oracle_status_only"
}
if (@($cases | Where-Object { $_.Id -eq "10-receipt-ledger" }).Count -gt 0 -and
    $Case10ReasoningBudgetTokens -gt 0 -and
    ($Case10RelayResponseTimeoutSeconds * 1000) -gt $script:providerRequestTimeoutMs) {
  throw "Case 10 relay response deadline must fit within the provider deadline."
}
if ($DryRun) {
  Write-Host "Thinking level: $ThinkingLevel"
  Write-Host "Recovery feedback scope: $recoveryFeedbackScope"
  $cases | ForEach-Object {
    [void](Get-InitialPrompt $_)
    $expectedOutput = if ($_.Id -eq "10-receipt-ledger") { $Case10MaxOutputTokens }
      else { 16384 }
    if ((Get-BenchmarkMaxOutputTokens $_) -ne $expectedOutput) {
      throw "Case 10 output control must preserve other cases' output limits."
    }
    $progressLimits = [pscustomobject]@{ max_model_requests_without_progress = 1 }
    Set-BenchmarkProgressBoundary $_ $progressLimits
    $hasProgressControl = $_.Id -in @("08-lease-fence", "09-lease-receipt", "10-receipt-ledger")
    if ($hasProgressControl) {
      $expectedControl = Get-BenchmarkProgressControl $_
      $expectedMode = $expectedControl.mode
      $expectedWindow = $expectedControl.window
      if ($progressLimits.progress_boundary_mode -cne $expectedMode) {
        throw "$($_.Id) Rupi must use the selected progress boundary mode."
      }
      if ($progressLimits.max_model_requests_without_progress -ne $expectedWindow) {
        throw "$($_.Id) Rupi must use the selected progress request window."
      }
    } elseif ($null -ne $progressLimits.PSObject.Properties["progress_boundary_mode"]) {
      throw "Selected progress mode must not change other cases."
    }
    if (-not $hasProgressControl -and
        $progressLimits.max_model_requests_without_progress -ne 1) {
      throw "Selected progress request window must not change other cases."
    }
    $expectedEndpoint = if ((Get-BenchmarkReasoningBudget $_) -gt 0) {
      if ($_.Id -eq "10-receipt-ledger") {
        "http://127.0.0.1:$Case10ReasoningRelayPort/v1"
      } else { "http://127.0.0.1:8001/v1" }
    } else { "http://127.0.0.1:8000/v1" }
    if ((Get-BenchmarkEndpoint $_) -cne $expectedEndpoint) {
      throw "The reasoning relay must match the selected case's explicit budget."
    }
    $environmentRoot = Join-Path ([IO.Path]::GetTempPath()) "rupi-case07-environment"
    $rupiEnvironment = Get-BenchmarkEnvironment $_ "rupi" $environmentRoot
    $piEnvironment = Get-BenchmarkEnvironment $_ "pi" $environmentRoot
    if ($piEnvironment.Count -ne 0 -or
        ($_.Id -notin @("07-lease-cascade", "08-lease-fence",
      "09-lease-receipt", "10-receipt-ledger") -and
          $rupiEnvironment.Count -ne 0)) {
      throw "Only Case 07/08/09/10 Rupi may receive an isolated discovery profile."
    }
    if ($_.Id -eq "07-lease-cascade") {
      if ($rupiEnvironment.Count -ne 2 -or -not $rupiEnvironment.ContainsKey("HOME") -or
          $null -ne $rupiEnvironment.HOME -or
          $rupiEnvironment.USERPROFILE -ne (Join-Path $environmentRoot "discovery-profile")) {
        throw "Case 07 Rupi must remove inherited HOME and use an isolated USERPROFILE."
      }
      if ((@(Get-BenchmarkTools $_ "rupi") -join ",") -ne "read,write,edit,grep") {
        throw "Case 07 Rupi tool allowlist differs from its file-only profile."
      }
      if ((@(Get-BenchmarkTools $_ "pi") -join ",") -ne "read,write,edit,grep,find,ls") {
        throw "Case 07 Pi tool allowlist differs from its file-only profile."
      }
      $reasoningEndpoints = @(
        [pscustomobject]@{
          capabilities = [pscustomobject]@{ exposed_reasoning = "native" }
        }
        [pscustomobject]@{
          capabilities = [pscustomobject]@{ exposed_reasoning = "native" }
          openai_compat = $null
        }
        [pscustomobject]@{
          capabilities = [pscustomobject]@{ exposed_reasoning = "native" }
          openai_compat = [pscustomobject]@{
            thinking_input = "none"
            thinking_disable = "omit"
            preserve_reasoning = $false
            stream = $false
            max_tokens_field = "max_tokens"
          }
        }
      )
      foreach ($endpoint in $reasoningEndpoints) {
        Set-BenchmarkReasoningCompatibility $_ $endpoint
        if ($endpoint.openai_compat.thinking_input -ne "reasoning_effort" -or
            $endpoint.openai_compat.thinking_disable -ne "reasoning_effort_none" -or
            $endpoint.openai_compat.preserve_reasoning -ne $true) {
          throw "Case 07 must configure explicit thinking control and native reasoning replay."
        }
      }
      foreach ($exposure in @($null, "none", "provider_summary", "declared")) {
        $invalidEndpoint = [pscustomobject]@{
          capabilities = [pscustomobject]@{ exposed_reasoning = $exposure }
        }
        $endpointBefore = $invalidEndpoint | ConvertTo-Json -Depth 4 -Compress
        $rejected = $false
        try { Set-BenchmarkReasoningCompatibility $_ $invalidEndpoint } catch {
          if ($_.Exception.Message -ne
              "Case 07 reasoning replay requires an explicit native exposure claim.") { throw }
          $rejected = $true
        }
        if (-not $rejected -or
            ($invalidEndpoint | ConvertTo-Json -Depth 4 -Compress) -ne $endpointBefore) {
          throw "Case 07 must reject non-native exposure before mutating endpoint compatibility."
        }
      }
      $preservedCompat = $reasoningEndpoints[2].openai_compat
      if ($preservedCompat.stream -ne $false -or
          $preservedCompat.max_tokens_field -ne "max_tokens") {
        throw "Case 07 reasoning compatibility must preserve other endpoint settings."
      }
      $entrypointGuidance = Get-CaseGuidance $_ "entrypoint"
      $entrypointRequirements = @(
        'First tool call: write a compact, runnable CLI in leasecascade/__main__.py.'
        'The current directory contains SPEC.md and is already the project root.'
        'Use leasecascade/ and tests/ paths directly relative to this current directory.'
        'Review the embedded specification as file inspection before this first source write.'
        'Use standard-library imports and a main guard; do not import absent local modules.'
        'Define needed constants in __main__.py; do not import __version__ from the package.'
        'Second write call: create tests/test_leasecascade.py with a real unittest.'
        'Keep initial tests under 60 lines; cover only imports and the three help paths.'
        'Third write call: create tests/__init__.py after the test module exists.'
        'Fourth write: create README.md under 80 lines with the public contract and exact checks.'
        'Cover commands, HMAC, routes, states, collect/fan_in, leases, sink, and persistence.'
        'Document implemented behavior honestly; keep command examples aligned with code.'
        'This attempt covers CLI/health, help tests, and README; do not plan workflow code yet.'
        'Complete CLI/health, help tests, and README in this attempt; yield after four writes.'
        'Keep all workflow code in __main__.py; do not create helper modules.'
        'Apply subsequent source edits of at most 80 new lines while preserving passing behavior.'
        'Complete workflow behavior in later attempts using public-spec tests and small edits.'
      )
      foreach ($instruction in $entrypointRequirements) {
        if (-not $entrypointGuidance.Contains($instruction)) {
          throw "Case 07 entrypoint guidance is missing: $instruction"
        }
      }
      $initialGuidance = Get-CaseGuidance $_
      $initialRequirements = @(
        'The current directory contains SPEC.md and is already the project root.'
        'Use leasecascade/ and tests/ paths directly relative to this current directory.'
        'Second write call: create tests/test_leasecascade.py with a real unittest.'
        'Keep initial tests under 60 lines; cover only imports and the three help paths.'
        'Third write call: create tests/__init__.py after the test module exists.'
        'Fourth write: create README.md under 80 lines with the public contract and exact checks.'
        'Cover commands, HMAC, routes, states, collect/fan_in, leases, sink, and persistence.'
        'Document implemented behavior honestly; keep command examples aligned with code.'
        'Use standard-library imports and a main guard; do not import absent local modules.'
        'Each write call creates one file; write the test module before its initializer.'
        'After the entry point, write the test module and initializer in consecutive calls.'
        'Keep all workflow code in __main__.py; do not create helper modules.'
        'Complete CLI/health, help tests, and README in this attempt; yield after four writes.'
        'Use the next harness feedback to begin workflow tests and implementation.'
        'Apply subsequent source edits of at most 80 new lines while preserving passing behavior.'
        'Invoke the sink with direct argv and persist output and terminal status.'
        'Expose the result through the documented pipeline/job retrieval route.'
        'Complete workflow behavior in later attempts using public-spec tests and small edits.'
      )
      foreach ($instruction in $initialRequirements) {
        if (-not $initialGuidance.Contains($instruction)) {
          throw "Case 07 initial guidance is missing: $instruction"
        }
      }
      $foundationGuidance = Get-CaseGuidance $_ "foundation"
      $foundationRequirements = @(
        'Project tests or help checks still fail; fix both foundation gates before workflow code.'
        'If help fails, repair leasecascade/__main__.py before writing more tests.'
        'Remove imports of missing local modules; keep the foundation self-contained.'
        'Each write call creates one file; write the test module before its initializer.'
        'Missing tests: write tests/test_leasecascade.py then tests/__init__.py separately.'
        'While either gate fails, repair only __main__.py or the two test files.'
        'Cover the three help paths with subprocess checks using sys.executable.'
        'Use workspace write tools only; no exec or running checks, services, workers, or oracle.'
        'Do not write validation, storage, server, or worker files until tests and all help pass.'
      )
      foreach ($instruction in $foundationRequirements) {
        if (-not $foundationGuidance.Contains($instruction)) {
          throw "Case 07 foundation guidance is missing: $instruction"
        }
      }
      $localGuidance = Get-CaseGuidance $_ "local"
      $localRequirements = @(
        'Preserve the public-specification assertions and fix the implementation in small edits.'
        'If tests assume an undocumented private API, replace that coupling with public checks.'
        'Preserve every public-spec assertion; never weaken expectations to make tests pass.'
        'Keep application repairs in __main__.py; test helpers belong inside the test module.'
        'Each implementation edit adds at most 80 lines; preserve passing tests and help.'
        'Repair other failures from the same feedback while the request budget remains.'
        'Then yield for harness feedback; do not run checks, service, worker, or oracle.'
      )
      foreach ($instruction in $localRequirements) {
        if (-not $localGuidance.Contains($instruction)) {
          throw "Case 07 local-test guidance is missing: $instruction"
        }
      }
      $workflowGuidance = Get-CaseGuidance $_ "workflow"
      $workflowRequirements = @(
        'Project tests and all help checks pass, but the independent oracle failed.'
        'Keep the passing tests and help paths intact.'
        'Do not repeat CLI, health-route, or test-discovery scaffolding.'
        'After workflow tests exist, advance leasecascade/__main__.py through small edits.'
        'Use prior context; read the intended source or test file once if its anchor is unknown.'
        'After that read, the next tool call must edit the intended file, not inspect more files.'
        'Each edit adds at most 80 lines; apply the first edit before designing later slices.'
        'After workflow tests exist, add signed admission, retrieval, then worker in small edits.'
        'With tests present, add missing raw-body HMAC and atomic SQLite pipeline/job state.'
        'Then connect POST /pipelines and GET /pipelines/<pipeline_id> in small separate edits.'
        'Keep workflow code in that file; do not create __init__.py or helper modules yet.'
        'Then add ordered leased claims, a direct-argv sink, and persisted terminal output.'
        'Use a bounded worker --once; reclaim expired leases without polling.'
        ('If workflow tests are missing, edit ' +
          'tests/test_leasecascade.py next.')
        'Use finite HTTP/process timeouts and terminate/wait for the server in finally.'
        'Test signed admission, persisted retrieval, and worker delivery of declared inputs.'
        'Exercise workflow behavior only through documented CLI, HTTP, and sink interfaces.'
        'Use sys.executable -m leasecascade, raw HTTP requests, and bounded sink fixtures.'
        'Keep test helpers in tests/test_leasecascade.py; use only standard-library imports.'
        'Do not import private application modules or assume undocumented function/class names.'
        'Do not create application helper modules just to satisfy test-specific internal imports.'
        'Test a barrier whose depends_on order reverses the two dependency insertion positions.'
        'Assert fan_in contains only collect.field values, with job_id/value items in that order.'
        'Missing collect.field test: no barrier sink call, failed barrier, blocked dependent.'
        'After adding missing workflow tests, end this attempt for harness feedback.'
        'Preserve all passing project tests and the three help paths.'
        'Then implement declared inputs, ordered selected-field fan-in, and dependency blocking.'
        'Build fan-in in depends_on order from only the selected collect.field values.'
        'Fail missing selections without running the sink, block dependents, and reclaim leases.'
      )
      foreach ($instruction in $workflowRequirements) {
        if (-not $workflowGuidance.Contains($instruction)) {
          throw "Case 07 workflow guidance is missing: $instruction"
        }
      }
    } elseif ($_.Id -eq "08-lease-fence") {
      if ($rupiEnvironment.Count -ne 2 -or $null -ne $rupiEnvironment.HOME -or
          $rupiEnvironment.USERPROFILE -ne (Join-Path $environmentRoot "discovery-profile") -or
          (@(Get-BenchmarkTools $_ "rupi") -join ",") -ne "read,write,edit,grep" -or
          (@(Get-BenchmarkTools $_ "pi") -join ",") -ne "read,write,edit,grep,find,ls") {
        throw "Case 08 requires file tools and isolated Rupi skill discovery."
      }
      $endpoint = [pscustomobject]@{
        capabilities = [pscustomobject]@{ exposed_reasoning = "native" }
      }
      Set-BenchmarkReasoningCompatibility $_ $endpoint
      if ($endpoint.openai_compat.thinking_input -ne "reasoning_effort" -or
          $endpoint.openai_compat.thinking_disable -ne "reasoning_effort_none" -or
          $endpoint.openai_compat.preserve_reasoning -ne $true) {
        throw "Case 08 must use explicit reasoning controls and native replay."
      }
      $initialPrompt = Get-InitialPrompt $_
      $spec = [IO.File]::ReadAllText((Join-Path (Join-Path $repoRoot $_.Source) "SPEC.md"))
      if (-not $initialPrompt.Contains($spec) -or
          -not $initialPrompt.Contains('First tool call: write leasefence/__main__.py') -or
          -not $initialPrompt.Contains('exact claim token; accept only one updated row.') -or
          -not $initialPrompt.Contains('complete public workflow') -or
          $initialPrompt.Contains('Yield after these four foundation writes.') -or
          -not $initialPrompt.Contains('Do not inspect or run the external acceptance oracle.')) {
        throw "Case 08 must preserve its specification and oracle boundary."
      }
    } elseif ($_.Id -eq "09-lease-receipt") {
      if ($progressLimits.progress_boundary_mode -cnotin @("one_shot", "recurring")) {
        throw "Case 09 progress mode must use canonical lowercase runtime JSON names."
      }
      if ($rupiEnvironment.Count -ne 2 -or $null -ne $rupiEnvironment.HOME -or
          $rupiEnvironment.USERPROFILE -ne (Join-Path $environmentRoot "discovery-profile") -or
          (@(Get-BenchmarkTools $_ "rupi") -join ",") -ne "read,write,edit,grep" -or
          (@(Get-BenchmarkTools $_ "pi") -join ",") -ne "read,write,edit,grep,find,ls") {
        throw "Case 09 requires file tools and isolated Rupi skill discovery."
      }
      $endpoint = [pscustomobject]@{
        capabilities = [pscustomobject]@{ exposed_reasoning = "native" }
        openai_compat = [pscustomobject]@{ stream = $false }
      }
      Set-BenchmarkReasoningCompatibility $_ $endpoint
      if ($endpoint.openai_compat.thinking_input -ne "reasoning_effort" -or
          $endpoint.openai_compat.thinking_disable -ne "reasoning_effort_none" -or
          $endpoint.openai_compat.preserve_reasoning -ne $true -or
          $endpoint.openai_compat.stream -ne $false) {
        throw "Case 09 must set native reasoning controls and preserve unrelated settings."
      }
      $invalidEndpoint = [pscustomobject]@{
        capabilities = [pscustomobject]@{ exposed_reasoning = "provider_summary" }
      }
      $before = $invalidEndpoint | ConvertTo-Json -Depth 4 -Compress
      $rejected = $false
      try { Set-BenchmarkReasoningCompatibility $_ $invalidEndpoint } catch {
        if ($_.Exception.Message -cne
            "Case 09 reasoning replay requires an explicit native exposure claim.") { throw }
        $rejected = $true
      }
      if (-not $rejected -or
          ($invalidEndpoint | ConvertTo-Json -Depth 4 -Compress) -cne $before) {
        throw "Case 09 must reject non-native exposure before changing endpoint settings."
      }
    } elseif ($_.Id -eq "10-receipt-ledger") {
      if ($progressLimits.progress_boundary_mode -cnotin @("one_shot", "recurring")) {
        throw "Case 10 progress mode must use canonical lowercase runtime JSON names."
      }
      if ($rupiEnvironment.Count -ne 2 -or $null -ne $rupiEnvironment.HOME -or
          $rupiEnvironment.USERPROFILE -ne (Join-Path $environmentRoot "discovery-profile") -or
          (@(Get-BenchmarkTools $_ "rupi") -join ",") -ne "read,write,edit,grep" -or
          (@(Get-BenchmarkTools $_ "pi") -join ",") -ne "read,write,edit,grep,find,ls") {
        throw "Case 10 requires file tools and isolated Rupi skill discovery."
      }
      $endpoint = [pscustomobject]@{
        capabilities = [pscustomobject]@{ exposed_reasoning = "native" }
        openai_compat = [pscustomobject]@{ stream = $false }
      }
      Set-BenchmarkReasoningCompatibility $_ $endpoint
      if ($endpoint.openai_compat.thinking_input -ne "reasoning_effort" -or
          $endpoint.openai_compat.thinking_disable -ne "reasoning_effort_none" -or
          $endpoint.openai_compat.preserve_reasoning -ne $true -or
          $endpoint.openai_compat.stream -ne $false) {
        throw "Case 10 must set native reasoning controls and preserve unrelated settings."
      }
      $invalidEndpoint = [pscustomobject]@{
        capabilities = [pscustomobject]@{ exposed_reasoning = "provider_summary" }
      }
      $before = $invalidEndpoint | ConvertTo-Json -Depth 4 -Compress
      $rejected = $false
      try { Set-BenchmarkReasoningCompatibility $_ $invalidEndpoint } catch {
        if ($_.Exception.Message -cne
            "Case 10 reasoning replay requires an explicit native exposure claim.") { throw }
        $rejected = $true
      }
      if (-not $rejected -or
          ($invalidEndpoint | ConvertTo-Json -Depth 4 -Compress) -cne $before) {
        throw "Case 10 must reject non-native exposure before changing endpoint settings."
      }
    } else {
      $unchangedEndpoint = [pscustomobject]@{
        openai_compat = [pscustomobject]@{ thinking_input = "none" }
      }
      $endpointBefore = $unchangedEndpoint | ConvertTo-Json -Depth 4 -Compress
      Set-BenchmarkReasoningCompatibility $_ $unchangedEndpoint
      if (($unchangedEndpoint | ConvertTo-Json -Depth 4 -Compress) -ne $endpointBefore) {
        throw "Non-Case 07 endpoint compatibility settings must remain unchanged."
      }
      if (@(Get-BenchmarkTools $_ "rupi").Count -ne 0) {
        throw "Non-Case 07 Rupi tools must retain their source configuration."
      }
      $piTools = @(Get-BenchmarkTools $_ "pi") -join ","
      if ($piTools -ne "read,write,edit,bash,powershell,grep,find,ls") {
        throw "Non-Case 07 Pi tools must retain the existing profile."
      }
    }
    $dryRunHelp = @($_.Help | ForEach-Object {
        [pscustomobject]@{
          timed_out = $false
          exit_code = 0
          stderr_path = $null
          stdout_path = $null
        }
      })
    $dryRunVerification = [pscustomobject]@{
      oracle = [pscustomobject]@{
        timed_out = $false
        exit_code = 0
        stderr_path = $null
        stdout_path = $null
      }
      project_tests = [pscustomobject]@{
        timed_out = $false
        exit_code = 0
        stderr_path = $null
        stdout_path = $null
      }
      help = $dryRunHelp
    }
    $dryRunRecovery = Get-RecoveryPrompt $_ $dryRunVerification
    if ($_.Id -eq "08-lease-fence") {
      $dryRunProject = Join-Path ([IO.Path]::GetTempPath()) (
        "rupi-case08-dryrun-" + [Guid]::NewGuid().ToString("N")
      )
      $oracleDiagnostic = Join-Path $dryRunProject "oracle-diagnostic.txt"
      New-Item -ItemType Directory -Path $dryRunProject -Force | Out-Null
      try {
        Write-Text $oracleDiagnostic "CASE08_PRIVATE_ORACLE_DIAGNOSTIC"
        $dryRunVerification.oracle.exit_code = 1
        $dryRunVerification.oracle.stderr_path = $oracleDiagnostic
        $dryRunVerification.oracle.stdout_path = $oracleDiagnostic
        $withoutFiles = Get-RecoveryPrompt $_ $dryRunVerification
        $withWorkspace = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        if ($withoutFiles -ne $withWorkspace) {
          throw "Case 08 recovery must not prescribe module stages from file presence."
        }
        foreach ($prompt in @($initialPrompt, $withoutFiles, $dryRunRecovery)) {
          if (-not $prompt.Contains($spec) -or
              -not $prompt.Contains('exact claim token; accept only one updated row.') -or
              -not $prompt.Contains('block worker A') -or
              -not $prompt.Contains('not private APIs') -or
              $prompt.Contains('CASE08_PRIVATE_ORACLE_DIAGNOSTIC') -or
              $prompt.Contains('Yield after these four foundation writes.') -or
              $prompt.Contains('First source write: leasefence/store.py') -or
              $prompt.Contains('First write: tests/test_workflow.py')) {
            throw "Case 08 must preserve full workflow/tests/fencing without staged authoring."
          }
        }
        $dryRunVerification.project_tests.exit_code = 1
        $repairPrompt = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        if (-not $repairPrompt.Contains(
              'Repair the earliest failing local test or help gate'
            ) -or
            -not $repairPrompt.Contains('one focused edit per response, at most 100 new lines') -or
            -not $repairPrompt.Contains('preserve both CLI and workflow tests') -or
            -not $repairPrompt.Contains('preserve assertions') -or
            -not $repairPrompt.Contains('exact claim token; accept only one updated row.') -or
            -not $repairPrompt.Contains('never replace workflow tests') -or
            -not $repairPrompt.Contains($spec) -or
            $repairPrompt.Contains('CASE08_PRIVATE_ORACLE_DIAGNOSTIC')) {
          throw "Case 08 local repair must preserve the public specification and assertions."
        }
        $dryRunVerification.project_tests.exit_code = 0
        $dryRunVerification.help[0].exit_code = 1
        $helpRepairPrompt = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        if (-not $helpRepairPrompt.Contains(
              'Repair the earliest failing local test or help gate'
            ) -or
            -not $helpRepairPrompt.Contains('Remove imports of missing local modules') -or
            -not $helpRepairPrompt.Contains('exact claim token; accept only one updated row.') -or
            $helpRepairPrompt.Contains('CASE08_PRIVATE_ORACLE_DIAGNOSTIC')) {
          throw "Case 08 failing help must preserve repair and oracle isolation."
        }
        $dryRunVerification.help[0].exit_code = 0
      } finally {
        Remove-Item -LiteralPath $oracleDiagnostic -Force
        if (@(Get-ChildItem -LiteralPath $dryRunProject -Force).Count -ne 0) {
          throw "Dry-run directory contains unexpected files: $dryRunProject"
        }
        Remove-Item -LiteralPath $dryRunProject -Force
      }
    }
    if ($_.Id -eq "09-lease-receipt") {
      $spec = [IO.File]::ReadAllText((Join-Path (Join-Path $repoRoot $_.Source) "SPEC.md"))
      $dryRunProject = Join-Path ([IO.Path]::GetTempPath()) (
        "rupi-case09-dryrun-" + [Guid]::NewGuid().ToString("N")
      )
      $oracleDiagnostic = Join-Path $dryRunProject "oracle-diagnostic.txt"
      New-Item -ItemType Directory -Path $dryRunProject | Out-Null
      try {
        Write-Text $oracleDiagnostic "CASE09_PRIVATE_ORACLE_DIAGNOSTIC"
        $dryRunVerification.oracle.exit_code = 1
        $dryRunVerification.oracle.stderr_path = $oracleDiagnostic
        $dryRunVerification.oracle.stdout_path = $oracleDiagnostic
        $initialPrompt = Get-InitialPrompt $_
        $oracleFailurePrompt = Get-RecoveryPrompt $_ $dryRunVerification
        $dryRunVerification.project_tests.exit_code = 1
        $repairPrompt = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        $dryRunVerification.project_tests.exit_code = 0
        $dryRunVerification.help[0].exit_code = 1
        $helpRepairPrompt = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        $requirements = @(
          $spec
          'Do not inspect or run the external acceptance oracle.'
          'public delivery_key is exactly pipeline_id + ":" + job_id'
          'fresh private unguessable claim token'
          'exact claim token;'
          'accept only one updated row'
          'status/output/attempts/lease/error/receipt'
          'EOF/lost acknowledgement is retryable failure'
          'never an invented receipt'
          'one logical effect, two attempts, same key and original receipt/output'
          'public commands/HTTP'
          'resource cleanup'
        )
        foreach ($prompt in @($initialPrompt, $dryRunRecovery, $oracleFailurePrompt,
            $repairPrompt, $helpRepairPrompt)) {
          foreach ($requirement in $requirements) {
            if (-not $prompt.Contains($requirement)) {
              throw "Case 09 prompt lost a public specification or receipt/fencing requirement."
            }
          }
          if ($prompt.Contains('CASE09_PRIVATE_ORACLE_DIAGNOSTIC')) {
            throw "Case 09 oracle diagnostics must remain hidden."
          }
        }
        if (-not $initialPrompt.Contains('First tool call: write leasereceipt/__main__.py')) {
          throw "Case 09 initial prompt must request complete application behavior first."
        }
        foreach ($prompt in @($repairPrompt, $helpRepairPrompt)) {
          if (-not $prompt.Contains('Repair the earliest failing local test or help gate') -or
              -not $prompt.Contains('preserve assertions') -or
              -not $prompt.Contains('at most 100 new lines')) {
            throw "Case 09 repair must preserve assertions and bounded application edits."
          }
        }
        $dryRunVerification.help[0].exit_code = 0
      } finally {
        Remove-Item -LiteralPath $oracleDiagnostic -Force
        if (@(Get-ChildItem -LiteralPath $dryRunProject -Force).Count -ne 0) {
          throw "Dry-run directory contains unexpected files: $dryRunProject"
        }
        Remove-Item -LiteralPath $dryRunProject -Force
      }
    }
    if ($_.Id -eq "10-receipt-ledger") {
      $spec = [IO.File]::ReadAllText((Join-Path (Join-Path $repoRoot $_.Source) "SPEC.md"))
      $outputGuardRoot = Join-Path $artifactRoot (
        "case10-output-guard-" + [Guid]::NewGuid().ToString("N")
      )
      $outputWorkspace = New-BenchmarkWorkspace $_ $outputGuardRoot $ThinkingLevel
      $outputConfig = Get-Content -Raw -LiteralPath $outputWorkspace.config | ConvertFrom-Json
      $piConfigRoot = New-PiConfig $outputGuardRoot $_
      $piOutputConfig = Get-Content -Raw -LiteralPath (Join-Path $piConfigRoot "models.json") |
        ConvertFrom-Json
      $outputEndpoint = $outputConfig.endpoints[0]
      $rupiOutputLimit = if ($null -ne $outputEndpoint.max_output_tokens) {
        $outputEndpoint.max_output_tokens
      } else { $outputEndpoint.capabilities.max_output_tokens }
      if ($rupiOutputLimit -ne $Case10MaxOutputTokens -or
          $piOutputConfig.providers.unsloth.models[0].maxTokens -ne $Case10MaxOutputTokens) {
        throw "Case 10 must configure the same effective output limit for both agents."
      }
      $dryRunProject = Join-Path ([IO.Path]::GetTempPath()) (
        "rupi-case10-dryrun-" + [Guid]::NewGuid().ToString("N")
      )
      $oracleDiagnostic = Join-Path $dryRunProject "oracle-diagnostic.txt"
      New-Item -ItemType Directory -Path $dryRunProject | Out-Null
      try {
        Write-Text $oracleDiagnostic "CASE10_PRIVATE_ORACLE_DIAGNOSTIC"
        $dryRunVerification.oracle.exit_code = 1
        $dryRunVerification.oracle.stderr_path = $oracleDiagnostic
        $dryRunVerification.oracle.stdout_path = $oracleDiagnostic
        $initialPrompt = Get-InitialPrompt $_
        $oracleFailurePrompt = Get-RecoveryPrompt $_ $dryRunVerification
        $dryRunVerification.project_tests.exit_code = 1
        $repairPrompt = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        $dryRunVerification.project_tests.exit_code = 0
        $dryRunVerification.help[0].exit_code = 1
        $helpRepairPrompt = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        $requirements = @(
          $spec
          'Do not inspect or run the external acceptance oracle.'
          'public delivery_key is exactly pipeline_id + ":" + job_id'
          'fresh private unguessable claim token'
          'exact claim token;'
          'accept only one updated row'
          'status/output/attempts/lease/error/receipt'
          'EOF/lost acknowledgement is retryable failure'
          'never an invented receipt'
          'one logical effect, two attempts, same key and original receipt/output'
          'public commands/HTTP'
          'resource cleanup'
          'SAME SQLite'
          'exact public SPEC hash expression'
          'two UTF-8 bytes 0x5c,0x6e (backslash then n)'
          'same separator bytes when appending, verifying and independently recomputing in tests'
          'Audit rows are evidence, never worker input or job state.'
          'Rejected stale finalization appends only a safe operational event'
          'audit --verify opens SQLite read-only'
          'FULL sequence and recomputed hash chain'
          'never repair/truncate'
          'audit --tail COUNT reads only'
          'outcome:unknown'
          'all four help paths'
          'Use unittest.TestCase subclasses with test_ methods'
          'Use the actual edit diagnostic; an attempted edit is not a completed change.'
          'If a failed edit explicitly made no change, read its target file before correcting it.'
          'Read a small target region with offset/limit; narrow it if the response is truncated.'
          'Use file text in edit anchors, excluding displayed line numbers and truncation markers.'
          'Then edit the observed current text with a unique anchor and the native tool schema.'
          'Do not guess another stale anchor or rewrite the whole application after a failed edit.'
          'If the diagnostic says already applied, inspect the file and preserve the completed change.'
          'For an Unknown mutation, inspect current state and defer retry until reconciliation.'
          'After a known failure is corrected, continue public contract repairs within this attempt.'
          'Do not end an attempt merely because an edit failed while time and requests remain.'
        )
        foreach ($prompt in @($initialPrompt, $dryRunRecovery, $oracleFailurePrompt,
            $repairPrompt, $helpRepairPrompt)) {
          foreach ($requirement in $requirements) {
            if (-not $prompt.Contains($requirement)) {
              throw "Case 10 prompt lost a public specification or receipt/fencing requirement."
            }
          }
          if ($prompt.Contains('CASE10_PRIVATE_ORACLE_DIAGNOSTIC')) {
            throw "Case 10 oracle diagnostics must remain hidden."
          }
        }
        if (-not $initialPrompt.Contains('First tool call: write receiptledger/__main__.py')) {
          throw "Case 10 initial prompt must request complete application behavior first."
        }
        if (-not $initialPrompt.Contains(
            'do not create separate app/store/storage/worker modules') -or
            -not $initialPrompt.Contains('Do not import local application modules')) {
          throw "Case 10 initial prompt must request one complete application module."
        }
        foreach ($prompt in @($repairPrompt, $helpRepairPrompt)) {
          if (-not $prompt.Contains('Repair the earliest failing local test or help gate') -or
              -not $prompt.Contains('preserve assertions') -or
              -not $prompt.Contains('at most 100 new lines')) {
            throw "Case 10 repair must preserve assertions and bounded application edits."
          }
          if (-not $prompt.Contains('first write tests/test_receiptledger.py') -or
              -not $prompt.Contains('never placeholders or an empty test suite') -or
              -not $prompt.Contains('at most one targeted read or grep') -or
              -not $prompt.Contains('Do not replace a complete module with a partial rewrite') -or
              -not $prompt.Contains('Read with offset/limit, at most 120 lines')) {
            throw "Case 10 repair must prioritize real tests and bounded reads/edits."
          }
        }
        $dryRunVerification.help[0].exit_code = 0
      } finally {
        Remove-Item -LiteralPath $oracleDiagnostic -Force
        if (@(Get-ChildItem -LiteralPath $dryRunProject -Force).Count -ne 0) {
          throw "Dry-run directory contains unexpected files: $dryRunProject"
        }
        Remove-Item -LiteralPath $dryRunProject -Force
      }
    }
    if ($_.Id -eq "07-lease-cascade") {
      $case07SpecPath = Join-Path (Join-Path $repoRoot $_.Source) "SPEC.md"
      $case07Spec = [IO.File]::ReadAllText($case07SpecPath)
      $entrypointPromptRequirements = @(
        'The complete Case 07 specification for this recovery follows:'
        $case07Spec
        ('Complete a compact entry point, help tests, and README in this attempt; ' +
          'yield after the four foundation writes.')
        ('Write CLI/health in __main__.py, then both test files and README; ' +
          'stop after those four writes and wait for harness feedback.')
      )
      foreach ($instruction in $entrypointPromptRequirements) {
        if (-not $dryRunRecovery.Contains($instruction)) {
          throw "Case 07 assembled entrypoint prompt is missing: $instruction"
        }
      }
      $dryRunProject = Join-Path ([IO.Path]::GetTempPath()) (
        "rupi-case07-dryrun-" + [Guid]::NewGuid().ToString("N")
      )
      $dryRunPackage = Join-Path $dryRunProject "leasecascade"
      $dryRunTests = Join-Path $dryRunProject "tests"
      $dryRunFiles = @(
        (Join-Path $dryRunPackage "__main__.py")
        (Join-Path $dryRunTests "__init__.py")
        (Join-Path $dryRunTests "test_leasecascade.py")
      )
      try {
        New-Item -ItemType Directory -Path $dryRunPackage, $dryRunTests | Out-Null
        foreach ($file in $dryRunFiles) { [IO.File]::WriteAllText($file, "") }
        $dryRunVerification.oracle.exit_code = 1
        $workflowPrompt = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        $workflowPromptRequirements = @(
          'The complete Case 07 specification for this recovery follows:'
          $case07Spec
          ('If workflow tests are missing, edit ' +
            'tests/test_leasecascade.py next. Otherwise add the next missing behavior')
          ('If workflow tests are missing, add tests and ' +
            'yield for harness feedback. Otherwise continue small implementation edits')
        )
        foreach ($instruction in $workflowPromptRequirements) {
          if (-not $workflowPrompt.Contains($instruction)) {
            throw "Case 07 assembled workflow prompt is missing: $instruction"
          }
        }
        $dryRunVerification.project_tests.exit_code = 1
        $localPrompt = Get-RecoveryPrompt $_ $dryRunVerification $dryRunProject
        $localPromptRequirements = @(
          $case07Spec
          'Repair the shown project-test failure before expanding behavior.'
          'Use the shown project-test diagnostic to make the smallest repair.'
          'Repair other failures from the same feedback while the request budget remains.'
        )
        foreach ($instruction in $localPromptRequirements) {
          if (-not $localPrompt.Contains($instruction)) {
            throw "Case 07 assembled local-test prompt is missing: $instruction"
          }
        }
        $editRecoveryRequirements = @(
          'Use the actual edit diagnostic; an attempted edit is not a completed change.'
          'If a failed edit explicitly made no change, read its target file before correcting it.'
          'Read a small target region with offset/limit; narrow it if the response is truncated.'
          ('Use file text in edit anchors, excluding displayed line numbers ' +
            'and truncation markers.')
          'Then edit the observed current text with a unique anchor and the native tool schema.'
          'Do not guess another stale anchor or rewrite the whole application after a failed edit.'
          ('If the diagnostic says already applied, inspect the file and ' +
            'preserve the completed change.')
          'For an Unknown mutation, inspect current state and defer retry until reconciliation.'
          ('After a known failure is corrected, continue public contract repairs ' +
            'within this attempt.')
          'Do not end an attempt merely because an edit failed while time and requests remain.'
        )
        foreach ($assembledPrompt in @($dryRunRecovery, $workflowPrompt, $localPrompt)) {
          foreach ($instruction in $editRecoveryRequirements) {
            if (-not $assembledPrompt.Contains($instruction)) {
              throw "Case 07 assembled recovery prompt is missing: $instruction"
            }
          }
        }
      } finally {
        foreach ($file in $dryRunFiles) {
          if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file -Force }
        }
        foreach ($directory in @($dryRunPackage, $dryRunTests, $dryRunProject)) {
          if (Test-Path -LiteralPath $directory) {
            if (@(Get-ChildItem -LiteralPath $directory -Force).Count -ne 0) {
              throw "Dry-run directory contains unexpected files: $directory"
            }
            Remove-Item -LiteralPath $directory -Force
          }
        }
      }
    }
    "{0}: package={1}; focus={2}" -f $_.Id, $_.Package, $_.Focus
  }
  exit 0
}
foreach ($budgetCase in @($cases | Where-Object { (Get-BenchmarkReasoningBudget $_) -gt 0 })) {
  $relayHealth = (Get-BenchmarkEndpoint $budgetCase) -replace '/v1$', '/healthz'
  $relay = Invoke-RestMethod $relayHealth -TimeoutSec 5
  if ($ThinkingLevel -ne "low" -or
      $relay.reasoning_budget_tokens -ne (Get-BenchmarkReasoningBudget $budgetCase) -or
      $relay.upstream -cne "http://127.0.0.1:8000/v1" -or
      $relay.content_logging -ne $false) {
    throw "$($budgetCase.Id) relay differs from the requested low-budget experiment."
  }
  if ($budgetCase.Id -eq "10-receipt-ledger" -and
      $Case10RelayResponseTimeoutSeconds -gt 0 -and
      $relay.response_timeout_seconds -ne $Case10RelayResponseTimeoutSeconds) {
    throw "Case 10 relay response deadline differs from the requested experiment."
  }
}
if ($Agent -ne "rupi") {
  $piLauncher = if ([string]::IsNullOrWhiteSpace($PiExecutable)) {
    (Get-Command pi -ErrorAction Stop).Source
  } else {
    (Resolve-Path -LiteralPath $PiExecutable -ErrorAction Stop).Path
  }
  if ([IO.Path]::GetExtension($piLauncher) -eq ".ps1") {
    $pwsh = (Get-Command pwsh.exe -ErrorAction Stop).Source
    $piVersionOutput = @(& $pwsh -NoProfile -ExecutionPolicy Bypass -File $piLauncher --version)
  } else {
    $piVersionOutput = @(& $piLauncher --version)
  }
  $piVersion = ($piVersionOutput -join "`n").Trim()
  if ($piVersion -ne $ExpectedPiVersion) {
    throw "Expected Pi $ExpectedPiVersion, but '$piLauncher' reported '$piVersion'."
  }
  Write-Host "Pi version: $piVersion"
} else {
  $piLauncher = $null
  $piVersion = $null
}
if (-not (Test-Path $rupiBinary)) { throw "Missing $rupiBinary; run cargo build --bin rupi first." }
New-Item -ItemType Directory -Force -Path $runRoot | Out-Null
$selectedAgents = if ($Agent -eq "all") { @("rupi", "pi") } else { @($Agent) }
$results = [Collections.Generic.List[object]]::new()
foreach ($case in $cases) {
  foreach ($selectedAgent in $selectedAgents) {
    Write-Host ("[{0}] {1}/{2}" -f (Get-Date -Format "HH:mm:ss"), $selectedAgent, $case.Id)
    [void]$results.Add((Invoke-AgentCase $case $selectedAgent (Join-Path $runRoot $case.Id) $ThinkingLevel))
    $partial = [ordered]@{
      run_id = $RunId
      pi_version = $piVersion
      thinking_level = $ThinkingLevel
      recovery_feedback_scope = $recoveryFeedbackScope
      results = @($results)
    }
    Write-Json (Join-Path $runRoot "partial.json") $partial
  }
}
$summary = [ordered]@{
  run_id = $RunId
  generated_at = (Get-Date).ToUniversalTime().ToString("o")
  pi_version = $piVersion
  model = "qwen3.8-flash-next"
  thinking_level = $ThinkingLevel
  recovery_feedback_scope = $recoveryFeedbackScope
  endpoint = if ($cases.Count -eq 1) {
    Get-BenchmarkEndpoint $cases[0]
  } else { "http://127.0.0.1:8000/v1" }
  case07_reasoning_budget_tokens = if ($Case07ReasoningBudgetTokens -gt 0) {
    $Case07ReasoningBudgetTokens
  } else { $null }
  case08_reasoning_budget_tokens = if ($Case08ReasoningBudgetTokens -gt 0) {
    $Case08ReasoningBudgetTokens
  } else { $null }
  case08_rupi_progress_boundary_mode = $Case08ProgressBoundaryMode
  case08_rupi_progress_request_window = $Case08ProgressRequestWindow
  case09_reasoning_budget_tokens = if ($Case09ReasoningBudgetTokens -gt 0) {
    $Case09ReasoningBudgetTokens
  } else { $null }
  case09_rupi_progress_boundary_mode = $Case09ProgressBoundaryMode
  case09_rupi_progress_request_window = $Case09ProgressRequestWindow
  case10_reasoning_budget_tokens = if ($Case10ReasoningBudgetTokens -gt 0) {
    $Case10ReasoningBudgetTokens
  } else { $null }
  case10_rupi_progress_boundary_mode = $Case10ProgressBoundaryMode
  case10_rupi_initial_progress_boundary = $Case10InitialProgressBoundary.IsPresent
  case10_max_output_tokens = $Case10MaxOutputTokens
  case10_rupi_max_turn_duration_ms = if ($Case10MaxTurnDurationMs -gt 0) {
    $Case10MaxTurnDurationMs
  } else { $null }
  case10_rupi_review_completion = $Case10ReviewCompletion.IsPresent
  case10_rupi_completion_review_reserve_ms = if ($Case10CompletionReviewReserveMs -gt 0) {
    $Case10CompletionReviewReserveMs
  } else { $null }
  case10_relay_response_timeout_seconds = if ($Case10RelayResponseTimeoutSeconds -gt 0) {
    $Case10RelayResponseTimeoutSeconds
  } else { $null }
  case10_rupi_progress_request_window = $Case10ProgressRequestWindow
  max_turns = $MaxTurns
  turn_timeout_seconds = $TurnTimeoutSeconds
  provider_timeout_grace_seconds = $script:providerTimeoutGraceSeconds
  provider_request_timeout_ms = $script:providerRequestTimeoutMs
  results = @($results)
}
Write-Json (Join-Path $runRoot "results.json") $summary
$summary | ConvertTo-Json -Depth 60
