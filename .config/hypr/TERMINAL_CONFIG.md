# Terminal Configuration

## Change Terminal in One Place

To switch between terminals (kitty, alacritty, foot, etc.), edit **only this file**:

```bash
~/.config/hypr/UserConfigs/01-UserDefaults.conf
```

Change the `$term` variable:

```bash
# Current setting:
$term = kitty

# To switch to alacritty:
$term = alacritty

# To switch to foot:
$term = foot
```

Then reload Hyprland:
```bash
hyprctl reload
```

## What This Controls

The `$term` variable in `01-UserDefaults.conf` controls:
- ✅ Default terminal for `Super+Return` (regular terminal window)
- ✅ Dropdown terminal for `Super+Shift+Return`
- ✅ Terminal opened from scripts and keybinds
- ✅ Fallback terminal for various Hyprland features

## How It Works

All scripts that need a terminal call the `get-terminal.sh` helper:

```bash
TERMINAL=$(~/.config/hypr/scripts/get-terminal.sh)
```

This reads the `$term` variable from Hyprland's active config, ensuring a single source of truth.

---

**Change only `01-UserDefaults.conf` - that's it!**
