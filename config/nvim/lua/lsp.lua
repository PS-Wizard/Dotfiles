vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = { current_line = true },
})

local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
local maximum_lsp_line_count = 1000

vim.api.nvim_set_hl(0, "TodoFloatNormal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "TodoFloatBorder", { bg = "NONE", fg = "#555555" })
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", config or {}, {
        border = "double",
    })

    local buffer_number, window_number = vim.lsp.handlers.hover(err, result, ctx, config)
    if window_number and vim.api.nvim_win_is_valid(window_number) then
        vim.wo[window_number].winhighlight = "Normal:TodoFloatNormal,NormalFloat:TodoFloatNormal,FloatBorder:TodoFloatBorder"
    end

    return buffer_number, window_number
end

-- Return whether a buffer should have LSP disabled for size reasons.
local function is_buffer_too_big(buffer_number)
    return vim.api.nvim_buf_line_count(buffer_number) > maximum_lsp_line_count
end

-- Open quickfix after diagnostic navigation when entries exist.
local function open_quickfix_if_diagnostics_exist()
    if type(_G.open_quickfix_if_diagnostics_exist) == "function" then
        _G.open_quickfix_if_diagnostics_exist()
    end
end

-- Apply buffer-local LSP keymaps.
local function set_lsp_keymaps(buffer_number)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buffer_number })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buffer_number })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buffer_number })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = buffer_number })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buffer_number })
    vim.keymap.set("n", "<leader>zz", vim.lsp.buf.format, { buffer = buffer_number })
    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { buffer = buffer_number })
    vim.keymap.set("n", "[d", function()
        vim.diagnostic.goto_prev()
        open_quickfix_if_diagnostics_exist()
    end, { buffer = buffer_number })
    vim.keymap.set("n", "]d", function()
        vim.diagnostic.goto_next()
        open_quickfix_if_diagnostics_exist()
    end, { buffer = buffer_number })
    vim.keymap.set("n", "<leader>hh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buffer_number })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = buffer_number })
    end, { buffer = buffer_number, desc = "Toggle inlay hints" })
    vim.keymap.set("n", "<leader>hd", function()
        if vim.diagnostic.is_enabled() then
            vim.diagnostic.enable(false)
            vim.notify("Diagnostics Disabled")
        else
            vim.diagnostic.enable(true)
            vim.notify("Diagnostics Enabled")
        end
    end, { buffer = buffer_number, desc = "Toggle diagnostics" })
end

-- Configure LSP servers with native Neovim APIs.
vim.lsp.config("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.mod", "go.work", ".git" },
    capabilities = blink_capabilities,
    settings = {
        gopls = {
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
    },
})

vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    capabilities = blink_capabilities,
})

vim.lsp.config("marksman", {
    cmd = { "marksman" },
    filetypes = { "markdown" },
    capabilities = blink_capabilities,
})

vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    root_markers = { "vite.config.ts", "vite.config.js", "package.json", "tsconfig.json", "jsconfig.json", ".git" },
    capabilities = blink_capabilities,
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
        },
    },
})

vim.lsp.config("svelte", {
    cmd = { "bunx", "svelteserver", "--stdio" },
    filetypes = { "svelte" },
    root_markers = { "package.json", "svelte.config.js", ".git" },
    capabilities = blink_capabilities,
})

vim.lsp.enable({ "gopls", "rust_analyzer", "marksman", "ts_ls", "svelte" })

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Set LSP keymaps and disable LSP for large buffers",
    group = vim.api.nvim_create_augroup("UserConfigLspAttach", { clear = true }),
    callback = function(args)
        local buffer_number = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end

        set_lsp_keymaps(buffer_number)

        if is_buffer_too_big(buffer_number) then
            vim.defer_fn(function()
                vim.lsp.buf_detach_client(buffer_number, client.id)
                vim.notify(
                    "LSP disabled for large file (>" .. maximum_lsp_line_count .. " lines)",
                    vim.log.levels.WARN
                )
            end, 10)
        end
    end,
})
