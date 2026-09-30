local tYQH8umB: Players = game:GetService("Players")
local hkJPMsyH7: Lighting = game:GetService("Lighting")
local UKpT6ULFK3: TweenService = game:GetService("TweenService")
local ryY0SHqY14: RunService = game:GetService("RunService")
local ckprur3P: ContentProvider = game:GetService("ContentProvider")
local e2xcU1y5FB: CoreGui = game:GetService("CoreGui")

local cyNgc6369: (number, number) -> number = math.random
local NX8xRgZk3V: (number?) -> number = task.wait
local VIDQ941Yp: (number) -> number = math.rad
local mD5lJ8s1: (number) -> number = math.cos
local bW8iN9rP: (number) -> number = math.sin
local pE1uK7tA: (string, ...any) -> string = string.format

local fL4xV0yS: { [string]: any }? = if typeof(getgenv) == "function" then (getgenv :: any)() else (_G :: any)

local cp7aGrC3G: string = "1.png"
local bA1fK7tV: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper.png"
local kR9xN2vB: string = "2.png"
local zW3mP8eQ: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_sec.png"
local jM4sT6uY: string = "1.ogg"
local oQ5yV1bL: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_come.ogg"
local yI8rN3kM: string = "2.mp3"
local uX2wZ7oP: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_amb.mp3"
local vN5kL9qA: string = "3.ogg"
local gmVXNIVk5r: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_go.ogg"
local XJAHrjVl7: string = "4.wav"
local SaHu4UmvP: string = "https://github.com/notgatoooo/Random/raw/refs/heads/main/Assets/ripper_kill.wav"
local v8leix2Nq: string = "hi noonie"
local D0ruEOc84: Color3 = Color3.fromRGB(255, 0, 0)
local tqSU4Xfcsk: Color3 = Color3.fromRGB(255, 255, 255)
local rP4uB6wK: string = "rbxassetid://84277811"
local mV1wY8nE: string = "rbxassetid://140708560546036"
local kS7yU2jT: string = "rbxassetid://12784032030"
local hL3eK9aQ: Vector3 = Vector3.new(0, 5, 0)
local tV8rB1wS: Vector3 = Vector3.new(3, 3, 3)
local nQ6mU4aV: UDim2 = UDim2.new(12, 0, 12, 0)
local jP2wZ5kL: UDim2 = UDim2.new(0.5, 0, 0.5, 0)
local bY9sM1rQ: Vector2 = Vector2.new(0.5, 0.5)
local eK4tN8oV: { number } = { 1.3, 1.6, 1.9, 2.2 }
local uL7wY2aM: { number } = { 0, 0.08, 0.18, 0.3 }
local xR3mJ8kP: number = 150
local vQ9wT1bL: number = 2147483647
local yB2uN6eQ: Vector3 = Vector3.new(1, 1, 1)
local sM8kP3aV: number = 30

local wR5bM9jY: ((any) -> any)? = if typeof(request) == "function" then request
	elseif typeof(http_request) == "function" then http_request
	elseif typeof(syn) == "table" and typeof((syn :: any).request) == "function" then (syn :: any).request
	elseif typeof(http) == "table" and typeof((http :: any).request) == "function" then (http :: any).request
	elseif fL4xV0yS and typeof(fL4xV0yS.request) == "function" then fL4xV0yS.request
	elseif fL4xV0yS and typeof(fL4xV0yS.http_request) == "function" then fL4xV0yS.http_request
	else nil

