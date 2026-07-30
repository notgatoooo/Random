-- Osvaldo e um viado

getgenv().isunx = "this is unxhub. | anti tamper: ahQ%o_q=8mQQt_[QAk"

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not isfolder("unxhub") then
    makefolder("unxhub")
    if not isfolder("unxhub/cache") then
        makefolder("unxhub/cache")
        if not isfile("unxhub/cache/lastlogs.txt") then
            writefile("unxhub/cache/lastlogs.txt")
        end
    end
end

function addlog(text, logtype)
    local time = os.date("%Y-%m-%d %H:%M:%S")
    local line = "[" .. time .. "][" .. tostring(logtype) .. "]: " .. tostring(text) .. "\n"
    if isfile("unxhub/cache/lastlogs.txt") then
        appendfile("unxhub/cache/lastlogs.txt", line)
    end
end

local function getsvr(service)
    local success, result = pcall(function()
        return game:GetService(service)
    end)
    if success and result then
        return result
    end
    return game:FindFirstChild(service) or game:FindFirstChildOfClass(service)
end

local Maid = loadstring([[
local Maid = {}
Maid.ClassName = "Maid"
Maid.__index = Maid

function Maid.new()
	return setmetatable({
		_tasks = {},
		_destroyed = false,
	}, Maid)
end

local function cleanupTask(task)
	if not task then
		return
	end

	local t = typeof(task)

	if t == "RBXScriptConnection" then
		task:Disconnect()
	elseif t == "Instance" then
		task:Destroy()
	elseif type(task) == "function" then
		task()
	elseif type(task) == "table" and type(task.Destroy) == "function" then
		task:Destroy()
	end
end

function Maid:Give(key, task)
	if self._destroyed then
		cleanupTask(task)
		return
	end

	if self._tasks[key] then
		cleanupTask(self._tasks[key])
	end

	self._tasks[key] = task
	return task
end

function Maid:GiveTask(task)
	if self._destroyed then
		cleanupTask(task)
		return
	end

	table.insert(self._tasks, task)
	return task
end

function Maid:DoCleaning()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for key, task in pairs(self._tasks) do
		cleanupTask(task)
		self._tasks[key] = nil
	end
end

function Maid:Destroy()
	self:DoCleaning()
end

return Maid
]])()

local Scheduler = loadstring([[
local Maid, RunService, addlog = ...

local Scheduler = {}
Scheduler.__index = Scheduler
Scheduler.Tasks = {}
Scheduler.Maid = Maid.new()

function Scheduler:Every(interval, fn)
    local taskObj = {
        Type = "Every",
        Interval = interval,
        NextRun = tick(),
        Function = fn,
        Active = true
    }
    table.insert(self.Tasks, taskObj)
    return taskObj
end

function Scheduler:After(delay, fn)
    local taskObj = {
        Type = "After",
        NextRun = tick() + delay,
        Function = fn,
        Active = true
    }
    table.insert(self.Tasks, taskObj)
    return taskObj
end

function Scheduler:Cancel(taskObj)
    if taskObj then taskObj.Active = false end
end

function Scheduler:Start()
    self.Maid:GiveTask(RunService.Heartbeat:Connect(function()
        local now = tick()
        for i = #self.Tasks, 1, -1 do
            local taskObj = self.Tasks[i]
            if not taskObj then
                table.remove(self.Tasks, i)
                continue
            end
            if not taskObj.Active then
                table.remove(self.Tasks, i)
            elseif now >= taskObj.NextRun then
                local success, err = pcall(taskObj.Function)
                if not success and addlog then addlog(tostring(err), "UNX_SCHELDULER_ERROR") end
                
                if taskObj and taskObj.Type == "Every" and taskObj.Active then
                    taskObj.NextRun = now + taskObj.Interval
                else
                    table.remove(self.Tasks, i)
                end
            end
        end
    end))
end

function Scheduler:Stop()
    self.Maid:DoCleaning()
    self.Tasks = {}
end

Scheduler:Start()
return Scheduler
]])(Maid, getsvr("RunService"), addlog)

local function GetHttp(url)
    addlog("GAH! Cache not found, using HttpGet() method for " .. tostring(url) .. "...", "UNX_LOADER")
    return game:HttpGet(url)
end

addlog("SafeGet thingy works", "UNX_LOADER")

local f_2 = "unxhub/cache"

local Library = loadstring(
    isfile(f_2 .. "/Library.lua") and readfile(f_2 .. "/Library.lua")
    or GetHttp("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua")
)()

