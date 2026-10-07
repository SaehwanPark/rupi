//! Caller-owned completion observations. This adapter exchanges data, never executes checks.

use std::{
  fs::{self, OpenOptions},
  io::{Read, Write},
  path::{Path, PathBuf},
  time::{Duration, Instant},
};

use rupi_core::{CancelToken, RuntimeConfig, TurnId};
use rupi_runtime::{
  CompletionCheckRequest, CompletionCheckResult, CompletionCheckStatus,
  MAX_COMPLETION_FEEDBACK_BYTES,
};
use serde::{Deserialize, Serialize};

const MAX_REPLY_BYTES: u64 = 128 * 1024;
const MAX_WAIT: Duration = Duration::from_secs(300);

#[derive(Debug)]
pub(crate) struct CompletionMailbox {
  directory: PathBuf,
  workspace: PathBuf,
  wait_limit: Duration,
}

#[cfg(test)]
mod tests {
  use super::*;
  use serde_json::{Value, json};

  fn fixture() -> (tempfile::TempDir, CompletionMailbox, RuntimeConfig) {
    let temp = tempfile::tempdir().unwrap();
    let workspace = temp.path().join("workspace");
    let directory = temp.path().join("mailbox");
    fs::create_dir(&workspace).unwrap();
    fs::create_dir(&directory).unwrap();
    let mut config = RuntimeConfig::new(
      rupi_core::ModelRef::parse("local/owned").unwrap(),
      "owned-state",
    );
    config.limits.max_completion_checks_per_turn = Some(2);
    let mailbox = CompletionMailbox::configure(Some(&directory), &workspace, &config, None)
      .unwrap()
      .unwrap();
    (temp, mailbox, config)
  }

  fn request() -> CompletionCheckRequest {
    CompletionCheckRequest {
      ordinal: 1,
      remaining_turn_time: Some(Duration::from_secs(2)),
    }
  }

  fn with_reply(transform: impl Fn(Value) -> Vec<u8> + Send + 'static) -> CompletionCheckResult {
    let (_temp, mailbox, _) = fixture();
    let directory = mailbox.directory.clone();
    fs::write(directory.join("reply-stale.json"), b"unrelated stale bytes").unwrap();
    let host = std::thread::spawn(move || {
      let deadline = Instant::now() + Duration::from_secs(3);
      loop {
        let published = fs::read_dir(&directory)
          .unwrap()
          .filter_map(Result::ok)
          .map(|entry| entry.path())
          .find(|path| {
            path
              .file_name()
              .unwrap()
              .to_string_lossy()
              .starts_with("request-")
              && path
                .extension()
                .is_some_and(|extension| extension == "json")
          });
        if let Some(path) = published {
          let request: Value = serde_json::from_slice(&fs::read(&path).unwrap()).unwrap();
          assert_eq!(request["version"], 1);
          assert_eq!(request["process_id"], std::process::id());
          assert_eq!(request["ordinal"], 1);
          assert!(request["wait_timeout_ms"].as_u64().unwrap() <= 2_000);
          assert!(Path::new(request["workspace"].as_str().unwrap()).is_absolute());
          let id = request["request_id"].as_str().unwrap().to_string();
          let bytes = transform(json!({"version":1,"request_id":id,
            "status":"failed","feedback":"owned public failure"}));
          let temporary = directory.join(format!("reply-{id}.tmp"));
          fs::write(&temporary, bytes).unwrap();
          fs::rename(temporary, directory.join(format!("reply-{id}.json"))).unwrap();
          return path;
        }
        assert!(Instant::now() < deadline, "request was not published");
        std::thread::sleep(Duration::from_millis(5));
      }
    });
    let result = mailbox.check(request(), &CancelToken::new());
    assert!(
      host.join().unwrap().exists(),
      "mailbox artifacts must be retained"
    );
    result
  }

  #[test]
  fn mailbox_matches_atomic_reply_and_ignores_stale_data() {
    let result = with_reply(|reply| serde_json::to_vec(&reply).unwrap());
    assert_eq!(result.status, CompletionCheckStatus::Failed);
    assert_eq!(result.feedback, "owned public failure");
    for status in ["passed", "unavailable"] {
      let result = with_reply(move |mut reply| {
        reply["status"] = json!(status);
        serde_json::to_vec(&reply).unwrap()
      });
      assert_eq!(
        result.status,
        if status == "passed" {
          CompletionCheckStatus::Passed
        } else {
          CompletionCheckStatus::Unavailable
        }
      );
    }
  }

