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

if vim.env.TMUX then
  local lazygit_tmux_nav = vim.api.nvim_create_augroup("lazygit_tmux_nav", { clear = true })

  vim.api.nvim_create_autocmd("TermOpen", {
    group = lazygit_tmux_nav,
    pattern = "term://*lazygit*",
    callback = function(event)
      local function tmux_select(direction)
        return function()
          vim.fn.jobstart({ "tmux", "select-pane", direction }, { detach = true })
        end
      end

      local opts = { buffer = event.buf, silent = true }
      vim.keymap.set("t", "<C-h>", tmux_select("-L"), opts)
      vim.keymap.set("t", "<C-j>", tmux_select("-D"), opts)
      vim.keymap.set("t", "<C-k>", tmux_select("-U"), opts)
      vim.keymap.set("t", "<C-l>", tmux_select("-R"), opts)
    end,
  })
end
