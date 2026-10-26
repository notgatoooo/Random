local a = os.clock()

-- // variables \\
local shared = odh_shared_plugins
local Players, Workspace, Lighting, RunService =
    game:GetService("Players"),
    game:GetService("Workspace"),
    game:GetService("Lighting"),
    game:GetService("RunService")

local Render = settings().Rendering
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local original = {
    Quality = Render.QualityLevel,
    Shadows = Lighting.GlobalShadows,
    Streaming = Workspace.StreamingEnabled,
    Rendering = true
}

pcall(function()
    original.Rendering = RunService:Is3dRenderingEnabled()
end)

pcall(function()
    if type(gethiddenproperty) == "function" then
        original.Streaming = gethiddenproperty(Workspace, "StreamingEnabled")
    end
end)

local BATCH_SIZE = 300

local function setHidden(property, value)
    if type(sethiddenproperty) ~= "function" then
        return false
    end

    return pcall(sethiddenproperty, Workspace, property, value)
end

local function saveSet(cache, object, property, value)
    local properties = cache[object]

    if not properties then
        properties = {}
        cache[object] = properties
    end

    if properties[property] == nil then
        local success, current = pcall(function()
            return object[property]
        end)

        if not success then
            return false
        end

        properties[property] = current
    end

    return pcall(function()
        object[property] = value
    end)
end

local function restore(cache)
    for object, properties in pairs(cache) do
        for property, value in pairs(properties) do
            pcall(function()
                object[property] = value
            end)
        end
    end

    table.clear(cache)
end

local function scanDescendants(root, callback, shouldContinue)
    local descendants = root:GetDescendants()

    for i = 1, #descendants do
        if not shouldContinue() then
            return
        end

        callback(descendants[i])

        if i % BATCH_SIZE == 0 then
            task.wait()
        end
    end
end

-- // gui [1] \\

local oldGui = PlayerGui:FindFirstChild("hi")

if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "hi"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = -9999
gui.Enabled = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = ""
frame.Size = UDim2.fromScale(1, 1)
frame.BorderSizePixel = 0
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.Parent = gui

local customColor = Color3.new(0, 0, 0)

-- // effects optimization \\

local effectSaved = setmetatable({}, {__mode = "k"})
local effectConnections = {}
local effectsOn = false
local effectsGeneration = 0

local function disableEffect(v)
    if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Beam")
        or v:IsA("PostEffect")
        or v:IsA("Light")
        or v:IsA("Fire")
        or v:IsA("Smoke")
        or v:IsA("Sparkles")
        or v:IsA("Highlight")
    then
        saveSet(effectSaved, v, "Enabled", false)
    end
end

local function setEffects(state)
    if state == effectsOn then
        return
    end

    effectsOn = state
    effectsGeneration += 1

    local generation = effectsGeneration

    if state then
        table.insert(
            effectConnections,
            Workspace.DescendantAdded:Connect(disableEffect)
        )

        table.insert(
            effectConnections,
            Lighting.DescendantAdded:Connect(disableEffect)
        )

        task.spawn(function()
            local function shouldContinue()
                return effectsOn
                    and effectsGeneration == generation
            end

            scanDescendants(Workspace, disableEffect, shouldContinue)

            if shouldContinue() then
                scanDescendants(Lighting, disableEffect, shouldContinue)
            end
        end)
    else
        for _, connection in ipairs(effectConnections) do
            connection:Disconnect()
        end

        table.clear(effectConnections)
        restore(effectSaved)
    end
end

-- // custom rendering \\

local function setCustomRendering(state)
    gui.Enabled = state

    if state then
        frame.BackgroundColor3 = customColor

        pcall(function()
            RunService:Set3dRenderingEnabled(false)
        end)
    else
        pcall(function()
            RunService:Set3dRenderingEnabled(original.Rendering)
        end)
    end
end

-- // aggressive optimization \\

local aggressiveSaved = setmetatable({}, {__mode = "k"})
local aggressiveConnection
local aggressiveOn = false
local aggressiveGeneration = 0

local function optimize(v)
    if not aggressiveOn then
        return
    end
    if v:IsA("BasePart") then
        saveSet(aggressiveSaved, v, "CastShadow", false)
    end
end

local function setAggressive(state)
    if state == aggressiveOn then
        return
    end

    aggressiveOn = state
    aggressiveGeneration += 1

    local generation = aggressiveGeneration

    if state then
        pcall(function()
            Render.QualityLevel = Enum.QualityLevel.Level01
        end)

        pcall(function()
            Lighting.GlobalShadows = false
        end)

        aggressiveConnection =
            Workspace.DescendantAdded:Connect(optimize)

        task.spawn(function()
            scanDescendants(Workspace, optimize, function()
                return aggressiveOn
                    and aggressiveGeneration == generation
            end)
        end)
    else
        if aggressiveConnection then
            aggressiveConnection:Disconnect()
            aggressiveConnection = nil
        end

        restore(aggressiveSaved)

        pcall(function()
            Render.QualityLevel = original.Quality
        end)

        pcall(function()
            Lighting.GlobalShadows = original.Shadows
        end)
    end
end

-- // UI [2] \\

local tab = shared.CreateTab(
    "Optimizer+",
    "/notgatoooo/Random/refs/heads/main/Assets/performance-svgrepo-com"
)

local rendering = tab:AddSection("Rendering", "made by gato 😎")

rendering:AddToggle("Disable Effects", setEffects)

rendering:AddToggle(
    "Disable Rendering (Custom Color 😎)",
    setCustomRendering
)

rendering:AddColorpicker(
    "Render Custom Color",
    customColor,
    function(color)
        customColor = color
        frame.BackgroundColor3 = color
    end
)

local aggressive = tab:AddSection("Aggresive", "made by gato 😎")

aggressive:AddParagraph(
    "HEY!!! READ ME!!!",
    "THIS MAY NOT WORK ON SOME EXECUTORS DUE TO USING AN ADVANCED API."
)

aggressive:AddToggle("Disable Streaming", function(state)
    local success = setHidden(
        "StreamingEnabled",
        state and false or original.Streaming
    )

    if not success then
        shared.Notify("Could not change StreamingEnabled.", 0)
    end
end)

aggressive:AddToggle(
    "Aggresive Other Optimizations",
    setAggressive
)

shared.Notify(
    "OPT+ Successfully Loaded in "
        .. math.floor((os.clock() - a) * 1000)
        .. "ms! :D",
    1
)
