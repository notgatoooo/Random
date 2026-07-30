local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

task.spawn(function()
    player.SimulationRadius = 99999
    player.MaximumSimulationRadius = 99999
    pcall(function() setsimulationradius(99999) end)
    game:GetService("RunService").Heartbeat:Connect(function()
        player.SimulationRadius = 99999
        player.MaximumSimulationRadius = 99999
    end)
end)

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ForceCheckbox = true

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "skiddex",
    Footer = "in the skid we believe 🙏🙏",
    Icon = 0,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "house"),
    Misc = Window:AddTab("UX Settings", "info")
}

local TargetGroup  = Tabs.Main:AddLeftGroupbox("Targeting & Setup", "")
local FunnyGroup   = Tabs.Main:AddLeftGroupbox("Funny", "")
local HelpersGroup = Tabs.Main:AddRightGroupbox("Helpers", "")
local OPGroup = Tabs.Main:AddRightGroupbox("OP", "")

local SettingsGroup = Tabs.Misc:AddRightGroupbox("UI Settings", "cog")

TargetGroup:AddDropdown("TargetName", {
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Text = "Target Player",
})

local function get()
    local targetOption = Options and Options.TargetName
    if not targetOption then return nil end
    
    local targetVal = targetOption.Value
    if not targetVal then return nil end

    if type(targetVal) == "table" then
        for k, v in pairs(targetVal) do
            if v then 
                targetVal = k 
                break 
            end
        end
    end

    if type(targetVal) == "string" and targetVal ~= "" then
        local extractedName = string.match(targetVal, "%(@([^%)]+)%)")
        if extractedName then
            targetVal = extractedName
        end

        local targetPlayer = Players:FindFirstChild(targetVal)
        if targetPlayer then return targetPlayer end

        local lowerName = string.lower(targetVal)
        for _, p in ipairs(Players:GetPlayers()) do
            if string.lower(p.Name) == lowerName or string.lower(p.DisplayName) == lowerName then
                return p
            end
        end
    elseif typeof(targetVal) == "Instance" and targetVal:IsA("Player") then
        return targetVal
    end

    return nil
end

do
    local TIME = 0.25
    local PO = Vector3.new(0, -3, 0)
    local RO = CFrame.Angles(math.rad(90), 0, math.rad(-69))
    local TP, con, savedpos, character, humanoid, root
    local db, isOn = false, false

    local function upd(newChar)
        character = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        root = newChar:WaitForChild("HumanoidRootPart")
    end
    if player.Character then upd(player.Character) end

    local function Stop()
        if con then con:Disconnect() con = nil end
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        if savedpos and root and root.Parent then
            root.CFrame = savedpos
            root.Velocity = Vector3.new()
            root.AssemblyLinearVelocity = Vector3.new()
            root.AssemblyAngularVelocity = Vector3.new()
            root.RotVelocity = Vector3.new()
        end
        savedpos = nil
    end

    local function Start()
        if db then return end
        db = true
        if con then con:Disconnect() con = nil end
        TP = get()
        if not TP then
            db = false; isOn = false
            return
        end
        savedpos = root.CFrame
        local tChar = TP.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

        con = RunService.Heartbeat:Connect(function()
            if not root or not root.Parent or humanoid.Health <= 0 then
                pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
                if con then con:Disconnect() end
                return
            end
            if not tRoot or not tRoot:IsDescendantOf(workspace) then
                tChar = TP.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart") or (tChar and tChar:WaitForChild("HumanoidRootPart", 0.2))
                if not tRoot then return end
            end
            pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", tRoot) end)
            root.CFrame = tRoot.CFrame * CFrame.new(PO) * RO
            root.Velocity = Vector3.new()
            root.AssemblyLinearVelocity = Vector3.new()
            root.AssemblyAngularVelocity = Vector3.new()
            root.RotVelocity = Vector3.new()
        end)

        task.delay(TIME, function()
            if isOn then
                isOn = false
                Stop()
            end
        end)

        TP.CharacterAdded:Connect(function(newChar)
            tChar = newChar
            tRoot = newChar:WaitForChild("HumanoidRootPart")
        end)
        db = false
    end

    FunnyGroup:AddButton({
        Text = "ForceJump",
        Func = function()
            if db then return end
            isOn = not isOn
            if isOn then Start() else Stop() end
        end
    })

    player.CharacterAdded:Connect(function(newChar)
        upd(newChar)
        if isOn then
            db = true; task.wait(0.5); db = false
            if isOn then Start() end
        end
    end)
    player.CharacterRemoving:Connect(function()
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        if con then con:Disconnect() end
    end)
end

