# NixOS setup: nixos-btw

This repository configures my current `x86_64-linux` NixOS machine, `nixos-btw`, and the `edtosoy` user's Home Manager environment. It is not a template for other machines.

**Keyboard warning:** Sway uses the custom `real-prog-dvorak` layout from this repository. LightDM/X11 uses US Dvorak. Keep a familiar keyboard layout available when recovering the machine.

## Current setup

- NixOS 26.05 and Home Manager release-26.05, pinned by `flake.lock`.
- Stable Nixpkgs by default; Zoom and Angular's language server use the separately locked unstable input.
- systemd-boot on UEFI; up to 20 boot configurations are configured for display.
- LightDM with a Sway session and XWayland compatibility.
- NetworkManager, Bluetooth/Blueman, PipeWire/WirePlumber, and desktop portals.
- Bash, Kitty, Neovim, tmux, Yazi, Qutebrowser, Chromium, and Rofi.
- Dunst notifications; swayidle invokes swaylock before sleep. There are currently no idle lock or display-off timeouts.
- Docker enabled with `enableOnBoot = false` and weekly automatic pruning. The pruning timer can start the daemon and runs `docker system prune -f`, removing stopped containers and other unused resources; the configured defaults do not prune volumes. The user belongs to the Docker group and can also start Docker with `sudo systemctl start docker`.
- System state version `25.11`; Home Manager state version `26.05`. Preserve these values during upgrades and refactors.

## Structure and ownership

```text
flake.nix                  # pinned inputs, one system, Home Manager integration
flake.lock                 # exact dependency revisions
configuration.nix          # boot, storage mount, account, services, fonts, Nix settings
hardware-configuration.nix # this machine's root/EFI/swap devices and hardware
home.nix                   # identity, packages, dotfiles, environment, small programs
home/
  desktop.nix              # cursor and GTK/Qt/Dconf appearance
  shell.nix                # Bash, aliases, Prisma function, direnv
real-prog-dvorak            # custom XKB layout registered by NixOS
secrets.nix.example         # historical example; see password limitation below
nvim/                      # Neovim configuration, Git submodule
sway/                      # native Sway config and wallpapers
tmux/                     # native tmux config
qutebrowser/               # Python config, userscripts, styles
rofi/                      # config.rasi, theme.rasi, launcher visibility module
scripts/tmux-sessionizer   # installed as ~/.local/bin/tmux-sessionizer
```

`flake.nix` imports `configuration.nix`, the optional password module, and Home Manager's NixOS module. `configuration.nix` imports the hardware file. Home Manager imports `home.nix`, which imports the two `home/` modules and `rofi/rofi.nix`.

NixOS owns system services, hardware, mounts, account creation, and system fonts. Home Manager owns personal packages, shell settings, dotfiles, and desktop preferences. Home Manager runs as part of the system rebuild; there is no separate `home-manager switch` step.

Application files remain native configs. Home Manager links them through Nix-store files rather than directly to the repository. Editing the repository requires a rebuild and activation before those changes appear at their installed paths; applications may also need a reload or restart. Codex hooks are managed here, while its mutable `config.toml` remains unmanaged.

## Rebuild without updating dependencies

These commands assume an existing NixOS installation with the `edtosoy` account and a working checkout. A build alone does not install NixOS onto an empty disk. From the existing checkout:

```bash
cd ~/nixos-setup
git status --short
git -C nvim status --short
nixos-rebuild build --flake "$HOME/nixos-setup?submodules=1#nixos-btw" --no-update-lock-file --no-write-lock-file
```

`build` evaluates and builds the system, including Home Manager, without activating it or changing the boot default. It creates a `result` symlink. Keep `?submodules=1`: Neovim is a submodule and its files are used by Home Manager.

New configuration files must be added to Git before a Git-backed flake can see them. Review explicit paths before staging; never force-add `secrets.nix`. Adding files does not require committing them.

After reviewing and approving a change, activation is a separate action:

```bash
sudo nixos-rebuild switch --flake "$HOME/nixos-setup?submodules=1#nixos-btw" --no-update-lock-file --no-write-lock-file
```

The existing `nrs` alias performs `switch` with the same submodule-enabled target, but does not include the lockfile protection flags above. It activates immediately. Do not use it for build-only verification.

`nixos-rebuild test` also activates the configuration; it leaves the boot default unchanged. `boot` changes the next boot's configuration. Neither is a build-only check. See the [NixOS manual](https://nixos.org/manual/nixos/stable/#sec-changing-config).

## Dependency updates

