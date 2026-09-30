# Agent notifications

`agent-notify` is the shared notification interface for OpenCode, Codex, and
Claude Code. It requires Python 3. The first desktop backend is macOS
`terminal-notifier` (installed with `brew install terminal-notifier`). Linux and
Windows desktop delivery can be added through the `send(record)` / `remove(group)`
backend interface without changing agent hooks.

## Behavior

- Completion, attention, and error notifications include a cleaned response or
  question preview, the agent name, and the working directory.
- A stable group per agent session replaces earlier notifications for that session.
- Clicking activates the terminal application and, inside tmux, switches the
  original attached client to the source pane's current session/window. A zoomed
  window is unzoomed to reveal the pane. A missing client or stale pane does not
  cause a different session to be opened.
- Notifications are suppressed only when the source pane is selected in a focused
  tmux client belonging to the frontmost terminal application.
- Viewing a pane clears its notifications and unread marker. Resuming work also
  clears notifications where the agent provides a prompt/reply hook.
- Outside tmux, desktop notifications still work; clicking activates the terminal
  when its bundle identifier is available. Exact non-tmux tab navigation and
  focus suppression are not implemented.

tmux retains its existing red completion and yellow attention indicators. The
legacy `tmux-ai-status` entry point delegates to `agent-notify`.

## Setup

1. Install `terminal-notifier` and Python 3; both are available through Homebrew.
2. Allow terminal-notifier notifications when macOS prompts. Choose Banners or
   Alerts in System Settings → Notifications → terminal-notifier.
3. Load tmux hooks with `tmux source-file ~/.config/tmux/tmux.conf`.
4. Restart OpenCode to load the updated plugin. Restart Claude Code to pick up its
   hooks in `~/.claude/settings.json`.

Use `terminal-notifier -diagnose` to check permissions and delivery settings.
If the first CLI invocation reports that notifications are not allowed before
macOS has even requested permission, launch the installed app once to register it:

```sh
open -a "$(brew --prefix terminal-notifier)/terminal-notifier.app" --args \
  -title 'Agent notifications' -message 'Notifications are ready.'
```

## Interface

```sh
~/.config/scripts/agent-notify complete 'Tests passed; fixed the login redirect.' \
  --agent opencode --session-id my-session

~/.config/scripts/agent-notify attention 'Which environment should I deploy to?' \
  --agent codex --session-id my-session

~/.config/scripts/agent-notify clear --agent opencode --session-id my-session
```

For structured events, invoke `agent-notify --json` and pass JSON on stdin:

```json
{
  "event": "complete",
  "agent": "opencode",
  "message": "Tests passed; fixed the login redirect.",
  "cwd": "/path/to/project",
  "session_id": "my-session"
}
```

Supported public events: `complete`, `attention`, `error`, `clear`. Session ID is
recommended; without one, grouping falls back to the agent, directory, and pane.
tmux context comes from `TMUX` / `TMUX_PANE`; focus hooks can supply `--socket` and
`--pane` explicitly. `viewed` clears only if that pane is actually being viewed.

The `codex` adapter accepts Codex's notification JSON argument, including
`last-assistant-message` and `thread-id`. `scripts/codex-notify` invokes it, preserving
the existing Codex Computer Use wrapper in `~/.codex/config.toml`.

The `claude` adapter reads hook JSON from stdin, including `last_assistant_message`
for Stop events. Global hooks cover Stop, UserPromptSubmit, PermissionRequest,
and the configured input-needed Notification types.

Navigation metadata and the latest preview are stored in private files under
`${XDG_STATE_HOME:-~/.local/state}/agent-notify/` and removed after successful
clearing. Click callbacks carry only a group ID, never response text or a shell
command supplied by an agent. Their Python/script paths are absolute so callbacks
work without loading shell configuration.

## Verification

```sh
python3 -B -m unittest discover -s scripts -p 'test_*.py' -v
node scripts/test-opencode-notify.mjs
```

For a manual click-through check, send a notification from an agent pane while
another pane is selected, then click it. Verify terminal activation, pane selection,
and removal from Notification Center. To test viewing without clicking, post again
and select the source pane yourself.
