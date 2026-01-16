-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- LSP keymaps with telescope reuse_win
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, vim.tbl_extend("force", opts, { desc = "Goto Definition" }))
    vim.keymap.set("n", "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, vim.tbl_extend("force", opts, { desc = "Goto Implementation" }))
    vim.keymap.set("n", "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, vim.tbl_extend("force", opts, { desc = "Goto Type Definition" }))
    vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references({ reuse_win = true }) end, vim.tbl_extend("force", opts, { desc = "References" }))
  end,
})

-- Spell check functions
local function spell_suggest(auto_continue)
  local word = vim.fn.spellbadword()[1]
  if word == "" then
    vim.notify("No more spelling errors!", vim.log.levels.INFO)
    return
  end

  local suggestions = vim.fn.spellsuggest(word, 10)
  if #suggestions == 0 then
    vim.notify("No suggestions for: " .. word, vim.log.levels.WARN)
    if auto_continue then
      vim.cmd("normal! ]s")
      vim.schedule(function() spell_suggest(true) end)
    end
    return
  end

  table.insert(suggestions, "I - Ignore")
  table.insert(suggestions, "A - Add to dictionary")

  vim.ui.select(suggestions, { prompt = "Correct '" .. word .. "':" }, function(choice)
    if not choice then
      if auto_continue then
        vim.notify("Spell check cancelled", vim.log.levels.INFO)
      end
      return
    end

    if choice == "I - Ignore" then
      -- skip, do nothing
    elseif choice == "A - Add to dictionary" then
      vim.cmd("normal! zg")
    else
      -- Replace word with selection
      vim.cmd("normal! ciw" .. choice)
      vim.cmd("stopinsert")
    end

    if auto_continue then
      vim.cmd("normal! ]s")
      vim.schedule(function() spell_suggest(true) end)
    end
  end)
end

vim.keymap.set("n", "<leader>sf", function()
  vim.cmd("normal! gg")
  vim.cmd("normal! ]s")
  spell_suggest(true)
end, { desc = "Spell fix from start (auto-continue)" })

vim.keymap.set("n", "<leader>sn", function()
  vim.cmd("normal! ]s")
  spell_suggest(false)
end, { desc = "Spell next error" })

vim.keymap.set("n", "<leader>sp", function()
  vim.cmd("normal! [s")
  spell_suggest(false)
end, { desc = "Spell previous error" })

-- Zet note creation command
vim.api.nvim_create_user_command("Zet", function(opts)
  local zet = require("zet")
  local filepath = zet.create_note(opts.args)
  if filepath then
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  end
end, { nargs = "+", desc = "Create a new zet note" })

-- Auto save after paste
vim.keymap.set("n", "p", "p:silent! update<CR>", { desc = "Paste and save" })
vim.keymap.set("n", "P", "P:silent! update<CR>", { desc = "Paste before and save" })
