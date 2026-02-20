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

-- unset default keymaps
vim.keymap.del("n", "<leader>ub") -- remove disable dark background

-- config
map("n", "<leader>C", LazyVim.pick.config_files(), { desc = "Open Config" })

-- Find all files
map(
  "n",
  "<leader>fa",
  "<cmd>:Telescope find_files find_command=rg,--ignore,--hidden,--files <cr>",
  { desc = "Find all files" }
)

-- ui
map("n", "E", "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Show line diagnostics" })
map("n", "<leader>ub", "<cmd>Gitsigns toggle_current_line_blame <cr>", { desc = "Toggle current line blame" })

-- Visual mode scroll mappings
map("x", "<C-u>", "<C-u>zz", { desc = "Scroll up in visual mode", silent = true })
map("x", "<C-d>", "<C-d>zz", { desc = "Scroll down in visual mode", silent = true })
