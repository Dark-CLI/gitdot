# Hyprland Migration - User Decisions Form

**Edit this file in vim and return it to confirm all options.**

---

## Section 1: Script Decisions

### 1.1 - KeyboardLayout Script Migration
**Question:** Should I migrate from your `SwitchKeyboardLayout.sh` to upstream's `KeyboardLayout.sh switch`?

**Your Options:**
- [x] A) Use upstream script (recommended, cleaner integration)
- [ ] B) Keep your custom script (if you have customizations)
- [ ] C) Keep both (with documentation)

**Your Decision:** _________________________________

---

### 1.2 - Tablet Transform Sync Bug Fix
**Question:** Your `SyncTabletTransform.sh` only runs at startup. Should I fix it to watch for monitor changes?

**Background:**
- Current: Syncs tablet rotation only on Hyprland startup
- Issue: If you change monitor profile later, tablet doesn't update
- Fix: Make it watch monitors.conf and re-sync when it changes

**Your Options:**
- [x] A) Yes, make it watch for changes (recommended) :: but will this make it run in  loop with out stoping that is wastfull and not practic the can we make it get run when the screen rotation script is called. we are only changing screen using it.
- [ ] B) No, keep startup-only (I'll document the limitation)
- [ ] C) Hybrid - watch during session, but not on every keystroke (performance-aware)

**Your Decision:** _________________________________

---

### 1.3 - Dropdown Terminal Replacement
**Question:** Replace your `ToggleDropdownTerminal.sh` with upstream's better `Dropterminal.sh`?

**Background:**
- Your current: Basic workspace toggle, no gaps awareness
- Upstream: Animation, gaps-aware positioning, special workspace, monitor-aware
- Integration: Will use your `open-alacritty.sh` wrapper with upstream's approach

**Your Options:**
- [x] A) Yes, replace it (recommended for cleaner, gaps-aware terminal)
- [ ] B) No, keep your custom script (if it works well for you)
- [ ] C) Hybrid - use upstream but keep yours as fallback

**Your Decision:** _________________________________

---

### 1.4 - Gap Settings for New Dropdown Terminal
**Question:** What gaps/positioning do you need for the dropdown terminal?

**Background:**
- Upstream uses percentage-based positioning (WIDTH_PERCENT, HEIGHT_PERCENT, Y_PERCENT, X_PERCENT)
- You mentioned: "top-left, aligned with window gaps"
- I need to calculate correct percentages to respect your custom gaps

**Provide these values:**
- Your left gap size (pixels): from my script
- Your top gap size (pixels): from my script
 Your right gap size (pixels): from my script
 Y Your bottom gap size (pixels): from my script

---

## Section 2: Animation Decisions

### 2.1 - Keep Custom "Fast" Animation Preset
**Question:** Keep your custom "Fast" animation preset or switch to upstream defaults?

**Background:**
- Your "Fast" preset is completely different from upstream
- Upstream has standard animations
- System supports multiple profiles - you can switch between them

**Your Options:**
- [ ] A) Keep "Fast" as primary, show upstream options as alternatives
- [ ] B) Switch to upstream defaults
- [ ] C) Keep both available, can switch with Super+Shift+A (Animations menu)

**Your Decision:** _________________________________

---

### 2.2 - Animation Profile Switching
**Question:** Do you want the ability to switch between animation profiles?

**Background:**
- Upstream provides `Animations.sh` script (Super+Shift+A)
- This lets you choose from different animation presets
- Your "Fast" should be one of the available options

**Your Options:**
- [x] A) Yes, enable animation switching menu (recommended) : Donot I allread have it. super + shift + A
- [ ] B) No, lock to current animation set
- [ ] C) Yes, but add my "Fast" preset to the menu as an option

**Your Decision:** _________________________________

---

## Section 3: Terminal & Alacritty

### 3.1 - Keep Alacritty as Terminal
**Question:** Confirm keeping alacritty (not switching to kitty)?

**Background:**
- You've worked hard to remove kitty from the project
- Upstream switched to kitty
- I will preserve your alacritty + swallow config, comment out kitty as alternative

**Your Options:**
- [x] A) Yes, keep alacritty (confirmed)
- [ ] B) No, switch to kitty
- [ ] C) Support both with ability to switch

**Your Decision:** _________________________________

---

### 3.2 - Alacritty Swallow Behavior
**Question:** Confirm keeping `enable_swallow = true` with alacritty?

**Background:**
- What "swallow" does: When alacritty spawns a new window, alacritty hides
- Your config: enabled for alacritty (`swallow_regex = ^(alacritty)$`)
- Benefit: Cleaner workspace, alacritty reappears when window closes

**Your Options:**
- [ ] A) Yes, keep swallow enabled for alacritty (current setting)
- [ ] B) Disable swallow
- [ ] C) Keep as-is but document the feature

