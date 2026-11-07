const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");

async function fixture({ ready = true, available = true, data, dailyEnabled = false } = {}) {
  const notices = [];
  const errors = [];
  const nativeCalls = [];
  const reveals = [];
  const opens = [];
  const activations = [];
  const leaves = [];
  const layoutCallbacks = [];
  const controls = [];
  const saves = [];
  const nativeDailyCalls = [];
  const group = {};
  class FileView {
    constructor(file) { this.file = file; }
  }
  class Plugin {
    constructor() { this.cleanups = []; }
    register(callback) { this.cleanups.push(callback); }
    addSettingTab(tab) { this.settingTab = tab; }
    async loadData() { return data; }
    async saveData(settings) { saves.push(JSON.parse(JSON.stringify(settings))); }
    unload() { this.cleanups.splice(0).reverse().forEach((callback) => callback()); }
  }
  class Setting {
    constructor() { controls.push(this); }
    setName(name) { this.name = name; return this; }
    setDesc() { return this; }
    addDropdown(callback) {
      this.dropdown = {
        options: {},
        addOption(value, label) { this.options[value] = label; return this; },
        setValue(value) { this.value = value; return this; },
        onChange(callback) { this.change = callback; return this; },
      };
      callback(this.dropdown);
      return this;
    }
  }
  class QuickSwitcherModal {
    constructor(app) { this.app = app; }
    onChooseSuggestion(...args) {
      nativeCalls.push({ modal: this, args });
      return "native";
    }
  }
  function leaf(filePath, { parent = group, time = 0, deferred = false, panel = false, pinned = false } = {}) {
    const item = {
      parent, activeTime: time, isDeferred: deferred, pinned,
      view: deferred || panel ? {} : new FileView({ path: filePath }),
      getViewState: () => ({ state: { file: filePath } }),
      async openFile(file, options) {
        opens.push({ leaf: item, file, options });
        item.view = new FileView(file);
        if (options.active) app.workspace.activeLeaf = item;
      },
    };
    leaves.push(item);
    parent.children ??= [];
    parent.children.push(item);
    return item;
  }
  const current = leaf("Current.md");
  const app = {
    internalPlugins: { plugins: available ? { switcher: { instance: { QuickSwitcherModal } } } : {} },
    commands: { commands: {} },
    workspace: {
      activeLeaf: current,
      getMostRecentLeaf() { return this.activeLeaf; },
      iterateAllLeaves: (callback) => leaves.forEach(callback),
      onLayoutReady: (callback) => ready ? callback() : layoutCallbacks.push(callback),
      async revealLeaf(item) { reveals.push(item); item.isDeferred = false; },
      setActiveLeaf(item, options) { activations.push({ leaf: item, options }); this.activeLeaf = item; },
      getLeaf(type) {
        assert.ok(type === "tab" || type === false);
        if (type === false && !this.activeLeaf.pinned) return this.activeLeaf;
        return leaf(undefined);
      },
      createLeafInParent(parent, index) {
        const created = leaf(undefined, { parent });
        parent.children.splice(parent.children.indexOf(created), 1);
        parent.children.splice(index, 0, created);
        this.activeLeaf = created;
        return created;
      },
    },
  };
  const dailyFiles = [2, 4, 7].map((day) => ({ path: `Journal/2026/11/0${day}.md`, timestamp: day }));
  const daily = {
    today: dailyFiles[1], lookups: 0, enumerations: 0,
    async getDailyNote() { this.lookups++; return this.today; },
    getCurrentFileDateTimestamp() {
      return dailyFiles.find((file) => file.path === app.workspace.activeLeaf.view.file?.path)?.timestamp ?? null;
    },
    iterateDailyNotes(callback) {
      this.enumerations++;
      // Deliberately unsorted; neighboring notes are separated by skipped days.
      for (const file of [dailyFiles[2], dailyFiles[0], dailyFiles[1]]) callback(file, file.timestamp);
    },
  };
  if (dailyEnabled) {
    app.internalPlugins.plugins["daily-notes"] = { instance: daily };
    app.commands.commands["daily-notes"] = {
      callback(...args) { nativeDailyCalls.push({ id: "daily-notes", args }); return "native-today"; },
    };
    for (const id of ["daily-notes:goto-prev", "daily-notes:goto-next"]) {
      app.commands.commands[id] = {
        checkCallback(checking) {
          const available = Boolean(daily.getCurrentFileDateTimestamp());
          if (available && !checking) nativeDailyCalls.push({ id });
          return available;
        },
      };
    }
  }
  const originalDaily = Object.fromEntries(Object.entries(app.commands.commands)
    .map(([id, command]) => [id, { ...command }]));
  const obsidian = {
    Plugin, FileView, Setting,
    Keymap: { isModEvent: (event) => event.metaKey || event.ctrlKey ? (event.altKey ? "split" : true) : false },
    PluginSettingTab: class { constructor() { this.containerEl = { empty() {} }; } },
    Notice: class { constructor(message) { notices.push(message); } },
  };
  const context = vm.createContext({
    module: { exports: {} },
    require(name) { assert.equal(name, "obsidian"); return obsidian; },
    console: { error: (...args) => errors.push(args) },
  });
  vm.runInContext(fs.readFileSync(path.join(__dirname, "main.js"), "utf8"), context);
  const plugin = new context.module.exports();
  plugin.app = app;
  const prototype = QuickSwitcherModal.prototype;
  const original = prototype.onChooseSuggestion;
  const modal = new QuickSwitcherModal(app);
  await plugin.onload();
  return {
    app, plugin, prototype, original, modal, leaf, leaves, current, group,
    notices, errors, nativeCalls, reveals, opens, activations, controls, saves,
    daily, dailyFiles, nativeDailyCalls, originalDaily,
    runDaily: async (id) => {
      const command = app.commands.commands[id];
      const result = command.callback ? await command.callback() : command.checkCallback(false);
      // Check callbacks return a synchronous boolean while navigation is async.
      await new Promise(setImmediate);
      return result;
    },
    ready: () => layoutCallbacks.splice(0).forEach((callback) => callback()),
    choose: (filePath, event = {}, type = "file") => modal.onChooseSuggestion({ type, file: { path: filePath } }, event),
  };
}

