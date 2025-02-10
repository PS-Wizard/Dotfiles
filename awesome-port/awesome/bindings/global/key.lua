local awful = require'awful'
local hotkeys_popup = require'awful.hotkeys_popup'
require'awful.hotkeys_popup.keys'

local apps = require'config.apps'
local mod = require'bindings.mod'
local widgets = require'widgets'

-- general awesome keys
awful.keyboard.append_global_keybindings{
    awful.key{
        modifiers   = {mod.super},
        key         = 's',
        description = 'show help',
        group       = 'awesome',
        on_press    = hotkeys_popup.show_help,
    },
    awful.key{
        modifiers   = {mod.super, mod.ctrl},
        key         = 'r',
        description = 'reload awesome',
        group       = 'awesome',
        on_press    = awesome.restart,
    },
    awful.key{
        modifiers   = {mod.super, mod.shift},
        key         = 'c',
        description = 'quit awesome',
        group       = 'awesome',
        on_press    = awesome.quit,
    },
    awful.key{
        modifiers   = {mod.super},
        key         = 'Return',
        description = 'open a terminal',
        group       = 'launcher',
        on_press    = function() awful.spawn(apps.terminal) end,
    },
    awful.key{
        modifiers   = {mod.super},
        key         = 'r',
        description = 'run prompt',
        group       = 'launcher',
        on_press    = function() awful.screen.focused().promptbox:run() end,
    },
}

-- tags related keybindings
awful.keyboard.append_global_keybindings{
    awful.key{
        modifiers   = {mod.super},
        key         = 'Tab',
        description = 'go back',
        group       = 'tag',
        on_press    = awful.tag.history.restore,
    },
}

-- focus related keybindings
awful.keyboard.append_global_keybindings{
    awful.key{
        modifiers   = {mod.super},
        key         = 'j',
        description = 'focus next by index',
        group       = 'client',
        on_press    = function() awful.client.focus.byidx(1) end,
    },
    awful.key{
        modifiers   = {mod.super},
        key         = 'k',
        description = 'focus previous by index',
        group       = 'client',
        on_press    = function() awful.client.focus.byidx(-1) end,
    },
    awful.key{
        modifiers   = {mod.super, mod.ctrl},
        key         = 'n',
        description = 'restore minimized',
        group       = 'client',
        on_press    = function()
            local c = awful.client.restore()
        end,
    },
}

awful.keyboard.append_global_keybindings{
    awful.key{
        modifiers   = {mod.super},
        keygroup    = 'numrow',
        description = 'only view tag',
        group       = 'tag',
        on_press    = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end
    },
    awful.key{
        modifiers   = {mod.super, mod.shift},
        keygroup    = 'numrow',
        description = 'move focused client to tag',
        group       = 'tag',
        on_press    = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end
    },
    awful.key{
        modifiers   = {mod.super},
        keygroup    = 'numpad',
        description = 'select layout directly',
        group       = 'layout',
        on_press    = function(index)
            local tag = awful.screen.focused().selected_tag
            if tag then
                tag.layout = tag.layouts[index] or tag.layout
            end
        end
    },
    awful.key{
        modifiers   = {mod.super},
        key         = 'space',
        description = 'select next',
        group       = 'layout',
        on_press    = function() awful.layout.inc(1) end,
    },
    awful.key{
      modifiers   = {mod.super, mod.shift},
      key         = 'space',
      description = 'select previous',
      group       = 'layout',
      on_press    = function() awful.layout.inc(-1) end,
   },
}

-- Volume and Brightness Controls
awful.keyboard.append_global_keybindings{
    -- Volume controls
    awful.key{
        modifiers   = {},
        key         = 'XF86AudioRaiseVolume',
        description = 'increase volume',
        group       = 'media',
        on_press    = function() awful.spawn('pactl set-sink-volume @DEFAULT_SINK@ +5%') end,
    },
    awful.key{
        modifiers   = {},
        key         = 'XF86AudioLowerVolume',
        description = 'decrease volume',
        group       = 'media',
        on_press    = function() awful.spawn('pactl set-sink-volume @DEFAULT_SINK@ -5%') end,
    },
    awful.key{
        modifiers   = {},
        key         = 'XF86AudioMute',
        description = 'mute/unmute volume',
        group       = 'media',
        on_press    = function() awful.spawn('pactl set-sink-mute @DEFAULT_SINK@ toggle') end,
    },

    -- Brightness controls
    awful.key{
        modifiers   = {},
        key         = 'XF86MonBrightnessUp',
        description = 'increase brightness',
        group       = 'media',
        on_press    = function() awful.spawn('light -A 3') end,
    },
    awful.key{
        modifiers   = {},
        key         = 'XF86MonBrightnessDown',
        description = 'decrease brightness',
        group       = 'media',
        on_press    = function() awful.spawn('light -U 3') end,
    },
}

awful.keyboard.append_global_keybindings{
    awful.key{
        modifiers   = {mod.super},
        key         = 'y',
        description = 'take screenshot and save to 1920x1080 resolution in ~/Pictures/',
        group       = 'media',
        on_press    = function() awful.spawn('maim -g 1920x1080 ' .. os.getenv("HOME") .. '/Pictures/screenshot.png') end,
    },

    awful.key{
        modifiers   = {mod.super, mod.shift},
        key         = 'y',
        description = 'take screenshot selection and copy to clipboard',
        group       = 'media',
        on_press    = function() awful.spawn.with_shell('maim -s | xclip -selection clipboard -t image/png') end,
    },
}

awful.keyboard.append_global_keybindings{
   awful.key{
      modifiers   = {mod.super},
      key         = 'p',
      description = 'toggle wibox visibility',
      group       = 'awesome',
      on_press    = function ()
         -- Call the toggle function from widgets
         widgets.toggle_wibar()
      end,
   },

}

