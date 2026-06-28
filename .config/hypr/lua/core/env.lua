-- Environment Variables
-- Set before Display Server initialization

-- Cursor configuration
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Default editor (used by Kool_Quick_Settings.sh and other scripts)
hl.env("EDITOR", "nvim")

-- Prepend ~/.local/bin so locally-built tools win over /usr/bin.
-- Currently needed for the patched waybar from source (Hyprland 0.55 IPC
-- dispatcher fix, PR #5013) since Fedora still ships waybar 0.15.0.
-- TODO: remove once Fedora packages waybar > 0.15.0.
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or "/usr/local/bin:/usr/bin"))

-- Qt configuration (optional - uncomment if needed)
-- hl.env("QT_STYLE_OVERRIDE", "kvantum")
-- hl.env("QT_QPA_PLATFORM_THEME", "qt5ct")

-- Other environment variables can be added here
-- These are set before the compositor initializes
