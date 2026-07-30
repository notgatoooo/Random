
local maid = {}
maid.classname = "Maid"
maid.__index = maid
function maid.New() return setmetatable({_tasks = {}, _destroyed = false}, maid) end
local cleanup = { RBXScriptConnection = "Disconnect", Instance = "Destroy" }
local function CleanupTask(t)
	if not t then return end
	local tt = typeof(t)
	local method = cleanup[tt]
	if method then t[method](t) return end
	if type(t) == "function" then t() return end
	if type(t) == "table" then
		if type(t.Destroy) == "function" then pcall(function() t:Destroy() end)
		elseif type(t.Remove) == "function" then pcall(function() t:Remove() end) end
	end
end
function maid:GiveTask(t)
	if self._destroyed then CleanupTask(t) return end
	local tasks = self._tasks
	tasks[#tasks + 1] = t
	return t
end
function maid:DoCleaning()
	if self._destroyed then return end
	self._destroyed = true
	local old = self._tasks
	self._tasks = {}
	for _, t in old do CleanupTask(t) end
	self._destroyed = false
end
function maid:Destroy() self:DoCleaning() self._destroyed = true end

local cloneref = (typeof(cloneref) == "function" and cloneref) or (typeof(clonereference) == "function" and clonereference) or nil
local function GetService(name)
	local ok, svc = pcall(game.GetService, game, name)
	if ok and svc then
		if cloneref then
			local ok2, cloned = pcall(cloneref, svc)
			if ok2 and cloned then return cloned end
		end
		return svc
	end
	return nil
end

local tweenservice = GetService("TweenService")
local userinputservice = GetService("UserInputService")
local runservice = GetService("RunService")
local players = GetService("Players")
local marketplaceservice = GetService("MarketplaceService")
local teams = GetService("Teams")
local httpservice = GetService("HttpService")
local player = players.LocalPlayer

local mathclamp = math.clamp
local mathround = math.round
local mathmax = math.max
local mathmin = math.min
local stringmatch = string.match
local stringsub = string.sub
local stringfind = string.find
local stringlower = string.lower
local stringgsub = string.gsub
local stringformat = string.format
local stringupper = string.upper
local mathfloor = math.floor
local tableinsert = table.insert
local tablefind = table.find
local tableconcat = table.concat
local tableremove = table.remove
local osclock = os.clock

local write_file, read_file, is_file, list_files, make_folder, is_folder, del_file, set_clip, load_str
pcall(function() write_file = writefile end)
pcall(function() read_file = readfile end)
pcall(function() is_file = isfile end)
pcall(function() list_files = listfiles end)
pcall(function() make_folder = makefolder end)
pcall(function() is_folder = isfolder end)
pcall(function() del_file = delfile end)
pcall(function() set_clip = setclipboard or toclipboard end)
pcall(function() load_str = loadstring end)

local get_hui = type(gethui) == "function" and gethui or function() return game:GetService("CoreGui") end

local colors = {
	TitleBar   = Color3.fromRGB(46, 46, 48),
	Body       = Color3.fromRGB(30, 30, 32),
	BodyLight  = Color3.fromRGB(44, 44, 46),
	Border     = Color3.fromRGB(72, 72, 76),
	Text       = Color3.fromRGB(245, 245, 247),
	TextDim    = Color3.fromRGB(152, 152, 157),
	CloseHover = Color3.fromRGB(191, 73, 66),
	ClosePress = Color3.fromRGB(150, 50, 44),
	BtnHover   = Color3.fromRGB(60, 60, 62),
	Accent     = Color3.fromRGB(10, 132, 255),
	Warning    = Color3.fromRGB(255, 159, 10),
	Error      = Color3.fromRGB(255, 69, 58),
	ImageColor = Color3.fromRGB(245, 245, 247),
	TrafficClose      = Color3.fromRGB(255, 97, 89),
	TrafficCloseHover = Color3.fromRGB(255, 120, 112),
	TrafficMin        = Color3.fromRGB(255, 189, 46),
	TrafficMinHover   = Color3.fromRGB(255, 203, 84),
	TrafficMax        = Color3.fromRGB(40, 201, 65),
	TrafficMaxHover   = Color3.fromRGB(74, 217, 97),
}

local titlebar_h = 36
local btn_w      = 46
local function TweenOut(duration)
	return TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end
local tween      = TweenOut(0.2)
local tween_open = TweenOut(0.3)
local tween_tooltip = TweenOut(0.1)
local icons = {
	Close      = "rbxassetid://100928939627907",
	Maximize   = "rbxassetid://84623133872179",
	Minimize   = "rbxassetid://82909496983440",
	Unmaximize = "rbxassetid://123032264643469",
}
local default_title  = "LunaUI"
local default_icon   = ""
local width  = 520
local height = 340

local lunahelpers = {}
local lunamain = {}
local lunalibrary = {
	themeableobjects = {},
	fontobjects = {},
	currentfont = Font.fromId(12187377099),
	currentfontenum = nil,
	currentwindow = nil,
	_maid = maid.New(),
	folder = "LunaUI",
	subfolder = "",
	flags = {}
}

function lunahelpers.CheckDep(func)
	if func == "setclipboard" then return set_clip ~= nil end
	if func == "loadstring" then return load_str ~= nil end
	return false
end

local function getLangDef(suffix)
	suffix = stringlower(suffix or "")
	if suffix == "lua" or suffix == "luau" then
		return {
			kw = {["local"]=1, ["function"]=1,["if"]=1,["then"]=1, ["else"]=1, ["elseif"]=1,["end"]=1,["for"]=1, ["while"]=1, ["do"]=1,["return"]=1,["in"]=1, ["not"]=1, ["and"]=1,["or"]=1,["repeat"]=1, ["until"]=1, ["break"]=1,["continue"]=1,["goto"]=1},
			bi = {["print"]=1,["pairs"]=1,["ipairs"]=1,["next"]=1, ["type"]=1,["tostring"]=1,["tonumber"]=1, ["math"]=1, ["table"]=1, ["string"]=1, ["coroutine"]=1, ["task"]=1,["game"]=1, ["workspace"]=1, ["script"]=1, ["Instance"]=1,["Color3"]=1,["Vector3"]=1,["UDim2"]=1,["CFrame"]=1,["Enum"]=1, ["require"]=1, ["assert"]=1,["error"]=1,["pcall"]=1, ["xpcall"]=1,["select"]=1,["unpack"]=1,["getmetatable"]=1,["setmetatable"]=1,["getgenv"]=1,["setclipboard"]=1},
			bool = {["true"]=1,["false"]=1,["nil"]=1},
			self = {["self"]=1},
			c_sl = "--", c_ml_s = "--[[", c_ml_e = "]]",
			s_ml_s = "[[", s_ml_e = "]]"
		}
	elseif suffix == "py" or suffix == "python" then
		return {
			kw = {["def"]=1,["class"]=1,["if"]=1,["elif"]=1,["else"]=1,["for"]=1,["while"]=1,["return"]=1,["import"]=1,["from"]=1,["as"]=1,["try"]=1,["except"]=1,["finally"]=1, ["with"]=1,["yield"]=1,["lambda"]=1,["pass"]=1, ["break"]=1,["continue"]=1,["raise"]=1,["not"]=1, ["and"]=1,["or"]=1,["in"]=1,["is"]=1},
			bi = {["print"]=1, ["len"]=1, ["range"]=1,["list"]=1, ["dict"]=1, ["str"]=1, ["int"]=1,["float"]=1, ["set"]=1, ["tuple"]=1, ["enumerate"]=1,["zip"]=1, ["type"]=1, ["dir"]=1, ["id"]=1,["getattr"]=1, ["setattr"]=1,["hasattr"]=1,["isinstance"]=1,["issubclass"]=1,["super"]=1,["open"]=1},
			bool = {["True"]=1,["False"]=1,["None"]=1},
			self = {["self"]=1,["cls"]=1},
			c_sl = "#", c_ml_s = '"""', c_ml_e = '"""',
			s_ml_s = "'''", s_ml_e = "'''"
		}
	elseif suffix == "js" or suffix == "ts" or suffix == "javascript" or suffix == "typescript" then
		return {
			kw = {["var"]=1,["let"]=1,["const"]=1, ["function"]=1,["if"]=1,["else"]=1,["for"]=1, ["while"]=1, ["do"]=1,["return"]=1,["switch"]=1, ["case"]=1, ["break"]=1,["continue"]=1,["new"]=1, ["typeof"]=1, ["instanceof"]=1,["class"]=1,["extends"]=1,["import"]=1, ["export"]=1,["default"]=1,["async"]=1,["await"]=1, ["try"]=1,["catch"]=1,["finally"]=1,["throw"]=1, ["of"]=1,["in"]=1},
			bi = {["console"]=1, ["document"]=1,["window"]=1,["Math"]=1, ["Array"]=1, ["Object"]=1,["Promise"]=1,["String"]=1,["Number"]=1, ["Boolean"]=1,["Date"]=1,["RegExp"]=1,["Error"]=1, ["Map"]=1,["Set"]=1,["JSON"]=1,["setTimeout"]=1, ["setInterval"]=1},
			bool = {["true"]=1,["false"]=1,["null"]=1, ["undefined"]=1, ["NaN"]=1},
			self = {["this"]=1},
			c_sl = "//", c_ml_s = "/*", c_ml_e = "*/",
			s_ml_s = "`", s_ml_e = "`"
		}
	elseif suffix == "c" or suffix == "cpp" or suffix == "cs" or suffix == "h" or suffix == "hpp" then
		return {
			kw = {["int"]=1, ["float"]=1,["double"]=1, ["char"]=1,["void"]=1, ["if"]=1, ["else"]=1, ["for"]=1,["while"]=1, ["do"]=1, ["return"]=1, ["switch"]=1,["case"]=1, ["break"]=1, ["continue"]=1, ["struct"]=1,["class"]=1, ["public"]=1, ["private"]=1, ["protected"]=1,["typedef"]=1, ["namespace"]=1, ["using"]=1, ["static"]=1,["virtual"]=1, ["override"]=1, ["inline"]=1, ["const"]=1,["template"]=1, ["typename"]=1, ["new"]=1, ["delete"]=1,["try"]=1, ["catch"]=1, ["throw"]=1},
			bi = {["std"]=1,["cout"]=1,["cin"]=1, ["endl"]=1,["string"]=1,["vector"]=1,["map"]=1, ["printf"]=1,["scanf"]=1,["malloc"]=1,["free"]=1, ["Console"]=1,["Math"]=1,["System"]=1},
			bool = {["true"]=1,["false"]=1,["NULL"]=1, ["nullptr"]=1},
			self = {["this"]=1},
			c_sl = "//", c_ml_s = "/*", c_ml_e = "*/"
		}
	else
		return {kw={}, bi={}, bool={}, self={}}
	end
end

local function highlightCode(codeStr, langDef)
	if not codeStr or codeStr == "" then return "" end
	local function esc(s)
		local strResult = stringgsub(s, "[&<>\"]", {["&"]="&amp;",["<"]="&lt;", [">"]="&gt;", ["\""]="&quot;"})
		return strResult
	end
	if not langDef then return esc(codeStr) end
	local res = {}
	local pos = 1
	local len = #codeStr
	local function wrap(s, col) return '<font color="' .. col .. '">' .. esc(s) .. '</font>' end

	while pos <= len do
		if langDef.c_ml_s and stringsub(codeStr, pos, pos + #langDef.c_ml_s - 1) == langDef.c_ml_s then
			local s = pos
			pos = pos + #langDef.c_ml_s
			local e = stringfind(codeStr, langDef.c_ml_e, pos, true)
			if e then pos = e + #langDef.c_ml_e else pos = len + 1 end
			tableinsert(res, wrap(stringsub(codeStr, s, pos - 1), "#666666"))
			continue
		end
		if langDef.c_sl and stringsub(codeStr, pos, pos + #langDef.c_sl - 1) == langDef.c_sl then
			local s = pos
			local e = stringfind(codeStr, "\n", pos, true)
			if e then pos = e else pos = len + 1 end
			tableinsert(res, wrap(stringsub(codeStr, s, pos - 1), "#666666"))
			continue
		end
		if langDef.s_ml_s and stringsub(codeStr, pos, pos + #langDef.s_ml_s - 1) == langDef.s_ml_s then
			local s = pos
			pos = pos + #langDef.s_ml_s
			local e = stringfind(codeStr, langDef.s_ml_e, pos, true)
			if e then pos = e + #langDef.s_ml_e else pos = len + 1 end
			tableinsert(res, wrap(stringsub(codeStr, s, pos - 1), "#98C379"))
			continue
		end
		local c1 = stringsub(codeStr, pos, pos)
		if c1 == '"' or c1 == "'" or (langDef.s_ml_s == "`" and c1 == "`") then
			local s = pos
			local quote = c1
			pos = pos + 1
			while pos <= len do
				local c = stringsub(codeStr, pos, pos)
				if c == '\\' then pos = pos + 2
				elseif c == quote then pos = pos + 1; break
				elseif c == '\n' then break
				else pos = pos + 1 end
			end
			tableinsert(res, wrap(stringsub(codeStr, s, pos - 1), "#98C379"))
			continue
		end
		if stringmatch(c1, "%d") or (c1 == "." and stringmatch(stringsub(codeStr, pos+1, pos+1), "%d")) then
			local s = pos
			local _, e = stringfind(codeStr, "^0x%x+", pos)
			if e then
				pos = e + 1
			else
				_, e = stringfind(codeStr, "^%d+%.?%d*", pos)
				if e then pos = e + 1 else pos = pos + 1 end
			end
			tableinsert(res, wrap(stringsub(codeStr, s, pos - 1), "#C678DD"))
			continue
		end
		if stringmatch(c1, "[%a_]") then
			local s = pos
			local _, e = stringfind(codeStr, "^[%w_]+", pos)
			if not e then e = pos end
			pos = e + 1
			local word = stringsub(codeStr, s, e)
			local isFuncCall = false
			local afterPos = pos
			while afterPos <= len do
				local ac = stringsub(codeStr, afterPos, afterPos)
				if stringmatch(ac, "%s") then
					afterPos = afterPos + 1
				elseif ac == "(" or ac == '"' or ac == "'" or ac == "{" or ac == "[" then
					isFuncCall = true
					break
				else
					break
				end
			end
			local isMethodCall = false
			for i = s - 1, 1, -1 do
				local pc = stringsub(codeStr, i, i)
				if stringmatch(pc, "%s") then continue end
				if pc == ":" then isMethodCall = true end
				break
			end
			if langDef.kw and langDef.kw[word] then
				tableinsert(res, wrap(word, "#569CD6"))
			elseif langDef.bi and langDef.bi[word] then
				tableinsert(res, wrap(word, "#4EC9B0"))
			elseif langDef.bool and langDef.bool[word] then
				tableinsert(res, wrap(word, "#C678DD"))
			elseif langDef.self and langDef.self[word] then
				tableinsert(res, wrap(word, "#E06C75"))
			elseif isMethodCall and isFuncCall then
				tableinsert(res, wrap(word, "#E5C07B"))
			elseif isFuncCall then
				tableinsert(res, wrap(word, "#E06C75"))
			else
				tableinsert(res, esc(word))
			end
			continue
		end
		if stringmatch(c1, "[%+%-%*/%%%=%<%>%~%&%|%^%.%,%:%(%)%{%}%[%]%;]") then
			tableinsert(res, wrap(c1, "#ABB2BF"))
			pos = pos + 1
			continue
		end
		tableinsert(res, esc(c1))
		pos = pos + 1
	end
	return tableconcat(res)
end

local gradientTweens = {}
function lunahelpers.TweenGradient(grad, targetC1, targetC2, duration)
	if gradientTweens[grad] then gradientTweens[grad]:Cancel(); gradientTweens[grad] = nil end
	local curr1 = grad.Color.Keypoints[1].Value
	local curr2 = grad.Color.Keypoints[#grad.Color.Keypoints].Value
	local val = Instance.new("NumberValue")
	val.Value = 0
	local tw = tweenservice:Create(val, TweenOut(duration), {Value = 1})
	local conn; conn = val.Changed:Connect(function(v)
		if grad and grad.Parent then
			grad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, curr1:Lerp(targetC1, v)), ColorSequenceKeypoint.new(1, curr2:Lerp(targetC2, v)) })
		else
			if conn then conn:Disconnect() end; if tw then tw:Cancel() end
		end
	end)
	tw.Completed:Connect(function() if conn then conn:Disconnect() end; val:Destroy(); gradientTweens[grad] = nil end)
	gradientTweens[grad] = tw; tw:Play()
end

function lunahelpers.AddFeedback(maidObj, element, targetParent)
	targetParent = targetParent or element
	local overlay = Instance.new("Frame")
	overlay.Name = "FeedbackOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.ZIndex = targetParent.ZIndex
	local existingcorner = targetParent:FindFirstChildOfClass("UICorner")
	local ovcorner = Instance.new("UICorner")
	ovcorner.CornerRadius = existingcorner and existingcorner.CornerRadius or UDim.new(0, 7)
	ovcorner.Parent = overlay
	overlay.Parent = targetParent

	local isHovering, isPressing = false, false

	maidObj:GiveTask(element.MouseEnter:Connect(function()
		isHovering = true
		if not isPressing then tweenservice:Create(overlay, tween_tooltip, {BackgroundTransparency = 0.9}):Play() end
	end))
	maidObj:GiveTask(element.MouseLeave:Connect(function()
		isHovering = false
		if not isPressing then tweenservice:Create(overlay, tween_tooltip, {BackgroundTransparency = 1}):Play() end
	end))
	maidObj:GiveTask(element.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isPressing = true
			tweenservice:Create(overlay, tween_tooltip, {BackgroundTransparency = 0.8}):Play()
		end
	end))
	maidObj:GiveTask(element.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isPressing = false
			tweenservice:Create(overlay, tween_tooltip, {BackgroundTransparency = isHovering and 0.9 or 1}):Play()
		end
	end))
end

local lastErrTime = 0
function lunamain.SafeCallback(callback, ...)
	if type(callback) ~= "function" then return true, nil end
	local s, r = pcall(callback, ...)
	if not s then 
		warn("LunaUI Callback Error:", r)
		if osclock() - lastErrTime > 1 then
			lastErrTime = osclock()
			lunalibrary:Notify({
				Title = "Execution Error",
				Description = tostring(r),
				Time = 5,
				Type = 3
			})
		end
	end
	return s, r
end
local SafeCall = lunamain.SafeCallback

function lunalibrary:OnUnload(callback) self._maid:GiveTask(function() SafeCall(callback) end) end

local function BuildPath(lib, suffix)
	local p = lib.folder or "Luna"
	if lib.subfolder and lib.subfolder ~= "" then p = p .. "/" .. lib.subfolder end
	if suffix then p = p .. "/" .. suffix end
	return p
end

local function EnsureFolder(path)
	if not make_folder or not is_folder then return end
	local ok, exists = pcall(is_folder, path)
	if ok and not exists then pcall(make_folder, path) end
end

local function EnsureJson(path)
	if not stringmatch(path, "%.json$") then return path .. ".json" end
	return path
end

