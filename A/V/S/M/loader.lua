local state = { alive = true, enabled = false, mode = 0, maxVotes = 0 }

local game_ref = game
local workspace_ref = workspace
local Vector3_new = Vector3.new
local Vector3_zero = Vector3.zero
local CFrame_new = CFrame.new
local math_abs = math.abs
local math_huge = math.huge
local math_random = math.random
local math_floor = math.floor
local tonumber_fn = tonumber
local str_lower = string.lower
local str_find = string.find
local str_sub = string.sub
local str_match = string.match
local str_gsub = string.gsub
local table_create = table.create
local task_wait = task.wait
local task_spawn = task.spawn
local pcall_fn = pcall

local Players = game_ref:GetService("Players")
local player = Players.LocalPlayer

local ORDER = {
	"Manor",
	"House 2",
	"Office 3",
	"Hospital 3",
	"Bank 2",
	"Vampire's Castle",
	"Mansion 2",
	"WorkPlace",
	"Hotel 2",
	"Farm House",
	"Police Station",
	"Factory",
	"Bio Lab",
	"Research Facility",
	"Mil Base",
}
local orderLen = #ORDER
local fallbackRank = (orderLen * 2) + 1
local RANK_SMALL = {}
local RANK_BIG = {}
local BASE_KEYS = table_create(orderLen)
local SHORT_KEYS = table_create(orderLen)

for i = 1, orderLen do
	local full = str_gsub(str_lower(ORDER[i]), "-", " ")
	local parenPos = str_find(full, " (", 1, true)
	local base = parenPos and str_sub(full, 1, parenPos - 1) or full
	local stripped = str_match(base, "^(.-)%s+%d+$") or base
	RANK_SMALL[full] = i
	RANK_BIG[full] = orderLen + i
	if not RANK_SMALL[base] then
		RANK_SMALL[base] = i + 0.05
		RANK_BIG[base] = orderLen + i - 0.05
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

local shared = odh_shared_plugins
local tab = shared.CreateTab("Auto Vote", "/notgatoooo/Random/refs/heads/main/Assets/map-svgrepo-com")
local section = tab:AddSection("Auto Vote", "Made by Gato 😎")

local statusLabel = nil
local function initLabel()
	local sec = section
	local sOff = STR_STATUS_OFF
	statusLabel = sec:AddLabel(sOff, true)
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

local t1On = false
local t2On = false
local t3On = false
local syncingToggles = false
local toggleSmallest = nil
local toggleBiggest = nil
local toggleRandom = nil

local function onToggleSmallest(enabled)
	local active = enabled and true or false
	t1On = active
	if syncingToggles then
		return
	end
	local s = state
	if active then
		s.mode = 1
		s.enabled = true
		local pc = pcall_fn
		syncingToggles = true
		if t2On then
			t2On = false
			local t2 = toggleBiggest
			if t2 then pc(t2) end
		end
		if t3On then
			t3On = false
			local t3 = toggleRandom
			if t3 then pc(t3) end
		end
		syncingToggles = false
	elseif s.mode == 1 then
		s.mode = 0
		s.enabled = false
		local setSt = setStatus
		local sOff = STR_STATUS_OFF
		setSt(sOff)
	end
end

local function onToggleBiggest(enabled)
	local active = enabled and true or false
	t2On = active
	if syncingToggles then
		return
	end
	local s = state
	if active then
		s.mode = 2
		s.enabled = true
		local pc = pcall_fn
		syncingToggles = true
		if t1On then
			t1On = false
			local t1 = toggleSmallest
			if t1 then pc(t1) end
		end
		if t3On then
			t3On = false
			local t3 = toggleRandom
			if t3 then pc(t3) end
		end
		syncingToggles = false
	elseif s.mode == 2 then
		s.mode = 0
		s.enabled = false
		local setSt = setStatus
		local sOff = STR_STATUS_OFF
		setSt(sOff)
	end
end

local function onToggleRandom(enabled)
	local active = enabled and true or false
	t3On = active
	if syncingToggles then
		return
	end
	local s = state
	if active then
		s.mode = 3
		s.enabled = true
		local pc = pcall_fn
		syncingToggles = true
		if t1On then
			t1On = false
			local t1 = toggleSmallest
			if t1 then pc(t1) end
		end
		if t2On then
			t2On = false
			local t2 = toggleBiggest
			if t2 then pc(t2) end
		end
		syncingToggles = false
	elseif s.mode == 3 then
		s.mode = 0
		s.enabled = false
		local setSt = setStatus
		local sOff = STR_STATUS_OFF
		setSt(sOff)
	end
end

local function onMaxVotesChanged(val)
	local s = state
	local toNum = tonumber_fn
	local flr = math_floor
	local n = toNum(val) or 0
	n = flr(n + 0.5)
	if n < 0 then
		n = 0
	elseif n > 100 then
		n = 100
	end
	s.maxVotes = n
end

toggleSmallest = section:AddToggle("Auto Vote: Smallest Map", onToggleSmallest)
toggleBiggest = section:AddToggle("Auto Vote: Biggest Map", onToggleBiggest)
toggleRandom = section:AddToggle("Auto Vote: Random Map", onToggleRandom)
section:AddSlider("Max Votes (0 = Infinite)", 0, 100, 0, onMaxVotesChanged)

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

