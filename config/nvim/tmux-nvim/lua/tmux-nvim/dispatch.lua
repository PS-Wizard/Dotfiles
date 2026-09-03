local M = {}

function M.send(target, text, opts)
  opts = opts or {}
  if not target or target == "" then return false, "no tmux target" end
  if vim.env.TMUX == nil or vim.env.TMUX == "" then
    return false, "not inside tmux"
  end
  -- write to temp file then load-buffer + paste
  local tmp = vim.fn.tempname()
  local lines = vim.split(text, "\n", { plain = true })
  -- vim.fn.writefile needs list, handle empty
  local ok = pcall(vim.fn.writefile, lines, tmp)
  if not ok then return false, "failed to write temp file" end

  local r1 = vim.system({ "tmux", "load-buffer", tmp }, { text = true }):wait()
  os.remove(tmp)
  if r1.code ~= 0 then
    return false, "tmux load-buffer failed: " .. (r1.stderr ~= "" and r1.stderr or ("exit " .. r1.code))
  end
  -- -p wraps the paste in bracketed-paste escapes so multi-line text arrives
  -- as one paste. Without it each newline is delivered as a separate Enter and
  -- agent TUIs submit line by line.
  local r2 = vim.system({ "tmux", "paste-buffer", "-d", "-p", "-t", target }, { text = true }):wait()
  if r2.code ~= 0 then
    return false, "tmux paste-buffer failed: " .. (r2.stderr ~= "" and r2.stderr or ("exit " .. r2.code))
  end
  if opts.submit then
    local r3 = vim.system({ "tmux", "send-keys", "-t", target, "Enter" }, { text = true }):wait()
    if r3.code ~= 0 then
      return false, "tmux send-keys Enter failed: " .. (r3.stderr ~= "" and r3.stderr or ("exit " .. r3.code))
    end
  end
  return true
end

return M
