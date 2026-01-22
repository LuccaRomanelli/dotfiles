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
_G.git_review = _G.git_review or { files = {}, branch = "main", current = 0, root = "" }

vim.keymap.set("n", "<leader>gR", function()
  local branch = vim.fn.input("Diff against branch: ", "main")
  if branch == "" then return end
  local root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
  local files = vim.fn.systemlist("git diff --name-only " .. branch)
  if #files == 0 then
    vim.notify("No changes found", vim.log.levels.INFO)
    return
  end
  _G.git_review = { files = files, branch = branch, current = 1, root = root }
  vim.cmd("edit " .. root .. "/" .. files[1])
  vim.cmd("Gvdiffsplit " .. branch)
end, { desc = "Git review diff against branch" })

vim.keymap.set("n", "]g", function()
  local review = _G.git_review
  if #review.files == 0 then
    vim.notify("No review active", vim.log.levels.WARN)
    return
  end
  review.current = review.current + 1
  if review.current > #review.files then
    local choice = vim.fn.confirm("Review finished!", "&Quit\n&Back", 1)
    if choice == 1 then
      vim.cmd("qa")
    else
      review.current = #review.files
    end
    return
  end
  vim.cmd("silent! tabonly | only")
  vim.cmd("edit " .. review.root .. "/" .. review.files[review.current])
  vim.cmd("Gvdiffsplit " .. review.branch)
end, { desc = "Git next diff file" })

vim.keymap.set("n", "[g", function()
  local review = _G.git_review
  if #review.files == 0 then
    vim.notify("No review active", vim.log.levels.WARN)
    return
  end
  if review.current <= 1 then
    vim.notify("Already at first file", vim.log.levels.INFO)
    return
  end
  review.current = review.current - 1
  vim.cmd("silent! tabonly | only")
  vim.cmd("edit " .. review.root .. "/" .. review.files[review.current])
  vim.cmd("Gvdiffsplit " .. review.branch)
end, { desc = "Git prev diff file" })
