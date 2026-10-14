# P2 activation and workflow evidence

Tested on 2026-10-14 with installed Codex CLI 0.162.1. No new dependency, skill,
or MCP declaration was introduced; existing declarations were realized and
activated. This agent ran no CLI upgrade, commit, push, or external publication.

## Activated configuration

The integrated Home Manager generation and complete NixOS system built
successfully. Activation dry-runs found no conflicting user files. The user
activated the reviewed system using:

```sh
sudo nixos-rebuild switch --flake path:/home/edtosoy/nixos-setup#nixos-btw
```

The activated system is
`/nix/store/q4an9p55pyghcs656d3hakg37mqfnq9x-nixos-system-nixos-btw-26.05.20260924.c508844`.
`home-manager-edtosoy.service` reports success. Helpers, catalog, and tmux
configuration resolve into Home Manager store files. The new skills retain
their mutable dev-config source ownership.

The ordinary `nrs` Git flake failed while the helper files were untracked.
The reviewed `path:` form included them without staging or committing anything.
`home.nix` now uses `cleanSource` for Neovim: its actual configuration contents
match the previous generation while the incidental Git pointer is excluded.

Fresh-shell checks confirm `tfaa` and `tfda` are absent and all three Codex
commands resolve. GNOME Keyring is active with `Transient=no` and its managed
unit path. Existing Dunst hooks are trusted/enabled and accepted synthetic Stop
and PermissionRequest events. The live config, rules, and hook contents match
the P2 baseline. Native thread creation still resolves to on-request,
workspace-write, network off, gpt-6.1-sol, high reasoning.

## Browser boundary and real workflow

The exact current network-off failure is Chromium Crashpad `setsockopt` returning
EPERM followed by SIGTRAP. The earlier broad namespace diagnosis was insufficient.
After explicit authorization, native `command/exec` passed Chromium launch,
the visual loop, and all 19 Shotback extension tests with **workspace-write
retained and network enabled for that command only**. An outside-workspace write
probe was denied with EROFS. No saved network setting or command allowance changed.
Chromium's own sandbox stayed enabled; no browser download was needed.

The network grant permits remote requests too; it is not a loopback firewall.
Use trusted local scenarios and test data. The interactive TUI's network-only
approval interaction is NOT RUN: its fine-grained permission features are under
development and disabled. Review the actual client grant; do not silently enable
beta features or unrestricted access. The tested native execution boundary is
distinct from proof of that UI interaction.

When the CLI cannot offer a suitable one-command grant, the user can explicitly
start a dedicated browser-verification session without changing saved defaults:

```sh
codex -C /mnt/storage/projects/shotback --sandbox workspace-write \
  --ask-for-approval on-request -c sandbox_workspace_write.network_access=true
```

Use it only for the reviewed local browser check and exit afterward. Its native
configuration/thread policy was verified; the complete interactive agent turn
is NOT RUN. Network access applies to that session and permits remote egress.
Normal `codex` and tmux G/W continue to use the saved network-off default.

No justified low-risk product defect was found in the inspected UI. The
demonstration therefore changed no application code:

1. `trace-source` followed the existing custom Select keyboard commit/focus path
   and verified General Feedback's wrapping label.
2. `visual-iterate` rendered the built editor at 390×844 and 1440×900, entered
   synthetic feedback, exercised focus/Tab/menu selection, and inspected actual
   screenshots. Runtime counts and measured horizontal overflow were zero.
3. `verify-changes` ran Shotback's native static/unit/build and real extension
   checks, including capture, annotations, redactions, exports, shares, and
   keyboard behavior.
4. `prepare-pr` produced scoped local drafts with evidence and limitations.

The source and browser probes found a custom combobox, so the scenario uses its
real keyboard behavior. The first static probe started the native server in the
configuration repository and could not write Shotback's Vite cache. Starting the
server in Shotback fixed the context; no permission setting changed.

## Security repair and service access

`fix-bug` reproduced the service wrapper accepting a forwarded OAuth storage
override after its forced keyring setting, using a fake CLI without credentials.
The wrapper now rejects storage overrides before invoking native tools. Five
stdlib tests cover override forms, Linear's read scope/keyring requirement,
missing-keyring refusal, required Supabase project selection, and isolated
inventory checks. All seven catalog configurations parsed with native Codex.

Linear public discovery confirmed the readonly resource, read scope, trusted
HTTPS issuer/endpoints, and S256 support. Matching native Codex source delegates
callback/state/issuer validation and credential storage to its OAuth client;
keyring mode refuses file fallback. The user authorized login interactively:

```sh
codex-service login linear
codex-service check linear
codex-service run linear -- "Read the relevant issue; do not modify it."
```

