-- Function to build the statusline
function build_statusline()
    local filename = vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.bufname(), ":t"))
    -- Right: Filename with @comment.todo highlight
    local left = "%#@comment.todo#" .. filename .. "%#Normal#"
    return left .. "%<"
end

-- Make statusline transparent
vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })

-- Set statusline at the bottom
vim.o.laststatus = 3  -- Enable global statusline at the bottom
vim.o.winbar = ''     -- Disable winbar to avoid statusline at the top
vim.o.statusline = "%!luaeval('build_statusline()')"

-- Refresh statusline on relevant events
vim.api.nvim_create_autocmd({"BufEnter", "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "ColorScheme"}, {
    group = vim.api.nvim_create_augroup("CustomStatusline", { clear = true }),
    pattern = "*",
    callback = function()
        -- Reapply transparent statusline after colorscheme changes
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
        vim.o.statusline = "%!luaeval('build_statusline()')"
    end,
})
