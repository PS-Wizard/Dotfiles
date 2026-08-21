-- review.lua -- collect code review comments.
-- Bindings (see keymaps.lua):
--   <leader><leader>  normal mode: comment the current line
--                     visual mode:  comment the selection
--   <leader>c         copy all comments to the global clipboard
--   <leader>d         clear all comments and ghost marks
-- In the comment window: :w saves, q cancels.

local M = {}

-- Ghost text shown at the end of each commented line.
local MARK = "--- " -- prefix for the comment preview on the first line
local CONTINUE = " ·" -- marker for the rest of the range


local ns = vim.api.nvim_create_namespace("review")

-- One entry per comment: { path, start, finish, text, comment, marks = { [buf] = mark_id } }
local entries = {}
local float_buf = nil
local float_win = nil
local pending = nil -- context of the open comment window

vim.api.nvim_set_hl(0, "ReviewMark", { link = "Comment" })
vim.api.nvim_set_hl(0, "ReviewFloatBorder", { bg = "NONE", fg = "#555555" })

-- Truncate s to maxw display columns, appending "…" when cut.
local function truncate_width(s, maxw)
    if vim.fn.strwidth(s) <= maxw then
        return s
    end
    local n = maxw
    while n > 0 and vim.fn.strwidth(vim.fn.strcharpart(s, 0, n)) > maxw - 1 do
        n = n - 1
    end
    return vim.fn.strcharpart(s, 0, n) .. "…"
end

-- Draw ghost text per commented line in the buffer.
local function apply_marks(buf)
    local path = vim.api.nvim_buf_get_name(buf)
    if path == "" then
        return
    end
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    local line_count = vim.api.nvim_buf_line_count(buf)
    local seen = {}
    for _, e in ipairs(entries) do
        if e.path == path then
            e.marks = e.marks or {}
            e.marks[buf] = nil
            local preview = e.comment:gsub("\n.*$", "") -- first line only
            if preview:match("^%s*$") then
                preview = "(comment)"
            end
            for ln = e.start, e.finish do
                if ln <= line_count and not seen[ln] then
                    seen[ln] = true
                    local vt
                    if ln == e.start then
                        local line_text = vim.api.nvim_buf_get_lines(buf, ln - 1, ln, false)[1] or ""
                        local avail = vim.o.columns - vim.fn.strwidth(line_text) - 6
                        if avail < 12 then
                            avail = 12
                        end
                        vt = { { MARK, "ReviewMark" }, { truncate_width(preview, avail), "ReviewMark" } }
                    else
                        vt = { { CONTINUE, "ReviewMark" } }
                    end
                    local id = vim.api.nvim_buf_set_extmark(buf, ns, ln - 1, 0, {
                        virt_text = vt,
                        virt_text_pos = "eol",
                        hl_mode = "combine",
                    })
                    if id and not e.marks[buf] then
                        e.marks[buf] = id
                    end
                end
            end
        end
    end
end

-- Refresh entry line numbers from the live ghost marks.
local function refresh_positions()
    for _, e in ipairs(entries) do
        local buf = vim.fn.bufnr(e.path)
        if buf ~= -1 and e.marks and e.marks[buf] then
            local ok, pos = pcall(vim.api.nvim_buf_get_extmark_by_id, buf, ns, e.marks[buf])
            if ok and pos and #pos > 0 then
                local span = e.finish - e.start
                e.start = pos[1] + 1
                e.finish = e.start + span
            end
        end
    end
end

local function close_float()
    if float_win and vim.api.nvim_win_is_valid(float_win) then
        vim.api.nvim_win_close(float_win, true)
    end
    float_buf = nil
    float_win = nil
    pending = nil
end

