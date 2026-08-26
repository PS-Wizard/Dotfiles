local silent = { noremap = true, silent = true }

-- File and buffer navigation.
vim.keymap.set("n", "<leader>pv", function()
    require("mini.files").open()
end, { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>n", "<C-^>", silent)
vim.keymap.set("n", "<leader>o", function()
    require("fzf-lua").buffers()
end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>l", "<cmd>e!<CR>", { desc = "Reload current file" })
vim.keymap.set("n", "<C-q>", "<cmd>wq!<CR>", silent)

-- Search and picker keymaps.
vim.keymap.set("n", "<leader>ff", function()
    require("fzf-lua").files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function()
    require("fzf-lua").live_grep()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fd", function()
    require("fzf-lua").diagnostics_document()
end, { desc = "Document diagnostics" })
vim.keymap.set("n", "<leader>fs", function()
    require("fzf-lua").lsp_document_symbols()
end, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fm", function()
    require("fzf-lua").marks()
end, { desc = "Find marks" })
vim.keymap.set("n", "<leader>gb", function()
    require("fzf-lua").git_branches()
end, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gc", function()
    require("fzf-lua").git_commits()
end, { desc = "Git commits" })


-- Clipboard keymaps.
vim.keymap.set("v", "gy", '"+y', silent)
vim.keymap.set("n", "gp", '"+p', silent)
vim.keymap.set("v", "gp", '"_d"+P', silent)



-- Todo notes.
vim.keymap.set("n", "<leader>t", function()
    require("todo").toggle()
end, { desc = "Toggle todo board" })
vim.keymap.set("n", "<leader>T", function()
    require("todo").edit()
end, { desc = "Edit raw TODO.md" })
vim.keymap.set("n", "<leader>ft", function()
    require("todo").pick()
end, { desc = "Pick todo board" })

-- Code review comments.
-- Note: the visual mapping uses :<C-u> because nvim does not set '< '> marks
-- inside a visual-mode callback; ending visual mode first makes them valid.
vim.keymap.set("n", "<leader><leader>", function()
    require("review").comment(false)
end, { desc = "Add review comment" })
vim.keymap.set("v", "<leader><leader>", ":<C-u>lua require('review').comment(true)<CR>", { desc = "Add review comment" })
vim.keymap.set("n", "<leader>c", function()
    require("review").copy()
end, { desc = "Copy review comments to clipboard" })
vim.keymap.set("n", "<leader>d", function()
    require("review").clear()
end, { desc = "Clear review comments" })

-- Editing helpers.
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting", silent = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<", "<gv", { desc = "Unindent and keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent and keep selection" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move down with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move up with cursor centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })


vim.keymap.set("n", "<leader>ab", function()
    vim.api.nvim_put({ "```", "", "```" }, "l", true, true)
    vim.api.nvim_feedkeys("k", "n", true)
end, { desc = "Insert markdown code block" })

local function markdown_todo_toggle()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    -- Toggle existing todo: - [ ] <-> - [x]
    local indent, mark, text = line:match("^(%s*)%- %[([ xX])%] ?(.*)$")
    if indent then
        local new_mark = (mark == " " and "x" or " ")
        vim.api.nvim_set_current_line(indent .. "- [" .. new_mark .. "] " .. text)
        return
    end
    -- Plain bullet "- " -> todo unchecked
    local b_indent, b_text = line:match("^(%s*)%- (.*)$")
    if b_indent then
        local new_line = b_indent .. "- [ ] " .. b_text
        vim.api.nvim_set_current_line(new_line)
        vim.api.nvim_win_set_cursor(0, { row, #new_line })
        return
    end
    -- Empty line -> new todo; plain text -> prefix with todo
    local p_indent, content = line:match("^(%s*)(.*)$")
    if content == "" then
        vim.api.nvim_set_current_line(p_indent .. "- [ ] ")
        vim.api.nvim_win_set_cursor(0, { row, #p_indent + 6 })
        return
    end
    local new_line = p_indent .. "- [ ] " .. content
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, col + 6 })
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(event)
        vim.keymap.set("i", "<C-l>", markdown_todo_toggle, {
            buffer = event.buf,
            desc = "Toggle markdown todo [ ] / [x]",
        })
        vim.keymap.set("n", "<C-l>", markdown_todo_toggle, {
            buffer = event.buf,
            desc = "Toggle markdown todo [ ] / [x]",
        })
    end,
})


-- Window navigation.
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<CR>", silent)
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<CR>", silent)
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<CR>", silent)
vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<CR>", silent)

-- Quickfix and location list helpers.
local function open_quickfix_if_diagnostics_exist()
    vim.diagnostic.setqflist()
    local quickfix_list = vim.fn.getqflist()
    if #quickfix_list > 0 then
        vim.cmd("copen")
    end
end

local function smart_qf_loc_next()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        local location_list = vim.fn.getloclist(0, { idx = 0, size = 0 })
        if location_list.idx == location_list.size then
            vim.cmd("lfirst")
        else
            vim.cmd("lnext")
        end
    elseif vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        local quickfix_list = vim.fn.getqflist({ idx = 0, size = 0 })
        if quickfix_list.idx == quickfix_list.size then
            vim.cmd("cfirst")
        else
            vim.cmd("cnext")
        end
    end
    vim.cmd("normal! zz")
end

local function smart_qf_loc_prev()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        local location_list = vim.fn.getloclist(0, { idx = 0 })
        if location_list.idx == 1 then
            vim.cmd("llast")
        else
            vim.cmd("lprev")
        end
    elseif vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        local quickfix_list = vim.fn.getqflist({ idx = 0 })
        if quickfix_list.idx == 1 then
            vim.cmd("clast")
        else
            vim.cmd("cprev")
        end
    end
    vim.cmd("normal! zz")
end

local function toggle_quickfix_window()
    for _, window in ipairs(vim.fn.getwininfo()) do
        if window.quickfix == 1 then
            vim.cmd("cclose")
            return
        end
    end
    vim.cmd("copen")
end

vim.keymap.set("n", "<leader>q", toggle_quickfix_window, { desc = "Toggle quickfix" })
vim.keymap.set("n", "<C-n>", smart_qf_loc_next, silent)
vim.keymap.set("n", "<C-p>", smart_qf_loc_prev, silent)

_G.open_quickfix_if_diagnostics_exist = open_quickfix_if_diagnostics_exist
