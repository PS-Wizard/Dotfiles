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
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
            heading = {
                sign = false,
                position = 'inline',
                width = 'block',
                left_margin = 0.5,   -- centers it
                left_pad = 1,
                right_pad = 2,
                border = true,
                border_virtual = true,
                border_prefix = false,
                above = '─',
                below = '─',
                icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
            },
            code = {
                sign = false,
                width = 'block',
                left_margin = 2,
                left_pad = 1,
                right_pad = 2,
                border = 'thin',
                above = '▄',
                below = '▀',
                highlight = 'RenderMarkdownCode',
                highlight_border = 'RenderMarkdownCodeBorder',
                highlight_inline = 'RenderMarkdownCodeInline',
            },
        },
        config = function(_, opts)
            require('render-markdown').setup(opts)

            vim.schedule(function()
                -- Headings: dark bg, readable fg
                local shades = {
                    '#c8e6c4', '#b8d6b4', '#a8c6a4',
                    '#98b694', '#88a684', '#789674',
                }
                for i = 1, 6 do
                    vim.api.nvim_set_hl(0, 'RenderMarkdownH' .. i,
                    { fg = shades[i], bold = true })
                    vim.api.nvim_set_hl(0, 'RenderMarkdownH' .. i .. 'Bg',
                    { fg = shades[i], bg = '#1e3320' })
                end

                -- Multi-line code block: dark olive bg, colored border
                vim.api.nvim_set_hl(0, 'RenderMarkdownCode',
                { bg = '#161d12' })
                vim.api.nvim_set_hl(0, 'RenderMarkdownCodeBorder',
                { fg = '#4a6741', bg = '#161d12' })

                -- Inline code: slightly lighter, distinct
                vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInline',
                { fg = '#91ba88', bg = '#243320' })
            end)
        end,
    },

}
