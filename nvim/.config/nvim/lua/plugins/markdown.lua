return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
      -- Render in normal mode, show raw in insert/visual
      render_modes = { "n", "c" },
      anti_conceal = {
        enabled = true,
      },
      heading = {
        enabled = true,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      code = {
        enabled = true,
        style = "full",
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
    },
  },
}
