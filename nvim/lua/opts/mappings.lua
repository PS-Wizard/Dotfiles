local opts = { noremap = true, silent = true }
vim.wo.signcolumn = 'yes'
-- Toggle between the latest buffers


vim.keymap.set("n", "<leader>pv", ":lua MiniFiles.open()<CR>", { desc = "Open File Explorer" })

vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)

vim.keymap.set("n", "<leader>ab", function() vim.api.nvim_put({ "```", "", "```" }, "l", true, true) vim.api.nvim_feedkeys("k", "n", true) end, { desc = "Insert markdown code block" })

-- yank / paste 
vim.api.nvim_set_keymap('v', 'g#', '"+y', opts) 
vim.api.nvim_set_keymap('n', 'gp', '"+p', opts) 
vim.api.nvim_set_keymap('n', '<C-q>', ':wq!<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fm', ':FzfLua marks<CR>', opts)
vim.keymap.set('n', '<leader>l', '<cmd>edit<CR>', { desc = 'Reload current file' })

vim.keymap.set("n", "<leader>t", ":lua require('todo').toggle()<CR>", { desc = "Toggle fold" })
vim.keymap.set("n", "<leader>T", ":e ~/.config/nvim/todos.md<CR>", { desc = "Toggle fold" })
vim.keymap.set('n', '<leader>dm', function()
    vim.cmd('delmarks a-zA-Z0-9')
    vim.notify('All marks cleared', vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Delete all marks" })

