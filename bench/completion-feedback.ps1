# Caller-owned Case10 public checks. These functions never use the acceptance oracle.
function Get-CompletionCanonicalPath([string]$Path) {
  $resolved = [IO.Path]::GetFullPath($Path)
  if ($resolved.StartsWith('\\?\UNC\')) { $resolved = '\\' + $resolved.Substring(8) }
  elseif ($resolved.StartsWith('\\?\')) { $resolved = $resolved.Substring(4) }
  $resolved.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
}

function New-CompletionFeedbackHost(
  [string]$Project, [string]$TurnRoot, [string]$Python, [object[]]$HelpArguments
) {
  $root = Join-Path $TurnRoot ('completion-' + [Guid]::NewGuid().ToString('N'))
  $canonicalProject = Get-CompletionCanonicalPath $Project
  $canonicalRoot = Get-CompletionCanonicalPath $root
  if ($canonicalRoot -eq $canonicalProject -or
      $canonicalRoot.StartsWith($canonicalProject + [IO.Path]::DirectorySeparatorChar,
        [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Completion host artifacts must be outside the model workspace.'
  }
  $mailbox = Join-Path $root 'mailbox'
  New-Item -ItemType Directory -Path $mailbox -Force | Out-Null
  [pscustomobject]@{
    project = $canonicalProject
    root = [IO.Path]::GetFullPath($root)
    mailbox = [IO.Path]::GetFullPath($mailbox)
    python = $Python
    help_arguments = $HelpArguments
    handled = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
  }
}

function Write-CompletionReply([object]$HostState, [string]$RequestId, [string]$Status, [string]$Feedback) {
  # Bound UTF-8 bytes, including multibyte diagnostics; no path or diagnostic becomes an instruction.
  $encoding = [Text.UTF8Encoding]::new($false)
  while ($encoding.GetByteCount($Feedback) -gt 16384) {
    $Feedback = $Feedback.Substring(0, [math]::Max(0, $Feedback.Length - 256))
  }
  if ($Feedback.Length -gt 0 -and [char]::IsHighSurrogate($Feedback[$Feedback.Length - 1])) {
    $Feedback = $Feedback.Substring(0, $Feedback.Length - 1)
  }
  $reply = [ordered]@{ version = 1; request_id = $RequestId; status = $Status; feedback = $Feedback }
  $temporary = Join-Path $HostState.mailbox ('reply-' + $RequestId + '.tmp')
  $published = Join-Path $HostState.mailbox ('reply-' + $RequestId + '.json')
  $stream = [IO.File]::Open($temporary, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
  try {
    $bytes = $encoding.GetBytes(($reply | ConvertTo-Json -Compress))
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush($true)
  } finally { $stream.Dispose() }
  [IO.File]::Move($temporary, $published)
}

function Copy-CompletionPublicSnapshot([string]$Project, [string]$Snapshot, [Diagnostics.Stopwatch]$Clock, [long]$BudgetMs) {
  New-Item -ItemType Directory -Path $Snapshot | Out-Null
  $totalBytes = [long]0; $files = 0
  # Explicit public package/tests/documentation roots exclude state, configs and private oracle files.
  foreach ($name in @('receiptledger', 'tests', 'README.md')) {
    $source = Join-Path $Project $name
    if (-not (Test-Path -LiteralPath $source)) { continue }
    $pending = [Collections.Generic.Queue[object]]::new()
    $pending.Enqueue((Get-Item -LiteralPath $source -Force))
    while ($pending.Count) {
      if ($Clock.ElapsedMilliseconds -ge $BudgetMs) { throw 'snapshot timeout' }
      $entry = $pending.Dequeue()
      if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'public snapshot has a link' }
      $relative = [IO.Path]::GetRelativePath($Project, $entry.FullName)
      if ($relative.StartsWith('..') -or [IO.Path]::IsPathRooted($relative)) { throw 'snapshot escaped project' }
      $destination = Join-Path $Snapshot $relative
      if ($entry.PSIsContainer) {
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
        foreach ($child in (Get-ChildItem -LiteralPath $entry.FullName -Force)) {
          if ($child.Name -eq '__pycache__') { continue }
          $pending.Enqueue($child)
        }
      } else {
        $files++; $totalBytes += $entry.Length
        if ($files -gt 1000 -or $entry.Length -gt 10485760 -or $totalBytes -gt 104857600) {
          throw 'public snapshot exceeded its size bound'
        }
        Copy-Item -LiteralPath $entry.FullName -Destination $destination
      }
    }
  }
}

function Invoke-CompletionPublicCheck([object]$HostState, [object]$Request, [long]$OuterRemainingMs) {
  $clock = [Diagnostics.Stopwatch]::StartNew()
  $budgetMs = [long][math]::Min(300000, [math]::Min($Request.wait_timeout_ms, $OuterRemainingMs)) - 2000
  if ($budgetMs -lt 1000) { throw 'insufficient completion observation time' }
  $checkRoot = Join-Path $HostState.root ('check-' + $Request.request_id)
  New-Item -ItemType Directory -Path $checkRoot | Out-Null
  $snapshot = Join-Path $checkRoot 'public-project'
  Copy-CompletionPublicSnapshot $HostState.project $snapshot $clock $budgetMs
  $lines = [Collections.Generic.List[string]]::new(); $failed = $false
  foreach ($required in @('receiptledger/__main__.py', 'receiptledger/__init__.py',
    'tests/test_receiptledger.py', 'tests/__init__.py', 'README.md')) {
    if (-not (Test-Path -LiteralPath (Join-Path $snapshot $required) -PathType Leaf)) {
      $failed = $true; $lines.Add("Missing requested public deliverable: $required")
    }
  }
  $commands = [Collections.Generic.List[object]]::new()
  $commands.Add([pscustomobject]@{ name = 'project tests'; seconds = 180;
    arguments = @('-W', 'error::ResourceWarning', '-m', 'unittest', 'discover', '-s', 'tests', '-p', 'test_*.py', '-v') })
  foreach ($helpArgs in $HostState.help_arguments) {
    $commands.Add([pscustomobject]@{ name = 'help ' + ($helpArgs -join ' '); seconds = 30;
      arguments = @('-m', 'receiptledger') + @($helpArgs) })
  }
  $index = 0
  foreach ($command in $commands) {
    $seconds = [int][math]::Min($command.seconds, [math]::Floor(($budgetMs - $clock.ElapsedMilliseconds) / 1000))
    if ($seconds -lt 1) { throw 'public checks exhausted observation time' }
    $index++
    $result = Invoke-External -FileName $HostState.python -Arguments $command.arguments `
      -WorkingDirectory $snapshot -StdoutPath (Join-Path $checkRoot "$index.stdout.txt") `
      -StderrPath (Join-Path $checkRoot "$index.stderr.txt") -TimeoutSeconds $seconds
    if ($result.timed_out -or $result.callback_failed -or $null -eq $result.exit_code) {
      throw 'public check completion uncertain; no check was replayed'
    }
    $passed = $result.exit_code -eq 0
    if ($index -eq 1) {
      $publicOutput = [IO.File]::ReadAllText($result.stderr_path)
      if ($publicOutput -notmatch '(?m)^Ran [1-9][0-9]* tests? in ') {
        $passed = $false; $lines.Add('Public unittest discovery did not report any executed tests.')
      }
    }
    $lines.Add("$($command.name): $(if ($passed) {'passed'} else {'failed'}) (exit $($result.exit_code))")
    if (-not $passed) {
      $failed = $true
      foreach ($path in @($result.stderr_path, $result.stdout_path)) {
        $excerpt = @(Get-Content -LiteralPath $path -Tail 18) -join "`n"
        if ($excerpt.Length -gt 1200) { $excerpt = $excerpt.Substring($excerpt.Length - 1200) }
        if ($excerpt) { $lines.Add("Public diagnostic excerpt:`n$excerpt"); break }
      }
    }
  }
  if ($clock.ElapsedMilliseconds -ge $budgetMs) { throw 'completion observation deadline expired' }
  [pscustomobject]@{ status = if ($failed) {'failed'} else {'passed'}; feedback = $lines -join "`n" }
}

function Invoke-CompletionFeedbackHost([object]$HostState, [int]$ProcessId, [long]$OuterRemainingMs) {
  foreach ($file in (Get-ChildItem -LiteralPath $HostState.mailbox -File -Filter 'request-*.json')) {
    if ($HostState.handled.Contains($file.Name) -or $file.Length -gt 65536) { continue }
    try { $request = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false, $true)) | ConvertFrom-Json }
    catch { continue }
    if ($request.process_id -ne $ProcessId) { continue }
    $parsedId = [Guid]::Empty
    if (-not [Guid]::TryParse([string]$request.request_id, [ref]$parsedId) -or
        $file.Name -cne ('request-' + $request.request_id + '.json')) { continue }
    # Mark before starting effects. Even an unavailable check is never automatically replayed.
    [void]$HostState.handled.Add($file.Name)
    $status = 'unavailable'; $feedback = 'Caller public observation unavailable; no check was replayed.'
    try {
      $fields = @($request.PSObject.Properties.Name | Sort-Object)
      $expected = @('version', 'request_id', 'process_id', 'ordinal', 'workspace', 'wait_timeout_ms' | Sort-Object)
      if (($fields -join ',') -cne ($expected -join ',') -or $request.version -ne 1 -or
          $request.ordinal -lt 1 -or $request.ordinal -gt 16 -or
          $request.wait_timeout_ms -le 0 -or $request.wait_timeout_ms -gt 300000 -or
          (Get-CompletionCanonicalPath $request.workspace) -ne $HostState.project) {
        throw 'invalid caller observation request'
      }
      $result = Invoke-CompletionPublicCheck $HostState $request $OuterRemainingMs
      $status = $result.status; $feedback = $result.feedback
    } catch { }
    Write-CompletionReply $HostState $request.request_id $status $feedback
  }
}
