local shared = odh_shared_plugins
local ps = game:GetService("Players")
local hs = game:GetService("HttpService")
local rs = game:GetService("RunService")

local plr: Player = ps.LocalPlayer
local file = "elflikesgayshit.dat"
local key = plr.Name .. "youregay11018382"
local hn = "_odh_tc"

type Entry = {[number]: any}

local cfg: {[string]: Entry} = {}
local picker
local drop
local speedSlider
local lock = false
local cur = Color3.fromRGB(255, 0, 0)
local mode = "Tool Color"
local speed = 3
local pending = false
local seen = setmetatable({}, {__mode = "k"}) :: {[Tool]: boolean}

local rainbowConn: RBXScriptConnection? = nil
local rainbowTool: Tool? = nil
local rainbowBaseParts: {BasePart} = {}
local rainbowMeshes: {DataModelMesh} = {}
local rainbowDecals: {Instance} = {}
local rainbowSurfaces: {SurfaceAppearance} = {}
local rainbowSequences: {Instance} = {}
local rainbowHighlights: {Highlight} = {}

local updateRainbowState: () -> ()
local stopRainbow: () -> ()
local setupRainbow: (t: Tool) -> ()
local stepRainbow: () -> ()

local kb = table.create(#key)

for i = 1, #key do
	kb[i] = string.byte(key, i)
end

local hexLookup = table.create(256)

for i = 0, 255 do
	hexLookup[i] = string.format("%02X", i)
end

local function crypt(s: string): string
	local len = #s
	local klen = #kb
	local out = table.create(len)

	for i = 1, len do
		out[i] = hexLookup[bit32.bxor(string.byte(s, i), kb[(i - 1) % klen + 1])]
	end

	return table.concat(out)
end

local function uncrypt(s: string): string?
	local len = #s

	if len % 2 ~= 0 then
		shared.kick("broo")
		return nil
	end

	local klen = #kb
	local out = table.create(len / 2)

	for i = 1, len, 2 do
		local b = tonumber(s:sub(i, i + 1), 16)

		if not b then
			shared.kick("broo")
			return nil
		end

		out[(i + 1) / 2] = string.char(bit32.bxor(b, kb[((i - 1) / 2) % klen + 1]))
	end

	return table.concat(out)
end

local function save()
	writefile(file, crypt(hs:JSONEncode(cfg)))
end

local function load()
	if not isfile(file) then
		return
	end

	local encrypted = readfile(file)
	local decoded = uncrypt(encrypted)

	if not decoded then
		return
	end

	local ok, data = pcall(function()
		return hs:JSONDecode(decoded)
	end)

	if not ok or type(data) ~= "table" then
		shared.kick("🫩")
		return
	end

	for name, e in data do
		if type(name) ~= "string"
			or type(e) ~= "table"
			or (#e ~= 2 and #e ~= 3)
			or type(e[1]) ~= "string"
			or type(e[2]) ~= "string"
			or (e[2] ~= "Tool Color" and e[2] ~= "Highlight")
			or (e[3] ~= nil and type(e[3]) ~= "number") then
			shared.kick("🫩")
			return
		end

		local x: Entry = table.create(3)
		x[1] = e[1]
		x[2] = e[2]
		x[3] = if type(e[3]) == "number" then e[3] else 3
		cfg[name] = x
	end
end

local function queue()
	if pending then
		return
	end

	pending = true

	task.delay(0.2, function()
		pending = false
		save()
	end)
end

local function color(s: string): Color3?
	if #s ~= 7 or string.byte(s, 1) ~= 35 then
		return nil
	end

	local r = tonumber(s:sub(2, 3), 16)
	local g = tonumber(s:sub(4, 5), 16)
	local b = tonumber(s:sub(6, 7), 16)

	if not r or not g or not b then
		return nil
	end

	return Color3.fromRGB(r, g, b)
end

local function getRainbowColor(s: number?): Color3
	local spd = s or speed
	return Color3.fromHSV((os.clock() * (spd * 0.1)) % 1, 1, 1)
end

local function get(): Tool?
	local c = plr.Character

	if c then
		local t = c:FindFirstChildOfClass("Tool")

		if t then
			return t
		end
	end

	local b = plr:FindFirstChildOfClass("Backpack")

	if b then
		return b:FindFirstChildOfClass("Tool")
	end

	return nil
end

local function set(o: Instance, c: Color3)
	if o:IsA("BasePart") then
		if o.Color ~= c then
			o.Color = c
		end
	elseif o:IsA("DataModelMesh") then
		local v = Vector3.new(c.R, c.G, c.B)

		if o.VertexColor ~= v then
			o.VertexColor = v
		end
	elseif o:IsA("Decal") or o:IsA("Texture") then
		if o.Color3 ~= c then
			o.Color3 = c
		end
	elseif o:IsA("SurfaceAppearance") then
		pcall(function()
			if o.Color ~= c then
				o.Color = c
			end
		end)
	elseif o:IsA("Beam") or o:IsA("Trail") or o:IsA("ParticleEmitter") then
		local cs = ColorSequence.new(c)

		if o.Color ~= cs then
			o.Color = cs
		end
	end
end

local function tint(t: Tool, c: Color3)
	local desc = t:GetDescendants()

	for i = 1, #desc do
		set(desc[i], c)
	end
end

local function clear(t: Tool)
	local desc = t:GetDescendants()

	for i = 1, #desc do
		local o = desc[i]

		if o:IsA("Highlight") and o.Name == hn then
			o:Destroy()
		end
	end
end

local function high(p: BasePart, c: Color3)
	local h = p:FindFirstChild(hn)

	if not h then
		h = Instance.new("Highlight")
		h.Name = hn
		h.Parent = p
	end

	h.FillColor = c
	h.FillTransparency = 0.5
	h.OutlineTransparency = 1
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Enabled = true
end

local function highlights(t: Tool, c: Color3)
	local desc = t:GetDescendants()

	for i = 1, #desc do
		local o = desc[i]

		if o:IsA("BasePart") then
			high(o, c)
		end
	end
end

function stopRainbow()
	if rainbowConn then
		rainbowConn:Disconnect()
		rainbowConn = nil
	end

	rainbowTool = nil
	table.clear(rainbowBaseParts)
	table.clear(rainbowMeshes)
	table.clear(rainbowDecals)
	table.clear(rainbowSurfaces)
	table.clear(rainbowSequences)
	table.clear(rainbowHighlights)
end

function setupRainbow(t: Tool)
	rainbowTool = t
	table.clear(rainbowBaseParts)
	table.clear(rainbowMeshes)
	table.clear(rainbowDecals)
	table.clear(rainbowSurfaces)
	table.clear(rainbowSequences)
	table.clear(rainbowHighlights)

	local e = cfg[t.Name]

	if not e or e[1] ~= "Rainbow" then
		return
	end

	local desc = t:GetDescendants()

	if e[2] == "Highlight" then
		for i = 1, #desc do
			local o = desc[i]

			if o:IsA("Highlight") and o.Name == hn then
				table.insert(rainbowHighlights, o)
			end
		end
	else
		for i = 1, #desc do
			local o = desc[i]

			if o:IsA("BasePart") then
				table.insert(rainbowBaseParts, o)
			elseif o:IsA("DataModelMesh") then
				table.insert(rainbowMeshes, o)
			elseif o:IsA("Decal") or o:IsA("Texture") then
				table.insert(rainbowDecals, o)
			elseif o:IsA("SurfaceAppearance") then
				table.insert(rainbowSurfaces, o)
			elseif o:IsA("Beam") or o:IsA("Trail") or o:IsA("ParticleEmitter") then
				table.insert(rainbowSequences, o)
			end
		end
	end
end

function stepRainbow()
	if not rainbowTool or rainbowTool.Parent ~= plr.Character then
		stopRainbow()
		updateRainbowState()
		return
	end

	local e = cfg[rainbowTool.Name]

	if not e or e[1] ~= "Rainbow" then
		stopRainbow()
		return
	end

	local spd = if type(e[3]) == "number" then e[3] else speed
	local col = Color3.fromHSV((os.clock() * (spd * 0.1)) % 1, 1, 1)

	if e[2] == "Highlight" then
		for i = 1, #rainbowHighlights do
			local h = rainbowHighlights[i]

			if h.Parent then
				h.FillColor = col
			end
		end
	else
		local v = Vector3.new(col.R, col.G, col.B)

		for i = 1, #rainbowBaseParts do
			local o = rainbowBaseParts[i]

			if o.Parent then
				o.Color = col
			end
		end

		for i = 1, #rainbowMeshes do
			local o = rainbowMeshes[i]

			if o.Parent then
				o.VertexColor = v
			end
		end

		for i = 1, #rainbowDecals do
			local o = rainbowDecals[i]

			if o.Parent then
				o.Color3 = col
			end
		end

		for i = 1, #rainbowSurfaces do
			local o = rainbowSurfaces[i]

			if o.Parent then
				pcall(function()
					o.Color = col
				end)
			end
		end

		if #rainbowSequences > 0 then
			local cs = ColorSequence.new(col)

			for i = 1, #rainbowSequences do
				local o = rainbowSequences[i]

				if o.Parent then
					o.Color = cs
				end
			end
		end
	end
end

function updateRainbowState()
	local c = plr.Character
	local t = c and c:FindFirstChildOfClass("Tool")

	if t then
		local e = cfg[t.Name]

		if e and e[1] == "Rainbow" then
			if rainbowTool ~= t or (#rainbowBaseParts == 0 and #rainbowHighlights == 0) then
				setupRainbow(t)
			end

			if not rainbowConn then
				rainbowConn = rs.RenderStepped:Connect(stepRainbow)
			end

			return
		end
	end

	stopRainbow()
end

local function apply(t: Tool)
	local e = cfg[t.Name]

	if not e then
		return
	end

	if e[1] == "Rainbow" then
		local spd = if type(e[3]) == "number" then e[3] else speed
		local c = getRainbowColor(spd)

		if e[2] == "Highlight" then
			clear(t)
			highlights(t, c)
		else
			clear(t)
			tint(t, c)
		end

		updateRainbowState()
		return
	end

	local c = color(e[1])

	if not c then
		return
	end

	if e[2] == "Highlight" then
		clear(t)
		highlights(t, c)
	else
		clear(t)
		tint(t, c)
	end

	updateRainbowState()
end

local function bind(t: Tool)
	if seen[t] then
		return
	end

	seen[t] = true
	apply(t)

	t.DescendantAdded:Connect(function(o)
		local e = cfg[t.Name]

		if not e then
			return
		end

		if e[1] == "Rainbow" then
			if rainbowTool == t then
				setupRainbow(t)
			end
			return
		end

		local c = color(e[1])

		if not c then
			return
		end

		if e[2] == "Highlight" then
			if o:IsA("BasePart") then
				high(o, c)
			end
		else
			set(o, c)
		end
	end)

	t.Equipped:Connect(function()
		local e = cfg[t.Name]

		if not e then
			updateRainbowState()
			return
		end

		local toolSpeed = if type(e[3]) == "number" then e[3] else speed
		speed = toolSpeed

		if e[1] == "Rainbow" then
			mode = e[2]

			lock = true
			drop:Select(mode)
			speedSlider:SetValue(speed)
			lock = false

			updateRainbowState()
			return
		end

		local c = color(e[1])

		if not c then
			updateRainbowState()
			return
		end

		cur = c
		mode = e[2]

		lock = true
		drop:Select(mode)
		picker:SetRGBValue(cur)
		speedSlider:SetValue(speed)
		lock = false

		updateRainbowState()
	end)

	t.Unequipped:Connect(function()
		updateRainbowState()
	end)
end

local function watch(x: Instance)
	local ch = x:GetChildren()

	for i = 1, #ch do
		local o = ch[i]

		if o:IsA("Tool") then
			bind(o)
		end
	end

	x.ChildAdded:Connect(function(o)
		if o:IsA("Tool") then
			bind(o)
			updateRainbowState()
		end
	end)

	x.ChildRemoved:Connect(function(o)
		if o:IsA("Tool") then
			updateRainbowState()
		end
	end)
end

local function all()
	local c = plr.Character

	if c then
		local ch = c:GetChildren()

		for i = 1, #ch do
			local o = ch[i]

			if o:IsA("Tool") then
				apply(o)
			end
		end
	end

	local b = plr:FindFirstChildOfClass("Backpack")

	if b then
		local bh = b:GetChildren()

		for i = 1, #bh do
			local o = bh[i]

			if o:IsA("Tool") then
				apply(o)
			end
		end
	end

	updateRainbowState()
end

local function sync(t: Tool?)
	if not t then
		return
	end

	local e = cfg[t.Name]

	if not e then
		return
	end

	local toolSpeed = if type(e[3]) == "number" then e[3] else speed
	speed = toolSpeed

	if e[1] == "Rainbow" then
		mode = e[2]

		lock = true
		drop:Select(mode)
		speedSlider:SetValue(speed)
		lock = false

		updateRainbowState()
		return
	end

	local c = color(e[1])

	if not c then
		return
	end

	cur = c
	mode = e[2]

	lock = true
	drop:Select(mode)
	picker:SetRGBValue(cur)
	speedSlider:SetValue(speed)
	lock = false

	updateRainbowState()
end

load()

local tab = shared.CreateTab("Guns & Knives", "/notgatoooo/Random/refs/heads/main/gk")
local sec = tab:AddSection("Guns & Knives", "MADE BY GATO 😎")

sec:AddToggle("Enabled", function(v: boolean)
	if v then
		all()
	else
		local c = plr.Character

		if c then
			local ch = c:GetChildren()

			for i = 1, #ch do
				local o = ch[i]

				if o:IsA("Tool") then
					clear(o)
				end
			end
		end

		local b = plr:FindFirstChildOfClass("Backpack")

		if b then
			local bh = b:GetChildren()

			for i = 1, #bh do
				local o = bh[i]

				if o:IsA("Tool") then
					clear(o)
				end
			end
		end

		stopRainbow()
	end
end)

drop = sec:AddDropdown("How Tint", {"Tool Color", "Highlight"}, function(v: string)
	if lock then
		return
	end

	mode = v

	local t = get()

	if not t then
		return
	end

	local e = cfg[t.Name]

	if not e then
		local x: Entry = table.create(3)
		x[1] = "#" .. cur:ToHex()
		x[2] = mode
		x[3] = speed
		cfg[t.Name] = x
	else
		e[2] = mode
	end

	apply(t)
	queue()
end)

local t = get()
local e = t and cfg[t.Name]

if e then
	if e[1] == "Rainbow" then
		mode = e[2]
	else
		local c = color(e[1])

		if c then
			cur = c
		end

		mode = e[2]
	end

	if type(e[3]) == "number" then
		speed = e[3]
	end
end

picker = sec:AddColorpicker("Color", cur, function(c: Color3)
	if lock then
		return
	end

	cur = c

	local t = get()

	if not t then
		return
	end

	local e = cfg[t.Name]

	if not e then
		e = table.create(3)
		cfg[t.Name] = e
	end

	e[1] = "#" .. c:ToHex()
	e[2] = mode
	e[3] = speed

	apply(t)
	queue()
end)

sec:AddButton("Enable Rainbow", function()
	local t = get()

	if not t then
		return
	end

	local e = cfg[t.Name]

	if not e then
		e = table.create(3)
		cfg[t.Name] = e
	end

	e[1] = "Rainbow"
	e[2] = mode
	e[3] = speed

	apply(t)
	queue()
end)

sec:AddButton("Disable Rainbow", function()
	local t = get()

	if not t then
		return
	end

	local e = cfg[t.Name]

	if not e then
		e = table.create(3)
		cfg[t.Name] = e
	end

	e[1] = "#" .. cur:ToHex()
	e[2] = mode
	e[3] = speed

	apply(t)
	queue()
end)

speedSlider = sec:AddSlider("Rainbow Speed", 1, 10, speed, function(v: number)
	if lock then
		return
	end

	speed = v

	local t = get()

	if not t then
		return
	end

	local e = cfg[t.Name]

	if not e then
		e = table.create(3)
		e[1] = "#" .. cur:ToHex()
		e[2] = mode
		e[3] = speed
		cfg[t.Name] = e
	else
		e[3] = speed
	end

	queue()
end)

drop:Select(mode)
picker:SetRGBValue(cur)
speedSlider:SetValue(speed)

if t and e then
	apply(t)
end

local b = plr:FindFirstChildOfClass("Backpack")

if b then
	watch(b)
end

if plr.Character then
	watch(plr.Character)
	sync(get())
	all()
end

plr.CharacterAdded:Connect(function(c)
	watch(c)

	task.defer(function()
		all()
		sync(get())
	end)
end)
