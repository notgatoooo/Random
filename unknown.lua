local u1: Players = game:GetService("Players")
local u2: Lighting = game:GetService("Lighting")
local u3: TweenService = game:GetService("TweenService")
local u4: RunService = game:GetService("RunService")
local u5: ContentProvider = game:GetService("ContentProvider")
local u6: CoreGui = game:GetService("CoreGui")

local u7: (number, number) -> number = math.random
local u8: (number?) -> number = task.wait
local u9: (number) -> number = math.rad
local u10: (number) -> number = math.cos
local u11: (number) -> number = math.sin
local u12: (string, ...any) -> string = string.format

local u13: { [string]: any }? = if typeof(getgenv) == "function" then (getgenv :: any)() else (_G :: any)

local c1: string = "1.png"
local c2: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper.png"
local c3: string = "2.png"
local c4: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_sec.png"
local c5: string = "1.ogg"
local c6: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_come.ogg"
local c7: string = "2.mp3"
local c8: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_amb.mp3"
local c9: string = "3.ogg"
local c10: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_go.ogg"
local c11: string = "4.wav"
local c12: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_kill.wav"
local c13: string = "hi noonie"
local c14: Color3 = Color3.fromRGB(255, 0, 0)
local c15: Color3 = Color3.fromRGB(255, 255, 255)
local c16: string = "rbxassetid://84277811"
local c17: string = "rbxassetid://140708560546036"
local c18: string = "rbxassetid://12784032030"
local c19: Vector3 = Vector3.new(0, 5, 0)
local c20: Vector3 = Vector3.new(3, 3, 3)
local c21: UDim2 = UDim2.new(12, 0, 12, 0)
local c22: UDim2 = UDim2.new(0.5, 0, 0.5, 0)
local c23: Vector2 = Vector2.new(0.5, 0.5)
local c24: { number } = { 1.3, 1.6, 1.9, 2.2 }
local c25: { number } = { 0, 0.08, 0.18, 0.3 }
local c26: number = 100
local c27: number = 2147483647
local c28: Vector3 = Vector3.new(1, 1, 1)
local c29: number = 30

local reqFunc: ((any) -> any)? = if typeof(request) == "function" then request
	elseif typeof(http_request) == "function" then http_request
	elseif typeof(syn) == "table" and typeof((syn :: any).request) == "function" then (syn :: any).request
	elseif typeof(http) == "table" and typeof((http :: any).request) == "function" then (http :: any).request
	elseif u13 and typeof(u13.request) == "function" then u13.request
	elseif u13 and typeof(u13.http_request) == "function" then u13.http_request
	else nil

local f1: ((string) -> string?)? = function(u14: string): string?
	local urlsToTry: { string } = {}
	local uRaw1: string = u14:gsub("^https://github%.com/([^/]+)/([^/]+)/raw/refs/heads/", "https://raw.githubusercontent.com/%1/%2/")
	local uRaw2: string = u14:gsub("^https://github%.com/([^/]+)/([^/]+)/raw/", "https://raw.githubusercontent.com/%1/%2/")

	if uRaw1 ~= u14 then table.insert(urlsToTry, uRaw1) end
	if uRaw2 ~= u14 and uRaw2 ~= uRaw1 then table.insert(urlsToTry, uRaw2) end
	table.insert(urlsToTry, u14)

	for _, tryUrl in ipairs(urlsToTry) do
		if typeof(game) == "Instance" and typeof((game :: any).HttpGet) == "function" then
			local ok: boolean, res: any = pcall(function()
				return (game :: any):HttpGet(tryUrl)
			end)
			if ok and typeof(res) == "string" and #res > 0 then
				local isHtml: boolean = res:match("^%s*<") ~= nil
				local is404: boolean = res:match("^404") ~= nil
				if not isHtml and not is404 then
					return res
				end
			end
		end

		if reqFunc then
			local ok: boolean, res: any = pcall(reqFunc, { Url = tryUrl, Method = "GET" })
			if ok and typeof(res) == "table" and typeof(res.Body) == "string" and #res.Body > 0 then
				local body: string = res.Body
				local statusCode: number = res.StatusCode or 200
				if statusCode >= 200 and statusCode < 300 then
					local isHtml: boolean = body:match("^%s*<") ~= nil
					local is404: boolean = body:match("^404") ~= nil
					if not isHtml and not is404 then
						return body
					end
				end
			end
		end
	end

	return nil
end

