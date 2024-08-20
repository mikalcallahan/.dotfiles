return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      underline = true,
      virtual_text = false,
    },
    inlay_hints = { enabled = false },

    servers = {
      sourcekit = {
        cmd = { "xcrun", "sourcekit-lsp" },
        filetypes = { "swift" },
        root_dir = function(filename)
          return require("lspconfig.util").root_pattern("Package.swift", ".git")(filename)
        end,
      },
      analog = {
        cmd = { "analog-language-server", "--stdio" },
        filetypes = { "analog" },
        root_dir = function(filename)
          return require("lspconfig.util").root_pattern("angular.json", "nx.json")(filename)
        end,
      },
      stylelint_lsp = {
        cmd = { "stylelint-lsp" },
        filetypes = { "css", "scss" },
      },
    },
    setup = {
      analog = function(_, opts)
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")
        local util = require("lspconfig.util")

        local function get_tsdk_path()
          local root_dir = util.root_pattern("angular.json", "nx.json")(vim.fn.getcwd())
          if root_dir then
            return root_dir .. "/node_modules/typescript/lib"
          else
            return vim.fn.expand(
              "~/.local/share/nvim/mason/packages/vtsls/node_modules/@vtsls/language-server/node_modules/typescript/lib"
            )
          end
        end

        if not configs.analog then
          configs.analog = {
            default_config = {
              cmd = { "analog-language-server", "--stdio" },
              init_options = {
                typescript = {
                  tsdk = get_tsdk_path(),
                },
              },
              name = "analog",
              filetypes = { "analog" },
              root_dir = function(filename)
                return require("lspconfig.util").root_pattern("angular.json", "nx.json")(filename)
              end,
            },
          }
        end
        lspconfig.analog.setup(opts)
      end,
    },
  },
}
