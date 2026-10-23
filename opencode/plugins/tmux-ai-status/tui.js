import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

function summarize(text) {
  const cleaned = String(text)
    .replace(/```[\s\S]*?```/g, " ")
    .replace(/`([^`]+)`/g, "$1")
    .replace(/\[([^\]]+)\]\([^)]*\)/g, "$1")
    .replace(/[*_#>|~]+/g, "")
    .replace(/\s+/g, " ")
    .trim();

  return cleaned.length > 120 ? `${cleaned.slice(0, 119).trimEnd()}…` : cleaned;
}

export default {
  id: "tmux-ai-status",
  setup(ctx) {
    const helper = join(homedir(), ".config/scripts/agent-notify");
    const pane = process.env.TMUX_PANE;
    const socket = process.env.TMUX?.split(",")[0];
    const workingSessions = new Set();
    const responses = new Map();
    const parents = new Map();
    let pending = Promise.resolve();
    let disposed = false;

    function rootSession(sessionID) {
      const seen = new Set();
      while (sessionID && !seen.has(sessionID)) {
        seen.add(sessionID);
        const parent = parents.get(sessionID) || ctx.data.session.get(sessionID)?.parentID;
        if (!parent) return ctx.data.session.root(sessionID);
        sessionID = parent;
      }
      return sessionID;
    }

    function isOpen(sessionID) {
      const route = ctx.ui.router.current();
      return (route.type === "session" && rootSession(route.sessionID) === sessionID) ||
        (ctx.ui.tabs.enabled() && ctx.ui.tabs.list().some((tab) => tab.sessionID === sessionID));
    }

    function updateStatus(action, detail, sessionID) {
      const directory = ctx.data.session.get(sessionID)?.location.directory ||
        ctx.location?.directory || ctx.data.location.default().directory;
      const args = ["--agent", "opencode", "--session-id", sessionID];
      if (directory) args.push("--cwd", directory);
      if (pane && socket) args.push("--pane", pane, "--socket", socket);
      args.push("--", action, detail || "");
      // Preserve event order without blocking the UI on notification delivery.
      pending = pending.then(() => {
        if (disposed) return;
        return new Promise((resolve) => {
          execFile(helper, args, { timeout: 15000 }, (error) => {
            if (error) console.warn(`tmux-ai-status: notification helper failed (${error.code || "unknown"})`);
            resolve();
          });
        });
      });
    }

    const stop = ctx.data.listen(({ details: event }) => {
      const data = event.data;
      const sessionID = data?.sessionID || data?.form?.sessionID;
      if (!sessionID || sessionID === "global") return;

      if (event.type === "session.created" && data.parentID) {
        parents.set(sessionID, data.parentID);
      }
      if (event.type === "session.deleted") {
        parents.delete(sessionID);
        workingSessions.delete(sessionID);
        responses.delete(sessionID);
        return;
      }

      const rootID = rootSession(sessionID);
      // The server stream includes other clients' sessions and locations.
      if (!rootID || !isOpen(rootID)) return;

      if (event.type === "permission.asked") {
        updateStatus("attention", `Permission required: ${data.action}`, rootID);
        return;
      }
      if (event.type === "form.created") {
        const field = data.form.fields?.[0];
        updateStatus("attention", summarize(field?.description || field?.title || data.form.title || "Input required"), rootID);
        return;
      }
      if (["permission.replied", "form.replied", "form.cancelled"].includes(event.type)) {
        updateStatus("clear", "", rootID);
        return;
      }

      // Child attention is routed to its root; only root execution finishes it.
      if (sessionID !== rootID) return;

      if (event.type === "session.execution.started") {
        workingSessions.add(sessionID);
        responses.delete(sessionID);
        updateStatus("clear", "", sessionID);
        return;
      }
      if (event.type === "session.step.started") {
        workingSessions.add(sessionID);
        responses.set(sessionID, { messageID: data.assistantMessageID, parts: new Map() });
        return;
      }
      if (["session.text.started", "session.text.delta", "session.text.ended"].includes(event.type)) {
        workingSessions.add(sessionID);
        let response = responses.get(sessionID);
        if (response?.messageID !== data.assistantMessageID) {
          response = { messageID: data.assistantMessageID, parts: new Map() };
          responses.set(sessionID, response);
        }
        if (event.type === "session.text.delta") {
          response.parts.set(data.ordinal, (response.parts.get(data.ordinal) || "") + data.delta);
        } else {
          response.parts.set(data.ordinal, data.text || "");
        }
        return;
      }
      if (event.type === "session.execution.failed") {
        updateStatus("error", summarize(data.error.message || "Session error"), sessionID);
        workingSessions.delete(sessionID);
        responses.delete(sessionID);
        return;
      }
      if (event.type === "session.execution.interrupted") {
        updateStatus("clear", "", sessionID);
        workingSessions.delete(sessionID);
        responses.delete(sessionID);
        return;
      }
      if (event.type !== "session.execution.succeeded" || !workingSessions.delete(sessionID)) return;

      const response = responses.get(sessionID);
      responses.delete(sessionID);
      const detail = summarize(response
        ? [...response.parts.entries()].sort(([a], [b]) => a - b).map(([, text]) => text).join("\n")
        : "");
      updateStatus("complete", detail || "Response completed", sessionID);
    });

    return () => {
      disposed = true;
      stop();
      workingSessions.clear();
      responses.clear();
      parents.clear();
    };
  },
};
