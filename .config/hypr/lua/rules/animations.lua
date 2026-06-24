-- Animation Configuration
-- Uses Hyprland's default styles with fast speeds
-- Note: Hyprland "speed" is actually duration in units of 100ms (LOWER = faster)

hl.animation({ leaf = "global",           enabled = true, speed = 3,   bezier = "default" })
hl.animation({ leaf = "windows",          enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 1.5, bezier = "default" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "border",           enabled = true, speed = 3,   bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 1.5, bezier = "default" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 2.5, bezier = "default" })
-- specialWorkspace animation disabled: eliminates the dark shade flash when
-- the dropdown terminal is moved into/out of special:scratchpad
hl.animation({ leaf = "specialWorkspace", enabled = false, bezier = "default" })
