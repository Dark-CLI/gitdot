# Hyprland Dotfiles Migration Plan

**Current Status:** v2.3.19 → v2.3.20 (upstream)  
**Hyprland Version:** 0.51.1  
**Audit Date:** 2026-05-24

---

## Phase 0: Audit & Snapshot
**Goal:** Document current state and create restore points  
**Definition of Done:** Clean git history with restore points before any changes

### Tasks
- [x] Clone latest JaKooLit/Hyprland-Dots (commit c093e836)
- [x] Audit both configs thoroughly
- [ ] Create initial backup commit (already exists: 2b2f612)
- [ ] Verify pre-migration snapshot is clean

### Files Involved
- `.git/` — version control
- All `.config/hypr/` files

---

## Phase 1: Fix Actively Broken Things
**Goal:** Address any broken functionality and version-specific issues  
**Definition of Done:** All keybinds work, no syntax errors, all startup apps function

### Identified Issues to Fix
1. **Keybind syntax changes** — User's `bindd = $mainMod CTRL, O, toggle active window opacity, exec, hyprctl setprop active opaque toggle` needs to be updated to new dispatcher syntax: `setprop, active opaque toggle`
2. **Script name changes** — `SwitchKeyboardLayout.sh` → `KeyboardLayout.sh switch` (need to update keybind and create wrapper or rename)
3. **Animation syntax validation** — User's custom "Fast" animation preset uses `enabled = true` format, verify Hyprland 0.51.1 accepts this
4. **Missing upstream keybind** — Theme switcher keybind is missing (Super+T for Wallust integration)
5. **Enable/disable syntax** — Verify `enable_swallow = off` vs `enable_swallow = true` (user uses alacritty, upstream uses kitty)

### Files Involved
- `configs/Keybinds.conf` — Fix dispatcher syntax
- `UserConfigs/UserKeybinds.conf` — Check for custom keybinds that need syntax updates
- Custom scripts directory

### Definition of Done
- All keybinds execute without error
- Window rules parse correctly
- No Hyprland startup warnings related to syntax
- All startup apps launch successfully

---

## Phase 2: Integrate Upstream Features
**Goal:** Bring in new upstream features without breaking customizations  
**Definition of Done:** All upstream improvements integrated, personal settings preserved

### New Features from Upstream
1. **New settings in SystemSettings.conf**
   - `on_focus_under_fullscreen = 1` (Hyprland 0.53+ compatibility)
   - Verify gesture settings are up-to-date
   
2. **Enhanced Keybinds**
   - New theme switcher: `bindd = $mainMod, T, Global theme switcher using Wallust, exec, $scriptsDir/ThemeChanger.sh`
   - Precise volume controls: `ALT + xf86audioraisevolume/lowervolume` for fine-grained adjustments
   - Updated layout initialization: `exec-once = $scriptsDir/ChangeLayout.sh init`

