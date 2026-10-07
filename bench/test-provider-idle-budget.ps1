$ErrorActionPreference = 'Stop'
$tokens=$null; $errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'),[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkReadTimeout','Set-BenchmarkReadTimeout')) {
  $definition=@($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned helper $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case=@{Id='10-receipt-ledger'}
$script:providerRequestTimeoutMs=2394000
$Case10ProviderReadTimeoutMs=0
$endpoint=[pscustomobject]@{request_timeout_ms=2394000}
Set-BenchmarkReadTimeout $case $endpoint
if ($endpoint.PSObject.Properties['read_timeout_ms'] -or
    $null -ne (Get-BenchmarkReadTimeout $case 'rupi')) { throw 'Default changed.' }
$Case10ProviderReadTimeoutMs=2394001
$rejected=$false
try { Set-BenchmarkReadTimeout $case $endpoint } catch { $rejected=$true }
if (-not $rejected -or $endpoint.PSObject.Properties['read_timeout_ms']) {
  throw 'Idle timeout beyond total deadline accepted.'
}
$Case10ProviderReadTimeoutMs=2394000
Set-BenchmarkReadTimeout $case $endpoint
if ($endpoint.read_timeout_ms -ne 2394000 -or $endpoint.request_timeout_ms -ne 2394000 -or
    (Get-BenchmarkReadTimeout $case 'rupi') -ne 2394000 -or
    $null -ne (Get-BenchmarkReadTimeout $case 'pi')) { throw 'Selection/Pi mismatch.' }
$other=[pscustomobject]@{}
Set-BenchmarkReadTimeout @{Id='09-lease-receipt'} $other
if ($other.PSObject.Properties['read_timeout_ms'] -or
    $null -ne (Get-BenchmarkReadTimeout @{Id='09-lease-receipt'} 'rupi')) {
  throw 'Other case changed.'
}
Write-Output 'Owned provider idle budget passed: omitted default, deadline, selection, isolation.'
