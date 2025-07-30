-- Basic Neovim settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = false
vim.o.swapfile = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.o.termguicolors = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.wo.cursorline = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.linebreak = true
vim.opt.list = false
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.opt.inccommand = 'split'
vim.opt.scrolloff = 10
vim.o.winborder = 'rounded'
vim.cmd([[highlight ColorColumn ctermbg=0 guibg=#3c3c3c]])

vim.api.nvim_create_autocmd("BufEnter", { pattern = "*.svelte", callback = function() vim.cmd("set syntax=html") end })

