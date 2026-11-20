const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");

// A fixed clock and the small Moment surface used by this plugin.
function moment(value = "2026-10-20", format = "YYYY-MM-DD") {
  const normalized = format === "YYYY/MM/DD" ? value.replaceAll("/", "-") : value;
  const date = new Date(`${normalized}T00:00:00Z`);
  const valid = /^\d{4}-\d{2}-\d{2}$/.test(normalized) && Number.isFinite(+date)
    && date.toISOString().slice(0, 10) === normalized;
  return {
    startOf() { return this; },
    isValid: () => valid,
    format: (output) => output === "YYYY/MM/DD" ? normalized.replaceAll("-", "/") : normalized,
    isBefore: (other) => +date < other.valueOf(),
    valueOf: () => +date,
  };
}

function load(data) {
  const notices = [];
  const errors = [];
  const controls = [];
  const saves = [];
  class Plugin {
    addCommand(command) { this.command = command; }
    registerEvent(event) { this.event = event; }
    addSettingTab(tab) { this.settingTab = tab; }
    async loadData() { return data; }
    async saveData(settings) { saves.push(JSON.parse(JSON.stringify(settings))); }
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
  const obsidian = {
    Plugin,
    PluginSettingTab: class { constructor() { this.containerEl = { empty() {} }; } },
    Setting,
    Notice: class { constructor(message) { notices.push(message); } },
    moment,
    normalizePath: (value) => value.replace(/\/+/g, "/").replace(/^\//, ""),
  };
  const context = vm.createContext({
    module: { exports: {} },
    require: (name) => { assert.equal(name, "obsidian"); return obsidian; },
    console: { error: (...args) => errors.push(args) },
  });
  vm.runInContext(fs.readFileSync(path.join(__dirname, "main.js"), "utf8")
    + "\nglobalThis.helpers = { rollover, previousDaily };", context);
  return { Plugin: context.module.exports, ...context.helpers, notices, errors, controls, saves };
}

function fixture(config = { folder: "Dailies" }, data) {
  const api = load(data);
  const plugin = new api.Plugin();
  const contents = new Map([
    ["Dailies/2026-10-16.md", "- [ ] Friday task\n"],
    ["Dailies/2026-10-20.md", "# Today\n\n## Tasks\n- [ ] \n\n## Notes\nKeep this.\n"],
    ["Dailies/2026-10-21.md", "- [ ] Future task\n"],
    ["Dailies/2026-10-16 1.md", "- [ ] Duplicate-name note\n"],
    ["Other/2026-10-19.md", "- [ ] Wrong folder\n"],
  ]);
  const file = (filePath) => ({ path: filePath, basename: filePath.split("/").pop().slice(0, -3) });
  const layoutCallbacks = [];
  const workspaceEvents = new Map();
  const vaultEvents = new Map();
  const on = (events) => (name, callback) => {
    if (!events.has(name)) events.set(name, []);
    events.get(name).push(callback);
    return { name, callback };
  };
  const emit = async (events, name, filePath) => {
    for (const callback of events.get(name) || []) callback(file(filePath));
    // Obsidian events do not await async handlers; let pending vault work finish.
    await new Promise(setImmediate);
  };
  const writes = [];
  plugin.app = {
    workspace: {
      on: on(workspaceEvents),
      onLayoutReady: (callback) => layoutCallbacks.push(callback),
    },
    vault: {
      on: on(vaultEvents),
      configDir: ".obsidian",
      adapter: { read: async () => JSON.stringify(config) },
      getMarkdownFiles: () => [...contents.keys()].map(file),
      read: async (source) => contents.get(source.path),
      process: async (target, callback) => {
        const next = callback(contents.get(target.path));
        if (next !== contents.get(target.path)) writes.push(target.path);
        contents.set(target.path, next);
      },
    },
  };
  return {
    ...api, plugin, contents, writes, file,
    ready: () => layoutCallbacks.splice(0).forEach((callback) => callback()),
    open: (filePath) => emit(workspaceEvents, "file-open", filePath),
    create: (filePath, text) => {
      contents.set(filePath, text);
      return emit(vaultEvents, "create", filePath);
    },
  };
}

test("carries real unfinished tasks with their nesting and parent context", () => {
  const { rollover } = load();
  const source = [
    "---", "- [ ] YAML", "---", "- [ ] Ship [[EXAMPLE-123]]", "- [x] Finished",
    "- [-] Cancelled", "- [/] In progress", "- [ ] ", "- [X] Done",
    "```md", "<!-- example", "- [ ] Code", "```", "- [ ] After code",
    "<!--", "- [ ] Comment", "-->", "~~~", "- [ ] Other code", "~~~",
    "- [x] Parent", "  - [ ] Child", "1. [ ] Ordered task",
  ].join("\n");
  const result = rollover(source, "## Tasks\n\n## Notes\nKeep me.\n");
  assert.equal(result.count, 5);
  assert.equal(result.text, "## Tasks\n- [ ] Ship [[EXAMPLE-123]]\n- [/] In progress\n- [ ] After code\n- Parent\n  - [ ] Child\n1. [ ] Ordered task\n\n## Notes\nKeep me.\n");
});

test("preserves tabs, multiple nesting levels, and unfinished statuses", () => {
  const { rollover } = load();
  const previous = "- [/] Build a sample garden planner\n\t- [ ] Testing:\n\t\t- [ ] Seed catalog\n\t\t- [ ] Watering schedule\n\t- [B] Blocked\n\t- [x] Finished\n";
  const first = rollover(previous, "## Tasks\n\n## Notes\n");
  assert.equal(first.count, 5);
  assert.equal(first.text, "## Tasks\n" + previous.replace("\t- [x] Finished\n", "") + "\n## Notes\n");
  assert.equal(rollover(previous, first.text).count, 0);
});

test("carries nested bullet notes with unfinished tasks, excluding closed branches and unrelated bullets", () => {
  const { rollover } = load();
  const previous = [
    "- [/] Parent", "\t- Details [[Reference]]", "\t\t- Nested detail",
    "\t- [ ] Child", "\t\t- Child detail", "\t- [x] Finished", "\t\t- Finished detail",
    "\t- [-] Cancelled", "\t\t- Cancelled detail", "\t- [>] Moved", "\t\t- Moved detail",
    "- Standalone", "- Project", "  - Unrelated detail", "  - [ ] Follow up", "",
  ].join("\n");
  const first = rollover(previous, "## Tasks\n");
  assert.equal(first.count, 6);
  assert.equal(first.text, [
    "## Tasks", "- [/] Parent", "\t- Details [[Reference]]", "\t\t- Nested detail",
    "\t- [ ] Child", "\t\t- Child detail", "- Project", "  - [ ] Follow up", "",
  ].join("\n"));
  assert.equal(rollover(previous, first.text).count, 0);
  assert.equal(rollover(first.text, "## Tasks\n").text, first.text);
});

test("merges only new bullet notes under existing tasks and notes without duplicating them", () => {
  const { rollover } = load();
  const previous = "- [ ] Parent\n  - Existing detail\n    - New nested detail\n  - New detail\n";
  const current = "## Tasks\n- [x] Parent\n  - Existing detail\n- [ ] Today's task\n";
  const first = rollover(previous, current);
  assert.equal(first.count, 2);
  assert.equal(first.text, "## Tasks\n- [x] Parent\n  - Existing detail\n    - New nested detail\n  - New detail\n- [ ] Today's task\n");
  assert.equal(rollover(previous, first.text).count, 0);
  assert.equal(rollover(previous, first.text).text, first.text);
});

test("retains plain parents and converts closed parents to plain context", () => {
  const { rollover } = load();
  const previous = "- Project\n  - [x] Completed parent\n    - [?] Follow up\n    - [x] Completed sibling\n  - [>] Moved parent\n    - [B] Unfinished child\n- [-] Cancelled\n";
  const first = rollover(previous, "## Tasks\n");
  assert.equal(first.count, 2);
  assert.equal(first.text, "## Tasks\n- Project\n  - Completed parent\n    - [?] Follow up\n  - Moved parent\n    - [B] Unfinished child\n");
  assert.equal(rollover(previous, first.text).count, 0);
});

test("merges new children under an existing parent while retaining today's status", () => {
  const { rollover } = load();
  const previous = "- [/] Parent\n  - [ ] Existing\n  - [!] New\n    - [B] Nested\n- [ ] Other\n";
  const current = "## Tasks\n- [x] Parent\n  - [x] Existing\n- [ ] Other\n\n## Notes\nKeep this.\n";
  const first = rollover(previous, current);
  assert.equal(first.count, 2);
  assert.equal(first.text, "## Tasks\n- [x] Parent\n  - [x] Existing\n  - [!] New\n    - [B] Nested\n- [ ] Other\n\n## Notes\nKeep this.\n");
  assert.equal(rollover(previous, first.text).count, 0);
});

test("same child text under different parents is not treated as a duplicate", () => {
  const { rollover } = load();
  const previous = "- [ ] Project A\n  - [ ] Test\n- [ ] Project B\n  - [ ] Test\n";
  const first = rollover(previous, "## Tasks\n");
  assert.equal(first.count, 4);
  assert.equal(first.text, "## Tasks\n" + previous);
  assert.equal(rollover(previous, first.text).count, 0);
});

test("new children use the existing parent's indentation", () => {
  const { rollover } = load();
  const previous = "- Project\n\t- [ ] Parent\n\t\t- [ ] New\n";
  const current = "## Tasks\n- Project\n  - [/] Parent\n\n## Notes\n";
  assert.equal(rollover(previous, current).text, "## Tasks\n- Project\n  - [/] Parent\n\n  \t- [ ] New\n## Notes\n");
});

test("carries in-progress Focus tasks with their status and excludes completed tasks", () => {
  const { rollover } = load();
  const previous = "## Focus\n- [/] Compare demo-alpha, demo-beta, and demo-gamma\n- [/] Record sample benchmark scores\n- [/] Build a sample garden planner\n- [x] Review the sample design\n";
  const first = rollover(previous, "## Tasks\n");
  assert.equal(first.count, 3);
  assert.equal((first.text.match(/\[\/\]/g) || []).length, 3);
  assert.doesNotMatch(first.text, /Review the sample design/);
  assert.equal(rollover(previous, first.text).count, 0);
  assert.equal(rollover(previous, first.text.replaceAll("[/]", "[x]")).count, 0);
});

test("repeated runs do not duplicate tasks, including tasks completed today", () => {
  const { rollover } = load();
  const previous = "- [ ] Same\n* [ ] Same\n- [ ] New\n";
  const current = "## Tasks\n+ [x] Same\n";
  const first = rollover(previous, current);
  assert.equal(first.count, 1);
  assert.equal(rollover(previous, first.text).count, 0);
  assert.equal(rollover(previous, first.text.replace("[ ] New", "[x] New")).count, 0);
});

test("carries all task statuses except completed, migrated, and cancelled", () => {
  const { rollover } = load();
  const included = [" ", "/", "<", "!", "?", "B", "b", "*"];
  const excluded = ["x", "X", ">", "-"];
  const previous = [...included, ...excluded]
    .map((status) => `- [${status}] Task (${status})`).join("\n");
  const first = rollover(previous, "## Tasks\n");
  assert.equal(first.count, included.length);
  assert.equal(first.text, "## Tasks\n" + included.map((status) => `- [${status}] Task (${status})`).join("\n") + "\n");
  assert.equal(rollover(previous, first.text).count, 0);
  // A task already moved or cancelled today must not reappear from yesterday.
  assert.equal(rollover("- [!] Important\n- [B] Blocked", "## Tasks\n- [>] Important\n- [-] Blocked").count, 0);
  assert.equal(rollover("- [!] \n- [B] \n- [?] ", "## Tasks\n").count, 0);
});

test("appends a missing Tasks section and preserves CRLF", () => {
  const { rollover } = load();
  const result = rollover("- [ ] New", "# Today\r\n\r\n## Notes\r\n");
  assert.equal(result.text, "# Today\r\n\r\n## Notes\r\n\r\n## Tasks\r\n- [ ] New\r\n");
});

test("ignores Tasks headings in code and leaves notes unchanged when nothing is pending", () => {
  const { rollover } = load();
  const current = "```\n## Tasks\n```\n\n## Tasks\n";
  assert.equal(rollover("- [ ] Real", current).text, current + "- [ ] Real\n");
  assert.equal(rollover("- [x] Done\n- [ ] ", current).text, current);
});

test("manual rollover selects the most recent valid past note and only changes today", async () => {
  const f = fixture();
  const original = new Map(f.contents);
  await f.plugin.onload();
  assert.equal(f.writes.length, 0);
  await f.plugin.command.callback();
  assert.match(f.contents.get("Dailies/2026-10-20.md"), /- \[ \] Friday task/);
  assert.deepEqual(f.writes, ["Dailies/2026-10-20.md"]);
  for (const [filePath, content] of original) {
    if (filePath !== "Dailies/2026-10-20.md") assert.equal(f.contents.get(filePath), content);
  }
  await f.plugin.command.callback();
  assert.equal(f.writes.length, 1);
});

test("default rollover runs on creation, skips startup files, and never reruns on open", async () => {
  const f = fixture();
  await f.plugin.onload();
  const today = "Dailies/2026-10-20.md";
  const template = f.contents.get(today);
  await f.create(today, template);
  assert.equal(f.writes.length, 0);
  f.ready();
  await f.open(today);
  assert.equal(f.writes.length, 0);

  f.contents.delete(today);
  await f.create(today, template);
  assert.deepEqual(f.writes, [today]);
  assert.match(f.contents.get(today), /- \[ \] Friday task/);
  assert.match(f.contents.get(today), /## Notes\nKeep this\./);

  f.contents.set(today, template); // Simulate removing the rolled-over task.
  await f.open("Dailies/2026-10-16.md");
  await f.open(today);
  assert.equal(f.contents.get(today), template);
  assert.equal(f.writes.length, 1);
});

test("automatic rollover ignores new historical, future, and unrelated notes", async () => {
  const f = fixture();
  await f.plugin.onload();
  f.ready();
  await f.create("Dailies/2026-10-19.md", "## Tasks\n");
  await f.create("Dailies/2026-10-22.md", "## Tasks\n");
  await f.create("Other/2026-10-20.md", "## Tasks\n");
  await f.create("Dailies/2026-10-20.txt", "Unrelated file");
  assert.equal(f.writes.length, 0);
});

test("command-only setting survives reload and still allows manual rollover", async () => {
  const f = fixture(undefined, { rolloverMode: "manual" });
  await f.plugin.onload();
  f.ready();
  f.plugin.settingTab.display();
  assert.equal(f.controls[0].dropdown.value, "manual");
  const today = "Dailies/2026-10-20.md";
  f.contents.delete(today);
  await f.create(today, "## Tasks\n");
  await f.open(today);
  assert.equal(f.writes.length, 0);
  await f.plugin.command.callback();
  assert.match(f.contents.get(today), /- \[ \] Friday task/);
  assert.deepEqual(f.writes, [today]);
});

test("settings changes apply immediately, persist, and do not themselves roll over tasks", async () => {
  const f = fixture();
  await f.plugin.onload();
  f.ready();
  f.plugin.settingTab.display();
  const dropdown = f.controls[0].dropdown;
  assert.equal(dropdown.value, "on-create");
  await dropdown.change("manual");
  assert.deepEqual(f.saves.at(-1), { rolloverMode: "manual" });
  const today = "Dailies/2026-10-20.md";
  f.contents.delete(today);
  await f.create(today, "## Tasks\n");
  assert.equal(f.writes.length, 0);

  await dropdown.change("on-create");
  assert.deepEqual(f.saves.at(-1), { rolloverMode: "on-create" });
  await f.open(today);
  assert.equal(f.writes.length, 0);
  f.contents.delete(today);
  await f.create(today, "## Tasks\n");
  assert.deepEqual(f.writes, [today]);

  const reloaded = fixture(undefined, f.saves.at(-1));
  await reloaded.plugin.onload();
  reloaded.ready();
  reloaded.contents.delete(today);
  await reloaded.create(today, "## Tasks\n");
  assert.deepEqual(reloaded.writes, [today]);
});

test("prevents overlapping rollover runs", async () => {
  const f = fixture();
  await f.plugin.onload();
  await Promise.all([
    f.plugin.run(false, f.file("Dailies/2026-10-20.md")),
    f.plugin.run(false, f.file("Dailies/2026-10-20.md")),
  ]);
  assert.equal(f.writes.length, 1);
});

test("missing today or missing previous note never creates files", async () => {
  const f = fixture();
  await f.plugin.onload();
  f.contents.delete("Dailies/2026-10-20.md");
  await f.plugin.run(true);
  assert.equal(f.notices.at(-1), "Create today's daily note first.");
  f.contents.clear();
  f.contents.set("Dailies/2026-10-20.md", "## Tasks\n");
  await f.plugin.run(true);
  assert.equal(f.notices.at(-1), "No previous daily note found.");
  assert.equal(f.writes.length, 0);
});

test("supports date formats with year/month subfolders and rejects impossible dates", () => {
  const { previousDaily } = load();
  const files = ["Daily/2026/09/31.md", "Daily/2026/09/30.md", "Daily/2026/10/20.md", "Daily/2026/10/21.md"]
    .map((filePath) => ({ path: filePath }));
  assert.equal(previousDaily(files, "Daily", "YYYY/MM/DD", moment()).path, "Daily/2026/09/30.md");
});

test("write failures are reported and release the run lock", async () => {
  const f = fixture();
  await f.plugin.onload();
  f.plugin.app.vault.process = async () => { throw new Error("Disk error"); };
  await f.plugin.run(true);
  assert.equal(f.errors.length, 1);
  assert.equal(f.plugin.running, false);
  assert.match(f.notices.at(-1), /failed/);
});
