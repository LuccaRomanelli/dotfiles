return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          {
            "gd",
            function()
              local pos = vim.api.nvim_win_get_cursor(0)
              table.insert(_G._nav_stack, {
                bufnr = vim.api.nvim_get_current_buf(),
                filename = vim.api.nvim_buf_get_name(0),
                lnum = pos[1],
                col = pos[2],
              })
              Snacks.picker.lsp_definitions()
            end,
            desc = "Goto Definition",
            has = "definition",
          },
        },
      },
    },
  },
}
