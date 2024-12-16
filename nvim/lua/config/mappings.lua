local opts = { noremap = true, silent = true }

-- Navigate Quickfix list
vim.api.nvim_set_keymap('n', '<A-k>', ':cnext<CR>', opts) -- Alt+l to go down
vim.api.nvim_set_keymap('n', '<A-j>', ':cprev<CR>', opts) -- Alt+h to go up

-- Add current line to Quickfix list
vim.api.nvim_set_keymap(
  'n',
  '<leader>a',
  ':lua vim.fn.setqflist({{filename = vim.fn.expand("%"), lnum = vim.fn.line("."), col = vim.fn.col("."), text = vim.fn.getline(vim.fn.line("."))}}, "a")<CR>',
  opts
)

-- Clear Quickfix list
vim.api.nvim_set_keymap('n', '<leader>cc', ':lua vim.fn.setqflist({})<CR>', opts) -- Clear Quickfix list

-- Toggle between the latest buffers
vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)

-- Insert a code block template
vim.api.nvim_set_keymap('n', '<leader>ab', 'i```<CR>~<CR><CR>```<Esc>O', opts)


-- Insert a math inline-block template
vim.api.nvim_set_keymap('n', '<leader>am', 'i$$<Esc>i', opts)