The authenticated inventory exposed the four allowed read tools. A native
`mcpServer/tool/call` request to `list_teams` with limit 1 succeeded and returned
one record; only its count was printed. These probes used zero additional CLI
model turns. No resource or issue was created or edited.

Only the new default vault's non-secret 16-byte header was examined. It matches
GNOME Keyring 50.0's encrypted binary format, and the file has owner-only 0600
permissions. Credential contents were neither printed nor copied.

Activation restarted the daemon and locked the encrypted vault. The first
post-activation checks timed out pending interactive unlock. The user retried
`codex-service check linear`, which passed; the subsequent native limit-1 team
read also passed. Authentication survived activation. Unlock the GNOME dialog
and retry when this recurs; do not use plaintext storage to avoid the unlock step.
If the managed service is inactive, `systemctl --user start gnome-keyring.service`
starts it. A new graphical login's automatic startup is NOT RUN in this phase.

Revoke provider access through Linear Settings → Security & Access → Authorized
applications. To remove only this local connection's credential interactively:

```sh
codex -c 'mcp_servers.dx-linear={url="https://mcp.linear.app/mcp/readonly"}' \
  -c 'mcp_oauth_credentials_store="keyring"' mcp logout dx-linear
```

## Executed checks and evidence

Private evidence: `/tmp/codex-p2-9jntcvll` (directory 0700). Inspect artifacts
before any separately authorized upload; screenshots/traces can contain data.

| Check | Result and boundary |
| --- | --- |
| Home Manager/system build and dry-run | PASS; actual system subsequently activated by user |
| Fresh shell, effective Codex policy, six-skill discovery | PASS; zero discovery errors |
| Dunst hooks | PASS; synthetic notifications recorded; hook contents unchanged |
| tmux G/W | PASS dispatch from activated configuration with a stub: correct cwd and native arguments; no model invocation |
| Git worktrees | Native managed checkout retained and separate Git index verified. An additional clean managed checkout is present at `~/.codex/worktrees/6d06/shotback`; left intact. No parallel product implementation was performed. |
| `python3 -m unittest discover -s tests -p test_codex_service.py -v` | PASS: five credential-free safety tests |
| `npm run check` in Shotback's normal workspace sandbox | PASS: types, lint, 308 units, build/content-script gate |
| `npm run test:e2e -- --output <private-dir>` with system Chromium | PASS: all 19 tests, repeated under narrower command network grant |
| `codex-browser` with P2 interaction flow | PASS: both viewports, actual images inspected; activated immutable entrypoint also passed |
| Controlled console/page/assertion failures | PASS detection: exit 1 and retained screenshots/valid traces; console/page injection repeated using activated entrypoint and narrower sandbox |
| Linear inventory and limit-1 team read | PASS before and after activation/unlock; no account contents printed |
| Cloudflare public docs inventory | PASS; account authentication not attempted |
| Hosted CI, deployment, complete accessibility certification | NOT RUN; outside this phase's executed evidence |

Flow, hospitalProject, and Shotback tracked diffs and pre-existing untracked
files matched their P2 baselines. Screenshots show synthetic data. No application
architecture, database, financial core, or production state was changed by this
task. The configuration repository's Git base changed outside this agent's
commands; original pending contents were reconstructed from the baseline patch
and compared successfully. Its current history and staging were left intact.

## Other service actions

| Service | Retained status / next action |
| --- | --- |
| GitHub | Existing authenticated gh retained; previous read checks passed. No new connection needed. |
| Vercel | Configured, awaiting consent: `codex-service login vercel`, then `check vercel`. Review provider scope; client read tools alone do not restrict the underlying token. |
| Cloudflare | Public docs inventory tested; optional account: `codex-service login cloudflare`, then `check cloudflare`. Only schema search is exposed. |
| Render | Configured, awaiting consent: `codex-service login render`, then `check render`; workspace selection may require interaction. |
| Convex | Deferred: no adopting project and the inspected official CLI uses plaintext token configuration. No new login or dependency. |
| Supabase | Configured, awaiting project-scoped consent: `codex-service login supabase --project-ref DEV_PROJECT_REF`; use matching ref for check/run. |
| Neon | Configured, awaiting consent: `codex-service login neon`, then `check neon`; readonly metadata categories retained. |
| AWS | Existing CLI authentication retained; no new keys or IAM changes. Use an existing scoped short-lived/SSO profile when available. |

Official context: [Codex native approvals](https://learn.chatgpt.com/docs/app-server),
[Linear read-only MCP](https://linear.app/docs/mcp),
[Linear revocation](https://linear.app/docs/security-and-access), and
[GNOME Keyring 50.0 storage selection](https://github.com/GNOME/gnome-keyring/blob/50.0/pkcs11/secret-store/gkm-secret-collection.c).
