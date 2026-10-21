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
local type_fn = type
local os_clock = os.clock
local str_lower = string.lower
local str_find = string.find
local str_sub = string.sub
local str_match = string.match
local str_gsub = string.gsub
local table_create = table.create
local task_wait = task.wait
local task_spawn = task.spawn
local pcall_fn = pcall
local HUM_DEAD = Enum.HumanoidStateType.Dead

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
local STR_BASEPART = "BasePart"
local STR_FUNCTION = "function"
local STR_TABLE = "table"
local STR_USERDATA = "userdata"
local LABEL_METHODS = { "SetValue", "SetText", "Set" }
local TOGGLE_METHODS = { "SetValue", "Set", "SetState" }
local SPAWN_SETTLE = 1

local function indexOf(obj, key)
	return obj[key]
end

local function callMethod(obj, names, arg)
	local t = type_fn(obj)
	if t ~= STR_TABLE and t ~= STR_USERDATA then
		return false
	end
	for i = 1, #names do
		local ok, fn = pcall_fn(indexOf, obj, names[i])
		if ok and type_fn(fn) == STR_FUNCTION then
			if pcall_fn(fn, obj, arg) then
				return true
			end
		end
	end
	return false
end

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

local function setStatus(txt)
	if lastStatusText ~= txt then
		lastStatusText = txt
		local lbl = statusLabel
		if lbl then
			callMethod(lbl, LABEL_METHODS, txt)
		end
	end
end

local t1On = false
local t2On = false
local t3On = false
local syncingToggles = false
local toggleSmallest = nil
local toggleBiggest = nil
local toggleRandom = nil

local function turnOff(toggleObj)
	if toggleObj then
		callMethod(toggleObj, TOGGLE_METHODS, false)
	end
end

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
		syncingToggles = true
		if t2On then
			t2On = false
			turnOff(toggleBiggest)
		end
		if t3On then
			t3On = false
			turnOff(toggleRandom)
		end
		syncingToggles = false
	elseif s.mode == 1 then
		s.mode = 0
		s.enabled = false
		setStatus(STR_STATUS_OFF)
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
		syncingToggles = true
		if t1On then
			t1On = false
			turnOff(toggleSmallest)
		end
		if t3On then
			t3On = false
			turnOff(toggleRandom)
		end
		syncingToggles = false
	elseif s.mode == 2 then
		s.mode = 0
		s.enabled = false
		setStatus(STR_STATUS_OFF)
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
		syncingToggles = true
		if t1On then
			t1On = false
			turnOff(toggleSmallest)
		end
		if t2On then
			t2On = false
			turnOff(toggleBiggest)
		end
		syncingToggles = false
	elseif s.mode == 3 then
		s.mode = 0
		s.enabled = false
		setStatus(STR_STATUS_OFF)
	end
end

