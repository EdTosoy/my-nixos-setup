from qutebrowser.api import interceptor
from PyQt6.QtCore import QUrl

config.load_autoconfig(False)

# -------------------------
# GitHub Dark Dimmed × VSCode
# -------------------------

BG       = "#22272e"
SURFACE  = "#1c2128"
INSET    = "#2d333b"
BORDER   = "#6d737a"

FG       = "#adbac7"
FG_MUTE  = "#768390"
FG_BRT   = "#cdd9e5"

BLUE      = "#539bf5"
BLUE_BG   = "#264466"

GREEN     = "#57ab5a"
GREEN_BG  = "#1f3325"

YELLOW     = "#daaa3f"
YELLOW_BG  = "#2f2411"

RED       = "#f47067"
RED_BG    = "#351515"

PURPLE     = "#986ee2"
PURPLE_BG  = "#211d41"

ORANGE = "#cc6b2c"

# -------------------------
# Statusbar
# -------------------------

c.colors.statusbar.normal.bg = BG
c.colors.statusbar.normal.fg = FG

c.colors.statusbar.insert.bg = GREEN_BG
c.colors.statusbar.insert.fg = FG_BRT

c.colors.statusbar.passthrough.bg = PURPLE_BG
c.colors.statusbar.passthrough.fg = FG_BRT

c.colors.statusbar.command.bg = INSET
c.colors.statusbar.command.fg = FG

c.colors.statusbar.caret.bg = PURPLE_BG
c.colors.statusbar.caret.fg = FG_BRT

c.colors.statusbar.caret.selection.bg = YELLOW_BG
c.colors.statusbar.caret.selection.fg = FG_BRT

c.colors.statusbar.progress.bg = BLUE

c.colors.statusbar.url.fg = FG
c.colors.statusbar.url.success.http.fg = GREEN
c.colors.statusbar.url.success.https.fg = GREEN
c.colors.statusbar.url.error.fg = RED
c.colors.statusbar.url.warn.fg = YELLOW
c.colors.statusbar.url.hover.fg = BLUE

# -------------------------
# Tabs
# -------------------------

c.colors.tabs.bar.bg = INSET

c.colors.tabs.odd.bg = INSET
c.colors.tabs.odd.fg = FG_MUTE

c.colors.tabs.even.bg = INSET
c.colors.tabs.even.fg = FG_MUTE

# VSCode-style active tab
c.colors.tabs.selected.odd.bg = SURFACE
c.colors.tabs.selected.odd.fg = FG_BRT

c.colors.tabs.selected.even.bg = SURFACE
c.colors.tabs.selected.even.fg = FG_BRT

c.colors.tabs.pinned.odd.bg = INSET
c.colors.tabs.pinned.odd.fg = FG_MUTE

c.colors.tabs.pinned.even.bg = INSET
c.colors.tabs.pinned.even.fg = FG_MUTE

c.colors.tabs.pinned.selected.odd.bg = SURFACE
c.colors.tabs.pinned.selected.odd.fg = FG_BRT

c.colors.tabs.pinned.selected.even.bg = SURFACE
c.colors.tabs.pinned.selected.even.fg = FG_BRT

c.colors.tabs.indicator.start = BLUE
c.colors.tabs.indicator.stop = GREEN
c.colors.tabs.indicator.error = RED
c.colors.tabs.indicator.system = "none"

# -------------------------
# Hints
# -------------------------

c.colors.hints.bg = SURFACE
c.colors.hints.fg = ORANGE
c.colors.hints.match.fg = YELLOW

c.hints.border = f"1px solid {BORDER}"

# -------------------------
# Completion
# -------------------------

c.colors.completion.fg = FG

c.colors.completion.odd.bg = BG
c.colors.completion.even.bg = SURFACE

# GitHub uses muted section labels
c.colors.completion.category.bg = INSET
c.colors.completion.category.fg = FG_MUTE

c.colors.completion.category.border.top = BORDER
c.colors.completion.category.border.bottom = BORDER

# Subtle selection instead of giant blue block
c.colors.completion.item.selected.bg = SURFACE
c.colors.completion.item.selected.fg = FG_BRT

c.colors.completion.item.selected.border.top = BLUE
c.colors.completion.item.selected.border.bottom = BLUE

c.colors.completion.item.selected.match.fg = BLUE
c.colors.completion.match.fg = YELLOW

c.colors.completion.scrollbar.fg = BORDER
c.colors.completion.scrollbar.bg = BG

