---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local gears = require("gears")
local themes_path = gfs.get_configuration_dir() .. 'themes/'

local theme = {}

theme.font          = "JetBrains Mono"

theme.bg_normal     = "#000000"
theme.bg_focus      = "#000000"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap         = dpi(1)
theme.border_width        = dpi(2)
theme.border_color_normal = "#000000"
theme.border_color_active = "#292929"
theme.border_color_marked = "#000000"

theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

theme.wallpaper = themes_path.."wizard/background.png"


theme.titlebar_bg_normal = "#000000"      -- Normal background color of the titlebar
theme.titlebar_bg_focus = "#000000"       -- Background color when the window is focused
theme.titlebar_fg_normal = "#aaaaaa"      -- Text color of the titlebar when the window is normal
theme.titlebar_fg_focus = "#ffffff"       -- Text color of the titlebar when the window is focused
theme.titlebar_height = 8  -- Set the height you want (default is usually around 16 or so)


-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
    rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = { bg = '#ff0000', fg = '#ffffff' }
    }
end)

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