local function onMaxVotesChanged(val)
	local s = state
	local n = tonumber_fn(val) or 0
	n = math_floor(n + 0.5)
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
		local lobby = workspace_ref:FindFirstChild(STR_LOBBY)
		pFolder = lobby and lobby:FindFirstChild(STR_VOTEPADS)
		pads = pFolder
		if not pFolder then
			return pool, 0
		end
	end
	local pNames = PAD_NAMES
	local count = 0
	for i = 1, 3 do
		local pad = pFolder:FindFirstChild(pNames[i])
		if pad then
			local trigger = pad:FindFirstChild(STR_PAD)
			local vgui = pad:FindFirstChild(STR_VGUI)
			if trigger and vgui and trigger:IsA(STR_BASEPART) then
				local cont = vgui:FindFirstChild(STR_CONTAINER)
				local nameObj = cont and cont:FindFirstChild(STR_MAPNAME)
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
	local list, count = getPads()
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
	local low = str_gsub(str_lower(rawMap), "-", " ")
	low = str_match(low, "^%s*(.-)%s*$") or low
	local exactS = rnkS[low]
	if exactS then
		local exactB = rnkB[low]
		rnkS[rawMap] = exactS
		rnkB[rawMap] = exactB
		return exactS, exactB
	end
	local parenPos = str_find(low, " (", 1, true)
	local clean = parenPos and str_sub(low, 1, parenPos - 1) or low
	clean = str_match(clean, "^%s*(.-)%s*$") or clean
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
		if str_find(clean, bk, 1, true) == 1 then
			local nxt = str_sub(clean, #bk + 1, #bk + 1)
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
		if str_find(clean, bKeys[i], 1, true) then
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
	local best = nil
	local bestRank = math_huge
	local list, count = getPads()
	for i = 1, count do
		local p = list[i]
		local r = resolveRanks(p.map)
		if r < bestRank then
			best = p
			bestRank = r
		end
	end
	return best
end

local function pickBiggest()
	local best = nil
	local bestRank = -1
	local list, count = getPads()
	for i = 1, count do
		local p = list[i]
		local _, rBig = resolveRanks(p.map)
		if rBig > bestRank then
			best = p
			bestRank = rBig
		end
	end
	return best
end

local function pickRandom()
	local list, count = getPads()
	if count > 0 then
		return list[math_random(1, count)]
	end
	return nil
end

local function pickTargetPad(mode)
	if mode == 1 then
		return pickSmallest()
	elseif mode == 2 then
		return pickBiggest()
	elseif mode == 3 then
		return pickRandom()
	end
	return nil
end

local function insidePad(trigger, pos)
	if not trigger or not trigger.Parent then
		return false
	end
	local lp = trigger.CFrame:PointToObjectSpace(pos)
	local h = trigger.Size * 0.5
	return math_abs(lp.X) <= h.X and math_abs(lp.Y) <= h.Y and math_abs(lp.Z) <= h.Z
end

local function humAlive(hum)
	if not hum or not hum.Parent or hum.Health <= 0 then
		return false
	end
	local ok, st = pcall_fn(hum.GetState, hum)
	return ok and st ~= HUM_DEAD
end

local function workerThread()
	local s = state
	local plr = player
	local wait_fn = task_wait
	local offset = Vector3_new(0, 1, 0)

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
	local seenChar = nil
	local seenTime = 0

	while s.alive do
		if not s.enabled or s.mode == 0 then
			flowState = 0
			wait_fn(0.25)
		elseif flowState == 0 then
			if not votingOpen() then
				setStatus(STR_WAIT_VOTE)
				wait_fn(0.5)
			else
				votesCast = 0
				flowState = 1
			end
		elseif flowState == 1 then
			wait_fn(0.5)
			if not (s.enabled and votingOpen()) then
				flowState = 0
			else
				local curMode = s.mode
				local best = pickTargetPad(curMode)
				if best then
					activeMode = curMode
					bestTrigger = best.trigger
					bestGui = best.gui
					bestStatusText = STR_VOTING_PREFIX .. best.map
					lastChar = nil
					flowState = 2
				else
					setStatus(STR_NO_PADS)
					wait_fn(1)
					flowState = 0
				end
			end
		elseif flowState == 2 then
			if not bestGui or not bestGui.Parent or not bestGui.Enabled or not bestTrigger or not bestTrigger.Parent or not votingOpen() then
				flowState = 0
			elseif s.mode ~= activeMode then
				flowState = 1
			else
				local maxV = s.maxVotes
				if maxV > 0 and votesCast >= maxV then
					flowState = 4
				else
					setStatus(bestStatusText)
					if not plr then
						plr = Players.LocalPlayer
					end
					local char = plr and plr.Character
					if char ~= seenChar then
						seenChar = char
						seenTime = os_clock()
					end
					if char and char ~= lastChar and char.Parent and os_clock() - seenTime >= SPAWN_SETTLE then
						local hrp = char:FindFirstChild(STR_HRP)
						local hum = char:FindFirstChildOfClass(STR_HUM)
						if hrp and humAlive(hum) and hum.RootPart then
							if not insidePad(bestTrigger, hrp.Position) then
								local target = bestTrigger.Position + offset
								hrp.CFrame = CFrame_new(target) * hrp.CFrame.Rotation
								hrp.AssemblyLinearVelocity = Vector3_zero
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
			if not (s.alive and s.enabled and bestGui and bestGui.Parent and bestGui.Enabled and votingOpen()) then
				flowState = 0
			elseif s.mode ~= activeMode then
				flowState = 1
			else
				if activeChar and activeChar.Parent and activeHrp and activeHrp.Parent and humAlive(activeHum) and insidePad(bestTrigger, activeHrp.Position) then
					lastChar = activeChar
					votesCast = votesCast + 1
					activeHum.Health = 0
					activeChar = nil
					activeHrp = nil
					activeHum = nil
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
			if not bestGui or not bestGui.Parent or not bestGui.Enabled or not votingOpen() then
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
