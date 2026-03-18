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
                extend_background_behind_borders = false,
                groups = {
                    panel = "base",
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
