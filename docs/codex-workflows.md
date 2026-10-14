# Codex engineering workflows: implemented capabilities

The [P2 activation and validation record](codex-p2-validation.md) contains the
current runtime status, corrected browser boundary, and Linear connection
evidence. The implementation-stage activation/authentication limitations below
are historical; consult P2 before repeating setup.

These changes extend P 0/P 1. No application logic, financial core, database,
deployment, publishing, or Git history was changed. Existing project tracked
diffs, Terraform source changes, command rules, and Dunst hook contents were
verified against the task baseline. The saved policy still resolves to
`on-request`, `workspace-write`, network off, and `gpt-6.1-sol` with high effort.
Persistent config/auth bytes changed across interrupted sessions; this task did
not rewrite/reset those files or restore an outdated snapshot.

The initial native demonstrations used CLI 0.161.0. The environment subsequently
reported CLI 0.162.1; no upgrade/reinstallation was performed by this task. Final
configuration, skill discovery, MCP inventory, and policy checks used 0.162.1.

## Implemented files and ownership

| Location | Change |
| --- | --- |
| `home/codex.nix` | Home Manager declarations for new commands, service catalog, three mutable dev-config skill links, secrets-only GNOME Keyring, and its password prompt activation file. Existing Dunst code retained. |
| `scripts/codex-browser.mjs` | Uses the importing package's Playwright and existing Chromium; fresh contexts, screenshots, traces, runtime counts, flow assertions, sanitized failure stages. No browser downloads or sandbox-disabling flags. |
| `scripts/codex-service.py` | Opt-in native HTTP MCP configuration, keyring-only OAuth, provider/tool scoping, native connectivity inventory without a model turn. No credential handling or persistent Codex config rewrite. |
| `config/codex-services.json` | Public official endpoints, narrow tool lists, and example read requests. No tokens or headers. |
| `tmux/tmux.conf` | Prefix `G`: Codex in current directory; prefix `W`: native Codex worktree session. Existing prefix `C` retained. New keys installed in the current server. |
| `~/dev-config/skills/visual-iterate/` | Design-reference → render → inspect → refine workflow and a lazy browser-evidence reference. |
| `~/dev-config/skills/trace-source/` | Source/version-grounded control-flow investigation, explanations, and optional Mermaid. |
| `~/dev-config/skills/prepare-pr/` | Scoped review, private screenshot evidence, and local PR title/body preparation. |
| `~/dev-config/skills/implement-feature/` | Lazy vertical-slice and isolated-parallel-work references. |
| `~/dev-config/skills/verify-changes/references/browser-verification.md` | Routes visual work to the new capability while retaining project integration tests as the journey authority. |

New command/catalog/skill links are live and backed by their source repositories.
Home Manager owns their durable declarations. GNOME Keyring was realized from
the pinned Nix derivation using binary-cache-only building:2.0 MiB fetched. A
secrets-only transient user unit is active; its password prompt is registered.
Vault creation/unlock and actual encrypted OAuth credential storage require
interactive use and are **NOT RUN**. Normal Home Manager activation will make
the service persistent. The old Terraform auto-approve aliases remain in the
generated `.bashrc`; their already-correct source still needs activation.

## Daily use

**New application or full-stack slice:**

> Use $implement-feature. Establish the smallest useful vertical slice and
> acceptance criteria. Identify the consequential architecture decision and
> recommend alternatives before implementing it. Verify the real UI/API/data
> path; add only the infrastructure required by that behavior.

**Visual frontend iteration:** start services with repository-native commands,
use synthetic/test data, provide a reference image and concrete visual criteria,
then request `$visual-iterate`. Native CLI image input is available:

```bash
codex -i reference.png
codex-browser --project "$PWD" --url http://127.0.0.1:3000
codex-browser --project /mnt/storage/projects/shotback \
  --extension /mnt/storage/projects/shotback/dist --page editor.html
```

`--project` selects the importing package, not necessarily the repository root.
For hospitalProject use `apps/frontend`. Use `--flow scenario.mjs` for reproducible
interactions/assertions; see the visual skill reference. The helper does not start
services or seed data. Inspect actual screenshots; a successful capture proves
neither visual acceptance nor accessibility. Unexpected console, page, and HTTP
failures fail the command, including failures in popups and during capture.
Expected HTTP classification does not silently excuse console errors.

The daily Codex sandbox rejected Chromium namespace setup in the executed probe.
Ask for approval of the specific browser/test command through normal CLI
approvals. Preserve network isolation and both sandboxes. The successful browser
checks below used this session's broader tool execution permissions with
Chromium's sandbox enabled. Browser operation inside the normal daily sandbox
has **NOT RUN** successfully; no bypass rule was added.

