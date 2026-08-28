local M = {}

local config = {}
local state = {
  board_tab = nil,
  previous_tab = nil,
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
  if vim.fn.filereadable(config.todo_file) == 0 then
    vim.fn.writefile({}, config.todo_file)
  end
end

local function valid_board_name(name)
  return name ~= "" and name ~= "." and name ~= ".." and not name:find("[/\\]") and not name:find("%c")
end

local function select_board(name, persist)
  config.board = name
  config.path = vim.fs.joinpath(config.root, name)
  config.todo_file = vim.fs.joinpath(config.path, "TODO.md")
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
local close_board

local function quit_board()
  if state.closing then return end
  vim.schedule(function() close_board() end)
end

do_save = function()
  if not config.path then return end
  local old_n = #state.buffers
  local old_vs = state.view_start
  local combined = {}
  for _, line in ipairs(state.prelude) do table.insert(combined, line) end
  for _, buf in ipairs(state.buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        table.insert(combined, line)
      end
    end
  end

  local new_prelude, parsed_sections = parse_lines(combined)
  local new_sections, completed, done = {}, {}, nil
  for _, section in ipairs(parsed_sections) do
    if (section[1] or ""):lower():match("^#%s+done%s*$") then
      if not done then
        done = section
        table.insert(new_sections, done)
      else
        for i = 2, #section do table.insert(done, section[i]) end
      end
    else
      local filtered = { section[1] }
      for i = 2, #section do
        if is_completed(section[i]) then
          table.insert(completed, section[i])
        else
          table.insert(filtered, section[i])
        end
      end
      table.insert(new_sections, filtered)
    end
  end
  if #completed > 0 then
    if not done then
      done = { "# Done", "" }
      table.insert(new_sections, done)
    end
    for _, line in ipairs(completed) do table.insert(done, line) end
  end

  local output = {}
  for _, line in ipairs(new_prelude) do table.insert(output, line) end
  for _, section in ipairs(new_sections) do
    if #output > 0 and output[#output] ~= "" and (section[1] or ""):lower():match("^#%s+done%s*$") then
      table.insert(output, "")
    end
    for _, line in ipairs(section) do table.insert(output, line) end
  end
  vim.fn.writefile(output, config.todo_file)
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
        vim.api.nvim_create_autocmd("QuitPre", {
          group = state.augroup,
          buffer = b,
          callback = quit_board,
        })
        vim.keymap.set("n", "<C-h>", function() M._nav_h(b) end, { buffer = b, silent = true })
        vim.keymap.set("n", "<C-l>", function() M._nav_l(b) end, { buffer = b, silent = true })
        vim.keymap.set("n", "<leader>an", function() M._create_note(b) end, { buffer = b, silent = true, desc = "Add task note" })
        vim.keymap.set("n", "gf", function() M._follow_link(b) end, { buffer = b, silent = true, desc = "Follow task link" })
        vim.keymap.set("n", "<leader>rn", function() M._rename_link(b) end, { buffer = b, silent = true, desc = "Rename task note" })
        vim.keymap.set("n", "<leader>ff", M._find_files, { buffer = b, silent = true, desc = "Find board files" })
        vim.keymap.set("n", "<leader>fg", M._live_grep, { buffer = b, silent = true, desc = "Grep board files" })
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

local function has_pinned_note()
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then return false end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(state.board_tab)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.b[buf].todo_return_buf then return true end
    end
  end
  return false
end

local function nav_h(cur_buf)
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then return end
  local idx = find_idx_by_buf(cur_buf)
  if not idx then idx = find_idx_by_buf(vim.api.nvim_get_current_buf()) end
  if not idx then
    vim.cmd("wincmd h")
    return
  end
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
    vim.cmd("wincmd h")
  elseif idx == vs and vs > 1 then
    if has_pinned_note() then
      vim.cmd("wincmd h")
      return
    end
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
    vim.cmd("wincmd h")
  else
    vim.cmd("wincmd h")
  end
end

local function nav_l(cur_buf)
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then return end
  local idx = find_idx_by_buf(cur_buf)
  if not idx then idx = find_idx_by_buf(vim.api.nvim_get_current_buf()) end
  if not idx then
    vim.cmd("wincmd l")
    return
  end
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
    vim.cmd("wincmd l")
  elseif idx == ve and ve < #state.buffers then
    if has_pinned_note() then
      vim.cmd("wincmd l")
      return
    end
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
    vim.cmd("wincmd l")
  else
    vim.cmd("wincmd l")
  end
end

local function open_in_place(path, cur_buf)
  if vim.api.nvim_buf_is_valid(cur_buf) and vim.bo[cur_buf].modified then do_save() end
  local return_idx = find_idx_by_buf(cur_buf)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local file_buf = vim.api.nvim_get_current_buf()
  vim.b[file_buf].todo_board_path = config.path
  vim.b[file_buf].todo_return_buf = cur_buf
  vim.b[file_buf].todo_return_idx = return_idx
  vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<CR>", { buffer = file_buf, silent = true })
  vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<CR>", { buffer = file_buf, silent = true })
  vim.keymap.set("n", "<leader>ff", function() M._find_files() end, { buffer = file_buf, silent = true, desc = "Find board files" })
  vim.keymap.set("n", "<leader>fg", function() M._live_grep() end, { buffer = file_buf, silent = true, desc = "Grep board files" })
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

local function link_at_cursor(cur_buf)
  local cur = vim.api.nvim_win_get_cursor(0)
  local lnum, col = cur[1], cur[2]
  local line = vim.api.nvim_buf_get_lines(cur_buf, lnum - 1, lnum, false)[1] or ""
  local dest, pos = nil, 1
  while true do
    local s, e, value = line:find("%]%((.-)%)", pos)
    if not s then break end
    if col + 1 >= s and col + 1 <= e then
      dest = value
      break
    end
    if dest == nil then dest = value end
    pos = e + 1
  end
  if dest == nil or dest == "" then dest = vim.fn.expand("<cfile>") end
  return dest, line, lnum
end

local function resolve_link(dest)
  if dest == nil or dest == "" or dest:match("://") then return nil end
  local path = dest
  if path:match("^/") or path:match("^%a:") or path:match("^~") then
    path = vim.fs.normalize((path:gsub("^~", vim.fn.expand("~"))))
  else
    path = vim.fs.joinpath(config.path, path)
  end
  return path
end

local function follow_link(cur_buf)
  local dest = link_at_cursor(cur_buf)
  local path = resolve_link(dest)
  if not path or vim.fn.filereadable(path) == 0 then
    vim.notify("todo: cannot find file: " .. (dest or ""), vim.log.levels.WARN)
    return
  end
  open_in_place(path, cur_buf)
end

local function rename_link(cur_buf)
  local dest, line, lnum = link_at_cursor(cur_buf)
  local path = resolve_link(dest)
  if not path or vim.fn.filereadable(path) == 0 then
    vim.notify("todo: cannot find file: " .. (dest or ""), vim.log.levels.WARN)
    return
  end
  local root = vim.fs.normalize(config.path)
  if path ~= root and path:sub(1, #root + 1) ~= root .. "/" then
    vim.notify("todo: refusing to rename a file outside this board", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "New note name: ", default = vim.fs.basename(path) }, function(name)
    if name == nil then return end
    name = vim.trim(name)
    if name == "" or name == "." or name == ".." or name:find("[/\\]") then
      vim.notify("todo: invalid note name", vim.log.levels.WARN)
      return
    end
    if not name:lower():match("%.md$") then name = name .. ".md" end
    local target = vim.fs.joinpath(vim.fs.dirname(path), name)
    if target == path then return end
    if vim.uv.fs_stat(target) or vim.fn.bufnr(target) >= 0 then
      vim.notify("todo: file already exists: " .. target, vim.log.levels.WARN)
      return
    end
    local current = vim.api.nvim_buf_get_lines(cur_buf, lnum - 1, lnum, false)[1] or ""
    if not current:find("](" .. dest .. ")", 1, true) then
      vim.notify("todo: task link changed while renaming", vim.log.levels.WARN)
      return
    end
    local loaded = vim.fn.bufnr(path)
    if loaded >= 0 and vim.api.nvim_buf_is_valid(loaded) and vim.bo[loaded].modified then
      vim.notify("todo: save the note before renaming", vim.log.levels.WARN)
      return
    end
    local ok = vim.uv.fs_rename(path, target)
    if not ok then ok = os.rename(path, target) end
    if not ok then
      vim.notify("todo: failed to rename " .. path, vim.log.levels.ERROR)
      return
    end
    if loaded >= 0 and vim.api.nvim_buf_is_valid(loaded) then
      local renamed = pcall(vim.api.nvim_buf_set_name, loaded, target)
      if not renamed then
        vim.uv.fs_rename(target, path)
        vim.notify("todo: failed to rename loaded note buffer", vim.log.levels.ERROR)
        return
      end
    end
    local updated = current:gsub("%]%((" .. vim.pesc(dest) .. ")%)", function() return "](" .. target .. ")" end, 1)
    vim.api.nvim_buf_set_lines(cur_buf, lnum - 1, lnum, false, { updated })
    do_save()
  end)
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
      open_in_place(full, cur_buf)
    end
    if vim.uv.fs_stat(full) or vim.fn.filereadable(full) == 1 then
      local link = "[" .. label .. "](" .. full .. ")"
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
    local link = "[" .. label .. "](" .. full .. ")"
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

local function return_to_board(return_buf)
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then return end
  vim.api.nvim_set_current_tabpage(state.board_tab)
  render_view()
  for _, win in ipairs(state.wins) do
    if vim.api.nvim_win_get_buf(win) == return_buf then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

local function open_board_result(selected, opts, return_buf)
  if not selected[1] then return end
  local entry = require("fzf-lua.path").entry_to_file(selected[1], opts, opts._uri)
  local path = entry.bufname or entry.path
  if not path then return end
  local board_path = opts.cwd or config.path
  if not path:match("^/") and not path:match("^%a:") then
    path = vim.fs.joinpath(board_path, path)
  end
  do_save()
  local target_tab = state.previous_tab
  if not target_tab or not vim.api.nvim_tabpage_is_valid(target_tab) or target_tab == state.board_tab then
    vim.cmd("tabnew")
    target_tab = vim.api.nvim_get_current_tabpage()
    state.previous_tab = target_tab
  else
    vim.api.nvim_set_current_tabpage(target_tab)
  end
  local ok = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(path))
  if not ok then
    return_to_board(return_buf)
    vim.notify("todo: could not open " .. path, vim.log.levels.WARN)
    return
  end
  local file_buf = vim.api.nvim_get_current_buf()
  vim.b[file_buf].todo_board_path = board_path
  vim.b[file_buf].todo_return_buf = return_buf
  vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<CR>", { buffer = file_buf, silent = true })
  vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<CR>", { buffer = file_buf, silent = true })
  vim.keymap.set("n", "<leader>ff", function() M._find_files() end, { buffer = file_buf, silent = true, desc = "Find board files" })
  vim.keymap.set("n", "<leader>fg", function() M._live_grep() end, { buffer = file_buf, silent = true, desc = "Grep board files" })
  if entry.line and entry.line > 0 then
    pcall(vim.api.nvim_win_set_cursor, 0, { entry.line, math.max(0, (entry.col or 1) - 1) })
  end
  local file_win = vim.api.nvim_get_current_win()
  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.augroup,
    pattern = tostring(file_win),
    once = true,
    callback = function()
      vim.schedule(function() return_to_board(return_buf) end)
    end,
  })
