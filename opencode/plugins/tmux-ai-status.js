import { execFile } from "node:child_process";

const helper = `${process.env.HOME}/.config/scripts/tmux-ai-status`;
const workingSessions = new Set();
const responses = new Map();

function updateStatus(action, detail) {
  execFile(helper, detail ? [action, detail] : [action], () => {});
}

function summarize(text) {
  const cleaned = text
    .replace(/```[\s\S]*?```/g, " ")
    .replace(/`([^`]+)`/g, "$1")
    .replace(/\[([^\]]+)\]\([^)]*\)/g, "$1")
    .replace(/[*_#>|~-]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();

  return cleaned.length > 120 ? `${cleaned.slice(0, 119).trimEnd()}…` : cleaned;
}

export const TmuxAiStatusPlugin = async () => ({
  "chat.message": async ({ sessionID }) => {
    if (sessionID) {
      workingSessions.add(sessionID);
      responses.delete(sessionID);
    }
    updateStatus("clear");
  },
  event: async ({ event }) => {
    const properties = event?.properties ?? {};
    const sessionID = properties.sessionID;

    if (event?.type === "message.updated") {
      const info = properties.info;
      if (
        info?.role === "assistant" &&
        workingSessions.has(sessionID) &&
        responses.get(sessionID)?.messageID !== info.id
      ) {
        responses.set(sessionID, { messageID: info.id, parts: new Map() });
      }
      return;
    }

    if (event?.type === "message.part.updated") {
      const part = properties.part;
      const response = responses.get(sessionID);
      if (
        response?.messageID === part?.messageID &&
        part.type === "text" &&
        !part.synthetic &&
        !part.ignored
      ) {
        response.parts.set(part.id, part.text);
      }
      return;
    }

    if (event?.type !== "session.idle") {
      return;
    }

    if (!sessionID || !workingSessions.delete(sessionID)) {
      return;
    }

    const response = responses.get(sessionID);
    responses.delete(sessionID);
    const detail = summarize(response ? [...response.parts.values()].join("\n") : "");
    updateStatus("complete", detail || "Response completed");
  },
});
