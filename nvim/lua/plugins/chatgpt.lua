return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "bw get password openai-key",
      openai_params = {
        model = "chatgpt-4o-latest",
        temperature = 1,
        top_p = 1,
      },
      chat = {
        keymaps = {
          close = "Qq",
        },
      },
    })
  end,
}
