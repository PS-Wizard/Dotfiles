local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fc', ':Telescope live_grep <CR>', opts)

vim.api.nvim_set_keymap('n', '<leader>pv', ':lua MiniFiles.open()<CR>', opts)

-- Toggle between the latest buffers
vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)

-- yank / paste 
vim.api.nvim_set_keymap('v', 'gy', '"+y', opts) -- Yank to system clipboard  
vim.api.nvim_set_keymap('n', 'gp', '"+p', opts) -- Paste from system clipboard  

vim.api.nvim_set_keymap('n', '<leader>ab', 'i```<CR>~<CR><CR>```<Esc>O', opts)
-- Quickfix navigation with wrapping
vim.api.nvim_set_keymap('n', '<A-l>', ':lua if vim.fn.getqflist({idx=0}).idx == #vim.fn.getqflist() then vim.cmd("cfirst") else vim.cmd("cnext") end<CR>zz', opts)
vim.api.nvim_set_keymap('n', '<A-h>', ':lua if vim.fn.getqflist({idx=0}).idx == 1 then vim.cmd("clast") else vim.cmd("cprev") end<CR>zz', opts)

-- Text formatting mappings
vim.api.nvim_set_keymap('n', '<leader>mb', 'i****<Esc>hi', opts)  -- Make bold
vim.api.nvim_set_keymap('n', '<leader>mi', 'i**<Esc>i', opts)   -- Make italic
vim.api.nvim_set_keymap('n', '<leader>mI', 'i++++<Esc>hi', opts)  -- Make insert
vim.api.nvim_set_keymap('n', '<leader>mn', 'i***++++***<Esc>3hi', opts)  -- Make bold+italic+insert


