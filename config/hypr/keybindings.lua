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

-- Prepare the active window as an i3-like scratchpad, then move it without following.
local function send_to_scratchpad()
    if not hl.get_active_window() then
        return
    end

    hl.dispatch(hl.dsp.window.float({ action = "on" }))
    hl.dispatch(hl.dsp.window.resize({ x = 1100, y = 700 }))
    hl.dispatch(hl.dsp.window.center())
    hl.dispatch(hl.dsp.window.move({ workspace = "special", follow = false }))
end

-- Mouse drag / resize
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Apps
hl.bind(M .. " + Return",    hl.dsp.exec_cmd("kitty"))
hl.bind(M .. " + D",         hl.dsp.exec_cmd("bemenu-run -b --binding vim"))
hl.bind(M .. " + Y",         hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/screenshot.sh"))
hl.bind(M .. " + P",         hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(M .. " + SHIFT + P", hl.dsp.exec_cmd("hyprctl keyword monitor eDP-1,disabled"))

-- Layout toggle: dwindle ↔ scrolling (vertical)
hl.bind(M .. " + Space", toggle_layout)

-- Resize focused window
hl.bind(M .. " + minus", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(M .. " + equal", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(M .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(M .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

-- WM
hl.bind(M .. " + SHIFT + Q",      hl.dsp.window.close())
hl.bind(M .. " + SHIFT + Return", hl.dsp.exit())

-- Fullscreen / maximize
hl.bind(M .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(M .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(M .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Focus direction
hl.bind(M .. " + H", hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/focus_or_workspace.sh l"))
hl.bind(M .. " + J", hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/focus_or_workspace.sh d e+1"))
hl.bind(M .. " + K", hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/focus_or_workspace.sh u e-1"))
hl.bind(M .. " + L", hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/focus_or_workspace.sh r"))

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

-- Scratchpad - grave (i3-like, default special workspace)
-- SUPER + grave = toggle the scratchpad over the current workspace
-- SUPER + SHIFT + grave = float, resize, center, and hide the active window
hl.bind(M .. " + grave",         hl.dsp.workspace.toggle_special())
hl.bind(M .. " + SHIFT + grave", send_to_scratchpad)

-- Media
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+"),   { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"),   { repeating = true })
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

-- hl.bind("CTRL + Space", hl.dsp.submap("normal"))
-- hl.define_submap("normal", function()
--     -- Focus
--     hl.bind("H", hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/focus_or_workspace.sh l"))
--     hl.bind("J", hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/focus_or_workspace.sh d e+1"))
--     hl.bind("K", hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/focus_or_workspace.sh u e-1"))
--     hl.bind("L", hl.dsp.exec_cmd("/home/wizard/.config/hypr/scripts/focus_or_workspace.sh r"))
--
--     hl.bind("Return", hl.dsp.exec_cmd("kitty"))
--
--     -- Workspaces
--     for i = 1, 9 do
--         hl.bind(tostring(i), hl.dsp.focus({ workspace = i }))
--     end
--
--     -- Window actions
--     hl.bind("F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
--     hl.bind("M", hl.dsp.window.fullscreen({ mode = "maximized" }))
--
--     -- Swap windows
--     hl.bind("SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
--     hl.bind("SHIFT + J", hl.dsp.window.swap({ direction = "d" }))
--     hl.bind("SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
--     hl.bind("SHIFT + L", hl.dsp.window.swap({ direction = "r" }))
--
--     -- Exit back to regular keyboard input
--     hl.bind("Escape", hl.dsp.submap("reset"))
--     hl.bind("I", hl.dsp.submap("reset"))
-- end)
