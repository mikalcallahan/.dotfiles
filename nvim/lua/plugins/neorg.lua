return {
  "nvim-neorg/neorg",
  build = ":Neorg sync-parsers",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.concealer"] = {}, -- Adds pretty icons to your documents
        -- ["core.completion"] = {}, -- Adds completion
        -- ["core.ui.calendar"] = {}, -- Adds completion
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = "~/Documents/org/",
              concerto = "~/dev/concertocard/notes/",
            },
            default_workspace = "notes",
          },
        },
      },
    })
  end,
}
