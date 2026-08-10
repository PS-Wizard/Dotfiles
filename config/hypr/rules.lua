-- Firefox picture-in-picture floats
hl.window_rule({
    name  = "pip-float",
    match = { class = "^(firefox|zen)$", title = "^Picture-in-Picture$" },
    float = true,
    suppress_event = "fullscreen maximize",
    size  = { 480, 270 },
})
