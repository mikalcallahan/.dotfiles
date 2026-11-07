const { FileView, Keymap, Notice, Plugin, PluginSettingTab, Setting } = require("obsidian");

const DEFAULT_SETTINGS = {
  openIn: "new",
  dailyToday: "follow",
  dailyPrevious: "follow",
  dailyNext: "follow",
};

function findOpenLeaf(workspace, file) {
  const current = workspace.activeLeaf ?? workspace.getMostRecentLeaf();
  const matches = [];
  workspace.iterateAllLeaves((leaf) => {
    // Deferred tabs have a placeholder view; their saved state still has the path.
    // Exclude non-file panels such as backlinks that also reference a file.
    if (!(leaf.view instanceof FileView) && !leaf.isDeferred) return;
    const path = leaf.view.file?.path ?? leaf.getViewState().state?.file;
    if (path === file.path) matches.push(leaf);
  });
  matches.sort((a, b) => (b.activeTime || 0) - (a.activeTime || 0));
  return matches.find((leaf) => leaf === current)
    ?? matches.find((leaf) => current && leaf.parent === current.parent)
    ?? matches[0];
}

function createNavigator(app, settings, reportError) {
  const pending = new Map();

  async function openFile(file, options, mode) {
    const workspace = app.workspace;
    const existing = mode === "follow" && findOpenLeaf(workspace, file);
    if (existing) {
      // Reveal loads deferred tabs and brings split/popout tabs into view.
      // Activating rather than reopening preserves cursor, scroll, and pin state.
      await workspace.revealLeaf(existing);
      workspace.setActiveLeaf(existing, { focus: true });
    } else {
      const current = workspace.getMostRecentLeaf();
      let target;
      if (mode === "current") {
        // An explicit "always current" choice also uses a pinned current tab.
        target = current ?? workspace.getLeaf(false);
      } else if (mode === "new" && current?.parent) {
        // getLeaf("tab") may reuse an empty tab, including one still loading.
        // An explicit "always new" choice creates a fresh tab for every command.
        target = workspace.createLeafInParent(current.parent, current.parent.children.indexOf(current) + 1);
      } else {
        // Follow mode's fallback retains native pinned-tab protection.
        target = workspace.getLeaf(mode === "new" || settings.openIn !== "current" ? "tab" : false);
      }
      await target.openFile(file, { ...options, active: true });
    }
  }

  return (file, options = {}, mode = "follow") => {
    // Explicit destinations must not be merged with a concurrent follow request.
    if (mode !== "follow") return openFile(file, options, mode).catch(reportError);
    const path = file.path;
    if (!pending.has(path)) {
      pending.set(path, openFile(file, options, mode)
        .catch(reportError)
        .finally(() => pending.delete(path)));
    }
    return pending.get(path);
  };
}

function connectSwitcher(prototype, app, navigate) {
  const original = prototype.onChooseSuggestion;
  let active = true;

  function onChooseSuggestion(suggestion, event) {
    const modified = event && (event.metaKey || event.ctrlKey || event.altKey || event.shiftKey || event.button > 0);
    if (!active || this.app !== app || modified
      || !["file", "alias"].includes(suggestion?.type) || !suggestion.file) {
      return original.apply(this, arguments);
    }

    return navigate(suggestion.file);
  }

  prototype.onChooseSuggestion = onChooseSuggestion;
  return () => {
    active = false;
    // Preserve any wrapper installed later by another plugin. Our wrapper becomes
    // a pass-through if it remains in that plugin's call chain after unloading.
    if (prototype.onChooseSuggestion === onChooseSuggestion) {
      prototype.onChooseSuggestion = original;
    }
  };
}