**Your Decision:** It never ever work like that. so just keep it off I do not use it like that anyway.

---

## Section 4: Window Rules

### 4.1 - Accept Upstream Window Rules Changes
**Question:** Should I integrate all upstream window rule updates?

**Background:**
- Upstream added: Zed editor, btrfs-assistant, timeshift-gtk, updated Thunderbird
- Upstream removed: ZapZap (deprecated Whatsapp app)
- No conflicts with your personal rules (they're in UserConfigs)

**Your Options:**
- [x] A) Yes, accept all upstream changes (recommended)
- [ ] B) Accept only specific changes (specify below)
- [ ] C) No, keep current window rules

**Your Decision:** _________________________________

**If B (specific changes), which do you want:**
- [ ] Zed editor support
- [ ] btrfs-assistant tag
- [ ] timeshift-gtk tag
- [ ] Updated Thunderbird matching
- [ ] Remove ZapZap (deprecated)

---

## Section 5: Opacity Toggle Fix

### 5.1 - Keybind Syntax Update
**Question:** Fix the opacity toggle keybind syntax for Hyprland 0.51 compatibility?

**Background:**
- Current: `exec, hyprctl setprop active opaque toggle`
- New syntax: `setprop, active opaque toggle` (direct dispatcher, not exec)
- You said: "I do not care, fix it however you like"

**Your Options:**
- [x] A) Yes, update to new syntax (I'll handle it)
- [ ] B) No, keep current syntax
- [ ] C) Whatever works best (I'll decide)

**Your Decision:** _________________________________

---

## Section 6: Preserved Scripts

### 6.1 - Confirm Script Preservation
**Question:** Confirm which custom scripts to keep?

**Background:**
- GapControl.sh - You said: YES
- ScratchpadSyncGaps.sh - You said: YES (syncs gaps with terminal rules)
- SyncTabletTransform.sh - You said: YES (with bug fix)
- ToggleDropdownTerminal.sh - You said: REPLACE with upstream's approach

**Your Options:**
- [ ] A) Keep all as listed above
- [ ] B) Archive some (specify which)
- [ ] C) Modify list (specify changes)

**Your Decision:** We did have some notes on each one so do like how we pervusely discused

**If C, which scripts to archive/remove:**
- [ ] GapControl.sh
- [ ] ScratchpadSyncGaps.sh
- [ ] SyncTabletTransform.sh
- [ ] Other (specify): _________________________________

---

## Section 7: Version & Startup

### 7.1 - Active Startup Apps
**Question:** Confirm these are your active startup apps?

**Background:**
- swww-daemon (wallpaper)
- firefox
- Feishin.AppImage (Navidrome music player)
- SyncTabletTransform.sh (with bug fix per 1.2)

**Your Options:**
- [ ] A) Correct, keep all (confirmed)
- [ ] B) Remove some (specify)
- [ ] C) Add others (specify)

**Your Decision:** keep them all except the SyncTabletTransform we descsed this before

**If B or C, specify changes:**
- Remove: _________________________________
- Add: _________________________________

---

## Section 8: Final Confirmation

### 8.1 - Ready for Phase 1?
**Question:** Confirm all decisions above are ready for implementation?

**Your Options:**
- [x] A) Yes, all decisions confirmed - proceed with Phase 1
- [ ] B) No, I need to review/modify some answers first
- [ ] C) Yes, but with caveats (specify below)

**Your Decision:** Yes but one more thing to add to the list. the powermenue in the waybar. it's agule and broken. for eacmple the logout allways crashing my system and put it in unreposnsave state. so the menue need some love too.

**If C, specify caveats:**
```
_________________________________________________________________________
_________________________________________________________________________
_________________________________________________________________________
```

---

## Summary (For Reference)

### Files to be created/modified in Phase 1:
- Fix keybind syntax (opacity toggle)
- Integrate/rename KeyboardLayout.sh
- Fix SyncTabletTransform.sh
- Replace ToggleDropdownTerminal.sh

### Files to preserve as-is:
- GapControl.sh
- ScratchpadSyncGaps.sh
- open-alacritty.sh
- All personal keyboard/animation settings

### Window rules:
- Merge upstream changes (no conflicts)

---

## Instructions for Vim Editing

1. Save this file: Already at `/home/max/gitdot/.claude/MIGRATION_DECISIONS.md`
2. Open in vim: `vim /home/max/gitdot/.claude/MIGRATION_DECISIONS.md`
3. Edit each section - REPLACE `_________________________________` with your choice
4. For checkboxes: Change `[ ]` to `[x]` for your selections
5. Save and exit: `:wq`
6. Return this form to me in the conversation

---

**Once you return this completed form, I will confirm all your options and begin Phase 1.**
