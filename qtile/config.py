# ~/.config/qtile/config.py
# Ported from i3 — Gruvbox Green | NixOS 25.11 | Wayland
# user: johncarlojose

import subprocess
from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.backend.wayland import InputConfig

mod      = "mod4"
terminal = "kitty"
home     = "/home/johncarlojose"

# ── Gruvbox ───────────────────────────────────────────────────────────────
c = {
    "bg":       "#282828",
    "red":      "#cc241d",
    "green":    "#98971a",
    "yellow":   "#d79921",
    "blue":     "#458588",
    "purple":   "#b16286",
    "aqua":     "#689d68",
    "gray":     "#a89984",
    "darkgray": "#1d2021",
    "white":    "#ffffff",
    "fg":       "#ebdbb2",
}

# ── Keys ──────────────────────────────────────────────────────────────────
keys = [
    # Focus — vim style
    Key([mod], "h", lazy.layout.left(),  desc="Focus left"),
    Key([mod], "l", lazy.layout.right(), desc="Focus right"),
    Key([mod], "j", lazy.layout.down(),  desc="Focus down"),
    Key([mod], "k", lazy.layout.up(),    desc="Focus up"),

    # Move
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),  desc="Move left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),  desc="Move down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(),    desc="Move up"),

    # Resize
    Key([mod, "control"], "h", lazy.layout.grow_left(),  desc="Grow left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),  desc="Grow down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(),    desc="Grow up"),
    Key([mod, "control"], "n", lazy.layout.normalize(),  desc="Reset sizes"),

    # Layout / window
    Key([mod], "f",              lazy.window.toggle_fullscreen(),  desc="Fullscreen"),
    Key([mod, "shift"], "space", lazy.window.toggle_floating(),    desc="Float toggle"),
    Key([mod], "space",          lazy.layout.next(),               desc="Focus mode toggle"),
    Key([mod], "e",              lazy.next_layout(),               desc="Cycle layout"),

    # Apps
    Key([mod], "Return", lazy.spawn(terminal),                               desc="Terminal"),
    Key([mod], "q",      lazy.window.kill(),                                 desc="Kill window"),
    Key([mod], "o",      lazy.spawn("rofi -show drun -font 'Hack 11'"),      desc="Launcher"),
    Key([mod], "n",      lazy.spawn("kitty yazi"),                           desc="File manager"),
    Key([mod], "w",      lazy.spawn("firefox"),                              desc="Browser"),
    Key([mod], "Escape", lazy.spawn("kitty -e htop"),                        desc="Monitor"),

    # Wallpaper swap (swaybg — Wayland)
    Key([mod, "shift"], "s",
        lazy.spawn(f"swaybg -i '{home}/Downloads/Arch Linux Wallpaper 4K.jpg' -m fill"),
        desc="Alt wallpaper"),

    # Qtile controls
    Key([mod, "shift"], "c", lazy.reload_config(), desc="Reload config"),
    Key([mod, "shift"], "r", lazy.restart(),       desc="Restart Qtile"),
    Key([mod, "shift"], "e", lazy.shutdown(),      desc="Quit Qtile"),

    # Multi-monitor
    Key([mod], "Right", lazy.next_screen(), desc="Next screen"),
    Key([mod], "Left",  lazy.prev_screen(), desc="Prev screen"),

    # Audio
    Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume @DEFAULT_SINK@ 5%+ --limit 1.0")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_SINK@ 5%-")),
    Key([], "XF86AudioMute",        lazy.spawn("wpctl set-mute @DEFAULT_SINK@ toggle")),
    Key([], "XF86AudioMicMute",     lazy.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle")),

    # Media
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),

    # Screenshot (Wayland)
    Key([], "Print", lazy.spawn("flameshot gui")),
]

# ── Groups (workspaces 1–10) ──────────────────────────────────────────────
groups = [Group(str(i)) for i in range(1, 11)]

for g in groups:
    ws_key = g.name if g.name != "10" else "0"
    keys += [
        Key([mod], ws_key,
            lazy.group[g.name].toscreen(),
            desc=f"Switch to ws {g.name}"),
        Key([mod, "shift"], ws_key,
            lazy.window.togroup(g.name, switch_group=False),
            desc=f"Move to ws {g.name}"),
    ]

# ── Layouts ───────────────────────────────────────────────────────────────
lt = dict(border_width=2, margin=1,
          border_focus=c["green"], border_normal=c["darkgray"])

layouts = [
    layout.Columns(**lt),
    layout.Max(**lt),
    layout.Stack(num_stacks=1, **lt),
]

# ── Floating ──────────────────────────────────────────────────────────────
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="ssh-askpass"),
        Match(wm_class="nm-connection-editor"),
        Match(wm_class="pavucontrol"),
        Match(title="pinentry"),
    ],
    border_focus=c["green"],
    border_normal=c["darkgray"],
    border_width=2,
)

# ── Mouse ─────────────────────────────────────────────────────────────────
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# ── No bar — 100% screen usage ───────────────────────────────────────────
screens = [
    Screen(),
]

# ── Autostart (Wayland-safe only) ─────────────────────────────────────────
@hook.subscribe.startup_once
def autostart():
    cmds = [
        # Wallpaper via swaybg
        ["swaybg", "-i",
         f"{home}/Downloads/peach-cat-goma-cat-3840x2160-10116.png",
         "-m", "fill"],
        # Notifications
        ["dunst"],
        # Network tray (runs fine on Wayland via XWayland)
        ["nm-applet"],
    ]
    for cmd in cmds:
        subprocess.Popen(cmd)

# ── Misc ──────────────────────────────────────────────────────────────────
dgroups_key_binder         = None
dgroups_app_rules          = []
follow_mouse_focus         = False
bring_front_click          = False
floats_kept_above          = True
cursor_warp                = False
auto_fullscreen            = True
focus_on_window_activation = "smart"
reconfigure_screens        = True
auto_minimize              = True
wmname                     = "LG3D"

wl_input_rules = {
    "*": InputConfig(kb_layout="real-prog-dvorak"),
}