local function open_float()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "review-comment") -- :w needs a name or it raises E32
    vim.bo[buf].buftype = "acwrite" -- :w must go through BufWriteCmd; nofile would raise E382
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false

    local width = math.min(60, vim.o.columns - 4)
    local height = math.min(6, vim.o.lines - 4)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = string.format(
            " Review: %s:%d-%d ",
            vim.fn.fnamemodify(pending.path, ":t"),
            pending.start,
            pending.finish
        ),
        title_pos = "center",
    })
    vim.wo[win].winhighlight = vim.wo[win].winhighlight .. ",FloatBorder:ReviewFloatBorder"
    vim.wo[win].wrap = true

    vim.keymap.set("n", "q", close_float, { buffer = buf, desc = "Discard review comment" })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        desc = "Save the review comment",
        callback = function()
            local comment = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
            comment = comment:gsub("^%s+", ""):gsub("%s+$", "")
            if comment == "" then
                vim.notify("Review: comment is empty", vim.log.levels.ERROR)
                return
            end
            local e = pending
            e.comment = comment
            table.insert(entries, e)
            local src = vim.fn.bufnr(e.path)
            if src ~= -1 then
                apply_marks(src)
            end
            vim.bo[buf].modified = false
            vim.schedule(close_float)
            vim.notify(string.format("Review: %d comment(s) saved", #entries))
        end,
    })

    float_buf = buf
    float_win = win
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>i", true, false, true), "n", false)
end

-- Add a review comment. from_visual is true when the visual keymap fired;
-- that keymap ends visual mode first, so '< '> and visualmode() are valid there.
function M.comment(from_visual)
    if float_win and vim.api.nvim_win_is_valid(float_win) then
        vim.notify("Review: comment window is already open", vim.log.levels.WARN)
        return
    end
    local path = vim.fn.expand("%:p")
    if path == "" then
        vim.notify("Review: buffer has no file name", vim.log.levels.ERROR)
        return
    end
    local start_line, finish_line, text
    if from_visual then
        local vmode = vim.fn.visualmode()
        start_line = vim.fn.line("'<")
        finish_line = vim.fn.line("'>")
        text = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vmode })
    else
        start_line = vim.fn.line(".")
        finish_line = start_line
        text = { vim.fn.getline(".") }
    end
    pending = { path = path, start = start_line, finish = finish_line, text = text }
    open_float()
end

-- Copy all comments to the global clipboard.
function M.copy()
    if #entries == 0 then
        vim.notify("Review: no comments to copy", vim.log.levels.ERROR)
        return
    end
    refresh_positions()
    table.sort(entries, function(a, b)
        if a.path == b.path then
            return a.start < b.start
        end
        return a.path < b.path
    end)
    local parts = {}
    for _, e in ipairs(entries) do
        local range = tostring(e.start)
        if e.finish ~= e.start then
            range = string.format("%d-%d", e.start, e.finish)
        end
        parts[#parts + 1] = string.format(
            "File: %s: line_num: %s\n\n%s\n\n%s",
            e.path,
            range,
            table.concat(e.text, "\n"),
            e.comment
        )
    end
    vim.fn.setreg("+", table.concat(parts, "\n\n\n---\n\n\n"))
    vim.notify(string.format("Review: copied %d comment(s) to the clipboard", #entries))
end

-- Clear all comments and ghost marks.
function M.clear()
    if #entries == 0 then
        vim.notify("Review: no comments to clear", vim.log.levels.INFO)
        return
    end
    local seen = {}
    for _, e in ipairs(entries) do
        local buf = vim.fn.bufnr(e.path)
        if buf ~= -1 and not seen[buf] then
            seen[buf] = true
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        end
    end
    entries = {}
    vim.notify("Review: cleared all comments")
end

-- Return the live entry list. Used by tests and for introspection.
function M.list()
    return entries
end

-- Re-apply ghost marks when a commented buffer is loaded again.
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("ReviewMarks", { clear = true }),
    desc = "Re-apply review ghost marks",
    callback = function()
        if #entries > 0 then
            apply_marks(vim.api.nvim_get_current_buf())
        end
    end,
})

return M
