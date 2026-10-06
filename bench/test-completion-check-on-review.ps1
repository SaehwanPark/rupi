$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkReviewCheck', 'Set-BenchmarkReviewCheck',
    'Get-BenchmarkReviewRequestReserve', 'Set-BenchmarkReviewRequestReserve')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$Case10CompletionCheckOnReview = $false
$Case10CompletionReviewRequestReserve = 0
$MaxModelRequestsPerTurn = 40
$limits = [pscustomobject]@{}
Set-BenchmarkReviewCheck $case $limits
Set-BenchmarkReviewRequestReserve $case $limits
if ($limits.PSObject.Properties['completion_check_on_review'] -or
    $limits.PSObject.Properties['completion_review_request_reserve'] -or
    $null -ne (Get-BenchmarkReviewRequestReserve $case 'rupi') -or
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
$Case10CompletionChecks = 8
foreach ($requestOnly in @($false, $true)) {
  $Case10CompletionReviewReserveMs = if ($requestOnly) { 0 } else { 300000 }
  $Case10CompletionReviewRequestReserve = if ($requestOnly) { 8 } else { 0 }
  $limits = [pscustomobject]@{}
  Set-BenchmarkReviewCheck $case $limits
  Set-BenchmarkReviewRequestReserve $case $limits
  if ($requestOnly -and ($limits.completion_review_request_reserve -ne 8 -or
      (Get-BenchmarkReviewRequestReserve $case 'rupi') -ne 8)) { throw 'Request reserve lost.' }
  if (-not $requestOnly -and $limits.PSObject.Properties['completion_review_request_reserve']) {
    throw 'Default reserve became active.'
  }
}
if ($limits.completion_check_on_review -ne $true -or
    (Get-BenchmarkReviewCheck $case 'rupi') -ne $true -or
    $null -ne (Get-BenchmarkReviewCheck $case 'pi') -or
    $null -ne (Get-BenchmarkReviewRequestReserve $case 'pi')) { throw 'Native/Pi mismatch.' }
foreach ($profile in @(@($false,40,8), @($true,40,39), @($true,40,40),
    @($true,2,1), @($true,1,1))) {
  $Case10ReviewCompletion = $profile[0]
  $MaxModelRequestsPerTurn = $profile[1]
  $Case10CompletionReviewRequestReserve = $profile[2]
  $rejected = $false
  $invalid = [pscustomobject]@{}
  try { Set-BenchmarkReviewRequestReserve $case $invalid } catch { $rejected = $true }
  if (-not $rejected -or $invalid.PSObject.Properties['completion_review_request_reserve']) {
    throw 'Invalid reserve accepted.'
  }
}
$Case10ReviewCompletion = $true
$MaxModelRequestsPerTurn = 40
$Case10CompletionReviewRequestReserve = 8
$other = [pscustomobject]@{}
Set-BenchmarkReviewCheck @{Id='09-lease-receipt'} $other
Set-BenchmarkReviewRequestReserve @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['completion_check_on_review'] -or
    $other.PSObject.Properties['completion_review_request_reserve'] -or
    $null -ne (Get-BenchmarkReviewCheck @{Id='09-lease-receipt'} 'rupi') -or
    $null -ne (Get-BenchmarkReviewRequestReserve @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Changed another case.'
}
Write-Output 'Owned review check fixture passed: default,dependencies,selection,case isolation,Pi null.'
