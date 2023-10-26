-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- f{ind,ile}
map("n", "<leader>ft", "<cmd>ToggleTerm <cr>", { desc = "Terminal" })
map("n", "<leader>fB", "<cmd>Neotree dir=~/ <cr>", { desc = "File Browser" })
map(
  "n",
  "<leader>fa",
  "<cmd>:Telescope find_files find_command=rg,--ignore,--hidden,--files <cr>",
  { desc = "Find all files" }
)

-- new {file, terminal}
map("n", "<leader>nf", "<cmd>ene | startinsert <cr>", { desc = "New File " })
map("n", "<leader>nt", "<cmd>terminal <cr>", { desc = "Terminal Buffer" })

-- config
map("n", "<leader>C", "<cmd>lua require('lazyvim.util').telescope.config_files()() <cr>", { desc = "Open Config" })

-- ui
map("n", "<leader>ub", "<cmd>Gitsigns toggle_current_line_blame <cr>", { desc = "Toggle current line blame" })
