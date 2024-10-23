return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      sorting_strategy = "ascending",

      layout_strategy = "bottom_pane",
      layout_config = {
        height = 24,
      },

      border = true,
      borderchars = {
        prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
        results = { " " },
        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    },
  },
}
