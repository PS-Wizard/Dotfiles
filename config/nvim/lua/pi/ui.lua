local M = {}

-- Fallback list only; real per-model levels come from the bridge metadata.
local thinking_levels = { "off", "minimal", "low", "medium", "high", "xhigh", "max" }
-- Canonical ordering used to clamp a level to a model's supported set.
local EXT = { "off", "minimal", "low", "medium", "high", "xhigh", "max" }

-- The single live draft. Hiding keeps its buffers alive so nothing typed is lost.
M.state = nil

function M.capture_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    if start_pos[2] == 0 and end_pos[2] == 0 then
        return nil
    end

    local ok, lines = pcall(vim.fn.getregion, start_pos, end_pos, { type = vim.fn.visualmode() })
    if not ok or not lines or #lines == 0 then
        return nil
    end

    local text = table.concat(lines, "\n")
    if text == "" then
        return nil
    end

    return {
        text = text,
        file = vim.fn.expand("%:."),
        absolute_file = vim.fn.expand("%:p"),
        start_line = start_pos[2],
        finish_line = end_pos[2],
        filetype = vim.bo.filetype,
    }
end

local function index_of(list, value)
    for i, v in ipairs(list) do
        if v == value then
            return i
        end
    end
    return nil
end

local function cycle(items, current)
    if #items == 0 then
        return current
    end

    local index = index_of(items, current) or 1
    return items[(index % #items) + 1]
end

-- Which effort levels the given model actually supports, as reported by the
-- bridge (falls back gracefully if the metadata predates that field).
local function levels_for(session, model)
    local per = session.model_thinking_levels
    if per and model and type(per[model]) == "table" and #per[model] > 0 then
        return per[model]
    end
    if type(session.thinking_levels) == "table" and #session.thinking_levels > 0 then
        return session.thinking_levels
    end
    return thinking_levels
end

-- Snap a level to the nearest one a model supports (walk up the effort ladder,
-- then down), mirroring pi's own clampThinkingLevel.
local function clamp_level(levels, level)
    if index_of(levels, level) then
        return level
    end

    local ri = index_of(EXT, level)
    if not ri then
        return levels[1] or "off"
    end

    for i = ri, #EXT do
        if index_of(levels, EXT[i]) then
            return EXT[i]
        end
    end
    for i = ri - 1, 1, -1 do
        if index_of(levels, EXT[i]) then
            return EXT[i]
        end
    end
    return levels[1] or "off"
end

local function scope_label(st)
    if st.selection then
        return string.format("selection %d-%d", st.selection.start_line, st.selection.finish_line)
    end
    if st.send_buffer then
        return "buffer"
    end
    return "file"
end

local function update_header(st)
    if not st.header_buf or not vim.api.nvim_buf_is_valid(st.header_buf) then
        return
    end

    local lines = {
        "Session: " .. (st.session.cwd or "?"),
        "File: " .. (st.relative_file ~= "" and st.relative_file or "(no file)"),
        "Scope: " .. scope_label(st),
        "Model: " .. (st.selected_model ~= "" and st.selected_model or "(current)"),
        "Effort: " .. st.selected_thinking,
        "Keys: :w send • q hide • :q close • <Tab> buffer • <C-p> model • <C-t> effort",
    }

    vim.bo[st.header_buf].modifiable = true
    vim.api.nvim_buf_set_lines(st.header_buf, 0, -1, false, lines)
    vim.bo[st.header_buf].modifiable = false
end

local function build_message(st, prompt_text)
    local selection = st.selection
    if selection then
        local target = selection.absolute_file ~= "" and selection.absolute_file or selection.file
        local header = string.format("%s lines %d-%d", target, selection.start_line, selection.finish_line)
        if prompt_text == "" then
            return string.format("Look at this code from %s:\n\n```%s\n%s\n```", header, selection.filetype, selection.text)
        end
        return string.format("%s\n\nFrom %s:\n```%s\n%s\n```", prompt_text, header, selection.filetype, selection.text)
    end

    if st.send_buffer and st.absolute_file ~= "" then
        local content = table.concat(st.buffer_lines, "\n")
        if prompt_text == "" then
            return string.format("Look at this file %s:\n\n```%s\n%s\n```", st.absolute_file, st.filetype, content)
        end
        return string.format("%s\n\nFile: %s\n```%s\n%s\n```", prompt_text, st.absolute_file, st.filetype, content)
    end

    if st.absolute_file ~= "" then
        if prompt_text == "" then
            return string.format("Look at this file: %s", st.absolute_file)
        end
        return string.format("File: %s\n\n%s", st.absolute_file, prompt_text)
    end

    return prompt_text
end

-- Close the floating windows but keep the buffers (and their text) alive.
function M.hide()
    local st = M.state
    if not st or not st.visible then
        return
    end

    st.suppress_winclosed = true
    pcall(vim.api.nvim_win_close, st.prompt_win, true)
    pcall(vim.api.nvim_win_close, st.header_win, true)
    st.suppress_winclosed = false
    st.prompt_win = nil
    st.header_win = nil
    st.visible = false
end

-- Fully tear down the draft, discarding everything.
function M.close()
    local st = M.state
    if not st then
        return
    end

    M.state = nil
    st.suppress_winclosed = true
    pcall(vim.api.nvim_win_close, st.prompt_win, true)
    pcall(vim.api.nvim_win_close, st.header_win, true)
    pcall(vim.api.nvim_buf_delete, st.prompt_buf, { force = true })
    pcall(vim.api.nvim_buf_delete, st.header_buf, { force = true })
    if st.augroup then
        pcall(vim.api.nvim_del_augroup_by_id, st.augroup)
    end
end

local function send(st)
    local prompt_text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(st.prompt_buf, 0, -1, false), "\n"))
    local message = build_message(st, prompt_text)
    if message == "" then
        vim.notify("Nothing to send", vim.log.levels.WARN)
        return
    end

    local pi = require("pi")
    local request_id = tostring(vim.uv.hrtime())
    pi.enqueue({
        id = request_id,
        prompt = message,
        model = st.selected_model,
        thinking = st.selected_thinking,
        buf = st.source_buf,
        line = st.source_line,
        col = st.source_col,
    }, function(err, response)
        if err then
            vim.notify("Pi send failed: " .. err, vim.log.levels.ERROR)
            return
        end

        local position = response and response.position or 1
        if position > 1 then
            vim.notify(string.format("Queued for pi (#%d)", position - 1), vim.log.levels.INFO)
        else
            vim.notify("Sent to pi", vim.log.levels.INFO)
        end
        M.close()
    end)
