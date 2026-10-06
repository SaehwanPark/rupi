//! One-shot agent runs through the real binary: what a turn prints, what it writes, and
//! what it refuses to do.
//!
//! The fake provider is shared with `tests/failover_cli.rs` and lives in
//! `tests/fake_provider`, where the reason it is deterministic is written down.

mod fake_provider;

use std::{
  fs,
  net::TcpListener,
  path::{Path, PathBuf},
  process::{Command, Output},
};

use rupi_core::{
  AgentEvent, ModelCapabilities, ModelEndpoint, ModelRef, ReasoningExposure, Role, RuntimeConfig,
  SessionEndReason, TurnStatus,
};
use rupi_store::{StateLayout, Store, TraceJournal, WritePolicy};
use tempfile::TempDir;

use fake_provider::{FakeServer, sse, status_response, text_response};

/// A response that asks for a tool, optionally after some reasoning, then ends the
/// stream. The adapter joins the fragments into one call when the stream ends.
fn truncated_text_response(text: &str) -> String {
  sse(&[
    serde_json::json!({"choices": [{"delta": {"content": text}}]}),
    serde_json::json!({
      "choices": [{"delta": {}, "finish_reason": "length"}],
      "usage": {"prompt_tokens": 20, "completion_tokens": 4}
    }),
  ])
}

fn tool_response(id: &str, name: &str, arguments: &str, reasoning: Option<&str>) -> String {
  let mut events = Vec::new();
  if let Some(reasoning) = reasoning {
    events.push(serde_json::json!({
      "choices": [{"delta": {"reasoning_content": reasoning}}]
    }));
  }
  events.push(serde_json::json!({
    "choices": [{"delta": {"tool_calls": [{
      "index": 0,
      "id": id,
      "function": {"name": name, "arguments": arguments}
    }]}}]
  }));
  events.push(serde_json::json!({
    "choices": [{"delta": {}, "finish_reason": "tool_calls"}]
  }));
  sse(&events)
}

fn write_config(root: &Path, base_url: &str, auto_approve_mutating: bool) -> PathBuf {
  write_config_exposing(
    root,
    base_url,
    auto_approve_mutating,
    ReasoningExposure::Native,
  )
}

/// The same config, declaring something else about reasoning output.
///
/// The declaration is what decides the provenance claim attached to thinking text,
/// so a test about provenance has to say what its endpoint claims to expose.
fn write_config_exposing(
  root: &Path,
  base_url: &str,
  auto_approve_mutating: bool,
  exposed_reasoning: ReasoningExposure,
) -> PathBuf {
  let state = root.join("state");
  let mut config = RuntimeConfig::new(ModelRef::new("fake", "agent"), state.to_string_lossy());
  config.endpoints.push(ModelEndpoint {
    provider: "fake".into(),
    model: "agent".into(),
    base_url: Some(base_url.into()),
    api_key_env: None,
    api_key: None,
    capabilities: ModelCapabilities {
      text: true,
      images: false,
      tools: true,
      exposed_reasoning,
      context_window: 32_768,
      max_output_tokens: Some(1_024),
    },
    max_output_tokens: Some(1_024),
    connect_timeout_ms: None,
    read_timeout_ms: None,
    request_timeout_ms: None,
    openai_compat: Default::default(),
  });
  config.tools.auto_approve_mutating = auto_approve_mutating;
  let path = root.join("config.json");
  fs::write(&path, serde_json::to_vec_pretty(&config).unwrap()).unwrap();
  path
}

fn run(config: &Path, cwd: &Path, prompt: &str) -> Output {
  Command::new(env!("CARGO_BIN_EXE_rupi"))
    .args(["run", "--config"])
    .arg(config)
    .arg("--cwd")
    .arg(cwd)
    .args(["--prompt", prompt])
    .output()
    .expect("run rupi")
}

