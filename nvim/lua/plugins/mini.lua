return {
    {
        'echasnovski/mini.files',
        version = false,
        opts = function()
            require('mini.files').setup({
                content = { prefix = function() end }
            })
        end,
    },

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
        "echasnovski/mini.basics",
        version = false,
        opts = {
            options = {
                basic = true,
                win_borders = 'single'
            },
            mappings = {
                basic = true,
                windows = true,
            },
            autocommands = {
                basic = true,
                relnum_in_visual_mode = false,
            },
        }
    },

    {
        "echasnovski/mini.indentscope",
        version = false,
        config = function()
            local noAnimation = require("mini.indentscope").gen_animation.none()
            require("mini.indentscope").setup({
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
                draw = {
                    delay = 0,
                    animation = noAnimation
                },
                symbol = '|',
            })
        end
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
        opts = function()
            require("mini.pairs").setup()

            -- Just override the insert `'` key in rust files
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "rust",
                callback = function()
                    vim.keymap.set("i", "'", "'", { buffer = 0 })
                end,
            })
        end,
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
