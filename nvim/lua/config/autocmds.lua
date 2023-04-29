-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})
--
-- vim.api.nvim_create_autocmd("TextDocument/hover", {
--   group = augroup("*"),
--   callback = function(_, result, ctx, config)
--     config = config or {}
--     config.focus_id = ctx.method
--     if not (result and result.contents) then
--       vim.notify("No information available")
--       return
--     end
--     local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
--     markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
--     if vim.tbl_isempty(markdown_lines) then
--       -- vim.notify('No information available')
--       return
--     end
--     return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
--   end,
-- })

-- Hide line numbers for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("*"),
  command = "setlocal nonumber norelativenumber",
})
