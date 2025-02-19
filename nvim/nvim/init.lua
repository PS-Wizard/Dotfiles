local config_path = vim.fn.stdpath('config') .. '/?.lua'
package.path = config_path .. ';' .. package.path
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.deps'

if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.deps`" | redraw')
    local clone_cmd = {
        'git', 'clone', '--filter=blob:none',
        'https://github.com/echasnovski/mini.deps', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.deps | helptags ALL')
    vim.cmd('echo "Installed `mini.deps`" | redraw')
end

vim.cmd('colorscheme dino')
require('settings.preferences')
require('settings.mappings')
-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

--- Plugins ---

later(function()
    add({ source = 'echasnovski/mini.surround', checkout = 'stable' })
    require('mini.surround').setup()
end)

later(function()
    add({ source = 'echasnovski/mini.pairs', checkout = 'stable' })
    require('mini.pairs').setup()
end)

later(function()
    add({ source = 'echasnovski/mini.ai', checkout = 'stable' })
end)

later(function()
    add({ source = 'echasnovski/mini.files', checkout = 'stable' })
    require('mini.files').setup()
end)

later(function()
    add({ source = 'echasnovski/mini.splitjoin', checkout = 'stable' })
    require('mini.splitjoin').setup({
        mappings = {
            toggle = 'ms' 
        } 
    })
end)

later(function()
    add({ source = 'echasnovski/mini.jump', checkout = 'stable' })
    require('mini.jump').setup({
        delay = {
            highlight = 20,
        },
        silent=true,
    })
end)

later(function()
    add({ source = 'echasnovski/mini.basics', checkout = 'stable' })
    require("mini.basics").setup({
        options = {
            basic = true,
            extra_ui = true,
        },
        mappings = {
            basic = true,
            windows = true,
        },
        autocommands = {
            basic = true,
            relnum_in_visual_mode = true,
        },
    })
end)

later(function()
    add({ source = 'echasnovski/mini.pick', checkout = 'stable' })
    require('mini.pick').setup({
        silent = true,
        mappings = {
            move_down = '<A-j>',
            move_up = '<A-k>',
            caret_left = '<A-h>',
            caret_right = '<A-l>',
        },
    })
end)

later(function()
    add({ source = 'echasnovski/mini.indentscope', checkout = 'stable' })
    require('mini.indentscope').setup({
        silent = true,
        mappings = {
            goto_top = "gt",
            goto_bottom= "gb",
        },
        options = {
            border='both',
            indent_at_cursor = true,
            try_as_border = true,
        },
    })
end)

later(function()
    add({ source = 'echasnovski/mini.move', checkout = 'stable' })
    require('mini.move').setup({
        silent = true,
        mappings = {
            -- Visual Mode
            right = '<A-l>',
            down = '<A-j>',
            left = '<A-h>',
            up = '<A-k>',

            -- Normal Mode
            line_right = '<A-l>',
            line_down = '<A-j>',
            line_left = '<A-h>',
            line_up = '<A-k>',
        }
    })
end)

MiniDeps.add({
    source = 'saghen/blink.cmp',
    checkout = 'v0.11.0', 
})

-- No need to build from source since you're using pre-built binaries
later(function()
    require('blink.cmp').setup({
        keymap = {
            preset = 'super-tab',
            ['<C-k>'] = { 'select_prev', 'fallback' },
            ['<C-j>'] = { 'select_next', 'fallback' },
        },
        sources = {
            default = {
                'lsp', 'path', 'snippets', 'buffer',
            },
        },
    })
end)

later(function()
    add({ source = 'neovim/nvim-lspconfig' })  

    local signs = {
        Error = "E",
        Warning = "W",
        Hint = "H",
        Information = "I"
    }

    local border = {
        { '┌', 'FloatBorder' }, { '─', 'FloatBorder' }, { '┐', 'FloatBorder' },
        { '│', 'FloatBorder' }, { '┘', 'FloatBorder' }, { '─', 'FloatBorder' },
        { '└', 'FloatBorder' }, { '│', 'FloatBorder' }
    }

    local handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
    }

    vim.diagnostic.config({
        virtual_text = { prefix = '<- ' },
        float = { border = border },
    })

    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    local on_attach = function(client)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover({ border = "rounded" })
        end, {})
        vim.keymap.set('n', '<leader>zz', vim.lsp.buf.format, {})
        vim.keymap.set('n', '[d', vim.diagnostic.goto_next, {})
        vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, {})
        vim.keymap.set('n', '<leader>rf', vim.lsp.buf.references, {})
    end

    local lspconfig = require("lspconfig")
    local blink_cmp = require('blink.cmp')
    local capabilities = blink_cmp.get_lsp_capabilities()

    lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        handlers = handlers,
    })

    -- lspconfig.ts_ls.setup({
        --     on_attach = on_attach,
        --     capabilities = capabilities,
        --     cmd = { "typescript-language-server", "--stdio" },
        -- })
    end)
