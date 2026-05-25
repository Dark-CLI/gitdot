-- Gap Control Helper
-- Manages dynamic gap adjustment with notifications
-- Replaces: scripts/GapControl.sh + scripts/ScratchpadSyncGaps.sh

local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"

local gap_control = {}

function gap_control.increment()
  -- Get current gaps
  local gaps_in = hl.config().general.gaps_in
  local gaps_out = hl.config().general.gaps_out

  -- Increment by 10
  local new_gaps = gaps_in + 10

  -- Update Hyprland config
  hl.config({
    general = {
      gaps_in = new_gaps,
      gaps_out = new_gaps
    }
  })

  -- Notify user
  hl.exec_cmd("notify-send 'Gaps' 'Set to: " .. new_gaps .. "'")

  -- Sync scratchpad (dropdown terminal)
  gap_control.sync_scratchpad()
end

function gap_control.decrement()
  -- Get current gaps
  local gaps_in = hl.config().general.gaps_in
  local gaps_out = hl.config().general.gaps_out

  -- Decrement by 10, minimum 0
  local new_gaps = math.max(0, gaps_in - 10)

  -- Update Hyprland config
  hl.config({
    general = {
      gaps_in = new_gaps,
      gaps_out = new_gaps
    }
  })

  -- Notify user
  hl.exec_cmd("notify-send 'Gaps' 'Set to: " .. new_gaps .. "'")

  -- Sync scratchpad (dropdown terminal)
  gap_control.sync_scratchpad()
end

function gap_control.reset()
  -- Reset to default (30px)
  local default_gaps = 30

  -- Update Hyprland config
  hl.config({
    general = {
      gaps_in = default_gaps,
      gaps_out = default_gaps
    }
  })

  -- Notify user
  hl.exec_cmd("notify-send 'Gaps' 'Reset to: " .. default_gaps .. "'")

  -- Sync scratchpad (dropdown terminal)
  gap_control.sync_scratchpad()
end

function gap_control.sync_scratchpad()
  -- Call bash script to update pyprland.toml and reposition dropdown terminal
  -- The script handles updating the scratchpad position based on current gaps
  hl.exec_cmd(SCRIPTS .. "/ScratchpadSyncGaps.sh")
end

return gap_control
