return {
  "folke/which-key.nvim",
  opts = {
    delay = 1,
    preset = "helix",
    spec = {
      {
        mode = { "n" },
        { "<leader>n", group = "+new", icon = { icon = "󰝒", hl = "false" } },
        { "<leader>o", group = "+org", icon = { icon = "󱅄", hl = "false" } },
        { "<leader>on", group = "+new", icon = { icon = "󰷥", hl = "false" } },
        -- { "<leader>oo", desc = "Org Options", "<cmd>", icon = { icon = "", hl = "false" } },
      },
      {
        mode = { "n", "v" },
        { "<leader>X", group = "+xcodebuild", icon = { icon = "󰝒", hl = "false" } },
        { "<leader>Xs", "<cmd>XcodebuildPicker<cr>", desc = "build picker", icon = { icon = "󱅄", hl = "false" } },
        { "<leader>Xb", "<cmd>XcodebuildBuild<cr>", desc = "build project", icon = { icon = "󱅄", hl = "false" } },
        {
          "<leader>Xr",
          "<cmd>XcodebuildBuildRun<cr>",
          desc = "build & run project",
          icon = { icon = "󱅄", hl = "false" },
        },
        {
          "<leader>Xa",
          "<cmd>XcodebuildCodeActions<cr>",
          desc = "code actions",
          icon = { icon = "󱅄", hl = "false" },
        },
        { "<leader>Xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "toggle logs", icon = { icon = "󱅄", hl = "false" } },
        { "<leader>XS", "<cmd>XcodebuildSetup<cr>", desc = "setup project", icon = { icon = "󱅄", hl = "false" } },
        {
          "<leader>Xd",
          "<cmd>XcodebuildSelectDevice<cr>",
          desc = "select device",
          icon = { icon = "󱅄", hl = "false" },
        },
        {
          "<leader>Xq",
          "<cmd>Telescope quickfix<cr>",
          desc = "telescope quickfix",
          icon = { icon = "󱅄", hl = "false" },
        },
      },
      {
        mode = { "n", "v" },
        { "<leader>a", group = "+ai", icon = { icon = "ﮧ", hl = "false" } },
        { "<leader>ac", "<cmd>ChatGPT<cr>", desc = "chat", icon = { icon = "", hl = "false" } },
        { "<leader>at", "<cmd>ChatGPTRun translate<cr>", desc = "translate", icon = { icon = "", hl = "false" } },
        { "<leader>ag", "<cmd>ChatGPTActAs<cr>", desc = "chatgpt act as", icon = { icon = "󱉕", hl = "false" } },
        {
          "<leader>ao",
          "<cmd>ChatGPTRun optimize_code<cr>",
          desc = "optimize code",
          icon = { icon = "", hl = "false" },
        },
        { "<leader>as", "<cmd>ChatGPTRun summarize<cr>", desc = "summarize", icon = { icon = "", hl = "false" } },
        { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "ask", icon = { icon = "", hl = "false" } },
        { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "refresh", icon = { icon = "", hl = "false" } },
      },
    },
  },
}
