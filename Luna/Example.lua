local httpservice = game:GetService("HttpService")

local lunalibrary = loadstring(game:HttpGet("https://filho.wtf/Luna/Library.lua"))().Library

lunalibrary:SetFolder("LunaUI")
lunalibrary:SetSubfolder("Profiles")

local windowobj = lunalibrary:CreateWindow()
windowobj:SetTitle("LunaUI - Advanced API Showcase")

local hometab = windowobj:AddTab({ Name = "Home", Icon = "rbxassetid://7733960981" })
hometab:SetHome()

local targetSec = hometab:AddSection({ Name = "Target Elements" })

local t_label = targetSec:AddLabel({ Text = "Initial Label Text", Tooltip = "I will be manipulated." })

local t_toggle = targetSec:AddToggle({ Name = "Target Toggle", Flag = "TargetTog", Callback = function(s) end })
local t_keybind = t_toggle:AddKeybind({ Default = "G", TouchEnabled = true })

local t_slider = targetSec:AddSlider({ Name = "Target Slider", Min = 0, Max = 100, Default = 50, Suffix = "%" })

local t_textbox = targetSec:AddTextBox({ Name = "Target Box", Placeholder = "Type here...", ClearOnFocus = false })

local t_dropdown = targetSec:AddDropdown({ Name = "Target Dropdown", Items = { "Apple", "Banana", "Cherry" }, IsMulti = true })

local t_image = targetSec:AddImage({ Name = "Preview", Image = "rbxassetid://7733770755", Height = 100 })

local t_colorpicker = targetSec:AddColorpicker({ Name = "Accent Color", Default = Color3.fromRGB(138, 43, 226), Callback = function(c) end })
local t_cp_keybind = t_colorpicker:AddKeybind({ Default = "C", TouchEnabled = true })

local t_colorpicker2 = targetSec:AddColorpicker({ Name = "Background Color", Default = Color3.fromRGB(20, 20, 20), Flag = "BgColor", Callback = function(c) end })

local utilitySec = hometab:AddSection({ Name = "Practical Use" })
utilitySec:AddButton({ Name = "Save Current Theme", Callback = function()
	lunalibrary:SaveTheme("QuickTheme")
end, Tooltip = "Exports the current live colors." })
utilitySec:AddButton({ Name = "Save Current Config", Callback = function()
	lunalibrary:SaveConfig("QuickConfig")
end, Tooltip = "Stores the current element state." })
utilitySec:AddButton({ Name = "Restore Default Dark", Callback = function()
	lunalibrary:LoadTheme([[{"TitleBar":[32,32,32],"Body":[20,20,20],"BodyLight":[28,28,28],"Border":[60,60,60],"Text":[240,240,240],"TextDim":[160,160,160],"CloseHover":[196,43,28],"ClosePress":[150,30,18],"BtnHover":[55,55,55],"Accent":[138,43,226],"Warning":[255,170,0],"Error":[255,50,50],"ImageColor":[255,255,255]}]])
end, Tooltip = "Returns the UI to the built-in preset." })

local controlSec = hometab:AddSection({ Name = "Sub-Function Triggers" })

controlSec:AddButton({ Name = "Manipulate Label", Callback = function()
	t_label:SetText("Label has been changed!")
	t_label:SetTooltip("Tooltip updated via code.")
end })

controlSec:AddButton({ Name = "Force Toggle & Slider", Callback = function()
	t_toggle:SetValue(not t_toggle:GetValue())
	t_slider:SetValue(math.random(0, 100))
end })

local state_disabled = false
controlSec:AddButton({ Name = "Toggle Element States", Callback = function()
	state_disabled = not state_disabled
	if state_disabled then
		t_textbox:Disable()
		t_slider:Disable()
		t_keybind:Disable()
		t_image:Disable()
	else
		t_textbox:Enable()
		t_slider:Enable()
		t_keybind:Enable()
		t_image:Enable()
	end
end })

controlSec:AddButton({ Name = "Edit Textbox Props", Callback = function()
	t_textbox:SetText("Updated Box Name")
	t_textbox:SetPlaceholderText("New placeholder...")
	t_textbox:SetValue("Injected string")
end })

