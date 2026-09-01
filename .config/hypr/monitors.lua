-- Dual monitor setup: LG (left, portrait) + ASUS (right)
-- Last updated: 2026-09-01

-- LG secondary monitor: 1600x900 rotated 90° = 900x1600 physical size
-- Position: top-left (0,0)
-- Scale: 0.78 for DPI-matched scaling (84.7 / 108.4)
hl.monitor({
    output = "HDMI-A-2",
    mode = "1600x900@60.0",
    position = "0x0",
    scale = 0.78,
    vrr = 0,
    transform = 1
})

-- ASUS primary monitor: 2560x1440
-- Position: right of LG, accounting for scaled width
-- LG logical width: 900 / 0.78 ≈ 1154
hl.monitor({
    output = "DP-2",
    mode = "2560x1440@143.97",
    position = "1154x0",
    scale = 1.0,
    vrr = 1
})
