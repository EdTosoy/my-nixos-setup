# my-nixos-setup

My personal NixOS dotfiles. Minimal, keyboard-driven, and built for development.

> **Heads up — Real Programmers Dvorak.** This config uses a non-standard keyboard layout. Read the [Keyboard Layout](#keyboard-layout) section before anything else. Switching back to QWERTY is easy and covered there.

---

## What's inside

| Component           | Details                                            |
| ------------------- | -------------------------------------------------- |
| **OS**              | NixOS 25.11 (flakes)                               |
| **Window Manager**  | Sway (Wayland)                                     |
| **Display Manager** | LightDM — select **"Sway"** at login               |
| **User Config**     | Home Manager (release-25.11)                       |
| **Shell**           | Bash                                               |
| **Editor**          | Neovim (default editor, `vi`/`vim` aliased)        |
| **Terminal**        | Kitty                                              |
| **Browser**         | Qutebrowser (JS off by default)                    |
| **Launcher**        | Rofi                                               |
| **File Manager**    | Yazi                                               |
| **Audio**           | PipeWire + WirePlumber                             |
| **Notifications**   | Dunst                                              |
| **Screen Locker**   | swaylock                                           |
| **Idle Daemon**     | swayidle                                           |
| **Cursor**          | Banana cursor                                      |
| **Fonts**           | JetBrainsMono Nerd Font, Hack Nerd Font, Noto Sans |

---

## Repository structure

```
my-nixos-setup/
├── flake.nix                  # entry point — nixos-btw host, edtosoy user
├── flake.lock
├── configuration.nix          # system config (hardware, services, fonts, docker)
├── home.nix                   # user config (packages, dotfiles, shell, git)
├── hardware-configuration.nix # machine-specific — do NOT copy this
├── real-prog-dvorak           # custom keyboard layout definition
├── secrets.nix.example        # copy to secrets.nix and fill in your password
├── nvim/                      # Neovim config (Lua)
├── sway/                      # Sway WM config
├── tmux/                      # tmux config
├── qutebrowser/
│   ├── config.py
│   ├── greasemonkey/
│   └── styles/
├── rofi/
│   ├── config.rasi
│   └── oneDarkPro.rasi
└── scripts/
    └── tmux-sessionizer        # installed to ~/.local/bin
```

---

## Fresh install

This assumes NixOS is already installed and you have a working user account. Complete the base NixOS install first, then continue here.

### 1. Clone the repo

```bash
git clone https://github.com/EdTosoy/my-nixos-setup ~/nixos-setup
cd ~/nixos-setup
```

### 2. Generate your hardware config

Do **not** copy the `hardware-configuration.nix` from this repo — it's specific to my machine. Generate your own:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### 3. Set up secrets

```bash
cp secrets.nix.example secrets.nix
```

Edit `secrets.nix` and set your password:

```nix
{ ... }:
{
  users.users.your-username.initialPassword = "your-password";
}
```

This file is gitignored and will never be committed.

### 4. Adapt to your system

**`configuration.nix`** — hostname:

```nix
networking.hostName = "your-hostname";
```

**`flake.nix`** — hostname and username:

```nix
nixosConfigurations.your-hostname = ...
users.your-username = import ./home.nix;
```

**`home.nix`** — username, home path, and git identity:

```nix
home.username = "your-username";
home.homeDirectory = "/home/your-username";

programs.git.settings = {
  user.name  = "Your Name";
  user.email = "you@example.com";
};
```

**`home.nix`** — shell aliases (update the flake target):

```nix
nrs = "sudo nixos-rebuild switch --flake ~/nixos-setup#your-hostname";
hms = "home-manager switch --flake ~/nixos-setup#your-hostname";
```

### 5. Rebuild

```bash
sudo nixos-rebuild switch --flake ~/nixos-setup#your-hostname
```

### 6. Reboot

```bash
reboot
```

After reboot, LightDM appears. Select **"Sway"** and log in with the password from `secrets.nix`.

---

## Keyboard layout

This config uses a custom variant of **Real Programmers Dvorak** — a heavily customized Dvorak layout optimized for programming.

```
QWERTY:  ` 1 2 3 4 5 6 7 8 9 0  *  +
RPD:     $ 1 2 3 4 5 6 7 8 9 0  *  +

QWERTY:  q  w  e  r  t  y  f  g  c  r  l  /  @
RPD:     ;  ,  .  p  y  f  g  c  r  l  /  @  \

QWERTY:  a  s  d  f  g  h  j  k  l  ;  '
RPD:     a  o  e  u  i  d  h  t  n  s  -

QWERTY:  z  x  c  v  b  n  m  ,  .  /
RPD:     '  q  j  k  x  b  m  w  v  z
```

Key differences from standard Dvorak:

- **Number row base layer is numbers** (`1`–`0`) — Shift gives symbols (`[`, `{`, `(`, etc.)
- `$` replaces `` ` `` on the tilde key
- `;` and `:` move to where `q` was
- `'` moves to where `z` was
- `/` and `?` replace `[` and `]`
- Last two keys on the number row are `*` and `+` (not `-` and `=`)

**To switch to QWERTY instead:**

In `configuration.nix`, update the xkb block:

```nix
xkb.layout = "us";
xkb.variant = "";  # or remove this line
```

Remove the `xkb.extraLayouts` block entirely.

In `sway/config`, update the input block:

```
input * {
    xkb_layout us
}
```

Then delete the `real-prog-dvorak` file — it's no longer needed.

---

## Sleep / Power management

Suspend is configured via `logind` in `configuration.nix`:

```nix
services.logind = {
  lidSwitch = "suspend";
  settings.Login = {
    HandleSuspendKey = "suspend";
    IdleAction = "suspend";
    IdleActionSec = "300";
  };
};
```

Idle management and screen locking is handled by `swayidle` + `swaylock` in `sway/config`:

```
exec swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 000000'
```

| Trigger          | Action                        |
| ---------------- | ----------------------------- |
| 5 min idle       | swaylock fires (black screen) |
| 10 min idle      | display turns off (DPMS)      |
| wake from either | display turns back on         |
| suspend          | swaylock fires before sleep   |
| lid close        | suspend                       |

Manual suspend keybinding: `mod + Shift + s`

---

## Shell aliases

### NixOS

| Alias       | Command                                                     |
| ----------- | ----------------------------------------------------------- |
| `nrs`       | `sudo nixos-rebuild switch --flake ~/nixos-setup#nixos-btw` |
| `hms`       | `home-manager switch --flake ~/nixos-setup#nixos-btw`       |
| `nix-clean` | `sudo nix-collect-garbage -d`                               |

### Git

| Alias | Command                                |
| ----- | -------------------------------------- |
| `gs`  | `git status`                           |
| `ga`  | `git add .`                            |
| `gc`  | `git commit -m`                        |
| `gp`  | `git push`                             |
| `gl`  | `git pull`                             |
| `glo` | `git log --oneline --graph --decorate` |
| `gco` | `git checkout`                         |
| `gb`  | `git branch`                           |
| `gd`  | `git diff`                             |

### CLI

| Alias  | Command                   |
| ------ | ------------------------- |
| `v`    | `nvim`                    |
| `ls`   | `eza --icons`             |
| `ll`   | `eza -al --icons`         |
| `la`   | `eza -A --icons`          |
| `cat`  | `bat`                     |
| `grep` | `rg`                      |
| `ng`   | `npx @angular/cli@latest` |

---

## Neovim LSPs

The following language servers are installed via Nix and available to Neovim:

- `typescript-language-server` — TypeScript / JavaScript
- `vscode-langservers-extracted` — HTML, CSS, ESLint
- `@tailwindcss/language-server` — Tailwind CSS
- `emmet-language-server` — Emmet
- `angular-language-server` — Angular
- `nil` (`nil_ls`) — Nix
- `lua-language-server` — Lua
- `prettierd` — formatting
- `stylua` — Lua formatting

---

## System features

- **Docker** — enabled with auto-prune, starts on boot, `edtosoy` in `docker` group
- **Bluetooth** — `blueman` + `bluez`, auto-enable on boot
- **PipeWire** — configured with a fixed 1024-frame quantum to reduce audio stuttering
- **Sleep** — `logind` suspend on lid close, suspend key, and idle; swaylock before sleep
- **Nix flakes** — enabled; weekly GC deletes generations older than 7 days
- **XWayland** — kept enabled for app compatibility alongside Sway
- **ProtonVPN** — installed via home packages

---

## Troubleshooting

**Home Manager conflict on rebuild**
Home Manager backs up conflicting files with a `.backup` extension. Check `~/.config` for `.backup` files after rebuilding.

**Cursor not showing in some apps**
Make sure you selected the **"Sway"** session at the LightDM screen. The cursor is set via both GTK settings and `gsettings` in the Sway autostart.

**Qutebrowser site not working**
JavaScript is off globally. Add the site to `TRUSTED_JS_SITES` in `qutebrowser/config.py` and restart the browser.

**Wrong keyboard layout after install**
Check the input block in `sway/config`. Reload Sway with `mod + Shift + c` after any changes.

**Workspace switching not working**
Make sure you're using `$mod+1` through `$mod+0` — the number row base layer sends numbers in this RPD variant.

**Screen doesn't lock / swaylock not firing**
The swayidle instance may have started before swaylock was installed. Kill it and reload:

```bash
pkill swayidle
swaymsg reload
```

**Machine doesn't suspend on idle**
Check that logind picked up the config:

```bash
loginctl show-session
```

Look for `IdleAction=suspend` and `IdleActionSec=300` in the output.

**Forgot your password**
Hold `Shift` at boot to open GRUB, press `e` on the NixOS entry, append `init=/bin/sh` to the `linux` line, boot with `Ctrl+x`, then:

```bash
mount -o remount,rw /
passwd your-username
exec /sbin/init
```

**Too many boot generations**
GC runs weekly automatically. To clean up now:

```bash
nix-clean
sudo nixos-rebuild boot --flake ~/nixos-setup#nixos-btw
```
