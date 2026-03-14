// ==UserScript==
// @name        JS Tab Indicator
// @match       *://*/*
// @run-at      document-end
// ==/UserScript==
(function () {
  // Prepend [JS] to page title — only runs when JS is enabled,
  // so tabs without JS won't have the prefix. Result in tab:
  //   "3: [JS] Claude"  → JS on
  //   "3: Claude"       → JS off
  if (!document.title.startsWith("[JS]")) {
    document.title = "[JS] " + document.title;
  }
  // Also handle title changes (SPAs)
  const observer = new MutationObserver(() => {
    if (!document.title.startsWith("[JS]")) {
      document.title = "[JS] " + document.title;
    }
  });
  observer.observe(document.querySelector("title") || document.head, {
    childList: true,
    characterData: true,
    subtree: true,
  });
})();
