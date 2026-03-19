-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable Lsp diagnostics for scratch buffers (not working)
local find_scratch = function(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  return vim.iter(Snacks.scratch.list()):find(function(s)
    return s.file == file
  end)
end
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("scratch_diagnostic", { clear = true }),
  pattern = "markdown",
  callback = function(e)
    if find_scratch(e.buf) then
      vim.diagnostic.enable(false, { bufnr = e.buf })
    end
  end,
})
