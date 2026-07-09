local M = {}

local thinking_levels = { "off", "minimal", "low", "medium", "high", "xhigh" }

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

local function cycle(items, current)
    if #items == 0 then
        return current
    end

    local index = 1
    for i, item in ipairs(items) do
        if item == current then
            index = i
            break
        end
    end

    return items[(index % #items) + 1]
end

function M.open(opts)
    opts = opts or {}

    local pi = require("pi")
    local session = pi.get_session()
    if not session then
        vim.notify("No pi session connected", vim.log.levels.WARN)
        return
    end

    local selection = opts.selection
    local source_buf = vim.api.nvim_get_current_buf()
    local source_cursor = vim.api.nvim_win_get_cursor(0)
    local source_line = selection and (selection.start_line - 1) or (source_cursor[1] - 1)
    local source_col = 0
    local relative_file = vim.fn.expand("%:.")
    local absolute_file = vim.fn.expand("%:p")
    local filetype = vim.bo.filetype
    local buffer_lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
    local send_buffer = false
    local models = vim.deepcopy(session.enabled_models or {})
    if #models == 0 and session.current_model then
        models = { session.current_model }
    end
    local selected_model = session.current_model or models[1] or ""
    local selected_thinking = session.current_thinking or "high"

    local header_height = 6
    local width = math.max(80, math.floor(vim.o.columns * 0.75))
    local height = math.max(12, math.floor(vim.o.lines * 0.45))
    width = math.min(width, vim.o.columns - 6)
    height = math.min(height, vim.o.lines - 10)
    local row = math.floor((vim.o.lines - (header_height + height + 2)) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local header_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[header_buf].bufhidden = "wipe"

    local prompt_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[prompt_buf].buftype = "acwrite"
    vim.bo[prompt_buf].bufhidden = "wipe"
    vim.bo[prompt_buf].swapfile = false
    vim.bo[prompt_buf].modifiable = true
    vim.bo[prompt_buf].filetype = "markdown"
    vim.api.nvim_buf_set_name(prompt_buf, "pi://prompt/" .. tostring(vim.uv.hrtime()))
    vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { "" })

    local header_win = vim.api.nvim_open_win(header_buf, false, {
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

    local prompt_win = vim.api.nvim_open_win(prompt_buf, true, {
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

    local closed = false

    local function scope_label()
        if selection then
            return string.format("selection %d-%d", selection.start_line, selection.finish_line)
        end

        if send_buffer then
            return "buffer"
        end

        return "file"
    end

    local function update_header()
        local lines = {
            "Session: " .. (session.cwd or "?"),
            "File: " .. (relative_file ~= "" and relative_file or "(no file)"),
            "Scope: " .. scope_label(),
            "Model: " .. (selected_model ~= "" and selected_model or "(current)"),
            "Effort: " .. selected_thinking,
            "Keys: :w send • :q close • <Tab> buffer • <C-p> model • <C-t> effort",
        }

        vim.bo[header_buf].modifiable = true
        vim.api.nvim_buf_set_lines(header_buf, 0, -1, false, lines)
        vim.bo[header_buf].modifiable = false
    end

    local function close()
        if closed then
            return
        end
        closed = true
        pcall(vim.api.nvim_win_close, prompt_win, true)
        pcall(vim.api.nvim_win_close, header_win, true)
        pcall(vim.api.nvim_buf_delete, prompt_buf, { force = true })
        pcall(vim.api.nvim_buf_delete, header_buf, { force = true })
    end

    local function build_message(prompt_text)
        if selection then
            local target = selection.absolute_file ~= "" and selection.absolute_file or selection.file
            local header = string.format("%s lines %d-%d", target, selection.start_line, selection.finish_line)
            if prompt_text == "" then
                return string.format("Look at this code from %s:\n\n```%s\n%s\n```", header, selection.filetype, selection.text)
            end
            return string.format("%s\n\nFrom %s:\n```%s\n%s\n```", prompt_text, header, selection.filetype, selection.text)
        end

        if send_buffer and absolute_file ~= "" then
            local content = table.concat(buffer_lines, "\n")
            if prompt_text == "" then
                return string.format("Look at this file %s:\n\n```%s\n%s\n```", absolute_file, filetype, content)
            end
            return string.format("%s\n\nFile: %s\n```%s\n%s\n```", prompt_text, absolute_file, filetype, content)
        end

        if absolute_file ~= "" then
            if prompt_text == "" then
                return string.format("Look at this file: %s", absolute_file)
            end
            return string.format("File: %s\n\n%s", absolute_file, prompt_text)
        end

        return prompt_text
    end

    local function send()
        local prompt_text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(prompt_buf, 0, -1, false), "\n"))
        local message = build_message(prompt_text)
        if message == "" then
            vim.notify("Nothing to send", vim.log.levels.WARN)
            return
        end

        local request_id = tostring(vim.uv.hrtime())
        pi.enqueue({
            id = request_id,
            prompt = message,
            model = selected_model,
            thinking = selected_thinking,
            buf = source_buf,
            line = source_line,
            col = source_col,
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
            close()
        end)
    end

    update_header()
    vim.api.nvim_set_current_win(prompt_win)
    vim.cmd("startinsert")

    local keymap_opts = { buffer = prompt_buf, noremap = true, silent = true }

    vim.keymap.set({ "n", "i" }, "<C-p>", function()
        selected_model = cycle(models, selected_model)
        update_header()
    end, keymap_opts)

    vim.keymap.set({ "n", "i" }, "<C-t>", function()
        selected_thinking = cycle(session.thinking_levels or thinking_levels, selected_thinking)
        update_header()
    end, keymap_opts)

    vim.keymap.set({ "n", "i" }, "<Tab>", function()
        if selection then
            return
        end
        send_buffer = not send_buffer
        update_header()
    end, keymap_opts)

    vim.keymap.set("n", "q", close, keymap_opts)

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = prompt_buf,
        callback = send,
    })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = prompt_buf,
        callback = function()
            vim.bo[prompt_buf].modified = false
        end,
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = prompt_buf,
        once = true,
        callback = function()
            if closed then
                return
            end
            closed = true
            pcall(vim.api.nvim_win_close, header_win, true)
            pcall(vim.api.nvim_buf_delete, header_buf, { force = true })
        end,
    })
end

return M