Rebuilding uses the revisions in `flake.lock`; it is separate from updating dependencies. For an intentional update, first preserve the current configuration, lockfile, submodule revision, and a known-good system generation. Then:

```bash
cd ~/nixos-setup
nix flake update
git diff -- flake.lock
nixos-rebuild build --flake "$HOME/nixos-setup?submodules=1#nixos-btw" --no-update-lock-file --no-write-lock-file
```

This refreshes all locked inputs within their configured refs, including unstable. Review and activate separately. A release upgrade additionally changes the appropriate input refs in `flake.nix`; do not change either state version just to match the release number. Git pulls and Neovim submodule updates are separate operations and should also be reviewed.

No automatic dependency-update service or update alias is declared here. The Prisma shell function uses `nix-shell -p prisma_7`, and `ng` uses `npx @angular/cli@latest`; those commands do not explicitly resolve against this flake's lockfile.

## Storage and local state

The hardware configuration declares ext4 `/`, FAT `/boot`, and swap using device UUIDs. `configuration.nix` declares the ext4 data disk at `/mnt/storage` with `nofail`, allowing boot to continue when it is unavailable. There is no storage provisioning or data migration in this repository.

Existing manually created home links are:

```text
~/storage   -> /mnt/storage
~/Downloads -> /mnt/storage/downloads
~/projects  -> /mnt/storage/projects
```

These links, their target directories, data, and permissions are not managed by Home Manager. They must be checked and restored separately during recovery. If the storage disk is absent, the links cannot provide the expected data even though the system may boot successfully. Check mounts before using them:

```bash
findmnt --mountpoint /mnt/storage
ls -ld ~/storage ~/Downloads ~/projects
```

`findmnt --mountpoint` must show `/mnt/storage` itself and the expected data disk. If it exits unsuccessfully, stop and check the disk; an existing mountpoint directory or home symlink does not prove the disk is mounted.

The sessionizer invokes `find` on `~/projects` and `~/nixos-setup`, so it depends on that local layout. Its current command does not follow the manually created `~/projects` symlink and therefore does not search the projects target directory. This behavior is deferred for repair. Back up storage data separately; a NixOS generation is not a data backup.

Other mutable state includes account passwords, NetworkManager connection credentials, application sessions, cloud credentials, Codex settings, and Neovim plugin/parser downloads. Restoring this repository does not restore those files. Keep private backups without adding credentials to Git.

## Password provisioning limitation

`secrets.nix` contains local login-password configuration and is intentionally ignored by Git. Switching branches in the same checkout leaves this ignored file in place. A fresh clone does not contain it.

The flake imports it only when `builtins.pathExists ./secrets.nix` is true. **Normal Git-backed flake evaluation excludes untracked files, including this ignored file**, so merely copying it into the checkout does not make the normal rebuild command use it. The conditional allows the build to succeed without that module. An existing account's working password is not evidence that this module was imported. See the [Nix 2.34 flake reference](https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-flake.html).

Git ignore prevents ordinary Git staging; it does not protect secret values from entering the Nix store if imported. Do not force-add the file or switch to a whole-directory `path:` flake as a workaround. Password provisioning is deferred for separate work. The historical example also names a different user, so it is not a working recovery procedure for `edtosoy`.

For recovery today, maintain a working account/password through the base installation or reset it through a recovery environment. Keep a private backup of the local password file, but do not rely on it being applied by the documented flake rebuild.

## Restoring this machine

1. Back up the current repository including uncommitted changes, the Neovim submodule including its uncommitted changes, private credentials, and storage data. A clone restores committed content only.
2. Preserve this machine's hardware configuration. It is tracked despite its `.gitignore` entry. Do not regenerate or replace it during an ordinary restore with unchanged disks. If disks or partitions change, generate a candidate hardware file separately and review device identities before replacing anything.
3. Restore the checkout and submodule:

   ```bash
   git clone https://github.com/EdTosoy/my-nixos-setup ~/nixos-setup
   cd ~/nixos-setup
   # Replace RECORDED_CONFIGURATION_COMMIT with the reviewed recovery commit.
   git switch --detach RECORDED_CONFIGURATION_COMMIT
   git submodule update --init --recursive
   ```

   The default branch may not match the system you intend to recover. Record the parent configuration commit and ensure it and the referenced Neovim commit are available from backups or their remotes. Phase 1 is currently uncommitted: its new modules are staged, but a remote clone will not contain these changes until they are committed and published. Use a working-tree backup to recover uncommitted changes; submodule checkout does not restore local edits.

   The recorded submodule URL uses SSH (`git@github.com:EdTosoy/nvim.git`), so recursive checkout requires working GitHub SSH access. Restoring a private backup is an alternative. Do not use `--remote`: recovery should use the recorded submodule revision.

