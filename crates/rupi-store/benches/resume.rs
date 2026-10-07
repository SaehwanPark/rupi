//! Full canonical resume plus restore, as performed before CLI turn admission.
//! SessionLog-only measurements omit blob verification and assistant-call recovery.

use std::{env, fs, process::ExitCode, time::Instant};

use rupi_core::{ContentBlock, ToolEffectDisposition, ToolExecutionState};
use rupi_store::TempDir;

#[path = "../tests/common/mod.rs"]
mod common;

const BUDGET_MS: f64 = 500.0;

fn main() -> ExitCode {
  let args: Vec<_> = env::args().skip(1).collect();
  if args.iter().any(|arg| arg == "--help" || arg == "-h") {
    println!("Usage: resume [--iterations <N>] [--json <path>]");
    return ExitCode::SUCCESS;
  }
  let value = |flag| {
    args
      .windows(2)
      .find(|pair| pair[0] == flag)
      .map(|pair| &pair[1])
  };
  let iterations = value("--iterations")
    .and_then(|text| text.parse::<usize>().ok())
    .filter(|count| *count > 0)
    .unwrap_or(5);
  let temp = TempDir::new("owned-canonical-resume-bench");
  let (store, id) = common::tool_history(temp.path(), 400, 48, true);
  let mut resume_samples = Vec::with_capacity(iterations);
  let mut restore_samples = Vec::with_capacity(iterations);
  let mut total_samples = Vec::with_capacity(iterations);
  for _ in 0..iterations {
    let start = Instant::now();
    let resumed = store.resume(&id).expect("resume canonical session");
    let resume_ms = start.elapsed().as_secs_f64() * 1_000.0;
    let restore_start = Instant::now();
    let restored = store.restore(&id).expect("restore CLI continuation state");
    let restore_ms = restore_start.elapsed().as_secs_f64() * 1_000.0;
    assert!(restored.interrupted_tools.is_empty());
    assert!(restored.unresolved_side_effects.is_empty());
    assert_eq!(restored.messages.len(), 49);
    assert_eq!(restored.messages[0].message.tool_calls().count(), 48);
    for message in &restored.messages[1..] {
      assert!(matches!(message.message.content.as_slice(),
        [ContentBlock::ToolResult(result)]
          if result.state == ToolExecutionState::Failed
            && result.effect == ToolEffectDisposition::None));
    }
    drop(resumed);
    resume_samples.push(resume_ms);
    restore_samples.push(restore_ms);
    total_samples.push(resume_ms + restore_ms);
  }
  let median = |samples: &mut [f64]| {
    samples.sort_by(f64::total_cmp);
    let mid = samples.len() / 2;
    if samples.len() % 2 == 0 {
      (samples[mid - 1] + samples[mid]) / 2.0
    } else {
      samples[mid]
    }
  };
  let resume_ms = median(&mut resume_samples);
  let restore_ms = median(&mut restore_samples);
  let total_ms = median(&mut total_samples);
  println!("canonical_resume_400_fragments_48_calls:");
  println!("  resume {resume_ms:.3} ms, restore {restore_ms:.3} ms, total {total_ms:.3} ms");
  println!("  budget {BUDGET_MS:.0} ms");
  if let Some(path) = value("--json") {
    let result = serde_json::json!({
      "iterations": iterations,
      "cases": {"canonical_resume_400_fragments_48_calls": {
        "resume_median_ms": resume_ms, "restore_median_ms": restore_ms,
        "total_median_ms": total_ms, "budget_ms": BUDGET_MS,
        "reasoning_fragments": 400, "tool_calls": 48, "restored_messages": 49,
      }},
    });
    if let Err(error) = fs::write(path, serde_json::to_vec_pretty(&result).unwrap()) {
      eprintln!("could not write results: {error}");
      return ExitCode::FAILURE;
    }
  }
  if total_ms <= BUDGET_MS {
    ExitCode::SUCCESS
  } else {
    eprintln!("canonical resume latency budget exceeded");
    ExitCode::FAILURE
  }
}
