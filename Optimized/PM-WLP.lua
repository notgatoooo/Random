--!strict
--!native
--!optimize 2
--[[
  ________        __          
 /  _____/_____ _/  |_  ____  
/   \  ___\__  \\   __\/  _ \ 
\    \_\  \/ __ \|  | (  <_> )
 \______  (____  /__|  \____/ 
        \/     \/             
 __      __                
/  \    /  \_____    ______
\   \/\/   /\__  \  /  ___/
 \        /  / __ \_\___ \ 
  \__/\  /  (____  /____  >
       \/        \/     \/ 
  ___ ___                        
 /   |   \   ___________   ____  
/    ~    \_/ __ \_  __ \_/ __ \ 
\    Y    /\  ___/|  | \/\  ___/ 
 \___|_  /  \___  >__|    \___  >
       \/       \/            \/ 

Gato was Here.
--> NOTE: This code is bad and needs further optimization. :)
]]

local shared = odh_shared_plugins

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera: Camera = Workspace.CurrentCamera or (Workspace:WaitForChild("Camera") :: Camera)

local math_abs = math.abs
local math_floor = math.floor
local math_pi = math.pi
local os_clock = os.clock
local xpcall = xpcall
local pcall = pcall
local typeof = typeof
local type = type
local task_wait = task.wait
local table_insert = table.insert
local table_clear = table.clear
local table_freeze = table.freeze
local Instance_new = Instance.new
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new
local UDim2_new = UDim2.new
local UDim_new = UDim.new
local CFrame_Angles = CFrame.Angles
local CFrame_lookAt = CFrame.lookAt
local TweenInfo_new = TweenInfo.new
local Color3_new = Color3.new
local Color3_fromRGB = Color3.fromRGB
local ColorSequence_new = ColorSequence.new
local ColorSequenceKeypoint_new = ColorSequenceKeypoint.new

local Enum_UserInputType_MouseButton1 = Enum.UserInputType.MouseButton1
local Enum_UserInputType_Touch = Enum.UserInputType.Touch
local Enum_UserInputType_MouseMovement = Enum.UserInputType.MouseMovement
local Enum_RaycastFilterType_Exclude = Enum.RaycastFilterType.Exclude
local Enum_HumanoidStateType_Dead = Enum.HumanoidStateType.Dead
local Enum_HumanoidStateType_Jumping = Enum.HumanoidStateType.Jumping
local Enum_EasingStyle_Sine = Enum.EasingStyle.Sine
local Enum_EasingStyle_Quad = Enum.EasingStyle.Quad
local Enum_EasingDirection_Out = Enum.EasingDirection.Out
local Enum_EasingDirection_InOut = Enum.EasingDirection.InOut
local Enum_Font_Jura = Enum.Font.Jura
local Enum_AspectType_ScaleWithParentSize = Enum.AspectType.ScaleWithParentSize
local Enum_KeyCode_Space = Enum.KeyCode.Space

local RAY_ANGLES: {CFrame} = table_freeze({
    CFrame_Angles(0, 0, 0),
    CFrame_Angles(0, 0.7853981633974483, 0),
    CFrame_Angles(0, 1.5707963267948966, 0),
    CFrame_Angles(0, 2.356194490192345, 0),
    CFrame_Angles(0, 3.141592653589793, 0),
    CFrame_Angles(0, 3.9269908169872414, 0),
    CFrame_Angles(0, 4.71238898038469, 0),
    CFrame_Angles(0, 5.497787143782138, 0)
})

local FLICK_CFRAME: CFrame = CFrame_Angles(0, math_pi, 0)
local TWEEN_INFO_FADE: TweenInfo = TweenInfo_new(0.3, Enum_EasingStyle_Quad, Enum_EasingDirection_InOut)
local TWEEN_INFO_RIPPLE: TweenInfo = TweenInfo_new(0.4, Enum_EasingStyle_Sine, Enum_EasingDirection_Out)

local __SHAPES: {[number]: string} = table_freeze({
    [0] = "rbxassetid://86221076925479",
    [1] = "rbxassetid://96242665417546",
    [2] = "rbxassetid://97129189935336",
    [3] = "rbxassetid://76165862027868",
    [4] = "rbxassetid://125868092127496"
})

local __NORMAL_COLOR: ColorSequence = ColorSequence_new({
    ColorSequenceKeypoint_new(0, Color3_new(0.133333, 0.827451, 0.494118)),
    ColorSequenceKeypoint_new(0.6, Color3_new(0.231373, 0.509804, 0.498039)),
    ColorSequenceKeypoint_new(1, Color3_new(0.501961, 0.501961, 0.501961))
})

local __ACTIVE_COLOR: ColorSequence = ColorSequence_new({
    ColorSequenceKeypoint_new(0, Color3_new(0.0, 0.8, 0.4)),
    ColorSequenceKeypoint_new(0.6, Color3_new(0.0, 0.5, 0.3)),
    ColorSequenceKeypoint_new(1, Color3_new(0.2, 0.8, 0.6))
})

local isWallHopEnabled: boolean = false
local detectionDistance: number = 3
local flickPower: number = 50
local showWallhopButton: boolean = true

local isFlicking: boolean = false
local lastFlickTime: number = 0
local isJumpKeyPressed: boolean = false
local lastHitInstance: Instance? = nil
local currentHitInstance: Instance? = nil

local myCharacter: Model? = LocalPlayer.Character
local myHumanoid: Humanoid? = myCharacter and (myCharacter:FindFirstChildOfClass("Humanoid") :: Humanoid?) or nil
local myRootPart: BasePart? = myCharacter and (myCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?) or nil

local wallRaycastParams: RaycastParams = RaycastParams.new()
wallRaycastParams.FilterType = Enum_RaycastFilterType.Exclude
wallRaycastParams.IgnoreWater = true

local cornerRaycastParams: RaycastParams = RaycastParams.new()
cornerRaycastParams.FilterType = Enum_RaycastFilterType.Exclude
cornerRaycastParams.IgnoreWater = true

local function updateRaycastFilter(): ()
    local filterList: {Instance} = {}
    if myCharacter then
        table_insert(filterList, myCharacter)
    end
    wallRaycastParams.FilterDescendantsInstances = filterList
    cornerRaycastParams.FilterDescendantsInstances = filterList
end
updateRaycastFilter()

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local newCam = Workspace.CurrentCamera
    if newCam then
        Camera = newCam
    end
end)

