return {
  -- Modify nvim-dap
  {
    "mfussenegger/nvim-dap",
    opts = {
      handlers = {
        configurations = {
          typescript = {
            -- The first three options are required by nvim-dap
            {
              name = "Firefox: Debug",
              type = "firefox",
              request = "launch",
              reAttach = true,
              url = "http://localhost:4200",
              webRoot = "${workspaceFolder}",
              firefoxExecutable = vim.fn.exepath("firefox"),
            },
          },
        },
      },
    },
  },
}
