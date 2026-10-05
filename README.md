# NixOS workstation: nixos-btw

A real single-user, single-workstation configuration for `edtosoy` on
`nixos-btw`, an `x86_64-linux` NixOS machine with Sway and Home Manager.
The objective is a simple, reproducible, understandable and recoverable system
without pretending that every byte of the workstation belongs in Nix.

This is a public reference, with machine-specific choices you must review before
using it elsewhere. It uses NixOS 26.05, Home Manager release-26.05 and locked
stable/unstable Nixpkgs inputs. The desktop includes LightDM, Sway/XWayland,
PipeWire, NetworkManager and native application configurations.

**Keyboard:** Sway uses the repository's custom `real-prog-dvorak` layout;
LightDM/X11 uses US Dvorak. Keep a familiar layout available during installation
and recovery.

## Design principles

- Give each concern an obvious owner and keep changes near that owner.
- Projects choose their framework and dependency versions.
- Keep application behavior in native configuration when it is clearer there.
- Allow writable runtime state deliberately: caches, sessions and authentication
  have different lifecycles from reviewed configuration.
- Keep secrets and private provisioning outside public Git and Nix expressions.
- Add abstraction when a real requirement needs it.

## Repository map

```text
flake.nix                  # locked inputs and the single system output
flake.lock                 # exact Nix input revisions
configuration.nix          # machine policy, services, account and storage mount
hardware-configuration.nix # this machine's devices and hardware detection
home.nix                   # user packages, identity and native-config deployment
home/                      # shell integration and desktop appearance
nvim/                      # native Lua config and reviewed plugin snapshot (submodule)
sway/                      # compositor behavior and wallpapers
tmux/                      # terminal multiplexer behavior
qutebrowser/               # browser behavior, userscripts and styles
rofi/                      # native launcher behavior and desktop-entry integration
scripts/                   # small user tools deployed by Home Manager
docs/                      # private provisioning and storage recovery contract
real-prog-dvorak            # custom XKB symbols registered by NixOS
```

`flake.nix` assembles `configuration.nix` and Home Manager's NixOS module.
`configuration.nix` imports the hardware file; `home.nix` imports `home/` and
Rofi's integration module. A service change belongs in the system configuration,
a package/deployment change in Home Manager, and a keybinding or plugin behavior
change in the application's native files.

## Ownership model

| Owner | Responsibility |
| --- | --- |
| NixOS | Boot, hardware, mounts, account creation, machine services and system policy |
| Home Manager | User packages, shell integration, desktop preferences and deployment of native configuration |
| Native application configuration | Application-specific behavior, including Neovim's Lua/LSP setup and Lazy plugin management |
| Projects | Frameworks, dependencies, lockfiles and project-local commands |
| Git | Configuration, locked Nix inputs, the Neovim submodule revision and reviewed editor state |
| Mutable runtime state | Downloaded plugins/parsers, caches, history, sessions, authentication and deliberately unmanaged settings |
| Private provisioning | Password-hash file, correct filesystem identities, directory permissions and service credentials |

Home Manager runs within the system rebuild; there is no separate
`home-manager switch` step. It deploys native files through Nix-store links.
Editing this checkout requires a rebuild and activation before deployed files
change; applications may then need a reload or restart. Operational files that
must remain writable are kept outside those deployed files.

### Why there is no hosts hierarchy

There is one actual workstation. A `hosts/`, profiles or roles hierarchy would
add indirection without solving current duplication. A second real machine or
genuine shared policy is the trigger to revisit that choice.

## Development-tool boundary

The workstation supplies editors, language servers, compilers, runtimes and
useful CLI fallbacks. They support the workstation; they do not choose a project's
framework version. Use each project's declared dependencies and package-manager
scripts/local commands. Direnv with nix-direnv is available for project environments.

There are no global Angular/latest or Prisma-version-selecting shell wrappers.
The `nx` convenience alias delegates to `pnpm nx`; projects must declare the
appropriate dependency. An installed framework CLI is a fallback, not a reason
to bypass the project's lockfile or select a new version during ordinary work.

## Neovim reproducibility

