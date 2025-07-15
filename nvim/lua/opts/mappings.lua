local opts = { noremap = true, silent = true }
-- Toggle between the latest buffers

vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open oil.nvim file explorer" })
vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)

-- yank / paste 
vim.api.nvim_set_keymap('v', 'g#', '"+y', opts) 
vim.api.nvim_set_keymap('n', 'gp', '"+p', opts) 
vim.api.nvim_set_keymap('n', '<C-q>', ':wq!<CR>', opts)
