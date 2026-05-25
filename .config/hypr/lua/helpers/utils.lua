-- Utility Helper Functions
-- Common functions used across the config
-- Consolidates repeated logic and provides common patterns

local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"

-- Send a desktop notification
local function notify(title, message)
  local escaped_title = title:gsub("'", "'\\''")
  local escaped_msg = message:gsub("'", "'\\''")
  hl.exec_cmd("notify-send '" .. escaped_title .. "' '" .. escaped_msg .. "'")
end

-- Execute a script and notify on completion
local function exec_with_notify(script, title, message)
  hl.exec_cmd(script)
  notify(title, message or "Done")
end

-- Get current gap value
local function get_gaps()
  local config = hl.config()
  return config.general.gaps_in
end

-- Set gaps and notify
local function set_gaps_with_notify(new_gap)
  hl.config({
    general = {
      gaps_in = new_gap,
      gaps_out = new_gap
    }
  })
  notify("Gaps", "Set to: " .. new_gap .. " px")
end

-- Restart waybar
local function restart_waybar()
  hl.exec_cmd("killall waybar ; waybar &")
  notify("Waybar", "Restarted")
end

-- Reload Hyprland config (useful for event handlers)
local function reload_config()
  hl.exec_cmd("hyprctl reload")
  notify("Hyprland", "Config reloaded")
end

-- Execute a script asynchronously in background
local function exec_async(cmd)
  hl.exec_cmd(cmd .. " &")
end

-- Execute a script and capture return status (basic check)
local function exec_check(cmd)
  hl.exec_cmd(cmd)
  -- Note: Full status capture requires more complex shell integration
  return true
end

return {
  notify = notify,
  exec_with_notify = exec_with_notify,
  get_gaps = get_gaps,
  set_gaps_with_notify = set_gaps_with_notify,
  restart_waybar = restart_waybar,
  reload_config = reload_config,
  exec_async = exec_async,
  exec_check = exec_check,
}
