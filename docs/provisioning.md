# Workstation provisioning and recovery contract

NixOS owns the storage mount. The filesystem contents, directory ownership, and
user-data recovery are external provisioning concerns.

Configuration recovery is not data backup.

## Recovery boundaries

Git and the locked Nix inputs recover the NixOS and Home Manager configuration,
native application configuration, and the recorded Neovim configuration and
plugin revisions. Neovim's [recovery instructions](../nvim/README.md) describe its
writable lock and disposable plugin/parser downloads.

Private provisioning supplies the login password-hash file, the intended storage
filesystem, suitable directory ownership, and authentication or re-authentication
for services. The existing mechanism is
`users.users.edtosoy.hashedPasswordFile = "/etc/nixos/secrets/edtosoy-password-hash"`.
Follow [private password provisioning](../README.md#private-password-provisioning)
before installation or activation. On installation media the destination is
`/mnt/etc/nixos/secrets/edtosoy-password-hash`, under the mounted target system.
Do not put its contents, credentials, or tokens in Git or Nix expressions.

The current tree contains no login password values. Older Git history contains
literal login-password settings: removing them from the current tree does not
erase that history. Treat those historical credentials as exposed and do not
reuse them. Credential retirement and any history removal require separate,
deliberate action before publishing additional history.

Project contents, downloads, personal files, browser profiles, application
history/state, and other user data are outside this repository. A configuration
clone or system rollback does not recover them.

## Private password provisioning

This procedure creates private machine state, not repository files. Use a new
password, never a historical exposed credential. Do not run concurrent provisioning
or change mounts/paths during these steps. Never enable shell tracing (`set -x`),
pass passwords as arguments/environment variables, or display the hash with `cat`.

### Obtain the tools and select the destination

From NixOS installation media or the installed system, enter a temporary root
Bash shell with Nix-provided `mkpasswd` and Bash. The revision below matches the
stable Nixpkgs revision recorded in this repository's `flake.lock`; downloading
uncached tools requires network access. This does not rebuild or activate NixOS,
update the repository lockfile, or permanently install these tools:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' shell \
  --no-update-lock-file --no-write-lock-file \
  'github:NixOS/nixpkgs/c508844df6c28fa6dabc1b6af70f3ccbd65c5201#mkpasswd' \
  'github:NixOS/nixpkgs/c508844df6c28fa6dabc1b6af70f3ccbd65c5201#bash' \
  --command bash --noprofile --norc
```

Choose **one** context in that root shell. For a fresh installation, first verify
that `/mnt` is the intended mounted target root, then use:

```bash
mountpoint -q /mnt || { echo 'STOP: target root is not mounted' >&2; exit 1; }
findmnt --mountpoint /mnt -o TARGET,SOURCE,UUID,FSTYPE
# Compare the displayed filesystem identity with your reviewed target root.
target_root=/mnt
secret_dir=/mnt/etc/nixos/secrets
secret_file="$secret_dir/edtosoy-password-hash"
```

For an already-installed/running system, use instead:

```bash
target_root=
secret_dir=/etc/nixos/secrets
secret_file="$secret_dir/edtosoy-password-hash"
```

Do not use the running-system destination from installation media: it would
provision the live environment rather than the target installation.

### Define silent checks

These checks report only generic failures, never password/hash contents. They
require the actual numeric root UID/GID and exact modes; they refuse symlinks.
The format check requires one non-empty, newline-terminated yescrypt line using
[libxcrypt's yescrypt syntax](https://github.com/besser82/libxcrypt/blob/develop/doc/crypt.5).
It checks structure, not whether you entered the intended password.

```bash
secret_error() { printf 'STOP: %s\n' "$1" >&2; return 1; }
check_secret_directory() {
    [[ -d "$secret_dir" && ! -L "$secret_dir" ]] || {
        secret_error 'secret directory is missing or is a symlink'; return 1;
    }
    [[ $(stat -c '%u:%g:%a' -- "$secret_dir") == 0:0:700 ]] || {
        secret_error 'secret directory must be root:root mode 0700'; return 1;
    }
}
check_secret_file_metadata() {
    [[ -f "$secret_file" && ! -L "$secret_file" ]] || {
        secret_error 'secret must be a regular non-symlink file'; return 1;
    }
    [[ $(stat -c '%u:%g:%a' -- "$secret_file") == 0:0:600 ]] || {
        secret_error 'secret file must be root:root mode 0600'; return 1;
    }
}
validate_secret() {
    local LC_ALL=C
    local -a lines
    check_secret_directory && check_secret_file_metadata || return 1
    mapfile -t lines < "$secret_file" || return 1
    [[ ${#lines[@]} -eq 1 ]] || {
        secret_error 'secret must contain exactly one line'; return 1;
    }
    [[ $(wc -l < "$secret_file") -eq 1 &&
       $(wc -c < "$secret_file") -eq $((${#lines[0]} + 1)) &&
       ${lines[0]} =~ ^\$y\$[./A-Za-z0-9]+\$[./A-Za-z0-9]{1,86}\$[./A-Za-z0-9]{43}$ ]] || {
        secret_error 'secret must be one newline-terminated yescrypt hash'; return 1;
    }
}
```

### Prepare the directory and create the hash

Create only missing directories. Existing secret-directory ownership/mode is
validated, not silently changed. Stop on an unexpected path or metadata; preserve
and investigate it rather than applying broad permission fixes.

```bash
[[ $EUID -eq 0 ]] || { echo 'STOP: use the root tool shell above' >&2; exit 1; }
for parent in "$target_root/etc" "$target_root/etc/nixos"; do
    if [[ ! -e "$parent" && ! -L "$parent" ]]; then
        mkdir -m 0755 -- "$parent" || exit 1
    fi
    [[ -d "$parent" && ! -L "$parent" && $(stat -c '%u:%g' -- "$parent") == 0:0 ]] || {
        echo 'STOP: unexpected parent directory' >&2; exit 1;
    }
    (( (8#$(stat -c '%a' -- "$parent") & 0022) == 0 )) || {
        echo 'STOP: parent directory is writable by group/others' >&2; exit 1;
    }
done
if [[ ! -e "$secret_dir" && ! -L "$secret_dir" ]]; then
    mkdir -m 0700 -- "$secret_dir" || exit 1
fi
check_secret_directory || exit 1
```

Define and call this creation function. Password entry remains interactive on the
terminal; only the hash goes to the exclusively opened file. An existing path,
including an empty file or dangling symlink, is refused. A successful creation
is validated before you proceed:

```bash
create_provisioning_hash() {
    local hash_fd created_id
    failed_empty_id=
    check_secret_directory || return 1
    [[ ! -e "$secret_file" && ! -L "$secret_file" ]] || {
        secret_error 'destination exists; validate it or investigate, do not overwrite'; return 1;
    }
    umask 077
    set -o noclobber
    exec {hash_fd}> "$secret_file" || return 1
    created_id=$(stat -Lc '%d:%i' -- "/proc/$$/fd/$hash_fd")
    if mkpasswd --method=yescrypt >&"$hash_fd"; then
        exec {hash_fd}>&-
        validate_secret
    else
        exec {hash_fd}>&-
        if check_secret_file_metadata && [[ ! -s "$secret_file" &&
           $(stat -c '%d:%i' -- "$secret_file") == "$created_id" ]]; then
            failed_empty_id=$created_id
        fi
        secret_error 'generation failed; stop and follow failed-creation recovery'
    fi
}
create_provisioning_hash
```

For an **existing** provisioning file, skip creation and run `validate_secret`.
It prints no hash and exits successfully only when every check passes. Do not
continue to installation/activation after any failed command or validation.

### Recover only a known new empty failed artifact

If generation failed after this shell exclusively created a file, the function
records its device/inode identity **only if it is still empty and has the expected
metadata**. In the same shell, before retrying creation, the following optional
cleanup removes only that identified empty artifact:

```bash
remove_failed_empty_artifact() {
    check_secret_directory && check_secret_file_metadata || return 1
    [[ -n ${failed_empty_id:-} && ! -s "$secret_file" &&
       $(stat -c '%d:%i' -- "$secret_file") == "$failed_empty_id" ]] || {
        secret_error 'not the recorded new empty failure artifact; preserve it'; return 1;
    }
    rm -- "$secret_file" || return 1
    failed_empty_id=
}
remove_failed_empty_artifact
```

After successful cleanup, fix the cause of generation failure, then call
`create_provisioning_hash` again. This is not a deletion recipe for pre-existing
credentials: an existing file, non-empty partial result, changed identity, wrong
metadata, symlink, or lost shell/session record must be preserved for deliberate
investigation. Never reconstruct a cleanup token merely because a file is empty.

Once `validate_secret` succeeds, leave the root tool shell with `exit`. Private
provisioning is complete; installation/activation remains a separate step.

### Fresh accounts versus existing accounts

With `users.mutableUsers = true`, a fresh account's password is initialized from
this file. An existing account's password is preserved, including `passwd`
changes; changing this provisioning hash does not reset that password. `passwd`
does not update the file, so refresh it separately if future provisioning should
use the new credential. Replacing an existing file requires a separate reviewed
procedure; do not bypass this workflow's no-clobber protection.

NixOS reads the file during activation. This repository's additional activation
guard aborts if it is missing or empty, even when the account already exists. The
guard does not validate format or permissions; the silent checks above do that.
Build-only commands and non-activating evaluation do not read or require the
private file. Neither provisioning nor a rebuild recovers application credentials,
mutable sessions, or personal data. Configuration recovery is not data backup.

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
