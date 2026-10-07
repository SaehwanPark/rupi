$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors
)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkInitialArgumentLimit', 'Set-BenchmarkInitialArgumentLimit')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$Case10InitialProgressMaxArgumentChars = 0
$Case10InitialProgressMaxOutputTokens = 8192
$Case10InitialProgressBoundary = $false
$limits = [pscustomobject]@{}
Set-BenchmarkInitialArgumentLimit $case $limits
if ($limits.PSObject.Properties['initial_progress_max_argument_chars'] -or
    $null -ne (Get-BenchmarkInitialArgumentLimit $case 'rupi')) { throw 'Default must omit selection.' }
$Case10InitialProgressMaxArgumentChars = 2048
$rejected = $false
try { Set-BenchmarkInitialArgumentLimit $case $limits } catch { $rejected = $true }
if (-not $rejected -or $limits.PSObject.Properties['initial_progress_max_argument_chars']) {
  throw 'Initial progress dependency was bypassed.'
}
$Case10InitialProgressBoundary = $true
$Case10InitialProgressMaxOutputTokens = 0
$rejected = $false
try { Set-BenchmarkInitialArgumentLimit $case $limits } catch { $rejected = $true }
if (-not $rejected -or $limits.PSObject.Properties['initial_progress_max_argument_chars']) {
  throw 'Initial output dependency was bypassed.'
}
$Case10InitialProgressMaxOutputTokens = 8192
Set-BenchmarkInitialArgumentLimit $case $limits
if ($limits.initial_progress_max_argument_chars -ne 2048 -or
    (Get-BenchmarkInitialArgumentLimit $case 'rupi') -ne 2048 -or
    $null -ne (Get-BenchmarkInitialArgumentLimit $case 'pi')) { throw 'Native selection or Pi null mismatch.' }
$other = [pscustomobject]@{}
Set-BenchmarkInitialArgumentLimit @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['initial_progress_max_argument_chars'] -or
    $null -ne (Get-BenchmarkInitialArgumentLimit @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Changed another case.'
}
Write-Output 'Owned initial argument fixture passed: omission,2048,dependency,case isolation,Pi null.'
