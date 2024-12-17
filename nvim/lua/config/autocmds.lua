-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Hide line numbers for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("*"),
  command = "setlocal nonumber norelativenumber",
})

local nativeTermGroup = vim.api.nvim_create_augroup("TerminalSettings", { clear = true })

vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "BufEnter" }, {
  group = nativeTermGroup,
  pattern = "term://*",
  callback = function()
    vim.wo.relativenumber = false
    vim.wo.number = false
    vim.o.signcolumn = "no"
    vim.cmd([[startinsert]])
    if vim.bo.filetype ~= "snacks_terminal" then
      vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
      vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Above Window" })
      vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "swift" }, -- List of filetypes
  callback = function()
    vim.opt_local.expandtab = true -- Set expandtab option
    vim.opt_local.shiftwidth = 2 -- Set shiftwidth to 2
    vim.opt_local.tabstop = 2 -- Set tabstop to 2
    vim.opt_local.softtabstop = 2 -- Set softtabstop to 2
  end,
})

vim.cmd([[
  augroup FileTypeAnalog
    autocmd!
    autocmd BufRead,BufNewFile *.analog set filetype=analog
  augroup END
]])
