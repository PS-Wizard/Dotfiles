local silent = { noremap = true, silent = true }

-- File and buffer navigation.
vim.keymap.set("n", "<leader>pv", function()
    require("mini.files").open()
end, { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>n", "<C-^>", silent)
vim.keymap.set("n", "<leader>o", function()
    require("mini.pick").builtin.buffers()
end, { desc = "Pick buffers" })
vim.keymap.set("n", "<leader>l", "<cmd>e!<CR>", { desc = "Reload current file" })
vim.keymap.set("n", "<C-q>", "<cmd>wq!<CR>", silent)

-- Search and picker keymaps.
vim.keymap.set("n", "<leader>ff", function()
    require("mini.pick").builtin.files()
end, { desc = "Pick files" })
vim.keymap.set("n", "<leader>fg", function()
    require("mini.pick").builtin.grep_live()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fd", function()
    require("mini.extra").pickers.diagnostic({ scope = "current" })
end, { desc = "Document diagnostics" })
vim.keymap.set("n", "<leader>fs", function()
    require("mini.extra").pickers.lsp({ scope = "document_symbol" })
end, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fm", function()
    require("mini.extra").pickers.marks()
end, { desc = "Pick marks" })
vim.keymap.set("n", "<leader>gb", function()
    require("mini.extra").pickers.git_branches()
end, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gc", function()
    require("mini.extra").pickers.git_commits()
end, { desc = "Git commits" })


-- Clipboard keymaps.
vim.keymap.set("v", "gy", '"+y', silent)
vim.keymap.set("n", "gp", '"+p', silent)
vim.keymap.set("v", "gp", '"_d"+P', silent)



-- Todo notes.
vim.keymap.set("n", "<leader>t", function()
    require("todo").toggle()
end, { desc = "Toggle todo float" })
vim.keymap.set("n", "<leader>T", "<cmd>edit ~/Projects/notes/todo.md<CR>", { desc = "Open todo file" })

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