local dpCtrlBtn = controlSec:AddButton({ Name = "Dropdown Disable Options", Callback = function()
	t_dropdown:DisableOption({ "Apple", "Cherry" })
end })
dpCtrlBtn:AddSubButton({ Name = "Enable Options", Callback = function()
	t_dropdown:EnableOption({ "Apple", "Cherry" })
end })

local dpCtrlBtn2 = controlSec:AddButton({ Name = "Dropdown Add Value", Callback = function()
	t_dropdown:AddValue({ "Dragonfruit", "Elderberry" })
end })
dpCtrlBtn2:AddSubButton({ Name = "Remove Value", Callback = function()
	t_dropdown:RemoveValue({ "Banana" })
end })

controlSec:AddButton({ Name = "Modify Image", Callback = function()
	t_image:SetImage("rbxassetid://7733964126")
	t_image:SetHeight(150)
end })

local cpDisabled = false
controlSec:AddButton({ Name = "Toggle Colorpicker State", Callback = function()
	cpDisabled = not cpDisabled
	if cpDisabled then
		t_colorpicker:Disable()
		t_colorpicker2:Disable()
	else
		t_colorpicker:Enable()
		t_colorpicker2:Enable()
	end
end })

controlSec:AddButton({ Name = "Set Colorpicker via Code", Callback = function()
	t_colorpicker:SetValue(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
	t_colorpicker2:SetValue("#1A1A2E")
end })

controlSec:AddButton({ Name = "Read Colorpicker Values", Callback = function()
	local r, g, b = t_colorpicker:GetValueRGB()
	local hex = t_colorpicker:GetValueHex()
	lunalibrary:Notify({ Title = "Colorpicker Values", Description = "RGB: " .. r .. ", " .. g .. ", " .. b .. "  |  HEX: #" .. hex, Time = 4, Type = 1 })
end })

controlSec:AddButton({ Name = "Nuke Targets", Callback = function()
	t_label:Remove()
	t_toggle:Remove()
	t_slider:Remove()
	t_textbox:Remove()
	t_dropdown:Remove()
	t_image:Remove()
	t_colorpicker:Remove()
	t_colorpicker2:Remove()
end }):MakeDangerous()

local notifTab = windowobj:AddTab({ Name = "Notifications", Icon = "rbxassetid://7733911828" })
local notifSec = notifTab:AddSection({ Name = "Notification Types", Side = "Left" })

notifSec:AddButton({ Name = "Info Notification", Callback = function()
	lunalibrary:Notify({ Title = "Information", Description = "A standard info alert.", Time = 3, Type = 1, Icon = "rbxassetid://7733960981" })
end })

notifSec:AddButton({ Name = "Warning Notification", Callback = function()
	lunalibrary:Notify({ Title = "Warning!", Description = "Proceed with caution.", Time = 3, Type = 2 })
end })

notifSec:AddButton({ Name = "Error Notification", Callback = function()
	lunalibrary:Notify({ Title = "Fatal Error", Description = "Something broke.", Time = 3, Type = 3 })
end })

notifSec:AddButton({ Name = "Yes/No Notification", Callback = function()
	lunalibrary:Notify({
		Title = "Confirmation",
		Description = "Are you absolutely sure you want to do this?",
		Time = 5,
		Type = 2,
		CallbackYes = function() print("User selected Yes") end,
		CallbackNo = function() print("User selected No") end
	})
end })

notifSec:AddButton({ Name = "Custom Buttons Notification", Callback = function()
	lunalibrary:Notify({
		Title = "Multiple Choices",
		Description = "Select an arbitrary option to proceed:",
		Time = 8,
		Type = 3,
		Buttons = {
			{ Name = "Opt A", Callback = function() print("A") end },
			{ Name = "Opt B", Callback = function() print("B") end },
			{ Name = "Opt C", Callback = function() print("C") end }
		}
	})
end })

local advNotifSec = notifTab:AddSection({ Name = "Advanced Notifications", Side = "Right" })

local activeProgress
advNotifSec:AddButton({ Name = "Simulate Download", Callback = function()
	if activeProgress then activeProgress:Dismiss() end
	activeProgress = lunalibrary:Notify({ Title = "Downloading Data", Description = "Initializing...", Infinite = true, Type = 1, Icon = "rbxassetid://7733770755" })

	task.spawn(function()
		for i = 0, 100, 5 do
			if not activeProgress then break end
			task.wait(0.1)
			activeProgress:SetLoad(i)
			activeProgress:SetDescription("Downloaded " .. i .. "% of assets.")

			if i == 50 then
				activeProgress:SetTitle("Halfway There!")
			end
		end
		if activeProgress then
			activeProgress:SetTitle("Download Complete")
			activeProgress:SetDescription("All assets loaded successfully.")
			activeProgress:SetIcon("rbxassetid://100928939627907")
			task.wait(1.5)
			activeProgress:Dismiss()
			activeProgress = nil
		end
	end)
end })

local interruptNotif
local intBtn = advNotifSec:AddButton({ Name = "Spawn Long Notification", Callback = function()
	interruptNotif = lunalibrary:Notify({ Title = "Waiting...", Description = "I will stay here for 15 seconds.", Time = 15, Type = 1 })
end })
intBtn:AddSubButton({ Name = "Dismiss Early", Callback = function()
	if interruptNotif then interruptNotif:Dismiss() end
end })

local codeTab = windowobj:AddTab({ Name = "Code & Viewport", Icon = "rbxassetid://7733920644" })

local codeSec = codeTab:AddSection({ Name = "Code Controller", Side = "Left" })
local t_code = codeSec:AddCode({
	Name = "script",
	Suffix = "lua",
	Code = "print('Hello, World!')\nwarn('This is Lua.')",
	CodeHighlight = true,
	Writable = true
})

codeSec:AddButton({ Name = "Change to JavaScript", Callback = function()
	t_code:ChangeLanguage("js")
	t_code:SetText("app.js")
	t_code:ChangeCode("console.log('Language swapped to JS!');\nlet x = 10;")
end })

codeSec:AddButton({ Name = "Change to C++", Callback = function()
	t_code:ChangeLanguage("cpp")
	t_code:SetText("main.cpp")
	t_code:ChangeCode("#include <iostream>\n\nint main() {\n\treturn 0;\n}")
end })

codeSec:AddButton({ Name = "Toggle Read-Only", Callback = function()
	t_code:SetDisabled(true)
end }):AddSubButton({ Name = "Enable Write", Callback = function()
	t_code:SetDisabled(false)
end })

local vpSec = codeTab:AddSection({ Name = "Viewport Controller", Side = "Right" })

local part1 = Instance.new("Part")
part1.Size = Vector3.new(4, 4, 4)
part1.Color = Color3.fromRGB(255, 50, 50)
part1.Material = Enum.Material.Neon

local part2 = Instance.new("Part")
part2.Shape = Enum.PartType.Ball
part2.Size = Vector3.new(5, 5, 5)
part2.Color = Color3.fromRGB(50, 255, 50)

local t_vp = vpSec:AddViewportFrame({
	Name = "3D Preview",
	Models = { part1 },
	CameraPosition = CFrame.lookAt(Vector3.new(6, 6, 6), Vector3.new(0, 0, 0)),
	Height = 150,
	Rotatable = true
})
t_vp:IsRotatable(true)

vpSec:AddButton({ Name = "Swap Model", Callback = function()
	t_vp:SetModels(part2)
end })

vpSec:AddButton({ Name = "Toggle Rotation", Callback = function()
	t_vp:IsRotatable(not t_vp:IsRotatable())
end })

vpSec:AddButton({ Name = "Clear Viewport", Callback = function()
	t_vp:Clear()
end })

vpSec:AddButton({ Name = "Top-Down Camera", Callback = function()
	t_vp:SetCamera(CFrame.lookAt(Vector3.new(0, 15, 0), Vector3.new(0, 0, 0)), 90)
end })

vpSec:AddButton({ Name = "Change Lighting", Callback = function()
	t_vp:SetLighting(Color3.fromRGB(50, 50, 200), Color3.new(1, 1, 1), Vector3.new(0, -1, 0))
end })

vpSec:AddButton({ Name = "Resize Viewport", Callback = function()
	t_vp:SetHeight(250)
end })

local cpShowcaseTab = windowobj:AddTab({ Name = "Colorpickers", Icon = "rbxassetid://7734021595" })
local cpLeftSec = cpShowcaseTab:AddSection({ Name = "Color Controls", Side = "Left" })
local cp_basic = cpLeftSec:AddColorpicker({ Name = "Basic Color", Default = Color3.fromRGB(255, 100, 50), Flag = "ShowcaseCP1", Callback = function(c)
	lunalibrary:Notify({ Title = "Color Changed", Description = "R=" .. math.round(c.R * 255) .. " G=" .. math.round(c.G * 255) .. " B=" .. math.round(c.B * 255), Time = 2, Type = 1 })
end })
local cp_kb = cpLeftSec:AddColorpicker({ Name = "Keybind Color (K)", Default = Color3.fromRGB(50, 200, 255), Flag = "ShowcaseCP2", Callback = function(c) end })
cp_kb:AddKeybind({ Default = "K", TouchEnabled = true })
local cp_kb2 = cpLeftSec:AddColorpicker({ Name = "Keybind Color (J)", Default = Color3.fromRGB(200, 50, 255), Flag = "ShowcaseCP3", Callback = function(c) end })
cp_kb2:AddKeybind({ Default = "J", TouchEnabled = true })
cpLeftSec:AddButton({ Name = "Randomise All Colors", Callback = function()
	cp_basic:SetValue(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
	cp_kb:SetValue(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
	cp_kb2:SetValue(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
end })
cpLeftSec:AddButton({ Name = "Read All as Hex", Callback = function()
	lunalibrary:Notify({ Title = "Hex Values", Description = "#" .. cp_basic:GetValueHex() .. "  |  #" .. cp_kb:GetValueHex() .. "  |  #" .. cp_kb2:GetValueHex(), Time = 4, Type = 1 })
end })

local cpRightSec = cpShowcaseTab:AddSection({ Name = "Disabled / Enable Tests", Side = "Right" })
local cp_dis = cpRightSec:AddColorpicker({ Name = "Starts Disabled", Default = Color3.fromRGB(100, 100, 100), Flag = "ShowcaseCPDis", Callback = function(c) end })
cp_dis:SetDisabled(true)
local cp_dis_kb = cpRightSec:AddColorpicker({ Name = "Disabled + Keybind", Default = Color3.fromRGB(200, 200, 50), Flag = "ShowcaseCPDisKB", Callback = function(c) end })
cp_dis_kb:AddKeybind({ Default = "None", TouchEnabled = false })
cp_dis_kb:SetDisabled(true)
cpRightSec:AddButton({ Name = "Enable All Disabled", Callback = function()
	cp_dis:Enable()
	cp_dis_kb:Enable()
end }):AddSubButton({ Name = "Disable All", Callback = function()
	cp_dis:Disable()
	cp_dis_kb:Disable()
end })
cpRightSec:AddButton({ Name = "Remove Basic Color", Callback = function()
	cp_basic:Remove()
end }):MakeDangerous()

local overflowTab = windowobj:AddTab({ Name = "Many Sections Testing", Icon = "rbxassetid://7733970318" })
for i = 1, 15 do
	local testingSec = overflowTab:AddSection({ Name = "Section " .. i, Side = i % 2 == 0 and "Right" or "Left" })
	testingSec:AddTab({ Name = "Sub Tab 1" })
	testingSec:AddTab({ Name = "Sub Tab 2" })
	testingSec:AddTab({ Name = "Sub Tab 3" })
	testingSec:AddTab({ Name = "Sub Tab 4" })
	testingSec:AddButton({ Name = "Test Button " .. i })
end

local settab = windowobj:AddTab({ Name = "Settings", Icon = "rbxassetid://8997386997" })
local themesec = settab:AddSection({ Name = "Theme Presets", Side = "Left" })

themesec:AddButton({ Name = "Default Dark", Callback = function()
	lunalibrary:LoadTheme([[{"TitleBar":[32,32,32],"Body":[20,20,20],"BodyLight":[28,28,28],"Border":[60,60,60],"Text":[240,240,240],"TextDim":[160,160,160],"CloseHover":[196,43,28],"ClosePress":[150,30,18],"BtnHover":[55,55,55],"Accent":[138,43,226],"Warning":[255,170,0],"Error":[255,50,50],"ImageColor":[255,255,255]}]])
end })

themesec:AddButton({ Name = "Ocean Breeze", Callback = function()
	lunalibrary:LoadTheme([[{"TitleBar":[0,42,84],"Body":[0,21,42],"BodyLight":[0,64,128],"Border":[0,100,200],"Text":[200,230,255],"TextDim":[100,150,200],"CloseHover":[200,50,50],"ClosePress":[150,30,30],"BtnHover":[0,80,160],"Accent":[0,180,255],"Warning":[255,200,50],"Error":[255,100,100],"ImageColor":[100,200,255]}]])
end })

themesec:AddButton({ Name = "Crimson Red", Callback = function()
	lunalibrary:LoadTheme([[{"TitleBar":[40,20,20],"Body":[25,10,10],"BodyLight":[35,15,15],"Border":[80,30,30],"Text":[255,200,200],"TextDim":[180,120,120],"CloseHover":[255,50,50],"ClosePress":[200,30,30],"BtnHover":[60,20,20],"Accent":[255,40,40],"Warning":[255,150,0],"Error":[255,0,0],"ImageColor":[255,200,200]}]])
end })

themesec:AddButton({ Name = "Cyberpunk", Callback = function()
	lunalibrary:LoadTheme([[{"TitleBar":[18,10,40],"Body":[10,5,20],"BodyLight":[25,15,50],"Border":[255,0,128],"Text":[0,255,255],"TextDim":[0,150,150],"CloseHover":[255,0,50],"ClosePress":[200,0,30],"BtnHover":[50,20,80],"Accent":[255,0,255],"Warning":[255,255,0],"Error":[255,0,50],"ImageColor":[0,255,255]}]])
end })

themesec:AddButton({ Name = "Forest", Callback = function()
	lunalibrary:LoadTheme([[{"TitleBar":[15,35,20],"Body":[10,20,10],"BodyLight":[20,45,25],"Border":[50,100,60],"Text":[220,255,220],"TextDim":[150,200,150],"CloseHover":[200,80,80],"ClosePress":[150,50,50],"BtnHover":[30,65,40],"Accent":[80,200,100],"Warning":[255,200,50],"Error":[255,100,100],"ImageColor":[150,255,150]}]])
end })

local liveSec = settab:AddSection({ Name = "Theme Maker", Side = "Right" })

local defaultTheme = {
	TitleBar = Color3.fromRGB(32, 32, 32),
	Body = Color3.fromRGB(20, 20, 20),
	BodyLight = Color3.fromRGB(28, 28, 28),
	Border = Color3.fromRGB(60, 60, 60),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(160, 160, 160),
	CloseHover = Color3.fromRGB(196, 43, 28),
	ClosePress = Color3.fromRGB(150, 30, 18),
	BtnHover = Color3.fromRGB(55, 55, 55),
	Accent = Color3.fromRGB(138, 43, 226),
	Warning = Color3.fromRGB(255, 170, 0),
	Error = Color3.fromRGB(255, 50, 50),
	ImageColor = Color3.fromRGB(255, 255, 255),
}

local themeOrder = {
	{ Key = "TitleBar", Name = "Title Bar" },
	{ Key = "Body", Name = "Body" },
	{ Key = "BodyLight", Name = "Body Light" },
	{ Key = "Border", Name = "Border" },
	{ Key = "Text", Name = "Text" },
	{ Key = "TextDim", Name = "Text Dim" },
	{ Key = "Accent", Name = "Accent" },
	{ Key = "CloseHover", Name = "Close Hover" },
	{ Key = "ClosePress", Name = "Close Press" },
	{ Key = "BtnHover", Name = "Button Hover" },
	{ Key = "Warning", Name = "Warning" },
	{ Key = "Error", Name = "Error" },
	{ Key = "ImageColor", Name = "Image Color" },
}

local liveTheme = {}
for k, v in pairs(defaultTheme) do
	liveTheme[k] = v
end

local themePickers = {}
local syncingTheme = false

local function ThemeToJson(themeTable)
	local payload = {}
	for key, c in pairs(themeTable) do
		if typeof(c) == "Color3" then
			payload[key] = { math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255) }
		end
	end
	return httpservice:JSONEncode(payload)
end

local function ApplyLiveTheme()
	lunalibrary:LoadTheme(ThemeToJson(liveTheme))
end

local function SyncThemePickers()
	syncingTheme = true
	for _, item in ipairs(themeOrder) do
		local cp = themePickers[item.Key]
		if cp then
			cp:SetValue(liveTheme[item.Key], true, true)
		end
	end
	syncingTheme = false
end

local function ApplyPresetTheme(themeTable)
	for key, c in pairs(defaultTheme) do
		liveTheme[key] = themeTable[key] or c
	end
	SyncThemePickers()
	ApplyLiveTheme()
end

local function LoadPresetTheme(name)
	ApplyPresetTheme(presetThemes[name])
end

local themeNameBox = liveSec:AddTextBox({
	Name = "Theme Name",
	Placeholder = "QuickTheme",
	Tooltip = "Name for saving.",
	Flag = "LiveThemeName"
})

for _, item in ipairs(themeOrder) do
	local key = item.Key
	themePickers[key] = liveSec:AddColorpicker({
		Name = item.Name,
		Default = liveTheme[key],
		Flag = "LiveTheme_" .. key,
		Callback = function(c)
			if typeof(c) ~= "Color3" then return end
			liveTheme[key] = c
			if not syncingTheme then
				ApplyLiveTheme()
			end
		end,
	})
end

local saveThemeBtn = liveSec:AddButton({
	Name = "Save Theme",
	Callback = function()
		local n = themeNameBox:GetValue()
		if n == "" then n = "QuickTheme" end
		lunalibrary:SaveTheme(n)
	end,
	Tooltip = "Writes the current colors to a theme file."
})

saveThemeBtn:AddSubButton({
	Name = "Sync Picks",
	Callback = function()
		SyncThemePickers()
	end,
	Tooltip = "Refreshes the pickers from the live theme table."
})

saveThemeBtn:AddSubButton({
	Name = "Reset Theme",
	Callback = function()
		for key, c in pairs(defaultTheme) do
			liveTheme[key] = c
		end
		SyncThemePickers()
		ApplyLiveTheme()
	end,
	Tooltip = "Restores the default theme colors."
})

local presetThemes = {
	DefaultDark = {
		TitleBar = Color3.fromRGB(32, 32, 32),
		Body = Color3.fromRGB(20, 20, 20),
		BodyLight = Color3.fromRGB(28, 28, 28),
		Border = Color3.fromRGB(60, 60, 60),
		Text = Color3.fromRGB(240, 240, 240),
		TextDim = Color3.fromRGB(160, 160, 160),
		CloseHover = Color3.fromRGB(196, 43, 28),
		ClosePress = Color3.fromRGB(150, 30, 18),
		BtnHover = Color3.fromRGB(55, 55, 55),
		Accent = Color3.fromRGB(138, 43, 226),
		Warning = Color3.fromRGB(255, 170, 0),
		Error = Color3.fromRGB(255, 50, 50),
		ImageColor = Color3.fromRGB(255, 255, 255),
	},
	OceanBreeze = {
		TitleBar = Color3.fromRGB(0, 42, 84),
		Body = Color3.fromRGB(0, 21, 42),
		BodyLight = Color3.fromRGB(0, 64, 128),
		Border = Color3.fromRGB(0, 100, 200),
		Text = Color3.fromRGB(200, 230, 255),
		TextDim = Color3.fromRGB(100, 150, 200),
		CloseHover = Color3.fromRGB(200, 50, 50),
		ClosePress = Color3.fromRGB(150, 30, 30),
		BtnHover = Color3.fromRGB(0, 80, 160),
		Accent = Color3.fromRGB(0, 180, 255),
		Warning = Color3.fromRGB(255, 200, 50),
		Error = Color3.fromRGB(255, 100, 100),
		ImageColor = Color3.fromRGB(100, 200, 255),
	},
	CrimsonRed = {
		TitleBar = Color3.fromRGB(40, 20, 20),
		Body = Color3.fromRGB(25, 10, 10),
		BodyLight = Color3.fromRGB(35, 15, 15),
		Border = Color3.fromRGB(80, 30, 30),
		Text = Color3.fromRGB(255, 200, 200),
		TextDim = Color3.fromRGB(180, 120, 120),
		CloseHover = Color3.fromRGB(255, 50, 50),
		ClosePress = Color3.fromRGB(200, 30, 30),
		BtnHover = Color3.fromRGB(60, 20, 20),
		Accent = Color3.fromRGB(255, 40, 40),
		Warning = Color3.fromRGB(255, 150, 0),
		Error = Color3.fromRGB(255, 0, 0),
		ImageColor = Color3.fromRGB(255, 200, 200),
	},
	Cyberpunk = {
		TitleBar = Color3.fromRGB(18, 10, 40),
		Body = Color3.fromRGB(10, 5, 20),
		BodyLight = Color3.fromRGB(25, 15, 50),
		Border = Color3.fromRGB(255, 0, 128),
		Text = Color3.fromRGB(0, 255, 255),
		TextDim = Color3.fromRGB(0, 150, 150),
		CloseHover = Color3.fromRGB(255, 0, 50),
		ClosePress = Color3.fromRGB(200, 0, 30),
		BtnHover = Color3.fromRGB(50, 20, 80),
		Accent = Color3.fromRGB(255, 0, 255),
		Warning = Color3.fromRGB(255, 255, 0),
		Error = Color3.fromRGB(255, 0, 50),
		ImageColor = Color3.fromRGB(0, 255, 255),
	},
	Forest = {
		TitleBar = Color3.fromRGB(15, 35, 20),
		Body = Color3.fromRGB(10, 20, 10),
		BodyLight = Color3.fromRGB(20, 45, 25),
		Border = Color3.fromRGB(50, 100, 60),
		Text = Color3.fromRGB(220, 255, 220),
		TextDim = Color3.fromRGB(150, 200, 150),
		CloseHover = Color3.fromRGB(200, 80, 80),
		ClosePress = Color3.fromRGB(150, 50, 50),
		BtnHover = Color3.fromRGB(30, 65, 40),
		Accent = Color3.fromRGB(80, 200, 100),
		Warning = Color3.fromRGB(255, 200, 50),
		Error = Color3.fromRGB(255, 100, 100),
		ImageColor = Color3.fromRGB(150, 255, 150),
	},
	Sunset = {
		TitleBar = Color3.fromRGB(80, 54, 111),
		Body = Color3.fromRGB(31, 33, 77),
		BodyLight = Color3.fromRGB(91, 62, 126),
		Border = Color3.fromRGB(191, 52, 117),

		Text = Color3.fromRGB(255, 229, 138),
		TextDim = Color3.fromRGB(255, 206, 97),

		CloseHover = Color3.fromRGB(238, 108, 69),
		ClosePress = Color3.fromRGB(191, 52, 117),

		BtnHover = Color3.fromRGB(80, 54, 111),
		Accent = Color3.fromRGB(255, 206, 97),
		Warning = Color3.fromRGB(238, 108, 69),
		Error = Color3.fromRGB(191, 52, 117),

		ImageColor = Color3.fromRGB(255, 229, 138),
	},
}

themesec:AddButton({ Name = "Default Dark", Callback = function() LoadPresetTheme("DefaultDark") end })
themesec:AddButton({ Name = "Ocean Breeze", Callback = function() LoadPresetTheme("OceanBreeze") end })
themesec:AddButton({ Name = "Crimson Red", Callback = function() LoadPresetTheme("CrimsonRed") end })
themesec:AddButton({ Name = "Cyberpunk", Callback = function() LoadPresetTheme("Cyberpunk") end })
themesec:AddButton({ Name = "Forest", Callback = function() LoadPresetTheme("Forest") end })
themesec:AddButton({ Name = "Sunset", Callback = function() LoadPresetTheme("Sunset") end })


settab:LoadThemeManager()
settab:LoadConfigManager()
lunalibrary:LoadAutoload()
