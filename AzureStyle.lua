--[[════════════════════════════════════════════════════════════════════════════
                                AzureStyle Library
        A modern, dark-mode-first UI library for Roblox  ·  accent #0077FF

        ▸ Distinctive sidebar-rail layout with a sliding accent pill
        ▸ Responsive across PC, Tablet and Mobile (mouse / touch / keyboard)
        ▸ Window · Tabs · Sections · Button · Toggle · Slider · Textbox ·
          Dropdown · Keybind · ColorPicker · Label · Paragraph
        ▸ Central Flags registry · Notifications · Config save/load · Theme API

        Usage:
            local Azure = loadstring(game:HttpGet("<url>"))()
            local Window = Azure:CreateWindow({ Title = "AzureStyle" })
            local Tab    = Window:CreateTab({ Name = "Home" })
            local Sec    = Tab:CreateSection("Section")
            Sec:AddToggle({ Text = "Enabled", Flag = "enabled", Callback = print })

        A full, runnable example lives at the very bottom of this file.

        Version 1.0.0  ·  Single-file  ·  MIT-style, free to use & modify
════════════════════════════════════════════════════════════════════════════]]

--═══════════════════════════════════════════════════════════════════════════
-- 1. SERVICES
--═══════════════════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- CurrentCamera can briefly be nil on mobile / early injection — always read it
-- safely so the whole UI never fails to build on a slow client.
local function getViewport()
	local cam = workspace.CurrentCamera
	if cam then
		local ok, vp = pcall(function() return cam.ViewportSize end)
		if ok and vp and vp.X > 0 then return vp end
	end
	return Vector2.new(1280, 720)
end

--═══════════════════════════════════════════════════════════════════════════
-- 2. SMALL UTILITIES (kept Luau-VM-portable: no math.clamp / table.find reliance)
--═══════════════════════════════════════════════════════════════════════════

local function clamp(n, lo, hi)
	if n < lo then return lo end
	if n > hi then return hi end
	return n
end

local function round(n, decimals)
	local m = 10 ^ (decimals or 0)
	return math.floor(n * m + 0.5) / m
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function indexOf(t, value)
	for i = 1, #t do
		if t[i] == value then return i end
	end
	return nil
end

local function randomString(len)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local out = table.create and table.create(len) or {}
	for i = 1, len do
		local idx = math.random(1, #chars)
		out[i] = string.sub(chars, idx, idx)
	end
	return table.concat(out)
end

-- Connection registry: every object owns a list it disconnects on :Destroy().
local function track(conns, conn)
	conns[#conns + 1] = conn
	return conn
end

local function cleanup(conns)
	for i = #conns, 1, -1 do
		local c = conns[i]
		if c then pcall(function() c:Disconnect() end) end
		conns[i] = nil
	end
end

--═══════════════════════════════════════════════════════════════════════════
-- 3. THEME (dark default · accent #0077FF)
--═══════════════════════════════════════════════════════════════════════════

local Theme = {
	Accent       = Color3.fromRGB(0, 119, 255),   -- #0077FF
	AccentDim    = Color3.fromRGB(0, 92, 199),
	AccentSoft   = Color3.fromRGB(20, 60, 120),    -- pill fill (sits over surface)
	OnAccent     = Color3.fromRGB(255, 255, 255),

	Background   = Color3.fromRGB(11, 14, 20),     -- deepest (window base)
	Surface      = Color3.fromRGB(18, 22, 31),     -- panels / sidebar
	Surface2     = Color3.fromRGB(23, 28, 39),     -- content backdrop
	Elevated     = Color3.fromRGB(29, 35, 48),     -- control rows
	Hover        = Color3.fromRGB(37, 44, 60),
	Stroke       = Color3.fromRGB(40, 47, 62),

	Text         = Color3.fromRGB(237, 240, 245),
	SubText      = Color3.fromRGB(150, 158, 172),
	Placeholder  = Color3.fromRGB(96, 104, 120),

	Success      = Color3.fromRGB(54, 201, 122),
	Warning      = Color3.fromRGB(240, 188, 64),
	Error        = Color3.fromRGB(232, 86, 86),

	Font         = Enum.Font.Gotham,
	FontMedium   = Enum.Font.GothamMedium,
	FontBold     = Enum.Font.GothamBold,
}

-- Re-paintable instances so the Theme/Accent API can re-skin live.
local themeRegistry = {}

local function paint(inst, prop, token)
	inst[prop] = Theme[token]
	themeRegistry[#themeRegistry + 1] = { inst = inst, prop = prop, token = token }
	return inst
end

--═══════════════════════════════════════════════════════════════════════════
-- 4. TWEEN + INSTANCE FACTORY + DECORATORS
--═══════════════════════════════════════════════════════════════════════════

local EASE = Enum.EasingStyle.Quint
local DIR  = Enum.EasingDirection.Out

local function Tween(inst, props, time, style, dir)
	local info = TweenInfo.new(time or 0.18, style or EASE, dir or DIR)
	local tw = TweenService:Create(inst, info, props)
	tw:Play()
	return tw
end

-- Create(class, props, children) — applies props (Parent set last for perf).
local function Create(class, props, children)
	local inst = Instance.new(class)
	if props then
		local parent = props.Parent
		props.Parent = nil
		for k, v in pairs(props) do
			inst[k] = v
		end
		if children then
			for i = 1, #children do
				children[i].Parent = inst
			end
		end
		if parent then inst.Parent = parent end
		props.Parent = parent
	elseif children then
		for i = 1, #children do
			children[i].Parent = inst
		end
	end
	return inst
end

local function corner(radius)
	return Create("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function stroke(color, thickness, transparency)
	return Create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(t, r, b, l)
	if r == nil then r = t end
	if b == nil then b = t end
	if l == nil then l = r end
	return Create("UIPadding", {
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft = UDim.new(0, l or 0),
	})
end

local function vlist(gap, align)
	return Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, gap or 8),
	})
end

-- Soft drop shadow behind a panel (graceful: if asset fails to load, nothing breaks).
local function shadow(parent, transparency)
	return Create("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = transparency or 0.45,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Size = UDim2.new(1, 60, 1, 60),
		Position = UDim2.new(0, -30, 0, -22),
		ZIndex = 0,
		Parent = parent,
	})
end

--── Vector icons drawn from Frames ──────────────────────────────────────────
-- These never depend on a font glyph or an uploaded image, so they render
-- identically on PC, console and every mobile device / executor.
local function iconBar(parent, w, h, color, rot, px, py)
	return Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(px or 0.5, 0, py or 0.5, 0),
		Size = UDim2.new(0, w, 0, h),
		BackgroundColor3 = color or Theme.SubText,
		BorderSizePixel = 0, Rotation = rot or 0, ZIndex = 3,
		Parent = parent,
	}, { corner(math.max(1, math.floor(h / 2))) })
end

-- "✕" close icon (two crossed bars).
local function iconCross(parent, size, color, thickness)
	size = size or 12; thickness = thickness or 2
	local holder = Create("Frame", {
		Name = "Icon", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, size, 0, size), ZIndex = 3, Parent = parent,
	})
	local a = iconBar(holder, size, thickness, color, 45)
	local b = iconBar(holder, size, thickness, color, -45)
	return holder, { a, b }
end

-- "—" minimize icon (single bar).
local function iconMinus(parent, size, color, thickness)
	size = size or 12; thickness = thickness or 2
	local holder = Create("Frame", {
		Name = "Icon", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, size, 0, size), ZIndex = 3, Parent = parent,
	})
	local bar = iconBar(holder, size, thickness, color, 0)
	return holder, { bar }
end

-- "▢" restore icon (small square outline).
local function iconSquare(parent, size, color, thickness)
	size = size or 11; thickness = thickness or 2
	local holder = Create("Frame", {
		Name = "Icon", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, size, 0, size),
		BackgroundColor3 = color or Theme.SubText, BackgroundTransparency = 1, ZIndex = 3, Parent = parent,
	}, { corner(3), Create("UIStroke", { Color = color or Theme.SubText, Thickness = thickness }) })
	return holder, {}
end

-- "⌄" downward chevron (two bars meeting at a point); rotate holder to flip.
local function iconChevron(parent, size, color, thickness)
	size = size or 10; thickness = thickness or 2
	local holder = Create("Frame", {
		Name = "Chevron", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, size, 0, size * 0.6), ZIndex = 3, Parent = parent,
	})
	local len = size * 0.72
	iconBar(holder, len, thickness, color, 45, 0.27, 0.5)   -- "\"
	iconBar(holder, len, thickness, color, -45, 0.73, 0.5)  -- "/"
	return holder
end