# -------------------------
# Keyhint
# -------------------------

c.colors.keyhint.bg = SURFACE
c.colors.keyhint.fg = FG
c.colors.keyhint.suffix.fg = YELLOW

# -------------------------
# Messages
# -------------------------

c.colors.messages.info.bg = SURFACE
c.colors.messages.info.fg = FG_BRT
c.colors.messages.info.border = BORDER

c.colors.messages.warning.bg = YELLOW_BG
c.colors.messages.warning.fg = FG_BRT
c.colors.messages.warning.border = YELLOW

c.colors.messages.error.bg = RED_BG
c.colors.messages.error.fg = FG_BRT
c.colors.messages.error.border = RED

# -------------------------
# Webpage background
# -------------------------

c.colors.webpage.bg = BG

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.threshold.foreground = 150
c.colors.webpage.darkmode.threshold.background = 100
# -------------------------
# Tabs
# -------------------------

c.tabs.position = "right"
c.tabs.show = "multiple"
c.tabs.width = "15%"
c.tabs.padding = {
    "top": 3,
    "bottom": 3,
    "left": 6,
    "right": 6,
}
c.tabs.indicator.width = 2
c.tabs.title.format = "{audio}{index}: {current_title}"
c.tabs.last_close = "close"
# -------------------------
# Fonts
# -------------------------
c.fonts.default_family = [
    "JetBrainsMono Nerd Font Mono",
    "JetBrains Mono",
    "FiraCode Nerd Font",
    "Fira Code",
    "monospace",
]
c.fonts.default_size = "13pt"
c.fonts.completion.entry = "13pt default_family"
c.fonts.completion.category = "bold 13pt default_family"
c.fonts.statusbar = "13pt default_family"
c.fonts.tabs.selected = "bold 13pt default_family"
c.fonts.tabs.unselected = "13pt default_family"
c.fonts.hints = "bold 12pt default_family"
c.fonts.keyhint = "12pt default_family"
c.fonts.messages.error = "13pt default_family"
c.fonts.messages.info = "13pt default_family"
c.fonts.messages.warning = "13pt default_family"
c.fonts.web.family.standard = "JetBrainsMono Nerd Font Mono"
c.fonts.web.family.fixed = "JetBrainsMono Nerd Font Mono"
c.fonts.web.family.sans_serif = "JetBrainsMono Nerd Font Mono"
c.fonts.web.family.serif = "JetBrainsMono Nerd Font Mono"
c.fonts.web.size.default = 14
c.fonts.web.size.default_fixed = 14
c.fonts.web.size.minimum = 10

# -------------------------
# Status bar
# -------------------------
c.statusbar.show = 'always'
c.statusbar.padding = {"top": 3, "bottom": 3, "left": 6, "right": 6}
c.statusbar.widgets = ['keypress', 'url', 'scroll', 'history', 'tabs', 'progress']

# -------------------------
# Session / window restore
# -------------------------
c.auto_save.session = True
c.session.lazy_restore = True

# -------------------------
# Editor (external)
# -------------------------
c.editor.command = ['nvim', '{file}']

# -------------------------
# Downloads
# -------------------------
c.downloads.position = 'bottom'
c.downloads.remove_finished = 5000

# -------------------------
# Scrolling
# -------------------------
c.scrolling.smooth = True
c.scrolling.bar = 'overlay'

# -------------------------
# Privacy / Security
# -------------------------
c.content.javascript.enabled = True
c.content.webgl = False
c.content.canvas_reading = False
c.content.geolocation = False
c.content.webrtc_ip_handling_policy = "default-public-interface-only"
c.content.cookies.accept = "all"
c.content.cookies.store = True
c.content.unknown_url_scheme_policy = 'allow-from-user-interaction'

# -------------------------
# Trusted JS sites
# -------------------------
TRUSTED_JS_SITES = [
    "https://claude.ai/*",
    "https://www.blinkist.com/*",
    "https://music.youtube.com/*",
    "https://www.youtube.com/*",
    "https://inv.nadeko.net/*",
    "https://libreddit.de/*",
    "https://safetwitch.drgns.space/*",
    "https://github.com/*",
    "https://docs.nestjs.com/*",
    "https://www.prisma.io/*",
    "https://nodejs.org/*",
    "https://neetcode.io/roadmap",
    "https://developer.mozilla.org/*",
    "https://stackoverflow.com/*",
    "http://localhost:*",
    "http://127.0.0.1:*",
    "http://10.0.0.1/*",
]
for site in TRUSTED_JS_SITES:
    config.set("content.javascript.enabled", True, site)

