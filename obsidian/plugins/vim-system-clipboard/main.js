const { Plugin, Notice } = require("obsidian");
const { clipboard } = require("electron");

function connectClipboard(controller, clipboard, reportError) {
  const originalPush = controller.pushText;
  const originalGet = controller.getRegister;
  let active = true;
  let lastYank = null;
  const isDefault = (name) => !name || name === '"';

  function pushText(name, operator, ...args) {
    const result = originalPush.call(this, name, operator, ...args);
    if (active && operator === "yank" && isDefault(name)) {
      try {
        const register = originalGet.call(this, '"');
        const text = register.toString();
        clipboard.writeText(text);
        lastYank = { text, linewise: register.linewise, blockwise: register.blockwise };
      } catch (error) {
        reportError(error);
      }
    }
    return result;
  }

  function getRegister(name) {
    const register = originalGet.call(this, name);
    if (active && isDefault(name)) {
      try {
        const text = clipboard.readText();
        // Preserve Vim's shape for our own yanks; infer linewise external text
        // from a trailing newline. Clipboard text alone has no block metadata.
        const shape = lastYank?.text === text ? lastYank : { linewise: text.endsWith("\n"), blockwise: false };
        register.setText(text, shape.linewise, shape.blockwise);
      } catch (error) {
        reportError(error);
      }
    }
    return register;
  }

  controller.pushText = pushText;
  controller.getRegister = getRegister;
  return () => {
    active = false;
    // Do not remove wrappers installed later by another plugin.
    if (controller.pushText === pushText) controller.pushText = originalPush;
    if (controller.getRegister === getRegister) controller.getRegister = originalGet;
  };
}

module.exports = class VimSystemClipboard extends Plugin {
  onload() {
    const connected = new Set();
    const cleanups = [];
    this.register(() => cleanups.forEach((cleanup) => cleanup()));

    const connectWindow = (win) => {
      // Obsidian exposes its bundled Vim engine here. This is an internal API;
      // guard access so an incompatible update doesn't break the editor.
      const controller = win?.CodeMirrorAdapter?.Vim?.getRegisterController?.();
      if (!controller || connected.has(controller)) return;
      if (typeof controller.pushText !== "function" || typeof controller.getRegister !== "function") return;
      const register = controller.getRegister('"');
      if (typeof register?.setText !== "function") return;
      cleanups.push(connectClipboard(controller, clipboard, (error) => {
        console.error("Vim System Clipboard failed", error);
        new Notice("Vim System Clipboard could not access the system clipboard.");
      }));
      connected.add(controller);
    };

    const connectEditors = () => {
      connectWindow(window);
      this.app.workspace.iterateAllLeaves((leaf) => {
        connectWindow(leaf.view.containerEl.ownerDocument.defaultView);
      });
    };
    this.app.workspace.onLayoutReady(() => {
      connectEditors();
      if (!connected.size) new Notice("Vim System Clipboard: Vim engine unavailable. Open a note in edit mode and enable Vim key bindings.");
    });
    this.registerEvent(this.app.workspace.on("layout-change", connectEditors));
  }
};
