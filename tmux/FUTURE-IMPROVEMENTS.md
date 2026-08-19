# Future Improvements

## Interactive AI completion notifications

Replace the current `osascript` notification with a small local macOS helper app built using system-provided Apple tooling. No third-party dependency should be required.

The helper should:

- Use a custom AI application icon.
- Show a truncated excerpt of the final assistant response in the notification body.
- Preserve the originating tmux session, window, and pane in the notification metadata.
- Focus the originating terminal application when the notification is clicked.
- Switch tmux to the originating session, window, and pane.
- Continue sending notifications only when none of the terminal applications attached to tmux are frontmost.

Creating a dedicated app will likely require separate macOS notification permission.
