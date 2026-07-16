local home = vim.fn.expand("$HOME")

return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  enabled = false,
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "gpg --decrypt " .. home .. "/Documents/openaikey.gpg",
      openai_params = {
        -- NOTE: model can be a function returning the model name
        -- this is useful if you want to change the model on the fly
        -- using commands
        -- Example:
        -- model = function()
        --     if some_condition() then
        --         return "gpt-5"
        --     else
        --         return "gpt-5-mini"
        --     end
        -- end,
        model = "gpt-5.2",
        -- frequency_penalty = 0,
        -- presence_penalty = 0,
        -- max_tokens = 4095,
        -- temperature = 0.2,
        -- top_p = 0.1,
        -- n = 1,
      },
    })

    -- vim.keymap.set("n", "<leader>ac", "<cmd>ChatGPT<cr>", { desc = "ChatGPT: open ChatGPT" })
  end,
  keys = {
    { "<leader>ac", "<cmd>ChatGPT<cr>", desc = "ChatGPT: open ChatGPT" },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim", -- optional
    "nvim-telescope/telescope.nvim",
  },
}
