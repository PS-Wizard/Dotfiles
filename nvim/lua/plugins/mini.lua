return {
    {
        "echasnovski/mini.move",
        version = false,
        opts = {
            silent = true,
            mappings = {
                right = '<C-l>',
                down = '<C-j>',
                left = '<C-h>',
                up = '<C-k>',
                -- Normal Mode
                line_right = '',
                line_down = '',
                line_left = '',
                line_up = '',
            }
        }
    },

    {
        "echasnovski/mini.indentscope",
        version = false,
        opts = {
            silent = true,
            mappings = {
                goto_top = '<leader>k',
                goto_bottom = '<leader>j',
            },
            options = {
                border='both',
                indent_at_cursor = true,
                try_as_border = true,
            },
        }
    },

    {
        "echasnovski/mini.basics",
        version = false,
        opts = {
            options = {
                basic = true,
            },
            mappings = {
                basic = true,
                windows = false,
            },
            autocommands = {
                basic = true,
                relnum_in_visual_mode = true,
            },
        }
    },

    {
        "echasnovski/mini.surround",
        version = false,
        opts = {}
    },

    {
        "echasnovski/mini.ai",      
        version = false,
        opts = {}
    },

    {
        "echasnovski/mini.pairs",   
        version = false,
        opts = {}
    },

    {
        "echasnovski/mini.files",   
        version = false,
        opts = {}
    },

    {
        "echasnovski/mini.splitjoin",
        version = false,
        opts = {
            mappings = {
                toggle = 'ms'
            }
        }
    },

    {
        "echasnovski/mini.jump",    
        version = false,
        opts = {
            delay = {
                highlight = 20,
            },
            silent = true,
        }
    },

}
