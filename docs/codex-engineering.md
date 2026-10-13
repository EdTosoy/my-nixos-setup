# Codex daily engineering boundaries

P0 baseline: Codex CLI 0.161.0. The mutable `~/.codex/config.toml` remains
owned by Codex/user configuration; Home Manager owns the existing Dunst hooks
in `home/codex.nix`. Portable instructions and the three engineering skills
remain in the private `~/dev-config` repository, discovered through existing
symlinks. No extra profile, skill, MCP server, or worktree wrapper is needed.

## Daily defaults

```toml
approval_policy = "on-request"
approvals_reviewer = "user"
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = false
```

Keep the model, effort, UI, authentication, plugins, and hook trust unchanged.
Start a fresh session to use changed defaults; an existing session or a client
override can retain different permissions. Native workspace-write also permits
temporary-directory writes by default and does not restrict reads to the project.
`on-request` allows normal sandboxed work; it is not approval for every command.

Trust individual repositories after reviewing their instructions/configuration.
Do not restore the blanket `/mnt/storage/projects` trust. Check `/permissions`
and `/hooks` in a new interactive session before sensitive work. Persistent
command allowances can bypass the sandbox: review them as executable authority,
including the current contents of package scripts and Nix expressions. P0 removes
all existing persistent `allow` rules; normal sandboxed development remains
available, and host escalation requires deliberate review.

The native rules prompt for direct Git staging/discard/publishing/history commands,
package runners, Nix, Docker/cloud/infra CLIs, GitHub CLI, and file removal when evaluated for execution
outside the sandbox. They are not a complete denylist: aliases, interpreters,
absolute executables, other tools, in-workspace writes, and external app tools
need separate judgment. Approve a specific action, not arbitrary shells or
temporary scripts. Destructive actions, cloud changes, production operations,
publishing, commits, pushes, and merges need deliberate task authorization.

## Credential and host boundaries

- AWS shared credential files have access-key fields, no session-token field,
  and mode 0600. GitHub CLI stores an OAuth token in its mode-0600 hosts file;
  Codex authentication is mode 0600. Values must never appear in logs or diffs.
- No credential environment-variable names were present in the audited process.
  That is one snapshot: shells, direnv, project dotenv files, subprocesses, and
  plugins can introduce credentials later. Do not dump the environment.
- Mode 0600 protects against other users, not agents running as this user.
  Workspace-write permits reads outside the workspace. Prefer separate,
  least-privilege development identities and short-lived AWS sessions after a
  verified replacement is approved; do not delete or rotate current credentials
  as part of P0. Project secrets and database URLs stay out of instructions.
- The user belongs to the Docker group. Host Docker access can confer root-like
  authority; a local daemon/socket and an approved host command are separate
  boundaries from sandbox network policy. Review container mounts, privileges,
  target resources, and cleanup before authorizing database integration tests.
- Existing plugin/MCP code and credentials remain intact. Shell sandbox settings
  do not grant or constrain all remote app operations. Review each external write
  and the connected account's scope. Polygraph's existing `npx ...@latest`
  startup is an unpinned dependency; pinning/replacing it is deferred.
- `tfaa` and `tfda` are removed from the Home Manager source. Existing shells
  retain old aliases until an independently authorized activation and new shell.
  Use reviewed Terraform plans and explicit authorization for apply/destroy.

## Verification and rollback

The project-local gate documents are `flow/docs/verification-gates.md`,
`hospitalProject/docs/verification-gates.md`, and
`shotback/.docs/verification-gates.md`. Follow the existing `verify-changes`
skill: report PASS, FAIL, SKIPPED, and NOT RUN with evidence and scope. An
integration or browser check without its real runtime is NOT RUN, not a pass.

Validate changed TOML and rules with the installed CLI, confirm resolved session
permissions, check native skill/hook discovery, and run harmless sandbox write
and network probes. Never test permissions by running a destructive command.
Check the Dunst bus and both existing hook events with non-sensitive payloads.
Do not change socket permissions or disable sandboxes to make tests pass.

P0 keeps private pre-change copies under `/tmp/codex-p0-jc1kt7mo` (mode 0700).
For rollback, compare current files against those copies and reverse only the
P0 hunks; do not overwrite later user edits. Nix source changes can be reversed
independently before activation. No system activation is included in P0.

Supported settings and rule semantics were checked against installed help and
the official [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference),
[rules documentation](https://learn.chatgpt.com/docs/agent-configuration/rules), and
[security documentation](https://learn.chatgpt.com/docs/agent-approvals-security).
