-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Zen note creation command
vim.api.nvim_create_user_command("Zen", function(opts)
  local zen = require("zen")
  local filepath = zen.create_note(opts.args)
  if filepath then
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  end
end, { nargs = "+", desc = "Create a new zen note" })