-- Resolve an icon spec to a usable rbxassetid string (number or string accepted).
local function resolveAsset(icon)
	if not icon then return nil end
	if type(icon) == "number" then return "rbxassetid://" .. icon end
	local s = tostring(icon)
	if s:match("^%d+$") then return "rbxassetid://" .. s end
	return s
end

--═══════════════════════════════════════════════════════════════════════════
-- 5. DEVICE / RESPONSIVE
--═══════════════════════════════════════════════════════════════════════════

local Device = {}
local resizeSubs = {}

function Device.refresh()
	local vp = getViewport()
	Device.viewport = vp
	Device.touch    = UserInputService.TouchEnabled
	Device.mouse    = UserInputService.MouseEnabled
	Device.keyboard = UserInputService.KeyboardEnabled
	-- TouchEnabled/KeyboardEnabled describe *input*, not device — combine with size.
	Device.mobile   = (Device.touch and not Device.mouse) or vp.X < 720
	Device.rowH     = Device.mobile and 44 or 36   -- ≥44px touch targets on mobile
	Device.textSize = Device.mobile and 15 or 14
	Device.sidebarW = Device.mobile and 116 or 156
end

Device.refresh()

-- Debounced viewport listener that also survives the CurrentCamera being
-- swapped or arriving late (common on mobile).
do
	local pending = false
	local function onChange()
		if pending then return end
		pending = true
		task.defer(function()
			pending = false
			Device.refresh()
			for i = 1, #resizeSubs do
				pcall(resizeSubs[i])
			end
		end)
	end
	local function bindCamera()
		local cam = workspace.CurrentCamera
		if cam then
			pcall(function() cam:GetPropertyChangedSignal("ViewportSize"):Connect(onChange) end)
		end
		onChange()
	end
	pcall(function() workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera) end)
	bindCamera()
end

local function onResize(fn)
	resizeSubs[#resizeSubs + 1] = fn
end

--═══════════════════════════════════════════════════════════════════════════
-- 6. INTERACTION HELPERS  (mouse + touch + keyboard, unified)
--═══════════════════════════════════════════════════════════════════════════

local function isPrimaryDown(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

-- Hover transitions only bound when a mouse exists (skipped on pure-touch).
local function addHover(conns, inst, hoverProps, normalProps)
	if not UserInputService.MouseEnabled then return end
	track(conns, inst.MouseEnter:Connect(function() Tween(inst, hoverProps, 0.15) end))
	track(conns, inst.MouseLeave:Connect(function() Tween(inst, normalProps, 0.15) end))
end

-- Subtle scale-pop on press (works for mouse and touch).
local function addPress(conns, button)
	local sc = Create("UIScale", { Scale = 1, Parent = button })
	local function down() Tween(sc, { Scale = 0.96 }, 0.08) end
	local function up() Tween(sc, { Scale = 1 }, 0.16, Enum.EasingStyle.Back) end
	track(conns, button.MouseButton1Down:Connect(down))
	track(conns, button.MouseButton1Up:Connect(up))
	track(conns, button.MouseLeave:Connect(up))
	track(conns, button.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then down() end end))
	track(conns, button.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then up() end end))
end

-- Drag a target frame by a handle (mouse + touch). Position stored as UDim2 offset.
-- Optional clampFn(scaleX, offX, scaleY, offY) -> offX, offY keeps it on-screen.
local function makeDraggable(conns, handle, target, clampFn)
	local dragging, startInput, startPos = false, nil, nil
	track(conns, handle.InputBegan:Connect(function(input)
		if isPrimaryDown(input) then
			dragging, startInput, startPos = true, input.Position, target.Position
		end
	end))
	track(conns, UserInputService.InputChanged:Connect(function(input)
		if dragging and isMove(input) then
			local d = input.Position - startInput
			local ox, oy = startPos.X.Offset + d.X, startPos.Y.Offset + d.Y
			if clampFn then ox, oy = clampFn(startPos.X.Scale, ox, startPos.Y.Scale, oy) end
			target.Position = UDim2.new(startPos.X.Scale, ox, startPos.Y.Scale, oy)
		end
	end))
	track(conns, UserInputService.InputEnded:Connect(function(input)
		if isPrimaryDown(input) then dragging = false end
	end))
end

-- Normalised drag over an area → onMove(ax, ay) in 0..1 (sliders, color picker).
local function bindAreaDrag(conns, area, onMove)
	local dragging = false
	local function update(input)
		local ap, sz = area.AbsolutePosition, area.AbsoluteSize
		local ax = sz.X > 0 and clamp((input.Position.X - ap.X) / sz.X, 0, 1) or 0
		local ay = sz.Y > 0 and clamp((input.Position.Y - ap.Y) / sz.Y, 0, 1) or 0
		onMove(ax, ay)
	end
	track(conns, area.InputBegan:Connect(function(input)
		if isPrimaryDown(input) then dragging = true; update(input) end
	end))
	track(conns, UserInputService.InputChanged:Connect(function(input)
		if dragging and isMove(input) then update(input) end
	end))
	track(conns, UserInputService.InputEnded:Connect(function(input)
		if isPrimaryDown(input) then dragging = false end
	end))
end

--═══════════════════════════════════════════════════════════════════════════
-- 7. MOUNTING  (gethui → protect/CoreGui → PlayerGui)
--═══════════════════════════════════════════════════════════════════════════

local function getMountParent()
	local ok, hidden = pcall(function()
		if typeof(gethui) == "function" then return gethui() end
		return nil
	end)
	if ok and hidden then return hidden, false end

	ok, hidden = pcall(function()
		local f = (getgenv and getgenv().get_hidden_gui) or get_hidden_gui
		if typeof(f) == "function" then return f() end
		return nil
	end)
	if ok and hidden then return hidden, false end

	-- CoreGui (needs protection so the GUI survives / hides from scripts).
	local okc, cg = pcall(function() return CoreGui end)
	if okc and cg then return cg, true end

	-- Studio / non-executor fallback.
	local okp, pg = pcall(function()
		return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
	end)
	if okp and pg then return pg, false end

	return CoreGui, true
end

local function protectGui(gui)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif typeof(protectgui) == "function" then
			protectgui(gui)
		elseif typeof(getgenv) == "function" and getgenv().protect_gui then
			getgenv().protect_gui(gui)
		end
	end)
end

local function mountGui()
	local parent, needsProtect = getMountParent()

	-- Remove any previous AzureStyle root (re-injection guard).
	pcall(function()
		for _, child in ipairs(parent:GetChildren()) do
			if child:GetAttribute("AzureStyleRoot") then
				child:Destroy()
			end
		end
	end)

	local gui = Create("ScreenGui", {
		Name = randomString(12),
		ResetOnSpawn = false,
		DisplayOrder = 1000000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function() gui:SetAttribute("AzureStyleRoot", true) end)
	-- ScreenInsets keeps the UI clear of the mobile notch / Roblox topbar.
	-- (Do NOT also set IgnoreGuiInset — the two conflict and break mobile layout.)
	pcall(function() gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)

	if needsProtect then protectGui(gui) end
	gui.Parent = parent
	return gui
end

--═══════════════════════════════════════════════════════════════════════════
-- 8. LIBRARY ROOT
--═══════════════════════════════════════════════════════════════════════════

local Library = {}
Library.__index = Library
Library.Version  = "1.0.0"
Library.Flags    = {}     -- flag -> current value  (read this for automation)
Library.Theme    = Theme
Library._flagged = {}     -- flag -> { api, encode, decode }
Library._windows = {}
Library._conns   = {}     -- global connections (toggle key, etc.)

local ScreenGui = mountGui()
Library.ScreenGui = ScreenGui

-- Notification holder (top-right, independent of any window). Width adapts so it
-- never overflows a small phone screen.
local function notifWidth()
	return math.floor(clamp(getViewport().X - 32, 240, 320))
end
local notifHolder = Create("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -16, 0, 16),
	Size = UDim2.new(0, notifWidth(), 1, -32),
	ZIndex = 50,
	Parent = ScreenGui,
}, {
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 8),
	}),
})
onResize(function() notifHolder.Size = UDim2.new(0, notifWidth(), 1, -32) end)

--═══════════════════════════════════════════════════════════════════════════
-- 9. FLAGS + COMMON CONTROL METHODS
--═══════════════════════════════════════════════════════════════════════════

local function registerFlag(api, flag, encode, decode)
	if not flag then return end
	Library._flagged[flag] = { api = api, encode = encode, decode = decode }
end

