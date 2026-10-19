local getgenv_fn = getgenv
local env = (getgenv_fn and getgenv_fn()) or {}
local prev = env.AutoVote
if prev then
	prev.alive = false
end

local state = { alive = true, enabled = false }
env.AutoVote = state

local game_ref = game
local workspace_ref = workspace
local Vector3_new = Vector3.new
local Vector3_zero = Vector3.zero
local CFrame_new = CFrame.new
local math_abs = math.abs
local math_huge = math.huge
local str_lower = string.lower
local str_find = string.find
local str_sub = string.sub
local str_match = string.match
local table_create = table.create
local task_wait = task.wait
local task_spawn = task.spawn
local pcall_fn = pcall

local Players = game_ref:GetService("Players")
local player = Players.LocalPlayer

local ORDER = {
	"House 2",
	"Hospital 3",
	"Haunted House (Retro)",
	"Barn (Infection)",
	"Mineshaft",
	"Office 3",
	"Workplace",
	"Bank 2",
	"Manor",
	"Police Station",
	"Spaceship",
	"Vampire's Castle",
	"Hotel 2",
	"Research Facility",
	"Mansion 2",
	"Factory",
	"Mil-Base",
	"Bio Lab",
}
local orderLen = #ORDER
local fallbackRank = orderLen + 1
local RANK = {}
local BASE_KEYS = table_create(orderLen)
local SHORT_KEYS = table_create(orderLen)

for i = 1, orderLen do
	local full = str_lower(ORDER[i])
	local parenPos = str_find(full, " (", 1, true)
	local base = parenPos and str_sub(full, 1, parenPos - 1) or full
	local stripped = str_match(base, "^(.-)%s+%d+$") or base
	RANK[full] = i
	if not RANK[base] then
		RANK[base] = i
	end
	BASE_KEYS[i] = base
	SHORT_KEYS[i] = stripped
end

local STR_STATUS_OFF = "Off"
local STR_WAIT_VOTE = "Waiting for vote"
local STR_NO_PADS = "No vote pads found"
local STR_VOTING_PREFIX = "Voting: "
local STR_LOBBY = "Lobby"
local STR_VOTEPADS = "VotePads"
local PAD_NAMES = { "VotePad1", "VotePad2", "VotePad3" }
local STR_PAD = "Pad"
local STR_VGUI = "VoteInfoGui"
local STR_CONTAINER = "Container"
local STR_MAPNAME = "MapName"
local STR_HRP = "HumanoidRootPart"
local STR_HUM = "Humanoid"

local shared = odh_shared_plugins or env.odh_shared_plugins
local tab = shared.CreateTab("Auto Vote", "/notgatoooo/Random/refs/heads/main/A/V/S/M/updater.lua")
local section = tab:AddSection("Auto Vote", "Made by Gato 😎")

local statusLabel = nil
local function initLabel()
	statusLabel = section:AddLabel(STR_STATUS_OFF, true)
end
pcall_fn(initLabel)

local lastStatusText = STR_STATUS_OFF

local function applyStatusLabel()
	local lbl = statusLabel
	if lbl then
		lbl:SetValue(lastStatusText)
	end
end

local function setStatus(txt)
	local prevTxt = lastStatusText
	if prevTxt ~= txt then
		lastStatusText = txt
		local pc = pcall_fn
		local app = applyStatusLabel
		pc(app)
	end
end

local function onToggle(enabled)
	local s = state
	local active = enabled and true or false
	s.enabled = active
	if not active then
		local setSt = setStatus
		local sOff = STR_STATUS_OFF
		setSt(sOff)
	end
end

section:AddToggle("Auto Vote: Smallest Map", onToggle)

local pads = nil
local padPool = table_create(3)
for i = 1, 3 do
	padPool[i] = { pad = nil, trigger = nil, gui = nil, map = "" }
end

local function getPads()
	local pool = padPool
	local pFolder = pads
	if not pFolder or not pFolder.Parent then
		local ws = workspace_ref
		local sLobby = STR_LOBBY
		local sVp = STR_VOTEPADS
		local lobby = ws:FindFirstChild(sLobby)
		pFolder = lobby and lobby:FindFirstChild(sVp)
		pads = pFolder
		if not pFolder then
			return pool, 0
		end
	end
	local pNames = PAD_NAMES
	local sPad = STR_PAD
	local sVgui = STR_VGUI
	local sCont = STR_CONTAINER
	local sMap = STR_MAPNAME
	local count = 0
	for i = 1, 3 do
		local pad = pFolder:FindFirstChild(pNames[i])
		if pad then
			local trigger = pad:FindFirstChild(sPad)
			local vgui = pad:FindFirstChild(sVgui)
			if trigger and vgui then
				local cont = vgui:FindFirstChild(sCont)
				local nameObj = cont and cont:FindFirstChild(sMap)
				if nameObj then
					count = count + 1
					local entry = pool[count]
					entry.pad = pad
					entry.trigger = trigger
					entry.gui = vgui
					entry.map = nameObj.Text
				end
			end
		end
	end
	return pool, count
