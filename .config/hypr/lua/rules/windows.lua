-- Window Rules (112 total)
-- Application-specific window configurations
-- Ported from: configs/WindowRules.conf

-- ============================================
-- BROWSER TAGGING
-- ============================================

local function add_browser_tags()
  hl.window_rule({
    match = { class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$" },
    tag = "browser"
  })
  hl.window_rule({ match = { class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$" }, tag = "browser" })
  hl.window_rule({ match = { class = "^(chrome-.+-Default)$" }, tag = "browser" })
  hl.window_rule({ match = { class = "^([Cc]hromium)$" }, tag = "browser" })
  hl.window_rule({ match = { class = "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$" }, tag = "browser" })
  hl.window_rule({ match = { class = "^(Brave-browser(-beta|-dev|-unstable)?)$" }, tag = "browser" })
  hl.window_rule({ match = { class = "^([Tt]horium-browser|[Cc]achy-browser)$" }, tag = "browser" })
  hl.window_rule({ match = { class = "^(zen-alpha|zen)$" }, tag = "browser" })
end

-- ============================================
-- NOTIFICATION TAGGING
-- ============================================

local function add_notif_tags()
  hl.window_rule({
    match = { class = "^(swaync-control-center|swaync-notification-window|swaync-client)$" },
    tag = "notif"
  })
end

-- ============================================
-- KOOL SETTINGS TAGGING
-- ============================================

local function add_kool_tags()
  hl.window_rule({ match = { title = "^(KooL Quick Cheat Sheet)$" }, tag = "KooL_Cheat" })
  hl.window_rule({ match = { title = "^(KooL Hyprland Settings)$" }, tag = "KooL_Settings" })
  hl.window_rule({ match = { class = "^(nwg-displays|nwg-look)$" }, tag = "KooL-Settings" })
end

-- ============================================
-- TERMINAL TAGGING
-- ============================================

local function add_terminal_tags()
  hl.window_rule({ match = { class = "^(Alacritty|kitty|kitty-dropterm)$" }, tag = "terminal" })
end

-- ============================================
-- EMAIL TAGGING
-- ============================================

local function add_email_tags()
  hl.window_rule({ match = { class = "^([Tt]hunderbird|org.mozilla.Thunderbird)$" }, tag = "email" })
  hl.window_rule({ match = { class = "^(eu.betterbird.Betterbird)$" }, tag = "email" })
  hl.window_rule({ match = { class = "^(org.gnome.Evolution)$" }, tag = "email" })
end

-- ============================================
-- PROJECT/IDE TAGGING
-- ============================================

local function add_project_tags()
  hl.window_rule({ match = { class = "^(codium|codium-url-handler|VSCodium)$" }, tag = "projects" })
  hl.window_rule({ match = { class = "^(VSCode|code|code-url-handler)$" }, tag = "projects" })
  hl.window_rule({ match = { class = "^(jetbrains-.+)$" }, tag = "projects" })
  hl.window_rule({ match = { class = "^(dev.zed.Zed|antigravity)$" }, tag = "projects" })
end

-- ============================================
-- SCREENSHARE TAGGING
-- ============================================

local function add_screenshare_tags()
  hl.window_rule({ match = { class = "^(com.obsproject.Studio)$" }, tag = "screenshare" })
end

-- ============================================
-- IM TAGGING
-- ============================================

local function add_im_tags()
  hl.window_rule({ match = { class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$" }, tag = "im" })
  hl.window_rule({ match = { class = "^([Ff]erdium)$" }, tag = "im" })
  hl.window_rule({ match = { class = "^([Ww]hatsapp-for-linux)$" }, tag = "im" })
  hl.window_rule({ match = { class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$" }, tag = "im" })
  hl.window_rule({ match = { class = "^(teams-for-linux)$" }, tag = "im" })
  hl.window_rule({ match = { class = "^(im.riot.Riot|Element)$" }, tag = "im" })
end

-- ============================================
-- GAME TAGGING
-- ============================================

local function add_game_tags()
  hl.window_rule({ match = { class = "^(gamescope)$" }, tag = "games" })
  hl.window_rule({ match = { class = "^(steam_app_\\d+)$" }, tag = "games" })
end

-- ============================================
-- GAMESTORE TAGGING
-- ============================================

local function add_gamestore_tags()
  hl.window_rule({ match = { class = "^([Ss]team)$" }, tag = "gamestore" })
  hl.window_rule({ match = { title = "^([Ll]utris)$" }, tag = "gamestore" })
  hl.window_rule({ match = { class = "^(com.heroicgameslauncher.hgl)$" }, tag = "gamestore" })
end

-- ============================================
-- FILE MANAGER TAGGING
-- ============================================

local function add_file_manager_tags()
  hl.window_rule({ match = { class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$" }, tag = "file-manager" })
  hl.window_rule({ match = { class = "^(app.drey.Warp)$" }, tag = "file-manager" })
end

-- ============================================
-- WALLPAPER TAGGING
-- ============================================

local function add_wallpaper_tags()
  hl.window_rule({ match = { class = "^([Ww]aytrogen)$" }, tag = "wallpaper" })
end

-- ============================================
-- MULTIMEDIA TAGGING
-- ============================================

local function add_multimedia_tags()
  hl.window_rule({ match = { class = "^([Aa]udacious)$" }, tag = "multimedia" })
  hl.window_rule({ match = { class = "^([Mm]pv|vlc)$" }, tag = "multimedia_video" })
end

-- ============================================
-- SETTINGS TAGGING
-- ============================================

local function add_settings_tags()
  hl.window_rule({ match = { title = "^(ROG Control)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(wihotspot(-gui)?)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^([Bb]aobab|org.gnome.[Bb]aobab)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(gnome-disks)$" }, tag = "settings" })
  hl.window_rule({ match = { title = "(Kvantum Manager)" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(file-roller|org.gnome.FileRoller)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(nm-applet|nm-connection-editor|blueman-manager)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(qt5ct|qt6ct)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "(xdg-desktop-portal-gtk)" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^([Rr]ofi)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(btrfs-assistant)$" }, tag = "settings" })
  hl.window_rule({ match = { class = "^(timeshift-gtk)$" }, tag = "settings" })
end

-- ============================================
-- VIEWER TAGGING
-- ============================================

local function add_viewer_tags()
  hl.window_rule({ match = { class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$" }, tag = "viewer" })
  hl.window_rule({ match = { class = "^(evince)$" }, tag = "viewer" })
  hl.window_rule({ match = { class = "^(eog|org.gnome.Loupe)$" }, tag = "viewer" })
end

-- ============================================
-- CUSTOM RULES & OVERRIDES
-- ============================================

local function add_custom_rules()
  -- Multimedia overrides
  hl.window_rule({ match = { tag = "multimedia_video" }, no_blur = true, opacity = 1.0 })
  hl.window_rule({ match = { tag = "multimedia" }, no_blur = true, opacity = 1.0 })

  -- Positioning
  hl.window_rule({ match = { tag = "KooL_Cheat" }, center = true })
  hl.window_rule({ match = { tag = "KooL-Settings" }, center = true })
  hl.window_rule({ match = { title = "^(ROG Control)$" }, center = true })
  hl.window_rule({ match = { title = "^(Keybindings)$" }, center = true })
  hl.window_rule({ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, center = true })
  hl.window_rule({ match = { class = "^([Ff]erdium)$" }, center = true })

  -- Idle inhibit for fullscreen
  hl.window_rule({ match = { fullscreen = true }, idle_inhibit = "fullscreen" })

  -- Floating windows
  hl.window_rule({ match = { tag = "KooL_Cheat" }, float = true })
  hl.window_rule({ match = { tag = "wallpaper" }, float = true, center = true })
  hl.window_rule({ match = { tag = "settings" }, float = true, center = true })
  hl.window_rule({ match = { tag = "viewer" }, float = true, center = true })
  hl.window_rule({ match = { tag = "KooL-Settings" }, float = true, center = true })
  hl.window_rule({ match = { class = "([Zz]oom|onedriver)" }, float = true })
  hl.window_rule({ match = { class = "(org.gnome.Calculator|qalculate-gtk)" }, float = true })
  hl.window_rule({ match = { class = "^(mpv|com.github.rafostar.Clapper)$" }, float = true })
  hl.window_rule({ match = { class = "^([Ff]erdium)$" }, float = true })

  -- Dialog windows
  hl.window_rule({ match = { title = "^(Authentication Required)$" }, float = true, center = true })
  hl.window_rule({ match = { class = "(codium|codium-url-handler|VSCodium)", title = "negative:(.*codium.*|.*VSCodium.*)" }, float = true })


  -- Size rules
  hl.window_rule({ match = { tag = "KooL_Cheat" }, size = "(monitor_w*0.65) (monitor_h*0.9)" })
  hl.window_rule({ match = { tag = "wallpaper" }, size = "(monitor_w*0.7) (monitor_h*0.7)" })
  hl.window_rule({ match = { tag = "settings" }, size = "(monitor_w*0.7) (monitor_h*0.7)" })
  hl.window_rule({ match = { class = "^([Ff]erdium)$" }, size = "(monitor_w*0.6) (monitor_h*0.7)" })

  -- Blur & Fullscreen for games
  hl.window_rule({ match = { tag = "games" }, no_blur = true, fullscreen = 0 })

  -- IntelliJ no initial focus
  hl.window_rule({ match = { class = "^(jetbrains-*)" }, no_initial_focus = true })
  hl.window_rule({ match = { title = "^(wind.*)$" }, no_initial_focus = true })
end

-- ============================================
-- CUSTOM DROPOUT TERMINAL RULE
-- ============================================

local function add_dropdown_rules()
  hl.window_rule({
    match = { class = "^(DropdownTerminal)$" },
    float = true,
    animation = "fade"
  })
end

-- Cheat sheet popup (KeyHints.sh launches kitty --class HyprCheatSheet)
-- Size and position are set dynamically by the script (it reads current
-- gaps_out and monitor size). The rule only handles float + animation.
local function add_cheatsheet_rules()
  hl.window_rule({
    match = { class = "^(HyprCheatSheet)$" },
    float = true,
    animation = "fade"
  })
end

-- Keybind fuzzy-search popup (KeyBinds.sh launches kitty --class HyprKeyBindsSearch)
local function add_keybinds_search_rules()
  hl.window_rule({
    match = { class = "^(HyprKeyBindsSearch)$" },
    float = true,
    animation = "fade"
  })
end

-- Wallpaper picker (test): WallpaperPickerFzf.sh launches kitty --class HyprWallpaperPicker
local function add_wallpaper_picker_rules()
  hl.window_rule({
    match = { class = "^(HyprWallpaperPicker)$" },
    float = true,
    animation = "fade"
  })
end

-- Terminal app launcher (Launcher.sh spawns kitty --class HyprLauncher;
-- LauncherAct.sh spawns follow-up kitty windows for root-mode actions
-- and for the directory mode's kitty+tmux session — all classed
-- distinctly so this single rule covers them all).
local function add_launcher_rules()
  hl.window_rule({
    match = { class = "^(HyprLauncher)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  hl.window_rule({
    match = { class = "^(HyprLauncherRoot)$" },
    float = true,
    animation = "fade"
  })
  hl.window_rule({
    match = { class = "^(HyprLauncherDir)$" },
    float = true,
    animation = "fade"
  })
  -- Help popup sits above the launcher (both pinned). pin = true keeps
  -- it on top even though the launcher itself is pinned.
  hl.window_rule({
    match = { class = "^(HyprLauncherHelp)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- Clipboard picker (SUPER+V) — same look as the launcher.
  hl.window_rule({
    match = { class = "^(HyprClipMenu)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- yazi file browser (SUPER+E).
  hl.window_rule({
    match = { class = "^(HyprYazi)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- Window switcher (SUPER+CTRL+S).
  hl.window_rule({
    match = { class = "^(HyprWinSwitch)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- Emoji picker (SUPER+ALT+E).
  hl.window_rule({
    match = { class = "^(HyprEmoji)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- Wallust theme picker (SUPER+T).
  hl.window_rule({
    match = { class = "^(HyprThemeChanger)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- Animation preset picker (SUPER+SHIFT+A).
  hl.window_rule({
    match = { class = "^(HyprAnimations)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- KooL Quick Settings hub (SUPER+SHIFT+E).
  hl.window_rule({
    match = { class = "^(HyprKoolQS)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- Waybar style picker (SUPER+CTRL+B).
  hl.window_rule({
    match = { class = "^(HyprWaybarStyles)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- Waybar layout picker (SUPER+ALT+B).
  hl.window_rule({
    match = { class = "^(HyprWaybarLayout)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- Power menu (CTRL+ALT+P).
  hl.window_rule({
    match = { class = "^(HyprWlogout)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
  -- btop from the SUPER+S,b app submap.
  hl.window_rule({
    match = { class = "^(HyprBtop)$" },
    float = true,
    pin = true,
    animation = "fade"
  })
end

-- ============================================
-- LOAD ALL RULES
-- ============================================

add_browser_tags()
add_notif_tags()
add_kool_tags()
add_terminal_tags()
add_email_tags()
add_project_tags()
add_screenshare_tags()
add_im_tags()
add_game_tags()
add_gamestore_tags()
add_file_manager_tags()
add_wallpaper_tags()
add_multimedia_tags()
add_settings_tags()
add_viewer_tags()
add_custom_rules()
add_dropdown_rules()
add_cheatsheet_rules()
add_keybinds_search_rules()
add_wallpaper_picker_rules()
add_launcher_rules()

-- All window rules loaded
