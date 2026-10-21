local state = { alive = true, enabled = false, mode = 0, maxVotes = 0 }

local game_ref = game
local workspace_ref = workspace
local Instance_new = Instance.new
local Vector3_new = Vector3.new
local Vector3_zero = Vector3.zero
local Vector2_new = Vector2.new
local UDim2_new = UDim2.new
local UDim2_fromOffset = UDim2.fromOffset
local UDim_new = UDim.new
local Color3_fromRGB = Color3.fromRGB
local CFrame_new = CFrame.new
local TweenInfo_new = TweenInfo.new
local math_abs = math.abs
local math_huge = math.huge
local math_random = math.random
local math_floor = math.floor
local math_clamp = math.clamp
local tonumber_fn = tonumber
local tostring_fn = tostring
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
local INPUT_MOUSE1 = Enum.UserInputType.MouseButton1
local INPUT_TOUCH = Enum.UserInputType.Touch
local INPUT_MOUSEMOVE = Enum.UserInputType.MouseMovement
local STATE_END = Enum.UserInputState.End
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MEDIUM = Enum.Font.GothamMedium
local FONT_SEMIBOLD = Enum.Font.GothamSemibold
local ALIGN_LEFT = Enum.TextXAlignment.Left
local ALIGN_RIGHT = Enum.TextXAlignment.Right

local Players = game_ref:GetService("Players")
local UserInputService = game_ref:GetService("UserInputService")
local TweenService = game_ref:GetService("TweenService")
local CoreGui = game_ref:GetService("CoreGui")
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
local SPAWN_SETTLE = 1

local COL_BG = Color3_fromRGB(18, 18, 24)
local COL_TOP = Color3_fromRGB(24, 24, 32)
local COL_CARD = Color3_fromRGB(28, 28, 38)
local COL_STROKE = Color3_fromRGB(45, 45, 60)
local COL_ACCENT = Color3_fromRGB(88, 101, 242)
local COL_TOGGLE_OFF = Color3_fromRGB(48, 48, 62)
local COL_TEXT = Color3_fromRGB(240, 240, 245)
local COL_SUBTEXT = Color3_fromRGB(160, 160, 175)
local COL_WHITE = Color3_fromRGB(255, 255, 255)
local COL_CLOSE = Color3_fromRGB(235, 87, 87)

local TWEEN_FAST = TweenInfo_new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local KNOB_ON_GOAL = { Position = UDim2_new(1, -18, 0.5, -8) }
local KNOB_OFF_GOAL = { Position = UDim2_new(0, 2, 0.5, -8) }
local TRACK_ON_GOAL = { BackgroundColor3 = COL_ACCENT }
local TRACK_OFF_GOAL = { BackgroundColor3 = COL_TOGGLE_OFF }

local connections = table_create(12)
local connCount = 0
local function trackConn(conn)
	connCount = connCount + 1
	connections[connCount] = conn
	return conn
end

local function resolveGuiParent()
	local okHui, hui = pcall_fn(function()
		return gethui and gethui()
	end)
	if okHui and hui then
		return hui
	end
	local okCore, core = pcall_fn(function()
		local _ = CoreGui.Name
		return CoreGui
	end)
	if okCore and core then
		return core
	end
	return player and player:WaitForChild("PlayerGui")
end

local guiParent = resolveGuiParent()
if guiParent then
	local old = guiParent:FindFirstChild("AutoVoteStandaloneUI")
	if old then
		old:Destroy()
	end
end

local screenGui = Instance_new("ScreenGui")
screenGui.Name = "AutoVoteStandaloneUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance_new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2_fromOffset(280, 266)
mainFrame.Position = UDim2_new(0.5, -140, 0.5, -133)
mainFrame.BackgroundColor3 = COL_BG
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance_new("UICorner")
mainCorner.CornerRadius = UDim_new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance_new("UIStroke")
mainStroke.Color = COL_STROKE
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local topBar = Instance_new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2_new(1, 0, 0, 36)
topBar.BackgroundColor3 = COL_TOP
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance_new("UICorner")
topCorner.CornerRadius = UDim_new(0, 10)
topCorner.Parent = topBar

