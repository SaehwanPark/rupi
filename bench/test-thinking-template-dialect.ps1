param([string]$PiAdapterBundle = '')
$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkThinkingInput','Get-BenchmarkThinkingControl',
    'Set-BenchmarkReasoningCompatibility','Get-BenchmarkEndpoint','Get-BenchmarkReasoningBudget',
    'Get-BenchmarkMaxOutputTokens','New-PiConfig','Write-Json','Write-Text')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$Case10ThinkingInput = 'reasoning_effort'
$Case10ReasoningBudgetTokens = 0
$Case10MaxOutputTokens = 32768
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('rupi-thinking-fixture-'+[Guid]::NewGuid().ToString('N'))
$endpoint = [pscustomobject]@{capabilities=[pscustomobject]@{exposed_reasoning='native'}}
Set-BenchmarkReasoningCompatibility $case $endpoint
if ($endpoint.openai_compat.thinking_input -cne 'reasoning_effort' -or
    (Get-BenchmarkThinkingControl $case 'off').off_value -cne 'none') {throw 'Default changed.'}
$piDefault = Get-Content -Raw (Join-Path (New-PiConfig $tempRoot $case) 'models.json') |
  ConvertFrom-Json
if ($piDefault.providers.unsloth.models[0].compat.thinkingFormat -cne 'openai' -or
    $piDefault.providers.unsloth.models[0].compat.PSObject.Properties['chatTemplateKwargs']) {
  throw 'Default Pi dialect changed.'
}
$Case10ThinkingInput = 'chat_template_enable_thinking'
$Case10ReasoningBudgetTokens = 4096
foreach ($action in @({Set-BenchmarkReasoningCompatibility $case $endpoint},
    {New-PiConfig $tempRoot $case})) {
  $rejected = $false
  try { & $action | Out-Null } catch { $rejected = $true }
  if (-not $rejected) {throw 'Low-only relay dependency bypassed.'}
}
$Case10ReasoningBudgetTokens = 0
Set-BenchmarkReasoningCompatibility $case $endpoint
if ($endpoint.openai_compat.thinking_input -cne 'chat_template_enable_thinking' -or
    $endpoint.openai_compat.preserve_reasoning -ne $true -or
    (Get-BenchmarkThinkingControl $case 'off').off_value -ne $false) {
  throw 'Native encoding/metadata mismatch.'
}
$piRoot = New-PiConfig $tempRoot $case
$pi = Get-Content -Raw (Join-Path $piRoot 'models.json') | ConvertFrom-Json
$compat = $pi.providers.unsloth.models[0].compat
if ($compat.thinkingFormat -cne 'chat-template' -or $compat.supportsReasoningEffort -ne $false -or
    $compat.chatTemplateKwargs.enable_thinking.'$var' -cne 'thinking.enabled' -or
    @($compat.chatTemplateKwargs.PSObject.Properties).Count -ne 1 -or
    $pi.providers.unsloth.baseUrl -cne 'http://127.0.0.1:8000/v1') {
  throw 'Pi selected dialect mismatch.'
}
if ((Get-BenchmarkThinkingInput @{Id='09-lease-receipt'}) -cne 'reasoning_effort') {
  throw 'Another case changed.'
}
if ($PiAdapterBundle) {
  & node (Join-Path $PSScriptRoot 'test-pi-thinking-template.mjs') $PiAdapterBundle `
    (Join-Path $piRoot 'models.json')
  if ($LASTEXITCODE -ne 0) {throw 'Pinned Pi fake wire failed.'}
}
Write-Output 'Owned template dialect fixture passed: default,selection,direct dependency,case isolation.'
