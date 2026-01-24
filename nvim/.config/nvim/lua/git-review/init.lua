local M = {}

M.state = {
  files = {},
  branch = "origin/main",
  current = 0,
  root = "",
}

--- Start a git diff review session against a branch
--- @param branch string|nil Branch to diff against (default: "origin/main")
function M.start(branch)
  M.state.branch = branch or "origin/main"
  M.state.root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
  M.state.files = vim.fn.systemlist("git diff --name-only " .. M.state.branch)

  if #M.state.files == 0 then
    vim.notify("No changes found against " .. M.state.branch, vim.log.levels.INFO)
    return
  end

  M.state.current = 1
  vim.cmd("edit " .. M.state.root .. "/" .. M.state.files[1])
  vim.cmd("Gvdiffsplit " .. M.state.branch)
end

--- Navigate to next changed file in review
function M.next()
  if #M.state.files == 0 then
    vim.notify("No review active", vim.log.levels.WARN)
    return
  end

  M.state.current = M.state.current + 1

  if M.state.current > #M.state.files then
    local choice = vim.fn.confirm("Review finished!", "&Quit\n&Back", 1)
    if choice == 1 then
      vim.cmd("qa")
    else
      M.state.current = #M.state.files
    end
    return
  end

  vim.cmd("silent! tabonly | only")
  vim.cmd("edit " .. M.state.root .. "/" .. M.state.files[M.state.current])
  vim.cmd("Gvdiffsplit " .. M.state.branch)
end

--- Navigate to previous changed file in review
function M.prev()
  if #M.state.files == 0 then
    vim.notify("No review active", vim.log.levels.WARN)
    return
  end

  if M.state.current <= 1 then
    vim.notify("Already at first file", vim.log.levels.INFO)
    return
  end

  M.state.current = M.state.current - 1
  vim.cmd("silent! tabonly | only")
  vim.cmd("edit " .. M.state.root .. "/" .. M.state.files[M.state.current])
  vim.cmd("Gvdiffsplit " .. M.state.branch)
end

function M.setup()
  vim.api.nvim_create_user_command("GitReview", function(opts)
    M.start(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    complete = function()
      return { "origin/main", "main", "master", "HEAD~1" }
    end,
    desc = "Start git diff review against a branch",
  })

  vim.keymap.set("n", "]g", M.next, { desc = "Next file in git review" })
  vim.keymap.set("n", "[g", M.prev, { desc = "Previous file in git review" })
end

return M