-- Attaches the shared method surface every control exposes.
-- state = { conns, callback, disabled, root, cover }
local function attachCommon(api, root, state)
	state.conns = state.conns or {}

	-- A cover that absorbs input + dims when disabled.
	local cover = Create("TextButton", {
		Name = "DisabledCover",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 30,
		Active = true,
		Parent = root,
	}, { corner(6) })
	state.cover = cover

	function api:SetVisible(v)
		root.Visible = v and true or false
		return api
	end
	function api:GetVisible()
		return root.Visible
	end
	function api:SetCallback(fn)
		state.callback = fn
		return api
	end
	function api:Disable()
		state.disabled = true
		cover.Visible = true
		Tween(cover, { BackgroundTransparency = 0.5 }, 0.15)
		return api
	end
	function api:Enable()
		state.disabled = false
		Tween(cover, { BackgroundTransparency = 1 }, 0.15)
		task.delay(0.16, function()
			if state.disabled == false then cover.Visible = false end
		end)
		return api
	end
	function api:Destroy()
		cleanup(state.conns)
		if state.flag then Library._flagged[state.flag] = nil end
		pcall(function() root:Destroy() end)
	end

	api.Instance = root
	return api
end

-- Pushes a value into the Flags table and fires callback + OnChanged.
local function fireChange(state, value)
	state.value = value
	if state.flag then Library.Flags[state.flag] = value end
	if state.callback then
		task.spawn(function()
			local ok, err = pcall(state.callback, value)
			if not ok then warn("[AzureStyle] callback error: " .. tostring(err)) end
		end)
	end
	if state.onChanged then pcall(state.onChanged, value) end
end

--═══════════════════════════════════════════════════════════════════════════
-- 10. NOTIFICATIONS
--═══════════════════════════════════════════════════════════════════════════

local typeColors = {
	Info = Theme.Accent, Success = Theme.Success,
	Warning = Theme.Warning, Error = Theme.Error,
}

function Library:Notify(opts)
	opts = opts or {}
	local duration = opts.Duration or 4
	local accent = typeColors[opts.Type or "Info"] or Theme.Accent

	-- Outer is positioned by the holder's UIListLayout; its height auto-fits the
	-- inner card. We slide the INNER frame horizontally (the outer's Y is owned by
	-- the layout, so animating the inner avoids fighting it — and no CanvasGroup,
	-- which is unreliable with AutomaticSize on real devices).
	local outer = Create("Frame", {
		Name = "Notification", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 51,
	})
	local card = Create("Frame", {
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(1, 12, 0, 0), -- start just off the right edge
		ZIndex = 51, Parent = outer,
	}, {
		corner(8), stroke(Theme.Stroke, 1, 0.2),
		padding(11, 13, 11, 16),
		Create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	Create("Frame", { -- accent edge
		BackgroundColor3 = accent, BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, -16), Position = UDim2.new(0, 5, 0, 8), ZIndex = 52, Parent = card,
	}, { corner(2) })

	Create("TextLabel", {
		BackgroundTransparency = 1, LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.Y,
		Font = Theme.FontBold, Text = opts.Title or "Notification",
		TextColor3 = Theme.Text, TextSize = Device.textSize,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 52, Parent = card,
	})
	if opts.Content then
		Create("TextLabel", {
			BackgroundTransparency = 1, LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Font = Theme.Font, Text = opts.Content,
			TextColor3 = Theme.SubText, TextSize = Device.textSize - 1,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 52, Parent = card,
		})
	end
	local bar = Create("Frame", {
		BackgroundColor3 = accent, BorderSizePixel = 0, LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 6), ZIndex = 52, Parent = card,
	}, { corner(2) })

	outer.Parent = notifHolder

	-- Slide in + progress bar drain.
	Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Quint)
	Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

	local dismissed = false
	local function dismiss()
		if dismissed then return end
		dismissed = true
		Tween(card, { Position = UDim2.new(1, 16, 0, 0) }, 0.22)
		task.delay(0.24, function() pcall(function() outer:Destroy() end) end)
	end
	task.delay(duration, dismiss)
	return { Dismiss = dismiss, Instance = outer }
end

--═══════════════════════════════════════════════════════════════════════════
-- 11. CONTROL BUILDERS  (used by Section)
--═══════════════════════════════════════════════════════════════════════════

-- Standard "label + control on the right" row.
local function baseRow(parent, order, text, height)
	local row = Create("Frame", {
		BackgroundColor3 = Theme.Elevated, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height or Device.rowH),
		LayoutOrder = order,
	}, { corner(6), stroke(Theme.Stroke, 1, 0.45), padding(0, 12, 0, 12) })
	local label = Create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -86, 1, 0),
		Font = Theme.Font, Text = text or "", TextColor3 = Theme.Text,
		TextSize = Device.textSize, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	row.Parent = parent
	return row, label
end

local Controls = {}

-- ── BUTTON ──────────────────────────────────────────────────────────────
function Controls.Button(section, opts)
	local state = { conns = {}, callback = opts.Callback }
	local btn = Create("TextButton", {
		BackgroundColor3 = Theme.Elevated, BorderSizePixel = 0, AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, Device.rowH), LayoutOrder = section:_next(),
		Font = Theme.FontMedium, Text = opts.Text or "Button",
		TextColor3 = Theme.Text, TextSize = Device.textSize,
	}, { corner(6), stroke(Theme.Stroke, 1, 0.4) })
	-- accent ghost that flashes on click
	local flash = Create("Frame", {
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0), ZIndex = 2, Parent = btn,
	}, { corner(6) })
	paint(flash, "BackgroundColor3", "Accent")
	btn.Parent = section.body

	addHover(state.conns, btn, { BackgroundColor3 = Theme.Hover }, { BackgroundColor3 = Theme.Elevated })
	addPress(state.conns, btn)

	track(state.conns, btn.MouseButton1Click:Connect(function()
		if state.disabled then return end
		flash.BackgroundTransparency = 0.7
		Tween(flash, { BackgroundTransparency = 1 }, 0.4)
		if state.callback then
			task.spawn(function()
				local ok, err = pcall(state.callback)
				if not ok then warn("[AzureStyle] button error: " .. tostring(err)) end
			end)
		end
	end))

	local api = {}
	attachCommon(api, btn, state)
	function api:SetText(t) btn.Text = t; return api end
	function api:GetText() return btn.Text end
	function api:Fire() if state.callback then task.spawn(state.callback) end; return api end
	return api
end

-- ── TOGGLE ──────────────────────────────────────────────────────────────
function Controls.Toggle(section, opts)
	local state = { conns = {}, callback = opts.Callback, flag = opts.Flag, value = opts.Default and true or false }
	local row, label = baseRow(section.body, section:_next(), opts.Text or "Toggle")

	local switch = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 42, 0, 22), BackgroundColor3 = Theme.Surface,
		AutoButtonColor = false, Text = "", BorderSizePixel = 0, Parent = row,
	}, { corner(11), stroke(Theme.Stroke, 1, 0.2) })
	local knob = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Theme.SubText,
		BorderSizePixel = 0, Parent = switch,
	}, { corner(8) })

	local function render(animate)
		local on = state.value
		local t = animate and 0.18 or 0
		Tween(switch, { BackgroundColor3 = on and Theme.Accent or Theme.Surface }, t)
		Tween(knob, {
			Position = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = on and Theme.OnAccent or Theme.SubText,
		}, t)
	end
	render(false)

	local function set(v, fire)
		state.value = v and true or false
		render(true)
		if fire ~= false then fireChange(state, state.value) end
	end

	track(state.conns, switch.MouseButton1Click:Connect(function()
		if state.disabled then return end
		set(not state.value, true)
	end))
	addPress(state.conns, switch)

	local api = {}
	state.api = api
	attachCommon(api, row, state)
	state.flag = opts.Flag
	function api:SetValue(v) set(v, true); return api end
	function api:GetValue() return state.value end
	function api:Toggle() set(not state.value, true); return api end
	function api:SetText(t) label.Text = t; return api end
	registerFlag(api, opts.Flag)
	if opts.Flag then Library.Flags[opts.Flag] = state.value end
	return api
end