3. **New Scripts/Features**
   - `ThemeChanger.sh` (new upstream feature for wallust integration)
   - Enhanced `KeyboardLayout.sh` (replacement for user's `SwitchKeyboardLayout.sh`)
   - `hyprlock-2k.conf` (new resolution profile)

4. **Window Rules Updates**
   - Upstream has expanded `WindowRules.conf` (216 lines vs user's 180)
   - Pre-53 version still needed for compatibility with older Hyprland

### Files Involved
- `configs/SystemSettings.conf` — Add new settings as commented blocks where Hyprland version < 0.53
- `configs/Keybinds.conf` — Merge upstream keybinds while keeping user customizations
- `configs/ENVariables.conf` — Version bumped to 2.3.20
- `scripts/ThemeChanger.sh` — Copy from upstream (new)
- `scripts/KeyboardLayout.sh` — Copy from upstream (replaces SwitchKeyboardLayout.sh)
- `hyprlock-2k.conf` — Add from upstream (new)

### Definition of Done
- All upstream keybinds are available (user can choose to use them)
- New window rules are integrated
- No conflicts between user and upstream keybinds
- Theme switcher works with wallust
- Precise volume controls available

---

## Phase 3: Clean Up & Consolidate Custom Scripts
**Goal:** Rationalize user's custom scripts and decide on keybind placement  
**Definition of Done:** Clear ownership of all scripts, deprecations documented

### User's Custom Scripts (not in upstream)
1. **GapControl.sh** — Custom script, check if used and document its purpose
2. **ScratchpadSyncGaps.sh** — Custom script, check if used and document its purpose  
3. **SwitchKeyboardLayout.sh** — Candidate for replacement with upstream's `KeyboardLayout.sh`
4. **SyncTabletTransform.sh** — Custom for tablet rotation, used by startup script
5. **ToggleDropdownTerminal.sh** — Custom dropdown terminal, used by keybind and user keybinds

### Review Questions (Flag for user decision)
- Should `SwitchKeyboardLayout.sh` be deprecated in favor of upstream's `KeyboardLayout.sh switch`?
- Are `GapControl.sh` and `ScratchpadSyncGaps.sh` actively used or can they be archived?
- Should `ToggleDropdownTerminal.sh` be moved into UserKeybinds or stay as external script?
- Should `SyncTabletTransform.sh` remain in startup or be wrapped differently?

### Files Involved
- `scripts/` — Custom scripts inventory
- `UserConfigs/Startup_Apps.conf` — Check script dependencies
- `UserConfigs/UserKeybinds.conf` — Check keybind dependencies

### Definition of Done
- All custom scripts are documented (purpose, usage, dependencies)
- Clear deprecation path for scripts (keep with comment vs. remove vs. wrap)
- No duplicate functionality between user and upstream scripts

---

## Phase 4: Preserve Personal Settings & Finalize Merge
**Goal:** Ensure all personal settings remain intact after merge  
**Definition of Done:** Config is fully functional with all personal settings preserved

### Personal Settings to Verify (NOT to be overwritten)
1. **Keyboard Layout** — User has `kb_layout = us,ara` with `grp:alt_shift_toggle` (must preserve)
2. **Terminal** — `$term = $HOME/.config/hypr/UserScripts/open-alacritty.sh` (custom wrapper, must preserve)
3. **File Manager** — `$files = nautilus` (user choice, must preserve)
4. **Animations** — User's custom "Fast" preset (must preserve or explicitly migrate)
5. **Touchpad Settings** — Custom `natural_scroll = false`, `middle_button_emulation = true` (must preserve)
6. **Tablet Settings** — `transform = 1` (90° clockwise rotation) (must preserve)
7. **Monitor Profiles** — User's custom `default_270.conf` and `default_90.conf` (must preserve)
8. **Startup Apps** — User's custom apps (Firefox, Feishin, custom scripts) (must preserve)
9. **Editor** — `EDITOR=nvim` (must preserve)
10. **Search Engine** — Custom Google search config (must preserve)

### Settings Requiring Review (ambiguous between personal & feature)
- `enable_swallow = true` with `swallow_regex = ^(alacritty)$` vs upstream's `off` with `kitty`
  - **Action:** Keep user's alacritty config but comment upstream's kitty config as alternative
- Custom UserAnimations.conf vs upstream's suggested animations
  - **Action:** Keep user's custom animation set, but document upstream's available options

### Files to Verify
- `UserConfigs/01-UserDefaults.conf` — Contains personal defaults
- `UserConfigs/UserSettings.conf` — Contains personal Hyprland settings (currently has all custom settings)
- `UserConfigs/UserAnimations.conf` — Custom animation preset
- `UserConfigs/Startup_Apps.conf` — Personal startup apps
- `configs/ENVariables.conf` — Version bump only
- Monitor profiles directory — No changes needed
- Scripts directory — Preserve all user scripts

### Definition of Done
- All personal settings remain functional after merge
- User can still use Arabic keyboard layout with Alt+Shift
- All custom startup apps launch
- Custom animations work as before
- Alacritty remains swallowed in terminal
- Tablet transform syncs correctly
- No git conflicts or manual merges needed

---

## Phase 5: Migration to Lua (Optional/Future)
**Goal:** Evaluate and plan migration to Lua config format  
**Status:** DEFERRED (no Lua files in either version currently)  
**Definition of Done:** Lua config exists and is feature-complete with shell config

### Notes
- Neither current user nor upstream config uses Lua yet
- Hyprland v0.51.1 supports Lua, but transition not critical
- Could be tackled in future update cycle if JaKooLit releases Lua version
- Shell config is still maintainable and upstream doesn't use Lua yet

---

## Implementation Order

1. **Phase 0** — Audit complete (DONE)
2. **Phase 1** — Fix broken things first (keybind syntax, script names)
3. **Phase 2** — Integrate new upstream features
4. **Phase 3** — Clean up custom scripts (with user review)
5. **Phase 4** — Verify all personal settings preserved and finalize
6. **Phase 5** — Defer Lua migration unless upstream adopts it

---

## Key Constraints
- No personal settings will be overwritten unilaterally
- All flagged ambiguous items require user review before proceeding
- Each phase gets a restore-point commit at the start
- Upstream features come in as-is (new keybinds added, not skipped)
- Commented-out options in upstream appear as commented blocks, never uncommented without reason
