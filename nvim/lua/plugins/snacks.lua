-- lazy.nvim
return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      git_ignored = true, -- Show Git-ignored files
      respect_gitignore = false, -- Don't let Git hide files
    },
    picker = {
      git_ignored = true, -- Show Git-ignored files
      respect_gitignore = false, -- Don't let Git hide files
    },
    terminal = {
      win = {
        height = 0.3,
      },
    },
    lazygit = {
      win = {
        style = "float",
        height = 0.9,
        width = 0.9,
      },
    },
  },
}
