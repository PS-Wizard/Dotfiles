local uv = vim.uv or vim.loop

local M = {}

function M.request(socket_path, payload, cb)
    if not socket_path or socket_path == "" then
        cb("No pi session selected", nil)
        return
    end

    local client = uv.new_pipe(false)
    if not client then
        cb("Failed to create socket client", nil)
        return
    end

    local done = false
    local function finish(err, response)
        if done then
            return
        end
        done = true
        pcall(client.read_stop, client)
        pcall(client.close, client)
        vim.schedule(function()
            cb(err, response)
        end)
    end

    client:connect(socket_path, function(err)
        if err then
            finish(err, nil)
            return
        end

        local ok, encoded = pcall(vim.json.encode, payload)
        if not ok then
            finish(encoded, nil)
            return
        end

        client:write(encoded .. "\n")

        local buffer = ""
        client:read_start(function(read_err, data)
            if read_err then
                finish(read_err, nil)
                return
            end

            if not data then
                finish("Socket closed before response", nil)
                return
            end

            buffer = buffer .. data
            local newline = buffer:find("\n", 1, true)
            if not newline then
                return
            end

            local line = buffer:sub(1, newline - 1)
            local parsed_ok, decoded = pcall(vim.json.decode, line)
            if not parsed_ok then
                finish("Invalid response from pi", nil)
                return
            end

            finish(nil, decoded)
        end)
    end)
end

return M
