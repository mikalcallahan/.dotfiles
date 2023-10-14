return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    opts.defaults["<leader>n"] = { name = "+new" }
    return opts
  end,
}
