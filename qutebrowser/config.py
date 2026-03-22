from qutebrowser.api import interceptor
from PyQt6.QtCore import QUrl

# ==========================
# qutebrowser — Focused Dev Setup
# Synced with VSCode config (One Dark Pro Night Flat)
# ==========================
config.load_autoconfig(False)

# -------------------------
# Status bar colors by mode
# Mirrors vim.statusBarColors.* from VSCode
# -------------------------
c.colors.statusbar.normal.bg = '#3C3C3C'
c.colors.statusbar.normal.fg = '#CCCCCC'
c.colors.statusbar.insert.bg = '#4B6E6E'  # teal — distinct from error red
c.colors.statusbar.insert.fg = '#CCCCCC'
c.colors.statusbar.passthrough.bg = '#5C4B6E'
c.colors.statusbar.passthrough.fg = '#CCCCCC'
c.colors.statusbar.command.bg = '#3C3C3C'
c.colors.statusbar.command.fg = '#CCCCCC'
c.colors.statusbar.caret.bg = '#5C4B6E'
c.colors.statusbar.caret.fg = '#CCCCCC'
c.colors.statusbar.caret.selection.bg = '#6E6E4B'
c.colors.statusbar.caret.selection.fg = '#CCCCCC'
c.colors.statusbar.progress.bg = '#2D2D2D'

# Status bar URL colors (One Dark Pro palette)
c.colors.statusbar.url.fg = '#CCCCCC'
c.colors.statusbar.url.success.http.fg = '#98C379'
c.colors.statusbar.url.success.https.fg = '#98C379'
c.colors.statusbar.url.error.fg = '#E06C75'
c.colors.statusbar.url.warn.fg = '#D19A66'
c.colors.statusbar.url.hover.fg = '#61AFEF'

# -------------------------
# Tabs
# -------------------------
c.tabs.position = 'right'
c.tabs.show = 'multiple'
c.tabs.padding = {"top": 3, "bottom": 3, "left": 6, "right": 6}
c.tabs.width = "15%"
c.tabs.indicator.width = 2
c.tabs.title.format = '{audio}{index}: {current_title}'
c.tabs.last_close = 'close'
c.colors.tabs.bar.bg = '#2D2D2D'
c.colors.tabs.odd.bg = '#2D2D2D'
c.colors.tabs.odd.fg = '#7A7A7A'
c.colors.tabs.even.bg = '#2D2D2D'
c.colors.tabs.even.fg = '#7A7A7A'
c.colors.tabs.selected.even.bg = '#3C3C3C'
c.colors.tabs.selected.odd.bg = '#3C3C3C'
c.colors.tabs.selected.even.fg = '#CCCCCC'
c.colors.tabs.selected.odd.fg = '#CCCCCC'
c.colors.tabs.pinned.even.bg = '#2D2D2D'
c.colors.tabs.pinned.odd.bg = '#2D2D2D'
c.colors.tabs.pinned.even.fg = '#7A7A7A'
c.colors.tabs.pinned.odd.fg = '#7A7A7A'
c.colors.tabs.pinned.selected.even.bg = '#3C3C3C'
c.colors.tabs.pinned.selected.odd.bg = '#3C3C3C'
c.colors.tabs.indicator.start = '#61AFEF'
c.colors.tabs.indicator.stop = '#98C379'
c.colors.tabs.indicator.error = '#E06C75'

# -------------------------
# Hints
# -------------------------
c.colors.hints.bg = '#2D2D2D'
c.colors.hints.fg = '#D19A66'
c.colors.hints.match.fg = '#E5C07B'
c.hints.border = '1px solid #3C3C3C'
c.hints.padding = {"top": 2, "bottom": 2, "left": 4, "right": 4}

# -------------------------
# Completion widget
# -------------------------
c.colors.completion.fg = '#CCCCCC'
c.colors.completion.odd.bg = '#2D2D2D'
c.colors.completion.even.bg = '#252526'
c.colors.completion.category.fg = '#61AFEF'
c.colors.completion.category.bg = '#1E1E1E'
c.colors.completion.category.border.top = '#1E1E1E'
c.colors.completion.category.border.bottom = '#1E1E1E'
c.colors.completion.item.selected.fg = '#FFFFFF'
c.colors.completion.item.selected.bg = '#094771'
c.colors.completion.item.selected.border.top = '#094771'
c.colors.completion.item.selected.border.bottom = '#094771'
c.colors.completion.item.selected.match.fg = '#E5C07B'
c.colors.completion.match.fg = '#E5C07B'
c.colors.completion.scrollbar.fg = '#3C3C3C'
c.colors.completion.scrollbar.bg = '#2D2D2D'

# -------------------------
# Keyhint / Messages
# -------------------------
c.colors.keyhint.bg = '#2D2D2D'
c.colors.keyhint.fg = '#CCCCCC'
c.colors.keyhint.suffix.fg = '#E5C07B'
c.colors.messages.info.bg = '#2D2D2D'
c.colors.messages.info.fg = '#CCCCCC'
c.colors.messages.info.border = '#3C3C3C'
c.colors.messages.warning.bg = '#6E4B4B'
c.colors.messages.warning.fg = '#CCCCCC'
c.colors.messages.warning.border = '#6E4B4B'
c.colors.messages.error.bg = '#6E4B4B'
c.colors.messages.error.fg = '#E06C75'
c.colors.messages.error.border = '#6E4B4B'

# -------------------------
# Webpage background (dark)
# -------------------------
c.colors.webpage.bg = '#1E1E1E'
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.threshold.foreground = 150
c.colors.webpage.darkmode.threshold.background = 100

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
# Privacy / Security (global defaults — overridden per-site below)
# -------------------------
c.content.javascript.enabled = False
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
# --- Quicklaunch sites ---
config.bind(",b", "open -t https://www.blinkist.com")
config.bind(",m", "open -t https://music.youtube.com")
config.bind(",c", "open -t https://claude.ai")
config.bind(",y", "open -t https://www.youtube.com/feed/subscriptions")
config.bind(",i", "open -t https://inv.nadeko.net")
config.bind(",r", "open -t https://libreddit.de")
config.bind(",t", "open -t https://safetwitch.drgns.space/ThePrimeagen")

# --- Session ---
config.bind(",s", "session-load default", mode="normal")
config.bind("<ctrl-s>", "session-save",   mode="normal")

# --- JS toggle ---
config.bind("<ctrl-j>",
    "config-cycle content.javascript.enabled true false",
    mode="normal")

# --- Darkmode toggle ---
config.bind("<ctrl-d>", "config-cycle colors.webpage.darkmode.enabled true false")

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
config.bind("f",  "hint all",             mode="normal")
config.bind("F",  "hint all tab",         mode="normal")
config.bind(";r", "hint --rapid all tab", mode="normal")

# --- Navigation ---
config.bind("H", "back",     mode="normal")
config.bind("L", "forward",  mode="normal")
config.bind("J", "tab-prev", mode="normal")
config.bind("K", "tab-next", mode="normal")

# --- Scrolling ---
config.bind("gg", "scroll-to-perc 0",        mode="normal")
config.bind("G",  "scroll-to-perc 100",       mode="normal")
config.bind("<ctrl-u>", "scroll-page 0 -0.5", mode="normal")

# --- Tabs ---
config.bind("d", "tab-close", mode="normal")
config.bind("u", "undo",      mode="normal")

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