local function is_that_tung_tung_tung_sahur(Name, DisplayName, Group, poVector, roCFrame, customExtras)
    local PO = poVector
    local RO = roCFrame
    local TP, con, savedpos, character, humanoid, root
    local db, isOn = false, false

    local function upd(newChar)
        character = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        root = newChar:WaitForChild("HumanoidRootPart")
    end
    if player.Character then upd(player.Character) end

    local function Stop()
        if con then con:Disconnect() con = nil end
        if customExtras and customExtras.stop then customExtras.stop() end
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        if savedpos and root and root.Parent then
            root.CFrame = savedpos
            root.Velocity = Vector3.new()
            root.AssemblyLinearVelocity = Vector3.new()
            root.AssemblyAngularVelocity = Vector3.new()
            root.RotVelocity = Vector3.new()
        end
        savedpos = nil
    end

    local function Start()
        if db then return end
        if con then con:Disconnect() con = nil end
        TP = get()
        if not TP then 
            Toggles[Name]:SetValue(false)
            return 
        end
        savedpos = root.CFrame
        local tChar = TP.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        
        if customExtras and customExtras.start then
            if customExtras.start() == false then
                Toggles[Name]:SetValue(false)
                return
            end
        end

        con = RunService.Heartbeat:Connect(function()
            if not root or not root.Parent or humanoid.Health <= 0 then
                pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
                if con then con:Disconnect() end
                return
            end
            if not tRoot or not tRoot:IsDescendantOf(workspace) then
                pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
                tChar = TP.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if not tRoot then return end
            end
            pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", tRoot) end)
            
            if customExtras and customExtras.dynamicOffset then
                PO, RO = customExtras.dynamicOffset(tRoot)
            end

            root.CFrame = tRoot.CFrame * CFrame.new(PO) * RO
            root.Velocity = Vector3.new()
            root.AssemblyLinearVelocity = Vector3.new()
            root.AssemblyAngularVelocity = Vector3.new()
            root.RotVelocity = Vector3.new()
            
            if customExtras and customExtras.heartbeat then customExtras.heartbeat(humanoid) end
        end)

        TP.CharacterAdded:Connect(function(newChar)
            tChar = newChar
            tRoot = newChar:WaitForChild("HumanoidRootPart")
        end)
    end

    Group:AddToggle(Name, {
        Text = DisplayName,
        Callback = function(Value)
            if db then return end
            isOn = Value
            if isOn then Start() else Stop() end
        end
    })

    player.CharacterAdded:Connect(function(newChar)
        upd(newChar)
        if isOn then
            db = true; task.wait(0.5); db = false
            if isOn then Start() end
        end
    end)
       player.CharacterRemoving:Connect(function()
       pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
       if con then con:Disconnect() end
       if customExtras and customExtras.cleanup then customExtras.cleanup() end
   end)
end


