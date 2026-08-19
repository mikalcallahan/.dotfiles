import { execFile } from "node:child_process";

const helper = `${process.env.HOME}/.config/scripts/tmux-ai-status`;
const workingSessions = new Set();

function updateStatus(action) {
  execFile(helper, [action], () => {});
}

export const TmuxAiStatusPlugin = async () => ({
  "chat.message": async ({ sessionID }) => {
    if (sessionID) {
      workingSessions.add(sessionID);
    }
    updateStatus("clear");
  },
  event: async ({ event }) => {
    if (event?.type !== "session.idle") {
      return;
    }

    const sessionID = event.properties?.sessionID;
    if (!sessionID || !workingSessions.delete(sessionID)) {
      return;
    }
    updateStatus("complete");
  },
});
