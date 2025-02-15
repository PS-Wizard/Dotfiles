local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<leader>ff', ':Pick files<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fc', ':Pick grep_live<CR>', opts)

-- Toggle between the latest buffers
vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)

-- yank / paste 
vim.api.nvim_set_keymap('v', 'gy', '"+y', opts) -- Yank to system clipboard  
vim.api.nvim_set_keymap('n', 'gp', '"+p', opts) -- Paste from system clipboard  

-- Insert a code block template
vim.api.nvim_set_keymap('n', '<leader>ab', 'i```<CR>~<CR><CR>```<Esc>O', opts)
