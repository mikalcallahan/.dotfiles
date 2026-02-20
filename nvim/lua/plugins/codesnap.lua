return {
  "mistricky/codesnap.nvim",
  build = "make",
  keys = {
    { "<leader>cx", "<cmd>CodeSnap<cr>", mode = "x", desc = "Copy selected code snapshot into clipboard" },
    {
      "<leader>cz",
      "<cmd>CodeSnapSave<cr>",
      mode = "x",
      desc = "Save selected code snapshot",
    },
  },
  opts = {
    save_path = "~/Pictures/Screenshots/code",
    has_breadcrumbs = true,
    watermark = "",
  },
}
