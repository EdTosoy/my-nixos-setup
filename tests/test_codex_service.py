"""Credential-free regression checks for the opt-in service wrapper."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import sys
from types import SimpleNamespace
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("codex_service", ROOT / "scripts/codex-service.py")
service = importlib.util.module_from_spec(spec)
spec.loader.exec_module(service)


class ServiceSafetyTests(unittest.TestCase):
    def invoke(self, arguments):
        with patch.object(sys, "argv", ["codex-service", *arguments]), patch.dict(
            os.environ, {"CODEX_SERVICE_CATALOG": str(ROOT / "config/codex-services.json")}
        ), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            return service.main()

    def test_storage_override_is_rejected_before_native_tools(self):
        for arguments in [
            ["-c", 'mcp_oauth_credentials_store="file"'],
            ["--config", 'mcp_oauth_credentials_store="auto"'],
            ['--config=mcp_oauth_credentials_store="file"'],
            ['-cmcp_oauth_credentials_store="file"'],
            ["-c", "'mcp_oauth_credentials_store' = 'file'"],
        ]:
            with (
                self.subTest(arguments=arguments),
                patch.object(service.subprocess, "run") as run,
                patch.object(service.subprocess, "call") as call,
            ):
                with self.assertRaises(SystemExit) as error:
                    self.invoke(["run", "linear", "--", *arguments])
                self.assertEqual(error.exception.code, 2)
                run.assert_not_called()
                call.assert_not_called()

    def test_linear_login_is_read_only_and_keyring_only(self):
        with patch.object(service.shutil, "which", return_value="/bin/busctl"), patch.object(
            service.subprocess, "run", return_value=SimpleNamespace(returncode=0)
        ), patch.object(service.subprocess, "call", return_value=0) as call:
            self.assertEqual(self.invoke(["login", "linear"]), 0)
            command = call.call_args.args[0]
            self.assertIn('mcp_oauth_credentials_store="keyring"', command)
            self.assertEqual(command[-5:], ["mcp", "login", "dx-linear", "--scopes", "read"])
            config = next(c for c in command if c.startswith("mcp_servers.dx-linear="))
            self.assertIn('"https://mcp.linear.app/mcp/readonly"', config)
            self.assertNotIn("http_headers", config)

    def test_missing_keyring_blocks_native_login(self):
        with patch.object(service.shutil, "which", return_value=None), patch.object(
            service.subprocess, "call"
        ) as call:
            self.assertEqual(self.invoke(["login", "linear"]), 2)
            call.assert_not_called()

    def test_supabase_requires_explicit_valid_project(self):
        for arguments in [[], ["--project-ref", "invalid&other=scope"]]:
            with self.subTest(arguments=arguments), patch.object(service.subprocess, "call") as call:
                with self.assertRaises(SystemExit):
                    self.invoke(["login", "supabase", *arguments])
                call.assert_not_called()

    def test_inventory_is_isolated_and_not_a_model_query(self):
        listing = SimpleNamespace(returncode=0, stdout=json.dumps([{"name": "another-server"}]))
        with patch.object(service.shutil, "which", return_value="/bin/busctl"), patch.object(
            service.subprocess, "run", side_effect=[SimpleNamespace(returncode=0), listing]
        ), patch.object(service, "inventory", return_value=0) as inventory:
            self.assertEqual(self.invoke(["check", "linear"]), 0)
            command, name, tools = inventory.call_args.args
            self.assertIn('mcp_servers."another-server".enabled=false', command)
            self.assertIn("apps", command)
            self.assertIn("plugins", command)
            self.assertEqual(name, "dx-linear")
            self.assertIn("list_teams", tools)
            self.assertNotIn("exec", command)


if __name__ == "__main__":
    unittest.main()