test("focuses a pinned existing tab without reopening it or adding a tab", async () => {
  const f = await fixture();
  const target = f.leaf("Target.md", { pinned: true });
  target.cursor = { line: 12, ch: 3 };
  target.scroll = 240;
  await f.choose("Target.md");
  assert.deepEqual(f.reveals, [target]);
  assert.equal(f.app.workspace.activeLeaf, target);
  assert.equal(f.activations[0].options.focus, true);
  assert.equal(f.leaves.length, 2);
  assert.equal(f.opens.length, 0);
  assert.equal(target.pinned, true);
  assert.deepEqual(target.cursor, { line: 12, ch: 3 });
  assert.equal(target.scroll, 240);
});

test("opens an unopened file in a new focused tab", async () => {
  const f = await fixture();
  await f.choose("New.md");
  assert.equal(f.leaves.length, 2);
  assert.equal(f.opens[0].file.path, "New.md");
  assert.equal(f.opens[0].options.active, true);
  assert.notEqual(f.opens[0].leaf, f.current);
  assert.equal(f.current.view.file.path, "Current.md");
  assert.equal(f.nativeCalls.length, 0);
});

test("alias selections reuse the target file's tab", async () => {
  const f = await fixture();
  const target = f.leaf("Target.md");
  await f.choose("Target.md", {}, "alias");
  assert.equal(f.app.workspace.activeLeaf, target);
  assert.equal(f.opens.length, 0);
});

test("prefers the active matching tab over other copies", async () => {
  const f = await fixture();
  f.leaf("Current.md", { time: 100 });
  await f.choose("Current.md");
  assert.equal(f.app.workspace.activeLeaf, f.current);
});

