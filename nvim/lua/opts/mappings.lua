local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>pv', ':lua MiniFiles.open()<CR>', opts)

-- Toggle between the latest buffers
vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)

-- yank / paste 
vim.api.nvim_set_keymap('v', 'g#', '"+y', opts) 
vim.api.nvim_set_keymap('n', 'gp', '"+p', opts) 
vim.api.nvim_set_keymap('n', '<C-q>', ':wq!<CR>', opts)