Neovim stays native: Home Manager supplies the editor and tools, Lua config owns
editor/LSP behavior, and Lazy owns plugins. Git records a reviewed plugin lock
snapshot and an immutable Lazy bootstrap revision. First startup seeds a writable
operational lock only when it is absent; normal startup preserves intentional
local lock changes. Downloads and compiled parsers remain disposable local state.

See [Neovim ownership and recovery](nvim/README.md) for restore commands,
intentional updates, and parser/toolchain limitations. Do not use plugin updates
as recovery operations.

## Private provisioning and storage

**Configuration recovery is not data backup.**

No login password or password hash belongs in this repository. The private hash
is provisioned at `/etc/nixos/secrets/edtosoy-password-hash` before installation or
activation. Authentication, project contents, downloads and personal application
data require separate provisioning or recovery.

NixOS mounts the optional ext4 disk at `/mnt/storage` with `nofail`. A missing
data disk should allow a usable recovery environment. The filesystem contents,
ownership and manual `~/storage`, `~/projects` and `~/Downloads` links are external
provisioning concerns. Verify the expected filesystem is mounted before writing
through those paths; otherwise data can land on the root filesystem and become
hidden when the disk mounts.

Read [the provisioning contract](docs/provisioning.md) for hardware UUIDs,
guarded link creation and the known top-level projects ownership prerequisite.

### Private password provisioning

`users.users.edtosoy.hashedPasswordFile` is an absolute string path. The hash is
read during activation, not imported into Git or the Nix store. Builds do not
require its contents; installation/activation requires a non-empty file.

Provision the directory as root:root mode `0700` and the file as root:root mode
`0600`, containing exactly one salted hash followed by a newline. On installation
media, after mounting the target root at `/mnt`, the destination is
`/mnt/etc/nixos/secrets/edtosoy-password-hash`. With `mkpasswd` available, the
following intentionally creates private state and refuses an existing file:

```bash
sudo install -d -o root -g root -m 0700 /mnt/etc/nixos/secrets
sudo sh -c 'umask 077; set -C; mkpasswd -m sha-512 > /mnt/etc/nixos/secrets/edtosoy-password-hash'
```

Enter the password interactively. Verify the resulting file's type, permissions
and one non-empty hash line without displaying it. Stop if generation fails;
do not overwrite an existing credential blindly. On an existing installation,
provision under `/etc/nixos/secrets` instead. The ignored legacy `secrets.nix` is
not imported and must never be force-added.

