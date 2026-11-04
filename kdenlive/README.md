# GitHub Dark Studio for Kdenlive

Home Manager installs `GitHubDarkStudio.colors` under
`$XDG_DATA_HOME/color-schemes` (normally `~/.local/share/color-schemes`). It adds
a selectable KDE color scheme without changing Sway, GTK, Qt style or the global
KDE color scheme. Kdenlive is already installed in `home.nix`.

This is a separate custom copy of the **Breeze Light** scheme bundled with KDE
ColorScheme 6.26.0, recolored with the GitHub Dark palette and saved under its own
name. The original **Breeze Light** and **Breeze Dark** schemes remain intact and
selectable. The copy retains the light scheme's state effects and group structure,
including a recolored inactive header, so switching focus does not reveal a light
header. Its scheme ID and display name are independent of both built-in schemes.

Close Kdenlive before activation. After reviewing and approving a system switch,
use the repository's normal activation command:

```bash
sudo nixos-rebuild switch --flake '.?submodules=1#nixos-btw' --no-update-lock-file --no-write-lock-file
```

The activation migrates `~/.config/kdenliverc` before Home Manager removes the old
managed symlink. It first copies the link's contents to a unique, regular
`kdenliverc.before-github-dark-studio.*` backup beside the config, then creates a
mode-600 writable file. Unreadable or dangling links abort without replacement.
The backup survives garbage collection of the original Nix store target.
For a fresh home, the repository's `kdenliverc` supplies initial settings.

During migration or initial creation, only `[UiSettings] ColorSchemePath` is
changed to `GitHubDarkStudio.colors`; other settings are retained. Subsequent
activations leave an existing regular config untouched, so GUI changes persist.
Existing regular configs are also preserved on first activation: select
**Settings → Color Scheme → GitHub Dark Studio** manually in that case. Restart
Kdenlive after activation to discover the new scheme.

The theme uses the requested background, surface, raised, border, text,
secondary, blue, green and amber palette. Negative text additionally uses GitHub's
red `#f47067`; selected text uses the dark background for contrast. KDE/Qt styles
derive some borders and shades, so the scheme does not force every widget edge
to use the border color. It does not change Kdenlive's existing widget style.

Version checks used the flake's Kdenlive **26.04.3** and KDE ColorScheme
**6.26.0** release archives:

- [Kdenlive theme manager](https://invent.kde.org/multimedia/kdenlive/-/blob/v26.04.3/src/utils/thememanager.cpp):
  `loadCurrentPath()` reads `UiSettings/ColorSchemePath`, and
  `schemeActionTriggered()` saves the `.colors` filename. The old
  `UiSettings/ColorScheme` entry is preserved but is not used to select this theme.
- [KDE scheme discovery](https://invent.kde.org/frameworks/kcolorscheme/-/blob/v6.26.0/src/kcolorschememodel.cpp)
  reads `color-schemes/*.colors` through Qt's generic data locations.
- [KDE palette reader](https://invent.kde.org/frameworks/kcolorscheme/-/blob/v6.26.0/src/kcolorscheme.cpp)
  defines the `Colors:*`, foreground, background, decoration and state-effect keys.
- [Breeze Light base](https://invent.kde.org/frameworks/kcolorscheme/-/blob/v6.26.0/src/color-schemes/BreezeLight.colors)
  supplies the structure and state-effect defaults for this separate custom scheme.
- [Kdenlive Color Scheme manual](https://docs.kdenlive.org/en/user_interface/menu/settings_menu/themes.html)
  describes choosing a scheme from the application menu.

No activation is necessary to verify the change: evaluate the host and Home
Manager activation derivations and run `git diff --check`. Migration behavior
can be exercised with `migrate-config.sh CONFIG SEED KWRITECONFIG` using temporary
files and the pinned `kconfig` package's `bin/kwriteconfig6`.
