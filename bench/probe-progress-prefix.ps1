param([string]$BaseUri = 'http://127.0.0.1:8000')

$ErrorActionPreference = 'Stop'
$tools = @('read', 'write', 'edit', 'grep' | ForEach-Object {
  [ordered]@{
    type = 'function'
    function = [ordered]@{
      name = $_
      description = "Synthetic $_ fixture"
      parameters = [ordered]@{ type = 'object'; properties = [ordered]@{} }
    }
  }
})
$messages = @(
  @{ role = 'system'; content = 'Synthetic immutable cache-prefix fixture.' },
  @{ role = 'user'; content = ('Synthetic history remains unchanged. ' * 512) }
)
function Render-Prompt($fixtureTools, $fixtureMessages) {
  $body = @{
    messages = $fixtureMessages
    tools = $fixtureTools
    reasoning_effort = 'low'
  } | ConvertTo-Json -Depth 20 -Compress
  $response = Invoke-RestMethod -Method Post -Uri "$baseUri/apply-template" `
    -Body $body -ContentType 'application/json' -TimeoutSec 15
  [string]$response.prompt
}
function Tokenize-Prompt([string]$prompt) {
  $body = @{ content = $prompt; add_special = $false; parse_special = $true } |
    ConvertTo-Json -Compress
  (Invoke-RestMethod -Method Post -Uri "$baseUri/tokenize" -Body $body `
    -ContentType 'application/json' -TimeoutSec 15).tokens
}
function Shared-Prefix($left, $right) {
  $count = 0
  while ($count -lt [Math]::Min($left.Count, $right.Count) -and
    $left[$count] -eq $right[$count]) { $count++ }
  $count
}
$full = Render-Prompt $tools $messages
$narrowTools = @($tools | Where-Object { $_.function.name -in @('write', 'edit') })
$narrow = Render-Prompt $narrowTools $messages
if (-not $full.Contains('Synthetic read fixture') -or
  $narrow.Contains('Synthetic read fixture') -or
  -not $narrow.Contains('Synthetic write fixture')) {
  throw 'Tool declarations were not rendered as expected'
}
$appended = Render-Prompt $tools ($messages + @(
  @{ role = 'assistant'; content = 'Synthetic response.' },
  @{ role = 'user'; content = 'Continue synthetic fixture.' }
))
$fullTokens = @(Tokenize-Prompt $full)
$narrowTokens = @(Tokenize-Prompt $narrow)
$appendedTokens = @(Tokenize-Prompt $appended)
[pscustomobject]@{
  fixture = 'synthetic-template-only-no-inference'
  full_tokens = $fullTokens.Count
  narrow_tokens = $narrowTokens.Count
  appended_tokens = $appendedTokens.Count
  narrowed_common_prefix = Shared-Prefix $fullTokens $narrowTokens
  stable_tools_appended_common_prefix = Shared-Prefix $fullTokens $appendedTokens
} | ConvertTo-Json -Compress
