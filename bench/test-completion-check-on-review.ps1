$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkReviewCheck', 'Set-BenchmarkReviewCheck')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$Case10CompletionCheckOnReview = $false
$limits = [pscustomobject]@{}
Set-BenchmarkReviewCheck $case $limits
if ($limits.PSObject.Properties['completion_check_on_review'] -or
    (Get-BenchmarkReviewCheck $case 'rupi') -ne $false) { throw 'Default mismatch.' }
$Case10CompletionCheckOnReview = $true
foreach ($profile in @(@($false,300000,8), @($true,0,8), @($true,300000,0))) {
  $Case10ReviewCompletion = $profile[0]
  $Case10CompletionReviewReserveMs = $profile[1]
  $Case10CompletionChecks = $profile[2]
  $rejected = $false
  try { Set-BenchmarkReviewCheck $case $limits } catch { $rejected = $true }
  if (-not $rejected -or $limits.PSObject.Properties['completion_check_on_review']) {
    throw 'Dependency was bypassed.'
  }
}
$Case10ReviewCompletion = $true
$Case10CompletionReviewReserveMs = 300000
$Case10CompletionChecks = 8
Set-BenchmarkReviewCheck $case $limits
if ($limits.completion_check_on_review -ne $true -or
    (Get-BenchmarkReviewCheck $case 'rupi') -ne $true -or
    $null -ne (Get-BenchmarkReviewCheck $case 'pi')) { throw 'Native/Pi mismatch.' }
$other = [pscustomobject]@{}
Set-BenchmarkReviewCheck @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['completion_check_on_review'] -or
    $null -ne (Get-BenchmarkReviewCheck @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Changed another case.'
}
Write-Output 'Owned review check fixture passed: default,dependencies,selection,case isolation,Pi null.'
