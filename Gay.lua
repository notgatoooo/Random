-- gay maker 3000

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local RGB_SPEED = 0.12
local UPDATE_INTERVAL = 0.08

local currentConnection
local currentCharacter

local function isAppearanceObject(instance)
    return instance:IsA("Accessory")
        or instance:IsA("Clothing")
        or instance:IsA("ShirtGraphic")
        or instance:IsA("CharacterMesh")
        or instance:IsA("BodyColors")
end

local function setupCharacter(character)
    if currentConnection then
        currentConnection:Disconnect()
        currentConnection = nil
    end

    currentCharacter = character

    local parts = {}
    local hue = 0

    local function process(instance)
        if isAppearanceObject(instance) then
            instance:Destroy()
            return
        end

        if instance:IsA("BasePart") then
            instance.Material = Enum.Material.Neon

            if instance.Name ~= "HumanoidRootPart" then
                table.insert(parts, instance)
            end
        end
    end

    for _, instance in ipairs(character:GetDescendants()) do
        process(instance)
    end

    currentConnection = character.DescendantAdded:Connect(process)

    task.spawn(function()
        while character.Parent and currentCharacter == character do
            local elapsed = task.wait(UPDATE_INTERVAL)

            hue = (hue + elapsed * RGB_SPEED) % 1

            local color = Color3.fromHSV(hue, 1, 1)

            for i = #parts, 1, -1 do
                local part = parts[i]

                if not part.Parent then
                    table.remove(parts, i)
                else
                    part.Color = color
                end
            end
        end
    end)
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
    setupCharacter(player.Character)
end
