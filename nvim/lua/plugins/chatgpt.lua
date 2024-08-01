return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  enabled = false,
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "bw get password openai-key",
      openai_params = {
        model = "gpt-4o",
      },
    })
  end,
}