**Debugging:**

> Use $fix-bug. Reproduce this scenario before editing. Trace the request/job
> through the relevant layers and compare hypotheses against runtime evidence.
> Repair the cause, add relevant regression coverage, and use $verify-changes.

Existing skills already cover contracts, authorization, transactions, concurrency,
migrations, retries, failures, and real integrations where relevant. No duplicate
backend/debugging skill or distributed infrastructure was added.

**Parallel engineering:**

```bash
codex --worktree
git worktree list
ts /absolute/worktree/path
```

New worktrees omit uncommitted changes and ignored dependencies/secrets. Assign
owned files, ports, test databases, and Compose project names before concurrent
runtime work. Subagents sharing a checkout also share files. Use parallelism for
independent investigation/review or bounded implementation with an integration
point. Inspect status/processes before normal, unforced cleanup. The 0.161.0 CLI
rejected `--worktree --ephemeral`; check current help after upgrades.

**Source investigation and learning:**

> Use $trace-source. Trace this caller to its observable outcome. Resolve the
> dependency from this workspace, record its actual version, explain the key
> invariant with source links, and distinguish static facts from runtime proof.

**Review and PR preparation:**

```bash
codex review --help
codex review --uncommitted
gh issue view NUMBER
gh pr checks NUMBER
gh run view RUN_ID
```

Use native review only when its full diff scope matches the task; otherwise scope
an independent review. `$prepare-pr` produces local title/body/evidence artifacts.
Avoid dumping unfiltered CI logs that may contain secrets. Publishing screenshots,
PRs, commits, pushes, merges, and deployments need specific authorization.

**Deployment preparation:** prepare the existing project's build, migration,
rollback, and health-check procedure locally. Select a provider based on actual
requirements. An authenticated account grants no permission to deploy or provision.
No deployment-specific skill was needed for this task.

## Service connections and exact next actions

`codex-service` creates per-invocation config overrides; these integrations do not
start in every Codex session and do not add dependencies to projects.

```bash
codex-service list
codex-service inspect linear
codex-service login linear
codex-service check linear
codex-service run linear -- "List accessible teams only; do not change anything."
```

Login uses native browser OAuth and forces keyring storage without file fallback.
Unlock/create an encrypted keyring through its password prompt; never supply a
password/token to chat. Linear requests only `read`. Review provider consent and
choose the relevant development account/project and smallest available scope.
If consent requires broader access than the intended read operation, cancel it
rather than granting that access merely to finish setup.
`check` verifies transport/tool inventory without model usage and disables other
MCP servers/apps/plugins for that check. It explicitly does not claim a business
API operation passed. `run` retains normal Codex capabilities and policies;
the selected server has a narrow tool list with prompt approvals. This is not a
complete security boundary for all other tools or same-user credentials.

| Service | Implemented route and local status | Authentication / executed verification | User action and enabled use |
| --- | --- | --- | --- |
| GitHub | Existing `gh`; no duplicate MCP installed | Existing session; identity and project run listing **PASS** | No new login needed. Read issues/diffs/CI and prepare local PRs. Existing broad scopes and credential storage unchanged. |
| Linear | Opt-in official read-only HTTP endpoint, `read` OAuth scope | Config loads; OAuth/API query **NOT RUN** | `codex-service login linear`, then `check linear`, then read teams/issues. |
| Vercel | Opt-in official HTTP MCP; project/deployment read tools | Config loads; OAuth/API query **NOT RUN** | `codex-service login vercel`, then `check vercel`; investigate project/deployment metadata. |
| Cloudflare | Public docs MCP plus optional account MCP exposing only schema `search` | Native docs inventory and actual public docs search **PASS**; account OAuth **NOT RUN** | `codex-service run cloudflare-docs`; `login cloudflare` for optional schema search. Account API execution is deliberately absent. |
| Render | Opt-in official HTTP MCP; service metadata tools | Config loads; OAuth/API query **NOT RUN** | `codex-service login render`, then `check render`. Workspace selection may need separate interaction; no deploy tools exposed. |
| Convex | Official project-local CLI/MCP investigated; no CLI/dependency installed | No adopting project found; login/runtime **NOT RUN** | Current official CLI writes its access token into JSON configuration. That conflicts with the requested storage boundary. Choose a secure authentication approach when a project adopts it; no login/token plumbing or global latest-package download added. |
| Supabase | Official HTTP MCP with `read_only=true`, required project reference, database/docs tools | Config loads; OAuth/API query **NOT RUN** | `codex-service login supabase --project-ref YOUR_DEV_PROJECT_REF`, then matching `check`; inspect schema/migration metadata. No SQL/migration write tool exposed. |
| Neon | Official HTTP MCP with `readonly=true`, metadata categories/tools | Config loads; OAuth/API query **NOT RUN** | `codex-service login neon`, then `check neon`. Choose one development project and leave writes disabled in consent. Connection-string and SQL tools absent. |
| AWS | Existing AWS CLI; no new MCP or IAM keys | Existing identity request **PASS**; infrastructure operations **NOT RUN** | Prefer an existing read-only short-lived profile. If IAM Identity Center is available: `aws configure sso --profile codex-readonly`, `aws sso login --profile codex-readonly`, then STS identity. `aws login` is also supported by the installed CLI, but inherits the chosen principal's permissions. No credential migration performed. |

