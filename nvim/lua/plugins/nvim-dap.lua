return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "jay-babu/mason-nvim-dap.nvim",
      event = "BufReadPre",
    },
  },
  opts = function()
    local dap = require("dap")
    dap.adapters.firefox = {
      type = "executable",
      command = "node",
      args = {
        os.getenv("HOME") .. ".vscode/extensions/firefox-devtools.vscode-firefox-debug-2.9.10/dist/adapter.bundle.js",
      },
    }

    dap.configurations.typescript = {
      {
        name = "Debug with Firefox",
        type = "firefox",
        request = "launch",
        reAttach = true,
        url = "http://localhost:4200",
        webRoot = "${workspaceFolder}",
        -- firefoxExecutable = "/Applications/Firefox Developer Edition.app/Contents/MacOS/firefox -start-debugger-server",
        pathMappings = {
          {
            url = "webpack:///projects/client-ui",
            path = "${workspaceFolder}/projects/client-ui",
          },
          {
            url = "webpack:///projects/client-ui",
            path = "${workspaceFolder}/projects/client-ui",
          },
          {
            url = "webpack:///projects/concerto-cards",
            path = "${workspaceFolder}/projects/concerto-cards",
          },
        },
      },
    }
  end,
}