#[test]
fn completion_mailbox_drives_a_real_cli_repair_without_new_execution_authority() {
  for review_mode in [
    "ordinary",
    "timed",
    "requests",
    "repair_window",
    "initial_window",
    "check_reserve",
  ] {
    let early_review = matches!(review_mode, "timed" | "requests");
    let initial_window = review_mode == "initial_window";
    let repair_window = review_mode == "repair_window";
    let check_reserve = review_mode == "check_reserve";
    let expected_checks = if check_reserve {
      4
    } else if repair_window {
      3
    } else {
      2
    };
    let temp = TempDir::new().unwrap();
    let workspace = temp.path().join("workspace");
    let mailbox = temp.path().join("mailbox");
    fs::create_dir(&workspace).unwrap();
    fs::create_dir(&mailbox).unwrap();
    let mut responses = vec![
      if early_review || initial_window || check_reserve {
        tool_response(
          "initial",
          "write",
          r#"{"path":"app.txt","contents":"owned initial"}"#,
          None,
        )
      } else {
        text_response("initial candidate")
      },
      tool_response(
        "repair",
        "write",
        r#"{"path":"app.txt","contents":"owned repaired"}"#,
        None,
      ),
      text_response("checked candidate"),
    ];
    if check_reserve {
      responses.insert(
        1,
        tool_response(
          "intermediate",
          "write",
          r#"{"path":"app.txt","contents":"owned intermediate"}"#,
          None,
        ),
      );
    }
    if repair_window {
      for (index, content) in [(1, "owned first repair"), (2, "owned intermediate")] {
        responses.insert(
          index,
          tool_response(
            &format!("repair-{index}"),
            "write",
            &serde_json::json!({"path":"app.txt", "contents":content}).to_string(),
            None,
          ),
        );
      }
    }
    let server = if review_mode == "timed" {
      FakeServer::answer_delayed(responses, std::time::Duration::from_secs(3))
    } else {
      FakeServer::answer(responses)
    };
    let path = write_config(temp.path(), &server.base_url(), true);
    let mut config = RuntimeConfig::parse(&fs::read_to_string(&path).unwrap()).unwrap();
    config.limits.max_completion_checks_per_turn = Some(expected_checks);
    if check_reserve {
      config.limits.max_model_requests_per_turn = 8;
      config.limits.completion_check_initial_request_window = Some(1);
      config.limits.completion_check_repair_request_window = Some(1);
      config.limits.review_completion = true;
      config.limits.completion_review_check_reserve = Some(2);
      config.limits.completion_check_on_review = true;
    }
    if initial_window {
      config.limits.max_model_requests_per_turn = 4;
      config.limits.completion_check_initial_request_window = Some(1);
    }
    if repair_window {
      config.limits.max_model_requests_per_turn = 8;
      config.limits.completion_check_repair_request_window = Some(2);
    }
    // This fixture tests mailbox repair, not scheduling against a short deadline.
    config.limits.max_turn_duration_ms = Some(60_000);
    if early_review {
      config.limits.review_completion = true;
      config.limits.completion_check_on_review = true;
      if review_mode == "timed" {
        config.limits.completion_review_reserve_ms = Some(55_000);
      } else {
        config.limits.max_model_requests_per_turn = 4;
        config.limits.completion_review_request_reserve = Some(2);
      }
    }
    config.tools.allow = vec!["read".into(), "write".into(), "edit".into(), "grep".into()];
    fs::write(&path, config.to_json_string().unwrap()).unwrap();
    let child = Command::new(env!("CARGO_BIN_EXE_rupi"))
      .args(["run", "--config"])
      .arg(&path)
      .arg("--cwd")
      .arg(&workspace)
      .args([
        "--prompt",
        "deliver owned file",
        "--completion-feedback-dir",
      ])
      .arg(&mailbox)
      .stdout(std::process::Stdio::piped())
      .stderr(std::process::Stdio::piped())
      .spawn()
      .unwrap();
    let child_id = child.id();
    let child_finished = std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false));
    let host_finished = std::sync::Arc::clone(&child_finished);
    let canonical_workspace = fs::canonicalize(&workspace).unwrap();
    let host = std::thread::spawn(move || {
      let deadline = std::time::Instant::now() + std::time::Duration::from_secs(75);
      let mut seen = std::collections::BTreeSet::new();
      while seen.len() < expected_checks as usize {
        for entry in fs::read_dir(&mailbox).unwrap() {
          let request_path = entry.unwrap().path();
          if !request_path
            .file_name()
            .unwrap()
            .to_string_lossy()
            .starts_with("request-")
            || request_path.extension().is_none_or(|ext| ext != "json")
            || !seen.insert(request_path.clone())
          {
            continue;
          }
          let request: serde_json::Value =
            serde_json::from_slice(&fs::read(&request_path).unwrap()).unwrap();
          assert_eq!(request["process_id"], child_id);
          assert_eq!(
            Path::new(request["workspace"].as_str().unwrap()),
            canonical_workspace
          );
          let ordinal = request["ordinal"].as_u64().unwrap();
          assert_eq!(ordinal as usize, seen.len());
          if (early_review || initial_window || check_reserve) && ordinal == 1 {
            assert_eq!(
              fs::read_to_string(canonical_workspace.join("app.txt")).unwrap(),
              "owned initial"
            );
          }
          if (repair_window || check_reserve) && ordinal == 2 {
            assert_eq!(
              fs::read_to_string(canonical_workspace.join("app.txt")).unwrap(),
              "owned intermediate"
            );
          }
          let id = request["request_id"].as_str().unwrap();
          let passed = ordinal >= expected_checks as u64 || (check_reserve && ordinal == 3);
          let reply = serde_json::json!({"version":1,"request_id":id,
          "status":if passed { "passed" } else { "failed" },
          "feedback":if passed { "owned pass" } else if ordinal == 1 { "owned public failure" }
            else { "owned remaining failure" }});
          let temporary = mailbox.join(format!("reply-{id}.tmp"));
          fs::write(&temporary, serde_json::to_vec(&reply).unwrap()).unwrap();
          fs::rename(temporary, mailbox.join(format!("reply-{id}.json"))).unwrap();
        }
        if host_finished.load(std::sync::atomic::Ordering::SeqCst)
          || std::time::Instant::now() >= deadline
        {
          break;
        }
        std::thread::sleep(std::time::Duration::from_millis(5));
      }
      seen.len()
    });
    let output = child.wait_with_output().unwrap();
    child_finished.store(true, std::sync::atomic::Ordering::SeqCst);
    let observations = host.join();
    let diagnostics = format!(
      "status {}; stdout: {}; stderr: {}",
      output.status,
      String::from_utf8_lossy(&output.stdout),
      String::from_utf8_lossy(&output.stderr)
    );
    assert!(output.status.success(), "{diagnostics}");
    assert_eq!(
      observations.expect("owned mailbox host failed"),
      expected_checks as usize,
      "owned CLI exited without both mailbox observations: {diagnostics}"
    );
    assert_eq!(
      fs::read_to_string(workspace.join("app.txt")).unwrap(),
      "owned repaired"
    );
    let requests = server.requests();
    assert_eq!(
      requests.len(),
      if check_reserve {
        4
      } else if repair_window {
        5
      } else {
        3
      }
    );
    if check_reserve {
      assert!(requests[2].body.contains("bounded review"));
      assert!(requests[2].body.contains("owned remaining failure"));
    }
    if repair_window {
      assert!(requests[3].body.contains("owned remaining failure"));
    }
    assert!(requests[1].body.contains("owned public failure"));
    assert_eq!(requests[1].body.contains("bounded review"), early_review);
    assert!(!requests[1].body.contains("\"name\":\"exec\""));
  }
}

#[test]
fn completion_mailbox_preflight_rejects_missing_and_exposed_handlers_before_requests() {
  for (configured, supplied, exposed) in [
    (true, false, false),
    (false, true, false),
    (true, true, true),
  ] {
    let temp = TempDir::new().unwrap();
    let workspace = temp.path().join("workspace");
    let mailbox = temp.path().join("mailbox");
    fs::create_dir(&workspace).unwrap();
    fs::create_dir(&mailbox).unwrap();
    let listener = TcpListener::bind("127.0.0.1:0").unwrap();
    listener.set_nonblocking(true).unwrap();
    let path = write_config(
      temp.path(),
      &format!("http://{}/v1", listener.local_addr().unwrap()),
      true,
    );
    let mut config = RuntimeConfig::parse(&fs::read_to_string(&path).unwrap()).unwrap();
    config.limits.max_completion_checks_per_turn = configured.then_some(2);
    config.tools.allow_search_outside = exposed;
    fs::write(&path, config.to_json_string().unwrap()).unwrap();
    let mut command = Command::new(env!("CARGO_BIN_EXE_rupi"));
    command
      .args(["run", "--config"])
      .arg(&path)
      .arg("--cwd")
      .arg(&workspace)
      .args(["--prompt", "unused"]);
    if supplied {
      command.arg("--completion-feedback-dir").arg(&mailbox);
    }
    let output = command.output().unwrap();
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("completion"));
    assert_eq!(
      listener.accept().unwrap_err().kind(),
      std::io::ErrorKind::WouldBlock
    );
    assert_eq!(fs::read_dir(&mailbox).unwrap().count(), 0);
  }
}

