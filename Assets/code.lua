local shared = odh_shared

local section = shared.AddSection("Speed Glitch+")

local enabled = false
local force = 60
local onlySideways = false
local increaseForce = false
local multiplierVal = 13
local resetTimeVal = 10
local multiplierCapVal = 3

local player = game.Players.LocalPlayer
local character, humanoid, root
local canBoost = true
local jumpConn, stateConn, hbConn
local airTime = 0
local groundTime = 0
local activeJumpSession = false
local RunService = game:GetService("RunService")

local function cleanup()
	if jumpConn then jumpConn:Disconnect() jumpConn = nil end
	if stateConn then stateConn:Disconnect() stateConn = nil end
	if hbConn then hbConn:Disconnect() hbConn = nil end
end

local function isSideways(moveDir, look)
	local dot = math.abs(moveDir:Dot(look))
	return dot < 0.4
end

local function hookCharacter(char)
	cleanup()
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
	canBoost = true
	airTime = 0
	groundTime = 0
	activeJumpSession = false

	jumpConn = humanoid.Jumping:Connect(function(isJumping)
		if not enabled or not isJumping then return end
		activeJumpSession = true
		groundTime = 0
		if not canBoost then return end
		canBoost = false
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude == 0 then return end
		if onlySideways then
			local look = root.CFrame.LookVector
			if not isSideways(moveDir.Unit, look.Unit) then return end
		end
		local vel = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(
			vel.X + moveDir.X * force,
			vel.Y,
			vel.Z + moveDir.Z * force
		)
	end)

	stateConn = humanoid.StateChanged:Connect(function(_, state)
		if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed then
			canBoost = true
		end
	end)

	hbConn = RunService.Heartbeat:Connect(function(dt)
		if not enabled or not root or not humanoid then return end
		if not activeJumpSession then
			airTime = 0
			return
		end
		if humanoid.FloorMaterial == Enum.Material.Air then
			groundTime = 0
			if increaseForce then
				airTime = airTime + dt
				local moveDir = humanoid.MoveDirection
				if moveDir.Magnitude == 0 then return end
				if onlySideways then
					local look = root.CFrame.LookVector
					if not isSideways(moveDir.Unit, look.Unit) then return end
				end
				local multFactor = multiplierVal / 10
				local steps = math.floor(airTime / 0.2)
				if steps > multiplierCapVal then
					steps = multiplierCapVal
				end
				local currentForce = force * (multFactor ^ steps)
				local vel = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(
					moveDir.X * currentForce,
					vel.Y,
					moveDir.Z * currentForce
				)
			end
		else
			groundTime = groundTime + dt
			local currentReset = resetTimeVal / 100
			if groundTime > currentReset then
				airTime = 0
				activeJumpSession = false
			end
		end
	end)
end

player.CharacterAdded:Connect(function(char)
	if enabled then
		hookCharacter(char)
	end
end)

if player.Character then
	hookCharacter(player.Character)
end

section:AddToggle("Enable Speed Glitch+", function(bool)
	enabled = bool
	if enabled then
		if player.Character then
			hookCharacter(player.Character)
		end
	else
		cleanup()
	end
end)

section:AddSlider("Speed Glitch Force", 1, 1024, force, function(int)
	force = int
end)

section:AddToggle("Only Trigger Sideways", function(bool)
	onlySideways = bool
end)

section:AddToggle("Increase Force", function(bool)
	increaseForce = bool
end)

section:AddSlider("Multiplier <font color=\"rgb(60, 160, 255)\"><u>(10 = 1x, 30 = 3x)</u></font>", 11, 30, 13, function(int)
	multiplierVal = int
end)

section:AddSlider("Reset Time <font color=\"rgb(60, 160, 255)\"><u>(10 = 0.1s, 100 = 1s)</u></font>", 10, 100, 10, function(int)
	resetTimeVal = int
end)

section:AddSlider("Multiplier Cap <font color=\"rgb(60, 160, 255)\"><u>(Times To Multiply)</u></font>", 2, 10, 3, function(int)
	multiplierCapVal = int
end)
