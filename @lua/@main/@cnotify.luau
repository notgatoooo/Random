-- cNotify Function
-- Made by me trust trust

return (function()

local shared = odh_shared_plugins

local game = game
local pcall = pcall
local ipairs = ipairs
local tostring = tostring
local string = string
local math = math
local Instance = Instance

-- shit games kills itself for no reason when getservice() doesnt workrkeke
local function getserv(name)
    local ok, serv = pcall(function()
        return game:GetService(name)
    end)
    return ok and serv or game[name]
end

local HttpService = getserv("HttpService")
local RunService = getserv("RunService")
local workspace = getserv("Workspace")
local CoreGui = getserv("CoreGui")
    
-- randomize function (idk why not use this instead of roblox guid like notification detection)
local function randomizething()
    return tostring(math.random(1000000,999999999))
end
-- yes
local function darker(c)
    return Color3.new(c.R*0.5,c.G*0.5,c.B*0.5)
end

local notifContainer

local function findContainer()
    if notifContainer and notifContainer.Parent then
        return notifContainer
    end

    for _,v in ipairs(CoreGui:GetDescendants()) do
        if v.Name == "@notificationcontainer.elia" then
            notifContainer = v
            return v
        end
    end
end
-- main shit
local function cNotify(title,description,icon,sound,barcolor,barfill)
    local guid = HttpService:GenerateGUID(false)
    -- or local guid = randomizething()
      
    pcall(function()
        shared.Notify(guid,1)
    end)

    local container = findContainer()
    if not container then return guid end

    while true do
        for _,frame in ipairs(container:GetChildren()) do
            if frame:IsA("Frame") then
                local msg = frame:FindFirstChild("Message")
                if msg and msg.Text == guid then

                    if title then
                        local t = frame:FindFirstChild("Title")
                        if t then
                            t.Text = title
                        end
                    end

                    if description then
                        msg.Text = description
                    end

                    if icon then
                        local ic = frame:FindFirstChild("Icon")
                        if ic then
                            ic.Image = icon
                        end
                    end

                    if barcolor then
                        local bar = frame:FindFirstChild("Bar")
                        if bar and bar:IsA("Frame") then
                            bar.BackgroundColor3 = darker(barcolor)

                            local fill = bar:FindFirstChild("Fill")
                            if fill and fill:IsA("Frame") then
                                if barfill then
                                    fill.BackgroundColor3 = barfill
                                else
                                    fill.BackgroundColor3 = barcolor
                                end
                            end
                        end
                    end
              
                    if sound then
                        local folder = Instance.new("Folder")
                        folder.Name = randomizething()
                        folder.Parent = workspace

                        local s = Instance.new("Sound")
                        s.SoundId = sound
                        s.Parent = folder

                        s:Play()
                        s.Ended:Wait()
                        -- debris where :p
                        folder:Destroy()
                    end

                    return guid
                end
            end
        end

        RunService.Heartbeat:Wait()
    end
end

return {
    cNotify = cNotify
}

end)()

-- i guess vro
