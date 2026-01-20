return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      get_selection_window = function()
        local current_win = vim.api.nvim_get_current_win()
        local current_buf = vim.api.nvim_win_get_buf(current_win)
        if vim.bo[current_buf].buftype == "" then
          return current_win
        end
        local wins = vim.api.nvim_list_wins()
        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == "" then
            return win
          end
        end
        return 0
      end,
    },
    pickers = {
      lsp_definitions = { reuse_win = true, jump_type = "never" },
      lsp_type_definitions = { reuse_win = true, jump_type = "never" },
      lsp_implementations = { reuse_win = true, jump_type = "never" },
      lsp_references = { reuse_win = true, jump_type = "never" },
      lsp_document_symbols = { reuse_win = true },
      lsp_workspace_symbols = { reuse_win = true },
      lsp_dynamic_workspace_symbols = { reuse_win = true },
      lsp_incoming_calls = { reuse_win = true, jump_type = "never" },
      lsp_outgoing_calls = { reuse_win = true, jump_type = "never" },
    },
  },
}
