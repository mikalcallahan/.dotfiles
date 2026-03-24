return {
  "folke/sidekick.nvim",
  enabled = false,
  opts = {
    -- nes = { enabled = false },
    cli = {
      mux = {
        enabled = true,
        backend = "tmux", -- or "zellij"
      },
      win = {
        keys = {
          prompt = { "<c-o>", "insert prompt or context", mode = "n" },
        },
      },
    },
  },
}
