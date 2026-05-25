-- Utility Helper Functions
-- Common functions used across the config
-- Phase 4: Will consolidate repeated logic
-- For now, basic utilities to support other modules

local function notify(title, message)
  local cmd = "notify-send '" .. title .. "' '" .. message .. "'"
  hl.exec_cmd(cmd)
end

local function exec_with_notify(script, title, message)
  hl.exec_cmd(script)
  notify(title, message or "Done")
end

return {
  notify = notify,
  exec_with_notify = exec_with_notify,
}
