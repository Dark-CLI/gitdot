-- Monitor Configuration
-- Set display modes, positions, and refresh rates

-- ============================================
-- AUTO-DETECTION (Default)
-- ============================================
-- Hyprland will automatically detect and configure monitors
-- using the native resolution and refresh rate.
-- No explicit configuration needed here.

-- Uncomment below to use explicit monitor configuration
-- instead of auto-detection.

-- ============================================
-- EXPLICIT MONITOR CONFIGURATION (Optional)
-- ============================================
-- Syntax: hl.monitor({
--   output = "display-name",
--   mode = "1920x1080@60",
--   position = "0x0",
--   scale = 1,
--   transform = 0,  -- 0=normal, 1=90°, 2=180°, 3=270°
--   enabled = true,
-- })

-- Example configurations (commented out):
-- hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1 })
-- hl.monitor({ output = "HDMI-1", mode = "1920x1080@60", position = "2560x0", scale = 1 })

-- ============================================
-- FALLBACK CONFIGURATION
-- ============================================
-- If Hyprland fails to detect monitors, uncomment below:
-- hl.monitor({
--   output = ",preferred,auto,auto",
-- })

-- Check current monitors with: hyprctl monitors
