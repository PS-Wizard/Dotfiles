return {
    'neovim/nvim-lspconfig',
    -- event = 'BufRead *.py,*.go,*.c ',  -- This ensures the plugin loads only when LSP attaches
        ft = {"go","c"},
    config = function()
        local signs = {
            Error = "E",
            Warning = "W",
            Hint = "H",
            Information = "I"
        }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
        local on_attach = function(client)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
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
        })

        -- lspconfig.jedi_language_server.setup({
        --     on_attach = on_attach,         
        --     capabilities = capabilities,    
        -- })

        -- lspconfig.ccls.setup({
        --     on_attach = on_attach,         
        --     capabilities = capabilities,    
        -- })
    end,
}