test("prefers the most recently used match in the current tab group", async () => {
  const f = await fixture();
  f.leaf("Target.md", { time: 100, parent: {} });
  f.leaf("Target.md", { time: 1 });
  const target = f.leaf("Target.md", { time: 2 });
  await f.choose("Target.md");
  assert.equal(f.app.workspace.activeLeaf, target);
});

test("reuses the most recent matching split or popout tab when none is in this group", async () => {
  const f = await fixture();
  f.leaf("Target.md", { time: 1, parent: {} });
  const target = f.leaf("Target.md", { time: 2, parent: {} });
  await f.choose("Target.md");
  assert.deepEqual(f.reveals, [target]);
  assert.equal(f.app.workspace.activeLeaf, target);
  assert.equal(f.opens.length, 0);
});

test("finds and reveals deferred tabs by saved path, including non-Markdown files", async () => {
  const f = await fixture();
  const target = f.leaf("Diagram.canvas", { deferred: true });
  await f.choose("Diagram.canvas");
  assert.equal(f.app.workspace.activeLeaf, target);
  assert.equal(target.isDeferred, false);
  assert.equal(f.opens.length, 0);
});

test("does not reuse a non-file panel that references the selected file", async () => {
  const f = await fixture();
  const panel = f.leaf("Target.md", { panel: true });
  await f.choose("Target.md");
  assert.equal(f.opens.length, 1);
  assert.notEqual(f.opens[0].leaf, panel);
});

test("explicit keyboard and mouse modifiers delegate to the native handler", async () => {
  const f = await fixture();
  for (const event of [
    { metaKey: true }, { ctrlKey: true }, { altKey: true }, { shiftKey: true },
    { metaKey: true, altKey: true }, { metaKey: true, altKey: true, shiftKey: true },
    { button: 1 }, { button: 2 },
  ]) {
    assert.equal(f.choose("Current.md", event), "native");
    assert.equal(f.nativeCalls.at(-1).modal, f.modal);
    assert.equal(f.nativeCalls.at(-1).args[1], event);
  }
  assert.equal(f.reveals.length, 0);
  assert.equal(f.opens.length, 0);
});

test("plain mouse clicks use tab reuse", async () => {
  const f = await fixture();
  await f.choose("Current.md", { button: 0 });
  assert.deepEqual(f.reveals, [f.current]);
});

test("new note creation, unresolved links, and bookmarks use native handling", async () => {
  const f = await fixture();
  for (const suggestion of [null, undefined, { type: "unresolved", linktext: "Missing" }, { type: "bookmark", item: {} }]) {
    assert.equal(f.modal.onChooseSuggestion(suggestion, {}), "native");
    assert.equal(f.nativeCalls.at(-1).args[0], suggestion);
  }
  assert.equal(f.opens.length, 0);
});

test("rapid selections of the same unopened file share one open operation", async () => {
  const f = await fixture();
  let finish;
  f.app.workspace.getLeaf = (type) => {
    assert.equal(type, "tab");
    const target = f.leaf(undefined);
    target.openFile = (file) => new Promise((resolve) => {
      f.opens.push({ file });
      finish = resolve;
    });
    return target;
  };
  const first = f.choose("New.md");
  const second = f.choose("New.md", {}, "alias");
  assert.equal(first, second);
  assert.equal(f.leaves.length, 2);
  assert.equal(f.opens.length, 1);
  finish();
  await first;
});

test("reports navigation failures and allows the next selection to retry", async () => {
  const f = await fixture();
  const reveal = f.app.workspace.revealLeaf;
  f.app.workspace.revealLeaf = async () => { throw new Error("Unable to reveal"); };
  await f.choose("Current.md");
  assert.equal(f.errors.length, 1);
  assert.match(f.notices[0], /could not open/);
  f.app.workspace.revealLeaf = reveal;
  await f.choose("Current.md");
  assert.deepEqual(f.reveals, [f.current]);
});

test("unloading restores the original handler", async () => {
  const f = await fixture();
  assert.notEqual(f.prototype.onChooseSuggestion, f.original);
  f.plugin.unload();
  assert.equal(f.prototype.onChooseSuggestion, f.original);
  assert.equal(f.choose("Current.md"), "native");
});

