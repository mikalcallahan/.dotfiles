import { execFile } from "node:child_process";

const helper = `${process.env.HOME}/.config/scripts/agent-notify`;
const workingSessions = new Set();
const responses = new Map();
const parents = new Map();
let pending = Promise.resolve();

function updateStatus(action, detail, sessionID) {
  while (parents.has(sessionID)) sessionID = parents.get(sessionID);
  const args = ["--agent", "opencode"];
  if (sessionID) args.push("--session-id", sessionID);
  args.push("--", action, detail || "");
  // Preserve event order without blocking the agent on notification delivery.
  pending = pending.then(() => new Promise((resolve) => {
    execFile(helper, args, { timeout: 15000 }, () => resolve());
  }));
}

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

export const TmuxAiStatusPlugin = async () => ({
  "chat.message": async ({ sessionID }) => {
    if (parents.has(sessionID)) return;
    if (sessionID) {
      workingSessions.add(sessionID);
      responses.delete(sessionID);
    }
    updateStatus("clear", "", sessionID);
  },
  event: async ({ event }) => {
    const properties = event?.properties ?? {};
    const sessionID = properties.sessionID || properties.info?.sessionID || properties.part?.sessionID;
    if (event?.type?.startsWith("session.") && properties.info?.parentID && properties.info?.id) {
      parents.set(properties.info.id, properties.info.parentID);
    }

    if (event?.type === "permission.asked") {
      const detail = properties.permission
        ? `Permission required: ${properties.permission}`
        : "Permission required";
      updateStatus("attention", detail, sessionID);
      return;
    }

    if (event?.type === "question.asked") {
      const question = properties.questions?.[0];
      updateStatus(
        "attention",
        summarize(question?.question || question?.header || "Input required"),
        sessionID,
      );
      return;
    }

    if (event?.type === "session.error") {
      const error = properties.error;
      updateStatus(
        "error",
        summarize(error?.data?.message || error?.name || "Session error"),
        sessionID,
      );
      workingSessions.delete(sessionID);
      responses.delete(sessionID);
      return;
    }

    if (
      event?.type === "permission.replied" ||
      event?.type === "question.replied" ||
      event?.type === "question.rejected"
    ) {
      updateStatus("clear", "", sessionID);
      return;
    }

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

    if (event?.type === "message.part.delta") {
      const response = responses.get(sessionID);
      if (response?.messageID === properties.messageID &&
          properties.field === "text" && response.parts.has(properties.partID)) {
        response.parts.set(properties.partID,
          response.parts.get(properties.partID) + properties.delta);
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
    updateStatus("complete", detail || "Response completed", sessionID);
  },
});
