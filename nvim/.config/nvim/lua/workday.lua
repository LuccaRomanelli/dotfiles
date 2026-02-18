local M = {}

local WORKDAY_DIR = "/home/lcc/obisidian/1_projects/workday"
local TEMPLATE_PATH = "/home/lcc/obisidian/Templates/workday.md"

--- Returns today's date as YYYY-MM-DD
--- @return string
local function today()
  return os.date("%Y-%m-%d")
end

--- Returns the path for today's workday note
--- @return string
local function get_path()
  return WORKDAY_DIR .. "/" .. today() .. ".md"
end

--- Reads the Obsidian template and replaces Templater date placeholders
--- @return string[]
local function get_template()
  local lines = vim.fn.readfile(TEMPLATE_PATH)
  for i, line in ipairs(lines) do
    lines[i] = line:gsub("<%%.- tp%.date%.now%(.-%).-%%>", today())
  end
  return lines
end

--- Creates the workday file from template if it doesn't exist
--- @param path string
local function ensure_file(path)
  if vim.fn.filereadable(path) == 1 then
    return
  end
  local dir = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(dir, "p")
  vim.fn.writefile(get_template(), path)
end

--- Opens today's workday note in nvim
function M.open_workday()
  local path = get_path()
  ensure_file(path)
  vim.cmd("edit " .. path)
end

--- Adds an item to the Inbox section of today's workday note
--- @param text string
function M.add_to_inbox(text)
  if not text or text == "" then
    vim.notify("Inbox item cannot be empty", vim.log.levels.WARN)
    return
  end

  local path = get_path()
  ensure_file(path)

  local lines = vim.fn.readfile(path)
  local inbox_idx = nil
  local insert_idx = nil

  -- Find the ## Inbox heading
  for i, line in ipairs(lines) do
    if line:match("^## Inbox") then
      inbox_idx = i
    elseif inbox_idx and not insert_idx and line:match("^## ") then
      -- Found the next heading after Inbox
      insert_idx = i
    end
  end

  if not inbox_idx then
    vim.notify("Could not find ## Inbox section", vim.log.levels.ERROR)
    return
  end

  local new_line = "- " .. text

  if insert_idx then
    -- Insert before the next heading
    table.insert(lines, insert_idx, new_line)
  else
    -- Append at end of file
    table.insert(lines, new_line)
  end

  vim.fn.writefile(lines, path)
  vim.notify("Added to inbox: " .. text, vim.log.levels.INFO)
end

-- Neovim commands
vim.api.nvim_create_user_command("Workday", function()
  M.open_workday()
end, { desc = "Open today's workday note" })

vim.api.nvim_create_user_command("WorkdayAdd", function(opts)
  M.add_to_inbox(opts.args)
end, { nargs = "+", desc = "Add item to workday inbox" })

return M
