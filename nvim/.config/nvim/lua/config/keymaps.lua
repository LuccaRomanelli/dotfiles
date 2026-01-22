-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

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

-- Telescope no diretório atual (do arquivo aberto)
vim.keymap.set("n", "<leader>fF", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Find files (current dir)" })

vim.keymap.set("n", "<leader>fG", function()
  require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Grep (current dir)" })

-- Auto save after paste
vim.keymap.set("n", "p", "p:silent! update<CR>", { desc = "Paste and save" })
vim.keymap.set("n", "P", "P:silent! update<CR>", { desc = "Paste before and save" })

-- Git diff review workflow
vim.keymap.set("n", "<leader>gR", function()
  local branch = vim.fn.input("Diff against branch: ", "main")
  if branch == "" then return end
  local files = vim.fn.systemlist("git diff --name-only " .. branch)
  if #files == 0 then
    vim.notify("No changes found", vim.log.levels.INFO)
    return
  end
  vim.fn.setqflist({}, " ", { title = "Git diff " .. branch, lines = files })
  vim.cmd("cfirst")
  vim.cmd("Gvdiffsplit " .. branch)
end, { desc = "Git review diff against branch" })

vim.keymap.set("n", "<leader>gn", function()
  vim.cmd("only")
  local ok = pcall(vim.cmd, "cnext")
  if ok then
    local branch = vim.fn.getqflist({ title = 1 }).title:match("Git diff (.+)")
    vim.cmd("Gvdiffsplit " .. (branch or "main"))
  else
    vim.notify("Review complete", vim.log.levels.INFO)
  end
end, { desc = "Git next diff file" })
