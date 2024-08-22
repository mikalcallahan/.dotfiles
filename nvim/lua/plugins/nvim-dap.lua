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
      {
        name = "Launch NestJS (Debug Mode)",
        type = "pwa-node",
        request = "launch",
        -- cwd = vim.fn.getcwd(),
        cwd = "${workspaceFolder}/magi",
        runtimeExecutable = "npm", -- Specify npm as the runtime executable
        args = { "run", "start:debug" }, -- Pass the run command and script name as arguments
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
        outFiles = { "${workspaceFolder}/magi/dist/**/*.js" },
        skipFiles = {
          "${workspaceFolder}/magi/node_modules/**/*.js",
          "<node_internals>/**",
        },
      },
      {
        -- For this to work you need to make sure the node process is started with the `--inspect` flag.
        name = "Attach to NestJS process",
        type = "node2",
        request = "attach",
        processId = require("dap.utils").pick_process,
        protocol = "inspector",
        console = "integratedTerminal",
      },
    }
  end,
}
