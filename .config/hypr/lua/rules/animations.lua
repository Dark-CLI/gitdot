-- Animation Configuration
-- Uses Hyprland's default styles with faster speeds

hl.animation({ leaf = "global",           enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "windows",          enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "border",           enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 7,  bezier = "default" })
-- specialWorkspace animation disabled: eliminates the dark shade flash when
-- the dropdown terminal is moved into/out of special:scratchpad
hl.animation({ leaf = "specialWorkspace", enabled = false, bezier = "default" })