local topCover = Instance_new("Frame")
topCover.Size = UDim2_new(1, 0, 0, 10)
topCover.Position = UDim2_new(0, 0, 1, -10)
topCover.BackgroundColor3 = COL_TOP
topCover.BorderSizePixel = 0
topCover.Parent = topBar

local titleLabel = Instance_new("TextLabel")
titleLabel.Size = UDim2_new(1, -80, 1, 0)
titleLabel.Position = UDim2_fromOffset(12, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = FONT_BOLD
titleLabel.Text = "Auto Vote"
titleLabel.TextColor3 = COL_TEXT
titleLabel.TextSize = 14
titleLabel.TextXAlignment = ALIGN_LEFT
titleLabel.Parent = topBar

local minBtn = Instance_new("TextButton")
minBtn.Size = UDim2_fromOffset(24, 24)
minBtn.Position = UDim2_new(1, -58, 0.5, -12)
minBtn.BackgroundColor3 = COL_CARD
minBtn.BorderSizePixel = 0
minBtn.Font = FONT_BOLD
minBtn.Text = "-"
minBtn.TextColor3 = COL_SUBTEXT
minBtn.TextSize = 14
minBtn.AutoButtonColor = true
minBtn.Parent = topBar

local minCorner = Instance_new("UICorner")
minCorner.CornerRadius = UDim_new(0, 6)
minCorner.Parent = minBtn

local closeBtn = Instance_new("TextButton")
closeBtn.Size = UDim2_fromOffset(24, 24)
closeBtn.Position = UDim2_new(1, -28, 0.5, -12)
closeBtn.BackgroundColor3 = COL_CLOSE
closeBtn.BackgroundTransparency = 0.15
closeBtn.BorderSizePixel = 0
closeBtn.Font = FONT_BOLD
closeBtn.Text = "X"
closeBtn.TextColor3 = COL_WHITE
closeBtn.TextSize = 12
closeBtn.AutoButtonColor = true
closeBtn.Parent = topBar

local closeCorner = Instance_new("UICorner")
closeCorner.CornerRadius = UDim_new(0, 6)
closeCorner.Parent = closeBtn

local content = Instance_new("Frame")
content.Name = "Content"
content.Size = UDim2_new(1, -20, 1, -46)
content.Position = UDim2_fromOffset(10, 42)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local statusCard = Instance_new("Frame")
statusCard.Size = UDim2_new(1, 0, 0, 32)
statusCard.Position = UDim2_fromOffset(0, 0)
statusCard.BackgroundColor3 = COL_CARD
statusCard.BorderSizePixel = 0
statusCard.Parent = content

local statusCorner = Instance_new("UICorner")
statusCorner.CornerRadius = UDim_new(0, 7)
statusCorner.Parent = statusCard

local statusTextLabel = Instance_new("TextLabel")
statusTextLabel.Size = UDim2_new(1, -20, 1, 0)
statusTextLabel.Position = UDim2_fromOffset(10, 0)
statusTextLabel.BackgroundTransparency = 1
statusTextLabel.Font = FONT_SEMIBOLD
statusTextLabel.Text = "Status: Off"
statusTextLabel.TextColor3 = COL_ACCENT
statusTextLabel.TextSize = 12
statusTextLabel.TextXAlignment = ALIGN_LEFT
statusTextLabel.TextTruncate = Enum.TextTruncate.AtEnd
statusTextLabel.Parent = statusCard

local lastStatusText = STR_STATUS_OFF

local function setStatus(txt)
	if lastStatusText ~= txt then
		lastStatusText = txt
		if statusTextLabel then
			statusTextLabel.Text = "Status: " .. txt
		end
	end
end

local function createToggle(yPos, labelText, callback)
	local row = Instance_new("TextButton")
	row.Size = UDim2_new(1, 0, 0, 36)
	row.Position = UDim2_fromOffset(0, yPos)
	row.BackgroundColor3 = COL_CARD
	row.BorderSizePixel = 0
	row.AutoButtonColor = false
	row.Text = ""
	row.Parent = content

	local rowCorner = Instance_new("UICorner")
	rowCorner.CornerRadius = UDim_new(0, 7)
	rowCorner.Parent = row

	local lbl = Instance_new("TextLabel")
	lbl.Size = UDim2_new(1, -60, 1, 0)
	lbl.Position = UDim2_fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = FONT_MEDIUM
	lbl.Text = labelText
	lbl.TextColor3 = COL_TEXT
	lbl.TextSize = 12
	lbl.TextXAlignment = ALIGN_LEFT
	lbl.Parent = row

	local track = Instance_new("Frame")
	track.Size = UDim2_fromOffset(38, 20)
	track.Position = UDim2_new(1, -48, 0.5, -10)
	track.BackgroundColor3 = COL_TOGGLE_OFF
	track.BorderSizePixel = 0
	track.Parent = row

	local trackCorner = Instance_new("UICorner")
	trackCorner.CornerRadius = UDim_new(1, 0)
	trackCorner.Parent = track

	local knob = Instance_new("Frame")
	knob.Size = UDim2_fromOffset(16, 16)
	knob.Position = UDim2_new(0, 2, 0.5, -8)
	knob.BackgroundColor3 = COL_WHITE
	knob.BorderSizePixel = 0
	knob.Parent = track

	local knobCorner = Instance_new("UICorner")
	knobCorner.CornerRadius = UDim_new(1, 0)
	knobCorner.Parent = knob

	local tweenTrackOn = TweenService:Create(track, TWEEN_FAST, TRACK_ON_GOAL)
	local tweenTrackOff = TweenService:Create(track, TWEEN_FAST, TRACK_OFF_GOAL)
	local tweenKnobOn = TweenService:Create(knob, TWEEN_FAST, KNOB_ON_GOAL)
	local tweenKnobOff = TweenService:Create(knob, TWEEN_FAST, KNOB_OFF_GOAL)

	local currentVal = false
	local obj = {}

	function obj:Set(val)
		local b = val and true or false
		if currentVal == b then
			return
		end
		currentVal = b
		if b then
			tweenTrackOn:Play()
			tweenKnobOn:Play()
		else
			tweenTrackOff:Play()
			tweenKnobOff:Play()
		end
		callback(b)
	end

	trackConn(row.MouseButton1Click:Connect(function()
		obj:Set(not currentVal)
	end))

	return obj
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
		toggleObj:Set(false)
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

toggleSmallest = createToggle(38, "Auto Vote: Smallest Map", onToggleSmallest)
toggleBiggest = createToggle(80, "Auto Vote: Biggest Map", onToggleBiggest)
toggleRandom = createToggle(122, "Auto Vote: Random Map", onToggleRandom)

local sliderCard = Instance_new("Frame")
sliderCard.Size = UDim2_new(1, 0, 0, 52)
sliderCard.Position = UDim2_fromOffset(0, 164)
sliderCard.BackgroundColor3 = COL_CARD
sliderCard.BorderSizePixel = 0
sliderCard.Parent = content

local sliderCorner = Instance_new("UICorner")
sliderCorner.CornerRadius = UDim_new(0, 7)
sliderCorner.Parent = sliderCard

local sliderTitle = Instance_new("TextLabel")
sliderTitle.Size = UDim2_new(1, -60, 0, 20)
sliderTitle.Position = UDim2_fromOffset(10, 6)
sliderTitle.BackgroundTransparency = 1
sliderTitle.Font = FONT_MEDIUM
sliderTitle.Text = "Max Votes (0 = Infinite)"
sliderTitle.TextColor3 = COL_TEXT
sliderTitle.TextSize = 12
sliderTitle.TextXAlignment = ALIGN_LEFT
sliderTitle.Parent = sliderCard

local sliderValLabel = Instance_new("TextLabel")
sliderValLabel.Size = UDim2_fromOffset(44, 20)
sliderValLabel.Position = UDim2_new(1, -54, 0, 6)
sliderValLabel.BackgroundTransparency = 1
sliderValLabel.Font = FONT_BOLD
sliderValLabel.Text = "0"
sliderValLabel.TextColor3 = COL_ACCENT
sliderValLabel.TextSize = 12
sliderValLabel.TextXAlignment = ALIGN_RIGHT
sliderValLabel.Parent = sliderCard

local sliderBar = Instance_new("Frame")
sliderBar.Size = UDim2_new(1, -20, 0, 6)
sliderBar.Position = UDim2_fromOffset(10, 34)
sliderBar.BackgroundColor3 = COL_TOGGLE_OFF
sliderBar.BorderSizePixel = 0
sliderBar.Parent = sliderCard

local sliderBarCorner = Instance_new("UICorner")
sliderBarCorner.CornerRadius = UDim_new(1, 0)
sliderBarCorner.Parent = sliderBar

local sliderFill = Instance_new("Frame")
sliderFill.Size = UDim2_new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = COL_ACCENT
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBar

local sliderFillCorner = Instance_new("UICorner")
sliderFillCorner.CornerRadius = UDim_new(1, 0)
sliderFillCorner.Parent = sliderFill

local sliderKnob = Instance_new("Frame")
sliderKnob.Size = UDim2_fromOffset(12, 12)
sliderKnob.AnchorPoint = Vector2_new(0.5, 0.5)
sliderKnob.Position = UDim2_new(0, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = COL_WHITE
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBar

local sliderKnobCorner = Instance_new("UICorner")
sliderKnobCorner.CornerRadius = UDim_new(1, 0)
sliderKnobCorner.Parent = sliderKnob

local sliderHitbox = Instance_new("TextButton")
sliderHitbox.Size = UDim2_new(1, 0, 0, 24)
sliderHitbox.Position = UDim2_fromOffset(0, 25)
sliderHitbox.BackgroundTransparency = 1
sliderHitbox.Text = ""
sliderHitbox.Parent = sliderCard

local draggingWindow = false
local dragStartPos = nil
local frameStartPos = nil
local draggingSlider = false

local function updateSliderFromX(x)
	local barPos = sliderBar.AbsolutePosition.X
	local barWidth = sliderBar.AbsoluteSize.X
	if barWidth <= 0 then
		return
	end
	local ratio = math_clamp((x - barPos) / barWidth, 0, 1)
	local val = math_floor(ratio * 100 + 0.5)
	local snappedRatio = val * 0.01
	sliderFill.Size = UDim2_new(snappedRatio, 0, 1, 0)
	sliderKnob.Position = UDim2_new(snappedRatio, 0, 0.5, 0)
	sliderValLabel.Text = tostring_fn(val)
	onMaxVotesChanged(val)
end

trackConn(sliderHitbox.InputBegan:Connect(function(input)
	local ut = input.UserInputType
	if ut == INPUT_MOUSE1 or ut == INPUT_TOUCH then
		draggingSlider = true
		updateSliderFromX(input.Position.X)
	end
end))

trackConn(topBar.InputBegan:Connect(function(input)
	local ut = input.UserInputType
	if ut == INPUT_MOUSE1 or ut == INPUT_TOUCH then
		draggingWindow = true
		dragStartPos = input.Position
		frameStartPos = mainFrame.Position
	end
end))

trackConn(UserInputService.InputChanged:Connect(function(input)
	local ut = input.UserInputType
	if ut == INPUT_MOUSEMOVE or ut == INPUT_TOUCH then
		if draggingSlider then
			updateSliderFromX(input.Position.X)
		elseif draggingWindow and dragStartPos and frameStartPos then
			local delta = input.Position - dragStartPos
			mainFrame.Position = UDim2_new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
		end
	end
end))

trackConn(UserInputService.InputEnded:Connect(function(input)
	local ut = input.UserInputType
	if (ut == INPUT_MOUSE1 or ut == INPUT_TOUCH) and input.UserInputState == STATE_END then
		draggingSlider = false
		draggingWindow = false
	end
end))

local minimized = false
local tweenExpand = TweenService:Create(mainFrame, TWEEN_FAST, { Size = UDim2_fromOffset(280, 266) })
local tweenCollapse = TweenService:Create(mainFrame, TWEEN_FAST, { Size = UDim2_fromOffset(280, 36) })

trackConn(minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		minBtn.Text = "+"
		tweenCollapse:Play()
	else
		minBtn.Text = "-"
		tweenExpand:Play()
	end
end))

trackConn(closeBtn.MouseButton1Click:Connect(function()
	state.alive = false
	state.enabled = false
	state.mode = 0
	for i = 1, connCount do
		local c = connections[i]
		if c then
			c:Disconnect()
			connections[i] = nil
		end
	end
	connCount = 0
	if screenGui then
		screenGui:Destroy()
	end
end))

if guiParent then
	screenGui.Parent = guiParent
end

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