For Vercel, Render, and other providers, client tool allowlists are not proof the
underlying OAuth token is least privilege. Account consent/scopes and actual
service responses remain unverified until the user authorizes them. Supabase
references are public project identifiers, never database passwords. Existing
Codex/GitHub/AWS credential state was retained rather than silently migrated.

To make Home Manager changes durable, review the source and activate with the
usual NixOS/Home Manager procedure. New source files must be included in the
flake; ordinary Git flakes omit untracked files. A reviewed `path:` flake includes
them. Full system activation was **NOT RUN**, so existing shells may retain the
Terraform aliases and the new keyring service is currently transient.

## Executed demonstrations and verification

| Exercise/check | Evidence and result | Limit |
| --- | --- | --- |
| Shotback visual loop | Built extension rendered at 390×844 and 1440×900; screenshots/traces; focus, Tab movement, feedback input assertions; zero unexpected runtime errors and horizontal overflow **PASS**. Images inspected directly and by a native CLI image-input review. | Empty editor state only; no full accessibility or visual-regression claim. |
| Browser evidence defects | Independent review reproduced false passes for popup errors and late errors, and raw-error/evidence loss for throwing classifiers. Repairs retained failure artifacts and returned exit 1. Async classifier and closed-page trace probes also **PASS** as expected failures. | Synthetic failure fixtures test the helper, not application business behavior. |
| Source exploration | Shotback capture control flow and installed React DOM 18.3.1 traced; Mermaid explanation;42 scoped capture helper unit tests **PASS**. | Static cleanup-scope observations were not claimed as reproduced product defects. |
| Worktree/parallel workflow | Native isolated source investigation **PASS**. Clean checkout lacked uncommitted P 1 changes. Separate Git worktree file/index test, normal cleanup, isolated tmux cwd/key test **PASS**. | Native managed demonstration checkout retained for review; no branch integration/merge performed. |
| GitHub workflow | Flow run listing:0 runs. hospitalProject and Shotback:3 older completed successful runs each; read-only API access **PASS**. | P 1 workflows remain uncommitted/unpublished; these old runs do not verify P 1 hosted CI. |
| Skills/configuration | Six bundled skill validations; current CLI discovery enabled with no errors; strict native config/policy loading **PASS**. | Discovery/structural validation alone does not prove every future workflow. |
| Nix/keyring | Module parsing and six new Home Manager file declarations evaluated; pinned package realized; Secret Service active; password prompt activatable **PASS**. | Full activation, encrypted credential write/read, and OAuth logins **NOT RUN**. |
| Browser portability | Existing Playwright 1.63.0 in Flow,1.56.1 in hospital frontend,1.61.1 in Shotback launched real system Chromium and captured fixture screenshots/traces **PASS**. | These compatibility fixtures do not verify Flow financial journeys or hospital roles. |
| Daily sandbox browser | Native command probe reached launch and returned a namespace/sandbox restriction **FAIL**; journey **NOT RUN**. | No sandbox weakening or bypass rule added. |
| Model-backed follow-up | Native CLI later reported its usage limit; further model-backed probes stopped. | No comparative quality/speed/model-cost benchmark completed. |

Evidence is private under `/tmp/codex-dx-implementation-fkxxdeqg`,
`/tmp/codex-helper-review-hcj04x_m`, and `/tmp/codex-source-pr-_dckkkz5`.
Temporary evidence is not durable project documentation. Inspect traces/images
for sensitive data before any authorized publication. Full P 1 suites were not
rerun merely to accumulate evidence.

The initial hospitalProject-root compatibility invocation failed with
`MODULE_NOT_FOUND`; selecting its actual `apps/frontend` importing package passed.
The browser helper also initially depended on `which`, which was unavailable in
the native command environment. Direct executable discovery fixed that friction;
the remaining daily-policy launch failure is a separate namespace restriction.
Final Shotback evidence recorded system Chromium 153.0.8010.52.

