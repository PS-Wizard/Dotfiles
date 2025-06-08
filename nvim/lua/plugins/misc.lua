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
        "mistweaverco/kulala.nvim",
        keys = {
            { "<leader>Rs", desc = "Send request" },
            { "<leader>Ra", desc = "Send all requests" },
        },
        ft = {"http", "rest"},
        opts = {
            -- your configuration comes here
            global_keymaps = true,
        },
    },
}
