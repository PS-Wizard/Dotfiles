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
            signature = {
                enabled=true,
            },
            completion = {
                documentation = {
                    
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    window = {
                        border = 'rounded',
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
                    },
                },
                menu = {
                    border = "rounded",
                    draw = { gap = 2 },
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
                },
            },
        }
    },

    {
        "neovim/nvim-lspconfig",
        -- ft = "go,rust,md,typescript,typescriptreact,javascriptreact,javascript",
        config = function()

            vim.diagnostic.config({
                virtual_text = { prefix = '<- ' },
                float = { border = 'rounded' },
            })
            local on_attach = function(client)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
                vim.keymap.set('n', '<leader>zz', vim.lsp.buf.format, {})
                vim.keymap.set('n', '[d', vim.diagnostic.goto_next, {})
                vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, {})
                vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, {})
            end

            local lspconfig = require("lspconfig")
            local blink_cmp = require('blink.cmp')
            local capabilities = blink_cmp.get_lsp_capabilities()

            lspconfig.gopls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = {"go"},
            })

            lspconfig.rust_analyzer.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = {"rust"},
            })

            lspconfig.ts_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            })

        end,
    }
}
