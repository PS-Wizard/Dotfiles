local opts = { noremap = true, silent = true }

-- Toggle between the latest buffers
vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)

-- Mapping for <leader>ab to insert a code block template
vim.api.nvim_set_keymap('n', '<leader>ab', 'i```<CR>~<CR><CR>```<Esc>O', { noremap = true, silent = true })

-- Mapping for <leader>ab to insert a math inline-block template
vim.api.nvim_set_keymap('n', '<leader>am', 'i$$<Esc>i', { noremap = true, silent = true })
