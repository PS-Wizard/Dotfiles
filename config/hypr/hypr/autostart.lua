hl.on("hyprland.start", function()
    -- Propagate Wayland env to dbus/systemd so wl-copy and XDG portals work
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("swaybg -o '*' -i '/home/wizard/.config/hypr/wallpaper.jpg' -m fill")
    hl.exec_cmd("waybar -c /home/wizard/.config/waybar/config.json -s /home/wizard/.config/waybar/style.css")
    hl.exec_cmd("trash-empty -f 10")
    hl.exec_cmd("brightnessctl s 0")
end)
