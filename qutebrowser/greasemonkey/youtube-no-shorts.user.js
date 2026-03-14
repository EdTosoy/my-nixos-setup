// ==UserScript==
// @name        YouTube No Shorts
// @match       https://www.youtube.com/*
// @run-at      document-start
// ==/UserScript==

(function () {
  const kill = () => {
    document.querySelectorAll(
      'ytd-reel-shelf-renderer, ytd-reel-video-renderer, a[href^="/shorts"]'
    ).forEach(e => e.remove());
  };

  new MutationObserver(kill).observe(document, {
    childList: true,
    subtree: true
  });

  kill();
})();