-- ── SLIDER ──────────────────────────────────────────────────────────────
function Controls.Slider(section, opts)
	local minV, maxV = opts.Min or 0, opts.Max or 100
	local decimals = opts.Decimals or 0
	local suffix = opts.Suffix or ""
	local state = { conns = {}, callback = opts.Callback, flag = opts.Flag }
	state.value = clamp(opts.Default or minV, minV, maxV)

	local row = Create("Frame", {
		BackgroundColor3 = Theme.Elevated, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Device.mobile and 58 or 50), LayoutOrder = section:_next(),
	}, { corner(6), stroke(Theme.Stroke, 1, 0.45), padding(8, 12, 8, 12) })
	row.Parent = section.body

	local label = Create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 16),
		Font = Theme.Font, Text = opts.Text or "Slider", TextColor3 = Theme.Text,
		TextSize = Device.textSize, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	local valueLabel = Create("TextLabel", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 60, 0, 16),
		Font = Theme.FontMedium, Text = "", TextColor3 = Theme.Accent,
		TextSize = Device.textSize, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
	})
	paint(valueLabel, "TextColor3", "Accent")

	-- Active=true makes the track sink touch input so dragging it slides the value
	-- instead of scrolling the page on mobile. A taller invisible hit-area improves
	-- touch accuracy without changing the visible 6px bar.
	local hit = Create("TextButton", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 2),
		Size = UDim2.new(1, 0, 0, Device.mobile and 26 or 16), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Active = true, Parent = row,
	})
	local bar = Create("Frame", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Parent = row,
	}, { corner(3) })
	local fill = Create("Frame", {
		Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = bar,
	}, { corner(3) })
	paint(fill, "BackgroundColor3", "Accent")
	local knob = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Theme.OnAccent, BorderSizePixel = 0,
		ZIndex = 3, Parent = bar,
	}, { corner(6), stroke(Theme.Accent, 2, 0) })

	local function render(animate)
		local alpha = (maxV - minV) == 0 and 0 or (state.value - minV) / (maxV - minV)
		local t = animate and 0.12 or 0
		Tween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, t)
		Tween(knob, { Position = UDim2.new(alpha, 0, 0.5, 0) }, t)
		valueLabel.Text = tostring(round(state.value, decimals)) .. suffix
	end
	render(false)

	local function setAlpha(alpha, fire)
		local v = clamp(round(minV + (maxV - minV) * clamp(alpha, 0, 1), decimals), minV, maxV)
		local changed = v ~= state.value
		state.value = v
		render(true)
		if fire ~= false and changed then fireChange(state, v) end
	end

	-- Drive from the larger invisible hit-area (its X extent matches the bar).
	bindAreaDrag(state.conns, hit, function(ax)
		if state.disabled then return end
		setAlpha(ax, true)
	end)
	track(state.conns, hit.InputBegan:Connect(function(i)
		if isPrimaryDown(i) then Tween(knob, { Size = UDim2.new(0, 16, 0, 16) }, 0.1) end
	end))
	track(state.conns, UserInputService.InputEnded:Connect(function(i)
		if isPrimaryDown(i) then Tween(knob, { Size = UDim2.new(0, 12, 0, 12) }, 0.1) end
	end))

	local api = {}
	state.api = api
	attachCommon(api, row, state)
	function api:SetValue(v) setAlpha((clamp(v, minV, maxV) - minV) / ((maxV - minV) == 0 and 1 or (maxV - minV)), true); return api end
	function api:GetValue() return state.value end
	function api:SetMin(v) minV = v; if state.value < minV then state.value = minV end; render(true); return api end
	function api:SetMax(v) maxV = v; if state.value > maxV then state.value = maxV end; render(true); return api end
	function api:SetText(t) label.Text = t; return api end
	registerFlag(api, opts.Flag)
	if opts.Flag then Library.Flags[opts.Flag] = state.value end
	return api
end

-- ── TEXTBOX ─────────────────────────────────────────────────────────────
function Controls.Textbox(section, opts)
	local state = { conns = {}, callback = opts.Callback, flag = opts.Flag, value = opts.Default or "" }
	local row, label = baseRow(section.body, section:_next(), opts.Text or "Textbox")
	label.Size = UDim2.new(0.42, 0, 1, 0)

	local holder = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0.55, 0, 0, Device.mobile and 30 or 24),
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Parent = row,
	}, { corner(5), stroke(Theme.Stroke, 1, 0.2), padding(0, 8, 0, 8) })
	local box = Create("TextBox", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.Font, Text = state.value, PlaceholderText = opts.Placeholder or "...",
		PlaceholderColor3 = Theme.Placeholder, TextColor3 = Theme.Text,
		TextSize = Device.textSize - 1, TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, ClipsDescendants = true, Parent = holder,
	})
	local focusStroke = holder:FindFirstChildOfClass("UIStroke")

	track(state.conns, box.Focused:Connect(function()
		if focusStroke then Tween(focusStroke, { Color = Theme.Accent, Transparency = 0 }, 0.15) end
	end))
	track(state.conns, box.FocusLost:Connect(function(enter)
		if focusStroke then Tween(focusStroke, { Color = Theme.Stroke, Transparency = 0.2 }, 0.15) end
		local text = box.Text
		if opts.Numeric then
			local n = tonumber(text)
			if n == nil then box.Text = tostring(state.value); return end
			text = tostring(n)
			box.Text = text
		end
		state.value = text
		if state.flag then Library.Flags[state.flag] = text end
		if state.callback then
			task.spawn(function() pcall(state.callback, text, enter) end)
		end
		if state.onChanged then pcall(state.onChanged, text) end
	end))

	local api = {}
	state.api = api
	attachCommon(api, row, state)
	function api:SetText(t) box.Text = tostring(t); state.value = box.Text; if state.flag then Library.Flags[state.flag] = state.value end; return api end
	function api:GetText() return box.Text end
	function api:SetValue(t) return api:SetText(t) end
	function api:GetValue() return box.Text end
	function api:Focus() pcall(function() box:CaptureFocus() end); return api end
	registerFlag(api, opts.Flag)
	if opts.Flag then Library.Flags[opts.Flag] = state.value end
	return api
end