is_that_tung_tung_tung_sahur("NoJump", "NoJump", FunnyGroup, Vector3.new(0, 3.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
is_that_tung_tung_tung_sahur("Elevator", "Elevator", FunnyGroup, Vector3.new(0, -3, 0), CFrame.Angles(math.rad(-90), 0, math.rad(3.34)))

is_that_tung_tung_tung_sahur("HeadSit", "HeadSit", FunnyGroup, Vector3.new(0, 3, 0.9), CFrame.Angles(0, 0, 0), {
    heartbeat = function(humanoid) humanoid.Sit = true end,
    stop = function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.Sit = false end end
})

do
    local animTrack1, animTrack2, currentAnim, animLoop = nil, nil, 1, nil
    local function PlayNextAnimation(humanoid)
        if not humanoid then return end
        currentAnim = (currentAnim == 1) and 2 or 1
        if currentAnim == 1 then
            if animTrack2 then animTrack2:Stop() end
            if not animTrack1 then
                local anim1 = Instance.new("Animation")
                anim1.AnimationId = "rbxassetid://215262147"
                animTrack1 = humanoid:LoadAnimation(anim1)
            end
            animTrack1:Play()
        else
            if animTrack1 then animTrack1:Stop() end
            if not animTrack2 then
                local anim2 = Instance.new("Animation")
                anim2.AnimationId = "rbxassetid://185299570"
                animTrack2 = humanoid:LoadAnimation(anim2)
            end
            animTrack2:Play()
        end
    end
    local function StartAnimationLoop(humanoid)
        PlayNextAnimation(humanoid)
        animLoop = task.delay(0.5, function() StartAnimationLoop(humanoid) end)
    end
    local function StopAnimations()
        if animLoop then task.cancel(animLoop) animLoop = nil end
        if animTrack1 then animTrack1:Stop() animTrack1 = nil end
        if animTrack2 then animTrack2:Stop() animTrack2 = nil end
    end

    is_that_tung_tung_tung_sahur("Bang", "Bang", FunnyGroup, Vector3.new(0, 0, 1.1), CFrame.Angles(0, 0, 0), {
        start = function() 
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                StartAnimationLoop(player.Character.Humanoid)
            end
        end,
        stop = function() StopAnimations() end,
        cleanup = function() StopAnimations() end
    })
end

do
    is_that_tung_tung_tung_sahur("Annoy", "Annoy", FunnyGroup, Vector3.new(0,0,0), CFrame.Angles(0,0,0), {
        dynamicOffset = function()
            local dir = Vector3.new(
                math.random(-1000, 1000) / 100,
                math.random(-1000, 1000) / 100,
                math.random(-1000, 1000) / 100
            ).Unit
            local dist = math.random(50, 100) / 100
            return dir * dist, CFrame.Angles(0,0,0)
        end
    })
end


HelpersGroup:AddInput("SpeedInput", {
    Default = "",
    Numeric = false,
    Finished = false,
    Text = "Speed",
    Placeholder = "Speed Value",
})

do
    local function gzoffset(speed)
        speed = tonumber(speed)
        if not speed then return nil end
        if speed <= 1 then return 1.0
        elseif speed >= 10 then return 0.35
        else
            local t = (speed - 1) / (10 - 1)
            t = 1 - (1 - t) * (1 - t)
            return 1.0 - (1.0 - 0.35) * t
        end
    end

    is_that_tung_tung_tung_sahur("SpeedBoost", "Speed Boost", HelpersGroup, Vector3.new(0, 0.7, 0.5), CFrame.Angles(0, 0, 0), {
        start = function()
            local speedValue = Options.SpeedInput.Value
            local zOffset = gzoffset(speedValue)
            if not zOffset then
                return false
            end
        end,
        dynamicOffset = function()
            local zOffset = gzoffset(Options.SpeedInput.Value) or 0.5
            return Vector3.new(0, 0.7, zOffset), CFrame.Angles(0,0,0)
        end
    })
end

is_that_tung_tung_tung_sahur("InfJump", "Infinite Jump", HelpersGroup, Vector3.new(0, -5.75, 0), CFrame.Angles(0, 0, 0))
is_that_tung_tung_tung_sahur("PlatformFly", "Platform Fly", HelpersGroup, Vector3.new(0, -4, 0), CFrame.Angles(math.rad(-90), 0, 0))
is_that_tung_tung_tung_sahur("MagicCarpet", "Magic Carpet", HelpersGroup, Vector3.new(0, -3.6, 0), CFrame.Angles(math.rad(-90), 0, 0))


do
    
    local DefaultOffset = Vector3.new(0, -20, 0)
    local Offset_Space  = Vector3.new(0, -3, 0)

    local jumpConn, jumpActive, jumpTimer = nil, false, nil
    local ctrlHumanoid = nil

    is_that_tung_tung_tung_sahur("ControlPlayer", "Control Player", OPGroup, DefaultOffset, CFrame.Angles(0,0,0), {
        start = function()
            local camera = workspace.CurrentCamera
            local tp = get()
            if tp and tp.Character and tp.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = tp.Character.Humanoid
            end
            if player.Character then
                ctrlHumanoid = player.Character:FindFirstChild("Humanoid")
            end
            jumpConn = UserInputService.JumpRequest:Connect(function()
                jumpActive = true
                if jumpTimer then task.cancel(jumpTimer) end
                jumpTimer = task.delay(0.3, function()
                    jumpActive = false
                    jumpTimer = nil
                end)
            end)
        end,
        stop = function()
            if jumpConn then jumpConn:Disconnect() jumpConn = nil end
            if jumpTimer then task.cancel(jumpTimer) jumpTimer = nil end
            jumpActive = false
            ctrlHumanoid = nil
            local camera = workspace.CurrentCamera
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = player.Character.Humanoid
            end
        end,
        cleanup = function()
            if jumpConn then jumpConn:Disconnect() jumpConn = nil end
            if jumpTimer then task.cancel(jumpTimer) jumpTimer = nil end
            jumpActive = false
            ctrlHumanoid = nil
        end,
        heartbeat = function(h)
            ctrlHumanoid = h
        end,
        dynamicOffset = function(tRoot)
            local currentPO = DefaultOffset
            local currentRO = CFrame.Angles(0, 0, 0)

            if jumpActive then
                currentPO = Offset_Space
                currentRO = CFrame.Angles(math.rad(-90), 0, 0)
            elseif ctrlHumanoid and ctrlHumanoid.Parent and tRoot and tRoot.Parent then
                local moveDir = ctrlHumanoid.MoveDirection
                if moveDir.Magnitude > 0.1 then
                    
                    
                    
                    local localMove = tRoot.CFrame:VectorToObjectSpace(moveDir)
                    local lx =  localMove.X   
                    local lz = -localMove.Z   
                    
                    currentPO = Vector3.new(lx * 1.7, 0.7, lz * 0.5)
                end
            end

            return currentPO, currentRO
        end
    })
end

is_that_tung_tung_tung_sahur("InvertMovement", "Invert Movement", OPGroup, Vector3.new(0, 0.7, -0.8), CFrame.Angles(0, 0, 0))

OPGroup:AddDivider()

local function is_that_tung_tung_tung_sahur_v2(Name, Group, poVector, roCFrame, duration)
    local TIME = duration
    local PO = poVector
    local RO = roCFrame
    local TP, con, savedpos, character, humanoid, root
    local db, isOn = false, false

    local function upd(newChar)
        character = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        root = newChar:WaitForChild("HumanoidRootPart")
    end
    if player.Character then upd(player.Character) end

    local function Stop()
        if con then con:Disconnect() con = nil end
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        if savedpos and root and root.Parent then
            root.CFrame = savedpos
            root.Velocity = Vector3.new()
            root.AssemblyLinearVelocity = Vector3.new()
            root.AssemblyAngularVelocity = Vector3.new()
            root.RotVelocity = Vector3.new()
        end
        savedpos = nil
    end

    local function Start()
        if db then return end
        db = true
        if con then con:Disconnect() con = nil end
        TP = get()
        if not TP then
            db = false; isOn = false
            return
        end
        savedpos = root.CFrame
        local tChar = TP.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

        con = RunService.Heartbeat:Connect(function()
            if not root or not root.Parent or humanoid.Health <= 0 then
                pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
                if con then con:Disconnect() end
                return
            end
            if not tRoot or not tRoot:IsDescendantOf(workspace) then
                tChar = TP.Character
                tRoot = tChar and (tChar:FindFirstChild("HumanoidRootPart") or tChar:WaitForChild("HumanoidRootPart", 0.2))
                if not tRoot then return end
            end
            pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", tRoot) end)
            root.CFrame = tRoot.CFrame * CFrame.new(PO) * RO
            root.Velocity = Vector3.new()
            root.AssemblyLinearVelocity = Vector3.new()
            root.AssemblyAngularVelocity = Vector3.new()
            root.RotVelocity = Vector3.new()
        end)

        task.delay(TIME, function()
            if isOn then
                isOn = false
                Stop()
            end
        end)

        TP.CharacterAdded:Connect(function(newChar)
            tChar = newChar
            tRoot = newChar:WaitForChild("HumanoidRootPart")
        end)
        db = false
    end

    Group:AddButton({
        Text = Name,
        Func = function()
            if db then return end
            isOn = not isOn
            if isOn then Start() else Stop() end
        end
    })

    player.CharacterAdded:Connect(function(newChar)
        upd(newChar)
        if isOn then
            db = true; task.wait(0.5); db = false
            if isOn then Start() end
        end
    end)
    player.CharacterRemoving:Connect(function()
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        if con then con:Disconnect() end
    end)
end


is_that_tung_tung_tung_sahur_v2("Rocket", FunnyGroup, Vector3.new(0, -3, 0), CFrame.Angles(math.rad(90), 0, math.rad(-69)), 0.55)
is_that_tung_tung_tung_sahur_v2("Slam", FunnyGroup, Vector3.new(0, 0.35, 0), CFrame.Angles(0, 0, 0), 4)
is_that_tung_tung_tung_sahur_v2("Jumpscare (First Person)", FunnyGroup, Vector3.new(0, 1.5, -0.8), CFrame.Angles(0, math.rad(180), 0), 2)

do
    local TIME = 1
    local PO = Vector3.new(0, 0, 0)
    local RO = CFrame.Angles(0, 0, 0)
    local TP, con, savedpos, character, humanoid, root
    local db, isOn = false, false

    local function upd(newChar)
        character = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        root = newChar:WaitForChild("HumanoidRootPart")
    end
    if player.Character then upd(player.Character) end

    local function hardStop()
        if con then con:Disconnect() con = nil end
        isOn = false
    end

    local function Stop()
        hardStop()
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        if savedpos and root and root.Parent then
            root.CFrame = savedpos
            root.Velocity = Vector3.new()
            root.AssemblyLinearVelocity = Vector3.new()
            root.AssemblyAngularVelocity = Vector3.new()
            root.RotVelocity = Vector3.new()
        end
        savedpos = nil
    end

    local function Start()
        if db then return end
        db = true
        if con then con:Disconnect() con = nil end
        TP = get()
        if not TP or not root or not root.Parent or not humanoid or not humanoid.Parent then
            db = false; isOn = false
            return
        end
        savedpos = root.CFrame
        local tChar = TP.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local sessionActive = true

        con = RunService.Heartbeat:Connect(function()
            if not sessionActive then
                if con then con:Disconnect() con = nil end
                return
            end
            local localRoot, localHumanoid = root, humanoid
            if not localRoot or not localRoot.Parent or not localHumanoid or not localHumanoid.Parent or localHumanoid.Health <= 0 then
                pcall(function() sethiddenproperty(localRoot, "PhysicsRepRootPart", nil) end)
                sessionActive = false; hardStop()
                return
            end
            if not TP or not TP.Parent then
                pcall(function() sethiddenproperty(localRoot, "PhysicsRepRootPart", nil) end)
                sessionActive = false; hardStop()
                return
            end
            if not tRoot or not tRoot:IsDescendantOf(workspace) then
                tChar = TP.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if not tRoot then return end
            end

            pcall(function() sethiddenproperty(localHumanoid, "MoveDirectionInternal", Vector3.new(0/0, 0/0, 0/0)) end)
            pcall(function() sethiddenproperty(localRoot, "PhysicsRepRootPart", tRoot) end)
            
            localRoot.CFrame = tRoot.CFrame * CFrame.new(PO) * RO
            localRoot.Velocity = Vector3.new()
            localRoot.AssemblyLinearVelocity = Vector3.new()
            localRoot.AssemblyAngularVelocity = Vector3.new()
            localRoot.RotVelocity = Vector3.new()
        end)

        task.delay(TIME, function()
            sessionActive = false
            if isOn then
                Stop()
                isOn = false
            end
        end)

        TP.CharacterAdded:Connect(function(newChar)
            if not sessionActive then return end
            tChar = newChar
            tRoot = newChar:WaitForChild("HumanoidRootPart")
        end)
        db = false
    end

    
    OPGroup:AddButton({
        Text = "Fling Target",
        Func = function()
            if db then return end
            isOn = not isOn
            if isOn then Start() else Stop() end
        end
    })

    player.CharacterAdded:Connect(function(newChar)
        upd(newChar)
        if isOn then db = true; task.wait(0.5); db = false; if isOn then Start() end end
    end)
    player.CharacterRemoving:Connect(function()
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        if con then con:Disconnect() con = nil end
    end)
end

local function caf(Name, Group, poVector, roCFrame, stepTime, useMoveDirection)
    local TPList, doneSet, currentIndex = {}, {}, 1
    local tChar, tRoot, con, moveDirCon, savedPos
    local isOn, sessionActive = false, false
    local character, humanoid, root

    local function upd(newChar)
        character = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        root = newChar:WaitForChild("HumanoidRootPart")
    end
    if player.Character then upd(player.Character) end

    local function stopMoveDirection()
        if moveDirCon then moveDirCon:Disconnect() moveDirCon = nil end
    end
    
    local function restorePosition()
        if savedPos and root and root.Parent then
            root.CFrame = savedPos
            root.Velocity = Vector3.new()
            root.AssemblyLinearVelocity = Vector3.new()
            root.AssemblyAngularVelocity = Vector3.new()
            root.RotVelocity = Vector3.new()
        end
        savedPos = nil
    end

    local function hardStop()
        sessionActive = false
        if con then con:Disconnect() con = nil end
        stopMoveDirection()
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        restorePosition()
        isOn = false
    end

    local function updateTargetCharacter()
        local tp = TPList[currentIndex]
        if tp and tp.Parent then
            tChar = tp.Character
            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart") or nil
        else
            tChar = nil; tRoot = nil
        end
    end

    local function allDone()
        for _, p in ipairs(TPList) do
            if not doneSet[p] then return false end
        end
        return true
    end

    local function advanceToNext()
        local startIdx = currentIndex
        local count = #TPList
        for i = 1, count do
            local idx = (startIdx - 1 + i) % count + 1
            local p = TPList[idx]
            if p and p.Parent and not doneSet[p] then
                local c = p.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if c and r and r:IsDescendantOf(workspace) then
                    currentIndex = idx
                    tChar = c; tRoot = r
                    return true
                end
            end
        end
        return false
    end

    local function Start()
        if con then con:Disconnect() con = nil end
        stopMoveDirection()
        TPList, doneSet = {}, {}
        for _, p in Players:GetPlayers() do
            if p ~= player then table.insert(TPList, p) end
        end

        if #TPList == 0 then return end
        if root and root.Parent then savedPos = root.CFrame end

        currentIndex = 1
        sessionActive = true
        updateTargetCharacter()

        if not tRoot then
            if not advanceToNext() then
                sessionActive = false; savedPos = nil
                return
            end
        end

        local timeOnTarget = tick()

        if useMoveDirection then
            moveDirCon = RunService.Heartbeat:Connect(function()
                if not sessionActive then stopMoveDirection() return end
                if not root or not root.Parent or not humanoid or humanoid.Health <= 0 then stopMoveDirection() return end
                if not tRoot or not tRoot:IsDescendantOf(workspace) then return end
                pcall(function() sethiddenproperty(humanoid, "MoveDirectionInternal", Vector3.new(0/0, 0/0, 0/0)) end)
            end)
        end

        con = RunService.Heartbeat:Connect(function()
            if not sessionActive then
                if con then con:Disconnect() con = nil end
                return
            end
            local lr, lh = root, humanoid
            if not lr or not lr.Parent or not lh or not lh.Parent or lh.Health <= 0 then
                pcall(function() sethiddenproperty(lr, "PhysicsRepRootPart", nil) end)
                hardStop() return
            end
            if not tRoot or not tRoot:IsDescendantOf(workspace) then
                local tp = TPList[currentIndex]
                if tp and tp.Parent and not doneSet[tp] then updateTargetCharacter() end
                if not tRoot then
                    if not advanceToNext() then
                        if allDone() then hardStop() end
                    end
                end
                return
            end

            if tick() - timeOnTarget >= stepTime then
                local tp = TPList[currentIndex]
                if tp then doneSet[tp] = true end
                pcall(function() sethiddenproperty(lr, "PhysicsRepRootPart", nil) end)
                if allDone() then hardStop() return end
                if not advanceToNext() then return end
                timeOnTarget = tick()
            end

            pcall(function() sethiddenproperty(lr, "PhysicsRepRootPart", tRoot) end)
            lr.CFrame = tRoot.CFrame * CFrame.new(poVector) * roCFrame
            lr.Velocity = Vector3.new()
            lr.AssemblyLinearVelocity = Vector3.new()
            lr.AssemblyAngularVelocity = Vector3.new()
            lr.RotVelocity = Vector3.new()
        end)
    end

    Group:AddButton({
        Text = Name,
        Func = function()
            isOn = not isOn
            if isOn then Start() else hardStop() end
        end
    })

    player.CharacterAdded:Connect(function(newChar)
        upd(newChar)
        if isOn then task.wait(0.5); if isOn then Start() end end
    end)
    player.CharacterRemoving:Connect(function()
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
        stopMoveDirection()
        if con then con:Disconnect() con = nil end
        sessionActive = false; savedPos = nil
    end)
    Players.PlayerAdded:Connect(function(p)
        if p ~= player and isOn then table.insert(TPList, p) end
    end)
    Players.PlayerRemoving:Connect(function(p)
        if not isOn then return end
        doneSet[p] = nil
        for i, tp in ipairs(TPList) do
            if tp == p then
                table.remove(TPList, i)
                if currentIndex > #TPList then currentIndex = 1 end
                updateTargetCharacter()
                break
            end
        end
    end)
    for _, p in Players:GetPlayers() do
        if p ~= player then
            p.CharacterAdded:Connect(function()
                if isOn and p == TPList[currentIndex] then updateTargetCharacter() end
            end)
        end
    end
end

caf("Jumpscare All", FunnyGroup, Vector3.new(0, 1.5, -0.8), CFrame.Angles(0, math.rad(180), 0), 1, false)
caf("Fling All", OPGroup, Vector3.new(0, 0, 0), CFrame.Angles(0, 0, 0), 1.5, true)


do
    local clickFlingCon, clickFlingEnabled = nil, false
    local flingCon, flingTarget = nil, nil
    
    local function StartClickFling()
        clickFlingCon = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local mouse = player:GetMouse()
                local target = mouse.Target
                if target then
                    local character = target:FindFirstAncestorWhichIsA("Model")
                    if character then
                        local humanoid = character:FindFirstChild("Humanoid")
                        if humanoid then
                            local targetPlayer = Players:GetPlayerFromCharacter(character)
                            if targetPlayer and targetPlayer ~= player then
                                flingTarget = targetPlayer
                                local tChar = targetPlayer.Character
                                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                local lChar = player.Character
                                local lRoot = lChar and lChar:FindFirstChild("HumanoidRootPart")
                                if tRoot and lRoot then
                                    lRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
                                    task.wait(0.1)
                                    if flingCon then flingCon:Disconnect() end
                                    local sessionActive = true
                                    flingCon = RunService.Heartbeat:Connect(function()
                                        if not sessionActive then return end
                                        if not lRoot or not lRoot.Parent then
                                            sessionActive = false
                                            return
                                        end
                                        if not tRoot or not tRoot:IsDescendantOf(workspace) then
                                            tChar = targetPlayer.Character
                                            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                            if not tRoot then return end
                                        end
                                        pcall(function() sethiddenproperty(lRoot, "PhysicsRepRootPart", tRoot) end)
                                        lRoot.CFrame = tRoot.CFrame
                                        lRoot.Velocity = Vector3.new()
                                        lRoot.AssemblyLinearVelocity = Vector3.new()
                                        lRoot.AssemblyAngularVelocity = Vector3.new()
                                        lRoot.RotVelocity = Vector3.new()
                                        pcall(function() sethiddenproperty(lChar.Humanoid, "MoveDirectionInternal", Vector3.new(0/0, 0/0, 0/0)) end)
                                    end)
                                    task.delay(1, function()
                                        sessionActive = false
                                        if flingCon then flingCon:Disconnect() flingCon = nil end
                                        pcall(function() sethiddenproperty(lRoot, "PhysicsRepRootPart", nil) end)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    local function StopClickFling()
        if clickFlingCon then clickFlingCon:Disconnect() clickFlingCon = nil end
        if flingCon then flingCon:Disconnect() flingCon = nil end
        flingTarget = nil
    end
    
    OPGroup:AddToggle("ClickFling", {
        Text = "Click Fling",
        Default = false,
        Callback = function(Value)
            clickFlingEnabled = Value
            if clickFlingEnabled then
                StartClickFling()
            else
                StopClickFling()
            end
        end
    })
end


do
    local flyFlingEnabled = false
    local flyCon, flingCon2, bg, bv = nil, nil, nil, nil
    local flySpeed = 50
    local goingUp, goingDown = false, false
    
    local function StartFlyFling()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = hrp.CFrame
        bg.Parent = hrp
        
        bv = Instance.new("BodyVelocity")
        bv.velocity = Vector3.new(0, 0, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = hrp
        
        local cam = workspace.CurrentCamera
        
        local upConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Space then
                goingUp = true
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                goingDown = true
            end
        end)
        
        local upConn2 = UserInputService.InputEnded:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Space then
                goingUp = false
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                goingDown = false
            end
        end)
        
        local jumpConn = UserInputService.JumpRequest:Connect(function()
            goingUp = true
            task.delay(0.3, function()
                goingUp = false
            end)
        end)
        
        flyCon = RunService.RenderStepped:Connect(function()
            if not flyFlingEnabled then return end
            if not hrp or not hrp.Parent then return end
            
            bg.cframe = cam.CFrame
            
            local humanoid = char:FindFirstChild("Humanoid")
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            
            if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
                local cf = cam.CFrame.Rotation
                local dir = cf:VectorToObjectSpace(humanoid.MoveDirection * 10)
                if dir.Magnitude ~= 0 then
                    local mobileMove = cf:VectorToWorldSpace(Vector3.new(dir.X, 0, dir.Z).Unit * dir.Magnitude)
                    moveDir = moveDir + mobileMove
                end
            end
            
            if goingUp then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if goingDown then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
            
            if moveDir.Magnitude > 0 then
                bv.velocity = moveDir.Unit * flySpeed
            else
                bv.velocity = Vector3.new(0, 0, 0)
            end
        end)
        
        flingCon2 = RunService.Heartbeat:Connect(function()
            if not flyFlingEnabled then return end
            if not hrp or not hrp.Parent then return end
            
            local nearestPlayer = nil
            local nearestDist = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if tHrp then
                        local dist = (hrp.Position - tHrp.Position).Magnitude
                        if dist < nearestDist and dist < 10 then
                            nearestDist = dist
                            nearestPlayer = p
                        end
                    end
                end
            end
            
            if nearestPlayer then
                local tHrp = nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", tHrp) end)
                    pcall(function() sethiddenproperty(char.Humanoid, "MoveDirectionInternal", Vector3.new(0/0, 0/0, 0/0)) end)
                end
            else
                pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end)
            end
        end)
    end
    
    local function StopFlyFling()
        flyFlingEnabled = false
        if flyCon then flyCon:Disconnect() flyCon = nil end
        if flingCon2 then flingCon2:Disconnect() flingCon2 = nil end
        if bg then bg:Destroy() bg = nil end
        if bv then bv:Destroy() bv = nil end
        goingUp, goingDown = false, false
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end)
            end
        end
    end
    
    OPGroup:AddToggle("FlyFling", {
        Text = "Fly Fling",
        Default = false,
        Callback = function(Value)
            flyFlingEnabled = Value
            if flyFlingEnabled then
                StartFlyFling()
            else
                StopFlyFling()
            end
        end
    })
