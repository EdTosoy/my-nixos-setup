# Workstation provisioning and recovery contract

NixOS owns the storage mount. The filesystem contents, directory ownership, and
user-data recovery are external provisioning concerns.

Configuration recovery is not data backup.

## Recovery boundaries

Git and the locked Nix inputs recover the NixOS and Home Manager configuration,
native application configuration, and the recorded Neovim configuration and
plugin revisions. Neovim's [recovery instructions](../nvim/README.md) describe its
writable lock and disposable plugin/parser downloads.

Private provisioning supplies the intended storage filesystem, suitable directory
ownership, and authentication or re-authentication for services. Login passwords
are managed manually with `passwd`, independently of Nix and Git.
Do not put credentials or tokens in Git or Nix expressions.

The current tree contains no login password values. Older Git history contains
literal login-password settings: removing them from the current tree does not
erase that history. Treat those historical credentials as exposed and do not
reuse them. Credential retirement and any history removal require separate,
deliberate action before publishing additional history.

Project contents, downloads, personal files, browser profiles, application
history/state, and other user data are outside this repository. A configuration
clone or system rollback does not recover them.

## Login password and recovery

NixOS creates and configures `edtosoy`; `users.mutableUsers = true` keeps the
login password under normal Linux management. Use interactive `passwd edtosoy`
from an appropriate privileged environment. `/etc/shadow` is the authoritative
runtime password state; neither the password nor its hash is reproducible from
Git. Never put password material in Git or Nix expressions.

After a fresh installation, the account has no usable login password until you
set one manually. From installation media, verify the installed target is mounted
at `/mnt`, enter it with `nixos-enter --root /mnt`, then run `passwd edtosoy` as
root in that target environment. On an installed system, a root recovery TTY can
run `passwd edtosoy` directly. Do not accidentally set the live media's password.

Changing or rebuilding this configuration must not reset an existing mutable
user's password. Activation preserves the existing password while the account
and `users.mutableUsers = true` remain in place. No private password file is
required. Configuration recovery is separate from authentication recovery and
personal-data recovery.

## Adapt hardware before installation

These identifiers describe this workstation, not arbitrary replacement hardware:

| Declaration | Current identity | Required target-machine review |
| --- | --- | --- |
| `/` in `hardware-configuration.nix` | `ad26aa5b-b316-4651-9a3c-a4677ee54d19`, ext4 | Root filesystem UUID and type |
| `/boot` in `hardware-configuration.nix` | `8A4D-B010`, vfat | EFI/boot filesystem UUID, type, mount and bootloader assumptions |
| Swap in `hardware-configuration.nix` | `7e5241ac-01da-4657-a202-bd34aec2ba87` | Swap identity, or whether swap exists |
| `/mnt/storage` in `configuration.nix` | `604eb451-ea69-4bfa-b3f0-d3069c7f9014`, ext4 | Intended optional data filesystem UUID and type |

After identifying and mounting the target root and boot filesystems on installation
media, generate a candidate hardware configuration for that target, for example
with `nixos-generate-config --root /mnt --dir /tmp/target-nixos-candidate`.
Review it before replacing this repository's hardware file. Also review kernel
modules, CPU/platform settings and UEFI/systemd-boot assumptions. The separately
declared storage UUID must be reviewed independently. This command does not
partition or format disks; this document is not a complete installation guide.
Preserve the existing hardware file during recovery with unchanged disks.

## Optional storage and current local layout

`configuration.nix` declares `/mnt/storage` as ext4 with `options = [ "nofail" ]`.
Keep it optional: a missing data disk must allow a usable NixOS/recovery environment.
On the inspected workstation it is `/dev/sda1`, mounted `rw,relatime`; the UUID,
rather than that potentially changing device name, identifies the disk.

The manual links are:

```text
~/storage   -> /mnt/storage
~/projects  -> /mnt/storage/projects
~/Downloads -> /mnt/storage/downloads
```

The target uses lowercase `downloads`. Home Manager does not create these links
or target directories. Do not write through them, create directories under
`/mnt/storage`, or correct ownership until the expected filesystem is mounted.
An unmounted `/mnt/storage` directory belongs to the root filesystem: writes there
can later be hidden by the mounted disk. If the disk is missing, leave storage
provisioning unfinished and work elsewhere until it is available.

Inspection on 2026-10-05 found:

| Path | UID:GID | Mode |
| --- | --- | --- |
| Account `edtosoy` | `1001:100` (`edtosoy:users`) | — |
| `/mnt/storage` | `1001:100` | `0755` |
| `/mnt/storage/downloads` | `1001:100` | `0755` |
| `/mnt/storage/projects` | `1000:1000` | `0755` |

The projects ownership mismatch is a provisioning prerequisite, not enforced by
Nix. Numeric IDs can differ on a new installation; use the target account's
actual IDs, not copied workstation numbers.

## Safe one-time directory and link provisioning

