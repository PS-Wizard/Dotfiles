local api = vim.api
local buffer = api.nvim_create_buf(false, true)
local window

local function update()
    local name = vim.fn.fnamemodify(api.nvim_buf_get_name(0), ":t")
    if name == "" then
        name = "[No Name]"
    end

    api.nvim_buf_set_lines(buffer, 0, -1, false, { name })
    local width = math.min(vim.o.columns, vim.fn.strdisplaywidth(name))
    local config = {
        relative = "editor",
        row = 0,
        col = vim.o.columns - width,
        width = width,
        height = 1,
        border = "none",
        style = "minimal",
        focusable = false,
        zindex = 50,
    }

    if window and api.nvim_win_is_valid(window) then
        api.nvim_win_set_config(window, config)
    else
        window = api.nvim_open_win(buffer, false, config)
        vim.wo[window].winhighlight = "Normal:Normal,NormalFloat:Normal"
        vim.wo[window].wrap = false
    end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "VimResized", "WinEnter" }, {
    group = vim.api.nvim_create_augroup("UserConfigFilename", { clear = true }),
    callback = update,
})

update()
