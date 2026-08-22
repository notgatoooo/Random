local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local cg = game:GetService("CoreGui")
local hs = game:GetService("HttpService")
local ts = game:GetService("TextService")

local player = players.LocalPlayer

local function getparent()
    local p = nil
    pcall(function()
        if gethui then
            p = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(cg)
            p = cg
        else
            p = cg
        end
    end)
    if not p then
        pcall(function()
            p = cg
        end)
    end
    if not p then
        p = player:WaitForChild("PlayerGui")
    end
    return p
end

local target = getparent()
local getasset = getcustomasset or getsynasset

local function resolve(paths, def)
    if getasset then
        for _, v in ipairs(paths) do
            local ok = false
            if isfile then
                pcall(function()
                    ok = isfile(v)
                end)
            else
                ok = true
            end
            if ok then
                local s, id = pcall(getasset, v)
                if s and id then
                    return id
                end
            end
        end
    end
    return def or ""
end

local function loadfont(name, paths)
    if getasset then
        local id = resolve(paths, nil)
        if id and id ~= "" then
            local cfg = {
                name = name,
                faces = {
                    { name = "Regular", weight = 400, style = "Normal", assetId = id },
                    { name = "Bold", weight = 700, style = "Normal", assetId = id }
                }
            }
            if writefile then
                local p = "gaf/assets/" .. name .. ".json"
                pcall(function()
                    writefile(p, hs:JSONEncode(cfg))
                end)
                local s, f = pcall(function()
                    return Font.new(getasset(p))
                end)
                if s and f then return f end
            end
            local s, f = pcall(function()
                return Font.new(id)
            end)
            if s and f then return f end
        end
    end
    return nil
end

local font = loadfont("gatosfont", { "gaf/assets/font.otf", "/gaf/assets/font.otf", "assets/font.otf", "font.otf" })
local fontalt = loadfont("gatosfontalt", { "gaf/assets/font_alt.otf", "/gaf/assets/font_alt.otf", "assets/font_alt.otf", "font_alt.otf" })

local cface = Color3.fromRGB(192, 192, 192)
local cwhite = Color3.fromRGB(255, 255, 255)
local clight = Color3.fromRGB(223, 223, 223)
local cdark = Color3.fromRGB(128, 128, 128)
local cblack = Color3.fromRGB(0, 0, 0)
local ctitle = Color3.fromRGB(0, 0, 128)
local ctrack = Color3.fromRGB(212, 208, 200)

local upimg = resolve({ "gaf/assets/up.png", "/gaf/assets/up.png", "assets/up.png", "up.png" }, "rbxassetid://90683894679540")
local downimg = resolve({ "gaf/assets/down.png", "/gaf/assets/down.png", "assets/down.png", "down.png" }, "rbxassetid://72000447719544")
local supimg = resolve({ "gaf/assets/sup.png", "/gaf/assets/sup.png", "assets/sup.png", "sup.png" }, "")
local sdownimg = resolve({ "gaf/assets/sdown.png", "/gaf/assets/sdown.png", "assets/sdown.png", "sdown.png" }, "")
local adbdownimg = resolve({ "gaf/assets/adbdown.png", "/gaf/assets/adbdown.png", "assets/adbdown.png", "adbdown.png" }, "")
local adbdownpressimg = resolve({ "gaf/assets/adbdownpress.png", "/gaf/assets/adbdownpress.png", "assets/adbdownpress.png", "adbdownpress.png" }, "")
local tickedimg = resolve({ "gaf/assets/ticked.png", "/gaf/assets/ticked.png", "assets/ticked.png", "ticked.png" }, "")
local untickedimg = resolve({ "gaf/assets/unticked.png", "/gaf/assets/unticked.png", "assets/unticked.png", "unticked.png" }, "")
local knobimg = resolve({ "gaf/assets/knob.png", "/gaf/assets/knob.png", "assets/knob.png", "knob.png" }, "")
local tbupnpimg = resolve({ "gaf/assets/tbupnp.png", "/gaf/assets/tbupnp.png", "assets/tbupnp.png", "tbupnp.png" }, "")
local tbdownnpimg = resolve({ "gaf/assets/tbdownnp.png", "/gaf/assets/tbdownnp.png", "assets/tbdownnp.png", "tbdownnp.png" }, "")
local tbuppimg = resolve({ "gaf/assets/tbupp.png", "/gaf/assets/tbupp.png", "assets/tbupp.png", "tbupp.png" }, "")
local tbdownpimg = resolve({ "gaf/assets/tbdownp.png", "/gaf/assets/tbdownp.png", "assets/tbdownp.png", "tbdownp.png" }, "")

local function loadcachedtexts()
    local list = {}
    if isfile and readfile then
        pcall(function()
            if isfile("gaf/cache/cachedtexts.json") then
                local raw = readfile("gaf/cache/cachedtexts.json")
                local data = hs:JSONDecode(raw)
                if type(data) == "table" then
                    list = data
                end
            end
        end)
    end
    return list
end

local function savecachedtext(str)
    if not str or str == "" then return end
    local list = loadcachedtexts()
    for i = #list, 1, -1 do
        if list[i] == str then
            table.remove(list, i)
        end
    end
    table.insert(list, 1, str)
    while #list > 5 do
        table.remove(list)
    end
    if writefile then
        pcall(function()
            if makefolder then
                if isfolder and not isfolder("gaf") then
                    pcall(makefolder, "gaf")
                end
                if isfolder and not isfolder("gaf/cache") then
                    pcall(makefolder, "gaf/cache")
                end
            end
            writefile("gaf/cache/cachedtexts.json", hs:JSONEncode(list))
        end)
    end
end

local function applybevel(obj, sunken)
    local to = sunken and cdark or cwhite
    local ti = sunken and cblack or clight
    local bo = sunken and cwhite or cblack
    local bi = sunken and clight or cdark

    local t1 = obj:FindFirstChild("Bevel_TO")
    local l1 = obj:FindFirstChild("Bevel_LO")
    local t2 = obj:FindFirstChild("Bevel_TI")
    local l2 = obj:FindFirstChild("Bevel_LI")
    local r1 = obj:FindFirstChild("Bevel_RO")
    local b1 = obj:FindFirstChild("Bevel_BO")
    local r2 = obj:FindFirstChild("Bevel_RI")
    local b2 = obj:FindFirstChild("Bevel_BI")

    if not (t1 and l1 and t2 and l2 and r1 and b1 and r2 and b2) then
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Frame") and (child.Name == "Bevel" or child.Name:sub(1, 6) == "Bevel_") then
                child:Destroy()
            end
        end

        local z = obj.ZIndex + 2

        t1 = Instance.new("Frame")
        t1.Name = "Bevel_TO"
        t1.Size = UDim2.new(1, 0, 0, 1)
        t1.Position = UDim2.new(0, 0, 0, 0)
        t1.BorderSizePixel = 0
        t1.ZIndex = z
        t1.Parent = obj

        l1 = Instance.new("Frame")
        l1.Name = "Bevel_LO"
        l1.Size = UDim2.new(0, 1, 1, 0)
        l1.Position = UDim2.new(0, 0, 0, 0)
        l1.BorderSizePixel = 0
        l1.ZIndex = z
        l1.Parent = obj

        t2 = Instance.new("Frame")
        t2.Name = "Bevel_TI"
        t2.Size = UDim2.new(1, -2, 0, 1)
        t2.Position = UDim2.new(0, 1, 0, 1)
        t2.BorderSizePixel = 0
        t2.ZIndex = z
        t2.Parent = obj

        l2 = Instance.new("Frame")
        l2.Name = "Bevel_LI"
        l2.Size = UDim2.new(0, 1, 1, -2)
        l2.Position = UDim2.new(0, 1, 0, 1)
        l2.BorderSizePixel = 0
        l2.ZIndex = z
        l2.Parent = obj

        r1 = Instance.new("Frame")
        r1.Name = "Bevel_RO"
        r1.Size = UDim2.new(0, 1, 1, 0)
        r1.Position = UDim2.new(1, -1, 0, 0)
        r1.BorderSizePixel = 0
        r1.ZIndex = z
        r1.Parent = obj

        b1 = Instance.new("Frame")
        b1.Name = "Bevel_BO"
        b1.Size = UDim2.new(1, 0, 0, 1)
        b1.Position = UDim2.new(0, 0, 1, -1)
        b1.BorderSizePixel = 0
        b1.ZIndex = z
        b1.Parent = obj

        r2 = Instance.new("Frame")
        r2.Name = "Bevel_RI"
        r2.Size = UDim2.new(0, 1, 1, -2)
        r2.Position = UDim2.new(1, -2, 0, 1)
        r2.BorderSizePixel = 0
        r2.ZIndex = z
        r2.Parent = obj

        b2 = Instance.new("Frame")
        b2.Name = "Bevel_BI"
        b2.Size = UDim2.new(1, -2, 0, 1)
        b2.Position = UDim2.new(0, 1, 1, -2)
        b2.BorderSizePixel = 0
        b2.ZIndex = z
        b2.Parent = obj
    end

    t1.BackgroundColor3 = to
    l1.BackgroundColor3 = to
    t2.BackgroundColor3 = ti
    l2.BackgroundColor3 = ti
    r1.BackgroundColor3 = bo
    b1.BackgroundColor3 = bo
    r2.BackgroundColor3 = bi
    b2.BackgroundColor3 = bi
end

