local M = {}

function M.send(target, text, opts)
  opts = opts or {}
  if not target or target == "" then return false, "no tmux target" end
  if not vim.env.TMUX or vim.env.TMUX == "" then return false, "not inside tmux" end
  if vim.fn.executable("tmux-send") ~= 1 then return false, "tmux-send not found in PATH" end

  local cmd = { "tmux-send", "send", "--pane", target }
  if opts.submit then
    table.insert(cmd, "--submit")
  else
    table.insert(cmd, "--no-submit")
  end

  local result = vim.system(cmd, { stdin = text or "", text = true }):wait()
  if result.code ~= 0 then
    local err = vim.trim(result.stderr or "")
    if err == "" then err = "tmux-send failed: exit " .. result.code end
    return false, err
  end

  return true
end

return M
