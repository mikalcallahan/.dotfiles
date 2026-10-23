import assert from "node:assert/strict";
import childProcess from "node:child_process";
import { syncBuiltinESMExports } from "node:module";

// Exercise V2 event handling without spawning desktop notifications.
const calls = [];
childProcess.execFile = (_file, args, _options, callback) => {
  calls.push(args);
  callback();
};
syncBuiltinESMExports();
process.env.TMUX = "/test/tmux/socket,123,0";
process.env.TMUX_PANE = "%7";

const { default: server } = await import("../opencode/plugins/tmux-ai-status/index.js");
const { default: plugin } = await import("../opencode/plugins/tmux-ai-status/tui.js");
assert.equal(server.id, "tmux-ai-status");
assert.equal(typeof server.setup, "function");

const sessions = new Map([
  ["root", { location: { directory: "/work/project" } }],
  ["existing-child", { parentID: "root" }],
]);
let listener;
let unsubscribed = false;
let route = { type: "session", sessionID: "root" };
let tabs = [];
const cleanup = plugin.setup({
  location: { directory: "/work/project" },
  data: {
    listen(callback) {
      listener = callback;
      return () => { unsubscribed = true; };
    },
    session: {
      get: (id) => sessions.get(id),
      root: (id) => sessions.get(id)?.parentID || id,
    },
  },
  ui: {
    router: { current: () => route },
    tabs: { enabled: () => true, list: () => tabs },
  },
});
const event = (type, data) => listener({ details: { type, data } });
const flush = () => new Promise((resolve) => setImmediate(resolve));
const expected = (action, message) => [
  "--agent", "opencode", "--session-id", "root", "--cwd", "/work/project",
  "--pane", "%7", "--socket", "/test/tmux/socket", "--", action, message,
];
const start = () => event("session.execution.started", { sessionID: "root" });
const finish = () => event("session.execution.succeeded", { sessionID: "root" });

start();
event("session.step.started", { sessionID: "root", assistantMessageID: "message-1" });
event("session.text.started", { sessionID: "root", assistantMessageID: "message-1", ordinal: 0 });
event("session.text.delta", { sessionID: "root", assistantMessageID: "message-1", ordinal: 0, delta: "Fixed " });
event("session.text.delta", { sessionID: "root", assistantMessageID: "message-1", ordinal: 0, delta: "the **bug**." });
// Final snapshots replace deltas rather than duplicating the response.
event("session.text.ended", { sessionID: "root", assistantMessageID: "message-1", ordinal: 0, text: "Fixed the **bug**." });
finish();
finish();
event("session.idle", { sessionID: "root" });
await flush();
assert.deepEqual(calls.splice(0), [expected("clear", ""), expected("complete", "Fixed the bug.")]);

event("session.created", { sessionID: "child", parentID: "root" });
event("session.execution.started", { sessionID: "child" });
event("permission.asked", { sessionID: "child", action: "shell" });
event("permission.replied", { sessionID: "child" });
event("form.created", { form: { sessionID: "existing-child", title: "Question", fields: [{ description: "Which **environment**?" }] } });
event("form.cancelled", { sessionID: "existing-child" });
event("session.execution.succeeded", { sessionID: "child" });
await flush();
assert.deepEqual(calls.splice(0), [
  expected("attention", "Permission required: shell"), expected("clear", ""),
  expected("attention", "Which environment?"), expected("clear", ""),
]);

start();
event("session.execution.failed", { sessionID: "root", error: { type: "network", message: "Connection failed" } });
finish();
await flush();
assert.deepEqual(calls.splice(0), [expected("clear", ""), expected("error", "Connection failed")]);

start();
event("session.execution.interrupted", { sessionID: "root", reason: "user" });
finish();
await flush();
assert.deepEqual(calls.splice(0), [expected("clear", ""), expected("clear", "")]);

// Shared-server events from other panes must not notify this terminal.
event("session.execution.started", { sessionID: "other" });
event("permission.asked", { sessionID: "other", action: "edit" });
event("form.created", { form: { sessionID: "global", title: "Login" } });
event("session.execution.succeeded", { sessionID: "other" });
await flush();
assert.deepEqual(calls.splice(0), []);

// Open background tabs continue to notify; only the final model step is shown.
route = { type: "home" };
tabs = [{ sessionID: "root" }];
start();
event("session.text.ended", { sessionID: "root", assistantMessageID: "old", ordinal: 0, text: "Let me check." });
event("session.step.started", { sessionID: "root", assistantMessageID: "new" });
event("session.text.ended", { sessionID: "root", assistantMessageID: "new", ordinal: 1, text: "All checks passed." });
event("session.text.ended", { sessionID: "root", assistantMessageID: "new", ordinal: 0, text: "**Done.**" });
finish();
await flush();
assert.deepEqual(calls.splice(0), [expected("clear", ""), expected("complete", "Done. All checks passed.")]);

// Reload mid-execution can still capture subsequent text and completion.
event("session.text.delta", { sessionID: "root", assistantMessageID: "resumed", ordinal: 0, delta: "Resumed." });
finish();
await flush();
assert.deepEqual(calls.splice(0), [expected("complete", "Resumed.")]);

start();
cleanup();
await flush();
assert.equal(unsubscribed, true);
assert.deepEqual(calls, [], "cleanup cancels queued notifications");
console.log("OpenCode V2 notification tests passed (previews, child attention, errors, interruptions, pane isolation, tabs, cleanup).");
