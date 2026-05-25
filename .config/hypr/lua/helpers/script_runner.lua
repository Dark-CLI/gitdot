-- Script Runner Helper
-- Utilities for calling external bash scripts from Lua
-- Phase 3: Will contain script wrapper functions
-- For now, placeholder to prevent load errors

local HOME = os.getenv("HOME")
local scripts = {
  theme_changer = HOME .. "/.config/hypr/scripts/ThemeChanger.sh",
  volume = HOME .. "/.config/hypr/scripts/Volume.sh",
  brightness = HOME .. "/.config/hypr/scripts/Brightness.sh",
  -- More scripts will be added in Phase 3
}

local function run_script(name, args)
  local cmd = scripts[name]
  if cmd then
    hl.exec_cmd(cmd .. " " .. (args or ""))
  else
    print("Unknown script: " .. name)
  end
end

return { run_script = run_script, scripts = scripts }
