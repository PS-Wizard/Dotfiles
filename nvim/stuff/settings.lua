vim.o.completeopt = 'menuone,noinsert'
vim.o.scrolloff = 10
vim.o.swapfile = false
vim.o.guifont = "JetBrains Mono:h18"
vim.opt.laststatus = 3
vim.g.mapleader = " "
vim.o.termguicolors = true
vim.o.smartcase = false
vim.o.ignorecase = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.wrap = true
vim.wo.signcolumn = 'yes'
vim.wo.cursorline = false
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.linebreak = true
vim.o.undofile = false
vim.opt.list = false
vim.opt.hlsearch = false

-- Map Ctrl+k and Ctrl+j to the up and down arrow keys
vim.keymap.set('i', '<M-j>', '<Down>', { noremap = true })
vim.keymap.set('i', '<M-k>', '<Up>', { noremap = true })
-- Use Tab to confirm selection
vim.keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-y>" : "\<Tab>"]], { expr = true })