local function applybuttonbevel(holder, state)
    local to, ti, bo, bi
    local isPreferred = (state == "preferred")
    local isPressed = (state == "pressed")

    if isPressed then
        to = cblack
        ti = cdark
        bo = cwhite
        bi = clight
    elseif isPreferred then
        to = cblack
        ti = cwhite
        bo = cblack
        bi = cdark
    else
        to = cwhite
        ti = clight
        bo = cblack
        bi = cdark
    end

    local t1 = holder:FindFirstChild("Bevel_TO")
    local l1 = holder:FindFirstChild("Bevel_LO")
    local t2 = holder:FindFirstChild("Bevel_TI")
    local l2 = holder:FindFirstChild("Bevel_LI")
    local r1 = holder:FindFirstChild("Bevel_RO")
    local b1 = holder:FindFirstChild("Bevel_BO")
    local r2 = holder:FindFirstChild("Bevel_RI")
    local b2 = holder:FindFirstChild("Bevel_BI")

    if not (t1 and l1 and t2 and l2 and r1 and b1 and r2 and b2) then
        for _, child in ipairs(holder:GetChildren()) do
            if child:IsA("Frame") and (child.Name == "Bevel" or child.Name:sub(1, 6) == "Bevel_") then
                child:Destroy()
            end
        end

        local z = holder.ZIndex + 1

        t1 = Instance.new("Frame")
        t1.Name = "Bevel_TO"
        t1.Size = UDim2.new(1, 0, 0, 1)
        t1.Position = UDim2.new(0, 0, 0, 0)
        t1.BorderSizePixel = 0
        t1.ZIndex = z
        t1.Parent = holder

        l1 = Instance.new("Frame")
        l1.Name = "Bevel_LO"
        l1.Size = UDim2.new(0, 1, 1, 0)
        l1.Position = UDim2.new(0, 0, 0, 0)
        l1.BorderSizePixel = 0
        l1.ZIndex = z
        l1.Parent = holder

        t2 = Instance.new("Frame")
        t2.Name = "Bevel_TI"
        t2.Size = UDim2.new(1, -2, 0, 1)
        t2.Position = UDim2.new(0, 1, 0, 1)
        t2.BorderSizePixel = 0
        t2.ZIndex = z
        t2.Parent = holder

        l2 = Instance.new("Frame")
        l2.Name = "Bevel_LI"
        l2.Size = UDim2.new(0, 1, 1, -2)
        l2.Position = UDim2.new(0, 1, 0, 1)
        l2.BorderSizePixel = 0
        l2.ZIndex = z
        l2.Parent = holder

        r1 = Instance.new("Frame")
        r1.Name = "Bevel_RO"
        r1.Size = UDim2.new(0, 1, 1, 0)
        r1.Position = UDim2.new(1, -1, 0, 0)
        r1.BorderSizePixel = 0
        r1.ZIndex = z
        r1.Parent = holder

        b1 = Instance.new("Frame")
        b1.Name = "Bevel_BO"
        b1.Size = UDim2.new(1, 0, 0, 1)
        b1.Position = UDim2.new(0, 0, 1, -1)
        b1.BorderSizePixel = 0
        b1.ZIndex = z
        b1.Parent = holder

        r2 = Instance.new("Frame")
        r2.Name = "Bevel_RI"
        r2.Size = UDim2.new(0, 1, 1, -2)
        r2.Position = UDim2.new(1, -2, 0, 1)
        r2.BorderSizePixel = 0
        r2.ZIndex = z
        r2.Parent = holder

        b2 = Instance.new("Frame")
        b2.Name = "Bevel_BI"
        b2.Size = UDim2.new(1, -2, 0, 1)
        b2.Position = UDim2.new(0, 1, 1, -2)
        b2.BorderSizePixel = 0
        b2.ZIndex = z
        b2.Parent = holder
    end

    t1.BackgroundColor3 = to
    l1.BackgroundColor3 = to
    t2.BackgroundColor3 = ti
    l2.BackgroundColor3 = ti
    r1.BackgroundColor3 = bo
    b1.BackgroundColor3 = bo
    r2.BackgroundColor3 = bi
    b2.BackgroundColor3 = bi
end

local function attachCustomScrollbar(box, scroll, sbw)
    sbw = sbw or 16
    local track = Instance.new("Frame")
    track.Name = "ScrollTrack"
    track.Size = UDim2.new(0, sbw, 1, -4)
    track.Position = UDim2.new(1, -(sbw + 2), 0, 2)
    track.BackgroundColor3 = ctrack
    track.BorderSizePixel = 0
    track.ZIndex = box.ZIndex + 2
    track.Parent = box

    local div = Instance.new("Frame")
    div.Name = ""
    div.Size = UDim2.new(0, 1, 1, 0)
    div.Position = UDim2.new(0, 0, 0, 0)
    div.BackgroundColor3 = cdark
    div.BorderSizePixel = 0
    div.ZIndex = track.ZIndex + 1
    div.Parent = track

    local btnup = Instance.new("ImageButton")
    btnup.Name = "BtnUp"
    btnup.Size = UDim2.new(1, 0, 0, sbw)
    btnup.Position = UDim2.new(0, 0, 0, 0)
    btnup.BackgroundColor3 = cface
    btnup.BorderSizePixel = 0
    btnup.Image = supimg
    btnup.AutoButtonColor = false
    btnup.ZIndex = track.ZIndex + 2
    btnup.Parent = track
    applybevel(btnup, false)

    local btndown = Instance.new("ImageButton")
    btndown.Name = "BtnDown"
    btndown.Size = UDim2.new(1, 0, 0, sbw)
    btndown.Position = UDim2.new(0, 0, 1, -sbw)
    btndown.BackgroundColor3 = cface
    btndown.BorderSizePixel = 0
    btndown.Image = sdownimg
    btndown.AutoButtonColor = false
    btndown.ZIndex = track.ZIndex + 2
    btndown.Parent = track
    applybevel(btndown, false)

    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(1, 0, 0, sbw)
    thumb.Position = UDim2.new(0, 0, 0, sbw)
    thumb.BackgroundColor3 = cface
    thumb.BorderSizePixel = 0
    thumb.ZIndex = track.ZIndex + 2
    thumb.Active = true
    thumb.Parent = track
    applybevel(thumb, false)

    local function updatethumb()
        local th = track.AbsoluteSize.Y - (sbw * 2)
        if th <= 0 then return end
        local wh = scroll.AbsoluteWindowSize.Y
        local ch = scroll.AbsoluteCanvasSize.Y
        local ms = math.max(0, ch - wh)
        if ms <= 0 then
            thumb.Visible = false
        else
            thumb.Visible = true
            local tbh = math.clamp(math.floor((wh / ch) * th), math.min(sbw, th), th)
            local av = th - tbh
            local r = math.clamp(scroll.CanvasPosition.Y / ms, 0, 1)
            thumb.Size = UDim2.new(1, 0, 0, tbh)
            thumb.Position = UDim2.new(0, 0, 0, sbw + math.floor(r * av))
        end
    end

    scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updatethumb)
    scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updatethumb)
    scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updatethumb)

    btnup.Activated:Connect(function()
        scroll.CanvasPosition = Vector2.new(0, math.max(0, scroll.CanvasPosition.Y - 18))
    end)

    btndown.Activated:Connect(function()
        local ms = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
        scroll.CanvasPosition = Vector2.new(0, math.min(ms, scroll.CanvasPosition.Y + 18))
    end)

    local tdrag = false
    local tdstarty = 0
    local tstartscrolly = 0

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tdrag = true
            tdstarty = input.Position.Y
            tstartscrolly = scroll.CanvasPosition.Y
        end
    end)

    uis.InputChanged:Connect(function(input)
        if tdrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local th = track.AbsoluteSize.Y - (sbw * 2)
            local wh = scroll.AbsoluteWindowSize.Y
            local ch = scroll.AbsoluteCanvasSize.Y
            local ms = math.max(0, ch - wh)
            if ms > 0 and th > 0 then
                local tbh = math.clamp(math.floor((wh / ch) * th), math.min(sbw, th), th)
                local av = th - tbh
                if av > 0 then
                    local dy = input.Position.Y - tdstarty
                    local sd = (dy / av) * ms
                    scroll.CanvasPosition = Vector2.new(0, math.clamp(tstartscrolly + sd, 0, ms))
                end
            end
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tdrag = false
        end
    end)

    task.defer(updatethumb)

    return {
        Track = track,
        Update = updatethumb,
        SetVisible = function(selfOrVis, vis)
            local visible = (type(selfOrVis) == "boolean" and selfOrVis) or (type(vis) == "boolean" and vis)
            if visible == nil then visible = true end
            track.Visible = visible
            if visible then updatethumb() end
        end
    }
end

function AddButton(parent, text, callback)
    local actualParent = (typeof(parent) == "table" and parent.Container) or parent
    local cb = (type(text) == "function" and text) or callback or function() end
    local btnText = (type(text) == "string" and text) or (type(text) == "number" and tostring(text)) or "Button"
    local isEnabled = true

    local holder = Instance.new("Frame")
    holder.Name = btnText .. "Holder"
    holder.Size = UDim2.new(1, 0, 0, 23)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.ZIndex = (actualParent and actualParent.ZIndex or 6) + 1
    holder.LayoutOrder = #actualParent:GetChildren() + 1
    holder.Parent = actualParent

    local function getbtnwidth(str)
        local tw = 0
        pcall(function()
            local bounds = ts:GetTextSize(str, 13, Enum.Font.SourceSans, Vector2.new(10000, 23))
            tw = bounds.X
        end)
        return math.max(20, math.ceil(tw) + 16)
    end

    local btn = Instance.new("TextButton")
    btn.Name = btnText
    btn.Position = UDim2.new(0, 2, 0, 0)
    btn.Size = UDim2.new(0, getbtnwidth(btnText), 0, 23)
    btn.BackgroundColor3 = cface
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Active = true
    btn.ZIndex = holder.ZIndex + 1
    btn.Parent = holder

    local bevelHolder = Instance.new("Frame")
    bevelHolder.Name = "BevelHolder"
    bevelHolder.Size = UDim2.new(1, 0, 1, 0)
    bevelHolder.Position = UDim2.new(0, 0, 0, 0)
    bevelHolder.BackgroundTransparency = 1
    bevelHolder.BorderSizePixel = 0
    bevelHolder.ZIndex = btn.ZIndex + 1
    bevelHolder.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = btnText
    lbl.TextColor3 = cblack
    lbl.TextSize = 13
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    if fontalt then
        lbl.FontFace = fontalt
    elseif font then
        lbl.FontFace = font
    else
        lbl.Font = Enum.Font.SourceSans
    end
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = btn.ZIndex + 3
    lbl.Parent = btn

    local isHovered = false
    local isPressed = false

    local function updateState()
        if not isEnabled then
            applybuttonbevel(bevelHolder, "default")
            lbl.TextColor3 = cdark
            lbl.Position = UDim2.new(0, 0, 0, 0)
            return
        end
        lbl.TextColor3 = cblack
        if isPressed then
            applybuttonbevel(bevelHolder, "pressed")
            lbl.Position = UDim2.new(0, 1, 0, 1)
        elseif isHovered then
            applybuttonbevel(bevelHolder, "preferred")
            lbl.Position = UDim2.new(0, 0, 0, 0)
        else
            applybuttonbevel(bevelHolder, "default")
            lbl.Position = UDim2.new(0, 0, 0, 0)
        end
    end

    btn.MouseEnter:Connect(function()
        if not isEnabled then return end
        isHovered = true
        updateState()
    end)

    btn.MouseLeave:Connect(function()
        isHovered = false
        isPressed = false
        updateState()
    end)

    btn.InputBegan:Connect(function(input)
        if not isEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isPressed = true
            updateState()
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isPressed then
                isPressed = false
                updateState()
            end
        end
    end)

    btn.Activated:Connect(function()
        if not isEnabled then return end
        pcall(cb)
    end)

    local function setDisabled(disabled)
        isEnabled = not disabled
        btn.Active = isEnabled
        if not isEnabled then
            isHovered = false
            isPressed = false
        end
        updateState()
    end

    updateState()

    local btnObj = {}
    btnObj.Instance = btn
    btnObj.SetText = function(selfOrText, newText)
        local t = (selfOrText == btnObj or (type(selfOrText) == "table" and selfOrText.Instance)) and newText or selfOrText
        btnText = (t ~= nil and tostring(t)) or ""
        lbl.Text = btnText
        btn.Size = UDim2.new(0, getbtnwidth(btnText), 0, 23)
    end
    btnObj.GetText = function() return btnText end
    btnObj.Get = function() return btnText end
    btnObj.SetCallback = function(selfOrCb, newCb)
        local c = (selfOrCb == btnObj or (type(selfOrCb) == "table" and selfOrCb.Instance)) and newCb or selfOrCb
        cb = c or function() end
    end
    btnObj.SetDisabled = function(selfOrDis, disabled)
        local d = (selfOrDis == btnObj or (type(selfOrDis) == "table" and selfOrDis.Instance)) and disabled or selfOrDis
        setDisabled(not not d)
    end
    btnObj.SetEnabled = function(selfOrEn, enabled)
        local e = (selfOrEn == btnObj or (type(selfOrEn) == "table" and selfOrEn.Instance)) and enabled or selfOrEn
        setDisabled(not e)
    end
    btnObj.GetDisabled = function() return not isEnabled end
    btnObj.IsEnabled = function() return isEnabled end
    btnObj.Fire = function() if isEnabled then pcall(cb) end end
    btnObj.Click = function() if isEnabled then pcall(cb) end end

    return btnObj
