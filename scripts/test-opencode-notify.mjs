import assert from "node:assert/strict";
import childProcess from "node:child_process";
import { syncBuiltinESMExports } from "node:module";

// Exercise real plugin event handling without spawning desktop notifications.
const calls = [];
childProcess.execFile = (_file, args, _options, callback) => {
  calls.push(args);
  callback();
};
syncBuiltinESMExports();
const { TmuxAiStatusPlugin } = await import("../opencode/plugins/tmux-ai-status.js");
const hooks = await TmuxAiStatusPlugin();
const event = (type, properties) => hooks.event({ event: { type, properties } });
const flush = () => new Promise((resolve) => setImmediate(resolve));
const expected = (action, message) => ["--agent", "opencode", "--session-id", "root", "--", action, message];

await hooks["chat.message"]({ sessionID: "root" });
await event("message.updated", { info: { role: "assistant", sessionID: "root", id: "message-1" } });
await event("message.part.updated", {
  part: { sessionID: "root", messageID: "message-1", id: "part-1", type: "text", text: "Fixed " },
});
await event("message.part.delta", {
  sessionID: "root", messageID: "message-1", partID: "part-1", field: "text", delta: "the **bug**.",
});
await event("session.idle", { sessionID: "root" });
await event("session.idle", { sessionID: "root" });
await flush();
assert.deepEqual(calls, [
  expected("clear", ""),
  expected("complete", "Fixed the bug."),
]);

calls.length = 0;
await event("session.created", { info: { id: "child", parentID: "root" } });
await hooks["chat.message"]({ sessionID: "child" });
await event("permission.asked", { sessionID: "child", permission: "bash" });
await event("session.idle", { sessionID: "child" });
await flush();
assert.deepEqual(calls, [
  expected("attention", "Permission required: bash"),
]);

calls.length = 0;
await hooks["chat.message"]({ sessionID: "root" });
await event("session.error", { sessionID: "root", error: { data: { message: "Connection failed" } } });
await event("session.idle", { sessionID: "root" });
await flush();
assert.equal(calls.length, 2);
assert.deepEqual(calls[1], expected("error", "Connection failed"));
console.log("OpenCode notification event tests passed (previews, deltas, deduplication, child sessions, errors).");
