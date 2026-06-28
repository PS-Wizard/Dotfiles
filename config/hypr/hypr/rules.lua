-- Firefox picture-in-picture floats
hl.window_rule({
    name  = "pip-float",
    match = { class = "firefox", title = "^Picture-in-Picture$" },
    float = true,
})
