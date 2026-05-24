# Custom Scripts Documentation

This document catalogs all custom scripts in your Hyprland configuration that were developed/modified for your specific setup (not from upstream JaKooLit repo).

**Last Updated:** 2026-05-24 (Phase 3 Migration)

---

## Active Custom Scripts

### 1. GapControl.sh
**Location:** `~/.config/hypr/scripts/GapControl.sh`  
**Status:** ✅ ACTIVE & MAINTAINED

**Purpose:**  
Dynamically adjust window gaps (inside and outside) during runtime without restarting Hyprland.

**Features:**
- Increase gaps: `GapControl.sh inc` (adds 10px to in/out gaps)
- Decrease gaps: `GapControl.sh dec` (subtracts 10px, minimum 0)
- Reset gaps: `GapControl.sh reset` (back to 30px default)
- Auto-syncs ScratchpadSyncGaps.sh when gaps change

**Keybinds:**
- `Super+=` — Increase gaps
- `Super++` — Increase gaps (alternative)
- `Super+-` — Decrease gaps
- `Super+Backspace` — Reset gaps to default

**Dependencies:**
- `jq` — Parse hyprctl JSON output
- `notify-send` — Display notifications
- `ScratchpadSyncGaps.sh` — Sync scratchpad with gaps

**Configuration:**
- Default gaps: `default_in=30`, `default_out=30` (pixels)
- Step size: `step=10` (pixels per increment)

**Integration:** Phase 1 (kept as-is, no changes needed)

---

### 2. ScratchpadSyncGaps.sh
**Location:** `~/.config/hypr/scripts/ScratchpadSyncGaps.sh`  
**Status:** ✅ ACTIVE (Conditional)

**Purpose:**  
Keep pyprland dropdown terminal position/size synchronized with current window gaps.

**Features:**
- Auto-calculates dropdown position as percentage of gaps
- Auto-calculates dropdown size as percentage of usable area
- Updates `pyprland.toml` configuration
- Restarts pyprland daemon to apply changes

**Triggered By:**
- GapControl.sh (inc/dec/reset actions)
- Manual execution: `./ScratchpadSyncGaps.sh`

**Dependencies:**
- `jq` — Parse hyprctl JSON output
- `awk` — Calculate percentages
- `sed` — Update pyprland.toml
- `pyprland` — Dropdown terminal backend (pypr command)

**Configuration:**
- Size factor width: `SIZE_FACTOR_W=55` (% of usable area)
- Size factor height: `SIZE_FACTOR_H=70` (% of usable area)

**Note on Replacement:**
- Used for **pyprland-based** dropdown terminal
- You also use **Dropterminal.sh** (upstream, uses special workspace)
- This script is still relevant because:
  - Pyprland is still used for Super+Z zoom feature
  - Gap syncing may benefit pyprland scratchpad features
  - Kept as safety measure; doesn't conflict with Dropterminal.sh

**Integration:** Phase 1 (kept as-is, called from GapControl.sh)

---

### 3. SyncTabletTransform.sh
**Location:** `~/.config/hypr/scripts/SyncTabletTransform.sh`  
**Status:** ✅ ACTIVE (Integrated)

**Purpose:**  
Synchronize XP-Pen tablet rotation with monitor profile rotation.

**Features:**
- Reads `monitors.conf` for monitor transform settings
- Sets tablet transform to match monitor rotation:
  - Monitor 270° (transform 3) → Tablet 90° (transform 1)
  - Monitor 90° (transform 1) → Tablet 90° (transform 1)
  - Other → Tablet 0° (transform 0)

**Triggered By:**
- **MonitorProfiles.sh** — Runs after user selects new monitor profile
- Previously ran at Hyprland startup (inefficient, now removed)
- Manual execution: `./SyncTabletTransform.sh`

**Dependencies:**
- `grep` — Search monitors.conf for transform values
- `hyprctl` — Set tablet transform dynamically

**Configuration:**
- Monitor profiles: `~/.config/hypr/Monitor_Profiles/`
- Currently available: `default.conf`, `default_90.conf`, `default_270.conf`

**Phase 1 Changes:**
- Removed from `Startup_Apps.conf` (only ran at boot)
- Added to `MonitorProfiles.sh` (runs when profile changes)
- **Benefit:** Now responds immediately to profile switches, not just startup

**Integration:** Phase 1 (moved to MonitorProfiles.sh, improved timing)

---

## Deprecated Scripts (Kept for Reference)

### ToggleDropdownTerminal.sh
**Location:** `~/.config/hypr/scripts/ToggleDropdownTerminal.sh`  
**Status:** ❌ DEPRECATED (Phase 1)

**Reason for Deprecation:**
- Replaced by upstream's `Dropterminal.sh` (more features)
- Old approach: Moved window between workspace 99 and current
- New approach: Uses special:scratchpad with animation and gap awareness

**What Changed:**
- Keybind `Super+Shift+Return` still works (now calls `Dropterminal.sh $term`)
- Old script archived with deprecation notice
- Can be safely deleted if you don't need the code for reference

**Migration Path:**
- Uses `open-alacritty.sh` wrapper just like old version
- Supports same terminal (alacritty)
- Integrates with new `Dropterminal.sh` upstream features

---

## Summary Table

| Script | Status | Purpose | Maintained By |
|--------|--------|---------|---|
| GapControl.sh | ✅ Active | Dynamic gap adjustment | User (custom) |
| ScratchpadSyncGaps.sh | ✅ Active | Pyprland position/size sync | User (custom) |
| SyncTabletTransform.sh | ✅ Active | Tablet rotation sync | User (custom) → Integrated into MonitorProfiles.sh |
| ToggleDropdownTerminal.sh | ❌ Deprecated | Old dropdown terminal | Archived (replaced by Dropterminal.sh) |

---

## Future Maintenance Notes

### If you upgrade to new Hyprland version:
- Check pyprland compatibility with ScratchpadSyncGaps.sh
- Verify GapControl.sh works with hyprctl changes
- Test tablet transform with new tablet driver updates

### If you add new custom features:
- Document in this file
- Add clear comments in the script
- Note any dependencies (especially external tools like `jq`, `awk`)
- Consider adding keybinds to UserKeybinds.conf with descriptions

### Before deleting any script:
- Check all references in:
  - `configs/Keybinds.conf` (default keybinds)
  - `UserConfigs/UserKeybinds.conf` (your keybinds)
  - Other scripts that might call it
- Consider if it's called by Hyprland exec-once or keybinds

---

## Testing & Verification

To verify all custom scripts are working:

```bash
# Check syntax
bash -n ~/.config/hypr/scripts/GapControl.sh
bash -n ~/.config/hypr/scripts/ScratchpadSyncGaps.sh
bash -n ~/.config/hypr/scripts/SyncTabletTransform.sh

# Test GapControl
~/.config/hypr/scripts/GapControl.sh inc      # Should increase gaps + notify
~/.config/hypr/scripts/GapControl.sh reset    # Should reset gaps to 30px

# Test tablet sync
~/.config/hypr/scripts/SyncTabletTransform.sh # Check current tablet transform

# Test from MonitorProfiles
~/.config/hypr/scripts/MonitorProfiles.sh    # Select a profile with rotation
```

---

**End of Custom Scripts Documentation**
