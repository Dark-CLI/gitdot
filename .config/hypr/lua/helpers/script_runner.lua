-- Script Runner Helper
-- Utilities for calling external bash scripts from Lua
-- Provides centralized script management and calling conventions

local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"
local USER_SCRIPTS = HOME .. "/.config/hypr/UserScripts"

-- Script registry organized by category
local scripts = {
  -- ============================================
  -- AUDIO & VOLUME CONTROL
  -- ============================================
  volume = SCRIPTS .. "/Volume.sh",
  volume_inc = { script = SCRIPTS .. "/Volume.sh", args = "--inc" },
  volume_dec = { script = SCRIPTS .. "/Volume.sh", args = "--dec" },
  volume_inc_precise = { script = SCRIPTS .. "/Volume.sh", args = "--inc-precise" },
  volume_dec_precise = { script = SCRIPTS .. "/Volume.sh", args = "--dec-precise" },
  volume_toggle = { script = SCRIPTS .. "/Volume.sh", args = "--toggle" },
  volume_toggle_mic = { script = SCRIPTS .. "/Volume.sh", args = "--toggle-mic" },
  media_play_pause = { script = SCRIPTS .. "/MediaCtrl.sh", args = "--pause" },
  media_next = { script = SCRIPTS .. "/MediaCtrl.sh", args = "--nxt" },
  media_prev = { script = SCRIPTS .. "/MediaCtrl.sh", args = "--prv" },
  media_stop = { script = SCRIPTS .. "/MediaCtrl.sh", args = "--stop" },

  -- ============================================
  -- BRIGHTNESS CONTROL
  -- ============================================
  brightness = SCRIPTS .. "/Brightness.sh",
  brightness_kbd = SCRIPTS .. "/BrightnessKbd.sh",

  -- ============================================
  -- THEME & VISUAL CUSTOMIZATION
  -- ============================================
  theme_changer = SCRIPTS .. "/ThemeChanger.sh",
  rofi_theme_selector = SCRIPTS .. "/RofiThemeSelector.sh",
  rofi_theme_selector_modified = SCRIPTS .. "/RofiThemeSelector-modified.sh",
  change_blur = SCRIPTS .. "/ChangeBlur.sh",
  change_layout = SCRIPTS .. "/ChangeLayout.sh",
  dark_light = SCRIPTS .. "/DarkLight.sh",
  wallust_swww = SCRIPTS .. "/WallustSwww.sh",

  -- ============================================
  -- SCREENSHOT & MEDIA CAPTURE
  -- ============================================
  screenshot_now = { script = SCRIPTS .. "/ScreenShot.sh", args = "--now" },
  screenshot_area = { script = SCRIPTS .. "/ScreenShot.sh", args = "--area" },
  screenshot_active = { script = SCRIPTS .. "/ScreenShot.sh", args = "--active" },
  screenshot_in5 = { script = SCRIPTS .. "/ScreenShot.sh", args = "--in5" },
  screenshot_in10 = { script = SCRIPTS .. "/ScreenShot.sh", args = "--in10" },
  screenshot_swappy = { script = SCRIPTS .. "/ScreenShot.sh", args = "--swappy" },

  -- ============================================
  -- KEYBOARD & INPUT
  -- ============================================
  keyboard_layout_switch = SCRIPTS .. "/KeyboardLayout.sh switch",
  switch_keyboard_layout = SCRIPTS .. "/SwitchKeyboardLayout.sh",
  keyboard_layout_init = SCRIPTS .. "/KeybindsLayoutInit.sh",
  touchpad = SCRIPTS .. "/TouchPad.sh",

  -- ============================================
  -- LAYOUT & WORKSPACE
  -- ============================================
  gap_control = SCRIPTS .. "/GapControl.sh",
  gap_inc = { script = SCRIPTS .. "/GapControl.sh", args = "inc" },
  gap_dec = { script = SCRIPTS .. "/GapControl.sh", args = "dec" },
  gap_reset = { script = SCRIPTS .. "/GapControl.sh", args = "reset" },
  overview_toggle = SCRIPTS .. "/OverviewToggle.sh",
  game_mode = SCRIPTS .. "/GameMode.sh",

  -- ============================================
  -- DROPDOWN TERMINAL
  -- ============================================
  dropdown_terminal_toggle = SCRIPTS .. "/ToggleDropdownTerminal.sh",
  dropterminal = SCRIPTS .. "/Dropterminal.sh",

  -- ============================================
  -- SYSTEM & POWER CONTROL
  -- ============================================
  lock_screen = SCRIPTS .. "/LockScreen.sh",
  wlogout = SCRIPTS .. "/Wlogout.sh",
  airplane_mode = SCRIPTS .. "/AirplaneMode.sh",
  hyprsunset = SCRIPTS .. "/Hyprsunset.sh",
  hypridle = SCRIPTS .. "/Hypridle.sh",

  -- ============================================
  -- UTILITIES & TOOLS
  -- ============================================
  clip_manager = SCRIPTS .. "/ClipManager.sh",
  rofi_emoji = SCRIPTS .. "/RofiEmoji.sh",
  rofi_search = SCRIPTS .. "/RofiSearch.sh",
  rofi_calc = USER_SCRIPTS .. "/RofiCalc.sh",
  key_binds = SCRIPTS .. "/KeyBinds.sh",
  key_hints = SCRIPTS .. "/KeyHints.sh",
  animations = SCRIPTS .. "/Animations.sh",
  monitor_profiles = SCRIPTS .. "/MonitorProfiles.sh",
  sync_tablet = SCRIPTS .. "/SyncTabletTransform.sh",
  scratchpad_sync = SCRIPTS .. "/ScratchpadSyncGaps.sh",
  refresh = SCRIPTS .. "/Refresh.sh",
  kool_settings = SCRIPTS .. "/Kool_Quick_Settings.sh",

  -- ============================================
  -- WAYBAR & UI
  -- ============================================
  waybar_layout = SCRIPTS .. "/WaybarLayout.sh",
  waybar_styles = SCRIPTS .. "/WaybarStyles.sh",
  waybar_cava = SCRIPTS .. "/WaybarCava.sh",

  -- ============================================
  -- SYSTEM UPDATES & MAINTENANCE
  -- ============================================
  distro_update = SCRIPTS .. "/Distro_update.sh",
  kools_dots_update = SCRIPTS .. "/KooLsDotsUpdate.sh",

  -- ============================================
  -- USER SCRIPTS
  -- ============================================
  wallpaper_select = USER_SCRIPTS .. "/WallpaperSelect.sh",
  wallpaper_effects = USER_SCRIPTS .. "/WallpaperEffects.sh",
  wallpaper_random = USER_SCRIPTS .. "/WallpaperRandom.sh",
  rofi_beats = USER_SCRIPTS .. "/RofiBeats.sh",
  zsh_change_theme = USER_SCRIPTS .. "/ZshChangeTheme.sh",
}

-- Run a script by name with optional arguments
local function run_script(name, extra_args)
  local script_def = scripts[name]

  if not script_def then
    print("Script '" .. name .. "' not found in registry")
    return false
  end

  local cmd
  if type(script_def) == "string" then
    -- Simple string path
    cmd = script_def .. (extra_args and " " .. extra_args or "")
  elseif type(script_def) == "table" then
    -- Table with script and predefined args
    cmd = script_def.script .. " " .. script_def.args .. (extra_args and " " .. extra_args or "")
  end

  if cmd then
    hl.exec_cmd(cmd)
    return true
  end

  return false
end

-- Get script path by name (useful for debugging)
local function get_script_path(name)
  local script_def = scripts[name]
  if type(script_def) == "string" then
    return script_def
  elseif type(script_def) == "table" then
    return script_def.script
  end
  return nil
end

return {
  run_script = run_script,
  get_script_path = get_script_path,
  scripts = scripts
}
