return {
    -- Mini Comment is built in now
    { 
        'echasnovski/mini.basics',
        version = '*',
        opts = {
            mappings = {
                windows = true,
            },
        },
    },

    { 
        'echasnovski/mini.surround',
        version = '*',
        opts = {},
    },
    { 
        'echasnovski/mini.pairs',
        version = '*',
        opts = {},
    },
    { 
        'echasnovski/mini.ai',
        version = '*',
        opts = {},
    },
    { 
        'echasnovski/mini.pick',
        version = '*',
        keys = {
            { "<leader>ff", "<cmd>Pick files<cr>", desc = "Pick files" },
            { "<leader>fc", "<cmd>Pick grep_live<cr>", desc = "Pick live grep" },
        },
        opts = {
            silent=true,
            mappings = {
                move_down = '<M-j>',
                move_up = '<M-k>',
                move_start = '<M-g>',
                caret_left = '<M-h>',
                caret_right = '<M-l>',
                caret_left = '<M-h>',
            }
        }
    },
    { 
        'echasnovski/mini.files',
        version = '*',
        keys = {
            { "<leader>pv", "<cmd>lua MiniFiles.open()<CR>", desc = "Open Window" },
        },
        opts = {},
    },
    { 
        'echasnovski/mini-git',
        version = '*',
        keys = {
            { "<leader>ga", "<cmd>Git add .<CR>", desc = "Git add Everything" },
            { "<leader>gc", "<cmd>Git commit<CR>",desc = "Git Commit" },
            { "<leader>gs", "<cmd>Git status<CR>", desc = "Show git status" },
            { "<leader>gp", "<cmd>Git push<CR>", desc = "Git Push"},
        },
        config = function()
            require('mini.git').setup() -- This explicitly requires calling it like this.
        end,
    },
    { 
        'echasnovski/mini.indentscope',
        version = '*',
        config = function()
            require('mini.indentscope').setup({
                mappings = {
                    goto_top = "gt",
                    goto_bottom= "gb",
                },
                options = {
                    try_as_border = true,
                },
            })
        end,
    },
    { 
        'echasnovski/mini.move',
        version = '*',
        opts = {
            mappings = {
                -- Visual Mode
                right = '<M-l>',
                down = '<M-j>',
                up = '<M-k>',
                left = '<M-h>',

                -- Normal Mode
                line_left = '<M-h>',
                line_right = '<M-l>',
                line_down = '<M-j>',
                line_up = '<M-k>',
            }
        }
    },
    {
        'echasnovski/mini.splitjoin',
        version = '*',
        opts = {
            mappings = {
                toggle = 'ms',
            }
        }
    }
}