local function resolveRanks(rawMap)
	local fb = fallbackRank
	if rawMap == "" then
		return fb, 0
	end
	local rnkS = RANK_SMALL
	local rnkB = RANK_BIG
	local cachedS = rnkS[rawMap]
	if cachedS then
		return cachedS, rnkB[rawMap]
	end
	local lower = str_lower
	local gsub = str_gsub
	local sMatch = str_match
	local sFind = str_find
	local sSub = str_sub
	local low = gsub(lower(rawMap), "-", " ")
	low = sMatch(low, "^%s*(.-)%s*$") or low
	local exactS = rnkS[low]
	if exactS then
		local exactB = rnkB[low]
		rnkS[rawMap] = exactS
		rnkB[rawMap] = exactB
		return exactS, exactB
	end
	local parenPos = sFind(low, " (", 1, true)
	local clean = parenPos and sSub(low, 1, parenPos - 1) or low
	clean = sMatch(clean, "^%s*(.-)%s*$") or clean
	local bKeys = BASE_KEYS
	local oLen = orderLen
	for i = 1, oLen do
		if clean == bKeys[i] then
			local sScore = i + 0.1
			local bScore = oLen + i - 0.1
			rnkS[rawMap] = sScore
			rnkB[rawMap] = bScore
			return sScore, bScore
		end
	end
	for i = 1, oLen do
		local bk = bKeys[i]
		if sFind(clean, bk, 1, true) == 1 then
			local nxt = sSub(clean, #bk + 1, #bk + 1)
			if nxt == "" or nxt == " " then
				local sScore = i + 0.2
				local bScore = oLen + i - 0.2
				rnkS[rawMap] = sScore
				rnkB[rawMap] = bScore
				return sScore, bScore
			end
		end
	end
	local sKeys = SHORT_KEYS
	for i = 1, oLen do
		if clean == sKeys[i] then
			local sScore = i + 0.3
			local bScore = oLen + i - 0.3
			rnkS[rawMap] = sScore
			rnkB[rawMap] = bScore
			return sScore, bScore
		end
	end
	for i = 1, oLen do
		if sFind(clean, bKeys[i], 1, true) then
			local sScore = oLen + i
			local bScore = i
			rnkS[rawMap] = sScore
			rnkB[rawMap] = bScore
			return sScore, bScore
		end
	end
	rnkS[rawMap] = fb
	rnkB[rawMap] = 0
	return fb, 0
end

local function pickSmallest()
	local getP = getPads
	local getR = resolveRanks
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

local function pickBiggest()
	local getP = getPads
	local getR = resolveRanks
	local best = nil
	local bestRank = -1
	local list, count = getP()
	for i = 1, count do
		local p = list[i]
		local _, rBig = getR(p.map)
		if rBig > bestRank then
			best = p
			bestRank = rBig
		end
	end
	return best
end

local function pickRandom()
	local getP = getPads
	local rand = math_random
	local list, count = getP()
	if count > 0 then
		return list[rand(1, count)]
	end
	return nil
end

local function pickTargetPad(mode)
	if mode == 1 then
		local pSmall = pickSmallest
		return pSmall()
	elseif mode == 2 then
		local pBig = pickBiggest
		return pBig()
	elseif mode == 3 then
		local pRand = pickRandom
		return pRand()
	end
	return nil
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
	local pickPad = pickTargetPad
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
	local activeMode = 0
	local votesCast = 0
	local bestTrigger = nil
	local bestGui = nil
	local bestStatusText = ""
	local lastChar = nil
	local activeChar = nil
	local activeHrp = nil
	local activeHum = nil

	while s.alive do
		if not s.enabled or s.mode == 0 then
			flowState = 0
			wait_fn(0.25)
		elseif flowState == 0 then
			if not vOpen() then
				setSt(sWaitVote)
				wait_fn(0.5)
			else
				votesCast = 0
				flowState = 1
			end
		elseif flowState == 1 then
			wait_fn(0.5)
			if not (s.enabled and vOpen()) then
				flowState = 0
			else
				local curMode = s.mode
				local best = pickPad(curMode)
				if best then
					activeMode = curMode
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
			end
		elseif flowState == 2 then
			if not bestGui or not bestGui.Parent or not bestGui.Enabled or not vOpen() then
				flowState = 0
			elseif s.mode ~= activeMode then
				flowState = 1
			else
				local maxV = s.maxVotes
				if maxV > 0 and votesCast >= maxV then
					flowState = 4
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
			end
		elseif flowState == 3 then
			wait_fn(0.25)
			if not (s.alive and s.enabled and bestGui and bestGui.Parent and bestGui.Enabled and vOpen()) then
				flowState = 0
			else
				if activeChar.Parent and activeHrp.Parent and activeHum.Health > 0 and inPad(bestTrigger, activeHrp.Position) then
					lastChar = activeChar
					votesCast = votesCast + 1
					activeHum.Health = 0
					local maxV = s.maxVotes
					if maxV > 0 and votesCast >= maxV then
						flowState = 4
					else
						flowState = 2
					end
				else
					flowState = 2
				end
			end
		elseif flowState == 4 then
			if not bestGui or not bestGui.Parent or not bestGui.Enabled or not vOpen() then
				flowState = 0
			elseif s.mode ~= activeMode then
				flowState = 1
			else
				local maxV = s.maxVotes
				if maxV == 0 or votesCast < maxV then
					flowState = 2
				else
					wait_fn(0.25)
				end
			end
		end
	end
end

task_spawn(workerThread)
