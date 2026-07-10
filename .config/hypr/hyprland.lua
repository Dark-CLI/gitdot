-- Hyprland Configuration in Lua
-- Migration from HyprLang (.conf) to Lua format
-- Version: 0.51.1+
-- Last updated: 2026-05-25

-- ============================================
-- GLOBAL CONFIGURATION CONSTANTS
-- ============================================

-- Programs
local TERMINAL = "kitty"
local LAUNCHER = "wofi"
local BROWSER = "firefox"
local FILES = "nautilus"
local EDITOR = "nvim"

-- Paths
local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"
local CONFIGS = HOME .. "/.config/hypr"

-- ============================================
-- LOAD CORE CONFIGURATION
-- ============================================

-- Environment variables (must be set before Display Server init)
require("lua.core.env")

-- Core Hyprland settings (general, decoration, input)
require("lua.core.config")

-- Monitor configuration
require("lua.core.monitors")

-- ============================================
-- LOAD ANIMATION & VISUAL SETTINGS
-- ============================================

require("lua.rules.animations")

-- ============================================
-- LOAD KEYBINDS
-- ============================================

-- System keybinds (window control, workspace, audio, etc.)
require("lua.binds.system")

-- Custom keybinds (vim-style navigation, gap control, etc.)
require("lua.binds.custom")

-- ============================================
-- LOAD WINDOW & WORKSPACE RULES
-- ============================================

require("lua.rules.windows")
require("lua.rules.workspaces")

-- ============================================
-- LOAD STARTUP & EVENTS
-- ============================================

require("lua.startup.boot")
require("lua.startup.events")

-- ============================================
-- LOAD PRIVATE / HOST-LOCAL OVERRIDES
-- ============================================
-- Anything sensitive (e.g. a hyprlock bypass shortcut) or host-specific
-- lives in ~/.local/state/hypr/private.lua, which is deliberately OUTSIDE
-- ~/.config/hypr so it never crosses paths with lazydot or gitdot.
-- Skip silently if the file doesn't exist.
do
  local private_path = os.getenv("HOME") .. "/.local/state/hypr/private.lua"
  local chunk = loadfile(private_path)
  if chunk then chunk() end
end

-- ============================================
-- CONFIGURATION COMPLETE
-- ============================================

-- All configuration has been loaded.
-- Hyprland will automatically reload this file when it changes.
-- To manually reload: hyprctl reload
-- To check for errors: hyprctl -n