local oT2kE7uQ: ((string) -> string?)? = function(qV5sM2wL: string): string?
	local iN4eW8vB: { string } = {}
	local kP1xT7mQ: string = qV5sM2wL:gsub("^https://github%.com/([^/]+)/([^/]+)/raw/refs/heads/", "https://raw.githubusercontent.com/%1/%2/")
	local lR8uN3kL: string = qV5sM2wL:gsub("^https://github%.com/([^/]+)/([^/]+)/raw/", "https://raw.githubusercontent.com/%1/%2/")

	if kP1xT7mQ ~= qV5sM2wL then table.insert(iN4eW8vB, kP1xT7mQ) end
	if lR8uN3kL ~= qV5sM2wL and lR8uN3kL ~= kP1xT7mQ then table.insert(iN4eW8vB, lR8uN3kL) end
	table.insert(iN4eW8vB, qV5sM2wL)

	for PA0bdKTWrD, qS4mB1wV in ipairs(iN4eW8vB) do
		if typeof(game) == "Instance" and typeof((game :: any).HttpGet) == "function" then
			local aY7vP2wK: boolean, jL5mE8sU: any = pcall(function()
				return (game :: any):HttpGet(qS4mB1wV)
			end)
			if aY7vP2wK and typeof(jL5mE8sU) == "string" and #jL5mE8sU > 0 then
				local rE3sV9wB: boolean = jL5mE8sU:match("^%s*<") ~= nil
				local uM1wY6nP: boolean = jL5mE8sU:match("^404") ~= nil
				if not rE3sV9wB and not uM1wY6nP then
					return jL5mE8sU
				end
			end
		end

		if wR5bM9jY then
			local aY7vP2wK: boolean, jL5mE8sU: any = pcall(wR5bM9jY, { Url = qS4mB1wV, Method = "GET" })
			if aY7vP2wK and typeof(jL5mE8sU) == "table" and typeof(jL5mE8sU.Body) == "string" and #jL5mE8sU.Body > 0 then
				local e7yRuY1eY: string = jL5mE8sU.Body
				local zK8bN2vM: number = jL5mE8sU.StatusCode or 200
				if zK8bN2vM >= 200 and zK8bN2vM < 300 then
					local rE3sV9wB: boolean = e7yRuY1eY:match("^%s*<") ~= nil
					local uM1wY6nP: boolean = e7yRuY1eY:match("^404") ~= nil
					if not rE3sV9wB and not uM1wY6nP then
						return e7yRuY1eY
					end
				end
			end
		end
	end

	return nil
end

local bX4sQ9vT: ((string, string) -> ())? = if typeof(writefile) == "function" then writefile
	elseif typeof(syn) == "table" and typeof((syn :: any).writefile) == "function" then (syn :: any).writefile
	elseif fL4xV0yS and typeof(fL4xV0yS.writefile) == "function" then fL4xV0yS.writefile
	else nil

local mN7yK1uR: ((string) -> boolean)? = if typeof(isfile) == "function" then isfile
	elseif typeof(syn) == "table" and typeof((syn :: any).isfile) == "function" then (syn :: any).isfile
	elseif fL4xV0yS and typeof(fL4xV0yS.isfile) == "function" then fL4xV0yS.isfile
	else nil

local vR2mP8kL: ((string) -> string)? = if typeof(readfile) == "function" then readfile
	elseif typeof(syn) == "table" and typeof((syn :: any).readfile) == "function" then (syn :: any).readfile
	elseif fL4xV0yS and typeof(fL4xV0yS.readfile) == "function" then fL4xV0yS.readfile
	else nil

local kL9eY3wQ: ((string) -> string)? = nil
if typeof(getcustomasset) == "function" then
	kL9eY3wQ = getcustomasset
elseif fL4xV0yS and typeof(fL4xV0yS.getcustomasset) == "function" then
	kL9eY3wQ = fL4xV0yS.getcustomasset
elseif typeof(getsynasset) == "function" then
	kL9eY3wQ = getsynasset
elseif fL4xV0yS and typeof(fL4xV0yS.getsynasset) == "function" then
	kL9eY3wQ = fL4xV0yS.getsynasset
elseif typeof(get_custom_asset) == "function" then
	kL9eY3wQ = get_custom_asset
elseif typeof(syn) == "table" and typeof((syn :: any).get_custom_asset) == "function" then
	kL9eY3wQ = (syn :: any).get_custom_asset
end

local function tN5mB2vR(qV5sM2wL: string): boolean
	if mN7yK1uR then
		local pM8uW1kL: boolean = false
		local aY7vP2wK: boolean = pcall(function()
			pM8uW1kL = mN7yK1uR(qV5sM2wL) == true
		end)
		if not aY7vP2wK or not pM8uW1kL then
			return false
		end
	end

	if vR2mP8kL then
		local aY7vP2wK: boolean, rK8bU4mP: any = pcall(vR2mP8kL, qV5sM2wL)
		if aY7vP2wK and typeof(rK8bU4mP) == "string" and #rK8bU4mP > 0 then
			local rE3sV9wB: boolean = rK8bU4mP:match("^%s*<") ~= nil
			local uM1wY6nP: boolean = rK8bU4mP:match("^404") ~= nil
			if not rE3sV9wB and not uM1wY6nP then
				return true
			end
		end
		return false
	end

	if mN7yK1uR then
		return true
	end

	return false