-- ── DROPDOWN (single or multi, inline expand) ─────────────────────────────
function Controls.Dropdown(section, opts)
	local multi = opts.Multi and true or false
	local state = { conns = {}, callback = opts.Callback, flag = opts.Flag, options = {} }
	for i = 1, #(opts.Options or {}) do state.options[i] = opts.Options[i] end
	state.selected = multi and {} or (opts.Default or state.options[1])
	if multi and type(opts.Default) == "table" then
		for _, v in ipairs(opts.Default) do state.selected[v] = true end
	end

	local container = Create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Device.rowH),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = section:_next(),
		ClipsDescendants = true, Parent = section.body,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local header = Create("TextButton", {
		BackgroundColor3 = Theme.Elevated, BorderSizePixel = 0, AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, Device.rowH), Text = "", LayoutOrder = 1, Parent = container,
	}, { corner(6), stroke(Theme.Stroke, 1, 0.45), padding(0, 12, 0, 12) })
	Create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
		Font = Theme.Font, Text = opts.Text or "Dropdown", TextColor3 = Theme.Text,
		TextSize = Device.textSize, TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
	})
	local valueText = Create("TextLabel", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -18, 0.5, 0), Size = UDim2.new(0.5, -8, 1, 0),
		Font = Theme.FontMedium, Text = "", TextColor3 = Theme.SubText,
		TextSize = Device.textSize - 1, TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
	})
	local arrow = Create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 14, 0, 14), Parent = header,
	})
	local arrowIcon = iconChevron(arrow, 10, Theme.SubText, 2)

	local listFrame = Create("Frame", {
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2, Visible = false, Parent = container,
	}, { corner(6), stroke(Theme.Stroke, 1, 0.3), padding(4), vlist(3, Enum.HorizontalAlignment.Center) })

	local function displayText()
		if multi then
			local list = {}
			for _, opt in ipairs(state.options) do
				if state.selected[opt] then list[#list + 1] = opt end
			end
			if #list == 0 then return "None" end
			return table.concat(list, ", ")
		end
		return tostring(state.selected or "None")
	end

	local optionButtons = {}
	local function rebuild()
		for _, b in ipairs(optionButtons) do b:Destroy() end
		optionButtons = {}
		for i, opt in ipairs(state.options) do
			local isSel = multi and state.selected[opt] or (state.selected == opt)
			local ob = Create("TextButton", {
				BackgroundColor3 = isSel and Theme.AccentSoft or Theme.Elevated,
				BorderSizePixel = 0, AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, Device.mobile and 36 or 28),
				Font = Theme.Font, Text = "  " .. tostring(opt),
				TextColor3 = isSel and Theme.Accent or Theme.SubText,
				TextSize = Device.textSize - 1, TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = i, Parent = listFrame,
			}, { corner(5) })
			optionButtons[i] = ob
			addHover(state.conns, ob, { BackgroundColor3 = Theme.Hover }, { BackgroundColor3 = (multi and state.selected[opt] or state.selected == opt) and Theme.AccentSoft or Theme.Elevated })
			track(state.conns, ob.MouseButton1Click:Connect(function()
				if state.disabled then return end
				if multi then
					state.selected[opt] = not state.selected[opt] or nil
				else
					state.selected = opt
					state.open = false
					Tween(arrow, { Rotation = 0 }, 0.2)
					listFrame.Visible = false
				end
				rebuild()
				valueText.Text = displayText()
				local out = multi and (function()
					local t = {}
					for _, o in ipairs(state.options) do if state.selected[o] then t[#t + 1] = o end end
					return t
				end)() or state.selected
				fireChange(state, out)
			end))
		end
	end
	valueText.Text = displayText()
	rebuild()

	state.open = false
	local function toggleOpen()
		state.open = not state.open
		listFrame.Visible = state.open
		Tween(arrow, { Rotation = state.open and 180 or 0 }, 0.2)
	end

	track(state.conns, header.MouseButton1Click:Connect(function()
		if state.disabled then return end
		toggleOpen()
	end))
	addHover(state.conns, header, { BackgroundColor3 = Theme.Hover }, { BackgroundColor3 = Theme.Elevated })

	local api = {}
	state.api = api
	attachCommon(api, container, state)
	function api:GetValue()
		if multi then
			local t = {}
			for _, o in ipairs(state.options) do if state.selected[o] then t[#t + 1] = o end end
			return t
		end
		return state.selected
	end
	function api:SetValue(v)
		if multi then
			state.selected = {}
			if type(v) == "table" then for _, o in ipairs(v) do state.selected[o] = true end end
		else
			state.selected = v
		end
		rebuild(); valueText.Text = displayText(); fireChange(state, api:GetValue())
		return api
	end
	function api:SetOptions(list)
		state.options = {}
		for i = 1, #list do state.options[i] = list[i] end
		local changed = false
		if multi then
			for k in pairs(state.selected) do
				if indexOf(state.options, k) == nil then state.selected[k] = nil; changed = true end
			end
		elseif indexOf(state.options, state.selected) == nil then
			state.selected = state.options[1]; changed = true
		end
		rebuild(); valueText.Text = displayText()
		-- keep the Flags registry in sync (and notify only if the value actually changed)
		if changed then fireChange(state, api:GetValue())
		elseif state.flag then Library.Flags[state.flag] = api:GetValue() end
		return api
	end
	function api:AddOption(opt)
		if indexOf(state.options, opt) == nil then state.options[#state.options + 1] = opt; rebuild() end
		return api
	end
	function api:RemoveOption(opt)
		local i = indexOf(state.options, opt)
		if not i then return api end
		table.remove(state.options, i)
		local changed = false
		if multi then
			if state.selected[opt] then state.selected[opt] = nil; changed = true end
		elseif state.selected == opt then
			state.selected = state.options[1]; changed = true
		end
		rebuild(); valueText.Text = displayText()
		if changed then fireChange(state, api:GetValue()) end
		return api
	end
	function api:Open() if not state.open then toggleOpen() end; return api end
	function api:Close() if state.open then toggleOpen() end; return api end
	registerFlag(api, opts.Flag)
	if opts.Flag then Library.Flags[opts.Flag] = api:GetValue() end
	return api
end

-- ── KEYBIND ──────────────────────────────────────────────────────────────
function Controls.Keybind(section, opts)
	local state = { conns = {}, callback = opts.Callback, flag = opts.Flag, capturing = false }
	state.key = opts.Default or Enum.KeyCode.Unknown
	local row, label = baseRow(section.body, section:_next(), opts.Text or "Keybind")

	local function keyName(k)
		if k == nil or k == Enum.KeyCode.Unknown then return "None" end
		return k.Name
	end

	local bindBtn = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 76, 0, Device.mobile and 30 or 24), AutoButtonColor = false,
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
		Font = Theme.FontMedium, Text = keyName(state.key), TextColor3 = Theme.SubText,
		TextSize = Device.textSize - 1, Parent = row,
	}, { corner(5), stroke(Theme.Stroke, 1, 0.2) })

	local function render()
		bindBtn.Text = state.capturing and "..." or keyName(state.key)
		bindBtn.TextColor3 = (state.capturing or state.key ~= Enum.KeyCode.Unknown) and Theme.Accent or Theme.SubText
	end
	render()

	track(state.conns, bindBtn.MouseButton1Click:Connect(function()
		if state.disabled then return end
		state.capturing = true
		render()
	end))

	track(state.conns, UserInputService.InputBegan:Connect(function(input, gpe)
		if state.capturing then
			local key
			if input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3 then
				key = input.UserInputType
			end
			if key then
				if key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Escape then
					state.key = Enum.KeyCode.Unknown
				else
					state.key = key
				end
				state.capturing = false
				render()
				if state.flag then Library.Flags[state.flag] = state.key end
				if state.onChanged then pcall(state.onChanged, state.key) end
			end
			return
		end
		if gpe then return end
		if state.disabled or state.key == Enum.KeyCode.Unknown then return end
		local hit = (input.KeyCode == state.key) or (input.UserInputType == state.key)
		if hit and state.callback then
			task.spawn(function() pcall(state.callback, state.key) end)
		end
	end))

	local api = {}
	state.api = api
	attachCommon(api, row, state)
	function api:SetKey(k) state.key = k or Enum.KeyCode.Unknown; render(); if state.flag then Library.Flags[state.flag] = state.key end; return api end
	function api:GetKey() return state.key end
	function api:SetValue(k) return api:SetKey(k) end
	function api:GetValue() return state.key end
	function api:OnClick(fn) state.callback = fn; return api end
	function api:SetText(t) label.Text = t; return api end
	registerFlag(api, opts.Flag,
		function(v) return v and v ~= Enum.KeyCode.Unknown and { __t = "Key", name = v.Name, kind = (v.EnumType == Enum.UserInputType) and "UserInputType" or "KeyCode" } or false end,
		function(d) if type(d) == "table" and d.__t == "Key" then local ok, e = pcall(function() return Enum[d.kind][d.name] end); if ok then return e end end; return Enum.KeyCode.Unknown end)
	if opts.Flag then Library.Flags[opts.Flag] = state.key end
	return api
end

-- ── COLOR PICKER (inline expand · HSV) ─────────────────────────────────────
function Controls.ColorPicker(section, opts)
	local state = { conns = {}, callback = opts.Callback, flag = opts.Flag }
	state.color = opts.Default or Theme.Accent
	local h, s, v = state.color:ToHSV()

	local container = Create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Device.rowH),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = section:_next(),
		ClipsDescendants = true, Parent = section.body,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local header = Create("TextButton", {
		BackgroundColor3 = Theme.Elevated, BorderSizePixel = 0, AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, Device.rowH), Text = "", LayoutOrder = 1, Parent = container,
	}, { corner(6), stroke(Theme.Stroke, 1, 0.45), padding(0, 12, 0, 12) })
	Create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -52, 1, 0),
		Font = Theme.Font, Text = opts.Text or "Color", TextColor3 = Theme.Text,
		TextSize = Device.textSize, TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
	})
	local preview = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 34, 0, 18), BackgroundColor3 = state.color, BorderSizePixel = 0, Parent = header,
	}, { corner(4), stroke(Theme.Stroke, 1, 0.2) })

	local svH = Device.mobile and 120 or 96
	local panel = Create("Frame", {
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, svH + 16), Visible = false, Parent = container,
	}, { corner(6), stroke(Theme.Stroke, 1, 0.3), padding(8) })

	-- Saturation / Value box: base = full-hue, then a WHITE overlay (opaque→clear,
	-- left→right = saturation) and a BLACK overlay (clear→opaque, top→bottom = value).
	local svBox = Create("Frame", {
		Size = UDim2.new(1, -26, 0, svH), BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0, ClipsDescendants = false, Active = true, Parent = panel,
	}, { corner(5) })
	local satOverlay = Create("Frame", { -- white, fades out to the right
		Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0, ZIndex = 2, Parent = svBox,
	}, {
		corner(5),
		Create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
			}),
		}),
	})
	local valOverlay = Create("Frame", { -- black, fades in toward the bottom
		Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0, ZIndex = 3, Parent = svBox,
	}, {
		corner(5),
		Create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
			}),
		}),
	})
	local svDot = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 4, Parent = svBox,
	}, { corner(6), stroke(Color3.new(0, 0, 0), 1.5, 0.2) })

	-- Hue bar (vertical rainbow).
	local hueBar = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 16, 0, svH), BorderSizePixel = 0, Active = true, Parent = panel,
	}, { corner(5) })
	Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
			ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
			ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
			ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
			ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
			ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
			ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
		}), Parent = hueBar,
	})
	local hueDot = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, h, 0),
		Size = UDim2.new(1, 6, 0, 5), BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0, ZIndex = 5, Parent = hueBar,
	}, { corner(2), stroke(Color3.new(0, 0, 0), 1.5, 0.2) })

	local function apply(fire)
		state.color = Color3.fromHSV(h, s, v)
		svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		preview.BackgroundColor3 = state.color
		svDot.Position = UDim2.new(s, 0, 1 - v, 0)
		svDot.BackgroundColor3 = state.color
		hueDot.Position = UDim2.new(0.5, 0, h, 0)
		if fire then fireChange(state, state.color) end
	end
	apply(false)

	bindAreaDrag(state.conns, svBox, function(ax, ay)
		if state.disabled then return end
		s, v = ax, 1 - ay
		apply(true)
	end)
	bindAreaDrag(state.conns, hueBar, function(_, ay)
		if state.disabled then return end
		h = ay
		apply(true)
	end)

	state.open = false
	track(state.conns, header.MouseButton1Click:Connect(function()
		if state.disabled then return end
		state.open = not state.open
		panel.Visible = state.open
	end))
	addHover(state.conns, header, { BackgroundColor3 = Theme.Hover }, { BackgroundColor3 = Theme.Elevated })

	local api = {}
	state.api = api
	attachCommon(api, container, state)
	function api:SetColor(c) state.color = c; h, s, v = c:ToHSV(); apply(true); return api end
	function api:GetColor() return state.color end
	function api:SetValue(c) return api:SetColor(c) end
	function api:GetValue() return state.color end
	registerFlag(api, opts.Flag,
		function(c) return { __t = "Color3", r = math.floor(c.R * 255 + 0.5), g = math.floor(c.G * 255 + 0.5), b = math.floor(c.B * 255 + 0.5) } end,
		function(d) if type(d) == "table" and d.__t == "Color3" then return Color3.fromRGB(d.r, d.g, d.b) end return Theme.Accent end)
	if opts.Flag then Library.Flags[opts.Flag] = state.color end
	return api
