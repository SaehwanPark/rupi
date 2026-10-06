$ErrorActionPreference = 'Stop'
$tokens=$null; $errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'),[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkReviewCheckReserve','Set-BenchmarkReviewCheckReserve')) {
  $definition=@($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned helper $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case=@{Id='10-receipt-ledger'}
$Case10CompletionReviewCheckReserve=0
$Case10ReviewCompletion=$true
$Case10CompletionChecks=8
$limits=[pscustomobject]@{}
Set-BenchmarkReviewCheckReserve $case $limits
if ($limits.PSObject.Properties['completion_review_check_reserve'] -or
    $null -ne (Get-BenchmarkReviewCheckReserve $case 'rupi')) { throw 'Default changed.' }
foreach ($profile in @(@($false,8,2),@($true,0,2),@($true,1,1),@($true,8,8))) {
  $Case10ReviewCompletion=$profile[0]
  $Case10CompletionChecks=$profile[1]
  $Case10CompletionReviewCheckReserve=$profile[2]
  $invalid=[pscustomobject]@{}
  $rejected=$false
  try { Set-BenchmarkReviewCheckReserve $case $invalid } catch { $rejected=$true }
  if (-not $rejected -or $invalid.PSObject.Properties['completion_review_check_reserve']) {
    throw 'Invalid check review reserve accepted.'
  }
}
$Case10ReviewCompletion=$true
$Case10CompletionChecks=8
$Case10CompletionReviewCheckReserve=2
Set-BenchmarkReviewCheckReserve $case $limits
if ($limits.completion_review_check_reserve -ne 2 -or
    (Get-BenchmarkReviewCheckReserve $case 'rupi') -ne 2 -or
    $null -ne (Get-BenchmarkReviewCheckReserve $case 'pi')) { throw 'Selection/Pi mismatch.' }
$other=[pscustomobject]@{}
Set-BenchmarkReviewCheckReserve @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['completion_review_check_reserve'] -or
    $null -ne (Get-BenchmarkReviewCheckReserve @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Other case changed.'
}
Write-Output 'Owned check review reserve passed: default, dependencies, selection, isolation, Pi null.'