4. Confirm the root/EFI/swap devices and `/mnt/storage` disk still match the declarations. Restore the manual storage links only after checking existing files and directories; do not overwrite them blindly.
5. Ensure the `edtosoy` account has a usable password; follow the limitation above. Restore private mutable state separately.
6. Run the non-activating build command, review the result, then activate when ready. After reboot, select Sway in LightDM.

## Rollback and recovery

Before activation, record the current system and available generations:

```bash
readlink -f /run/current-system
sudo nixos-rebuild list-generations
```

For a running system that needs its previous system-profile generation:

```bash
sudo nixos-rebuild switch --rollback
```

This changes the active system and boot default. After a `test` activation, a reboot returns to the configured boot default; do not assume `--rollback` selects the system that was active just before the test. To select a particular recorded, still-present system closure, the installed rebuild tool also supports `sudo nixos-rebuild switch --store-path /nix/store/RECORDED-SYSTEM-PATH`.

If the machine cannot boot normally, hold **Space** during boot to show the systemd-boot menu and choose a known-good NixOS generation. This machine uses systemd-boot, not GRUB. See the [systemd-boot key documentation](https://github.com/systemd/systemd-stable/blob/v255-stable/docs/BOOT.md).

If no usable generation or password is available, boot a NixOS installation USB. Identify and mount this machine's root partition at `/mnt` and EFI partition at `/mnt/boot`; do not format them. Enter the installed system with `sudo nixos-enter --root /mnt` and use `passwd edtosoy` to reset the password if needed. This assumes an intact installed system that `nixos-enter` can enter. If its system closure is missing or the disk is empty, follow the NixOS installation procedure with the reviewed flake and verified mounts; do not run `nixos-rebuild switch` against the live USB system as a substitute for installation. Rebuilding from recovery additionally requires the checkout, its submodule, and dependencies to be available. See the [NixOS installation manual](https://nixos.org/manual/nixos/stable/#sec-installation).

Rollback does not restore project data, mutable application state, or a password changed with `passwd`. Keep private backups for those.

Weekly GC deletes generations older than seven days. The `nix-clean` alias runs `sudo nix-collect-garbage -d`, deleting old generations immediately. The 20-entry boot limit does not guarantee their closures survive GC. Avoid `nix-clean` during migration, and retain the known-good closure with a GC root if recovery must remain possible beyond the GC window:

```bash
mkdir -p ~/.local/state/nix/gcroots
nix-store --add-root "$HOME/.local/state/nix/gcroots/nixos-known-good" --indirect --realise "$(readlink -f /run/current-system)"
```

This intentionally preserves the current closure; it does not activate anything. Keep the root until the replacement has been verified.

## Keyboard, sleep, and desktop notes

Sway's `input *` selects `real-prog-dvorak`; NixOS registers the layout from the repository's symbols file. LightDM/X11 separately uses `us` with the `dvorak` variant. The custom layout's number row sends numbers without Shift. Preserve the symbols file when recovering.

Sway binds `mod+Shift+s` to suspend. Logind handles lid-close and suspend-key events with suspend. The only configured swayidle action is `before-sleep 'swaylock -f -c 000000'`; idle suspend, five-minute locking, and ten-minute display-off are not configured.

Home Manager uses `.backup` for conflicting managed files. Inspect a reported collision before rebuilding again; an existing backup can also need attention. Appearance and cursor preferences are set in several places; this phase preserves them.

Qutebrowser ignores its autoconfig and enables JavaScript globally, with explicit YouTube URL overrides in `qutebrowser/config.py`. Most listed site-specific enablements are therefore redundant with the global setting. Edit that file to change the policy, rebuild and activate, then restart the browser. Sway config changes likewise need a rebuild and activation before `mod+Shift+c` reloads the installed file.

## Deferred TODOs

These are recorded for later review; the current configuration is preserved:

- Duplicate tmux `D` binding (the later binding wins).
- tmux's `xclip` reference without an explicit package here.
- Rofi's `Papirus-Dark` icon theme without an explicit package here.
- Neovim's `terraform-ls` command without an explicit package here.
- Qutebrowser's repeated global stylesheet assignment (the later assignment wins).
- Neovim reproducibility: runtime Lazy bootstrap, mutable plugin lockfile, and downloaded Treesitter parsers.
- Password provisioning and declarative storage links.
- Repeated `basedpyright` and `ruff` entries in `home.packages`. Retained in Phase 1 to preserve the evaluated list exactly; deduplicate in a separately reviewed cleanup.