Older Git history contains literal login-password settings. Treat those historical
credentials as exposed and never reuse them; see the
[provisioning contract](docs/provisioning.md#recovery-boundaries). Removing values
from the current tree does not erase Git history.

`users.mutableUsers = true` preserves an existing account's password. The private
file provisions a new account; changing it does not reset an existing password.
`passwd` changes do not update the provisioning file automatically.

## Installation and adaptation

This checkout assumes this user's name/home, UEFI/systemd-boot, Intel hardware,
filesystem UUIDs, keyboard layout and storage arrangement. Adapt those choices
before installation on another machine:

1. Clone the parent and recorded submodule. Recovery should use a reviewed parent
   commit, not whichever branch happens to be newest.

   ```bash
   git clone --recurse-submodules https://github.com/EdTosoy/my-nixos-setup.git ~/nixos-setup
   cd ~/nixos-setup
   ```

2. Review or generate a candidate hardware configuration for the target machine.
   Verify root, EFI/boot, swap and optional storage identities. Do not blindly
   reuse this workstation's UUIDs. Follow [hardware adaptation](docs/provisioning.md#adapt-hardware-before-installation).
3. Review `edtosoy`, `/home/edtosoy`, hostname, Git identity, groups and private hash
   paths wherever referenced. Keep these consistent with the intended account.
   Preserve state versions (`25.11` system, `26.05` home) during ordinary upgrades;
   they are compatibility settings, not release labels.
4. Provision the private password file. Review optional storage and existing
   home paths before using the guarded provisioning instructions.
5. Review the diff and build without activation or lock updates. From the checkout:

   ```bash
   git status --short
   git -C nvim status --short
   nix build --no-link --no-update-lock-file --no-write-lock-file \
     '.?submodules=1#nixosConfigurations.nixos-btw.config.home-manager.users.edtosoy.home.activationPackage'
   nix build --no-link --no-update-lock-file --no-write-lock-file \
     '.?submodules=1#nixosConfigurations.nixos-btw.config.system.build.toplevel'
   ```

   Keep `?submodules=1`: Neovim's files are deployed by Home Manager. A Git-backed
   flake sees newly added files only after they are staged; review explicit paths
   before staging and never stage secret material.
6. On an existing target NixOS installation, activate only after reviewing a
   successful build and provisioning prerequisites:

   ```bash
   sudo nixos-rebuild switch --flake '.?submodules=1#nixos-btw' --no-update-lock-file --no-write-lock-file
   ```

   This changes the running system and boot default. `test` also activates;
   `boot` changes the next boot. The `nrs` alias activates immediately and does
   not add the lockfile-protection flags above.

A build is not an empty-disk installation. From installation media, identify and
mount the target filesystems, adapt the checkout and provision the target hash
before following the [NixOS installation procedure](https://nixos.org/manual/nixos/stable/#sec-installation)
with this flake's `nixos-btw` output. Do not run `switch` against the live USB as a
substitute for installation. No partitioning, formatting or data migration is
performed by this repository.

## Update workflow

Nix input updates are intentional and separate from rebuilding:

```bash
nix flake update
git diff -- flake.lock
```

Review the changed inputs, run both builds above, then review activation
separately. Release upgrades also change input refs in `flake.nix`; do not bump
state versions merely to match a release. The separately locked unstable input
supplies Zoom and Angular's language server.

Update project dependencies inside their projects. Update Neovim plugins through
the [review/test/snapshot workflow](nvim/README.md#intentional-updates), then record
the new submodule revision in the parent. Mutable applications and external
services retain their own authentication/session lifecycle where deliberately
chosen; rebuilding does not reset that state.

## Recovery model and evidence

Git plus the locked inputs recover system/user configuration and reviewed editor
plugin revisions. They do not recover passwords, service credentials, project
contents, downloads or mutable application data. Required source revisions and
build dependencies must remain available; a lockfile is not an archive of them.

Non-activating Home Manager and full NixOS builds verify the configured system
closures. An isolated Neovim recovery test has installed all 26 recorded plugin
revisions from empty data and checked the writable lock, startup and representative
LSP configuration. Angular command/root behavior was checked with a temporary
fixture, not a real-project server handshake. Parser binaries are not byte-identical
recovery artifacts; the recorded Python grammar definition uses an upstream tag.

An anonymous HTTPS checkout test verified submodule initialization with the
reviewed HTTPS metadata. Final public recovery requires the exact referenced
Neovim commit to be published before its parent and a fresh anonymous recursive
clone of that final parent revision. A full replacement-machine installation and
user-data disaster recovery have not been demonstrated.

For configuration recovery, record the reviewed parent commit and its submodule
revision, restore that checkout, run `git submodule update --init --recursive`
without `--remote`, verify private prerequisites and mounts, then build before
activation. A clone cannot restore uncommitted work.

On this UEFI machine, hold **Space** at boot to open systemd-boot's generation
menu. An available known-good generation can restore system configuration.
`sudo nixos-rebuild switch --rollback` activates the previous system-profile
generation and changes the boot default; it does not roll back user data or
password changes. If recovery needs installation media, verify mounts before
using `nixos-enter --root /mnt` against an intact installed system.

Weekly GC deletes generations older than seven days. The `nix-clean` alias deletes
old generations immediately; a 20-entry boot menu limit does not guarantee their
closures survive. Preserve an intentional known-good generation/closure when
needed, and avoid cleanup during recovery.

## Tradeoffs and triggers for change

- A second real machine or duplicated shared policy: reconsider host abstraction.
- Many private secrets with lifecycle/distribution needs: reconsider secret-management tooling.
- Repeated native/Nix integration problems: reconsider that application's ownership boundary.
- Storage becoming boot-critical: reconsider the optional mount and `nofail`.

The current boundaries solve this workstation's requirements. Change them when
evidence creates a requirement, rather than adding a framework in anticipation.