end

local function board_picker_action(return_buf)
  return function(selected, opts) open_board_result(selected, opts, return_buf) end
end

local function picker_context()
  local current = vim.api.nvim_get_current_buf()
  return vim.b[current].todo_board_path or config.path, vim.b[current].todo_return_buf or current
end

local function find_board_files()
  local cwd, return_buf = picker_context()
  require("fzf-lua").files({
    cwd = cwd,
    actions = { ["default"] = board_picker_action(return_buf) },
  })
end

local function grep_board_files()
  local cwd, return_buf = picker_context()
  require("fzf-lua").live_grep({
    cwd = cwd,
    actions = { ["default"] = board_picker_action(return_buf) },
  })
end

M._nav_h = nav_h
M._nav_l = nav_l
M._create_note = create_note
M._follow_link = follow_link
M._rename_link = rename_link
M._find_files = find_board_files
M._live_grep = grep_board_files

close_board = function()
  if not state.board_tab or not vim.api.nvim_tabpage_is_valid(state.board_tab) then
    if has_modified() then
      vim.notify("todo: board has unsaved changes", vim.log.levels.WARN)
      return false
    end
    for _, buf in ipairs(state.buffers) do
      if vim.api.nvim_buf_is_valid(buf) then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
    end
    state.buffers = {}
    state.wins = {}
    state.board_tab = nil
    state.view_start = 1
    state.prelude = {}
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
    sections = { { "# Backlog", "" } }
    local output = {}
    for _, line in ipairs(prelude) do table.insert(output, line) end
    for _, section in ipairs(sections) do
      for _, line in ipairs(section) do table.insert(output, line) end
    end
    vim.fn.writefile(output, config.todo_file)
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
    vim.api.nvim_create_autocmd("QuitPre", {
      group = state.augroup,
      buffer = b,
      callback = quit_board,
    })
    vim.keymap.set("n", "<C-h>", function() nav_h(b) end, { buffer = b, silent = true })
    vim.keymap.set("n", "<C-l>", function() nav_l(b) end, { buffer = b, silent = true })
    vim.keymap.set("n", "<leader>an", function() create_note(b) end, { buffer = b, silent = true, desc = "Add task note" })
    vim.keymap.set("n", "gf", function() follow_link(b) end, { buffer = b, silent = true, desc = "Follow task link" })
    vim.keymap.set("n", "<leader>rn", function() rename_link(b) end, { buffer = b, silent = true, desc = "Rename task note" })
    vim.keymap.set("n", "<leader>ff", find_board_files, { buffer = b, silent = true, desc = "Find board files" })
    vim.keymap.set("n", "<leader>fg", grep_board_files, { buffer = b, silent = true, desc = "Grep board files" })
  end

  state.previous_tab = vim.api.nvim_get_current_tabpage()
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
    vim.fn.mkdir(path, "p")
    vim.fn.writefile({ "", "# Backlog", "- Example 1", "" }, vim.fs.joinpath(path, "TODO.md"))
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
