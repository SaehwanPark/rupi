import contextlib
import importlib.util
import io
from pathlib import Path
import threading
from types import SimpleNamespace
import unittest
from unittest import mock


RELAY_PATH = Path(__file__).resolve().parents[1] / "case07-thinking-budget-relay.py"
SPEC = importlib.util.spec_from_file_location("thinking_budget_relay", RELAY_PATH)
relay = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(relay)


class Clock:
  def __init__(self, schedule, client, upstream):
    self.now = 0
    self.schedule = iter(schedule)
    self.peers = {"client": client, "upstream": upstream}

  def monotonic(self):
    return self.now

  def select(self, *_):
    self.now += 0.4
    signal = next(self.schedule, None)
    return ([] if signal is None else [self.peers[signal]], [], [])


class RelayDeadlineTests(unittest.TestCase):
  def forward(self, timeout, schedule, chunks=()):
    handler = object.__new__(relay.Relay)
    handler.connection = mock.Mock()
    handler.server = SimpleNamespace(response_timeout=timeout)
    handler.headers = {}
    handler.command = "POST"
    handler.path = "/v1/chat/completions"
    handler.json_response = mock.Mock()
    upstream = mock.MagicMock()
    upstream.__enter__.return_value = upstream
    upstream.recv.side_effect = chunks
    clock = Clock(schedule, handler.connection, upstream)
    with mock.patch.object(relay.socket, "create_connection", return_value=upstream) as connect:
      with mock.patch.object(relay.time, "monotonic", side_effect=clock.monotonic):
        with mock.patch.object(relay.select, "select", side_effect=clock.select):
          handler.forward(b"owned-fixture-request")
    connect.assert_called_once()
    upstream.sendall.assert_called_once()
    upstream.__exit__.assert_called_once()
    self.assertTrue(handler.close_connection)
    return handler, clock

  def test_short_deadline_closes_without_replaying_request(self):
    handler, clock = self.forward(1, [])
    self.assertLess(clock.now, 2)
    handler.json_response.assert_called_once_with(
      502, {"error": "upstream transport unavailable"}
    )
    handler.connection.sendall.assert_not_called()

  def test_longer_deadline_allows_the_delayed_response(self):
    handler, _ = self.forward(
      2, [None, None, None, "upstream", "upstream"], [b"owned-fixture-response", b""]
    )
    handler.connection.sendall.assert_called_once_with(b"owned-fixture-response")
    handler.json_response.assert_not_called()

  def test_expiry_after_partial_response_does_not_fabricate_a_second_response(self):
    handler, clock = self.forward(1, ["upstream"], [b"owned-fixture-partial"])
    self.assertLess(clock.now, 2)
    handler.connection.sendall.assert_called_once_with(b"owned-fixture-partial")
    handler.json_response.assert_not_called()

  def test_client_disconnect_closes_upstream_without_replaying(self):
    handler, _ = self.forward(1194, ["client"])
    handler.connection.sendall.assert_not_called()
    handler.json_response.assert_not_called()

  def test_health_reports_the_configured_deadline_without_content(self):
    handler = object.__new__(relay.Relay)
    handler.path = "/healthz"
    handler.server = SimpleNamespace(
      counter_lock=threading.Lock(), injected_requests=0, budget=4096, response_timeout=1194
    )
    handler.json_response = mock.Mock()
    handler.do_GET()
    status, health = handler.json_response.call_args.args
    self.assertEqual(status, 200)
    self.assertEqual(health["response_timeout_seconds"], 1194)
    self.assertEqual(health["reasoning_budget_tokens"], 4096)
    self.assertFalse(health["content_logging"])

  def test_default_deadline_preserves_the_existing_profile(self):
    server = mock.Mock()
    with mock.patch.object(relay, "QuietServer", return_value=server):
      with mock.patch("sys.argv", [str(RELAY_PATH)]):
        relay.main()
    self.assertEqual(server.response_timeout, 650)
    self.assertEqual(server.budget, 2048)
    server.serve_forever.assert_called_once()

  def test_invalid_deadline_is_rejected_before_binding(self):
    for timeout in (0, 3601):
      with self.subTest(timeout=timeout), mock.patch.object(relay, "QuietServer") as server:
        with mock.patch("sys.argv", [str(RELAY_PATH), "--response-timeout-seconds", str(timeout)]):
          with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
            relay.main()
        self.assertEqual(error.exception.code, 2)
        server.assert_not_called()


if __name__ == "__main__":
  unittest.main()
