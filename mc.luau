local shared = odh_shared_plugins

local tab = shared.CreateTab("Minecraftizer", "/notgatoooo/Random/refs/heads/main/Assets/mc")
local Minecraftizer = tab:AddSection("Minecraftizer", "MADE BY GATO 😎")

Minecraftizer:AddLabel("<b><font color='#FFD700'>Credits:</font></b> not_.gato", true)

local materialTextures = {
    [Enum.Material.Asphalt] = "rbxassetid://10777285622",
    [Enum.Material.Basalt] = "rbxassetid://10777285622",
    [Enum.Material.Brick] = "rbxassetid://10777285622",
    [Enum.Material.Carpet] = "rbxassetid://18699165714",
    [Enum.Material.Fabric] = "rbxassetid://18699165714",
    [Enum.Material.CeramicTiles] = "rbxassetid://82688463827095",
    [Enum.Material.Cobblestone] = "rbxassetid://112006332656762",
    [Enum.Material.Concrete] = "rbxassetid://76434845888896",
    [Enum.Material.CrackedLava] = "rbxassetid://6072514670",
    [Enum.Material.DiamondPlate] = "rbxassetid://121527765592383",
    [Enum.Material.Glacier] = "rbxassetid://138703197443219",
    [Enum.Material.Glass] = "rbxassetid://11384458772",
    [Enum.Material.Granite] = "rbxassetid://84691298982406",
    [Enum.Material.Grass] = "rbxassetid://129412557796389",
    [Enum.Material.LeafyGrass] = "rbxassetid://129412557796389",
    [Enum.Material.Ground] = "rbxassetid://114241584338245",
    [Enum.Material.Ice] = "rbxassetid://11413423466",
    [Enum.Material.Marble] = "rbxassetid://71371694781487",
    [Enum.Material.Metal] = "rbxassetid://8677286748",
    [Enum.Material.Mud] = "rbxassetid://5104022863",
    [Enum.Material.Pavement] = "rbxassetid://76838016906118",
    [Enum.Material.Rock] = "rbxassetid://92531008905854",
    [Enum.Material.Salt] = "rbxassetid://112438351210604",
    [Enum.Material.Sand] = "rbxassetid://9277770677",
    [Enum.Material.Sandstone] = "rbxassetid://120884186339230",
    [Enum.Material.Slate] = "rbxassetid://92531008905854",
    [Enum.Material.Snow] = "rbxassetid://11108881974",
    [Enum.Material.Wood] = "rbxassetid://8676581022",
    [Enum.Material.WoodPlanks] = "rbxassetid://8676581022",
}

local faces = Enum.NormalId:GetEnumItems()
local enabled = false
local connection = nil

local function applyTexture(part)
    if not enabled or not part:IsA("BasePart") or part.Transparency >= 0.99 then return end
    local id = materialTextures[part.Material]
    if not id or part:FindFirstChild("MCTexture") then return end

    for _, face in ipairs(faces) do
        local texture = Instance.new("Texture")
        texture.Name = "MCTexture"
        texture.Texture = id
        texture.Face = face
        texture.StudsPerTileU = 4
        texture.StudsPerTileV = 4
        texture.Color3 = part.Color
        texture.Parent = part
    end
end

local function removeTextures()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Texture") and (obj.Name == "MCTexture" or (obj.Texture and obj.Texture:find("rbxassetid://", 1, true))) then
            obj:Destroy()
        end
    end
end

local function start()
    enabled = true
    for _, part in ipairs(workspace:GetDescendants()) do
        applyTexture(part)
    end
    if not connection then
        connection = workspace.DescendantAdded:Connect(function(part)
            task.defer(applyTexture, part)
        end)
    end
end

local function stop()
    enabled = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    removeTextures()
end

local toggle
toggle = Minecraftizer:AddToggle("Auto Apply", function(state)
    if state then
        start()
    else
        stop()
    end
end)

Minecraftizer:AddKeybind("Toggle Keybind", "O", function()
    toggle()
end)

toggle()
