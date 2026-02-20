return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_z = {
          {
            "datetime",
            style = "%-I:%M %p", -- 12-hour, e.g. 3:07 PM
            icon = "",
          },
        },
      },
    },
  },
}