#[test]
fn configured_initial_output_ceiling_reaches_the_provider_wire_first_only() {
  for thinking_input in [
    rupi_core::OpenAiThinkingInput::ReasoningEffort,
    rupi_core::OpenAiThinkingInput::ChatTemplateEnableThinking,
  ] {
    let temp = TempDir::new().unwrap();
    let workspace = temp.path().join("workspace");
    fs::create_dir(&workspace).unwrap();
    let server = FakeServer::answer(vec![
      tool_response(
        "first",
        "write",
        r#"{"path":"owned.txt","contents":"small coherent owned change"}"#,
        None,
      ),
      text_response("owned done"),
    ]);
    let path = write_config(temp.path(), &server.base_url(), true);
    let mut config = RuntimeConfig::parse(&fs::read_to_string(&path).unwrap()).unwrap();
    config.endpoints[0].capabilities.context_window = 262_144;
    config.endpoints[0].capabilities.max_output_tokens = Some(32_768);
    config.endpoints[0].max_output_tokens = Some(32_768);
    config.limits.max_model_requests_without_progress = Some(3);
    config.limits.initial_progress_boundary = true;
    config.limits.initial_progress_max_output_tokens = Some(8_192);
    config.limits.initial_progress_max_argument_chars = Some(2_048);
    config.limits.initial_progress_thinking = Some(rupi_core::ThinkingLevel::Off);
    config.thinking = rupi_core::ThinkingLevel::Low;
    config.endpoints[0].openai_compat.thinking_input = Some(thinking_input);
    config.endpoints[0].openai_compat.thinking_disable =
      Some(rupi_core::OpenAiThinkingDisable::ReasoningEffortNone);
    config.endpoints[0].openai_compat.preserve_reasoning = true;
    fs::write(&path, config.to_json_string().unwrap()).unwrap();
    let output = run(&path, &workspace, "create owned.txt");
    assert!(
      output.status.success(),
      "{}",
      String::from_utf8_lossy(&output.stderr)
    );
    let requests = server.requests();
    assert_eq!(requests.len(), 2);
    let first: serde_json::Value = serde_json::from_str(&requests[0].body).unwrap();
    let later: serde_json::Value = serde_json::from_str(&requests[1].body).unwrap();
    assert_eq!(first["max_tokens"], 8_192);
    if thinking_input == rupi_core::OpenAiThinkingInput::ChatTemplateEnableThinking {
      assert_eq!(
        first["chat_template_kwargs"],
        serde_json::json!({"enable_thinking":false})
      );
      assert_eq!(
        later["chat_template_kwargs"],
        serde_json::json!({"enable_thinking":true})
      );
      assert!(first.get("reasoning_effort").is_none());
      assert!(later.get("reasoning_effort").is_none());
    } else {
      assert_eq!(first["reasoning_effort"], "none");
      assert_eq!(later["reasoning_effort"], "low");
    }
    let first_write = first["tools"]
      .as_array()
      .unwrap()
      .iter()
      .find(|tool| tool["function"]["name"] == "write")
      .unwrap();
    assert_eq!(
      first_write["function"]["parameters"]["properties"]["contents"]["maxLength"],
      2_048
    );
    assert_eq!(later["max_tokens"], 32_768);
    let later_write = later["tools"]
      .as_array()
      .unwrap()
      .iter()
      .find(|tool| tool["function"]["name"] == "write")
      .unwrap();
    assert!(
      later_write["function"]["parameters"]["properties"]["contents"]
        .get("maxLength")
        .is_none()
    );
    assert_eq!(first["model"], later["model"]);
    assert_eq!(
      fs::read_to_string(workspace.join("owned.txt")).unwrap(),
      "small coherent owned change"
    );
  }
}

