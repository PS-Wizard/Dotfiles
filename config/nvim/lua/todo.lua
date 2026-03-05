local M = {}
-- Todo file path
local todo_file = vim.fn.expand("~/.config/nvim/todos.md")
local buf = nil
local win = nil
-- Function to create centered floating window
local function create_float()
    -- Get editor dimensions
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    -- Calculate float window size (80% width, 80% height)
    local win_width = math.floor(width * 0.8)
    local win_height = math.floor(height * 0.8)
    -- Calculate starting position - starts at 10% from top, centered horizontally
    local row = math.floor(height * 0.01)  -- 10vh from top
    local col = math.floor((width - win_width) / 2)
    -- Window options
    local opts = {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = "double"
    }
    -- Create buffer if it doesn't exist
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        buf = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_buf_set_name(buf, todo_file)
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    end
    -- Create the window
    win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Add margin by setting signcolumn and numberwidth
    vim.api.nvim_win_set_option(win, "signcolumn", "yes:2")  -- 2-column margin on the left
    vim.api.nvim_win_set_option(win, "number", false)  -- No line numbers
    vim.api.nvim_win_set_option(win, "relativenumber", false)  -- No relative numbers
    
    -- Load the file if it exists
    if vim.fn.filereadable(todo_file) == 1 then
        vim.cmd("edit " .. todo_file)
    else
        -- Create the file if it doesn't exist
        vim.fn.writefile({}, todo_file)
    end
    -- Set local keybinding to close with 'q'
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua require("todo").close()<CR>', 
    { noremap = true, silent = true })
end
-- Function to toggle todo window
function M.toggle()
    if win and vim.api.nvim_win_is_valid(win) then
        M.close()
    else
        create_float()
    end
end
-- Function to close the window
function M.close()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
        win = nil
    end
end
return M
