$ErrorActionPreference = 'Stop'
$tokens=$null; $errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'),[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkFinalCheckReserve','Set-BenchmarkFinalCheckReserve')) {
  $definition=@($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned helper $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case=@{Id='10-receipt-ledger'}
$Case10CompletionCheckReserveFinal=$false
$Case10CompletionChecks=8
$limits=[pscustomobject]@{}
Set-BenchmarkFinalCheckReserve $case $limits
if ($limits.PSObject.Properties['completion_check_reserve_final'] -or
    $null -ne (Get-BenchmarkFinalCheckReserve $case 'rupi')) { throw 'Default changed.' }
$Case10CompletionCheckReserveFinal=$true
foreach ($checks in @(0,1)) {
  $Case10CompletionChecks=$checks
  $invalid=[pscustomobject]@{}
  $rejected=$false
  try { Set-BenchmarkFinalCheckReserve $case $invalid } catch { $rejected=$true }
  if (-not $rejected -or $invalid.PSObject.Properties['completion_check_reserve_final']) {
    throw 'Invalid final check reserve accepted.'
  }
}
foreach ($checks in @(2,8)) {
  $Case10CompletionChecks=$checks
  Set-BenchmarkFinalCheckReserve $case $limits
  if ($limits.completion_check_reserve_final -ne $true -or
      (Get-BenchmarkFinalCheckReserve $case 'rupi') -ne $true -or
      $null -ne (Get-BenchmarkFinalCheckReserve $case 'pi')) { throw 'Selection/Pi mismatch.' }
}
$other=[pscustomobject]@{}
Set-BenchmarkFinalCheckReserve @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['completion_check_reserve_final'] -or
    $null -ne (Get-BenchmarkFinalCheckReserve @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Other case changed.'
}
Write-Output 'Owned final check reserve passed: default, dependency, selection, isolation, Pi null.'
