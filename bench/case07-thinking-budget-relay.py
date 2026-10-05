"""Local Case 07 transport experiment; never log model request or response content."""

import argparse
import json
import select
import socket
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class QuietServer(ThreadingHTTPServer):
  def handle_error(self, *_):
    # Tracebacks could expose transport data; the benchmark records client failures.
    pass


class Relay(BaseHTTPRequestHandler):
  protocol_version = "HTTP/1.1"

  def log_message(self, *_):
    pass

  def json_response(self, status, value):
    body = json.dumps(value, separators=(",", ":")).encode()
    self.send_response(status)
    self.send_header("Content-Type", "application/json")
    self.send_header("Content-Length", str(len(body)))
    self.send_header("Connection", "close")
    self.end_headers()
    self.wfile.write(body)
    self.close_connection = True

  def do_GET(self):
    if self.path == "/healthz":
      with self.server.counter_lock:
        requests = self.server.injected_requests
      self.json_response(200, {
        "reasoning_budget_tokens": self.server.budget,
        "response_timeout_seconds": self.server.response_timeout,
        "upstream": "http://127.0.0.1:8000/v1",
        "injected_requests": requests,
        "content_logging": False,
      })
    elif self.path == "/v1/models":
      self.forward(b"")
    else:
      self.json_response(404, {"error": "unsupported relay route"})

  def do_POST(self):
    if self.path != "/v1/chat/completions":
      self.json_response(404, {"error": "unsupported relay route"})
      return
    try:
      if self.headers.get("Transfer-Encoding"):
        raise ValueError("chunked requests are unsupported")
      length = int(self.headers.get("Content-Length", "0"))
      if not 0 < length <= 32 * 1024 * 1024:
        raise ValueError("invalid request length")
      self.connection.settimeout(10)
      raw = self.rfile.read(length)
      if len(raw) != length:
        raise ValueError("incomplete request")
      value = json.loads(raw)
      if not isinstance(value, dict) or value.get("model") != "qwen3.8-flash-next":
        raise ValueError("unexpected model request")
      if value.get("reasoning_effort") != "low":
        raise ValueError("the budget experiment requires low effort")
      for field in ("reasoning_budget_tokens", "thinking_budget_tokens"):
        if field in value and value[field] != self.server.budget:
          raise ValueError("conflicting budget")
      value["reasoning_budget_tokens"] = self.server.budget
      body = json.dumps(value, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    except (ValueError, OSError):
      self.json_response(400, {"error": "invalid budget experiment request"})
      return
    self.forward(body, injected=True)

  def forward(self, body, injected=False):
    self.close_connection = True
    self.connection.settimeout(10)
    response_started = False
    try:
      # One upstream request only: a disconnect is never retried or replayed.
      with socket.create_connection(("127.0.0.1", 8000), timeout=10) as upstream:
        headers = [f"{self.command} {self.path} HTTP/1.1", "Host: 127.0.0.1:8000"]
        excluded = {"host", "content-length", "connection", "transfer-encoding",
          "proxy-connection", "expect", "keep-alive", "upgrade", "te", "trailer"}
        for name, value in self.headers.items():
          if name.lower() not in excluded:
            headers.append(f"{name}: {value}")
        headers.extend([f"Content-Length: {len(body)}", "Connection: close", "", ""])
        upstream.sendall("\r\n".join(headers).encode("latin-1") + body)
        if injected:
          with self.server.counter_lock:
            self.server.injected_requests += 1
        deadline = time.monotonic() + self.server.response_timeout
        while time.monotonic() < deadline:
          ready, _, _ = select.select([self.connection, upstream], [], [], 1)
          if self.connection in ready:
            # Close upstream too; leave generation cancellation to the server.
            return
          if upstream in ready:
            chunk = upstream.recv(65536)
            if not chunk:
              return
            response_started = True
            self.connection.sendall(chunk)
        raise TimeoutError("relay response deadline")
    except OSError:
      if not response_started:
        try:
          self.json_response(502, {"error": "upstream transport unavailable"})
        except OSError:
          pass


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--port", type=int, default=8001)
  parser.add_argument("--budget", type=int, default=2048)
  parser.add_argument("--response-timeout-seconds", type=int, default=650)
  args = parser.parse_args()
  if not 1 <= args.port <= 65535 or args.port == 8000 or args.budget < 1:
    parser.error("use a positive budget and a distinct valid loopback port")
  if not 1 <= args.response_timeout_seconds <= 3600:
    parser.error("response timeout must be between 1 and 3600 seconds")
  server = QuietServer(("127.0.0.1", args.port), Relay)
  server.daemon_threads = True
  server.budget = args.budget
  server.response_timeout = args.response_timeout_seconds
  server.injected_requests = 0
  server.counter_lock = threading.Lock()
  server.serve_forever()


if __name__ == "__main__":
  main()
