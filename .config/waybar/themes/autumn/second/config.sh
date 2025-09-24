{
    "layer": "top",
    "position": "top",
    "height": 35,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["pulseaudio", "network", "clock", "tray"],
    "hyprland/workspaces": {
        "format": "{icon}",
        "on-click": "activate"
    },
    "hyprland/window": {
        "format": "{}"
    },
    "tray": {
        "icon-size": 18,
        "spacing": 10
    },
    "clock": {
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%Y-%m-%d}"
    },
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-bluetooth": "{volume}% {icon}",
        "format-muted": " ",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },
    "network": {
        "format-wifi": "  {signalStrength}%",
        "format-ethernet": " {ifname}",
        "format-disconnected": "⚠ Disconnected",
        "on-click": "nm-connection-editor"
    }
}