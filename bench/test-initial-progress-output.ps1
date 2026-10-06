$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors
)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkInitialOutputLimit', 'Set-BenchmarkInitialOutputLimit')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$Case10InitialProgressMaxOutputTokens = 0
$Case10InitialProgressBoundary = $false
$limits = [pscustomobject]@{}
Set-BenchmarkInitialOutputLimit $case $limits
if ($limits.PSObject.Properties['initial_progress_max_output_tokens'] -or
    $null -ne (Get-BenchmarkInitialOutputLimit $case 'rupi')) { throw 'Default must omit selection.' }
$Case10InitialProgressMaxOutputTokens = 8192
$rejected = $false
try { Set-BenchmarkInitialOutputLimit $case $limits } catch { $rejected = $true }
if (-not $rejected -or $limits.PSObject.Properties['initial_progress_max_output_tokens']) {
  throw 'Initial progress dependency was bypassed.'
}
$Case10InitialProgressBoundary = $true
Set-BenchmarkInitialOutputLimit $case $limits
if ($limits.initial_progress_max_output_tokens -ne 8192 -or
    (Get-BenchmarkInitialOutputLimit $case 'rupi') -ne 8192 -or
    $null -ne (Get-BenchmarkInitialOutputLimit $case 'pi')) { throw 'Native selection or Pi null mismatch.' }
$other = [pscustomobject]@{}
Set-BenchmarkInitialOutputLimit @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['initial_progress_max_output_tokens'] -or
    $null -ne (Get-BenchmarkInitialOutputLimit @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Changed another case.'
}
Write-Output 'Owned initial output fixture passed: omission,8192,dependency,case isolation,Pi null.'
