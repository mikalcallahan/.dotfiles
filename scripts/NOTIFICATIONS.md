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

OpenCode V2 discovers `opencode/plugins/tmux-ai-status/index.js` and its `tui.js`
terminal component. Notification delivery runs in the terminal client so the
helper receives that client's tmux pane/socket and desktop environment, even
when OpenCode uses a shared server. Events are limited to the current session
and open tabs; child-session attention is routed to its root. V2 execution,
text, permission, and form events drive the notifications. Headless server
sessions do not emit desktop notifications through this terminal plugin.

## Setup

1. Install `terminal-notifier` and Python 3; both are available through Homebrew.
2. Allow terminal-notifier notifications when macOS prompts. Choose Banners or
   Alerts in System Settings → Notifications → terminal-notifier.
3. Load tmux hooks with `tmux source-file ~/.config/tmux/tmux.conf`.
4. Run `/reload` in OpenCode to reload the plugin. Restart Claude Code to pick up its
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

### Codex context and status

- A turn ending is labeled **Codex response ready**. It does not imply that the
  requested task succeeded or that no user input is needed; the response preview
  supplies that context. The notify event does not provide task success status.
- The subtitle uses the chat's current name and project directory when available.
  Metadata is read from the matching thread in the local Codex state database in
  read-only mode. This is optional, version-sensitive enrichment: if the database
  is absent, busy, or incompatible, delivery falls back to the latest input message
  or working directory. It never reads another thread's latest response.
- Stored subagent/guardian results are suppressed. Desktop title-generation JSON
  (exactly `title` and `description`) is suppressed only when a readable database
  confirms the event's thread has no stored row. Real stored chats returning that
  JSON and ordinary unknown-thread responses still notify.
- The existing `PermissionRequest` command in `~/.codex/hooks.json` remains valid.
  Its `attention "Permission required"` invocation now consumes the hook's stdin
  JSON, using the Codex session, tool, and human-readable approval reason. Raw tool
  inputs and shell commands are not included. This adapter never approves or denies
  a request and produces no hook output.
- Permission requests and responses share a group by Codex thread, even if their
  inherited terminal context differs. Duplicate completion events for an already
  delivered turn are suppressed; failed deliveries can retry. Older groups for the
  same thread are removed when replaced.
- Clicking a notification from Codex Desktop opens that exact chat via its Codex
  URL. CLI notifications keep terminal/tmux navigation. Desktop source detection
  also prevents inherited tmux variables from routing a desktop chat into a pane.
- These are event notifications, not a live status monitor. No new lifecycle hooks
  are installed, so resuming a Codex chat does not clear its previous alert until
  another notification replaces it or it is opened. Script changes apply on the
  next invocation without a restart or a change to the trusted hook definition.

Markdown previews preserve identifiers such as `RESOURCE_NOT_FOUND`, tool names,
and issue numbers, and omit rendering directives and table separator rows.

Event contracts: [Codex notifications](https://learn.chatgpt.com/docs/config-file/config-advanced#notifications)
and [PermissionRequest hooks](https://learn.chatgpt.com/docs/hooks#permissionrequest).

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
