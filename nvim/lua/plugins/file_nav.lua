return {
    {
        "ibhagwan/fzf-lua",
        config = function()
            require('fzf-lua').setup({
                "telescope",
                winopts = { 
                    fullscreen = true,
                    border = 'rounded',
                    winblend = 0,
                },
                keymap = {
                    builtin = {
                        ["<C-h>"] = "toggle-preview",
                    },
                },
                fzf_colors = {
                    true, -- auto generate rest of fzf’s highlights?
                    bg = '-1',
                    gutter = '-1', -- I like this one too, try with and without
                }

            })
            local opts = { noremap = true, silent = true }  -- define opts

            vim.api.nvim_set_keymap('n', '<leader>ff', ':FzfLua files<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>gb', ':FzfLua git_branches<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>fc', ':FzfLua lgrep_curbuf<CR>', opts)
            -- changed the duplicate <leader>fc to <leader>fg for live_grep to avoid collision
            vim.api.nvim_set_keymap('n', '<leader>fg', ':FzfLua live_grep<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>fd', ':FzfLua lsp_document_diagnostics<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>s', ':FzfLua lsp_document_symbols<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>o', ':FzfLua buffers<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>gc', ':FzfLua git_commits<CR>', opts)

        end
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "<leader><leader>", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
    },
}