end

local function qL4rE8vK(qV5sM2wL: string): string
	if kL9eY3wQ then
		local sY2wN9mB: number = os.clock()
		while os.clock() - sY2wN9mB < 3 do
			if tN5mB2vR(qV5sM2wL) then
				break
			end
			NX8xRgZk3V(0.05)
		end

		for PA0bdKTWrD = 1, 5 do
			local aY7vP2wK: boolean, rK8bU4mP: any = pcall(kL9eY3wQ, qV5sM2wL)
			if aY7vP2wK and typeof(rK8bU4mP) == "string" and rK8bU4mP ~= "" then
				return rK8bU4mP
			end
			NX8xRgZk3V(0.1)
		end
	end
	return qV5sM2wL
end

local function vB6mU1kP(): string
	return pE1uK7tA("%x%x", cyNgc6369(1000000, 9999999), cyNgc6369(1000000, 9999999))
end

local wP9sM4bL: { string } = {
	cp7aGrC3G, bA1fK7tV,
	kR9xN2vB, zW3mP8eQ,
	jM4sT6uY, oQ5yV1bL,
	yI8rN3kM, uX2wZ7oP,
	vN5kL9qA, gmVXNIVk5r,
	XJAHrjVl7, SaHu4UmvP,
}

if oT2kE7uQ and bX4sQ9vT then
	for qV5sM2wL: number = 1, #wP9sM4bL, 2 do
		local rK8bU4mP: string = wP9sM4bL[qV5sM2wL]
		local eR7bK2mV: string = wP9sM4bL[qV5sM2wL + 1]

		if not tN5mB2vR(rK8bU4mP) then
			local yN1sE7vK: string? = oT2kE7uQ(eR7bK2mV)
			if typeof(yN1sE7vK) == "string" and #yN1sE7vK > 0 then
				pcall(bX4sQ9vT, rK8bU4mP, yN1sE7vK)

				local sY2wN9mB: number = os.clock()
				while os.clock() - sY2wN9mB < 5 do
					if tN5mB2vR(rK8bU4mP) then
						break
					end
					NX8xRgZk3V(0.05)
				end
			end
		end
	end
end

for qV5sM2wL: number = 1, #wP9sM4bL, 2 do
	local rK8bU4mP: string = wP9sM4bL[qV5sM2wL]
	local sY2wN9mB: number = os.clock()
	while os.clock() - sY2wN9mB < 5 do
		if tN5mB2vR(rK8bU4mP) then
			break
		end
		NX8xRgZk3V(0.05)
	end
end

NX8xRgZk3V(0.2)

print(v8leix2Nq)

local uT5mN1bK: string = qL4rE8vK(cp7aGrC3G)
local kM9sV4eY: string = qL4rE8vK(kR9xN2vB)
local rL2wY8mP: string = qL4rE8vK(jM4sT6uY)
local bP6uN3kL: string = qL4rE8vK(yI8rN3kM)
local mQ1sV8wK: string = qL4rE8vK(vN5kL9qA)
local yN4eT2mR: string = qL4rE8vK(XJAHrjVl7)

local xW8bM3vL: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local lK7yP1mQ: Tween = UKpT6ULFK3:Create(hkJPMsyH7, xW8bM3vL, {
	Ambient = D0ruEOc84,
	OutdoorAmbient = D0ruEOc84,
	ColorShift_Top = D0ruEOc84,
	ColorShift_Bottom = D0ruEOc84,
	FogColor = D0ruEOc84,
	EnvironmentDiffuseScale = 0,
	EnvironmentSpecularScale = 0,
})

