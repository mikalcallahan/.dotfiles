return {
  "folke/which-key.nvim",
  opts = {
    delay = 1,
    preset = "helix",
    spec = {
      {
        mode = { "n" },
        -- { "<leader>n", group = "+new", icon = { icon = "󰝒", hl = "false" } },
        { "<leader>gr", "<cmd>CodeDiff<cr>", desc = "Code Diff" },
        { "<leader>o", group = "+obsidian", icon = { icon = "󰈙", hl = "false" } },
        { "<leader>ol", group = "+links", icon = { icon = "", hl = "false" } },
        { "<leader>ow", group = "+workspaces", icon = { icon = "󰷉", hl = "false" } },
        {
          "<leader>of",
          "<cmd>Obsidian quick_switch<cr>",
          desc = "files",
          icon = { icon = "󰈞", hl = "false" },
        },
        {
          "<leader>og",
          "<cmd>Obsidian search<cr>",
          desc = "grep file contents",
          -- icon = { icon = "􀕹", hl = "false" },
          icon = { icon = "󰱼", hl = "false" },
        },
        {
          "<leader>od",
          "<cmd>Obsidian dailies<cr>",
          desc = "dailies",
          icon = { icon = "󰃶", hl = "false" },
        },
        {
          "<leader>ob",
          "<cmd>Obsidian backlinks<cr>",
          desc = "backlinks",
          icon = { icon = "", hl = "false" },
        },
        {
          "<leader>on",
          "<cmd>Obsidian new<cr>",
          desc = "new",
          icon = { icon = "󰝒", hl = "false" },
        },
        {
          "<leader>oww",
          "<cmd>Obsidian workspace work<cr>",
          desc = "obsidian workspaces: work",
          icon = { icon = "􀤧", hl = "false" },
        },
        {
          "<leader>owp",
          "<cmd>Obsidian workspace personal<cr>",
          desc = "obsidian workspaces: personal",
          icon = { icon = "􀤧", hl = "false" },
        },
      },
    },
  },
}