local WallhopBindableButtons = {
    Buttons = {} :: {[string]: ImageButton},
    Maids = {} :: {[string]: any},
    Count = 0
}

local function safecallback(callback: (() -> ())?): ()
    if not callback then return end
    local ok, err = xpcall(callback, debug.traceback)
    if not ok then warn("[BIND ERROR] " .. tostring(err)) end
end

local function GetStorage(): Instance
    local parent: any = gethui and gethui()
    if not parent or typeof(parent) ~= "Instance" then
        parent = CoreGui
    end
    if not parent or typeof(parent) ~= "Instance" then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        parent = playerGui or LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    if typeof(parent) ~= "Instance" then
        parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    local sg: ScreenGui? = parent:FindFirstChild("@wallhopstorage") :: ScreenGui?
    if not sg then
        sg = Instance_new("ScreenGui")
        sg.Name = "@wallhopstorage"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() (sg :: any).ScreenInsets = Enum.ScreenInsets.None end)
        sg.Parent = parent
    end
    return sg
end

local function MakeDraggable(gui: ImageButton, maid: any, ripple: Frame, sound: Sound, clickFunc: () -> ()): ()
    local dragging: boolean = false
    local dragInput: InputObject? = nil
    local dragStart: Vector3 = Vector3.zero
    local startPos: UDim2 = gui.Position
    local hasMoved: boolean = false
    local releaseConn: RBXScriptConnection? = nil

    maid:GiveTask(gui.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum_UserInputType_MouseButton1 or input.UserInputType == Enum_UserInputType_Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            hasMoved = false

            sound:Play()
            local absPos: Vector2 = gui.AbsolutePosition
            ripple.Position = UDim2_new(0, input.Position.X - absPos.X, 0, input.Position.Y - absPos.Y)
            ripple.Size = UDim2_new(0, 0, 0, 0)
            ripple.BackgroundTransparency = 0.5
            ripple.Visible = true

            TweenService:Create(ripple, TWEEN_INFO_RIPPLE, {
                Size = UDim2_new(0, 45, 0, 45),
                BackgroundTransparency = 1
            }):Play()

            if releaseConn then
                releaseConn:Disconnect()
            end

            releaseConn = UserInputService.InputEnded:Connect(function(endInput: InputObject)
                if endInput.UserInputType == input.UserInputType then
                    dragging = false
                    if not hasMoved then
                        clickFunc()
                    end
                    if releaseConn then
                        releaseConn:Disconnect()
                        releaseConn = nil
                    end
                end
            end)
        end
    end))

    maid:GiveTask(gui.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum_UserInputType_MouseMovement or input.UserInputType == Enum_UserInputType_Touch then
            dragInput = input
        end
    end))

    maid:GiveTask(UserInputService.InputChanged:Connect(function(input: InputObject)
        if dragging and input == dragInput then
            local delta: Vector3 = input.Position - dragStart
            if math_abs(delta.X) > 5 or math_abs(delta.Y) > 5 then
                hasMoved = true
            end
            local parentGui = gui.Parent :: GuiBase2d?
            if parentGui then
                local screen: Vector2 = parentGui.AbsoluteSize
                gui.Position = UDim2_new(startPos.X.Scale + (delta.X / screen.X), 0, startPos.Y.Scale + (delta.Y / screen.Y), 0)
            end
        end
    end))
