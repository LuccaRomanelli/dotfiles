local M = {}

local paths = {
  personal = "/home/lcc/obisidian/todo.md",
  work = "/home/lcc/obisidian/todo-work.md",
  vanta = "/home/lcc/obisidian/todo-vanta.md",
}

--- Retorna o path baseado no tipo
--- @param todo_type string|nil Tipo do todo (personal, work, vanta)
--- @return string
local function get_path(todo_type)
  local t = todo_type or "personal"
  return paths[t] or paths.personal
end

--- Adiciona uma tarefa ao arquivo todo.md
--- @param text string Texto da tarefa
--- @param todo_type string|nil Tipo do todo (personal, work, vanta)
function M.add_task(text, todo_type)
  if not text or text == "" then
    vim.notify("Texto da tarefa não pode ser vazio", vim.log.levels.WARN)
    return
  end

  local todo_path = get_path(todo_type)
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
--- @param todo_type string|nil Tipo do todo (personal, work, vanta)
function M.open_todo(todo_type)
  local todo_path = get_path(todo_type)

  -- Cria arquivo com header se não existir
  if vim.fn.filereadable(todo_path) ~= 1 then
    local dir = vim.fn.fnamemodify(todo_path, ":h")
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile({ "# Todo", "" }, todo_path)
  end

  vim.cmd("edit " .. todo_path)
end

-- Comandos Neovim
vim.api.nvim_create_user_command("Todo", function(opts)
  M.open_todo(opts.args ~= "" and opts.args or nil)
end, { nargs = "?", desc = "Abre o arquivo todo.md" })

vim.api.nvim_create_user_command("TodoAdd", function(opts)
  M.add_task(opts.args)
end, { nargs = "+", desc = "Adiciona tarefa ao todo.md" })

return M
