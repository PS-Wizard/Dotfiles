vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.netrw_banner = 0

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.showmode = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8
vim.opt.inccommand = "split"
vim.opt.completeopt = "menuone,noselect,popup,fuzzy,nosort"
vim.opt.shortmess:append("c")
vim.opt.isfname:append("@-@")
vim.opt.termguicolors = true
vim.opt.cmdheight = 0
vim.opt.winborder = "rounded"
vim.opt.laststatus = 3
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false
vim.opt.colorcolumn = "0"
vim.opt.hlsearch = true
vim.opt.autoread = true

local general_augroup = vim.api.nvim_create_augroup("UserConfigGeneral", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    group = general_augroup,
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.api.nvim_create_autocmd("FocusGained", {
    desc = "Reload files from disk when Neovim regains focus",
    group = general_augroup,
    pattern = "*",
    command = "if getcmdwintype() == '' | checktime | endif",
})

vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Reload unmodified buffers changed on disk",
    group = general_augroup,
    pattern = "*",
    command = "if &buftype == '' && !&modified && expand('%') != '' | exec 'checktime ' . expand('<abuf>') | endif",
})

vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Use html syntax for svelte buffers",
    group = general_augroup,
    pattern = "*.svelte",
    callback = function()
        vim.bo.syntax = "html"
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Disable semantic tokens",
    group = vim.api.nvim_create_augroup("DisableSemanticTokens", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.semanticTokensProvider then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
})
