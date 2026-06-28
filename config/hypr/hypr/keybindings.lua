local M = "SUPER"

-- Track active layout; starts as dwindle (matches hyprland.lua general.layout)
local active_layout = "dwindle"

local function toggle_layout()
    if active_layout == "dwindle" then
        active_layout = "scrolling"
    else
        active_layout = "dwindle"
    end
    hl.config({ general = { layout = active_layout } })
end

-- Mouse drag / resize
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Apps
hl.bind(M .. " + Return",    hl.dsp.exec_cmd("foot"))
hl.bind(M .. " + D",         hl.dsp.exec_cmd("bemenu-run -b --binding vim"))
hl.bind(M .. " + Y",         hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/screenshot.sh"))
hl.bind(M .. " + P",         hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(M .. " + SHIFT + P", hl.dsp.exec_cmd("hyprctl keyword monitor eDP-1,disabled"))

-- Layout toggle: dwindle ↔ scrolling (vertical)
hl.bind(M .. " + Space", toggle_layout)

-- Resize current scrolling-layout column
hl.bind(M .. " + minus", hl.dsp.layout("colresize -0.1"))
hl.bind(M .. " + equal", hl.dsp.layout("colresize +0.1"))

-- WM
hl.bind(M .. " + SHIFT + Q",      hl.dsp.window.close())
hl.bind(M .. " + SHIFT + Return", hl.dsp.exit())

-- Fullscreen / maximize
hl.bind(M .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(M .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Focus urgent or last window
hl.bind(M .. " + C", hl.dsp.focus({ urgent_or_last = true }))

-- Focus direction
hl.bind(M .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(M .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(M .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(M .. " + L", hl.dsp.focus({ direction = "r" }))

-- Swap windows
hl.bind(M .. " + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind(M .. " + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))
hl.bind(M .. " + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind(M .. " + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))

-- Focus monitor
hl.bind(M .. " + CTRL + H", hl.dsp.focus({ monitor = "l" }))
hl.bind(M .. " + CTRL + J", hl.dsp.focus({ monitor = "d" }))
hl.bind(M .. " + CTRL + K", hl.dsp.focus({ monitor = "u" }))
hl.bind(M .. " + CTRL + L", hl.dsp.focus({ monitor = "r" }))

-- Move current workspace to a monitor
hl.bind(M .. " + SHIFT + CTRL + H", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(M .. " + SHIFT + CTRL + J", hl.dsp.workspace.move({ monitor = "d" }))
hl.bind(M .. " + SHIFT + CTRL + K", hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(M .. " + SHIFT + CTRL + L", hl.dsp.workspace.move({ monitor = "r" }))

-- Workspaces
hl.bind(M .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(M .. " + U",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(M .. " + I",   hl.dsp.focus({ workspace = "e+1" }))

for i = 1, 9 do
    hl.bind(M .. " + " .. i,          hl.dsp.focus({ workspace = i }))
    hl.bind(M .. " + SHIFT + " .. i,  hl.dsp.window.move({ workspace = i }))
end

-- Mouse wheel workspace scroll
hl.bind(M .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad
hl.bind(M .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(M .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Media
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"),   { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"),   { repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl --class=backlight set +10%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl --class=backlight set 10%-"), { repeating = true })

-- Misc tools
hl.bind("ALT + W",         hl.dsp.exec_cmd("wlr-which-key"))
hl.bind("ALT + SHIFT + W", hl.dsp.exec_cmd("pkill wayscriber; wayscriber --active --mode whiteboard"))
