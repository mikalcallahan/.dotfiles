return {
  "folke/which-key.nvim",
  opts = {
    delay = 0,
    preset = "helix",
    spec = {
      {
        mode = { "n" },
        { "<leader>n", group = "+new", icon = { icon = "󰝒", hl = "false" } },
        { "<leader>o", group = "+org", icon = { icon = "󱅄", hl = "false" } },
        { "<leader>on", group = "+new", icon = { icon = "󰷥", hl = "false" } },
        { "<leader>oo", desc = "Org Options", icon = { icon = "", hl = "false" } },
      },
    },
  },
  -- opts = function(_, opts)
  --   opts.spec["<leader>n"] = { name = "+new" }
  --   opts.spec["<leader>o"] = { name = "+org" }
  --   opts.spec["<leader>on"] = { name = "+new" }
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
