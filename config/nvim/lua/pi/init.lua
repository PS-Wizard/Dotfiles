local M = {
    session = nil,
}

local socket = require("pi.socket")
local sessions = require("pi.sessions")
local status = require("pi.status")

local function set_session(session)
    M.session = session
    if session then
        status.connect(session)
    else
        status.disconnect()
    end
end

local function ensure_session(cb)
    if M.session and M.session.socket_path and vim.uv.fs_stat(M.session.socket_path) then
        cb(M.session)
        return
    end

    sessions.choose(function(session)
        if not session then
            cb(nil)
            return
        end

        set_session(session)
        vim.notify("Connected to pi: " .. (session.cwd or "?"), vim.log.levels.INFO)
        cb(session)
    end)
end

function M.get_session()
    return M.session
end

function M.connect(cb)
    sessions.choose(function(session)
        if not session then
            if cb then
                cb(false)
            end
            return
        end

        set_session(session)
        vim.notify("Connected to pi: " .. (session.cwd or "?"), vim.log.levels.INFO)
        if cb then
            cb(true)
        end
    end)
end

function M.ping()
    ensure_session(function(session)
        if not session then
            return
        end

        socket.request(session.socket_path, { type = "ping" }, function(err, response)
            if err then
                vim.notify("Pi not reachable: " .. err, vim.log.levels.ERROR)
                return
            end

            if response and response.ok then
                vim.notify("Pi is alive", vim.log.levels.INFO)
                return
            end

            vim.notify("Unexpected pi response", vim.log.levels.WARN)
        end)
    end)
end

function M.enqueue(request, cb)
    ensure_session(function(session)
        if not session then
            cb("No pi session connected", nil)
            return
        end

        socket.request(session.socket_path, {
            type = "enqueue",
            id = request.id,
            prompt = request.prompt,
            model = request.model,
            thinking = request.thinking,
        }, function(err, response)
            if err then
                cb(err, nil)
                return
            end

            if not response or not response.ok then
                cb(response and response.error or "Unknown pi error", response)
                return
            end

            status.register_request(request.id, {
                buf = request.buf,
                line = request.line,
                col = request.col,
            })
            cb(nil, response)
        end)
    end)
end

function M.open(opts)
    ensure_session(function(session)
        if not session then
            return
        end

        require("pi.ui").open(opts)
    end)
end

function M.setup()
    vim.o.autoread = true

    vim.api.nvim_create_user_command("PiConnect", function()
        M.connect()
    end, { desc = "Connect to a pi session" })

    vim.api.nvim_create_user_command("PiPing", function()
        M.ping()
    end, { desc = "Ping the connected pi session" })

    vim.api.nvim_create_user_command("Pi", function(args)
        local selection = nil
        if args.range == 2 then
            selection = require("pi.ui").capture_selection()
        end
        M.open({ selection = selection })
    end, { range = true, desc = "Open pi prompt" })

    vim.keymap.set("n", "<leader><leader>", ":Pi<CR>", { desc = "Open Pi prompt" })
    vim.keymap.set({ "x", "v" }, "<leader><leader>", ":Pi<CR>", { desc = "Open Pi prompt" })
end

return M
