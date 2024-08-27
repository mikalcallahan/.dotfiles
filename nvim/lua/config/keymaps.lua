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

-- CodeSnap
map("x", "<leader>cs", ":CodeSnapSave<cr>", { desc = "CodeSnap save to ~/Desktop", silent = true })
map("x", "<leader>cS", ":CodeSnapSave<cr>", { desc = "CodeSnap to clipboard", silent = true })

-- f{ind,ile}
map("n", "<leader>ft", "<cmd>1 ToggleTerm <cr>", { desc = "Terminal" })
map("n", "<leader>ft1", "<cmd>1 ToggleTerm <cr>", { desc = "Terminal" })
map("n", "<leader>ft2", "<cmd>2 ToggleTerm <cr>", { desc = "Terminal" })
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

-- org mode
-- map(
--   "n",
--   "<leader>od",
--   "<cmd>terminal open 'https://github.com/nvim-neorg/norg-specs/blob/main/1.0-specification.norg' && <cr>",
--   { desc = "Open docs" }
-- )
map("n", "<leader>onj", "<cmd>Neorg journal <cr>", { desc = "New Journal" })

-- config
map("n", "<leader>C", LazyVim.pick.config_files(), { desc = "Open Config" })

-- ui
map("n", "E", "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Show line diagnostics" })
map("n", "<leader>ub", "<cmd>Gitsigns toggle_current_line_blame <cr>", { desc = "Toggle current line blame" })

-- Visual mode scroll mappings
map("x", "<C-u>", "<C-u>zz", { desc = "Scroll up in visual mode", silent = true })
map("x", "<C-d>", "<C-d>zz", { desc = "Scroll down in visual mode", silent = true })
