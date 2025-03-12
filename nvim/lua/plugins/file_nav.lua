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
                            '.*_templ.txt',
                            '*.mod',
                            '*.sum',
                            '*.class',
                            '*.pdf',
                            'tailwindcss',
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
                            '.*_templ.txt',
                            '*.class',
                            'package%-lock.json',
                            'tailwindcss',
                            'package.json',
                        },
                        hidden = false
                    }
                },
            })
        end,
    },
}
