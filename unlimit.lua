-- if your executor is shit ts wont work btw
local shared = odh_shared_plugins
local idk = shared.AddSection("Inventory Unlimiter")

-- ts will fw upvalues cuz 
local getupvalues = debug.getupvalues or getupvalues
local setupvalue = debug.setupvalue or setupvalue
local getinfo = debug.getinfo or getinfo
local getconstants = debug.getconstants or getconstants

local enabled = false
local maxItems = 9999
local defaultLimit = 10

local DeviceService
pcall(function()
    DeviceService = require(game:GetService("ReplicatedStorage"):WaitForChild("ClientServices"):WaitForChild("DeviceService"))
end)

if DeviceService and DeviceService.IsMobileDevice then
    pcall(function()
        if DeviceService:IsMobileDevice() then
            defaultLimit = 3
        end
    end)
end

-- applier shit
local function applyLimit(targetLimit)
    if not (getgc and getupvalues and setupvalue and getinfo) then return end
    for _, f in ipairs(getgc()) do
        if type(f) == "function" then
            local success, info = pcall(getinfo, f)
            if success and info then
                local isTarget = false
                if info.name == "updateItemFrame" or info.name == "onItemEquipped" then
                    isTarget = true
                elseif getconstants then
                    local cSuccess, constants = pcall(getconstants, f)
                    if cSuccess and type(constants) == "table" then
                        local hasTouch = false
                        local hasEquip = false
                        for _, c in ipairs(constants) do
                            if c == "TouchBinding" then
                                hasTouch = true
                            elseif c == "EquipButton" then
                                hasEquip = true
                            end
                        end
                        if hasTouch and hasEquip then
                            isTarget = true
                        end
                    end
                end
                
                if isTarget then
                    local uSuccess, upvalues = pcall(getupvalues, f)
                    if uSuccess and type(upvalues) == "table" then
                        for idx, val in ipairs(upvalues) do
                            if type(val) == "number" then
                                pcall(setupvalue, f, idx, targetLimit)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function update()
    local target = enabled and maxItems or defaultLimit
    applyLimit(target)
end

idk:AddToggle("Unlimit Inventory", function(bool)
    enabled = bool
    update()
end)

idk:AddSlider("Max Items", 2, 9999, 9999, function(int)
    maxItems = int
    if enabled then
        update()
    end
end)

local LocalPlayer = game:GetService("Players").LocalPlayer
if LocalPlayer then
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.67)
        update()
    end)
end