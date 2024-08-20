return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  enabled = false,
  config = function()
    local home = vim.fn.expand("$HOME")
    require("chatgpt").setup({
      api_key_cmd = "gpg --decrypt " .. home .. "/.config/.apikey.txt.gpg",
      openai_params = {
        model = "gpt-4o",
      },
    })
  end,
}
