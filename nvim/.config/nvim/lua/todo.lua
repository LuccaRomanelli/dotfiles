local M = {}

local todo_path = "/home/lcc/obisidian/todo.md"

--- Adiciona uma tarefa ao arquivo todo.md
--- @param text string Texto da tarefa
function M.add_task(text)
  if not text or text == "" then
    vim.notify("Texto da tarefa não pode ser vazio", vim.log.levels.WARN)
    return
  end

  local file_exists = vim.fn.filereadable(todo_path) == 1
  local lines = {}

  if file_exists then
    lines = vim.fn.readfile(todo_path)
  else
    -- Cria diretório se não existir
    local dir = vim.fn.fnamemodify(todo_path, ":h")
    vim.fn.mkdir(dir, "p")
    lines = { "# Todo", "" }
  end

  table.insert(lines, "- [ ] " .. text)
  vim.fn.writefile(lines, todo_path)
  vim.notify("Tarefa adicionada: " .. text, vim.log.levels.INFO)
end

--- Abre o arquivo todo.md no Neovim
function M.open_todo()
  -- Cria arquivo com header se não existir
  if vim.fn.filereadable(todo_path) ~= 1 then
    local dir = vim.fn.fnamemodify(todo_path, ":h")
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile({ "# Todo", "" }, todo_path)
  end

  vim.cmd("edit " .. todo_path)
end

-- Comandos Neovim
vim.api.nvim_create_user_command("Todo", function()
  M.open_todo()
end, { desc = "Abre o arquivo todo.md" })

vim.api.nvim_create_user_command("TodoAdd", function(opts)
  M.add_task(opts.args)
end, { nargs = "+", desc = "Adiciona tarefa ao todo.md" })

return M
