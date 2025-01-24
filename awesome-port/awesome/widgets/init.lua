local _M = {}

local awful = require'awful'
local beautiful = require'beautiful'
local wibox = require'wibox'
local gears = require'gears'

local apps = require'config.apps'
local mod = require'bindings.mod'

_M.textclock = wibox.widget.textclock()

function _M.create_promptbox()
    return awful.widget.prompt()
end

function _M.create_taglist(s)
    return awful.widget.taglist{
        screen = s,
        filter = awful.widget.taglist.filter.all,
    }
end

function _M.create_battery_widget()
    local battery_widget = wibox.widget {
        {
            id = 'battery_text',
            widget = wibox.widget.textbox,
            text = "Loading...",
        },
        layout = wibox.layout.flex.horizontal,
    }

    -- Update battery widget every minute
    gears.timer {
        timeout = 60,
        autostart = true,
        callback = function()
            awful.spawn.easy_async_with_shell("cat /sys/class/power_supply/BAT0/capacity", function(stdout)
                local capacity = stdout:match("(%d+)")
                if capacity then
                    battery_widget:get_children_by_id('battery_text')[1].text = capacity .. "%"
                else
                    battery_widget:get_children_by_id('battery_text')[1].text = "N/A"
                end
            end)
        end,
    }

    return battery_widget
end

function _M.create_wibox(s)
    s.promptbox = _M.create_promptbox()
    s.taglist = _M.create_taglist(s)

    s.mywibox = awful.wibar{
        screen = s,
        position = 'top',
        margins = {
            top = 5,
            bottom = 5,
            left = 10,
            right = 10,
        },
        widget = {
            layout = wibox.layout.align.horizontal,
            expand = 'none',
            -- Left widget
            {
                layout = wibox.layout.fixed.horizontal,
                s.taglist,
                s.promptbox,
            },
            -- Middle widget
            {
                layout = wibox.layout.fixed.horizontal,
                _M.textclock,
            },
            -- Right widget
            {
                layout = wibox.layout.fixed.horizontal,
                _M.create_battery_widget(),
            },
        },
    }

    return s.mywibox
end

-- Toggle function for the wibar
function _M.toggle_wibar()
    for s in screen do
        if s.mywibox then
            s.mywibox.visible = not s.mywibox.visible
        end
    end
end

return _M
