-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use Telescope as the default picker instead of Snacks
vim.g.lazyvim_picker = "telescope"

vim.opt.relativenumber = true
vim.opt.spell = true
vim.opt.spelllang = { "en", "pt" }
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.switchbuf = "useopen"
vim.opt.diffopt:append("followwrap")
