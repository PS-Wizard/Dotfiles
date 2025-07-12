-- Define highlight groups for TODO-like keywords and statusline
vim.api.nvim_set_hl(0, "@comment.error", { bg = "#F5B829", fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@comment.hint", { bg = "#C3E991", fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@comment.info", { bg = "#BFD1E5", fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@comment.note", { bg = "#D6FF79", fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@comment.todo", { bg = "#ccccff", fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@comment.warning", { bg = "#f5c32e", fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@statusline.left", { fg = "#7f7f7f", bold = false })

-- Function to set up highlight matches for TODO-like keywords in comments
local function setup_todo_highlights()
    vim.fn.clearmatches()
    local keywords = {
        { pattern = "\\(TODO:\\)", group = "@comment.todo" },
        { pattern = "\\(NOTE:\\)", group = "@comment.note" },
        { pattern = "\\(INFO:\\)", group = "@comment.info" },
        { pattern = "\\(HINT:\\)", group = "@comment.hint" },
        { pattern = "\\(WARN:\\|WARNING:\\)", group = "@comment.warning" },
        { pattern = "\\(ERROR:\\|FIXME:\\|BUG:\\)", group = "@comment.error" },
    }
    for _, kw in ipairs(keywords) do
        vim.fn.matchadd(kw.group, kw.pattern, 10)
    end
end

-- Set up autocommand for TODO highlights
vim.api.nvim_create_autocmd({"BufEnter", "ColorScheme"}, {
    group = vim.api.nvim_create_augroup("TodoHighlights", { clear = true }),
    pattern = "*",
    callback = setup_todo_highlights,
})