end

function AddNumberInput(parent, text, default, size, callback)
    local actualParent = (typeof(parent) == "table" and parent.Container) or parent
    local cb = callback
    local boxSize = size

    if type(size) == "function" then
        cb = size
        boxSize = nil
    elseif type(default) == "function" then
        cb = default
        default = nil
        boxSize = nil
    end

    cb = cb or function() end

    local currentVal = default
    local currentText = (default ~= nil) and tostring(default) or ""
    local hasLabel = (text and text ~= "")
    local labelTitle = text or ""
    local isEnabled = true

    local inputSize = UDim2.new(0, 75, 0, 22)
    if typeof(boxSize) == "UDim2" then
        inputSize = boxSize
    elseif type(boxSize) == "number" then
        inputSize = UDim2.new(0, boxSize, 0, 22)
    elseif typeof(boxSize) == "Vector2" then
        inputSize = UDim2.new(0, boxSize.X, 0, boxSize.Y)
    end

    local boxH = inputSize.Y.Offset > 0 and inputSize.Y.Offset or 22
    local labelH = hasLabel and 14 or 0
    local totalH = hasLabel and (labelH + 2 + boxH) or boxH

    local row = Instance.new("Frame")
    row.Name = (hasLabel and labelTitle or "NumberInput") .. "Row"
    row.Size = UDim2.new(1, 0, 0, totalH)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.ZIndex = (actualParent and actualParent.ZIndex or 6) + 1
    row.ClipsDescendants = false
    row.LayoutOrder = #actualParent:GetChildren() + 1
    row.Parent = actualParent

    local lbl = nil
    if hasLabel then
        lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(1, -4, 0, labelH)
        lbl.Position = UDim2.new(0, 2, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.BorderSizePixel = 0
        lbl.Text = labelTitle
        lbl.TextColor3 = cblack
        lbl.TextSize = 13
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.ClipsDescendants = true
        if fontalt then
            lbl.FontFace = fontalt
        elseif font then
            lbl.FontFace = font
        else
            lbl.Font = Enum.Font.SourceSans
        end
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.ZIndex = row.ZIndex + 1
        lbl.Parent = row
    end

    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputBox"
    inputContainer.Size = inputSize
    inputContainer.Position = UDim2.new(0, 2, 0, hasLabel and (labelH + 2) or 0)
    inputContainer.BackgroundColor3 = cwhite
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = row.ZIndex + 1
    inputContainer.ClipsDescendants = true
    inputContainer.Parent = row

    applybevel(inputContainer, true)

    local btnW = 15
    local halfH = math.floor(boxH / 2)
    local bottomH = boxH - halfH

    local boxInput = Instance.new("TextBox")
    boxInput.Name = "Text"
    boxInput.Size = UDim2.new(1, -(btnW + 6), 1, 0)
    boxInput.Position = UDim2.new(0, 3, 0, 0)
    boxInput.BackgroundTransparency = 1
    boxInput.BorderSizePixel = 0
    boxInput.Text = currentText
    boxInput.TextColor3 = cblack
    boxInput.PlaceholderColor3 = cdark
    boxInput.TextSize = 13
    boxInput.TextTruncate = Enum.TextTruncate.AtEnd
    boxInput.ClipsDescendants = true
    if fontalt then
        boxInput.FontFace = fontalt
    elseif font then
        boxInput.FontFace = font
    else
        boxInput.Font = Enum.Font.SourceSans
    end
    boxInput.TextXAlignment = Enum.TextXAlignment.Left
    boxInput.TextYAlignment = Enum.TextYAlignment.Center
    boxInput.ClearTextOnFocus = false
    boxInput.ZIndex = inputContainer.ZIndex + 2
    boxInput.Parent = inputContainer

    local btnUp = Instance.new("ImageButton")
    btnUp.Name = "BtnUp"
    btnUp.Size = UDim2.new(0, btnW, 0, halfH)
    btnUp.Position = UDim2.new(1, -btnW, 0, 0)
    btnUp.BackgroundColor3 = cface
    btnUp.BorderSizePixel = 0
    btnUp.AutoButtonColor = false
    btnUp.Image = tbupnpimg
    btnUp.ZIndex = inputContainer.ZIndex + 2
    btnUp.Parent = inputContainer

    if tbupnpimg == "" then
        applybevel(btnUp, false)
    end

    local btnDown = Instance.new("ImageButton")
    btnDown.Name = "BtnDown"
    btnDown.Size = UDim2.new(0, btnW, 0, bottomH)
    btnDown.Position = UDim2.new(1, -btnW, 0, halfH)
    btnDown.BackgroundColor3 = cface
    btnDown.BorderSizePixel = 0
    btnDown.AutoButtonColor = false
    btnDown.Image = tbdownnpimg
    btnDown.ZIndex = inputContainer.ZIndex + 2
    btnDown.Parent = inputContainer

    if tbdownnpimg == "" then
        applybevel(btnDown, false)
    end

    local function getNumericValue()
        local n = tonumber(boxInput.Text)
        if not n then
            n = tonumber(currentVal) or 0
        end
        return n
    end

    local function updateValue(newVal)
        currentVal = newVal
        currentText = (newVal ~= nil) and tostring(newVal) or ""
        boxInput.Text = currentText
        pcall(cb, currentVal)
    end

    local function filterInput()
        local raw = boxInput.Text
        local filtered = raw:gsub("[^%-%d%.]", "")
        local minus = filtered:sub(1, 1) == "-" and "-" or ""
        filtered = filtered:gsub("%-", "")
        local firstDot = filtered:find("%.")
        if firstDot then
            local intPart = filtered:sub(1, firstDot - 1)
            local decPart = filtered:sub(firstDot + 1):gsub("%.", "")
            filtered = intPart .. "." .. decPart
        end
        filtered = minus .. filtered
        if filtered ~= raw then
            boxInput.Text = filtered
        end
        currentText = filtered
        currentVal = tonumber(filtered)
    end

    boxInput:GetPropertyChangedSignal("Text"):Connect(function()
        if not isEnabled then return end
        filterInput()
    end)

    boxInput.FocusLost:Connect(function(enterPressed)
        if not isEnabled then return end
        local n = tonumber(boxInput.Text)
        if n then
            currentVal = n
            currentText = tostring(n)
            boxInput.Text = currentText
            pcall(cb, currentVal)
        else
            currentVal = nil
            currentText = ""
            boxInput.Text = ""
            pcall(cb, nil)
        end
    end)

    local upHolding = false
    local downHolding = false
    local loopThread = nil

    local function stopHold()
        upHolding = false
        downHolding = false
        btnUp.Image = tbupnpimg
        btnDown.Image = tbdownnpimg
        if loopThread then
            task.cancel(loopThread)
            loopThread = nil
        end
    end

    local function stepValue(delta)
        if not isEnabled then return end
        local val = getNumericValue() + delta
        updateValue(val)
    end

    btnUp.InputBegan:Connect(function(input)
        if not isEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            stopHold()
            upHolding = true
            btnUp.Image = (tbuppimg ~= "" and tbuppimg) or tbupnpimg
            stepValue(1)
            loopThread = task.spawn(function()
                task.wait(0.4)
                while upHolding do
                    stepValue(1)
                    task.wait(0.08)
                end
            end)
        end
    end)

    btnUp.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if upHolding then
                stopHold()
            end
        end
    end)

    btnUp.MouseLeave:Connect(function()
        if upHolding then
            stopHold()
        end
    end)

    btnDown.InputBegan:Connect(function(input)
        if not isEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            stopHold()
            downHolding = true
            btnDown.Image = (tbdownpimg ~= "" and tbdownpimg) or tbdownnpimg
            stepValue(-1)
            loopThread = task.spawn(function()
                task.wait(0.4)
                while downHolding do
                    stepValue(-1)
                    task.wait(0.08)
                end
            end)
        end
    end)

    btnDown.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if downHolding then
                stopHold()
            end
        end
    end)

    btnDown.MouseLeave:Connect(function()
        if downHolding then
            stopHold()
        end
    end)

    local function setDisabled(disabled)
        isEnabled = not disabled
        boxInput.TextEditable = isEnabled
        if isEnabled then
            if lbl then lbl.TextColor3 = cblack end
            inputContainer.BackgroundColor3 = cwhite
            boxInput.TextColor3 = cblack
            btnUp.ImageTransparency = 0
            btnDown.ImageTransparency = 0
            btnUp.Active = true
            btnDown.Active = true
        else
            stopHold()
            if lbl then lbl.TextColor3 = cdark end
            inputContainer.BackgroundColor3 = ctrack
            boxInput.TextColor3 = cdark
            btnUp.ImageTransparency = 0.5
            btnDown.ImageTransparency = 0.5
            btnUp.Active = false
            btnDown.Active = false
        end
    end

    local numObj = {}
    numObj.Instance = row
    numObj.Set = function(selfOrVal, val)
        local v = (selfOrVal == numObj or (type(selfOrVal) == "table" and selfOrVal.Instance)) and val or selfOrVal
        local n = tonumber(v)
        if n then
            updateValue(n)
        else
            currentVal = nil
            currentText = ""
            boxInput.Text = ""
            pcall(cb, nil)
        end
    end
    numObj.SetValue = numObj.Set
    numObj.Get = function() return currentVal end
    numObj.GetValue = function() return currentVal end
    numObj.Clear = function()
        currentVal = nil
        currentText = ""
        boxInput.Text = ""
        pcall(cb, nil)
    end
    numObj.SetPlaceholder = function(selfOrText, text)
        local t = (selfOrText == numObj or (type(selfOrText) == "table" and selfOrText.Instance)) and text or selfOrText
        boxInput.PlaceholderText = (t ~= nil and tostring(t)) or ""
    end
    numObj.SetLabel = function(selfOrText, text)
        local t = (selfOrText == numObj or (type(selfOrText) == "table" and selfOrText.Instance)) and text or selfOrText
        labelTitle = (t ~= nil and tostring(t)) or ""
        if lbl then
            lbl.Text = labelTitle
        end
    end
    numObj.SetText = numObj.SetLabel
    numObj.SetCallback = function(selfOrCb, newCb)
        local c = (selfOrCb == numObj or (type(selfOrCb) == "table" and selfOrCb.Instance)) and newCb or selfOrCb
        cb = c or function() end
    end
    numObj.SetDisabled = function(selfOrDis, disabled)
        local d = (selfOrDis == numObj or (type(selfOrDis) == "table" and selfOrDis.Instance)) and disabled or selfOrDis
        setDisabled(not not d)
    end
    numObj.SetEnabled = function(selfOrEn, enabled)
        local e = (selfOrEn == numObj or (type(selfOrEn) == "table" and selfOrEn.Instance)) and enabled or selfOrEn
        setDisabled(not e)
    end
    numObj.GetDisabled = function() return not isEnabled end
    numObj.IsEnabled = function() return isEnabled end

    return numObj
