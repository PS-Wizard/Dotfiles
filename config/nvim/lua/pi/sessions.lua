local uv = vim.uv or vim.loop

local M = {}

local SESSIONS_DIR = "/tmp/pi-bridge-sessions"

local function read_json(path)
    local stat = uv.fs_stat(path)
    if not stat then
        return nil
    end

    local fd = uv.fs_open(path, "r", 438)
    if not fd then
        return nil
    end

    local data = uv.fs_read(fd, stat.size, 0)
    uv.fs_close(fd)
    if not data or data == "" then
        return nil
    end

    local ok, decoded = pcall(vim.json.decode, data)
    if not ok or type(decoded) ~= "table" then
        return nil
    end

    return decoded
end

local function session_label(session)
    local parts = {
        session.cwd or "?",
        string.format("pid %s", session.pid or "?"),
    }

    if session.current_model and session.current_model ~= "" then
        table.insert(parts, session.current_model)
    end

    if session.current_thinking and session.current_thinking ~= "" then
        table.insert(parts, string.format("effort %s", session.current_thinking))
    end

    if session.busy then
        table.insert(parts, string.format("busy%s", session.queue_length and session.queue_length > 1 and string.format(" (%d)", session.queue_length) or ""))
    end

    return table.concat(parts, " • ")
end

function M.list()
    local files = vim.fn.glob(SESSIONS_DIR .. "/*.json", false, true)
    local sessions = {}

    for _, file in ipairs(files) do
        local session = read_json(file)
        if session and session.socket_path and uv.fs_stat(session.socket_path) then
            session.info_path = file
            table.insert(sessions, session)
        end
    end

    table.sort(sessions, function(a, b)
        return (a.started_at or "") > (b.started_at or "")
    end)

    return sessions
end

function M.choose(cb)
    local sessions = M.list()
    if #sessions == 0 then
        vim.notify("No pi bridge sessions found", vim.log.levels.WARN)
        cb(nil)
        return
    end

    if #sessions == 1 then
        cb(sessions[1])
        return
    end

    vim.ui.select(sessions, {
        prompt = "Pi sessions",
        format_item = session_label,
    }, function(choice)
        cb(choice)
    end)
end

function M.label(session)
    return session_label(session)
end

return M
