//! Normalization of MCP tools into the internal rupi tool abstraction.

use std::sync::Arc;

use rupi_core::{
  Tool, ToolChunk, ToolError, ToolExecutionContext, ToolMetadata, ToolOutcome, ToolProgress,
  ToolRequest,
};
use serde_json::Value;

use crate::{client::McpClient, protocol::McpToolDefinition};

/// Formats the canonical tool name for an MCP tool to prevent collisions.
pub fn mcp_namespaced_tool_name(server_name: &str, tool_name: &str) -> String {
  format!("mcp__{server_name}__{tool_name}")
}

/// An MCP tool normalized into the rupi [`Tool`] trait.
#[derive(Clone)]
pub struct McpTool {
  server_name: String,
  definition: McpToolDefinition,
  client: Arc<McpClient>,
  read_only: bool,
}

impl McpTool {
  /// Create a new normalized MCP tool.
  pub fn new(
    server_name: impl Into<String>,
    definition: McpToolDefinition,
    client: Arc<McpClient>,
    read_only: bool,
  ) -> Self {
    Self {
      server_name: server_name.into(),
      definition,
      client,
      read_only,
    }
  }

  /// The server that provides this tool.
  pub fn server_name(&self) -> &str {
    &self.server_name
  }

  /// The original tool definition from the MCP server.
  pub fn definition(&self) -> &McpToolDefinition {
    &self.definition
  }
}

impl Tool for McpTool {
  fn metadata(&self) -> ToolMetadata {
    let namespaced = mcp_namespaced_tool_name(&self.server_name, &self.definition.name);
    let desc = format!(
      "[MCP:{}] {}",
      self.server_name,
      self
        .definition
        .description
        .as_deref()
        .unwrap_or("external MCP tool")
    );

    if self.read_only {
      ToolMetadata::read_only(namespaced, desc)
    } else {
      ToolMetadata::mutating(namespaced, desc, false)
    }
  }

  fn arguments_schema(&self) -> Value {
    self.definition.input_schema.clone()
  }

  fn preflight(&self, _request: &ToolRequest) -> Result<(), ToolError> {
    if self.client.tool_catalog_stale() {
      Err(ToolError::new(
        "MCP tool catalog changed; disable and re-enable the server to refresh its tool bindings",
      ))
    } else {
      Ok(())
    }
  }

  fn execute(
    &self,
    request: &ToolRequest,
    progress: &mut dyn ToolProgress,
  ) -> Result<ToolOutcome, ToolError> {
    self.execute_with_context(request, progress, &ToolExecutionContext::unbounded())
  }