end

-- ── LABEL & PARAGRAPH ──────────────────────────────────────────────────────
function Controls.Label(section, text)
	local state = { conns = {} }
	local lbl = Create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = section:_next(),
		Font = Theme.Font, Text = text or "", TextColor3 = Theme.SubText,
		TextSize = Device.textSize, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
		Parent = section.body,
	})
	local api = {}
	attachCommon(api, lbl, state)
	function api:SetText(t) lbl.Text = t; return api end
	function api:GetText() return lbl.Text end
	return api
end

function Controls.Paragraph(section, title, body)
	local state = { conns = {} }
	local frame = Create("Frame", {
		BackgroundColor3 = Theme.Elevated, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = section:_next(), Parent = section.body,
	}, { corner(6), stroke(Theme.Stroke, 1, 0.45), padding(10, 12, 10, 12), vlist(3, Enum.HorizontalAlignment.Left) })
	local titleLbl = Create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.Y,
		Font = Theme.FontBold, Text = title or "Title", TextColor3 = Theme.Text,
		TextSize = Device.textSize, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = frame,
	})
	local bodyLbl = Create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.Y,
		Font = Theme.Font, Text = body or "", TextColor3 = Theme.SubText,
		TextSize = Device.textSize - 1, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = frame,
	})
	local api = {}
	attachCommon(api, frame, state)
	function api:SetText(t) bodyLbl.Text = t; return api end
	function api:GetText() return bodyLbl.Text end
	function api:SetTitle(t) titleLbl.Text = t; return api end
	return api
end

--═══════════════════════════════════════════════════════════════════════════
-- 12. SECTION  (a.k.a. Groupbox)
--═══════════════════════════════════════════════════════════════════════════

local function createSection(tab, title)
	local order = 0
	local section = {}
	function section:_next() order = order + 1; return order end

	local root = Create("Frame", {
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #tab._sections + 1, Parent = tab.content,
	}, { corner(8), stroke(Theme.Stroke, 1, 0.55), padding(12) })

	local head = Create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 0, Parent = root,
	})
	Create("Frame", { -- accent tick
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 0, 14), Position = UDim2.new(0, 0, 0, 2), Parent = head,
	}, { corner(2), })
	local titleLbl = Create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -10, 1, 0),
		Font = Theme.FontBold, Text = title or "Section", TextColor3 = Theme.Text,
		TextSize = Device.textSize, TextXAlignment = Enum.TextXAlignment.Left, Parent = head,
	})

	local body = Create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = root,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }), padding(8, 0, 0, 0) })

	section.root = root
	section.body = body
	section._tab = tab
	tab._sections[#tab._sections + 1] = section

	-- builder methods
	function section:AddButton(o) return Controls.Button(self, o or {}) end
	function section:AddToggle(o) return Controls.Toggle(self, o or {}) end
	function section:AddSlider(o) return Controls.Slider(self, o or {}) end
	function section:AddTextbox(o) return Controls.Textbox(self, o or {}) end
	function section:AddDropdown(o) return Controls.Dropdown(self, o or {}) end
	function section:AddKeybind(o) return Controls.Keybind(self, o or {}) end
	function section:AddColorPicker(o) return Controls.ColorPicker(self, o or {}) end
	function section:AddLabel(t) return Controls.Label(self, t) end
	function section:AddParagraph(t, b) return Controls.Paragraph(self, t, b) end

	function section:SetTitle(t) titleLbl.Text = t; return section end
	function section:SetVisible(b) root.Visible = b and true or false; return section end
	function section:Destroy() pcall(function() root:Destroy() end) end

	return section
end

--═══════════════════════════════════════════════════════════════════════════
-- 13. TAB  (sidebar button + sliding pill + content page)
--═══════════════════════════════════════════════════════════════════════════

local function createTab(window, opts)
	local index = #window._tabs + 1
	local btnH = window._tabBtnH

	-- Sidebar button
	local btn = Create("TextButton", {
		BackgroundTransparency = 1, AutoButtonColor = false, BorderSizePixel = 0,
		Size = UDim2.new(1, -12, 0, btnH), Text = "", LayoutOrder = index,
		Parent = window._tabList,
	})
	-- Optional tab icon (image asset). Accepts a number id or an "rbxassetid://" string.
	local iconImg
	local textInset = 12
	local iconAsset = resolveAsset(opts.Icon)
	if iconAsset then
		iconImg = Create("ImageLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.new(0, 16, 0, 16),
			Image = iconAsset, ImageColor3 = Theme.SubText, ZIndex = 3, Parent = btn,
		})
		textInset = 36
	end
	local btnLabel = Create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, textInset, 0, 0), Size = UDim2.new(1, -(textInset + 4), 1, 0),
		Font = Theme.FontMedium, Text = opts.Name or ("Tab " .. index),
		TextColor3 = Theme.SubText, TextSize = Device.textSize,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3,
		Parent = btn,
	})

	-- Content page (ScrollingFrame), one visible at a time.
	local content = Create("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
		Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Stroke,
		ScrollBarImageTransparency = 0.3, ClipsDescendants = true,
		Parent = window._pages,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
		padding(2, 8, 12, 2),
	})

	local tab = { _sections = {}, content = content, button = btn, _window = window, _index = index }

	local function setActive(active, animate)
		Tween(btnLabel, { TextColor3 = active and Theme.Text or Theme.SubText }, 0.18)
		if iconImg then Tween(iconImg, { ImageColor3 = active and Theme.Accent or Theme.SubText }, 0.18) end
		if active then
			content.Visible = true
			content.Position = UDim2.new(0, 0, 0, 8)
			Tween(content, { Position = UDim2.new(0, 0, 0, 0) }, 0.25)
		else
			content.Visible = false
		end
	end
	tab._setActive = setActive

	track(window._conns, btn.MouseButton1Click:Connect(function()
		window:_selectTab(tab)
	end))
	if UserInputService.MouseEnabled then
		track(window._conns, btn.MouseEnter:Connect(function()
			if window._activeTab ~= tab then Tween(btnLabel, { TextColor3 = Theme.Text }, 0.12) end
		end))
		track(window._conns, btn.MouseLeave:Connect(function()
			if window._activeTab ~= tab then Tween(btnLabel, { TextColor3 = Theme.SubText }, 0.12) end
		end))
	end

	window._tabs[index] = tab

	function tab:CreateSection(title) return createSection(self, title) end
	tab.AddSection = tab.CreateSection
	function tab:Select() window:_selectTab(tab); return tab end
	function tab:SetVisible(b) btn.Visible = b and true or false; return tab end
	function tab:Destroy() pcall(function() btn:Destroy(); content:Destroy() end) end

	-- First tab auto-selects.
	if index == 1 then window:_selectTab(tab) end
	return tab
end

--═══════════════════════════════════════════════════════════════════════════
-- 14. WINDOW
--═══════════════════════════════════════════════════════════════════════════