# -------------------------
# YouTube overrides
# -------------------------
config.set("content.javascript.enabled",    False, "https://www.youtube.com/")
config.set("content.javascript.enabled",    True,  "https://www.youtube.com/feed/subscriptions")
config.set("content.javascript.enabled",    True,  "https://www.youtube.com/watch*")
config.set("content.javascript.enabled",    True,  "https://www.youtube.com/results*")
config.set("content.javascript.enabled",    False, "https://www.youtube.com/shorts/*")
config.set("content.mute",                  True,  "https://www.youtube.com/shorts/*")
config.set("content.autoplay",              False, "https://www.youtube.com/*")
config.set("content.notifications.enabled", False, "https://www.youtube.com/*")
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "https://www.youtube.com/*",
)

# -------------------------
# Keybindings
# -------------------------
config.unbind(".")

# --- Quicklaunch sites ---
config.bind("<space>m", "open -t https://music.youtube.com")
config.bind("<space>c", "open -t https://claude.ai")
config.bind("<space>y", "open -t https://www.youtube.com/feed/subscriptions")
config.bind("<space>i", "open -t https://inv.nadeko.net")
config.bind("<space>n", "open -t https://neetcode.io/roadmap")

# --- Session ---
config.bind("<ctrl-s>", "session-save", mode="normal")

# --- Toggles ---
config.bind("<ctrl-j>",
    "config-cycle content.javascript.enabled true false",
    mode="normal")
config.bind("<ctrl-d>", "config-cycle colors.webpage.darkmode.enabled true false")
config.bind("<ctrl-b>", "config-cycle content.blocking.enabled true false", mode="normal")
config.bind("<space>.", "config-cycle tabs.show always never")

# --- Search / highlight ---
config.bind("<Escape>", "search", mode="normal")

# --- Clipboard ---
config.bind("yy", "yank url")
config.bind("yt", "yank title")
config.bind("ys", "yank selection")
config.bind("p",  "open {clipboard}",    mode="normal")
config.bind("P",  "open -t {clipboard}", mode="normal")
config.bind("p", "yank selection ;; message-info 'yanked selection'", mode="caret")

# --- Hints ---
# d now triggers hint all (replaces f)
# f removed
config.bind("d",  "hint all",             mode="normal")
config.bind("D",  "hint all tab",         mode="normal")
config.bind(";r", "hint --rapid all tab", mode="normal")

# --- Navigation ---
config.bind("H", "back",     mode="normal")
config.bind("L", "forward",  mode="normal")
config.bind("J", "tab-prev", mode="normal")
config.bind("K", "tab-next", mode="normal")

# --- Insert mode ---
config.bind("a", "mode-enter insert", mode="normal")
config.bind("i", "mode-enter insert", mode="normal")

# --- Scrolling ---
config.bind("gg", "scroll-to-perc 0",        mode="normal")
config.bind("G",  "scroll-to-perc 100",       mode="normal")
config.bind("<ctrl-u>", "scroll-page 0 -0.5", mode="normal")

# --- Tabs ---
config.bind("<space>;", "tab-close", mode="normal")  # safe close — no accidental d
config.bind("u", "undo",             mode="normal")

# --- Passthrough ---
config.bind("<ctrl-f>", "search",            mode="normal")
config.bind("<ctrl-a>", "fake-key <ctrl-a>", mode="normal")

# --- Reload ---
config.bind("<ctrl-shift-r>", "reload -f", mode="normal")

# -------------------------
# Adblock
# -------------------------
c.content.blocking.enabled = True
c.content.blocking.method = "auto"
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt",
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
]

# -------------------------
# HTTPS everywhere
# -------------------------
config.set("content.headers.custom", {"Upgrade-Insecure-Requests": "1"})

config.set("content.user_stylesheets", ["~/.config/qutebrowser/styles/messenger.css"])

# -------------------------
# Load interceptor LAST
# -------------------------
@interceptor.register
def block_youtube_shorts(info: interceptor.Request):
    url = info.request_url
    if url.host() != "www.youtube.com":
        return
    if url.path().startswith("/shorts/"):
        new_url = QUrl(url)
        new_url.setPath("/feed/subscriptions")
        new_url.setQuery("")
        new_url.setFragment("")
        info.redirect(new_url)
