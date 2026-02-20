# Create a new worktree and branch from within current git directory.
# TODO: use `git rev-parse --show-toplevel` to get git root (for monorepos/nested folders)
ga() {
  if [[ -z "$1" ]]; then
    echo "Usage: ga [branch name]"
    return 1
  fi

  local branch="$1"
  local base="$(basename "$PWD")"
  local worktree_path="../${base}--${branch}"

  git worktree add -b "$branch" "$worktree_path"
  # mise trust "$worktree_path"
  cd "$worktree_path"
}

# Remove worktree and branch from within active worktree directory.
# TODO: use `git rev-parse --show-toplevel` to get git root (for monorepos/nested folders)
gd() {
  if gum confirm "Remove worktree and branch?"; then
    local cwd base branch root

    cwd="$(pwd)"
    worktree="$(basename "$cwd")"

    # split on first `--`
    root="${worktree%%--*}"
    branch="${worktree#*--}"

    # Protect against accidentially nuking a non-worktree directory
    if [[ "$root" != "$worktree" ]]; then
      cd "../$root"
      git worktree remove "$worktree" --force
      git branch -D "$branch"
    fi
  fi
}
