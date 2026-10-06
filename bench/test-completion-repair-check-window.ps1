$ErrorActionPreference = 'Stop'
$tokens=$null; $errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'),[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkRepairCheckWindow','Set-BenchmarkRepairCheckWindow')) {
  $definition=@($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned helper $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case=@{Id='10-receipt-ledger'}
$Case10CompletionCheckRepairRequestWindow=0
$MaxModelRequestsPerTurn=40
$Case10CompletionChecks=8
$limits=[pscustomobject]@{}
Set-BenchmarkRepairCheckWindow $case $limits
if ($limits.PSObject.Properties['completion_check_repair_request_window'] -or
    $null -ne (Get-BenchmarkRepairCheckWindow $case 'rupi')) { throw 'Default changed.' }
foreach ($profile in @(@(0,40,3),@(1,40,3),@(8,40,39),@(8,2,1),@(8,1,1))) {
  $Case10CompletionChecks=$profile[0]
  $MaxModelRequestsPerTurn=$profile[1]
  $Case10CompletionCheckRepairRequestWindow=$profile[2]
  $invalid=[pscustomobject]@{}
  $rejected=$false
  try { Set-BenchmarkRepairCheckWindow $case $invalid } catch { $rejected=$true }
  if (-not $rejected -or $invalid.PSObject.Properties['completion_check_repair_request_window']) {
    throw 'Invalid window accepted.'
  }
}
$MaxModelRequestsPerTurn=40
$Case10CompletionChecks=8
$Case10CompletionCheckRepairRequestWindow=3
Set-BenchmarkRepairCheckWindow $case $limits
if ($limits.completion_check_repair_request_window -ne 3 -or
    (Get-BenchmarkRepairCheckWindow $case 'rupi') -ne 3 -or
    $null -ne (Get-BenchmarkRepairCheckWindow $case 'pi')) { throw 'Selection/Pi mismatch.' }
$other=[pscustomobject]@{}
Set-BenchmarkRepairCheckWindow @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['completion_check_repair_request_window'] -or
    $null -ne (Get-BenchmarkRepairCheckWindow @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Other case changed.'
}
Write-Output 'Owned repair check window passed: default, dependencies, selection, case isolation, Pi null.'
