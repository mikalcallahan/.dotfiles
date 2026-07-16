_git_worktrees_choose() {
  local prompt="$1"
  shift

  if command -v gum >/dev/null 2>&1; then
    gum choose --header "$prompt" "$@"
    return
  fi

  local i=1 choice option
  printf '%s\n' "$prompt" >&2
  for option in "$@"; do
    printf '  %d) %s\n' "$i" "$option" >&2
    i=$((i + 1))
  done

  while true; do
    printf 'Choose [1-%d]: ' "$#" >&2
    read -r choice || return 1

    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= $# )); then
      i=1
      for option in "$@"; do
        if (( i == choice )); then
          printf '%s\n' "$option"
          return 0
        fi
        i=$((i + 1))
      done
    fi
  done
}

_git_worktrees_path_in_list() {
  local target_path="$1"
  git worktree list --porcelain | awk -v target="$target_path" '
    index($0, "worktree ")==1 && substr($0, 10)==target {found=1; exit}
    END{exit !found}
  '
}

_git_worktrees_next_path() {
  local base_path="$1"
  local candidate="$base_path"
  local i=2

  while [[ -e "$candidate" ]] || _git_worktrees_path_in_list "$candidate"; do
    candidate="${base_path}--$i"
    i=$((i + 1))
  done

  printf '%s\n' "$candidate"
}

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

  if [[ "$start" == "--here" ]]; then
    here_flag="--here"
    start="HEAD"
  fi

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

  # If branch already has a worktree, decide whether to reuse it or create a replacement.
  local existing choice force_checkout
  existing="$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
    index($0, "worktree ")==1{p=substr($0, 10)}
    index($0, "branch ")==1 && substr($0, 8)==b{print p; exit}
  ')"

  if [[ -n "$existing" ]]; then
    echo "Worktree for '$branch' already exists at: $existing"
    choice="$(_git_worktrees_choose "How would you like to continue?" \
      "Use existing worktree" \
      "Delete existing worktree and create a new one" \
      "Ignore existing worktree and create another")" || return 1

    case "$choice" in
      "Use existing worktree")
        cd "$existing" || return 1
        return 0
        ;;
      "Delete existing worktree and create a new one")
        git worktree remove "$existing" --force || return 1
        ;;
      "Ignore existing worktree and create another")
        worktree_path="$(_git_worktrees_next_path "$worktree_path")"
        force_checkout=1
        ;;
    esac
  fi

  # If the branch-derived path is already occupied, decide how to handle it.
  if _git_worktrees_path_in_list "$worktree_path"; then
    echo "A worktree already exists at the branch-derived path: $worktree_path"
    choice="$(_git_worktrees_choose "How would you like to continue?" \
      "Use existing worktree" \
      "Delete existing worktree and create a new one" \
      "Ignore existing worktree and create another")" || return 1

    case "$choice" in
      "Use existing worktree")
        cd "$worktree_path" || return 1
        return 0
        ;;
      "Delete existing worktree and create a new one")
        git worktree remove "$worktree_path" --force || return 1
        ;;
      "Ignore existing worktree and create another")
        worktree_path="$(_git_worktrees_next_path "$worktree_path")"
        ;;
    esac
  elif [[ -e "$worktree_path" ]]; then
    echo "Target path already exists and is not a registered worktree: $worktree_path"
    choice="$(_git_worktrees_choose "How would you like to continue?" \
      "Ignore existing path and create another" \
      "Cancel")" || return 1

    case "$choice" in
      "Ignore existing path and create another")
        worktree_path="$(_git_worktrees_next_path "$worktree_path")"
        ;;
      "Cancel")
        return 1
        ;;
    esac
  fi

  # Create a worktree from an existing local branch when possible; otherwise create the branch.
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    if [[ "$force_checkout" == "1" ]]; then
      git worktree add --force "$worktree_path" "$branch" || return 1
    else
      git worktree add "$worktree_path" "$branch" || return 1
    fi
  else
    git worktree add -b "$branch" "$worktree_path" "$start" || return 1
  fi

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
