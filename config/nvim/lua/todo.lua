local M = {}

local config = {}
local state = {
  board_tab = nil,
  buffers = {},
  prelude = {},
  view_start = 1,
  wins = {},
  augroup = nil,
  showtabline = nil,
  closing = false,
}

local function is_completed(line)
  return line:match("^%s*%- %[[xX]%]") ~= nil
end

local function is_task_line(line)
  return line:match("^%s*%- ") ~= nil
end

local function has_modified()
  for _, buf in ipairs(state.buffers) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
      return true
    end
  end
  return false
end

local function find_idx_by_buf(buf)
  for i, b in ipairs(state.buffers) do
    if b == buf then return i end
  end
  return nil
end

local function parse_lines(lines)
  local prelude = {}
  local sections = {}
  local cur = nil
  for _, line in ipairs(lines) do
    if line:match("^#%s+") then
      cur = { line }
      table.insert(sections, cur)
    else
      if cur then
        table.insert(cur, line)
      else
        table.insert(prelude, line)
      end
    end
  end
  return prelude, sections
end

local function read_todo_lines()
  if vim.fn.filereadable(config.todo_file) == 1 then
    return vim.fn.readfile(config.todo_file)
  end
  return {}
end

local function ensure_files()
  if not config.path or config.path == "" then return end
  vim.fn.mkdir(config.path, "p")
  vim.fn.mkdir(config.done_dir, "p")
  if vim.fn.filereadable(config.todo_file) == 0 then
    vim.fn.writefile({}, config.todo_file)
  end
  if vim.fn.filereadable(config.done_file) == 0 then
    vim.fn.writefile({ "# Done", "" }, config.done_file)
  end
end

local function valid_board_name(name)
  return name ~= "" and name ~= "." and name ~= ".." and not name:find("[/\\]") and not name:find("%c")
end

local function select_board(name, persist)
  config.board = name
  config.path = vim.fs.joinpath(config.root, name)
  config.todo_file = vim.fs.joinpath(config.path, "TODO.md")
  config.done_dir = vim.fs.joinpath(config.path, "done")
  config.done_file = vim.fs.joinpath(config.done_dir, "done.md")
  if persist then vim.fn.writefile({ name }, config.current_file) end
end

local function board_names()
  local names = {}
  for name, kind in vim.fs.dir(config.root) do
    if kind == "directory" and vim.fn.filereadable(vim.fs.joinpath(config.root, name, "TODO.md")) == 1 then
      table.insert(names, name)
    end
  end
  table.sort(names)
  return names
end

local render_view
local do_save

