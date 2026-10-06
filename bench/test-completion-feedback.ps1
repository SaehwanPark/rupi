$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'completion-feedback.ps1')
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors
)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Invoke-External', 'Write-Text')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Owned function missing: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$python = (Get-Command python -ErrorAction Stop).Source
$fixture = Join-Path $repoRoot ('.benchmark/completion-host-' + [Guid]::NewGuid().ToString('N'))
$project = Join-Path $fixture 'project'
$turnRoot = Join-Path $fixture 'turn'
foreach ($name in @('receiptledger', 'tests', 'acceptance', '.rupi-state')) {
  New-Item -ItemType Directory -Path (Join-Path $project $name) -Force | Out-Null
}
$utf8 = [Text.UTF8Encoding]::new($false)
function Write-Owned([string]$Name, [string]$Text) {
  [IO.File]::WriteAllText((Join-Path $project $Name), $Text, $utf8)
}
Write-Owned 'receiptledger/__init__.py' ''
Write-Owned 'receiptledger/__main__.py' "print('owned help')"
Write-Owned 'tests/__init__.py' ''
Write-Owned 'README.md' 'owned README'
Write-Owned 'acceptance/test_private.py' "raise RuntimeError('owned-private-marker')"
Write-Owned '.rupi-state/private.txt' 'owned-private-marker'
$passingTest = @'
import unittest
from pathlib import Path
class Owned(unittest.TestCase):
    def test_public(self):
        Path('owned-observation.txt').write_text('snapshot effect', encoding='utf-8')
        self.assertEqual(1, 1)
'@
Write-Owned 'tests/test_receiptledger.py' $passingTest
$state = New-CompletionFeedbackHost $project $turnRoot $python @(@('--help'))
$rejectedInside = $false
try { New-CompletionFeedbackHost $project $project $python @(@('--help')) | Out-Null }
catch { $rejectedInside = $true }
if (-not $rejectedInside) { throw 'Host artifacts inside the model workspace were accepted.' }
function Submit-Owned([int]$Ordinal, [long]$WaitMs = 30000, [int]$OwnerId = $PID, [bool]$Invalid = $false) {
  $id = [Guid]::NewGuid().ToString()
  $request = [ordered]@{ version=1; request_id=$id; process_id=$OwnerId; ordinal=$Ordinal;
    workspace=$project; wait_timeout_ms=$WaitMs }
  if ($Invalid) { $request['unexpected'] = 'owned invalid field' }
  [IO.File]::WriteAllText((Join-Path $state.mailbox "request-$id.json"),
    ($request | ConvertTo-Json -Compress), $utf8)
  $id
}
function Read-OwnedReply([string]$Id) {
  [IO.File]::ReadAllText((Join-Path $state.mailbox "reply-$Id.json")) | ConvertFrom-Json
}
$stale = Submit-Owned 1 10000 ($PID + 100000)
$id = Submit-Owned 1
Invoke-CompletionFeedbackHost $state $PID 30000
$reply = Read-OwnedReply $id
if ($reply.status -cne 'passed' -or $reply.feedback.Contains('owned-private-marker')) {
  throw 'Public pass or private-content exclusion failed.'
}
if (Test-Path -LiteralPath (Join-Path $state.mailbox "reply-$stale.json")) { throw 'Handled stale process.' }
$snapshot = Join-Path $state.root "check-$id/public-project"
if (-not (Test-Path -LiteralPath (Join-Path $snapshot 'owned-observation.txt')) -or
    (Test-Path -LiteralPath (Join-Path $project 'owned-observation.txt')) -or
    (Test-Path -LiteralPath (Join-Path $snapshot 'acceptance')) -or
    (Test-Path -LiteralPath (Join-Path $snapshot '.rupi-state'))) {
  throw 'Public snapshot effects or private exclusion failed.'
}
$published = Get-Item -LiteralPath (Join-Path $state.mailbox "reply-$id.json")
$previousTicks = $published.LastWriteTimeUtc.Ticks
Invoke-CompletionFeedbackHost $state $PID 30000
if ((Get-Item -LiteralPath $published.FullName).LastWriteTimeUtc.Ticks -ne $previousTicks -or
    $state.handled.Count -ne 1) { throw 'Host replayed a handled check.' }

Write-Owned 'tests/test_receiptledger.py' $passingTest.Replace('self.assertEqual(1, 1)',
  "self.fail('owned-public-failure')")
