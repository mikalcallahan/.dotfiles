const { Plugin, PluginSettingTab, Setting, Notice, moment, normalizePath } = require("obsidian");

const DEFAULT_SETTINGS = { rolloverMode: "on-create" };

// Only inspect actual Markdown, not frontmatter, comments, or fenced examples.
function markdownLines(text) {
  let frontmatter = false;
  let fence = null;
  let comment = false;
  return text.split(/\r?\n/).map((line, index) => {
    if (index === 0 && line.replace(/^\uFEFF/, "") === "---") {
      frontmatter = true;
      return null;
    }
    if (frontmatter) {
      if (/^(---|\.\.\.)\s*$/.test(line)) frontmatter = false;
      return null;
    }
    const marker = line.match(/^\s*(`{3,}|~{3,})(.*)$/);
    if (fence) {
      if (marker && marker[1][0] === fence[0] && marker[1].length >= fence.length && !marker[2].trim()) {
        fence = null;
      }
      return null;
    }
    if (comment) {
      if (line.includes("-->")) comment = false;
      return null;
    }
    if (line.includes("<!--")) {
      comment = !line.slice(line.indexOf("<!--") + 4).includes("-->");
      return null;
    }
    if (marker) {
      fence = marker[1];
      return null;
    }
    return line;
  });
}

function listItems(text) {
  const items = [];
  const stack = [];
  const lines = markdownLines(text);
  const width = (indent) => [...indent].reduce((column, char) => char === "\t" ? column + 4 - column % 4 : column + 1, 0);
  lines.forEach((line, index) => {
    if (line === null || !line.trim()) return;
    const match = line.match(/^([ \t]*)([-*+]|\d+[.)])\s+(.*)$/);
    const indent = match ? match[1] : line.match(/^[ \t]*/)[0];
    const columns = width(indent);
    while (stack.length && stack.at(-1).columns >= columns) stack.pop().end = index;
    if (!match) return;
    const checkbox = match[3].match(/^\[([^\]])\](?:\s+(.*))?$/);
    const item = {
      index, end: lines.length, indent, columns, marker: match[2],
      status: checkbox ? checkbox[1] : null,
      text: (checkbox ? checkbox[2] || "" : match[3]).trim(),
      parent: stack.at(-1),
    };
    item.key = JSON.stringify([...(item.parent?.path || []), item.text]);
    item.path = [...(item.parent?.path || []), item.text];
    items.push(item);
    stack.push(item);
  });
  return items;
}

function unfinished(item) {
  return item.status !== null && item.text && !["x", "X", ">", "-"].includes(item.status);
}

function rollover(previous, current) {
  const eol = current.includes("\r\n") ? "\r\n" : "\n";
  let heading = markdownLines(current).findIndex((line) => /^## Tasks\s*$/.test(line ?? ""));
  const base = heading === -1 ? `${current.trimEnd()}${eol}${eol}## Tasks${eol}` : current;
  const lines = base.split(/\r?\n/);
  if (heading === -1) heading = lines.length - 2;
  const existing = new Map(listItems(base).filter((item) => item.text).map((item) => [item.key, item]));
  const insertions = new Map();
  const carried = new Set();
  const selected = new Set();
  const source = listItems(previous);
  // Carry plain child notes recursively with open tasks, stopping at closed tasks.
  for (const item of source) {
    if (!unfinished(item) && !(item.status === null && item.text && carried.has(item.parent))) continue;
    carried.add(item);
    // Include ancestors as context, but never revive a completed task checkbox.
    for (let ancestor = item; ancestor; ancestor = ancestor.parent) selected.add(ancestor);
  }
  let count = 0;
  for (const item of source) {
    if (!selected.has(item) || existing.has(item.key)) continue;
    const parent = item.parent ? existing.get(item.parent.key) : null;
    const suffix = item.parent && item.indent.startsWith(item.parent.indent)
      ? item.indent.slice(item.parent.indent.length)
      : " ".repeat(Math.max(0, item.columns - (item.parent?.columns || 0)));
    const added = {
      ...item,
      indent: parent ? parent.indent + suffix : item.indent,
      status: unfinished(item) ? item.status : null,
      children: [], added: true,
    };
    existing.set(item.key, added);
    if (carried.has(item)) count++;
    if (parent?.added) {
      parent.children.push(added);
    } else {
      const index = parent ? parent.end : heading + 1;
      if (!insertions.has(index)) insertions.set(index, []);
      insertions.get(index).push(added);
    }
  }
  if (!count) return { text: current, count: 0 };
  const render = (item) => [
    `${item.indent}${item.marker} ${item.status === null ? "" : `[${item.status}] `}${item.text}`,
    ...item.children.flatMap(render),
  ];
  for (const [index, items] of [...insertions].sort((a, b) => b[0] - a[0])) {
    lines.splice(index, 0, ...items.flatMap(render));
  }
  return { text: lines.join(eol), count };
}

function previousDaily(files, folder, format, today) {
  const prefix = folder ? `${folder}/` : "";
  return files.flatMap((file) => {
    if (!file.path.startsWith(prefix)) return [];
    const name = file.path.slice(prefix.length, -3);
    const date = moment(name, format, true);
    return date.isValid() && date.format(format) === name && date.isBefore(today, "day")
      ? [{ file, date: date.valueOf() }] : [];
  }).sort((a, b) => b.date - a.date)[0]?.file;
}

class DailyTaskRolloverSettings extends PluginSettingTab {
  constructor(app, plugin) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display() {
    this.containerEl.empty();
    new Setting(this.containerEl)
      .setName("Rollover trigger")
      .setDesc("Choose when to carry tasks into today. The rollover command is always available.")
      .addDropdown((dropdown) => dropdown
        .addOption("manual", "Command only")
        .addOption("on-create", "When creating today's daily note")
        .setValue(this.plugin.settings.rolloverMode)
        .onChange(async (value) => {
          this.plugin.settings.rolloverMode = value;
          await this.plugin.saveData(this.plugin.settings);
        }));
  }
}

module.exports = class DailyTaskRollover extends Plugin {
  async onload() {
    this.running = false;
    this.settings = { ...DEFAULT_SETTINGS, ...await this.loadData() };
    this.addSettingTab(new DailyTaskRolloverSettings(this.app, this));
    try {
      const config = JSON.parse(await this.app.vault.adapter.read(`${this.app.vault.configDir}/daily-notes.json`));
      this.folder = config.folder ? normalizePath(config.folder).replace(/\/$/, "") : "";
      this.format = config.format || "YYYY-MM-DD";
    } catch (error) {
      console.error("Daily Task Rollover: could not read Daily Notes settings", error);
      new Notice("Daily Task Rollover: configure the core Daily Notes plugin, then reload this plugin.");
      return;
    }

    this.addCommand({
      id: "rollover-tasks",
      name: "Carry unfinished tasks into today",
      callback: () => this.run(true),
    });
    // Vault create events also fire for existing files during startup.
    this.app.workspace.onLayoutReady(() => {
      this.registerEvent(this.app.vault.on("create", (file) => {
        if (this.settings.rolloverMode === "on-create") void this.run(false, file);
      }));
    });
  }

  async run(manual, createdFile) {
    if (this.running) return;
    const today = moment().startOf("day");
    const path = normalizePath(`${this.folder ? `${this.folder}/` : ""}${today.format(this.format)}.md`);
    if (createdFile && createdFile.path !== path) return;
    this.running = true;
    try {
      const vault = this.app.vault;
      const target = vault.getMarkdownFiles().find((file) => file.path === path);
      if (!target) {
        if (manual) new Notice("Create today's daily note first.");
        return;
      }
      const source = previousDaily(vault.getMarkdownFiles(), this.folder, this.format, today);
      if (!source) {
        if (manual) new Notice("No previous daily note found.");
        return;
      }
      const previous = await vault.read(source);
      let count = 0;
      await vault.process(target, (current) => {
        const result = rollover(previous, current);
        count = result.count;
        return result.text;
      });
      if (count || manual) new Notice(count ? `Carried ${count} item${count === 1 ? "" : "s"} from ${source.basename}.` : "No new unfinished tasks or bullet notes to carry forward.");
    } catch (error) {
      console.error("Daily Task Rollover failed", error);
      new Notice("Daily Task Rollover failed. See the developer console for details.");
    } finally {
      this.running = false;
    }
  }
};
