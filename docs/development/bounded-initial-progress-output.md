# Bounded initial progress response

Implement this bounded runtime slice before another attempt. Risk: medium, output
admission and initial progress guidance. Parent owns implementation/review; no child
agent is needed. Generated/model/diagnostic contents remain unread.

Retry26 ends Transport on its first request at1,196.199s, with no usage, tools, files
or checks. This is consistent with the preserved relay's hard1,194s response window;
native2370s/provider2394s allow longer. Exact defect/output size are unmeasured. The
enhancement bounds initial requested output and guides a smaller coherent change;
it does not promise latency, reinterpret unknown work as zero or replay that failure.

1. Add optional limits.initial_progress_max_output_tokens (None/default omitted,
   positive1..65536); configured values require initial_progress_boundary=true,
   which already requires a progress window. Add TurnLoop builder and CLI wiring.
2. Only the first ordinary provider request of an active initial progress boundary
   uses this ceiling, renewed each turn. Cap at the active endpoint's smaller limit,
   retain desired/effective output-budget semantics and normal context clamping.
   Later requests retain the endpoint ceiling, even if initial progress is unsatisfied.
   Default/no-limit/no-tools paths skip it. No new timer, request or execution authority.
3. Initial ProgressBoundary control explains the configured upper bound and asks for
   a small coherent completed change within it, with later complete tool calls finishing
   requested work. It is guidance, not a scaffold, claimed observation or correctness
   proof. Existing progress approval/Changed/Unknown/cap requirements remain intact.
4. Before/after owned fixture proves first8192/later32768 on the same model, with fresh
   turns renewing the cap. Cover omission, endpoint minimum, context clamping, disabled/
   no-tools/no-limit, no-effect progress and incomplete-response no-dispatch/no-replay.
   Config omission/range/dependency/round-trip and CLI fake-provider wire fixture required.
5. Add Case10InitialProgressMaxOutputTokens (0/default omitted, positive1..65536) requiring
   selected initial progress. Native config/summary scalar selected; Pi selection null.
   Preserve default endpoint32768, checks8/mutations32 and all other Retry26 controls.
   Shared prompt, full public SPEC,18 other prompts and three reference hashes unchanged.
6. Run required Rust checks/debug, startup and session/context budget checks. Rendering
   has no new status/event; prior rendering budgets remain applicable. Reconcile docs,
   parent invariant review, commit/push and freeze. Retry27 is one fresh development
   turn with first8192/later32768, same model/prompt. Any failure needs analysis and
   another verified enhancement. Fresh matched Pi only after Rupi acceptance; native
   initial-output parity is not claimed, nor any latency/token/acceptance/paired win.
