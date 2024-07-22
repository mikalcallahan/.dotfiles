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
      },
    },
  },
}
