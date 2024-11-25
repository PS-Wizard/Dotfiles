require("mini.deps").setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- LSP 
later(function()
    add({ source = "neovim/nvim-lspconfig" })
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

    local _border = "single"
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = _border
    })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = _border
    })
    vim.diagnostic.config {
        float = { border = "rounded"}
    }
    local on_attach = function(client)
        vim.opt.omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
        vim.keymap.set('n', '<leader>zz', vim.lsp.buf.format, {})
        vim.keymap.set('n', '[d', vim.diagnostic.goto_next, {})
        vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, {})
    end

    local lspconfig = require("lspconfig")
    lspconfig.gopls.setup({
        on_attach = on_attach,
        -- capabilities = capabilities,
    })

    lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        -- capabilities = capabilities,
    })

    lspconfig.templ.setup({
        on_attach = on_attach,
        -- capabilities = capabilities,
    })

    lspconfig.jedi_language_server.setup({
        on_attach = on_attach,         -- Assuming you have this function defined
        -- capabilities = capabilities,    -- Assuming you have capabilities configured (optional)
    })

    lspconfig.ts_ls.setup({
        on_attach = on_attach,
        hostInfo = "neovim",
        -- capabilities = capabilities,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        cmd = { "typescript-language-server", "--stdio" }
    })
end)

later(function() 
    require("mini.completion").setup({
        delay = { completion = 100, info = 100, signature = 50 },
        window = {
            info = { height = 25, width = 80, border = 'single' },
            signature = { height = 25, width = 80, border = 'single' },
        },
        lsp_completion = {
            source_func = 'omnifunc',
            auto_setup = false,
        },
        fallback_action = '<C-x><C-n>',
        mappings = {
            force_twostep = '<C-Space>', -- Force two-step completion
            force_fallback = '<A-Space>', -- Force fallback completion
        },
        set_vim_settings = false,
        silent = true
    })
end)

later(function()
    add({ source = "leath-dub/snipe.nvim" })
    local snipe = require("snipe")
    snipe.setup({
        ui = {
            max_height = -1, -- Dynamic height
            position = "topright", -- Adjust to your preference
            open_win_override = {
                title = "69 lol",
                border = "single", -- Styled border
            },
            preselect_current = true,
            text_align = "left",
        },
        hints = {

            dictionary = "qsadflewcmpghio",
        },
        navigate = {
            next_page = "J",
            prev_page = "K",
            under_cursor = "<cr>",
            cancel_snipe = "<esc>",
            close_buffer = "D",
            open_vsplit = "V",
            open_split = "H",
            change_tag = "C",
        },
        sort = "default", -- Sorting order
    })
    snipe.ui_select_menu = require("snipe.menu"):new { position = "center" }
    snipe.ui_select_menu:add_new_buffer_callback(function (m)
        vim.keymap.set("n", "<esc>", function ()
            m:close()
        end, { nowait = true, buffer = m.buf })
    end)
    vim.ui.select = snipe.ui_select;
    vim.keymap.set("n", "<C-e>", snipe.open_buffer_menu, { desc = "Open Snipe Buffer Menu" })
end)