function Library:CreateWindow(opts)
	opts = opts or {}
	if opts.Accent then
		Theme.Accent = opts.Accent
	end

	local window = { _tabs = {}, _sections = {}, _conns = {}, _activeTab = nil }
	window._tabBtnH = Device.mobile and 40 or 34
	window.ConfigFolder = opts.ConfigFolder or "AzureStyle"
	window.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

	local function winSize()
		local vp = getViewport()
		if Device.mobile then
			return UDim2.fromOffset(
				math.floor(clamp(vp.X * 0.94, 300, 560)),
				math.floor(clamp(vp.Y * 0.82, 320, 470)))
		end
		return opts.Size or UDim2.fromOffset(584, 466)
	end

	local topbarH = Device.mobile and 50 or 46
	local sidebarW = Device.sidebarW
	local ctrlSize = Device.mobile and 32 or 26

	local root = Create("Frame", {
		Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = winSize(), BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
		ClipsDescendants = true, Parent = ScreenGui,
	}, { corner(12), stroke(Theme.Stroke, 1, 0.3) })
	shadow(root, 0.5)
	window.root = root
	paint(root, "BackgroundColor3", "Background")

	-- ── Top bar ──
	local topbar = Create("Frame", {
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Active = true,
		Size = UDim2.new(1, 0, 0, topbarH), ZIndex = 2, Parent = root,
	}, { padding(0, 12, 0, 14) })
	paint(topbar, "BackgroundColor3", "Surface")
	Create("Frame", { -- bottom hairline
		BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), Parent = topbar,
	})

	-- Left: [accent dot] [title] [subtitle] arranged inline so they never overlap.
	local titleRow = Create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, -(ctrlSize * 2 + 16), 1, 0), ClipsDescendants = true, Parent = topbar,
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
		}),
	})
	local dot = Create("Frame", {
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, LayoutOrder = 1,
		Size = UDim2.new(0, 10, 0, 10), Parent = titleRow,
	}, { corner(5) })
	paint(dot, "BackgroundColor3", "Accent")
	Create("TextLabel", {
		BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0),
		Font = Theme.FontBold, Text = opts.Title or "AzureStyle", TextColor3 = Theme.Text,
		TextSize = Device.textSize + 1, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = titleRow,
	})
	if opts.SubTitle then
		Create("TextLabel", {
			BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0),
			Font = Theme.Font, Text = opts.SubTitle, TextColor3 = Theme.SubText,
			TextSize = Device.textSize - 1, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 3, Parent = titleRow,
		})
	end

	-- Control buttons with frame-drawn icons (no font glyphs → always render).
	local function ctrlButton(kind, xOffset)
		local b = Create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOffset, 0.5, 0),
			Size = UDim2.new(0, ctrlSize, 0, ctrlSize), BackgroundColor3 = Theme.Elevated,
			AutoButtonColor = false, Text = "", BorderSizePixel = 0, ZIndex = 3, Parent = topbar,
		}, { corner(6) })
		local icon
		if kind == "close" then icon = select(1, iconCross(b, 11, Theme.SubText, 2))
		elseif kind == "min" then icon = select(1, iconMinus(b, 12, Theme.SubText, 2)) end
		addPress(window._conns, b)
		if UserInputService.MouseEnabled then
			track(window._conns, b.MouseEnter:Connect(function()
				Tween(b, { BackgroundColor3 = Theme.Hover }, 0.12)
				for _, c in ipairs(icon:GetChildren()) do pcall(function() Tween(c, { BackgroundColor3 = Theme.Text }, 0.12) end) end
			end))
			track(window._conns, b.MouseLeave:Connect(function()
				Tween(b, { BackgroundColor3 = Theme.Elevated }, 0.12)
				for _, c in ipairs(icon:GetChildren()) do pcall(function() Tween(c, { BackgroundColor3 = Theme.SubText }, 0.12) end) end
			end))
		end
		return b, icon
	end
	local closeBtn = ctrlButton("close", 0)
	local minBtn, minIcon = ctrlButton("min", -(ctrlSize + 6))

	-- Keep the window from being dragged/resized off-screen (centred anchor).
	local function clampOffsets(_, ox, _, oy)
		local vp = getViewport()
		local w = window._fullSize and window._fullSize.X.Offset or root.AbsoluteSize.X
		local h = window._fullSize and window._fullSize.Y.Offset or root.AbsoluteSize.Y
		local mx = math.max(0, (vp.X - w) / 2)
		local my = math.max(0, (vp.Y - h) / 2)
		return clamp(ox, -mx, mx), clamp(oy, -my, my)
	end
	window._clampOffsets = clampOffsets

	makeDraggable(window._conns, topbar, root, clampOffsets)

	-- ── Sidebar ──
	local sidebar = Create("Frame", {
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, topbarH), Size = UDim2.new(0, sidebarW, 1, -topbarH), Parent = root,
	})
	Create("Frame", { -- vertical divider
		BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, BackgroundTransparency = 0.4,
		Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), Parent = sidebar,
	})
	local tabListHolder = Create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 8),
		Size = UDim2.new(1, 0, 1, -16), Parent = sidebar,
	})
	-- sliding accent pill (behind buttons)
	local pill = Create("Frame", {
		BackgroundColor3 = Theme.AccentSoft, BorderSizePixel = 0, BackgroundTransparency = 0.25,
		Size = UDim2.new(1, -12, 0, window._tabBtnH), Position = UDim2.new(0, 6, 0, 0),
		Visible = false, ZIndex = 1, Parent = tabListHolder,
	}, { corner(7) })
	Create("Frame", { -- accent left edge of pill
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 0.55, 0), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
		ZIndex = 2, Parent = pill,
	}, { corner(2) })
	local tabList = Create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2, Parent = tabListHolder,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }) })
	window._tabList = tabList
	window._pill = pill

	-- ── Content / pages ──
	local pages = Create("Frame", {
		BackgroundColor3 = Theme.Surface2, BorderSizePixel = 0,
		Position = UDim2.new(0, sidebarW, 0, topbarH),
		Size = UDim2.new(1, -sidebarW, 1, -topbarH), Parent = root,
	}, { padding(12, 12, 12, 14) })
	paint(pages, "BackgroundColor3", "Surface2")
	window._pages = pages

	-- ── Reopen bubble (works on every platform; essential on touch) ──
	local bubble = Create("TextButton", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.new(0, 46, 0, 46), BackgroundColor3 = Theme.Surface, AutoButtonColor = false,
		Text = "", Visible = false, BorderSizePixel = 0, ZIndex = 40, Parent = ScreenGui,
	}, { corner(23), stroke(Theme.Accent, 1.5, 0.2) })
	shadow(bubble, 0.55)
	Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 41,
		Parent = bubble,
	}, { corner(7) })
	makeDraggable(window._conns, bubble, bubble, function(sx, ox, sy, oy)
		local vp = getViewport()
		ox = clamp(ox, 4, math.max(4, vp.X - 50))
		oy = clamp(oy, -(vp.Y / 2 - 27), vp.Y / 2 - 27)
		return ox, oy
	end)

	-- ── Tab selection (slide the pill) ──
	function window:_selectTab(tab)
		if self._activeTab == tab then return end
		local prev = self._activeTab
		self._activeTab = tab
		if prev then prev._setActive(false) end
		tab._setActive(true, true)

		local targetY = (tab._index - 1) * (self._tabBtnH + 4)
		if not pill.Visible then
			pill.Visible = true
			pill.Position = UDim2.new(0, 6, 0, targetY)
		else
			Tween(pill, { Position = UDim2.new(0, 6, 0, targetY) }, 0.28, Enum.EasingStyle.Quint)
		end
	end

	-- ── Visibility / toggle / minimize ──
	window._visible = true
	window._fullSize = root.Size
	window._minimized = false

	function window:SetVisible(b)
		b = b and true or false
		if b == self._visible then return self end
		self._visible = b
		if b then
			root.Visible = true
			root.Size = UDim2.new(self._fullSize.X.Scale, self._fullSize.X.Offset, 0, 0)
			Tween(root, { Size = self._fullSize }, 0.28, Enum.EasingStyle.Quint)
			bubble.Visible = false
		else
			Tween(root, { Size = UDim2.new(root.Size.X.Scale, root.Size.X.Offset, 0, 0) }, 0.22)
			task.delay(0.23, function() if not self._visible then root.Visible = false end end)
			bubble.Visible = true
		end
		return self
	end
	function window:GetVisible() return self._visible end
	function window:Toggle() return self:SetVisible(not self._visible) end

	function window:Minimize()
		self._minimized = not self._minimized
		pcall(function() minIcon:Destroy() end)
		if self._minimized then
			Tween(root, { Size = UDim2.new(self._fullSize.X.Scale, self._fullSize.X.Offset, 0, topbarH) }, 0.25)
			minIcon = select(1, iconSquare(minBtn, 10, Theme.SubText, 2)) -- restore glyph
		else
			Tween(root, { Size = self._fullSize }, 0.25)
			minIcon = select(1, iconMinus(minBtn, 12, Theme.SubText, 2))
		end
		return self
	end

	track(window._conns, closeBtn.MouseButton1Click:Connect(function()
		window:SetVisible(false)
		Library:Notify({ Title = opts.Title or "AzureStyle", Content = "Hidden — tap the bubble or press " .. (window.ToggleKey.Name or "the toggle key") .. " to reopen.", Duration = 4 })
	end))
	track(window._conns, minBtn.MouseButton1Click:Connect(function() window:Minimize() end))
	track(window._conns, bubble.MouseButton1Click:Connect(function() window:SetVisible(true) end))

	-- toggle key
	track(window._conns, UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == window.ToggleKey then
			window:Toggle()
		end
	end))

	-- responsive: keep window sized + on-screen after rotation / resize
	onResize(function()
		if not root.Parent then return end
		window._fullSize = winSize()
		if window._visible and not window._minimized then
			root.Size = window._fullSize
		end
		local p = root.Position
		local ox, oy = clampOffsets(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset)
		root.Position = UDim2.new(0.5, ox, 0.5, oy)
	end)

	-- ── public window API ──
	function window:CreateTab(o) return createTab(self, o or {}) end
	window.AddTab = window.CreateTab
	function window:Notify(o) return Library:Notify(o) end
	function window:Destroy()
		cleanup(self._conns)
		pcall(function() root:Destroy() end)
		pcall(function() bubble:Destroy() end)
	end
	window.Unload = window.Destroy

	-- config helpers bound to this window's folder
	function window:SaveConfig(name) return Library:SaveConfig(name, self.ConfigFolder) end
	function window:LoadConfig(name) return Library:LoadConfig(name, self.ConfigFolder) end
	function window:ListConfigs() return Library:ListConfigs(self.ConfigFolder) end
	function window:DeleteConfig(name) return Library:DeleteConfig(name, self.ConfigFolder) end

	Library._windows[#Library._windows + 1] = window
	return window
end

--═══════════════════════════════════════════════════════════════════════════
-- 15. THEME / ACCENT API
--═══════════════════════════════════════════════════════════════════════════

local function repaintAll()
	for i = #themeRegistry, 1, -1 do
		local e = themeRegistry[i]
		local ok = pcall(function() e.inst[e.prop] = Theme[e.token] end)
		if not ok then table.remove(themeRegistry, i) end
	end
end

function Library:SetAccent(color)
	Theme.Accent = color
	-- derive a soft variant for pills
	local h, s, v = color:ToHSV()
	Theme.AccentSoft = Color3.fromHSV(h, clamp(s * 0.9, 0, 1), clamp(v * 0.35, 0.08, 0.4))
	Theme.AccentDim = Color3.fromHSV(h, s, clamp(v * 0.8, 0, 1))
	repaintAll()
	return self
end

function Library:SetTheme(partial)
	for k, val in pairs(partial or {}) do
		Theme[k] = val
	end
	repaintAll()
	return self
end

--═══════════════════════════════════════════════════════════════════════════
-- 16. CONFIG SAVE / LOAD  (executor file API, all pcall-guarded)
--═══════════════════════════════════════════════════════════════════════════

local function hasFileApi()
	return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
end

local function ensureFolder(folder)
	pcall(function()
		if typeof(makefolder) == "function" and typeof(isfolder) == "function" and not isfolder(folder) then
			makefolder(folder)
		end
	end)
end

function Library:SaveConfig(name, folder)
	folder = folder or "AzureStyle"
	name = name or "default"
	if not hasFileApi() then
		self:Notify({ Title = "Config", Content = "File API unavailable in this executor.", Type = "Warning" })
		return false
	end
	ensureFolder(folder)
	local data = {}
	for flag, entry in pairs(self._flagged) do
		local val = self.Flags[flag]
		if entry.encode then
			local ok, enc = pcall(entry.encode, val)
			data[flag] = ok and enc or nil
		else
			data[flag] = val
		end
	end
	local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
	if not ok then return false end
	local wok = pcall(function() writefile(folder .. "/" .. name .. ".json", encoded) end)
	if wok then self:Notify({ Title = "Config", Content = "Saved '" .. name .. "'.", Type = "Success" }) end
	return wok
end

function Library:LoadConfig(name, folder)
	folder = folder or "AzureStyle"
	name = name or "default"
	if not hasFileApi() then return false end
	local path = folder .. "/" .. name .. ".json"
	local exists = false
	pcall(function() exists = isfile(path) end)
	if not exists then
		self:Notify({ Title = "Config", Content = "'" .. name .. "' not found.", Type = "Warning" })
		return false
	end
	local ok, raw = pcall(function() return readfile(path) end)
	if not ok then return false end
	local dok, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if not dok or type(data) ~= "table" then return false end
	for flag, stored in pairs(data) do
		local entry = self._flagged[flag]
		if entry and entry.api and entry.api.SetValue then
			local value = stored
			if entry.decode then
				local sok, dec = pcall(entry.decode, stored)
				if sok then value = dec end
			end
			pcall(function() entry.api:SetValue(value) end)
		end
	end
	self:Notify({ Title = "Config", Content = "Loaded '" .. name .. "'.", Type = "Success" })
	return true
end

function Library:ListConfigs(folder)
	folder = folder or "AzureStyle"
	local out = {}
	if typeof(listfiles) ~= "function" then return out end
	pcall(function()
		for _, file in ipairs(listfiles(folder)) do
			local nm = string.match(file, "([^/\\]+)%.json$")
			if nm then out[#out + 1] = nm end
		end
	end)
	return out
end

function Library:DeleteConfig(name, folder)
	folder = folder or "AzureStyle"
	if typeof(delfile) ~= "function" then return false end
	local ok = pcall(function() delfile(folder .. "/" .. (name or "default") .. ".json") end)
	return ok
end

--═══════════════════════════════════════════════════════════════════════════
-- 17. GLOBAL DESTROY
--═══════════════════════════════════════════════════════════════════════════

function Library:Destroy()
	for _, w in ipairs(self._windows) do pcall(function() w:Destroy() end) end
	cleanup(self._conns)
	pcall(function() ScreenGui:Destroy() end)
end
Library.Unload = Library.Destroy

return Library

--[[════════════════════════════════════════════════════════════════════════════
                              MINIMAL EXAMPLE
        Paste this AFTER loading the library to see the dark theme + #0077FF.
────────────────────────────────────────────────────────────────────────────

local Azure = loadstring(game:HttpGet("<your-host-url>"))()

local Window = Azure:CreateWindow({
    Title    = "AzureStyle",
    SubTitle = "v1.0",
    Accent   = Color3.fromRGB(0, 119, 255),   -- #0077FF
    ToggleKey = Enum.KeyCode.RightShift,
    ConfigFolder = "AzureStyleDemo",
})

local Home = Window:CreateTab({ Name = "Home" })
local Main = Home:CreateSection("Main Controls")

Main:AddButton({
    Text = "Notify me",
    Callback = function()
        Azure:Notify({ Title = "Hello", Content = "AzureStyle is running.", Type = "Success" })
    end,
})

Main:AddToggle({
    Text = "Enable feature",
    Default = true,
    Flag = "feature_enabled",
    Callback = function(v) print("toggle:", v) end,
})

Main:AddSlider({
    Text = "Field of View",
    Min = 0, Max = 500, Default = 120, Decimals = 0, Suffix = " px",
    Flag = "fov",
    Callback = function(v) print("fov:", v) end,
})

local Options = Home:CreateSection("Options")

Options:AddDropdown({
    Text = "Mode",
    Options = { "Smooth", "Instant", "Hybrid" },
    Default = "Smooth",
    Flag = "mode",
    Callback = function(opt) print("mode:", opt) end,
})

Options:AddTextbox({
    Text = "Target name",
    Placeholder = "username...",
    Flag = "target",
    Callback = function(text) print("target:", text) end,
})

Options:AddKeybind({
    Text = "Aim key",
    Default = Enum.KeyCode.E,
    Flag = "aim_key",
    Callback = function() print("aim key pressed") end,
})

Options:AddColorPicker({
    Text = "ESP color",
    Default = Color3.fromRGB(0, 119, 255),
    Flag = "esp_color",
    Callback = function(c) print("color:", c) end,
})

local Cfg = Home:CreateSection("Config")
Cfg:AddButton({ Text = "Save config", Callback = function() Window:SaveConfig("default") end })
Cfg:AddButton({ Text = "Load config", Callback = function() Window:LoadConfig("default") end })

-- Read any value at any time for automation:
-- print(Azure.Flags["fov"], Azure.Flags["mode"])

════════════════════════════════════════════════════════════════════════════]]
