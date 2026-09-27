local shared = odh_shared_plugins
local ps = game:GetService("Players")
local hs = game:GetService("HttpService")

local plr: Player = ps.LocalPlayer
local file = "elflikesgayshit.dat"
local key = plr.Name .. "youregay11018382"
local hn = "_odh_tc"

type Entry = {[number]: string}

local cfg: {[string]: Entry} = {}
local picker
local drop
local lock = false
local cur = Color3.fromRGB(255, 0, 0)
local mode = "Tool Color"
local pending = false
local seen = setmetatable({}, {__mode = "k"}) :: {[Tool]: boolean}

local kb = table.create(#key)

for i = 1, #key do
	kb[i] = string.byte(key, i)
end

local function crypt(s: string): string
	local out = table.create(#s)

	for i = 1, #s do
		out[i] = string.format("%02X", bit32.bxor(string.byte(s, i), kb[(i - 1) % #kb + 1]))
	end

	return table.concat(out)
end

local function uncrypt(s: string): string?
	if #s % 2 ~= 0 then
		shared.kick("broo")
		return nil
	end

	local out = table.create(#s / 2)

	for i = 1, #s, 2 do
		local b = tonumber(s:sub(i, i + 1), 16)

		if not b then
			shared.kick("broo")
			return nil
		end

		out[(i + 1) / 2] = string.char(bit32.bxor(b, kb[((i - 1) / 2) % #kb + 1]))
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

	if not ok then
		shared.kick("🫩")
		return
	end

	if type(data) ~= "table" then
		shared.kick("🫩")
		return
	end

	for name, e in data do
		if type(name) ~= "string"
			or type(e) ~= "table"
			or #e ~= 2
			or type(e[1]) ~= "string"
			or type(e[2]) ~= "string"
			or (e[2] ~= "Tool Color" and e[2] ~= "Highlight") then
			shared.kick("🫩")
			return
		end

		local x: Entry = table.create(2)
		x[1] = e[1]
		x[2] = e[2]
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
	if #s ~= 7 or s:sub(1, 1) ~= "#" then
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
	elseif o:IsA("SpecialMesh") then
		local v = Vector3.new(c.R, c.G, c.B)

		if o.VertexColor ~= v then
			o.VertexColor = v
		end
	elseif o:IsA("Texture") or o:IsA("Decal") then
		if o.Color3 ~= c then
			o.Color3 = c
		end
	elseif o:IsA("SurfaceAppearance") then
		if o.Color ~= c then
			o.Color = c
		end
	end
end

local function tint(t: Tool, c: Color3)
	for _, o in t:GetDescendants() do
		set(o, c)
	end
end

local function clear(t: Tool)
	for _, o in t:GetDescendants() do
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
	for _, o in t:GetDescendants() do
		if o:IsA("BasePart") then
			high(o, c)
		end
	end
end

local function apply(t: Tool)
	local e = cfg[t.Name]

	if not e then
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
		lock = false
	end)
end

local function watch(x: Instance)
	for _, o in x:GetChildren() do
		if o:IsA("Tool") then
			bind(o)
		end
	end

	x.ChildAdded:Connect(function(o)
		if o:IsA("Tool") then
			bind(o)
		end
	end)
end

local function all()
	local c = plr.Character

	if c then
		for _, o in c:GetChildren() do
			if o:IsA("Tool") then
				apply(o)
			end
		end
	end

	local b = plr:FindFirstChildOfClass("Backpack")

	if b then
		for _, o in b:GetChildren() do
			if o:IsA("Tool") then
				apply(o)
			end
		end
	end
end

local function sync(t: Tool?)
	if not t then
		return
	end

	local e = cfg[t.Name]

	if not e then
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
	lock = false
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
			for _, o in c:GetChildren() do
				if o:IsA("Tool") then
					clear(o)
				end
			end
		end

		local b = plr:FindFirstChildOfClass("Backpack")

		if b then
			for _, o in b:GetChildren() do
				if o:IsA("Tool") then
					clear(o)
				end
			end
		end
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
		local x: Entry = table.create(2)
		x[1] = "#" .. cur:ToHex()
		x[2] = mode
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
	local c = color(e[1])

	if c then
		cur = c
	end

	mode = e[2]
end

picker = sec:AddColorpicker("Color", cur, function(c: Color3)
	if lock then
		return
	end

	local t = get()

	if not t then
		cur = c
		return
	end

	cur = c

	local e = cfg[t.Name]

	if not e then
		e = table.create(2)
		cfg[t.Name] = e
	end

	e[1] = "#" .. c:ToHex()
	e[2] = mode

	apply(t)
	queue()
end)

drop:Select(mode)
picker:SetRGBValue(cur)

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

-- warn("ok")