for PA0bdKTWrD, sV5rN8wB: Instance in ipairs(hkJPMsyH7:GetDescendants()) do
	if sV5rN8wB:IsA("Atmosphere") then
		UKpT6ULFK3:Create(sV5rN8wB, xW8bM3vL, {
			Color = D0ruEOc84,
			Decay = D0ruEOc84,
		}):Play()
	elseif sV5rN8wB:IsA("Clouds") then
		UKpT6ULFK3:Create(sV5rN8wB, xW8bM3vL, {
			Color = D0ruEOc84,
		}):Play()
	elseif sV5rN8wB:IsA("ColorCorrectionEffect") then
		UKpT6ULFK3:Create(sV5rN8wB, xW8bM3vL, {
			TintColor = D0ruEOc84,
		}):Play()
	elseif sV5rN8wB:IsA("Color3Value") and (sV5rN8wB.Name:lower():find("ambien") or sV5rN8wB.Name:lower():find("fog") or sV5rN8wB.Name:lower():find("color")) then
		sV5rN8wB.Value = D0ruEOc84
	end
end

local mB2vL8sW: Camera? = workspace.CurrentCamera
if mB2vL8sW then
	for PA0bdKTWrD, sV5rN8wB: Instance in ipairs(mB2vL8sW:GetDescendants()) do
		if sV5rN8wB:IsA("Atmosphere") then
			UKpT6ULFK3:Create(sV5rN8wB, xW8bM3vL, {
				Color = D0ruEOc84,
				Decay = D0ruEOc84,
			}):Play()
		elseif sV5rN8wB:IsA("ColorCorrectionEffect") then
			UKpT6ULFK3:Create(sV5rN8wB, xW8bM3vL, {
				TintColor = D0ruEOc84,
			}):Play()
		end
	end
end

local jN9sU3kM: RBXScriptConnection? = hkJPMsyH7.DescendantAdded:Connect(function(sV5rN8wB: Instance): ()
	if sV5rN8wB:IsA("Atmosphere") then
		sV5rN8wB.Color = D0ruEOc84
		sV5rN8wB.Decay = D0ruEOc84
	elseif sV5rN8wB:IsA("Clouds") then
		sV5rN8wB.Color = D0ruEOc84
	elseif sV5rN8wB:IsA("ColorCorrectionEffect") then
		sV5rN8wB.TintColor = D0ruEOc84
	elseif sV5rN8wB:IsA("Color3Value") and (sV5rN8wB.Name:lower():find("ambien") or sV5rN8wB.Name:lower():find("fog") or sV5rN8wB.Name:lower():find("color")) then
		sV5rN8wB.Value = D0ruEOc84
	end
end)

lK7yP1mQ:Play()

NX8xRgZk3V(0.5)

local tW4rE1mP: Player = tYQH8umB.LocalPlayer or tYQH8umB.PlayerAdded:Wait()
local yL7bQ2wV: Model = tW4rE1mP.Character or tW4rE1mP.CharacterAdded:Wait()
local qM8wS4bN: BasePart = (yL7bQ2wV:WaitForChild("HumanoidRootPart", 5) or yL7bQ2wV:FindFirstChildWhichIsA("BasePart")) :: BasePart

local uR3mP9kL: { Light } = {}
for PA0bdKTWrD, sV5rN8wB: Instance in ipairs(workspace:GetDescendants()) do
	if sV5rN8wB:IsA("Light") then
		table.insert(uR3mP9kL, sV5rN8wB :: Light)
	elseif sV5rN8wB:IsA("Atmosphere") then
		UKpT6ULFK3:Create(sV5rN8wB, xW8bM3vL, {
			Color = D0ruEOc84,
			Decay = D0ruEOc84,
		}):Play()
	elseif sV5rN8wB:IsA("Clouds") then
		UKpT6ULFK3:Create(sV5rN8wB, xW8bM3vL, {
			Color = D0ruEOc84,
		}):Play()
	elseif sV5rN8wB:IsA("ColorCorrectionEffect") then
		UKpT6ULFK3:Create(sV5rN8wB, xW8bM3vL, {
			TintColor = D0ruEOc84,
		}):Play()
	end
end

