return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects", -- for the sick text objects
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            -- Install parsers for languages you actually use
            ensure_installed = {
                "lua",
                "svelte",
                "typescript",
                "rust",
                "go",
                "c",
                "markdown",
            },

            -- Auto-install missing parsers when entering buffer
            auto_install = false,

            -- Better syntax highlighting
            highlight = {
                enable = true,
                -- disable = { "c" }, -- if you have issues with specific langs
            },

            -- Indentation based on treesitter
            indent = {
                enable = true,
                -- disable = { "python" }, -- python indenting can be weird sometimes
            },

            -- Incremental selection (this is SICK)
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",    -- start selection
                    node_incremental = "<CR>",  -- expand selection
                    scope_incremental = "<C-s>", -- expand to scope
                    node_decremental = "<BS>",  -- shrink selection
                },
            },

            -- Text objects - these won't collide with mini.ai
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- jump forward to next textobj

                    keymaps = {
                        -- functions
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",

                        -- classes
                        -- ["ac"] = "@class.outer",
                        -- ["ic"] = "@class.inner",

                        -- conditionals (if statements, etc)
                        ["ac"] = "@conditional.outer",
                        ["ic"] = "@conditional.inner",

                        -- loops
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",

                        -- parameters/arguments - but mini.ai handles 'a' better
                        -- so maybe use 'P' for parameter
                        ["aa"] = "@parameter.outer",
                        ["ia"] = "@parameter.inner",

                        -- comments
                        ["a/"] = "@comment.outer",
                    },
                },

                -- Move between functions, classes, etc
                move = {
                    enable = true,
                    set_jumps = true, -- add to jumplist

                    goto_next_start = {
                        ["]f"] = "@function.outer",
                        ["]c"] = "@class.outer",
                        ["]a"] = "@parameter.inner",
                    },
                    goto_next_end = {
                        ["]F"] = "@function.outer",
                        ["]C"] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[f"] = "@function.outer",
                        ["[c"] = "@class.outer",
                        ["[a"] = "@parameter.inner",
                    },
                    goto_previous_end = {
                        ["[F"] = "@function.outer",
                        ["[C"] = "@class.outer",
                    },
                },
            },
        })
    end,
}
