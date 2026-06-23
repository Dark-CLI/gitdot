-- System Keybinds (145 total)
-- Window control, workspace navigation, audio, brightness, etc.
-- Ported from: configs/Keybinds.conf

local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"
local USER_SCRIPTS = HOME .. "/.config/hypr/UserScripts"
local TERM = "kitty"
local FILES = "nautilus"

-- ============================================
-- STANDARD / COMMON SHORTCUTS
-- ============================================

-- Application launchers
hl.bind("SUPER + D", hl.dsp.exec_cmd("pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("xdg-open 'https://'"))
hl.bind("SUPER + A", hl.dsp.exec_cmd(SCRIPTS .. "/OverviewToggle.sh"))
hl.bind("SUPER + Return", hl.dsp.exec_cmd(TERM))
hl.bind("SUPER + E", hl.dsp.exec_cmd(FILES))

-- Features / Extras
hl.bind("SUPER + T", hl.dsp.exec_cmd(SCRIPTS .. "/ThemeChanger.sh"))
hl.bind("SUPER + H", hl.dsp.exec_cmd(SCRIPTS .. "/KeyHints.sh"))
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd(SCRIPTS .. "/Refresh.sh"))
hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd(SCRIPTS .. "/RofiEmoji.sh"))
hl.bind("SUPER + S", hl.dsp.exec_cmd(SCRIPTS .. "/RofiSearch.sh"))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("rofi -show window"))
hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd(SCRIPTS .. "/ChangeBlur.sh"))
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd(SCRIPTS .. "/GameMode.sh"))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd(SCRIPTS .. "/ChangeLayout.sh"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd(SCRIPTS .. "/ClipManager.sh"))
hl.bind("SUPER + CTRL + R", hl.dsp.exec_cmd(SCRIPTS .. "/RofiThemeSelector.sh"))
hl.bind("SUPER + CTRL + SHIFT + R", hl.dsp.exec_cmd("pkill rofi || true && " .. SCRIPTS .. "/RofiThemeSelector-modified.sh"))

-- Window state & floating
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen({ all = true }))
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + ALT + Space", hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"))
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("sh -c '" .. SCRIPTS .. "/Dropterminal.sh " .. TERM .. "'"))

-- Desktop zoom (magnifier)
hl.bind("SUPER + ALT + mouse_down", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')\""))
hl.bind("SUPER + ALT + mouse_up", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 2.0}')\""))

-- Waybar / Bar related
hl.bind("SUPER + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd(SCRIPTS .. "/WaybarStyles.sh"))
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd(SCRIPTS .. "/WaybarLayout.sh"))

-- Night light
hl.bind("SUPER + N", hl.dsp.exec_cmd(SCRIPTS .. "/Hyprsunset.sh toggle"))

-- User Scripts
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd(USER_SCRIPTS .. "/RofiBeats.sh"))
hl.bind("SUPER + W", hl.dsp.exec_cmd(USER_SCRIPTS .. "/WallpaperSelect.sh"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(USER_SCRIPTS .. "/WallpaperEffects.sh"))
hl.bind("CTRL + ALT + W", hl.dsp.exec_cmd(USER_SCRIPTS .. "/WallpaperRandom.sh"))
hl.bind("SUPER + CTRL + O", hl.dsp.exec_cmd("hyprctl setprop active opaque toggle"))
hl.bind("SUPER + SHIFT + K", hl.dsp.exec_cmd(SCRIPTS .. "/KeyBinds.sh"))
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd(SCRIPTS .. "/Animations.sh"))
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd(USER_SCRIPTS .. "/ZshChangeTheme.sh"))
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd(USER_SCRIPTS .. "/RofiCalc.sh"))