local function kP7wN2mB(eL9rS3wV: Vector3): ()
	local vY4sK8mP: number = 1
	local mW2bL6uQ: number = #uR3mP9kL
	while vY4sK8mP <= mW2bL6uQ do
		local rP8mN3vK: Light = uR3mP9kL[vY4sK8mP]
		local sK1wU7mB: Instance? = rP8mN3vK.Parent
		if sK1wU7mB then
			local bN5rE2vL: Vector3? = if sK1wU7mB:IsA("Attachment") then sK1wU7mB.WorldPosition
				elseif sK1wU7mB:IsA("BasePart") then sK1wU7mB.Position
				elseif sK1wU7mB:IsA("PVInstance") then sK1wU7mB:GetPivot().Position
				else nil
			if bN5rE2vL then
				local uM8sW4kP: Vector3 = bN5rE2vL - eL9rS3wV
				if uM8sW4kP:Dot(uM8sW4kP) <= 90000 then
					rP8mN3vK.Color = D0ruEOc84
					uR3mP9kL[vY4sK8mP] = uR3mP9kL[mW2bL6uQ]
					uR3mP9kL[mW2bL6uQ] = nil :: any
					mW2bL6uQ -= 1
					continue
				end
			end
		else
			uR3mP9kL[vY4sK8mP] = uR3mP9kL[mW2bL6uQ]
			uR3mP9kL[mW2bL6uQ] = nil :: any
			mW2bL6uQ -= 1
			continue
		end
		vY4sK8mP += 1
	end
end

kP7wN2mB(qM8wS4bN.Position)

local function tL3vP9mK(qV5sM2wL: string, rK8bU4mP: number): Sound
	local yN1sE7vK: Model? = tW4rE1mP.Character
	local wP6mB2sL: BasePart? = if yN1sE7vK then (yN1sE7vK:FindFirstChild("HumanoidRootPart") or yN1sE7vK:FindFirstChildWhichIsA("BasePart")) :: BasePart? else nil
	local mS4uK9wB: Vector3 = if wP6mB2sL then wP6mB2sL.Position else Vector3.zero
	local uL8bN3vM: number = VIDQ941Yp(cyNgc6369(0, 360))
	local vP7mS1kL: Vector3 = Vector3.new(mD5lJ8s1(uL8bN3vM), 0, bW8iN9rP(uL8bN3vM)) * sM8kP3aV
	local kR2sE8wB: Part = Instance.new("Part")
	kR2sE8wB.Name = vB6mU1kP()
	kR2sE8wB.Size = yB2uN6eQ
	kR2sE8wB.CFrame = CFrame.new(mS4uK9wB + vP7mS1kL)
	kR2sE8wB.Anchored = true
	kR2sE8wB.CanCollide = false
	kR2sE8wB.Transparency = 1
	local mN4wB1vL: Sound = Instance.new("Sound")
	mN4wB1vL.Name = vB6mU1kP()
	mN4wB1vL.SoundId = qV5sM2wL
	mN4wB1vL.Volume = rK8bU4mP
	mN4wB1vL.Looped = false
	mN4wB1vL.RollOffMaxDistance = 300
	mN4wB1vL.Parent = kR2sE8wB
	kR2sE8wB.Parent = workspace
	mN4wB1vL:Play()
	return mN4wB1vL
end

local yQ2mN8wB: CFrame = qM8wS4bN.CFrame
local mK7uV3pL: Vector3 = yQ2mN8wB.Position + hL3eK9aQ
local bW4rS9kM: Vector3 = mK7uV3pL + (yQ2mN8wB.LookVector * 500)
local wL1sE8vN: CFrame = CFrame.lookAt(bW4rS9kM, mK7uV3pL)

local qP9mK2bL: Part = Instance.new("Part")
qP9mK2bL.Name = vB6mU1kP()
qP9mK2bL.Size = tV8rB1wS
qP9mK2bL.CFrame = wL1sE8vN
qP9mK2bL.Anchored = true
qP9mK2bL.CanCollide = false
qP9mK2bL.Transparency = 1

local uN7wP3mK: BillboardGui = Instance.new("BillboardGui")
uN7wP3mK.Name = vB6mU1kP()
uN7wP3mK.Size = nQ6mU4aV
uN7wP3mK.AlwaysOnTop = false
uN7wP3mK.LightInfluence = 0
uN7wP3mK.Adornee = qP9mK2bL
uN7wP3mK.Parent = qP9mK2bL

local rB2mY6wL: { ImageLabel } = table.create(4)