test("unloading preserves a later plugin's wrapper and makes ours a pass-through", async () => {
  const f = await fixture();
  const patched = f.prototype.onChooseSuggestion;
  function other(...args) { return patched.apply(this, args); }
  f.prototype.onChooseSuggestion = other;
  f.plugin.unload();
  assert.equal(f.prototype.onChooseSuggestion, other);
  assert.equal(f.choose("Current.md"), "native");
  assert.equal(f.reveals.length, 0);
});

test("does not change a different vault's selection through a shared prototype", async () => {
  const f = await fixture();
  assert.equal(f.prototype.onChooseSuggestion.call({ app: {} }, { type: "file", file: { path: "Current.md" } }, {}), "native");
  assert.equal(f.reveals.length, 0);
});

test("waits for layout readiness and does not attach after being unloaded", async () => {
  const f = await fixture({ ready: false });
  assert.equal(f.prototype.onChooseSuggestion, f.original);
  f.plugin.unload();
  f.ready();
  assert.equal(f.prototype.onChooseSuggestion, f.original);
  const loaded = await fixture({ ready: false });
  loaded.ready();
  assert.notEqual(loaded.prototype.onChooseSuggestion, loaded.original);
});

test("an unavailable internal hook produces a useful notice", async () => {
  const f = await fixture({ available: false });
  assert.match(f.notices[0], /enable the core Quick Switcher/);
  assert.equal(f.prototype.onChooseSuggestion, f.original);
});

test("current-tab mode opens an unopened file in the current tab", async () => {
  const f = await fixture({ data: { openIn: "current" } });
  await f.choose("New.md");
  assert.equal(f.leaves.length, 1);
  assert.equal(f.opens[0].leaf, f.current);
  assert.equal(f.app.workspace.activeLeaf, f.current);
  assert.equal(f.current.view.file.path, "New.md");
});

test("current-tab mode still reuses an existing pinned tab", async () => {
  const f = await fixture({ data: { openIn: "current" } });
  const target = f.leaf("Target.md", { pinned: true });
  await f.choose("Target.md");
  assert.equal(f.app.workspace.activeLeaf, target);
  assert.equal(f.current.view.file.path, "Current.md");
  assert.equal(f.opens.length, 0);
  assert.equal(f.leaves.length, 2);
});

test("current-tab mode respects native pinned-tab protection and explicit new-tab shortcuts", async () => {
  const f = await fixture({ data: { openIn: "current" } });
  f.current.pinned = true;
  await f.choose("New.md");
  assert.equal(f.current.view.file.path, "Current.md");
  assert.equal(f.leaves.length, 2);
  assert.equal(f.app.workspace.activeLeaf.view.file.path, "New.md");
  assert.equal(f.choose("Another.md", { metaKey: true }), "native");
});

test("destination setting applies immediately and survives reload", async () => {
  const f = await fixture();
  f.plugin.settingTab.display();
  const dropdown = f.controls[0].dropdown;
  assert.equal(dropdown.value, "new");
  await dropdown.change("current");
  assert.equal(f.saves.at(-1).openIn, "current");
  await f.choose("New.md");
  assert.equal(f.opens[0].leaf, f.current);
  assert.equal(f.leaves.length, 1);

  const reloaded = await fixture({ data: f.saves.at(-1) });
  reloaded.plugin.settingTab.display();
  assert.equal(reloaded.controls[0].dropdown.value, "current");
  await reloaded.choose("New.md");
  assert.equal(reloaded.opens[0].leaf, reloaded.current);

  await dropdown.change("new");
  assert.equal(f.saves.at(-1).openIn, "new");
  await f.choose("Another.md");
  assert.equal(f.leaves.length, 2);
  assert.notEqual(f.opens[1].leaf, f.current);
  assert.equal(f.current.view.file.path, "New.md");
});

const dailyCommands = [
  ["daily-notes", 1, "dailyToday"],
  ["daily-notes:goto-prev", 0, "dailyPrevious"],
  ["daily-notes:goto-next", 2, "dailyNext"],
];

