local todo_module = {}

local todo_file = vim.fn.expand("~/Projects/notes/todo.md")
local todo_buffer = nil
local todo_window = nil

-- Create the floating todo window.
local function create_todo_float()
    local editor_width = vim.o.columns
    local editor_height = vim.o.lines
    local window_width = math.floor(editor_width * 0.8)
    local window_height = math.floor(editor_height * 0.8)
    local row = math.floor(editor_height * 0.1)
    local column = math.floor((editor_width - window_width) / 2)

    if not todo_buffer or not vim.api.nvim_buf_is_valid(todo_buffer) then
        todo_buffer = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_buf_set_name(todo_buffer, todo_file)
        vim.bo[todo_buffer].filetype = "markdown"
    end

    todo_window = vim.api.nvim_open_win(todo_buffer, true, {
        relative = "editor",
        width = window_width,
        height = window_height,
        row = row,
        col = column,
        style = "minimal",
        border = "double",
    })

    vim.api.nvim_set_hl(0, "TodoFloatNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TodoFloatBorder", { bg = "NONE", fg = "#555555" })
    vim.wo[todo_window].winhighlight = "Normal:TodoFloatNormal,NormalFloat:TodoFloatNormal,FloatBorder:TodoFloatBorder"
    vim.wo[todo_window].signcolumn = "yes:2"
    vim.wo[todo_window].number = false
    vim.wo[todo_window].relativenumber = false

    if vim.fn.filereadable(todo_file) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(todo_file))
    else
        vim.fn.writefile({}, todo_file)
    end

    vim.keymap.set("n", "q", function()
        todo_module.close()
    end, { buffer = todo_buffer, silent = true })
end

function todo_module.toggle()
    if todo_window and vim.api.nvim_win_is_valid(todo_window) then
        todo_module.close()
        return
    end

    create_todo_float()
end

function todo_module.close()
    if todo_window and vim.api.nvim_win_is_valid(todo_window) then
        vim.api.nvim_win_close(todo_window, true)
        todo_window = nil
    end
end

return todo_module
