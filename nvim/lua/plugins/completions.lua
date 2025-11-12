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
            cmdline = {
                keymap = { preset = 'inherit' },
                completion = { menu = { auto_show = true } },
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
                        winhighlight = "Normal:Normal,CursorLine:BlinkCmpDocCursorLine,Search:None",
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
        config = function()
            vim.diagnostic.config({ 
                virtual_text = false, 
                virtual_lines = { current_line = true }, 
            })

            local on_attach = function(client, bufnr)
                -- keymaps
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr })
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
                vim.keymap.set('n', '<leader>zz', vim.lsp.buf.format, { buffer = bufnr })
                vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { buffer = bufnr })

                if client.supports_method("textDocument/inlayHint") then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end

                -- Optional: Toggle with <leader>hi
                vim.keymap.set('n', '<leader>h', function()
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
                end, { buffer = bufnr, desc = "Toggle inlay hints" })

                -- helper for quickfix diagnostics
                local function open_qflist_if_diagnostics()
                    vim.diagnostic.setqflist()
                    local qflist = vim.fn.getqflist()
                    if #qflist > 0 then
                        vim.cmd("copen")
                    end
                end

                -- navigation with quickfix updates
                vim.keymap.set('n', '[d', function()
                    vim.diagnostic.goto_prev()
                    open_qflist_if_diagnostics()
                end, { buffer = bufnr })

                vim.keymap.set('n', ']d', function()
                    vim.diagnostic.goto_next()
                    open_qflist_if_diagnostics()
                end, { buffer = bufnr })
            end

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
                        end, 10)
                    end
                end,
            })

            -- Get capabilities from blink.cmp if available
            local capabilities = vim.tbl_deep_extend(
                'force',
                vim.lsp.protocol.make_client_capabilities(),
                require('blink.cmp').get_lsp_capabilities() or {}
            )

            -- Setup LSP servers using vim.lsp.config
            vim.lsp.config('gopls', {
                cmd = { 'gopls' },
                filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
                root_markers = { 'go.mod', 'go.work', '.git' },
                capabilities = capabilities,
            })

            vim.lsp.config('rust_analyzer', {
                cmd = { 'rust-analyzer' },
                filetypes = { 'rust' },
                root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
                capabilities = capabilities,
            })

            vim.lsp.config('tinymist', {
                cmd = { 'tinymist' },
                filetypes = { 'typst' },
                capabilities = capabilities,
                settings = {
                    formatterMode = "typstyle",
                    exportPdf = "none",
                    semanticTokens = "disable"

                }
            })

            vim.lsp.config('ts_ls', {
                cmd = { 'bunx', 'typescript-language-server', '--stdio' },
                filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
                root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
                capabilities = capabilities,
                settings = {
                    maxTsServerMemory = 2048
                },
            })

            vim.lsp.config('svelte', {
                cmd = { 'bunx', 'svelteserver', '--stdio' },
                filetypes = { 'svelte' },
                root_markers = { 'package.json', 'svelte.config.js', '.git' },
                capabilities = capabilities,
            })

            vim.lsp.enable({ 'gopls', 'rust_analyzer', 'ts_ls', 'svelte', 'tinymist' })

            -- Set up LspAttach autocommand for keybindings
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client then
                        on_attach(client, args.buf)
                    end
                end,
            })
        end,
    }
}