for (const [id, index, setting] of dailyCommands) {
  test(`${id} reuses an existing daily-note tab`, async () => {
    const f = await fixture({ dailyEnabled: true });
    if (id !== "daily-notes") f.current.view.file = f.dailyFiles[1];
    const target = f.leaf(f.dailyFiles[index].path, { parent: {}, pinned: true, deferred: true });
    await f.runDaily(id);
    assert.equal(f.app.workspace.activeLeaf, target);
    assert.equal(target.pinned, true);
    assert.equal(f.leaves.length, 2);
    assert.equal(f.opens.length, 0);
  });

  for (const openIn of ["new", "current"]) {
    test(`${id} opens an unopened daily note in the configured ${openIn} tab`, async () => {
      const f = await fixture({ dailyEnabled: true, data: { openIn } });
      if (id !== "daily-notes") f.current.view.file = f.dailyFiles[1];
      await f.runDaily(id);
      assert.equal(f.opens.length, 1);
      assert.equal(f.opens[0].file.path, f.dailyFiles[index].path);
      assert.equal(f.opens[0].options.active, true);
      assert.equal(f.opens[0].leaf === f.current, openIn === "current");
      assert.equal(f.leaves.length, openIn === "new" ? 2 : 1);
      if (id === "daily-notes") {
        assert.equal(f.daily.lookups, 1);
        assert.equal(f.opens[0].options.state.mode, "source");
      } else {
        assert.equal(f.daily.lookups, 0); // Previous/Next only visit existing notes.
      }
    });
  }

  for (const mode of ["new", "current"]) {
    test(`${id} always-${mode} mode uses its destination even when the note is already open`, async () => {
      const f = await fixture({
        dailyEnabled: true,
        data: { openIn: mode === "new" ? "current" : "new", [setting]: mode },
      });
      if (id !== "daily-notes") f.current.view.file = f.dailyFiles[1];
      f.current.pinned = true;
      const originalPath = f.current.view.file.path;
      const existing = f.leaf(f.dailyFiles[index].path, { parent: {}, pinned: true });
      await f.runDaily(id);
      assert.equal(f.opens.length, 1);
      assert.equal(f.opens[0].file.path, existing.view.file.path);
      assert.notEqual(f.app.workspace.activeLeaf, existing);
      assert.equal(f.reveals.length, 0);
      assert.equal(f.app.workspace.activeLeaf === f.current, mode === "current");
      assert.equal(f.leaves.length, mode === "new" ? 3 : 2);
      assert.equal(f.current.pinned, true);
      if (mode === "new") assert.equal(f.current.view.file.path, originalPath);
    });
  }
}

test("Daily Notes availability checks are synchronous and do not navigate or create notes", async () => {
  const f = await fixture({ dailyEnabled: true });
  for (const id of ["daily-notes:goto-prev", "daily-notes:goto-next"]) {
    const command = f.app.commands.commands[id];
    assert.equal(command.checkCallback(true), false);
    assert.equal(command.checkCallback(false), false);
    f.current.view.file = f.dailyFiles[1];
    assert.equal(command.checkCallback(true), true);
    f.current.view.file = { path: "Current.md" };
  }
  assert.equal(f.daily.lookups, 0);
  assert.equal(f.daily.enumerations, 0);
  assert.equal(f.opens.length, 0);
  assert.equal(f.nativeDailyCalls.length, 0);
});

test("missing previous/next notes delegate to the native command for its notices", async () => {
  const f = await fixture({ dailyEnabled: true });
  f.current.view.file = f.dailyFiles[0];
  assert.equal(await f.runDaily("daily-notes:goto-prev"), true);
  f.current.view.file = f.dailyFiles[2];
  assert.equal(await f.runDaily("daily-notes:goto-next"), true);
  assert.deepEqual(f.nativeDailyCalls.map((call) => call.id), ["daily-notes:goto-prev", "daily-notes:goto-next"]);
  assert.equal(f.daily.lookups, 0);
  assert.equal(f.opens.length, 0);
});

