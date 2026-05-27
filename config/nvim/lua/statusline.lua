-- Build the minimal filename-only statusline.
local function build_statusline()
    local filename = vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.bufname(), ":t"))
    local left = "%#@comment.todo#" .. filename .. "%#Normal#"
    return left .. "%<"
end

-- Feed the custom statusline into tpipeline and clear Neovim's own bar.
local function apply_statusline()
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
    vim.g.tpipeline_statusline = "%!v:lua.UserConfigBuildStatusline()"
    vim.g.tpipeline_clearstl = 1
    vim.o.laststatus = 3
    vim.o.winbar = ""
    vim.o.statusline = vim.g.tpipeline_clearstl == 1 and "%#StatusLine#" or vim.g.tpipeline_statusline
end

_G.UserConfigBuildStatusline = build_statusline

vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "ColorScheme" }, {
    group = vim.api.nvim_create_augroup("UserConfigStatusline", { clear = true }),
    callback = apply_statusline,
})

apply_statusline()
