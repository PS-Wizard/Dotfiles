return {
    {
        'stevearc/quicker.nvim',
        ft = "qf",
        ---@module "quicker"
        ---@type quicker.SetupOptions
        config = function()

            require('quicker').setup{
                opts = {
                    -- number = true,
                    relativenumber = true,
                },
            }

            vim.keymap.set("n", "<leader>q", function() 
                require("quicker").toggle()
                -- Focus on quickfix window after opening
                vim.cmd("wincmd j")  -- Move down to quickfix (it usually opens at bottom)
            end, { desc = "Toggle quickfix"})
        end,
    },
    {
        'vimpostor/vim-tpipeline',
        config = function()
        end,
    },
    {

        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
            "TmuxNavigatorProcessList",
        },
        keys = {
            { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                dim_inactive_windows = false,
                extend_background_behind_borders = true,

                enable = {
                    terminal = true,
                    migrations = true, -- Handle deprecated options automatically
                },

                styles = {
                    bold = true,
                    italic = true,
                    transparency = false,
                },

                groups = {
                    border = "muted",
                    link = "iris",
                    panel = "surface",

                    error = "love",
                    hint = "iris",
                    info = "foam",
                    note = "pine",
                    todo = "rose",
                    warn = "gold",

                    git_add = "foam",
                    git_change = "rose",
                    git_delete = "love",
                    git_dirty = "rose",
                    git_ignore = "muted",
                    git_merge = "iris",
                    git_rename = "pine",
                    git_stage = "iris",
                    git_text = "rose",
                    git_untracked = "subtle",

                    h1 = "iris",
                    h2 = "foam",
                    h3 = "rose",
                    h4 = "gold",
                    h5 = "pine",
                    h6 = "foam",
                },

                palette = {
                    -- Override the builtin palette per variant
                    -- moon = {
                        --     base = '#18191a',
                        --     overlay = '#363738',
                        -- },
                    },
                })

                vim.cmd("colorscheme rose-pine")
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
            anti_conceal = {
                enabled = false,
            },
            heading = {
                sign = false,
                position = 'inline',
                left_margin = 0,   -- centers it
                border = true,
                border_virtual = true,
                border_prefix = false,
                above = '-',
                below = '-',
                icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
            },
            code = {
                sign = false,
                width = 'block',
                left_margin = 0,
                left_pad = 0,
                right_pad = 0,
                border = 'thin',
                above = '▄',
                below = '▀',
            },
        },
    },

}
