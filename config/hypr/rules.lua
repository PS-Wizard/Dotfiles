-- Browsers that open fullscreen (RE2, case-insensitive).
local BROWSER_CLASS = "(?i)^(zen|zen-browser|chromium|chromium-browser)$"

-- Browsers open fullscreen.
hl.window_rule({
    name = "browser-fullscreen",
    match = { class = BROWSER_CLASS },
    fullscreen = true,
})


-- Picture-in-picture floats instead (later rule wins over browser-fullscreen).
hl.window_rule({
    name  = "pip-float",
    match = { class = BROWSER_CLASS, title = "^Picture-in-Picture$" },
    float = true,
    fullscreen = false,
    suppress_event = "fullscreen maximize",
    size  = { 480, 270 },
})


-- Scratchpad: i3-like floating, centered and resizable (Hypr special workspace)
-- Matches default special (SUPER+grave) and named magic (SUPER+S)
-- Windows spawned directly in special will use this size (bigger than default 600x400)
hl.window_rule({
    name  = "scratchpad-float",
    match = { workspace = "^special.*" },
    float = true,
    size  = { 1100, 700 },
    center = true,
})
