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

map("n", "<leader>ft", "<cmd>ToggleTerm <cr>", { desc = "Terminal" })
map("n", "<leader>fT", "<cmd>terminal <cr>", { desc = "Terminal window" })
map("n", "<leader>fst", "<cmd>2 ToggleTerm <cr>", { desc = "Split Terminal" })
map("n", "<leader>fp", "<cmd>Telescope projects <cr>", { desc = "Find project" })
map("n", "<leader>C", "<cmd> e $MYVIMRC <cr>", { desc = "Open Config" })
map("n", "<leader>ub", "<cmd>Gitsigns toggle_current_line_blame <cr>", { desc = "Toggle current line blame" })
map("n", "<leader>Owh", "<cmd>Neorg workspace home <cr>", { desc = "Switch Neorg workspace to Home " })
map("n", "<leader>Ows", "<cmd>Neorg workspace spendline <cr>", { desc = "Switch Neorg workspace to Spendline" })
