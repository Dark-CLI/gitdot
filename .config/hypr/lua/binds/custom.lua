-- Custom Keybinds (22 total)
-- Vim-style navigation, gap control, custom utilities
-- Ported from: UserConfigs/UserKeybinds.conf

local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"
local USER_SCRIPTS = HOME .. "/.config/hypr/UserScripts"

-- Load gap control helper
local gap_control = require("lua.helpers.gap_control")

-- ============================================
-- GAP CONTROL
-- ============================================

hl.bind("SUPER + equal", function() gap_control.increment() end)
hl.bind("SUPER + plus", function() gap_control.increment() end)
hl.bind("SUPER + minus", function() gap_control.decrement() end)
hl.bind("SUPER + BackSpace", function() gap_control.reset() end)

-- ============================================
-- VIM-STYLE FOCUS NAVIGATION
-- ============================================

hl.bind("SUPER + h", hl.dsp.window.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.window.focus({ direction = "right" }))
hl.bind("SUPER + k", hl.dsp.window.focus({ direction = "up" }))
hl.bind("SUPER + j", hl.dsp.window.focus({ direction = "down" }))

-- ============================================
-- VIM-STYLE WINDOW MOVEMENT
-- ============================================

hl.bind("SUPER + SHIFT + h", hl.dsp.window.moveWindow({ direction = "left" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.moveWindow({ direction = "right" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.moveWindow({ direction = "up" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.moveWindow({ direction = "down" }))

-- ============================================
-- VIM-STYLE WINDOW RESIZE
-- ============================================

hl.bind("SUPER + CTRL + h", hl.dsp.window.resizeActive({ direction = "left", amount = -50 }))
hl.bind("SUPER + CTRL + l", hl.dsp.window.resizeActive({ direction = "right", amount = 50 }))
hl.bind("SUPER + CTRL + k", hl.dsp.window.resizeActive({ direction = "up", amount = -50 }))
hl.bind("SUPER + CTRL + j", hl.dsp.window.resizeActive({ direction = "down", amount = 50 }))

-- ============================================
-- SYSTEM SHORTCUTS
-- ============================================

hl.bind("CTRL + ALT + Home", hl.dsp.exec_cmd("systemctl suspend"))

-- ============================================
-- KEYBINDS SEARCH (Override Super+Shift+K)
-- ============================================

hl.bind("SUPER + O", hl.dsp.exec_cmd(SCRIPTS .. "/KeyBinds.sh"))

-- ============================================
-- CUSTOM SYSTEM COMMANDS
-- ============================================

hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("killall waybar && waybar &"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- ============================================
-- PYPRLAND ZOOM
-- ============================================

hl.bind("SUPER + Z", hl.dsp.exec_cmd("pypr zoom"))

-- ============================================
-- KEYBOARD LAYOUT SWITCHING
-- ============================================

-- ALT+SHIFT switches keyboard layout
hl.bind("ALT + SHIFT", hl.dsp.exec_cmd(SCRIPTS .. "/KeyboardLayout.sh switch"))

-- ============================================
-- OPTIONAL: PASSTHROUGH KEYBOARD (For VMs)
-- ============================================

-- To enable: uncomment below
-- hl.bind("SUPER + ALT + P", function()
--   hl.dispatch("submap passthru")
-- end)
--
-- In passthrough mode:
-- hl.bind("SUPER + ALT + P", function()
--   hl.dispatch("submap reset")
-- end)

-- All custom keybinds loaded
