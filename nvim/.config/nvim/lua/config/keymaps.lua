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

-- Telescope no diretório atual (do arquivo aberto)
vim.keymap.set("n", "<leader>fF", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Find files (current dir)" })

vim.keymap.set("n", "<leader>fG", function()
  require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Grep (current dir)" })

-- LSP navigation stack (populated by plugins/lsp-navigation.lua)
_G._nav_stack = {}

vim.keymap.set("n", "gb", function()
  local stack = _G._nav_stack
  if not stack or #stack == 0 then
    vim.notify("No previous positions", vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local items = {}
  for i = #stack, 1, -1 do
    local e = stack[i]
    table.insert(items, {
      display = vim.fn.fnamemodify(e.filename, ":~:.") .. ":" .. e.lnum,
      filename = e.filename,
      lnum = e.lnum,
      col = e.col,
      bufnr = e.bufnr,
      idx = i,
    })
  end

  pickers.new({}, {
    prompt_title = "Go Back",
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        return {
          value = item,
          display = item.display,
          ordinal = item.display,
          filename = item.filename,
          lnum = item.lnum,
          col = item.col + 1,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local sel = action_state.get_selected_entry()
        if sel then
          local v = sel.value
          -- Remove selected and all newer entries
          for j = #stack, v.idx, -1 do
            table.remove(stack, j)
          end
          if vim.api.nvim_buf_is_valid(v.bufnr) then
            vim.api.nvim_set_current_buf(v.bufnr)
          else
            vim.cmd("edit " .. vim.fn.fnameescape(v.filename))
          end
          vim.api.nvim_win_set_cursor(0, { v.lnum, v.col })
        end
      end)
      return true
    end,
  }):find()
end, { desc = "Go back (navigation picker)" })

-- LSP: go to implementation with gi (overrides default gi = insert at last insert position)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })

-- Copy file path relative to project root
vim.keymap.set("n", "yp", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy file path (project relative)" })

-- Redo with U
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

-- Auto save after paste
vim.keymap.set("n", "p", function()
  vim.cmd("normal! p")
  vim.cmd("silent! update")
end, { desc = "Paste and save" })
vim.keymap.set("n", "P", function()
  vim.cmd("normal! P")
  vim.cmd("silent! update")
end, { desc = "Paste before and save" })
