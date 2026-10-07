$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors
)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkMutatingBudget', 'Set-BenchmarkMutatingBudget')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$Case10MaxMutatingToolCalls = 0
$limits = [pscustomobject]@{}
Set-BenchmarkMutatingBudget $case $limits
if ($limits.PSObject.Properties['max_mutating_tool_calls_per_turn'] -or
    $null -ne (Get-BenchmarkMutatingBudget $case 'rupi')) { throw 'Default must omit selection.' }
$Case10MaxMutatingToolCalls = 32
Set-BenchmarkMutatingBudget $case $limits
if ($limits.max_mutating_tool_calls_per_turn -ne 32 -or
    $limits.PSObject.Properties['max_tool_calls_per_turn'] -or
    (Get-BenchmarkMutatingBudget $case 'rupi') -ne 32 -or
    $null -ne (Get-BenchmarkMutatingBudget $case 'pi')) { throw 'Native budget or Pi null mismatch.' }
$other = [pscustomobject]@{}
Set-BenchmarkMutatingBudget @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['max_mutating_tool_calls_per_turn'] -or
    $null -ne (Get-BenchmarkMutatingBudget @{Id='09-lease-receipt'} 'rupi')) { throw 'Changed another case.' }
$lowTotal = [pscustomobject]@{max_tool_calls_per_turn=16}
$rejected = $false
try { Set-BenchmarkMutatingBudget $case $lowTotal } catch { $rejected = $true }
if (-not $rejected -or $lowTotal.max_tool_calls_per_turn -ne 16 -or
    $lowTotal.PSObject.Properties['max_mutating_tool_calls_per_turn']) { throw 'Total cap was bypassed.' }
$Case10MaxMutatingToolCalls = 64
$upper = [pscustomobject]@{max_tool_calls_per_turn=64}
Set-BenchmarkMutatingBudget $case $upper
if ($upper.max_mutating_tool_calls_per_turn -ne 64 -or $upper.max_tool_calls_per_turn -ne 64) {
  throw 'Bounded upper selection mismatch.'
}
Write-Output 'Owned Case10 mutation budget fixture passed: omission,32,64,total rejection,case isolation,Pi null.'