do
    local _notify = Library.Notify
    function Library:Notify(...)
        task.spawn(function()
            local s = workspace:FindFirstChild("unx@instances") and workspace["unx@instances"]:FindFirstChild("unx@sfx")
            if s then
                s:Play()
            end
        end)
        return _notify(self, ...)
    end
end

local ThemeManager = loadstring(
    isfile(f_2 .. "/ThemeManager.lua") and readfile(f_2 .. "/ThemeManager.lua")
    or GetHttp("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua")
)()

local SaveManager = loadstring(
    isfile(f_2 .. "/SaveManager.lua") and readfile(f_2 .. "/SaveManager.lua")
    or GetHttp("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua")
)()

local BindModule = loadstring(
    isfile(f_2 .. "/Bind.lua") and readfile(f_2 .. "/Bind.lua")
    or GetHttp("https://api.getunx.cc/Modules/v2/Bind.lua")
)()

if not BindModule or type(BindModule) ~= "table" or not BindModule.Lock then
    BindModule = loadstring(GetHttp("https://api.getunx.cc/Modules/v2/Bind.lua"))()
end

addlog("Other stuff modules works", "UNX_LOADER")

local Options = Library.Options
local Toggles = Library.Toggles

local Players = getsvr("Players")
local RunService = getsvr("RunService")
local UserInputService = getsvr("UserInputService")
local Workspace = getsvr("Workspace")

local CharacterManager = {}
CharacterManager.__index = CharacterManager

function CharacterManager.new()
    local self = setmetatable({}, CharacterManager)
    self.LocalPlayer = Players.LocalPlayer
    return self
end

function CharacterManager:Init()
    local VirtualUser = getsvr("VirtualUser")
    
    UserInputService.JumpRequest:Connect(function()
        if Toggles.InfiniteJump and Toggles.InfiniteJump.Value then
            local char = self.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)

    RunService.Stepped:Connect(function()
        if Toggles.Noclip and Toggles.Noclip.Value then
            local char = self.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
    
    self.LocalPlayer.Idled:Connect(function()
        if Toggles.NoAFKKick and Toggles.NoAFKKick.Value then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)

    Scheduler:Every(0.025, function()
        self:UpdateLoop()
    end)
end

function CharacterManager:UpdateLoop()
    local char = self.LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if Toggles.LockWalkSpeed and Toggles.LockWalkSpeed.Value and hum then
        local targetWS = tonumber(Options.WalkSpeed.Value) or 16
        if hum.WalkSpeed ~= targetWS then
            hum.WalkSpeed = targetWS
        end
    end

    if Toggles.LockJumpPower and Toggles.LockJumpPower.Value and hum then
        hum.UseJumpPower = true
        local targetJP = tonumber(Options.JumpPower.Value) or 50
        if hum.JumpPower ~= targetJP then
            hum.JumpPower = targetJP
        end
    end

    if Toggles.LockMaxZoom and Toggles.LockMaxZoom.Value then
        local targetZoom = tonumber(Options.MaxZoom.Value) or 128
        self.LocalPlayer.CameraMaxZoom = targetZoom
        if self.LocalPlayer.CameraMinZoom > targetZoom then
            self.LocalPlayer.CameraMinZoom = targetZoom
        end
    end

    if Toggles.ForceThirdPerson and Toggles.ForceThirdPerson.Value then
        self.LocalPlayer.CameraMode = Enum.CameraMode.Classic
        self.LocalPlayer.CameraMinZoom = 5
    end

    if Toggles.CounterVoid and Toggles.CounterVoid.Value and root then
        local voidHeight = workspace.FallenPartsDestroyHeight + 5
        local p = workspace:FindFirstChild("unx@novoid")
        if not p then
            p = Instance.new("Part")
            p.Name = "unx@novoid"
            p.Anchored = true
            p.CanCollide = true
            p.Transparency = 1
            p.Size = Vector3.new(2, 1, 2)
            p.Parent = workspace
        end
        p.CFrame = CFrame.new(root.Position.X, voidHeight, root.Position.Z)
    else
        local p = workspace:FindFirstChild("unx@novoid")
        if p then p:Destroy() end
    end

    if Toggles.CounterFling and Toggles.CounterFling.Value and root then
        if root.AssemblyAngularVelocity.Magnitude > 50 or root.AssemblyLinearVelocity.Magnitude > 500 then
            root.AssemblyAngularVelocity = Vector3.new(0,0,0)
            root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= self.LocalPlayer and p.Character then
                for _, part in pairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
    
    if Toggles.Platform and Toggles.Platform.Value and root then
        local p = workspace:FindFirstChild("unx@pltf")
        if not p then
            p = Instance.new("Part")
            p.Name = "unx@pltf"
            p.Anchored = true
            p.CanCollide = true
            p.Transparency = 0.5
            p.Parent = workspace
        end
        local px = tonumber(Options.PlatformSizeX.Value) or 5
        local pz = tonumber(Options.PlatformSizeZ.Value) or 5
        p.Size = Vector3.new(px, 1, pz)
        p.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.1, root.Position.Z)
    else
        local p = workspace:FindFirstChild("unx@pltf")
        if p then p:Destroy() end
    end
