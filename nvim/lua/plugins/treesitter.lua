return {
  "nvim-treesitter",
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, { "angular", "scss" })
    end
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      pattern = { "*.analog", "*.analog" },
      callback = function()
        vim.treesitter.start(nil, "vim")
      end,
    })
  end,
}
