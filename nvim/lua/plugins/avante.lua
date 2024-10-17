return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  opts = {
    -- add any opts here
    provider = "openai",
    openai = {
      model = "chatgpt-4o-latest",
    },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
    },
    {
      "grapp-dev/nui-components.nvim",
      dependencies = {
        "MunifTanjim/nui.nvim",
      },
    },
    --- The below is optional, make sure to setup it properly if you have lazy=true
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