  fn execute_with_context(
    &self,
    request: &ToolRequest,
    progress: &mut dyn ToolProgress,
    context: &ToolExecutionContext,
  ) -> Result<ToolOutcome, ToolError> {
    if context.is_cancelled_or_expired() {
      let message = if context.is_cancelled() {
        "MCP tool call was cancelled before dispatch"
      } else {
        "MCP tool call exceeded its deadline before dispatch"
      };
      return Ok(ToolOutcome::failed(message).with_effect(rupi_core::ToolEffectDisposition::None));
    }
    match self.client.call_tool_with_context(
      &self.definition.name,
      Some(request.arguments.clone()),
      context,
    ) {
      Ok(res) => {
        let text = res.text_content();
        if !text.is_empty() {
          progress.emit(&ToolChunk::new(&text));
        }

        if res.is_error == Some(true) {
          let outcome = ToolOutcome::failed(text);
          Ok(if self.read_only {
            outcome
          } else {
            outcome.with_effect(rupi_core::ToolEffectDisposition::Possible)
          })
        } else {
          Ok(ToolOutcome::succeeded(text).with_effect(if self.read_only {
            rupi_core::ToolEffectDisposition::None
          } else {
            rupi_core::ToolEffectDisposition::Unverified
          }))
        }
      }
      Err(crate::error::McpError::CatalogStale) => Ok(ToolOutcome::failed(
        "MCP tool catalog changed before dispatch; no remote call was made. Disable and re-enable the server to refresh bindings.",
      )
      .with_effect(rupi_core::ToolEffectDisposition::None)),
      Err(err) => {
        let err_msg = err.to_string();
        // Invariant defense: If a mutating tool's execution status is uncertain
        // due to a communication/transport failure, record as Unknown so it is never
        // blindly replayed.
        if !self.read_only {
          Ok(ToolOutcome::unknown(format!(
            "MCP communication interrupted on mutating tool: {err_msg}"
          )))
        } else {
          Ok(ToolOutcome::failed(format!(
            "MCP communication failed: {err_msg}"
          )))
        }
      }
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::transport::MockTransport;
  use rupi_core::{ReplayDecision, ToolExecutionState, ids::ToolCallId};
  use serde_json::json;

  struct ChunkCollector(Vec<String>);
  impl ToolProgress for ChunkCollector {
    fn emit(&mut self, chunk: &ToolChunk) {
      self.0.push(chunk.text.clone());
    }
  }

  #[test]
  fn test_mcp_tool_execution_success() {
    let mock = Arc::new(MockTransport::new());
    mock.on(
      "tools/call",
      json!({
        "content": [{ "type": "text", "text": "result from server" }],
        "isError": false
      }),
    );
    let client = Arc::new(McpClient::new(mock));
    let def = McpToolDefinition {
      name: "query".into(),
      description: Some("run a query".into()),
      input_schema: json!({ "type": "object" }),
    };

    let tool = McpTool::new("db", def, client, true);
    assert_eq!(tool.metadata().name, "mcp__db__query");
    assert!(tool.metadata().read_only);

    let req = ToolRequest {
      call_id: ToolCallId::new(),
      name: "mcp__db__query".into(),
      arguments: json!({ "sql": "SELECT 1" }),
    };

    let mut collector = ChunkCollector(Vec::new());
    let outcome = tool.execute(&req, &mut collector).expect("call succeeds");
    assert_eq!(outcome.state, ToolExecutionState::Succeeded);
    assert_eq!(outcome.text, "result from server");
    assert_eq!(collector.0, vec!["result from server"]);
  }

  #[test]
  fn stale_catalog_fails_before_mutating_dispatch() {
    let mock = Arc::new(MockTransport::new());
    mock.on(
      "initialize",
      json!({
        "protocolVersion": "2024-11-05",
        "capabilities": {"tools": {"listChanged": true}},
        "serverInfo": {"name": "db", "version": "1.0.0"}
      }),
    );
    let client = Arc::new(McpClient::new(mock.clone()));
    client
      .initialize()
      .expect("notification-capable client activates");
    let tool = McpTool::new(
      "db",
      McpToolDefinition {
        name: "delete_record".into(),
        description: None,
        input_schema: json!({"type":"object"}),
      },
      Arc::clone(&client),
      false,
    );
    let request = ToolRequest {
      call_id: ToolCallId::new(),
      name: "mcp__db__delete_record".into(),
      arguments: json!({"id": 7}),
    };
    mock.signal_tool_list_changed();
    assert!(tool.preflight(&request).is_err());

    let outcome = tool
      .execute(&request, &mut ChunkCollector(Vec::new()))
      .expect("stale binding becomes a terminal failed outcome");

    assert_eq!(outcome.state, ToolExecutionState::Failed);
    assert_eq!(outcome.effect, rupi_core::ToolEffectDisposition::None);
    assert!(client.tool_catalog_stale());
    assert!(
      mock
        .recorded_calls()
        .iter()
        .all(|(method, _)| method != "tools/call"),
      "stale tool binding must not dispatch to the server"
    );
  }

  #[test]
  fn mutating_tool_error_has_possible_effect() {
    let mock = Arc::new(MockTransport::new());
    mock.on(
      "tools/call",
      json!({"content":[{"type":"text","text":"partial update failed"}],"isError":true}),
    );
    let client = Arc::new(McpClient::new(mock));
    let tool = McpTool::new(
      "db",
      McpToolDefinition {
        name: "update_record".into(),
        description: None,
        input_schema: json!({"type":"object"}),
      },
      client,
      false,
    );
    let request = ToolRequest {
      call_id: ToolCallId::new(),
      name: "mcp__db__update_record".into(),
      arguments: json!({"id": 7}),
    };

    let outcome = tool
      .execute(&request, &mut ChunkCollector(Vec::new()))
      .expect("tool-level error is an observed failed result");

    assert_eq!(outcome.state, ToolExecutionState::Failed);
    assert_eq!(outcome.effect, rupi_core::ToolEffectDisposition::Possible);
  }

  #[test]
  fn test_mcp_mutating_tool_uncertainty_defense() {
    let mock = Arc::new(MockTransport::new());
    // No mock response registered -> transport returns error
    let client = Arc::new(McpClient::new(mock));
    let def = McpToolDefinition {
      name: "delete_record".into(),
      description: Some("delete records".into()),
      input_schema: json!({ "type": "object" }),
    };

    let tool = McpTool::new("db", def, client, false);
    assert!(!tool.metadata().read_only);

    let req = ToolRequest {
      call_id: ToolCallId::new(),
      name: "mcp__db__delete_record".into(),
      arguments: json!({ "id": 123 }),
    };

    let mut collector = ChunkCollector(Vec::new());
    let outcome = tool.execute(&req, &mut collector).expect("handled");
    // Must be unknown because mutation completion could not be observed!
    assert_eq!(outcome.state, ToolExecutionState::Unknown);
    assert_eq!(
      outcome
        .state
        .replay_decision_with_effect(&tool.metadata(), outcome.effect),
      ReplayDecision::ReconcileFirst
    );
  }
}
