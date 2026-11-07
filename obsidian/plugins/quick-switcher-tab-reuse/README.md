# Quick Switcher Tab Reuse

A local, dependency-free plugin that hooks the native Obsidian Quick Switcher
and Daily Notes commands.
Enable **Quick Switcher Tab Reuse** in Settings → Community plugins and keep
the core **Quick Switcher** enabled. Use the usual **⌘ O** (macOS) or **Ctrl O**
(Windows/Linux), select a file, and press Enter or click the result.

- An already-open file activates its existing tab, preserving its cursor,
  scroll position, and pinned state. This also works for file aliases.
- A file that is not open uses your configured destination (a new tab by default).
- If there are multiple matching tabs, preference is: the active tab, the most
  recently used match in the current tab group, then the most recently used
  match elsewhere. Split panes, popout windows, and deferred tabs are included.
- Ctrl, Cmd, Alt, Shift, and non-left mouse button selections use the native
  handler, including explicit new-tab/split/window shortcuts and Shift+Enter
  note creation. Unresolved links, new note names, and non-file bookmark
  suggestions also use the native handler.
- Disabling the plugin restores the original handlers.

## Daily Notes commands

With the core **Daily Notes** plugin enabled, configure tab behavior separately for:

- **Daily notes: Open today's daily note**
- **Daily notes: Open previous daily note**
- **Daily notes: Open next daily note**

Use these commands through the Command Palette or assigned hotkeys. Today's
note is resolved or created by Daily Notes using its folder, date format, and
template. Previous/Next navigate to the nearest existing daily note relative to
the active daily note, including across skipped days. Their native availability
checks and missing-note notices are preserved.

In **Follow existing tab when open** mode, an already-open daily note is focused
with its view state intact. Otherwise, the note follows **Open unopened files in**.
Today opens new views in editing mode, as the native command does. In Follow mode,
explicit modifier-driven Today navigation uses its native handler; the Always
modes enforce the selected destination. This integration hooks the Command
Palette commands.

## Settings

Under **Settings → Quick Switcher Tab Reuse → Open unopened files in**, choose:

- **New tab** (default): open the selected file in a new, focused tab.
- **Current tab**: open the selected file in the current tab, using Obsidian's
  normal navigation behavior for pinned tabs (another unpinned tab, or a new tab
  if needed).

This setting applies to the Quick Switcher and is the fallback for Daily Notes
commands using **Follow existing tab when open**.

The separate **Daily Notes: Today**, **Daily Notes: Previous**, and **Daily Notes:
Next** settings each offer:

- **Follow existing tab when open** (default): focus an existing tab; if none is
  open, use **Open unopened files in**.
- **Always open in new tab**: create a fresh tab each time, even when the note is
  already open in another tab or the current tab.
- **Always open in current tab**: open directly in the current editor tab, even
  if it is pinned or the note is already open elsewhere. If there is no editor
  tab, Obsidian creates one.

All settings apply immediately and are saved across restarts. Existing
installations default all three Daily Notes settings to **Follow existing tab
when open**, preserving their previous behavior.

The hooks use Obsidian's internal `QuickSwitcherModal.onChooseSuggestion`,
Daily Notes helpers, and command registry; an Obsidian update may require an
adjustment. Reload this plugin after enabling or re-enabling a core plugin so
its current handlers are hooked.

## Installation

Copy `main.js` and `manifest.json` into
`<vault>/.obsidian/plugins/quick-switcher-tab-reuse/`, then enable the plugin.
The source is kept in `~/.config/obsidian/plugins/quick-switcher-tab-reuse/`.
After updating the installed files, reload this plugin.

## Verification

Run `node --test main.test.cjs` here for API-stub regression tests. Live checks
in Obsidian cover native switcher selection, Daily Notes commands, tab reuse,
both destinations, settings, and unloading.
