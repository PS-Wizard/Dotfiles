return {
    'saghen/blink.cmp',
    -- dependencies = 'rafamadriz/friendly-snippets', 
    lazy = false,
    version = 'v0.5.1',
    opts = {
        keymap = {
            preset = 'super-tab',
            ['<C-k>'] = { 'select_prev', 'fallback' },
            ['<C-j>'] = { 'select_next', 'fallback' },
        },
        nerd_font_variant = 'mono',
        sources = {
            completion = {
                enabled_providers = { 'lsp', 'path', 'snippets', 'buffer' },
            },
        },
        -- trigger = { signature_help = { enabled = true } } //  Still kinda buggy 
    }
}