end

local function votingOpen()
	local getP = getPads
	local list, count = getP()
	for i = 1, count do
		if list[i].gui.Enabled then
			return true
		end
	end
	return false
end

local function resolveRank(rawMap)
	local fb = fallbackRank
	if rawMap == "" then
		return fb
	end
	local lower = str_lower
	local rnk = RANK
	local low = lower(rawMap)
	local r = rnk[low]
	if r then
		return r
	end
	local sFind = str_find
	local bKeys = BASE_KEYS
	local oLen = orderLen
	for i = 1, oLen do
		if sFind(low, bKeys[i], 1, true) then
			rnk[low] = i
			return i
		end
	end
	local sKeys = SHORT_KEYS
	for i = 1, oLen do
		if sFind(low, sKeys[i], 1, true) then
			rnk[low] = i
			return i
		end
	end
	rnk[low] = fb
	return fb
end

local function pickSmallest()
	local getP = getPads
	local getR = resolveRank
	local best = nil
	local bestRank = math_huge
	local list, count = getP()
	for i = 1, count do
		local p = list[i]
		local r = getR(p.map)
		if r < bestRank then
			best = p
			bestRank = r
		end
	end
	return best
end

local function insidePad(trigger, pos)
	local abs = math_abs
	local lp = trigger.CFrame:PointToObjectSpace(pos)
	local h = trigger.Size * 0.5
	return abs(lp.X) <= h.X and abs(lp.Y) <= h.Y and abs(lp.Z) <= h.Z
end

local function workerThread()
	local s = state
	local plrs = Players
	local plr = player
	local wait_fn = task_wait
	local vOpen = votingOpen
	local pickS = pickSmallest
	local inPad = insidePad
	local setSt = setStatus
	local cfNew = CFrame_new
	local vZero = Vector3_zero
	local offset = Vector3_new(0, 1, 0)
	local sWaitVote = STR_WAIT_VOTE
	local sNoPads = STR_NO_PADS
	local sVotePref = STR_VOTING_PREFIX
	local sHrp = STR_HRP
	local sHum = STR_HUM

	local flowState = 0
	local bestTrigger = nil
	local bestGui = nil
	local bestStatusText = ""
	local lastChar = nil
	local activeChar = nil
	local activeHrp = nil
	local activeHum = nil

	while s.alive do
		if not s.enabled then
			flowState = 0
			wait_fn(0.25)
		elseif flowState == 0 then
			if not vOpen() then
				setSt(sWaitVote)
				wait_fn(0.5)
			else
				flowState = 1
			end
		elseif flowState == 1 then
			wait_fn(0.5)
			local best = pickS()
			if best then
				bestTrigger = best.trigger
				bestGui = best.gui
				bestStatusText = sVotePref .. best.map
				lastChar = nil
				flowState = 2
			else
				setSt(sNoPads)
				wait_fn(1)
				flowState = 0
			end
		elseif flowState == 2 then
			if not bestGui or not bestGui.Parent or not bestGui.Enabled then
				flowState = 0
			else
				setSt(bestStatusText)
				if not plr then
					plr = plrs.LocalPlayer
				end
				local char = plr and plr.Character
				if char and char ~= lastChar then
					local hrp = char:FindFirstChild(sHrp)
					local hum = char:FindFirstChildOfClass(sHum)
					if hrp and hum and hum.Health > 0 then
						if not inPad(bestTrigger, hrp.Position) then
							local target = bestTrigger.Position + offset
							hrp.CFrame = cfNew(target) * hrp.CFrame.Rotation
							hrp.AssemblyLinearVelocity = vZero
						end
						activeChar = char
						activeHrp = hrp
						activeHum = hum
						flowState = 3
					else
						wait_fn(0.1)
					end
				else
					wait_fn(0.1)
				end
			end
		elseif flowState == 3 then
			wait_fn(0.25)
			if not (s.alive and s.enabled and bestGui and bestGui.Parent and bestGui.Enabled) then
				flowState = 0
			else
				if activeChar.Parent and activeHrp.Parent and activeHum.Health > 0 and inPad(bestTrigger, activeHrp.Position) then
					lastChar = activeChar
					activeHum.Health = 0
				end
				flowState = 2
			end
		end
	end
end

task_spawn(workerThread)
