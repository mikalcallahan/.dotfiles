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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "swift" }, -- List of filetypes
  callback = function()
    vim.opt_local.expandtab = true -- Set expandtab option
    vim.opt_local.shiftwidth = 2 -- Set shiftwidth to 2
    vim.opt_local.tabstop = 2 -- Set tabstop to 2
    vim.opt_local.softtabstop = 2 -- Set softtabstop to 2
  end,
})