end

local FlyManager = {}
FlyManager.__index = FlyManager

function FlyManager.new()
    return setmetatable({
        FlyMaid = Maid.new(),
        VFlyMaid = Maid.new(),
        CFlyMaid = Maid.new(),
        FlyActive = false,
        VFlyActive = false,
        CFlyActive = false
    }, FlyManager)
end

function FlyManager:StartFly()
    if self.FlyActive then return end
    self.FlyActive = true
    self.FlyMaid = Maid.new()

    local player = Players.LocalPlayer
    local camera = Workspace.CurrentCamera
    
    local function enableFly()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        hum.PlatformStand = true
        self.FlyMaid:GiveTask(function() if hum then hum.PlatformStand = false end end)

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = root
        self.FlyMaid:GiveTask(bodyVelocity)

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
        bodyGyro.P = 10000
        bodyGyro.D = 500
        bodyGyro.Parent = root
        self.FlyMaid:GiveTask(bodyGyro)

        local controlModule
        local success, err = pcall(function() 
            controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule", 5):WaitForChild("ControlModule", 5)) 
        end)
        
        if not success or not controlModule then return end

        self.FlyMaid:GiveTask(RunService.Heartbeat:Connect(function()
            if not hum or not root or not bodyVelocity.Parent or not bodyGyro.Parent then return end
            
            local speed = tonumber(Options.FlySpeed.Value) or 20
            local moveVector = controlModule:GetMoveVector()
            local dir = camera.CFrame:VectorToWorldSpace(moveVector)
            
            bodyVelocity.Velocity = dir * (speed * 10)
            bodyGyro.CFrame = camera.CFrame
        end))
    end

    enableFly()
    self.FlyMaid:GiveTask(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        enableFly()
    end))
end

function FlyManager:StopFly()
    self.FlyActive = false
    self.FlyMaid:DoCleaning()
end

function FlyManager:StartVFly()
    if self.VFlyActive then return end
    self.VFlyActive = true
    self.VFlyMaid = Maid.new()

    local player = Players.LocalPlayer
    local camera = Workspace.CurrentCamera

    local function enableVFly()
        local char = player.Character
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 10)
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        
        local target = root
        if hum.SeatPart then target = hum.SeatPart end

        local bv = Instance.new("BodyVelocity")
        bv.Name = "VFlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = target
        self.VFlyMaid:GiveTask(bv)

        local bg = Instance.new("BodyGyro")
        bg.Name = "VFlyGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 3000
        bg.D = 100
        bg.CFrame = target.CFrame
        bg.Parent = target
        self.VFlyMaid:GiveTask(bg)

        local controlModule
        local success, err = pcall(function() 
            controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule", 5):WaitForChild("ControlModule", 5)) 
        end)
        if not success or not controlModule then return end

        self.VFlyMaid:GiveTask(RunService.RenderStepped:Connect(function()
            if not target or not target.Parent or not bv.Parent or not bg.Parent then
                return
            end

            bg.CFrame = camera.CFrame
            local speed = tonumber(Options.VFlySpeed.Value) or 100
            local moveVector = controlModule:GetMoveVector()

            if moveVector.Magnitude > 0.1 then
                local direction = (camera.CFrame.LookVector * -moveVector.Z) + (camera.CFrame.RightVector * moveVector.X)
                bv.Velocity = direction.Unit * speed
            else
                bv.Velocity = Vector3.zero
            end
        end))
    end

    enableVFly()
    self.VFlyMaid:GiveTask(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        enableVFly()
    end))
end

function FlyManager:StopVFly()
    self.VFlyActive = false
    self.VFlyMaid:DoCleaning()
end