end

function WallhopBindableButtons.AddBButton(id: string, text: string, onFunc: () -> (), offFunc: () -> ()): BoolValue?
    if WallhopBindableButtons.Buttons[id] then
        return WallhopBindableButtons.Buttons[id]:FindFirstChild("BindValue") :: BoolValue?
    end

    local buttonMaid = {
        _tasks = {} :: {any}
    }
    function buttonMaid:GiveTask(task: any)
        table_insert(self._tasks, task)
        return task
    end
    function buttonMaid:Destroy()
        for _, t in self._tasks do
            local tType = typeof(t)
            if tType == "RBXScriptConnection" then
                (t :: RBXScriptConnection):Disconnect()
            elseif tType == "Instance" then
                (t :: Instance):Destroy()
            elseif type(t) == "function" then
                t()
            end
        end
        table_clear(self._tasks)
    end

    local screen: Vector2 = Camera.ViewportSize
    local buttonSizeY: number = 0.11
    local widthScale: number = buttonSizeY * (screen.Y / screen.X)

    local xPos: number = 0.1 + ((WallhopBindableButtons.Count % 8) * (widthScale + 0.005))
    local yPos: number = 0.7 - (math_floor(WallhopBindableButtons.Count / 8) * (buttonSizeY + 0.015))

    local ImageButton: ImageButton = Instance_new("ImageButton")
    ImageButton.Name = id
    ImageButton.Size = UDim2_new(widthScale, 0, buttonSizeY, 0)
    ImageButton.Position = UDim2_new(xPos, 0, yPos, 0)
    ImageButton.AnchorPoint = Vector2_new(0.5, 0.5)
    ImageButton.Image = __SHAPES[0]
    ImageButton.BackgroundTransparency = 1
    ImageButton.BorderSizePixel = 0
    ImageButton.ClipsDescendants = false
    ImageButton.AutoButtonColor = false
    ImageButton.Parent = GetStorage()
    buttonMaid:GiveTask(ImageButton)

    local BindValue: BoolValue = Instance_new("BoolValue")
    BindValue.Name = "BindValue"
    BindValue.Parent = ImageButton

    local TextLabel: TextLabel = Instance_new("TextLabel")
    TextLabel.Name = "@Text"
    TextLabel.Size = UDim2_new(0.8, 0, 0.8, 0)
    TextLabel.Position = UDim2_new(0.5, 0, 0.5, 0)
    TextLabel.AnchorPoint = Vector2_new(0.5, 0.5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum_Font_Jura
    TextLabel.Text = text
    TextLabel.TextColor3 = Color3_new(1, 1, 1)
    TextLabel.TextSize = 10
    TextLabel.TextWrapped = true
    TextLabel.ZIndex = 3
    TextLabel.Parent = ImageButton

    local Aspect: UIAspectRatioConstraint = Instance_new("UIAspectRatioConstraint")
    Aspect.AspectRatio = 1
    Aspect.AspectType = Enum_AspectType_ScaleWithParentSize
    Aspect.Parent = ImageButton

    local Gradient: UIGradient = Instance_new("UIGradient")
    Gradient.Name = "@Stroke"
    Gradient.Color = __NORMAL_COLOR
    Gradient.Parent = ImageButton

    local ripple: Frame = Instance_new("Frame")
    ripple.Name = "@ripple"
    ripple.BackgroundColor3 = Color3_fromRGB(0, 155, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.Size = UDim2_new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2_new(0.5, 0.5)
    ripple.Visible = false
    ripple.ZIndex = 2
    ripple.Parent = ImageButton

    local rippleCorner: UICorner = Instance_new("UICorner")
    rippleCorner.CornerRadius = UDim_new(1, 0)
    rippleCorner.Parent = ripple

    local sound: Sound = Instance_new("Sound")
    sound.SoundId = "rbxassetid://3868133279"
    sound.Volume = 0.5
    sound.Parent = ImageButton

    local debounce: boolean = false
    local function onClick(): ()
        if debounce then return end
        debounce = true

        local fOut = TweenService:Create(ImageButton, TWEEN_INFO_FADE, {ImageTransparency = 1})
        fOut:Play()
        fOut.Completed:Wait()

        BindValue.Value = not BindValue.Value
        Gradient.Color = BindValue.Value and __ACTIVE_COLOR or __NORMAL_COLOR
        if BindValue.Value then
            safecallback(onFunc)
        else
            safecallback(offFunc)
        end

        local fIn = TweenService:Create(ImageButton, TWEEN_INFO_FADE, {ImageTransparency = 0})
        fIn:Play()
        fIn.Completed:Wait()
        debounce = false
    end

    MakeDraggable(ImageButton, buttonMaid, ripple, sound, onClick)

    buttonMaid:GiveTask(RunService.RenderStepped:Connect(function()
        if showWallhopButton and ImageButton.Visible then
            Gradient.Rotation = (Gradient.Rotation + 1) % 360
        end
    end))

    WallhopBindableButtons.Buttons[id] = ImageButton
    WallhopBindableButtons.Maids[id] = buttonMaid
    WallhopBindableButtons.Count += 1
    return BindValue
end

function WallhopBindableButtons.DeleteBButton(id: string): ()
    if WallhopBindableButtons.Maids[id] then
        WallhopBindableButtons.Maids[id]:Destroy()
        WallhopBindableButtons.Maids[id] = nil
    end
    if WallhopBindableButtons.Buttons[id] then
        WallhopBindableButtons.Buttons[id]:Destroy()
        WallhopBindableButtons.Buttons[id] = nil
    end
end

local function UpdateWallhopButtonState(): ()
    local btn: ImageButton? = WallhopBindableButtons.Buttons["wallhop_toggle"]
    if not btn then return end
    local textLabel = btn:FindFirstChild("@Text") :: TextLabel?
    if textLabel then
        textLabel.Text = isWallHopEnabled and "ON" or "OFF"
    end
    local gradient = btn:FindFirstChild("@Stroke") :: UIGradient?
    if gradient then
        gradient.Color = isWallHopEnabled and __ACTIVE_COLOR or __NORMAL_COLOR
    end
end

local function ToggleWallhopButtonVisibility(): ()
    local btn: ImageButton? = WallhopBindableButtons.Buttons["wallhop_toggle"]
    if btn then
        btn.Visible = showWallhopButton
    end
end

local function CreateWallhopBindButton(): ()
    if WallhopBindableButtons.Buttons["wallhop_toggle"] then return end

    WallhopBindableButtons.AddBButton("wallhop_toggle", "WH", function()
        isWallHopEnabled = true
        shared.Notify("Pm-WallHop включен", 2)
        UpdateWallhopButtonState()
    end, function()
        isWallHopEnabled = false
        shared.Notify("Pm-WallHop выключен", 2)
        UpdateWallhopButtonState()
    end)

    UpdateWallhopButtonState()
    ToggleWallhopButtonVisibility()
end

local function isPlayerCharacter(instance: Instance?): boolean
    if not instance then return false end
    local current: Instance? = instance
    while current and current ~= Workspace do
        if current:IsA("Model") and (Players:GetPlayerFromCharacter(current) or current:FindFirstChildOfClass("Humanoid")) then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isWall(instance: Instance?): boolean
    if not instance or not instance:IsA("BasePart") then
        return false
    end
    local part = instance :: BasePart
    if not part.CanCollide then
        return false
    end
    local current = part.Parent
    while current and current ~= Workspace do
        if current:IsA("Model") and (Players:GetPlayerFromCharacter(current) or current:FindFirstChildOfClass("Humanoid")) then
            return false
        end
        current = current.Parent
    end
    return true
end

local function getWallRaycastResult(): RaycastResult?
    if not myRootPart then return nil end
    local hrpCF: CFrame = myRootPart.CFrame
    local hrpPos: Vector3 = hrpCF.Position
    local closestHit: RaycastResult? = nil
    local minDistance: number = detectionDistance

    for i = 1, 8 do
        local dir: Vector3 = (hrpCF * RAY_ANGLES[i]).LookVector * detectionDistance
        local ray: RaycastResult? = Workspace:Raycast(hrpPos, dir, wallRaycastParams)
        if ray and ray.Distance < minDistance then
            local hitInstance: Instance = ray.Instance
            if isWall(hitInstance) then
                minDistance = ray.Distance
                closestHit = ray
            end
        end
    end
    return closestHit
end

local function performVideoFlick(): ()
    if not isWallHopEnabled or isFlicking then return end
    isFlicking = true

    if not myHumanoid or not myRootPart or myHumanoid.Health <= 0 then
        isFlicking = false
        return
    end

    local currentVel: Vector3 = myRootPart.AssemblyLinearVelocity
    myHumanoid:ChangeState(Enum_HumanoidStateType_Jumping)
    myRootPart.AssemblyLinearVelocity = Vector3_new(currentVel.X, flickPower, currentVel.Z)

    local startCFrame: CFrame = Camera.CFrame
    Camera.CFrame = startCFrame * FLICK_CFRAME

    task_wait(0.01)
    Camera.CFrame = startCFrame

    isFlicking = false
end

local function performWallhop(): ()
    if not isWallHopEnabled then return end
    if not myHumanoid or not myRootPart or myHumanoid.Health <= 0 or myHumanoid:GetState() == Enum_HumanoidStateType_Dead then
        return
    end

    local wall = getWallRaycastResult()
    if not wall then return end

    myRootPart.CFrame = CFrame_lookAt(myRootPart.Position, myRootPart.Position + wall.Normal)
    RunService.Heartbeat:Wait()

    if myHumanoid and myHumanoid.Health > 0 and myHumanoid:GetState() ~= Enum_HumanoidStateType_Dead then
        myHumanoid:ChangeState(Enum_HumanoidStateType_Jumping)
        task_wait(0.1)
    end
end

local wallhop_section = shared.AddSection("Pm-WallHop")

wallhop_section:AddLabel("Pm-WallHop Script by @Phemtom (IMPROVED BY GATO!!!!)")
--wallhop_section:AddParagraph("Pm-WallHop", "Флинг при прыжке возле стыка стен")

wallhop_section:AddToggle("Activate WallHop", function(bool: boolean)
    isWallHopEnabled = bool
    --[[
    if bool then
        shared.Notify("Pm-WallHop включен", 2)
    else
        shared.Notify("Pm-WallHop выключен", 2)
    end
    ]]
    UpdateWallhopButtonState()
end)

wallhop_section:AddButton("WallHop Status", function()
    isWallHopEnabled = not isWallHopEnabled
    shared.Notify(isWallHopEnabled and "Pm-WallHop Active" or "Pm-WallHop Inactive", 2)
    UpdateWallhopButtonState()
end)

wallhop_section:AddSlider("Detection Distance", 1, 6, 3, function(int: number)
    detectionDistance = int
    --shared.Notify("Дистанция: " .. int, 2)
end)

wallhop_section:AddSlider("Flick Power", 20, 100, 50, function(int: number)
    flickPower = int
    --shared.Notify("Сила: " .. int, 2)
end)

wallhop_section:AddButton("Perform Flick", function()
    if isWallHopEnabled then
        performVideoFlick()
    end
end)

wallhop_section:AddKeybind("Toggle Keybind", "F", function()
    isWallHopEnabled = not isWallHopEnabled
    shared.Notify(isWallHopEnabled and "Pm-WallHop Active" or "Pm-WallHop Inactive", 2)
    UpdateWallhopButtonState()
end)

wallhop_section:AddKeybind("WallHop Jump Key", "J", function()
    if isWallHopEnabled then
        performWallhop()
      end
end)

wallhop_section:AddToggle("Wallhop Bindable Button", function(b: boolean)
    showWallhopButton = b
    ToggleWallhopButtonVisibility()
end)

wallhop_section:AddSlider("Bindable Button Size", 5, 25, 11, function(value: number)
    local btnSize: number = value / 100
    local btn: ImageButton? = WallhopBindableButtons.Buttons["wallhop_toggle"]
    if btn then
        local screen: Vector2 = Camera.ViewportSize
        btn.Size = UDim2_new(btnSize * (screen.Y / screen.X), 0, btnSize, 0)
    end
end)

CreateWallhopBindButton()

RunService.Heartbeat:Connect(function()
    if not isWallHopEnabled or not isJumpKeyPressed or isFlicking then
        lastHitInstance = nil
        return
    end

    if not myRootPart or not myHumanoid or myHumanoid.Health <= 0 then
        lastHitInstance = nil
        return
    end

    local direction: Vector3 = Camera.CFrame.LookVector * detectionDistance
    local result: RaycastResult? = Workspace:Raycast(myRootPart.Position, direction, cornerRaycastParams)

    currentHitInstance = nil

    if result then
        local hitInstance: Instance = result.Instance
        if isWall(hitInstance) then
            currentHitInstance = hitInstance
            if lastHitInstance and lastHitInstance ~= currentHitInstance then
                local currentTime: number = os_clock()
                if currentTime - lastFlickTime > 0.1 then
                    lastFlickTime = currentTime
                    performVideoFlick()
                end
            end
        end
    end

    lastHitInstance = currentHitInstance
end)

UserInputService.JumpRequest:Connect(function()
    if isWallHopEnabled then
        performWallhop()
    end
end)

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
    if gameProcessed then return end
    if input.KeyCode == Enum_KeyCode_Space then
        isJumpKeyPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
    if gameProcessed then return end
    if input.KeyCode == Enum_KeyCode_Space then
        isJumpKeyPressed = false
        lastHitInstance = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character: Model)
    myCharacter = character
    myHumanoid = character:WaitForChild("Humanoid", 5) :: Humanoid?
    myRootPart = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
    lastHitInstance = nil
    currentHitInstance = nil
    isFlicking = false
    updateRaycastFilter()
end)

LocalPlayer.CharacterRemoving:Connect(function()
    myCharacter = nil
    myHumanoid = nil
    myRootPart = nil
    lastHitInstance = nil
    currentHitInstance = nil
    isFlicking = false
end)

UserInputService.WindowFocused:Connect(function()
    isJumpKeyPressed = false
    lastHitInstance = nil
end)

UserInputService.WindowFocusReleased:Connect(function()
    isJumpKeyPressed = false
    lastHitInstance = nil
end)
