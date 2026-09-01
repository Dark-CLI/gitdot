-- Workspace distribution: 5,6,7 on LG | 1,2,3,4,8,9,10 on ASUS
-- Last updated: 2026-09-01

local LG = "HDMI-A-2"      -- Secondary monitor (left, portrait)
local ASUS = "DP-2"         -- Primary monitor (right)

-- Secondary monitor (LG - left, portrait)
hl.workspace_rule({ workspace = "5", monitor = LG })
hl.workspace_rule({ workspace = "6", monitor = LG })
hl.workspace_rule({ workspace = "7", monitor = LG })

-- Primary monitor (ASUS - right)
hl.workspace_rule({ workspace = "1", monitor = ASUS })
hl.workspace_rule({ workspace = "2", monitor = ASUS })
hl.workspace_rule({ workspace = "3", monitor = ASUS })
hl.workspace_rule({ workspace = "4", monitor = ASUS })
hl.workspace_rule({ workspace = "8", monitor = ASUS })
hl.workspace_rule({ workspace = "9", monitor = ASUS })
hl.workspace_rule({ workspace = "10", monitor = ASUS })
