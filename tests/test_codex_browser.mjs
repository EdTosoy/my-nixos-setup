import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

const helper = fileURLToPath(new URL("../scripts/codex-browser.mjs", import.meta.url));

for (const [scenario, expected] of [
  ["complete", 0],
  ["closed-page", 1],
  ["screenshot-failure", 1],
  ["trace-failure", 1],
]) {
  test(`browser evidence: ${scenario}`, t => {
    const project = mkdtempSync(path.join(os.tmpdir(), "codex-browser-test-"));
    t.after(() => rmSync(project, { recursive: true, force: true }));

    for (const name of ["playwright", "playwright-core"]) {
      const pkg = path.join(project, "node_modules", name);
      mkdirSync(pkg, { recursive: true });
      writeFileSync(path.join(pkg, "package.json"), '{"version":"0.0.0"}');
    }

    writeFileSync(path.join(project, "node_modules/playwright-core/index.js"), `
      const { writeFileSync } = require("node:fs");
      const scenario = ${JSON.stringify(scenario)};
      let evaluations = 0;
      const page = {
        async goto() {},
        async evaluate() { evaluations++; return 0; },
        isClosed() { return scenario === "closed-page" && evaluations === 2; },
        async screenshot({ path }) {
          if (scenario === "screenshot-failure") throw new Error("screenshot fixture");
          writeFileSync(path, "");
        },
      };
      const context = {
        setDefaultTimeout() {},
        setDefaultNavigationTimeout() {},
        on() {},
        pages() { return []; },
        async newPage() { return page; },
        async close() {},
        tracing: {
          async start() {},
          async stop({ path }) {
            if (scenario === "trace-failure") throw new Error("trace fixture");
            writeFileSync(path, "");
          },
        },
      };
      exports.chromium = {
        async launch() {
          return { version: () => "fixture", newContext: async () => context, async close() {} };
        },
      };
    `);

    const out = path.join(project, "report");
    const run = spawnSync(process.execPath, [
      helper, "--project", project, "--url", "http://localhost:3000",
      "--widths", "390", "--out", out, "--executable", process.execPath,
    ], { encoding: "utf8" });
    assert.equal(run.status, expected, run.stderr || run.stdout);
    const { results: [viewport] } = JSON.parse(readFileSync(path.join(out, "results.json"), "utf8"));
    assert.equal(viewport.status, expected === 0 ? "PASS" : "FAIL");
    assert.equal(viewport.screenshot, ["closed-page", "screenshot-failure"].includes(scenario) ? null : "390.png");
    assert.equal(viewport.trace, scenario === "trace-failure" ? null : "390.zip");
  });
}