end


do
    local touchFlingEnabled = false
    local touchedCon = nil
    local flingConnections = {}
    
    local function StartTouchFling()
        local function onTouched(hit)
            if not touchFlingEnabled then return end
            local char = hit:FindFirstAncestorWhichIsA("Model")
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            local targetPlayer = Players:GetPlayerFromCharacter(char)
            if not targetPlayer or targetPlayer == player then return end
            
            local lChar = player.Character
            local lHrp = lChar and lChar:FindFirstChild("HumanoidRootPart")
            local tHrp = char:FindFirstChild("HumanoidRootPart")
            if not lHrp or not tHrp then return end
            
            if flingConnections[targetPlayer] then return end
            
            local sessionActive = true
            local con = RunService.Heartbeat:Connect(function()
                if not sessionActive then return end
                if not lHrp or not lHrp.Parent then
                    sessionActive = false
                    return
                end
                if not tHrp or not tHrp:IsDescendantOf(workspace) then
                    tHrp = char:FindFirstChild("HumanoidRootPart")
                    if not tHrp then return end
                end
                pcall(function() sethiddenproperty(lHrp, "PhysicsRepRootPart", tHrp) end)
                lHrp.CFrame = tHrp.CFrame
                lHrp.Velocity = Vector3.new()
                lHrp.AssemblyLinearVelocity = Vector3.new()
                lHrp.AssemblyAngularVelocity = Vector3.new()
                lHrp.RotVelocity = Vector3.new()
                pcall(function() sethiddenproperty(lChar.Humanoid, "MoveDirectionInternal", Vector3.new(0/0, 0/0, 0/0)) end)
            end)
            
            flingConnections[targetPlayer] = con
            
            task.delay(1.5, function()
                sessionActive = false
                if con then con:Disconnect() end
                flingConnections[targetPlayer] = nil
                if lHrp and lHrp.Parent then
                    pcall(function() sethiddenproperty(lHrp, "PhysicsRepRootPart", nil) end)
                end
            end)
        end
        
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                touchedCon = hrp.Touched:Connect(onTouched)
            end
        end
        
        player.CharacterAdded:Connect(function(newChar)
            if not touchFlingEnabled then return end
            task.wait(0.5)
            local newHrp = newChar:FindFirstChild("HumanoidRootPart")
            if newHrp then
                if touchedCon then touchedCon:Disconnect() end
                touchedCon = newHrp.Touched:Connect(onTouched)
            end
        end)
    end
    
    local function StopTouchFling()
        touchFlingEnabled = false
        if touchedCon then touchedCon:Disconnect() touchedCon = nil end
        for _, con in pairs(flingConnections) do
            if con then con:Disconnect() end
        end
        flingConnections = {}
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end)
            end
        end
    end
    
    OPGroup:AddToggle("TouchFling", {
        Text = "Touch Fling",
        Default = false,
        Callback = function(Value)
            touchFlingEnabled = Value
            if touchFlingEnabled then
                StartTouchFling()
            else
                StopTouchFling()
            end
        end
    })