$id = Submit-Owned 2
Invoke-CompletionFeedbackHost $state $PID 30000
$reply = Read-OwnedReply $id
if ($reply.status -cne 'failed' -or -not $reply.feedback.Contains('owned-public-failure')) {
  throw 'Bounded public diagnostic was not supplied.'
}
Write-Owned 'tests/test_receiptledger.py' $passingTest
# Rename an explicitly owned fixture path; preserve it as an artifact.
Move-Item -LiteralPath (Join-Path $project 'README.md') -Destination (Join-Path $project 'README.saved')
$id = Submit-Owned 3
Invoke-CompletionFeedbackHost $state $PID 30000
$reply = Read-OwnedReply $id
if ($reply.status -cne 'failed' -or -not $reply.feedback.Contains('README.md')) { throw 'Missing README accepted.' }
Move-Item -LiteralPath (Join-Path $project 'README.saved') -Destination (Join-Path $project 'README.md')
Write-Owned 'tests/test_receiptledger.py' '# owned empty tests'
$id = Submit-Owned 4
Invoke-CompletionFeedbackHost $state $PID 30000
$reply = Read-OwnedReply $id
if ($reply.status -cne 'failed' -or -not $reply.feedback.Contains('executed tests')) { throw 'Empty tests accepted.' }
$id = Submit-Owned 5 10000 $PID $true
Invoke-CompletionFeedbackHost $state $PID 30000
if ((Read-OwnedReply $id).status -cne 'unavailable' -or
    (Test-Path -LiteralPath (Join-Path $state.root "check-$id"))) { throw 'Invalid request ran checks.' }
Write-Owned 'tests/test_receiptledger.py' $passingTest.Replace('self.assertEqual(1, 1)',
  '__import__("time").sleep(2)')
$id = Submit-Owned 6 13100
Invoke-CompletionFeedbackHost $state $PID 30000
if ((Read-OwnedReply $id).status -cne 'unavailable') { throw 'Uncertain timed check accepted.' }
if (-not (Test-Path -LiteralPath (Join-Path $state.root "check-$id/1.stderr.txt"))) {
  throw 'Owned timeout fixture did not start its public command.'
}
Write-Owned 'tests/test_receiptledger.py' $passingTest

# The real process wait path must service the callback while the child is still alive.
$childScript = Join-Path $fixture 'owned-mailbox-child.py'
$childSource = @'
import json, os, sys, time, uuid
from pathlib import Path
mailbox, project = map(Path, sys.argv[1:])
request_id = str(uuid.uuid4())
request = dict(version=1, request_id=request_id, process_id=os.getpid(), ordinal=7,
               workspace=str(project), wait_timeout_ms=25000)
temporary = mailbox / ('request-' + request_id + '.tmp')
temporary.write_text(json.dumps(request), encoding='utf-8')
temporary.rename(mailbox / ('request-' + request_id + '.json'))
reply_path = mailbox / ('reply-' + request_id + '.json')
deadline = time.monotonic() + 27
while not reply_path.exists() and time.monotonic() < deadline:
    time.sleep(0.02)
reply = json.loads(reply_path.read_text(encoding='utf-8'))
sys.exit(0 if reply['status'] == 'passed' else 1)
'@
[IO.File]::WriteAllText($childScript, $childSource, $utf8)
$state | Add-Member -NotePropertyName callback_error -NotePropertyValue ''
$callback = { param($processId, $remainingMs)
  try { Invoke-CompletionFeedbackHost $state $processId $remainingMs }
  catch { $state.callback_error = $_.Exception.Message; throw }
}
$result = Invoke-External -FileName $python -Arguments @($childScript, $state.mailbox, $project) `
  -WorkingDirectory $fixture -StdoutPath (Join-Path $fixture 'child.stdout.txt') `
  -StderrPath (Join-Path $fixture 'child.stderr.txt') -TimeoutSeconds 30 -WhileRunning $callback
if ($result.exit_code -ne 0 -or $result.timed_out -or $result.callback_failed) {
  throw "Owned live callback failed: $($state.callback_error)"
}
$default = Invoke-External -FileName $python -Arguments @('-c', 'print("owned default")') `
  -WorkingDirectory $fixture -StdoutPath (Join-Path $fixture 'default.stdout.txt') `
  -StderrPath (Join-Path $fixture 'default.stderr.txt') -TimeoutSeconds 5
if ($default.exit_code -ne 0 -or $default.timed_out) { throw 'Default wait path changed.' }
Write-Output 'Owned completion host fixtures passed: snapshots, public feedback, exclusion, once, timeout, live callback.'