## Workshop notes coverage

| Original idea | Outcome |
| --- | --- |
| Visualization skills | Source-backed Mermaid supported and exercised by `trace-source`; no diagram server/package added. |
| Git worktrees | Native CLI, Git isolation/cleanup, and tmux navigation exercised. |
| Linear | Read-only OAuth connection prepared; awaiting authorization. |
| Vercel | Read-only tool connection prepared; awaiting authorization. |
| Cloudflare | Public documentation connection/search verified; optional account schema connection prepared. |
| Render | Read-only metadata connection prepared; awaiting authorization. |
| Convex | Conditional project-local adoption; current CLI credential persistence conflicts with the storage constraint, and no current project uses it. |
| Supabase | Scoped, read-only connection prepared; awaiting project selection/OAuth. |
| Neon | Read-only metadata connection prepared; awaiting scoped OAuth. |
| GitHub | Existing authentication and real CI metadata reads exercised; local PR workflow added. |
| Web application building | Existing implementation skill extended with lazy vertical-slice guidance; no unrelated application generated. |
| Builder workflows | Merged with `implement-feature`, avoiding a redundant full-stack builder skill/framework. |
| Moodboards | Included in visual direction selection; new generated moodboard **NOT RUN** without a product/design request. |
| Debugging workflows | Existing skill preserved; actual browser-helper defects reproduced, repaired, and reverified. |
| Practical Codex use cases | Source tracing, visual review, runtime diagnostics, Git isolation, and CI inspection demonstrated. |
| Screenshot-backed PRs | Private screenshot evidence and local PR preparation capability added; publication **NOT RUN**. |
| Reading source code | Dedicated narrow skill plus real application/dependency investigation. |
| AGENTS.md | Existing global ownership/content retained; no expanding global rule set. |
| Living frontends | Future use of visual/state/interaction workflow; no speculative framework created. |
| Interactive frontends | Real keyboard/form interactions verified; animation-specific behavior deferred to a real project. |
| Skill creator | Used for scoped skills, bundled validation, independent helper review, and forward exercises. |

## Stop here; next useful work

1. Complete one relevant OAuth login, then inventory and one explicit read-only
   request. Repeat for another provider only when a project needs it.
2. Activate reviewed Home Manager changes, including Terraform alias removal.
3. Use the visual workflow on one real UI change with the necessary specific
   approval, and verify the complete project journey. Hosted P 1 CI still needs
   authorized publication and execution.

The supported model catalog includes `gpt-6.1-sol`, `gpt-6-luna`, and
`gpt-6-astra`. Medium effort can be selected per invocation for bounded work;
high/xhigh for difficult engineering only when useful. The default is unchanged.
The isolated Luna investigation used 134,203 aggregate input tokens,97,024 cached,
and 1,404 output tokens; a smaller model did not imply negligible workflow usage.
Do not add default parallelism, model profiles, another browser stack, deployment
skills, or more MCP servers until real repeated friction justifies them.

## Source material

Public course pages and companion source/README materials were inspected; full
lesson transcripts were not supplied or claimed as read. The frontend repository
demonstrates deterministic local data and reference/iteration/brownfield prompts;
the full-stack repository demonstrates vertical slices and runtime/concurrency
investigation. These informed workflow choices rather than dependency copying.
[Frontend companion](https://github.com/katia-openai/master-dev-workshop),
[full-stack companion](https://github.com/schneidenbach/master-dot-dev-codex-course-live).

Native configuration, OAuth, tool restrictions, and skills were checked against
installed output and [official Codex MCP documentation](https://learn.chatgpt.com/docs/extend/mcp?surface=cli).
Provider endpoints/scoping were checked against
[Linear](https://linear.app/docs/mcp),
[Vercel](https://vercel.com/docs/agent-resources/vercel-mcp),
[Cloudflare](https://developers.cloudflare.com/agents/model-context-protocol/cloudflare/servers-for-cloudflare/),
[Render](https://render.com/docs/mcp-server),
[Supabase](https://supabase.com/docs/guides/ai-tools/mcp),
[Neon's official source](https://github.com/neondatabase/mcp-server-neon),
[Convex](https://docs.convex.dev/cli/reference/mcp), and
[AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sign-in.html).
Neon's documentation page was inaccessible, so its official repository was used.
Convex credential persistence was verified in its official
[login implementation](https://github.com/get-convex/convex-backend/blob/main/npm-packages/convex/src/cli/lib/login.ts)
and [configuration writer](https://github.com/get-convex/convex-backend/blob/main/npm-packages/convex/src/cli/lib/utils/globalConfig.ts).
