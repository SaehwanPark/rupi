[CmdletBinding()]
param(
  [ValidateSet("all", "rupi", "pi")]
  [string]$Agent = "all",
  [string[]]$CaseId = @(),
  [string]$RunId = "",
  [ValidateRange(1, 10)]
  [int]$MaxTurns = 4,
  [ValidateRange(30, 3600)]
  [int]$TurnTimeoutSeconds = 900,
  [ValidateRange(1, 100)]
  [int]$MaxModelRequestsPerTurn = 24,
  [ValidateSet("off", "low")]
  [string]$ThinkingLevel = "low",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
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

function Get-InitialPrompt([hashtable]$case) {
  @"
You are implementing a new small project from scratch in the current workspace.
Read SPEC.md completely before acting. Build the complete dependency-free Python
3 project described by the specification, including its package, a readable
README.md, and focused unittest tests. The project focus is $($case.Focus).

Work only inside this project workspace. Do not edit SPEC.md, any rupi config,
or files outside this workspace. Do not inspect or run the external acceptance
oracle. Use only Python standard-library modules.

On this Windows host, use the available file and process tools directly for
known programs and avoid Unix-only shell assumptions or fragile inline quoting.
After reading the contract, make `tasklog/__main__.py` the first source file and
keep the CLI in that entry point until `add`, `list`, `done`, and `remove` work
with persistent JSON state. Do not create `__init__.py`, separate model or
storage modules, a README, tests, or placeholders before that runnable CLI
exists. Then add the README and focused tests. Run the project unittest suite,
the project-specific help commands described by SPEC.md, and a small smoke check
before finishing. Do not treat your final summary as proof: report exact
commands and statuses only after running them, and state any incomplete
requirement explicitly.
"@
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

function Get-RecoveryPrompt([hashtable]$case, [object]$verification) {
  $feedback = Get-RecoveryFeedback $verification
  @"
Continue the incomplete $($case.Package) implementation in this workspace.
Read SPEC.md and inspect the files already present. Work only inside this
workspace and do not edit the specification, rupi configs, or the external
acceptance oracle. Finish every missing implementation, README section, and
focused test required by the spec. Prioritize the full reliability contract:
$($case.Focus).

Use only Python standard-library modules and direct process arguments on Windows.
Previous local verification results (project tests and help commands):
$feedback

Use any failing local results above to correct the implementation. Continue
working through the missing items in SPEC.md, then run the complete project
unittest suite, the project-specific help commands, and a smoke sequence. If
anything remains incomplete, state it instead of claiming success.
"@
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
      $timeoutGraceSeconds = [int][math]::Min(
        30,
        [math]::Max(1, [math]::Floor($TurnTimeoutSeconds / 10))
      )
      $reqTimeout = ($TurnTimeoutSeconds - $timeoutGraceSeconds) * 1000
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
      Get-RecoveryPrompt $case $lastVerification
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
      $piLauncher = (Get-Command pi -ErrorAction Stop).Source
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
  Write-Host "Recovery feedback: project tests and help only"
  $cases | ForEach-Object { "{0}: {1}" -f $_.Id, (Get-InitialPrompt $_).Split("`n")[0] }
  exit 0
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
      thinking_level = $ThinkingLevel
      recovery_feedback_scope = "project_tests_and_help"
      results = @($results)
    }
    Write-Json (Join-Path $runRoot "partial.json") $partial
  }
}
$summary = [ordered]@{
  run_id = $RunId
  generated_at = (Get-Date).ToUniversalTime().ToString("o")
  model = "qwen3.8-flash-next"
  thinking_level = $ThinkingLevel
  recovery_feedback_scope = "project_tests_and_help"
  endpoint = "http://127.0.0.1:8000/v1"
  max_turns = $MaxTurns
  turn_timeout_seconds = $TurnTimeoutSeconds
  results = @($results)
}
Write-Json (Join-Path $runRoot "results.json") $summary
$summary | ConvertTo-Json -Depth 60