local f2: ((string, string) -> ())? = if typeof(writefile) == "function" then writefile
	elseif typeof(syn) == "table" and typeof((syn :: any).writefile) == "function" then (syn :: any).writefile
	elseif u13 and typeof(u13.writefile) == "function" then u13.writefile
	else nil

local f3: ((string) -> boolean)? = if typeof(isfile) == "function" then isfile
	elseif typeof(syn) == "table" and typeof((syn :: any).isfile) == "function" then (syn :: any).isfile
	elseif u13 and typeof(u13.isfile) == "function" then u13.isfile
	else nil

local f4: ((string) -> string)? = if typeof(readfile) == "function" then readfile
	elseif typeof(syn) == "table" and typeof((syn :: any).readfile) == "function" then (syn :: any).readfile
	elseif u13 and typeof(u13.readfile) == "function" then u13.readfile
	else nil

local f5: ((string) -> string)? = nil
if typeof(getcustomasset) == "function" then
	f5 = getcustomasset
elseif u13 and typeof(u13.getcustomasset) == "function" then
	f5 = u13.getcustomasset
elseif typeof(getsynasset) == "function" then
	f5 = getsynasset
elseif u13 and typeof(u13.getsynasset) == "function" then
	f5 = u13.getsynasset
elseif typeof(get_custom_asset) == "function" then
	f5 = get_custom_asset
elseif typeof(syn) == "table" and typeof((syn :: any).get_custom_asset) == "function" then
	f5 = (syn :: any).get_custom_asset
end

local function f6(u14: string): boolean
	if f3 then
		local exists: boolean = false
		local ok: boolean = pcall(function()
			exists = f3(u14) == true
		end)
		if not ok or not exists then
			return false
		end
	end

	if f4 then
		local ok: boolean, u15: any = pcall(f4, u14)
		if ok and typeof(u15) == "string" and #u15 > 0 then
			local isHtml: boolean = u15:match("^%s*<") ~= nil
			local is404: boolean = u15:match("^404") ~= nil
			if not isHtml and not is404 then
				return true
			end
		end
		return false
	end

	if f3 then
		return true
	end

	return false
end

local function f7(u14: string): string
	if f5 then
		local start: number = os.clock()
		while os.clock() - start < 3 do
			if f6(u14) then
				break
			end
			u8(0.05)
		end

		for _ = 1, 5 do
			local ok: boolean, u15: any = pcall(f5, u14)
			if ok and typeof(u15) == "string" and u15 ~= "" then
				return u15
			end
			u8(0.1)
		end
	end
	return u14
end

local function f8(): string
	return u12("%x%x", u7(1000000, 9999999), u7(1000000, 9999999))
end

local v1: { string } = {
	c1, c2,
	c3, c4,
	c5, c6,
	c7, c8,
	c9, c10,
	c11, c12,
}

if f1 and f2 then
	for u14: number = 1, #v1, 2 do
		local u15: string = v1[u14]
		local url: string = v1[u14 + 1]

		if not f6(u15) then
			local u16: string? = f1(url)
			if typeof(u16) == "string" and #u16 > 0 then
				pcall(f2, u15, u16)

				local start: number = os.clock()
				while os.clock() - start < 5 do
					if f6(u15) then
						break
					end
					u8(0.05)
				end
			end
		end
	end
end

for u14: number = 1, #v1, 2 do
	local u15: string = v1[u14]
	local start: number = os.clock()
	while os.clock() - start < 5 do
		if f6(u15) then
			break
		end
		u8(0.05)
	end
end

u8(0.2)

print(c13)

local v2: string = f7(c1)
local v3: string = f7(c3)
local v4: string = f7(c5)
local v5: string = f7(c7)
local v6: string = f7(c9)
local v7: string = f7(c11)

local v8: ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
v8.Name = f8()
v8.TintColor = c15
v8.Parent = u2

local v9: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local v10: Tween = u3:Create(v8, v9, {
	TintColor = c14,
})

local v11: Tween = u3:Create(u2, v9, {
	Ambient = c14,
	OutdoorAmbient = c14,
	ColorShift_Top = c14,
	ColorShift_Bottom = c14,
	FogColor = c14,
})

v10:Play()
v11:Play()

u8(0.5)

local v12: Player = u1.LocalPlayer or u1.PlayerAdded:Wait()
local v13: Model = v12.Character or v12.CharacterAdded:Wait()
local v14: BasePart = (v13:WaitForChild("HumanoidRootPart", 5) or v13:FindFirstChildWhichIsA("BasePart")) :: BasePart

