$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors
)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkInitialThinking', 'Set-BenchmarkInitialThinking')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$Case10InitialProgressThinking = 'inherit'
$Case10InitialProgressBoundary = $false
$limits = [pscustomobject]@{}
Set-BenchmarkInitialThinking $case $limits
if ($limits.PSObject.Properties['initial_progress_thinking'] -or
    $null -ne (Get-BenchmarkInitialThinking $case 'rupi')) { throw 'Default must omit selection.' }
$Case10InitialProgressThinking = 'off'
$rejected = $false
try { Set-BenchmarkInitialThinking $case $limits } catch { $rejected = $true }
if (-not $rejected -or $limits.PSObject.Properties['initial_progress_thinking']) {
  throw 'Initial progress dependency was bypassed.'
}
$Case10InitialProgressBoundary = $true
Set-BenchmarkInitialThinking $case $limits
if ($limits.initial_progress_thinking -cne 'off' -or
    (Get-BenchmarkInitialThinking $case 'rupi') -cne 'off' -or
    $null -ne (Get-BenchmarkInitialThinking $case 'pi')) { throw 'Native selection or Pi null mismatch.' }
$other = [pscustomobject]@{}
Set-BenchmarkInitialThinking @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['initial_progress_thinking'] -or
    $null -ne (Get-BenchmarkInitialThinking @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Changed another case.'
}
Write-Output 'Owned initial thinking fixture passed: inherit,off,dependency,case isolation,Pi null.'
