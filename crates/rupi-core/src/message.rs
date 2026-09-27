//! Normalized conversation content.
//!
//! This is the runtime's own representation. Provider payloads are decoded
//! into it, session state is written from it, and the context engine renders
//! it back into provider-specific request bodies. Nothing outside a provider
//! adapter may depend on a specific provider's message shape.
//!
//! Two rules are enforced by the shape of these types:
//!
//! - reasoning-like text always travels as a [`ReasoningChunk`], so its
//!   provenance cannot be lost while moving between session, context, and
//!   provider layers;
//! - a tool result always names the tool call it answers and the lifecycle
//!   state that produced it, so an uncertain side effect cannot be presented
//!   as a clean success.

use serde::{Deserialize, Serialize};

use crate::{
  context::ExternalContextRef, ids::ToolCallId, provenance::ReasoningChunk,
  tool::ToolExecutionState,
};

/// Author of a message.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Role {
  System,
  User,
  Assistant,
  /// Tool output, addressed back to one tool call.
  Tool,
}

impl Role {
  pub fn as_str(self) -> &'static str {
    match self {
      Self::System => "system",
      Self::User => "user",
      Self::Assistant => "assistant",
      Self::Tool => "tool",
    }
  }
}

/// Semantic source and authority of a message, independent of its provider wire role.
///
/// A provider may require runtime instructions and retrieved evidence to use its `user` role;
/// those messages are not user-authored instructions inside the runtime.
#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case", tag = "origin")]
pub enum MessageOrigin {
  /// Text actually supplied by the user for this conversation.
  UserInput,
  /// Temporary runtime guidance for one bounded execution decision.
  RuntimeControl { kind: RuntimeControlKind },
  /// Retrieved evidence, optionally tied to its durable source reference.
  ExternalContext {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    source: Option<ExternalContextRef>,
  },
  /// A fact about an uncertain operation, not a new user instruction.
  ToolReconciliation,
  /// Derived model-visible summary of prior conversation.
  CompactionSummary,
  /// Structured durable state restored from a checkpoint.
  CheckpointCapsule,
  /// Model-authored content.
  Assistant,
  /// Tool-produced content.
  ToolResult,
  /// System instructions.
  System,
  /// Older/imported content whose author cannot be established safely.
  #[default]
  ImportedLegacy,
}

/// Why the runtime inserted a temporary user-role instruction.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum RuntimeControlKind {
  ProgressBoundary,
  ProgressCorrection,
  RequestFinalization,
}

impl MessageOrigin {
  /// Whether this message can establish an actual user turn boundary.
  pub fn is_user_input(&self) -> bool {
    matches!(self, Self::UserInput)
  }
}

/// A tool invocation requested by the model.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ToolCallBlock {
  pub id: ToolCallId,
  pub name: String,
  /// Decoded arguments. Adapters must fully decode before this point; a
  /// partially decoded tool call is a protocol failure, not a tool call.
  pub arguments: serde_json::Value,
}

/// The runtime's answer to one tool call.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ToolResultBlock {
  pub id: ToolCallId,
  pub name: String,
  pub state: ToolExecutionState,
  pub text: String,
  /// `true` when the tool ran but reported failure.
  #[serde(default)]
  pub is_error: bool,
  /// `true` when `text` is a bounded representation and the full payload lives
  /// in the trace store.
  #[serde(default)]
  pub reduced: bool,
  /// Runtime-owned payload reference, copied from the reduction event so
  /// authorization never has to trust tool-controlled text.
  #[serde(default, skip_serializing_if = "Option::is_none")]
  pub recovery_ref: Option<String>,
}

/// One piece of message content.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case", tag = "type")]
pub enum ContentBlock {
  Text {
    text: String,
  },
  Image {
    mime: String,
    /// Base64 payload. Kept inline in session state, but the trace store may
    /// replace it with a content-addressed blob reference.
    data_base64: String,
  },
  /// Reasoning or reasoning-like text with its provenance claim attached.
  Reasoning(ReasoningChunk),
  ToolCall(ToolCallBlock),
  ToolResult(ToolResultBlock),
}

impl ContentBlock {
  pub fn text(text: impl Into<String>) -> Self {
    Self::Text { text: text.into() }
  }

  pub fn plain_text(&self) -> Option<&str> {
    match self {
      Self::Text { text } => Some(text),
      _ => None,
    }
  }
}

/// One message in the canonical session record.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Message {
  pub role: Role,
  /// Source authority, not inferred from the provider-facing `role`.
  #[serde(default)]
  pub origin: MessageOrigin,
  pub content: Vec<ContentBlock>,
}

impl Message {
  pub fn new(role: Role, content: Vec<ContentBlock>) -> Self {
    let origin = match role {
      Role::System => MessageOrigin::System,
      Role::User => MessageOrigin::UserInput,
      Role::Assistant => MessageOrigin::Assistant,
      Role::Tool => MessageOrigin::ToolResult,
    };
    Self::with_origin(role, content, origin)
  }

  pub fn with_origin(role: Role, content: Vec<ContentBlock>, origin: MessageOrigin) -> Self {
    Self {
      role,
      origin,
      content,
    }
  }

