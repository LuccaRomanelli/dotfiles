return {
  "LuccaRomanelli/git-review.nvim",
  dependencies = { "tpope/vim-fugitive" },
  config = function()
    require("git-review").setup()
  end,
}
