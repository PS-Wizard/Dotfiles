local M = {}
local comments = require("tmux-nvim.comments")
local prompt = require("tmux-nvim.prompt")
local tmux = require("tmux-nvim.tmux")
local dispatch = require("tmux-nvim.dispatch")
local ui = require("tmux-nvim.ui")

M.config = { prefix = "<leader>a", keymaps = true, clear_after_send = false }

local function map(mode, lhs, rhs, desc)
  if vim.fn.maparg(vim.api.nvim_replace_termcodes(lhs, true, true, true), mode) ~= "" then
    vim.notify("tmux-nvim: not overriding existing map " .. lhs, vim.log.levels.WARN)
    return
  end
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

function M.setup(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})
  if M.config.keymaps then
    local p = M.config.prefix
    map("x", p .. "c", function() M.comment_selection() end, "tmux-nvim: comment selection")
    map("n", p .. "c", function() M.comment_line() end, "tmux-nvim: comment line")
    map("n", "<leader>l", function() M.list_comments() end, "tmux-nvim: list comments")
    map("n", "<leader>S", function() M.send_all({ submit = true }) end, "tmux-nvim: send comments (submit)")
    map("n", "<leader>c", function() M.copy_all() end, "tmux-nvim: copy comments to clipboard")
    map("n", "<leader>s", function() M.send_all({ submit = false }) end, "tmux-nvim: send comments (no submit)")
    map("n", "<leader>d", function() M.delete_all() end, "tmux-nvim: delete all comments")
  end
end

local function add_comment(start_line, end_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  local title = string.format(" Tmux Comment: %s:%d ", vim.fn.fnamemodify(file, ":t") ~= "" and vim.fn.fnamemodify(file, ":t") or "[No Name]", start_line)
  if end_line ~= start_line then
    title = string.format(" Tmux Comment: %s:%d-%d ", vim.fn.fnamemodify(file, ":t"), start_line, end_line)
  end
  ui.input_comment(function(text)
    local id = comments.add(bufnr, start_line, end_line, text)
    ui.decorate(id)
  end, { title = title })
end

function M.comment_selection()
  vim.cmd([[execute "normal! \<esc>"]])
  local s, e = ui.visual_range()
  add_comment(s, e)
end

function M.comment_line()
  local l = vim.api.nvim_win_get_cursor(0)[1]
  add_comment(l, l)
end

function M.edit_comment(c, on_done)
  ui.input_comment(function(t)
    if t and t ~= "" and t ~= c.text then
      ui.undecorate(c.id)
      comments.edit(c.id, t)
      ui.decorate(c.id)
    end
    if on_done then on_done() end
  end, { title = " Edit Comment ", default = c.text })
end

function M.delete_comment(c)
  ui.undecorate(c.id)
  comments.delete(c.id)
end

function M.list_comments()
  ui.comment_list({
    edit = function(c, refresh) M.edit_comment(c, refresh) end,
    delete = function(c) M.delete_comment(c) end,
  })
end

function M._git_context(cwd)
  local ok, r = pcall(function()
    return vim.system({ "git", "rev-parse", "--show-toplevel", "--abbrev-ref", "HEAD" }, { text = true, cwd = cwd }):wait()
  end)
  if not ok or r.code ~= 0 then return nil end
  local root, branch = r.stdout:match("([^\n]*)\n([^\n]*)")
  if not root then return nil end
  return string.format("repo: %s, branch: %s", vim.fn.fnamemodify(vim.trim(root), ":t"), vim.trim(branch))
end

function M.copy_all()
  local list = comments.list()
  if #list == 0 then
    vim.notify("tmux-nvim: no comments to copy", vim.log.levels.INFO)
    return
  end
  local items = {}
  for _, c in ipairs(list) do
    table.insert(items, { comment = c, snippet = comments.snippet(c.id) })
  end
  local first_file = list[1].file
  local cwd = first_file ~= "" and vim.fn.fnamemodify(first_file, ":h") or nil
  local text = prompt.format(items, { header_context = M._git_context(cwd) })
  vim.fn.setreg("+", text)
  vim.notify(string.format("tmux-nvim: copied %d comment(s) to clipboard", #list))
end

function M.send_all(opts)
  local list = comments.list()
  if #list == 0 then
    vim.notify("tmux-nvim: no comments to send", vim.log.levels.INFO)
    return
  end
  if not tmux.is_inside() then
    vim.notify("tmux-nvim: not inside tmux (no $TMUX)", vim.log.levels.ERROR)
    return
  end
  local items = {}
  for _, c in ipairs(list) do
    table.insert(items, { comment = c, snippet = comments.snippet(c.id) })
  end
  local first_file = list[1].file
  local cwd = first_file ~= "" and vim.fn.fnamemodify(first_file, ":h") or nil
  local text = prompt.format(items, { header_context = M._git_context(cwd) })

  local panes, err = tmux.list_panes()
  if not panes then
    vim.notify("tmux-nvim: " .. err, vim.log.levels.ERROR)
    return
  end

  local function deliver(pane)
    local ok, derr = dispatch.send(pane.pane_id, text, opts)
    if not ok then
      vim.notify("tmux-nvim: " .. derr, vim.log.levels.ERROR)
      return
    end
    if M.config.clear_after_send then
      for _, c in ipairs(list) do M.delete_comment(c) end
    end
    vim.notify(string.format("tmux-nvim: sent %d comment(s) to %s", #list, tmux.display(pane)))
  end

  local pane = tmux.resolve(panes)
  if pane then
    deliver(pane)
  else
    tmux.pick(panes, deliver)
  end
end

function M.delete_all()
  local list = comments.list()
  if #list == 0 then
    vim.notify("tmux-nvim: no comments to delete", vim.log.levels.INFO)
    return
  end
  for _, c in ipairs(list) do
    ui.undecorate(c.id)
    comments.delete(c.id)
  end
  vim.notify(string.format("tmux-nvim: deleted %d comment(s)", #list))
end

function M.statusline()
  local n = #comments.list()
  return n == 0 and "" or ("● " .. n)
end

return M
