param([string]$PiAdapterBundle = '')
$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkNativeReasoningBudget','Get-BenchmarkThinkingInput',
    'Set-BenchmarkReasoningCompatibility','Get-BenchmarkEndpoint','Get-BenchmarkReasoningBudget',
    'Get-BenchmarkMaxOutputTokens','New-PiConfig','Write-Json','Write-Text')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$ThinkingLevel = 'low'
$Case10ThinkingInput = 'chat_template_enable_thinking'
$Case10ReasoningBudgetTokens = 0
$Case09ReasoningBudgetTokens = 0
$Case10NativeReasoningBudgetTokens = 0
$Case10MaxOutputTokens = 32768
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) (
  'rupi-native-budget-fixture-'+[Guid]::NewGuid().ToString('N'))
function New-OwnedEndpoint {
  [pscustomobject]@{capabilities=[pscustomobject]@{exposed_reasoning='native'};
    openai_compat=[pscustomobject]@{stream=$false}}
}
$defaultEndpoint = New-OwnedEndpoint
Set-BenchmarkReasoningCompatibility $case $defaultEndpoint
$defaultPiRoot = New-PiConfig (Join-Path $tempRoot 'default') $case
$defaultPi = Get-Content -Raw (Join-Path $defaultPiRoot 'models.json') | ConvertFrom-Json
if ($null -ne (Get-BenchmarkNativeReasoningBudget $case) -or
    $defaultEndpoint.openai_compat.PSObject.Properties['reasoning_budget_tokens'] -or
    $defaultPi.providers.unsloth.models[0].compat.PSObject.Properties['thinkingTokenBudgetField']) {
  throw 'Default native budget changed.'
}
$Case10NativeReasoningBudgetTokens = 2048
$endpoint = New-OwnedEndpoint
Set-BenchmarkReasoningCompatibility $case $endpoint
if ($endpoint.openai_compat.reasoning_budget_tokens -ne 2048 -or
    $endpoint.openai_compat.stream -ne $false -or
    $endpoint.openai_compat.thinking_input -cne 'chat_template_enable_thinking') {
  throw 'Selected native endpoint contract changed.'
}
$piRoot = New-PiConfig (Join-Path $tempRoot 'selected') $case
$pi = Get-Content -Raw (Join-Path $piRoot 'models.json') | ConvertFrom-Json
$compat = $pi.providers.unsloth.models[0].compat
if ($compat.supportsThinkingTokenBudget -ne $true -or
    $compat.thinkingTokenBudgetField -cne 'reasoning_budget_tokens' -or
    $compat.chatTemplateKwargs.enable_thinking.'$var' -cne 'thinking.enabled' -or
    $pi.providers.unsloth.baseUrl -cne 'http://127.0.0.1:8000/v1') {
  throw 'Pinned Pi native compatibility mismatch.'
}
$other = @{Id='09-lease-receipt'}
$otherEndpoint = New-OwnedEndpoint
Set-BenchmarkReasoningCompatibility $other $otherEndpoint
$otherPiRoot = New-PiConfig (Join-Path $tempRoot 'other') $other
$otherPi = Get-Content -Raw (Join-Path $otherPiRoot 'models.json') | ConvertFrom-Json
if ($null -ne (Get-BenchmarkNativeReasoningBudget $other) -or
    $otherEndpoint.openai_compat.PSObject.Properties['reasoning_budget_tokens'] -or
    $otherPi.providers.unsloth.models[0].compat.PSObject.Properties['thinkingTokenBudgetField']) {
  throw 'Unrelated case native budget changed.'
}
foreach ($invalid in @(
    @{budget=4096;dialect='chat_template_enable_thinking';helper=0;level='low'},
    @{budget=2048;dialect='reasoning_effort';helper=0;level='low'},
    @{budget=2048;dialect='chat_template_enable_thinking';helper=4096;level='low'},
    @{budget=2048;dialect='chat_template_enable_thinking';helper=0;level='off'})) {
  $Case10NativeReasoningBudgetTokens = $invalid.budget
  $Case10ThinkingInput = $invalid.dialect
  $Case10ReasoningBudgetTokens = $invalid.helper
  $ThinkingLevel = $invalid.level
  foreach ($action in @({Get-BenchmarkNativeReasoningBudget $case},
      {Set-BenchmarkReasoningCompatibility $case (New-OwnedEndpoint)},
      {New-PiConfig (Join-Path $tempRoot 'invalid') $case})) {
    $rejected = $false
    try { & $action | Out-Null } catch { $rejected = $true }
    if (-not $rejected) { throw 'Invalid matched native selection was accepted.' }
  }
}
if ($PiAdapterBundle) {
  & node (Join-Path $PSScriptRoot 'test-pi-thinking-template.mjs') $PiAdapterBundle `
    (Join-Path $piRoot 'models.json') 2048
  if ($LASTEXITCODE -ne 0) { throw 'Pinned Pi native fake wire failed.' }
}
Write-Output 'Owned native budget fixture passed: default,matching,direct dependency,isolation.'