function FlyManager:StartCFly()
    if self.CFlyActive then return end
    self.CFlyActive = true
    self.CFlyMaid = Maid.new()

    local player = Players.LocalPlayer
    local camera = Workspace.CurrentCamera

    local function enableCFly()
        local char = player.Character
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 10)
        local head = char:WaitForChild("Head", 10)
        if not hum or not head then return end

        hum.PlatformStand = true
        self.CFlyMaid:GiveTask(function() if hum then hum.PlatformStand = false end end)
        
        head.Anchored = true
        self.CFlyMaid:GiveTask(function() if head then head.Anchored = false end end)

        self.CFlyMaid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime)
            if not hum or not head then return end
            
            local speed = tonumber(Options.CFlySpeed.Value) or 50
            local moveDirection = hum.MoveDirection * (speed * deltaTime)
            local headCFrame = head.CFrame
            local cameraCFrame = camera.CFrame
            local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
            cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
            local cameraPosition = cameraCFrame.Position
            local headPosition = headCFrame.Position

            local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
            head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
        end))
    end

    enableCFly()
    self.CFlyMaid:GiveTask(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        enableCFly()
    end))
end

function FlyManager:StopCFly()
    self.CFlyActive = false
    self.CFlyMaid:DoCleaning()
end

local CM = CharacterManager.new()
local FM = FlyManager.new()

Library.ForceCheckbox = true
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "UNXHub",
    Footer = "Version: " .. tostring(getgenv().unxshared and getgenv().unxshared.version or "Unknown") .. ", Game: " .. tostring(getgenv().unxshared and getgenv().unxshared.gamename or "Unknown") .. ", Player: " .. tostring(getgenv().unxshared and getgenv().unxshared.playername or "Unknown"),
    Icon = 73740010358428,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "house"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Features = Window:AddTab("Features", "bug"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local CharacterMods = Tabs.Main:AddLeftGroupbox("Character Mods", "user")

local function HandleBindButton(tglValue, bindName, optionToggle)
    if not BindModule then return end
    if tglValue then
        BindModule:AddToggleBB(bindName, function()
            optionToggle:SetValue(true)
        end, function()
            optionToggle:SetValue(false)
        end)
    else
        BindModule:DelBindB(bindName)
    end
end

CharacterMods:AddToggle("LockWalkSpeed", {
    Text = "Lock Walkspeed",
    Default = false,
})

CharacterMods:AddToggle("LockWalkSpeedBindButton", {
    Text = "Lock Walkspeed BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "Lock Walkspeed", Toggles.LockWalkSpeed)
    end
})

CharacterMods:AddInput("WalkSpeed", {
    Default = "16",
    Numeric = true,
    Finished = false,
    Text = "Walkspeed",
    Placeholder = "16",
})

CharacterMods:AddToggle("LockJumpPower", {
    Text = "Lock Jumppower",
    Default = false,
})

CharacterMods:AddToggle("LockJumpPowerBindButton", {
    Text = "Lock Jumppower BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "Lock Jumppower", Toggles.LockJumpPower)
    end
})

CharacterMods:AddInput("JumpPower", {
    Default = "50",
    Numeric = true,
    Finished = false,
    Text = "JumpPower",
    Placeholder = "50",
})

CharacterMods:AddToggle("LockMaxZoom", {
    Text = "Lock MaxZoom",
    Default = false,
})

CharacterMods:AddToggle("LockMaxZoomBindButton", {
    Text = "Lock MaxZoom BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "Lock MaxZoom", Toggles.LockMaxZoom)
    end
})

CharacterMods:AddInput("MaxZoom", {
    Default = "128",
    Numeric = true,
    Finished = false,
    Text = "MaxZoom",
    Placeholder = "128",
})

CharacterMods:AddDivider()

CharacterMods:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
})

CharacterMods:AddToggle("InfiniteJumpBindButton", {
    Text = "Infinite Jump BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "Infinite Jump", Toggles.InfiniteJump)
    end
})

CharacterMods:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
}):AddKeyPicker("NoclipKeybind", {
    Default = "N",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Noclip"
})

CharacterMods:AddToggle("NoclipBindButton", {
    Text = "Noclip BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "Noclip", Toggles.Noclip)
    end
})

CharacterMods:AddToggle("ForceThirdPerson", {
    Text = "Force Third Person",
    Default = false,
})

CharacterMods:AddToggle("ForceThirdPersonBindButton", {
    Text = "Force Third Person BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "Force Third Person", Toggles.ForceThirdPerson)
    end
})

CharacterMods:AddDivider()

CharacterMods:AddToggle("CounterFling", {
    Text = "Counter Fling",
    Default = false,
})

CharacterMods:AddToggle("CounterVoid", {
    Text = "Counter Void",
    Default = false,
})

CharacterMods:AddToggle("NoAFKKick", {
    Text = "No AFK Kick",
    Default = false,
})