function lunalibrary:Unload()
	if self.currentwindow and self.currentwindow.gui then
		local luna = self.currentwindow.luna
		local gui = self.currentwindow.gui
		local mainstroke = self.currentwindow.mainstroke
		local curp = luna.Position
		local curs = luna.Size
		local tw, th = curs.X.Offset * 0.85, curs.Y.Offset * 0.85
		tweenservice:Create(luna, tween_open, { GroupTransparency = 1, Size = UDim2.new(0, tw, 0, th), Position = UDim2.new(curp.X.Scale, curp.X.Offset + (curs.X.Offset - tw) / 2, curp.Y.Scale, curp.Y.Offset + (curs.Y.Offset - th) / 2) }):Play()
		if mainstroke then tweenservice:Create(mainstroke, tween_open, { Transparency = 1 }):Play() end
		task.delay(0.35, function() self._maid:Destroy(); if gui and gui.Parent then gui:Destroy() end end)
	else
		self._maid:Destroy()
	end
end

function lunalibrary:UpdateTheme(isSmooth)
	local active = {}
	local n = 0
	local animdur = isSmooth and 0.4 or 0.2
	for _, item in self.themeableobjects do
		if item.Obj and item.Obj.Parent ~= nil then
			n += 1
			active[n] = item
			if item.IsGradient then
				local c1, c2 = colors[item.C1], colors[item.C2]
				if item.Darken then
					local d = item.Darken
					c1 = Color3.new(c1.R * d, c1.G * d, c1.B * d)
					c2 = Color3.new(c2.R * d, c2.G * d, c2.B * d)
				end
				if isSmooth then lunahelpers.TweenGradient(item.Obj, c1, c2, animdur)
				else item.Obj.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2) }) end
			else
				tweenservice:Create(item.Obj, TweenOut(animdur), {[item.Prop] = colors[item.ColorName] }):Play()
			end
		end
	end
	self.themeableobjects = active
end

function lunalibrary:SetFolder(name)
	self.folder = tostring(name or "Luna")
	EnsureFolder(self.folder)
	EnsureFolder(self.folder .. "/Themes")
	EnsureFolder(self.folder .. "/Configs")
end

function lunalibrary:SetSubfolder(name)
	self.subfolder = tostring(name or "")
	local base = BuildPath(self)
	EnsureFolder(base)
	EnsureFolder(base .. "/Themes")
	EnsureFolder(base .. "/Configs")
end

function lunalibrary:SaveTheme(name)
	name = (name == nil or name == "") and "LunaTheme" or tostring(name)
	if not write_file then
		self:Notify({ Title = "Theme Manager", Description = "Your executor does not support writefile.", Time = 4, Type = 3 })
		return false
	end
	local themedata = {}
	for k, v in colors do themedata[k] = { mathround(v.R * 255), mathround(v.G * 255), mathround(v.B * 255) } end
	local ok, jsonstr = pcall(httpservice.JSONEncode, httpservice, themedata)
	if not ok then
		self:Notify({ Title = "Theme Error", Description = "Failed to encode theme data.", Time = 4, Type = 3 })
		return false
	end
	local ok2, err = pcall(write_file, EnsureJson(BuildPath(self, "Themes/" .. name)), jsonstr)
	if ok2 then
		self:Notify({ Title = "Theme Manager", Description = "Successfully saved theme: " .. name, Time = 3, Type = 1 })
		return true
	else
		self:Notify({ Title = "Theme Error", Description = "Failed to save theme: " .. tostring(err), Time = 4, Type = 3 })
		return false
	end
end

function lunalibrary:LoadTheme(jsonstrorpath)
	local jsonstr = tostring(jsonstrorpath or "")
	local nameDisplay = "Theme"
	if not (stringmatch(jsonstr, "^%s*{") and stringmatch(jsonstr, "}%s*$")) then
		local path = EnsureJson(BuildPath(self, "Themes/" .. jsonstr))
		nameDisplay = jsonstr
		if is_file and read_file then
			local s1, r1 = pcall(is_file, path)
			if s1 and r1 then local s2, c = pcall(read_file, path); if s2 and c then jsonstr = c end end
		end
	end
	local ok, parsed = pcall(httpservice.JSONDecode, httpservice, jsonstr)
	if ok and type(parsed) == "table" then
		for k, v in parsed do
			if colors[k] and type(v) == "table" and type(v[1]) == "number" and type(v[2]) == "number" and type(v[3]) == "number" then
				colors[k] = Color3.fromRGB(v[1], v[2], v[3])
			end
		end
		self:UpdateTheme(true)
		self:Notify({ Title = "Theme Manager", Description = "Loaded theme: " .. nameDisplay, Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Theme Error", Description = "Failed to load theme data.", Time = 4, Type = 3 })
	return false
end

function lunalibrary:SetThemeAutoload(name)
	if not write_file then
		self:Notify({ Title = "Theme Manager", Description = "Your executor does not support writefile.", Time = 4, Type = 3 })
		return false
	end
	local ok, err = pcall(write_file, BuildPath(self, "Themes/autoload.txt"), EnsureJson(tostring(name or "")))
	if ok then
		self:Notify({ Title = "Theme Manager", Description = "Set autoload theme to: " .. tostring(name), Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Theme Error", Description = "Failed to set autoload: " .. tostring(err), Time = 4, Type = 3 })
	return false
end

function lunalibrary:RemoveThemeAutoload()
	local path = BuildPath(self, "Themes/autoload.txt")
	if del_file and is_file then
		local s, r = pcall(is_file, path)
		if s and r then
			pcall(del_file, path)
			self:Notify({ Title = "Theme Manager", Description = "Removed theme autoload.", Time = 3, Type = 1 })
			return true
		end
	end
	if write_file then
		local ok = pcall(write_file, path, "")
		if ok then
			self:Notify({ Title = "Theme Manager", Description = "Removed theme autoload.", Time = 3, Type = 1 })
			return true
		end
	end
	self:Notify({ Title = "Theme Error", Description = "Failed to remove autoload.", Time = 4, Type = 3 })
	return false
end

local function SerializeConfigValue(value)
	local valueType = typeof(value)
	if valueType == "Color3" then
		return "#" .. value:ToHex()
	elseif type(value) == "table" then
		local out = {}
		for k, v in pairs(value) do
			out[k] = SerializeConfigValue(v)
		end
		return out
	end
	return value
end

function lunalibrary:SaveConfig(name)
	name = (name == nil or name == "") and "LunaConfig" or tostring(name)
	if not write_file then
		self:Notify({ Title = "Config Manager", Description = "Your executor does not support writefile.", Time = 4, Type = 3 })
		return false
	end
	local configdata = {}
	for flag, element in self.flags do
		local s, val = pcall(element.GetValue, element)
		if s then
			configdata[flag] = SerializeConfigValue(val)
		end
	end
	local ok, jsonstr = pcall(httpservice.JSONEncode, httpservice, configdata)
	if not ok then
		self:Notify({ Title = "Config Error", Description = "Failed to encode config data.", Time = 4, Type = 3 })
		return false
	end
	local ok2, err = pcall(write_file, EnsureJson(BuildPath(self, "Configs/" .. name)), jsonstr)
	if ok2 then
		self:Notify({ Title = "Config Manager", Description = "Successfully saved config: " .. name, Time = 3, Type = 1 })
		return true
	else
		self:Notify({ Title = "Config Error", Description = "Failed to save config: " .. tostring(err), Time = 4, Type = 3 })
		return false
	end
end

function lunalibrary:LoadConfig(jsonstrorpath)
	local jsonstr = tostring(jsonstrorpath or "")
	local nameDisplay = "Config"
	if not (stringmatch(jsonstr, "^%s*{") and stringmatch(jsonstr, "}%s*$")) then
		local path = EnsureJson(BuildPath(self, "Configs/" .. jsonstr))
		nameDisplay = jsonstr
		if is_file and read_file then
			local s1, r1 = pcall(is_file, path)
			if s1 and r1 then
				local s2, c = pcall(read_file, path)
				if s2 and c then
					jsonstr = c
				end
			end
		end
	end
	local ok, parsed = pcall(httpservice.JSONDecode, httpservice, jsonstr)
	if ok and type(parsed) == "table" then
		for k, v in parsed do
			if self.flags[k] then
				pcall(self.flags[k].SetValue, self.flags[k], v)
			end
		end
		self:Notify({ Title = "Config Manager", Description = "Loaded config: " .. nameDisplay, Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Config Error", Description = "Failed to load config data.", Time = 4, Type = 3 })
	return false
end

function lunalibrary:SetConfigAutoload(name)
	if not write_file then
		self:Notify({ Title = "Config Manager", Description = "Your executor does not support writefile.", Time = 4, Type = 3 })
		return false
	end
	local ok, err = pcall(write_file, BuildPath(self, "Configs/autoload.txt"), EnsureJson(tostring(name or "")))
	if ok then
		self:Notify({ Title = "Config Manager", Description = "Set autoload config to: " .. tostring(name), Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Config Error", Description = "Failed to set autoload: " .. tostring(err), Time = 4, Type = 3 })
	return false
end

function lunalibrary:RemoveConfigAutoload()
	local path = BuildPath(self, "Configs/autoload.txt")
	if del_file and is_file then
		local s, r = pcall(is_file, path)
		if s and r then
			pcall(del_file, path)
			self:Notify({ Title = "Config Manager", Description = "Removed config autoload.", Time = 3, Type = 1 })
			return true
		end
	end
	if write_file then
		local ok = pcall(write_file, path, "")
		if ok then
			self:Notify({ Title = "Config Manager", Description = "Removed config autoload.", Time = 3, Type = 1 })
			return true
		end
	end
	self:Notify({ Title = "Config Error", Description = "Failed to remove autoload.", Time = 4, Type = 3 })
	return false
end

function lunalibrary:GetFiles(typestr)
	local res = {}
	if not (list_files and is_folder) then return res end
	local path = BuildPath(self, typestr .. "s")
	local s, isfolderres = pcall(is_folder, path)
	if not (s and isfolderres) then return res end
	local s2, files = pcall(list_files, path)
	if not (s2 and files) then return res end
	local n = 0
	for _, v in files do local name = stringmatch(v, "([^/\\]+)%.json$"); if name then n += 1; res[n] = name end end
	return res
end

function lunalibrary:DuplicateFile(typestr, name)
	if not (read_file and write_file and is_file) then return end
	local basepath = BuildPath(self, typestr .. "s/")
	local s, content = pcall(read_file, EnsureJson(basepath .. name))
	if not s then return end
	local num = 1
	local newname = name .. " (" .. num .. ")"
	while true do
		local s2, r2 = pcall(is_file, basepath .. newname .. ".json")
		if not (s2 and r2) then break end
		num += 1; newname = name .. " (" .. num .. ")"
	end
	pcall(write_file, basepath .. newname .. ".json", content)
	self:Notify({ Title = "File Manager", Description = "Duplicated to: " .. newname, Time = 3, Type = 1 })
end

function lunalibrary:LoadAutoload()
	if not (read_file and is_file) then return end
	local path = BuildPath(self)
	local themeauto = path .. "/Themes/autoload.txt"
	local s1, r1 = pcall(is_file, themeauto)
	if s1 and r1 then local s2, n = pcall(read_file, themeauto); if s2 and type(n) == "string" and n ~= "" then self:LoadTheme(n) end end
	local configauto = path .. "/Configs/autoload.txt"
	local s3, r3 = pcall(is_file, configauto)
	if s3 and r3 then local s4, n = pcall(read_file, configauto); if s4 and type(n) == "string" and n ~= "" then self:LoadConfig(n) end end
end

function lunalibrary:SetFont(fromid, id)
	if fromid then self.currentfont = Font.fromId(id); self.currentfontenum = nil
	else self.currentfont = nil; self.currentfontenum = id end
	local active = {}
	local n = 0
	for _, obj in self.fontobjects do
		if obj and obj.Parent then
			n += 1; active[n] = obj
			if self.currentfont then obj.FontFace = self.currentfont
			elseif self.currentfontenum then obj.Font = self.currentfontenum end
		end
	end
	self.fontobjects = active
end

function lunahelpers.UpdateThemeMapping(obj, prop, newthemename)
	if not obj then return end
	local found = false
	for _, item in lunalibrary.themeableobjects do
		if item.Obj == obj and item.Prop == prop then item.ColorName = newthemename; found = true; break end
	end
	if not found then local t = lunalibrary.themeableobjects; t[#t + 1] = { Obj = obj, Prop = prop, ColorName = newthemename } end
	tweenservice:Create(obj, tween, {[prop] = colors[newthemename] }):Play()
end

function lunahelpers.RemoveThemeEntries(obj, recursive)
	if not obj then return end
	local cleaned = {}
	local n = 0
	for _, item in lunalibrary.themeableobjects do
		if item.Obj then
			local ismatch = (item.Obj == obj)
			if recursive and not ismatch then
				local s, isdesc = pcall(item.Obj.IsDescendantOf, item.Obj, obj)
				if s and isdesc then ismatch = true end
			end
			if not ismatch then n += 1; cleaned[n] = item end
		end
	end
	lunalibrary.themeableobjects = cleaned
end

local cornerradii = {
	CanvasGroup = UDim.new(0, 12),
	ScrollingFrame = UDim.new(0, 8),
	Frame = UDim.new(0, 7),
	TextButton = UDim.new(0, 7),
	ImageButton = UDim.new(0, 7),
	TextBox = UDim.new(0, 7),
}

function lunahelpers.Make(class, props, parent)
	local obj = Instance.new(class)
	local corneroverride = nil
	if props then
		corneroverride = props._Corner
		props._Corner = nil
		for k, v in props do
			if type(v) == "table" and v.Theme then
				obj[k] = colors[v.Theme]
				local t = lunalibrary.themeableobjects; t[#t + 1] = { Obj = obj, Prop = k, ColorName = v.Theme }
			else obj[k] = v end
		end
	end
	local radius = corneroverride
	if radius == nil then radius = cornerradii[class] end
	if radius and radius ~= false then
		local c = Instance.new("UICorner")
		c.CornerRadius = radius
		c.Parent = obj
	end
	if parent then obj.Parent = parent end
	return obj
end

function lunahelpers.ApplyFont(obj)
	if not obj then return end
	if lunalibrary.currentfont then obj.FontFace = lunalibrary.currentfont
	elseif lunalibrary.currentfontenum then obj.Font = lunalibrary.currentfontenum end
	local t = lunalibrary.fontobjects; t[#t + 1] = obj
end

function lunahelpers.ApplyGradient(parent, c1, c2, darken)
	if not parent then return end
	c1 = c1 or "BodyLight"; c2 = c2 or "Body"
	parent.BackgroundColor3 = Color3.new(1, 1, 1)
	local color1, color2 = colors[c1], colors[c2]
	if darken then
		color1 = Color3.new(color1.R * darken, color1.G * darken, color1.B * darken)
		color2 = Color3.new(color2.R * darken, color2.G * darken, color2.B * darken)
	end
	local grad = lunahelpers.Make("UIGradient", {Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, color2) }), Rotation = 90}, parent)
	local t = lunalibrary.themeableobjects; t[#t + 1] = { Obj = grad, IsGradient = true, C1 = c1, C2 = c2, Darken = darken }
	return grad
end

function lunahelpers.HoverImg(maidobj, btn, normaltheme, hottheme, presstheme)
	if not (maidobj and btn) then return end
	maidobj:GiveTask(btn.MouseEnter:Connect(function() lunahelpers.UpdateThemeMapping(btn, "BackgroundColor3", hottheme) end))
	maidobj:GiveTask(btn.MouseLeave:Connect(function() lunahelpers.UpdateThemeMapping(btn, "BackgroundColor3", normaltheme) end))
	if presstheme then
		maidobj:GiveTask(btn.MouseButton1Down:Connect(function() lunahelpers.UpdateThemeMapping(btn, "BackgroundColor3", presstheme) end))
		maidobj:GiveTask(btn.MouseButton1Up:Connect(function() lunahelpers.UpdateThemeMapping(btn, "BackgroundColor3", hottheme) end))
	end
end

function lunahelpers.ApplyTooltip(maidobj, instance, textorfn, windowobj)
	if not (maidobj and instance and windowobj) then return end
	local function ResolveText()
		if type(textorfn) == "function" then local s, r = pcall(textorfn); return s and r or "" end
		return textorfn or ""
	end
	maidobj:GiveTask(instance.MouseEnter:Connect(function()
		local txt = ResolveText()
		if not txt or txt == "" then return end
		windowobj._currenttooltipinstance = instance
		windowobj.tooltiplabel.Text = txt
		windowobj.tooltip.Visible = true
		windowobj._tooltipcounter = (windowobj._tooltipcounter or 0) + 1
		tweenservice:Create(windowobj.tooltip, tween_tooltip, { BackgroundTransparency = 0 }):Play()
		tweenservice:Create(windowobj._tooltipstroke, tween_tooltip, { Transparency = 0 }):Play()
		tweenservice:Create(windowobj.tooltiplabel, tween_tooltip, { TextTransparency = 0 }):Play()
	end))
	maidobj:GiveTask(instance.MouseLeave:Connect(function()
		if windowobj._currenttooltipinstance == instance then windowobj._currenttooltipinstance = nil end
		windowobj._tooltipcounter = (windowobj._tooltipcounter or 0) + 1
		local cc = windowobj._tooltipcounter
		tweenservice:Create(windowobj.tooltip, tween_tooltip, { BackgroundTransparency = 1 }):Play()
		tweenservice:Create(windowobj._tooltipstroke, tween_tooltip, { Transparency = 1 }):Play()
		tweenservice:Create(windowobj.tooltiplabel, tween_tooltip, { TextTransparency = 1 }):Play()
		task.delay(0.12, function() if windowobj._tooltipcounter == cc then windowobj.tooltip.Visible = false end end)
	end))
	maidobj:GiveTask(instance.AncestryChanged:Connect(function(_, parent)
		if not parent and windowobj._currenttooltipinstance == instance then
			windowobj._currenttooltipinstance = nil
			windowobj.tooltip.Visible = false
			windowobj._tooltipcounter = (windowobj._tooltipcounter or 0) + 1
		end
	end))
end

function lunalibrary:Notify(options)
	options = options or {}
	local title = options.Title or "Notification"
	local desc = options.Description or ""
	local icon = options.Icon or ""
	local time = tonumber(options.Time) or 5
	local notifType = tonumber(options.Type) or 1
	local infinite = not not options.Infinite

	local strokeThemeMap = "Accent"
	if notifType == 2 then 
		strokeThemeMap = "Warning"
	elseif notifType == 3 then
		strokeThemeMap = "Error"
	end
	
	if not self.notifycontainer then
		local targetGui = self.currentwindow and self.currentwindow.gui or get_hui():FindFirstChild("LunaGui")
		if not targetGui then return end
		self.notifycontainer = lunahelpers.Make("Frame", { Size = UDim2.new(0, 300, 1, -40), Position = UDim2.new(1, -20, 0, 20), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1000 }, targetGui)
		lunahelpers.Make("UIListLayout", { Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder }, self.notifycontainer)
	end

	local n_maid = maid.New()
	local notifObj = { _maid = n_maid, _load = 0 }
	
	local n_outer = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 999 }, self.notifycontainer)
	local n_frame = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(1, 320, 0, 0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 1000 }, n_outer)
	lunahelpers.ApplyGradient(n_frame, "BodyLight", "Body")
	
	local n_stroke = lunahelpers.Make("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, n_frame)
	lunahelpers.UpdateThemeMapping(n_stroke, "Color", strokeThemeMap)
	
	local inner = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1001 }, n_frame)
	lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, inner)
	lunahelpers.Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, inner)

	local header = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 1, ZIndex = 1001 }, inner)
	
	local textOffset = 0
	local n_icon
	if icon ~= "" then
		textOffset = 24
		n_icon = lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Image = icon, ImageColor3 = { Theme = "Text" }, ZIndex = 1001 }, header)
	end
	
	local n_title = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -textOffset, 1, 0), Position = UDim2.new(0, textOffset, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = title, TextColor3 = { Theme = "Text" }, TextSize = 13, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1001 }, header)
	lunahelpers.ApplyFont(n_title)
	
	local n_desc = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, Text = desc, TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, LayoutOrder = 2, ZIndex = 1001 }, inner)
	lunahelpers.ApplyFont(n_desc)
	
	local btnContainer
	if notifType == 2 or notifType == 3 then
		local btns = {}
		if notifType == 2 then
			btns = {
				{ Name = "Yes", Callback = options.CallbackYes },
				{ Name = "No", Callback = options.CallbackNo }
			}
		elseif notifType == 3 then
			btns = options.Buttons or {}
			while #btns > 5 do table.remove(btns) end
		end

		if #btns > 0 then
			btnContainer = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 3, ZIndex = 1001 }, inner)
			lunahelpers.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, btnContainer)
		end

		for i, btnData in ipairs(btns) do
			local b = lunahelpers.Make("TextButton", { Size = UDim2.new(1/#btns, -((#btns-1)*6)/#btns, 1, 0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Text = "", LayoutOrder = i, ZIndex = 1002 }, btnContainer)
			lunahelpers.ApplyGradient(b, "BodyLight", "Body", 0.96)
			lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
			local bt = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = btnData.Name or "Button", TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, ZIndex = 1003 }, b)
			lunahelpers.ApplyFont(bt)
			lunahelpers.AddFeedback(n_maid, b)
			
			n_maid:GiveTask(b.MouseButton1Click:Connect(function()
				if btnData.Callback then task.spawn(SafeCall, btnData.Callback) end
				notifObj:Dismiss()
			end))
		end
	end

	local n_barbg = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = { Theme = "Border" }, BorderSizePixel = 0, ZIndex = 1001 }, n_frame)
	local n_bar = lunahelpers.Make("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, ZIndex = 1002 }, n_barbg)
	lunahelpers.UpdateThemeMapping(n_bar, "BackgroundColor3", strokeThemeMap)
	
	tweenservice:Create(n_frame, TweenOut(0.4), { Position = UDim2.new(0, 0, 0, 0) }):Play()

	local dismissed = false
	function notifObj:Dismiss()
		if dismissed then return end
		dismissed = true
		n_maid:DoCleaning()
		
		tweenservice:Create(n_frame, TweenOut(0.4), { Position = UDim2.new(1, 320, 0, 0) }):Play()
		
		task.delay(0.4, function()
			lunahelpers.RemoveThemeEntries(n_outer, true)
			n_outer:Destroy()
		end)
	end
	
	function notifObj:SetLoad(num)
		if dismissed then return end
		num = mathclamp(tonumber(num) or 0, 0, 100)
		self._load = num
		tweenservice:Create(n_bar, tween, { Size = UDim2.new(num / 100, 0, 1, 0) }):Play()
		if infinite and num >= 100 then
			task.delay(0.5, function() self:Dismiss() end)
		end
	end
	
	function notifObj:SetTitle(str)
		if not dismissed then n_title.Text = tostring(str or "") end
	end
	
	function notifObj:SetDescription(str)
		if not dismissed then
			n_desc.Text = tostring(str or "")
		end
	end
	
	function notifObj:SetIcon(newIcon)
		if dismissed then return end
		if newIcon == nil or newIcon == "" then
			if n_icon then
				n_icon.Visible = false
				textOffset = 0
				n_title.Position = UDim2.new(0, textOffset, 0, 0)
				n_title.Size = UDim2.new(1, -textOffset, 1, 0)
			end
		else
			if not n_icon then
				textOffset = 24
				n_icon = lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Image = newIcon, ImageColor3 = { Theme = "Text" }, ZIndex = 1001 }, header)
				n_title.Position = UDim2.new(0, textOffset, 0, 0)
				n_title.Size = UDim2.new(1, -textOffset, 1, 0)
			else
				n_icon.Image = newIcon
				n_icon.Visible = true
			end
		end
	end

	n_maid:GiveTask(n_frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			notifObj:Dismiss()
		end
	end))

	if not infinite then
		tweenservice:Create(n_bar, TweenOut(time), { Size = UDim2.new(1, 0, 1, 0) }):Play()
		task.delay(time, function() notifObj:Dismiss() end)
	end
	
	return notifObj
