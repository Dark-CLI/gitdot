-- Custom Keybinds (22 total)
-- Vim-style navigation, gap control, custom utilities
-- Ported from: UserConfigs/UserKeybinds.conf

local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"
local USER_SCRIPTS = HOME .. "/.config/hypr/UserScripts"

-- Load helpers
local gap_control = require("lua.helpers.gap_control")

-- ============================================
-- GAP CONTROL
-- ============================================

hl.bind("SUPER + equal", function() gap_control.increment() end) --: increase gaps
hl.bind("SUPER + plus", function() gap_control.increment() end) --: increase gaps
hl.bind("SUPER + minus", function() gap_control.decrement() end) --: decrease gaps
hl.bind("SUPER + BackSpace", function() gap_control.reset() end) --: reset gaps to default

-- ============================================
-- VIM-STYLE FOCUS NAVIGATION
-- ============================================

hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" })) --: focus window left (vim)
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" })) --: focus window right (vim)
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" })) --: focus window up (vim)
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" })) --: focus window down (vim)

-- ============================================
-- VIM-STYLE WINDOW MOVEMENT
-- ============================================

-- Floating windows edge-snap to the monitor's usable area (minus reserved
-- bar space, minus gaps_out). Tiled windows use Hyprland's direction
-- move. Logic lives in scripts/FloatingEdgeSnap.sh so hyprctl calls
-- happen in a child process and never block Hyprland's main thread.
hl.bind("SUPER + SHIFT + h", hl.dsp.exec_cmd(SCRIPTS .. "/FloatingEdgeSnap.sh l")) --: move window left (vim)
hl.bind("SUPER + SHIFT + l", hl.dsp.exec_cmd(SCRIPTS .. "/FloatingEdgeSnap.sh r")) --: move window right (vim)
hl.bind("SUPER + SHIFT + k", hl.dsp.exec_cmd(SCRIPTS .. "/FloatingEdgeSnap.sh u")) --: move window up (vim)
hl.bind("SUPER + SHIFT + j", hl.dsp.exec_cmd(SCRIPTS .. "/FloatingEdgeSnap.sh d")) --: move window down (vim)

-- ============================================
-- VIM-STYLE WINDOW RESIZE
-- ============================================

hl.bind("SUPER + CTRL + h", hl.dsp.window.resize({ x = -50, y = 0, relative = true })) --: resize window left -50px (vim)
hl.bind("SUPER + CTRL + l", hl.dsp.window.resize({ x = 50, y = 0, relative = true })) --: resize window right +50px (vim)
hl.bind("SUPER + CTRL + k", hl.dsp.window.resize({ x = 0, y = -50, relative = true })) --: resize window up -50px (vim)
hl.bind("SUPER + CTRL + j", hl.dsp.window.resize({ x = 0, y = 50, relative = true })) --: resize window down +50px (vim)

-- ============================================
-- SYSTEM SHORTCUTS
-- ============================================

hl.bind("CTRL + ALT + Home", hl.dsp.exec_cmd("systemctl suspend")) --: suspend system

-- ============================================
-- KEYBINDS SEARCH (alternative to SUPER+F2)
-- ============================================

hl.bind("SUPER + O", hl.dsp.exec_cmd(SCRIPTS .. "/KeyBinds.sh")) --: search keybinds

-- ============================================
-- CUSTOM SYSTEM COMMANDS
-- ============================================

hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("sh -c 'killall waybar; sleep 0.2; waybar &'")) --: restart waybar
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload")) --: reload Hyprland config

-- ============================================
-- PYPRLAND ZOOM
-- ============================================

hl.bind("SUPER + Z", hl.dsp.exec_cmd("pypr zoom")) --: toggle desktop zoom (pypr)

-- ============================================
-- KEYBOARD LAYOUT SWITCHING
-- ============================================

-- ALT+SHIFT switches keyboard layout
hl.bind("ALT + SHIFT", hl.dsp.exec_cmd(SCRIPTS .. "/KeyboardLayout.sh switch")) --: switch keyboard layout

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