end

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("skiddex")
SaveManager:BuildConfigSection(Tabs.Misc)
ThemeManager:ApplyToTab(Tabs.Misc)

print([[
in behalf of the skiddex team we got a image for u, enjoy it!:
---------------------------------------------------------------
-----------------------------------#%%#=-----------------------
----------------------------------=*=+#%+++==------------------
-----------------------=---------=#%%%%%%%%%%%#=---------------
----------------------=:--------#%%%%%%%%%%%%%%%@%%%=----------
------------------------:=-----#%%%%%%%%%%%%%%%%%%@%%#---------
--------------------=-----=---+%%%%%#@@%@@%%%%%%%%%%%%+--------
---------------------:=---=---%%%%%+-=*%=%@@%%%%%%%@%%#--------
---------------------=----==-=%%@%%%%%=:-#=+@@%%%%%@%%%--------
------------------------=-----#%@%#--==+--=-=%@%%%%#%%%--------
----------------------------=-==#%*::-+*=:-=%%=-::::-%%--------
--------------------------+*+****%%*---:::-*%*-:::::-#%=-------
-----------------------+#######%%%%%%%%%%%%+=*-::::::=%#-------
---------------------+%########%%%%%%%######%%+:::::::+%+------
--------------------=#%+=-:::-=*+==---==+######=:::::::*%*-----
------------=#**+=--=+-:::::::-+=-:::::::::-###+-:::::::+------
----------+%+::::::=+=*=-::---====-::::::::::+***==+#-::-=-----
---------#+==::::::::-+=++*=-::::-==--:::---#*-:--=++=+-=------
--------*=+==::::::::--+-=-::::::::::-===++-:::::===+-=#=------
-------++-+-=::::::::--+=::::::::::::-+=-:::::-==+=-=-..+=-----
------==:=:++=:::::::-=-::::-:::::::-=-::::::-++=:=-....-+-----
------=..-+-++-:::::::-::::-+=:::::-:::::::::#*=:+:......==----
-----=:...-+=+++-::::::::-----:::::::::::::-%*++=........-+----
------....:-++*#+:::::::=-:----::::::::::::=%#*=-.........==---
----=....:--=+*+-::::::--------:::::::::::::*#+--:.........#---
---=.....:--==++:::::::::---::::::::::::::::-#+=-:.........-+--
----.....--==+*-:::::::-::--:::-=::::::::::--+*=--:.........+--
---=:.::-===++*=:::::::=#*#*+=+*=:::::::::---=++=--.........=+-
----+*#+++=++*%*-:::::::=--=----+-:::::::---=-=+==-:........:+-
--------===+++--+=-::::-=--=-----*-:::-----==--#+==-........:+=
------------------=*=====+--=----+=-----===-----@+==--:...-=*=-
------------------=---------------*+====---------++*++=--=-----
-----------------=-----------------+---------------------------
-----------------=--------+--------+---------------------------
-----------------=+=----=+*=------==---------------------------
--------------------===----=*+=+*=-----------------------------
---------------------------------------------------------------
bradar what is this
]])
