$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'compare-pi-rupi.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
foreach ($name in @('Get-BenchmarkCompletionFeedbackTimeout',
    'Add-BenchmarkCompletionFeedbackArguments')) {
  $definition = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -eq $name
  })
  if ($definition.Count -ne 1) { throw "Missing owned function: $name" }
  Invoke-Expression $definition[0].Extent.Text
}
$case = @{Id='10-receipt-ledger'}
$Case10CompletionFeedbackTimeoutMs = 0
$Case10CompletionChecks = 8
foreach ($selection in @(@{case=$case;agent='rupi'}, @{case=$case;agent='pi'},
    @{case=@{Id='09-lease-receipt'};agent='rupi'})) {
  $arguments = [Collections.Generic.List[string]]::new()
  $arguments.Add('owned')
  Add-BenchmarkCompletionFeedbackArguments $selection.case $selection.agent $arguments
  if ($arguments.Count -ne 1 -or
      $null -ne (Get-BenchmarkCompletionFeedbackTimeout $selection.case $selection.agent)) {
    throw 'Default or unrelated CLI controls changed.'
  }
}
$Case10CompletionFeedbackTimeoutMs = 60000
$arguments = [Collections.Generic.List[string]]::new()
$arguments.Add('owned')
Add-BenchmarkCompletionFeedbackArguments $case 'rupi' $arguments
if (($arguments -join ',') -cne 'owned,--completion-feedback-timeout-ms,60000' -or
    (Get-BenchmarkCompletionFeedbackTimeout $case 'rupi') -ne 60000) {
  throw 'Caller deadline argument/metadata contract differs.'
}
foreach ($selection in @(@{case=$case;agent='pi'},
    @{case=@{Id='09-lease-receipt'};agent='rupi'})) {
  $arguments = [Collections.Generic.List[string]]::new()
  $arguments.Add('owned')
  Add-BenchmarkCompletionFeedbackArguments $selection.case $selection.agent $arguments
  if ($arguments.Count -ne 1 -or
      $null -ne (Get-BenchmarkCompletionFeedbackTimeout $selection.case $selection.agent)) {
    throw 'Pi or unrelated case received a Rupi-only deadline.'
  }
}
foreach ($invalid in @(
    @{timeout=60000;checks=0}, @{timeout=-1;checks=8},
    @{timeout=1;checks=8}, @{timeout=300001;checks=8})) {
  $Case10CompletionFeedbackTimeoutMs = $invalid.timeout
  $Case10CompletionChecks = $invalid.checks
  $rejected = $false
  try { Get-BenchmarkCompletionFeedbackTimeout $case 'rupi' | Out-Null }
  catch { $rejected = $true }
  if (-not $rejected) { throw 'Unverified caller deadline selection accepted.' }
}
Write-Output 'Owned caller deadline guards pass: default,60s,dependency,Pi/other-case isolation.'
