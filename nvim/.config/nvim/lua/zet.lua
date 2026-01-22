local M = {}

local ZET_DIR = "/home/lcc/obisidian/00_zet"

-- Get the next unique ID for today (format: YYYYMMDDNNN)
local function get_next_id()
  local today = os.date("%Y%m%d")
  local max_num = 0

  -- Scan all files in zet directory for IDs
  local handle = io.popen('grep -rh "^ID: " "' .. ZET_DIR .. '" 2>/dev/null')
  if handle then
    for line in handle:lines() do
      local id = line:match("^ID: (%d+)")
      if id and id:sub(1, 8) == today then
        local num = tonumber(id:sub(9))
        if num and num > max_num then
          max_num = num
        end
      end
    end
    handle:close()
  end

  return today .. string.format("%03d", max_num + 1)
end

-- Create a new zet note with the given title
function M.create_note(title)
  if not title or title == "" then
    vim.notify("Zet: Title is required", vim.log.levels.ERROR)
    return nil
  end

  -- Convert spaces to underscores for title and filename
  local normalized_title = title:gsub(" ", "_")
  local filename = normalized_title .. ".md"
  local filepath = ZET_DIR .. "/" .. filename

  -- Check if file already exists - just open it
  local f = io.open(filepath, "r")
  if f then
    f:close()
    vim.notify("Zet: Opening existing note: " .. filename)
    return filepath
  end

  -- Generate unique ID
  local id = get_next_id()

  -- Create file content
  local content = "# " .. normalized_title .. "\n\n\n---\nID: " .. id .. "\n"

  -- Write the file
  f = io.open(filepath, "w")
  if not f then
    vim.notify("Zet: Failed to create file: " .. filepath, vim.log.levels.ERROR)
    return nil
  end
  f:write(content)
  f:close()

  vim.notify("Zet: Created " .. filename .. " (ID: " .. id .. ")")
  return filepath
end

return M