-- Move workspaces to monitors
hl.bind("SUPER + CTRL + F9", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind("SUPER + CTRL + F10", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind("SUPER + CTRL + F11", hl.dsp.workspace.move({ monitor = "u" }))
hl.bind("SUPER + CTRL + F12", hl.dsp.workspace.move({ monitor = "d" }))

-- ============================================
-- SYSTEM KEYBINDS
-- ============================================

hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd(SCRIPTS .. "/KillActiveProcess.sh"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(SCRIPTS .. "/LockScreen.sh"))
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd(SCRIPTS .. "/Wlogout.sh"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd(SCRIPTS .. "/Kool_Quick_Settings.sh"))

-- ============================================
-- MASTER LAYOUT
-- ============================================

hl.bind("SUPER + CTRL + D", hl.dsp.layout("removemaster"))
hl.bind("SUPER + I", hl.dsp.layout("addmaster"))
hl.bind("SUPER + CTRL + Return", hl.dsp.layout("swapwithmaster"))

-- ============================================
-- DWINDLE LAYOUT
-- ============================================

hl.bind("SUPER + SHIFT + I", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + P", hl.dsp.window.pseudo())

-- ============================================
-- LAYOUT MANAGEMENT
-- ============================================

hl.bind("SUPER + M", hl.dsp.exec_cmd("hyprctl dispatch splitratio 0.3"))

-- ============================================
-- WINDOW CYCLING
-- ============================================

hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + Tab", hl.dsp.window.bring_to_top())

-- ============================================
-- SPECIAL KEYS / HOT KEYS (Audio, Media, etc.)
-- ============================================

-- Volume control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(SCRIPTS .. "/Volume.sh --inc"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(SCRIPTS .. "/Volume.sh --dec"))
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd(SCRIPTS .. "/Volume.sh --inc-precise"))
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd(SCRIPTS .. "/Volume.sh --dec-precise"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(SCRIPTS .. "/Volume.sh --toggle-mic"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(SCRIPTS .. "/Volume.sh --toggle"))

-- System controls
hl.bind("XF86Sleep", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("XF86Rfkill", hl.dsp.exec_cmd(SCRIPTS .. "/AirplaneMode.sh"))

-- Media controls (XF86AudioPlayPause is not a valid keysym - use XF86AudioPause/Play instead)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --pause"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --nxt"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --prv"))
hl.bind("XF86AudioStop", hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --stop"))

-- ============================================
-- SCREENSHOT KEYBINDINGS
-- ============================================

hl.bind("SUPER + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --now"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --area"))
hl.bind("SUPER + CTRL + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --in5"))
hl.bind("SUPER + CTRL + SHIFT + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --in10"))
hl.bind("ALT + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --active"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --swappy"))

-- ============================================
-- WINDOW RESIZE (Hold to repeat)
-- ============================================

hl.bind("SUPER + SHIFT + Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

-- ============================================
-- WINDOW MOVEMENT
-- ============================================

hl.bind("SUPER + CTRL + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + CTRL + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + CTRL + Down", hl.dsp.window.move({ direction = "d" }))

-- ============================================
-- WINDOW SWAPPING
-- ============================================

hl.bind("SUPER + ALT + Left", hl.dsp.window.swap({ direction = "l" }))
hl.bind("SUPER + ALT + Right", hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + ALT + Up", hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + ALT + Down", hl.dsp.window.swap({ direction = "d" }))

-- ============================================
-- GROUP MANAGEMENT
-- ============================================

hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + Tab", hl.dsp.group.next())
hl.bind("SUPER + CTRL + Tab", hl.dsp.group.next())
hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev())

-- Move windows into/out of groups
hl.bind("SUPER + CTRL + K", hl.dsp.group.move_window({ direction = "l" }))
hl.bind("SUPER + CTRL + L", hl.dsp.group.move_window({ direction = "r" }))
hl.bind("SUPER + CTRL + H", hl.dsp.exec_cmd("hyprctl dispatch moveoutofgroup"))

-- ============================================
-- WINDOW FOCUS
-- ============================================

hl.bind("SUPER + Left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "d" }))

-- ============================================
-- WORKSPACE NAVIGATION
-- ============================================

hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace
hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "special" }))
hl.bind("SUPER + U", hl.dsp.workspace.toggle_special())

-- ============================================
-- WORKSPACE SWITCHING (By Number)
-- ============================================

-- Switch to workspace with Super + [1-9, 0]
for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  local code = i < 10 and "code:" .. (9 + i) or "code:19"
  hl.bind("SUPER + " .. code, hl.dsp.focus({ workspace = i }))
end

-- ============================================
-- MOVE WINDOW TO WORKSPACE
-- ============================================

-- Move window to workspace with Super + Shift + [1-9, 0]
for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  local code = i < 10 and "code:" .. (9 + i) or "code:19"
  hl.bind("SUPER + SHIFT + " .. code, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.window.move({ workspace = "e+1" }))

-- ============================================
-- MOVE WINDOW SILENTLY TO WORKSPACE
-- ============================================

-- Move window silently with Super + Ctrl + [1-9, 0]
for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  local code = i < 10 and "code:" .. (9 + i) or "code:19"
  hl.bind("SUPER + CTRL + " .. code, hl.dsp.window.move({ workspace = i, silent = true }))
end

hl.bind("SUPER + CTRL + bracketleft", hl.dsp.window.move({ workspace = "e-1", silent = true }))
hl.bind("SUPER + CTRL + bracketright", hl.dsp.window.move({ workspace = "e+1", silent = true }))

-- ============================================
-- SCROLL THROUGH WORKSPACES
-- ============================================

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + comma", hl.dsp.focus({ workspace = "e-1" }))

-- ============================================
-- MOUSE BINDINGS
-- ============================================

-- LMB: Move window, RMB: Resize window
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- All system keybinds loaded