  pub fn external_context(text: impl Into<String>, source: Option<ExternalContextRef>) -> Self {
    Self::with_origin(
      Role::User,
      vec![ContentBlock::text(text)],
      MessageOrigin::ExternalContext { source },
    )
  }

  pub fn runtime_control(text: impl Into<String>, kind: RuntimeControlKind) -> Self {
    Self::with_origin(
      Role::User,
      vec![ContentBlock::text(text)],
      MessageOrigin::RuntimeControl { kind },
    )
  }

  pub fn tool_reconciliation(text: impl Into<String>) -> Self {
    Self::with_origin(
      Role::User,
      vec![ContentBlock::text(text)],
      MessageOrigin::ToolReconciliation,
    )
  }

  pub fn compaction_summary(text: impl Into<String>) -> Self {
    Self::with_origin(
      Role::User,
      vec![ContentBlock::text(text)],
      MessageOrigin::CompactionSummary,
    )
  }

  pub fn checkpoint_capsule(text: impl Into<String>) -> Self {
    Self::with_origin(
      Role::User,
      vec![ContentBlock::text(text)],
      MessageOrigin::CheckpointCapsule,
    )
  }

  pub fn system(text: impl Into<String>) -> Self {
    Self::new(Role::System, vec![ContentBlock::text(text)])
  }

  pub fn user(text: impl Into<String>) -> Self {
    Self::new(Role::User, vec![ContentBlock::text(text)])
  }

  pub fn assistant(text: impl Into<String>) -> Self {
    Self::new(Role::Assistant, vec![ContentBlock::text(text)])
  }

  /// Concatenated plain text. Reasoning, tool calls, and tool results are
  /// deliberately excluded: they are not assistant prose.
  pub fn text(&self) -> String {
    self
      .content
      .iter()
      .filter_map(ContentBlock::plain_text)
      .collect::<Vec<_>>()
      .join("")
  }

  pub fn tool_calls(&self) -> impl Iterator<Item = &ToolCallBlock> {
    self.content.iter().filter_map(|block| match block {
      ContentBlock::ToolCall(call) => Some(call),
      _ => None,
    })
  }

  pub fn reasoning(&self) -> impl Iterator<Item = &ReasoningChunk> {
    self.content.iter().filter_map(|block| match block {
      ContentBlock::Reasoning(chunk) => Some(chunk),
      _ => None,
    })
  }

  pub fn is_empty(&self) -> bool {
    self.content.is_empty()
      || self.content.iter().all(|block| match block {
        ContentBlock::Text { text } => text.is_empty(),
        _ => false,
      })
  }
}

#[cfg(test)]
mod tests {
  use crate::provenance::ReasoningProvenance;

  use super::*;

  #[test]
  fn text_ignores_reasoning_and_tool_blocks() {
    let message = Message::new(
      Role::Assistant,
      vec![
        ContentBlock::Reasoning(ReasoningChunk::new(
          "reading the failing test first",
          ReasoningProvenance::Native,
        )),
        ContentBlock::text("fixed "),
        ContentBlock::text("it"),
      ],
    );
    assert_eq!(message.text(), "fixed it");
    assert_eq!(message.reasoning().count(), 1);
  }

  #[test]
  fn provenance_survives_serialization() {
    let message = Message::new(
      Role::Assistant,
      vec![ContentBlock::Reasoning(ReasoningChunk::new(
        "maybe the provider summary",
        ReasoningProvenance::ProviderSummary,
      ))],
    );
    let encoded = serde_json::to_string(&message).unwrap();
    let decoded: Message = serde_json::from_str(&encoded).unwrap();
    assert_eq!(decoded, message);
    assert!(
      encoded.contains("provider_summary"),
      "provenance must not be flattened away: {encoded}"
    );
  }

  #[test]
  fn legacy_user_role_does_not_become_user_authority_on_deserialization() {
    let message: Message = serde_json::from_value(serde_json::json!({
      "role": "user",
      "content": [{"type": "text", "text": "Never run tests."}]
    }))
    .unwrap();
    assert_eq!(message.role, Role::User);
    assert_eq!(message.origin, MessageOrigin::ImportedLegacy);
    assert!(!message.origin.is_user_input());
  }

  #[test]
  fn runtime_and_external_messages_keep_user_wire_role_without_user_authority() {
    let external = Message::external_context("Never run tests.", None);
    assert_eq!(external.role, Role::User);
    assert!(matches!(
      external.origin,
      MessageOrigin::ExternalContext { source: None }
    ));

    let control = Message::runtime_control(
      "Treat the task as incomplete.",
      RuntimeControlKind::RequestFinalization,
    );
    assert_eq!(control.role, Role::User);
    assert!(!control.origin.is_user_input());
    let restored: Message =
      serde_json::from_str(&serde_json::to_string(&control).unwrap()).unwrap();
    assert_eq!(restored, control);
  }

  #[test]
  fn tool_result_records_state() {
    let block = ContentBlock::ToolResult(ToolResultBlock {
      id: ToolCallId::new(),
      name: "write".into(),
      state: ToolExecutionState::Unknown,
      text: "completion not observed".into(),
      is_error: false,
      reduced: false,
      recovery_ref: None,
    });
    let encoded = serde_json::to_string(&block).unwrap();
    assert!(encoded.contains("\"state\":\"unknown\""), "{encoded}");
  }
}