local function f9(u14: string, u15: number): Sound
	local u16: Model? = v12.Character
	local u17: BasePart? = if u16 then (u16:FindFirstChild("HumanoidRootPart") or u16:FindFirstChildWhichIsA("BasePart")) :: BasePart? else nil
	local u18: Vector3 = if u17 then u17.Position else Vector3.zero
	local u19: number = u9(u7(0, 360))
	local u20: Vector3 = Vector3.new(u10(u19), 0, u11(u19)) * c29
	local u21: Part = Instance.new("Part")
	u21.Name = f8()
	u21.Size = c28
	u21.CFrame = CFrame.new(u18 + u20)
	u21.Anchored = true
	u21.CanCollide = false
	u21.Transparency = 1
	local u22: Sound = Instance.new("Sound")
	u22.Name = f8()
	u22.SoundId = u14
	u22.Volume = u15
	u22.Looped = false
	u22.Parent = u21
	u21.Parent = workspace
	u22:Play()
	return u22
end

local v15: CFrame = v14.CFrame
local v16: Vector3 = v15.Position + c19
local v17: Vector3 = v16 + (v15.LookVector * 500)
local v18: CFrame = CFrame.lookAt(v17, v16)

local v19: Part = Instance.new("Part")
v19.Name = f8()
v19.Size = c20
v19.CFrame = v18
v19.Anchored = true
v19.CanCollide = false
v19.Transparency = 1

local v20: BillboardGui = Instance.new("BillboardGui")
v20.Name = f8()
v20.Size = c21
v20.AlwaysOnTop = false
v20.LightInfluence = 0
v20.Adornee = v19
v20.Parent = v19

local v21: { ImageLabel } = table.create(4)

for u14: number = 1, 4 do
	local u15: ImageLabel = Instance.new("ImageLabel")
	u15.Name = f8()
	u15.AnchorPoint = c23
	u15.BackgroundTransparency = 1
	u15.Size = UDim2.new(c24[u14], 0, c24[u14], 0)
	u15.Position = c22
	u15.Image = c16
	u15.ImageColor3 = c14
	u15.ImageTransparency = c25[u14]
	u15.ZIndex = 1
	u15.Parent = v20
	v21[u14] = u15
end

local v22: ImageLabel = Instance.new("ImageLabel")
v22.Name = f8()
v22.AnchorPoint = c23
v22.BackgroundTransparency = 1
v22.Size = UDim2.new(1.1, 0, 1.1, 0)
v22.Position = c22
v22.Image = v2
v22.ZIndex = 2
v22.Parent = v20

local v23: Sound = Instance.new("Sound")
v23.Name = f8()
v23.SoundId = v5
v23.Volume = 1
v23.Looped = true
v23.Parent = v19
v23:Play()

f9(v4, 8)

local v24: PointLight = Instance.new("PointLight")
v24.Name = f8()
v24.Color = c14
v24.Brightness = 12
v24.Range = 50
v24.Shadows = false
v24.Parent = v19

v19.Parent = workspace

task.spawn(function(): ()
	while v19.Parent do
		for u14: number = 1, 4 do
			v21[u14].Rotation = u7(0, 360)
		end
		u8(0.04)
	end
end)

task.spawn(function(): ()
	while v19.Parent do
		u8(0.1)
	end
end)