end

function AddTextBox(parent, text, default, hasDropdown, callback)
    local actualParent = (typeof(parent) == "table" and parent.Container) or parent
    local cb = callback
    local currentText = default or ""
    local dropFlag = hasDropdown

    if type(hasDropdown) == "function" then
        cb = hasDropdown
        dropFlag = false
    elseif type(default) == "function" then
        cb = default
        currentText = ""
        dropFlag = false
    end

    cb = cb or function() end
    local hasLabel = (text and text ~= "")
    local labelText = text or ""
    local dropOpen = false
    local isEnabled = true

    local row = Instance.new("Frame")
    row.Name = (hasLabel and labelText or "TextBox") .. "Row"
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.ZIndex = (actualParent and actualParent.ZIndex or 6) + 1
    row.ClipsDescendants = false
    row.LayoutOrder = #actualParent:GetChildren() + 1
    row.Parent = actualParent

    local lbl = nil
    local boxOffset = 2
    if hasLabel then
        local measuredX = 48
        pcall(function()
            local bounds = ts:GetTextSize(labelText, 13, Enum.Font.SourceSans, Vector2.new(10000, 22))
            measuredX = bounds.X
        end)

        local labelWidth = math.clamp(math.ceil(measuredX) + 4, 12, 140)

        lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(0, labelWidth, 1, 0)
        lbl.Position = UDim2.new(0, 2, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.BorderSizePixel = 0
        lbl.Text = labelText
        lbl.TextColor3 = cblack
        lbl.TextSize = 13
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.ClipsDescendants = true
        if fontalt then
            lbl.FontFace = fontalt
        elseif font then
            lbl.FontFace = font
        else
            lbl.Font = Enum.Font.SourceSans
        end
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.ZIndex = row.ZIndex + 1
        lbl.Parent = row
        boxOffset = labelWidth + 6
    end

    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputBox"
    inputContainer.Size = UDim2.new(1, -(boxOffset + 2), 1, 0)
    inputContainer.Position = UDim2.new(0, boxOffset, 0, 0)
    inputContainer.BackgroundColor3 = cwhite
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = row.ZIndex + 1
    inputContainer.ClipsDescendants = true
    inputContainer.Parent = row

    applybevel(inputContainer, true)

    local boxInput = Instance.new("TextBox")
    boxInput.Name = "Text"
    boxInput.Size = UDim2.new(1, dropFlag and -19 or -6, 1, 0)
    boxInput.Position = UDim2.new(0, 3, 0, 0)
    boxInput.BackgroundTransparency = 1
    boxInput.BorderSizePixel = 0
    boxInput.Text = currentText
    boxInput.TextColor3 = cblack
    boxInput.PlaceholderColor3 = cdark
    boxInput.TextSize = 13
    boxInput.TextTruncate = Enum.TextTruncate.AtEnd
    boxInput.ClipsDescendants = true
    if fontalt then
        boxInput.FontFace = fontalt
    elseif font then
        boxInput.FontFace = font
    else
        boxInput.Font = Enum.Font.SourceSans
    end
    boxInput.TextXAlignment = Enum.TextXAlignment.Left
    boxInput.TextYAlignment = Enum.TextYAlignment.Center
    boxInput.ClearTextOnFocus = false
    boxInput.ZIndex = inputContainer.ZIndex + 2
    boxInput.Parent = inputContainer

    local topRoot = row:FindFirstAncestorOfClass("ScreenGui") or target

    local dropListFrame = nil
    local dropScroll = nil
    local dropScrollbar = nil
    local outsideConn = nil
    local dropBtn = nil
    local dropIcn = nil

    local function closeDropdown()
        dropOpen = false
        if dropListFrame then
            dropListFrame.Visible = false
        end
        if outsideConn then
            outsideConn:Disconnect()
            outsideConn = nil
        end
        if dropBtn then
            applybevel(dropBtn, false)
            if dropIcn then
                dropIcn.Image = adbdownimg
            end
        end
    end

    local function isInsideVisibleArea()
        if not inputContainer or not inputContainer.Parent then return false end
        local p = inputContainer
        while p do
            if p:IsA("GuiObject") and not p.Visible then
                return false
            end
            p = p.Parent
        end
        local scrollAncestor = row:FindFirstAncestorWhichIsA("ScrollingFrame")
        if scrollAncestor then
            local spPos = scrollAncestor.AbsolutePosition
            local spSize = scrollAncestor.AbsoluteSize
            local bPos = inputContainer.AbsolutePosition
            local bSize = inputContainer.AbsoluteSize
            if (bPos.Y + bSize.Y <= spPos.Y) or (bPos.Y >= spPos.Y + spSize.Y) or (bPos.X + bSize.X <= spPos.X) or (bPos.X >= spPos.X + spSize.X) then
                return false
            end
        end
        return true
    end

    local function updateDropPosition()
        if not dropOpen or not dropListFrame or not inputContainer then return end
        if not isInsideVisibleArea() then
            closeDropdown()
            return
        end
        local absPos = inputContainer.AbsolutePosition
        local absSize = inputContainer.AbsoluteSize
        dropListFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 1)
        dropListFrame.Size = UDim2.new(0, absSize.X, 0, dropListFrame.Size.Y.Offset)
    end

    local function openDropdown()
        if not isEnabled then return end
        local items = loadcachedtexts()
        local count = #items
        if count == 0 then return end

        dropOpen = true

        if dropBtn then
            applybevel(dropBtn, true)
            if dropIcn then
                dropIcn.Image = (adbdownpressimg ~= "" and adbdownpressimg) or adbdownimg
            end
        end

        for _, child in ipairs(dropScroll:GetChildren()) do
            if child:IsA("GuiObject") and child.Name == "Item" then
                child:Destroy()
            end
        end

        local visibleItems = math.min(count, 4)
        local frameHeight = visibleItems * 18 + 4
        local hasScroll = (count > 4)

        local absPos = inputContainer.AbsolutePosition
        local absSize = inputContainer.AbsoluteSize

        dropListFrame.Size = UDim2.new(0, absSize.X, 0, frameHeight)
        dropListFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 1)
        dropListFrame.Parent = topRoot
        dropListFrame.Visible = true

        dropScroll.Size = UDim2.new(1, hasScroll and -20 or -4, 1, -4)
        dropScroll.CanvasSize = UDim2.new(0, 0, 0, count * 18)
        dropScroll.ScrollBarThickness = 0

        if dropScrollbar then
            dropScrollbar.SetVisible(hasScroll)
        end

        for i, itemText in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Name = "Item"
            itemBtn.Size = UDim2.new(1, 0, 0, 18)
            itemBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 18)
            itemBtn.BackgroundColor3 = cwhite
            itemBtn.BorderSizePixel = 0
            itemBtn.AutoButtonColor = false
            itemBtn.Text = "  " .. itemText
            itemBtn.TextColor3 = cblack
            itemBtn.TextSize = 13
            itemBtn.TextTruncate = Enum.TextTruncate.AtEnd
            itemBtn.ClipsDescendants = true
            if fontalt then
                itemBtn.FontFace = fontalt
            elseif font then
                itemBtn.FontFace = font
            else
                itemBtn.Font = Enum.Font.SourceSans
            end
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.TextYAlignment = Enum.TextYAlignment.Center
            itemBtn.ZIndex = dropScroll.ZIndex + 2
            itemBtn.Parent = dropScroll

            itemBtn.MouseEnter:Connect(function()
                itemBtn.BackgroundColor3 = ctitle
                itemBtn.TextColor3 = cwhite
            end)

            itemBtn.MouseLeave:Connect(function()
                itemBtn.BackgroundColor3 = cwhite
                itemBtn.TextColor3 = cblack
            end)

            itemBtn.Activated:Connect(function()
                if not isEnabled then return end
                boxInput.Text = itemText
                currentText = itemText
                savecachedtext(itemText)
                closeDropdown()
                pcall(cb, itemText, false)
            end)
        end

        if outsideConn then outsideConn:Disconnect() end
        outsideConn = uis.InputBegan:Connect(function(input)
            if not dropOpen then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local p = input.Position
                local dp = dropListFrame.AbsolutePosition
                local ds = dropListFrame.AbsoluteSize
                local bp = inputContainer.AbsolutePosition
                local bs = inputContainer.AbsoluteSize
                local inDrop = (p.X >= dp.X and p.X <= dp.X + ds.X and p.Y >= dp.Y and p.Y <= dp.Y + ds.Y)
                local inBox = (p.X >= bp.X and p.X <= bp.X + bs.X and p.Y >= bp.Y and p.Y <= bp.Y + bs.Y)
                if not inDrop and not inBox then
                    closeDropdown()
                end
            end
        end)
    end

    if dropFlag then
        dropBtn = Instance.new("ImageButton")
        dropBtn.Name = "DropdownButton"
        dropBtn.Size = UDim2.new(0, 16, 1, 0)
        dropBtn.Position = UDim2.new(1, -16, 0, 0)
        dropBtn.BackgroundColor3 = cface
        dropBtn.BorderSizePixel = 0
        dropBtn.AutoButtonColor = false
        dropBtn.ZIndex = inputContainer.ZIndex + 2
        dropBtn.Parent = inputContainer

        applybevel(dropBtn, false)

        dropIcn = Instance.new("ImageLabel")
        dropIcn.Name = "Icon"
        dropIcn.Size = UDim2.new(1, 0, 1, 0)
        dropIcn.Position = UDim2.new(0, 0, 0, 0)
        dropIcn.BackgroundTransparency = 1
        dropIcn.BorderSizePixel = 0
        dropIcn.Image = adbdownimg
        dropIcn.ZIndex = dropBtn.ZIndex + 2
        dropIcn.Parent = dropBtn

        dropListFrame = Instance.new("Frame")
        dropListFrame.Name = "DropdownList"
        dropListFrame.BackgroundColor3 = cwhite
        dropListFrame.BorderSizePixel = 0
        dropListFrame.Visible = false
        dropListFrame.ZIndex = 100
        dropListFrame.ClipsDescendants = false

        applybevel(dropListFrame, true)

        dropScroll = Instance.new("ScrollingFrame")
        dropScroll.Name = "ListScroll"
        dropScroll.Position = UDim2.new(0, 2, 0, 2)
        dropScroll.Size = UDim2.new(1, -20, 1, -4)
        dropScroll.BackgroundTransparency = 1
        dropScroll.BorderSizePixel = 0
        dropScroll.ScrollBarThickness = 0
        dropScroll.ZIndex = dropListFrame.ZIndex + 1
        dropScroll.Parent = dropListFrame

        dropScrollbar = attachCustomScrollbar(dropListFrame, dropScroll, 16)
        dropScrollbar.SetVisible(false)

        inputContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateDropPosition)
        inputContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateDropPosition)

        local scrollAncestor = row:FindFirstAncestorWhichIsA("ScrollingFrame") or (actualParent:IsA("ScrollingFrame") and actualParent)
        if scrollAncestor then
            scrollAncestor:GetPropertyChangedSignal("CanvasPosition"):Connect(updateDropPosition)
            scrollAncestor:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateDropPosition)
        end

        dropBtn.Activated:Connect(function()
            if not isEnabled then return end
            if dropOpen then
                closeDropdown()
            else
                openDropdown()
            end
        end)
    end

    boxInput.FocusLost:Connect(function(enterPressed)
        if not isEnabled then return end
        currentText = boxInput.Text
        if enterPressed and currentText ~= "" then
            savecachedtext(currentText)
        end
        pcall(cb, currentText, enterPressed)
    end)

    local function setDisabled(disabled)
        isEnabled = not disabled
        boxInput.TextEditable = isEnabled
        if not isEnabled then
            closeDropdown()
            if lbl then lbl.TextColor3 = cdark end
            inputContainer.BackgroundColor3 = ctrack
            boxInput.TextColor3 = cdark
            if dropBtn then
                dropBtn.Active = false
                if dropIcn then dropIcn.ImageTransparency = 0.5 end
            end
        else
            if lbl then lbl.TextColor3 = cblack end
            inputContainer.BackgroundColor3 = cwhite
            boxInput.TextColor3 = cblack
            if dropBtn then
                dropBtn.Active = true
                if dropIcn then dropIcn.ImageTransparency = 0 end
            end
        end
    end

    local txtObj = {}
    txtObj.Instance = row
    txtObj.Set = function(selfOrVal, val)
        local v = (selfOrVal == txtObj or (type(selfOrVal) == "table" and selfOrVal.Instance)) and val or selfOrVal
        currentText = (v ~= nil and tostring(v)) or ""
        boxInput.Text = currentText
        pcall(cb, currentText, false)
    end
    txtObj.SetText = txtObj.Set
    txtObj.SetValue = txtObj.Set
    txtObj.Get = function() return currentText end
    txtObj.GetText = function() return currentText end
    txtObj.GetValue = function() return currentText end
    txtObj.Clear = function()
        currentText = ""
        boxInput.Text = ""
        pcall(cb, "", false)
    end
    txtObj.SetPlaceholder = function(selfOrText, text)
        local t = (selfOrText == txtObj or (type(selfOrText) == "table" and selfOrText.Instance)) and text or selfOrText
        boxInput.PlaceholderText = (t ~= nil and tostring(t)) or ""
    end
    txtObj.SetLabel = function(selfOrText, text)
        local t = (selfOrText == txtObj or (type(selfOrText) == "table" and selfOrText.Instance)) and text or selfOrText
        labelText = (t ~= nil and tostring(t)) or ""
        if lbl then
            lbl.Text = labelText
        end
    end
    txtObj.SetCallback = function(selfOrCb, newCb)
        local c = (selfOrCb == txtObj or (type(selfOrCb) == "table" and selfOrCb.Instance)) and newCb or selfOrCb
        cb = c or function() end
    end
    txtObj.SetDisabled = function(selfOrDis, disabled)
        local d = (selfOrDis == txtObj or (type(selfOrDis) == "table" and selfOrDis.Instance)) and disabled or selfOrDis
        setDisabled(not not d)
    end
    txtObj.SetEnabled = function(selfOrEn, enabled)
        local e = (selfOrEn == txtObj or (type(selfOrEn) == "table" and selfOrEn.Instance)) and enabled or selfOrEn
        setDisabled(not e)
    end
    txtObj.GetDisabled = function() return not isEnabled end
    txtObj.IsEnabled = function() return isEnabled end

    return txtObj