  #[test]
  fn mailbox_rejects_invalid_identity_version_fields_and_partial_data() {
    for (field, value) in [
      ("request_id", json!("wrong")),
      ("version", json!(2)),
      ("unexpected", json!(true)),
      ("status", json!("unknown")),
      ("feedback", json!(false)),
    ] {
      let result = with_reply(move |mut reply| {
        reply[field] = value.clone();
        serde_json::to_vec(&reply).unwrap()
      });
      assert_eq!(result.status, CompletionCheckStatus::Unavailable);
    }
    for bytes in [
      b"{\"version\":".to_vec(),
      vec![0xff, 0xfe],
      vec![b'x'; MAX_REPLY_BYTES as usize + 1],
    ] {
      assert_eq!(
        with_reply(move |_| bytes.clone()).status,
        CompletionCheckStatus::Unavailable
      );
    }
    assert_eq!(
      with_reply(|mut reply| {
        reply["feedback"] = json!("é".repeat(MAX_COMPLETION_FEEDBACK_BYTES / 2 + 1));
        serde_json::to_vec(&reply).unwrap()
      })
      .status,
      CompletionCheckStatus::Unavailable
    );
  }

  #[test]
  fn mailbox_cancels_bounds_time_and_never_replays_an_exchange() {
    let (_temp, mailbox, _) = fixture();
    let cancel = CancelToken::new();
    cancel.cancel();
    assert_eq!(
      mailbox.check(request(), &cancel).status,
      CompletionCheckStatus::Unavailable
    );
    assert_eq!(fs::read_dir(&mailbox.directory).unwrap().count(), 0);
    let short = CompletionCheckRequest {
      remaining_turn_time: Some(Duration::from_millis(30)),
      ..request()
    };
    assert_eq!(
      mailbox.check(short, &CancelToken::new()).status,
      CompletionCheckStatus::Unavailable
    );
    let cancel = CancelToken::new();
    let child = cancel.clone();
    let thread = std::thread::spawn(move || {
      std::thread::sleep(Duration::from_millis(30));
      child.cancel();
    });
    assert_eq!(
      mailbox.check(request(), &cancel).status,
      CompletionCheckStatus::Unavailable
    );
    thread.join().unwrap();
    let count = fs::read_dir(&mailbox.directory).unwrap().count();
    assert_eq!(count, 2);
    let no_time = CompletionCheckRequest {
      remaining_turn_time: Some(Duration::ZERO),
      ..request()
    };
    assert_eq!(
      mailbox.check(no_time, &CancelToken::new()).status,
      CompletionCheckStatus::Unavailable
    );
    assert_eq!(fs::read_dir(&mailbox.directory).unwrap().count(), count);
  }

  #[test]
  fn mailbox_caps_slow_observations_and_ignores_late_passed_replies() {
    let (_temp, original, config) = fixture();
    let mailbox = CompletionMailbox::configure(
      Some(&original.directory),
      &original.workspace,
      &config,
      Some(Duration::from_millis(30)),
    )
    .unwrap()
    .unwrap();
    let directory = mailbox.directory.clone();
    let host = std::thread::spawn(move || {
      let deadline = Instant::now() + Duration::from_secs(2);
      loop {
        if let Some(path) = fs::read_dir(&directory)
          .unwrap()
          .map(|entry| entry.unwrap().path())
          .find(|path| {
            path
              .file_name()
              .unwrap()
              .to_string_lossy()
              .starts_with("request-")
              && path
                .extension()
                .is_some_and(|extension| extension == "json")
          })
        {
          let request: Value = serde_json::from_slice(&fs::read(path).unwrap()).unwrap();
          assert_eq!(request["wait_timeout_ms"], 30);
          let id = request["request_id"].as_str().unwrap();
          // A determinate pass arriving after the deadline cannot accept this or a later request.
          std::thread::sleep(Duration::from_millis(80));
          fs::write(
            directory.join(format!("reply-{id}.json")),
            serde_json::to_vec(&json!({"version":1,"request_id":id,
              "status":"passed","feedback":"owned late pass"}))
            .unwrap(),
          )
          .unwrap();
          return;
        }
        assert!(Instant::now() < deadline, "owned request did not arrive");
        std::thread::sleep(Duration::from_millis(1));
      }
    });
    let started = Instant::now();
    let first = mailbox.check(request(), &CancelToken::new());
    assert_eq!(first.status, CompletionCheckStatus::Unavailable);
    assert_eq!(first.feedback, "completion observation timed out");
    assert!(started.elapsed() < Duration::from_secs(1));
    host.join().unwrap();
    let second = mailbox.check(
      CompletionCheckRequest {
        ordinal: 2,
        remaining_turn_time: Some(Duration::from_millis(10)),
      },
      &CancelToken::new(),
    );
    assert_eq!(second.status, CompletionCheckStatus::Unavailable);
    let mut requests: Vec<Value> = fs::read_dir(&mailbox.directory)
      .unwrap()
      .map(|entry| entry.unwrap().path())
      .filter(|path| {
        path
          .file_name()
          .unwrap()
          .to_string_lossy()
          .starts_with("request-")
          && path
            .extension()
            .is_some_and(|extension| extension == "json")
      })
      .map(|path| serde_json::from_slice(&fs::read(path).unwrap()).unwrap())
      .collect();
    requests.sort_by_key(|request| request["ordinal"].as_u64().unwrap());
    assert_eq!(
      requests.len(),
      2,
      "a timed-out observation must never be replayed"
    );
    assert_eq!(
      requests[1]["wait_timeout_ms"], 10,
      "remaining turn time stays authoritative"
    );
    assert_ne!(requests[0]["request_id"], requests[1]["request_id"]);
  }