function connectDailyNotes(app, settings, navigate, reportError) {
  const daily = app.internalPlugins?.plugins?.["daily-notes"]?.instance;
  const commands = app.commands?.commands;
  const cleanups = [];
  let active = true;
  let pendingToday = null;

  function wrap(id, key, intercept) {
    const command = commands?.[id];
    const original = command?.[key];
    if (typeof original !== "function") return;
    function wrapped(...args) {
      if (!active) return original.apply(this, args);
      return intercept.call(this, original, args);
    }
    command[key] = wrapped;
    cleanups.push(() => {
      if (command[key] === wrapped) command[key] = original;
    });
  }

  if (typeof daily?.getDailyNote === "function") {
    wrap("daily-notes", "callback", function (original, args) {
      const mode = settings.dailyToday;
      const event = args[0] || app.lastEvent;
      if (mode === "follow" && event && Keymap.isModEvent(event)) return original.apply(this, args);
      if (!pendingToday) {
        // Let Daily Notes resolve/create the file using its folder, format, and
        // template. Share creation, but honor each command's navigation choice.
        pendingToday = (async () => daily.getDailyNote())()
          .finally(() => { pendingToday = null; });
      }
      return pendingToday.then((file) => {
        if (file) return navigate(file, { state: { mode: "source" } }, mode);
      }).catch(reportError);
    });
  }

  if (typeof daily?.getCurrentFileDateTimestamp === "function" && typeof daily.iterateDailyNotes === "function") {
    for (const [id, direction, setting] of [
      ["daily-notes:goto-prev", -1, "dailyPrevious"],
      ["daily-notes:goto-next", 1, "dailyNext"],
    ]) {
      wrap(id, "checkCallback", function (original, args) {
        // Command Palette availability checks must remain synchronous and read-only.
        const available = original.call(this, true, ...args.slice(1));
        if (args[0] || !available) return available;
        try {
          const current = daily.getCurrentFileDateTimestamp();
          let target = null;
          let distance = Infinity;
          // Native enumeration understands custom date formats and nested folders.
          // Pick the nearest existing note, including across skipped days.
          daily.iterateDailyNotes((file, timestamp) => {
            const delta = (timestamp - current) * direction;
            if (delta > 0 && delta < distance) {
              target = file;
              distance = delta;
            }
          });
          // Preserve native notices when no previous/next daily note exists.
          if (!target) return original.apply(this, args);
          void navigate(target, {}, settings[setting]);
        } catch (error) {
          reportError(error);
        }
        return available;
      });
    }
  }

  return () => {
    active = false;
    cleanups.forEach((cleanup) => cleanup());
  };
}

class QuickSwitcherTabReuseSettings extends PluginSettingTab {
  constructor(app, plugin) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display() {
    this.containerEl.empty();
    new Setting(this.containerEl)
      .setName("Open unopened files in")
      .setDesc("Destination for the Quick Switcher and Daily Notes set to Follow existing tab when the note is not already open.")
      .addDropdown((dropdown) => dropdown
        .addOption("new", "New tab")
        .addOption("current", "Current tab")
        .setValue(this.plugin.settings.openIn)
        .onChange(async (value) => {
          this.plugin.settings.openIn = value;
          await this.plugin.saveData(this.plugin.settings);
        }));

    for (const [key, label] of [["dailyToday", "Today"], ["dailyPrevious", "Previous"], ["dailyNext", "Next"]]) {
      new Setting(this.containerEl)
        .setName(`Daily Notes: ${label}`)
        .setDesc("Follow uses the destination above if no tab is open. Always modes use their destination even if the note is already open; Current tab also uses pinned tabs.")
        .addDropdown((dropdown) => dropdown
          .addOption("follow", "Follow existing tab when open")
          .addOption("new", "Always open in new tab")
          .addOption("current", "Always open in current tab")
          .setValue(this.plugin.settings[key])
          .onChange(async (value) => {
            this.plugin.settings[key] = value;
            await this.plugin.saveData(this.plugin.settings);
          }));
    }
  }
}

module.exports = class QuickSwitcherTabReuse extends Plugin {
  async onload() {
    let active = true;
    this.register(() => { active = false; });
    this.settings = { ...DEFAULT_SETTINGS, ...await this.loadData() };
    if (!active) return;
    this.addSettingTab(new QuickSwitcherTabReuseSettings(this.app, this));
    this.app.workspace.onLayoutReady(() => {
      if (!active) return;
      const reportError = (error) => {
        console.error("Quick Switcher Tab Reuse failed", error);
        new Notice("Quick Switcher Tab Reuse could not open the file. See the developer console for details.");
      };
      const navigate = createNavigator(this.app, this.settings, reportError);
      // This is the native switcher's internal selection hook, not a new switcher.
      const prototype = this.app.internalPlugins?.plugins?.switcher?.instance?.QuickSwitcherModal?.prototype;
      if (typeof prototype?.onChooseSuggestion !== "function") {
        new Notice("Quick Switcher Tab Reuse: enable the core Quick Switcher, then reload this plugin. The native selection hook is unavailable.");
      } else {
        this.register(connectSwitcher(prototype, this.app, navigate));
      }
      this.register(connectDailyNotes(this.app, this.settings, navigate, reportError));
    });
  }
};
