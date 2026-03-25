# Create a new worktree + branch (works from any subdir of the repo).
ga() {
  if [[ -z "$1" ]]; then
    echo "Usage: ga <branch> [<start-point>] [--here]"
    echo "  ga feat/foo main        # branch from main"
    echo "  ga feat/foo origin/main # branch from origin/main"
    echo "  ga feat/foo <sha>       # branch from a commit"
    echo "  ga feat/foo --here      # create worktree inside repo root/.worktrees"
    return 1
  fi

  local branch="$1"
  local start="${2:-HEAD}"
  local here_flag="$3"

  # Repo root no matter where you are
  local top
  top="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Not inside a git repository."
    return 1
  }

  # Prefer placing worktrees next to the main repo folder,
  # but optionally keep them under .worktrees inside the repo.
  local repo_name parent_dir worktrees_dir
  repo_name="$(basename "$top")"
  parent_dir="$(dirname "$top")"
  if [[ "$start" == "--here" || "$here_flag" == "--here" ]]; then
    worktrees_dir="$top/.worktrees"
  else
    worktrees_dir="$parent_dir"
  fi
  mkdir -p "$worktrees_dir" 2>/dev/null

  # Directory name: repo--branch, but sanitize / to -
  local safe_branch="${branch//\//-}"
  local worktree_path="$worktrees_dir/${repo_name}--${safe_branch}"

  # If branch already has a worktree, jump to it
  local existing
  existing="$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
    $1=="worktree"{p=$2}
    $1=="branch" && $2==b{print p}
  ' | head -n1)"

  if [[ -n "$existing" ]]; then
    echo "Worktree for '$branch' already exists at: $existing"
    cd "$existing" || return 1
    return 0
  fi

  # If dir exists, avoid clobbering
  if [[ -e "$worktree_path" ]]; then
    local i=2
    while [[ -e "${worktree_path}--$i" ]]; do i=$((i + 1)); done
    worktree_path="${worktree_path}--$i"
  fi

  # Create worktree + branch
  if [[ "$start" == "--here" ]]; then
    start="HEAD"
  fi
  git worktree add -b "$branch" "$worktree_path" "$start" || return 1

  # Optional: trust via mise if you use it
  # mise trust "$worktree_path" 2>/dev/null || true

  cd "$worktree_path" || return 1
}

# Remove current worktree and (optionally) its branch.
gd() {
  # Must be inside a worktree
  local top main
  top="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Not inside a git repository."
    return 1
  }

  # Find the main worktree (where .git is a directory)
  main="$(git worktree list --porcelain | awk '
    $1=="worktree"{p=$2}
    $1=="gitdir" && $2 !~ /\.git\/worktrees\// {print p}
  ' | head -n1)"

  # Determine branch (empty if detached)
  local branch
  branch="$(git symbolic-ref -q --short HEAD 2>/dev/null || true)"

  # Protect against deleting main worktree
  if [[ -n "$main" && "$top" == "$main" ]]; then
    echo "Refusing to remove the main worktree: $top"
    return 1
  fi

  if ! gum confirm "Remove worktree $(basename "$top")${branch:+ and branch $branch}?"; then
    return 0
  fi

  # Remove worktree directory by absolute path
  git worktree remove "$top" --force || return 1

  # Delete branch only if it exists and we were on one
  if [[ -n "$branch" ]]; then
    # If it's checked out elsewhere, this will fail (good).
    git -C "${main:-.}" branch -D "$branch"
  fi
}