  #[test]
  fn mailbox_validates_deadline_before_filesystem_or_provider_work() {
    let (_temp, mailbox, mut config) = fixture();
    for wait in [
      Duration::ZERO,
      Duration::from_nanos(1),
      MAX_WAIT + Duration::from_millis(1),
    ] {
      assert!(
        CompletionMailbox::configure(
          Some(Path::new("nonexistent")),
          &mailbox.workspace,
          &config,
          Some(wait),
        )
        .unwrap_err()
        .contains("1..300000")
      );
    }
    config.limits.max_completion_checks_per_turn = None;
    assert!(
      CompletionMailbox::configure(None, Path::new("nonexistent"), &config, Some(MAX_WAIT),)
        .unwrap_err()
        .contains("requires a caller mailbox")
    );
    assert!(
      CompletionMailbox::configure(None, Path::new("nonexistent"), &config, None,)
        .unwrap()
        .is_none()
    );
  }

  #[test]
  fn mailbox_requires_configured_private_absolute_directory() {
    let (_temp, mailbox, mut config) = fixture();
    assert!(CompletionMailbox::configure(None, &mailbox.workspace, &config, None).is_err());
    assert!(
      CompletionMailbox::configure(
        Some(Path::new("relative")),
        &mailbox.workspace,
        &config,
        None
      )
      .is_err()
    );
    assert!(
      CompletionMailbox::configure(Some(&mailbox.workspace), &mailbox.workspace, &config, None)
        .is_err()
    );
    let nested = mailbox.workspace.join("nested");
    fs::create_dir(&nested).unwrap();
    assert!(
      CompletionMailbox::configure(Some(&nested), &mailbox.workspace, &config, None).is_err()
    );
    for kind in ["read", "write", "search"] {
      config.tools.allow_read_outside = kind == "read";
      config.tools.allow_write_outside = kind == "write";
      config.tools.allow_search_outside = kind == "search";
      assert!(
        CompletionMailbox::configure(Some(&mailbox.directory), &mailbox.workspace, &config, None)
          .is_err()
      );
    }
    config.limits.max_completion_checks_per_turn = None;
    assert!(
      CompletionMailbox::configure(Some(&mailbox.directory), &mailbox.workspace, &config, None)
        .is_err()
    );
    assert!(
      CompletionMailbox::configure(None, Path::new("nonexistent"), &config, None)
        .unwrap()
        .is_none()
    );
  }
}

#[derive(Serialize)]
struct Request<'a> {
  version: u32,
  request_id: &'a str,
  process_id: u32,
  ordinal: u32,
  workspace: &'a Path,
  wait_timeout_ms: u64,
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case")]
enum ReplyStatus {
  Passed,
  Failed,
  Unavailable,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct Reply {
  version: u32,
  request_id: String,
  status: ReplyStatus,
  feedback: String,
}

impl CompletionMailbox {
  /// Validate the caller channel before any provider request. No filesystem work when disabled.
  pub(crate) fn configure(
    directory: Option<&Path>,
    workspace: &Path,
    config: &RuntimeConfig,
    wait_limit: Option<Duration>,
  ) -> Result<Option<Self>, String> {
    if wait_limit.is_some() && directory.is_none() {
      return Err("completion feedback timeout requires a caller mailbox".into());
    }
    let wait_limit = wait_limit.unwrap_or(MAX_WAIT);
    if wait_limit.as_millis() == 0 || wait_limit > MAX_WAIT {
      return Err("completion feedback timeout must be 1..300000 milliseconds".into());
    }
    match (config.limits.max_completion_checks_per_turn, directory) {
      (None, None) => return Ok(None),
      (None, Some(_)) => {
        return Err(
          "--completion-feedback-dir requires limits.max_completion_checks_per_turn".into(),
        );
      }
      (Some(_), None) => {
        return Err("configured completion checks require run --completion-feedback-dir".into());
      }
      (Some(_), Some(_)) => {}
    }
    if config.tools.allow_read_outside
      || config.tools.allow_write_outside
      || config.tools.allow_search_outside
    {
      return Err(
        "completion feedback requires outside read, write and search access disabled".into(),
      );
    }
    let directory = directory.expect("composition validated");
    if !directory.is_absolute() {
      return Err("--completion-feedback-dir must be an absolute directory path".into());
    }
    let directory = fs::canonicalize(directory)
      .map_err(|error| format!("cannot resolve completion feedback directory: {error}"))?;
    let workspace = fs::canonicalize(workspace)
      .map_err(|error| format!("cannot resolve completion feedback workspace: {error}"))?;
    if !directory.is_dir() || !workspace.is_dir() || directory.starts_with(&workspace) {
      return Err("completion feedback directory must exist outside the workspace".into());
    }
    // Caller-controlled permissions and identity are the trust boundary. This is not an OS sandbox.
    Ok(Some(Self {
      directory,
      workspace,
      wait_limit,
    }))
  }

