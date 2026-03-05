return {
    {
        "ibhagwan/fzf-lua",
        config = function()
            local actions = require('fzf-lua.actions')
            
            require('fzf-lua').setup({
                "ivy",
                winopts = { 
                    fullscreen = true,
                    border = 'rounded',
                    winblend = 0,
                },
                keymap = {
                    builtin = {
                        ["<C-h>"] = "toggle-preview",
                        ["<C-j>"] = "down",
                        ["<C-k>"] = "up",
                        ["<C-d>"] = "preview-page-down",
                        ["<C-u>"] = "preview-page-up",
                    },
                    fzf = {
                        ["ctrl-space"] = "toggle",
                        ["ctrl-a"] = "select-all",  -- Select all first
                    },
                },
                actions = {
                    files = {
                        ["default"] = actions.file_edit_or_qf,
                        ["ctrl-q"] = actions.file_sel_to_qf,
                    },
                },
                fzf_colors = {
                    true,
                    ["bg"]          = { "bg", "Normal" },
                    ["gutter"]      = "-1",
                    ["bg+"]         = { "bg", "Normal" },
                    ["preview-bg"]  = { "bg", "Normal" },
                },
                oncreate = function()
                    vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
                    vim.keymap.set("t", "<C-k>", "<Up>", { silent = true, buffer = true })
                    vim.keymap.set("t", "<C-Space>", "<C-Space>", { silent = true, buffer = true })
                end,
            })
            
            local opts = { noremap = true, silent = true }
            vim.keymap.set('n', '<leader>ff', ':FzfLua files<CR>', opts)
            vim.keymap.set('n', '<leader>gb', ':FzfLua git_branches<CR>', opts)
            vim.keymap.set('n', '<leader>fc', ':FzfLua lgrep_curbuf<CR>', opts)
            vim.keymap.set('n', '<leader>fg', ':FzfLua live_grep<CR>', opts)
            vim.keymap.set('n', '<leader>fd', ':FzfLua lsp_document_diagnostics<CR>', opts)
            vim.keymap.set('n', '<leader>s', ':FzfLua lsp_document_symbols<CR>', opts)
            vim.keymap.set('n', '<leader>o', ':FzfLua buffers<CR>', opts)
            vim.keymap.set('n', '<leader>gc', ':FzfLua git_commits<CR>', opts)
        end
    },
}
