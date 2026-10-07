$ErrorActionPreference = 'Stop'
$tokens=$null; $errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'),[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkInitialCheckWindow','Set-BenchmarkInitialCheckWindow')) {
  $definition=@($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned helper $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case=@{Id='10-receipt-ledger'}
$Case10CompletionCheckInitialRequestWindow=0
$MaxModelRequestsPerTurn=40
$Case10CompletionChecks=8
$limits=[pscustomobject]@{}
Set-BenchmarkInitialCheckWindow $case $limits
if ($limits.PSObject.Properties['completion_check_initial_request_window'] -or
    $null -ne (Get-BenchmarkInitialCheckWindow $case 'rupi')) { throw 'Default changed.' }
foreach ($profile in @(@(0,40,8),@(1,40,8),@(8,40,39),@(8,2,1),@(8,1,1))) {
  $Case10CompletionChecks=$profile[0]
  $MaxModelRequestsPerTurn=$profile[1]
  $Case10CompletionCheckInitialRequestWindow=$profile[2]
  $invalid=[pscustomobject]@{}
  $rejected=$false
  try { Set-BenchmarkInitialCheckWindow $case $invalid } catch { $rejected=$true }
  if (-not $rejected -or $invalid.PSObject.Properties['completion_check_initial_request_window']) {
    throw 'Invalid initial window accepted.'
  }
}
$MaxModelRequestsPerTurn=40
$Case10CompletionChecks=8
$Case10CompletionCheckInitialRequestWindow=8
Set-BenchmarkInitialCheckWindow $case $limits
if ($limits.completion_check_initial_request_window -ne 8 -or
    (Get-BenchmarkInitialCheckWindow $case 'rupi') -ne 8 -or
    $null -ne (Get-BenchmarkInitialCheckWindow $case 'pi')) { throw 'Selection/Pi mismatch.' }
$other=[pscustomobject]@{}
Set-BenchmarkInitialCheckWindow @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['completion_check_initial_request_window'] -or
    $null -ne (Get-BenchmarkInitialCheckWindow @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Other case changed.'
}
Write-Output 'Owned initial check window passed: default, dependencies, selection, isolation, Pi null.'