end

function AddToggle(parent, text, default, callback)
    local actualParent = (typeof(parent) == "table" and parent.Container) or parent
    local cb = callback
    local state = default or false

    if type(default) == "function" then
        cb = default
        state = false
    end

    cb = cb or function() end
    local toggleText = text or ""
    local isEnabled = true

    local row = Instance.new("TextButton")
    row.Name = toggleText ~= "" and toggleText or "Toggle"
    row.Size = UDim2.new(1, 0, 0, 18)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Active = true
    row.ZIndex = (actualParent and actualParent.ZIndex or 6) + 1
    row.LayoutOrder = #actualParent:GetChildren() + 1
    row.Parent = actualParent

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Size = UDim2.new(0, 13, 0, 13)
    box.Position = UDim2.new(0, 2, 0.5, -6)
    box.BackgroundColor3 = cwhite
    box.BorderSizePixel = 0
    box.ZIndex = row.ZIndex + 1
    box.Parent = row

    applybevel(box, true)

    local icon = Instance.new("ImageLabel")
    icon.Name = "Checkmark"
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0
    icon.ZIndex = box.ZIndex + 3
    icon.Parent = box

    local fallback = Instance.new("TextLabel")
    fallback.Name = "FallbackCheck"
    fallback.Size = UDim2.new(1, 0, 1, 0)
    fallback.Position = UDim2.new(0, 0, 0, -1)
    fallback.BackgroundTransparency = 1
    fallback.Text = "✓"
    fallback.TextColor3 = cblack
    fallback.TextSize = 12
    fallback.Font = Enum.Font.SourceSansBold
    fallback.Visible = false
    fallback.ZIndex = box.ZIndex + 3
    fallback.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -22, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = toggleText
    lbl.TextColor3 = cblack
    lbl.TextSize = 13
    if fontalt then
        lbl.FontFace = fontalt
    elseif font then
        lbl.FontFace = font
    else
        lbl.Font = Enum.Font.SourceSans
    end
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = row.ZIndex + 1
    lbl.Parent = row

    local function updatevisual()
        if state then
            if tickedimg and tickedimg ~= "" then
                icon.Image = tickedimg
                icon.Visible = true
                fallback.Visible = false
            else
                icon.Visible = false
                fallback.Visible = true
            end
        else
            if untickedimg and untickedimg ~= "" then
                icon.Image = untickedimg
                icon.Visible = true
                fallback.Visible = false
            else
                icon.Image = ""
                icon.Visible = false
                fallback.Visible = false
            end
        end
    end

    local function setstate(val)
        state = not not val
        updatevisual()
        pcall(cb, state)
    end

    row.Activated:Connect(function()
        if not isEnabled then return end
        setstate(not state)
    end)

    local function setDisabled(disabled)
        isEnabled = not disabled
        row.Active = isEnabled
        if isEnabled then
            box.BackgroundColor3 = cwhite
            lbl.TextColor3 = cblack
            icon.ImageTransparency = 0
            fallback.TextColor3 = cblack
        else
            box.BackgroundColor3 = ctrack
            lbl.TextColor3 = cdark
            icon.ImageTransparency = 0.5
            fallback.TextColor3 = cdark
        end
    end

    updatevisual()

    local togObj = {}
    togObj.Instance = row
    togObj.Set = function(selfOrVal, val)
        local v = (selfOrVal == togObj or (type(selfOrVal) == "table" and selfOrVal.Instance)) and val or selfOrVal
        setstate(v)
    end
    togObj.SetValue = togObj.Set
    togObj.Get = function() return state end
    togObj.GetValue = function() return state end
    togObj.Toggle = function()
        if isEnabled then setstate(not state) end
    end
    togObj.SetText = function(selfOrText, newText)
        local t = (selfOrText == togObj or (type(selfOrText) == "table" and selfOrText.Instance)) and newText or selfOrText
        toggleText = (t ~= nil and tostring(t)) or ""
        lbl.Text = toggleText
    end
    togObj.SetLabel = togObj.SetText
    togObj.SetCallback = function(selfOrCb, newCb)
        local c = (selfOrCb == togObj or (type(selfOrCb) == "table" and selfOrCb.Instance)) and newCb or selfOrCb
        cb = c or function() end
    end
    togObj.SetDisabled = function(selfOrDis, disabled)
        local d = (selfOrDis == togObj or (type(selfOrDis) == "table" and selfOrDis.Instance)) and disabled or selfOrDis
        setDisabled(not not d)
    end
    togObj.SetEnabled = function(selfOrEn, enabled)
        local e = (selfOrEn == togObj or (type(selfOrEn) == "table" and selfOrEn.Instance)) and enabled or selfOrEn
        setDisabled(not e)
    end
    togObj.GetDisabled = function() return not isEnabled end
    togObj.IsEnabled = function() return isEnabled end

    return togObj
