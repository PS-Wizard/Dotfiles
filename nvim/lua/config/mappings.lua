local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<A-t>', ':tabnew<CR>', opts)
vim.api.nvim_set_keymap('n', '<A-k>', ':tabn<CR>', opts)
vim.api.nvim_set_keymap('n', '<A-j>', ':tabp<CR>', opts)
vim.api.nvim_set_keymap('n', '<A-q>', ':tabclose<CR>', opts)
-- Toggle between the latest buffers
vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)
-- Insert a code block template
vim.api.nvim_set_keymap('n', '<leader>ab', 'i```<CR>~<CR><CR>```<Esc>O', opts)

