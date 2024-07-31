return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      underline = true,
      virtual_text = false,
    },
    inlay_hints = { enabled = false },

    servers = {
      -- pyright will be automatically installed with mason and loaded with lspconfig
      sourcekit = {
        cmd = { "xcrun", "sourcekit-lsp" },
        filetypes = { "swift" },
        root_dir = function(filename, _)
          return require("lspconfig.util").root_pattern("Package.swift", ".git")(filename)
        end,
      },
    },
  },
}
