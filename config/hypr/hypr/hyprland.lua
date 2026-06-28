-- Fallback rule: any unspecified monitor uses preferred mode
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
    general = {
        layout = "dwindle",
        border_size = 0,
        gaps_in = 4,
        gaps_out = 4,
        ["col.active_border"]   = "rgba(8a8a8aff)",
        ["col.inactive_border"] = "rgba(2f2f2fff)",
    },
    decoration = {
        rounding        = 8,
        active_opacity  = 1.0,
        inactive_opacity = 1.0,
        blur   = { enabled = false },
        shadow = { enabled = false },
    },
    animations = {
        enabled = true,
    },
    input = {
        kb_layout  = "us",
        kb_options = "caps:ctrl_modifier",
        kb_rules   = "",
        repeat_rate  = 25,
        repeat_delay = 600,
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll      = true,
            tap_to_click        = true,
            tap_and_drag        = true,
            drag_lock           = 1,
            disable_while_typing = true,
        },
    },
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        middle_click_paste       = false,
    },
    cursor = {
        warp_on_change_workspace = false,
    },
    dwindle = {
        preserve_split = false,
        smart_split    = false,
    },
    scrolling = {
        direction    = "down",
        column_width = 0.8,
    },
})

-- Curves
hl.curve("linear",  { type = "bezier", points = { {0.0, 0.0}, {1.0, 1.0} } })
hl.curve("easeOut", { type = "bezier", points = { {0.0, 0.0}, {0.2, 1.0} } })

hl.animation({ leaf = "windows",    enabled = true,  speed = 1,   bezier = "easeOut", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true,  speed = 1.4, bezier = "easeOut", style = "slide" })
hl.animation({ leaf = "fade",       enabled = true,  speed = 1,   bezier = "linear" })
hl.animation({ leaf = "workspaces", enabled = false })

require("autostart")
require("rules")
require("keybindings")
