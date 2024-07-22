return {
  "nvim-neorg/neorg",
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
              mazefaze = "~/Developer/web/MazeFaze/notes",
              concerto = "~/dev/concertocard/notes/",
            },
            default_workspace = "notes",
          },
        },
      },
    })
  end,
}
