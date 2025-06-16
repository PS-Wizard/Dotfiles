return {
    {
        "ibhagwan/fzf-lua",
        config = function()
            require('fzf-lua').setup({
                "telescope",
                winopts = { 
                    fullscreen = true,
                },
                -- grep = {
                --     -- rg_opts = table.concat({
                --     --     "--color=never",
                --     --     "--no-heading",
                --     --     "--with-filename",
                --     --     "--line-number",
                --     --     "--column",
                --     --     "--smart-case",
                --     --     "--ignore-file=" .. vim.fn.expand("~/.config/nvim/lua/opts/fzf_ignore")
                --     -- }, " ")
                -- },
                -- files = {
                --     fd_opts = [[--color=never --type f --hidden --follow --exclude .git --ignore-file ]]
                --     .. vim.fn.expand("$HOME/.config/nvim/lua/opts/fzf_ignore"),
                -- },
            })
            local opts = { noremap = true, silent = true }  -- define opts

            vim.api.nvim_set_keymap('n', '<leader>ff', ':FzfLua files<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>fc', ':FzfLua lgrep_curbuf<CR>', opts)
            -- changed the duplicate <leader>fc to <leader>fg for live_grep to avoid collision
            vim.api.nvim_set_keymap('n', '<leader>fg', ':FzfLua live_grep<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>fd', ':FzfLua lsp_document_diagnostics<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>fs', ':FzfLua lsp_document_symbols<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>o', ':FzfLua buffers<CR>', opts)

        end
    },
}
