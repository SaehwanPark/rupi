$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSScriptRoot -Parent
$tokens = $null; $parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot "compare-pi-rupi.ps1"), [ref]$tokens, [ref]$parseErrors
)
if ($parseErrors.Count) { throw "Harness parse failed." }
$definition = @($ast.EndBlock.Statements | Where-Object {
  $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and
  $_.Name -eq "Read-RupiMetrics"
})
if ($definition.Count -ne 1) { throw "Metrics function not found." }
Invoke-Expression $definition[0].Extent.Text

# Keep the fixture under ignored artifacts; no actual session or model output is read.
$fixture = Join-Path $repoRoot (".benchmark/control-metrics-" + [Guid]::NewGuid().ToString("N"))
$sessions = Join-Path $fixture ".rupi-state/sessions"
New-Item -ItemType Directory -Force -Path $sessions | Out-Null
$marker = "owned-content-must-not-enter-metrics"
$records = @(
  @{ type = "model_request_started" },
  @{ type = "runtime_control_injected"; kind = "completion_review"; text = $marker },
  @{ type = "runtime_control_injected"; kind = "turn_time_budget"; text = $marker },
  @{ type = "model_request_started" },
  @{ type = "runtime_control_injected"; kind = "completion_review"; text = $marker },
  @{ type = "runtime_control_injected"; kind = "future_control"; text = $marker },
  @{ type = "assistant_delta"; text = $marker },
  @{ type = "user_input"; text = $marker }
)
$lines = @($records | ForEach-Object { $_ | ConvertTo-Json -Compress })
[IO.File]::WriteAllLines(
  (Join-Path $sessions "owned.trace.jsonl"), $lines, [Text.UTF8Encoding]::new($false)
)
$all = Read-RupiMetrics $fixture
$scoped = Read-RupiMetrics $fixture 3
if ($all.runtime_control_counts.completion_review -ne 2 -or
    $all.runtime_control_counts.turn_time_budget -ne 1 -or
    $all.runtime_control_counts.unknown -ne 1 -or
    $scoped.runtime_control_counts.completion_review -ne 1 -or
    $scoped.runtime_control_counts.turn_time_budget -ne 0 -or
    $scoped.runtime_control_counts.unknown -ne 1) {
  throw "Control count or turn scope mismatch."
}
if (($all.completion_review_after_started_requests -join ',') -cne '1,2' -or
    ($scoped.completion_review_after_started_requests -join ',') -cne '1' -or
    $all.model_requests_started -ne 2 -or $scoped.model_requests_started -ne 1) {
  throw "Review request position or turn scope mismatch."
}
foreach ($metrics in @($all, $scoped)) {
  if (($metrics | ConvertTo-Json -Depth 20 -Compress).Contains($marker)) {
    throw "Metrics exposed control or model content."
  }
  if ($metrics.usage_records -ne 0 -or $metrics.inference_work_tokens -ne 0) {
    throw "Control and request-start events must not invent usage."
  }
}
Write-Output "Runtime control metrics fixture passed: counts, positions, scope, content exclusion."
