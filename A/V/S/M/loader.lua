local Players = game:GetService("Players")
local player = Players.LocalPlayer
local a = os.clock()

local DEAD = Enum.HumanoidStateType.Dead
local RUNNING = Enum.HumanoidStateType.Running
local OFFSET = Vector3.new(0, 1, 0)
local SPAWN_SETTLE = 0.15
local PAD_SETTLE = 0.12
local RESET_COOLDOWN = 0.25
local PAD_NAMES = { "VotePad1", "VotePad2", "VotePad3" }
local LABEL_SET = { "SetValue", "SetText", "Set" }
local TOGGLE_SET = { "SetValue", "Set", "SetState" }

local firetouch = firetouchinterest
local rng = Random.new()

local mode = 0
local maxVotes = 0

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
local N = #ORDER

local function normalize(s)
	s = string.lower(s):gsub("-", " "):gsub("%s+", " ")
	return s:match("^%s*(.-)%s*$")
end

local function stripParen(s)
	local p = string.find(s, " (", 1, true)
	return p and s:sub(1, p - 1) or s
end

local RANK_SMALL, RANK_BIG, BASE, SHORT = {}, {}, {}, {}
for i, name in ipairs(ORDER) do
	local full = normalize(name)
	local base = stripParen(full)
	RANK_SMALL[full], RANK_BIG[full] = i, N + i
	if not RANK_SMALL[base] then
		RANK_SMALL[base], RANK_BIG[base] = i + 0.05, N + i - 0.05
	end
	BASE[i] = base
	SHORT[i] = base:match("^(.-)%s+%d+$") or base
end

