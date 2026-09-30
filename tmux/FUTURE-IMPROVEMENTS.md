# Future Improvements

## Agent notifications

Implemented using the shared `scripts/agent-notify` interface and the macOS
terminal-notifier backend: response previews, per-session replacement,
click-to-pane navigation, and clearing when viewed. See
[`scripts/NOTIFICATIONS.md`](../scripts/NOTIFICATIONS.md) for setup and behavior.

Possible follow-ups:

- Linux and Windows notification backends.
- Native session navigation for Herdr and non-tmux terminal tabs.
- Action buttons, snoozing, and agent-specific reply handling.
- Optional phone escalation for agents waiting for input.
