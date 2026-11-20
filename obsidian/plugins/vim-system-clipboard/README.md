# Vim System Clipboard

A small, desktop-only Obsidian plugin with no dependencies, build step, settings,
key remappings, clipboard polling, or background clipboard history.

Run `python3 ~/.config/obsidian/sync-plugins.py` to link the runtime files from
this checkout into your registered vaults. See the
[shared setup instructions](../../README.md) for other machines.

Enable **Vim System Clipboard** under Settings → Community plugins. Reload
Obsidian if it isn't listed. Enable **Vim key bindings** under Settings → Editor
(already enabled in this vault).

- `yy`, `yiw`, `y` with motions, and visual-mode `y` copy to the system clipboard.
- Deletes and changes (`dd`, `dw`, `x`, `cc`, `ciw`, and visual-mode `d`/`c`) also
  copy the removed text to the system clipboard.
- `p` and `P` read the system clipboard, including text copied from other apps.
- Linewise and blockwise yanks, deletes, and changes preserve their Vim paste
  behavior while the clipboard text still matches. External text ending in a
  newline is treated as linewise; other external text is characterwise.
- Explicit named registers (`"ayy`, `"add`, `"ap`) retain their normal behavior.
  Named-register and black-hole (`"_dd`) operations do not overwrite the system
  clipboard. Vim's numbered and small-delete registers still work normally.
- Disabling the plugin restores the original register methods.

This uses Electron's synchronous clipboard API to avoid async paste races.
Clipboard content stays on your computer and is never written to plugin data.

The plugin uses Obsidian's internal `window.CodeMirrorAdapter.Vim` bridge,
verified against the installed app. A future Obsidian update may require an
adjustment. Avoid enabling another plugin that also replaces Vim clipboard behavior.

Run `node --test main.test.cjs` in this directory for API-stub tests. Live editor
behavior still needs to be checked in Obsidian after enabling the plugin.