do_save = function()
  if not config.path then return end
  local old_n = #state.buffers
  local old_vs = state.view_start
  local combined = {}
  for _, l in ipairs(state.prelude) do table.insert(combined, l) end
  for _, buf in ipairs(state.buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      local bl = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      for _, line in ipairs(bl) do table.insert(combined, line) end
    end
  end

  local remaining = {}
  local archived = {}

  for _, line in ipairs(combined) do
    if is_completed(line) then
      local arc_line = line:gsub("%[(.-)%]%((.-)%)", function(label, dest)
        if dest:match("://") then
          return "[" .. label .. "](" .. dest .. ")"
        end
        if dest:match("^#") then
          return "[" .. label .. "](" .. dest .. ")"
        end
        if dest:match("^/") or dest:match("^\\") or dest:match("^%a:") or dest:match("^~") then
          return "[" .. label .. "](" .. dest .. ")"
        end
        if dest:find("%.%.", 1, true) then
          return "[" .. label .. "](" .. dest .. ")"
        end
        local is_simple_md = not dest:find("[/\\]") and dest:lower():match("%.md$") ~= nil
        if not is_simple_md then
          return "[" .. label .. "](" .. "../" .. dest .. ")"
        end
        local src = vim.fs.joinpath(config.path, dest)
        local st = vim.uv.fs_stat(src)
        if not st then
          return "[" .. label .. "](" .. "../" .. dest .. ")"
        end
        local tgt = vim.fs.joinpath(config.done_dir, dest)
        vim.fn.mkdir(config.done_dir, "p")
        local tst = vim.uv.fs_stat(tgt)
        if tst then
          vim.notify("todo: collision, leaving " .. src .. " and linking ../" .. dest, vim.log.levels.WARN)
          return "[" .. label .. "](" .. "../" .. dest .. ")"
        end
        local ok = vim.uv.fs_rename(src, tgt)
        if not ok then ok = os.rename(src, tgt) end
        if ok or vim.uv.fs_stat(tgt) then
          return "[" .. label .. "](" .. dest .. ")"
        else
          vim.notify("todo: failed to move " .. src, vim.log.levels.WARN)
          return "[" .. label .. "](" .. "../" .. dest .. ")"
        end
      end)
      table.insert(archived, arc_line)
    else
      table.insert(remaining, line)
    end
  end

  vim.fn.writefile(remaining, config.todo_file)

  if #archived > 0 then
    vim.fn.mkdir(config.done_dir, "p")
    local done_lines = {}
    if vim.fn.filereadable(config.done_file) == 1 then
      done_lines = vim.fn.readfile(config.done_file)
    end
    if #done_lines == 0 or not done_lines[1]:match("^#%s*Done") then
      table.insert(done_lines, 1, "# Done")
      table.insert(done_lines, 2, "")
    end
    for _, l in ipairs(archived) do table.insert(done_lines, l) end
    vim.fn.writefile(done_lines, config.done_file)
  end

  local new_prelude, new_sections = parse_lines(remaining)
  state.prelude = new_prelude

  if #new_sections ~= #state.buffers then
    if #new_sections > #state.buffers then
      for i = #state.buffers + 1, #new_sections do
        local sec = new_sections[i]
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "acwrite"
        vim.bo[buf].bufhidden = "hide"
        vim.bo[buf].swapfile = false
        vim.api.nvim_buf_set_name(buf, string.format("todo://%s/%d/%d/%s", config.board, buf, i, (sec[1] or ""):gsub("[^%w]", "_")))
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, sec)
        vim.bo[buf].filetype = "markdown"
        vim.bo[buf].modified = false
        table.insert(state.buffers, buf)
        local b = buf
        vim.api.nvim_create_autocmd("BufWriteCmd", {
          group = state.augroup,
          buffer = b,
          callback = function() do_save() end,
        })
        vim.keymap.set("n", "<C-h>", function() M._nav_h(b) end, { buffer = b, silent = true })
        vim.keymap.set("n", "<C-l>", function() M._nav_l(b) end, { buffer = b, silent = true })
        vim.keymap.set("n", "<leader>an", function() M._create_note(b) end, { buffer = b, silent = true, desc = "Add task note" })
      end
    else
      for i = #state.buffers, #new_sections + 1, -1 do
        local b = state.buffers[i]
        if vim.api.nvim_buf_is_valid(b) then vim.api.nvim_buf_delete(b, { force = true }) end
        table.remove(state.buffers, i)
      end
      if state.view_start > #state.buffers then
        state.view_start = math.max(1, #state.buffers - 2)
      end
    end
  end

  for i, buf in ipairs(state.buffers) do
    if new_sections[i] then
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_sections[i])
        vim.bo[buf].modified = false
      end
    end
  end

  local need_rerender = (old_n ~= #state.buffers) or (old_vs ~= state.view_start)
  if need_rerender and state.board_tab and vim.api.nvim_tabpage_is_valid(state.board_tab) then
    vim.schedule(function()
      if state.board_tab and vim.api.nvim_tabpage_is_valid(state.board_tab) then
        local ok, err = pcall(render_view)
        if not ok then
          vim.notify("todo: render failed: " .. tostring(err), vim.log.levels.WARN)
        end
      end
    end)
  end
end

local function board_wins()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(state.board_tab)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      table.insert(wins, win)
    end
  end
  return wins
end

render_view = function()
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then return end
  local N = #state.buffers
  if N == 0 then return end
  local visible = math.min(3, N)
  vim.api.nvim_set_current_tabpage(state.board_tab)
  local wins = board_wins()
  while #wins > visible do
    vim.api.nvim_win_close(wins[#wins], true)
    wins = board_wins()
  end
  while #wins < visible do
    vim.cmd("rightbelow vsplit")
    wins = board_wins()
  end
  table.sort(wins, function(a, b)
    local pa = vim.api.nvim_win_get_position(a)
    local pb = vim.api.nvim_win_get_position(b)
    if pa[2] == pb[2] then return pa[1] < pb[1] end
    return pa[2] < pb[2]
  end)
  for i, win in ipairs(wins) do
    local sec_idx = state.view_start + i - 1
    if sec_idx <= N then
      vim.api.nvim_win_set_buf(win, state.buffers[sec_idx])
      vim.wo[win].number = false
      vim.wo[win].relativenumber = false
      vim.wo[win].signcolumn = "no"
      vim.wo[win].fillchars = "vert:│"
      vim.wo[win].winhighlight = "WinSeparator:WinSeparator"
    end
  end
  vim.cmd("wincmd =")
  state.wins = wins
end

local function nav_h(cur_buf)
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then return end
  local idx = find_idx_by_buf(cur_buf)
  if not idx then idx = find_idx_by_buf(vim.api.nvim_get_current_buf()) end
  if not idx then return end
  local visible = math.min(3, #state.buffers)
  local vs = state.view_start
  if idx > vs then
    local target = idx - 1
    local tgt = state.buffers[target]
    for _, w in ipairs(state.wins or {}) do
      if vim.api.nvim_win_get_buf(w) == tgt then
        vim.api.nvim_set_current_win(w)
        return
      end
    end
  elseif idx == vs and vs > 1 then
    state.view_start = vs - 1
    render_view()
    local target = idx - 1
    local tgt = state.buffers[target]
    for _, w in ipairs(state.wins or {}) do
      if vim.api.nvim_win_get_buf(w) == tgt then
        vim.api.nvim_set_current_win(w)
        return
      end
    end
  end
end

local function nav_l(cur_buf)
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then return end
  local idx = find_idx_by_buf(cur_buf)
  if not idx then idx = find_idx_by_buf(vim.api.nvim_get_current_buf()) end
  if not idx then return end
  local visible = math.min(3, #state.buffers)
  local vs = state.view_start
  local ve = vs + visible - 1
  if idx < ve and idx < #state.buffers then
    local target = idx + 1
    local tgt = state.buffers[target]
    for _, w in ipairs(state.wins or {}) do
      if vim.api.nvim_win_get_buf(w) == tgt then
        vim.api.nvim_set_current_win(w)
        return
      end
    end
  elseif idx == ve and ve < #state.buffers then
    state.view_start = vs + 1
    render_view()
    local target = idx + 1
    local tgt = state.buffers[target]
    for _, w in ipairs(state.wins or {}) do
      if vim.api.nvim_win_get_buf(w) == tgt then
        vim.api.nvim_set_current_win(w)
        return
      end
    end
  end
end

local function create_note(cur_buf)
  local win = vim.api.nvim_get_current_win()
  local cur = vim.api.nvim_win_get_cursor(win)
  local lnum = cur[1]
  local lines = vim.api.nvim_buf_get_lines(cur_buf, lnum - 1, lnum, false)
  local line = lines[1] or ""
  if not is_task_line(line) then
    vim.notify("todo: add note only works on a task line", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Note name: " }, function(input)
    if input == nil then return end
    input = vim.trim(input)
    if input == "" then
      vim.notify("todo: empty name", vim.log.levels.WARN)
      return
    end
    if input:find("[/\\]") or input == "." or input == ".." then
      vim.notify("todo: invalid name", vim.log.levels.WARN)
      return
    end
    if not input:lower():match("%.md$") then input = input .. ".md" end
    if input:find("[/\\]") then
      vim.notify("todo: invalid name", vim.log.levels.WARN)
      return
    end
    local dest = input
    local label = dest:gsub("%.[mM][dD]$", "")
    local full = vim.fs.joinpath(config.path, dest)
    local function open_note()
      if vim.api.nvim_buf_is_valid(cur_buf) and vim.bo[cur_buf].modified then do_save() end
      local archived = vim.fs.joinpath(config.done_dir, dest)
      local path = not vim.uv.fs_stat(full) and vim.uv.fs_stat(archived) and archived or full
      local return_idx = find_idx_by_buf(cur_buf)
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      local note_win = vim.api.nvim_get_current_win()
      vim.api.nvim_create_autocmd("WinClosed", {
        group = state.augroup,
        pattern = tostring(note_win),
        once = true,
        callback = function()
          if state.closing then return end
          vim.schedule(function()
            if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then
              vim.o.showtabline = 0
              vim.cmd("tabnew")
              state.board_tab = vim.api.nvim_get_current_tabpage()
            end
            render_view()
            local target = state.buffers[return_idx]
            for _, board_win in ipairs(state.wins) do
              if vim.api.nvim_win_get_buf(board_win) == target then
                vim.api.nvim_set_current_win(board_win)
                return
              end
            end
          end)
        end,
      })
    end
    if vim.uv.fs_stat(full) or vim.fn.filereadable(full) == 1 then
      local link = "[" .. label .. "](" .. dest .. ")"
      local cur_lines = vim.api.nvim_buf_get_lines(cur_buf, lnum - 1, lnum, false)
      local cur_line = cur_lines[1] or line
      if not cur_line:find(link, 1, true) then
        local new_line = cur_line .. " " .. link
        vim.api.nvim_buf_set_lines(cur_buf, lnum - 1, lnum, false, { new_line })
        do_save()
      end
      vim.notify("todo: file exists: " .. dest, vim.log.levels.WARN)
      open_note()
      return
    end
    vim.fn.mkdir(config.path, "p")
    vim.fn.writefile({}, full)
    local link = "[" .. label .. "](" .. dest .. ")"
    local cur_lines = vim.api.nvim_buf_get_lines(cur_buf, lnum - 1, lnum, false)
    local cur_line = cur_lines[1] or line
    if not cur_line:find(link, 1, true) then
      local new_line = cur_line .. " " .. link
      vim.api.nvim_buf_set_lines(cur_buf, lnum - 1, lnum, false, { new_line })
      do_save()
    end
    open_note()
  end)
end

M._nav_h = nav_h
M._nav_l = nav_l
M._create_note = create_note

local function close_board()
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then
    state.board_tab = nil
    if state.showtabline ~= nil then
      vim.o.showtabline = state.showtabline
      state.showtabline = nil
    end
    return true
  end
  if has_modified() then
    vim.notify("todo: board has unsaved changes", vim.log.levels.WARN)
    return false
  end
  state.closing = true
  local ok = pcall(function()
    vim.api.nvim_set_current_tabpage(state.board_tab)
    vim.cmd("tabclose")
  end)
  state.closing = false
  if not ok then return false end
  if state.showtabline ~= nil then
    vim.o.showtabline = state.showtabline
    state.showtabline = nil
  end
  for _, buf in ipairs(state.buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
  state.buffers = {}
  state.wins = {}
  state.board_tab = nil
  state.view_start = 1
  state.prelude = {}
  return true
end

local function open_board()
  if not config.path then return end
  ensure_files()
  local raw_lines = read_todo_lines()
  local prelude, sections = parse_lines(raw_lines)
  if #sections == 0 then
    sections = { { "# Backlog", "" }, { "# In Progress", "" }, { "# In Review", "" } }
    local out = {}
    for _, l in ipairs(prelude) do table.insert(out, l) end
    for _, sec in ipairs(sections) do for _, l in ipairs(sec) do table.insert(out, l) end end
    vim.fn.writefile(out, config.todo_file)
  end
  state.prelude = prelude
  state.buffers = {}
  state.view_start = 1

  if not state.augroup then
    state.augroup = vim.api.nvim_create_augroup("TodoKanban", { clear = true })
  end

  for i, sec in ipairs(sections) do
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "acwrite"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    local nm = (sec[1] or ""):gsub("[^%w]", "_")
    vim.api.nvim_buf_set_name(buf, string.format("todo://%s/%d/%d/%s", config.board, buf, i, nm))
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, sec)
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].modified = false
    table.insert(state.buffers, buf)
    local b = buf
    vim.api.nvim_create_autocmd("BufWriteCmd", {
      group = state.augroup,
      buffer = b,
      callback = function() do_save() end,
    })
    vim.keymap.set("n", "<C-h>", function() nav_h(b) end, { buffer = b, silent = true })
    vim.keymap.set("n", "<C-l>", function() nav_l(b) end, { buffer = b, silent = true })
    vim.keymap.set("n", "<leader>an", function() create_note(b) end, { buffer = b, silent = true, desc = "Add task note" })
  end

  state.showtabline = vim.o.showtabline
  vim.o.showtabline = 0
  vim.cmd("tabnew")
  state.board_tab = vim.api.nvim_get_current_tabpage()
  render_view()
  if state.wins and #state.wins > 0 then
    vim.api.nvim_set_current_win(state.wins[1])
  end
end

function M.setup(opts)
  opts = opts or {}
  local raw = opts.path or "~/Projects/gnosis/tasks/"
  config.root = vim.fn.expand(raw):gsub("/+$", "")
  if config.root == "" then config.root = vim.fn.expand("~/Projects/gnosis/tasks") end
  config.current_file = vim.fs.joinpath(config.root, ".current")
  config.board = nil
  config.path = nil
  config.todo_file = nil
  config.done_dir = nil
  config.done_file = nil
  vim.fn.mkdir(config.root, "p")

  if vim.fn.filereadable(config.current_file) == 1 then
    local name = vim.trim(vim.fn.readfile(config.current_file)[1] or "")
    if valid_board_name(name) and vim.fn.filereadable(vim.fs.joinpath(config.root, name, "TODO.md")) == 1 then
      select_board(name, false)
    end
  end

  if not state.augroup then
    state.augroup = vim.api.nvim_create_augroup("TodoKanban", { clear = true })
  elseif not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then
    vim.api.nvim_clear_autocmds({ group = state.augroup })
  end
end

function M.switch(name)
  name = vim.trim(name or "")
  if not valid_board_name(name) or vim.fn.filereadable(vim.fs.joinpath(config.root, name, "TODO.md")) == 0 then
    vim.notify("todo: board does not exist: " .. name, vim.log.levels.WARN)
    return
  end
  if state.board_tab and vim.api.nvim_tabpage_is_valid(state.board_tab) then
    if config.board == name then
      vim.api.nvim_set_current_tabpage(state.board_tab)
      return
    end
    if not close_board() then
      vim.notify("todo: save the current board before switching", vim.log.levels.WARN)
      return
    end
  end
  select_board(name, true)
  open_board()
end

function M.create()
  vim.ui.input({ prompt = "Board name: " }, function(name)
    if name == nil then return end
    name = vim.trim(name)
    if not valid_board_name(name) then
      vim.notify("todo: invalid board name", vim.log.levels.WARN)
      return
    end
    local path = vim.fs.joinpath(config.root, name)
    if vim.uv.fs_stat(path) then
      if vim.fn.filereadable(vim.fs.joinpath(path, "TODO.md")) == 1 then
        vim.notify("todo: board already exists: " .. name, vim.log.levels.WARN)
        M.switch(name)
      else
        vim.notify("todo: path already exists: " .. path, vim.log.levels.ERROR)
      end
      return
    end
    vim.fn.mkdir(vim.fs.joinpath(path, "done"), "p")
    vim.fn.writefile({ "", "# Backlog", "- Example 1", "" }, vim.fs.joinpath(path, "TODO.md"))
    vim.fn.writefile({ "# Done", "" }, vim.fs.joinpath(path, "done", "done.md"))
    M.switch(name)
  end)
end

function M.pick()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    vim.notify("todo: fzf-lua is unavailable", vim.log.levels.ERROR)
    return
  end
  local header = "<ctrl-n> create board"
  if config.board then header = "Current: " .. config.board .. "  |  " .. header end
  fzf.fzf_exec(board_names(), {
    prompt = "Boards> ",
    header = header,
    previewer = false,
    fzf_opts = { ["--no-multi"] = true },
    actions = {
      ["default"] = function(selected)
        if selected[1] then vim.schedule(function() M.switch(selected[1]) end) end
      end,
      ["ctrl-n"] = function() vim.schedule(M.create) end,
    },
  })
end

function M.toggle()
  if state.board_tab and vim.api.nvim_tabpage_is_valid(state.board_tab) then
    close_board()
    return
  end
  if not config.path then
    M.pick()
    return
  end
  open_board()
end

function M.edit()
  if state.board_tab and vim.api.nvim_tabpage_is_valid(state.board_tab) then
    if has_modified() then
      vim.notify("todo: board has unsaved changes, save first", vim.log.levels.WARN)
      return
    end
    close_board()
  end
  if not config.path then
    M.pick()
    return
  end
  vim.cmd("edit " .. vim.fn.fnameescape(config.todo_file))
end

M._parse = parse_lines
M._is_completed = is_completed
M._config = config
M._state = state

return M