test("Today waits for native file creation and coalesces overlapping commands", async () => {
  const f = await fixture({ dailyEnabled: true });
  let resolve;
  let calls = 0;
  f.daily.getDailyNote = () => {
    calls++;
    return new Promise((done) => { resolve = done; });
  };
  const callback = f.app.commands.commands["daily-notes"].callback;
  const first = callback();
  const second = callback();
  assert.equal(calls, 1);
  assert.equal(f.opens.length, 0);
  resolve(f.dailyFiles[1]);
  await Promise.all([first, second]);
  assert.equal(f.opens.length, 1);
  assert.equal(f.opens[0].file, f.dailyFiles[1]);
});

test("Today handles a missing file or resolver error without opening a blank tab and can retry", async () => {
  const f = await fixture({ dailyEnabled: true });
  f.daily.today = null;
  await f.runDaily("daily-notes");
  assert.equal(f.leaves.length, 1);
  f.daily.getDailyNote = async () => { throw new Error("Template read failed"); };
  await f.runDaily("daily-notes");
  assert.equal(f.errors.length, 1);
  assert.match(f.notices[0], /could not open/);
  assert.equal(f.leaves.length, 1);
  f.daily.getDailyNote = async () => f.dailyFiles[1];
  await f.runDaily("daily-notes");
  assert.equal(f.opens.length, 1);
});

test("Today preserves explicit native modifier navigation", async () => {
  const f = await fixture({ dailyEnabled: true });
  const callback = f.app.commands.commands["daily-notes"].callback;
  const event = { metaKey: true, altKey: true };
  assert.equal(callback(event), "native-today");
  assert.equal(f.nativeDailyCalls[0].args[0], event);
  f.app.lastEvent = { ctrlKey: true };
  assert.equal(callback(), "native-today");
  assert.equal(f.daily.lookups, 0);
  assert.equal(f.opens.length, 0);
});

test("destination changes apply immediately to Daily Notes and existing-tab reuse", async () => {
  const f = await fixture({ dailyEnabled: true });
  f.plugin.settingTab.display();
  await f.controls[0].dropdown.change("current");
  await f.runDaily("daily-notes");
  assert.equal(f.app.workspace.activeLeaf, f.current);
  assert.equal(f.leaves.length, 1);
  await f.controls[0].dropdown.change("new");
  await f.runDaily("daily-notes:goto-prev");
  assert.equal(f.leaves.length, 2);
  assert.notEqual(f.app.workspace.activeLeaf, f.current);
  await f.runDaily("daily-notes:goto-next");
  assert.equal(f.app.workspace.activeLeaf, f.current);
  assert.equal(f.leaves.length, 2);
});

test("Daily Notes command hooks restore on unload and respect later wrappers", async () => {
  const f = await fixture({ dailyEnabled: true });
  const today = f.app.commands.commands["daily-notes"];
  const patched = today.callback;
  function other(...args) { return patched.apply(this, args); }
  today.callback = other;
  f.plugin.unload();
  assert.equal(today.callback, other);
  assert.equal(today.callback(), "native-today");
  for (const id of ["daily-notes:goto-prev", "daily-notes:goto-next"]) {
    assert.equal(f.app.commands.commands[id].checkCallback, f.originalDaily[id].checkCallback);
  }
  const direct = await fixture({ dailyEnabled: true });
  direct.plugin.unload();
  assert.equal(direct.app.commands.commands["daily-notes"].callback, direct.originalDaily["daily-notes"].callback);
});

test("Daily Notes hooks work when the Quick Switcher hook is unavailable", async () => {
  const f = await fixture({ available: false, dailyEnabled: true });
  await f.runDaily("daily-notes");
  assert.equal(f.opens[0].file.path, f.dailyFiles[1].path);
});

test("new Daily Notes settings default to Follow for existing installations", async () => {
  const f = await fixture({ data: { openIn: "current" } });
  f.plugin.settingTab.display();
  assert.deepEqual(f.controls.map((control) => control.dropdown.value), ["current", "follow", "follow", "follow"]);
  assert.deepEqual(f.controls.slice(1).map((control) => control.name), ["Daily Notes: Today", "Daily Notes: Previous", "Daily Notes: Next"]);
});

