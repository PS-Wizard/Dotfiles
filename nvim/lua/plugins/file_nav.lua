return {
    {
        "ibhagwan/fzf-lua",
        config = function()
            require('fzf-lua').setup({
                "telescope",
                winopts = { 
                    fullscreen = true,
                },
                grep = {
                    rg_opts = table.concat({
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden",
                        "--glob=!node_modules/*",
                        "--glob=!.git/*",
                        "--glob=!.venv/*",
                        "--glob=!*.mod",
                        "--glob=!*.sum",
                        "--glob=!*.class",
                        "--glob=!*.pdf",
                        "--glob=!tailwindcss",
                        "--glob=!package-lock.json",
                        "--glob=!package.json",
                        "--glob=!lib/*",
                        "--glob=!**/*_templ.go",
                        "--glob=!**/*_templ.txt"
                    }, " ")
                },
                files = {
                    fd_opts = table.concat({
                        "--color=never",
                        "--type f",
                        "--hidden",
                        "--exclude .git",
                        "--exclude node_modules",
                        "--exclude .venv",
                        "--exclude lib",
                        "--exclude tailwindcss",
                        "--exclude package-lock.json",
                        "--exclude package.json",
                        "--exclude **/*_templ.go",
                        "--exclude **/*_templ.txt",
                        "--exclude *.class"
                    }, " ")
                }
            })
            local opts = { noremap = true, silent = true }  -- define opts

            vim.api.nvim_set_keymap('n', '<leader>ff', ':FzfLua files<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>fc', ':FzfLua lgrep_curbuf<CR>', opts)
            -- changed the duplicate <leader>fc to <leader>fg for live_grep to avoid collision
            vim.api.nvim_set_keymap('n', '<leader>fg', ':FzfLua live_grep<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>fd', ':FzfLua lsp_document_diagnostics<CR>', opts)
            vim.api.nvim_set_keymap('n', '<leader>fs', ':FzfLua lsp_document_symbols<CR>', opts)
        end
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")

            -- REQUIRED
            harpoon:setup()
            -- REQUIRED

            vim.keymap.set("n", "<M-a>", function() harpoon:list():add() end)
            vim.keymap.set("n", "<M-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
            vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)
            vim.keymap.set("n", "<leader>6", function() harpoon:list():select(6) end)
            vim.keymap.set("n", "<leader>7", function() harpoon:list():select(7) end)
            vim.keymap.set("n", "<leader>8", function() harpoon:list():select(8) end)
            vim.keymap.set("n", "<leader>9", function() harpoon:list():select(9) end)
            vim.keymap.set("n", "<leader>0", function() harpoon:list():select(0) end)

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<M-j>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<M-k>", function() harpoon:list():next() end)
        end,
    },
}
