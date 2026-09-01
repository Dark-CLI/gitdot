-- Workspace Rules
-- Workspace-specific configurations and assignments

-- Fast fade animation for dropdown terminal scratchpad
hl.workspace_rule({ workspace = "special:scratchpad", animation = "fade" })

-- Load workspace-to-monitor assignments
local HOME = os.getenv("HOME")
local workspaces_file = HOME .. "/.config/hypr/workspaces.lua"
local f = io.open(workspaces_file, "r")
if f then
  f:close()
  dofile(workspaces_file)
end

-- Example workspace rule patterns:
-- hl.workspace_rule({
--   workspace = 1,
--   monitor = "eDP-1"
-- })
--
-- hl.workspace_rule({
--   workspace = "name:gaming",
--   gapsin = 0,
--   gapsout = 0,
--   border = false,
--   decorate = false
-- })