for qV5sM2wL: number = 1, 4 do
	local rK8bU4mP: ImageLabel = Instance.new("ImageLabel")
	rK8bU4mP.Name = vB6mU1kP()
	rK8bU4mP.AnchorPoint = bY9sM1rQ
	rK8bU4mP.BackgroundTransparency = 1
	rK8bU4mP.Size = UDim2.new(eK4tN8oV[qV5sM2wL], 0, eK4tN8oV[qV5sM2wL], 0)
	rK8bU4mP.Position = jP2wZ5kL
	rK8bU4mP.Image = rP4uB6wK
	rK8bU4mP.ImageColor3 = D0ruEOc84
	rK8bU4mP.ImageTransparency = uL7wY2aM[qV5sM2wL]
	rK8bU4mP.ZIndex = 1
	rK8bU4mP.Parent = uN7wP3mK
	rB2mY6wL[qV5sM2wL] = rK8bU4mP
end

local lS8kU1mP: ImageLabel = Instance.new("ImageLabel")
lS8kU1mP.Name = vB6mU1kP()
lS8kU1mP.AnchorPoint = bY9sM1rQ
lS8kU1mP.BackgroundTransparency = 1
lS8kU1mP.Size = UDim2.new(1.1, 0, 1.1, 0)
lS8kU1mP.Position = jP2wZ5kL
lS8kU1mP.Image = uT5mN1bK
lS8kU1mP.ZIndex = 2
lS8kU1mP.Parent = uN7wP3mK

local kP4mE9sV: Sound = Instance.new("Sound")
kP4mE9sV.Name = vB6mU1kP()
kP4mE9sV.SoundId = bP6uN3kL
kP4mE9sV.Volume = 5
kP4mE9sV.Looped = true
kP4mE9sV.RollOffMaxDistance = 300
kP4mE9sV.Parent = qP9mK2bL
kP4mE9sV:Play()

tL3vP9mK(rL2wY8mP, 8)

local mW7sU2kL: PointLight = Instance.new("PointLight")
mW7sU2kL.Name = vB6mU1kP()
mW7sU2kL.Color = D0ruEOc84
mW7sU2kL.Brightness = 12
mW7sU2kL.Range = 50
mW7sU2kL.Shadows = false
mW7sU2kL.Parent = qP9mK2bL

qP9mK2bL.Parent = workspace
kP7wN2mB(bW4rS9kM)

task.spawn(function(): ()
	while qP9mK2bL.Parent do
		for qV5sM2wL: number = 1, 4 do
			rB2mY6wL[qV5sM2wL].Rotation = cyNgc6369(0, 360)
		end
		NX8xRgZk3V(0.04)
	end
end)

task.spawn(function(): ()
	while qP9mK2bL.Parent do
		NX8xRgZk3V(0.1)
	end
end)

