-- Firefox picture-in-picture floats
hl.window_rule({
    name  = "pip-float",
    match = { class = "^(firefox|zen)$", title = "^Picture-in-Picture$" },
    float = true,
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
