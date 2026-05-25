-- Core Hyprland Configuration
-- General settings, decorations, input configuration

hl.config({
  -- ============================================
  -- GENERAL SETTINGS
  -- ============================================
  general = {
    gaps_in = 30,
    gaps_out = 30,
    border_size = 2,
    "col.active_border" = "rgb(d8d8d8)",
    "col.inactive_border" = "rgb(1a1a1a)",
    layout = "dwindle",
    allow_tearing = false,
    resize_on_border = true,
  },

  -- ============================================
  -- DECORATION SETTINGS
  -- ============================================
  decoration = {
    rounding = 5,
    active_opacity = 1.35,
    inactive_opacity = 1.35,
    fullscreen_opacity = 1.0,

    -- Blur configuration
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
      optimized = true,
      popups = true,
    },

    -- Shadow configuration
    shadow = {
      enabled = true,
      range = 3,
      render_power = 1,
      color = "rgba(00000080)",
      color_inactive = "rgba(00000040)",
    },

    -- Dimming configuration
    dim_inactive = true,
    dim_strength = 0.1,
    dim_special = 0.8,
  },

  -- ============================================
  -- GROUP CONFIGURATION
  -- ============================================
  group = {
    groupbar = {
      font_family = "JetBrainsMono Nerd Font",
      font_size = 10,
      "col.textActive" = "rgb(d8d8d8)",
      "col.textInactive" = "rgb(6b6b6b)",
    },
    "col.border_active" = "rgb(f8f8f8)",
    "col.border_inactive" = "rgb(6b6b6b)",
  },

  -- ============================================
  -- DWINDLE LAYOUT SETTINGS
  -- ============================================
  dwindle = {
    pseudotile = true,
    preserve_split = true,
    smart_split = false,
    smart_resizing = true,
  },

  -- ============================================
  -- MASTER LAYOUT SETTINGS
  -- ============================================
  master = {
    new_status = "slave",
    new_on_top = false,
    mfact = 0.55,
    orientation = "left",
  },

  -- ============================================
  -- INPUT CONFIGURATION
  -- ============================================
  input = {
    kb_layout = "us,ara",
    kb_options = "grp:alt_shift_toggle",
    kb_variant = "",
    kb_model = "",
    kb_rules = "",

    follow_mouse = 1,
    float_switch_override_focus = 1,
    mouse_refocus = true,

    sensitivity = 0.0,
    accel_profile = "adaptive",
    force_no_accel = false,

    -- Numlock enabled by default
    numlock_by_default = true,

    -- Repeat rate
    repeat_delay = 300,
    repeat_rate = 50,

    -- Touchpad configuration
    touchpad = {
      natural_scroll = false,
      disable_while_typing = true,
      tap_button_map = "lmr",
      drag_lock = false,
      middle_button_emulation = true,
      tap_and_drag = false,
      scroll_factor = 1.0,
    },
  },

  -- ============================================
  -- DEVICE SPECIFIC CONFIGURATION
  -- ============================================
  device = {
    -- Tablet configuration (XP-Pen)
    ["wacom-hid-5024-pen"] = {
      enabled = true,
      output = "auto",
      transform = 0,
    },

    -- Additional device configs can be added here
    -- Example: ["device-name"] = { sensitivity = 0.5 }
  },

  -- ============================================
  -- RENDER CONFIGURATION
  -- ============================================
  render = {
    explicit_sync = 1,
    explicit_sync_kms = 0,
    direct_scanout = true,
  },

  -- ============================================
  -- XWayland CONFIGURATION
  -- ============================================
  xwayland = {
    use_nearest_neighbor = true,
    force_zero_scaling = false,
  },

  -- ============================================
  -- DEBUG CONFIGURATION
  -- ============================================
  debug = {
    damage_blink = false,
    overlay = false,
    damage_tracking = 2,
  },

  -- ============================================
  -- MISC SETTINGS
  -- ============================================
  misc = {
    vrr = 1,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    animate_manual_resizes = true,
    mouse_move_focuses_monitor = true,
    focus_on_activate = true,
    always_follow_on_dnd = true,
    layers_hog_keyboard_focus = true,
    allow_session_lock_restore = true,
  },

  -- ============================================
  -- CURSOR CONFIGURATION
  -- ============================================
  cursor = {
    zoom_factor = 1.0,
    zoom_rigid = false,
    no_hardware_cursors = false,
    min_refresh_rate = 24,
    enable_hyprcursor = true,
  },
})
