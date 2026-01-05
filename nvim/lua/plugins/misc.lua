return {
    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            -- suggested keymap
            { "<leader>gp", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },

        },
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

    }
}
