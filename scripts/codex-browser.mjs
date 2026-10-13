#!/usr/bin/env node
// Reuse the importing project's Playwright; never download a browser or disable its sandbox.
import { createRequire } from "node:module";
import { promises as fs, constants as fsConstants } from "node:fs";
import path from "node:path";
import os from "node:os";
import { pathToFileURL } from "node:url";

const help = `codex-browser --project DIR (--url http://localhost:PORT | --extension DIST --page editor.html)
  [--flow FILE.mjs] [--out NEW_DIRECTORY] [--widths 390,1440] [--executable PATH]
  [--allow-remote]
Flow exports async run({ page, context, viewport }) with actual behavioral assertions.
Optional expectedResponse({ url, status }) classifies intentionally failing HTTP fixtures.
Fresh profiles only. Use synthetic data; inspect images before sharing. No downloads.
Reports runtime failure counts without console contents, headers, bodies, or query strings.
`;

let phase = "arguments";
function diagnostic(error) {
  const names = new Set(["Error", "TypeError", "AssertionError", "TimeoutError"]);
  const codes = new Set(["EACCES", "EPERM", "ENOENT", "EEXIST", "MODULE_NOT_FOUND", "ERR_MODULE_NOT_FOUND", "ERR_PACKAGE_PATH_NOT_EXPORTED"]);
  const message = String(error?.message ?? "");
  const reason = /Failed to move to new namespace|No usable sandbox|unshare|Operation not permitted/i.test(message) ? "sandbox_or_namespace_restriction"
    : /Permission denied|EACCES|EPERM/i.test(message) ? "permission_denied"
    : /Executable doesn't exist|ENOENT/i.test(message) ? "missing_executable"
    : /error while loading shared libraries|missing dependencies/i.test(message) ? "missing_library"
    : /SingletonLock|ProcessSingleton/i.test(message) ? "profile_locked"
    : error?.name === "TimeoutError" ? "timeout" : "unclassified";
  return { kind: names.has(error?.name) ? error.name : "Error", code: codes.has(error?.code) ? error.code : "UNCLASSIFIED", reason };
}

