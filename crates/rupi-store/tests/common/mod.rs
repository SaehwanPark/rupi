use std::path::Path;

use rupi_core::{
  AgentEvent, ContentBlock, EventEnvelope, EventMeta, Message, ModelRef, ModelRequestCompleted,
  ModelRequestStarted, ReasoningDelta, ReasoningProvenance, Role, SessionHeader, SessionId,
  ToolCallBlock, ToolCallId, ToolRequested, TraceId, TurnId,
};
use rupi_store::{Store, WritePolicy};

pub fn tool_history(
  root: &Path,
  fragments: u32,
  calls: usize,
  record_requests: bool,
) -> (Store, SessionId) {
  let policy = WritePolicy {
    inline_threshold_bytes: 4_096,
    ..WritePolicy::default()
  };
  let store = Store::open(root, policy).unwrap();
  let id = SessionId::new();
  let model = ModelRef::new("owned", "fixture");
  let turn = TurnId::new();
  let trace = TraceId::new();
  let meta = || {
    let mut value = EventMeta::new(id.clone(), trace.clone());
    value.turn_id = Some(turn.clone());
    value.model_epoch = Some(0);
    value.model = Some(model.clone());
    value
  };
  let mut session = store
    .begin(SessionHeader {
      session_id: id.clone(),
      version: rupi_core::session::SESSION_SCHEMA_VERSION,
      started_at_ms: 1,
      working_dir: "owned".into(),
      model: model.clone(),
      parent_session: None,
      branched_from_event: None,
      imported_from: None,
    })
    .unwrap();
  let mut start = EventEnvelope::new(
    meta(),
    AgentEvent::ModelRequestStarted(ModelRequestStarted {
      epoch: 0,
      model: model.clone(),
      message_count: 1,
      context_tokens_est: 10,
      tools_exposed: 1,
    }),
  );
  session.emit(&mut start).unwrap();
  let text = "owned-fixture ".repeat(700);
  for chunk_index in 0..fragments {
    let mut delta = EventEnvelope::new(
      meta(),
      AgentEvent::ReasoningDelta(ReasoningDelta {
        text: text.clone(),
        provenance: ReasoningProvenance::Native,
        chunk_index,
      }),
    );
    session.emit(&mut delta).unwrap();
  }
  let calls: Vec<_> = (0..calls)
    .map(|index| ToolCallBlock {
      id: ToolCallId::from_string(format!("owned-call-{index}")),
      name: "read".into(),
      arguments: serde_json::json!({"path": format!("owned-{index}.txt")}),
    })
    .collect();
  let mut completed = EventEnvelope::new(
    meta(),
    AgentEvent::ModelRequestCompleted(ModelRequestCompleted {
      epoch: 0,
      model: model.clone(),
      finish_reason: Some("tool_calls".into()),
      input_tokens: Some(10),
      uncached_input_tokens: Some(10),
      logical_prompt_tokens: Some(10),
      cache_read_tokens: None,
      cache_write_tokens: None,
      output_tokens: Some(10),
      provider_total_tokens: Some(20),
      duration_ms: 1,
      tool_calls: calls.len() as u32,
      reasoning_provenance: Some(ReasoningProvenance::Native),
      first_delta_ms: Some(0),
      failure: None,
    }),
  );
  let message = Message::new(
    Role::Assistant,
    calls.iter().cloned().map(ContentBlock::ToolCall).collect(),
  );
  session.emit_message(&mut completed, &message).unwrap();
  if record_requests {
    for call in &calls {
      let mut request_meta = meta();
      request_meta.parent_event_id = Some(completed.meta.event_id.clone());
      request_meta.tool_call_id = Some(call.id.clone());
      let mut request = EventEnvelope::new(
        request_meta,
        AgentEvent::ToolRequested(ToolRequested {
          call_id: call.id.clone(),
          name: call.name.clone(),
          arguments: call.arguments.clone(),
          read_only: true,
          definition_fingerprint: None,
        }),
      );
      session.emit(&mut request).unwrap();
    }
  }
  session.flush().unwrap();
  drop(session);
  (store, id)
}
