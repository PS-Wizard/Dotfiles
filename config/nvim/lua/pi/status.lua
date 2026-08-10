local uv = vim.uv or vim.loop

local M = {}

local namespace = vim.api.nvim_create_namespace("pi_bridge_status")
local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local poll_timer = nil
local anim_timer = nil
local frame = 1
local connected = nil
local requests = {}
local last_finish_token = nil

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

local function clear_request(id)
    local item = requests[id]
    if not item then
        return
    end

    if vim.api.nvim_buf_is_valid(item.buf) then
        pcall(vim.api.nvim_buf_del_extmark, item.buf, namespace, item.mark_id)
    end

    requests[id] = nil
end

local function draw(item)
    if not vim.api.nvim_buf_is_valid(item.buf) then
        requests[item.id] = nil
        return
    end

    local text
    if item.state == "running" then
        text = string.format(" %s pi working", spinner[frame])
    elseif item.state == "queued" then
        text = string.format(" 󱎫 pi queued #%d", item.qindex or 1)
    else
        text = " 󱎫 pi queued"
    end

    item.mark_id = vim.api.nvim_buf_set_extmark(item.buf, namespace, item.line, item.col, {
        id = item.mark_id,
        virt_text = { { text, "Comment" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
    })
end

local function handle_finished(meta)
    if not meta.last_finished_job_id or not meta.last_finished_at then
        return
    end

    local token = meta.last_finished_job_id .. ":" .. meta.last_finished_at
    if token == last_finish_token then
        return
    end

    last_finish_token = token
    clear_request(meta.last_finished_job_id)
    pcall(vim.cmd, "silent! checktime")

    if meta.last_finished_ok == false and meta.last_error and meta.last_error ~= "" then
        vim.notify("Pi failed: " .. meta.last_error, vim.log.levels.ERROR)
    end
end

local function apply_meta(meta)
    if connected then
        for key, value in pairs(meta) do
            connected[key] = value
        end
    end

    handle_finished(meta)

    local running_id = meta.current_job_id
    local queued = {}
    for index, id in ipairs(meta.queued_job_ids or {}) do
        queued[id] = index
    end

    for id, item in pairs(requests) do
        if running_id and running_id ~= "" and running_id == id then
            item.state = "running"
            draw(item)
        elseif queued[id] then
            item.state = "queued"
            item.qindex = queued[id]
            draw(item)
        elseif meta.last_finished_job_id == id then
            clear_request(id)
        end
    end
end

function M.refresh()
    if not connected or not connected.info_path then
        return
    end

    local meta = read_json(connected.info_path)
    if not meta then
        return
    end

    apply_meta(meta)
end

-- Advance the spinner independently of the (slower) metadata poll so "pi working"
-- animates smoothly instead of ticking once per file read.
local function animate()
    frame = (frame % #spinner) + 1
    for _, item in pairs(requests) do
        if item.state == "running" then
            draw(item)
        end
    end
end

local function stop_timer(timer)
    if timer then
        timer:stop()
        timer:close()
    end
end

function M.connect(session)
    connected = session
    M.refresh()

    stop_timer(poll_timer)
    poll_timer = uv.new_timer()
    if poll_timer then
        poll_timer:start(0, 250, vim.schedule_wrap(M.refresh))
    end

    stop_timer(anim_timer)
    anim_timer = uv.new_timer()
    if anim_timer then
        anim_timer:start(100, 100, vim.schedule_wrap(animate))
    end
end

function M.disconnect()
    connected = nil
    stop_timer(poll_timer)
    poll_timer = nil
    stop_timer(anim_timer)
    anim_timer = nil

    for id in pairs(requests) do
        clear_request(id)
    end
end

function M.register_request(id, opts)
    if not vim.api.nvim_buf_is_valid(opts.buf) then
        return
    end

    local line = math.max(0, math.min(opts.line or 0, vim.api.nvim_buf_line_count(opts.buf) - 1))
    local item = {
        id = id,
        buf = opts.buf,
        line = line,
        col = opts.col or 0,
        state = "queued",
    }

    draw(item)
    requests[id] = item
    M.refresh()
end

return M