async function main() {
  const args = process.argv.slice(2);
  if (!args.length || args.includes("--help")) { console.log(help); return; }
  const opts = {};
  const flags = new Set(["--allow-remote"]);
  const values = new Set(["--project", "--url", "--extension", "--page", "--flow", "--out", "--widths", "--executable"]);
  while (args.length) {
    const key = args.shift();
    if (flags.has(key)) opts[key] = true;
    else if (values.has(key) && args.length && !args[0].startsWith("--")) opts[key] = args.shift();
    else throw new Error(`Unknown or incomplete option: ${key}`);
  }
  if (!opts["--project"] || !!opts["--url"] === !!opts["--extension"]) throw new Error("Choose a project and exactly one URL or extension.");
  const project = path.resolve(opts["--project"]);
  if (opts["--url"]) {
    const url = new URL(opts["--url"]);
    if (url.username || url.password || !["http:", "https:"].includes(url.protocol)) throw new Error("Use an HTTP URL without credentials.");
    if (!opts["--allow-remote"] && !["localhost", "127.0.0.1", "[::1]"].includes(url.hostname)) throw new Error("Remote URLs require --allow-remote.");
  }
  const widths = (opts["--widths"] ?? "390,1440").split(",").map(Number);
  if (widths.some(w => !Number.isInteger(w) || w < 200 || w > 4000) || new Set(widths).size !== widths.length) throw new Error("Use distinct viewport widths between 200 and 4000.");
  phase = "browser executable selection";
  let executable = opts["--executable"] ?? process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH;
  if (!executable) {
    const candidates = (process.env.PATH ?? "").split(path.delimiter).filter(Boolean).map(dir => path.join(dir, "chromium"));
    candidates.push(path.join("/etc/profiles/per-user", os.userInfo().username, "bin/chromium"));
    for (const candidate of candidates) {
      try { await fs.access(candidate, fsConstants.X_OK); executable = candidate; break; }
      catch { /* Try the next existing executable; no shell/which dependency. */ }
    }
    if (!executable) throw new Error("Set --executable to an existing Chromium; this command does not install browsers.");
  }
  phase = "project Playwright resolution";
  const requireProject = createRequire(path.join(project, "package.json"));
  let requirePlaywright;
  try {
    const requireTest = createRequire(requireProject.resolve("@playwright/test/package.json"));
    requirePlaywright = createRequire(requireTest.resolve("playwright/package.json"));
  } catch { requirePlaywright = createRequire(requireProject.resolve("playwright/package.json")); }
  const { chromium } = requirePlaywright("playwright-core");
  const version = requirePlaywright("playwright-core/package.json").version;
  phase = "scenario loading";
  const flow = opts["--flow"] ? await import(pathToFileURL(path.resolve(opts["--flow"]))) : {};
  if (opts["--flow"] && typeof flow.run !== "function") throw new Error("Flow must export run().");
  if (flow.expectedResponse && typeof flow.expectedResponse !== "function") throw new Error("expectedResponse must be a function.");
  phase = "evidence directory creation";
  const out = opts["--out"] ? path.resolve(opts["--out"]) : await fs.mkdtemp(path.join(os.tmpdir(), "codex-browser-"));
  if (opts["--out"]) await fs.mkdir(out, { mode: 0o700 }); // Refuse to overwrite previous evidence.
  const results = [];
  for (const width of widths) {
    const viewport = { width, height: width < 600 ? 844 : 900 };
    const counts = { pageerror: 0, consoleError: 0, failedRequest: 0, httpError: 0, expectedHttpError: 0 };
    let browser, context, page, stage = "browser launch";
    const result = { viewport, counts, status: "FAIL", screenshot: `${width}.png`, trace: `${width}.zip` };
    const file = name => path.join(out, name);
    try {
      if (opts["--extension"]) {
        const extension = await fs.realpath(opts["--extension"]);
        await fs.access(path.join(extension, "manifest.json"));
        context = await chromium.launchPersistentContext("", {
          executablePath: executable, chromiumSandbox: true, headless: false, viewport,
          args: ["--headless=new", `--disable-extensions-except=${extension}`, `--load-extension=${extension}`]
        });
      } else {
        browser = await chromium.launch({ executablePath: executable, chromiumSandbox: true });
        context = await browser.newContext({ viewport });
      }
      context.setDefaultTimeout(30000);
      context.setDefaultNavigationTimeout(30000);
      result.chromium = (browser ?? context.browser())?.version() ?? null;
      stage = "trace startup";
      await context.tracing.start({ screenshots: true, snapshots: true, sources: true });
      const watchPage = observed => observed.on("pageerror", () => counts.pageerror++);
      context.on("page", watchPage);
      context.pages().forEach(watchPage);
      context.on("console", msg => { if (msg.type() === "error") counts.consoleError++; });
      context.on("requestfailed", () => counts.failedRequest++);
      context.on("response", response => {
        if (response.status() >= 400) {
          try {
            const classification = flow.expectedResponse?.({ url: response.url(), status: response.status() });
            if (classification && typeof classification.then === "function") {
              // Classifiers are synchronous. Consume rejection without printing application data.
              Promise.resolve(classification).catch(() => {});
              counts.httpError++;
            } else if (classification === true) counts.expectedHttpError++;
            else counts.httpError++;
          } catch { counts.httpError++; }
        }
      });
      page = await context.newPage();
      let target = opts["--url"];
      if (opts["--extension"]) {
        const worker = context.serviceWorkers()[0] ?? await context.waitForEvent("serviceworker", { timeout: 10000 });
        const extensionPage = opts["--page"] ?? "editor.html";
        target = new URL(extensionPage, `chrome-extension://${new URL(worker.url()).host}/`).href;
        if (!target.startsWith(`chrome-extension://${new URL(worker.url()).host}/`)) throw new Error("Extension page must remain in the loaded extension origin.");
      }
      // A local entry URL is not an egress boundary: apps/flows may request remote assets.
      stage = "navigation";
      await page.goto(target, { waitUntil: "domcontentloaded", timeout: 30000 });
      stage = "flow assertions";
      await flow.run?.({ page, context, viewport });
      await page.evaluate(() => document.fonts.ready);
      result.horizontalOverflow = await page.evaluate(() => Math.max(0, document.documentElement.scrollWidth - innerWidth));
      result.status = Object.entries(counts).every(([key, value]) => key === "expectedHttpError" || value === 0) ? "PASS" : "FAIL";
    } catch (error) {
      // Raw exception strings can contain page content, URLs, or application secrets.
      result.failure = { stage, ...diagnostic(error) };
    } finally {
      if (page && !page.isClosed()) {
        try { await page.screenshot({ path: file(result.screenshot), fullPage: true, timeout: 5000 }); }
        catch { result.screenshot = null; result.status = "FAIL"; }
      } else result.screenshot = null;
      if (context) {
        try { await context.tracing.stop({ path: file(result.trace) }); }
        catch { result.trace = null; result.status = "FAIL"; }
        try { await context.close(); } catch { result.status = "FAIL"; }
      } else result.trace = null;
      if (browser) await browser.close();
      // Include errors from popups and from screenshot/trace capture, not just navigation.
      if (Object.entries(counts).some(([key, value]) => key !== "expectedHttpError" && value > 0)) result.status = "FAIL";
    }
    results.push(result);
  }
  const report = { project, playwright: version, executable, results,
    limitations: "Screenshots/traces may contain sensitive page data. Inspect before sharing. Overflow is measured, not an accessibility verdict. No automatic visual comparison." };
  await fs.writeFile(path.join(out, "results.json"), JSON.stringify(report, null, 2) + "\n", { mode: 0o600 });
  console.log(JSON.stringify({ evidence: out, playwright: version, results }, null, 2));
  if (results.some(r => r.status !== "PASS")) process.exitCode = 1;
}
main().catch(error => { console.error(`Browser evidence failed at ${phase}: ${JSON.stringify(diagnostic(error))}. Use --help.`); process.exitCode = 1; });
