-- Basic Neovim settings
vim.g.mapleader = ' '
vim.o.wrap = true
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
vim.wo.cursorline = false
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.linebreak = true
vim.opt.list = false
vim.opt.hlsearch = true
vim.keymap.set('n', '<C-c>', '<cmd>nohlsearch<CR>')
vim.opt.inccommand = 'split'
vim.opt.cmdheight = 0
vim.opt.scrolloff = 10
vim.o.winborder = 'rounded'

vim.cmd([[highlight ColorColumn ctermbg=0 guibg=#3c3c3c]])

vim.o.autoread = true

vim.api.nvim_create_autocmd("FocusGained", {
    desc = "Reload files from disk when we focus vim",
    pattern = "*",
    command = "if getcmdwintype() == '' | checktime | endif",
    group = aug,
})
vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Every time we enter an unmodified buffer, check if it changed on disk",
    pattern = "*",
    command = "if &buftype == '' && !&modified && expand('%') != '' | exec 'checktime ' . expand('<abuf>') | endif",
    group = aug,
})


vim.api.nvim_create_autocmd("BufEnter", { pattern = "*.svelte", callback = function() vim.cmd("set syntax=html") end })
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("DisableSemanticTokens", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities and client.server_capabilities.semanticTokensProvider then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
})


