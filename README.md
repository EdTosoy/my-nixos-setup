# nixos-dotfiles

My personal NixOS setup. Minimal, keyboard-driven, and built for development.

> **Heads up** — this config uses **Real Programmers Dvorak**, the layout used by
> [ThePrimeagen](https://github.com/ThePrimeagen). If you've seen his streams,
> this is exactly what he types on. It's a non-standard layout — read the
> [Keyboard](#keyboard-layout) section before you do anything.
> Don't worry though, switching to a standard QWERTY layout is straightforward
> and covered in that section.

---

## What's inside

| Tool                  | What it does                                     |
| --------------------- | ------------------------------------------------ |
| NixOS 25.11 (flakes)  | The OS                                           |
| Sway (Wayland)        | Window manager                                   |
| LightDM               | Login screen — select **"Sway"** at login        |
| Home Manager          | Manages dotfiles and user packages declaratively |
| Qutebrowser           | Keyboard-driven browser (JS off by default)      |
| Rofi                  | App launcher                                     |
| Kitty                 | Terminal                                         |
| VSCode (Neovim setup) | Editor                                           |
| Yazi                  | Terminal file manager                            |
| Dunst                 | Notifications                                    |
| PipeWire              | Audio                                            |
| bat + eza             | Better `cat` and `ls`                            |

---

## Folder structure

```
nixos-dotfiles/
├── flake.nix                  # entry point
├── flake.lock
├── configuration.nix          # system config (hardware, services, fonts)
├── home.nix                   # user config (packages, dotfiles, shell)
├── hardware-configuration.nix # generated — do not copy this one
├── real-prog-dvorak           # custom keyboard layout file
├── secrets.nix.example        # copy to secrets.nix and fill in your values
├── sway/
│   └── config                 # window manager config
├── qtile/
│   └── config.py              # old WM config — kept for reference
├── qutebrowser/
│   ├── config.py              # browser config + keybindings
│   ├── greasemonkey/          # userscripts
│   └── styles/                # custom CSS
├── rofi/
│   ├── config.rasi            # launcher behavior + keybindings
│   └── oneDarkPro.rasi        # launcher theme
└── vscode/
    ├── settings.json
    └── keybindings.json
```

---

## Fresh install

This config assumes NixOS is already installed and you have a working user
account. If you're on a fresh machine, complete the base NixOS installation
first, then come back here.

### 1. Clone the repo

Once NixOS is installed and you're logged in as your user:

```bash
git clone https://github.com/EdTosoy/nixos-dotfiles ~/nixos-dotfiles
cd ~/nixos-dotfiles
```

### 2. Generate your own hardware config

Do **not** copy the `hardware-configuration.nix` from this repo — it's specific
to my machine and will likely break yours. Generate your own:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### 3. Set up your secrets

```bash
cp secrets.nix.example secrets.nix
```

Then edit `secrets.nix` — replace the username and password:

```nix
{ ... }:
{
  users.users.your-username.initialPassword = "your-password-here";
}
```

This file is gitignored — it will never be committed. If you skip this step,
the build will still succeed but no password will be set.

### 4. Update these values to match your system

**`configuration.nix`** — your hostname:

```nix
networking.hostName = "your-hostname";
```

**`flake.nix`** — your hostname and username:

```nix
nixosConfigurations.your-hostname = ...
users.your-username = import ./home.nix;
```

**`home.nix`** — your username and home path:

```nix
home.username = "your-username";
home.homeDirectory = "/home/your-username";
```

**`home.nix`** — your git identity:

```nix
programs.git.settings = {
  user.name  = "your-name";
  user.email = "your@email.com";
};
```

**`home.nix`** — your shell aliases:

```nix
nrs = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#your-hostname";
hms = "home-manager switch --flake ~/nixos-dotfiles#your-hostname";
```

### 5. Rebuild

```bash
sudo nixos-rebuild switch --flake ~/nixos-dotfiles#your-hostname
```

### 6. Reboot

```bash
reboot
```

After reboot, LightDM will appear. Select **"Sway"** and log in with the
password you set in `secrets.nix`.

### 7. Finish up

Once you're on the desktop:

- Install VSCode extensions manually — they're not managed by Nix in this config
- Set up any additional git credentials if needed

---

## Keyboard Layout

This config uses **Real Programmers Dvorak** — the layout used by
[ThePrimeagen](https://github.com/ThePrimeagen). If you've seen his streams,
this is exactly what he types on. It's a heavily customized Dvorak layout
built for programming.

Here's what the layout actually looks like compared to QWERTY:

```
QWERTY:  ` 1 2 3 4 5 6 7 8 9 0 - =
RPD:     $ + [ { ( & = ) } ] * ! |

QWERTY:  q w e r t y u i o p [ ] \
RPD:     ; , . p y f g c r l / @ \

QWERTY:  a s d f g h j k l ; '
RPD:     a o e u i d h t n s -

QWERTY:  z x c v b n m , . /
RPD:     ' q j k x b m w v z
```

Notable differences from standard Dvorak:

- Number row **base layer is symbols** — numbers are on shift
- `$` replaces `` ` `` on the tilde key
- `;` and `:` move to where `q` was
- `'` moves to where `z` was
- `/` and `?` replace `[` and `]`

> **Workspace switching** uses the base layer symbols (`+`, `[`, `{`, etc.)
> since numbers require shift in this layout. See the [Workspaces](#workspaces)
> section for the full mapping.

**To use a standard QWERTY layout instead:**

In `configuration.nix`, find the xserver block and change:

```nix
xkb.layout = "us";  # or "gb", "de", "fr", etc.
xkb.variant = "";   # remove "dvorak"
```

Also remove the entire `xkb.extraLayouts` block and `environment.etc` entry:

```nix
# delete these blocks
services.xserver.xkb.extraLayouts = { ... };
environment.etc."xkb/symbols/real-prog-dvorak" = { ... };
```

In `sway/config`, update the input block:

```
input * {
    xkb_layout us
}
```

And update the workspace bindings back to numbers:

```
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
# etc.
```

Then delete the `real-prog-dvorak` file — you won't need it.

---

## Customization

### Terminal

In `sway/config`:

```
set $term kitty  # swap with alacritty, foot, wezterm, etc.
```

### Browser

In `sway/config`:

```
bindsym $mod+w exec firefox
```

### Wallpaper

`swaybg` is already installed. Add to `sway/config`:

```
output * bg /path/to/wallpaper.jpg fill
```

### Window border colors

In `sway/config`:

```
client.focused   #98971a  #98971a  #1d2021  #98971a  #98971a
client.unfocused #1d2021  #1d2021  #7A7A7A  #1d2021  #1d2021
```

### Gaps

In `sway/config`:

```
gaps inner 4
gaps outer 0
```

### Enabling JavaScript in Qutebrowser

JS is off globally for privacy. To whitelist a site, add it in `qutebrowser/config.py`:

```python
TRUSTED_JS_SITES = [
    "https://yoursite.com/*",
]
```

### Cursor theme

In `home.nix`, update `home.pointerCursor` with your preferred theme.

### VSCode extensions

Extensions are not managed by Nix in this config — install them manually through
the VSCode UI. Settings and keybindings are tracked though.

---

## Keybindings

### Sway

`mod` = Super (Windows key)

#### Window management

| Binding                 | Action                          |
| ----------------------- | ------------------------------- |
| `mod + h/j/k/l`         | Focus window left/down/up/right |
| `mod + shift + h/j/k/l` | Move window                     |
| `mod + ctrl + h/j/k/l`  | Resize window                   |
| `mod + f`               | Toggle fullscreen               |
| `mod + e`               | Toggle split layout             |
| `mod + q`               | Close window                    |
| `mod + semicolon`       | Split horizontal                |
| `mod + v`               | Split vertical                  |
| `mod + shift + space`   | Toggle floating                 |
| `mod + space`           | Focus floating/tiling toggle    |

#### Workspaces

> RPD number row base layer is symbols — use these to switch workspaces.

| Binding              | Workspace | Key |
| -------------------- | --------- | --- |
| `mod + plus`         | 1         | `+` |
| `mod + bracketleft`  | 2         | `[` |
| `mod + braceleft`    | 3         | `{` |
| `mod + parenleft`    | 4         | `(` |
| `mod + ampersand`    | 5         | `&` |
| `mod + equal`        | 6         | `=` |
| `mod + parenright`   | 7         | `)` |
| `mod + braceright`   | 8         | `}` |
| `mod + bracketright` | 9         | `]` |
| `mod + asterisk`     | 10        | `*` |

Add `shift` to any of the above to **move the focused window** to that workspace.

#### Apps

| Binding        | Action                 |
| -------------- | ---------------------- |
| `mod + Return` | Terminal (Kitty)       |
| `mod + o`      | App launcher (Rofi)    |
| `mod + w`      | Browser (Firefox)      |
| `mod + n`      | File manager (Yazi)    |
| `mod + b`      | Beeper                 |
| `mod + Escape` | System monitor (htop)  |
| `Print`        | Screenshot (Flameshot) |

#### System

| Binding            | Action             |
| ------------------ | ------------------ |
| `mod + shift + c`  | Reload Sway config |
| `mod + shift + r`  | Restart Sway       |
| `mod + shift + e`  | Exit Sway          |
| `mod + Left/Right` | Switch monitor     |

---

### VSCode

All VSCode keybindings are remapped for Real Programmers Dvorak.
`space` = leader key (Neovim normal mode only)

#### Editor

| Binding       | Action                  |
| ------------- | ----------------------- |
| `space ,`     | Save + format           |
| `space e`     | Save without formatting |
| `space ;`     | Close active editor     |
| `space o`     | Split editor right      |
| `space k`     | Split editor down       |
| `space c a`   | Code action             |
| `space p b`   | Rename symbol           |
| `space u m`   | Format document         |
| `shift+t`     | Show hover              |
| `[ e` / `] e` | Prev / next diagnostic  |

#### Navigation

| Binding          | Action               |
| ---------------- | -------------------- |
| `space i e`      | Go to definition     |
| `space i p`      | Go to references     |
| `space i c`      | Go to implementation |
| `space i o`      | Go to symbol         |
| `space u u`      | Quick open file      |
| `space u i`      | Find in files        |
| `space i i`      | Open source control  |
| `ctrl + h/j/k/l` | Navigate panes       |

#### Buffers

| Binding     | Action                   |
| ----------- | ------------------------ |
| `tab`       | Next editor in group     |
| `shift+tab` | Previous editor in group |
| `space y`   | Close other editors      |

#### File tree

| Binding   | Action                    |
| --------- | ------------------------- |
| `space .` | Toggle explorer           |
| `a`       | New file                  |
| `shift+a` | New folder                |
| `p`       | Rename                    |
| `c`       | Copy                      |
| `x`       | Cut                       |
| `l`       | Paste                     |
| `e`       | Delete                    |
| `o`       | Open to side              |
| `enter`   | Open file / expand folder |

#### Terminal

| Binding        | Action                |
| -------------- | --------------------- |
| `ctrl+shift+j` | Toggle terminal panel |
| `ctrl+shift+b` | New terminal          |
| `ctrl+shift+x` | Next terminal         |
| `ctrl+shift+a` | Previous terminal     |
| `ctrl+shift+'` | Kill terminal         |

#### Harpoon

| Binding     | Action               |
| ----------- | -------------------- |
| `space a`   | Add to harpoon       |
| `space d`   | Edit harpoon list    |
| `space l`   | Harpoon quick pick   |
| `space 1–5` | Jump to harpoon slot |

---

## Shell aliases

### NixOS

> Replace `your-hostname` with whatever you set in `networking.hostName`.

| Alias       | Command                                                            |
| ----------- | ------------------------------------------------------------------ |
| `nrs`       | `sudo nixos-rebuild switch --flake ~/nixos-dotfiles#your-hostname` |
| `hms`       | `home-manager switch --flake ~/nixos-dotfiles#your-hostname`       |
| `nix-clean` | `sudo nix-collect-garbage -d`                                      |

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

| Alias  | Command                 |
| ------ | ----------------------- |
| `v`    | `nvim`                  |
| `ls`   | `eza --icons`           |
| `ll`   | `eza -al --icons`       |
| `la`   | `eza -A --icons`        |
| `cat`  | `bat`                   |
| `grep` | `rg`                    |
| `btw`  | `echo I use nixos, btw` |

---

## Troubleshooting

**Home Manager conflicts on rebuild**
If you get a conflict error about existing files, Home Manager will back them up
automatically with a `.backup` extension. Check `~/.config` for `.backup` files
after rebuilding.

**Cursor not showing in some apps**
Make sure you selected the **"Sway"** session at the LightDM login screen. The
cursor theme is set via both GTK settings and `gsettings` in the Sway autostart.

**Qutebrowser site not working**
JavaScript is off by default. Add the site to `TRUSTED_JS_SITES` in
`qutebrowser/config.py` and restart the browser.

**Wrong keyboard layout after install**
Check the input config in `sway/config`:

```
input * {
    xkb_layout real-prog-dvorak
}
```

Reload Sway with `mod + shift + c` after any changes.

**Workspace switching not working**
This layout's number row produces symbols on the base layer. Use the symbol
keys — see the [Workspaces](#workspaces) table above for the full mapping.

**Forgot your password**
Reboot, hold `Shift` at boot to open GRUB, press `e` on the NixOS entry, add
`init=/bin/sh` to the end of the `linux` line, boot with `Ctrl+x`, then:

```bash
mount -o remount,rw /
passwd your-username
exec /sbin/init
```

**Too many boot entries**
Generations are automatically limited and cleaned up weekly. To manually
clean up old generations right now:

```bash
nix-clean
sudo nixos-rebuild boot --flake ~/nixos-dotfiles#your-hostname
```