#[test]
fn configured_recurring_progress_rejects_completion_until_a_file_change_is_observed() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(vec![
    text_response("premature success"),
    tool_response(
      "write1",
      "write",
      r#"{"path":"app.txt","contents":"changed"}"#,
      None,
    ),
    text_response("done"),
  ]);
  let path = write_config(temp.path(), &server.base_url(), true);
  let mut config = RuntimeConfig::parse(&fs::read_to_string(&path).unwrap()).unwrap();
  config.limits.max_model_requests_without_progress = Some(5);
  config.limits.progress_boundary_mode = rupi_core::ProgressBoundaryMode::Recurring;
  config.limits.progress_tool_names = vec!["write".into()];
  config.limits.max_model_requests_per_turn = 4;
  fs::write(&path, config.to_json_string().unwrap()).unwrap();

  let output = run(&path, &workspace, "create app.txt");
  assert!(
    output.status.success(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  assert_eq!(
    fs::read_to_string(workspace.join("app.txt")).unwrap(),
    "changed"
  );
  let requests = server.requests();
  assert_eq!(requests.len(), 3);
  let correction: serde_json::Value = serde_json::from_str(&requests[1].body).unwrap();
  assert_eq!(correction["tools"].as_array().unwrap().len(), 1);
  assert_eq!(correction["tools"][0]["function"]["name"], "write");
  assert!(!requests[2].body.contains("premature success"));
  let events = trace_events(&temp.path().join("state"));
  assert!(events.iter().any(|event| matches!(
    event,
    AgentEvent::TurnCompleted(done) if done.status == TurnStatus::Completed
  )));
}

#[test]
fn streamed_partial_answer_is_not_followed_by_an_output_limit_retry() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(vec![truncated_text_response("partial answer")]);
  let config = write_config(temp.path(), &server.base_url(), true);

  let output = run(&config, &workspace, "answer the question");

  assert!(!output.status.success());
  assert_eq!(String::from_utf8_lossy(&output.stdout), "partial answer");
  assert_eq!(
    server.requests().len(),
    1,
    "no second request can fix stdout"
  );
  assert!(
    String::from_utf8_lossy(&output.stderr)
      .contains("partial assistant output was already streamed"),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
}

#[test]
fn endpoint_only_output_ceiling_is_budgeted_and_matches_the_wire_request() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(vec![text_response("budgeted answer")]);
  let config_path = write_config(temp.path(), &server.base_url(), true);
  let mut config = RuntimeConfig::parse(&fs::read_to_string(&config_path).unwrap()).unwrap();
  let endpoint = &mut config.endpoints[0];
  endpoint.capabilities.context_window = 8_192;
  endpoint.capabilities.max_output_tokens = None;
  endpoint.max_output_tokens = Some(4_096);
  fs::write(&config_path, serde_json::to_vec_pretty(&config).unwrap()).unwrap();
  let prompt = "x".repeat(12_000);

  let output = run(&config_path, &workspace, &prompt);

  assert!(
    output.status.success(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  let requests = server.requests();
  assert_eq!(requests.len(), 1);
  let body: serde_json::Value = serde_json::from_str(&requests[0].body).unwrap();
  let effective = body["max_tokens"].as_u64().expect("exact wire ceiling");
  assert!((256..4_096).contains(&effective), "{effective}");
  assert!(
    String::from_utf8_lossy(&output.stderr).contains("output budget reduced from 4096"),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
}

#[test]
fn one_turn_streams_and_persists_tools_messages_and_trace() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  #[cfg(windows)]
  let exec_cmd = r#"{"command":"set /p=executed<nul>exec.txt&exit /b 0"}"#;
  #[cfg(not(windows))]
  let exec_cmd = r#"{"command":"printf executed > exec.txt"}"#;

  let server = FakeServer::answer(vec![
    tool_response(
      "call_write",
      "write",
      r#"{"path":"model.txt","contents":"from tool\n"}"#,
      Some("choose a file"),
    ),
    tool_response("call_exec", "exec", exec_cmd, None),
    text_response("completed"),
  ]);
  let config = write_config(temp.path(), &server.base_url(), true);

  let output = run(&config, &workspace, "make the files");
  let requests = server.requests();
  assert!(
    output.status.success(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  // The assistant answer is byte-faithful on stdout, and the surface terminates the
  // prose block so a piped answer ends with a newline instead of a shell's `%`.
  assert_eq!(String::from_utf8_lossy(&output.stdout), "completed\n");
  let stderr = String::from_utf8_lossy(&output.stderr);
  // Reasoning is labelled with its provenance, never styled as prose.
  assert!(stderr.contains("[reasoning] choose a file"), "{stderr}");
  // The request line names the operation, the argument, and the declared risk.
  assert!(stderr.contains("[tool] write"), "{stderr}");
  assert!(stderr.contains("path=model.txt"), "{stderr}");
  assert!(stderr.contains("mutating"), "{stderr}");
  // Completion is spelled out, not a debug-formatted enum variant.
  assert!(stderr.contains("[tool ok] exec · succeeded"), "{stderr}");
  assert!(!stderr.contains("Succeeded"), "{stderr}");
  // Routine chrome is calm by default: one line per model request is noise.
  assert!(!stderr.contains("[request]"), "{stderr}");
  assert!(stderr.contains("[session end]"), "{stderr}");
  assert_eq!(requests.len(), 3);
  assert_eq!(
    fs::read_to_string(workspace.join("model.txt")).unwrap(),
    "from tool\n"
  );
  assert_eq!(
    fs::read_to_string(workspace.join("exec.txt")).unwrap(),
    "executed"
  );

  let state = temp.path().join("state");
  let layout = StateLayout::new(&state);
  let session_id = layout
    .list_session_ids()
    .unwrap()
    .pop()
    .expect("session id");
  let restored = Store::new(&state, WritePolicy::default())
    .restore(&session_id)
    .unwrap();
  assert_eq!(
    restored.header.working_dir,
    workspace.canonicalize().unwrap().to_string_lossy()
  );
  assert_eq!(restored.header.model, ModelRef::new("fake", "agent"));

  let messages: Vec<_> = restored.messages.iter().collect();
  assert!(messages.iter().any(|message| message.role == Role::User));
  assert!(
    messages
      .iter()
      .any(|message| message.role == Role::Assistant)
  );
  assert!(messages.iter().any(|message| message.role == Role::Tool));
  assert!(messages.iter().all(|message| {
    message.epoch == 0 && message.model == ModelRef::new("fake", "agent") && message.seq.is_some()
  }));

  let trace = TraceJournal::read(&layout.trace_path(&session_id))
    .unwrap()
    .items;
  let sequences: Vec<u64> = trace
    .iter()
    .map(|entry| entry.envelope.meta.seq.expect("store sequence").0)
    .collect();
  assert_eq!(sequences, (1..=sequences.len() as u64).collect::<Vec<_>>());
  assert!(trace.iter().any(|entry| matches!(
    &entry.envelope.event,
    AgentEvent::SessionStarted(started)
      if started.working_dir == workspace.canonicalize().unwrap().to_string_lossy()
        && started.model == ModelRef::new("fake", "agent")
  )));
  assert!(trace.iter().any(|entry| matches!(
    &entry.envelope.event,
    AgentEvent::ReasoningDelta(delta)
      if delta.provenance == rupi_core::ReasoningProvenance::Native
  )));

  for call_id in ["call_write", "call_exec"] {
    let requested = trace
      .iter()
      .position(|entry| {
        matches!(
          &entry.envelope.event,
          AgentEvent::ToolRequested(event) if event.call_id.as_str() == call_id
        )
      })
      .unwrap();
    let started = trace
      .iter()
      .position(|entry| {
        matches!(
          &entry.envelope.event,
          AgentEvent::ToolStarted(event) if event.call_id.as_str() == call_id
        )
      })
      .unwrap();
    let completed = trace
      .iter()
      .position(|entry| {
        matches!(
          &entry.envelope.event,
          AgentEvent::ToolCompleted(event) if event.call_id.as_str() == call_id
        )
      })
      .unwrap();
    assert!(requested < started && started < completed);
  }
  for message in messages {
    let entry = trace
      .iter()
      .find(|entry| entry.envelope.meta.event_id == message.event_id)
      .expect("message introducing event");
    assert_eq!(entry.envelope.meta.seq, message.seq);
    assert!(
      matches!(
        (message.role, &entry.envelope.event),
        (Role::User, AgentEvent::UserInput(_))
          | (Role::Assistant, AgentEvent::AssistantDelta(_))
          | (Role::Assistant, AgentEvent::ModelRequestCompleted(_))
          | (Role::Tool, AgentEvent::ToolCompleted(_))
          | (Role::Tool, AgentEvent::ToolFailed(_))
          | (Role::Tool, AgentEvent::ToolUnknown(_))
      ),
      "message role {:?} attributed to {:?}",
      message.role,
      entry.envelope.event
    );
  }
}

#[test]
fn one_shot_budget_exhaustion_exits_successfully_with_a_resumable_status() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let responses = (0..3)
    .map(|index| tool_response(&format!("budget_{index}"), "unknown_tool", "{}", None))
    .collect();
  let server = FakeServer::answer(responses);
  let config = write_config(temp.path(), &server.base_url(), true);
  let mut config_value: RuntimeConfig =
    serde_json::from_str(&fs::read_to_string(&config).unwrap()).unwrap();
  config_value.limits.max_model_requests_per_turn = 3;
  fs::write(&config, serde_json::to_vec_pretty(&config_value).unwrap()).unwrap();

  let output = run(&config, &workspace, "keep working");
  let requests = server.requests();
  assert_eq!(requests.len(), 3, "the configured request budget is finite");
  assert!(
    output.status.success(),
    "a durably recorded budget boundary is resumable: {}",
    String::from_utf8_lossy(&output.stderr)
  );
  let terminal = format!(
    "{}{}",
    String::from_utf8_lossy(&output.stdout),
    String::from_utf8_lossy(&output.stderr)
  );
  assert!(terminal.contains("budget exhausted"), "{terminal}");
  assert!(terminal.contains("request 2/3"), "{terminal}");

  let layout = StateLayout::new(temp.path().join("state"));
  let session_id = layout.list_session_ids().unwrap().pop().expect("session");
  let trace = TraceJournal::read(&layout.trace_path(&session_id))
    .unwrap()
    .items;
  assert!(trace.iter().any(|entry| matches!(
    &entry.envelope.event,
    AgentEvent::TurnCompleted(done) if done.status == TurnStatus::BudgetExhausted
  )));
  assert!(matches!(
    &trace.last().expect("session end follows the completed turn").envelope.event,
    AgentEvent::SessionEnded(ended)
      if matches!(&ended.reason, SessionEndReason::Interrupted { message }
        if message == "model request budget exhausted")
  ));
}

#[test]
fn headless_requests_do_not_expose_mutating_tools_without_auto_approval() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(vec![
    tool_response(
      "call_denied",
      "write",
      r#"{"path":"denied.txt","contents":"must not exist"}"#,
      None,
    ),
    text_response("denied as expected"),
  ]);
  let config = write_config(temp.path(), &server.base_url(), false);

  let output = run(&config, &workspace, "try to write");
  let requests = server.requests();
  let request: serde_json::Value = serde_json::from_str(&requests[0].body).unwrap();
  assert!(
    request["tools"]
      .as_array()
      .into_iter()
      .flatten()
      .all(|tool| tool["function"]["name"] != "write")
  );
  assert!(
    output.status.success(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  assert!(!workspace.join("denied.txt").exists());

  let layout = StateLayout::new(temp.path().join("state"));
  let session_id = layout.list_session_ids().unwrap().pop().unwrap();
  let trace = TraceJournal::read(&layout.trace_path(&session_id))
    .unwrap()
    .items;
  assert!(trace.iter().any(|entry| matches!(
    &entry.envelope.event,
    AgentEvent::ToolFailed(failed)
      if failed.call_id.as_str() == "call_denied"
        && failed.message.contains("not in this request's permitted tool catalog")
  )));
  assert!(!trace.iter().any(|entry| matches!(
    &entry.envelope.event,
    AgentEvent::ToolStarted(started) if started.call_id.as_str() == "call_denied"
  )));
}

#[test]
fn one_shot_read_cannot_escape_the_workspace_or_leak_secret_bytes() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let secret = "outside-secret-value-91f7";
  let outside = temp.path().join("secret.txt");
  fs::write(&outside, secret).unwrap();
  let absolute_arguments = serde_json::json!({"path": outside.to_string_lossy()}).to_string();
  let server = FakeServer::answer(vec![
    tool_response("call_absolute", "read", &absolute_arguments, None),
    tool_response("call_parent", "read", r#"{"path":"../secret.txt"}"#, None),
    text_response("outside reads refused"),
  ]);
  let config = write_config(temp.path(), &server.base_url(), true);

  let output = run(&config, &workspace, "read outside");
  let requests = server.requests();
  assert!(
    output.status.success(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  assert_eq!(requests.len(), 3);
  assert!(
    requests
      .iter()
      .all(|request| !request.body.contains(secret))
  );

  let layout = StateLayout::new(temp.path().join("state"));
  let session_id = layout.list_session_ids().unwrap().pop().unwrap();
  let trace = TraceJournal::read(&layout.trace_path(&session_id))
    .unwrap()
    .items;
  for call_id in ["call_absolute", "call_parent"] {
    assert!(trace.iter().any(|entry| matches!(
      &entry.envelope.event,
      AgentEvent::ToolFailed(failed)
        if failed.call_id.as_str() == call_id && failed.message.contains("outside the workspace")
    )));
  }
}

#[test]
fn invalid_workspace_is_rejected_before_any_provider_request() {
  let temp = TempDir::new().unwrap();
  let listener = TcpListener::bind("127.0.0.1:0").unwrap();
  listener.set_nonblocking(true).unwrap();
  let config = write_config(
    temp.path(),
    &format!("http://{}/v1", listener.local_addr().unwrap()),
    true,
  );

  let output = run(&config, &temp.path().join("missing"), "hello");
  assert!(!output.status.success());
  assert!(
    String::from_utf8_lossy(&output.stderr).contains("invalid workspace"),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  assert_eq!(
    listener.accept().unwrap_err().kind(),
    std::io::ErrorKind::WouldBlock
  );
}

#[cfg(target_os = "linux")]
#[test]
fn non_utf8_workspace_is_rejected_before_any_provider_request() {
  use std::{ffi::OsString, os::unix::ffi::OsStringExt};

  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join(OsString::from_vec(vec![b'w', 0xff]));
  fs::create_dir(&workspace).unwrap();
  let listener = TcpListener::bind("127.0.0.1:0").unwrap();
  listener.set_nonblocking(true).unwrap();
  let config = write_config(
    temp.path(),
    &format!("http://{}/v1", listener.local_addr().unwrap()),
    true,
  );

  let output = run(&config, &workspace, "hello");
  assert!(!output.status.success());
  assert!(
    String::from_utf8_lossy(&output.stderr).contains("not valid UTF-8"),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  assert_eq!(
    listener.accept().unwrap_err().kind(),
    std::io::ErrorKind::WouldBlock
  );
}

#[test]
fn absent_primary_endpoint_and_invalid_json_exit_nonzero() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let no_endpoint = temp.path().join("no-endpoint.json");
  let config = RuntimeConfig::new(
    ModelRef::new("missing", "model"),
    temp.path().join("state").to_string_lossy(),
  );
  fs::write(&no_endpoint, serde_json::to_vec(&config).unwrap()).unwrap();
  let output = run(&no_endpoint, &workspace, "hello");
  assert!(!output.status.success());
  assert!(String::from_utf8_lossy(&output.stderr).contains("has no endpoint entry"));

  let invalid = temp.path().join("invalid.json");
  fs::write(&invalid, b"not json").unwrap();
  let output = run(&invalid, &workspace, "hello");
  assert!(!output.status.success());
  assert!(String::from_utf8_lossy(&output.stderr).contains("invalid config"));
}

#[test]
fn provider_and_durable_state_failures_exit_nonzero() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(vec![
    status_response(503, "Unavailable", r#"{"error":{"message":"offline"}}"#),
    status_response(503, "Unavailable", r#"{"error":{"message":"offline"}}"#),
  ]);
  let config = write_config(temp.path(), &server.base_url(), true);
  let output = run(&config, &workspace, "hello");
  server.requests();
  assert!(!output.status.success());
  let stderr = String::from_utf8_lossy(&output.stderr);
  assert!(stderr.contains("provider failure"));
  assert!(stderr.contains("provider_unavailable"), "{stderr}");
  assert!(stderr.contains("http 503"), "{stderr}");
  assert!(stderr.contains("offline"), "{stderr}");

  let blocked_root = temp.path().join("state-is-a-file");
  fs::write(&blocked_root, "not a directory").unwrap();
  let mut config_value: serde_json::Value =
    serde_json::from_slice(&fs::read(&config).unwrap()).unwrap();
  config_value["state_dir"] = blocked_root.to_string_lossy().into_owned().into();
  let blocked_config = temp.path().join("blocked-config.json");
  fs::write(&blocked_config, serde_json::to_vec(&config_value).unwrap()).unwrap();
  let output = run(&blocked_config, &workspace, "hello");
  assert!(!output.status.success());
  assert!(String::from_utf8_lossy(&output.stderr).contains("durable state"));
}

#[test]
fn help_argument_errors_and_bare_invocation_exit_without_configuration() {
  let binary = env!("CARGO_BIN_EXE_rupi");
  let bare = Command::new(binary).output().unwrap();
  assert!(bare.status.success());
  // A bare invocation names the commands rather than guessing one, so it has to list
  // all of them.
  let top_help = String::from_utf8_lossy(&bare.stdout);
  assert!(top_help.contains("Usage: rupi <command>"), "{top_help}");
  for command in ["run", "interactive", "trace", "skills", "prompts", "prompt"] {
    assert!(
      top_help.contains(command),
      "{command} missing from: {top_help}"
    );
  }

  let help = Command::new(binary)
    .args(["run", "--help"])
    .output()
    .unwrap();
  assert!(help.status.success());
  assert!(String::from_utf8_lossy(&help.stdout).contains("one durable coding-agent turn"));

  let invalid = Command::new(binary)
    .args(["run", "--prompt", "hi"])
    .output()
    .unwrap();
  assert_eq!(invalid.status.code(), Some(2));
  assert!(String::from_utf8_lossy(&invalid.stderr).contains("--config is required"));
}

// --- surface flags -------------------------------------------------------------

/// Run with extra surface flags, under a pinned environment.
///
/// The surface resolves colour and width from the environment, so a test that inherited
/// the developer's `NO_COLOR` or `TERM` would render differently in CI than at a desk.
fn run_surface(config: &Path, cwd: &Path, prompt: &str, extra: &[&str]) -> Output {
  Command::new(env!("CARGO_BIN_EXE_rupi"))
    .args(["run", "--config"])
    .arg(config)
    .arg("--cwd")
    .arg(cwd)
    .args(["--prompt", prompt])
    .args(extra)
    .env_remove("NO_COLOR")
    .env_remove("TERM")
    .env_remove("CLICOLOR")
    .env_remove("CLICOLOR_FORCE")
    .output()
    .expect("run rupi")
}

/// One offline turn with its own workspace, state root, config and fake provider.
///
/// A run consumes its provider's responses and writes its own session, so two runs that
/// are meant to be compared need two scenarios.
struct Scenario {
  workspace: PathBuf,
  state: PathBuf,
  config: PathBuf,
  server: FakeServer,
  _temp: TempDir,
}

fn scenario(responses: Vec<String>) -> Scenario {
  scenario_exposing(responses, ReasoningExposure::Native)
}

/// A scenario whose endpoint declares a different reasoning exposure.
fn scenario_exposing(responses: Vec<String>, exposed_reasoning: ReasoningExposure) -> Scenario {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(responses);
  let config = write_config_exposing(temp.path(), &server.base_url(), true, exposed_reasoning);
  let state = temp.path().join("state");
  Scenario {
    workspace,
    state,
    config,
    server,
    _temp: temp,
  }
}

/// A turn that reasons, calls one mutating tool, then answers in a single long line.
fn reasoning_and_long_answer() -> Vec<String> {
  vec![
    tool_response(
      "call_write",
      "write",
      r#"{"path":"model.txt","contents":"from tool\n"}"#,
      Some("choose a file"),
    ),
    text_response(&"answer ".repeat(40)),
  ]
}

fn trace_events(state: &Path) -> Vec<AgentEvent> {
  let layout = StateLayout::new(state);
  let session_id = layout
    .list_session_ids()
    .unwrap()
    .pop()
    .expect("session id");
  TraceJournal::read(&layout.trace_path(&session_id))
    .unwrap()
    .items
    .into_iter()
    .map(|entry| entry.envelope.event)
    .collect()
}

#[test]
fn no_reasoning_flag_hides_reasoning_without_hiding_the_answer() {
  let scene = scenario(reasoning_and_long_answer());
  let output = run_surface(&scene.config, &scene.workspace, "go", &["--no-reasoning"]);
  let stderr = String::from_utf8_lossy(&output.stderr);
  assert!(output.status.success(), "{stderr}");
  assert!(!stderr.contains("[reasoning"), "{stderr}");
  // Hiding reasoning is not hiding the work: the rest of the transcript is intact.
  assert!(stderr.contains("[tool] write"), "{stderr}");
  assert!(stderr.contains("[tool ok] write"), "{stderr}");
  assert!(String::from_utf8_lossy(&output.stdout).starts_with("answer answer"));
}

/// The provenance claim is a claim about where the text came from, and only the
/// endpoint's own declaration says. A hosted endpoint exposes a *summary* of
/// reasoning it keeps hidden, sends it in the same `reasoning_content` field a local
/// server uses for the model's actual thinking, and must not be rendered as if
/// hidden thought had been recovered.
#[test]
fn a_summary_only_endpoint_is_labelled_as_a_summary() {
  let scene = scenario_exposing(
    reasoning_and_long_answer(),
    ReasoningExposure::ProviderSummary,
  );
  let output = run_surface(&scene.config, &scene.workspace, "go", &[]);
  let stderr = String::from_utf8_lossy(&output.stderr);
  assert!(output.status.success(), "{stderr}");
  assert!(
    stderr.contains("[provider summary] choose a file"),
    "{stderr}"
  );
  assert!(
    !stderr.contains("[reasoning] "),
    "a summary must not be shown as native thinking: {stderr}"
  );
  // The durable record carries the same claim, not the field it was decoded from.
  let provenance: Vec<&str> = trace_events(&scene.state)
    .iter()
    .filter_map(|event| match event {
      AgentEvent::ReasoningDelta(delta) => Some(delta.provenance.as_str()),
      _ => None,
    })
    .collect();
  assert!(
    !provenance.is_empty(),
    "the reasoning must still be recorded"
  );
  assert!(
    provenance.iter().all(|p| *p == "provider_summary"),
    "{provenance:?}"
  );
}

#[test]
fn silent_suppresses_the_surface_but_not_the_record() {
  let scene = scenario(reasoning_and_long_answer());
  let output = run_surface(&scene.config, &scene.workspace, "go", &["--silent"]);
  assert!(output.status.success(), "{:?}", output.stderr);
  assert!(
    output.stderr.is_empty(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  // Suppressing the display must not suppress the answer...
  assert!(String::from_utf8_lossy(&output.stdout).starts_with("answer answer"));
  // ...nor the durable trace, which is the product.
  let events = trace_events(&scene.state);
  assert!(
    events
      .iter()
      .any(|event| matches!(event, AgentEvent::ReasoningDelta(_))),
    "reasoning must still be recorded: {events:?}"
  );
  assert!(
    events
      .iter()
      .any(|event| matches!(event, AgentEvent::ToolRequested(_))),
    "tool calls must still be recorded: {events:?}"
  );
}

#[test]
fn quiet_keeps_trouble_and_drops_routine_work() {
  let scene = scenario(reasoning_and_long_answer());
  let output = run_surface(&scene.config, &scene.workspace, "go", &["--quiet"]);
  let stderr = String::from_utf8_lossy(&output.stderr);
  assert!(output.status.success(), "{stderr}");
  // Routine work is not news in a log someone scans for trouble.
  assert!(!stderr.contains("[tool ok]"), "{stderr}");
  assert!(!stderr.contains("[tool] write"), "{stderr}");
  assert!(!stderr.contains("[reasoning"), "{stderr}");
  assert!(!stderr.contains("> go"), "{stderr}");
  // The answer is not transcript, so quiet never touches it.
  assert!(String::from_utf8_lossy(&output.stdout).starts_with("answer answer"));
}

#[test]
fn quiet_still_reports_an_unavailable_mutating_tool() {
  // A policy refusal is news precisely in the log that asked for only news: the model
  // tried to change something and did not.
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(vec![
    tool_response(
      "call_denied",
      "write",
      r#"{"path":"denied.txt","contents":"must not exist"}"#,
      None,
    ),
    text_response("denied as expected"),
  ]);
  // Headless execution without auto-approval does not expose mutating tools.
  let config = write_config(temp.path(), &server.base_url(), false);

  let output = run_surface(&config, &workspace, "try to write", &["--quiet"]);
  let stderr = String::from_utf8_lossy(&output.stderr);
  assert!(output.status.success(), "{stderr}");
  assert!(stderr.contains("[tool failed] write"), "{stderr}");
  assert!(
    stderr.contains("not in this request's permitted tool catalog"),
    "{stderr}"
  );
  assert!(!workspace.join("denied.txt").exists());
}

#[test]
fn verbose_prints_each_request_once_not_twice() {
  let scene = scenario(vec![
    tool_response(
      "call_write",
      "write",
      r#"{"path":"a.txt","contents":"x"}"#,
      None,
    ),
    tool_response("call_read", "read", r#"{"path":"a.txt"}"#, None),
    text_response("done"),
  ]);
  let output = run_surface(&scene.config, &scene.workspace, "go", &["--verbose"]);
  let stderr = String::from_utf8_lossy(&output.stderr);
  assert!(output.status.success(), "{stderr}");
  let requests = scene.server.requests();
  assert_eq!(requests.len(), 3);
  // The live surface and the durable trace partition events. If that partition were
  // wrong, the same request line would print twice per request.
  assert_eq!(
    stderr.matches("[request] fake/agent").count(),
    3,
    "one line per request, no double printing: {stderr}"
  );
}

#[test]
fn width_wraps_stderr_but_never_the_answer() {
  let scene = scenario(reasoning_and_long_answer());
  let output = run_surface(&scene.config, &scene.workspace, "go", &["--width=40"]);
  let stderr = String::from_utf8_lossy(&output.stderr);
  assert!(output.status.success(), "{stderr}");
  for line in stderr.lines() {
    assert!(line.chars().count() <= 40, "wider than requested: {line}");
  }
  // The answer is data for a pipe, not a paragraph for a terminal: it is never wrapped.
  let stdout = String::from_utf8_lossy(&output.stdout);
  assert_eq!(stdout.lines().count(), 1, "{stdout}");
  assert!(stdout.starts_with(&"answer ".repeat(40)));
}

#[test]
fn colour_is_a_projection_and_never_touches_the_answer() {
  // Piped output is monochrome by default: nobody wants escape codes in a log file.
  let scene = scenario(reasoning_and_long_answer());
  let plain = run_surface(&scene.config, &scene.workspace, "go", &[]);
  assert!(
    plain.status.success(),
    "{}",
    String::from_utf8_lossy(&plain.stderr)
  );
  assert!(
    !plain.stdout.contains(&0x1b),
    "{}",
    String::from_utf8_lossy(&plain.stdout)
  );
  assert!(
    !plain.stderr.contains(&0x1b),
    "{}",
    String::from_utf8_lossy(&plain.stderr)
  );

  // An explicit request wins over the environment, including NO_COLOR.
  let scene = scenario(reasoning_and_long_answer());
  let coloured = Command::new(env!("CARGO_BIN_EXE_rupi"))
    .args(["run", "--config"])
    .arg(&scene.config)
    .arg("--cwd")
    .arg(&scene.workspace)
    .args(["--prompt", "go"])
    .args(["--color=always"])
    .env("NO_COLOR", "1")
    .output()
    .expect("run rupi");
  let coloured_stderr = String::from_utf8_lossy(&coloured.stderr);
  assert!(coloured.stderr.contains(&0x1b), "{coloured_stderr}");
  // Even forced, colour stays on the diagnostic stream; the answer stays byte-faithful.
  assert!(
    !coloured.stdout.contains(&0x1b),
    "{}",
    String::from_utf8_lossy(&coloured.stdout)
  );
}

#[test]
fn the_answer_does_not_change_with_what_the_surface_shows() {
  let loud = scenario(reasoning_and_long_answer());
  let quiet = scenario(reasoning_and_long_answer());
  let loud = run_surface(&loud.config, &loud.workspace, "go", &["--verbose"]);
  let quiet = run_surface(&quiet.config, &quiet.workspace, "go", &["--silent"]);
  assert!(
    loud.status.success(),
    "{}",
    String::from_utf8_lossy(&loud.stderr)
  );
  assert_eq!(loud.stdout, quiet.stdout);
  assert!(!loud.stdout.is_empty());
}

/// The committed skills fixture, used as `$HOME` so the scan is the same on every machine.
fn fixture_home() -> std::path::PathBuf {
  std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
    .join("tests/compat/skills/home")
    .canonicalize()
    .expect("fixture home")
}

#[test]
fn a_skill_listing_reaches_the_model_as_the_system_message() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(vec![text_response("done")]);
  let config = write_config(temp.path(), &server.base_url(), true);
  let output = Command::new(env!("CARGO_BIN_EXE_rupi"))
    .args(["run", "--config"])
    .arg(&config)
    .arg("--cwd")
    .arg(&workspace)
    .args(["--prompt", "hello"])
    .env("HOME", fixture_home())
    .env("USERPROFILE", fixture_home())
    .output()
    .expect("run rupi");
  let requests = server.requests();
  assert!(
    output.status.success(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  let body = &requests[0].body;
  // Pi's mechanism, exactly: the model is told what skills exist and where the files
  // are, and decides to read one. The block travels as the system message, first.
  assert!(body.contains("\"role\":\"system\""), "{body}");
  assert!(body.contains("You are Rupi, a coding assistant"), "{body}");
  assert!(body.contains("Working directory:"), "{body}");
  assert!(body.contains("never claim an unrun check passed"), "{body}");
  assert!(body.contains("<available_skills>"), "{body}");
  assert!(
    body.find("You are Rupi, a coding assistant") < body.find("<available_skills>"),
    "the permanent prompt precedes appended skills: {body}"
  );
  assert!(body.contains("pdf-tools"), "{body}");
  assert!(
    !body.contains("loose"),
    "a disable-model-invocation skill is not offered to the model:\n{body}"
  );
}

#[test]
fn a_run_with_no_skills_nearby_still_sends_the_core_system_prompt() {
  let temp = TempDir::new().unwrap();
  let workspace = temp.path().join("workspace");
  fs::create_dir(&workspace).unwrap();
  let server = FakeServer::answer(vec![text_response("done")]);
  let config = write_config(temp.path(), &server.base_url(), true);
  let output = Command::new(env!("CARGO_BIN_EXE_rupi"))
    .args(["run", "--config"])
    .arg(&config)
    .arg("--cwd")
    .arg(&workspace)
    .args(["--prompt", "hello"])
    .env("HOME", temp.path()) // a home with no skills anywhere under it
    .env("USERPROFILE", temp.path())
    .output()
    .expect("run rupi");
  let requests = server.requests();
  assert!(
    output.status.success(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  assert!(
    requests[0].body.contains("\"role\":\"system\""),
    "{}",
    requests[0].body
  );
  assert!(
    requests[0]
      .body
      .contains("You are Rupi, a coding assistant"),
    "{}",
    requests[0].body
  );
  assert!(requests[0].body.contains("Working directory:"));
  assert!(
    requests[0].body.contains(
      "Tools available for this request: append, edit, exec, grep, process, read, write."
    )
  );
  assert!(
    !requests[0].body.contains("available_skills"),
    "{}",
    requests[0].body
  );
}
