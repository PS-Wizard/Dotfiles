-- Function to get human-readable file size
function get_file_size()
    local size = vim.fn.getfsize(vim.fn.bufname())
    if size < 0 then return "0 B" end
    local units = { "B", "KB", "MB", "GB" }
    local i = 1
    while size > 1024 and i < #units do
        size = size / 1024
        i = i + 1
    end
    return string.format("%.1f %s", size, units[i])
end

-- Function to get word count
function get_word_count()
    return vim.fn.wordcount().words
end

-- Function to get scroll percentage
function get_scroll_percentage()
    local current_line = vim.fn.line('.')
    local total_lines = vim.fn.line('$')
    if total_lines == 0 then return "0%" end
    return string.format("%d%%", math.floor(current_line / total_lines * 100))
end

-- Function to build the statusline
function build_statusline()
    local file_size = get_file_size()
    local filename = vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.bufname(), ":t"))
    local word_count = get_word_count()
    local scroll_pct = get_scroll_percentage()

    -- Left: File size, word count, and scroll percentage
    local right = "%#@statusline.left#" .. file_size .. " | " .. word_count .. " words | " .. scroll_pct
    -- Right: Filename with @comment.todo highlight
    local left = "%#@comment.todo#" .. filename .. "%#Normal#"

    return left .. "%<" .. "%=" .. right
end

-- Set statusline at the bottom
vim.o.laststatus = 3  -- Enable global statusline at the bottom
vim.o.winbar = ''     -- Disable winbar to avoid statusline at the top
vim.o.statusline = "%!luaeval('build_statusline()')"

-- Refresh statusline on relevant events
vim.api.nvim_create_autocmd({"BufEnter", "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "ColorScheme"}, {
    group = vim.api.nvim_create_augroup("CustomStatusline", { clear = true }),
    pattern = "*",
    callback = function()
        vim.o.statusline = "%!luaeval('build_statusline()')"
    end,
})
