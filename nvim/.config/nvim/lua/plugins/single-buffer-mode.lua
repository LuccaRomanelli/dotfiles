return {
  {
    "LazyVim/LazyVim",
    init = function()
      local prev_buf = nil
      local ignore_filetypes = {
        "neo-tree", "Trouble", "trouble", "qf", "help",
        "terminal", "toggleterm", "lazy", "mason", "notify",
        "snacks_dashboard", "snacks_notif", "snacks_terminal",
      }

      local group = vim.api.nvim_create_augroup("SingleBufferMode", { clear = true })

      vim.api.nvim_create_autocmd("BufLeave", {
        group = group,
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local ft = vim.bo[buf].filetype
          local bt = vim.bo[buf].buftype

          if bt == "" and not vim.tbl_contains(ignore_filetypes, ft) then
            prev_buf = buf
          end
        end,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function()
          vim.defer_fn(function()
            if prev_buf and prev_buf ~= vim.api.nvim_get_current_buf() and vim.api.nvim_buf_is_valid(prev_buf) then
              local ok_to_delete = not vim.bo[prev_buf].modified
                and vim.bo[prev_buf].buftype == ""
                and vim.bo[prev_buf].buflisted

              if ok_to_delete then
                local wins = vim.fn.win_findbuf(prev_buf)
                if #wins == 0 then
                  pcall(vim.api.nvim_buf_delete, prev_buf, { force = false })
                end
              end
              prev_buf = nil
            end
          end, 10)
        end,
      })
    end,
  },
}
