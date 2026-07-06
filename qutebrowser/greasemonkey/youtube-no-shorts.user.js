// ==UserScript==
// @name        YouTube Cleanup (No Shorts + Minimal Mini-Guide)
// @match       https://www.youtube.com/*
// @run-at      document-start
// ==/UserScript==
(function() {
  const kill = () => {
    // Remove Shorts shelves, Shorts video renderers, and any Shorts links
    document.querySelectorAll(
      'ytd-reel-shelf-renderer, ytd-reel-video-renderer, a[href^="/shorts"]'
    ).forEach(e => e.remove());

    // Trim mini-guide sidebar down to only the Subscriptions entry
    document.querySelectorAll('ytd-mini-guide-entry-renderer').forEach(e => {
      const label = e.querySelector('a')?.getAttribute('aria-label');
      if (label && label !== 'Subscriptions') e.remove();
    });

    // Trim full expanded guide (hover-out sidebar) down to only Subscriptions
    document.querySelectorAll('ytd-guide-entry-renderer').forEach(e => {
      const a = e.querySelector('a');
      const label = a?.getAttribute('title') || a?.getAttribute('aria-label');
      if (label && label !== 'Subscriptions') e.remove();
    });
  };

  // Debounce so we only run once per animation frame, not on every mutation
  let scheduled = false;
  const scheduleKill = () => {
    if (!scheduled) {
      scheduled = true;
      requestAnimationFrame(() => {
        kill();
        scheduled = false;
      });
    }
  };

  new MutationObserver(scheduleKill).observe(document, {
    childList: true,
    subtree: true
  });

  kill();
})();
