---
name: git-worktrees
description: Use when creating, switching to, deleting, or managing git worktrees with git-worktrees.sh, ga, gd, or git worktree.
---

# Git Worktrees

Use this skill when the user asks to add, remove, switch to, inspect, or troubleshoot git worktrees, including requests mentioning `git-worktrees.sh`, `ga`, `gd`, or `git worktree`.

The helper script lives at:

```sh
~/.config/scripts/git-worktrees.sh
```

It defines:

```sh
ga <branch> [<start-point>] [--here]
gd
```

## Add A Worktree

When adding a worktree, first resolve the repository root from the current directory:

```sh
git rev-parse --show-toplevel
```

By default, new worktrees must be created as siblings of the repository root, not beside the current subdirectory.

Example:

```text
cwd:       ~/Developer/example/web
repo root: ~/Developer/example
worktree:  ~/Developer/example--feature-name
```

Only create inside `<repo-root>/.worktrees` when the user explicitly asks for `--here`.

Use this naming convention unless the user requests a different path:

```text
<repo-name>--<branch-with-slashes-replaced-by-dashes>
```

Before creating a worktree, inspect existing worktrees:

```sh
git worktree list --porcelain
```

If an existing worktree is already attached to the requested branch, ask the user whether to:

1. use the existing worktree
2. delete the existing worktree and create a new one
3. ignore the existing worktree and create another

If the branch-derived path already exists or is already registered as a worktree, ask the user whether to:

1. use it, when it is a registered worktree
2. delete it and create a new one, when it is a registered worktree
3. ignore it and create another suffixed path, such as `--2`
4. cancel, when the path exists but is not a registered worktree

If the local branch already exists but has no worktree, create the worktree without `-b`:

```sh
git worktree add "<path>" "<branch>"
```

If the local branch does not exist, create it from the requested start point, defaulting to `HEAD`:

```sh
git worktree add -b "<branch>" "<path>" "<start-point>"
```

If intentionally creating another worktree for a branch that is already checked out elsewhere, use a suffixed path and `--force`:

```sh
git worktree add --force "<path>" "<branch>"
```

## Using The Helper Script

Prefer the helper script when it can complete without requiring an interactive terminal prompt:

```sh
source ~/.config/scripts/git-worktrees.sh && ga "<branch>" "<start-point>"
```

The `ga` function already implements duplicate detection and existing-local-branch handling. However, it may prompt interactively when conflicts exist. For opencode tool calls, preflight with `git worktree list --porcelain`; if a conflict exists, ask the user for the desired option before running commands.

## Remove A Worktree

When removing a worktree, never remove the main worktree. Identify the main worktree from `git worktree list --porcelain`; it is the entry whose `gitdir` is the repository's `.git` directory rather than `.git/worktrees/...`.

If the user asks to remove the current worktree and they have confirmed, the helper can be used:

```sh
source ~/.config/scripts/git-worktrees.sh && gd
```

If an interactive prompt would be unsafe or unsupported, remove the worktree directly after explicit user confirmation:

```sh
git worktree remove "<worktree-path>" --force
```

If deleting the branch is also requested, delete it from the main worktree after the worktree is removed:

```sh
git -C "<main-worktree-path>" branch -D "<branch>"
```

Do not delete branches unless the user explicitly requests or confirms that behavior.

## Safety Rules

Do not run destructive worktree removal commands without user confirmation.

Do not overwrite an existing non-worktree directory. Ask whether to use another suffixed path or cancel.

Do not assume the current directory is the repo root; always resolve it.

Quote all paths and branch names in shell commands.
