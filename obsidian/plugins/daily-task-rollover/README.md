# Daily Task Rollover

A local, dependency-free Obsidian plugin. No build step.

The source lives in `~/.config/obsidian/plugins/daily-task-rollover/`. Run
`python3 ~/.config/obsidian/sync-plugins.py` to link it into your registered
vaults. See the [shared setup instructions](../../README.md) for other machines.

Enable **Daily Task Rollover** in Settings → Community plugins. Reload Obsidian
if the plugin is not listed. In Settings → Daily Task Rollover, choose a
**Rollover trigger**:

- **When creating today's daily note** (default): automatically carries tasks
  when today's note is created, including through the core Daily Notes command.
- **Command only**: carries tasks only when you run the rollover command.

Changing the setting takes effect immediately and is saved across restarts.
Opening an existing note or starting Obsidian does not trigger rollover.

The command **Daily Task Rollover: Carry unfinished tasks into today** also works
when today's note already exists. It always targets today, never the active
historical or future note. Enabling the plugin alone does not modify notes.
Repeated commands skip existing task and bullet-note text, including tasks completed today.

## Behavior

- Reads the core Daily Notes folder and date format when enabled. Reload the
  plugin after changing those settings. No Periodic Notes dependency.
- Finds the most recent earlier daily note, including across skipped days.
- Copies nonempty tasks with any single-character checkbox status except `[x]`
  or `[X]` (completed), `[>]` (migrated), and `[-]` (cancelled). This includes
  `[ ]`, `[/]`, `[<]`, `[!]`, `[?]`, and `[B]`, as well as other custom statuses.
  Copies tasks from anywhere in that note under `## Tasks`, preserving their status.
  Creates the heading if missing. Ignores frontmatter, fenced code, and HTML comments.
- Never modifies previous notes. Copies are independent: completing today's
  task does not check off an earlier copy.
- Preserves task nesting, indentation, and list markers. Plain list ancestors
  are included as context. Completed, migrated, or cancelled ancestors of open
  tasks are included as plain bullets without checkboxes; closed siblings are omitted.
- Carries plain child list items (such as `- Details`) with unfinished tasks,
  including nested bullet notes. Standalone bullets and notes beneath closed tasks
  are omitted unless needed as context for an unfinished task.
- Matches duplicate task text and its ancestor labels after trimming outer
  whitespace, regardless of checkbox state or bullet style. Identical child
  labels under different parents remain separate. New children are merged under
  existing parents without changing today's task statuses.
- Copies single-line task and list-item text only; continuation text is not carried.
- Rollover notices count new tasks and their bullet notes, excluding ancestors
  included only as context. New notes are carried even if their task already exists today.
- Uses an atomic vault update and prevents overlapping runs.

There is no task deletion, sync engine, configurable statuses, or persistent
rollover history.

## Verification

Run `node --test main.test.cjs` in this directory. Tests use Obsidian API stubs;
actual loading and UI behavior must be checked in Obsidian.
