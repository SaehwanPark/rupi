mod common;

use rupi_core::{AgentEvent, ExternalizedField, Role, ToolExecutionState, TraceEntry};
use rupi_store::{Store, TempDir, TraceJournal};

fn rewrite_trace(store: &Store, id: &rupi_core::SessionId, entries: &[TraceEntry]) {
  let mut bytes = Vec::new();
  for entry in entries {
    serde_json::to_writer(&mut bytes, entry).unwrap();
    bytes.push(b'\n');
  }
  std::fs::write(store.layout().trace_path(id), bytes).unwrap();
}

#[test]
fn streamed_history_recovers_unstarted_or_missing_calls_without_execution() {
  for recorded in [false, true] {
    let temp = TempDir::new("owned-streamed-tool-history");
    let (store, id) = common::tool_history(temp.path(), 3, 4, recorded);
    let resumed = store.resume(&id).unwrap();
    let restored = store.restore(&id).unwrap();
    assert!(restored.interrupted_tools.is_empty());
    assert!(restored.unresolved_side_effects.is_empty());
    assert_eq!(restored.messages.len(), 5);
    assert_eq!(restored.messages[0].message.tool_calls().count(), 4);
    for message in &restored.messages[1..] {
      assert_eq!(message.role, Role::Tool);
      let results: Vec<_> = message
        .message
        .content
        .iter()
        .filter_map(|block| match block {
          rupi_core::ContentBlock::ToolResult(result) => Some(result),
          _ => None,
        })
        .collect();
      assert_eq!(results.len(), 1);
      assert_eq!(results[0].state, ToolExecutionState::Failed);
      assert_eq!(results[0].effect, rupi_core::ToolEffectDisposition::None);
    }
    let trace = TraceJournal::read(&store.layout().trace_path(&id)).unwrap();
    assert!(trace.items.iter().all(|entry| !matches!(
      entry.envelope.event,
      AgentEvent::ToolStarted(_) | AgentEvent::ToolUnknown(_)
    )));
    drop(resumed);
  }
}

#[test]
fn tool_history_rejects_corrupt_unrelated_externalized_fields() {
  for corruption in ["duplicate", "missing", "schema"] {
    let temp = TempDir::new("owned-corrupt-streamed-tool-history");
    let (store, id) = common::tool_history(temp.path(), 2, 2, true);
    let mut entries = TraceJournal::read(&store.layout().trace_path(&id))
      .unwrap()
      .items;
    let delta = entries
      .iter_mut()
      .find(|entry| !entry.externalized.is_empty())
      .unwrap();
    match corruption {
      "duplicate" => delta.externalized.push(delta.externalized[0].clone()),
      "missing" => delta.externalized[0].field = "absent".into(),
      "schema" => delta.externalized[0].field = "provenance".into(),
      _ => unreachable!(),
    }
    rewrite_trace(&store, &id, &entries);
    let before = std::fs::read(store.layout().trace_path(&id)).unwrap();
    assert!(store.restore(&id).is_err(), "restore accepted {corruption}");
    assert!(store.resume(&id).is_err(), "resume accepted {corruption}");
    assert_eq!(
      std::fs::read(store.layout().trace_path(&id)).unwrap(),
      before
    );
  }
}

#[test]
fn tool_history_matches_restored_request_arguments() {
  let temp = TempDir::new("owned-externalized-tool-request");
  let (store, id) = common::tool_history(temp.path(), 2, 2, true);
  let blobs = store.blobs(&id).unwrap();
  let mut entries = TraceJournal::read(&store.layout().trace_path(&id))
    .unwrap()
    .items;
  let entry = entries
    .iter_mut()
    .find(|entry| matches!(entry.envelope.event, AgentEvent::ToolRequested(_)))
    .unwrap();
  let AgentEvent::ToolRequested(request) = &mut entry.envelope.event else {
    unreachable!()
  };
  let value = request.arguments["path"].as_str().unwrap();
  let blob = blobs.put(value.as_bytes(), Some("text/plain")).unwrap();
  entry.externalized.push(ExternalizedField {
    field: "arguments/path".into(),
    reference: blob.relative_path(),
    bytes: value.len() as u64,
    inline: 7,
  });
  request.arguments["path"] = serde_json::json!("preview");
  rewrite_trace(&store, &id, &entries);
  let resumed = store.resume(&id).unwrap();
  let restored = store.restore(&id).unwrap();
  assert_eq!(restored.messages.len(), 3);
  assert!(restored.unresolved_side_effects.is_empty());
  drop(resumed);
}
