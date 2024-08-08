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
        { "<leader>a", group = "+ai", icon = { icon = "󰝒", hl = "false" } },
        { "<leader>ac", "<cmd>ChatGPT<cr>", desc = "chat", icon = { icon = "󱅄", hl = "false" } },
        { "<leader>at", "<cmd>ChatGPTRun translate<cr>", desc = "translate", icon = { icon = "󱅄", hl = "false" } },
        {
          "<leader>ao",
          "<cmd>ChatGPTRun optimize_code<cr>",
          desc = "optimize code",
          icon = { icon = "󱅄", hl = "false" },
        },
        { "<leader>as", "<cmd>ChatGPTRun summarize<cr>", desc = "summarize", icon = { icon = "󱅄", hl = "false" } },
        { "<leader>aa", "<cmd>ChatGPTRun add_tests<cr>", desc = "add tests", icon = { icon = "󱅄", hl = "false" } },
      },
    },
  },
  -- opts = function(_, opts)
  --   opts.spec["<leader>a"] = {
  --     name = "ChatGPT",
  --     c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
  --     e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
  --     g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
  --     t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
  --     k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
  --     d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
  --     a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
  --     o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
  --     s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
  --     f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
  --     x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
  --     r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
  --     l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
  --   }
  --   return opts
  -- end,
}
