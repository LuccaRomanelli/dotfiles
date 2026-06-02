local omarchy_theme = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")

if vim.fn.filereadable(omarchy_theme) == 1 then
  local ok, theme = pcall(dofile, omarchy_theme)
  if ok and type(theme) == "table" then
    return theme
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
