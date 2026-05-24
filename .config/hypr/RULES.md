# Migration Rules & Constraints

These rules apply to all phases of the Hyprland dotfiles migration. They ensure consistency, safety, and preserve your customizations while integrating upstream improvements.

---

## Rule 1: Personal Settings Are Inviolable
**Never overwrite or remove personal settings without explicit approval.**

**What counts as personal:**
- Device/monitor names (e.g., `DP-2`, `HDMI-1`)
- Specific keyboard layouts or input configurations (e.g., `kb_layout = us,ara`)
- Local file paths (e.g., `$HOME/Pictures/wallpapers`)
- Application choices (terminal, file manager, editor)
- Hardware-specific settings (tablet transform, touchpad behavior)
- Custom color schemes or animation presets

**How to apply:**
- When merging, keep the user's value in place
- If upstream has a new default, add upstream's value as a commented alternative
- Always preserve the working, tested version

**Example:**
```
# User's setting (KEEP THIS)
kb_layout = us,ara
# Upstream default (for reference):
# kb_layout = us
```

---

## Rule 2: Upstream Features Come In As-Is
**New features from upstream are integrated unchanged, not skipped or modified.**

**What this means:**
- New keybinds are added to the config
- New settings are included
- New scripts are copied as provided
- User is not forced to use them but they're available

**How to apply:**
- Don't "improve" or customize upstream code before committing it
- Don't skip features because "they might not work for this setup"
- Add new keybinds even if the user already has a keybind for that action
- Let user decide which version to use (user's custom vs. upstream's standard)

**Example:**
```
# NEW upstream keybind (ALWAYS ADD)
bindd = $mainMod, T, Global theme switcher using Wallust, exec, $scriptsDir/ThemeChanger.sh

# User's existing different keybind for similar function (KEEP BOTH)
bindd = $mainMod, H, help / cheat sheet, exec, $scriptsDir/KeyHints.sh
```

---

## Rule 3: Upstream Comments Stay Commented
**Commented-out options in upstream files must stay commented in merged files.**

**What this means:**
- If upstream has `#env = LIBVA_DRIVER_NAME,nvidia` (commented), keep it commented
- Don't uncomment settings unless you're certain they're needed
- Add new commented options as full blocks, maintaining upstream's structure

**How to apply:**
- When a new commented option appears in upstream, add it as a commented block
- Add a note explaining what it is and when it might be needed
- Never assume a commented line is "deprecated" or "wrong"

**Example:**
```
# User's active setting:
misc {
  enable_swallow = true
  swallow_regex = ^(alacritty)$
}

# Upstream alternative (for kitty users, KEEP COMMENTED):
# misc {
#   enable_swallow = off
#   swallow_regex = ^(kitty)$
# }
```

---

## Rule 4: Each Phase Gets a Git Restore Point
**Create a commit at the start of each implementation phase as a restore point.**

**What this means:**
- Before modifying files in a phase, create a commit with a clear message
- The commit should be on a clean working tree (except files about to be changed)
- Include the phase number and goal in the commit message

**How to apply:**
- Use descriptive commit messages: `phase(1): fix keybind syntax and script names`
- Include rationale if complex: `phase(1): fix: update setprop syntax for Hyprland 0.51 compatibility`
- Never amend or squash phases together—each phase is a distinct checkpoint

**Example:**
```
git commit -m "phase(1): fix keybind syntax and script names"
git commit -m "phase(2): integrate upstream features (v2.3.20)"
git commit -m "phase(3): clean up custom scripts"
git commit -m "phase(4): verify personal settings preserved"
```

---

## Rule 5: Ambiguous Settings Require Explicit Review
**If a setting could be either personal customization or upstream feature, flag it for review.**

**What counts as ambiguous:**
- Settings that exist in both user and upstream but with different values
- Settings where the difference could be preference-based (e.g., animation speed)
- Scripts with similar names but different purposes

**How to apply:**
- When unsure, add a comment in the code flagging the decision point
- Include the reason for the flag and what options exist
- Wait for explicit user direction before choosing
- Document the user's decision for future reference

**Example:**
```
# FLAGGED: User has custom animations, upstream has different defaults
# User choice: Keep custom "Fast" preset or switch to upstream's standard animations?
# Current decision: Keep custom (user preference)
# To revert: See /tmp/jakoolit-dots/config/hypr/UserConfigs/UserAnimations.conf

animations {
  enabled = true
  # ... user's custom beziers ...
}
```

---

## Rule 6: No Unilateral Changes to Unclear Settings
**If you can't determine whether something is personal or upstream, ask first.**

**What this applies to:**
- Settings with no clear "source" comment
- Customizations that might be workarounds for specific hardware
- Scripts that might be solving local problems

**How to apply:**
- When unsure if something is personal, check git blame or recent commits
- If still unclear, flag it with a comment and ask
- Default to "preserve" when in doubt
- Document assumptions in commit messages

