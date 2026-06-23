-- Event Listeners & Callbacks
-- Hyprland event handlers for config reload and other system events
-- Idle/lock behavior managed by hypridle.conf (separate daemon)

local SCRIPTS = os.getenv("HOME") .. "/.config/hypr/scripts"

-- ============================================
-- CONFIG RELOAD EVENTS
-- ============================================

hl.on("config.reloaded", function()
  -- Post-reload tasks
  -- Refresh UI components that depend on config state
  -- Example: update workspace indicators in waybar
  -- Note: waybar reloads via signal elsewhere; this is for custom handlers
end)

-- ============================================
-- OPTIONAL: WINDOW/WORKSPACE EVENTS
-- ============================================

-- Uncomment if you need to handle specific window or workspace events

-- hl.on("window.open", function(win)
--   -- Triggered when a window opens
-- end)

-- hl.on("window.close", function(win)
--   -- Triggered when a window closes
-- end)

-- hl.on("workspace.created", function(ws)
--   -- Triggered when a new workspace is created
-- end)

-- hl.on("workspace.changed", function(ws)
--   -- Triggered when switching workspaces
-- end)