local function computeRanks(raw)
	local low = normalize(raw)
	if low == "" then
		return N * 2 + 1, 0
	end
	if RANK_SMALL[low] then
		return RANK_SMALL[low], RANK_BIG[low]
	end
	local clean = stripParen(low)
	for i = 1, N do
		if clean == BASE[i] then
			return i + 0.1, N + i - 0.1
		end
	end
	for i = 1, N do
		local b = BASE[i]
		local nxt = clean:sub(#b + 1, #b + 1)
		if clean:sub(1, #b) == b and (nxt == "" or nxt == " ") then
			return i + 0.2, N + i - 0.2
		end
	end
	for i = 1, N do
		if clean == SHORT[i] then
			return i + 0.3, N + i - 0.3
		end
	end
	for i = 1, N do
		if string.find(clean, BASE[i], 1, true) then
			return N + i, i
		end
	end
	return N * 2 + 1, 0
end

local rankCache = {}
local function ranks(raw)
	local r = rankCache[raw]
	if not r then
		r = { computeRanks(raw) }
		rankCache[raw] = r
	end
	return r[1], r[2]
end

local function trySet(obj, methods, value)
	for _, name in ipairs(methods) do
		local ok, fn = pcall(function()
			return obj[name]
		end)
		if ok and type(fn) == "function" and pcall(fn, obj, value) then
			return
		end
	end
end

local tab = odh_shared_plugins.CreateTab("Auto Vote", "/notgatoooo/Random/refs/heads/main/Assets/map-svgrepo-com")
local section = tab:AddSection("Auto Vote", "Made by Gato 😎")
local statusLabel = section:AddLabel("Off", true)

local lastStatus = "Off"
local function setStatus(text)
	if text ~= lastStatus then
		lastStatus = text
		trySet(statusLabel, LABEL_SET, text)
	end
end

local toggles = {}
local syncing = false
local function onToggle(m)
	return function(on)
		if syncing then
			return
		end
		if on then
			mode = m
			syncing = true
			for i, t in ipairs(toggles) do
				if i ~= m then
					trySet(t, TOGGLE_SET, false)
				end
			end
			syncing = false
		elseif mode == m then
			mode = 0
			setStatus("Off")
		end
	end
end

toggles[1] = section:AddToggle("Auto Vote: Smallest Map", onToggle(1))
toggles[2] = section:AddToggle("Auto Vote: Biggest Map", onToggle(2))
toggles[3] = section:AddToggle("Auto Vote: Random Map", onToggle(3))
section:AddSlider("Max Votes (0 = Infinite)", 0, 100, 0, function(v)
	maxVotes = math.clamp(math.floor((tonumber(v) or 0) + 0.5), 0, 100)
end)

local function getOpenPads()
	local open = {}
	local lobby = workspace:FindFirstChild("Lobby")
	local folder = lobby and lobby:FindFirstChild("VotePads")
	if not folder then
		return open
	end
	for _, name in ipairs(PAD_NAMES) do
		local pad = folder:FindFirstChild(name)
		local trigger = pad and pad:FindFirstChild("Pad")
		local gui = pad and pad:FindFirstChild("VoteInfoGui")
		local container = gui and gui:FindFirstChild("Container")
		local label = container and container:FindFirstChild("MapName")
		if trigger and label and gui.Enabled then
			table.insert(open, { trigger = trigger, gui = gui, map = label.Text })
		end
	end
	return open
end

local function pick(open)
	if mode == 3 then
		return open[rng:NextInteger(1, #open)]
	end
	local best, bestScore
	for _, p in ipairs(open) do
		local small, big = ranks(p.map)
		local score = mode == 1 and -small or big
		if not bestScore or score > bestScore then
			best, bestScore = p, score
		end
	end
	return best
end

local function inside(trigger, pos)
	local lp = trigger.CFrame:PointToObjectSpace(pos)
	local h = trigger.Size * 0.5
	return math.abs(lp.X) <= h.X and math.abs(lp.Y) <= h.Y and math.abs(lp.Z) <= h.Z
end

local function touch(hrp, trigger)
	if firetouch then
		firetouch(hrp, trigger, 0)
		firetouch(hrp, trigger, 1)
	end
end

local votes, votedChar, wasOpen, resetTime = 0, nil, false, 0
local readyChar, readyTime = player.Character, 0
local target, targetMode = nil, 0

local function step()
	if mode == 0 then
		return 0.1
	end

	local open = getOpenPads()
	if #open == 0 then
		wasOpen, target = false, nil
		setStatus("Waiting for vote")
		return 0.05
	end
	if not wasOpen then
		wasOpen, votes, votedChar = true, 0, nil
	end

	if not (target and targetMode == mode and target.gui.Enabled and target.trigger.Parent) then
		target, targetMode = pick(open), mode
	end

	if maxVotes > 0 and votes >= maxVotes then
		setStatus("Max votes reached")
		return 0.1
	end
	setStatus("Voting: " .. target.map)

	local char = player.Character
	if not char then
		return 0.05
	end
	local now = os.clock()

	if char == votedChar then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and now - resetTime >= RESET_COOLDOWN then
			resetTime = now
			hum:ChangeState(RUNNING)
			hum:ChangeState(DEAD)
			hum.Health = 0
		end
		return 0.05
	end

	if char ~= readyChar then
		readyChar, readyTime = char, now
	end
	if now - readyTime < SPAWN_SETTLE then
		return readyTime + SPAWN_SETTLE - now
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = hum and hum.RootPart
	if not hrp or hum.Health <= 0 then
		return 0.05
	end

	local trigger = target.trigger
	if not inside(trigger, hrp.Position) then
		hrp.CFrame = CFrame.new(trigger.Position + OFFSET) * hrp.CFrame.Rotation
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
	touch(hrp, trigger)

	task.wait(PAD_SETTLE)

	if mode ~= targetMode or not target.gui.Enabled or not trigger.Parent then
		return 0
	end
	if hum.Health > 0 and inside(trigger, hrp.Position) then
		touch(hrp, trigger)
		votedChar = char
		votes += 1
		resetTime = os.clock()
		hum:ChangeState(DEAD)
		hum.Health = 0
	end
	return 0
end

shared.Notify("Successfully Loaded in " .. (os.clock() - a) .. "s!", 1)

task.spawn(function()
	while true do
		local ok, delay = pcall(step)
		task.wait(ok and delay or 0.5)
	end
end)
