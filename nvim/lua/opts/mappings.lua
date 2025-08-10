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
vim.api.nvim_set_keymap('n', '<C-b>', 'i****<esc>2ha', opts)
vim.api.nvim_set_keymap('n', '<C-i>', 'i**<esc>ha', opts)
