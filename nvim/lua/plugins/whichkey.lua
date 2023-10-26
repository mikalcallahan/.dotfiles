return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    opts.defaults["<leader>n"] = { name = "+new" }
    opts.defaults["<leader>o"] = { name = "+org" }
    opts.defaults["<leader>on"] = { name = "+new" }
    return opts
  end,
}