end

function lunalibrary:CreateWindow()
	local windowobj = {}
	windowobj._maid = maid.New()
	self._maid:GiveTask(windowobj._maid)
	windowobj.tabs = {}
	windowobj.currenttab = nil
	windowobj.isminimized = false
	windowobj.ismaximized = false

	local guiparent = get_hui()
	local gui = lunahelpers.Make("ScreenGui", { Name = "LunaGui", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 2147483647 }, guiparent)
	windowobj.gui = gui
	lunalibrary.currentwindow = windowobj

	local startw, starth = width * 0.85, height * 0.85
	local luna = lunahelpers.Make("CanvasGroup", { Name = "Luna", Size = UDim2.new(0, startw, 0, starth), Position = UDim2.new(0.5, -startw / 2, 0.5, -starth / 2), BackgroundColor3 = { Theme = "Body" }, BackgroundTransparency = 0.4, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 2 }, gui)
	windowobj.luna = luna
	windowobj.mainstroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, luna)
	tweenservice:Create(luna, tween_open, { Size = UDim2.new(0, width, 0, height), Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2), BackgroundTransparency = 0, GroupTransparency = 0 }):Play()
	tweenservice:Create(windowobj.mainstroke, tween_open, { Transparency = 0 }):Play()

	local tooltipframe = lunahelpers.Make("Frame", { Name = "Tooltip", Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 100 }, gui)
	lunahelpers.ApplyGradient(tooltipframe, "BodyLight", "Body")
	local tooltipstroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tooltipframe)
	lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, tooltipframe)
	lunahelpers.Make("UISizeConstraint", { MaxSize = Vector2.new(250, 100) }, tooltipframe)
	local tooltiplabel = lunahelpers.Make("TextLabel", { Name = "TooltipText", Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, TextColor3 = { Theme = "Text" }, TextTransparency = 1, TextSize = 11, Font = Enum.Font.Legacy, TextWrapped = false, RichText = true, ZIndex = 101 }, tooltipframe)
	lunahelpers.ApplyFont(tooltiplabel)
	lunahelpers.Make("UITextSizeConstraint", { MaxTextSize = 11 }, tooltiplabel)
	windowobj.tooltip = tooltipframe
	windowobj.tooltiplabel = tooltiplabel
	windowobj._tooltipstroke = tooltipstroke
	windowobj._tooltipcounter = 0
	windowobj._currenttooltipinstance = nil

	local tabtooltipframe = lunahelpers.Make("Frame", { Name = "TabTooltip", Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY, AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 100 }, gui)
	lunahelpers.ApplyGradient(tabtooltipframe, "BodyLight", "Body")
	local tabtooltipstroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tabtooltipframe)
	lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, tabtooltipframe)
	local tabtooltiplabel = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, TextColor3 = { Theme = "Text" }, TextTransparency = 1, TextSize = 11, Font = Enum.Font.Legacy, TextWrapped = false, ZIndex = 101 }, tabtooltipframe)
	lunahelpers.ApplyFont(tabtooltiplabel)
	windowobj.tabtooltip = tabtooltipframe
	windowobj.tabtooltiplabel = tabtooltiplabel
	windowobj._tabtooltipstroke = tabtooltipstroke
	windowobj._tabtooltipcounter = 0

	local titlebar = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, titlebar_h), BackgroundColor3 = { Theme = "TitleBar" }, BorderSizePixel = 0, ZIndex = 3, _Corner = false }, luna)
	lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = { Theme = "Border" }, BorderSizePixel = 0, ZIndex = 10, _Corner = false }, titlebar)
	local iconoffset = 12
	if default_icon ~= "" then
		lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -26, 0.5, -9), BackgroundTransparency = 1, Image = default_icon, ImageColor3 = { Theme = "ImageColor" }, ZIndex = 4 }, titlebar)
		iconoffset = 34
	end
	local titlelabel = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -160, 1, 0), Position = UDim2.new(0, 80, 0, 0), BackgroundTransparency = 1, Text = default_title, TextColor3 = { Theme = "Text" }, TextSize = 13, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4 }, titlebar)
	lunahelpers.ApplyFont(titlelabel)
	windowobj.titlelabel = titlelabel

	local tl_size, tl_gap, tl_left = 12, 8, 13
	local function MakeBtn(index, icon, basetheme, bghot, bgpress)
		local btn = lunahelpers.Make("ImageButton", { Size = UDim2.new(0, tl_size, 0, tl_size), Position = UDim2.new(0, tl_left + index * (tl_size + tl_gap), 0.5, -tl_size / 2), BackgroundColor3 = { Theme = basetheme }, BorderSizePixel = 0, Image = "", ZIndex = 5, _Corner = UDim.new(1, 0) }, titlebar)
		lunahelpers.Make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Transparency = 0.85, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, btn)
		local sym = lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0.5, -4, 0.5, -4), BackgroundTransparency = 1, Image = icon, ImageColor3 = Color3.fromRGB(20, 20, 20), ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit, ZIndex = 6 }, btn)
		lunahelpers.HoverImg(windowobj._maid, btn, basetheme, bghot, bgpress)
		windowobj._maid:GiveTask(btn.MouseEnter:Connect(function() tweenservice:Create(sym, tween_tooltip, { ImageTransparency = 0.1 }):Play() end))
		windowobj._maid:GiveTask(btn.MouseLeave:Connect(function() tweenservice:Create(sym, tween_tooltip, { ImageTransparency = 1 }):Play() end))
		return btn
	end
	local btnclose = MakeBtn(0, icons.Close, "TrafficClose", "TrafficCloseHover", "TrafficCloseHover")
	local btnmin   = MakeBtn(1, icons.Minimize, "TrafficMin", "TrafficMinHover", nil)
	local btnmax   = MakeBtn(2, icons.Maximize, "TrafficMax", "TrafficMaxHover", nil)

	local gradientframe = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, -titlebar_h), Position = UDim2.new(0, 0, 0, titlebar_h), BorderSizePixel = 0, ZIndex = 1 }, luna)
	lunahelpers.ApplyGradient(gradientframe, "BodyLight", "Body")
	windowobj.gradientframe = gradientframe
	local contentarea = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, -(titlebar_h + (height * 0.13) + 20)), Position = UDim2.new(0, 0, 0, titlebar_h), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, luna)
	windowobj.contentarea = contentarea

	local tabbarcontainer = lunahelpers.Make("Frame", { Name = "TabBarContainer", Size = UDim2.new(0.95, 0, 0.13, 0), Position = UDim2.new(0.5, 0, 0.96, 0), AnchorPoint = Vector2.new(0.5, 1), BorderSizePixel = 0, ZIndex = 20, _Corner = UDim.new(0, 16) }, luna)
	lunahelpers.ApplyGradient(tabbarcontainer)
	lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tabbarcontainer)
	windowobj.tabbarcontainer = tabbarcontainer
	local tabbar = lunahelpers.Make("ScrollingFrame", { Name = "TabBar", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, ZIndex = 20 }, tabbarcontainer)
	lunahelpers.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tabbar)
	lunahelpers.Make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, tabbar)

	local openbtn = lunahelpers.Make("TextButton", { Name = "OpenUI", Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0.5, -50, 0, -30), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 50, Visible = false }, gui)
	local openbtnbg = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 49, _Corner = UDim.new(1, 0) }, openbtn)
	lunahelpers.ApplyGradient(openbtnbg, "BodyLight", "Body")
	local openbtntext = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "Open UI", TextColor3 = { Theme = "Text" }, TextSize = 13, Font = Enum.Font.Legacy, ZIndex = 51, TextTransparency = 1 }, openbtn)
	lunahelpers.ApplyFont(openbtntext)
	local openbtnstroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, openbtnbg)
	local preminsize = UDim2.new(0, width, 0, height)
	local preminpos = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	local openbtndraginput, openbtndragorigin, openbtnorigin, openbtndragged = nil, nil, nil, false

	local function RestoreFromMinimize()
		if not windowobj.isminimized then return end
		windowobj.isminimized = false
		tweenservice:Create(openbtnbg, tween, { BackgroundTransparency = 1 }):Play()
		tweenservice:Create(openbtntext, tween, { TextTransparency = 1 }):Play()
		tweenservice:Create(openbtnstroke, tween, { Transparency = 1 }):Play()
		task.delay(0.22, function() if not windowobj.isminimized then openbtn.Visible = false end end)

		local curp = preminpos
		local curs = preminsize
		local tw, th = curs.X.Offset * 0.85, curs.Y.Offset * 0.85
		luna.Size = UDim2.new(0, tw, 0, th)
		luna.Position = UDim2.new(curp.X.Scale, curp.X.Offset + (curs.X.Offset - tw) / 2, curp.Y.Scale, curp.Y.Offset + (curs.Y.Offset - th) / 2)
		
		luna.Visible = true; luna.GroupTransparency = 1; windowobj.mainstroke.Transparency = 1
		if windowobj.contentarea then windowobj.contentarea.Visible = true end
		if windowobj.gradientframe then windowobj.gradientframe.Visible = true end
		if windowobj.tabbarcontainer then windowobj.tabbarcontainer.Visible = true end
		
		tweenservice:Create(luna, tween_open, { Size = preminsize, Position = preminpos, GroupTransparency = 0 }):Play()
		tweenservice:Create(windowobj.mainstroke, tween_open, { Transparency = 0 }):Play()
	end

	windowobj._maid:GiveTask(openbtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			openbtndraginput = input
			openbtndragorigin = Vector2.new(input.Position.X, input.Position.Y)
			local vp = gui.AbsoluteSize
			openbtnorigin = Vector2.new(openbtn.Position.X.Scale * vp.X + openbtn.Position.X.Offset, openbtn.Position.Y.Scale * vp.Y + openbtn.Position.Y.Offset)
			openbtndragged = false
		end
	end))
	windowobj._maid:GiveTask(userinputservice.InputChanged:Connect(function(input)
		if not openbtndraginput then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local cur = Vector2.new(input.Position.X, input.Position.Y)
			local delta = cur - openbtndragorigin
			if delta.Magnitude > 5 then
				openbtndragged = true
				local vp = gui.AbsoluteSize
				openbtn.Position = UDim2.new(0, mathclamp(openbtnorigin.X + delta.X, 0, vp.X - 100), 0, mathclamp(openbtnorigin.Y + delta.Y, 0, vp.Y - 30))
			end
		end
	end))
	windowobj._maid:GiveTask(userinputservice.InputEnded:Connect(function(input) if input == openbtndraginput then if not openbtndragged then RestoreFromMinimize() end; openbtndraginput = nil end end))

	local activeinput, dragorigin, lunaorigin = nil, nil, nil
	windowobj._maid:GiveTask(titlebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeinput = input
			dragorigin = Vector2.new(input.Position.X, input.Position.Y)
			local vp = gui.AbsoluteSize
			lunaorigin = Vector2.new(luna.Position.X.Scale * vp.X + luna.Position.X.Offset, luna.Position.Y.Scale * vp.Y + luna.Position.Y.Offset)
		end
	end))
	windowobj._maid:GiveTask(userinputservice.InputEnded:Connect(function(input) if input == activeinput then activeinput = nil end end))

	windowobj._maid:GiveTask(runservice.RenderStepped:Connect(function()
		if activeinput then
			local cur = Vector2.new(activeinput.Position.X, activeinput.Position.Y)
			local delta = cur - dragorigin
			local vp = gui.AbsoluteSize
			local fsz = luna.AbsoluteSize
			luna.Position = UDim2.new(0, mathclamp(lunaorigin.X + delta.X, 0, vp.X - fsz.X), 0, mathclamp(lunaorigin.Y + delta.Y, 0, vp.Y - fsz.Y))
		end
		if windowobj.tooltip.Visible and windowobj._currenttooltipinstance then
			local inst = windowobj._currenttooltipinstance
			if not inst:IsDescendantOf(game) then
				windowobj.tooltip.Visible = false
				windowobj._currenttooltipinstance = nil
			else
				local mloc = userinputservice:GetMouseLocation()
				local tts = windowobj.tooltip.AbsoluteSize
				local vp = gui.AbsoluteSize
				local rx = mloc.X + 12
				local ry = mloc.Y + 12
				if rx + tts.X > vp.X then rx = mloc.X - tts.X - 4 end
				if ry + tts.Y > vp.Y then ry = mloc.Y - tts.Y - 4 end
				rx = mathclamp(rx, 0, mathmax(0, vp.X - tts.X))
				ry = mathclamp(ry, 0, mathmax(0, vp.Y - tts.Y))
				windowobj.tooltip.Position = UDim2.new(0, rx, 0, ry)
			end
		end
		if windowobj.tabtooltip.Visible and windowobj._tabtooltipinstance and windowobj._tabtooltipinstance:IsDescendantOf(game) then
			local inst = windowobj._tabtooltipinstance
			local bx = inst.AbsolutePosition.X
			local bw = inst.AbsoluteSize.X
			windowobj.tabtooltip.Position = UDim2.new(0, bx + bw / 2, 0, inst.AbsolutePosition.Y + 8)
		end
	end))

	local savedsize, savedpos
	windowobj._maid:GiveTask(btnclose.MouseButton1Click:Connect(function() lunalibrary:Unload() end))
	windowobj._maid:GiveTask(btnmin.MouseButton1Click:Connect(function() windowobj:Toggle() end))
	windowobj._maid:GiveTask(btnmax.MouseButton1Click:Connect(function()
		local icon = btnmax:FindFirstChildOfClass("ImageLabel")
		local vp = gui.AbsoluteSize
		if windowobj.ismaximized then
			tweenservice:Create(luna, tween, { Size = savedsize, Position = savedpos }):Play()
			windowobj.ismaximized = false
			if icon then icon.Image = icons.Maximize end
		else
			if windowobj.isminimized then
				windowobj.isminimized = false
				if windowobj.contentarea then windowobj.contentarea.Visible = true end
				if windowobj.gradientframe then windowobj.gradientframe.Visible = true end
				if windowobj.tabbarcontainer then windowobj.tabbarcontainer.Visible = true end
			end
			savedsize = luna.Size; savedpos = luna.Position
			tweenservice:Create(luna, tween, { Size = UDim2.new(0, vp.X, 0, vp.Y), Position = UDim2.new(0, 0, 0, 0) }):Play()
			windowobj.ismaximized = true
			if icon then icon.Image = icons.Unmaximize end
		end
	end))

	function windowobj:SetTitle(text) if self.titlelabel then self.titlelabel.Text = tostring(text or "") end end
	function windowobj:GetTitle() return self.titlelabel and self.titlelabel.Text or "" end
	function windowobj:SetSize(x, y)
		local curx, cury = self.luna.Size.X.Offset, self.luna.Size.Y.Offset
		x = x and mathclamp(tonumber(x) or curx, 100, 4096) or curx
		y = y and mathclamp(tonumber(y) or cury, titlebar_h, 4096) or cury
		tweenservice:Create(self.luna, tween, { Size = UDim2.new(0, x, 0, y) }):Play()
	end
	function windowobj:GetSize() return self.luna.Size.X.Offset, self.luna.Size.Y.Offset end

	function windowobj:Toggle()
		if self.isminimized then RestoreFromMinimize() return end
		self.isminimized = true
		preminsize = luna.Size; preminpos = luna.Position
		local curp = luna.Position
		local curs = luna.Size
		local tw, th = curs.X.Offset * 0.85, curs.Y.Offset * 0.85
		tweenservice:Create(luna, tween_open, { GroupTransparency = 1, Size = UDim2.new(0, tw, 0, th), Position = UDim2.new(curp.X.Scale, curp.X.Offset + (curs.X.Offset - tw) / 2, curp.Y.Scale, curp.Y.Offset + (curs.Y.Offset - th) / 2) }):Play()
		tweenservice:Create(windowobj.mainstroke, tween_open, { Transparency = 1 }):Play()
		task.delay(0.35, function()
			if self.isminimized then
				luna.Visible = false; openbtn.Visible = true; openbtn.Position = UDim2.new(0.5, -50, 0, -30)
				tweenservice:Create(openbtn, tween, { Position = UDim2.new(0.5, -50, 0, 8) }):Play()
				tweenservice:Create(openbtnbg, tween, { BackgroundTransparency = 0 }):Play()
				tweenservice:Create(openbtntext, tween, { TextTransparency = 0 }):Play()
				tweenservice:Create(openbtnstroke, tween, { Transparency = 0 }):Play()
			end
		end)
	end

	function windowobj:AddTab(options)
		options = options or {}
		local name = type(options) == "string" and options or options.Name or "Tab"
		local icon = type(options) == "table" and options.Icon or ""
		local tabobj = { _maid = maid.New(), _contentmaid = maid.New() }
		self._maid:GiveTask(tabobj._maid)
		tabobj._maid:GiveTask(tabobj._contentmaid)
		local btn = lunahelpers.Make("TextButton", { Name = name .. "Tab", Size = UDim2.new(0, 44, 0, 44), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "", ZIndex = 21, _Corner = UDim.new(0, 10) }, tabbar)
		local function UpdateTabBtnSize()
			local s = mathmax(30, tabbar.AbsoluteSize.Y - 8)
			btn.Size = UDim2.new(0, s, 0, s)
		end
		UpdateTabBtnSize()
		tabobj._maid:GiveTask(tabbar:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTabBtnSize))
		lunahelpers.Make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, btn)
		lunahelpers.ApplyGradient(btn, "BodyLight", "BodyLight")
		lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, btn)
		local overlay = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 21, _Corner = UDim.new(0, 10) }, btn)
		
		tabobj._maid:GiveTask(btn.MouseEnter:Connect(function()
			tweenservice:Create(overlay, tween, { BackgroundTransparency = 0.94 }):Play()
			windowobj._tabtooltipcounter = (windowobj._tabtooltipcounter or 0) + 1
			windowobj._tabtooltipinstance = btn
			windowobj.tabtooltiplabel.Text = name
			windowobj.tabtooltip.Visible = true
			
			local bx = btn.AbsolutePosition.X
			local bw = btn.AbsoluteSize.X
			local targetY = btn.AbsolutePosition.Y + 8
			windowobj.tabtooltip.Position = UDim2.new(0, bx + bw / 2, 0, targetY)
			
			tweenservice:Create(windowobj.tabtooltip, tween_tooltip, { BackgroundTransparency = 0 }):Play()
			tweenservice:Create(windowobj._tabtooltipstroke, tween_tooltip, { Transparency = 0 }):Play()
			tweenservice:Create(windowobj.tabtooltiplabel, tween_tooltip, { TextTransparency = 0 }):Play()
		end))
		
		tabobj._maid:GiveTask(btn.MouseLeave:Connect(function()
			tweenservice:Create(overlay, tween, { BackgroundTransparency = 1 }):Play()
			windowobj._tabtooltipcounter = (windowobj._tabtooltipcounter or 0) + 1
			if windowobj._tabtooltipinstance == btn then windowobj._tabtooltipinstance = nil end
			local cc = windowobj._tabtooltipcounter
			tweenservice:Create(windowobj.tabtooltip, tween_tooltip, { BackgroundTransparency = 1 }):Play()
			tweenservice:Create(windowobj._tabtooltipstroke, tween_tooltip, { Transparency = 1 }):Play()
			tweenservice:Create(windowobj.tabtooltiplabel, tween_tooltip, { TextTransparency = 1 }):Play()
			task.delay(0.12, function() if windowobj._tabtooltipcounter == cc then windowobj.tabtooltip.Visible = false end end)
		end))

		tabobj._maid:GiveTask(btn.AncestryChanged:Connect(function(_, parent)
			if not parent and windowobj._tabtooltipinstance == btn then
				windowobj._tabtooltipinstance = nil
				windowobj.tabtooltip.Visible = false
				windowobj._tabtooltipcounter = (windowobj._tabtooltipcounter or 0) + 1
			end
		end))
		
		tabobj._maid:GiveTask(btn.MouseButton1Down:Connect(function() tweenservice:Create(overlay, tween, { BackgroundTransparency = 0.88 }):Play() end))
		tabobj._maid:GiveTask(btn.MouseButton1Up:Connect(function() tweenservice:Create(overlay, tween, { BackgroundTransparency = 0.94 }):Play() end))
		
		if icon ~= "" then lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Image = icon, ImageColor3 = { Theme = "ImageColor" }, ScaleType = Enum.ScaleType.Fit, ZIndex = 22 }, btn)
		else local txt = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 1, BorderSizePixel = 0, Text = stringsub(name, 1, 1), TextColor3 = { Theme = "Text" }, TextSize = 16, Font = Enum.Font.Legacy, ZIndex = 22 }, btn); lunahelpers.ApplyFont(txt) end

		local tabcanvas = lunahelpers.Make("CanvasGroup", { Name = name .. "Canvas", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 2 }, contentarea)
		local emptylabel = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "This Tab is Empty! :(", TextColor3 = { Theme = "TextDim" }, TextSize = 16, Font = Enum.Font.Legacy, ZIndex = 5 }, tabcanvas)
		lunahelpers.ApplyFont(emptylabel)
		local colscont = lunahelpers.Make("Frame", { Size = UDim2.new(1, -32, 1, -24), Position = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, BorderSizePixel = 0 }, tabcanvas)
		lunahelpers.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }, colscont)
		local function MakeCol(order)
			local col = lunahelpers.Make("ScrollingFrame", { Size = UDim2.new(0.5, -4, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = { Theme = "Border" }, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, LayoutOrder = order }, colscont)
			lunahelpers.Make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, col)
			lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 4) }, col)
			return col
		end
		local leftcol, rightcol = MakeCol(1), MakeCol(2)
		windowobj.tabs[name] = tabcanvas
		if not windowobj.currenttab then tabcanvas.Visible = true; tabcanvas.GroupTransparency = 0; windowobj.currenttab = tabcanvas end

		tabobj._maid:GiveTask(btn.MouseButton1Click:Connect(function()
			if windowobj.currenttab == tabcanvas then return end
			for _, canvas in windowobj.tabs do if canvas ~= tabcanvas then canvas.GroupTransparency = 1; canvas.Visible = false end end
			tabcanvas.Visible = true; tabcanvas.Position = UDim2.new(0, 0, 0, -10); tabcanvas.GroupTransparency = 1
			tweenservice:Create(tabcanvas, tween, { GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }):Play()
			windowobj.currenttab = tabcanvas
		end))

		function tabobj:Clean()
			self._contentmaid:DoCleaning()
			for _, col in {leftcol, rightcol} do
				for _, child in col:GetChildren() do
					if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then lunahelpers.RemoveThemeEntries(child, true); child:Destroy() end
				end
			end
			self._hasmain = false
			if emptylabel then emptylabel.Visible = true end
		end
		
		function tabobj:Remove()
			self:Clean()
			self._maid:Destroy()
			lunahelpers.RemoveThemeEntries(btn, true)
			btn:Destroy()
			lunahelpers.RemoveThemeEntries(tabcanvas, true)
			tabcanvas:Destroy()
			if windowobj.tabs[name] == tabcanvas then windowobj.tabs[name] = nil end
			if windowobj.currenttab == tabcanvas then windowobj.currenttab = nil; windowobj.tabtooltip.Visible = false end
		end

		function tabobj:SetMain()
			if self._hasmain then return end
			self._hasmain = true
			if emptylabel then emptylabel.Visible = false end
			local infoframe = lunahelpers.Make("Frame", { Name = "Info", Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, LayoutOrder = -10, ZIndex = 3 }, leftcol)
			lunahelpers.ApplyGradient(infoframe, "BodyLight", "Body", 0.98); lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, infoframe); lunahelpers.Make("UIPadding", { PaddingRight = UDim.new(0, 32) }, infoframe)
			local pfp = lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 42, 0, 42), Position = UDim2.new(0, 10, 0.5, -21), BackgroundTransparency = 1, BorderSizePixel = 0, Image = "", ZIndex = 4 }, infoframe)
			
			local dispName = player and player.DisplayName or "Unknown"
			local realName = player and player.Name or "Unknown"
			local dnl = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 16), Position = UDim2.new(0, 62, 0, 13), BackgroundTransparency = 1, BorderSizePixel = 0, Text = dispName, TextColor3 = { Theme = "Text" }, TextSize = 14, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4 }, infoframe); lunahelpers.ApplyFont(dnl)
			local unl = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 62, 0, 29), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "@" .. realName, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4 }, infoframe); lunahelpers.ApplyFont(unl)
			task.spawn(function()
				if not player then return end
				local ok, c = pcall(players.GetUserThumbnailAsync, players, player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				if ok and c then pfp.Image = c end
			end)

			local gameframe = lunahelpers.Make("Frame", { Name = "Game", Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, LayoutOrder = -9, ZIndex = 3 }, leftcol)
			lunahelpers.ApplyGradient(gameframe, "BodyLight", "Body", 0.98); lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, gameframe); lunahelpers.Make("UIPadding", { PaddingRight = UDim.new(0, 32) }, gameframe)
			local gamepfp = lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 42, 0, 42), Position = UDim2.new(0, 10, 0.5, -21), BackgroundTransparency = 1, BorderSizePixel = 0, Image = "", ZIndex = 4 }, gameframe)
			local gnl = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 16), Position = UDim2.new(0, 62, 0, 13), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Loading...", TextColor3 = { Theme = "Text" }, TextSize = 14, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4 }, gameframe); lunahelpers.ApplyFont(gnl)
			local gcl = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 62, 0, 29), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "By ...", TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4 }, gameframe); lunahelpers.ApplyFont(gcl)
			task.spawn(function()
				local ok, info = pcall(marketplaceservice.GetProductInfo, marketplaceservice, game.PlaceId)
				if ok and info then
					gnl.Text = info.Name
					gcl.Text = info.Creator and ("By " .. info.Creator.Name) or "By Unknown"
					gamepfp.Image = (info.IconImageAssetId and info.IconImageAssetId > 0) and ("rbxassetid://" .. info.IconImageAssetId) or ("rbxthumb://type=Asset&id=" .. tostring(game.PlaceId) .. "&w=150&h=150")
				else
					gnl.Text = game.Name
					gcl.Text = "By Unknown"
				end
			end)

			local pingframe = lunahelpers.Make("Frame", { Name = "PingModal", Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, LayoutOrder = -10, ZIndex = 3 }, rightcol)
			lunahelpers.ApplyGradient(pingframe, "BodyLight", "Body", 0.98); lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, pingframe)
			local pt = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 10, 0, 6), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Ping", TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, pingframe); lunahelpers.ApplyFont(pt)
			local pv = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -20, 0, 32), Position = UDim2.new(0, 10, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "0 ms", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 28, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4 }, pingframe); lunahelpers.ApplyFont(pv)

			local fpsframe = lunahelpers.Make("Frame", { Name = "FPSModal", Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, LayoutOrder = -9, ZIndex = 3 }, rightcol)
			lunahelpers.ApplyGradient(fpsframe, "BodyLight", "Body", 0.98); lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, fpsframe)
			local ft = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 10, 0, 6), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "FPS", TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, fpsframe); lunahelpers.ApplyFont(ft)
			local fv = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -20, 0, 32), Position = UDim2.new(0, 10, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "0", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 28, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4 }, fpsframe); lunahelpers.ApplyFont(fv)

			local lastupdate = osclock()
			local frames = 0
			self._contentmaid:GiveTask(runservice.Heartbeat:Connect(function()
				frames += 1
				local now = osclock()
				if now - lastupdate >= 1 then
					fv.Text = tostring(frames)
					fv.TextColor3 = (frames < 10 and Color3.fromRGB(255, 0, 0)) or (frames < 30 and Color3.fromRGB(255, 85, 0)) or (frames < 40 and Color3.fromRGB(255, 170, 0)) or (frames < 50 and Color3.fromRGB(255, 215, 0)) or (frames < 120 and Color3.fromRGB(0, 255, 0)) or Color3.fromRGB(0, 170, 255)
					local png = player and mathround(player:GetNetworkPing() * 1000) or 0
					pv.Text = tostring(png) .. " ms"
					pv.TextColor3 = (png >= 1000 and Color3.fromRGB(255, 0, 0)) or (png >= 500 and Color3.fromRGB(255, 85, 0)) or (png >= 300 and Color3.fromRGB(255, 170, 0)) or (png >= 200 and Color3.fromRGB(255, 215, 0)) or (png >= 70 and Color3.fromRGB(0, 255, 0)) or Color3.fromRGB(0, 170, 255)
					frames = 0; lastupdate = now
				end
			end))
		end

		function tabobj:SetHome() self:SetMain() end

		local function CountSectionChildren(col)
			local n = 0
			for _, child in col:GetChildren() do
				if child:IsA("Frame") or child:IsA("ScrollingFrame") then
					n += 1
				end
			end
			return n
		end

		function tabobj:AddSection(options)
			options = options or {}
			local secname = type(options) == "string" and options or options.Name or "Section"
			local side = type(options) == "table" and type(options.Side) == "string" and stringlower(options.Side) or ""
			if side ~= "left" and side ~= "right" then
				if CountSectionChildren(leftcol) <= CountSectionChildren(rightcol) then side = "left" else side = "right" end
			end
			local sectionobj = { tabs = {}, _maid = maid.New() }
			self._contentmaid:GiveTask(sectionobj._maid)
			if emptylabel then emptylabel.Visible = false end
			local parentcol = side == "right" and rightcol or leftcol
			local secframe = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y }, parentcol)
			lunahelpers.ApplyGradient(secframe, "BodyLight", "Body", 0.98); lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, secframe)
			lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, secframe)
			lunahelpers.Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, secframe)
			local sectitle = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1, BorderSizePixel = 0, Text = secname, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1, Visible = true }, secframe); lunahelpers.ApplyFont(sectitle)
			
			local sectabbar = lunahelpers.Make("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, LayoutOrder = 2, Visible = false }, secframe)
			lunahelpers.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, sectabbar)
			lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }, sectabbar)
			
			local secline = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, LayoutOrder = 3, Visible = false }, secframe)
			local seccc = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4 }, secframe)

			function sectionobj:AddTab(options)
				options = options or {}
				local elname = type(options) == "string" and options or options.Name or "Tab"
				local tco = { container = nil, _maid = maid.New() }
				self._maid:GiveTask(tco._maid)
				local elbtn = lunahelpers.Make("TextButton", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = { Theme = "Body" }, BorderSizePixel = 0, Text = elname, TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy }, sectabbar); lunahelpers.ApplyFont(elbtn)
				lunahelpers.Make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, elbtn)
				lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, elbtn)
				local tc = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, Visible = false }, seccc)
				lunahelpers.Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tc)
				local secel = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "This Tab is Empty! :(", TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center }, tc); lunahelpers.ApplyFont(secel)
				tco.container = tc
				lunahelpers.ApplyTooltip(tco._maid, elbtn, elname, windowobj)
				
				local function AttachKeybindLogic(maidToUse, parent, size, pos, anchor, zindex, default, touchenabled, callback)
					local kbo = { _maid = maid.New() }; maidToUse:GiveTask(kbo._maid)
					local btn = lunahelpers.Make("TextButton", { Size = size, Position = pos, AnchorPoint = anchor, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = zindex }, parent)
					lunahelpers.ApplyGradient(btn, "BodyLight", "Body", 0.95)
					kbo.Button = btn
					local stroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, btn)
					local valText = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "None", TextColor3 = { Theme = "Text" }, TextScaled = true, Font = Enum.Font.Legacy, ZIndex = zindex + 1 }, btn); lunahelpers.ApplyFont(valText)
					lunahelpers.Make("UITextSizeConstraint", { MaxTextSize = 11 }, valText)
					
					local currentKey = nil
					local disabled = false
					local isBinding = false
					local isTouch = userinputservice.TouchEnabled and not userinputservice.MouseEnabled
					
					function kbo:SetValue(key)
						if disabled then return end
						if key == nil or key == "None" then currentKey = nil; valText.Text = "None"
						elseif typeof(key) == "EnumItem" then currentKey = key; valText.Text = key.Name
						elseif type(key) == "string" then
							local s, r = pcall(function() return Enum.KeyCode[key] end)
							if s and r then currentKey = r; valText.Text = r.Name else currentKey = nil; valText.Text = "None" end
						end
						if not isBinding then
							lunahelpers.UpdateThemeMapping(valText, "TextColor3", "Text")
						end
					end
					
					kbo:SetValue(default)
					if isTouch and not touchenabled then kbo:SetValue(default) end
					
					function kbo:GetValue() return currentKey and currentKey.Name or "None" end
					function kbo:Disable() self:SetDisabled(true) end
					function kbo:Enable() self:SetDisabled(false) end
					function kbo:SetDisabled(val)
						disabled = not not val
						if disabled then
							isBinding = false
							lunahelpers.UpdateThemeMapping(stroke, "Color", "Border")
							lunahelpers.UpdateThemeMapping(valText, "TextColor3", "Border")
						else
							lunahelpers.UpdateThemeMapping(stroke, "Color", "Accent")
							lunahelpers.UpdateThemeMapping(valText, "TextColor3", "Text")
							kbo:SetValue(currentKey)
						end
					end
					function kbo:Remove() kbo._maid:Destroy(); lunahelpers.RemoveThemeEntries(btn, true); btn:Destroy() end
					
					kbo._maid:GiveTask(btn.MouseButton1Click:Connect(function()
						if disabled then return end
						if isTouch and not touchenabled then return end
						if isTouch and touchenabled then task.spawn(SafeCall, callback); return end
						isBinding = true; valText.Text = "..."; lunahelpers.UpdateThemeMapping(valText, "TextColor3", "Accent"); lunahelpers.UpdateThemeMapping(stroke, "Color", "Accent")
					end))
					
					kbo._maid:GiveTask(userinputservice.InputBegan:Connect(function(input, gp)
						if disabled then return end
						if isBinding then
							if input.UserInputType == Enum.UserInputType.Keyboard then
								local k = input.KeyCode
								if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Backspace then kbo:SetValue(nil) else kbo:SetValue(k) end
								isBinding = false
								lunahelpers.UpdateThemeMapping(valText, "TextColor3", "Text")
								lunahelpers.UpdateThemeMapping(stroke, "Color", "Accent")
							end
						else
							if not gp and currentKey and input.KeyCode == currentKey then
								task.spawn(SafeCall, callback)
							end
						end
					end))
					return kbo
				end
				
				function tco:HideEmpty() secel.Visible = false end

				function tco:AddKeybind(options)
					options = options or {}
					local kbname = options.Name or "Keybind"
					local flag = options.Flag or kbname
					local default = options.Default or "None"
					local touchenabled = options.TouchEnabled == nil and true or options.TouchEnabled
					local callback = options.Callback
					local tooltip = options.Tooltip
					self:HideEmpty()
					local kbo = { _maid = maid.New() }; self._maid:GiveTask(kbo._maid)
					local kbf = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local kbl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = kbname, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, kbf); lunahelpers.ApplyFont(kbl)
					local _tip = tooltip
					lunahelpers.ApplyTooltip(kbo._maid, kbf, function() return _tip or "" end, windowobj)
					local core = AttachKeybindLogic(kbo._maid, kbf, UDim2.new(0, 24, 0, 24), UDim2.new(1, -2, 0.5, 0), Vector2.new(1, 0.5), 5, default, touchenabled, callback)
					
					function kbo:SetValue(v) core:SetValue(v) end
					function kbo:GetValue() return core:GetValue() end
					function kbo:Disable() core:Disable(); lunahelpers.UpdateThemeMapping(kbl, "TextColor3", "Border") end
					function kbo:Enable() core:Enable(); lunahelpers.UpdateThemeMapping(kbl, "TextColor3", "TextDim") end
					function kbo:SetText(t) kbl.Text = tostring(t or "") end
					function kbo:SetTooltip(t) _tip = t end
					function kbo:Remove() if lunalibrary.flags[flag] == kbo then lunalibrary.flags[flag] = nil end; kbo._maid:Destroy(); lunahelpers.RemoveThemeEntries(kbf, true); kbf:Destroy() end
					
					lunalibrary.flags[flag] = kbo
					return kbo
				end

				function tco:AddToggle(options)
					options = options or {}
					local togglename = options.Name or "Toggle"
					local flag = options.Flag or togglename
					local cb = options.Callback
					local tooltip = options.Tooltip
					self:HideEmpty()
					local t = { _maid = maid.New() }; self._maid:GiveTask(t._maid)
					local tf = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, self.container)
					local tt = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = togglename, TextColor3 = { Theme = "TextDim" }, TextSize = 14, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tf); lunahelpers.ApplyFont(tt)
					local cbFrame = lunahelpers.Make("Frame", { Size = UDim2.new(0, 38, 0, 22), Position = UDim2.new(1, -2, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = { Theme = "Body" }, BorderSizePixel = 0, ZIndex = 3, _Corner = UDim.new(1, 0) }, tf)
					local cbs = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, cbFrame)
					local cm = lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(250, 250, 252), BackgroundTransparency = 0, BorderSizePixel = 0, Image = "", ZIndex = 4, _Corner = UDim.new(1, 0) }, cbFrame)
					lunahelpers.Make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Transparency = 0.8, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, cm)
					local clk = lunahelpers.Make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", ZIndex = 5 }, tf)
					local state, disabled = false, false; local _tip = tooltip
					lunahelpers.ApplyTooltip(t._maid, tf, function() if disabled then return "This Function Is Disabled! :(" end; return _tip or "" end, windowobj)
					lunalibrary.flags[flag] = t
					function t:SetValue(val) if disabled then return end; state = not not val; tweenservice:Create(cm, tween, { Position = state and UDim2.new(0, 18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }):Play(); if state then lunahelpers.UpdateThemeMapping(cbFrame, "BackgroundColor3", "Accent"); lunahelpers.UpdateThemeMapping(cbs, "Color", "Accent"); lunahelpers.UpdateThemeMapping(tt, "TextColor3", "Text"); else lunahelpers.UpdateThemeMapping(cbFrame, "BackgroundColor3", "Body"); lunahelpers.UpdateThemeMapping(cbs, "Color", "Border"); lunahelpers.UpdateThemeMapping(tt, "TextColor3", "TextDim"); end; task.spawn(SafeCall, cb, state) end
					function t:SetDisabled(val) val = not not val; disabled = val; lunahelpers.UpdateThemeMapping(tt, "TextColor3", val and "Border" or (state and "Text" or "TextDim")); lunahelpers.UpdateThemeMapping(cbs, "Color", "Border"); lunahelpers.UpdateThemeMapping(cbFrame, "BackgroundColor3", val and "BodyLight" or (state and "Accent" or "Body")) end
					function t:SetText(val) tt.Text = tostring(val or "") end
					function t:GetValue() return state end
					function t:SetTooltip(text) _tip = text end
					function t:Disable() self:SetDisabled(true) end
					function t:Enable() self:SetDisabled(false) end
					function t:Remove() if lunalibrary.flags[flag] == t then lunalibrary.flags[flag] = nil end; t._maid:Destroy(); lunahelpers.RemoveThemeEntries(tf, true); tf:Destroy() end
					
					function t:AddKeybind(keybindOptions)
						keybindOptions = keybindOptions or {}
						local default = keybindOptions.Default or "None"
						local touchenabled = keybindOptions.TouchEnabled == nil and true or keybindOptions.TouchEnabled
						local callback = keybindOptions.Callback or function() if not disabled then t:SetValue(not state) end end
						
						cbFrame.Position = UDim2.new(1, -34, 0.5, 0)
						tt.Size = UDim2.new(1, -80, 1, 0)
						return AttachKeybindLogic(t._maid, tf, UDim2.new(0, 24, 0, 24), UDim2.new(1, -2, 0.5, 0), Vector2.new(1, 0.5), 10, default, touchenabled, callback)
					end
					
					t._maid:GiveTask(clk.MouseButton1Click:Connect(function() if not disabled then t:SetValue(not state) end end))
					if options.Default then t:SetValue(true) end
					return t
				end

				function tco:AddButton(options)
					options = options or {}
					local btnname = options.Name or "Button"
					local callback = options.Callback
					local tooltip = options.Tooltip
					self:HideEmpty()
					local bo = { _maid = maid.New() }; self._maid:GiveTask(bo._maid)
					local bc = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					lunahelpers.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, bc)
					
					local btnList = {}
					local keybindCount = 0
					
					local function UpdateLayout()
						local N = #btnList
						local K = keybindCount
						if N == 0 then return end
						local totalFixed = ((N + K - 1) * 6) + (K * 24)
						local offset = math.floor(totalFixed / N)
						for _, b in btnList do
							b.Size = UDim2.new(1/N, -offset, 1, 0)
						end
					end

					local function ConstructBtn(text, ccb, tip, layoutOrder)
						local bf = lunahelpers.Make("TextButton", { Size = UDim2.new(1, 0, 1, 0), LayoutOrder = layoutOrder, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 2 }, bc)
						table.insert(btnList, bf)
						UpdateLayout()
						
						lunahelpers.ApplyGradient(bf, "BodyLight", "Body", 0.96)
						lunahelpers.AddFeedback(bo._maid, bf)
						local bs = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, bf)
						local bt = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = text, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, bf); lunahelpers.ApplyFont(bt)
						local dis, isdang, isconf = false, false, false; local origtext = text
						local o = { _maid = maid.New() }; bo._maid:GiveTask(o._maid)
						local _tip = tip
						lunahelpers.ApplyTooltip(o._maid, bf, function() if dis then return "This Function Is Disabled! :(" end; return _tip or "" end, windowobj)
						
						function o:ForceFire() if not dis then task.spawn(SafeCall, ccb) end end
						function o:Disable() self:SetDisabled(true) end
						function o:Enable() self:SetDisabled(false) end
						function o:SetDisabled(val) dis = not not val; if not isconf then lunahelpers.UpdateThemeMapping(bt, "TextColor3", dis and "Border" or "Text") end; lunahelpers.UpdateThemeMapping(bs, "Color", "Border") end
						function o:SetText(val) origtext = tostring(val or ""); if not isconf then bt.Text = origtext end end
						function o:SetTooltip(val) _tip = val end
						function o:MakeDangerous() isdang = true end
						function o:Remove() 
							o._maid:Destroy()
							for i, b in btnList do if b == bf then table.remove(btnList, i) break end end
							lunahelpers.RemoveThemeEntries(bf, true); bf:Destroy()
							UpdateLayout()
						end
						
						function o:AddKeybind(keybindOptions)
							keybindOptions = keybindOptions or {}
							local default = keybindOptions.Default or "None"
							local touchenabled = keybindOptions.TouchEnabled == nil and true or keybindOptions.TouchEnabled
							local keycallback = keybindOptions.Callback or function() if not dis then o:ForceFire() end end
							
							keybindCount = keybindCount + 1
							UpdateLayout()
							local kbo = AttachKeybindLogic(o._maid, bc, UDim2.new(0, 24, 0, 24), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0), 10, default, touchenabled, keycallback)
							kbo.Button.LayoutOrder = layoutOrder + 1
							
							local oldRem = kbo.Remove
							function kbo:Remove()
								keybindCount = keybindCount - 1
								oldRem(self)
								UpdateLayout()
							end
							
							return kbo
						end
						
						o._maid:GiveTask(bf.MouseButton1Click:Connect(function()
							if dis then return end
							if isdang and not isconf then isconf = true; bt.Text = "Are You Sure?"; lunahelpers.UpdateThemeMapping(bt, "TextColor3", "Accent"); task.delay(3, function() if isconf then isconf = false; bt.Text = origtext; lunahelpers.UpdateThemeMapping(bt, "TextColor3", dis and "Border" or "Text") end end); return end
							isconf = false; bt.Text = origtext; if not dis then lunahelpers.UpdateThemeMapping(bt, "TextColor3", "Text") end; o:ForceFire()
						end))
						return o, bf
					end
					
					local button, mbf = ConstructBtn(btnname, callback, tooltip, 10)
					function button:AddSubButton(subOptions) 
						subOptions = subOptions or {}
						local st = subOptions.Name or "Button"
						local sc = subOptions.Callback
						local stt = subOptions.Tooltip
						local sb, sbf = ConstructBtn(st, sc, stt, 30) 
						return sb 
					end
					function button:Remove() bo._maid:Destroy(); lunahelpers.RemoveThemeEntries(bc, true); bc:Destroy() end
					return button
				end

				function tco:AddLabel(options)
					options = options or {}
					local text = options.Text or ""
					local tooltip = options.Tooltip
					self:HideEmpty()
					local lo = { _maid = maid.New() }; self._maid:GiveTask(lo._maid)
					local lbl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, BorderSizePixel = 0, Text = text, TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, RichText = true, TextTruncate = Enum.TextTruncate.AtEnd }, self.container); lunahelpers.ApplyFont(lbl)
					local _tip = tooltip; lunahelpers.ApplyTooltip(lo._maid, lbl, function() return _tip or "" end, windowobj)
					function lo:SetText(val) lbl.Text = tostring(val or "") end
					function lo:SetTooltip(val) _tip = val end
					function lo:Remove() lo._maid:Destroy(); lunahelpers.RemoveThemeEntries(lbl, true); lbl:Destroy() end
					return lo
				end

				function tco:AddSlider(options)
					options = options or {}
					local sn = options.Name or "Slider"
					local flag = options.Flag or sn
					local minv = tonumber(options.Min) or 0
					local maxv = tonumber(options.Max) or 100
					if minv > maxv then minv, maxv = maxv, minv end
					if minv == maxv then maxv = minv + 1 end
					local default = mathclamp(tonumber(options.Default) or minv, minv, maxv)
					local suffix = tostring(options.Suffix or "")
					local rounding = mathclamp(tonumber(options.Rounding) or 0, 0, 10)
					local callback = options.Callback
					local tooltip = options.Tooltip
					self:HideEmpty()
					local so = { _maid = maid.New() }; self._maid:GiveTask(so._maid)
					local sf = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local tl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -50, 0, 14), BackgroundTransparency = 1, BorderSizePixel = 0, Text = sn, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, sf); lunahelpers.ApplyFont(tl)
					local vll = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 50, 0, 14), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextColor3 = { Theme = "Text" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd }, sf); lunahelpers.ApplyFont(vll)
					local sbg = lunahelpers.Make("TextButton", { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 2 }, sf)
					lunahelpers.ApplyGradient(sbg, "BodyLight", "Body", 0.96); lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, sbg)
					local sfl = lunahelpers.Make("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0 }, sbg)
					local cv, isdragging, disabled = default, false, false; local _tip = tooltip; local mult = 10 ^ rounding
					lunahelpers.ApplyTooltip(so._maid, sf, function() if disabled then return "This Function Is Disabled! :(" end; return _tip or "" end, windowobj)
					lunalibrary.flags[flag] = so
					local function Upd(val) val = mathclamp(mathround(val * mult) / mult, minv, maxv); cv = val; local range = maxv - minv; local pct = range > 0 and ((val - minv) / range) or 0; tweenservice:Create(sfl, tween, { Size = UDim2.new(pct, 0, 1, 0) }):Play(); vll.Text = tostring(val) .. suffix; task.spawn(SafeCall, callback, val) end
					Upd(cv)
					so._maid:GiveTask(sbg.InputBegan:Connect(function(input) if disabled then return end; if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isdragging = true; lunahelpers.UpdateThemeMapping(tl, "TextColor3", "Text"); local pct = mathclamp((input.Position.X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1); Upd(minv + (maxv - minv) * pct) end end))
					so._maid:GiveTask(userinputservice.InputEnded:Connect(function(input) if disabled then return end; if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isdragging = false; lunahelpers.UpdateThemeMapping(tl, "TextColor3", "TextDim") end end))
					so._maid:GiveTask(userinputservice.InputChanged:Connect(function(input) if disabled or not isdragging then return end; if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then local pct = mathclamp((input.Position.X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1); Upd(minv + (maxv - minv) * pct) end end))
					function so:SetValue(num) Upd(tonumber(num) or minv) end
					function so:GetValue() return cv end
					function so:SetText(text) tl.Text = tostring(text or "") end
					function so:SetTooltip(val) _tip = val end
					function so:SetDisabled(val) val = not not val; disabled = val; if disabled then lunahelpers.UpdateThemeMapping(tl, "TextColor3", "Border"); lunahelpers.UpdateThemeMapping(vll, "TextColor3", "Border"); lunahelpers.UpdateThemeMapping(sfl, "BackgroundColor3", "Border") else lunahelpers.UpdateThemeMapping(tl, "TextColor3", "TextDim"); lunahelpers.UpdateThemeMapping(vll, "TextColor3", "Text"); lunahelpers.UpdateThemeMapping(sfl, "BackgroundColor3", "Accent") end end
					function so:Disable() self:SetDisabled(true) end
					function so:Enable() self:SetDisabled(false) end
					function so:Remove() if lunalibrary.flags[flag] == so then lunalibrary.flags[flag] = nil end; so._maid:Destroy(); lunahelpers.RemoveThemeEntries(sf, true); sf:Destroy() end
					
					function so:AddKeybind(keybindOptions)
						keybindOptions = keybindOptions or {}
						local keydefault = keybindOptions.Default or "None"
						local touchenabled = keybindOptions.TouchEnabled == nil and true or keybindOptions.TouchEnabled
						local keycallback = keybindOptions.Callback
						
						sbg.Size = UDim2.new(1, -34, 0, 14)
						vll.Position = UDim2.new(1, -84, 0, 0)
						return AttachKeybindLogic(so._maid, sf, UDim2.new(0, 24, 0, 24), UDim2.new(1, -2, 0, 20), Vector2.new(1, 0), 10, keydefault, touchenabled, keycallback)
					end
					
					return so
				end

				function tco:AddTextBox(options)
					options = options or {}
					local tbname = options.Name or "TextBox"
					local flag = options.Flag or tbname
					local placeholder = options.Placeholder or ""
					local isnumerical = not not options.IsNumerical
					local maxchars = tonumber(options.MaxChars)
					if maxchars and maxchars <= 0 then maxchars = nil end
					local clearonfocus = not not options.ClearOnFocus
					local callback = options.Callback
					local tooltip = options.Tooltip
					self:HideEmpty()
					local tbo = { _maid = maid.New() }; self._maid:GiveTask(tbo._maid)
					local tbf = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local tbt = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, BorderSizePixel = 0, Text = tbname, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tbf); lunahelpers.ApplyFont(tbt)
					local tbb = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2 }, tbf); lunahelpers.ApplyGradient(tbb, "BodyLight", "Body", 0.96)
					local tbs = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tbb)
					local tb = lunahelpers.Make("TextBox", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", PlaceholderText = placeholder, TextColor3 = { Theme = "Text" }, PlaceholderColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ClearTextOnFocus = clearonfocus, ZIndex = 3 }, tbb); lunahelpers.ApplyFont(tb)
					local disabled, _isnum, _maxc = false, isnumerical, maxchars; local _tip = tooltip
					lunahelpers.ApplyTooltip(tbo._maid, tbf, function() if disabled then return "This Function Is Disabled! :(" end; return _tip or "" end, windowobj)
					lunalibrary.flags[flag] = tbo
					tbo._maid:GiveTask(tb:GetPropertyChangedSignal("Text"):Connect(function() if disabled then return end; local txt = tb.Text; if _isnum then txt = stringgsub(txt, "[^%d%.%-]", "") end; if _maxc and #txt > _maxc then txt = stringsub(txt, 1, _maxc) end; if tb.Text ~= txt then tb.Text = txt end end))
					tbo._maid:GiveTask(tb.Focused:Connect(function() if disabled then tb:ReleaseFocus(); return end; lunahelpers.UpdateThemeMapping(tbt, "TextColor3", "Text"); lunahelpers.UpdateThemeMapping(tbs, "Color", "Accent") end))
					tbo._maid:GiveTask(tb.FocusLost:Connect(function() lunahelpers.UpdateThemeMapping(tbt, "TextColor3", "TextDim"); lunahelpers.UpdateThemeMapping(tbs, "Color", "Border"); if not disabled then task.spawn(SafeCall, callback, tb.Text) end end))
					function tbo:SetValue(val) tb.Text = tostring(val or "") end
					function tbo:GetValue() return tb.Text end
					function tbo:SetText(val) tbt.Text = tostring(val or "") end
					function tbo:SetPlaceholderText(val) tb.PlaceholderText = tostring(val or "") end
					function tbo:SetTooltip(val) _tip = val end
					function tbo:SetProperties(isnum, maxch, confo) _isnum = not not isnum; _maxc = tonumber(maxch); if _maxc and _maxc <= 0 then _maxc = nil end; if confo ~= nil then tb.ClearTextOnFocus = not not confo end end
					function tbo:SetDisabled(val) val = not not val; disabled = val; tb.TextEditable = not val; if val then lunahelpers.UpdateThemeMapping(tbt, "TextColor3", "Border"); lunahelpers.UpdateThemeMapping(tb, "TextColor3", "Border") else lunahelpers.UpdateThemeMapping(tbt, "TextColor3", "TextDim"); lunahelpers.UpdateThemeMapping(tb, "TextColor3", "Text") end end
					function tbo:Disable() self:SetDisabled(true) end
					function tbo:Enable() self:SetDisabled(false) end
					function tbo:Remove() if lunalibrary.flags[flag] == tbo then lunalibrary.flags[flag] = nil end; tbo._maid:Destroy(); lunahelpers.RemoveThemeEntries(tbf, true); tbf:Destroy() end
					
					function tbo:AddKeybind(keybindOptions)
						keybindOptions = keybindOptions or {}
						local keydefault = keybindOptions.Default or "None"
						local touchenabled = keybindOptions.TouchEnabled == nil and true or keybindOptions.TouchEnabled
						local keycallback = keybindOptions.Callback or function() if not disabled then tb:CaptureFocus() end end
						
						tbb.Size = UDim2.new(1, -34, 0, 24)
						return AttachKeybindLogic(tbo._maid, tbf, UDim2.new(0, 24, 0, 24), UDim2.new(1, -2, 0, 18), Vector2.new(1, 0), 10, keydefault, touchenabled, keycallback)
					end
					
					return tbo
				end

				function tco:AddDropdown(options)
					options = options or {}
					local dpname = options.Name or "Dropdown"
					local flag = options.Flag or dpname
					local items = type(options.Items) == "table" and options.Items or {}
					local updatetime = tonumber(options.UpdateTime) or 0
					local isplayer = not not options.IsPlayer
					local isteam = not not options.IsTeam
					local ismulti = not not options.IsMulti
					local issearchable = not not options.IsSearchable
					local callback = options.Callback
					local tooltip = options.Tooltip
					self:HideEmpty()
					local do_obj = { _maid = maid.New() }; self._maid:GiveTask(do_obj._maid)
					local lm = maid.New(); do_obj._maid:GiveTask(lm)
					local df = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local tb2 = lunahelpers.Make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 2 }, df)
					lunahelpers.ApplyGradient(tb2, "BodyLight", "Body", 0.96)
					local ds = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tb2)
					local dt = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = dpname .. ": None", TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, tb2); lunahelpers.ApplyFont(dt)
					
					local disabled_opts = {}
					local selected = ismulti and {} or nil; local displaynames = {}; local ci = {}
					for _, v in items do ci[#ci + 1] = tostring(v) end
					local disabled, _tip, isopen = false, tooltip, false
					lunahelpers.ApplyTooltip(do_obj._maid, tb2, function() if disabled then return "This Function Is Disabled! :(" end; return _tip or "" end, windowobj)
					lunalibrary.flags[flag] = do_obj
					local fc = lunahelpers.Make("TextButton", { Name = "DropdownOverlay", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Visible = false, ZIndex = 90 }, windowobj.gui); do_obj._maid:GiveTask(fc)
					local ff = lunahelpers.Make("CanvasGroup", { Size = UDim2.new(0, 200, 0, 40), BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 91 }, fc)
					local fb = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 91 }, ff); lunahelpers.ApplyGradient(fb, "BodyLight", "Body", 0.96)
					local fs = lunahelpers.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 1 }, ff)
					local lo = 0; local sb2
					if issearchable then
						sb2 = lunahelpers.Make("TextBox", { Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 6, 0, 6), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", PlaceholderText = "Search...", TextColor3 = { Theme = "Text" }, PlaceholderColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 92 }, ff); lunahelpers.ApplyFont(sb2)
						lunahelpers.Make("Frame", { Size = UDim2.new(1, -12, 0, 1), Position = UDim2.new(0, 6, 0, 32), BackgroundColor3 = { Theme = "Border" }, BorderSizePixel = 0, ZIndex = 92 }, ff); lo = 36
					end
					local fsc = lunahelpers.Make("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -lo - 6), Position = UDim2.new(0, 0, 0, lo + 3), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, ScrollBarImageColor3 = { Theme = "Border" }, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingEnabled = false, ZIndex = 92 }, ff)
					lunahelpers.Make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, fsc); lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, fsc)
					local del = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "This Dropdown is Empty! :(", TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, ZIndex = 93, Visible = false }, fsc); lunahelpers.ApplyFont(del)
					local item_h = 22
					local function Udt()
						local s = ""
						if ismulti then local sl = {}; local sn = 0; for k, v in selected do if v then sn += 1; sl[sn] = displaynames[k] or k end end; s = sn > 0 and tableconcat(sl, ", ") or "None"
						else s = selected and (displaynames[selected] or selected) or "None" end
						dt.Text = dpname .. ": " .. s
					end
					local function Cd()
						if not isopen then return end; isopen = false
						local curp = ff.Position
						local curs = ff.Size
						local sw, sh = curs.X.Offset * 0.85, curs.Y.Offset * 0.85
						tweenservice:Create(ff, tween, { Size = UDim2.new(0, sw, 0, sh), Position = UDim2.new(curp.X.Scale, curp.X.Offset + (curs.X.Offset - sw) / 2, curp.Y.Scale, curp.Y.Offset + (curs.Y.Offset - sh) / 2), GroupTransparency = 1 }):Play()
						tweenservice:Create(fs, tween, { Transparency = 1 }):Play()
						task.delay(0.22, function() if not isopen then fc.Visible = false end end)
					end
					local function Gf(ft) local r = {}; local rn = 0; for _, item in ci do local dn = displaynames[item] or item; if not ft or ft == "" or stringfind(stringlower(dn), stringlower(ft), 1, true) then rn += 1; r[rn] = item end end; return r end
					local function Bl(ft)
						lm:DoCleaning()
						for _, child in fsc:GetChildren() do if child:IsA("TextButton") or (child:IsA("Frame") and child ~= del) then lunahelpers.RemoveThemeEntries(child, true); child:Destroy() end end
						local filtered = Gf(ft); local count = #filtered; del.Visible = (count == 0); fsc.ScrollingEnabled = true; fsc.ScrollBarThickness = count > 6 and 2 or 0
						for idx, item in filtered do
							local dn = displaynames[item] or item
							local is_opt_dis = disabled_opts[item]
							if idx > 1 then lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = { Theme = "Accent" }, BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 93 }, fsc) end
							local issel = ismulti and selected[item] or (selected == item)
							local ib = lunahelpers.Make("TextButton", { Size = UDim2.new(1, 0, 0, item_h), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", ZIndex = 93 }, fsc)
							local il = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = dn, TextColor3 = is_opt_dis and { Theme = "Border" } or (issel and { Theme = "Accent" } or { Theme = "Text" }), TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 94 }, ib); lunahelpers.ApplyFont(il)
							lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -16, 0.5, -6), BackgroundTransparency = 1, BorderSizePixel = 0, Image = "rbxassetid://9754130783", ImageColor3 = { Theme = "Accent" }, Visible = issel, ZIndex = 94 }, ib)
							lm:GiveTask(ib.MouseEnter:Connect(function() if not is_opt_dis then tweenservice:Create(ib, tween_tooltip, { BackgroundTransparency = 0.8 }):Play() end end))
							lm:GiveTask(ib.MouseLeave:Connect(function() if not is_opt_dis then tweenservice:Create(ib, tween_tooltip, { BackgroundTransparency = 1 }):Play() end end))
							lm:GiveTask(ib.MouseButton1Click:Connect(function()
								if is_opt_dis then return end
								if ismulti then selected[item] = not selected[item]; if not selected[item] then selected[item] = nil end
								else if selected == item then selected = nil else selected = item; Cd() end end
								Udt(); task.spawn(SafeCall, callback, selected)
								if isopen and fc.Visible then Bl(sb2 and sb2.Text or "") end
							end))
						end
					end
					function do_obj:Update()
						if isplayer then ci = {}; for _, p in players:GetPlayers() do ci[#ci + 1] = p.Name end
						elseif isteam then ci = {}; for _, t in teams:GetTeams() do ci[#ci + 1] = t.Name end end
						if ismulti then for k, v in selected do if v and not tablefind(ci, k) then selected[k] = nil end end
						else if selected and not tablefind(ci, selected) then selected = nil end end
						Udt(); if fc.Visible then Bl(sb2 and sb2.Text or "") end
					end
					if sb2 then do_obj._maid:GiveTask(sb2:GetPropertyChangedSignal("Text"):Connect(function() Bl(sb2.Text) end)) end
					if updatetime > 0 then local alive = true; do_obj._maid:GiveTask(function() alive = false end); task.spawn(function() while alive do task.wait(updatetime); do_obj:Update() end end) end
					do_obj._maid:GiveTask(tb2.MouseButton1Click:Connect(function()
						if disabled or isopen then return end; isopen = true; fc.Visible = true
						if sb2 then sb2.Text = "" end; do_obj:Update()
						local mloc = userinputservice:GetMouseLocation()
						local windowwidth = windowobj.luna.AbsoluteSize.X
						local windowheight = windowobj.luna.AbsoluteSize.Y
						local th = mathmin(180, windowheight * 0.8)
						local vp = windowobj.gui.AbsoluteSize
						local fw = mathclamp(tb2.AbsoluteSize.X, 160, windowwidth * 0.8)
						local fx, fy = mloc.X, mloc.Y
						if fx + fw > vp.X then fx = vp.X - fw - 4 end
						if fy + th > vp.Y then fy = vp.Y - th - 4 end
						fx = mathmax(4, fx); fy = mathmax(4, fy)
						local sw, sh = fw * 0.85, th * 0.85
						ff.Position = UDim2.new(0, fx + (fw - sw) / 2, 0, fy + (th - sh) / 2); ff.Size = UDim2.new(0, sw, 0, sh); ff.GroupTransparency = 1; fs.Transparency = 1
						Bl("")
						tweenservice:Create(ff, tween, { Size = UDim2.new(0, fw, 0, th), Position = UDim2.new(0, fx, 0, fy), GroupTransparency = 0 }):Play()
						tweenservice:Create(fs, tween, { Transparency = 0 }):Play()
					end))
					do_obj._maid:GiveTask(fc.MouseButton1Click:Connect(Cd))
					function do_obj:AddValue(t) t = type(t) == "table" and t or {}; for _, v in t do ci[#ci + 1] = tostring(v) end; self:Update() end
					function do_obj:EditValue(t) t = type(t) == "table" and t or {}; ci = {}; for _, v in t do ci[#ci + 1] = tostring(v) end; self:Update() end
					function do_obj:RemoveValue(t) t = type(t) == "table" and t or {}; for _, v in t do local i = tablefind(ci, tostring(v)); if i then tableremove(ci, i) end end; self:Update() end
					function do_obj:GetValue() return selected end
					function do_obj:SetValue(val) if ismulti then selected = type(val) == "table" and val or {} else selected = val ~= nil and tostring(val) or nil end; self:Update() end
					function do_obj:EditText(t) t = type(t) == "table" and t or {}; for k, v in t do displaynames[tostring(k)] = tostring(v) end; self:Update() end
					function do_obj:SetTooltip(val) _tip = val end
					function do_obj:SetDisabled(val) disabled = not not val; lunahelpers.UpdateThemeMapping(dt, "TextColor3", disabled and "Border" or "Text"); if disabled and isopen then Cd() end end
					function do_obj:Disable() self:SetDisabled(true) end
					function do_obj:Enable() self:SetDisabled(false) end
					function do_obj:Remove() if lunalibrary.flags[flag] == do_obj then lunalibrary.flags[flag] = nil end; Cd(); do_obj._maid:Destroy(); lunahelpers.RemoveThemeEntries(df, true); df:Destroy() end
					
					function do_obj:DisableOption(t)
						t = type(t) == "table" and t or {t}
						for _, v in t do
							local str_v = tostring(v)
							disabled_opts[str_v] = true
							if ismulti then
								if selected[str_v] then selected[str_v] = nil end
							else
								if selected == str_v then selected = nil end
							end
						end
						self:Update()
					end
					
					function do_obj:EnableOption(t)
						t = type(t) == "table" and t or {t}
						for _, v in t do disabled_opts[tostring(v)] = nil end
						self:Update()
					end
					
					function do_obj:AddKeybind(keybindOptions)
						keybindOptions = keybindOptions or {}
						local keydefault = keybindOptions.Default or "None"
						local touchenabled = keybindOptions.TouchEnabled == nil and true or keybindOptions.TouchEnabled
						local keycallback = keybindOptions.Callback
						
						tb2.Size = UDim2.new(1, -34, 1, 0)
						return AttachKeybindLogic(do_obj._maid, df, UDim2.new(0, 24, 1, 0), UDim2.new(1, -2, 0, 0), Vector2.new(1, 0), 10, keydefault, touchenabled, keycallback)
					end
					
					do_obj:Update()
					return do_obj
				end

				function tco:AddCode(options)
					options = options or {}
					local kbname = options.Name or "MyScript"
					local suffix = options.Suffix or "lua"
					local codeStr = options.Code or ""
					local codeHighlight = options.CodeHighlight == nil and true or options.CodeHighlight
					local writable = not not options.Writable
					local callback = options.Callback
					local tooltip = options.Tooltip
					local flag = options.Flag or kbname

					self:HideEmpty()
					local code_obj = { _maid = maid.New() }; self._maid:GiveTask(code_obj._maid)
					
					local container = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 140), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local containerBg = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 1 }, container)
					lunahelpers.ApplyGradient(containerBg, "BodyLight", "Body", 0.96)
					local containerStroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, containerBg)
					
					local header = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2 }, container)
					lunahelpers.ApplyGradient(header, "BodyLight", "TitleBar")
					lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, ZIndex = 3 }, header)
					
					local titleLbl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = kbname .. "." .. suffix, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, header)
					lunahelpers.ApplyFont(titleLbl)
					
					local copyBtn = lunahelpers.Make("TextButton", { Size = UDim2.new(0, 40, 1, -6), Position = UDim2.new(1, -4, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "", ZIndex = 3, Visible = false }, header)
					lunahelpers.ApplyGradient(copyBtn, "BodyLight", "Body", 0.96)
					lunahelpers.AddFeedback(code_obj._maid, copyBtn)
					local copyBtnStroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, copyBtn)
					local copyBtnTxt = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Copy", TextColor3 = { Theme = "Text" }, TextSize = 10, Font = Enum.Font.Legacy, ZIndex = 4 }, copyBtn)
					lunahelpers.ApplyFont(copyBtnTxt)

					local runBtn = lunahelpers.Make("TextButton", { Size = UDim2.new(0, 40, 1, -6), Position = UDim2.new(1, -48, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "", ZIndex = 3, Visible = false }, header)
					lunahelpers.ApplyGradient(runBtn, "BodyLight", "Body", 0.96)
					lunahelpers.AddFeedback(code_obj._maid, runBtn)
					local runBtnStroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, runBtn)
					local runBtnTxt = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Run", TextColor3 = { Theme = "Text" }, TextSize = 10, Font = Enum.Font.Legacy, ZIndex = 4 }, runBtn)
					lunahelpers.ApplyFont(runBtnTxt)

					local hasLoadstring = lunahelpers.CheckDep("loadstring")
					local hasCopy = lunahelpers.CheckDep("setclipboard")

					local iconImg = nil
					local function UpdateIconAndLayout(lang)
						local lsuf = stringlower(lang or "")
						local isLua = (lsuf == "lua" or lsuf == "luau")
						
						local iconId = ""
						if lsuf == "luau" then iconId = "rbxassetid://92857476264077"
						elseif lsuf == "lua" then iconId = "rbxassetid://131595787434428"
						elseif lsuf == "py" or lsuf == "python" then iconId = "rbxassetid://127951493476985"
						elseif lsuf == "js" or lsuf == "ts" or lsuf == "javascript" or lsuf == "typescript" then iconId = "rbxassetid://120266034170732"
						elseif lsuf == "c" or lsuf == "cpp" or lsuf == "cs" or lsuf == "h" or lsuf == "hpp" then iconId = "rbxassetid://95729917526937"
						end

						local leftOff = 6
						if iconId ~= "" then
							if not iconImg then
								iconImg = lunahelpers.Make("ImageLabel", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 6, 0.5, -6), BackgroundTransparency = 1, BorderSizePixel = 0, Image = iconId, ImageColor3 = { Theme = "Text" }, ScaleType = Enum.ScaleType.Fit, ZIndex = 4 }, header)
							else
								iconImg.Image = iconId
								iconImg.Visible = true
							end
							leftOff = 24
						else
							if iconImg then iconImg.Visible = false end
						end
						
						local rightOff = 4
						if hasCopy then
							copyBtn.Position = UDim2.new(1, -4, 0.5, 0)
							copyBtn.Visible = true
							rightOff = rightOff + 44
						end
						
						if isLua and hasLoadstring then
							local rX = hasCopy and -48 or -4
							runBtn.Position = UDim2.new(1, rX, 0.5, 0)
							runBtn.Visible = true
							rightOff = rightOff + 44
						else
							runBtn.Visible = false
						end
						
						titleLbl.Position = UDim2.new(0, leftOff, 0, 0)
						titleLbl.Size = UDim2.new(1, -(leftOff + rightOff), 1, 0)
					end
					UpdateIconAndLayout(suffix)
					
					local scroll = lunahelpers.Make("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -24), Position = UDim2.new(0, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = { Theme = "Border" }, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 2 }, container)
					lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, scroll)
					
					local textClass = writable and "TextBox" or "TextLabel"
					local textObj = lunahelpers.Make(textClass, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextColor3 = { Theme = "Text" }, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, RichText = true, ZIndex = 3 }, scroll)
					textObj.Font = Enum.Font.Code
					if writable then
						textObj.ClearTextOnFocus = false
						textObj.MultiLine = true
					end
					
					local _tip = tooltip
					lunahelpers.ApplyTooltip(code_obj._maid, container, function() return _tip or "" end, windowobj)
					lunalibrary.flags[flag] = code_obj
					
					local currentRawCode = ""
					local currentHighlightedCode = ""
					local langDef = getLangDef(suffix)
					local disabled = false
					
					function code_obj:ChangeCode(newStr)
						currentRawCode = tostring(newStr or "")
						if codeHighlight then
							currentHighlightedCode = highlightCode(currentRawCode, langDef)
							textObj.Text = currentHighlightedCode
						else
							currentHighlightedCode = currentRawCode
							textObj.Text = currentRawCode
						end
					end
					
					function code_obj:SetValue(val) self:ChangeCode(val) end
					function code_obj:GetValue() return currentRawCode end
					function code_obj:SetText(headerText) titleLbl.Text = tostring(headerText or "") end
					function code_obj:SetTooltip(val) _tip = val end
					function code_obj:SetDisabled(val)
						disabled = not not val
						if writable then textObj.TextEditable = not disabled end
						lunahelpers.UpdateThemeMapping(titleLbl, "TextColor3", disabled and "Border" or "Text")
						lunahelpers.UpdateThemeMapping(copyBtnTxt, "TextColor3", disabled and "Border" or "Text")
						if iconImg then lunahelpers.UpdateThemeMapping(iconImg, "ImageColor3", disabled and "Border" or "Text") end
						if runBtnTxt then lunahelpers.UpdateThemeMapping(runBtnTxt, "TextColor3", disabled and "Border" or "Text") end
					end
					function code_obj:Disable() self:SetDisabled(true) end
					function code_obj:Enable() self:SetDisabled(false) end
					function code_obj:ChangeLanguage(newLang)
						langDef = getLangDef(newLang)
						UpdateIconAndLayout(newLang)
						self:ChangeCode(currentRawCode)
					end
					function code_obj:Remove()
						if lunalibrary.flags[flag] == code_obj then lunalibrary.flags[flag] = nil end
						code_obj._maid:Destroy()
						lunahelpers.RemoveThemeEntries(container, true)
						container:Destroy()
					end
					
					if writable then
						code_obj._maid:GiveTask(textObj.Focused:Connect(function()
							if disabled then textObj:ReleaseFocus(); return end
							lunahelpers.UpdateThemeMapping(containerStroke, "Color", "Accent")
							textObj.Text = currentRawCode
						end))
						code_obj._maid:GiveTask(textObj.FocusLost:Connect(function()
							if disabled then return end
							lunahelpers.UpdateThemeMapping(containerStroke, "Color", "Border")
							local newCode = textObj.Text
							code_obj:ChangeCode(newCode)
							task.spawn(SafeCall, callback, newCode)
						end))
					end
					
					code_obj._maid:GiveTask(copyBtn.MouseButton1Click:Connect(function()
						if disabled then return end
						if set_clip then pcall(set_clip, currentRawCode) end
						copyBtnTxt.Text = "Copied!"
						task.delay(1.5, function()
							if copyBtnTxt.Parent then copyBtnTxt.Text = "Copy" end
						end)
					end))

					code_obj._maid:GiveTask(runBtn.MouseButton1Click:Connect(function()
						if disabled then return end
						if runBtnTxt.Text == "Running..." then return end
						runBtnTxt.Text = "Running..."
						lunahelpers.UpdateThemeMapping(runBtnStroke, "Color", "Accent")
						
						task.spawn(function()
							if load_str then
								local f, err = load_str(currentRawCode)
								if f then
									local s, r = lunamain.SafeCallback(f)
									if s then
										if runBtnTxt.Parent then
											runBtnTxt.Text = "Ran!"
											lunahelpers.UpdateThemeMapping(runBtnStroke, "Color", "Border")
										end
									else
										if runBtnTxt.Parent then
											runBtnTxt.Text = "Error! :("
											lunahelpers.UpdateThemeMapping(runBtnTxt, "TextColor3", "Error")
											lunahelpers.UpdateThemeMapping(runBtnStroke, "Color", "Error")
										end
									end
								else
									if runBtnTxt.Parent then
										runBtnTxt.Text = "Error! :("
										lunahelpers.UpdateThemeMapping(runBtnTxt, "TextColor3", "Error")
										lunahelpers.UpdateThemeMapping(runBtnStroke, "Color", "Error")
									end
									lunalibrary:Notify({ Title = "Syntax Error", Description = tostring(err), Time = 5, Type = 3 })
								end
							else
								if runBtnTxt.Parent then
									runBtnTxt.Text = "N/A"
								end
								lunalibrary:Notify({ Title = "Execution Error", Description = "loadstring is not supported by your executor.", Time = 5, Type = 3 })
							end
							
							task.delay(1.5, function()
								if runBtnTxt.Parent then 
									runBtnTxt.Text = "Run"
									lunahelpers.UpdateThemeMapping(runBtnTxt, "TextColor3", "Text")
									if runBtnStroke.Color == colors.Error then
										lunahelpers.UpdateThemeMapping(runBtnStroke, "Color", "Border")
									end
								end
							end)
						end)
					end))
					
					code_obj:ChangeCode(codeStr)
					return code_obj
				end

				function tco:AddViewportFrame(options)
					options = options or {}
					local name = options.Name or "Viewport"
					local models = type(options.Models) == "table" and options.Models or (options.Models and {options.Models} or {})
					local camPos = options.CameraPosition or CFrame.new(0, 5, 10)
					local fov = options.FieldOfView or 70
					local ambient = options.Ambient or Color3.fromRGB(200, 200, 200)
					local lightColor = options.LightColor or Color3.fromRGB(255, 255, 255)
					local lightDir = options.LightDirection or Vector3.new(-1, -1, -1)
					local height = tonumber(options.Height) or 140
					local tooltip = options.Tooltip
					local flag = options.Flag or name
					local rotatable = not not options.Rotatable
					local rotateSensitivity = tonumber(options.RotateSensitivity) or 0.0085

					self:HideEmpty()
					local vpo = { _maid = maid.New() }; self._maid:GiveTask(vpo._maid)

					local container = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local containerBg = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 1 }, container)
					lunahelpers.ApplyGradient(containerBg, "BodyLight", "Body", 0.96)
					local containerStroke = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, containerBg)

					local header = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2 }, container)
					lunahelpers.ApplyGradient(header, "BodyLight", "TitleBar")
					lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, ZIndex = 3 }, header)

					local titleLbl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = name, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, header)
					lunahelpers.ApplyFont(titleLbl)

					local vpf = lunahelpers.Make("ViewportFrame", { Size = UDim2.new(1, 0, 1, -24), Position = UDim2.new(0, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, Ambient = ambient, LightColor = lightColor, LightDirection = lightDir, Active = true, ZIndex = 2 }, container)
					local world = lunahelpers.Make("WorldModel", { Name = "ViewportWorld" }, vpf)

					local cam = Instance.new("Camera")
					cam.FieldOfView = fov
					cam.CFrame = camPos
					cam.Parent = vpf
					vpf.CurrentCamera = cam

					local orbitTarget = Vector3.new(0, 0, 0)
					local orbitDistance = mathmax((typeof(camPos) == "CFrame" and camPos.Position or Vector3.new(0, 0, 0)).Magnitude, 6)
					local orbitYaw = 0
					local orbitPitch = 0
					local function GetBounds(inst)
						if not inst then return nil end
						if inst:IsA("Model") then
							local ok, cf, size = pcall(inst.GetBoundingBox, inst)
							if ok and cf and size then
								return cf.Position, size
							end
						elseif inst:IsA("BasePart") then
							return inst.Position, inst.Size
						end
						return nil
					end
					local function SyncOrbitFromCamera(cf)
						if typeof(cf) ~= "CFrame" then return end
						local offset = cf.Position - orbitTarget
						local dist = offset.Magnitude
						if dist < 0.001 then dist = orbitDistance end
						orbitDistance = dist
						orbitYaw = math.atan(offset.X, offset.Z)
						orbitPitch = math.asin(mathclamp(offset.Y / dist, -0.9999, 0.9999))
					end
					local function ApplyOrbitCamera()
						if not rotatable then return end
						local cosPitch = math.cos(orbitPitch)
						local offset = Vector3.new(
							math.sin(orbitYaw) * cosPitch * orbitDistance,
							math.sin(orbitPitch) * orbitDistance,
							math.cos(orbitYaw) * cosPitch * orbitDistance
						)
						cam.CFrame = CFrame.lookAt(orbitTarget + offset, orbitTarget)
					end
					local function RefreshOrbit()
						local found = false
						local minv, maxv
						for _, child in world:GetChildren() do
							local pos, size = GetBounds(child)
							if pos and size then
								local half = size * 0.5
								local cmin = pos - half
								local cmax = pos + half
								if not found then
									minv = cmin
									maxv = cmax
									found = true
								else
									minv = Vector3.new(mathmin(minv.X, cmin.X), mathmin(minv.Y, cmin.Y), mathmin(minv.Z, cmin.Z))
									maxv = Vector3.new(mathmax(maxv.X, cmax.X), mathmax(maxv.Y, cmax.Y), mathmax(maxv.Z, cmax.Z))
								end
							end
						end
						if found then
							orbitTarget = (minv + maxv) * 0.5
							local size = maxv - minv
							local maxAxis = mathmax(size.X, size.Y, size.Z)
							orbitDistance = mathmax(maxAxis * 1.65, 6)
						else
							orbitTarget = Vector3.new(0, 0, 0)
							orbitDistance = mathmax((typeof(camPos) == "CFrame" and camPos.Position or Vector3.new(0, 0, 0)).Magnitude, 6)
						end
						if rotatable then
							if typeof(camPos) == "CFrame" then
								SyncOrbitFromCamera(camPos)
							end
							ApplyOrbitCamera()
						else
							cam.CFrame = camPos
						end
					end
					local function SetCameraInternal(cf, nfov)
						if cf then
							camPos = cf
							if rotatable and typeof(cf) == "CFrame" then
								SyncOrbitFromCamera(cf)
								ApplyOrbitCamera()
							else
								cam.CFrame = cf
							end
						end
						if nfov then cam.FieldOfView = nfov end
					end

					local _tip = tooltip
					lunahelpers.ApplyTooltip(vpo._maid, container, function() return _tip or "" end, windowobj)
					lunalibrary.flags[flag] = vpo
					local disabled = false
					local dragging = false
					local dragInput = nil
					local dragStart = nil
					local dragYaw = 0
					local dragPitch = 0

					function vpo:SetModels(newModels)
						self:Clear()
						local tbl = type(newModels) == "table" and newModels or (newModels and {newModels} or {})
						for _, m in tbl do
							if typeof(m) == "Instance" then
								local cloned = m:Clone()
								if cloned then cloned.Parent = world end
							end
						end
						RefreshOrbit()
					end

					function vpo:Clear()
						for _, child in world:GetChildren() do
							child:Destroy()
						end
						RefreshOrbit()
					end

					function vpo:SetCamera(cf, nfov)
						SetCameraInternal(cf, nfov)
					end

					function vpo:SetLighting(amb, lCol, lDir)
						if amb then vpf.Ambient = amb end
						if lCol then vpf.LightColor = lCol end
						if lDir then vpf.LightDirection = lDir end
					end

					function vpo:IsRotatable(val)
						if val == nil then return rotatable end
						rotatable = not not val
						if rotatable then
							RefreshOrbit()
						else
							cam.CFrame = camPos
						end
						return rotatable
					end

					function vpo:SetHeight(nh) container.Size = UDim2.new(1, 0, 0, nh) end
					function vpo:GetViewport() return vpf end
					function vpo:GetCamera() return cam end

					function vpo:SetText(t) titleLbl.Text = tostring(t or "") end
					function vpo:SetTooltip(t) _tip = t end
					function vpo:SetDisabled(val)
						disabled = not not val
						lunahelpers.UpdateThemeMapping(titleLbl, "TextColor3", disabled and "Border" or "Text")
					end
					function vpo:Disable() self:SetDisabled(true) end
					function vpo:Enable() self:SetDisabled(false) end
					function vpo:Remove()
						if lunalibrary.flags[flag] == vpo then lunalibrary.flags[flag] = nil end
						vpo._maid:Destroy()
						lunahelpers.RemoveThemeEntries(container, true)
						container:Destroy()
					end

					vpo._maid:GiveTask(vpf.InputBegan:Connect(function(input)
						if not rotatable or disabled then return end
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							dragInput = input
							dragStart = Vector2.new(input.Position.X, input.Position.Y)
							dragYaw = orbitYaw
							dragPitch = orbitPitch
						end
					end))
					vpo._maid:GiveTask(userinputservice.InputChanged:Connect(function(input)
						if not dragging or not dragInput or disabled or not rotatable then return end
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
							orbitYaw = dragYaw - (delta.X * rotateSensitivity)
							orbitPitch = mathclamp(dragPitch - (delta.Y * rotateSensitivity), -1.35, 1.35)
							ApplyOrbitCamera()
						end
					end))
					vpo._maid:GiveTask(userinputservice.InputEnded:Connect(function(input)
						if input == dragInput then
							dragging = false
							dragInput = nil
							dragStart = nil
						end
					end))

					vpo:SetModels(models)
					return vpo
				end

				function tco:AddImage(options)
					options = options or {}
					local name = options.Name or "Image"
					local image = options.Image or ""
					local height = tonumber(options.Height) or 140
					local scaleType = options.ScaleType or Enum.ScaleType.Fit
					local tooltip = options.Tooltip
					local flag = options.Flag or name
					
					self:HideEmpty()
					local imo = { _maid = maid.New() }; self._maid:GiveTask(imo._maid)
					
					local container = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local containerBg = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 1 }, container)
					lunahelpers.ApplyGradient(containerBg, "BodyLight", "Body", 0.96)
					lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, containerBg)
					
					local header = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2 }, container)
					lunahelpers.ApplyGradient(header, "BodyLight", "TitleBar")
					lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, ZIndex = 3 }, header)
					
					local titleLbl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = name, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, header)
					lunahelpers.ApplyFont(titleLbl)
					
					local img = lunahelpers.Make("ImageLabel", { Size = UDim2.new(1, -12, 1, -36), Position = UDim2.new(0, 6, 0, 30), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Image = image, ScaleType = scaleType, ZIndex = 2 }, container)
					
					local _tip = tooltip
					lunahelpers.ApplyTooltip(imo._maid, container, function() return _tip or "" end, windowobj)
					lunalibrary.flags[flag] = imo
					local disabled = false
					
					function imo:SetImage(newImage) img.Image = tostring(newImage or "") end
					function imo:GetImage() return img.Image end
					function imo:SetScaleType(st) if st then img.ScaleType = st end end
					function imo:SetHeight(nh) container.Size = UDim2.new(1, 0, 0, tonumber(nh) or height) end
					function imo:GetImageLabel() return img end
					function imo:SetValue(val) self:SetImage(val) end
					function imo:GetValue() return img.Image end
					function imo:SetText(t) titleLbl.Text = tostring(t or "") end
					function imo:SetTooltip(t) _tip = t end
					function imo:SetDisabled(val)
						disabled = not not val
						lunahelpers.UpdateThemeMapping(titleLbl, "TextColor3", disabled and "Border" or "Text")
						tweenservice:Create(img, tween, { ImageTransparency = disabled and 0.6 or 0 }):Play()
					end
					function imo:Disable() self:SetDisabled(true) end
					function imo:Enable() self:SetDisabled(false) end
					function imo:Remove()
						if lunalibrary.flags[flag] == imo then lunalibrary.flags[flag] = nil end
						imo._maid:Destroy()
						lunahelpers.RemoveThemeEntries(container, true)
						container:Destroy()
					end
					
					return imo
				end

				function tco:AddColorpicker(options)
					options = options or {}
					local cpname = options.Name or "Colorpicker"
					local flag = options.Flag or cpname
					local default = options.Default or options.Color or Color3.fromRGB(255, 255, 255)
					if typeof(default) ~= "Color3" then default = Color3.fromRGB(255, 255, 255) end
					local callback = options.Callback
					local tooltip = options.Tooltip
					self:HideEmpty()
					local cpo = { _maid = maid.New() }; self._maid:GiveTask(cpo._maid)

					local cpf = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local cpl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, -34, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = cpname, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, cpf); lunahelpers.ApplyFont(cpl)
					local swatch = lunahelpers.Make("TextButton", { Size = UDim2.new(0, 23, 0, 23), Position = UDim2.new(1, -2, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = default, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 2 }, cpf)
					local swatchStroke = lunahelpers.Make("UIStroke", { Color = colors.Accent, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 0.5 }, swatch)
					local swatchOverlay = lunahelpers.Make("Frame", { Name = "OpenButtonGradient", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = swatch.ZIndex + 1 }, swatch)
					lunahelpers.Make("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.7) }), Rotation = 90 }, swatchOverlay)
					local t = lunalibrary.themeableobjects; t[#t + 1] = { Obj = swatchStroke, Prop = "Color", ColorName = "Accent" }

					local disabled = false
					local _tip = tooltip
					lunahelpers.ApplyTooltip(cpo._maid, cpf, function() if disabled then return "This Function Is Disabled! :(" end return _tip or "" end, windowobj)
					lunalibrary.flags[flag] = cpo

					local hue, sat, val = default:ToHSV()
					local committed = default
					local currentMode = "RGB"
					local isopen = false
					local dragTarget = nil
					local dragOccurred = false
					local function CurrentColor() return Color3.fromHSV(hue, sat, val) end

					local fc = lunahelpers.Make("TextButton", { Name = "ColorpickerOverlay", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Visible = false, ZIndex = 95 }, windowobj.gui); cpo._maid:GiveTask(fc)
					local cg = lunahelpers.Make("CanvasGroup", { Size = UDim2.new(0, 320, 0, 230), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 96 }, fc)
					local cgStroke = lunahelpers.Make("UIStroke", { Color = colors.Accent, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 1 }, cg)
					local t2 = lunalibrary.themeableobjects; t2[#t2 + 1] = { Obj = cgStroke, Prop = "Color", ColorName = "Accent" }
					local body = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 96 }, cg); lunahelpers.ApplyGradient(body, "BodyLight", "Body", 0.96)
					lunahelpers.Make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, body)

					local titleLbl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, BorderSizePixel = 0, Text = cpname, TextColor3 = { Theme = "Text" }, TextSize = 13, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 97 }, body); lunahelpers.ApplyFont(titleLbl)

					local leftCol = lunahelpers.Make("Frame", { Size = UDim2.new(0.42, -6, 1, -22), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, body)
					local rightCol = lunahelpers.Make("Frame", { Size = UDim2.new(0.58, -6, 1, -22), Position = UDim2.new(0.42, 6, 0, 22), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, body)

					local switcher = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, leftCol)
					lunahelpers.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, switcher)
					local modeBtns = {}
					local SetMode
					local modeOrder = { "RGB", "HSV", "HEX" }
					for i, m in ipairs(modeOrder) do
						local mb = lunahelpers.Make("TextButton", { Size = UDim2.new(1 / 3, -((2) * 4) / 3, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 97 }, switcher)
						lunahelpers.ApplyGradient(mb, "BodyLight", "Body", 0.96)
						local mbs = lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, mb)
						local mbl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = m, TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, ZIndex = 98 }, mb); lunahelpers.ApplyFont(mbl)
						modeBtns[m] = { Stroke = mbs, Label = mbl }
						cpo._maid:GiveTask(mb.MouseButton1Click:Connect(function() SetMode(m) end))
					end

					local rows = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, -28), Position = UDim2.new(0, 0, 0, 28), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, leftCol)
					lunahelpers.Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, rows)
					local boxLbls, boxes = {}, {}
					for i = 1, 3 do
						local row = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 97 }, rows)
						local rl = lunahelpers.Make("TextLabel", { Size = UDim2.new(0, 26, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 98 }, row); lunahelpers.ApplyFont(rl)
						local bf = lunahelpers.Make("Frame", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 97 }, row)
						lunahelpers.ApplyGradient(bf, "BodyLight", "Body", 0.96)
						lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, bf)
						local tbx = lunahelpers.Make("TextBox", { Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", ClearTextOnFocus = false, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 98 }, bf); lunahelpers.ApplyFont(tbx)
						boxLbls[i] = rl; boxes[i] = tbx
					end

					local svSquare = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, -54), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromHSV(hue, 1, 1), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 97 }, rightCol)
					lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, svSquare)
					local svBgGradient = lunahelpers.Make("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 0.95)) }), Rotation = 90 }, svSquare)
					local satLayer = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 97 }, svSquare)
					lunahelpers.Make("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1)), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Rotation = 0 }, satLayer)
					local valLayer = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 98 }, svSquare)
					lunahelpers.Make("UIGradient", { Color = ColorSequence.new(Color3.new(0, 0, 0)), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }), Rotation = 90 }, valLayer)
					local darkOverlay = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 98 }, svSquare)
					lunahelpers.Make("UIGradient", { Color = ColorSequence.new(Color3.new(0, 0, 0)), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.7) }), Rotation = 0 }, darkOverlay)
					local svPointerInitColor = val > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
					local svPointer = lunahelpers.Make("Frame", { Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(sat, 0, 1 - val, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 99 }, svSquare)
					lunahelpers.Make("UICorner", { CornerRadius = UDim.new(1, 0) }, svPointer)
					local svPointerStroke = lunahelpers.Make("UIStroke", { Color = svPointerInitColor, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, svPointer)

					local hueStrip = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -30), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 97 }, rightCol)
					lunahelpers.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, hueStrip)
					lunahelpers.Make("UIGradient", { Rotation = 0, Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
						ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
						ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
						ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
						ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
						ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
					}) }, hueStrip)
					local huePointer = lunahelpers.Make("Frame", { Size = UDim2.new(0, 4, 1, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(hue, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 98 }, hueStrip)
					lunahelpers.Make("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, huePointer)

					local btnRow = lunahelpers.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, rightCol)
					lunahelpers.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, btnRow)
					local function MakeActionBtn(text, order, accent)
						local b = lunahelpers.Make("TextButton", { Size = UDim2.new(0.5, -3, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = order, ZIndex = 97 }, btnRow)
						lunahelpers.ApplyGradient(b, "BodyLight", "Body", 0.96)
						lunahelpers.Make("UIStroke", { Color = { Theme = accent and "Accent" or "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
						local bl = lunahelpers.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = text, TextColor3 = { Theme = accent and "Accent" or "Text" }, TextSize = 11, Font = Enum.Font.Legacy, ZIndex = 98 }, b); lunahelpers.ApplyFont(bl)
						lunahelpers.AddFeedback(cpo._maid, b)
						return b
					end
					local cancelBtn = MakeActionBtn("Cancel", 1, false)
					local applyBtn = MakeActionBtn("Apply", 2, true)

					local function ToHex(c) return stringformat("%02X", mathround(c.R * 255)), stringformat("%02X", mathround(c.G * 255)), stringformat("%02X", mathround(c.B * 255)) end
					local function UpdateBoxes()
						local c = CurrentColor()
						if currentMode == "RGB" then
							boxLbls[1].Text = "R"; boxLbls[2].Text = "G"; boxLbls[3].Text = "B"
							boxes[1].Text = tostring(mathround(c.R * 255)); boxes[2].Text = tostring(mathround(c.G * 255)); boxes[3].Text = tostring(mathround(c.B * 255))
						elseif currentMode == "HSV" then
							boxLbls[1].Text = "H"; boxLbls[2].Text = "S"; boxLbls[3].Text = "V"
							boxes[1].Text = tostring(mathround(hue * 360)); boxes[2].Text = tostring(mathround(sat * 100)); boxes[3].Text = tostring(mathround(val * 100))
						else
							boxLbls[1].Text = "RR"; boxLbls[2].Text = "GG"; boxLbls[3].Text = "BB"
							local rr, gg, bb = ToHex(c); boxes[1].Text = rr; boxes[2].Text = gg; boxes[3].Text = bb
						end
					end
					local function Render(skipBoxes)
						local c = CurrentColor()
						local hueColor = Color3.fromHSV(hue, 1, 1)
						local darkerHueColor = Color3.fromHSV(hue, 1, 0.95)
						svSquare.BackgroundColor3 = hueColor
						svBgGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hueColor), ColorSequenceKeypoint.new(1, darkerHueColor) })
						svPointer.Position = UDim2.new(mathclamp(sat, 0, 1), 0, 1 - mathclamp(val, 0, 1), 0)
						local pointerTargetColor = val > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
						tweenservice:Create(svPointerStroke, tween, { Color = pointerTargetColor }):Play()
						huePointer.Position = UDim2.new(mathclamp(hue, 0, 1), 0, 0.5, 0)
						swatch.BackgroundColor3 = c
						if not skipBoxes then UpdateBoxes() end
					end
					SetMode = function(m)
						currentMode = m
						for key, refs in modeBtns do
							local on = key == m
							lunahelpers.UpdateThemeMapping(refs.Stroke, "Color", on and "Accent" or "Border")
							lunahelpers.UpdateThemeMapping(refs.Label, "TextColor3", on and "Accent" or "TextDim")
						end
						UpdateBoxes()
					end
					local function HexPair(t)
						local clean = stringgsub(stringupper(tostring(t or "")), "[^0-9A-F]", "")
						if clean == "" then return 0 end
						return mathclamp(tonumber(stringsub(clean, 1, 2), 16) or 0, 0, 255)
					end
					local function CommitBoxes()
						if currentMode == "RGB" then
							local r = mathclamp(mathfloor(tonumber(boxes[1].Text) or 0), 0, 255)
							local g = mathclamp(mathfloor(tonumber(boxes[2].Text) or 0), 0, 255)
							local b = mathclamp(mathfloor(tonumber(boxes[3].Text) or 0), 0, 255)
							hue, sat, val = Color3.fromRGB(r, g, b):ToHSV()
						elseif currentMode == "HSV" then
							hue = mathclamp(tonumber(boxes[1].Text) or 0, 0, 360) / 360
							sat = mathclamp(tonumber(boxes[2].Text) or 0, 0, 100) / 100
							val = mathclamp(tonumber(boxes[3].Text) or 0, 0, 100) / 100
						else
							hue, sat, val = Color3.fromRGB(HexPair(boxes[1].Text), HexPair(boxes[2].Text), HexPair(boxes[3].Text)):ToHSV()
						end
						Render()
					end
					for _, tbx in ipairs(boxes) do
						cpo._maid:GiveTask(tbx.FocusLost:Connect(function() CommitBoxes() end))
					end

					local function SetSVFromInput(pos)
						local ap, as = svSquare.AbsolutePosition, svSquare.AbsoluteSize
						if as.X <= 0 or as.Y <= 0 then return end
						sat = mathclamp((pos.X - ap.X) / as.X, 0, 1)
						val = 1 - mathclamp((pos.Y - ap.Y) / as.Y, 0, 1)
						Render()
					end
					local function SetHueFromInput(pos)
						local ap, as = hueStrip.AbsolutePosition, hueStrip.AbsoluteSize
						if as.X <= 0 then return end
						hue = mathclamp((pos.X - ap.X) / as.X, 0, 1)
						Render()
					end
					cpo._maid:GiveTask(svSquare.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragTarget = "sv"; dragOccurred = false; SetSVFromInput(input.Position) end
					end))
					cpo._maid:GiveTask(hueStrip.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragTarget = "hue"; dragOccurred = false; SetHueFromInput(input.Position) end
					end))
					cpo._maid:GiveTask(userinputservice.InputChanged:Connect(function(input)
						if not dragTarget then return end
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							dragOccurred = true
							if dragTarget == "sv" then SetSVFromInput(input.Position) elseif dragTarget == "hue" then SetHueFromInput(input.Position) end
						end
					end))
					cpo._maid:GiveTask(userinputservice.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragTarget = nil
							task.defer(function() dragOccurred = false end)
						end
					end))

					local function Close()
						if not isopen then return end
						isopen = false; dragTarget = nil; dragOccurred = false
						tweenservice:Create(swatchStroke, tween, { Transparency = 0.5 }):Play()
						local s = cg.Size
						tweenservice:Create(cg, tween, { GroupTransparency = 1, Size = UDim2.new(0, s.X.Offset * 0.9, 0, s.Y.Offset * 0.9) }):Play()
						tweenservice:Create(cgStroke, tween, { Transparency = 1 }):Play()
						task.delay(0.22, function() if not isopen then fc.Visible = false end end)
					end
					local function Open()
						if disabled or isopen then return end
						isopen = true; fc.Visible = true
						hue, sat, val = committed:ToHSV()
						tweenservice:Create(swatchStroke, tween, { Transparency = 0 }):Play()
						local lw, lh = windowobj.luna.AbsoluteSize.X, windowobj.luna.AbsoluteSize.Y
						local lp = windowobj.luna.AbsolutePosition
						local w = mathclamp(lw * 0.62, 225, 290)
						local h = mathclamp(lh * 0.60, 165, 215)
						local cx = lp.X + lw / 2
						local cy = lp.Y + lh / 2
						cg.Position = UDim2.new(0, cx, 0, cy)
						cg.Size = UDim2.new(0, w * 0.9, 0, h * 0.9); cg.GroupTransparency = 1; cgStroke.Transparency = 1
						SetMode(currentMode); Render()
						tweenservice:Create(cg, tween, { Size = UDim2.new(0, w, 0, h), GroupTransparency = 0 }):Play()
						tweenservice:Create(cgStroke, tween, { Transparency = 0 }):Play()
					end
					cpo._maid:GiveTask(swatch.MouseButton1Click:Connect(Open))
					cpo._maid:GiveTask(fc.MouseButton1Click:Connect(function()
						if dragOccurred then return end
						local mp = userinputservice:GetMouseLocation()
						local cp, cs = cg.AbsolutePosition, cg.AbsoluteSize
						if mp.X >= cp.X and mp.X <= cp.X + cs.X and mp.Y >= cp.Y and mp.Y <= cp.Y + cs.Y then return end
						hue, sat, val = committed:ToHSV(); swatch.BackgroundColor3 = committed; Close()
					end))
					cpo._maid:GiveTask(cancelBtn.MouseButton1Click:Connect(function()
						hue, sat, val = committed:ToHSV(); swatch.BackgroundColor3 = committed; Close()
					end))
					cpo._maid:GiveTask(applyBtn.MouseButton1Click:Connect(function()
						committed = CurrentColor(); swatch.BackgroundColor3 = committed; task.spawn(SafeCall, callback, committed); Close()
					end))

					function cpo:GetValue() return committed end
					function cpo:GetValueRGB() return mathround(committed.R * 255), mathround(committed.G * 255), mathround(committed.B * 255) end
					function cpo:GetValueHex() local rr, gg, bb = ToHex(committed); return rr .. gg .. bb end
					function cpo:SetValue(v, silent, skipRender)
						local c
						if typeof(v) == "Color3" then c = v
						elseif type(v) == "table" then c = Color3.fromRGB(mathclamp(tonumber(v[1] or v.R or v.r) or 0, 0, 255), mathclamp(tonumber(v[2] or v.G or v.g) or 0, 0, 255), mathclamp(tonumber(v[3] or v.B or v.b) or 0, 0, 255))
						elseif type(v) == "string" then
							local clean = stringgsub(stringupper(v), "[^0-9A-F]", "")
							if #clean >= 6 then c = Color3.fromRGB(tonumber(stringsub(clean, 1, 2), 16) or 0, tonumber(stringsub(clean, 3, 4), 16) or 0, tonumber(stringsub(clean, 5, 6), 16) or 0) end
						end
						c = c or committed
						committed = c; hue, sat, val = c:ToHSV(); swatch.BackgroundColor3 = c
						if isopen and not skipRender then Render() end
						if not silent then task.spawn(SafeCall, callback, c) end
					end
					function cpo:SetText(t) cpl.Text = tostring(t or "") end
					function cpo:SetTooltip(t) _tip = t end
					function cpo:SetDisabled(v)
						disabled = not not v
						lunahelpers.UpdateThemeMapping(cpl, "TextColor3", disabled and "Border" or "TextDim")
						swatch.BackgroundTransparency = disabled and 0.5 or 0
						tweenservice:Create(swatchStroke, tween, { Transparency = disabled and 0.85 or (isopen and 0 or 0.5) }):Play()
						if disabled and isopen then Close() end
					end
					function cpo:Disable() self:SetDisabled(true) end
					function cpo:Enable() self:SetDisabled(false) end
					function cpo:Remove()
						if lunalibrary.flags[flag] == cpo then lunalibrary.flags[flag] = nil end
						Close(); cpo._maid:Destroy()
						lunahelpers.RemoveThemeEntries(fc, true); fc:Destroy()
						lunahelpers.RemoveThemeEntries(cpf, true); cpf:Destroy()
					end

					function cpo:AddKeybind(keybindOptions)
						keybindOptions = keybindOptions or {}
						local keydefault = keybindOptions.Default or "None"
						local touchenabled = keybindOptions.TouchEnabled == nil and true or keybindOptions.TouchEnabled
						local keycallback = keybindOptions.Callback or function() if not disabled then Open() end end
						swatch.Position = UDim2.new(1, -36, 0.5, 0)
						cpl.Size = UDim2.new(1, -68, 1, 0)
						return AttachKeybindLogic(cpo._maid, cpf, UDim2.new(0, 23, 0, 23), UDim2.new(1, -2, 0.5, 0), Vector2.new(1, 0.5), 10, keydefault, touchenabled, keycallback)
					end

					UpdateBoxes()
					return cpo
				end

				tableinsert(sectionobj.tabs, { Button = elbtn, Container = tc, TabContentObj = tco })
				if #sectionobj.tabs == 1 then sectitle.Visible = true; sectabbar.Visible = false; secline.Visible = false; tc.Visible = true; lunahelpers.UpdateThemeMapping(elbtn, "TextColor3", "Text"); lunahelpers.UpdateThemeMapping(elbtn, "BackgroundColor3", "BodyLight"); sectionobj.currenttab = tc
				else sectitle.Visible = false; sectabbar.Visible = true; secline.Visible = true end
				sectionobj._maid:GiveTask(elbtn.MouseButton1Click:Connect(function()
					if sectionobj.currenttab == tc then return end
					for _, td in sectionobj.tabs do td.Container.Visible = false; lunahelpers.UpdateThemeMapping(td.Button, "TextColor3", "TextDim"); lunahelpers.UpdateThemeMapping(td.Button, "BackgroundColor3", "Body") end
					tc.Visible = true; lunahelpers.UpdateThemeMapping(elbtn, "TextColor3", "Text"); lunahelpers.UpdateThemeMapping(elbtn, "BackgroundColor3", "BodyLight"); sectionobj.currenttab = tc
				end))
				return tco
			end

			function sectionobj:AddKeybind(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddKeybind(opts) end
			function sectionobj:AddToggle(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddToggle(opts) end
			function sectionobj:AddButton(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddButton(opts) end
			function sectionobj:AddLabel(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddLabel(opts) end
			function sectionobj:AddSlider(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddSlider(opts) end
			function sectionobj:AddTextBox(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddTextBox(opts) end
			function sectionobj:AddDropdown(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddDropdown(opts) end
			function sectionobj:AddCode(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddCode(opts) end
			function sectionobj:AddViewportFrame(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddViewportFrame(opts) end
			function sectionobj:AddImage(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddImage(opts) end
			function sectionobj:AddColorpicker(opts) if #self.tabs == 0 then self:AddTab({Name = "Default"}) end return self.tabs[1].TabContentObj:AddColorpicker(opts) end
			return sectionobj
		end

		function tabobj:LoadThemeManager()
			local sec = self:AddSection({ Name = "Theme Management", Side = "Right" })
			local dp = sec:AddDropdown({ Name = "Selected Theme", Items = lunalibrary:GetFiles("Theme"), IsSearchable = true, Tooltip = "Select a theme.", Flag = "SelectedThemeDP" })
			task.spawn(function() local lf = {}; while task.wait(1) do if not dp._maid or dp._maid._destroyed then break end; local cf = lunalibrary:GetFiles("Theme"); local ch = false; if #lf ~= #cf then ch = true else for i, v in lf do if cf[i] ~= v then ch = true; break end end end; if ch then lf = cf; local c = dp:GetValue(); dp:EditValue(cf); dp:SetValue(c) end end end)
			local tbb = sec:AddTextBox({ Name = "Theme Name", Placeholder = "MyTheme", Tooltip = "Name for saving.", Flag = "ThemeManagerName" })
			local sv = sec:AddButton({ Name = "Save Theme", Callback = function() local n = tbb:GetValue(); if n == "" then n = "MyTheme" end; lunalibrary:SaveTheme(n) end, Tooltip = "Save current colors to new file." })
			sv:AddSubButton({ Name = "Load Theme", Callback = function() local n = dp:GetValue(); if n then lunalibrary:LoadTheme(n) end end })
			local ow = sec:AddButton({ Name = "Overwrite Theme", Callback = function() local n = dp:GetValue(); if n then lunalibrary:SaveTheme(n) end end, Tooltip = "Overwrite selected theme." })
			ow:AddSubButton({ Name = "Duplicate Theme", Callback = function() local n = dp:GetValue(); if n then lunalibrary:DuplicateFile("Theme", n) end end })
			local ab = sec:AddButton({ Name = "Set Autoload", Callback = function() local n = dp:GetValue(); if n then lunalibrary:SetThemeAutoload(n) end end, Tooltip = "Sets autoload to selected theme." })
			ab:AddSubButton({ Name = "Remove Autoload", Callback = function() lunalibrary:RemoveThemeAutoload() end })
		end

		function tabobj:LoadConfigManager()
			local sec = self:AddSection({ Name = "Config Management", Side = "Right" })
			local dp = sec:AddDropdown({ Name = "Selected Config", Items = lunalibrary:GetFiles("Config"), IsSearchable = true, Tooltip = "Select a config.", Flag = "SelectedConfigDP" })
			task.spawn(function() local lf = {}; while task.wait(1) do if not dp._maid or dp._maid._destroyed then break end; local cf = lunalibrary:GetFiles("Config"); local ch = false; if #lf ~= #cf then ch = true else for i, v in lf do if cf[i] ~= v then ch = true; break end end end; if ch then lf = cf; local c = dp:GetValue(); dp:EditValue(cf); dp:SetValue(c) end end end)
			local tbb = sec:AddTextBox({ Name = "Config Name", Placeholder = "MyConfig", Tooltip = "Name for saving.", Flag = "ConfigManagerName" })
			local sv = sec:AddButton({ Name = "Save Config", Callback = function() local n = tbb:GetValue(); if n == "" then n = "MyConfig" end; lunalibrary:SaveConfig(n) end, Tooltip = "Save element states to new file." })
			sv:AddSubButton({ Name = "Load Config", Callback = function() local n = dp:GetValue(); if n then lunalibrary:LoadConfig(n) end end })
			local ow = sec:AddButton({ Name = "Overwrite Config", Callback = function() local n = dp:GetValue(); if n then lunalibrary:SaveConfig(n) end end, Tooltip = "Overwrite selected config." })
			ow:AddSubButton({ Name = "Duplicate Config", Callback = function() local n = dp:GetValue(); if n then lunalibrary:DuplicateFile("Config", n) end end })
			local ab = sec:AddButton({ Name = "Set Autoload", Callback = function() local n = dp:GetValue(); if n then lunalibrary:SetConfigAutoload(n) end end, Tooltip = "Sets autoload to selected config." })
			ab:AddSubButton({ Name = "Remove Autoload", Callback = function() lunalibrary:RemoveConfigAutoload() end })
		end
		return tabobj
	end
	return windowobj
end

return {
	Library = lunalibrary,
	Helpers = lunahelpers,
	Main = lunamain,
}