local FlySection = Tabs.Main:AddLeftGroupbox("Fly", "plane")

FlySection:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(Value)
        if Value then
            if Toggles.VFly and Toggles.VFly.Value then Toggles.VFly:SetValue(false) end
            if Toggles.CFly and Toggles.CFly.Value then Toggles.CFly:SetValue(false) end
            FM:StartFly()
        else
            FM:StopFly()
        end
    end
}):AddKeyPicker("FlyKeybind", {
    Default = "F",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Fly"
})

FlySection:AddToggle("FlyBindButton", {
    Text = "Fly BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "Fly", Toggles.Fly)
    end
})

FlySection:AddInput("FlySpeed", {
    Default = "20",
    Numeric = true,
    Finished = false,
    Text = "Fly Speed",
    Placeholder = "20",
})

local VFlySection = Tabs.Main:AddLeftGroupbox("VFly", "plane")

VFlySection:AddToggle("VFly", {
    Text = "VFly",
    Default = false,
    Callback = function(Value)
        if Value then
            if Toggles.Fly and Toggles.Fly.Value then Toggles.Fly:SetValue(false) end
            if Toggles.CFly and Toggles.CFly.Value then Toggles.CFly:SetValue(false) end
            FM:StartVFly()
        else
            FM:StopVFly()
        end
    end
}):AddKeyPicker("VFlyKeybind", {
    Default = "V",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "VFly"
})

VFlySection:AddToggle("VFlyBindButton", {
    Text = "VFly BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "VFly", Toggles.VFly)
    end
})

VFlySection:AddInput("VFlySpeed", {
    Default = "100",
    Numeric = true,
    Finished = false,
    Text = "VFly Speed",
    Placeholder = "100",
})

local CFlySection = Tabs.Main:AddLeftGroupbox("CFly", "plane")

CFlySection:AddToggle("CFly", {
    Text = "CFly",
    Default = false,
    Callback = function(Value)
        if Value then
            if Toggles.Fly and Toggles.Fly.Value then Toggles.Fly:SetValue(false) end
            if Toggles.VFly and Toggles.VFly.Value then Toggles.VFly:SetValue(false) end
            FM:StartCFly()
        else
            FM:StopCFly()
        end
    end
}):AddKeyPicker("CFlyKeybind", {
    Default = "C",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "CFly"
})

CFlySection:AddToggle("CFlyBindButton", {
    Text = "CFly BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "CFly", Toggles.CFly)
    end
})

CFlySection:AddInput("CFlySpeed", {
    Default = "50",
    Numeric = true,
    Finished = false,
    Text = "CFly Speed",
    Placeholder = "50",
})

local CharFeatures = Tabs.Main:AddRightGroupbox("Character Features", "chevrons-left-right-ellipsis")

CharFeatures:AddToggle("Platform", {
    Text = "Platform",
    Default = false,
}):AddKeyPicker("PlatformKeybind", {
    Default = "P",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Platform"
})

CharFeatures:AddToggle("PlatformBindButton", {
    Text = "Platform BindButton",
    Default = false,
    Callback = function(Value)
        HandleBindButton(Value, "Platform", Toggles.Platform)
    end
})

CharFeatures:AddSlider("PlatformSizeX", {
    Text = "Platform Size (X)",
    Default = 5,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Compact = false,
})

CharFeatures:AddSlider("PlatformSizeZ", {
    Text = "Platform Size (Z)",
    Default = 5,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Compact = false,
})

local OthersSection = Tabs.Main:AddRightGroupbox("Others", "ellipsis")

OthersSection:AddButton("Reset Character", function()
    local char = CM.LocalPlayer.Character
    if char then char:BreakJoints() end
end)

OthersSection:AddButton("Damage Character", function()
    local char = CM.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid:TakeDamage(tonumber(Options.DamageAmount.Value) or 10)
    end
end)

OthersSection:AddInput("DamageAmount", {
    Default = "10",
    Numeric = true,
    Finished = false,
    Text = "Damage",
    Placeholder = "10",
})

local VisualsTabbox = Tabs.Visuals:AddLeftTabbox()
local EspTab = VisualsTabbox:AddTab("ESPs")
local ConfigTab = VisualsTabbox:AddTab("Configurations")

local LightningSection = Tabs.Visuals:AddRightGroupbox("Lightning", "lightbulb")

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("unxhub")
SaveManager:SetFolder("unxhub/universal")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
CM:Init()
if BindModule then
    BindModule:SetSizeB(1)
    BindModule:ResetPos()
end