task.spawn(function(): ()
	u8(2)

	local v25: Vector3 = (v16 - v17).Unit
	local v26: number = 1000
	local v27: number = v26 / c26
	local v28: Vector3 = v16 + (v25 * 500)
	local v29: Tween = u3:Create(v19, TweenInfo.new(v27, Enum.EasingStyle.Linear), {
		CFrame = CFrame.lookAt(v28, v28 + v25),
	})

	v29:Play()

	local v30: boolean = false
	local v31: RaycastParams = RaycastParams.new()
	v31.FilterType = Enum.RaycastFilterType.Exclude
	v31.FilterDescendantsInstances = { v19 }

	while v29.PlaybackState == Enum.PlaybackState.Playing do
		local u14: Model? = v12.Character
		local u15: BasePart? = if u14 then (u14:FindFirstChild("HumanoidRootPart") or u14:FindFirstChild("Head")) :: BasePart? else nil

		if u14 and u15 then
			local u16: Vector3 = v19.Position
			local u17: Vector3 = u15.Position
			local u18: Vector3 = u17 - u16
			local u19: RaycastResult? = workspace:Raycast(u16, u18, v31)

			if u19 then
				if u19.Instance:IsDescendantOf(u14) then
					v30 = true
					v29:Cancel()
					break
				end
			else
				v30 = true
				v29:Cancel()
				break
			end
		end

		u8(0.04)
	end

	if v30 then
		v22.Image = v3

		local v32: Sound = Instance.new("Sound")
		v32.Name = f8()
		v32.SoundId = v7
		v32.Volume = 3
		v32.Looped = false
		v32.Parent = v19
		v32:Play()

		local v33: Camera = workspace.CurrentCamera
		v33.CameraType = Enum.CameraType.Scriptable

		local v34: Tween = u3:Create(v33, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.lookAt(v33.CFrame.Position, v19.Position),
		})
		v34:Play()
		v34.Completed:Wait()

		local v35: RBXScriptConnection? = nil
		v35 = u4.RenderStepped:Connect(function(): ()
			if v19 and v19.Parent then
				v33.CameraType = Enum.CameraType.Scriptable
				v33.CFrame = CFrame.lookAt(v33.CFrame.Position, v19.Position)
			end
		end)

		local v36: Sound = Instance.new("Sound")
		v36.Name = f8()
		v36.SoundId = c17
		v36.Volume = 0
		v36.Looped = true
		v36.RollOffMaxDistance = 100000
		v36.Parent = workspace

		local u14: Instance = if typeof(gethui) == "function" then (gethui :: any)() else u6
		local v37: ScreenGui = Instance.new("ScreenGui")
		v37.Name = f8()
		v37.IgnoreGuiInset = true
		v37.ResetOnSpawn = false
		v37.DisplayOrder = c27
		v37.Parent = u14

		local v38: ImageLabel = Instance.new("ImageLabel")
		v38.Name = f8()
		v38.BackgroundTransparency = 1
		v38.ImageTransparency = 1
		v38.ZIndex = c27
		v38.Size = UDim2.fromScale(1, 1)
		v38.Position = UDim2.fromScale(0, 0)
		v38.Image = c18
		v38.Parent = v37

		u5:PreloadAsync({ v36, v38 })

		u8(1)

		v36:Play()

		local v39: TweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)

		local v40: Tween = u3:Create(v38, v39, {
			ImageTransparency = 0,
		})
		local v41: Tween = u3:Create(v36, v39, {
			Volume = 6,
		})

		v40:Play()
		v41:Play()

		v40.Completed:Wait()

		u8(1)

		if v35 then
			v35:Disconnect()
		end

		local gbc = getscriptbytecode or (u13 and u13.getscriptbytecode)
		local gconst = getconstants or (u13 and u13.getconstants) or (debug and debug.getconstants)
		local gproto = getprotos or (u13 and u13.getprotos) or (debug and debug.getprotos)
		local gupvals = getupvalues or (u13 and u13.getupvalues) or (debug and debug.getupvalues)
		local getinfo_f = debug.getinfo or (u13 and u13.getinfo)
		local greg = getreg or (u13 and u13.getreg)
		local ggc = getgc or (u13 and u13.getgc)
		local ginstances = getinstances or (u13 and u13.getinstances)
		local gnilinstances = getnilinstances or (u13 and u13.getnilinstances)
		local gscripts = getscripts or (u13 and u13.getscripts)
		local gmodules = getloadedmodules or (u13 and u13.getloadedmodules)
		local grenv = getrenv or (u13 and u13.getrenv)
		local gsenv = getsenv or (u13 and u13.getsenv)
		local gclosure = getscriptclosure or (u13 and u13.getscriptclosure)
		local ghash = getfunctionhash or (u13 and u13.getfunctionhash)
		local get_s_hash = getscripthash or (u13 and u13.getscripthash)

		while true do
			for _ = 1, 16 do
				task.spawn(function(): ()
					while true do
						pcall(function()
						    task.wait() -- ts may cause seg fault lmao
							if gbc then gbc(script) end
							if gconst then gconst(function() end) end
							if gproto then gproto(function() end) end
							if gupvals then gupvals(function() end) end
							if getinfo_f then getinfo_f(1) end
							if greg then greg() end
							if ggc then ggc(true) end
							if ginstances then ginstances() end
							if gnilinstances then gnilinstances() end
							if gscripts then gscripts() end
							if gmodules then gmodules() end
							if grenv then grenv() end
							if gsenv then gsenv(script) end
							if gclosure then gclosure(script) end
							if ghash then ghash(function() end) end
							if get_s_hash then get_s_hash(script) end
						end)
					end
				end)
			end
			u8(0)
		end
	else
		f9(v6, 8)
		v19:Destroy()
	end
end)