**Example:**
```
# FLAGGED FOR REVIEW: This was added in commit abc123 for reason unclear.
# Possible interpretations:
# A) Workaround for specific hardware/setup
# B) Upstream feature user customized
# Decision: [WAITING FOR USER INPUT]
exec-once = $scriptsDir/SyncTabletTransform.sh
```

---

## Rule 7: Test Before Declaring Phase Done
**Don't mark a phase as complete without testing the actual functionality.**

**What this means:**
- If you change keybinds, verify they execute
- If you integrate a script, verify it runs without errors
- If you modify startup apps, verify they launch
- If you change settings, verify Hyprland parses them without warnings

**How to apply:**
- Use `hyprctl` commands to validate syntax
- Check Hyprland logs for warnings/errors: `journalctl -u hyprland --lines=100`
- For UI changes, verify visually in a Hyprland session if possible
- Document test results in commit message

**Example:**
```
# Verify syntax
hyprctl reload  # or check -c if implemented

# Check for startup warnings
journalctl -u hyprland -n 50

# Confirm keybinds work
# Manually test: Super+D should open rofi
```

---

## Rule 8: Keep Personal Scripts, Question Redundancy
**User's custom scripts are preserved, but check for duplication with upstream.**

**What this means:**
- Never delete a user script without understanding its purpose
- If upstream adds a similar script, keep both but document the difference
- If they're truly redundant, flag for user review (don't delete unilaterally)

**How to apply:**
- When you find user script X and upstream script X-similar:
  - Check if they do the same thing (compare code/docs)
  - If identical or near-identical, flag for deprecation
  - If different (even subtly), document the difference
  - Wait for user approval before removing anything

**User scripts to preserve:**
- `GapControl.sh`
- `ScratchpadSyncGaps.sh`
- `SwitchKeyboardLayout.sh` (possible deprecation candidate vs upstream's `KeyboardLayout.sh`)
- `SyncTabletTransform.sh`
- `ToggleDropdownTerminal.sh`

---

## Rule 9: Document All Decisions
**Every non-obvious choice gets a comment in code or in the commit message.**

**What this means:**
- If you chose to keep user's setting over upstream's, say why
- If you merged two similar keybinds, explain the decision
- If you flagged something for review, explain the ambiguity

**How to apply:**
- Add inline comments for complex decisions
- Use detailed commit messages (not just file names, explain reasoning)
- Reference this document when applicable: "Per RULES.md Rule X, ..."

**Example:**
```
# PRESERVED per personal settings rule: User's Arabic keyboard layout
# Upstream only has: kb_layout = us
# User has: kb_layout = us,ara with grp:alt_shift_toggle toggle
# Decision: Keep user's version (confirmed working for 2+ years)

kb_layout = us,ara
kb_options = grp:alt_shift_toggle
```

---

## Rule 10: Commit Atomically, Not in Bulk
**Each significant functional change gets its own commit, not a single "mega-commit" at phase end.**

**What this means:**
- If you fix 3 keybinds, 3 commits (or 1 per file if they're independent)
- If you integrate a new script and add a keybind for it, that's 1 commit with both changes
- If you update a config file, add its dependent script, that's 1 commit

**How to apply:**
- Commits should be reviewable: "git show" should make sense
- If a commit message needs "and also..." more than once, split it
- Related changes (file + corresponding keybind) can be 1 commit
- Phase restore points are separate from functional commits

**Example:**
```
# GOOD: Focused, related changes
git add configs/Keybinds.conf
git add scripts/KeyboardLayout.sh  
git commit -m "phase(2): add new KeyboardLayout.sh script and integrate upstream keybind"

# AVOID: Too many unrelated things
git commit -m "phase(2): update keybinds, animations, and window rules"
```

---

## Summary: Decision Tree

When unsure what to do, use this order:

1. **Is it a personal setting?** (Rule 1) → Keep it, add upstream as comment
2. **Is it a new upstream feature?** (Rule 2) → Add it, don't skip
3. **Is the upstream version commented out?** (Rule 3) → Keep it commented
4. **Is it ambiguous?** (Rule 5) → Flag for review, don't decide unilaterally
5. **Could it break something?** (Rule 7) → Test before marking done
6. **Is it a user script?** (Rule 8) → Preserve it, check for redundancy
7. **Would someone question this change?** (Rule 9) → Add a comment explaining it
8. **Could this commit be split?** (Rule 10) → Split it, keep commits focused

If none of these clearly apply, **flag it for user review** rather than guessing.

---

## Escalation Path

If you encounter something that violates these rules or you're genuinely unsure:

1. **Flag it in code** with a clear comment explaining the ambiguity
2. **Document the options** in the comment (what could be done)
3. **Pause at that point** and summarize for user review
4. **Wait for explicit guidance** before proceeding

This is more valuable than making a wrong guess and having to undo work.