  pub(crate) fn check(
    &self,
    request: CompletionCheckRequest,
    cancel: &CancelToken,
  ) -> CompletionCheckResult {
    match self.exchange(request, cancel) {
      Ok(result) => result,
      Err(reason) => CompletionCheckResult {
        status: CompletionCheckStatus::Unavailable,
        feedback: reason,
      },
    }
  }

  fn exchange(
    &self,
    request: CompletionCheckRequest,
    cancel: &CancelToken,
  ) -> Result<CompletionCheckResult, String> {
    let wait = request
      .remaining_turn_time
      .unwrap_or(self.wait_limit)
      .min(self.wait_limit);
    if cancel.is_cancelled() || wait.is_zero() {
      return Err("completion observation cancelled before submission".into());
    }
    let deadline = Instant::now() + wait;
    let request_id = TurnId::new().to_string();
    let payload = serde_json::to_vec(&Request {
      version: 1,
      request_id: &request_id,
      process_id: std::process::id(),
      ordinal: request.ordinal,
      workspace: &self.workspace,
      wait_timeout_ms: wait.as_millis() as u64,
    })
    .map_err(|_| "cannot encode completion request".to_string())?;
    let temporary = self.directory.join(format!("request-{request_id}.tmp"));
    let published = self.directory.join(format!("request-{request_id}.json"));
    let reply_path = self.directory.join(format!("reply-{request_id}.json"));
    let mut file = OpenOptions::new()
      .write(true)
      .create_new(true)
      .open(&temporary)
      .map_err(|_| "cannot create completion request".to_string())?;
    file
      .write_all(&payload)
      .and_then(|_| file.sync_all())
      .map_err(|_| "cannot persist completion request".to_string())?;
    drop(file);
    fs::rename(&temporary, &published)
      .map_err(|_| "cannot publish completion request".to_string())?;
    loop {
      if cancel.is_cancelled() {
        return Err("completion observation cancelled".into());
      }
      if Instant::now() >= deadline {
        return Err("completion observation timed out".into());
      }
      match fs::File::open(&reply_path) {
        Ok(file) => {
          let mut bytes = Vec::new();
          file
            .take(MAX_REPLY_BYTES + 1)
            .read_to_end(&mut bytes)
            .map_err(|_| "cannot read completion reply".to_string())?;
          if bytes.len() as u64 > MAX_REPLY_BYTES {
            return Err("completion reply exceeded its byte limit".into());
          }
          let reply: Reply =
            serde_json::from_slice(&bytes).map_err(|_| "invalid completion reply".to_string())?;
          if reply.version != 1 || reply.request_id != request_id {
            return Err("completion reply version or identity mismatch".into());
          }
          if reply.feedback.len() > MAX_COMPLETION_FEEDBACK_BYTES {
            return Err("completion feedback exceeded its byte limit".into());
          }
          return Ok(CompletionCheckResult {
            status: match reply.status {
              ReplyStatus::Passed => CompletionCheckStatus::Passed,
              ReplyStatus::Failed => CompletionCheckStatus::Failed,
              ReplyStatus::Unavailable => CompletionCheckStatus::Unavailable,
            },
            feedback: reply.feedback,
          });
        }
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => {}
        Err(_) => return Err("cannot open completion reply".into()),
      }
      std::thread::sleep(
        Duration::from_millis(20).min(deadline.saturating_duration_since(Instant::now())),
      );
    }
  }
}