Run these examples in Bash as the intended, already-created login user, not from
a root shell. On replacement hardware, substitute the UUID reviewed above. Close
applications using these paths and keep the disk mounted throughout the procedure.
Every failed check means stop and investigate; do not bypass it with forced links,
recursive ownership changes, or data deletion.

First verify the mount and inspect only the top-level directory metadata:

```bash
expected_uuid=604eb451-ea69-4bfa-b3f0-d3069c7f9014
require_storage() {
    mountpoint -q /mnt/storage &&
    [ "$(findmnt --mountpoint /mnt/storage -n -o UUID)" = "$expected_uuid" ] &&
    [ "$(findmnt --mountpoint /mnt/storage -n -o FSTYPE)" = ext4 ]
}
require_storage || { echo "STOP: expected storage is not mounted" >&2; exit 1; }
findmnt --mountpoint /mnt/storage -o TARGET,SOURCE,UUID,FSTYPE,OPTIONS
id
for target in /mnt/storage /mnt/storage/projects /mnt/storage/downloads; do
    [ -d "$target" ] && [ ! -L "$target" ] || {
        echo "STOP: missing directory or unexpected symlink: $target" >&2; exit 1;
    }
    stat -c '%n: uid=%u gid=%g mode=%a type=%F' "$target"
done
```

If a directory is missing, stop and decide whether the correct filesystem/data
has been recovered. Do not create an empty replacement that masks missing data.
If ownership is unexpected, establish who should own that directory first.
For this workstation's verified projects mismatch, the smallest one-time
correction is the following **optional mutation**, only after reviewing the
metadata above. It changes just the directory itself, not its contents:

```bash
require_storage || { echo "STOP: mount changed" >&2; exit 1; }
[ -d /mnt/storage/projects ] && [ ! -L /mnt/storage/projects ] || exit 1
[ "$(stat -c '%u:%g' /mnt/storage/projects)" = 1000:1000 ] || {
    echo "STOP: ownership differs from the inspected mismatch" >&2; exit 1;
}
sudo chown --no-dereference -- "$(id -u):$(id -g)" /mnt/storage/projects
stat -c '%n: uid=%u gid=%g mode=%a' /mnt/storage/projects
```

Changing the directory owner does not prove that existing contents have suitable
permissions. If subsequent access encounters unexpected ownership or permissions,
stop and investigate
those specific paths separately; do not apply `chown -R` or broad `chmod` fixes.

Before making links, inspect all three existing home paths. The checks below
accept already-correct symlinks, refuse files/directories/different or dangling
links with unexpected targets, and never replace existing paths:

```bash
require_storage || { echo "STOP: mount changed" >&2; exit 1; }
for target in /mnt/storage /mnt/storage/projects /mnt/storage/downloads; do
    [ -d "$target" ] && [ ! -L "$target" ] && [ -w "$target" ] && [ -x "$target" ] || {
        echo "STOP: unexpected directory or insufficient access: $target" >&2; exit 1;
    }
done
check_link() {
    if [ -L "$1" ]; then
        [ "$(readlink -- "$1")" = "$2" ] || return 1
        ls -ld -- "$1"
    elif [ -e "$1" ]; then
        ls -ld -- "$1"
        return 1
    fi
}
check_link "$HOME/storage" /mnt/storage &&
check_link "$HOME/projects" /mnt/storage/projects &&
check_link "$HOME/Downloads" /mnt/storage/downloads || {
    echo "STOP: unexpected home path; preserve and inspect it" >&2; exit 1;
}
require_storage || { echo "STOP: mount changed" >&2; exit 1; }
[ -L "$HOME/storage" ] || ln -sT -- /mnt/storage "$HOME/storage" || exit 1
[ -L "$HOME/projects" ] || ln -sT -- /mnt/storage/projects "$HOME/projects" || exit 1
[ -L "$HOME/Downloads" ] || ln -sT -- /mnt/storage/downloads "$HOME/Downloads" || exit 1
ls -ld -- "$HOME/storage" "$HOME/projects" "$HOME/Downloads"
```

`ln -sT` has no force option here: an unexpected path appearing after the checks
causes failure instead of replacement. These examples assume a stable mount and
local filesystem; they are not an automatic provisioning service.

## Anonymous configuration checkout

The public submodule URL in `.gitmodules` uses HTTPS, so a checkout can include
Neovim without SSH keys:

```bash
git clone --recurse-submodules https://github.com/EdTosoy/my-nixos-setup.git ~/nixos-setup
```

Recovery of a specific reviewed parent commit still requires checking out that
commit and running `git submodule update --init --recursive`. Do not use
`--remote`, which selects a submodule branch rather than the recorded revision.
An older parent commit can contain the older SSH URL. Private provisioning and
user-data recovery remain necessary after an anonymous configuration clone.

Publish the referenced Neovim commit before publishing a parent commit that
requires it, or retain a recovery backup containing both. Both recorded commits
must be available for a public clone to recover the intended configuration.
