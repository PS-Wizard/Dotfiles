return {

    {
        "saghen/blink.cmp",
        version = "*",
        opts = {
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
        }
    },

    {
        "neovim/nvim-lspconfig",
        ft = "go,templ",
        config = function()
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
                filetypes = {"go"},
            })

            lspconfig.templ.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                handlers = handlers,
            })
        end,
    }

}
