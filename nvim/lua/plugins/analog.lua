return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    LazyVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
      {
        name = "@analogjs/language-server",
        -- location = LazyVim.get_pkg_path("analog-language-server", "/node_modules/@analogjs/language-server"),
        location = vim.fn.expand("/opt/homebrew/lib/node_modules/@analogjs/language-server"), -- Adjust this path to where you have the analog-language-server installed
        enableForWorkspaceTypeScriptVersions = false,
      },
    })
  end,
}
-- return {
--   "neovim/nvim-lspconfig",
--   opts = function(_, opts)
--     if opts.servers.vtsls then
--       print("Extending LazyVim configuration...") -- Logging
--       opts.servers.vtsls.settings = opts.servers.vtsls.settings or {}
--       opts.servers.vtsls.settings.vtsls = opts.servers.vtsls.settings.vtsls or {}
--       opts.servers.vtsls.settings.vtsls.tsserver = opts.servers.vtsls.settings.vtsls.tsserver or {}
--       opts.servers.vtsls.settings.vtsls.tsserver.globalPlugins = opts.servers.vtsls.settings.vtsls.tsserver.globalPlugins
--         or {}
--       table.insert(opts.servers.vtsls.settings.vtsls.tsserver.globalPlugins, {
--         name = "@analogjs/language-server",
--         location = vim.fn.expand("/opt/homebrew/lib/node_modules/@analogjs/language-server"), -- Adjust this path to where you have the analog-language-server installed
--         enableForWorkspaceTypeScriptVersions = false,
--       })
--     end
--   end,
-- }
