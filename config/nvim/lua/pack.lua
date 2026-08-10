-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "Saghen/blink.cmp",
        dependencies = { "Saghen/blink.lib" },
        build = function()
            require("blink.cmp").build():pwait()
        end,
        config = function()
            require("blink.cmp").setup({
                keymap = {
                    preset = "super-tab",
                    ["<C-k>"] = { "select_prev", "fallback" },
                    ["<C-j>"] = { "select_next", "fallback" },
                    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                },
                snippets = {
                    preset = "default",
                },
                sources = {
                    default = { "snippets", "lsp", "path", "buffer" },
                    providers = {
                        snippets = {
                            opts = {
                                search_paths = { vim.fn.stdpath("config") .. "/snippets" },
                                friendly_snippets = false,
                            },
                        },
                    },
                },
                cmdline = {
                    keymap = { preset = "inherit" },
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
                            border = "rounded",
                            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
                        },
                    },
                    menu = {
                        border = "rounded",
                        draw = { gap = 2 },
                        winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
                    },
                },
            })
        end,
    },
    {
        "ibhagwan/fzf-lua",
        lazy = false,
        opts = {
            defaults = {
                prompt = "> ",
                file_icons = false,
                git_icons = false,
                color_icons = false,
            },
            diagnostics = { diag_icons = false },
            lsp = { symbols = { symbol_style = 3 } },
            winopts = {
                fullscreen = true,
                border = "none",
                preview = { border = "none" },
            },
            keymap = {
                fzf = {
                    ["ctrl-c"] = "abort",
                    ["ctrl-space"] = "toggle",
                    ["ctrl-j"] = "down",
                    ["ctrl-k"] = "up",
                    ["ctrl-d"] = "half-page-down",
                    ["ctrl-u"] = "half-page-up",
                },
            },
        },
    },
    "neovim/nvim-lspconfig",
    "echasnovski/mini.nvim",
    "vimpostor/vim-tpipeline",
})

-- Configure mini.files as the file explorer.
require("mini.files").setup({
    content = { prefix = function() end },
    mappings = {
        go_in = "<CR>",
        go_in_plus = "l",
        go_out = "h",
    },
})

-- Configure jump motions.
require("mini.jump").setup({})

-- Configure indent guides without animation.
local no_indentscope_animation = require("mini.indentscope").gen_animation.none()
require("mini.indentscope").setup({
    mappings = {
        goto_top = "<leader>k",
        goto_bottom = "<leader>j",
    },
    options = {
        border = "both",
        indent_at_cursor = true,
        try_as_border = true,
    },
    draw = {
        delay = 0,
        animation = no_indentscope_animation,
    },
    symbol = "|",
})

-- Configure editing helpers.
require("mini.surround").setup()
require("mini.ai").setup()
require("mini.pairs").setup()
require("mini.splitjoin").setup({
    mappings = {
        toggle = "ms",
    },
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Avoid auto-pairing apostrophes in rust",
    group = vim.api.nvim_create_augroup("MiniPairsRustQuote", { clear = true }),
    pattern = "rust",
    callback = function()
        vim.keymap.set("i", "'", "'", { buffer = true })
    end,
})


-- Configure local pi bridge.
require("pi").setup()
