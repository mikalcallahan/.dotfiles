# Create a tmux layout for dev with editor, ai, and terminal
tml() {
  local dir="$PWD"
  local right_pane ai_pane
  local shell_bin="${SHELL:-/bin/zsh}"
  local nvim_bin="/opt/homebrew/bin/nvim"
  local -a ai_cmd
  if (($#)); then
    ai_cmd=("$@")
  else
    ai_cmd=(opencode)
  fi
  [[ -n "$TMUX" ]] || {
    print -u2 "tml: run this inside tmux"
    return 1
  }
  right_pane=$(tmux display-message -p '#{pane_id}') || return 1
  tmux split-window -v -p 15 -c "$dir" || return 1
  tmux select-pane -t "$right_pane" || return 1
  tmux split-window -h -b -p 70 -t "$right_pane" -c "$dir" \
    "$shell_bin -lc '$nvim_bin; exec $shell_bin -l'" || return 1
  ai_pane="$right_pane"
  tmux send-keys -t "$ai_pane" "opencode" C-m

  # Focus left pane (nvim pane) without changing launch behavior
  tmux select-pane -t "$right_pane"
  # Slight delayed focus to left pane
  tmux run-shell -b "sleep 0.75; tmux select-pane -t '$right_pane'; tmux select-pane -L"
  # tmux select-pane -L
}

# @NOTE: works but pane is focused to the right
# tml() {
#   local dir="$PWD"
#   local right_pane
#   local shell_bin="${SHELL:-/bin/zsh}"
#   local nvim_bin="/opt/homebrew/bin/nvim"
#   local -a ai_cmd
#   if (( $# )); then
#     ai_cmd=("$@")
#   else
#     ai_cmd=(opencode)
#   fi
#   [[ -n "$TMUX" ]] || { print -u2 "tml: run this inside tmux"; return 1; }
#
#   # Get current pane ID (will become editor pane after splits)
#   editor_pane=$(tmux display-message -p '#{pane_id}')
#   right_pane=$(tmux display-message -p '#{pane_id}') || return 1
#   # Bottom terminal (15%)
#   tmux split-window -v -p 15 -c "$dir"
#   # Back to top pane (this will be the right/opencode pane)
#   tmux select-pane -t "$right_pane"
#   # Create LEFT pane and run nvim there directly
#   tmux split-window -h -b -p 70 -t "$right_pane" -c "$dir" \
#     "$shell_bin -lc '$nvim_bin; exec $shell_bin -l'"
#   # Keep focus in right pane and run AI directly (no send-keys)
#   tmux select-pane -t "$right_pane"
#   # "${ai_cmd[@]}"
#   ai_pane=$(tmux display-message -p '#{pane_id}')
#   tmux send-keys -t "$ai_pane" "opencode" C-m
#
#   # Select the nvim pane for focus
#   tmux select-pane -t "$editor_pane"
#
# }

# Create a dev layout using tmux with editor, opencode, and terminal
nic() {
  tml opencode
}