end

function AddSlider(parent, text, min, max, default, stepOrCallback, callback)
    local actualParent = (typeof(parent) == "table" and parent.Container) or parent
    local minVal = tonumber(min) or 0
    local maxVal = tonumber(max) or 100
    local step = 1
    local cb = callback

    if type(stepOrCallback) == "function" then
        cb = stepOrCallback
        step = 1
    elseif type(stepOrCallback) == "number" then
        step = stepOrCallback
    end

    if type(default) == "function" then
        cb = default
        default = minVal
        step = 1
    end

    cb = cb or function() end

    local current = tonumber(default) or minVal
    local labelTitle = text or "Slider"
    local isEnabled = true
    local kw = 11
    local kh = 20

    local row = Instance.new("Frame")
    row.Name = labelTitle .. "Slider"
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.ZIndex = (actualParent and actualParent.ZIndex or 6) + 1
    row.LayoutOrder = #actualParent:GetChildren() + 1
    row.Parent = actualParent

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -4, 0, 14)
    lbl.Position = UDim2.new(0, 2, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelTitle .. ": " .. tostring(current)
    lbl.TextColor3 = cblack
    lbl.TextSize = 13
    if fontalt then
        lbl.FontFace = fontalt
    elseif font then
        lbl.FontFace = font
    else
        lbl.Font = Enum.Font.SourceSans
    end
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = row.ZIndex + 1
    lbl.Parent = row

    local trackContainer = Instance.new("TextButton")
    trackContainer.Name = "Track"
    trackContainer.Size = UDim2.new(1, -16, 0, 26)
    trackContainer.Position = UDim2.new(0, 8, 0, 16)
    trackContainer.BackgroundTransparency = 1
    trackContainer.BorderSizePixel = 0
    trackContainer.Text = ""
    trackContainer.AutoButtonColor = false
    trackContainer.Active = true
    trackContainer.ZIndex = row.ZIndex + 1
    trackContainer.Parent = row

    local channel = Instance.new("Frame")
    channel.Name = "Channel"
    channel.Size = UDim2.new(1, 0, 0, 4)
    channel.Position = UDim2.new(0, 0, 0, 8)
    channel.BackgroundColor3 = cface
    channel.BorderSizePixel = 0
    channel.ZIndex = row.ZIndex + 1
    channel.Parent = trackContainer

    applybevel(channel, true)

    local ticksContainer = Instance.new("Frame")
    ticksContainer.Name = "Ticks"
    ticksContainer.Size = UDim2.new(1, 0, 0, 4)
    ticksContainer.Position = UDim2.new(0, 0, 0, 16)
    ticksContainer.BackgroundTransparency = 1
    ticksContainer.BorderSizePixel = 0
    ticksContainer.ZIndex = row.ZIndex + 1
    ticksContainer.Parent = trackContainer

    local function rebuildTicks()
        for _, c in ipairs(ticksContainer:GetChildren()) do
            c:Destroy()
        end
        local stepVal = step > 0 and step or 1
        local totalSteps = (maxVal > minVal) and math.floor(((maxVal - minVal) / stepVal) + 0.5) or 1
        local maxTicks = 25
        local stride = (totalSteps <= maxTicks) and 1 or math.ceil(totalSteps / maxTicks)

        for k = 0, totalSteps, stride do
            local r = k / totalSteps
            local tick = Instance.new("Frame")
            tick.Name = "Tick"
            tick.Size = UDim2.new(0, 1, 0, 3)
            tick.Position = UDim2.new(r, 0, 0, 0)
            tick.BackgroundColor3 = isEnabled and cblack or cdark
            tick.BorderSizePixel = 0
            tick.ZIndex = row.ZIndex + 1
            tick.Parent = ticksContainer
        end

        if (totalSteps % stride) ~= 0 then
            local tick = Instance.new("Frame")
            tick.Name = "Tick"
            tick.Size = UDim2.new(0, 1, 0, 3)
            tick.Position = UDim2.new(1, 0, 0, 0)
            tick.BackgroundColor3 = isEnabled and cblack or cdark
            tick.BorderSizePixel = 0
            tick.ZIndex = row.ZIndex + 1
            tick.Parent = ticksContainer
        end
    end

    local knob = Instance.new("ImageLabel")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, kw, 0, kh)
    knob.Position = UDim2.new(0, 0, 0, 0)
    knob.BackgroundColor3 = cface
    knob.BackgroundTransparency = (knobimg ~= "" and 1 or 0)
    knob.BorderSizePixel = 0
    knob.Image = knobimg
    knob.ZIndex = row.ZIndex + 4
    knob.Parent = trackContainer

    if knobimg == "" then
        applybevel(knob, false)
    end

    local function updatevisual()
        local r = (maxVal == minVal) and 0 or math.clamp((current - minVal) / (maxVal - minVal), 0, 1)
        knob.Position = UDim2.new(r, -math.floor(kw / 2), 0, 0)
        lbl.Text = labelTitle .. ": " .. tostring(current)
    end

    local function setval(val)
        local n = tonumber(val)
        if not n then return end
        local raw = math.clamp(n, minVal, maxVal)
        if step > 0 then
            raw = minVal + math.floor(((raw - minVal) / step) + 0.5) * step
            raw = math.clamp(raw, minVal, maxVal)
        end
        current = raw
        updatevisual()
        pcall(cb, current)
    end

    local dragging = false

    local function handleinput(input)
        if not isEnabled then return end
        local tw = trackContainer.AbsoluteSize.X
        if tw > 0 then
            local relX = math.clamp(input.Position.X - trackContainer.AbsolutePosition.X, 0, tw)
            local r = relX / tw
            local computed = minVal + (maxVal - minVal) * r
            setval(computed)
        end
    end

    trackContainer.InputBegan:Connect(function(input)
        if not isEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            handleinput(input)
        end
    end)

    uis.InputChanged:Connect(function(input)
        if not isEnabled then return end
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            handleinput(input)
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local function setDisabled(disabled)
        isEnabled = not disabled
        trackContainer.Active = isEnabled
        if not isEnabled then
            dragging = false
            lbl.TextColor3 = cdark
            knob.ImageTransparency = 0.5
        else
            lbl.TextColor3 = cblack
            knob.ImageTransparency = 0
        end
        rebuildTicks()
    end

    rebuildTicks()
    updatevisual()

    local sldObj = {}
    sldObj.Instance = row
    sldObj.Set = function(selfOrVal, val)
        local v = (selfOrVal == sldObj or (type(selfOrVal) == "table" and selfOrVal.Instance)) and val or selfOrVal
        setval(v)
    end
    sldObj.SetValue = sldObj.Set
    sldObj.Get = function() return current end
    sldObj.GetValue = function() return current end
    sldObj.SetMin = function(selfOrMin, newMin)
        local m = (selfOrMin == sldObj or (type(selfOrMin) == "table" and selfOrMin.Instance)) and newMin or selfOrMin
        minVal = tonumber(m) or 0
        rebuildTicks()
        setval(current)
    end
    sldObj.SetMax = function(selfOrMax, newMax)
        local m = (selfOrMax == sldObj or (type(selfOrMax) == "table" and selfOrMax.Instance)) and newMax or selfOrMax
        maxVal = tonumber(m) or 100
        rebuildTicks()
        setval(current)
    end
    sldObj.SetStep = function(selfOrStep, newStep)
        local s = (selfOrStep == sldObj or (type(selfOrStep) == "table" and selfOrStep.Instance)) and newStep or selfOrStep
        step = tonumber(s) or 1
        rebuildTicks()
        setval(current)
    end
    sldObj.SetText = function(selfOrText, newText)
        local t = (selfOrText == sldObj or (type(selfOrText) == "table" and selfOrText.Instance)) and newText or selfOrText
        labelTitle = (t ~= nil and tostring(t)) or "Slider"
        updatevisual()
    end
    sldObj.SetLabel = sldObj.SetText
    sldObj.SetCallback = function(selfOrCb, newCb)
        local c = (selfOrCb == sldObj or (type(selfOrCb) == "table" and selfOrCb.Instance)) and newCb or selfOrCb
        cb = c or function() end
    end
    sldObj.SetDisabled = function(selfOrDis, disabled)
        local d = (selfOrDis == sldObj or (type(selfOrDis) == "table" and selfOrDis.Instance)) and disabled or selfOrDis
        setDisabled(not not d)
    end
    sldObj.SetEnabled = function(selfOrEn, enabled)
        local e = (selfOrEn == sldObj or (type(selfOrEn) == "table" and selfOrEn.Instance)) and enabled or selfOrEn
        setDisabled(not e)
    end
    sldObj.GetDisabled = function() return not isEnabled end
    sldObj.IsEnabled = function() return isEnabled end

    return sldObj
end

function CreateWindow(title, icon)
    local w = 420
    local h = 280
    local tbh = 18
    local bw = 3
    local sbw = 16

    local sg = Instance.new("ScreenGui")
    sg.Name = ""
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999

    local main = Instance.new("Frame")
    main.Name = ""
    main.Size = UDim2.new(0, w, 0, h)
    main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
    main.BackgroundColor3 = cface
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = false
    main.Parent = sg

    applybevel(main, false)

    local bar = Instance.new("Frame")
    bar.Name = ""
    bar.Size = UDim2.new(1, -(bw * 2), 0, tbh)
    bar.Position = UDim2.new(0, bw, 0, bw)
    bar.BackgroundColor3 = ctitle
    bar.BorderSizePixel = 0
    bar.ZIndex = 10
    bar.Parent = main

    local iconasset = resolve({ icon or "", "gaf/assets/" .. (icon or ""), "assets/" .. (icon or ""), "gaf/assets/topbaricon.png", "assets/topbaricon.png", "topbaricon.png" }, "")
    local hasicon = (iconasset ~= "")

    local topicon = Instance.new("ImageLabel")
    topicon.Name = ""
    topicon.Size = UDim2.new(0, 16, 0, 16)
    topicon.Position = UDim2.new(0, 1, 0.5, -8)
    topicon.BackgroundTransparency = 1
    topicon.BorderSizePixel = 0
    topicon.Image = iconasset
    topicon.Visible = hasicon
    topicon.ZIndex = 11
    topicon.Parent = bar

    local toplbl = Instance.new("TextLabel")
    toplbl.Name = ""
    toplbl.Size = UDim2.new(1, hasicon and -37 or -21, 1, 0)
    toplbl.Position = UDim2.new(0, hasicon and 19 or 3, 0, 0)
    toplbl.BackgroundTransparency = 1
    toplbl.Text = title or "GatosAutoFarm"
    toplbl.TextColor3 = cwhite
    toplbl.TextSize = 13
    if font then
        toplbl.FontFace = font
    else
        toplbl.Font = Enum.Font.SourceSansBold
    end
    toplbl.TextXAlignment = Enum.TextXAlignment.Left
    toplbl.TextYAlignment = Enum.TextYAlignment.Center
    toplbl.ZIndex = 11
    toplbl.Parent = bar

    local minbtn = Instance.new("ImageButton")
    minbtn.Name = ""
    minbtn.Size = UDim2.new(0, 16, 0, 14)
    minbtn.Position = UDim2.new(1, -18, 0.5, -7)
    minbtn.BackgroundColor3 = cface
    minbtn.BackgroundTransparency = 1
    minbtn.BorderSizePixel = 0
    minbtn.Image = upimg
    minbtn.AutoButtonColor = false
    minbtn.ZIndex = 12
    minbtn.Parent = bar

    local addrrow = Instance.new("Frame")
    addrrow.Name = ""
    addrrow.Size = UDim2.new(1, -(bw * 2), 0, 22)
    addrrow.Position = UDim2.new(0, bw, 0, tbh + bw + 3)
    addrrow.BackgroundColor3 = cface
    addrrow.BorderSizePixel = 0
    addrrow.ZIndex = 9
    addrrow.Parent = main

    local addrlbl = Instance.new("TextLabel")
    addrlbl.Name = ""
    addrlbl.Size = UDim2.new(0, 48, 1, 0)
    addrlbl.Position = UDim2.new(0, 2, 0, 0)
    addrlbl.BackgroundTransparency = 1
    addrlbl.Text = "Address:"
    addrlbl.TextColor3 = cblack
    addrlbl.TextSize = 13
    if fontalt then
        addrlbl.FontFace = fontalt
    elseif font then
        addrlbl.FontFace = font
    else
        addrlbl.Font = Enum.Font.SourceSans
    end
    addrlbl.TextXAlignment = Enum.TextXAlignment.Left
    addrlbl.TextYAlignment = Enum.TextYAlignment.Center
    addrlbl.ZIndex = 10
    addrlbl.Parent = addrrow

    local addrbox = Instance.new("Frame")
    addrbox.Name = ""
    addrbox.Size = UDim2.new(1, -52, 1, -2)
    addrbox.Position = UDim2.new(0, 50, 0, 1)
    addrbox.BackgroundColor3 = cwhite
    addrbox.BorderSizePixel = 0
    addrbox.ZIndex = 10
    addrbox.Parent = addrrow

    applybevel(addrbox, true)

    local addrtxt = Instance.new("TextLabel")
    addrtxt.Name = ""
    addrtxt.Size = UDim2.new(1, -19, 1, 0)
    addrtxt.Position = UDim2.new(0, 3, 0, 0)
    addrtxt.BackgroundTransparency = 1
    addrtxt.Text = "http://filho.wtf/auto_farm.php"
    addrtxt.TextColor3 = cblack
    addrtxt.TextSize = 13
    if fontalt then
        addrtxt.FontFace = fontalt
    elseif font then
        addrtxt.FontFace = font
    else
        addrtxt.Font = Enum.Font.SourceSans
    end
    addrtxt.TextXAlignment = Enum.TextXAlignment.Left
    addrtxt.TextYAlignment = Enum.TextYAlignment.Center
    addrtxt.ZIndex = 11
    addrtxt.Parent = addrbox

    local addrdrop = Instance.new("Frame")
    addrdrop.Name = ""
    addrdrop.Size = UDim2.new(0, 16, 1, 0)
    addrdrop.Position = UDim2.new(1, -16, 0, 0)
    addrdrop.BackgroundColor3 = cface
    addrdrop.BorderSizePixel = 0
    addrdrop.ZIndex = 11
    addrdrop.Parent = addrbox

    applybevel(addrdrop, false)

    local addricn = Instance.new("ImageLabel")
    addricn.Name = ""
    addricn.Size = UDim2.new(1, 0, 1, 0)
    addricn.Position = UDim2.new(0, 0, 0, 0)
    addricn.BackgroundTransparency = 1
    addricn.BorderSizePixel = 0
    addricn.Image = adbdownimg
    addricn.ZIndex = 12
    addricn.Parent = addrdrop

    local sep = Instance.new("Frame")
    sep.Name = ""
    sep.Size = UDim2.new(1, -(bw * 2), 0, 2)
    sep.Position = UDim2.new(0, bw, 0, tbh + bw + 27)
    sep.BackgroundColor3 = cdark
    sep.BorderSizePixel = 0
    sep.ZIndex = 9
    sep.Parent = main

    local sephi = Instance.new("Frame")
    sephi.Name = ""
    sephi.Size = UDim2.new(1, 0, 0, 1)
    sephi.Position = UDim2.new(0, 0, 0, 1)
    sephi.BackgroundColor3 = cwhite
    sephi.BorderSizePixel = 0
    sephi.ZIndex = 9
    sephi.Parent = sep

    local ctop = tbh + bw + 31

    local box = Instance.new("Frame")
    box.Name = ""
    box.Size = UDim2.new(1, -(bw * 2), 1, -(ctop + bw))
    box.Position = UDim2.new(0, bw, 0, ctop)
    box.BackgroundColor3 = cface
    box.BorderSizePixel = 0
    box.ClipsDescendants = true
    box.ZIndex = 5
    box.Parent = main

    applybevel(box, true)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Container"
    scroll.Size = UDim2.new(1, -(sbw + 4), 1, -4)
    scroll.Position = UDim2.new(0, 2, 0, 2)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
    scroll.ZIndex = 6
    scroll.Parent = box

    local layout = Instance.new("UIListLayout")
    layout.Name = "Layout"
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.Name = "Padding"
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = scroll

    local function updateCanvas()
        local pt = pad.PaddingTop.Offset
        local pb = pad.PaddingBottom.Offset
        local totalH = layout.AbsoluteContentSize.Y + pt + pb
        scroll.CanvasSize = UDim2.new(0, 0, 0, totalH)
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    scroll.ChildAdded:Connect(function(child)
        if child:IsA("GuiObject") then
            task.defer(updateCanvas)
        end
    end)
    scroll.ChildRemoved:Connect(function(child)
        if child:IsA("GuiObject") then
            task.defer(updateCanvas)
        end
    end)
    task.defer(updateCanvas)

    attachCustomScrollbar(box, scroll, sbw)

    local min = false
    local hold = false

    local function setpressed(p)
        minbtn.Image = p and downimg or upimg
    end

    minbtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hold = true
            setpressed(true)
        end
    end)

    minbtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hold = false
            setpressed(false)
        end
    end)

    minbtn.MouseLeave:Connect(function()
        if hold then
            hold = false
            setpressed(false)
        end
    end)

    local minh = tbh + (bw * 2)

    local function togglemin()
        min = not min
        if min then
            addrrow.Visible = false
            sep.Visible = false
            box.Visible = false
            main.Size = UDim2.new(0, w, 0, minh)
        else
            main.Size = UDim2.new(0, w, 0, h)
            addrrow.Visible = true
            sep.Visible = true
            box.Visible = true
        end
    end

    minbtn.Activated:Connect(togglemin)

    local drag = false
    local dstart = nil
    local fstart = nil

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mp = input.Position
            local bp = minbtn.AbsolutePosition
            local bs = minbtn.AbsoluteSize
            local over = (mp.X >= bp.X and mp.X <= bp.X + bs.X and mp.Y >= bp.Y and mp.Y <= bp.Y + bs.Y)
            if not over then
                drag = true
                dstart = input.Position
                fstart = main.Position
            end
        end
    end)

    uis.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dstart
            main.Position = UDim2.new(fstart.X.Scale, fstart.X.Offset + d.X, fstart.Y.Scale, fstart.Y.Offset + d.Y)
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    sg.Parent = target

    local winObj = {
        ScreenGui = sg,
        Main = main,
        Container = scroll
    }

    winObj.AddTextBox = function(selfOrText, textOrDefault, defaultOrDropdown, hasDropdownOrCb, cb)
        if selfOrText == winObj or (type(selfOrText) == "table" and selfOrText.ScreenGui ~= nil) then
            return AddTextBox(scroll, textOrDefault, defaultOrDropdown, hasDropdownOrCb, cb)
        else
            return AddTextBox(scroll, selfOrText, textOrDefault, defaultOrDropdown, hasDropdownOrCb)
        end
    end
    winObj.AddInput = winObj.AddTextBox

    winObj.AddNumberInput = function(selfOrText, textOrDefault, defaultOrSize, sizeOrCb, cb)
        if selfOrText == winObj or (type(selfOrText) == "table" and selfOrText.ScreenGui ~= nil) then
            return AddNumberInput(scroll, textOrDefault, defaultOrSize, sizeOrCb, cb)
        else
            return AddNumberInput(scroll, selfOrText, textOrDefault, defaultOrSize, sizeOrCb)
        end
    end

    winObj.AddButton = function(selfOrText, textOrCb, cb)
        if selfOrText == winObj or (type(selfOrText) == "table" and selfOrText.ScreenGui ~= nil) then
            return AddButton(scroll, textOrCb, cb)
        else
            return AddButton(scroll, selfOrText, textOrCb)
        end
    end

    winObj.AddToggle = function(selfOrText, textOrDefault, defaultOrCb, cb)
        if selfOrText == winObj or (type(selfOrText) == "table" and selfOrText.ScreenGui ~= nil) then
            return AddToggle(scroll, textOrDefault, defaultOrCb, cb)
        else
            return AddToggle(scroll, selfOrText, textOrDefault, defaultOrCb)
        end
    end

    winObj.AddSlider = function(selfOrText, textOrMin, minOrMax, maxOrDefault, defaultOrStep, stepOrCb, cb)
        if selfOrText == winObj or (type(selfOrText) == "table" and selfOrText.ScreenGui ~= nil) then
            return AddSlider(scroll, textOrMin, minOrMax, maxOrDefault, defaultOrStep, stepOrCb, cb)
        else
            return AddSlider(scroll, selfOrText, textOrMin, minOrMax, maxOrDefault, defaultOrStep, stepOrCb)
        end
    end

    return winObj
