# Explicit enable_thinking template dialect

Retry31 consumes8192 output with length before a decoded tool call despite requested
global/initial Off. Timed-review observation is not reached. Frozen audits and all three
source/freeze CI jobs pass; actual contents/reasoning composition stay unread.
The failure proves incomplete response and unreliable observed first-call progression,
not backend failure to disable thinking.

Current llama.cpp README and server-common.cpp document chat_template_kwargs.enable_thinking
as a boolean, distinct from rupi's existing thinking-key dialect. Local static capability
supports_enable_thinking is null/unknown; exact build/application defect is unmeasured.
Sources: https://raw.githubusercontent.com/ggml-org/llama.cpp/master/tools/server/README.md
and https://raw.githubusercontent.com/ggml-org/llama.cpp/master/tools/server/server-common.cpp.

Parent owns a bounded endpoint adapter/config/CLI/harness slice. Add typed
OpenAiThinkingInput::ChatTemplateEnableThinking (snake-case config), emitting only
chat_template_kwargs.enable_thinking = level != Off. Preserve ChatTemplateThinking's
existing thinking-key encoding and default ReasoningEffort; correct its overbroad
llama.cpp comment. No arbitrary payload map, provider capability claim, retry/timer/event,
model switch, reasoning provenance change or incomplete dispatch/replay.

Owned mapping fixtures cover every level, exact boolean/key/absence, defaults/legacy;
config roundtrip and provider-derived setting. Existing CLI wire fixture tests both
reasoning-effort and new dialect with firstOff/laterLow inheritance, initial output/string
limits and reasoning replay. No actual hidden-reasoning/backend enforcement claim.

Pinned Pi0.86.1 supports generic thinkingFormat chat-template with chatTemplateKwargs
enable_thinking variable thinking.enabled. Use that exact field rather than qwen-chat-template,
which also injects preserve_thinking. Verify fake HTTP wire Off false/non-Off true,
no reasoning_effort or extra preserve flag; do not change Pi implementation.
Add isolated Case10 thinking-input option (default reasoning_effort, selected
chat_template_enable_thinking requires direct budget0), matched both agents' scalar
configured_thinking_control and respective typed/native model configs. Preserve other
cases and existing defaults. Owned fixture verifies default/selection/dependencies/case
isolation, shared prompt/18 other prompt hashes/full SPEC/three references.

Required Rust/debug/startup and relevant restore/context performance checks, parent author
invariant review, source and frozen-checkout CI; commit/push/freeze before Retry32.
Planned direct8000/globalOff/firstOff both agents, all Retry31 output/argument/progress/
review/check/budget/time/sampling/context/tool settings retained, original model/helpers
unchanged. One fresh Rupi screen; matched Pi only after acceptance. Any failure requires
new analysis and verified enhancement before another attempt. No configured win claimed.
