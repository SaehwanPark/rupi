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
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$script:providerTimeoutGraceSeconds = [int][math]::Min(
  $ProviderTimeoutGraceSeconds,
  [math]::Max(1, [math]::Floor($TurnTimeoutSeconds / 10))
)
$script:providerRequestTimeoutMs = [int](
  ($TurnTimeoutSeconds - $script:providerTimeoutGraceSeconds) * 1000
)
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
    "05-batch-relay" {
      switch ($phase) {
        "initial" {
          return (@(
            'Build an import-safe CLI and persistent health server before batch behavior.'
            'After reading SPEC.md, make the first source write to batchrelay/__main__.py.'
            'It must run as python -m batchrelay and show top-level argparse help.'
            'Do not create __init__.py, tests, or support modules before __main__.py runs.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Create batchrelay/__main__.py with argparse and lazy command imports.'
            'Create tests/__init__.py, tests/test_cli.py, and tests/test_server.py.'
            'Use subprocess tests with sys.executable for top-level, serve, and worker help.'
            'Implement server.run(db, secret, host, port).'
            'Make GET /healthz return HTTP 200 JSON {"ok": true}.'
            'Subprocess-test serve: poll /healthz, confirm it stays alive, and clean up.'
            'Keep command modules lazy so every help command succeeds before worker.py exists.'
            'Do not implement signed batch routes or worker behavior in this first phase.'
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
            'The CLI and test-discovery foundation passed; implement only server health now.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Create server.py with run(db, secret, host, port); bind and call serve_forever().'
            'Implement GET /healthz as HTTP 200 application/json with {"ok": true}.'
            'Wire the serve command to server.run with a lazy import after argument parsing.'
            'Add tests/test_server.py with a subprocess health check and cleanup.'
            'Check that the service stays alive while /healthz is polled.'
            'Do not add batch routes or worker until this health test and all help checks pass.'
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
            'Signed admission passed; add validation and status tests in test_contract.py.'
            'Never store database state as handler attribute `connection`.'
            '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
            'Validate the full batch and dependency graph before one atomic database write.'
            'Malformed bodies, duplicate ids, and unknown fields return JSON 400.'
            'Missing or repeated dependencies, self-dependencies, and cycles return JSON 400.'
            'Rejected requests leave no rows, and the server stays up for the next request.'
            'GET /batches/<batch_id> returns full status or JSON 404 for an unknown batch.'
            'Test status reads and persistence across a server restart.'
            'Do not start worker work until these focused contract tests pass.'
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

function Get-InitialPrompt([hashtable]$case) {
  $guidance = Get-CaseGuidance $case
  $toolingGuidance = Get-WindowsToolGuidance
  $embeddedSpec = ""
  $caseSpecBlock = ""
  $specAccessOrder = if ($case.Id -eq "03-event-outbox") {
    'Implement the complete service and worker from the embedded Case 03 specification.'
  } else {
    'Read SPEC.md completely before acting.'
  }
  if ($case.Id -eq "03-event-outbox") {
    $specPath = Join-Path (Join-Path $repoRoot $case.Source) "SPEC.md"
    $embeddedSpec = [IO.File]::ReadAllText($specPath)
    $caseSpecBlock = "`nThe complete Case 03 specification follows:`n`n$embeddedSpec`n"
  }
  $verificationGuidance = if ($case.Id -eq "02-reading-queue") {
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
  if ($case.Id -eq "03-event-outbox") {
    $requiredInstructions += @(
      'Implement the complete service and worker from the embedded Case 03 specification.'
      'The full Case 03 specification is embedded in this prompt.'
      'Do not call `read`, `exec`, or another inspection tool before this first write.'
    )
  } else {
    $requiredInstructions += 'Read SPEC.md completely before acting'
  }
  if ($case.Id -eq "02-reading-queue") {
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
  if ($case.Id -eq "03-event-outbox" -and -not $prompt.Contains($embeddedSpec)) {
    throw 'Case 03 initial prompt is missing the complete project specification.'
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
  } elseif ($case.Id -eq "05-batch-relay") {
    $caseSpecificInstructions = @(
      'Build an import-safe CLI and persistent health server before batch behavior.'
      'After reading SPEC.md, make the first source write to batchrelay/__main__.py.'
      'It must run as python -m batchrelay and show top-level argparse help.'
      'Do not create __init__.py, tests, or support modules before __main__.py runs.'
      'Never store database state as handler attribute `connection`.'
      '`BaseHTTPRequestHandler` reserves `connection` for the client socket.'
      'Create batchrelay/__main__.py with argparse and lazy command imports.'
      'Create tests/__init__.py, tests/test_cli.py, and tests/test_server.py.'
      'Use subprocess tests with sys.executable for top-level, serve, and worker help.'
      'Implement server.run(db, secret, host, port).'
      'Make GET /healthz return HTTP 200 JSON {"ok": true}.'
      'Subprocess-test serve: poll /healthz, confirm it stays alive, and clean up.'
      'Keep command modules lazy so every help command succeeds before worker.py exists.'
      'Do not implement signed batch routes or worker behavior in this first phase.'
      'Advance only after harness project tests and all three help commands pass.'
      'Do not call `exec` or run shell commands; rely on the harness for verification.'
      'Never inspect or run the external oracle.'
    )
  }
  foreach ($instruction in $caseSpecificInstructions) {
    if (-not $prompt.Contains($instruction)) {
      throw "Initial benchmark prompt for $($case.Id) is missing: $instruction"
    }
  }
  if (
    $case.Id -eq "03-event-outbox" -and
    $prompt.Contains('Read SPEC.md completely before acting')
  ) {
    throw 'Case 03 prompt asks the agent to inspect SPEC.md before its first write.'
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
  $feedback = Get-RecoveryFeedback $verification
  $case05Phase = $null
  if ($case.Id -eq "05-batch-relay") {
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
  }
  $toolingGuidance = Get-WindowsToolGuidance
  $caseGuidance = if ($case.Id -eq "05-batch-relay") {
    Get-CaseGuidance $case $case05Phase
  } else {
    Get-CaseGuidance $case
  }
  $verificationResultLabel = if ($case.Id -eq "05-batch-relay") {
    'Previous harness results (oracle status, project tests, and help commands):'
  } else {
    'Previous local verification results (project tests and help commands):'
  }
  $recoveryHeader = if ($case.Id -eq "05-batch-relay") {
    $phaseHeader = switch ($case05Phase) {
      "foundation" {
        'CLI and test-discovery did not pass. Fix them before server, HTTP, or worker code.'
      }
      "health" {
        'CLI and test discovery passed. Implement and verify only persistent server health.'
      }
      "admission" {
        'CLI and server health passed. Complete and verify signed batch admission.'
      }
      "contract" {
        'Signed admission passed. Complete and verify HTTP validation and status.'
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
  } else {
    "Read SPEC.md and inspect the files already present. Work only inside this" +
      [Environment]::NewLine +
      "workspace and do not edit the specification, rupi configs, or the external" +
      [Environment]::NewLine + "acceptance oracle."
  }
  $verificationGuidance = if ($case.Id -eq "02-reading-queue") {
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
  } else {
@'
Continue working through the missing items in SPEC.md, then run the complete project
unittest suite, the project-specific help commands, and a smoke sequence.
'@
  }
  $completionDirective = if ($case.Id -eq "05-batch-relay") {
    'Complete this slice; advance after project tests and help pass.'
  } else {
    'Finish every missing implementation, README section, and focused test required by the spec.'
  }
  $continuationDirective = if ($case.Id -eq "05-batch-relay") {
    'Use failing local checks to repair this slice. Oracle status only; do not inspect or run it.'
  } else {
    'Continue working through the missing items in SPEC.md.'
  }
  $priorityDirective = if ($case.Id -eq "05-batch-relay") {
    'Prioritize the current gated phase.'
  } else {
    "Prioritize the full reliability contract: $($case.Focus)."
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
  if ($case.Id -eq "05-batch-relay") {
    $phaseInstruction = switch ($case05Phase) {
      "foundation" { 'CLI and test-discovery did not pass.' }
      "health" { 'CLI and test discovery passed.' }
      "admission" { 'CLI and server health passed.' }
      "contract" { 'Signed admission passed.' }
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
    $psi.Environment[$entry.Key] = [string]$entry.Value
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
    if ($null -eq $config.limits) {
      $config | Add-Member -MemberType NoteProperty -Name limits -Value ([pscustomobject]@{})
    }
    if ($null -eq $config.limits.PSObject.Properties["max_model_requests_per_turn"]) {
      $config.limits | Add-Member -MemberType NoteProperty -Name max_model_requests_per_turn -Value $MaxModelRequestsPerTurn
    } else {
      $config.limits.max_model_requests_per_turn = $MaxModelRequestsPerTurn
    }
    if ($config.endpoints -and $config.endpoints.Count -gt 0) {
      if ($config.endpoints[0].capabilities) {
        $config.endpoints[0].capabilities.max_output_tokens = 16384
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

function New-PiConfig([string]$agentRoot) {
  $piConfig = Join-Path $agentRoot "pi-config"
  New-Item -ItemType Directory -Force -Path $piConfig | Out-Null
  $models = [ordered]@{
    providers = [ordered]@{
      unsloth = [ordered]@{
        baseUrl = "http://127.0.0.1:8000/v1"
        api = "openai-completions"
        apiKey = "local"
        models = @([ordered]@{
          id = "qwen3.8-flash-next"
          name = "Qwen3.8 Flash Next"
          contextWindow = 262144
          maxTokens = 16384
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
  $toolNames = [Collections.Generic.List[string]]::new(); $status = $null; $finish = [Collections.Generic.List[string]]::new()
  $seenLines = 0
  foreach ($file in $traceFiles) {
    foreach ($line in (Get-Content -LiteralPath $file.FullName)) {
      if ($seenLines -lt $SkipLines) { $seenLines++; continue }
      $seenLines++
      try { $record = $line | ConvertFrom-Json } catch { continue }
      switch ($record.type) {
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
  $piConfig = New-PiConfig $agentRoot
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
      $call = Invoke-External -FileName $rupiBinary -Arguments @($args) -WorkingDirectory $workspace.project -StdoutPath (Join-Path $turnRoot "stdout.txt") -StderrPath (Join-Path $turnRoot "stderr.txt") -TimeoutSeconds $TurnTimeoutSeconds
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
      $args.Add("--tools"); $args.Add("read,write,edit,bash,powershell,grep,find,ls")
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
if ($DryRun) {
  Write-Host "Thinking level: $ThinkingLevel"
  Write-Host "Recovery feedback: project tests and help; Case 05 oracle status only"
  $cases | ForEach-Object {
    [void](Get-InitialPrompt $_)
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
    [void](Get-RecoveryPrompt $_ $dryRunVerification)
    "{0}: package={1}; focus={2}" -f $_.Id, $_.Package, $_.Focus
  }
  exit 0
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
$recoveryFeedbackScope = if (@($cases | Where-Object { $_.Id -eq "05-batch-relay" }).Count -gt 0) {
  "project_tests_and_help;case05_oracle_status_only"
} else {
  "project_tests_and_help"
}
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
  endpoint = "http://127.0.0.1:8000/v1"
  max_turns = $MaxTurns
  turn_timeout_seconds = $TurnTimeoutSeconds
  provider_timeout_grace_seconds = $script:providerTimeoutGraceSeconds
  provider_request_timeout_ms = $script:providerRequestTimeoutMs
  results = @($results)
}
Write-Json (Join-Path $runRoot "results.json") $summary
$summary | ConvertTo-Json -Depth 60
