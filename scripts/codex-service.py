#!/usr/bin/env python3
"""Opt-in native Codex MCP connections. Public configuration only; no token handling."""
import argparse
import json
import os
from pathlib import Path
import re
import queue
import shutil
import subprocess
import sys
import threading
import time
from urllib.parse import urlencode


def inventory(command, name, allowed_tools):
    """Let native Codex handle OAuth; inspect metadata without a model turn."""
    process = subprocess.Popen(command + ['app-server', '--strict-config', '--stdio'],
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                               stderr=subprocess.DEVNULL, text=True)
    replies = queue.Queue()

    def read():
        for line in process.stdout:
            try:
                replies.put(json.loads(line))
            except ValueError:
                continue

    threading.Thread(target=read, daemon=True).start()

    def rpc(identifier, method, params):
        process.stdin.write(json.dumps({'id': identifier, 'method': method, 'params': params}) + '\n')
        process.stdin.flush()
        deadline = time.monotonic() + 25
        while time.monotonic() < deadline:
            reply = replies.get(timeout=max(0.1, deadline-time.monotonic()))
            if reply.get('id') == identifier:
                if 'error' in reply:
                    raise ValueError('Native MCP inventory request failed')
                return reply['result']
        raise TimeoutError('Native MCP inventory timed out')

    try:
        rpc(1, 'initialize', {'clientInfo': {'name': 'codex_service_check', 'version': '1'}})
        process.stdin.write('{"method":"initialized"}\n')
        process.stdin.flush()
        result = rpc(2, 'mcpServerStatus/list', {'serverName': name, 'detail': 'toolsAndAuthOnly'})
        server = next((s for s in result.get('data', []) if s.get('name') == name), {})
        tools = sorted(set(server.get('tools', {})) & set(allowed_tools))
        passed = bool(tools) and not server.get('toolsError')
        print(json.dumps({'name': name, 'connectivity': 'PASS' if passed else 'NOT RUN',
                          'auth_status': server.get('authStatus', 'unknown'), 'available_allowed_tools': tools,
                          'service_operation': 'NOT RUN: inventory verifies connection and tools, not an account query',
                          'model_turns': 0}, indent=2))
        return 0 if passed else 2
    except (OSError, ValueError, queue.Empty, TimeoutError):
        print('NOT RUN: native MCP inventory did not complete; no model turn was used.', file=sys.stderr)
        return 2
    finally:
        process.terminate()
        try:
            process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['list', 'inspect', 'login', 'run', 'check'])
    parser.add_argument('service', nargs='?')
    parser.add_argument('--project-ref', help='Supabase development project identifier, never a secret')
    args, codex_args = parser.parse_known_args()
    if codex_args and codex_args[0] == '--':
        codex_args = codex_args[1:]
    if args.action != 'run' and codex_args:
        parser.error('only run accepts extra Codex arguments after --')
    # Keep the wrapper's no-plaintext contract even when forwarding CLI options.
    for index, argument in enumerate(codex_args):
        override = None
        if argument in ('-c', '--config') and index + 1 < len(codex_args):
            override = codex_args[index + 1]
        elif argument.startswith('--config='):
            override = argument[len('--config='):]
        elif argument.startswith('-c') and argument != '-c':
            override = argument[2:]
        if override and override.partition('=')[0].strip().strip('\"\'') == 'mcp_oauth_credentials_store':
            parser.error('OAuth storage is fixed to keyring; omit the conflicting configuration override')
    args.codex_args = codex_args
    catalog_path = Path(os.environ.get('CODEX_SERVICE_CATALOG', str(Path.home()/'.config/codex/services.json')))
    catalog = json.loads(catalog_path.read_text())
    if args.action == 'list':
        if args.service or args.codex_args:
            parser.error('list does not take a service or Codex arguments')
        for name, entry in catalog.items():
            print(f"{name}: {'OAuth/keyring required' if entry['oauth'] else 'public documentation'}; opt-in; {len(entry['tools'])} allowed tools")
        print('GitHub: existing gh CLI/connected app. AWS: existing aws CLI/short-lived profile. Convex: awaiting an adopting project and a secure authentication-storage design.')
        return 0
    if args.service not in catalog:
        parser.error('choose a service from: ' + ', '.join(catalog))
    entry = catalog[args.service]
    url = entry['url']
    if entry.get('project_required'):
        if not args.project_ref or not re.fullmatch(r'[a-z0-9-]{5,64}', args.project_ref):
            parser.error('Supabase requires --project-ref for a specific development project')
        url += '&' + urlencode({'project_ref': args.project_ref})
    name = 'dx-' + args.service
    # JSON strings/arrays are valid TOML values. Build only public fields; never headers or tokens.
    fields = {'url': url, 'enabled': True, 'required': True, 'startup_timeout_sec': 20,
              'enabled_tools': entry['tools'], 'default_tools_approval_mode': 'prompt'}
    value = '{' + ','.join(k + '=' + json.dumps(v) for k, v in fields.items()) + '}'
    command = ['codex', '-c', f'mcp_servers.{name}={value}', '-c', 'mcp_oauth_credentials_store="keyring"',
               '-c', 'mcp_optional_startup_grace_ms=0']
    if args.action == 'inspect':
        if args.codex_args:
            parser.error('inspect does not take Codex arguments')
        result = subprocess.run(command + ['mcp', 'get', name, '--json'], capture_output=True, text=True)
        if result.returncode:
            print('Codex could not load this connection configuration.', file=sys.stderr)
            return result.returncode
        actual = json.loads(result.stdout)
        print(json.dumps({'name': actual['name'], 'url': actual['transport']['url'], 'allowed_tools': actual['enabled_tools'],
                          'configured': True, 'authentication': 'not tested', 'persistent_config_changed': False,
                          'example_read_request': entry['probe']}, indent=2))
        return 0
    if entry['oauth']:
        if not shutil.which('busctl'):
            print('OAuth blocked: Secret Service keyring detection needs busctl. No file fallback is permitted.', file=sys.stderr)
            return 2
        service = subprocess.run(['busctl', '--user', 'status', 'org.freedesktop.secrets'], capture_output=True)
        if service.returncode:
            print('OAuth blocked: unlock/start your Secret Service keyring, then retry. Codex is forced to keyring storage; no plaintext fallback.', file=sys.stderr)
            return 2
    if args.action == 'login':
        if args.codex_args:
            parser.error('login does not take Codex arguments')
        if not entry['oauth']:
            print('This public documentation connection needs no authentication.')
            return 0
        command += ['mcp', 'login', name]
        if entry.get('scopes'):
            command += ['--scopes', ','.join(entry['scopes'])]
    elif args.action == 'check':
        if args.codex_args:
            parser.error('check does not take Codex arguments')
        # Discover the effective server names, including project entries. Keep all
        # other MCP servers, apps, and plugins out of this connectivity check.
        listing = subprocess.run(['codex', '--disable', 'apps', '--disable', 'plugins',
                                  'mcp', 'list', '--json'], capture_output=True, text=True)
        if listing.returncode:
            print('Could not isolate the connection check; no agent started.', file=sys.stderr)
            return 2
        command += ['--disable', 'apps', '--disable', 'plugins']
        for server in json.loads(listing.stdout):
            if server['name'] != name:
                command += ['-c', 'mcp_servers.' + json.dumps(server['name']) + '.enabled=false']
        return inventory(command, name, entry['tools'])
    else:
        extra = args.codex_args
        if extra and extra[0] == '--':
            extra = extra[1:]
        # The wrapper scopes MCP, not the rest of Codex. Caller retains the normal CLI and policies.
        command += extra
    return subprocess.call(command)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError):
        print('Service setup failed: check the public catalog, installed Codex, and arguments. No credentials were read by this helper.', file=sys.stderr)
        sys.exit(1)