end

local window = CreateWindow("Gatos Windows Control Center", "topbaricon.png")

local targetBox = window:AddTextBox("Target Player:", "Player1", true, function(val, enter)
    print("Target player updated:", val, "Enter pressed:", enter)
end)
targetBox:SetPlaceholder("Enter username...")

local webhookBox = window:AddTextBox("Webhook URL:", "https://discord.com/api/webhooks/demo", false, function(val)
    print("Webhook URL changed:", val)
end)

local aliasBox = window:AddInput("Server IP:", "127.0.0.1", true, function(val)
    print("Server IP alias input:", val)
end)

local portInput = window:AddNumberInput("Port (Default 75px):", 8080, function(val)
    print("Port number changed:", val)
end)

local delayInput = window:AddNumberInput("Interval Delay (ms, 120px):", 250, 120, function(val)
    print("Delay changed:", val)
end)

local stepInput = window:AddNumberInput("Batch Size (UDim2 Sized):", 10, UDim2.new(0, 100, 0, 22), function(val)
    print("Batch size changed:", val)
end)

local speedSlider = window:AddSlider("Walk Speed Multiplier", 16, 250, 32, 2, function(val)
    print("Speed slider:", val)
end)

local fovSlider = window:AddSlider("Camera Field Of View", 50, 120, 70, 1, function(val)
    print("FOV slider:", val)
end)

