require("mini.deps").setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- ColorScheme
now(function()
    vim.cmd('colorscheme dino')
end)

now(function()
    require("mini.basics").setup({
        extra_ui = true,
        mappings = {
            windows = true,
        },
        silent=true,
    })
end)
-- Better around, in actions
later(function() require ("mini.ai").setup({ silent = true }) end)

-- Comments
later(function() require ("mini.comment").setup() end)

-- Indent Scope
later(function()
    require ("mini.indentscope").setup({
        draw = {
            delay = 0,
            animation = require('mini.indentscope').gen_animation.none(),
        },
        mappings = {goto_top = 'gt', goto_bottom = 'gb',},
        options = {
            indent_at_cursor =false,
            try_as_border = true,
        },
        symbol = '!',
    })
end)

-- Pairs
later(function() require("mini.pairs").setup() end)

-- Split Join
later(function() require("mini.splitjoin").setup({mappings = {toggle = 'ms'}}) end)

-- Surround
later(function() require("mini.surround").setup({silent=true}) end)

-- Pick
later(function() require("mini.pick").setup({
    silent=true,
    mappings = {
        move_down = '<M-j>',
        move_up = '<M-k>',
        move_start = '<M-g>',
        caret_left = '<M-h>',
        caret_right = '<M-l>',
        caret_left = '<M-h>',
    }
}) end)

-- Files
later(function() require("mini.files").setup({}) end)

-- Move
later(function() require("mini.move").setup(
    {
        mappings = {
            -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
            right = '<M-l>',
            down = '<M-j>',
            up = '<M-k>',
            left = '<M-h>',

            -- Move in Normal Mode (Not Using This)
            line_left = '',
            line_right = '',
            line_down = '',
            line_up = '',
        },
}) end)

later(function() 
    require("mini.git").setup()
end)


