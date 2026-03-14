// ==UserScript==
// @name        Search highlight
// @match       *://*/*
// @run-at      document-end
// ==/UserScript==
(function () {
  const style = document.createElement("style");
  style.textContent = `
    ::selection { background: #f6ff0080; color: #fff; }
  `;
  document.head.appendChild(style);
})();
