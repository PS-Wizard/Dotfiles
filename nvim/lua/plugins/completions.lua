return {
    {
        "saghen/blink.cmp",
        version = "*",
        opts = {
            keymap = {
                preset = 'super-tab',
                ['<C-k>'] = { 'select_prev', 'fallback' },
                ['<C-j>'] = { 'select_next', 'fallback' },
                ['<C-u>'] = { 'scroll_documentation_up','fallback' },
                ['<C-d>'] = { 'scroll_documentation_down','fallback' },
            },
            sources = {
                default = {
                    'lsp', 'path', 'snippets', 'buffer',
                },
            },
            signature = {
                enabled = true,
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
                    draw = { gap = 2, },
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
                },
            },
        }
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.diagnostic.config({
                virtual_text = { prefix = '<- ' },
                float = { border = 'rounded' },
            })

            local on_attach = function(client, bufnr)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr })
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
                vim.keymap.set('n', '<leader>zz', vim.lsp.buf.format, { buffer = bufnr })
                local function open_loclist_if_diagnostics()
                    vim.diagnostic.setloclist()
                    local loclist = vim.fn.getloclist(0)
                    if #loclist > 0 then
                        vim.cmd("lopen")
                    end
                end

                vim.keymap.set('n', '[d', function()
                    vim.diagnostic.goto_prev()
                    open_loclist_if_diagnostics()
                end, { buffer = bufnr })

                vim.keymap.set('n', ']d', function()
                    vim.diagnostic.goto_next()
                    open_loclist_if_diagnostics()
                end, { buffer = bufnr })
                vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { buffer = bufnr })
            end

            local lspconfig = require("lspconfig")
            local blink_cmp = require('blink.cmp')
            local capabilities = blink_cmp.get_lsp_capabilities()

            -- Define the maximum line count
            local MAX_LSP_LINES = 1000

            -- Function to check if a buffer is "too big"
            local function is_buffer_too_big(bufnr)
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                return line_count > MAX_LSP_LINES
            end

            -- Autocmd to handle large files
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("LspLargeFileHandler", { clear = true }),
                callback = function(args)
                    local bufnr = args.buf
                    local client_id = args.data.client_id
                    local client = vim.lsp.get_client_by_id(client_id)

                    if client and is_buffer_too_big(bufnr) then
                        vim.defer_fn(function()
                            vim.lsp.buf_detach_client(bufnr, client.id)
                            print("Detaching LSP client '" .. client.name .. "' for large buffer: " .. vim.fn.bufname(bufnr))
                            vim.notify("LSP disabled for large file (>" .. MAX_LSP_LINES .. " lines)", vim.log.levels.WARN)
                        end, 10) -- Add a small delay to ensure attachment fully completes before detaching
                    end
                end,
            })

            -- Setup your LSP servers
            lspconfig.gopls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = { "go" },
            })

            lspconfig.rust_analyzer.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = { "rust" },
            })

            lspconfig.ts_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            })

            lspconfig.svelte.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = { "svelte" },
            })

            lspconfig.astro.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                cmd = { "astro-ls", "--stdio" },
                filetypes = { "astro" },
                init_options = {
                    typescript = {
                        tsdk = "/home/wizard/.pnpm/bin/global/5/.pnpm/typescript@5.8.3/node_modules/typescript/lib"
                    }
                }
            })

        end,
    }
}
