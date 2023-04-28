return {
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    event = "VeryLazy",
    opts = {
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.concealer"] = {}, -- Adds pretty icons to your documents
        ["core.export"] = {}, -- Adds pretty icons to your documents
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            default_workspace = "home",
            workspaces = {
              home = "~/Documents/notes",
              spendline = "~/Developer/spendline/notes",
            },
          },
        },
      },
    },
    dependencies = { { "nvim-lua/plenary.nvim" } },
  },
}
