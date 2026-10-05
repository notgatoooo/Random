```luau
--!native
--!optimize 2

local t_ins = table.insert
local t_rem = table.remove
local t_fnd = table.find
local t_cat = table.concat
local s_sub = string.sub
local s_fnd = string.find
local s_mat = string.match
local s_rep = string.gsub
local s_low = string.lower
local s_upp = string.upper
local s_fmt = string.format
local m_clp = math.clamp
local m_rnd = math.round
local m_flr = math.floor
local m_max = math.max
local m_min = math.min
local m_abs = math.abs
local m_sin = math.sin
local m_cos = math.cos
local m_atn = math.atan
local m_asn = math.asin
local o_clk = os.clock

local c_cre = cloneref or function(s) return s end
local function g_svc(n: string)
	local o, s = pcall(game.GetService, game, n)
	return (o and s and c_cre(s)) or nil
end

local ts: TweenService = g_svc("TweenService")
local uis: UserInputService = g_svc("UserInputService")
local rs: RunService = g_svc("RunService")
local pls: Players = g_svc("Players")
local mps: MarketplaceService = g_svc("MarketplaceService")
local tms: Teams = g_svc("Teams")
local hs: HttpService = g_svc("HttpService")
local lp: Player? = pls and pls.LocalPlayer

local w_f, r_f, i_f, l_f, m_d, i_d, d_f, s_cp, l_st
pcall(function() w_f = writefile end)
pcall(function() r_f = readfile end)
pcall(function() i_f = isfile end)
pcall(function() l_f = listfiles end)
pcall(function() m_d = makefolder end)
pcall(function() i_d = isfolder end)
pcall(function() d_f = delfile end)
pcall(function() s_cp = setclipboard or toclipboard end)
pcall(function() l_st = loadstring end)

local g_hui = (typeof(gethui) == "function" and gethui) or function() return game:GetService("CoreGui") end

local Maid = {}
Maid.__index = Maid
function Maid.New()
	return setmetatable({ _t = {}, _d = false }, Maid)
end
local cl_map = { RBXScriptConnection = "Disconnect", Instance = "Destroy" }
local function clean_t(t: any)
	if not t then return end
	local m = cl_map[typeof(t)]
	if m then t[m](t) return end
	local tt = type(t)
	if tt == "function" then t() return end
	if tt == "table" then
		if type(t.Destroy) == "function" then pcall(t.Destroy, t)
		elseif type(t.Remove) == "function" then pcall(t.Remove, t) end
	end
end
function Maid:GiveTask(t: any): any
	if self._d then clean_t(t) return t end
	self._t[#self._t + 1] = t
	return t
end
function Maid:DoCleaning()
	if self._d then return end
	self._d = true
	local o = self._t
	self._t = {}
	for i = 1, #o do clean_t(o[i]) end
	self._d = false
end
function Maid:Destroy()
	self:DoCleaning()
	self._d = true
end

local tw_c = {}
local function tw_o(d: number?): TweenInfo
	local dr = d or 0.2
	local c = tw_c[dr]
	if not c then
		c = TweenInfo.new(dr, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		tw_c[dr] = c
	end
	return c
end

local tw_def = tw_o(0.2)
local tw_opn = tw_o(0.3)
local tw_tip = tw_o(0.1)
local tw_fast = tw_o(0.12)

local cols = {
	TitleBar   = Color3.fromRGB(32, 32, 32),
	Body       = Color3.fromRGB(20, 20, 20),
	BodyLight  = Color3.fromRGB(28, 28, 28),
	Border     = Color3.fromRGB(60, 60, 60),
	Text       = Color3.fromRGB(240, 240, 240),
	TextDim    = Color3.fromRGB(160, 160, 160),
	CloseHover = Color3.fromRGB(196, 43, 28),
	ClosePress = Color3.fromRGB(150, 30, 18),
	BtnHover   = Color3.fromRGB(55, 55, 55),
	Accent     = Color3.fromRGB(138, 43, 226),
	Warning    = Color3.fromRGB(255, 170, 0),
	Error      = Color3.fromRGB(255, 50, 50),
	ImageColor = Color3.fromRGB(255, 255, 255),
}

local icns = {
	Close      = "rbxassetid://100928939627907",
	Maximize   = "rbxassetid://84623133872179",
	Minimize   = "rbxassetid://82909496983440",
	Unmaximize = "rbxassetid://123032264643469",
	Check      = "rbxassetid://9754130783",
}

local UI_W, UI_H, TB_H, BTN_W = 520, 340, 36, 46
local c_wht, c_blk = Color3.new(1, 1, 1), Color3.new(0, 0, 0)

local l_hlp = {}
local l_main = {}
local l_lib = {
	themeableobjects = {},
	fontobjects = {},
	currentfont = Font.fromId(12187377099),
	currentfontenum = nil,
	currentwindow = nil,
	_maid = Maid.New(),
	folder = "LunaUI",
	subfolder = "",
	flags = {}
}

function l_hlp.CheckDep(f: string): boolean
	if f == "setclipboard" then return s_cp ~= nil end
	if f == "loadstring" then return l_st ~= nil end
	return false
end

local function get_lang(s: string)
	s = s_low(s or "")
	if s == "lua" or s == "luau" then
		return {
			kw = { ["local"]=1, ["function"]=1, ["if"]=1, ["then"]=1, ["else"]=1, ["elseif"]=1, ["end"]=1, ["for"]=1, ["while"]=1, ["do"]=1, ["return"]=1, ["in"]=1, ["not"]=1, ["and"]=1, ["or"]=1, ["repeat"]=1, ["until"]=1, ["break"]=1, ["continue"]=1, ["goto"]=1 },
			bi = { ["print"]=1, ["pairs"]=1, ["ipairs"]=1, ["next"]=1, ["type"]=1, ["tostring"]=1, ["tonumber"]=1, ["math"]=1, ["table"]=1, ["string"]=1, ["coroutine"]=1, ["task"]=1, ["game"]=1, ["workspace"]=1, ["script"]=1, ["Instance"]=1, ["Color3"]=1, ["Vector3"]=1, ["UDim2"]=1, ["CFrame"]=1, ["Enum"]=1, ["require"]=1, ["assert"]=1, ["error"]=1, ["pcall"]=1, ["xpcall"]=1, ["select"]=1, ["unpack"]=1, ["getmetatable"]=1, ["setmetatable"]=1, ["getgenv"]=1, ["setclipboard"]=1 },
			bool = { ["true"]=1, ["false"]=1, ["nil"]=1 }, self = { ["self"]=1 },
			c_sl = "--", c_ml_s = "--[[", c_ml_e = "]]", s_ml_s = "[[", s_ml_e = "]]"
		}
	elseif s == "py" or s == "python" then
		return {
			kw = { ["def"]=1, ["class"]=1, ["if"]=1, ["elif"]=1, ["else"]=1, ["for"]=1, ["while"]=1, ["return"]=1, ["import"]=1, ["from"]=1, ["as"]=1, ["try"]=1, ["except"]=1, ["finally"]=1, ["with"]=1, ["yield"]=1, ["lambda"]=1, ["pass"]=1, ["break"]=1, ["continue"]=1, ["raise"]=1, ["not"]=1, ["and"]=1, ["or"]=1, ["in"]=1, ["is"]=1 },
			bi = { ["print"]=1, ["len"]=1, ["range"]=1, ["list"]=1, ["dict"]=1, ["str"]=1, ["int"]=1, ["float"]=1, ["set"]=1, ["tuple"]=1, ["enumerate"]=1, ["zip"]=1, ["type"]=1, ["dir"]=1, ["id"]=1, ["getattr"]=1, ["setattr"]=1, ["hasattr"]=1, ["isinstance"]=1, ["issubclass"]=1, ["super"]=1, ["open"]=1 },
			bool = { ["True"]=1, ["False"]=1, ["None"]=1 }, self = { ["self"]=1, ["cls"]=1 },
			c_sl = "#", c_ml_s = '"""', c_ml_e = '"""', s_ml_s = "'''", s_ml_e = "'''"
		}
	elseif s == "js" or s == "ts" or s == "javascript" or s == "typescript" then
		return {
			kw = { ["var"]=1, ["let"]=1, ["const"]=1, ["function"]=1, ["if"]=1, ["else"]=1, ["for"]=1, ["while"]=1, ["do"]=1, ["return"]=1, ["switch"]=1, ["case"]=1, ["break"]=1, ["continue"]=1, ["new"]=1, ["typeof"]=1, ["instanceof"]=1, ["class"]=1, ["extends"]=1, ["import"]=1, ["export"]=1, ["default"]=1, ["async"]=1, ["await"]=1, ["try"]=1, ["catch"]=1, ["finally"]=1, ["throw"]=1, ["of"]=1, ["in"]=1 },
			bi = { ["console"]=1, ["document"]=1, ["window"]=1, ["Math"]=1, ["Array"]=1, ["Object"]=1, ["Promise"]=1, ["String"]=1, ["Number"]=1, ["Boolean"]=1, ["Date"]=1, ["RegExp"]=1, ["Error"]=1, ["Map"]=1, ["Set"]=1, ["JSON"]=1, ["setTimeout"]=1, ["setInterval"]=1 },
			bool = { ["true"]=1, ["false"]=1, ["null"]=1, ["undefined"]=1, ["NaN"]=1 }, self = { ["this"]=1 },
			c_sl = "//", c_ml_s = "/*", c_ml_e = "*/", s_ml_s = "`", s_ml_e = "`"
		}
	elseif s == "c" or s == "cpp" or s == "cs" or s == "h" or s == "hpp" then
		return {
			kw = { ["int"]=1, ["float"]=1, ["double"]=1, ["char"]=1, ["void"]=1, ["if"]=1, ["else"]=1, ["for"]=1, ["while"]=1, ["do"]=1, ["return"]=1, ["switch"]=1, ["case"]=1, ["break"]=1, ["continue"]=1, ["struct"]=1, ["class"]=1, ["public"]=1, ["private"]=1, ["protected"]=1, ["typedef"]=1, ["namespace"]=1, ["using"]=1, ["static"]=1, ["virtual"]=1, ["override"]=1, ["inline"]=1, ["const"]=1, ["template"]=1, ["typename"]=1, ["new"]=1, ["delete"]=1, ["try"]=1, ["catch"]=1, ["throw"]=1 },
			bi = { ["std"]=1, ["cout"]=1, ["cin"]=1, ["endl"]=1, ["string"]=1, ["vector"]=1, ["map"]=1, ["printf"]=1, ["scanf"]=1, ["malloc"]=1, ["free"]=1, ["Console"]=1, ["Math"]=1, ["System"]=1 },
			bool = { ["true"]=1, ["false"]=1, ["NULL"]=1, ["nullptr"]=1 }, self = { ["this"]=1 },
			c_sl = "//", c_ml_s = "/*", c_ml_e = "*/"
		}
	end
	return { kw = {}, bi = {}, bool = {}, self = {} }
end

local esc_m = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;" }
local function hl_code(s: string, l: any): string
	if not s or s == "" then return "" end
	local function esc(str) return s_rep(str, "[&<>\"]", esc_m) end
	if not l then return esc(s) end
	local res, p, len = {}, 1, #s
	local function wrp(txt, col) return '<font color="' .. col .. '">' .. esc(txt) .. "</font>" end

	while p <= len do
		if l.c_ml_s and s_sub(s, p, p + #l.c_ml_s - 1) == l.c_ml_s then
			local sp = p
			p += #l.c_ml_s
			local e = s_fnd(s, l.c_ml_e, p, true)
			p = e and (e + #l.c_ml_e) or (len + 1)
			t_ins(res, wrp(s_sub(s, sp, p - 1), "#666666"))
			continue
		end
		if l.c_sl and s_sub(s, p, p + #l.c_sl - 1) == l.c_sl then
			local sp = p
			local e = s_fnd(s, "\n", p, true)
			p = e or (len + 1)
			t_ins(res, wrp(s_sub(s, sp, p - 1), "#666666"))
			continue
		end
		if l.s_ml_s and s_sub(s, p, p + #l.s_ml_s - 1) == l.s_ml_s then
			local sp = p
			p += #l.s_ml_s
			local e = s_fnd(s, l.s_ml_e, p, true)
			p = e and (e + #l.s_ml_e) or (len + 1)
			t_ins(res, wrp(s_sub(s, sp, p - 1), "#98C379"))
			continue
		end
		local c = s_sub(s, p, p)
		if c == '"' or c == "'" or (l.s_ml_s == "`" and c == "`") then
			local sp, q = p, c
			p += 1
			while p <= len do
				local sc = s_sub(s, p, p)
				if sc == "\\" then p += 2
				elseif sc == q then p += 1 break
				elseif sc == "\n" then break
				else p += 1 end
			end
			t_ins(res, wrp(s_sub(s, sp, p - 1), "#98C379"))
			continue
		end
		if s_mat(c, "%d") or (c == "." and s_mat(s_sub(s, p + 1, p + 1), "%d")) then
			local sp = p
			local _, e = s_fnd(s, "^0x%x+", p)
			if not e then _, e = s_fnd(s, "^%d+%.?%d*", p) end
			p = e and (e + 1) or (p + 1)
			t_ins(res, wrp(s_sub(s, sp, p - 1), "#C678DD"))
			continue
		end
		if s_mat(c, "[%a_]") then
			local sp = p
			local _, e = s_fnd(s, "^[%w_]+", p)
			e = e or p
			p = e + 1
			local w = s_sub(s, sp, e)
			local is_fn, ap = false, p
			while ap <= len do
				local ac = s_sub(s, ap, ap)
				if s_mat(ac, "%s") then ap += 1
				elseif ac == "(" or ac == '"' or ac == "'" or ac == "{" or ac == "[" then is_fn = true break
				else break end
			end
			local is_m = false
			for i = sp - 1, 1, -1 do
				local pc = s_sub(s, i, i)
				if not s_mat(pc, "%s") then if pc == ":" then is_m = true end break end
			end
			if l.kw and l.kw[w] then t_ins(res, wrp(w, "#569CD6"))
			elseif l.bi and l.bi[w] then t_ins(res, wrp(w, "#4EC9B0"))
			elseif l.bool and l.bool[w] then t_ins(res, wrp(w, "#C678DD"))
			elseif l.self and l.self[w] then t_ins(res, wrp(w, "#E06C75"))
			elseif is_m and is_fn then t_ins(res, wrp(w, "#E5C07B"))
			elseif is_fn then t_ins(res, wrp(w, "#E06C75"))
			else t_ins(res, esc(w)) end
			continue
		end
		if s_mat(c, "[%+%-%*/%%%=%<%>%~%&%|%^%.%,%:%(%)%{%}%[%]%;]") then
			t_ins(res, wrp(c, "#ABB2BF"))
			p += 1
			continue
		end
		t_ins(res, esc(c))
		p += 1
	end
	return t_cat(res)
end

local g_tw = {}
function l_hlp.TweenGradient(gr: UIGradient, t1: Color3, t2: Color3, dur: number?)
	if g_tw[gr] then g_tw[gr]() g_tw[gr] = nil end
	local kps = gr.Color.Keypoints
	local c1, c2 = kps[1].Value, kps[#kps].Value
	local val = Instance.new("NumberValue")
	local tw = ts:Create(val, tw_o(dur or 0.2), { Value = 1 })
	local conn: RBXScriptConnection?
	local function cln()
		if conn then conn:Disconnect() conn = nil end
		if tw then tw:Cancel() end
		val:Destroy()
		g_tw[gr] = nil
	end
	g_tw[gr] = cln
	conn = val.Changed:Connect(function(v)
		if gr and gr.Parent then
			gr.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, c1:Lerp(t1, v)),
				ColorSequenceKeypoint.new(1, c2:Lerp(t2, v))
			})
		else
			cln()
		end
	end)
	tw.Completed:Connect(cln)
	tw:Play()
end

function l_hlp.AddFeedback(m: any, el: GuiObject, tg: GuiObject?)
	local p = tg or el
	local o = Instance.new("Frame")
	o.Name = "FeedbackOverlay"
	o.Size = UDim2.new(1, 0, 1, 0)
	o.BackgroundColor3 = c_blk
	o.BackgroundTransparency = 1
	o.BorderSizePixel = 0
	o.ZIndex = p.ZIndex
	o.Parent = p

	local hov, prs = false, false
	m:GiveTask(el.MouseEnter:Connect(function()
		hov = true
		if not prs then ts:Create(o, tw_tip, { BackgroundTransparency = 0.9 }):Play() end
	end))
	m:GiveTask(el.MouseLeave:Connect(function()
		hov = false
		if not prs then ts:Create(o, tw_tip, { BackgroundTransparency = 1 }):Play() end
	end))
	m:GiveTask(el.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			prs = true
			ts:Create(o, tw_tip, { BackgroundTransparency = 0.8 }):Play()
		end
	end))
	m:GiveTask(el.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			prs = false
			ts:Create(o, tw_tip, { BackgroundTransparency = hov and 0.9 or 1 }):Play()
		end
	end))
end

local l_err_t = 0
function l_main.SafeCallback(cb: any, ...: any)
	if type(cb) ~= "function" then return true, nil end
	local s, r = pcall(cb, ...)
	if not s then
		warn("LunaUI Callback Error:", r)
		if o_clk() - l_err_t > 1 then
			l_err_t = o_clk()
			l_lib:Notify({ Title = "Execution Error", Description = tostring(r), Time = 5, Type = 3 })
		end
	end
	return s, r
end
local s_call = l_main.SafeCallback

function l_lib:OnUnload(cb) self._maid:GiveTask(function() s_call(cb) end) end

local function b_path(lib, sfx)
	local p = lib.folder or "LunaUI"
	if lib.subfolder and lib.subfolder ~= "" then p = p .. "/" .. lib.subfolder end
	return sfx and (p .. "/" .. sfx) or p
end

local function e_fold(p)
	if not m_d or not i_d then return end
	local ok, ex = pcall(i_d, p)
	if ok and not ex then pcall(m_d, p) end
end

local function e_json(p)
	return s_mat(p, "%.json$") and p or (p .. ".json")
end

function l_lib:Unload()
	local w = self.currentwindow
	if w and w.gui then
		local lu, g, st = w.luna, w.gui, w.mainstroke
		local cp, cs = lu.Position, lu.Size
		local tw, th = cs.X.Offset * 0.85, cs.Y.Offset * 0.85
		ts:Create(lu, tw_opn, {
			GroupTransparency = 1,
			Size = UDim2.new(0, tw, 0, th),
			Position = UDim2.new(cp.X.Scale, cp.X.Offset + (cs.X.Offset - tw) * 0.5, cp.Y.Scale, cp.Y.Offset + (cs.Y.Offset - th) * 0.5)
		}):Play()
		if st then ts:Create(st, tw_opn, { Transparency = 1 }):Play() end
		task.delay(0.35, function() self._maid:Destroy() if g and g.Parent then g:Destroy() end end)
	else
		self._maid:Destroy()
	end
end

function l_lib:UpdateTheme(sm: boolean?)
	local act, n, dur = {}, 0, sm and 0.4 or 0.2
	local t_info = tw_o(dur)
	for _, it in self.themeableobjects do
		local obj = it.Obj
		if obj and obj.Parent then
			n += 1
			act[n] = it
			if it.IsGradient then
				local c1, c2 = cols[it.C1], cols[it.C2]
				if it.Darken then
					local d = it.Darken
					c1 = Color3.new(c1.R * d, c1.G * d, c1.B * d)
					c2 = Color3.new(c2.R * d, c2.G * d, c2.B * d)
				end
				if sm then l_hlp.TweenGradient(obj, c1, c2, dur)
				else obj.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2) }) end
			else
				local target = cols[it.ColorName]
				if target then ts:Create(obj, t_info, { [it.Prop] = target }):Play() end
			end
		end
	end
	self.themeableobjects = act
end

function l_lib:SetFolder(n)
	self.folder = tostring(n or "LunaUI")
	e_fold(self.folder)
	e_fold(self.folder .. "/Themes")
	e_fold(self.folder .. "/Configs")
end

function l_lib:SetSubfolder(n)
	self.subfolder = tostring(n or "")
	local b = b_path(self)
	e_fold(b)
	e_fold(b .. "/Themes")
	e_fold(b .. "/Configs")
end

function l_lib:SaveTheme(n)
	n = (n == nil or n == "") and "LunaTheme" or tostring(n)
	if not w_f then
		self:Notify({ Title = "Theme Manager", Description = "Executor does not support writefile.", Time = 4, Type = 3 })
		return false
	end
	local d = {}
	for k, v in cols do d[k] = { m_rnd(v.R * 255), m_rnd(v.G * 255), m_rnd(v.B * 255) } end
	local s, j = pcall(hs.JSONEncode, hs, d)
	if not s then
		self:Notify({ Title = "Theme Error", Description = "Failed to encode theme data.", Time = 4, Type = 3 })
		return false
	end
	local s2, err = pcall(w_f, e_json(b_path(self, "Themes/" .. n)), j)
	if s2 then
		self:Notify({ Title = "Theme Manager", Description = "Saved theme: " .. n, Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Theme Error", Description = "Save failed: " .. tostring(err), Time = 4, Type = 3 })
	return false
end

function l_lib:LoadTheme(raw_or_name, silent: boolean?)
	local j = tostring(raw_or_name or "")
	local disp = "Theme"
	local is_raw = s_mat(j, "^%s*{") and s_mat(j, "}%s*$")
	if not is_raw then
		local p = e_json(b_path(self, "Themes/" .. j))
		disp = j
		if i_f and r_f then
			local s1, r1 = pcall(i_f, p)
			if s1 and r1 then
				local s2, c = pcall(r_f, p)
				if s2 and c then j = c end
			end
		end
	end
	local s, p = pcall(hs.JSONDecode, hs, j)
	if s and type(p) == "table" then
		for k, v in p do
			if cols[k] and type(v) == "table" and type(v[1]) == "number" and type(v[2]) == "number" and type(v[3]) == "number" then
				cols[k] = Color3.fromRGB(v[1], v[2], v[3])
			end
		end
		self:UpdateTheme(true)
		if not silent and not is_raw then
			self:Notify({ Title = "Theme Manager", Description = "Loaded theme: " .. disp, Time = 3, Type = 1 })
		end
		return true
	end
	if not silent and not is_raw then
		self:Notify({ Title = "Theme Error", Description = "Failed to load theme data.", Time = 4, Type = 3 })
	end
	return false
end

function l_lib:SetThemeAutoload(n)
	if not w_f then
		self:Notify({ Title = "Theme Manager", Description = "Executor does not support writefile.", Time = 4, Type = 3 })
		return false
	end
	local s, e = pcall(w_f, b_path(self, "Themes/autoload.txt"), e_json(tostring(n or "")))
	if s then
		self:Notify({ Title = "Theme Manager", Description = "Autoload set: " .. tostring(n), Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Theme Error", Description = "Failed: " .. tostring(e), Time = 4, Type = 3 })
	return false
end

function l_lib:RemoveThemeAutoload()
	local p = b_path(self, "Themes/autoload.txt")
	if d_f and i_f then
		local s, ex = pcall(i_f, p)
		if s and ex then
			pcall(d_f, p)
			self:Notify({ Title = "Theme Manager", Description = "Removed theme autoload.", Time = 3, Type = 1 })
			return true
		end
	end
	if w_f then
		local s = pcall(w_f, p, "")
		if s then
			self:Notify({ Title = "Theme Manager", Description = "Removed theme autoload.", Time = 3, Type = 1 })
			return true
		end
	end
	self:Notify({ Title = "Theme Error", Description = "Failed to remove autoload.", Time = 4, Type = 3 })
	return false
end

local function ser_cfg(v)
	local t = typeof(v)
	if t == "Color3" then return "#" .. v:ToHex()
	elseif t == "table" then
		local o = {}
		for k, val in v do o[k] = ser_cfg(val) end
		return o
	end
	return v
end

function l_lib:SaveConfig(n)
	n = (n == nil or n == "") and "LunaConfig" or tostring(n)
	if not w_f then
		self:Notify({ Title = "Config Manager", Description = "Executor does not support writefile.", Time = 4, Type = 3 })
		return false
	end
	local d = {}
	for fl, el in self.flags do
		local s, v = pcall(el.GetValue, el)
		if s then d[fl] = ser_cfg(v) end
	end
	local s, j = pcall(hs.JSONEncode, hs, d)
	if not s then
		self:Notify({ Title = "Config Error", Description = "Failed to encode config data.", Time = 4, Type = 3 })
		return false
	end
	local s2, err = pcall(w_f, e_json(b_path(self, "Configs/" .. n)), j)
	if s2 then
		self:Notify({ Title = "Config Manager", Description = "Saved config: " .. n, Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Config Error", Description = "Save failed: " .. tostring(err), Time = 4, Type = 3 })
	return false
end

function l_lib:LoadConfig(raw_or_name)
	local j = tostring(raw_or_name or "")
	local disp = "Config"
	if not (s_mat(j, "^%s*{") and s_mat(j, "}%s*$")) then
		local p = e_json(b_path(self, "Configs/" .. j))
		disp = j
		if i_f and r_f then
			local s1, ex = pcall(i_f, p)
			if s1 and ex then
				local s2, c = pcall(r_f, p)
				if s2 and c then j = c end
			end
		end
	end
	local s, p = pcall(hs.JSONDecode, hs, j)
	if s and type(p) == "table" then
		for k, v in p do
			local el = self.flags[k]
			if el then pcall(el.SetValue, el, v) end
		end
		self:Notify({ Title = "Config Manager", Description = "Loaded config: " .. disp, Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Config Error", Description = "Failed to load config data.", Time = 4, Type = 3 })
	return false
end

function l_lib:SetConfigAutoload(n)
	if not w_f then
		self:Notify({ Title = "Config Manager", Description = "Executor does not support writefile.", Time = 4, Type = 3 })
		return false
	end
	local s, e = pcall(w_f, b_path(self, "Configs/autoload.txt"), e_json(tostring(n or "")))
	if s then
		self:Notify({ Title = "Config Manager", Description = "Autoload set: " .. tostring(n), Time = 3, Type = 1 })
		return true
	end
	self:Notify({ Title = "Config Error", Description = "Failed: " .. tostring(e), Time = 4, Type = 3 })
	return false
end

function l_lib:RemoveConfigAutoload()
	local p = b_path(self, "Configs/autoload.txt")
	if d_f and i_f then
		local s, ex = pcall(i_f, p)
		if s and ex then
			pcall(d_f, p)
			self:Notify({ Title = "Config Manager", Description = "Removed config autoload.", Time = 3, Type = 1 })
			return true
		end
	end
	if w_f then
		local s = pcall(w_f, p, "")
		if s then
			self:Notify({ Title = "Config Manager", Description = "Removed config autoload.", Time = 3, Type = 1 })
			return true
		end
	end
	self:Notify({ Title = "Config Error", Description = "Failed to remove autoload.", Time = 4, Type = 3 })
	return false
end

function l_lib:GetFiles(tp: string): {string}
	local res = {}
	if not (l_f and i_d) then return res end
	local p = b_path(self, tp .. "s")
	local s, is_f = pcall(i_d, p)
	if not (s and is_f) then return res end
	local s2, fls = pcall(l_f, p)
	if not (s2 and fls) then return res end
	local n = 0
	for _, v in fls do
		local nm = s_mat(v, "([^/\\]+)%.json$")
		if nm then n += 1 res[n] = nm end
	end
	return res
end

function l_lib:DuplicateFile(tp: string, n: string)
	if not (r_f and w_f and i_f) then return end
	local bp = b_path(self, tp .. "s/")
	local s, cnt = pcall(r_f, e_json(bp .. n))
	if not s then return end
	local c, nn = 1, n .. " (1)"
	while true do
		local s2, ex = pcall(i_f, bp .. nn .. ".json")
		if not (s2 and ex) then break end
		c += 1
		nn = n .. " (" .. c .. ")"
	end
	pcall(w_f, bp .. nn .. ".json", cnt)
	self:Notify({ Title = "File Manager", Description = "Duplicated to: " .. nn, Time = 3, Type = 1 })
end

function l_lib:LoadAutoload()
	if not (r_f and i_f) then return end
	local bp = b_path(self)
	local ta = bp .. "/Themes/autoload.txt"
	local s1, e1 = pcall(i_f, ta)
	if s1 and e1 then
		local s2, n = pcall(r_f, ta)
		if s2 and type(n) == "string" and n ~= "" then self:LoadTheme(n, true) end
	end
	local ca = bp .. "/Configs/autoload.txt"
	local s3, e3 = pcall(i_f, ca)
	if s3 and e3 then
		local s4, n = pcall(r_f, ca)
		if s4 and type(n) == "string" and n ~= "" then self:LoadConfig(n) end
	end
end

function l_lib:SetFont(fid: boolean, id: any)
	if fid then self.currentfont = Font.fromId(id) self.currentfontenum = nil
	else self.currentfont = nil self.currentfontenum = id end
	local act, n = {}, 0
	for _, o in self.fontobjects do
		if o and o.Parent then
			n += 1 act[n] = o
			if self.currentfont then o.FontFace = self.currentfont
			elseif self.currentfontenum then o.Font = self.currentfontenum end
		end
	end
	self.fontobjects = act
end

function l_hlp.UpdateThemeMapping(o: Instance?, pr: string, th: string)
	if not o then return end
	local f = false
	for _, it in l_lib.themeableobjects do
		if it.Obj == o and it.Prop == pr then it.ColorName = th f = true break end
	end
	if not f then t_ins(l_lib.themeableobjects, { Obj = o, Prop = pr, ColorName = th }) end
	local tc = cols[th]
	if tc then ts:Create(o, tw_def, { [pr] = tc }):Play() end
end

function l_hlp.RemoveThemeEntries(o: Instance?, rec: boolean?)
	if not o then return end
	local cl, n = {}, 0
	for _, it in l_lib.themeableobjects do
		local obj = it.Obj
		if obj then
			local m = (obj == o)
			if rec and not m then
				local s, id = pcall(obj.IsDescendantOf, obj, o)
				if s and id then m = true end
			end
			if not m then n += 1 cl[n] = it end
		end
	end
	l_lib.themeableobjects = cl
end

function l_hlp.Make(cls: string, props: any, par: Instance?): any
	local o = Instance.new(cls)
	if props then
		for k, v in props do
			if type(v) == "table" and v.Theme then
				o[k] = cols[v.Theme]
				t_ins(l_lib.themeableobjects, { Obj = o, Prop = k, ColorName = v.Theme })
			else
				o[k] = v
			end
		end
	end
	if par then o.Parent = par end
	return o
end

function l_hlp.ApplyFont(o: TextLabel | TextBox | TextButton)
	if not o then return end
	if l_lib.currentfont then o.FontFace = l_lib.currentfont
	elseif l_lib.currentfontenum then o.Font = l_lib.currentfontenum end
	t_ins(l_lib.fontobjects, o)
end

function l_hlp.ApplyGradient(par: GuiObject, c1: string?, c2: string?, dk: number?): UIGradient?
	if not par then return nil end
	c1 = c1 or "BodyLight"
	c2 = c2 or "Body"
	par.BackgroundColor3 = c_wht
	local k1, k2 = cols[c1], cols[c2]
	if dk then
		k1 = Color3.new(k1.R * dk, k1.G * dk, k1.B * dk)
		k2 = Color3.new(k2.R * dk, k2.G * dk, k2.B * dk)
	end
	local gr = l_hlp.Make("UIGradient", {
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, k1), ColorSequenceKeypoint.new(1, k2) }),
		Rotation = 90
	}, par)
	t_ins(l_lib.themeableobjects, { Obj = gr, IsGradient = true, C1 = c1, C2 = c2, Darken = dk })
	return gr
end

function l_hlp.HoverImg(m: any, btn: GuiButton, n_th: string, h_th: string, p_th: string?)
	if not (m and btn) then return end
	m:GiveTask(btn.MouseEnter:Connect(function() l_hlp.UpdateThemeMapping(btn, "BackgroundColor3", h_th) end))
	m:GiveTask(btn.MouseLeave:Connect(function() l_hlp.UpdateThemeMapping(btn, "BackgroundColor3", n_th) end))
	if p_th then
		m:GiveTask(btn.MouseButton1Down:Connect(function() l_hlp.UpdateThemeMapping(btn, "BackgroundColor3", p_th) end))
		m:GiveTask(btn.MouseButton1Up:Connect(function() l_hlp.UpdateThemeMapping(btn, "BackgroundColor3", h_th) end))
	end
end

function l_hlp.ApplyTooltip(m: any, inst: GuiObject, txt_fn: any, win: any)
	if not (m and inst and win) then return end
	local function get_txt()
		if type(txt_fn) == "function" then local s, r = pcall(txt_fn) return (s and r) or "" end
		return txt_fn or ""
	end
	m:GiveTask(inst.MouseEnter:Connect(function()
		local t = get_txt()
		if not t or t == "" then return end
		win._currenttooltipinstance = inst
		win.tooltiplabel.Text = t
		win.tooltip.Visible = true
		win._tooltipcounter = (win._tooltipcounter or 0) + 1
		ts:Create(win.tooltip, tw_tip, { BackgroundTransparency = 0 }):Play()
		ts:Create(win._tooltipstroke, tw_tip, { Transparency = 0 }):Play()
		ts:Create(win.tooltiplabel, tw_tip, { TextTransparency = 0 }):Play()
	end))
	m:GiveTask(inst.MouseLeave:Connect(function()
		if win._currenttooltipinstance == inst then win._currenttooltipinstance = nil end
		win._tooltipcounter = (win._tooltipcounter or 0) + 1
		local cur_c = win._tooltipcounter
		ts:Create(win.tooltip, tw_tip, { BackgroundTransparency = 1 }):Play()
		ts:Create(win._tooltipstroke, tw_tip, { Transparency = 1 }):Play()
		ts:Create(win.tooltiplabel, tw_tip, { TextTransparency = 1 }):Play()
		task.delay(0.12, function() if win._tooltipcounter == cur_c then win.tooltip.Visible = false end end)
	end))
	m:GiveTask(inst.AncestryChanged:Connect(function(_, par)
		if not par and win._currenttooltipinstance == inst then
			win._currenttooltipinstance = nil
			win.tooltip.Visible = false
			win._tooltipcounter = (win._tooltipcounter or 0) + 1
		end
	end))
end

function l_lib:Notify(opts: any): any
	opts = opts or {}
	local tit = opts.Title or "Notification"
	local desc = opts.Description or ""
	local icon = opts.Icon or ""
	local tm = tonumber(opts.Time) or 5
	local n_tp = tonumber(opts.Type) or 1
	local inf = not not opts.Infinite

	local s_th = (n_tp == 2 and "Warning") or (n_tp == 3 and "Error") or "Accent"

	if not self.notifycontainer then
		local tg = (self.currentwindow and self.currentwindow.gui) or g_hui():FindFirstChild("LunaGui")
		if not tg then return end
		self.notifycontainer = l_hlp.Make("Frame", {
			Size = UDim2.new(0, 300, 1, -40),
			Position = UDim2.new(1, -20, 0, 20),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 1000
		}, tg)
		l_hlp.Make("UIListLayout", {
			Padding = UDim.new(0, 10),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder
		}, self.notifycontainer)
	end

	local nm = Maid.New()
	local no = { _maid = nm, _load = 0 }

	local outr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 999 }, self.notifycontainer)
	local frm = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(1, 320, 0, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 1000 }, outr)
	l_hlp.ApplyGradient(frm, "BodyLight", "Body")
	local n_st = l_hlp.Make("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, frm)
	l_hlp.UpdateThemeMapping(n_st, "Color", s_th)

	local innr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1001 }, frm)
	l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, innr)
	l_hlp.Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, innr)

	local hdr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 1, ZIndex = 1001 }, innr)
	local tx_off = 0
	local ico_img: ImageLabel?
	if icon ~= "" then
		tx_off = 24
		ico_img = l_hlp.Make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1, BorderSizePixel = 0, Image = icon, ImageColor3 = { Theme = "Text" }, ZIndex = 1001 }, hdr)
	end
	local tit_lbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -tx_off, 1, 0), Position = UDim2.new(0, tx_off, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = tit, TextColor3 = { Theme = "Text" }, TextSize = 13, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1001 }, hdr)
	l_hlp.ApplyFont(tit_lbl)

	local dsc_lbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, Text = desc, TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, LayoutOrder = 2, ZIndex = 1001 }, innr)
	l_hlp.ApplyFont(dsc_lbl)

	local btns = {}
	if opts.Buttons and type(opts.Buttons) == "table" then
		for _, b in opts.Buttons do btns[#btns + 1] = b end
		while #btns > 5 do t_rem(btns) end
	elseif n_tp == 2 and (opts.CallbackYes or opts.CallbackNo) then
		btns = {
			{ Name = "Yes", Callback = opts.CallbackYes },
			{ Name = "No", Callback = opts.CallbackNo }
		}
	end

	if #btns > 0 then
		local b_cnt = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 3, ZIndex = 1001 }, innr)
		l_hlp.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, b_cnt)
		local count = #btns
		local off = ((count - 1) * 6) / count
		for i, bd in ipairs(btns) do
			local b = l_hlp.Make("TextButton", { Size = UDim2.new(1 / count, -off, 1, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", LayoutOrder = i, ZIndex = 1002 }, b_cnt)
			l_hlp.ApplyGradient(b, "BodyLight", "Body", 0.96)
			l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
			local btl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = bd.Name or "Button", TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, ZIndex = 1003 }, b)
			l_hlp.ApplyFont(btl)
			l_hlp.AddFeedback(nm, b)
			nm:GiveTask(b.MouseButton1Click:Connect(function()
				if bd.Callback then task.spawn(s_call, bd.Callback) end
				no:Dismiss()
			end))
		end
	end

	local b_bg = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = { Theme = "Border" }, BorderSizePixel = 0, ZIndex = 1001 }, frm)
	local bar = l_hlp.Make("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, ZIndex = 1002 }, b_bg)
	l_hlp.UpdateThemeMapping(bar, "BackgroundColor3", s_th)

	ts:Create(frm, tw_o(0.4), { Position = UDim2.new(0, 0, 0, 0) }):Play()

	local dis = false
	function no:Dismiss()
		if dis then return end
		dis = true
		nm:DoCleaning()
		ts:Create(frm, tw_o(0.4), { Position = UDim2.new(1, 320, 0, 0) }):Play()
		task.delay(0.4, function()
			l_hlp.RemoveThemeEntries(outr, true)
			outr:Destroy()
		end)
	end
	function no:SetLoad(v: number)
		if dis then return end
		local n = m_clp(tonumber(v) or 0, 0, 100)
		self._load = n
		ts:Create(bar, tw_def, { Size = UDim2.new(n / 100, 0, 1, 0) }):Play()
		if inf and n >= 100 then task.delay(0.5, function() self:Dismiss() end) end
	end
	function no:SetTitle(s: string) if not dis then tit_lbl.Text = tostring(s or "") end end
	function no:SetDescription(s: string) if not dis then dsc_lbl.Text = tostring(s or "") end end
	function no:SetIcon(ni: string)
		if dis then return end
		if not ni or ni == "" then
			if ico_img then
				ico_img.Visible = false
				tit_lbl.Position = UDim2.new(0, 0, 0, 0)
				tit_lbl.Size = UDim2.new(1, 0, 1, 0)
			end
		else
			if not ico_img then
				ico_img = l_hlp.Make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1, BorderSizePixel = 0, Image = ni, ImageColor3 = { Theme = "Text" }, ZIndex = 1001 }, hdr)
			else
				ico_img.Image = ni
				ico_img.Visible = true
			end
			tit_lbl.Position = UDim2.new(0, 24, 0, 0)
			tit_lbl.Size = UDim2.new(1, -24, 1, 0)
		end
	end

	nm:GiveTask(frm.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			no:Dismiss()
		end
	end))

	if not inf then
		ts:Create(bar, tw_o(tm), { Size = UDim2.new(1, 0, 1, 0) }):Play()
		task.delay(tm, function() no:Dismiss() end)
	end

	return no
end

function l_lib:CreateWindow()
	local w = { _maid = Maid.New(), tabs = {}, currenttab = nil, isminimized = false, ismaximized = false }
	self._maid:GiveTask(w._maid)
	l_lib.currentwindow = w

	local gp = g_hui()
	local gui = l_hlp.Make("ScreenGui", { Name = "LunaGui", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 2147483647 }, gp)
	w.gui = gui

	local sw, sh = UI_W * 0.85, UI_H * 0.85
	local lu = l_hlp.Make("CanvasGroup", { Name = "Luna", Size = UDim2.new(0, sw, 0, sh), Position = UDim2.new(0.5, -sw * 0.5, 0.5, -sh * 0.5), BackgroundColor3 = { Theme = "Body" }, BackgroundTransparency = 0.4, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 2 }, gui)
	w.luna = lu
	local m_st = l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, lu)
	w.mainstroke = m_st

	ts:Create(lu, tw_opn, { Size = UDim2.new(0, UI_W, 0, UI_H), Position = UDim2.new(0.5, -UI_W * 0.5, 0.5, -UI_H * 0.5), BackgroundTransparency = 0, GroupTransparency = 0 }):Play()
	ts:Create(m_st, tw_opn, { Transparency = 0 }):Play()

	local t_tip = l_hlp.Make("Frame", { Name = "Tooltip", AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = c_wht, BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 100 }, gui)
	l_hlp.ApplyGradient(t_tip, "BodyLight", "Body")
	local tt_st = l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, t_tip)
	l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, t_tip)
	l_hlp.Make("UISizeConstraint", { MaxSize = Vector2.new(250, 100) }, t_tip)
	local tt_lbl = l_hlp.Make("TextLabel", { AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, TextColor3 = { Theme = "Text" }, TextTransparency = 1, TextSize = 11, Font = Enum.Font.Legacy, TextWrapped = false, RichText = true, ZIndex = 101 }, t_tip)
	l_hlp.ApplyFont(tt_lbl)
	l_hlp.Make("UITextSizeConstraint", { MaxTextSize = 11 }, tt_lbl)
	w.tooltip, w.tooltiplabel, w._tooltipstroke, w._tooltipcounter = t_tip, tt_lbl, tt_st, 0

	local tb_tip = l_hlp.Make("Frame", { Name = "TabTooltip", AutomaticSize = Enum.AutomaticSize.XY, AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = c_blk, BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 100 }, gui)
	l_hlp.ApplyGradient(tb_tip, "BodyLight", "Body")
	local tbt_st = l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tb_tip)
	l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, tb_tip)
	local tbt_lbl = l_hlp.Make("TextLabel", { AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, TextColor3 = { Theme = "Text" }, TextTransparency = 1, TextSize = 11, Font = Enum.Font.Legacy, TextWrapped = false, ZIndex = 101 }, tb_tip)
	l_hlp.ApplyFont(tbt_lbl)
	w.tabtooltip, w.tabtooltiplabel, w._tabtooltipstroke, w._tabtooltipcounter = tb_tip, tbt_lbl, tbt_st, 0

	local tb = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, TB_H), BackgroundColor3 = { Theme = "TitleBar" }, BorderSizePixel = 0, ZIndex = 3 }, lu)
	l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, ZIndex = 10 }, tb)

	local tit_lbl2 = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -(12 + BTN_W * 3 + 8), 1, 0), Position = UDim2.new(0, 12, 0, 1), BackgroundTransparency = 1, Text = "LunaUI", TextColor3 = { Theme = "Text" }, TextSize = 13, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4 }, tb)
	l_hlp.ApplyFont(tit_lbl2)
	w.titlelabel = tit_lbl2

	local function mk_tbtn(x_off, ic, bh, bp)
		local b = l_hlp.Make("ImageButton", { Size = UDim2.new(0, BTN_W, 0, TB_H), Position = UDim2.new(1, -(BTN_W * 3) + x_off, 0, 0), BackgroundColor3 = { Theme = "TitleBar" }, BorderSizePixel = 0, Image = "", ZIndex = 5 }, tb)
		l_hlp.Make("ImageLabel", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0.5, -7, 0.5, -7), BackgroundTransparency = 1, Image = ic, ImageColor3 = { Theme = "ImageColor" }, ScaleType = Enum.ScaleType.Fit, ZIndex = 6 }, b)
		l_hlp.HoverImg(w._maid, b, "TitleBar", bh, bp)
		return b
	end
	local b_min = mk_tbtn(0, icns.Minimize, "BtnHover", nil)
	local b_max = mk_tbtn(BTN_W, icns.Maximize, "BtnHover", nil)
	local b_cls = mk_tbtn(BTN_W * 2, icns.Close, "CloseHover", "ClosePress")

	local gr_fr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, -TB_H), Position = UDim2.new(0, 0, 0, TB_H), BorderSizePixel = 0, ZIndex = 1 }, lu)
	l_hlp.ApplyGradient(gr_fr, "BodyLight", "Body")
	w.gradientframe = gr_fr
	local c_area = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, -(TB_H + (UI_H * 0.13) + 20)), Position = UDim2.new(0, 0, 0, TB_H), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, lu)
	w.contentarea = c_area

	local tbc = l_hlp.Make("Frame", { Name = "TabBarContainer", Size = UDim2.new(0.95, 0, 0.13, 0), Position = UDim2.new(0.5, 0, 0.96, 0), AnchorPoint = Vector2.new(0.5, 1), BorderSizePixel = 0, ZIndex = 20 }, lu)
	l_hlp.ApplyGradient(tbc)
	l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tbc)
	w.tabbarcontainer = tbc
	local tbar = l_hlp.Make("ScrollingFrame", { Name = "TabBar", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, ZIndex = 20 }, tbc)
	l_hlp.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tbar)
	l_hlp.Make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, tbar)

	local o_btn = l_hlp.Make("TextButton", { Name = "OpenUI", Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0.5, -50, 0, -30), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 50, Visible = false }, gui)
	local o_bg = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_wht, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 49 }, o_btn)
	l_hlp.ApplyGradient(o_bg, "BodyLight", "Body")
	local o_tx = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "Open UI", TextColor3 = { Theme = "Text" }, TextSize = 13, Font = Enum.Font.Legacy, ZIndex = 51, TextTransparency = 1 }, o_btn)
	l_hlp.ApplyFont(o_tx)
	local o_st = l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o_bg)

	local p_sz, p_ps = UDim2.new(0, UI_W, 0, UI_H), UDim2.new(0.5, -UI_W * 0.5, 0.5, -UI_H * 0.5)
	local ob_in, ob_og, ob_pos, ob_drg = nil, nil, nil, false

	local function restore_min()
		if not w.isminimized then return end
		w.isminimized = false
		ts:Create(o_bg, tw_def, { BackgroundTransparency = 1 }):Play()
		ts:Create(o_tx, tw_def, { TextTransparency = 1 }):Play()
		ts:Create(o_st, tw_def, { Transparency = 1 }):Play()
		task.delay(0.22, function() if not w.isminimized then o_btn.Visible = false end end)

		local tw_s = p_sz.X.Offset * 0.85
		local th_s = p_sz.Y.Offset * 0.85
		lu.Size = UDim2.new(0, tw_s, 0, th_s)
		lu.Position = UDim2.new(p_ps.X.Scale, p_ps.X.Offset + (p_sz.X.Offset - tw_s) * 0.5, p_ps.Y.Scale, p_ps.Y.Offset + (p_sz.Y.Offset - th_s) * 0.5)
		lu.Visible, lu.GroupTransparency, m_st.Transparency = true, 1, 1
		c_area.Visible, gr_fr.Visible, tbc.Visible = true, true, true

		ts:Create(lu, tw_opn, { Size = p_sz, Position = p_ps, GroupTransparency = 0 }):Play()
		ts:Create(m_st, tw_opn, { Transparency = 0 }):Play()
	end

	w._maid:GiveTask(o_btn.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			ob_in = inp
			ob_og = Vector2.new(inp.Position.X, inp.Position.Y)
			local vp = gui.AbsoluteSize
			ob_pos = Vector2.new(o_btn.Position.X.Scale * vp.X + o_btn.Position.X.Offset, o_btn.Position.Y.Scale * vp.Y + o_btn.Position.Y.Offset)
			ob_drg = false
		end
	end))
	w._maid:GiveTask(uis.InputChanged:Connect(function(inp)
		if not ob_in then return end
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			local cur = Vector2.new(inp.Position.X, inp.Position.Y)
			local delta = cur - ob_og
			if delta.Magnitude > 5 then
				ob_drg = true
				local vp = gui.AbsoluteSize
				o_btn.Position = UDim2.new(0, m_clp(ob_pos.X + delta.X, 0, vp.X - 100), 0, m_clp(ob_pos.Y + delta.Y, 0, vp.Y - 30))
			end
		end
	end))
	w._maid:GiveTask(uis.InputEnded:Connect(function(inp)
		if inp == ob_in then
			if not ob_drg then restore_min() end
			ob_in = nil
		end
	end))

	local a_in, d_og, l_og = nil, nil, nil
	w._maid:GiveTask(tb.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			a_in = inp
			d_og = Vector2.new(inp.Position.X, inp.Position.Y)
			local vp = gui.AbsoluteSize
			l_og = Vector2.new(lu.Position.X.Scale * vp.X + lu.Position.X.Offset, lu.Position.Y.Scale * vp.Y + lu.Position.Y.Offset)
		end
	end))
	w._maid:GiveTask(uis.InputEnded:Connect(function(inp) if inp == a_in then a_in = nil end end))

	w._maid:GiveTask(rs.RenderStepped:Connect(function()
		local tt_vis = t_tip.Visible and w._currenttooltipinstance
		local tbt_vis = tb_tip.Visible and w._tabtooltipinstance
		if not (a_in or tt_vis or tbt_vis) then return end

		if a_in then
			local delta = Vector2.new(a_in.Position.X, a_in.Position.Y) - d_og
			local vp, fsz = gui.AbsoluteSize, lu.AbsoluteSize
			lu.Position = UDim2.new(0, m_clp(l_og.X + delta.X, 0, vp.X - fsz.X), 0, m_clp(l_og.Y + delta.Y, 0, vp.Y - fsz.Y))
		end

		if tt_vis then
			local inst = w._currenttooltipinstance
			if not inst:IsDescendantOf(game) then
				t_tip.Visible = false
				w._currenttooltipinstance = nil
			else
				local ml, tts, vp = uis:GetMouseLocation(), t_tip.AbsoluteSize, gui.AbsoluteSize
				local rx, ry = ml.X + 12, ml.Y + 12
				if rx + tts.X > vp.X then rx = ml.X - tts.X - 4 end
				if ry + tts.Y > vp.Y then ry = ml.Y - tts.Y - 4 end
				t_tip.Position = UDim2.new(0, m_clp(rx, 0, m_max(0, vp.X - tts.X)), 0, m_clp(ry, 0, m_max(0, vp.Y - tts.Y)))
			end
		end

		if tbt_vis then
			local inst = w._tabtooltipinstance
			if not inst:IsDescendantOf(game) then
				tb_tip.Visible = false
				w._tabtooltipinstance = nil
			else
				tb_tip.Position = UDim2.new(0, inst.AbsolutePosition.X + inst.AbsoluteSize.X * 0.5, 0, inst.AbsolutePosition.Y + 8)
			end
		end
	end))

	local sv_sz, sv_ps
	w._maid:GiveTask(b_cls.MouseButton1Click:Connect(function() l_lib:Unload() end))
	w._maid:GiveTask(b_min.MouseButton1Click:Connect(function() w:Toggle() end))
	w._maid:GiveTask(b_max.MouseButton1Click:Connect(function()
		local ico = b_max:FindFirstChildOfClass("ImageLabel")
		local vp = gui.AbsoluteSize
		if w.ismaximized then
			ts:Create(lu, tw_def, { Size = sv_sz, Position = sv_ps }):Play()
			w.ismaximized = false
			if ico then ico.Image = icns.Maximize end
		else
			if w.isminimized then
				w.isminimized = false
				c_area.Visible, gr_fr.Visible, tbc.Visible = true, true, true
			end
			sv_sz, sv_ps = lu.Size, lu.Position
			ts:Create(lu, tw_def, { Size = UDim2.new(0, vp.X, 0, vp.Y), Position = UDim2.new(0, 0, 0, 0) }):Play()
			w.ismaximized = true
			if ico then ico.Image = icns.Unmaximize end
		end
	end))

	function w:SetTitle(t) if self.titlelabel then self.titlelabel.Text = tostring(t or "") end end
	function w:GetTitle() return self.titlelabel and self.titlelabel.Text or "" end
	function w:SetSize(x, y)
		local cx, cy = self.luna.Size.X.Offset, self.luna.Size.Y.Offset
		ts:Create(self.luna, tw_def, { Size = UDim2.new(0, x and m_clp(tonumber(x) or cx, 100, 4096) or cx, 0, y and m_clp(tonumber(y) or cy, TB_H, 4096) or cy) }):Play()
	end
	function w:GetSize() return self.luna.Size.X.Offset, self.luna.Size.Y.Offset end

	function w:Toggle()
		if self.isminimized then restore_min() return end
		self.isminimized = true
		p_sz, p_ps = lu.Size, lu.Position
		local tw_s = p_sz.X.Offset * 0.85
		local th_s = p_sz.Y.Offset * 0.85
		ts:Create(lu, tw_opn, {
			GroupTransparency = 1,
			Size = UDim2.new(0, tw_s, 0, th_s),
			Position = UDim2.new(p_ps.X.Scale, p_ps.X.Offset + (p_sz.X.Offset - tw_s) * 0.5, p_ps.Y.Scale, p_ps.Y.Offset + (p_sz.Y.Offset - th_s) * 0.5)
		}):Play()
		ts:Create(m_st, tw_opn, { Transparency = 1 }):Play()
		task.delay(0.35, function()
			if self.isminimized then
				lu.Visible, o_btn.Visible = false, true
				o_btn.Position = UDim2.new(0.5, -50, 0, -30)
				ts:Create(o_btn, tw_def, { Position = UDim2.new(0.5, -50, 0, 8) }):Play()
				ts:Create(o_bg, tw_def, { BackgroundTransparency = 0 }):Play()
				ts:Create(o_tx, tw_def, { TextTransparency = 0 }):Play()
				ts:Create(o_st, tw_def, { Transparency = 0 }):Play()
			end
		end)
	end

	function w:AddTab(opts: any): any
		opts = opts or {}
		local t_nm = type(opts) == "string" and opts or opts.Name or "Tab"
		local t_ic = type(opts) == "table" and opts.Icon or ""
		local tab = { _maid = Maid.New(), _contentmaid = Maid.New() }
		self._maid:GiveTask(tab._maid)
		tab._maid:GiveTask(tab._contentmaid)

		local t_btn = l_hlp.Make("TextButton", { Name = t_nm .. "Tab", Size = UDim2.new(0, 44, 0, 44), BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", ZIndex = 21 }, tbar)
		local function upd_btn_sz()
			local s = m_max(30, tbar.AbsoluteSize.Y - 8)
			t_btn.Size = UDim2.new(0, s, 0, s)
		end
		upd_btn_sz()
		tab._maid:GiveTask(tbar:GetPropertyChangedSignal("AbsoluteSize"):Connect(upd_btn_sz))
		l_hlp.Make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, t_btn)
		l_hlp.ApplyGradient(t_btn, "BodyLight", "BodyLight")
		l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, t_btn)
		local ov = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_blk, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 21 }, t_btn)

		tab._maid:GiveTask(t_btn.MouseEnter:Connect(function()
			ts:Create(ov, tw_def, { BackgroundTransparency = 0.94 }):Play()
			w._tabtooltipcounter = (w._tabtooltipcounter or 0) + 1
			w._tabtooltipinstance = t_btn
			w.tabtooltiplabel.Text = t_nm
			w.tabtooltip.Visible = true
			w.tabtooltip.Position = UDim2.new(0, t_btn.AbsolutePosition.X + t_btn.AbsoluteSize.X * 0.5, 0, t_btn.AbsolutePosition.Y + 8)
			ts:Create(w.tabtooltip, tw_tip, { BackgroundTransparency = 0 }):Play()
			ts:Create(w._tabtooltipstroke, tw_tip, { Transparency = 0 }):Play()
			ts:Create(w.tabtooltiplabel, tw_tip, { TextTransparency = 0 }):Play()
		end))
		tab._maid:GiveTask(t_btn.MouseLeave:Connect(function()
			ts:Create(ov, tw_def, { BackgroundTransparency = 1 }):Play()
			w._tabtooltipcounter = (w._tabtooltipcounter or 0) + 1
			if w._tabtooltipinstance == t_btn then w._tabtooltipinstance = nil end
			local cur_c = w._tabtooltipcounter
			ts:Create(w.tabtooltip, tw_tip, { BackgroundTransparency = 1 }):Play()
			ts:Create(w._tabtooltipstroke, tw_tip, { Transparency = 1 }):Play()
			ts:Create(w.tabtooltiplabel, tw_tip, { TextTransparency = 1 }):Play()
			task.delay(0.12, function() if w._tabtooltipcounter == cur_c then w.tabtooltip.Visible = false end end)
		end))
		tab._maid:GiveTask(t_btn.AncestryChanged:Connect(function(_, par)
			if not par and w._tabtooltipinstance == t_btn then
				w._tabtooltipinstance = nil
				w.tabtooltip.Visible = false
				w._tabtooltipcounter = (w._tabtooltipcounter or 0) + 1
			end
		end))
		tab._maid:GiveTask(t_btn.MouseButton1Down:Connect(function() ts:Create(ov, tw_def, { BackgroundTransparency = 0.88 }):Play() end))
		tab._maid:GiveTask(t_btn.MouseButton1Up:Connect(function() ts:Create(ov, tw_def, { BackgroundTransparency = 0.94 }):Play() end))

		if t_ic ~= "" then
			l_hlp.Make("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Image = t_ic, ImageColor3 = { Theme = "ImageColor" }, ScaleType = Enum.ScaleType.Fit, ZIndex = 22 }, t_btn)
		else
			local tx = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = s_sub(t_nm, 1, 1), TextColor3 = { Theme = "Text" }, TextSize = 16, Font = Enum.Font.Legacy, ZIndex = 22 }, t_btn)
			l_hlp.ApplyFont(tx)
		end

		local tc_cv = l_hlp.Make("CanvasGroup", { Name = t_nm .. "Canvas", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 2 }, c_area)
		local mt_lbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "This Tab is Empty! :(", TextColor3 = { Theme = "TextDim" }, TextSize = 16, Font = Enum.Font.Legacy, ZIndex = 5 }, tc_cv)
		l_hlp.ApplyFont(mt_lbl)

		local cols_c = l_hlp.Make("Frame", { Size = UDim2.new(1, -32, 1, -24), Position = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, BorderSizePixel = 0 }, tc_cv)
		l_hlp.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }, cols_c)

		local function mk_col(ord)
			local c = l_hlp.Make("ScrollingFrame", { Size = UDim2.new(0.5, -4, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = { Theme = "Border" }, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, LayoutOrder = ord }, cols_c)
			l_hlp.Make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, c)
			l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 4) }, c)
			return c
		end
		local l_col, r_col = mk_col(1), mk_col(2)
		w.tabs[t_nm] = tc_cv
		if not w.currenttab then
			tc_cv.Visible, tc_cv.GroupTransparency = true, 0
			w.currenttab = tc_cv
		end

		tab._maid:GiveTask(t_btn.MouseButton1Click:Connect(function()
			if w.currenttab == tc_cv then return end
			for _, cv in w.tabs do if cv ~= tc_cv then cv.GroupTransparency, cv.Visible = 1, false end end
			tc_cv.Visible = true
			tc_cv.Position = UDim2.new(0, 0, 0, -10)
			tc_cv.GroupTransparency = 1
			ts:Create(tc_cv, tw_def, { GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }):Play()
			w.currenttab = tc_cv
		end))

		function tab:Clean()
			self._contentmaid:DoCleaning()
			for _, c in { l_col, r_col } do
				for _, ch in c:GetChildren() do
					if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
						l_hlp.RemoveThemeEntries(ch, true)
						ch:Destroy()
					end
				end
			end
			self._hasmain = false
			if mt_lbl then mt_lbl.Visible = true end
		end

		function tab:Remove()
			self:Clean()
			self._maid:Destroy()
			l_hlp.RemoveThemeEntries(t_btn, true)
			t_btn:Destroy()
			l_hlp.RemoveThemeEntries(tc_cv, true)
			tc_cv:Destroy()
			if w.tabs[t_nm] == tc_cv then w.tabs[t_nm] = nil end
			if w.currenttab == tc_cv then w.currenttab = nil w.tabtooltip.Visible = false end
		end

		local fps_c = {
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(255, 85, 0),
			Color3.fromRGB(255, 170, 0),
			Color3.fromRGB(255, 215, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 170, 255),
		}

		function tab:SetMain()
			if self._hasmain then return end
			self._hasmain = true
			if mt_lbl then mt_lbl.Visible = false end

			local ifr = l_hlp.Make("Frame", { Name = "Info", Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, LayoutOrder = -10, ZIndex = 3 }, l_col)
			l_hlp.ApplyGradient(ifr, "BodyLight", "Body", 0.98)
			l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, ifr)
			l_hlp.Make("UIPadding", { PaddingRight = UDim.new(0, 32) }, ifr)
			local pfp = l_hlp.Make("ImageLabel", { Size = UDim2.new(0, 42, 0, 42), Position = UDim2.new(0, 10, 0.5, -21), BackgroundTransparency = 1, BorderSizePixel = 0, Image = "", ZIndex = 4 }, ifr)

			local dn = lp and lp.DisplayName or "Unknown"
			local rn = lp and lp.Name or "Unknown"
			local dnl = l_hlp.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 16), Position = UDim2.new(0, 62, 0, 13), BackgroundTransparency = 1, BorderSizePixel = 0, Text = dn, TextColor3 = { Theme = "Text" }, TextSize = 14, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4 }, ifr)
			l_hlp.ApplyFont(dnl)
			local unl = l_hlp.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 62, 0, 29), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "@" .. rn, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4 }, ifr)
			l_hlp.ApplyFont(unl)

			task.spawn(function()
				if not lp then return end
				local s, c = pcall(pls.GetUserThumbnailAsync, pls, lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				if s and c then pfp.Image = c end
			end)

			local gfr = l_hlp.Make("Frame", { Name = "Game", Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, LayoutOrder = -9, ZIndex = 3 }, l_col)
			l_hlp.ApplyGradient(gfr, "BodyLight", "Body", 0.98)
			l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, gfr)
			l_hlp.Make("UIPadding", { PaddingRight = UDim.new(0, 32) }, gfr)
			local gpfp = l_hlp.Make("ImageLabel", { Size = UDim2.new(0, 42, 0, 42), Position = UDim2.new(0, 10, 0.5, -21), BackgroundTransparency = 1, BorderSizePixel = 0, Image = "", ZIndex = 4 }, gfr)
			local gnl = l_hlp.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 16), Position = UDim2.new(0, 62, 0, 13), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Loading...", TextColor3 = { Theme = "Text" }, TextSize = 14, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4 }, gfr)
			l_hlp.ApplyFont(gnl)
			local gcl = l_hlp.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 62, 0, 29), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "By ...", TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4 }, gfr)
			l_hlp.ApplyFont(gcl)

			task.spawn(function()
				local s, inf = pcall(mps.GetProductInfo, mps, game.PlaceId)
				if s and inf then
					gnl.Text = inf.Name
					gcl.Text = inf.Creator and ("By " .. inf.Creator.Name) or "By Unknown"
					gpfp.Image = (inf.IconImageAssetId and inf.IconImageAssetId > 0) and ("rbxassetid://" .. inf.IconImageAssetId) or ("rbxthumb://type=Asset&id=" .. tostring(game.PlaceId) .. "&w=150&h=150")
				else
					gnl.Text = game.Name
					gcl.Text = "By Unknown"
				end
			end)

			local pfr = l_hlp.Make("Frame", { Name = "PingModal", Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, LayoutOrder = -10, ZIndex = 3 }, r_col)
			l_hlp.ApplyGradient(pfr, "BodyLight", "Body", 0.98)
			l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, pfr)
			local pt = l_hlp.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 10, 0, 6), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Ping", TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, pfr)
			l_hlp.ApplyFont(pt)
			local pv = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -20, 0, 32), Position = UDim2.new(0, 10, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "0 ms", TextColor3 = c_wht, TextSize = 28, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, pfr)
			l_hlp.ApplyFont(pv)

			local ffr = l_hlp.Make("Frame", { Name = "FPSModal", Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, LayoutOrder = -9, ZIndex = 3 }, r_col)
			l_hlp.ApplyGradient(ffr, "BodyLight", "Body", 0.98)
			l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, ffr)
			local ft = l_hlp.Make("TextLabel", { Size = UDim2.new(0, 0, 0, 14), Position = UDim2.new(0, 10, 0, 6), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "FPS", TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, ffr)
			l_hlp.ApplyFont(ft)
			local fv = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -20, 0, 32), Position = UDim2.new(0, 10, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "0", TextColor3 = c_wht, TextSize = 28, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, ffr)
			l_hlp.ApplyFont(fv)

			local l_upd, fc = o_clk(), 0
			self._contentmaid:GiveTask(rs.Heartbeat:Connect(function()
				fc += 1
				local nw = o_clk()
				if nw - l_upd >= 1 then
					fv.Text = tostring(fc)
					fv.TextColor3 = (fc < 10 and fps_c[1]) or (fc < 30 and fps_c[2]) or (fc < 40 and fps_c[3]) or (fc < 50 and fps_c[4]) or (fc < 120 and fps_c[5]) or fps_c[6]
					local png = lp and m_rnd(lp:GetNetworkPing() * 1000) or 0
					pv.Text = tostring(png) .. " ms"
					pv.TextColor3 = (png >= 1000 and fps_c[1]) or (png >= 500 and fps_c[2]) or (png >= 300 and fps_c[3]) or (png >= 200 and fps_c[4]) or (png >= 70 and fps_c[5]) or fps_c[6]
					fc = 0
					l_upd = nw
				end
			end))
		end

		function tab:SetHome() self:SetMain() end

		local function cnt_sec(col)
			local n = 0
			for _, ch in col:GetChildren() do if ch:IsA("Frame") or ch:IsA("ScrollingFrame") then n += 1 end end
			return n
		end

		function tab:AddSection(s_opts: any): any
			s_opts = s_opts or {}
			local s_name = type(s_opts) == "string" and s_opts or s_opts.Name or "Section"
			local side = type(s_opts) == "table" and type(s_opts.Side) == "string" and s_low(s_opts.Side) or ""
			if side ~= "left" and side ~= "right" then
				side = (cnt_sec(l_col) <= cnt_sec(r_col)) and "left" or "right"
			end
			local sec = { tabs = {}, _maid = Maid.New() }
			self._contentmaid:GiveTask(sec._maid)
			if mt_lbl then mt_lbl.Visible = false end

			local p_col = (side == "right") and r_col or l_col
			local s_frm = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y }, p_col)
			l_hlp.ApplyGradient(s_frm, "BodyLight", "Body", 0.98)
			l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, s_frm)
			l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, s_frm)
			l_hlp.Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, s_frm)

			local s_tit = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1, BorderSizePixel = 0, Text = s_name, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1, Visible = true }, s_frm)
			l_hlp.ApplyFont(s_tit)

			local s_tb = l_hlp.Make("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, LayoutOrder = 2, Visible = false }, s_frm)
			l_hlp.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, s_tb)
			l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }, s_tb)

			local s_ln = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, LayoutOrder = 3, Visible = false }, s_frm)
			local s_cc = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4 }, s_frm)

			function sec:AddTab(t_opts: any): any
				t_opts = t_opts or {}
				local tn = type(t_opts) == "string" and t_opts or t_opts.Name or "Tab"
				local tc_o = { container = nil, _maid = Maid.New() }
				self._maid:GiveTask(tc_o._maid)

				local e_btn = l_hlp.Make("TextButton", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = { Theme = "Body" }, BorderSizePixel = 0, Text = tn, TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy }, s_tb)
				l_hlp.ApplyFont(e_btn)
				l_hlp.Make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, e_btn)
				l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, e_btn)

				local tc = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, Visible = false }, s_cc)
				l_hlp.Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tc)
				local s_el = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "This Tab is Empty! :(", TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Center }, tc)
				l_hlp.ApplyFont(s_el)
				tc_o.container = tc

				l_hlp.ApplyTooltip(tc_o._maid, e_btn, tn, w)

				local function att_kb(m_use, par, sz, pos, anc, zidx, def, tch, cb)
					local kbo = { _maid = Maid.New() }
					m_use:GiveTask(kbo._maid)

					local kb_b = l_hlp.Make("TextButton", { Size = sz, Position = pos, AnchorPoint = anc, BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = zidx }, par)
					l_hlp.ApplyGradient(kb_b, "BodyLight", "Body", 0.95)
					kbo.Button = kb_b

					local st = l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, kb_b)
					local vt = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "None", TextColor3 = { Theme = "Text" }, TextScaled = true, Font = Enum.Font.Legacy, ZIndex = zidx + 1 }, kb_b)
					l_hlp.ApplyFont(vt)
					l_hlp.Make("UITextSizeConstraint", { MaxTextSize = 11 }, vt)

					local c_key, dis, is_b = nil, false, false
					local is_t = uis.TouchEnabled and not uis.MouseEnabled

					function kbo:SetValue(k)
						if dis then return end
						if k == nil or k == "None" then c_key = nil vt.Text = "None"
						elseif typeof(k) == "EnumItem" then c_key = k vt.Text = k.Name
						elseif type(k) == "string" then
							local s, r = pcall(function() return Enum.KeyCode[k] end)
							if s and r then c_key = r vt.Text = r.Name else c_key = nil vt.Text = "None" end
						end
						if not is_b then l_hlp.UpdateThemeMapping(vt, "TextColor3", "Text") end
					end

					kbo:SetValue(def)
					if is_t and not tch then kbo:SetValue(def) end

					function kbo:GetValue() return c_key and c_key.Name or "None" end
					function kbo:Disable() self:SetDisabled(true) end
					function kbo:Enable() self:SetDisabled(false) end
					function kbo:SetDisabled(v)
						dis = not not v
						if dis then
							is_b = false
							l_hlp.UpdateThemeMapping(st, "Color", "Border")
							l_hlp.UpdateThemeMapping(vt, "TextColor3", "Border")
						else
							l_hlp.UpdateThemeMapping(st, "Color", "Accent")
							l_hlp.UpdateThemeMapping(vt, "TextColor3", "Text")
							kbo:SetValue(c_key)
						end
					end
					function kbo:Remove()
						kbo._maid:Destroy()
						l_hlp.RemoveThemeEntries(kb_b, true)
						kb_b:Destroy()
					end

					kbo._maid:GiveTask(kb_b.MouseButton1Click:Connect(function()
						if dis then return end
						if is_t and not tch then return end
						if is_t and tch then task.spawn(s_call, cb) return end
						is_b = true
						vt.Text = "..."
						l_hlp.UpdateThemeMapping(vt, "TextColor3", "Accent")
						l_hlp.UpdateThemeMapping(st, "Color", "Accent")
					end))

					kbo._maid:GiveTask(uis.InputBegan:Connect(function(inp, gp)
						if dis then return end
						if is_b then
							if inp.UserInputType == Enum.UserInputType.Keyboard then
								local k = inp.KeyCode
								if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Backspace then kbo:SetValue(nil)
								else kbo:SetValue(k) end
								is_b = false
								l_hlp.UpdateThemeMapping(vt, "TextColor3", "Text")
								l_hlp.UpdateThemeMapping(st, "Color", "Accent")
							end
						else
							if not gp and c_key and inp.KeyCode == c_key then
								task.spawn(s_call, cb)
							end
						end
					end))

					return kbo
				end

				function tc_o:HideEmpty() s_el.Visible = false end

				function tc_o:AddKeybind(opts: any): any
					opts = opts or {}
					local k_nm = opts.Name or "Keybind"
					local fl = opts.Flag or k_nm
					local def = opts.Default or "None"
					local tch = opts.TouchEnabled == nil and true or opts.TouchEnabled
					local cb = opts.Callback
					local tip = opts.Tooltip

					self:HideEmpty()
					local kbo = { _maid = Maid.New() }
					self._maid:GiveTask(kbo._maid)

					local kbf = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local kbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = k_nm, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, kbf)
					l_hlp.ApplyFont(kbl)

					local c_tip = tip
					l_hlp.ApplyTooltip(kbo._maid, kbf, function() return c_tip or "" end, w)
					local core = att_kb(kbo._maid, kbf, UDim2.new(0, 24, 0, 24), UDim2.new(1, -2, 0.5, 0), Vector2.new(1, 0.5), 5, def, tch, cb)

					function kbo:SetValue(v) core:SetValue(v) end
					function kbo:GetValue() return core:GetValue() end
					function kbo:Disable() core:Disable() l_hlp.UpdateThemeMapping(kbl, "TextColor3", "Border") end
					function kbo:Enable() core:Enable() l_hlp.UpdateThemeMapping(kbl, "TextColor3", "TextDim") end
					function kbo:SetText(t) kbl.Text = tostring(t or "") end
					function kbo:SetTooltip(t) c_tip = t end
					function kbo:Remove()
						if l_lib.flags[fl] == kbo then l_lib.flags[fl] = nil end
						kbo._maid:Destroy()
						l_hlp.RemoveThemeEntries(kbf, true)
						kbf:Destroy()
					end

					l_lib.flags[fl] = kbo
					return kbo
				end

				function tc_o:AddToggle(opts: any): any
					opts = opts or {}
					local tn = opts.Name or "Toggle"
					local fl = opts.Flag or tn
					local cb = opts.Callback
					local tip = opts.Tooltip

					self:HideEmpty()
					local t = { _maid = Maid.New(), _keybinds = {} }
					self._maid:GiveTask(t._maid)

					local tf = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, self.container)
					local tt = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = tn, TextColor3 = { Theme = "TextDim" }, TextSize = 14, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tf)
					l_hlp.ApplyFont(tt)
					local cbf = l_hlp.Make("Frame", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -2, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = { Theme = "Body" }, BorderSizePixel = 0, ZIndex = 3 }, tf)
					local cbs = l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, cbf)
					local cm = l_hlp.Make("ImageLabel", { Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Image = icns.Check, ImageColor3 = { Theme = "Accent" }, ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit, ZIndex = 4 }, cbf)
					local clk = l_hlp.Make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", ZIndex = 5 }, tf)

					local state, dis, c_tip = false, false, tip
					l_hlp.ApplyTooltip(t._maid, tf, function() return dis and "This Function Is Disabled! :(" or (c_tip or "") end, w)
					l_lib.flags[fl] = t

					function t:SetValue(v)
						if dis then return end
						state = not not v
						ts:Create(cm, tw_def, { ImageTransparency = state and 0 or 1 }):Play()
						if state then
							l_hlp.UpdateThemeMapping(cbs, "Color", "Accent")
							l_hlp.UpdateThemeMapping(tt, "TextColor3", "Text")
						else
							l_hlp.UpdateThemeMapping(cbs, "Color", "Border")
							l_hlp.UpdateThemeMapping(tt, "TextColor3", "TextDim")
						end
						task.spawn(s_call, cb, state)
					end
					function t:SetDisabled(v)
						dis = not not v
						l_hlp.UpdateThemeMapping(tt, "TextColor3", dis and "Border" or (state and "Text" or "TextDim"))
						l_hlp.UpdateThemeMapping(cbs, "Color", "Border")
						l_hlp.UpdateThemeMapping(cbf, "BackgroundColor3", dis and "BodyLight" or "Body")
						for _, k in self._keybinds do k:SetDisabled(dis) end
					end
					function t:SetText(v) tt.Text = tostring(v or "") end
					function t:GetValue() return state end
					function t:SetTooltip(v) c_tip = v end
					function t:Disable() self:SetDisabled(true) end
					function t:Enable() self:SetDisabled(false) end
					function t:Remove()
						if l_lib.flags[fl] == t then l_lib.flags[fl] = nil end
						t._maid:Destroy()
						l_hlp.RemoveThemeEntries(tf, true)
						tf:Destroy()
					end

					function t:AddKeybind(kb_opts: any): any
						kb_opts = kb_opts or {}
						local def = kb_opts.Default or "None"
						local tch = kb_opts.TouchEnabled == nil and true or kb_opts.TouchEnabled
						local k_cb = kb_opts.Callback or function() if not dis then t:SetValue(not state) end end
						cbf.Position = UDim2.new(1, -34, 0.5, 0)
						tt.Size = UDim2.new(1, -56, 1, 0)
						local kb = att_kb(t._maid, tf, UDim2.new(0, 24, 0, 24), UDim2.new(1, -2, 0.5, 0), Vector2.new(1, 0.5), 10, def, tch, k_cb)
						t_ins(self._keybinds, kb)
						return kb
					end

					t._maid:GiveTask(clk.MouseButton1Click:Connect(function() if not dis then t:SetValue(not state) end end))
					if opts.Default then t:SetValue(true) end
					return t
				end

				function tc_o:AddButton(opts: any): any
					opts = opts or {}
					local bn = opts.Name or "Button"
					local cb = opts.Callback
					local tip = opts.Tooltip

					self:HideEmpty()
					local bo = { _maid = Maid.New() }
					self._maid:GiveTask(bo._maid)

					local bc = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					l_hlp.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, bc)

					local b_list, kb_cnt = {}, 0
					local function upd_layout()
						local n, k = #b_list, kb_cnt
						if n == 0 then return end
						local tot = ((n + k - 1) * 6) + (k * 24)
						local off = m_flr(tot / n)
						for _, b in b_list do b.Size = UDim2.new(1 / n, -off, 1, 0) end
					end

					local function c_btn(txt, b_cb, b_tip, l_ord)
						local bf = l_hlp.Make("TextButton", { Size = UDim2.new(1, 0, 1, 0), LayoutOrder = l_ord, BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 2 }, bc)
						t_ins(b_list, bf)
						upd_layout()

						l_hlp.ApplyGradient(bf, "BodyLight", "Body", 0.96)
						l_hlp.AddFeedback(bo._maid, bf)
						local bs = l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, bf)
						local bt = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = txt, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, bf)
						l_hlp.ApplyFont(bt)

						local dis, is_d, is_c = false, false, false
						local o_txt, c_tip = txt, b_tip
						local o = { _maid = Maid.New() }
						bo._maid:GiveTask(o._maid)

						l_hlp.ApplyTooltip(o._maid, bf, function() return dis and "This Function Is Disabled! :(" or (c_tip or "") end, w)

						function o:ForceFire() if not dis then task.spawn(s_call, b_cb) end end
						function o:Disable() self:SetDisabled(true) end
						function o:Enable() self:SetDisabled(false) end
						function o:SetDisabled(v)
							dis = not not v
							if not is_c then l_hlp.UpdateThemeMapping(bt, "TextColor3", dis and "Border" or "Text") end
							l_hlp.UpdateThemeMapping(bs, "Color", "Border")
						end
						function o:SetText(v) o_txt = tostring(v or "") if not is_c then bt.Text = o_txt end end
						function o:SetTooltip(v) c_tip = v end
						function o:MakeDangerous() is_d = true return self end
						function o:Remove()
							o._maid:Destroy()
							local idx = t_fnd(b_list, bf)
							if idx then t_rem(b_list, idx) end
							l_hlp.RemoveThemeEntries(bf, true)
							bf:Destroy()
							upd_layout()
						end

						function o:AddKeybind(kb_opts: any): any
							kb_opts = kb_opts or {}
							local def = kb_opts.Default or "None"
							local tch = kb_opts.TouchEnabled == nil and true or kb_opts.TouchEnabled
							local k_cb = kb_opts.Callback or function() if not dis then o:ForceFire() end end
							kb_cnt += 1
							upd_layout()
							local kb = att_kb(o._maid, bc, UDim2.new(0, 24, 0, 24), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0), 10, def, tch, k_cb)
							kb.Button.LayoutOrder = l_ord + 1
							local o_rm = kb.Remove
							function kb:Remove()
								kb_cnt -= 1
								o_rm(self)
								upd_layout()
							end
							return kb
						end

						o._maid:GiveTask(bf.MouseButton1Click:Connect(function()
							if dis then return end
							if is_d and not is_c then
								is_c = true
								bt.Text = "Are You Sure?"
								l_hlp.UpdateThemeMapping(bt, "TextColor3", "Accent")
								task.delay(3, function()
									if is_c then
										is_c = false
										bt.Text = o_txt
										l_hlp.UpdateThemeMapping(bt, "TextColor3", dis and "Border" or "Text")
									end
								end)
								return
							end
							is_c = false
							bt.Text = o_txt
							if not dis then l_hlp.UpdateThemeMapping(bt, "TextColor3", "Text") end
							o:ForceFire()
						end))

						return o, bf
					end

					local btn, _ = c_btn(bn, cb, tip, 10)
					function btn:AddSubButton(s_opts: any): any
						s_opts = s_opts or {}
						local sb, _ = c_btn(s_opts.Name or "Button", s_opts.Callback, s_opts.Tooltip, 30)
						return sb
					end
					function btn:Remove()
						bo._maid:Destroy()
						l_hlp.RemoveThemeEntries(bc, true)
						bc:Destroy()
					end

					return btn
				end

				function tc_o:AddLabel(opts: any): any
					opts = opts or {}
					local txt = opts.Text or ""
					local tip = opts.Tooltip

					self:HideEmpty()
					local lo = { _maid = Maid.New() }
					self._maid:GiveTask(lo._maid)

					local lbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, BorderSizePixel = 0, Text = txt, TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, RichText = true, TextTruncate = Enum.TextTruncate.AtEnd }, self.container)
					l_hlp.ApplyFont(lbl)

					local c_tip = tip
					l_hlp.ApplyTooltip(lo._maid, lbl, function() return c_tip or "" end, w)

					function lo:SetText(v) lbl.Text = tostring(v or "") end
					function lo:SetTooltip(v) c_tip = v end
					function lo:Remove()
						lo._maid:Destroy()
						l_hlp.RemoveThemeEntries(lbl, true)
						lbl:Destroy()
					end
					return lo
				end

				function tc_o:AddSlider(opts: any): any
					opts = opts or {}
					local sn = opts.Name or "Slider"
					local fl = opts.Flag or sn
					local min_v = tonumber(opts.Min) or 0
					local max_v = tonumber(opts.Max) or 100
					if min_v > max_v then min_v, max_v = max_v, min_v end
					if min_v == max_v then max_v = min_v + 1 end
					local def = m_clp(tonumber(opts.Default) or min_v, min_v, max_v)
					local sfx = tostring(opts.Suffix or "")
					local rnd = m_clp(tonumber(opts.Rounding) or 0, 0, 10)
					local cb = opts.Callback
					local tip = opts.Tooltip

					self:HideEmpty()
					local so = { _maid = Maid.New() }
					self._maid:GiveTask(so._maid)

					local sf = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local tl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -50, 0, 14), BackgroundTransparency = 1, BorderSizePixel = 0, Text = sn, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, sf)
					l_hlp.ApplyFont(tl)
					local vl = l_hlp.Make("TextLabel", { Size = UDim2.new(0, 50, 0, 14), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextColor3 = { Theme = "Text" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd }, sf)
					l_hlp.ApplyFont(vl)

					local sbg = l_hlp.Make("TextButton", { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = c_wht, BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 2 }, sf)
					l_hlp.ApplyGradient(sbg, "BodyLight", "Body", 0.96)
					l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, sbg)
					local sfl = l_hlp.Make("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0 }, sbg)

					local cv, is_drg, dis, c_tip = def, false, false, tip
					local mult = 10 ^ rnd

					l_hlp.ApplyTooltip(so._maid, sf, function() return dis and "This Function Is Disabled! :(" or (c_tip or "") end, w)
					l_lib.flags[fl] = so

					local function upd(v)
						v = m_clp(m_rnd(v * mult) / mult, min_v, max_v)
						cv = v
						local rng = max_v - min_v
						local pct = rng > 0 and ((v - min_v) / rng) or 0
						ts:Create(sfl, tw_def, { Size = UDim2.new(pct, 0, 1, 0) }):Play()
						vl.Text = tostring(v) .. sfx
						task.spawn(s_call, cb, v)
					end
					upd(cv)

					so._maid:GiveTask(sbg.InputBegan:Connect(function(inp)
						if dis then return end
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							is_drg = true
							l_hlp.UpdateThemeMapping(tl, "TextColor3", "Text")
							local pct = m_clp((inp.Position.X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
							upd(min_v + (max_v - min_v) * pct)
						end
					end))
					so._maid:GiveTask(uis.InputEnded:Connect(function(inp)
						if dis then return end
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							is_drg = false
							l_hlp.UpdateThemeMapping(tl, "TextColor3", "TextDim")
						end
					end))
					so._maid:GiveTask(uis.InputChanged:Connect(function(inp)
						if dis or not is_drg then return end
						if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
							local pct = m_clp((inp.Position.X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
							upd(min_v + (max_v - min_v) * pct)
						end
					end))

					function so:SetValue(n) upd(tonumber(n) or min_v) end
					function so:GetValue() return cv end
					function so:SetText(t) tl.Text = tostring(t or "") end
					function so:SetTooltip(v) c_tip = v end
					function so:SetDisabled(v)
						dis = not not v
						if dis then
							l_hlp.UpdateThemeMapping(tl, "TextColor3", "Border")
							l_hlp.UpdateThemeMapping(vl, "TextColor3", "Border")
							l_hlp.UpdateThemeMapping(sfl, "BackgroundColor3", "Border")
						else
							l_hlp.UpdateThemeMapping(tl, "TextColor3", "TextDim")
							l_hlp.UpdateThemeMapping(vl, "TextColor3", "Text")
							l_hlp.UpdateThemeMapping(sfl, "BackgroundColor3", "Accent")
						end
					end
					function so:Disable() self:SetDisabled(true) end
					function so:Enable() self:SetDisabled(false) end
					function so:Remove()
						if l_lib.flags[fl] == so then l_lib.flags[fl] = nil end
						so._maid:Destroy()
						l_hlp.RemoveThemeEntries(sf, true)
						sf:Destroy()
					end

					function so:AddKeybind(kb_opts: any): any
						kb_opts = kb_opts or {}
						local def_k = kb_opts.Default or "None"
						local tch = kb_opts.TouchEnabled == nil and true or kb_opts.TouchEnabled
						local k_cb = kb_opts.Callback
						sbg.Size = UDim2.new(1, -34, 0, 14)
						vl.Position = UDim2.new(1, -84, 0, 0)
						return att_kb(so._maid, sf, UDim2.new(0, 24, 0, 24), UDim2.new(1, -2, 0, 20), Vector2.new(1, 0), 10, def_k, tch, k_cb)
					end

					return so
				end

				function tc_o:AddTextBox(opts: any): any
					opts = opts or {}
					local tn = opts.Name or "TextBox"
					local fl = opts.Flag or tn
					local ph = opts.Placeholder or ""
					local is_num = not not opts.IsNumerical
					local mc = tonumber(opts.MaxChars)
					if mc and mc <= 0 then mc = nil end
					local clr_foc = not not opts.ClearOnFocus
					local cb = opts.Callback
					local tip = opts.Tooltip

					self:HideEmpty()
					local tbo = { _maid = Maid.New() }
					self._maid:GiveTask(tbo._maid)

					local tbf = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local tbt = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, BorderSizePixel = 0, Text = tn, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tbf)
					l_hlp.ApplyFont(tbt)
					local tbb = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 2 }, tbf)
					l_hlp.ApplyGradient(tbb, "BodyLight", "Body", 0.96)
					local tbs = l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tbb)
					local tb_in = l_hlp.Make("TextBox", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", PlaceholderText = ph, TextColor3 = { Theme = "Text" }, PlaceholderColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ClearTextOnFocus = clr_foc, ZIndex = 3 }, tbb)
					l_hlp.ApplyFont(tb_in)

					local dis, c_isnum, c_maxc, c_tip = false, is_num, mc, tip
					l_hlp.ApplyTooltip(tbo._maid, tbf, function() return dis and "This Function Is Disabled! :(" or (c_tip or "") end, w)
					l_lib.flags[fl] = tbo

					tbo._maid:GiveTask(tb_in:GetPropertyChangedSignal("Text"):Connect(function()
						if dis then return end
						local t = tb_in.Text
						if c_isnum then t = s_rep(t, "[^%d%.%-]", "") end
						if c_maxc and #t > c_maxc then t = s_sub(t, 1, c_maxc) end
						if tb_in.Text ~= t then tb_in.Text = t end
					end))
					tbo._maid:GiveTask(tb_in.Focused:Connect(function()
						if dis then tb_in:ReleaseFocus() return end
						l_hlp.UpdateThemeMapping(tbt, "TextColor3", "Text")
						l_hlp.UpdateThemeMapping(tbs, "Color", "Accent")
					end))
					tbo._maid:GiveTask(tb_in.FocusLost:Connect(function()
						l_hlp.UpdateThemeMapping(tbt, "TextColor3", "TextDim")
						l_hlp.UpdateThemeMapping(tbs, "Color", "Border")
						if not dis then task.spawn(s_call, cb, tb_in.Text) end
					end))

					function tbo:SetValue(v) tb_in.Text = tostring(v or "") end
					function tbo:GetValue() return tb_in.Text end
					function tbo:SetText(v) tbt.Text = tostring(v or "") end
					function tbo:SetPlaceholderText(v) tb_in.PlaceholderText = tostring(v or "") end
					function tbo:SetTooltip(v) c_tip = v end
					function tbo:SetProperties(isnum, maxch, confo)
						c_isnum = not not isnum
						c_maxc = tonumber(maxch)
						if c_maxc and c_maxc <= 0 then c_maxc = nil end
						if confo ~= nil then tb_in.ClearTextOnFocus = not not confo end
					end
					function tbo:SetDisabled(v)
						dis = not not v
						tb_in.TextEditable = not dis
						l_hlp.UpdateThemeMapping(tbt, "TextColor3", dis and "Border" or "TextDim")
						l_hlp.UpdateThemeMapping(tb_in, "TextColor3", dis and "Border" or "Text")
					end
					function tbo:Disable() self:SetDisabled(true) end
					function tbo:Enable() self:SetDisabled(false) end
					function tbo:Remove()
						if l_lib.flags[fl] == tbo then l_lib.flags[fl] = nil end
						tbo._maid:Destroy()
						l_hlp.RemoveThemeEntries(tbf, true)
						tbf:Destroy()
					end

					function tbo:AddKeybind(kb_opts: any): any
						kb_opts = kb_opts or {}
						local def_k = kb_opts.Default or "None"
						local tch = kb_opts.TouchEnabled == nil and true or kb_opts.TouchEnabled
						local k_cb = kb_opts.Callback or function() if not dis then tb_in:CaptureFocus() end end
						tbb.Size = UDim2.new(1, -34, 0, 24)
						return att_kb(tbo._maid, tbf, UDim2.new(0, 24, 0, 24), UDim2.new(1, -2, 0, 18), Vector2.new(1, 0), 10, def_k, tch, k_cb)
					end

					return tbo
				end

				function tc_o:AddDropdown(opts: any): any
					opts = opts or {}
					local dp_n = opts.Name or "Dropdown"
					local fl = opts.Flag or dp_n
					local items = type(opts.Items) == "table" and opts.Items or {}
					local upd_tm = tonumber(opts.UpdateTime) or 0
					local is_ply = not not opts.IsPlayer
					local is_tm = not not opts.IsTeam
					local is_mlt = not not opts.IsMulti
					local is_sch = not not opts.IsSearchable
					local cb = opts.Callback
					local tip = opts.Tooltip

					self:HideEmpty()
					local do_obj = { _maid = Maid.New() }
					self._maid:GiveTask(do_obj._maid)
					local lm = Maid.New()
					do_obj._maid:GiveTask(lm)

					local df = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local tb2 = l_hlp.Make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 2 }, df)
					l_hlp.ApplyGradient(tb2, "BodyLight", "Body", 0.96)
					l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, tb2)
					local dt = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = dp_n .. ": None", TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, tb2)
					l_hlp.ApplyFont(dt)

					local dis_opts = {}
					local sel = is_mlt and {} or nil
					local d_names, ci = {}, {}
					for _, v in items do ci[#ci + 1] = tostring(v) end
					local dis, c_tip, is_opn = false, tip, false

					l_hlp.ApplyTooltip(do_obj._maid, tb2, function() return dis and "This Function Is Disabled! :(" or (c_tip or "") end, w)
					l_lib.flags[fl] = do_obj

					local fc = l_hlp.Make("TextButton", { Name = "DropdownOverlay", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Visible = false, ZIndex = 90 }, w.gui)
					do_obj._maid:GiveTask(fc)
					local ff = l_hlp.Make("CanvasGroup", { Size = UDim2.new(0, 200, 0, 40), BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 91 }, fc)
					local fb = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 91 }, ff)
					l_hlp.ApplyGradient(fb, "BodyLight", "Body", 0.96)
					local fs = l_hlp.Make("UIStroke", { Color = { Theme = "Accent" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 1 }, ff)

					local s_off = 0
					local sb2: TextBox?
					if is_sch then
						sb2 = l_hlp.Make("TextBox", { Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 6, 0, 6), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", PlaceholderText = "Search...", TextColor3 = { Theme = "Text" }, PlaceholderColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 92 }, ff)
						l_hlp.ApplyFont(sb2)
						l_hlp.Make("Frame", { Size = UDim2.new(1, -12, 0, 1), Position = UDim2.new(0, 6, 0, 32), BackgroundColor3 = { Theme = "Border" }, BorderSizePixel = 0, ZIndex = 92 }, ff)
						s_off = 36
					end

					local fsc = l_hlp.Make("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -s_off - 6), Position = UDim2.new(0, 0, 0, s_off + 3), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, ScrollBarImageColor3 = { Theme = "Border" }, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingEnabled = false, ZIndex = 92 }, ff)
					l_hlp.Make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, fsc)
					l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, fsc)
					local d_empty = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "This Dropdown is Empty! :(", TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, ZIndex = 93, Visible = false }, fsc)
					l_hlp.ApplyFont(d_empty)

					local function upd_tx()
						local str = ""
						if is_mlt then
							local sl, sn = {}, 0
							for k, v in sel do if v then sn += 1 sl[sn] = d_names[k] or k end end
							str = sn > 0 and t_cat(sl, ", ") or "None"
						else
							str = sel and (d_names[sel] or sel) or "None"
						end
						dt.Text = dp_n .. ": " .. str
					end

					local function close_dp()
						if not is_opn then return end
						is_opn = false
						local cp, cs = ff.Position, ff.Size
						local sw_d, sh_d = cs.X.Offset * 0.85, cs.Y.Offset * 0.85
						ts:Create(ff, tw_def, {
							Size = UDim2.new(0, sw_d, 0, sh_d),
							Position = UDim2.new(cp.X.Scale, cp.X.Offset + (cs.X.Offset - sw_d) * 0.5, cp.Y.Scale, cp.Y.Offset + (cs.Y.Offset - sh_d) * 0.5),
							GroupTransparency = 1
						}):Play()
						ts:Create(fs, tw_def, { Transparency = 1 }):Play()
						task.delay(0.22, function() if not is_opn then fc.Visible = false end end)
					end

					local function get_flt(f_txt)
						local r, rn = {}, 0
						for _, it in ci do
							local dn = d_names[it] or it
							if not f_txt or f_txt == "" or s_fnd(s_low(dn), s_low(f_txt), 1, true) then
								rn += 1 r[rn] = it
							end
						end
						return r
					end

					local function build_list(f_txt)
						lm:DoCleaning()
						for _, ch in fsc:GetChildren() do
							if ch:IsA("TextButton") or (ch:IsA("Frame") and ch ~= d_empty) then
								l_hlp.RemoveThemeEntries(ch, true)
								ch:Destroy()
							end
						end
						local flt = get_flt(f_txt)
						local cnt = #flt
						d_empty.Visible = (cnt == 0)
						fsc.ScrollingEnabled = true
						fsc.ScrollBarThickness = cnt > 6 and 2 or 0

						for idx, it in flt do
							local dn = d_names[it] or it
							local opt_dis = dis_opts[it]
							if idx > 1 then
								l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = { Theme = "Accent" }, BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 93 }, fsc)
							end
							local is_sel = is_mlt and sel[it] or (sel == it)
							local ib = l_hlp.Make("TextButton", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", ZIndex = 93 }, fsc)
							local il = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = dn, TextColor3 = opt_dis and { Theme = "Border" } or (is_sel and { Theme = "Accent" } or { Theme = "Text" }), TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 94 }, ib)
							l_hlp.ApplyFont(il)
							l_hlp.Make("ImageLabel", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -16, 0.5, -6), BackgroundTransparency = 1, BorderSizePixel = 0, Image = icns.Check, ImageColor3 = { Theme = "Accent" }, Visible = is_sel, ZIndex = 94 }, ib)

							lm:GiveTask(ib.MouseEnter:Connect(function() if not opt_dis then ts:Create(ib, tw_tip, { BackgroundTransparency = 0.8 }):Play() end end))
							lm:GiveTask(ib.MouseLeave:Connect(function() if not opt_dis then ts:Create(ib, tw_tip, { BackgroundTransparency = 1 }):Play() end end))
							lm:GiveTask(ib.MouseButton1Click:Connect(function()
								if opt_dis then return end
								if is_mlt then
									sel[it] = not sel[it] or nil
								else
									if sel == it then sel = nil else sel = it close_dp() end
								end
								upd_tx()
								task.spawn(s_call, cb, sel)
								if is_opn and fc.Visible then build_list(sb2 and sb2.Text or "") end
							end))
						end
					end

					function do_obj:Update()
						if is_ply then
							ci = {}
							for _, p in pls:GetPlayers() do ci[#ci + 1] = p.Name end
						elseif is_tm then
							ci = {}
							for _, t in tms:GetTeams() do ci[#ci + 1] = t.Name end
						end
						if is_mlt then
							for k in sel do if not t_fnd(ci, k) then sel[k] = nil end end
						else
							if sel and not t_fnd(ci, sel) then sel = nil end
						end
						upd_tx()
						if fc.Visible then build_list(sb2 and sb2.Text or "") end
					end

					if sb2 then do_obj._maid:GiveTask(sb2:GetPropertyChangedSignal("Text"):Connect(function() build_list(sb2.Text) end)) end
					if upd_tm > 0 then
						local alv = true
						do_obj._maid:GiveTask(function() alv = false end)
						task.spawn(function()
							while alv do
								task.wait(upd_tm)
								if not alv then break end
								do_obj:Update()
							end
						end)
					end

					do_obj._maid:GiveTask(tb2.MouseButton1Click:Connect(function()
						if dis or is_opn then return end
						is_opn, fc.Visible = true, true
						if sb2 then sb2.Text = "" end
						do_obj:Update()

						local ml = uis:GetMouseLocation()
						local ww, wh = w.luna.AbsoluteSize.X, w.luna.AbsoluteSize.Y
						local th_d = m_min(180, wh * 0.8)
						local vp = w.gui.AbsoluteSize
						local fw = m_clp(tb2.AbsoluteSize.X, 160, ww * 0.8)
						local fx, fy = ml.X, ml.Y
						if fx + fw > vp.X then fx = vp.X - fw - 4 end
						if fy + th_d > vp.Y then fy = vp.Y - th_d - 4 end
						fx = m_max(4, fx)
						fy = m_max(4, fy)

						local sw_d, sh_d = fw * 0.85, th_d * 0.85
						ff.Position = UDim2.new(0, fx + (fw - sw_d) * 0.5, 0, fy + (th_d - sh_d) * 0.5)
						ff.Size = UDim2.new(0, sw_d, 0, sh_d)
						ff.GroupTransparency, fs.Transparency = 1, 1
						build_list("")
						ts:Create(ff, tw_def, { Size = UDim2.new(0, fw, 0, th_d), Position = UDim2.new(0, fx, 0, fy), GroupTransparency = 0 }):Play()
						ts:Create(fs, tw_def, { Transparency = 0 }):Play()
					end))
					do_obj._maid:GiveTask(fc.MouseButton1Click:Connect(close_dp))

					function do_obj:AddValue(t)
						t = type(t) == "table" and t or { t }
						for _, v in t do ci[#ci + 1] = tostring(v) end
						self:Update()
					end
					function do_obj:EditValue(t)
						t = type(t) == "table" and t or {}
						ci = {}
						for _, v in t do ci[#ci + 1] = tostring(v) end
						self:Update()
					end
					function do_obj:RemoveValue(t)
						t = type(t) == "table" and t or { t }
						for _, v in t do
							local idx = t_fnd(ci, tostring(v))
							if idx then t_rem(ci, idx) end
						end
						self:Update()
					end
					function do_obj:GetValue() return sel end
					function do_obj:SetValue(v)
						if is_mlt then
							sel = {}
							if type(v) == "table" then
								for k, val in v do
									if type(k) == "number" and type(val) == "string" then sel[val] = true
									elseif val then sel[tostring(k)] = true end
								end
							end
						else
							sel = (v ~= nil) and tostring(v) or nil
						end
						self:Update()
					end
					function do_obj:EditText(t)
						if type(t) == "table" then for k, v in t do d_names[tostring(k)] = tostring(v) end end
						self:Update()
					end
					function do_obj:SetTooltip(v) c_tip = v end
					function do_obj:SetDisabled(v)
						dis = not not v
						l_hlp.UpdateThemeMapping(dt, "TextColor3", dis and "Border" or "Text")
						if dis and is_opn then close_dp() end
					end
					function do_obj:Disable() self:SetDisabled(true) end
					function do_obj:Enable() self:SetDisabled(false) end
					function do_obj:Remove()
						if l_lib.flags[fl] == do_obj then l_lib.flags[fl] = nil end
						close_dp()
						do_obj._maid:Destroy()
						l_hlp.RemoveThemeEntries(df, true)
						df:Destroy()
					end
					function do_obj:DisableOption(t)
						t = type(t) == "table" and t or { t }
						for _, v in t do
							local sv = tostring(v)
							dis_opts[sv] = true
							if is_mlt then if sel[sv] then sel[sv] = nil end
							else if sel == sv then sel = nil end end
						end
						self:Update()
					end
					function do_obj:EnableOption(t)
						t = type(t) == "table" and t or { t }
						for _, v in t do dis_opts[tostring(v)] = nil end
						self:Update()
					end

					function do_obj:AddKeybind(kb_opts: any): any
						kb_opts = kb_opts or {}
						local def_k = kb_opts.Default or "None"
						local tch = kb_opts.TouchEnabled == nil and true or kb_opts.TouchEnabled
						local k_cb = kb_opts.Callback
						tb2.Size = UDim2.new(1, -34, 1, 0)
						return att_kb(do_obj._maid, df, UDim2.new(0, 24, 1, 0), UDim2.new(1, -2, 0, 0), Vector2.new(1, 0), 10, def_k, tch, k_cb)
					end

					do_obj:Update()
					return do_obj
				end

				function tc_o:AddCode(opts: any): any
					opts = opts or {}
					local kn = opts.Name or "MyScript"
					local sfx = opts.Suffix or "lua"
					local cd_str = opts.Code or ""
					local hl_on = opts.CodeHighlight == nil and true or opts.CodeHighlight
					local wrt = not not opts.Writable
					local cb = opts.Callback
					local tip = opts.Tooltip
					local fl = opts.Flag or kn

					self:HideEmpty()
					local co = { _maid = Maid.New() }
					self._maid:GiveTask(co._maid)

					local cntr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 140), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local c_bg = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 1 }, cntr)
					l_hlp.ApplyGradient(c_bg, "BodyLight", "Body", 0.96)
					local c_st = l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, c_bg)

					local hdr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 2 }, cntr)
					l_hlp.ApplyGradient(hdr, "BodyLight", "TitleBar")
					l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, ZIndex = 3 }, hdr)

					local t_lbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = kn .. "." .. sfx, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, hdr)
					l_hlp.ApplyFont(t_lbl)

					local cp_b = l_hlp.Make("TextButton", { Size = UDim2.new(0, 40, 1, -6), Position = UDim2.new(1, -4, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", ZIndex = 3, Visible = false }, hdr)
					l_hlp.ApplyGradient(cp_b, "BodyLight", "Body", 0.96)
					l_hlp.AddFeedback(co._maid, cp_b)
					l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, cp_b)
					local cp_tx = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Copy", TextColor3 = { Theme = "Text" }, TextSize = 10, Font = Enum.Font.Legacy, ZIndex = 4 }, cp_b)
					l_hlp.ApplyFont(cp_tx)

					local rn_b = l_hlp.Make("TextButton", { Size = UDim2.new(0, 40, 1, -6), Position = UDim2.new(1, -48, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", ZIndex = 3, Visible = false }, hdr)
					l_hlp.ApplyGradient(rn_b, "BodyLight", "Body", 0.96)
					l_hlp.AddFeedback(co._maid, rn_b)
					local rn_st = l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, rn_b)
					local rn_tx = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Run", TextColor3 = { Theme = "Text" }, TextSize = 10, Font = Enum.Font.Legacy, ZIndex = 4 }, rn_b)
					l_hlp.ApplyFont(rn_tx)

					local has_ls = l_hlp.CheckDep("loadstring")
					local has_cp = l_hlp.CheckDep("setclipboard")

					local ico_img: ImageLabel?
					local function upd_ico_layout(lang)
						local ls = s_low(lang or "")
						local is_l = (ls == "lua" or ls == "luau")
						local ic_id = (ls == "luau" and "rbxassetid://92857476264077")
							or (ls == "lua" and "rbxassetid://131595787434428")
							or ((ls == "py" or ls == "python") and "rbxassetid://127951493476985")
							or ((ls == "js" or ls == "ts" or ls == "javascript" or ls == "typescript") and "rbxassetid://120266034170732")
							or ((ls == "c" or ls == "cpp" or ls == "cs" or ls == "h" or ls == "hpp") and "rbxassetid://95729917526937")
							or ""

						local l_off = 6
						if ic_id ~= "" then
							if not ico_img then
								ico_img = l_hlp.Make("ImageLabel", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 6, 0.5, -6), BackgroundTransparency = 1, BorderSizePixel = 0, Image = ic_id, ImageColor3 = { Theme = "Text" }, ScaleType = Enum.ScaleType.Fit, ZIndex = 4 }, hdr)
							else
								ico_img.Image = ic_id
								ico_img.Visible = true
							end
							l_off = 24
						else
							if ico_img then ico_img.Visible = false end
						end

						local r_off = 4
						if has_cp then
							cp_b.Position = UDim2.new(1, -4, 0.5, 0)
							cp_b.Visible = true
							r_off += 44
						end
						if is_l and has_ls then
							local rx = has_cp and -48 or -4
							rn_b.Position = UDim2.new(1, rx, 0.5, 0)
							rn_b.Visible = true
							r_off += 44
						else
							rn_b.Visible = false
						end

						t_lbl.Position = UDim2.new(0, l_off, 0, 0)
						t_lbl.Size = UDim2.new(1, -(l_off + r_off), 1, 0)
					end
					upd_ico_layout(sfx)

					local sc_fr = l_hlp.Make("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -24), Position = UDim2.new(0, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = { Theme = "Border" }, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 2 }, cntr)
					l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, sc_fr)

					local tx_cls = wrt and "TextBox" or "TextLabel"
					local tx_obj = l_hlp.Make(tx_cls, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextColor3 = { Theme = "Text" }, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, RichText = true, ZIndex = 3 }, sc_fr)
					tx_obj.Font = Enum.Font.Code
					if wrt then
						tx_obj.ClearTextOnFocus = false
						tx_obj.MultiLine = true
					end

					local c_tip = tip
					l_hlp.ApplyTooltip(co._maid, cntr, function() return c_tip or "" end, w)
					l_lib.flags[fl] = co

					local cur_raw = ""
					local l_def = get_lang(sfx)
					local dis = false

					function co:ChangeCode(ns)
						cur_raw = tostring(ns or "")
						tx_obj.Text = hl_on and hl_code(cur_raw, l_def) or cur_raw
					end
					function co:SetValue(v) self:ChangeCode(v) end
					function co:GetValue() return cur_raw end
					function co:SetText(t) t_lbl.Text = tostring(t or "") end
					function co:SetTooltip(v) c_tip = v end
					function co:SetDisabled(v)
						dis = not not v
						if wrt then tx_obj.TextEditable = not dis end
						l_hlp.UpdateThemeMapping(t_lbl, "TextColor3", dis and "Border" or "Text")
						l_hlp.UpdateThemeMapping(cp_tx, "TextColor3", dis and "Border" or "Text")
						if ico_img then l_hlp.UpdateThemeMapping(ico_img, "ImageColor3", dis and "Border" or "Text") end
						if rn_tx then l_hlp.UpdateThemeMapping(rn_tx, "TextColor3", dis and "Border" or "Text") end
					end
					function co:Disable() self:SetDisabled(true) end
					function co:Enable() self:SetDisabled(false) end
					function co:ChangeLanguage(nl)
						l_def = get_lang(nl)
						upd_ico_layout(nl)
						self:ChangeCode(cur_raw)
					end
					function co:Remove()
						if l_lib.flags[fl] == co then l_lib.flags[fl] = nil end
						co._maid:Destroy()
						l_hlp.RemoveThemeEntries(cntr, true)
						cntr:Destroy()
					end

					if wrt then
						co._maid:GiveTask(tx_obj.Focused:Connect(function()
							if dis then tx_obj:ReleaseFocus() return end
							l_hlp.UpdateThemeMapping(c_st, "Color", "Accent")
							tx_obj.Text = cur_raw
						end))
						co._maid:GiveTask(tx_obj.FocusLost:Connect(function()
							if dis then return end
							l_hlp.UpdateThemeMapping(c_st, "Color", "Border")
							local nc = tx_obj.Text
							co:ChangeCode(nc)
							task.spawn(s_call, cb, nc)
						end))
					end

					co._maid:GiveTask(cp_b.MouseButton1Click:Connect(function()
						if dis then return end
						if s_cp then pcall(s_cp, cur_raw) end
						cp_tx.Text = "Copied!"
						task.delay(1.5, function() if cp_tx.Parent then cp_tx.Text = "Copy" end end)
					end))

					co._maid:GiveTask(rn_b.MouseButton1Click:Connect(function()
						if dis or rn_tx.Text == "Running..." then return end
						rn_tx.Text = "Running..."
						l_hlp.UpdateThemeMapping(rn_st, "Color", "Accent")

						task.spawn(function()
							if l_st then
								local fn, err = l_st(cur_raw)
								if fn then
									local s, _ = l_main.SafeCallback(fn)
									if s then
										if rn_tx.Parent then
											rn_tx.Text = "Ran!"
											l_hlp.UpdateThemeMapping(rn_st, "Color", "Border")
										end
									else
										if rn_tx.Parent then
											rn_tx.Text = "Error! :("
											l_hlp.UpdateThemeMapping(rn_tx, "TextColor3", "Error")
											l_hlp.UpdateThemeMapping(rn_st, "Color", "Error")
										end
									end
								else
									if rn_tx.Parent then
										rn_tx.Text = "Error! :("
										l_hlp.UpdateThemeMapping(rn_tx, "TextColor3", "Error")
										l_hlp.UpdateThemeMapping(rn_st, "Color", "Error")
									end
									l_lib:Notify({ Title = "Syntax Error", Description = tostring(err), Time = 5, Type = 3 })
								end
							else
								if rn_tx.Parent then rn_tx.Text = "N/A" end
								l_lib:Notify({ Title = "Execution Error", Description = "loadstring not supported.", Time = 5, Type = 3 })
							end

							task.delay(1.5, function()
								if rn_tx.Parent then
									rn_tx.Text = "Run"
									l_hlp.UpdateThemeMapping(rn_tx, "TextColor3", "Text")
									if rn_st.Color == cols.Error then l_hlp.UpdateThemeMapping(rn_st, "Color", "Border") end
								end
							end)
						end)
					end))

					co:ChangeCode(cd_str)
					return co
				end

				function tc_o:AddViewportFrame(opts: any): any
					opts = opts or {}
					local vn = opts.Name or "Viewport"
					local mdls = type(opts.Models) == "table" and opts.Models or (opts.Models and { opts.Models } or {})
					local c_pos = opts.CameraPosition or CFrame.new(0, 5, 10)
					local fov = opts.FieldOfView or 70
					local amb = opts.Ambient or Color3.fromRGB(200, 200, 200)
					local l_col = opts.LightColor or c_wht
					local l_dir = opts.LightDirection or Vector3.new(-1, -1, -1)
					local v_h = tonumber(opts.Height) or 140
					local tip = opts.Tooltip
					local fl = opts.Flag or vn
					local rot = not not opts.Rotatable
					local sens = tonumber(opts.RotateSensitivity) or 0.0085

					self:HideEmpty()
					local vpo = { _maid = Maid.New() }
					self._maid:GiveTask(vpo._maid)

					local cntr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, v_h), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local c_bg = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 1 }, cntr)
					l_hlp.ApplyGradient(c_bg, "BodyLight", "Body", 0.96)
					l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, c_bg)

					local hdr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 2 }, cntr)
					l_hlp.ApplyGradient(hdr, "BodyLight", "TitleBar")
					l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, ZIndex = 3 }, hdr)

					local t_lbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = vn, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, hdr)
					l_hlp.ApplyFont(t_lbl)

					local vpf = l_hlp.Make("ViewportFrame", { Size = UDim2.new(1, 0, 1, -24), Position = UDim2.new(0, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, Ambient = amb, LightColor = l_col, LightDirection = l_dir, Active = true, ZIndex = 2 }, cntr)
					local wld = l_hlp.Make("WorldModel", { Name = "ViewportWorld" }, vpf)

					local cam = Instance.new("Camera")
					cam.FieldOfView = fov
					cam.CFrame = c_pos
					cam.Parent = vpf
					vpf.CurrentCamera = cam

					local o_tg = Vector3.new(0, 0, 0)
					local o_dist = m_max((typeof(c_pos) == "CFrame" and c_pos.Position or o_tg).Magnitude, 6)
					local o_yaw, o_pitch = 0, 0

					local function g_bounds(inst)
						if not inst then return nil end
						if inst:IsA("Model") then
							local s, cf, sz = pcall(inst.GetBoundingBox, inst)
							if s and cf and sz then return cf.Position, sz end
						elseif inst:IsA("BasePart") then
							return inst.Position, inst.Size
						end
						return nil
					end

					local function sync_orbit(cf)
						if typeof(cf) ~= "CFrame" then return end
						local off = cf.Position - o_tg
						local d = off.Magnitude
						if d < 0.001 then d = o_dist end
						o_dist = d
						o_yaw = m_atn(off.X, off.Z)
						o_pitch = m_asn(m_clp(off.Y / d, -0.9999, 0.9999))
					end

					local function app_orbit()
						if not rot then return end
						local cp = m_cos(o_pitch)
						local off = Vector3.new(m_sin(o_yaw) * cp * o_dist, m_sin(o_pitch) * o_dist, m_cos(o_yaw) * cp * o_dist)
						cam.CFrame = CFrame.lookAt(o_tg + off, o_tg)
					end

					local function ref_orbit()
						local fnd, min_p, max_p = false, nil, nil
						for _, ch in wld:GetChildren() do
							local p, sz = g_bounds(ch)
							if p and sz then
								local h = sz * 0.5
								local mn, mx = p - h, p + h
								if not fnd then min_p, max_p, fnd = mn, mx, true
								else
									min_p = Vector3.new(m_min(min_p.X, mn.X), m_min(min_p.Y, mn.Y), m_min(min_p.Z, mn.Z))
									max_p = Vector3.new(m_max(max_p.X, mx.X), m_max(max_p.Y, mx.Y), m_max(max_p.Z, mx.Z))
								end
							end
						end
						if fnd then
							o_tg = (min_p + max_p) * 0.5
							local sz = max_p - min_p
							o_dist = m_max(m_max(sz.X, sz.Y, sz.Z) * 1.65, 6)
						else
							o_tg = Vector3.new(0, 0, 0)
							o_dist = m_max((typeof(c_pos) == "CFrame" and c_pos.Position or o_tg).Magnitude, 6)
						end
						if rot then
							if typeof(c_pos) == "CFrame" then sync_orbit(c_pos) end
							app_orbit()
						else
							cam.CFrame = c_pos
						end
					end

					local function set_cam(cf, n_fov)
						if cf then
							c_pos = cf
							if rot and typeof(cf) == "CFrame" then sync_orbit(cf) app_orbit()
							else cam.CFrame = cf end
						end
						if n_fov then cam.FieldOfView = n_fov end
					end

					local c_tip = tip
					l_hlp.ApplyTooltip(vpo._maid, cntr, function() return c_tip or "" end, w)
					l_lib.flags[fl] = vpo

					local dis, drg, d_inp, d_st, d_yaw, d_pt = false, false, nil, nil, 0, 0

					function vpo:SetModels(nm)
						self:Clear()
						local t = type(nm) == "table" and nm or (nm and { nm } or {})
						for _, m in t do
							if typeof(m) == "Instance" then
								local cl = m:Clone()
								if cl then cl.Parent = wld end
							end
						end
						ref_orbit()
					end
					function vpo:Clear()
						for _, ch in wld:GetChildren() do ch:Destroy() end
						ref_orbit()
					end
					function vpo:SetCamera(cf, n_fov) set_cam(cf, n_fov) end
					function vpo:SetLighting(am, lc, ld)
						if am then vpf.Ambient = am end
						if lc then vpf.LightColor = lc end
						if ld then vpf.LightDirection = ld end
					end
					function vpo:IsRotatable(v)
						if v == nil then return rot end
						rot = not not v
						if rot then ref_orbit() else cam.CFrame = c_pos end
						return rot
					end
					function vpo:SetHeight(nh) cntr.Size = UDim2.new(1, 0, 0, nh) end
					function vpo:GetViewport() return vpf end
					function vpo:GetCamera() return cam end
					function vpo:SetText(t) t_lbl.Text = tostring(t or "") end
					function vpo:SetTooltip(t) c_tip = t end
					function vpo:SetDisabled(v)
						dis = not not v
						l_hlp.UpdateThemeMapping(t_lbl, "TextColor3", dis and "Border" or "Text")
					end
					function vpo:Disable() self:SetDisabled(true) end
					function vpo:Enable() self:SetDisabled(false) end
					function vpo:Remove()
						if l_lib.flags[fl] == vpo then l_lib.flags[fl] = nil end
						vpo._maid:Destroy()
						l_hlp.RemoveThemeEntries(cntr, true)
						cntr:Destroy()
					end

					vpo._maid:GiveTask(vpf.InputBegan:Connect(function(inp)
						if not rot or dis then return end
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							drg = true
							d_inp = inp
							d_st = Vector2.new(inp.Position.X, inp.Position.Y)
							d_yaw = o_yaw
							d_pt = o_pitch
						end
					end))
					vpo._maid:GiveTask(uis.InputChanged:Connect(function(inp)
						if not drg or not d_inp or dis or not rot then return end
						if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
							local d = Vector2.new(inp.Position.X, inp.Position.Y) - d_st
							o_yaw = d_yaw - (d.X * sens)
							o_pitch = m_clp(d_pt - (d.Y * sens), -1.35, 1.35)
							app_orbit()
						end
					end))
					vpo._maid:GiveTask(uis.InputEnded:Connect(function(inp)
						if inp == d_inp then drg = false d_inp = nil d_st = nil end
					end))

					vpo:SetModels(mdls)
					return vpo
				end

				function tc_o:AddImage(opts: any): any
					opts = opts or {}
					local iname = opts.Name or "Image"
					local img = opts.Image or ""
					local ih = tonumber(opts.Height) or 140
					local s_tp = opts.ScaleType or Enum.ScaleType.Fit
					local tip = opts.Tooltip
					local fl = opts.Flag or iname

					self:HideEmpty()
					local imo = { _maid = Maid.New() }
					self._maid:GiveTask(imo._maid)

					local cntr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, ih), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local c_bg = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 1 }, cntr)
					l_hlp.ApplyGradient(c_bg, "BodyLight", "Body", 0.96)
					l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, c_bg)

					local hdr = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 2 }, cntr)
					l_hlp.ApplyGradient(hdr, "BodyLight", "TitleBar")
					l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = { Theme = "Accent" }, BorderSizePixel = 0, ZIndex = 3 }, hdr)

					local t_lbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = iname, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 }, hdr)
					l_hlp.ApplyFont(t_lbl)

					local il = l_hlp.Make("ImageLabel", { Size = UDim2.new(1, -12, 1, -36), Position = UDim2.new(0, 6, 0, 30), BackgroundColor3 = c_wht, BackgroundTransparency = 1, BorderSizePixel = 0, Image = img, ScaleType = s_tp, ZIndex = 2 }, cntr)

					local c_tip = tip
					l_hlp.ApplyTooltip(imo._maid, cntr, function() return c_tip or "" end, w)
					l_lib.flags[fl] = imo
					local dis = false

					function imo:SetImage(ni) il.Image = tostring(ni or "") end
					function imo:GetImage() return il.Image end
					function imo:SetScaleType(st) if st then il.ScaleType = st end end
					function imo:SetHeight(nh) cntr.Size = UDim2.new(1, 0, 0, tonumber(nh) or ih) end
					function imo:GetImageLabel() return il end
					function imo:SetValue(v) self:SetImage(v) end
					function imo:GetValue() return il.Image end
					function imo:SetText(t) t_lbl.Text = tostring(t or "") end
					function imo:SetTooltip(v) c_tip = v end
					function imo:SetDisabled(v)
						dis = not not v
						l_hlp.UpdateThemeMapping(t_lbl, "TextColor3", dis and "Border" or "Text")
						ts:Create(il, tw_def, { ImageTransparency = dis and 0.6 or 0 }):Play()
					end
					function imo:Disable() self:SetDisabled(true) end
					function imo:Enable() self:SetDisabled(false) end
					function imo:Remove()
						if l_lib.flags[fl] == imo then l_lib.flags[fl] = nil end
						imo._maid:Destroy()
						l_hlp.RemoveThemeEntries(cntr, true)
						cntr:Destroy()
					end

					return imo
				end

				function tc_o:AddColorpicker(opts: any): any
					opts = opts or {}
					local c_nm = opts.Name or "Colorpicker"
					local fl = opts.Flag or c_nm
					local def = opts.Default or opts.Color or c_wht
					if typeof(def) ~= "Color3" then def = c_wht end
					local cb = opts.Callback
					local tip = opts.Tooltip

					self:HideEmpty()
					local cpo = { _maid = Maid.New(), _keybinds = {} }
					self._maid:GiveTask(cpo._maid)

					local cpf = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0 }, self.container)
					local cpl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, -34, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = c_nm, TextColor3 = { Theme = "TextDim" }, TextSize = 12, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, cpf)
					l_hlp.ApplyFont(cpl)

					local sw = l_hlp.Make("TextButton", { Size = UDim2.new(0, 23, 0, 23), Position = UDim2.new(1, -2, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = def, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 2 }, cpf)
					local sw_st = l_hlp.Make("UIStroke", { Color = cols.Accent, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 0.5 }, sw)
					local sw_ov = l_hlp.Make("Frame", { Name = "OpenButtonGradient", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_blk, BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = sw.ZIndex + 1 }, sw)
					l_hlp.Make("UIGradient", { Color = ColorSequence.new(c_blk), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.7) }), Rotation = 90 }, sw_ov)
					t_ins(l_lib.themeableobjects, { Obj = sw_st, Prop = "Color", ColorName = "Accent" })

					local dis, c_tip = false, tip
					l_hlp.ApplyTooltip(cpo._maid, cpf, function() return dis and "This Function Is Disabled! :(" or (c_tip or "") end, w)
					l_lib.flags[fl] = cpo

					local h_v, s_v, v_v = def:ToHSV()
					local com = def
					local cur_m, is_opn = "RGB", false
					local d_tg, d_oc = nil, false

					local function cur_col() return Color3.fromHSV(h_v, s_v, v_v) end

					local fc = l_hlp.Make("TextButton", { Name = "ColorpickerOverlay", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_blk, BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Visible = false, ZIndex = 95 }, w.gui)
					cpo._maid:GiveTask(fc)

					local cg = l_hlp.Make("CanvasGroup", { Size = UDim2.new(0, 320, 0, 230), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 96 }, fc)
					local cg_st = l_hlp.Make("UIStroke", { Color = cols.Accent, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 1 }, cg)
					t_ins(l_lib.themeableobjects, { Obj = cg_st, Prop = "Color", ColorName = "Accent" })

					local bdy = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 96 }, cg)
					l_hlp.ApplyGradient(bdy, "BodyLight", "Body", 0.96)
					l_hlp.Make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, bdy)

					local tl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, BorderSizePixel = 0, Text = c_nm, TextColor3 = { Theme = "Text" }, TextSize = 13, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 97 }, bdy)
					l_hlp.ApplyFont(tl)

					local l_col_f = l_hlp.Make("Frame", { Size = UDim2.new(0.42, -6, 1, -22), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, bdy)
					local r_col_f = l_hlp.Make("Frame", { Size = UDim2.new(0.58, -6, 1, -22), Position = UDim2.new(0.42, 6, 0, 22), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, bdy)

					local swt = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, l_col_f)
					l_hlp.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, swt)

					local m_btns = {}
					local set_m
					for i, m in ipairs({ "RGB", "HSV", "HEX" }) do
						local mb = l_hlp.Make("TextButton", { Size = UDim2.new(1 / 3, -8 / 3, 1, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 97 }, swt)
						l_hlp.ApplyGradient(mb, "BodyLight", "Body", 0.96)
						local mbs = l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, mb)
						local mbl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = m, TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, ZIndex = 98 }, mb)
						l_hlp.ApplyFont(mbl)
						m_btns[m] = { Stroke = mbs, Label = mbl }
						cpo._maid:GiveTask(mb.MouseButton1Click:Connect(function() set_m(m) end))
					end

					local rws = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, -28), Position = UDim2.new(0, 0, 0, 28), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, l_col_f)
					l_hlp.Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, rws)
					local b_lbls, b_boxes = {}, {}
					for i = 1, 3 do
						local rw = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 97 }, rws)
						local rl = l_hlp.Make("TextLabel", { Size = UDim2.new(0, 26, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextColor3 = { Theme = "TextDim" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 98 }, rw)
						l_hlp.ApplyFont(rl)
						local bf = l_hlp.Make("Frame", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 97 }, rw)
						l_hlp.ApplyGradient(bf, "BodyLight", "Body", 0.96)
						l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, bf)
						local tbx = l_hlp.Make("TextBox", { Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", ClearTextOnFocus = false, TextColor3 = { Theme = "Text" }, TextSize = 11, Font = Enum.Font.Legacy, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 98 }, bf)
						l_hlp.ApplyFont(tbx)
						b_lbls[i], b_boxes[i] = rl, tbx
					end

					local sv_sq = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, -54), BackgroundColor3 = Color3.fromHSV(h_v, 1, 1), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 97 }, r_col_f)
					l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, sv_sq)
					local sv_gr = l_hlp.Make("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHSV(h_v, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(h_v, 1, 0.95)) }), Rotation = 90 }, sv_sq)
					local sat_l = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 97 }, sv_sq)
					l_hlp.Make("UIGradient", { Color = ColorSequence.new(c_wht), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Rotation = 0 }, sat_l)
					local val_l = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_blk, BorderSizePixel = 0, ZIndex = 98 }, sv_sq)
					l_hlp.Make("UIGradient", { Color = ColorSequence.new(c_blk), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }), Rotation = 90 }, val_l)
					local dk_ov = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = c_blk, BorderSizePixel = 0, ZIndex = 98 }, sv_sq)
					l_hlp.Make("UIGradient", { Color = ColorSequence.new(c_blk), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.7) }), Rotation = 0 }, dk_ov)

					local sv_p = l_hlp.Make("Frame", { Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(s_v, 0, 1 - v_v, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 99 }, sv_sq)
					l_hlp.Make("UICorner", { CornerRadius = UDim.new(1, 0) }, sv_p)
					local sv_pst = l_hlp.Make("UIStroke", { Color = v_v > 0.5 and c_blk or c_wht, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, sv_p)

					local h_stp = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -30), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = c_wht, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 97 }, r_col_f)
					l_hlp.Make("UIStroke", { Color = { Theme = "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, h_stp)
					l_hlp.Make("UIGradient", { Rotation = 0, Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
						ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
						ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
						ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
						ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
						ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
					}) }, h_stp)
					local h_p = l_hlp.Make("Frame", { Size = UDim2.new(0, 4, 1, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(h_v, 0, 0.5, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, ZIndex = 98 }, h_stp)
					l_hlp.Make("UIStroke", { Color = c_blk, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, h_p)

					local b_rw = l_hlp.Make("Frame", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 97 }, r_col_f)
					l_hlp.Make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, b_rw)

					local function mk_act_btn(txt, ord, act)
						local b = l_hlp.Make("TextButton", { Size = UDim2.new(0.5, -3, 1, 0), BackgroundColor3 = c_wht, BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = ord, ZIndex = 97 }, b_rw)
						l_hlp.ApplyGradient(b, "BodyLight", "Body", 0.96)
						l_hlp.Make("UIStroke", { Color = { Theme = act and "Accent" or "Border" }, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
						local bl = l_hlp.Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = txt, TextColor3 = { Theme = act and "Accent" or "Text" }, TextSize = 11, Font = Enum.Font.Legacy, ZIndex = 98 }, b)
						l_hlp.ApplyFont(bl)
						l_hlp.AddFeedback(cpo._maid, b)
						return b
					end
					local c_can = mk_act_btn("Cancel", 1, false)
					local c_app = mk_act_btn("Apply", 2, true)

					local function to_hex(c) return s_fmt("%02X", m_rnd(c.R * 255)), s_fmt("%02X", m_rnd(c.G * 255)), s_fmt("%02X", m_rnd(c.B * 255)) end
					local function upd_boxes()
						local c = cur_col()
						if cur_m == "RGB" then
							b_lbls[1].Text, b_lbls[2].Text, b_lbls[3].Text = "R", "G", "B"
							b_boxes[1].Text = tostring(m_rnd(c.R * 255))
							b_boxes[2].Text = tostring(m_rnd(c.G * 255))
							b_boxes[3].Text = tostring(m_rnd(c.B * 255))
						elseif cur_m == "HSV" then
							b_lbls[1].Text, b_lbls[2].Text, b_lbls[3].Text = "H", "S", "V"
							b_boxes[1].Text = tostring(m_rnd(h_v * 360))
							b_boxes[2].Text = tostring(m_rnd(s_v * 100))
							b_boxes[3].Text = tostring(m_rnd(v_v * 100))
						else
							b_lbls[1].Text, b_lbls[2].Text, b_lbls[3].Text = "RR", "GG", "BB"
							local r, g, b = to_hex(c)
							b_boxes[1].Text, b_boxes[2].Text, b_boxes[3].Text = r, g, b
						end
					end

					local function render_cp(skp)
						local c = cur_col()
						local hc = Color3.fromHSV(h_v, 1, 1)
						local dhc = Color3.fromHSV(h_v, 1, 0.95)
						sv_sq.BackgroundColor3 = hc
						sv_gr.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, hc), ColorSequenceKeypoint.new(1, dhc) })
						sv_p.Position = UDim2.new(m_clp(s_v, 0, 1), 0, 1 - m_clp(v_v, 0, 1), 0)
						ts:Create(sv_pst, tw_def, { Color = v_v > 0.5 and c_blk or c_wht }):Play()
						h_p.Position = UDim2.new(m_clp(h_v, 0, 1), 0, 0.5, 0)
						sw.BackgroundColor3 = c
						if not skp then upd_boxes() end
					end

					set_m = function(m)
						cur_m = m
						for k, refs in m_btns do
							local on = (k == m)
							l_hlp.UpdateThemeMapping(refs.Stroke, "Color", on and "Accent" or "Border")
							l_hlp.UpdateThemeMapping(refs.Label, "TextColor3", on and "Accent" or "TextDim")
						end
						upd_boxes()
					end

					local function hex_pair(t)
						local cl = s_rep(s_upp(tostring(t or "")), "[^0-9A-F]", "")
						return cl == "" and 0 or m_clp(tonumber(s_sub(cl, 1, 2), 16) or 0, 0, 255)
					end

					local function commit_boxes()
						if cur_m == "RGB" then
							local r = m_clp(m_flr(tonumber(b_boxes[1].Text) or 0), 0, 255)
							local g = m_clp(m_flr(tonumber(b_boxes[2].Text) or 0), 0, 255)
							local b = m_clp(m_flr(tonumber(b_boxes[3].Text) or 0), 0, 255)
							h_v, s_v, v_v = Color3.fromRGB(r, g, b):ToHSV()
						elseif cur_m == "HSV" then
							h_v = m_clp(tonumber(b_boxes[1].Text) or 0, 0, 360) / 360
							s_v = m_clp(tonumber(b_boxes[2].Text) or 0, 0, 100) / 100
							v_v = m_clp(tonumber(b_boxes[3].Text) or 0, 0, 100) / 100
						else
							h_v, s_v, v_v = Color3.fromRGB(hex_pair(b_boxes[1].Text), hex_pair(b_boxes[2].Text), hex_pair(b_boxes[3].Text)):ToHSV()
						end
						render_cp()
					end
					for _, tbx in ipairs(b_boxes) do cpo._maid:GiveTask(tbx.FocusLost:Connect(commit_boxes)) end

					local function set_sv(pos)
						local ap, as = sv_sq.AbsolutePosition, sv_sq.AbsoluteSize
						if as.X <= 0 or as.Y <= 0 then return end
						s_v = m_clp((pos.X - ap.X) / as.X, 0, 1)
						v_v = 1 - m_clp((pos.Y - ap.Y) / as.Y, 0, 1)
						render_cp()
					end
					local function set_hue(pos)
						local ap, as = h_stp.AbsolutePosition, h_stp.AbsoluteSize
						if as.X <= 0 then return end
						h_v = m_clp((pos.X - ap.X) / as.X, 0, 1)
						render_cp()
					end

					cpo._maid:GiveTask(sv_sq.InputBegan:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							d_tg, d_oc = "sv", false
							set_sv(inp.Position)
						end
					end))
					cpo._maid:GiveTask(h_stp.InputBegan:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							d_tg, d_oc = "hue", false
							set_hue(inp.Position)
						end
					end))
					cpo._maid:GiveTask(uis.InputChanged:Connect(function(inp)
						if not d_tg then return end
						if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
							d_oc = true
							if d_tg == "sv" then set_sv(inp.Position) elseif d_tg == "hue" then set_hue(inp.Position) end
						end
					end))
					cpo._maid:GiveTask(uis.InputEnded:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							d_tg = nil
							task.defer(function() d_oc = false end)
						end
					end))

					local function close_cp()
						if not is_opn then return end
						is_opn, d_tg, d_oc = false, nil, false
						ts:Create(sw_st, tw_def, { Transparency = 0.5 }):Play()
						local s = cg.Size
						ts:Create(cg, tw_def, { GroupTransparency = 1, Size = UDim2.new(0, s.X.Offset * 0.9, 0, s.Y.Offset * 0.9) }):Play()
						ts:Create(cg_st, tw_def, { Transparency = 1 }):Play()
						task.delay(0.22, function() if not is_opn then fc.Visible = false end end)
					end

					local function open_cp()
						if dis or is_opn then return end
						is_opn, fc.Visible = true, true
						h_v, s_v, v_v = com:ToHSV()
						ts:Create(sw_st, tw_def, { Transparency = 0 }):Play()
						local lw, lh = w.luna.AbsoluteSize.X, w.luna.AbsoluteSize.Y
						local lp = w.luna.AbsolutePosition
						local wd = m_clp(lw * 0.62, 225, 290)
						local hg = m_clp(lh * 0.60, 165, 215)
						cg.Position = UDim2.new(0, lp.X + lw * 0.5, 0, lp.Y + lh * 0.5)
						cg.Size = UDim2.new(0, wd * 0.9, 0, hg * 0.9)
						cg.GroupTransparency, cg_st.Transparency = 1, 1
						set_m(cur_m)
						render_cp()
						ts:Create(cg, tw_def, { Size = UDim2.new(0, wd, 0, hg), GroupTransparency = 0 }):Play()
						ts:Create(cg_st, tw_def, { Transparency = 0 }):Play()
					end

					cpo._maid:GiveTask(sw.MouseButton1Click:Connect(open_cp))
					cpo._maid:GiveTask(fc.MouseButton1Click:Connect(function()
						if d_oc then return end
						local mp, cp, cs = uis:GetMouseLocation(), cg.AbsolutePosition, cg.AbsoluteSize
						if mp.X >= cp.X and mp.X <= cp.X + cs.X and mp.Y >= cp.Y and mp.Y <= cp.Y + cs.Y then return end
						h_v, s_v, v_v = com:ToHSV()
						sw.BackgroundColor3 = com
						close_cp()
					end))
					cpo._maid:GiveTask(c_can.MouseButton1Click:Connect(function()
						h_v, s_v, v_v = com:ToHSV()
						sw.BackgroundColor3 = com
						close_cp()
					end))
					cpo._maid:GiveTask(c_app.MouseButton1Click:Connect(function()
						com = cur_col()
						sw.BackgroundColor3 = com
						task.spawn(s_call, cb, com)
						close_cp()
					end))

					function cpo:GetValue() return com end
					function cpo:GetValueRGB() return m_rnd(com.R * 255), m_rnd(com.G * 255), m_rnd(com.B * 255) end
					function cpo:GetValueHex() local r, g, b = to_hex(com) return r .. g .. b end
					function cpo:SetValue(v, slt: boolean?, skp_r: boolean?)
						local c
						if typeof(v) == "Color3" then c = v
						elseif type(v) == "table" then
							c = Color3.fromRGB(m_clp(tonumber(v[1] or v.R or v.r) or 0, 0, 255), m_clp(tonumber(v[2] or v.G or v.g) or 0, 0, 255), m_clp(tonumber(v[3] or v.B or v.b) or 0, 0, 255))
						elseif type(v) == "string" then
							local cl = s_rep(s_upp(v), "[^0-9A-F]", "")
							if #cl >= 6 then
								c = Color3.fromRGB(tonumber(s_sub(cl, 1, 2), 16) or 0, tonumber(s_sub(cl, 3, 4), 16) or 0, tonumber(s_sub(cl, 5, 6), 16) or 0)
							end
						end
						c = c or com
						com = c
						h_v, s_v, v_v = c:ToHSV()
						sw.BackgroundColor3 = c
						if is_opn and not skp_r then render_cp() end
						if not slt then task.spawn(s_call, cb, c) end
					end
					function cpo:SetText(t) cpl.Text = tostring(t or "") end
					function cpo:SetTooltip(v) c_tip = v end
					function cpo:SetDisabled(v)
						dis = not not v
						l_hlp.UpdateThemeMapping(cpl, "TextColor3", dis and "Border" or "TextDim")
						sw.BackgroundTransparency = dis and 0.5 or 0
						ts:Create(sw_st, tw_def, { Transparency = dis and 0.85 or (is_opn and 0 or 0.5) }):Play()
						if dis and is_opn then close_cp() end
						for _, k in self._keybinds do k:SetDisabled(dis) end
					end
					function cpo:Disable() self:SetDisabled(true) end
					function cpo:Enable() self:SetDisabled(false) end
					function cpo:Remove()
						if l_lib.flags[fl] == cpo then l_lib.flags[fl] = nil end
						close_cp()
						cpo._maid:Destroy()
						l_hlp.RemoveThemeEntries(fc, true)
						fc:Destroy()
						l_hlp.RemoveThemeEntries(cpf, true)
						cpf:Destroy()
					end

					function cpo:AddKeybind(kb_opts: any): any
						kb_opts = kb_opts or {}
						local def_k = kb_opts.Default or "None"
						local tch = kb_opts.TouchEnabled == nil and true or kb_opts.TouchEnabled
						local k_cb = kb_opts.Callback or function() if not dis then open_cp() end end
						sw.Position = UDim2.new(1, -36, 0.5, 0)
						cpl.Size = UDim2.new(1, -68, 1, 0)
						local kb = att_kb(cpo._maid, cpf, UDim2.new(0, 23, 0, 23), UDim2.new(1, -2, 0.5, 0), Vector2.new(1, 0.5), 10, def_k, tch, k_cb)
						t_ins(self._keybinds, kb)
						return kb
					end

					upd_boxes()
					return cpo
				end

				t_ins(sec.tabs, { Button = e_btn, Container = tc, TabContentObj = tc_o })
				if #sec.tabs == 1 then
					s_tit.Visible, s_tb.Visible, s_ln.Visible, tc.Visible = true, false, false, true
					l_hlp.UpdateThemeMapping(e_btn, "TextColor3", "Text")
					l_hlp.UpdateThemeMapping(e_btn, "BackgroundColor3", "BodyLight")
					sec.currenttab = tc
				else
					s_tit.Visible, s_tb.Visible, s_ln.Visible = false, true, true
				end

				sec._maid:GiveTask(e_btn.MouseButton1Click:Connect(function()
					if sec.currenttab == tc then return end
					for _, td in sec.tabs do
						td.Container.Visible = false
						l_hlp.UpdateThemeMapping(td.Button, "TextColor3", "TextDim")
						l_hlp.UpdateThemeMapping(td.Button, "BackgroundColor3", "Body")
					end
					tc.Visible = true
					l_hlp.UpdateThemeMapping(e_btn, "TextColor3", "Text")
					l_hlp.UpdateThemeMapping(e_btn, "BackgroundColor3", "BodyLight")
					sec.currenttab = tc
				end))

				return tc_o
			end

			local fwd = { "AddKeybind", "AddToggle", "AddButton", "AddLabel", "AddSlider", "AddTextBox", "AddDropdown", "AddCode", "AddViewportFrame", "AddImage", "AddColorpicker" }
			for _, m in fwd do
				sec[m] = function(self, o)
					if #self.tabs == 0 then self:AddTab({ Name = "Default" }) end
					return self.tabs[1].TabContentObj[m](self.tabs[1].TabContentObj, o)
				end
			end

			return sec
		end

		function tab:LoadThemeManager()
			local s = self:AddSection({ Name = "Theme Management", Side = "Right" })
			local dp = s:AddDropdown({ Name = "Selected Theme", Items = l_lib:GetFiles("Theme"), IsSearchable = true, Tooltip = "Select a theme.", Flag = "SelectedThemeDP" })
			task.spawn(function()
				local lf = {}
				while task.wait(1) do
					if not dp._maid or dp._maid._d then break end
					local cf = l_lib:GetFiles("Theme")
					local ch = (#lf ~= #cf)
					if not ch then
						for i, v in lf do if cf[i] ~= v then ch = true break end end
					end
					if ch then
						lf = cf
						local cv = dp:GetValue()
						dp:EditValue(cf)
						dp:SetValue(cv)
					end
				end
			end)
			local tb = s:AddTextBox({ Name = "Theme Name", Placeholder = "MyTheme", Tooltip = "Name for saving.", Flag = "ThemeManagerName" })
			local sv = s:AddButton({ Name = "Save Theme", Callback = function()
				local n = tb:GetValue()
				l_lib:SaveTheme(n == "" and "MyTheme" or n)
			end, Tooltip = "Save current colors to new file." })
			sv:AddSubButton({ Name = "Load Theme", Callback = function()
				local n = dp:GetValue()
				if n then l_lib:LoadTheme(n) end
			end })
			local ow = s:AddButton({ Name = "Overwrite Theme", Callback = function()
				local n = dp:GetValue()
				if n then l_lib:SaveTheme(n) end
			end, Tooltip = "Overwrite selected theme." })
			ow:AddSubButton({ Name = "Duplicate Theme", Callback = function()
				local n = dp:GetValue()
				if n then l_lib:DuplicateFile("Theme", n) end
			end })
			local ab = s:AddButton({ Name = "Set Autoload", Callback = function()
				local n = dp:GetValue()
				if n then l_lib:SetThemeAutoload(n) end
			end, Tooltip = "Sets autoload to selected theme." })
			ab:AddSubButton({ Name = "Remove Autoload", Callback = function() l_lib:RemoveThemeAutoload() end })
		end

		function tab:LoadConfigManager()
			local s = self:AddSection({ Name = "Config Management", Side = "Right" })
			local dp = s:AddDropdown({ Name = "Selected Config", Items = l_lib:GetFiles("Config"), IsSearchable = true, Tooltip = "Select a config.", Flag = "SelectedConfigDP" })
			task.spawn(function()
				local lf = {}
				while task.wait(1) do
					if not dp._maid or dp._maid._d then break end
					local cf = l_lib:GetFiles("Config")
					local ch = (#lf ~= #cf)
					if not ch then
						for i, v in lf do if cf[i] ~= v then ch = true break end end
					end
					if ch then
						lf = cf
						local cv = dp:GetValue()
						dp:EditValue(cf)
						dp:SetValue(cv)
					end
				end
			end)
			local tb = s:AddTextBox({ Name = "Config Name", Placeholder = "MyConfig", Tooltip = "Name for saving.", Flag = "ConfigManagerName" })
			local sv = s:AddButton({ Name = "Save Config", Callback = function()
				local n = tb:GetValue()
				l_lib:SaveConfig(n == "" and "MyConfig" or n)
			end, Tooltip = "Save element states to new file." })
			sv:AddSubButton({ Name = "Load Config", Callback = function()
				local n = dp:GetValue()
				if n then l_lib:LoadConfig(n) end
			end })
			local ow = s:AddButton({ Name = "Overwrite Config", Callback = function()
				local n = dp:GetValue()
				if n then l_lib:SaveConfig(n) end
			end, Tooltip = "Overwrite selected config." })
			ow:AddSubButton({ Name = "Duplicate Config", Callback = function()
				local n = dp:GetValue()
				if n then l_lib:DuplicateFile("Config", n) end
			end })
			local ab = s:AddButton({ Name = "Set Autoload", Callback = function()
				local n = dp:GetValue()
				if n then l_lib:SetConfigAutoload(n) end
			end, Tooltip = "Sets autoload to selected config." })
			ab:AddSubButton({ Name = "Remove Autoload", Callback = function() l_lib:RemoveConfigAutoload() end })
		end

		return tab
	end

	return w
end

return {
	Library = l_lib,
	Helpers = l_hlp,
	Main = l_main,
}