end

-- (Re)create the floating windows for the current draft buffers.
local function show(st)
    if st.visible then
        vim.api.nvim_set_current_win(st.prompt_win)
        return
    end

    local header_height = 6
    local width = math.max(80, math.floor(vim.o.columns * 0.75))
    local height = math.max(12, math.floor(vim.o.lines * 0.45))
    width = math.min(width, vim.o.columns - 6)
    height = math.min(height, vim.o.lines - 10)
    local row = math.floor((vim.o.lines - (header_height + height + 2)) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    st.header_win = vim.api.nvim_open_win(st.header_buf, false, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = header_height,
        style = "minimal",
        border = "rounded",
        title = " pi ",
        title_pos = "center",
        focusable = false,
    })

    st.prompt_win = vim.api.nvim_open_win(st.prompt_buf, true, {
        relative = "editor",
        row = row + header_height + 1,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " prompt ",
        title_pos = "center",
    })

    st.visible = true
    update_header(st)

    local last = vim.api.nvim_buf_line_count(st.prompt_buf)
    local last_line = vim.api.nvim_buf_get_lines(st.prompt_buf, last - 1, last, false)[1] or ""
    pcall(vim.api.nvim_win_set_cursor, st.prompt_win, { last, #last_line })
    vim.cmd("startinsert")
end

local function create(opts)
    local pi = require("pi")
    local session = pi.get_session()
    if not session then
        vim.notify("No pi session connected", vim.log.levels.WARN)
        return nil
    end

    local selection = opts.selection
    local source_cursor = vim.api.nvim_win_get_cursor(0)
    local models = vim.deepcopy(session.enabled_models or {})
    if #models == 0 and session.current_model then
        models = { session.current_model }
    end
    local selected_model = session.current_model or models[1] or ""

    local header_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[header_buf].bufhidden = "hide"

    local prompt_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[prompt_buf].buftype = "acwrite"
    vim.bo[prompt_buf].bufhidden = "hide"
    vim.bo[prompt_buf].swapfile = false
    vim.bo[prompt_buf].modifiable = true
    vim.bo[prompt_buf].filetype = "markdown"
    vim.api.nvim_buf_set_name(prompt_buf, "pi://prompt/" .. tostring(vim.uv.hrtime()))
    vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { "" })

    local st = {
        session = session,
        selection = selection,
        source_buf = vim.api.nvim_get_current_buf(),
        source_line = selection and (selection.start_line - 1) or (source_cursor[1] - 1),
        source_col = 0,
        relative_file = vim.fn.expand("%:."),
        absolute_file = vim.fn.expand("%:p"),
        filetype = vim.bo.filetype,
        buffer_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false),
        send_buffer = false,
        models = models,
        selected_model = selected_model,
        selected_thinking = clamp_level(levels_for(session, selected_model), session.current_thinking or "high"),
        header_buf = header_buf,
        prompt_buf = prompt_buf,
        visible = false,
        suppress_winclosed = false,
    }
    M.state = st

    local keymap_opts = { buffer = prompt_buf, noremap = true, silent = true }

    vim.keymap.set({ "n", "i" }, "<C-p>", function()
        st.selected_model = cycle(st.models, st.selected_model)
        st.selected_thinking = clamp_level(levels_for(st.session, st.selected_model), st.selected_thinking)
        update_header(st)
    end, keymap_opts)

    vim.keymap.set({ "n", "i" }, "<C-t>", function()
        st.selected_thinking = cycle(levels_for(st.session, st.selected_model), st.selected_thinking)
        update_header(st)
    end, keymap_opts)

    vim.keymap.set({ "n", "i" }, "<Tab>", function()
        if st.selection then
            return
        end
        st.send_buffer = not st.send_buffer
        update_header(st)
    end, keymap_opts)

    vim.keymap.set("n", "q", M.hide, keymap_opts)

    st.augroup = vim.api.nvim_create_augroup("PiPrompt", { clear = true })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        group = st.augroup,
        buffer = prompt_buf,
        callback = function()
            send(st)
        end,
    })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = st.augroup,
        buffer = prompt_buf,
        callback = function()
            vim.bo[prompt_buf].modified = false
        end,
    })

    -- A window close we did not initiate (e.g. the user typed :q) discards the draft.
    vim.api.nvim_create_autocmd("WinClosed", {
        group = st.augroup,
        callback = function(args)
            if not M.state or not M.state.visible or M.state.suppress_winclosed then
                return
            end
            if tonumber(args.match) == M.state.prompt_win then
                M.close()
            end
        end,
    })

    return st
end

function M.is_active()
    return M.state ~= nil
end

function M.toggle_visibility()
    local st = M.state
    if not st then
        return false
    end
    if st.visible then
        M.hide()
    else
        show(st)
    end
    return true
end

function M.open(opts)
    opts = opts or {}

    -- An existing draft is always reopened as-is so nothing typed is ever lost.
    if M.state then
        show(M.state)
        return
    end

    local st = create(opts)
    if st then
        show(st)
    end
end

return M