test("Daily Notes settings apply independently, save all choices, and survive reload", async () => {
  const f = await fixture({ dailyEnabled: true, data: { openIn: "current" } });
  f.plugin.settingTab.display();
  await f.controls[1].dropdown.change("new");
  await f.controls[2].dropdown.change("current");
  await f.controls[3].dropdown.change("follow");
  const settings = { openIn: "current", dailyToday: "new", dailyPrevious: "current", dailyNext: "follow" };
  assert.deepEqual(f.saves.at(-1), settings);

  const existingToday = f.leaf(f.dailyFiles[1].path);
  await f.runDaily("daily-notes");
  const newToday = f.app.workspace.activeLeaf;
  assert.notEqual(newToday, existingToday);
  assert.equal(f.leaves.length, 3);
  await f.runDaily("daily-notes:goto-prev");
  assert.equal(f.app.workspace.activeLeaf, newToday);
  assert.equal(newToday.view.file.path, f.dailyFiles[0].path);
  assert.equal(f.leaves.length, 3);
  await f.runDaily("daily-notes:goto-next");
  assert.equal(f.app.workspace.activeLeaf, existingToday);
  assert.equal(f.leaves.length, 3);

  // The Quick Switcher still uses its own fallback and existing-tab navigation.
  await f.choose("Other.md");
  assert.equal(f.app.workspace.activeLeaf, existingToday);
  assert.equal(f.leaves.length, 3);
  await f.choose(f.dailyFiles[0].path);
  assert.equal(f.app.workspace.activeLeaf, newToday);

  const reloaded = await fixture({ dailyEnabled: true, data: f.saves.at(-1) });
  reloaded.plugin.settingTab.display();
  assert.deepEqual(reloaded.controls.map((control) => control.dropdown.value), ["current", "new", "current", "follow"]);
  await reloaded.runDaily("daily-notes");
  assert.notEqual(reloaded.app.workspace.activeLeaf, reloaded.current);
});

test("Today always-new mode opens another tab when today's note is the current tab", async () => {
  const f = await fixture({ dailyEnabled: true, data: { dailyToday: "new" } });
  f.current.view.file = f.dailyFiles[1];
  await f.runDaily("daily-notes");
  const first = f.app.workspace.activeLeaf;
  await f.runDaily("daily-notes");
  assert.notEqual(first, f.current);
  assert.notEqual(f.app.workspace.activeLeaf, first);
  assert.equal(f.leaves.length, 3);
  assert.equal(f.opens.length, 2);
});

test("rapid Today always-new commands share file creation but each open their own tab", async () => {
  const f = await fixture({ dailyEnabled: true, data: { dailyToday: "new" } });
  let resolve;
  let calls = 0;
  f.daily.getDailyNote = () => {
    calls++;
    return new Promise((done) => { resolve = done; });
  };
  const callback = f.app.commands.commands["daily-notes"].callback;
  const first = callback();
  const second = callback();
  assert.equal(calls, 1);
  assert.equal(f.opens.length, 0);
  resolve(f.dailyFiles[1]);
  await Promise.all([first, second]);
  assert.equal(f.opens.length, 2);
  assert.notEqual(f.opens[0].leaf, f.opens[1].leaf);
  assert.equal(f.leaves.length, 3);
});

test("Today always-current mode enforces its destination for modifier-driven commands", async () => {
  const f = await fixture({ dailyEnabled: true, data: { dailyToday: "current" } });
  const existing = f.leaf(f.dailyFiles[1].path);
  await f.app.commands.commands["daily-notes"].callback({ metaKey: true, altKey: true });
  assert.equal(f.nativeDailyCalls.length, 0);
  assert.equal(f.app.workspace.activeLeaf, f.current);
  assert.notEqual(f.app.workspace.activeLeaf, existing);
  assert.equal(f.current.view.file.path, f.dailyFiles[1].path);
  assert.equal(f.leaves.length, 2);
});
