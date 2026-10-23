const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");

function load() {
  let text = "External clipboard";
  const clipboard = { readText: () => text, writeText: (value) => { text = value; } };
  const notices = [];
  class Plugin {
    register(callback) { this.cleanup = callback; }
    registerEvent() {}
  }
  const context = {
    module: { exports: {} },
    require: (name) => name === "electron" ? { clipboard }
      : { Plugin, Notice: class { constructor(message) { notices.push(message); } } },
    window: {}, console,
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "main.js"), "utf8")
    + "\nglobalThis.connectClipboardForTest = connectClipboard;", context);
  return { clipboard, notices, connect: context.connectClipboardForTest, Plugin: context.module.exports, window: context.window };
}

class Register {
  setText(text, linewise = false, blockwise = false) {
    this.text = text; this.linewise = linewise; this.blockwise = blockwise;
  }
  toString() { return this.text || ""; }
}

function controller() {
  const unnamed = new Register();
  const named = new Map();
  return {
    getRegister(name) {
      if (!name || name === '"') return unnamed;
      if (!named.has(name)) named.set(name, new Register());
      return named.get(name);
    },
    pushText(name, operator, text, linewise, blockwise) {
      if (name === "_") return;
      if (linewise && !text.endsWith("\n")) text += "\n";
      if (name) this.getRegister(name).setText(text, linewise, blockwise);
      unnamed.setText(text, linewise, blockwise);
    },
  };
}

test("yanks copy to the clipboard and p reads fresh external text", () => {
  const f = load(), c = controller();
  f.connect(c, f.clipboard, assert.fail);
  c.pushText(undefined, "yank", "hello", false, false);
  assert.equal(f.clipboard.readText(), "hello");
  f.clipboard.writeText("Copied in another app");
  assert.equal(c.getRegister().toString(), "Copied in another app");
  assert.equal(c.getRegister().linewise, false);
});

test("linewise and blockwise yank shape is preserved", () => {
  const f = load(), c = controller();
  f.connect(c, f.clipboard, assert.fail);
  c.pushText(undefined, "yank", "whole line", true, false);
  assert.equal(f.clipboard.readText(), "whole line\n");
  assert.equal(c.getRegister().linewise, true);
  c.pushText('"', "yank", "abc\ndef", false, true);
  assert.equal(c.getRegister().blockwise, true);
  f.clipboard.writeText("External line\n");
  assert.equal(c.getRegister().linewise, true);
  assert.equal(c.getRegister().blockwise, false);
});

test("named registers, black-hole operations, deletes, and changes do not overwrite clipboard", () => {
  const f = load(), c = controller();
  f.connect(c, f.clipboard, assert.fail);
  c.pushText("a", "yank", "Named text", false, false);
  assert.equal(c.getRegister("a").toString(), "Named text");
  c.pushText("_", "yank", "Discarded", false, false);
  c.pushText(undefined, "delete", "Deleted", false, false);
  c.pushText(undefined, "change", "Changed", false, false);
  assert.equal(f.clipboard.readText(), "External clipboard");
  assert.equal(c.getRegister().toString(), "External clipboard");
});

test("empty clipboard doesn't paste stale text", () => {
  const f = load(), c = controller();
  f.connect(c, f.clipboard, assert.fail);
  c.pushText(undefined, "yank", "Old text");
  f.clipboard.writeText("");
  assert.equal(c.getRegister().toString(), "");
});

test("clipboard failures retain Vim operation and are reported", () => {
  const f = load(), c = controller(), errors = [];
  f.connect(c, { readText() { throw Error("read"); }, writeText() { throw Error("write"); } }, (error) => errors.push(error));
  c.pushText(undefined, "yank", "Still yanked");
  assert.equal(c.getRegister().toString(), "Still yanked");
  assert.deepEqual(errors.map((error) => error.message), ["write", "read"]);
});

test("unload restores methods and disables wrappers retained by other plugins", () => {
  const f = load(), c = controller();
  const originalPush = c.pushText, originalGet = c.getRegister;
  const disconnect = f.connect(c, f.clipboard, assert.fail);
  disconnect();
  assert.equal(c.pushText, originalPush);
  assert.equal(c.getRegister, originalGet);
  const disconnectAgain = f.connect(c, f.clipboard, assert.fail);
  const wrapped = c.pushText;
  const otherPlugin = function (...args) { return wrapped.apply(this, args); };
  c.pushText = otherPlugin;
  disconnectAgain();
  assert.equal(c.pushText, otherPlugin);
  c.pushText(undefined, "yank", "Internal only");
  assert.equal(f.clipboard.readText(), "External clipboard");
});

test("lifecycle connects each window/controller once and cleans up", () => {
  const f = load(), c = controller(), original = c.pushText;
  f.window.CodeMirrorAdapter = { Vim: { getRegisterController: () => c } };
  let onLayoutChange;
  const plugin = new f.Plugin();
  plugin.app = { workspace: {
    onLayoutReady: (callback) => callback(),
    iterateAllLeaves: (callback) => callback({ view: { containerEl: { ownerDocument: { defaultView: f.window } } } }),
    on: (name, callback) => { assert.equal(name, "layout-change"); onLayoutChange = callback; },
  } };
  plugin.onload();
  const wrapped = c.pushText;
  onLayoutChange();
  assert.equal(c.pushText, wrapped);
  plugin.cleanup();
  assert.equal(c.pushText, original);
});

const archivePath = "/Applications/Obsidian.app/Contents/Resources/obsidian.asar";
test("compatible with the installed Obsidian Vim register controller", { skip: !fs.existsSync(archivePath) }, () => {
  const archive = fs.readFileSync(archivePath);
  const header = JSON.parse(archive.subarray(16, 16 + archive.readUInt32LE(12)).toString());
  const entry = header.files.lib.files.codemirror.files["vim.js"];
  const start = 8 + archive.readUInt32LE(4) + Number(entry.offset);
  const context = { CodeMirror: { commands: {}, Pos: function (line, ch) { this.line = line; this.ch = ch; } } };
  vm.runInNewContext(archive.subarray(start, start + entry.size).toString(), context);
  const c = context.CodeMirror.Vim.getRegisterController();
  const f = load();
  const original = c.pushText;
  const disconnect = f.connect(c, f.clipboard, assert.fail);
  c.pushText(undefined, "yank", "Real linewise yank", true, false);
  assert.equal(f.clipboard.readText(), "Real linewise yank\n");
  assert.equal(c.getRegister().linewise, true);
  c.pushText(undefined, "delete", "Deleted text", false, false);
  assert.equal(c.getRegister().toString(), "Real linewise yank\n");
  c.pushText("a", "yank", "Named text", false, false);
  assert.equal(c.getRegister("a").toString(), "Named text");
  f.clipboard.writeText("External paste");
  assert.equal(c.getRegister().toString(), "External paste");
  disconnect();
  assert.equal(c.pushText, original);
});
