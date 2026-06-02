vim.pack.add({
    "https://github.com/Saghen/blink.lib",
    "https://github.com/Saghen/blink.cmp",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/echasnovski/mini.nvim",
    "https://github.com/vimpostor/vim-tpipeline",
    "https://github.com/mistweaverco/kulala.nvim",
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

-- Configure MiniPick and MiniExtra.
require("mini.pick").setup({
    mappings = {
        move_down = "<C-j>",
        move_up = "<C-k>",
        scroll_down = "<C-d>",
        scroll_up = "<C-u>",
        delete_left = "",
    },
    window = {
        config = function()
            local height = math.floor(0.8 * vim.o.lines)
            local width = math.floor(0.8 * vim.o.columns)
            return {
                anchor = "NW",
                height = height,
                width = width,
                row = math.floor(0.1 * vim.o.lines),
                col = math.floor(0.1 * vim.o.columns),
                border = "rounded",
            }
        end,
        prompt_caret = ">",
    },
})
require("mini.extra").setup()

-- Configure Kulala as the in-editor REST client.
require("kulala").setup({
    global_keymaps = false,
    global_keymaps_prefix = "<leader>R",
    kulala_keymaps_prefix = "",
})

-- Build blink's native matcher, then configure completion.
local blink_completion = require("blink.cmp")
blink_completion.build():wait(60000)
blink_completion.setup({
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
