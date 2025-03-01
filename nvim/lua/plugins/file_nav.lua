return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local actions  = require('telescope.actions')
            require('telescope').setup({
                defaults = {
                    mappings = {
                        i = {
                            -- Exit on Escape
                            ["<Esc>"] = actions.close,
                            -- Move up and down
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-j>"] = actions.move_selection_next,
                        },
                        n = {
                            -- Move up and down in normal mode
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-j>"] = actions.move_selection_next,
                        },
                    },
                },
                pickers = {
                    live_grep = {
                        file_ignore_patterns = {
                            'node_modules/.',
                            '.git',
                            '.venv',
                            '.*_templ.go',
                            '*.mod',
                            '*.sum',
                            '*.class',
                            '*.pdf',
                            'package%-lock.json',
                            'package.json',
                        },
                        additional_args = function(_)
                            return { "--hidden" }
                        end
                    },
                    find_files = {
                        file_ignore_patterns = {
                            'node_modules/.',
                            '.git',
                            '.venv',
                            '.*_templ.go',
                            '*.class',
                            'package%-lock.json',
                            'package.json',
                        },
                        hidden = true
                    }
                },
            })
        end,
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()
            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<A-j>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<A-k>", function() harpoon:list():next() end)
        end,
    }
}
