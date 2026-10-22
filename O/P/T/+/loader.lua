local a = os.clock()

-- // variables \\
local shared = odh_shared_plugins
local Players, Workspace, Lighting, RunService = game:GetService("Players"), game:GetService("Workspace"), game:GetService("Lighting"), game:GetService("RunService")
local Render = settings().Rendering
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local original = {Quality = Render.QualityLevel, Shadows = Lighting.GlobalShadows, Streaming = Workspace.StreamingEnabled, Rendering = true}
pcall(function() original.Rendering = RunService:Is3dRenderingEnabled() end)
pcall(function() if type(gethiddenproperty) == "function" then original.Streaming = gethiddenproperty(Workspace, "StreamingEnabled") end end)

local function setHidden(property, value)
    if type(sethiddenproperty) ~= "function" then return false end
    return pcall(sethiddenproperty, Workspace, property, value)
end

local function saveSet(cache, object, property, value)
    cache[object] = cache[object] or {}
    if cache[object][property] == nil then cache[object][property] = object[property] end
    object[property] = value
end

local function restore(cache)
    for object, properties in pairs(cache) do
        for property, value in pairs(properties) do
            pcall(function() object[property] = value end)
        end
    end
    table.clear(cache)
end

-- // gui [1] \\
local oldGui = PlayerGui:FindFirstChild("hi")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "hi"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = -9999
gui.Enabled = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BorderSizePixel = 0
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.Parent = gui
frame.Name = ""

local customColor = Color3.new(0, 0, 0)

-- // main stuffs \\
local effectSaved = setmetatable({}, {__mode = "k"})
local effectConnections = {}
local effectsOn = false

local function disableEffect(v)
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("PostEffect") or v:IsA("Light") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Highlight") then
        saveSet(effectSaved, v, "Enabled", false)
    end
end

local function setEffects(state)
    if state == effectsOn then return end
    effectsOn = state

    if state then
        table.insert(effectConnections, Workspace.DescendantAdded:Connect(disableEffect))
        table.insert(effectConnections, Lighting.DescendantAdded:Connect(disableEffect))
        for _, v in ipairs(Workspace:GetDescendants()) do disableEffect(v) end
        for _, v in ipairs(Lighting:GetDescendants()) do disableEffect(v) end
    else
        for _, connection in ipairs(effectConnections) do connection:Disconnect() end
        table.clear(effectConnections)
        restore(effectSaved)
    end
end

local function setCustomRendering(state)
    gui.Enabled = state
    if state then
        frame.BackgroundColor3 = customColor
        pcall(function() RunService:Set3dRenderingEnabled(false) end)
    else
        pcall(function() RunService:Set3dRenderingEnabled(original.Rendering) end)
    end
end

-- // scaryyy stufff \\
local aggressiveSaved = setmetatable({}, {__mode = "k"})
local aggressiveConnection
local aggressiveOn = false

local function optimize(v)
    if v:IsA("BasePart") then saveSet(aggressiveSaved, v, "CastShadow", false) end
    if v:IsA("MeshPart") then saveSet(aggressiveSaved, v, "RenderFidelity", Enum.RenderFidelity.Performance) end
end

local function setAggressive(state)
    if state == aggressiveOn then return end
    aggressiveOn = state

    if state then
        Render.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        aggressiveConnection = Workspace.DescendantAdded:Connect(optimize)
        for _, v in ipairs(Workspace:GetDescendants()) do optimize(v) end
    else
        if aggressiveConnection then aggressiveConnection:Disconnect() aggressiveConnection = nil end
        restore(aggressiveSaved)
        Render.QualityLevel = original.Quality
        Lighting.GlobalShadows = original.Shadows
    end
end

-- // ui stuff [2] \\
local tab = shared.CreateTab("Optimizer+", "/notgatoooo/Random/refs/heads/main/Assets/performance-svgrepo-com")

local rendering = tab:AddSection("Rendering", "made by gato 😎")
rendering:AddToggle("Disable Effects", setEffects)
rendering:AddToggle("Disable Rendering (Custom Color 😎)", setCustomRendering)
rendering:AddColorpicker("Render Custom Color", customColor, function(uhhh)
    customColor = uhhh
    frame.BackgroundColor3 = uhhh
end)

local aggressive = tab:AddSection("Aggresive", "made by gato 😎")
aggressive:AddParagraph("HEY!!! READ ME!!!", "THIS MAY NOT WORK ON SOME EXECUTORS DUE TO USING AN ADVANCED API.")
aggressive:AddToggle("Disable Streaming", function(state)
    local success = setHidden("StreamingEnabled", state and false or original.Streaming)
    if not success then shared.Notify("Could not change StreamingEnabled.", 0) end
end)
aggressive:AddToggle("Aggresive Other Optimizations", setAggressive)

shared.Notify("OPT+ Sucessfully Loaded in ".. (os.clock() - a) .."ms! :D", 1)