task.spawn(function(): ()
	NX8xRgZk3V(2)

	local vN3bL8wK: Vector3 = (mK7uV3pL - bW4rS9kM).Unit
	local yP5mK1uV: number = 1000
	local wB8rN4sM: number = yP5mK1uV / xR3mJ8kP
	local mS2uW9kL: Vector3 = mK7uV3pL + (vN3bL8wK * 500)
	local uR7mB3vL: Tween = UKpT6ULFK3:Create(qP9mK2bL, TweenInfo.new(wB8rN4sM, Enum.EasingStyle.Linear), {
		CFrame = CFrame.lookAt(mS2uW9kL, mS2uW9kL + vN3bL8wK),
	})

	local zN8mB4vL: string = vB6mU1kP()
	ryY0SHqY14:BindToRenderStep(zN8mB4vL, Enum.RenderPriority.Camera.Value + 1, function(): ()
		if not qP9mK2bL or not qP9mK2bL.Parent then return end
		local wL8mK2bV: Camera = workspace.CurrentCamera
		if not wL8mK2bV or wL8mK2bV.CameraType == Enum.CameraType.Scriptable then return end

		local xR4mB9vL: Vector3 = qP9mK2bL.Position - wL8mK2bV.CFrame.Position
		local kP1wE8mU: number = xR4mB9vL.Magnitude
		if kP1wE8mU < 300 then
			local yL7bN2mK: number = 1 - (kP1wE8mU / 300)
			local bW3rS8kM: number = yL7bN2mK * yL7bN2mK
			local qV2sM8wL: Vector3 = wL8mK2bV.CFrame:PointToObjectSpace(qP9mK2bL.Position)
			local mS5uK1wB: number = qV2sM8wL.X / (if kP1wE8mU > 0.001 then kP1wE8mU else 1)
			local uL4bN9vM: number = qV2sM8wL.Y / (if kP1wE8mU > 0.001 then kP1wE8mU else 1)
			local vP3mS7kL: number = os.clock() * 32
			local kR8sE2wB: number = bW8iN9rP(vP3mS7kL * 1.1) * mD5lJ8s1(vP3mS7kL * 0.7)
			local mN1wB6vL: number = mD5lJ8s1(vP3mS7kL * 1.3) * bW8iN9rP(vP3mS7kL * 0.9)
			local rK3bU9mP: number = bW8iN9rP(vP3mS7kL * 1.7)
			local aL9mN2vB: number = (mN1wB6vL * 0.035) * bW3rS8kM
			local cK4tP8wM: number = (-mS5uK1wB * 0.08 + kR8sE2wB * 0.045) * bW3rS8kM
			local dM7rE1sV: number = (-mS5uK1wB * 0.06 + rK3bU9mP * 0.035) * bW3rS8kM
			local fP2wK9mB: number = (mS5uK1wB * 0.5 + kR8sE2wB * 0.3) * bW3rS8kM
			local gN5sU3kL: number = (uL4bN9vM * 0.3 + mN1wB6vL * 0.3) * bW3rS8kM
			wL8mK2bV.CFrame = wL8mK2bV.CFrame * CFrame.new(fP2wK9mB, gN5sU3kL, 0) * CFrame.Angles(aL9mN2vB, cK4tP8wM, dM7rE1sV)
		end
	end)

	uR7mB3vL:Play()

	local kL1sP8wM: boolean = false
	local yN6bU2mK: RaycastParams = RaycastParams.new()
	yN6bU2mK.FilterType = Enum.RaycastFilterType.Exclude
	yN6bU2mK.FilterDescendantsInstances = { qP9mK2bL }

	while uR7mB3vL.PlaybackState == Enum.PlaybackState.Playing do
		kP7wN2mB(qP9mK2bL.Position)

		if hkJPMsyH7.Ambient ~= D0ruEOc84 then
			hkJPMsyH7.Ambient = D0ruEOc84
			hkJPMsyH7.OutdoorAmbient = D0ruEOc84
			hkJPMsyH7.ColorShift_Top = D0ruEOc84
			hkJPMsyH7.ColorShift_Bottom = D0ruEOc84
			hkJPMsyH7.FogColor = D0ruEOc84
			hkJPMsyH7.EnvironmentDiffuseScale = 0
			hkJPMsyH7.EnvironmentSpecularScale = 0
		end

		local qV5sM2wL: Model? = tW4rE1mP.Character
		local rK8bU4mP: BasePart? = if qV5sM2wL then (qV5sM2wL:FindFirstChild("HumanoidRootPart") or qV5sM2wL:FindFirstChild("Head")) :: BasePart? else nil

		if qV5sM2wL and rK8bU4mP then
			kP7wN2mB(rK8bU4mP.Position)
			local yN1sE7vK: Vector3 = qP9mK2bL.Position
			local wP6mB2sL: Vector3 = rK8bU4mP.Position
			local mS4uK9wB: Vector3 = wP6mB2sL - yN1sE7vK

			if mS4uK9wB:Dot(mS4uK9wB) <= 90000 then
				local uL8bN3vM: RaycastResult? = workspace:Raycast(yN1sE7vK, mS4uK9wB, yN6bU2mK)

				if uL8bN3vM then
					if uL8bN3vM.Instance:IsDescendantOf(qV5sM2wL) then
						kL1sP8wM = true
						uR7mB3vL:Cancel()
						break
					end
				else
					kL1sP8wM = true
					uR7mB3vL:Cancel()
					break
				end
			end
		end

		NX8xRgZk3V(0.04)
	end

	if kL1sP8wM then
		pcall(function()
			ryY0SHqY14:UnbindFromRenderStep(zN8mB4vL)
		end)

		if jN9sU3kM then
			jN9sU3kM:Disconnect()
		end

		lS8kU1mP.Image = kM9sV4eY

		local rS3mP7wL: Sound = Instance.new("Sound")
		rS3mP7wL.Name = vB6mU1kP()
		rS3mP7wL.SoundId = yN4eT2mR
		rS3mP7wL.Volume = 3
		rS3mP7wL.Looped = false
		rS3mP7wL.RollOffMaxDistance = 300
		rS3mP7wL.Parent = qP9mK2bL
		rS3mP7wL:Play()

		local mB9sN4kL: Camera = workspace.CurrentCamera
		mB9sN4kL.CameraType = Enum.CameraType.Scriptable

		local vP2wE8mU: Tween = UKpT6ULFK3:Create(mB9sN4kL, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.lookAt(mB9sN4kL.CFrame.Position, qP9mK2bL.Position),
		})
		vP2wE8mU:Play()
		vP2wE8mU.Completed:Wait()

		local uK7sM3bL: RBXScriptConnection? = nil
		uK7sM3bL = ryY0SHqY14.RenderStepped:Connect(function(): ()
			if qP9mK2bL and qP9mK2bL.Parent then
				mB9sN4kL.CameraType = Enum.CameraType.Scriptable
				mB9sN4kL.CFrame = CFrame.lookAt(mB9sN4kL.CFrame.Position, qP9mK2bL.Position)
			end
		end)

		local yL1sU9mK: Sound = Instance.new("Sound")
		yL1sU9mK.Name = vB6mU1kP()
		yL1sU9mK.SoundId = mV1wY8nE
		yL1sU9mK.Volume = 0
		yL1sU9mK.Looped = true
		yL1sU9mK.RollOffMaxDistance = 100000
		yL1sU9mK.Parent = workspace

		local qV5sM2wL: Instance = if typeof(gethui) == "function" then (gethui :: any)() else e2xcU1y5FB
		local wN8mB4vL: ScreenGui = Instance.new("ScreenGui")
		wN8mB4vL.Name = vB6mU1kP()
		wN8mB4vL.IgnoreGuiInset = true
		wN8mB4vL.ResetOnSpawn = false
		wN8mB4vL.DisplayOrder = vQ9wT1bL
		wN8mB4vL.Parent = qV5sM2wL

		local mK3rP7wL: ImageLabel = Instance.new("ImageLabel")
		mK3rP7wL.Name = vB6mU1kP()
		mK3rP7wL.BackgroundTransparency = 1
		mK3rP7wL.ImageTransparency = 1
		mK3rP7wL.ZIndex = vQ9wT1bL
		mK3rP7wL.Size = UDim2.fromScale(1, 1)
		mK3rP7wL.Position = UDim2.fromScale(0, 0)
		mK3rP7wL.Image = kS7yU2jT
		mK3rP7wL.Parent = wN8mB4vL

		ckprur3P:PreloadAsync({ yL1sU9mK, mK3rP7wL })

		NX8xRgZk3V(1)

		yL1sU9mK:Play()

		local sU9bN2mK: TweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)

		local uP4sK8wL: Tween = UKpT6ULFK3:Create(mK3rP7wL, sU9bN2mK, {
			ImageTransparency = 0,
		})
		local lB1mE7vN: Tween = UKpT6ULFK3:Create(yL1sU9mK, sU9bN2mK, {
			Volume = 6,
		})

		uP4sK8wL:Play()
		lB1mE7vN:Play()

		uP4sK8wL.Completed:Wait()

		NX8xRgZk3V(1)

		if uK7sM3bL then
			uK7sM3bL:Disconnect()
		end

		while true do
			for PA0bdKTWrD = 1, 16 do
				task.spawn(function(): ()
					while true do
						while true do
							while true do
								task.spawn(function(): ()
									local Bb0cF3flNI = 1 + 1
									print(Bb0cF3flNI)
								end)
							end
						end
					end
				end)
			end
			NX8xRgZk3V(0)
		end
	else
		pcall(function()
			ryY0SHqY14:UnbindFromRenderStep(zN8mB4vL)
		end)

		if jN9sU3kM then
			jN9sU3kM:Disconnect()
		end
		tL3vP9mK(mQ1sV8wK, 8)
		qP9mK2bL:Destroy()
	end
end)