local volumeSlider = window:AddSlider("Volume Level", 0, 100, 80, 5, function(val)
    print("Volume slider:", val)
end)

local autoFarmToggle = window:AddToggle("Enable Auto-Farm Cycle", true, function(state)
    print("Auto-farm toggle:", state)
end)

local noclipToggle = window:AddToggle("Bypass Collision (Noclip)", false, function(state)
    print("Noclip toggle:", state)
end)

local actionButton = window:AddButton("Execute Operation", function()
    print("Executing Routine with current parameters:")
    print("  Target:", targetBox:Get())
    print("  Webhook:", webhookBox:Get())
    print("  Server IP:", aliasBox:Get())
    print("  Port:", portInput:Get())
    print("  Delay:", delayInput:Get())
    print("  Batch:", stepInput:Get())
    print("  WalkSpeed:", speedSlider:Get())
    print("  FOV:", fovSlider:Get())
    print("  Volume:", volumeSlider:Get())
    print("  AutoFarm:", autoFarmToggle:Get())
    print("  Noclip:", noclipToggle:Get())
end)

local masterLockToggle = window:AddToggle("Master Lock (Disable All)", false, function(locked)
    targetBox:SetDisabled(locked)
    webhookBox:SetDisabled(locked)
    aliasBox:SetDisabled(locked)
    portInput:SetDisabled(locked)
    delayInput:SetDisabled(locked)
    stepInput:SetDisabled(locked)
    speedSlider:SetDisabled(locked)
    fovSlider:SetDisabled(locked)
    volumeSlider:SetDisabled(locked)
    autoFarmToggle:SetDisabled(locked)
    noclipToggle:SetDisabled(locked)
    actionButton:SetDisabled(locked)
    
    if locked then
        actionButton:SetText("Locked (Disabled)")
    else
        actionButton:SetText("Execute Operation")
    end
end)

window:AddButton("Read All Values (Get)", function()
    print("Target Box:", targetBox:Get())
    print("Webhook Box:", webhookBox:Get())
    print("Server IP Box:", aliasBox:Get())
    print("Port Input:", portInput:Get())
    print("Delay Input:", delayInput:Get())
    print("Batch Input:", stepInput:Get())
    print("Speed Slider:", speedSlider:Get())
    print("FOV Slider:", fovSlider:Get())
    print("Volume Slider:", volumeSlider:Get())
    print("Auto-Farm State:", autoFarmToggle:Get())
    print("Noclip State:", noclipToggle:Get())
    print("Action Button Text:", actionButton:GetText())
    print("Master Lock State:", masterLockToggle:Get())
end)

window:AddButton("Randomize Settings (Set)", function()
    if masterLockToggle:Get() then return end
    
    local rPort = math.random(1000, 9999)
    local rDelay = math.random(50, 1000)
    local rBatch = math.random(1, 100)
    local rSpeed = math.random(20, 200)
    local rFov = math.random(60, 110)
    local rVol = math.random(10, 100)
    local rTarget = "Target_" .. tostring(math.random(100, 999))
    local rWebhook = "https://custom.api/hook/" .. tostring(math.random(1000, 9999))
    local rIP = "192.168.1." .. tostring(math.random(2, 254))
    
    portInput:Set(rPort)
    delayInput:Set(rDelay)
    stepInput:Set(rBatch)
    speedSlider:Set(rSpeed)
    fovSlider:Set(rFov)
    volumeSlider:Set(rVol)
    targetBox:Set(rTarget)
    webhookBox:Set(rWebhook)
    aliasBox:Set(rIP)
    autoFarmToggle:Set(math.random(1, 2) == 1)
    noclipToggle:Set(math.random(1, 2) == 1)
    
    actionButton:SetText("Run (" .. rTarget .. ")")
end)

window:AddButton("Clear All Inputs (Clear)", function()
    if masterLockToggle:Get() then return end
    targetBox:Clear()
    webhookBox:Clear()
    aliasBox:Clear()
    portInput:Clear()
    delayInput:Clear()
    stepInput:Clear()
end)

window:AddButton("Mutate Labels & Placeholders", function()
    if masterLockToggle:Get() then return end
    local tag = "(" .. tostring(math.random(10, 99)) .. ")"
    
    targetBox:SetLabel("Player Tag " .. tag .. ":")
    targetBox:SetPlaceholder("e.g. Guest_" .. tag)
    
    webhookBox:SetLabel("Endpoint " .. tag .. ":")
    webhookBox:SetPlaceholder("e.g. /endpoint/" .. tag)
    
    portInput:SetLabel("Port ID " .. tag .. ":")
    portInput:SetPlaceholder(tag)
    
    speedSlider:SetLabel("Velocity " .. tag)
    speedSlider:SetText("Velocity " .. tag)
    
    autoFarmToggle:SetText("Automated System " .. tag)
    actionButton:SetText("Perform Task " .. tag)
end)

window:AddButton("Reconfigure Slider Bounds", function()
    if masterLockToggle:Get() then return end
    speedSlider:SetMin(50)
    speedSlider:SetMax(500)
    speedSlider:SetStep(25)
    speedSlider:Set(250)
end)

window:AddButton("Dynamic Callback Switcher", function()
    actionButton:SetCallback(function()
        print("Dynamic secondary action executed successfully at timestamp:", os.time())
    end)
    print("Action button callback has been dynamically re-assigned")
end)

window:AddButton("Inspect Hierarchy Instances", function()
    print("Window ScreenGui:", window.ScreenGui:GetFullName())
    print("Window Main Frame:", window.Main:GetFullName())
    print("Window Scroll Container:", window.Container:GetFullName())
    print("TargetBox Frame:", targetBox.Instance:GetFullName())
    print("PortInput Frame:", portInput.Instance:GetFullName())
    print("SpeedSlider Frame:", speedSlider.Instance:GetFullName())
    print("AutoFarmToggle Frame:", autoFarmToggle.Instance:GetFullName())
    print("ActionButton Frame:", actionButton.Instance:GetFullName())
end)

window:AddButton("Reset All Factory Defaults", function()
    masterLockToggle:Set(false)
    
    targetBox:SetDisabled(false)
    webhookBox:SetDisabled(false)
    aliasBox:SetDisabled(false)
    portInput:SetDisabled(false)
    delayInput:SetDisabled(false)
    stepInput:SetDisabled(false)
    speedSlider:SetDisabled(false)
    fovSlider:SetDisabled(false)
    volumeSlider:SetDisabled(false)
    autoFarmToggle:SetDisabled(false)
    noclipToggle:SetDisabled(false)
    actionButton:SetDisabled(false)
    
    targetBox:SetLabel("Target Player:")
    targetBox:SetPlaceholder("Enter username...")
    targetBox:Set("Player1")
    
    webhookBox:SetLabel("Webhook URL:")
    webhookBox:Set("https://discord.com/api/webhooks/demo")
    
    aliasBox:SetLabel("Server IP:")
    aliasBox:Set("127.0.0.1")
    
    portInput:SetLabel("Port (Default 75px):")
    portInput:Set(8080)
    
    delayInput:SetLabel("Interval Delay (ms, 120px):")
    delayInput:Set(250)
    
    stepInput:SetLabel("Batch Size (UDim2 Sized):")
    stepInput:Set(10)
    
    speedSlider:SetMin(16)
    speedSlider:SetMax(250)
    speedSlider:SetStep(2)
    speedSlider:SetLabel("Walk Speed Multiplier")
    speedSlider:SetText("Walk Speed Multiplier")
    speedSlider:Set(32)
    
    fovSlider:Set(70)
    volumeSlider:Set(80)
    
    autoFarmToggle:SetText("Enable Auto-Farm Cycle")
    autoFarmToggle:Set(true)
    
    noclipToggle:SetText("Bypass Collision (Noclip)")
    noclipToggle:Set(false)
    
    actionButton:SetText("Execute Operation")
    actionButton:SetCallback(function()
        print("Default execute routine called.")
    end)
end)
