--!optimize 2
if not LPH_OBFUSCATED then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Luraph/macrosdk/main/luraphsdk.lua"))()
end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local c3, cSeq, cKp = Color3.new, ColorSequence.new, ColorSequenceKeypoint.new
local nSeq, nKp = NumberSequence.new, NumberSequenceKeypoint.new
local clock, randInt, ceil, max, min, cos = os.clock, math.random, math.ceil, math.max, math.min, math.cos
local char, byte, find, fmt, gsub, lower, match, rep, sub, unpack = string.char, string.byte, string.find, string.format, string.gsub, string.lower, string.match, string.rep, string.sub, string.unpack
local u2, u2s, u2o, u1, v2 = UDim2.new, UDim2.fromScale, UDim2.fromOffset, UDim.new, Vector2.new
local iNew = Instance.new
local tCreate, tConcat, tFreeze, tClear, tRemove, tSort = table.create, table.concat, table.freeze, table.clear, table.remove, table.sort
local spawn, delay, pcall = task.spawn, task.delay, pcall
local type, typeof, tostring, tonumber, next, select, error, setmetatable = type, typeof, tostring, tonumber, next, select, error, setmetatable
local game, workspace, tWait = game, workspace, task.wait
local uLen, uOff, uChar = utf8.len, utf8.offset, utf8.char

local function rand()
	return char(
		randInt(65,90), randInt(97,122), randInt(48,57), randInt(97,122),
		randInt(65,90), randInt(97,122), randInt(48,57), randInt(97,122),
		randInt(65,90), randInt(97,122), randInt(48,57), randInt(97,122),
		randInt(65,90), randInt(97,122), randInt(48,57), randInt(97,122)
	)
end

do
	if typeof(script) == "Instance" then pcall(function() script.Name = rand() end) end
end

local lp = Players.LocalPlayer
local pName = (lp.DisplayName ~= "" and lp.DisplayName or lp.Name) .. ":"
local pThumb = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150"

local black, white = c3(0,0,0), c3(1,1,1)
local purple, pink, green = c3(0.50,0.12,0.90), c3(1.00,0.20,0.78), c3(0.16,0.78,0.42)
local darkBox, inputBg, bubbleBg = c3(0.055,0.050,0.068), c3(0.078,0.072,0.098), c3(0.105,0.095,0.138)
local bubbleStroke, grayName = c3(0.20,0.16,0.28), c3(0.64,0.62,0.70)
local iconIdle, iconHover = c3(0.70,0.68,0.78), c3(0.98,0.96,1.00)
local hoverBg, selChatBg = c3(0.15,0.13,0.20), c3(0.22,0.11,0.38)
local menuBg, focusStroke, descCol = c3(0.068,0.062,0.086), c3(0.40,0.22,0.68), c3(0.80,0.78,0.86)
local errAcc, warnAcc = c3(1.00,0.42,0.47), c3(1.00,0.76,0.30)

local cAnc, lAnc, rAnc = v2(0.5,0.5), v2(0,0.5), v2(1,0.5)
local mainRad, cardRad, itemRad, circRad = u1(0,18), u1(0,8), u1(0,6), u1(0.5,0)
local bMode, rJoin = Enum.ApplyStrokeMode.Border, Enum.LineJoinMode.Round
local autoY, autoXY = Enum.AutomaticSize.Y, Enum.AutomaticSize.XY
local twFast = TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local twMid = TweenInfo.new(0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local interThin = Font.fromId(12187365364, Enum.FontWeight.Thin, Enum.FontStyle.Normal)
local alL, alC, alR = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center, Enum.TextXAlignment.Right
local vaT, vaC = Enum.TextYAlignment.Top, Enum.TextYAlignment.Center
local trEnd, trNone = Enum.TextTruncate.AtEnd, Enum.TextTruncate.None
local fdH, fdV, pbDone, sdY = Enum.FillDirection.Horizontal, Enum.FillDirection.Vertical, Enum.PlaybackState.Completed, Enum.ScrollingDirection.Y

local function decal(id) return "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150" end
local function tw(o, info, goal) return TweenService:Create(o, info, goal) end

local defModels = tFreeze({
	Gemini = "gemini-2.5-flash",
	ChatGPT = "gpt-4o-mini",
	Claude = "claude-3-5-sonnet-latest",
	Groq = "llama-3.3-70b-versatile",
	Custom = "gpt-4o-mini"
})

local cfg = {
	provider = "Gemini",
	apiKeys = { Gemini = "", ChatGPT = "", Claude = "", Groq = "", Custom = "" },
	models = { Gemini = "gemini-2.5-flash", ChatGPT = "gpt-4o-mini", Claude = "claude-3-5-sonnet-latest", Groq = "llama-3.3-70b-versatile", Custom = "gpt-4o-mini" },
	customUrl = "",
	sysExtra = "",
	saveConfigs = true,
	encodeConfig = true,
	encodeChats = false,
	effort = { Gemini = "low", ChatGPT = "low", Claude = "low", Groq = "low", Custom = "auto" }
}

local provIcons = {
	Gemini = decal(139807262244286),
	ChatGPT = decal(93370078895660),
	Claude = "",
	Groq = "",
	Custom = decal(110790436463173)
}

local st = {
	drawerW = 210,
	effortW = 72,
	plusW = 38,
	introSeq = cSeq(purple, pink),
	chats = {},
	provBtns = {},
	provOptIcons = {},
	fetchedModels = {},
	modelCaps = {},
	thinkLabels = {},
	thinkGrads = {},
	aiAvIcons = {},
	typewriters = {},
	offsets = tCreate(168),
	starts = tCreate(168),
	totalDur = 0,
	loaderAsset = "",
	loaderReady = false,
	phase = 0,
	fadeStep = 0,
	cycleStep = 0,
	showingSend = false
}

local formatInline, parseSegments, frameAtTime, applyLoaderUri, scanMentions
do
	local function esc(s) return gsub(gsub(gsub(s, "&", "&amp;"), "<", "&lt;"), ">", "&gt;") end
	local mPat = "^:%a+%(%s*[\"'][^\"']*[\"']%s*%)"
	scanMentions = function(s)
		local out, pos, len = {}, 1, #s
		while true do
			local a = find(s, "@", pos, true)
			if not a then break end
			local i = a + 1
			if (a == 1 or match(sub(s, a - 1, a - 1), "[%s%(%[,]")) and match(sub(s, i, i), "[%a_]") then
				while i <= len do
					local c = sub(s, i, i)
					if match(c, "[%w_%.]") then
						i += 1
					elseif c == "[" then
						local q = sub(s, i + 1, i + 1)
						local isQ = q == '"' or q == "'"
						local e = isQ and find(s, q .. "]", i + 2, true) or (not isQ and find(s, "]", i + 1, true))
						if not e then break end
						i = isQ and e + 2 or e + 1
					elseif c == ":" and match(s, mPat, i) then
						local _, e = find(s, mPat, i)
						i = e + 1
					else
						break
					end
				end
				local e = i - 1
				while e > a and sub(s, e, e) == "." do e -= 1 end
				if e > a then out[#out + 1] = { a, e, sub(s, a + 1, e) } end
				pos = max(i, a + 1)
			else
				pos = a + 1
			end
		end
		return out
	end
	formatInline = function(raw)
		local ic = {}
		local w = gsub(raw, "`([^`\r\n]+)`", function(c)
			ic[#ic + 1] = '<font color="#d8bfff">' .. esc(c) .. "</font>"
			return "%%IC" .. #ic .. "%%"
		end)
		local ms = scanMentions(w)
		local mn = {}
		for i = #ms, 1, -1 do
			local m = ms[i]
			mn[i] = '<font color="#c99bff"><b>' .. esc(sub(w, m[1], m[2])) .. "</b></font>"
			w = sub(w, 1, m[1] - 1) .. "%%MN" .. i .. "%%" .. sub(w, m[2] + 1)
		end
		w = esc(w)
		w = gsub(gsub(w, "\n#+%s+([^\r\n]+)", "\n<b>%1</b>"), "^#+%s+([^\r\n]+)", "<b>%1</b>")
		w = gsub(gsub(gsub(gsub(gsub(w, "%*%*%*(.-)%*%*%*", "<b><i>%1</i></b>"), "%*%*(.-)%*%*", "<b>%1</b>"), "__(.-)__", "<u>%1</u>"), "%*([^%*\r\n]+)%*", "<i>%1</i>"), "~~(.-)~~", "<s>%1</s>")
		w = gsub(w, "%%%%IC(%d+)%%%%", function(n) return ic[tonumber(n)] or "" end)
		w = gsub(w, "%%%%MN(%d+)%%%%", function(n) return mn[tonumber(n)] or "" end)
		local pl = gsub(gsub(gsub(gsub(w, "<[^>]+>", ""), "&lt;", "<"), "&gt;", ">"), "&amp;", "&")
		return w, pl
	end

	local function parseRaw(raw)
		local segs, pos, len = {}, 1, #raw
		while pos <= len do
			local s0, s1, lg, cd = find(raw, "```([%w_%-]*)[ \t]*\r?\n?(.-)```", pos)
			if not s0 then
				local tail = match(sub(raw, pos), "^%s*(.-)%s*$")
				if tail and tail ~= "" then
					local r, p = formatInline(tail)
					segs[#segs + 1] = { kind = "text", rich = r, plain = p }
				end
				break
			end
			if s0 > pos then
				local pre = match(sub(raw, pos, s0 - 1), "^%s*(.-)%s*$")
				if pre and pre ~= "" then
					local r, p = formatInline(pre)
					segs[#segs + 1] = { kind = "text", rich = r, plain = p }
				end
			end
			segs[#segs + 1] = { kind = "code", lang = (lg and lg ~= "") and lower(lg) or "code", code = match(cd or "", "^(.-)%s*$") or "" }
			pos = s1 + 1
		end
		if #segs == 0 then
			local r, p = formatInline(raw)
			segs[1] = { kind = "text", rich = r, plain = p }
		end
		return segs
	end
	local psNew, psOld, psCount = {}, {}, 0
	parseSegments = function(raw)
		local sg = psNew[raw]
		if sg then return sg end
		sg = psOld[raw] or parseRaw(raw)
		psNew[raw] = sg
		psCount += 1
		if psCount >= 128 then psOld, psNew, psCount = psNew, {}, 0 end
		return sg
	end

	local d = 0
	for i = 0, 167 do
		st.starts[i + 1] = d
		d += (i % 6 == 5) and 0.05 or 0.04
		st.offsets[i + 1] = v2(0, 0)
	end
	st.totalDur = d
	tFreeze(st.starts)

	local starts = st.starts
	frameAtTime = function(t)
		LPH_ATTRIBUTES(VM(NONE))
		local lo, hi = 1, 168
		while lo < hi do
			local mid = (lo + hi + 1) // 2
			if starts[mid] <= t then lo = mid else hi = mid - 1 end
		end
		return lo
	end

	local fromUri = Content and Content.fromUri
	applyLoaderUri = function(lbl, uri)
		if fromUri then
			local ok = pcall(function() lbl.ImageContent = fromUri(uri) end)
			if ok then return end
		end
		lbl.Image = uri
	end
end

local function privPath(p)
	p = lower(p)
	return LPH_OPAQUE(find(p, "bloxy/internal", 1, true) ~= nil or find(p, "bloxy/profiles/[^/]*/internal") ~= nil)
end

local httpReq, setClip, saveCfg, saveChats, loadChats, initCdn
do
	local band, bxor, bnot, rrot, rsh, lsh = bit32.band, bit32.bxor, bit32.bnot, bit32.rrotate, bit32.rshift, bit32.lshift
	LPH_PRECHECK(function() return LPH_OPAQUE(band and bxor and rrot and lsh) end)
	local K = {
		0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
		0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
		0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
		0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
		0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
		0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
		0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
		0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
	}
	local W = tCreate(64, 0)
	local function shaWords(msg)
		local l = #msg
		local bl = l * 8
		local p = msg .. "\128" .. rep("\0", (55 - (l % 64)) % 64) .. char(0,0,0,0, band(rsh(bl,24),255), band(rsh(bl,16),255), band(rsh(bl,8),255), band(bl,255))
		local h0,h1,h2,h3,h4,h5,h6,h7 = 0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
		for i = 1, #p, 64 do
			for j = 1, 16 do
				local o = i + (j - 1) * 4
				local b1,b2,b3,b4 = byte(p, o, o + 3)
				W[j] = lsh(b1,24) + lsh(b2,16) + lsh(b3,8) + b4
			end
			for j = 17, 64 do
				local v15, v2 = W[j - 15], W[j - 2]
				W[j] = band(W[j - 16] + bxor(rrot(v15,7), rrot(v15,18), rsh(v15,3)) + W[j - 7] + bxor(rrot(v2,17), rrot(v2,19), rsh(v2,10)), 0xFFFFFFFF)
			end
			local a,b,c,d,e,f,g,h = h0,h1,h2,h3,h4,h5,h6,h7
			for j = 1, 64 do
				local t1 = band(h + bxor(rrot(e,6), rrot(e,11), rrot(e,25)) + bxor(band(e,f), band(bnot(e),g)) + K[j] + W[j], 0xFFFFFFFF)
				local t2 = band(bxor(rrot(a,2), rrot(a,13), rrot(a,22)) + bxor(band(a,b), band(a,c), band(b,c)), 0xFFFFFFFF)
				h,g,f,e,d,c,b,a = g,f,e,band(d + t1, 0xFFFFFFFF),c,b,a,band(t1 + t2, 0xFFFFFFFF)
			end
			h0,h1,h2,h3,h4,h5,h6,h7 = band(h0+a,0xFFFFFFFF),band(h1+b,0xFFFFFFFF),band(h2+c,0xFFFFFFFF),band(h3+d,0xFFFFFFFF),band(h4+e,0xFFFFFFFF),band(h5+f,0xFFFFFFFF),band(h6+g,0xFFFFFFFF),band(h7+h,0xFFFFFFFF)
		end
		return h0,h1,h2,h3,h4,h5,h6,h7
	end
	local function shaHex(m)
		local a,b,c,d,e,f,g,h = shaWords(m)
		return fmt("%08x%08x%08x%08x%08x%08x%08x%08x", a,b,c,d,e,f,g,h)
	end
	local spack = string.pack
	local HE, HD = {}, {}
	for i = 0, 255 do
		local c, h = char(i), fmt("%02x", i)
		HE[c], HD[h] = h, c
	end
	local function xorStr(s, k)
		local l = #s
		if l == 0 then return "" end
		local nb = (l + 31) // 32
		local pad = nb * 32 - l
		local src = pad > 0 and (s .. rep("\0", pad)) or s
		local out = tCreate(nb)
		for blk = 1, nb do
			local w1, w2, w3, w4, w5, w6, w7, w8 = shaWords(k .. ":" .. blk)
			local a1, a2, a3, a4, a5, a6, a7, a8 = unpack(">I4I4I4I4I4I4I4I4", src, blk * 32 - 31)
			out[blk] = spack(">I4I4I4I4I4I4I4I4", bxor(a1, w1), bxor(a2, w2), bxor(a3, w3), bxor(a4, w4), bxor(a5, w5), bxor(a6, w6), bxor(a7, w7), bxor(a8, w8))
		end
		local r = tConcat(out)
		return pad > 0 and sub(r, 1, l) or r
	end
	local lrot = bit32.lrotate
	local F16 = "<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4"
	local function chacha(s, key, nonce)
		local l = #s
		if l == 0 then return "" end
		local k0, k1, k2, k3, k4, k5, k6, k7 = unpack("<I4I4I4I4I4I4I4I4", key)
		local n0, n1, n2 = unpack("<I4I4I4", nonce)
		local nb = (l + 63) // 64
		local pad = nb * 64 - l
		local src = pad > 0 and (s .. rep("\0", pad)) or s
		local out = tCreate(nb)
		for blk = 1, nb do
			local x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15 = 0x61707865, 0x3320646e, 0x79622d32, 0x6b206574, k0, k1, k2, k3, k4, k5, k6, k7, blk, n0, n1, n2
			for _ = 1, 10 do
				x0 = band(x0 + x4, 0xFFFFFFFF); x12 = lrot(bxor(x12, x0), 16); x8 = band(x8 + x12, 0xFFFFFFFF); x4 = lrot(bxor(x4, x8), 12)
				x0 = band(x0 + x4, 0xFFFFFFFF); x12 = lrot(bxor(x12, x0), 8); x8 = band(x8 + x12, 0xFFFFFFFF); x4 = lrot(bxor(x4, x8), 7)
				x1 = band(x1 + x5, 0xFFFFFFFF); x13 = lrot(bxor(x13, x1), 16); x9 = band(x9 + x13, 0xFFFFFFFF); x5 = lrot(bxor(x5, x9), 12)
				x1 = band(x1 + x5, 0xFFFFFFFF); x13 = lrot(bxor(x13, x1), 8); x9 = band(x9 + x13, 0xFFFFFFFF); x5 = lrot(bxor(x5, x9), 7)
				x2 = band(x2 + x6, 0xFFFFFFFF); x14 = lrot(bxor(x14, x2), 16); x10 = band(x10 + x14, 0xFFFFFFFF); x6 = lrot(bxor(x6, x10), 12)
				x2 = band(x2 + x6, 0xFFFFFFFF); x14 = lrot(bxor(x14, x2), 8); x10 = band(x10 + x14, 0xFFFFFFFF); x6 = lrot(bxor(x6, x10), 7)
				x3 = band(x3 + x7, 0xFFFFFFFF); x15 = lrot(bxor(x15, x3), 16); x11 = band(x11 + x15, 0xFFFFFFFF); x7 = lrot(bxor(x7, x11), 12)
				x3 = band(x3 + x7, 0xFFFFFFFF); x15 = lrot(bxor(x15, x3), 8); x11 = band(x11 + x15, 0xFFFFFFFF); x7 = lrot(bxor(x7, x11), 7)
				x0 = band(x0 + x5, 0xFFFFFFFF); x15 = lrot(bxor(x15, x0), 16); x10 = band(x10 + x15, 0xFFFFFFFF); x5 = lrot(bxor(x5, x10), 12)
				x0 = band(x0 + x5, 0xFFFFFFFF); x15 = lrot(bxor(x15, x0), 8); x10 = band(x10 + x15, 0xFFFFFFFF); x5 = lrot(bxor(x5, x10), 7)
				x1 = band(x1 + x6, 0xFFFFFFFF); x12 = lrot(bxor(x12, x1), 16); x11 = band(x11 + x12, 0xFFFFFFFF); x6 = lrot(bxor(x6, x11), 12)
				x1 = band(x1 + x6, 0xFFFFFFFF); x12 = lrot(bxor(x12, x1), 8); x11 = band(x11 + x12, 0xFFFFFFFF); x6 = lrot(bxor(x6, x11), 7)
				x2 = band(x2 + x7, 0xFFFFFFFF); x13 = lrot(bxor(x13, x2), 16); x8 = band(x8 + x13, 0xFFFFFFFF); x7 = lrot(bxor(x7, x8), 12)
				x2 = band(x2 + x7, 0xFFFFFFFF); x13 = lrot(bxor(x13, x2), 8); x8 = band(x8 + x13, 0xFFFFFFFF); x7 = lrot(bxor(x7, x8), 7)
				x3 = band(x3 + x4, 0xFFFFFFFF); x14 = lrot(bxor(x14, x3), 16); x9 = band(x9 + x14, 0xFFFFFFFF); x4 = lrot(bxor(x4, x9), 12)
				x3 = band(x3 + x4, 0xFFFFFFFF); x14 = lrot(bxor(x14, x3), 8); x9 = band(x9 + x14, 0xFFFFFFFF); x4 = lrot(bxor(x4, x9), 7)
			end
			local d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15 = unpack(F16, src, blk * 64 - 63)
			out[blk] = spack(F16,
				bxor(d0, x0 + 0x61707865), bxor(d1, x1 + 0x3320646e), bxor(d2, x2 + 0x79622d32), bxor(d3, x3 + 0x6b206574),
				bxor(d4, x4 + k0), bxor(d5, x5 + k1), bxor(d6, x6 + k2), bxor(d7, x7 + k3),
				bxor(d8, x8 + k4), bxor(d9, x9 + k5), bxor(d10, x10 + k6), bxor(d11, x11 + k7),
				bxor(d12, x12 + blk), bxor(d13, x13 + n0), bxor(d14, x14 + n1), bxor(d15, x15 + n2))
		end
		local r = tConcat(out)
		return pad > 0 and sub(r, 1, l) or r
	end
	local function enc(pl, k)
		local nc = sub(shaHex(rand() .. clock() .. #pl), 1, 24)
		return LPH_ENCSTR("BX257:") .. nc .. ":" .. gsub(chacha(pl, (gsub(k, "%x%x", HD)), (gsub(nc, "%x%x", HD))), ".", HE)
	end
	local function dec(ci, k)
		local tag = sub(ci, 1, 6)
		if tag == LPH_ENCSTR("BX257:") then return chacha((gsub(sub(ci, 32), "%x%x", HD)), (gsub(k, "%x%x", HD)), (gsub(sub(ci, 7, 30), "%x%x", HD))) end
		if tag == LPH_ENCSTR("BX256:") then return xorStr((gsub(sub(ci, 7), "%x%x", HD)), k) end
		return ci
	end

	local pKey = lower(lp.Name)
	local profDir = "Bloxy/Profiles/" .. pKey
	local intDir = profDir .. "/internal"
	local cfgName = "DO_NOT_SHARE_THIS_IF_YOU_DO_ALL_YOUR_API_KEYS_WILL_GET_LEAKED.bf"
	local cfgPath, chatPath = intDir .. "/" .. cfgName, intDir .. "/chats"
	local oldCfg, oldChat = "Bloxy/internal/" .. cfgName, "Bloxy/internal/chats"
	local sheetPath = "Bloxy/cdn/sprite_shesh_loader.png"
	local sheetUrl = LPH_ENCSTR("https://raw.githubusercontent.com/notgatoooo/Random/refs/heads/main/Assets/Bloxy/sprite_shesh_loader.png")
	local devKey = shaHex(LPH_ENCSTR("Bloxy:v2|") .. pKey .. "|" .. lp.UserId .. "|" .. LPH_ENCSTR("c4e19a07f25b6d83e1a04f7c9b2d5e60"))
	local oldKey = nil

	local env = (getgenv and getgenv()) or _G
	local wf, rf, isf, isdir, mkdir = (env and env.writefile) or writefile, (env and env.readfile) or readfile, (env and env.isfile) or isfile, (env and env.isfolder) or isfolder, (env and env.makefolder) or makefolder
	local dlf, dld = (env and env.delfile) or delfile, (env and env.delfolder) or delfolder
	local getasset = (env and (env.getcustomasset or env.getsynasset)) or getcustomasset or getsynasset
	setClip = (env and (env.setclipboard or env.toclipboard)) or setclipboard or toclipboard
	httpReq = (env and (env.request or env.http_request or (env.syn and env.syn.request) or (env.http and env.http.request))) or request or http_request or (syn and syn.request) or (http and http.request)

	local dirsOk = false
	local function mkDirs()
		if dirsOk or not isdir or not mkdir then return end
		for _, p in { "Bloxy", "Bloxy/Profiles", profDir, intDir, "Bloxy/cdn" } do
			local ok, ex = pcall(isdir, p)
			if ok and not ex then pcall(mkdir, p) end
		end
		dirsOk = true
	end
	local function save(p, d)
		mkDirs()
		if pcall(wf, p, d) then return true end
		dirsOk = false
		mkDirs()
		return (pcall(wf, p, d))
	end
	local function exists(p)
		if not isf then return false end
		local ok, ex = pcall(isf, p)
		return ok and ex == true
	end
	local function readF(p)
		if not rf or not exists(p) then return nil end
		local ok, b = pcall(rf, p)
		return (ok and type(b) == "string") and b or nil
	end
	local function cleanOld()
		if dld and not exists(oldCfg) and not exists(oldChat) then
			local ok, ex = pcall(isdir, "Bloxy/internal")
			if ok and ex then pcall(dld, "Bloxy/internal") end
		end
	end
	local function applyCfg(d)
		if type(d) ~= "table" then return end
		if d.provider and cfg.apiKeys[d.provider] then cfg.provider = d.provider end
		if type(d.apiKeys) == "table" then
			for n, v in d.apiKeys do if cfg.apiKeys[n] ~= nil and type(v) == "string" then cfg.apiKeys[n] = v end end
		end
		if type(d.models) == "table" then
			for n, v in d.models do if cfg.models[n] ~= nil and type(v) == "string" and v ~= "" then cfg.models[n] = v end end
		end
		if type(d.customUrl) == "string" then cfg.customUrl = d.customUrl end
		if type(d.sysExtra) == "string" then cfg.sysExtra = d.sysExtra end
		if type(d.saveConfigs) == "boolean" then cfg.saveConfigs = d.saveConfigs end
		if type(d.encodeConfig) == "boolean" then cfg.encodeConfig = d.encodeConfig end
		if type(d.encodeChats) == "boolean" then cfg.encodeChats = d.encodeChats end
		if type(d.effort) == "table" then
			for n, v in d.effort do if cfg.effort[n] ~= nil and type(v) == "string" and v ~= "" then cfg.effort[n] = v end end
		end
	end

	do
		local body = readF(cfgPath)
		if body then
			local okJ, d = pcall(HttpService.JSONDecode, HttpService, dec(body, devKey))
			if okJ then applyCfg(d) end
		else
			local ob = readF(oldCfg)
			local k, rest
			if ob then k, rest = match(ob, "^([0-9a-fA-F]+)\r?\n(.*)$") end
			if k and #k == 64 then
				oldKey = k
				local okJ, d = pcall(HttpService.JSONDecode, HttpService, dec(rest, k))
				if okJ then applyCfg(d) end
			end
		end
	end

	saveCfg = function()
		if not wf or not cfg.saveConfigs then return end
		local okJ, j = pcall(HttpService.JSONEncode, HttpService, cfg)
		if okJ then save(cfgPath, cfg.encodeConfig and enc(j, devKey) or j) end
	end
	saveChats = function(list)
		if not wf then return end
		local ser = tCreate(#list)
		for i = 1, #list do
			local c = list[i]
			local ms = tCreate(#c.messages)
			for j = 1, #c.messages do
				local m = c.messages[j]
				ms[j] = { role = m.role or "user", text = m.text, provider = m.provider, model = m.model, tools = m.tools, img = m.img }
			end
			ser[i] = { title = c.title, provider = c.provider, messages = ms }
		end
		local okJ, j = pcall(HttpService.JSONEncode, HttpService, ser)
		if okJ then save(chatPath, cfg.encodeChats and enc(j, devKey) or j) end
	end
	loadChats = function()
		local b, k, mig = readF(chatPath), devKey, false
		if not b then
			b = readF(oldChat)
			k, mig = oldKey or devKey, b ~= nil
		end
		if not b or #b == 0 then return nil end
		local okJ, d = pcall(HttpService.JSONDecode, HttpService, dec(b, k))
		if not okJ or type(d) ~= "table" then return nil end
		if mig and wf then
			saveChats(d)
			if exists(chatPath) and dlf then
				pcall(dlf, oldChat)
				cleanOld()
			end
		end
		return d
	end

	local function parseSheet(png)
		if type(png) ~= "string" or #png <= 24 or sub(png, 1, 8) ~= "\137PNG\r\n\026\n" then return end
		local sw, sh = unpack(">I4I4", png, 17)
		local cols, rows = sw // 56, sh // 56
		if cols <= 0 or rows <= 0 or (cols * rows) < 168 then return end
		for i = 0, 167 do
			st.offsets[i + 1] = v2((i % cols) * 56 + 2, (i // cols) * 56 + 2)
		end
		if getasset then
			local okA, uri = pcall(getasset, sheetPath)
			if okA and type(uri) == "string" then
				st.loaderAsset, st.loaderReady = uri, true
				local f0 = st.offsets[1]
				for i = 1, #st.thinkLabels do
					local l = st.thinkLabels[i]
					applyLoaderUri(l, uri)
					l.ImageRectOffset = f0
				end
			end
		end
	end

	local function fetchFile(path, url, cb)
		local okF, ex = pcall(isf, path)
		if okF and ex then cb() else
			spawn(function()
				local okH, d = pcall(game.HttpGet, game, url)
				if okH and type(d) == "string" and #d > 0 then pcall(wf, path, d); cb(d) end
			end)
		end
	end

	initCdn = function(onReady)
		if not getasset or not wf or not isf then return end
		mkDirs()
		for _, it in {
			{ n = "Claude", p = "Bloxy/cdn/claude.png", u = LPH_ENCSTR("https://raw.githubusercontent.com/notgatoooo/Random/refs/heads/main/Assets/Bloxy/Claude_AI_symbol.svg.png") },
			{ n = "Groq", p = "Bloxy/cdn/groq.png", u = LPH_ENCSTR("https://raw.githubusercontent.com/notgatoooo/Random/refs/heads/main/Assets/Bloxy/groq_icon.png") }
		} do
			fetchFile(it.p, it.u, function()
				local okA, id = pcall(getasset, it.p)
				if okA and type(id) == "string" then provIcons[it.n] = id; onReady(it.n, id) end
			end)
		end
		if rf then
			fetchFile(sheetPath, sheetUrl, function(d)
				if not d then
					local okR, r = pcall(rf, sheetPath)
					if okR then d = r end
				end
				if d then parseSheet(d) end
			end)
		end
	end
	if cfg.saveConfigs then
		saveCfg()
		if oldKey and dlf and exists(cfgPath) then
			pcall(dlf, oldCfg)
			cleanOld()
		end
	end
end

local screenGui = iNew("ScreenGui")
local mainFrame = iNew("Frame")
do
	screenGui.Name, screenGui.AutoLocalize, screenGui.ResetOnSpawn, screenGui.IgnoreGuiInset, screenGui.ZIndexBehavior = rand(), false, false, true, Enum.ZIndexBehavior.Sibling
	mainFrame.Name, mainFrame.Active, mainFrame.ClipsDescendants, mainFrame.AnchorPoint, mainFrame.Position, mainFrame.Size, mainFrame.BackgroundColor3, mainFrame.BorderSizePixel = rand(), true, true, cAnc, u2s(0.5, 0.5), u2s(0.72, 0.62), purple, 0

	local ar = iNew("UIAspectRatioConstraint")
	ar.Name, ar.AspectRatio, ar.AspectType, ar.Parent = rand(), 1.6, Enum.AspectType.FitWithinMaxSize, mainFrame
	local sc = iNew("UISizeConstraint")
	sc.Name, sc.MinSize, sc.MaxSize, sc.Parent = rand(), v2(288, 180), v2(420, 262), mainFrame
	local cr = iNew("UICorner")
	cr.Name, cr.CornerRadius, cr.Parent = rand(), mainRad, mainFrame

	local baseSeq = cSeq({
		cKp(0.00, black), cKp(0.35, c3(0.02,0.02,0.02)),
		cKp(0.52, c3(0.09,0.09,0.09)), cKp(0.68, c3(0.26,0.26,0.26)),
		cKp(0.84, c3(0.56,0.56,0.56)), cKp(1.00, white)
	})
	local fg = iNew("UIGradient")
	fg.Name, fg.Color, fg.Rotation, fg.Parent = rand(), baseSeq, 90, mainFrame

	local ms = iNew("UIStroke")
	ms.Name, ms.ApplyStrokeMode, ms.LineJoinMode, ms.Thickness, ms.Color = rand(), bMode, rJoin, 1, c3(0.28, 0.07, 0.52)
	local sg = iNew("UIGradient")
	sg.Name, sg.Color, sg.Rotation, sg.Parent = rand(), baseSeq, 90, ms
	ms.Parent = mainFrame
end

local crn, strk, pad, icn, lbl, div, lst, mrow
;(function()
	local zero = u2o(0, 0)
	local noAuto = Enum.AutomaticSize.None
	crn = function(p, r)
		local c = iNew("UICorner")
		c.Name, c.CornerRadius, c.Parent = rand(), r, p
	end
	strk = function(p, col, tr)
		local s = iNew("UIStroke")
		s.Name, s.ApplyStrokeMode, s.LineJoinMode, s.Thickness, s.Color, s.Transparency, s.Parent = rand(), bMode, rJoin, 1, col or bubbleStroke, tr or 0, p
		return s
	end
	pad = function(p, l, r, t, b)
		local u = iNew("UIPadding")
		u.Name = rand()
		if l then u.PaddingLeft = u1(0, l) end
		if r then u.PaddingRight = u1(0, r) end
		if t then u.PaddingTop = u1(0, t) end
		if b then u.PaddingBottom = u1(0, b) end
		u.Parent = p
	end
	lst = function(p, dir, padPx, hAlign, vAlign)
		local l = iNew("UIListLayout")
		l.Name, l.FillDirection, l.SortOrder, l.Padding = rand(), dir or fdV, Enum.SortOrder.LayoutOrder, u1(0, padPx or 0)
		if hAlign then l.HorizontalAlignment = hAlign end
		if vAlign then l.VerticalAlignment = vAlign end
		l.Parent = p
		return l
	end
	icn = function(p, img, sz, xPos, col)
		local ic = iNew("ImageLabel")
		ic.Name, ic.BackgroundTransparency, ic.Size, ic.Image, ic.ImageColor3, ic.ScaleType = rand(), 1, u2o(sz, sz), img, col or iconIdle, Enum.ScaleType.Fit
		if xPos then ic.AnchorPoint, ic.Position = lAnc, u2(0, xPos, 0.5, 0) else ic.AnchorPoint, ic.Position = cAnc, u2s(0.5, 0.5) end
		ic.Parent = p
		return ic
	end
	lbl = function(p, txt, sz, col, pos, fsize, align)
		local lb = iNew("TextLabel")
		lb.Name, lb.AutoLocalize, lb.BackgroundTransparency, lb.Position, lb.Size, lb.FontFace, lb.Text, lb.TextColor3, lb.TextSize, lb.TextTruncate, lb.TextXAlignment, lb.TextYAlignment = rand(), false, 1, pos, fsize, interThin, txt, col, sz, trEnd, align or alL, vaC
		lb.Parent = p
		return lb
	end
	local chkId, fitSc = decal(9754130783), Enum.ScaleType.Fit
	mrow = function(p, ord, txt, img, imgCol)
		local b = iNew("TextButton")
		b.Name, b.AutoLocalize, b.AutoButtonColor, b.LayoutOrder, b.BackgroundColor3, b.BackgroundTransparency, b.BorderSizePixel, b.Size, b.FontFace, b.Text, b.TextColor3, b.TextSize, b.TextTruncate, b.TextXAlignment = rand(), false, false, ord, darkBox, 1, 0, u2(1, 0, 0, 22), interThin, txt, iconIdle, 11, trEnd, alL
		crn(b, itemRad); pad(b, img and 26 or 9, 22)
		local ic = img and icn(b, img, 12, -18, imgCol) or nil
		local ck = iNew("ImageLabel")
		ck.Name, ck.BackgroundTransparency, ck.AnchorPoint, ck.Position, ck.Size, ck.Image, ck.ImageColor3, ck.ImageTransparency, ck.ScaleType, ck.Parent = rand(), 1, lAnc, u2(1, 7, 0.5, 0), u2o(10, 10), chkId, white, 1, fitSc, b
		b.Parent = p
		return b, ck, ic
	end
	local divSeq = nSeq({ nKp(0, 1), nKp(0.5, 0), nKp(1, 1) })
	div = function(p, y)
		local dv = iNew("Frame")
		dv.Name, dv.BackgroundColor3, dv.BorderSizePixel, dv.Position, dv.Size = rand(), bubbleStroke, 0, u2o(0, y), u2(1, 0, 0, 1)
		local dg = iNew("UIGradient")
		dg.Name, dg.Transparency, dg.Parent = rand(), divSeq, dv
		dv.Parent = p
		return dv
	end
	local function fitCanvas(scr, layout, extra)
		local function upd() scr.CanvasSize = u2o(0, layout.AbsoluteContentSize.Y + extra) end
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
		upd()
	end
	local function mkCircBtn(p, imgId, bSz, iSz, pos, anc, z)
		local b = iNew("ImageButton")
		b.Name, b.AutoButtonColor, b.BackgroundColor3, b.BackgroundTransparency, b.BorderSizePixel, b.Size, b.Position = rand(), false, darkBox, 1, 0, u2o(bSz, bSz), pos
		if anc then b.AnchorPoint = anc end
		if z then b.ZIndex = z end
		crn(b, circRad)
		local ic = icn(b, imgId, iSz)
		if z then ic.ZIndex = z end
		b.Parent = p
		return b
	end
	local function mkInput(p, ord, txt, ph)
		local bx = iNew("TextBox")
		bx.Name, bx.AutoLocalize, bx.ClearTextOnFocus, bx.LayoutOrder, bx.BackgroundColor3, bx.BorderSizePixel, bx.Size, bx.FontFace, bx.Text, bx.PlaceholderText, bx.PlaceholderColor3, bx.TextColor3, bx.TextSize, bx.TextTruncate, bx.TextXAlignment = rand(), false, false, ord, inputBg, 0, u2(1, 0, 0, 24), interThin, txt, ph, grayName, white, 11, trEnd, alL
		crn(bx, cardRad); strk(bx); pad(bx, 10, 10)
		bx.Parent = p
		return bx
	end

	local textContainer, helloLabel, bloxyLabel, exclaimLabel = iNew("Frame"), iNew("TextLabel"), iNew("TextLabel"), iNew("TextLabel")
	local bloxyGradient, exclaimGradient = iNew("UIGradient"), iNew("UIGradient")
	local chatScroll, promptBox, sendButton = iNew("ScrollingFrame"), iNew("TextBox"), iNew("TextButton")
	local drawerBackdrop, drawerFrame = iNew("TextButton"), iNew("Frame")
	local chatsPage, settingsPage = iNew("Frame"), iNew("Frame")
	local newChatButton, chatList = iNew("TextButton"), iNew("ScrollingFrame")
	local bloxySpacer, errorOverlay, errorCard = iNew("Frame"), iNew("TextButton"), iNew("Frame")

	st.textContainer, st.helloLabel, st.bloxyLabel, st.exclaimLabel = textContainer, helloLabel, bloxyLabel, exclaimLabel
	st.bloxyGradient, st.exclaimGradient = bloxyGradient, exclaimGradient
	st.chatScroll, st.promptBox, st.sendButton = chatScroll, promptBox, sendButton
	st.drawerBackdrop, st.drawerFrame, st.chatsPage, st.settingsPage = drawerBackdrop, drawerFrame, chatsPage, settingsPage
	st.newChatButton, st.chatList, st.bloxySpacer, st.errorOverlay, st.errorCard = newChatButton, chatList, bloxySpacer, errorOverlay, errorCard

	textContainer.Name, textContainer.BackgroundTransparency, textContainer.AnchorPoint, textContainer.Position, textContainer.Size = rand(), 1, cAnc, u2s(0.5, 0.42), u2s(0.9, 0.25)
	lst(textContainer, fdH, 0, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

	helloLabel.Name, helloLabel.AutoLocalize, helloLabel.LayoutOrder, helloLabel.BackgroundTransparency, helloLabel.Size, helloLabel.AutomaticSize, helloLabel.FontFace, helloLabel.Text, helloLabel.TextColor3, helloLabel.TextSize = rand(), false, 1, 1, zero, autoXY, interThin, "Hello! I'm", white, 22
	pad(helloLabel, nil, 6); helloLabel.Parent = textContainer

	bloxyLabel.Name, bloxyLabel.AutoLocalize, bloxyLabel.LayoutOrder, bloxyLabel.BackgroundTransparency, bloxyLabel.Size, bloxyLabel.AutomaticSize, bloxyLabel.FontFace, bloxyLabel.Text, bloxyLabel.TextColor3, bloxyLabel.TextSize = rand(), false, 2, 1, zero, autoXY, interThin, "Bloxy", white, 22
	bloxyGradient.Name, bloxyGradient.Color, bloxyGradient.Parent = rand(), st.introSeq, bloxyLabel
	bloxyLabel.Parent = textContainer

	exclaimLabel.Name, exclaimLabel.AutoLocalize, exclaimLabel.LayoutOrder, exclaimLabel.BackgroundTransparency, exclaimLabel.Size, exclaimLabel.AutomaticSize, exclaimLabel.FontFace, exclaimLabel.Text, exclaimLabel.TextColor3, exclaimLabel.TextSize = rand(), false, 3, 1, zero, autoXY, interThin, "!", white, 22
	exclaimGradient.Name, exclaimGradient.Color, exclaimGradient.Parent = rand(), st.introSeq, exclaimLabel
	exclaimLabel.Parent = textContainer
	textContainer.Parent = mainFrame

	chatScroll.Name, chatScroll.Active, chatScroll.BackgroundTransparency, chatScroll.BorderSizePixel, chatScroll.Position, chatScroll.Size, chatScroll.CanvasSize, chatScroll.AutomaticCanvasSize, chatScroll.ScrollBarThickness, chatScroll.ScrollBarImageColor3, chatScroll.ScrollingDirection, chatScroll.Visible = rand(), false, 1, 0, u2(0, 10, 0, 32), u2(1, -20, 1, -76), zero, noAuto, 2, purple, sdY, false
	st.chatLayout = lst(chatScroll, nil, 8); pad(chatScroll, 2, 6, 4, 8); chatScroll.Parent = mainFrame

	promptBox.Name, promptBox.AutoLocalize, promptBox.ClearTextOnFocus, promptBox.AnchorPoint, promptBox.Position, promptBox.Size, promptBox.BackgroundColor3, promptBox.BackgroundTransparency, promptBox.BorderSizePixel, promptBox.FontFace, promptBox.Text, promptBox.PlaceholderText, promptBox.PlaceholderColor3, promptBox.TextColor3, promptBox.TextSize, promptBox.TextTruncate, promptBox.TextXAlignment = rand(), false, false, v2(0, 1), u2(0, 10 + st.plusW, 1, -8), u2(1, -(26 + st.effortW + st.plusW), 0, 32), darkBox, 0.06, 0, interThin, "", "Bloxy, build me...", grayName, white, 13, trEnd, alL
	crn(promptBox, mainRad); strk(promptBox, black); pad(promptBox, 14, 14)
	promptBox.Parent = mainFrame

	sendButton.Name, sendButton.AutoLocalize, sendButton.AutoButtonColor, sendButton.Active, sendButton.Interactable, sendButton.AnchorPoint, sendButton.Position, sendButton.Size, sendButton.BackgroundColor3, sendButton.BackgroundTransparency, sendButton.BorderSizePixel, sendButton.Text = rand(), false, false, false, false, v2(1, 1), u2(1, -10, 1, -8), u2o(32, 32), darkBox, 1, 0, ""
	crn(sendButton, mainRad)
	st.sendStroke = strk(sendButton, black, 1)
	st.sendIcon = icn(sendButton, "rbxassetid://79920755857235", 16)
	st.sendIcon.ImageTransparency = 1
	sendButton.Parent = mainFrame

	local effortBtn = iNew("TextButton")
	effortBtn.Name, effortBtn.AutoLocalize, effortBtn.AutoButtonColor, effortBtn.AnchorPoint, effortBtn.Position, effortBtn.Size, effortBtn.BackgroundColor3, effortBtn.BackgroundTransparency, effortBtn.BorderSizePixel, effortBtn.Text = rand(), false, false, v2(1, 1), u2(1, -10, 1, -8), u2o(st.effortW, 32), darkBox, 0.06, 0, ""
	crn(effortBtn, mainRad); st.effortStroke = strk(effortBtn, black)
	st.effortLbl = lbl(effortBtn, "Auto", 11, white, u2o(14, 0), u2(1, -34, 1, 0))
	st.effortArr = icn(effortBtn, decal(11552476728), 10)
	st.effortArr.AnchorPoint, st.effortArr.Position, st.effortArr.Rotation = rAnc, u2(1, -12, 0.5, 0), 180
	effortBtn.Parent = mainFrame
	st.effortBtn = effortBtn

	local plusBtn = iNew("TextButton")
	plusBtn.Name, plusBtn.AutoLocalize, plusBtn.AutoButtonColor, plusBtn.AnchorPoint, plusBtn.Position, plusBtn.Size, plusBtn.BackgroundColor3, plusBtn.BackgroundTransparency, plusBtn.BorderSizePixel, plusBtn.Text = rand(), false, false, v2(0, 1), u2(0, 10, 1, -8), u2o(32, 32), darkBox, 0.06, 0, ""
	crn(plusBtn, mainRad); st.plusStroke = strk(plusBtn, black)
	st.plusIcon = icn(plusBtn, decal(15928997778), 16)
	local badge = iNew("Frame")
	badge.Name, badge.AnchorPoint, badge.Position, badge.Size, badge.BackgroundColor3, badge.BackgroundTransparency, badge.BorderSizePixel = rand(), cAnc, u2(1, -6, 0, 6), u2o(8, 8), purple, 1, 0
	crn(badge, circRad)
	st.plusBadgeStroke = strk(badge, darkBox, 1)
	badge.Parent = plusBtn
	st.plusBadge = badge
	plusBtn.ZIndex = 4
	plusBtn.Parent = mainFrame
	st.plusBtn = plusBtn

	bloxySpacer.Name, bloxySpacer.BackgroundTransparency, bloxySpacer.LayoutOrder, bloxySpacer.Visible, bloxySpacer.Parent = rand(), 1, 2, false, textContainer
	st.menuButton = mkCircBtn(mainFrame, decal(6953992690), 24, 14, u2o(10, 4), nil, 2)

	drawerBackdrop.Name, drawerBackdrop.AutoLocalize, drawerBackdrop.AutoButtonColor, drawerBackdrop.Selectable, drawerBackdrop.BackgroundColor3, drawerBackdrop.BackgroundTransparency, drawerBackdrop.BorderSizePixel, drawerBackdrop.Size, drawerBackdrop.Text, drawerBackdrop.Visible, drawerBackdrop.ZIndex = rand(), false, false, false, black, 1, 0, u2s(1, 1), "", false, 5
	crn(drawerBackdrop, mainRad); drawerBackdrop.Parent = mainFrame

	local drawerClip = iNew("Frame")
	drawerClip.Name, drawerClip.Active, drawerClip.BackgroundTransparency, drawerClip.BorderSizePixel, drawerClip.ClipsDescendants, drawerClip.Size, drawerClip.Visible, drawerClip.ZIndex = rand(), false, 1, 0, true, u2(0, 0, 1, 0), false, 6
	st.drawerClip = drawerClip
	drawerFrame.Name, drawerFrame.Active, drawerFrame.BackgroundColor3, drawerFrame.BorderSizePixel, drawerFrame.ClipsDescendants, drawerFrame.Size = rand(), true, darkBox, 0, true, u2(0, st.drawerW, 1, 0)
	crn(drawerFrame, mainRad); strk(drawerFrame)

	local drawerHolder = iNew("Frame")
	drawerHolder.Name, drawerHolder.BackgroundTransparency, drawerHolder.Position, drawerHolder.Size, drawerHolder.Parent = rand(), 1, u2o(-(st.drawerW + 1), 0), u2(0, st.drawerW, 1, 0), drawerFrame
	st.drawerHolder = drawerHolder

	chatsPage.Name, chatsPage.BackgroundTransparency, chatsPage.BorderSizePixel, chatsPage.ClipsDescendants, chatsPage.Size, chatsPage.Parent = rand(), 1, 0, false, u2s(1, 1), drawerHolder
	settingsPage.Name, settingsPage.BackgroundTransparency, settingsPage.BorderSizePixel, settingsPage.ClipsDescendants, settingsPage.Size, settingsPage.Visible, settingsPage.Position, settingsPage.Parent = rand(), 1, 0, false, u2s(1, 1), false, u2o(0, 18), drawerHolder

	local pageVeil = iNew("Frame")
	pageVeil.Name, pageVeil.Active, pageVeil.BackgroundColor3, pageVeil.BackgroundTransparency, pageVeil.BorderSizePixel, pageVeil.Size, pageVeil.Visible, pageVeil.ZIndex, pageVeil.Parent = rand(), false, darkBox, 1, 0, u2s(1, 1), false, 3, drawerHolder
	crn(pageVeil, mainRad)
	st.pageVeil = pageVeil

	do
		pad(chatsPage, 12, 12, 6, 8)
		lbl(chatsPage, "Chats", 14, white, u2o(4, 0), u2(1, -36, 0, 26))
		st.closeButton = mkCircBtn(chatsPage, decal(109058392374604), 26, 14, u2(1, 0, 0, 0), v2(1, 0))

		newChatButton.Name, newChatButton.AutoLocalize, newChatButton.AutoButtonColor, newChatButton.BackgroundColor3, newChatButton.BorderSizePixel, newChatButton.Position, newChatButton.Size, newChatButton.Text = rand(), false, false, bubbleBg, 0, u2o(0, 32), u2(1, 0, 0, 28), ""
		crn(newChatButton, cardRad); strk(newChatButton)
		icn(newChatButton, decal(5595830734), 14, 10)
		lbl(newChatButton, "Create new Chat", 12, white, u2o(32, 0), u2(1, -40, 1, 0))
		newChatButton.Parent = chatsPage

		div(chatsPage, 67)
		lbl(chatsPage, "Your chats", 11, grayName, u2o(4, 73), u2(1, -8, 0, 14))

		chatList.Name, chatList.BackgroundTransparency, chatList.BorderSizePixel, chatList.Position, chatList.Size, chatList.AutomaticCanvasSize, chatList.CanvasSize, chatList.ScrollBarThickness, chatList.ScrollBarImageColor3, chatList.ScrollingDirection = rand(), 1, 0, u2o(0, 91), u2(1, 0, 1, -133), noAuto, zero, 2, purple, sdY
		fitCanvas(chatList, lst(chatList, nil, 3), 0)

		local noChats = lbl(chatList, "No chats yet", 11, grayName, zero, u2(1, 0, 0, 22))
		noChats.TextTransparency = 0.35
		st.noChatsLabel = noChats
		pad(noChats, 6); chatList.Parent = chatsPage

		local footer = iNew("Frame")
		footer.Name, footer.BackgroundTransparency, footer.AnchorPoint, footer.Position, footer.Size = rand(), 1, v2(0, 1), u2s(0, 1), u2(1, 0, 0, 36)
		div(footer, 0)

		local av = iNew("ImageLabel")
		av.Name, av.BackgroundColor3, av.BorderSizePixel, av.AnchorPoint, av.Position, av.Size, av.Image = rand(), bubbleBg, 0, lAnc, u2(0, 4, 0.5, 2), u2o(24, 24), pThumb
		crn(av, circRad); av.Parent = footer

		local un = lbl(footer, lp.Name, 12, white, u2(0, 36, 0.5, 2), u2(1, -68, 0, 18))
		un.AnchorPoint = lAnc
		st.settingsButton = mkCircBtn(footer, decal(9405931578), 26, 15, u2(1, 0, 0.5, 2), rAnc)
		footer.Parent = chatsPage
	end

	do
		pad(settingsPage, 12, 12, 6, 8)
		lbl(settingsPage, "Settings", 14, white, zero, u2(1, 0, 0, 26), alC)
		st.backButton = mkCircBtn(settingsPage, decal(111290129018455), 26, 14, u2(1, 0, 0, 0), v2(1, 0))
		div(settingsPage, 29)

		local setScroll = iNew("ScrollingFrame")
		setScroll.Name, setScroll.BackgroundTransparency, setScroll.BorderSizePixel, setScroll.Position, setScroll.Size, setScroll.CanvasSize, setScroll.AutomaticCanvasSize, setScroll.ScrollBarThickness, setScroll.ScrollBarImageColor3, setScroll.ScrollBarImageTransparency, setScroll.ScrollingDirection = rand(), 1, 0, u2o(0, 34), u2(1, 0, 1, -34), zero, noAuto, 2, purple, 0.35, sdY
		pad(setScroll, 2, 6, 2, 12); fitCanvas(setScroll, lst(setScroll, nil, 5), 14)

		local function mkDropShell(ord, titleTxt, listH)
			local df = iNew("Frame")
			df.Name, df.LayoutOrder, df.BackgroundColor3, df.BorderSizePixel, df.ClipsDescendants, df.Size = rand(), ord, bubbleBg, 0, true, u2(1, 0, 0, 28)
			crn(df, cardRad)
			local ds = strk(df)
			local hb = iNew("TextButton")
			hb.Name, hb.AutoButtonColor, hb.BackgroundColor3, hb.BackgroundTransparency, hb.BorderSizePixel, hb.Size, hb.Text = rand(), false, hoverBg, 1, 0, u2(1, 0, 0, 28), ""
			crn(hb, cardRad)
			lbl(hb, titleTxt, 11, grayName, u2o(10, 0), u2(0, 64, 1, 0))
			local arr = icn(hb, decal(11552476728), 10)
			arr.AnchorPoint, arr.Position = rAnc, u2(1, -10, 0.5, 0)
			hb.Parent = df
			local lg = iNew("Frame")
			lg.Name, lg.BackgroundTransparency, lg.BorderSizePixel, lg.Position, lg.Size, lg.Visible = rand(), 1, 0, u2o(0, 22), u2(1, 0, 0, listH), false
			div(lg, 0); lg.Parent = df; df.Parent = setScroll
			return df, hb, arr, lg, ds
		end

		local pFrame, pBtn, pArr, pGroup, pStroke = mkDropShell(1, "Provider API", 126)
		local selBadge = iNew("Frame")
		selBadge.Name, selBadge.BackgroundTransparency, selBadge.AnchorPoint, selBadge.Position, selBadge.Size = rand(), 1, rAnc, u2(1, -24, 0.5, 0), u2(0, 86, 1, 0)
		lst(selBadge, fdH, 5, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

		local pIcon = iNew("ImageLabel")
		pIcon.Name, pIcon.LayoutOrder, pIcon.BackgroundTransparency, pIcon.Size, pIcon.Image, pIcon.ImageColor3, pIcon.ScaleType, pIcon.Parent = rand(), 1, 1, u2o(13, 13), provIcons[cfg.provider] or "", white, Enum.ScaleType.Fit, selBadge

		local pVal = iNew("TextLabel")
		pVal.Name, pVal.AutoLocalize, pVal.LayoutOrder, pVal.BackgroundTransparency, pVal.Size, pVal.AutomaticSize, pVal.FontFace, pVal.Text, pVal.TextColor3, pVal.TextSize, pVal.TextYAlignment, pVal.Parent = rand(), false, 2, 1, zero, autoXY, interThin, cfg.provider, white, 11, vaC, selBadge
		selBadge.Parent = pBtn

		lst(pGroup, nil, 2); pad(pGroup, 4, 4, 4, 4)

		for idx, pName in { "Gemini", "ChatGPT", "Claude", "Groq", "Custom" } do
			local isSel = pName == cfg.provider
			local ob, ck, ic = mrow(pGroup, idx, pName, provIcons[pName] or "", white)
			if isSel then ob.BackgroundColor3, ob.BackgroundTransparency, ob.TextColor3, ck.ImageTransparency = selChatBg, 0, white, 0 end
			st.provOptIcons[pName] = ic
			st.provBtns[pName] = { btn = ob, lbl = ob, chk = ck }
		end

		initCdn(function(pName, id)
			if st.provOptIcons[pName] then st.provOptIcons[pName].Image = id end
			if cfg.provider == pName then pIcon.Image = id end
			for i = 1, #st.aiAvIcons do
				local e = st.aiAvIcons[i]
				if e.provider == pName then e.icon.Image = id end
			end
		end)

		local apiKeyBox = mkInput(setScroll, 2, cfg.apiKeys[cfg.provider] or "", cfg.provider .. " API Key")
		local mFrame, mBtn, mArr, mGroup, mStroke = mkDropShell(3, "Model", 102)
		mFrame.Visible = false
		local mVal = lbl(mBtn, cfg.models[cfg.provider] or defModels[cfg.provider], 11, white, u2o(48, 0), u2(1, -72, 1, 0), alR)

		local mScroll = iNew("ScrollingFrame")
		mScroll.Name, mScroll.BackgroundTransparency, mScroll.BorderSizePixel, mScroll.Position, mScroll.Size, mScroll.CanvasSize, mScroll.AutomaticCanvasSize, mScroll.ScrollBarThickness, mScroll.ScrollBarImageColor3, mScroll.ScrollingDirection = rand(), 1, 0, u2o(0, 2), u2(1, 0, 1, -2), zero, noAuto, 2, purple, sdY
		pad(mScroll, 4, 6, 3, 3); fitCanvas(mScroll, lst(mScroll, nil, 2), 6)
		mScroll.Parent = mGroup

		local modelBox = mkInput(setScroll, 4, cfg.models[cfg.provider] or "", "Model (" .. (defModels[cfg.provider] or "model") .. ")")
		do
			local sysBox = mkInput(setScroll, 5, cfg.sysExtra or "", "Custom system prompt (added to Bloxy's)")
			sysBox.MultiLine, sysBox.TextWrapped, sysBox.TextTruncate, sysBox.AutomaticSize, sysBox.TextYAlignment = true, true, trNone, autoY, vaT
			local sp = sysBox:FindFirstChildOfClass("UIPadding")
			sp.PaddingTop, sp.PaddingBottom = u1(0, 6), u1(0, 6)
			st.sysBox = sysBox
		end

		local isCust = cfg.provider == "Custom"
		local urlWrap = iNew("Frame")
		urlWrap.Name, urlWrap.LayoutOrder, urlWrap.BackgroundTransparency, urlWrap.ClipsDescendants, urlWrap.Size, urlWrap.Visible = rand(), 6, 1, true, u2(1, 0, 0, isCust and 26 or 0), isCust
		local urlBox = mkInput(urlWrap, 1, cfg.customUrl or "", "Endpoint URL (https://.../v1/chat/completions)")
		urlBox.Position = u2o(0, 1)
		urlWrap.Parent = setScroll

		st.pFrame, st.pBtn, st.pIcon, st.pVal, st.pArr, st.pGroup, st.pStroke = pFrame, pBtn, pIcon, pVal, pArr, pGroup, pStroke
		st.mFrame, st.mBtn, st.mVal, st.mArr, st.mGroup, st.mScroll, st.mStroke = mFrame, mBtn, mVal, mArr, mGroup, mScroll, mStroke
		st.apiKeyBox, st.modelBox, st.urlWrap, st.urlBox = apiKeyBox, modelBox, urlWrap, urlBox

		local divWrap = iNew("Frame")
		divWrap.Name, divWrap.LayoutOrder, divWrap.BackgroundTransparency, divWrap.Size, divWrap.Parent = rand(), 7, 1, u2(1, 0, 0, 4), setScroll
		div(divWrap, 2)

		local function mkToggle(ord, text, kName)
			local row = iNew("TextButton")
			row.Name, row.AutoButtonColor, row.LayoutOrder, row.BackgroundColor3, row.BackgroundTransparency, row.BorderSizePixel, row.Size, row.Text = rand(), false, ord, bubbleBg, 0.35, 0, u2(1, 0, 0, 24), ""
			crn(row, itemRad)
			lbl(row, text, 11, white, u2o(8, 0), u2(1, -30, 1, 0))

			local box = iNew("Frame")
			box.Name, box.AnchorPoint, box.Position, box.Size, box.BackgroundColor3 = rand(), rAnc, u2(1, -6, 0.5, 0), u2o(15, 15), cfg[kName] and purple or darkBox
			crn(box, u1(0, 4))
			local bs = strk(box, cfg[kName] and purple or bubbleStroke)
			local chk = icn(box, decal(9754130783), 10, nil, white)
			chk.ImageTransparency = cfg[kName] and 0 or 1
			box.Parent = row; row.Parent = setScroll

			row.Activated:Connect(function()
				local on = not cfg[kName]
				cfg[kName] = on
				tw(box, twFast, { BackgroundColor3 = on and purple or darkBox }):Play()
				tw(bs, twFast, { Color = on and purple or bubbleStroke }):Play()
				tw(chk, twFast, { ImageTransparency = on and 0 or 1 }):Play()
				saveCfg()
				if kName == "encodeChats" then saveChats(st.chats) end
			end)
		end

		mkToggle(8, "Save Configs. on File System", "saveConfigs")
		mkToggle(9, "Encode File Config. File", "encodeConfig")
		mkToggle(10, "Encode Chats", "encodeChats")
		do
			local skDiv = iNew("Frame")
			skDiv.Name, skDiv.LayoutOrder, skDiv.BackgroundTransparency, skDiv.Size, skDiv.Parent = rand(), 11, 1, u2(1, 0, 0, 4), setScroll
			div(skDiv, 2)
			local skHdr = lbl(setScroll, "Skills", 11, grayName, zero, u2(1, 0, 0, 14))
			skHdr.LayoutOrder = 12
			local skBox = mkInput(setScroll, 13, "", "Install skill: SKILL.md URL or GitHub folder")
			local skStatus = lbl(setScroll, "", 10, grayName, zero, u2(1, 0, 0, 0))
			skStatus.LayoutOrder, skStatus.AutomaticSize, skStatus.TextWrapped, skStatus.TextTruncate, skStatus.Visible = 14, autoY, true, trNone, false
			local skList = iNew("Frame")
			skList.Name, skList.LayoutOrder, skList.BackgroundTransparency, skList.Size, skList.AutomaticSize = rand(), 15, 1, u2(1, 0, 0, 0), autoY
			lst(skList, nil, 4)
			skList.Parent = setScroll
			st.skBox, st.skStatus, st.skList = skBox, skStatus, skList
		end
		setScroll.Parent = settingsPage
	end

	do
		errorOverlay.Name, errorOverlay.AutoLocalize, errorOverlay.AutoButtonColor, errorOverlay.Selectable, errorOverlay.BackgroundColor3, errorOverlay.BackgroundTransparency, errorOverlay.BorderSizePixel, errorOverlay.Size, errorOverlay.Text, errorOverlay.Visible, errorOverlay.ZIndex = rand(), false, false, false, black, 1, 0, u2s(1, 1), "", false, 10
		crn(errorOverlay, mainRad)

		errorCard.Name, errorCard.Active, errorCard.AnchorPoint, errorCard.Position, errorCard.Size, errorCard.AutomaticSize, errorCard.BackgroundColor3, errorCard.BorderSizePixel, errorCard.ZIndex = rand(), true, cAnc, u2s(0.5, 0.5), u2(1, -36, 0, 0), autoY, inputBg, 0, 11
		crn(errorCard, u1(0, 12))
		local cMax = iNew("UISizeConstraint")
		cMax.Name, cMax.MaxSize, cMax.Parent = rand(), v2(272, 1e4), errorCard
		st.errCardStroke = strk(errorCard, white)
		local cGrad = iNew("UIGradient")
		cGrad.Name, cGrad.Rotation, cGrad.Parent = rand(), 90, st.errCardStroke
		st.errCardGrad = cGrad
		pad(errorCard, 12, 12, 12, 12); lst(errorCard, nil, 9)

		local cScale = iNew("UIScale")
		cScale.Name, cScale.Scale, cScale.Parent = rand(), 0.94, errorCard

		local eHdr = iNew("Frame")
		eHdr.Name, eHdr.LayoutOrder, eHdr.BackgroundTransparency, eHdr.Size, eHdr.ZIndex, eHdr.Parent = rand(), 1, 1, u2(1, 0, 0, 30), 11, errorCard

		local eBadge = iNew("Frame")
		eBadge.Name, eBadge.BackgroundColor3, eBadge.BackgroundTransparency, eBadge.BorderSizePixel, eBadge.Size, eBadge.ZIndex, eBadge.Parent = rand(), errAcc, 0.84, 0, u2o(30, 30), 11, eHdr
		crn(eBadge, cardRad)
		local eIcon = icn(eBadge, decal(86000033190397), 16, nil, errAcc)
		eIcon.ZIndex = 11

		local eTag = lbl(eHdr, "ERROR", 10, errAcc, u2o(40, 1), u2(1, -68, 0, 12))
		eTag.ZIndex = 11
		local eTitle = lbl(eHdr, "Error", 13, white, u2o(40, 13), u2(1, -68, 0, 17))
		eTitle.ZIndex = 11
		st.errCloseBtn = mkCircBtn(eHdr, decal(109058392374604), 22, 10, u2(1, 4, 0, -4), v2(1, 0), 11)

		local eDesc = iNew("TextLabel")
		eDesc.Name, eDesc.AutoLocalize, eDesc.LayoutOrder, eDesc.BackgroundTransparency, eDesc.Size, eDesc.AutomaticSize, eDesc.FontFace, eDesc.Text, eDesc.TextColor3, eDesc.TextSize, eDesc.TextWrapped, eDesc.TextTruncate, eDesc.TextXAlignment, eDesc.TextYAlignment, eDesc.ZIndex, eDesc.Parent = rand(), false, 2, 1, u2(1, 0, 0, 0), autoY, interThin, "", descCol, 11, true, trEnd, alL, vaT, 11, errorCard
		local dMax = iNew("UISizeConstraint")
		dMax.Name, dMax.MaxSize, dMax.Parent = rand(), v2(1e4, 58), eDesc

		local eAct = iNew("Frame")
		eAct.Name, eAct.LayoutOrder, eAct.BackgroundTransparency, eAct.Size, eAct.ZIndex, eAct.Parent = rand(), 3, 1, u2(1, 0, 0, 26), 11, errorCard
		local function eBtn(txt, xs, bg, sc, tc)
			local b = iNew("TextButton")
			b.Name, b.AutoLocalize, b.AutoButtonColor, b.AnchorPoint, b.Position, b.Size, b.BackgroundColor3, b.BorderSizePixel, b.FontFace, b.Text, b.TextColor3, b.TextSize, b.ZIndex = rand(), false, false, v2(xs, 0), u2s(xs, 0), u2(0.5, -3, 1, 0), bg, 0, interThin, txt, tc, 11, 11
			crn(b, cardRad)
			local s = strk(b, sc)
			b.Parent = eAct
			return b, s
		end
		local eDismiss, eDisStroke = eBtn("Dismiss", 0, bubbleBg, bubbleStroke, iconIdle)
		local eRetry, eRetStroke = eBtn("Retry", 1, selChatBg, focusStroke, white)
		st.errRetryStroke, st.errDisStroke = eRetStroke, eDisStroke

		st.eIcon, st.eBadge, st.eTag, st.eTitle, st.eDesc, st.eRetry, st.eDismiss = eIcon, eBadge, eTag, eTitle, eDesc, eRetry, eDismiss
		errorCard.Parent = errorOverlay; errorOverlay.Parent = mainFrame
	end

	drawerHolder.Parent = drawerFrame; drawerFrame.Parent = drawerClip; drawerClip.Parent = mainFrame
end)()

do
	mainFrame.Parent = screenGui
	local okP = pcall(function()
		screenGui.Parent = (gethui and gethui()) or lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui")
	end)
	if not okP then screenGui.Parent = lp:WaitForChild("PlayerGui") end
end

local setDrawerOpen, bindFeedback, showError, doHttp
;(function()
	doHttp = function(req)
		if httpReq then
			local ok, res = pcall(httpReq, req)
			if ok and type(res) == "table" then return res.StatusCode or res.Status or 0, res.Body or "" end
		end
		local ok, res = pcall(HttpService.RequestAsync, HttpService, req)
		if ok and type(res) == "table" then return res.StatusCode or 0, res.Body or "" end
		return 0, ""
	end

	local isOpen, isSettings, isErr = false, false, false
	local retryCb = nil
	local dClip, dFrame, dBack, cPage, sPage = st.drawerClip, st.drawerFrame, st.drawerBackdrop, st.chatsPage, st.settingsPage
	local fbReset = {}
	local eOver, eCard = st.errorOverlay, st.errorCard
	local eScale = eCard:FindFirstChildOfClass("UIScale")
	local warnIc, errIc = decal(18576886056), decal(86000033190397)
	local accSeq = { [true] = cSeq(warnAcc, c3(0.55, 0.40, 0.12)), [false] = cSeq(errAcc, c3(0.60, 0.20, 0.24)) }
	local closeIc = st.errCloseBtn:FindFirstChildOfClass("ImageLabel")
	local errFade = {
		{ eCard, "BackgroundTransparency", 0 },
		{ st.errCardStroke, "Transparency", 0 },
		{ st.eBadge, "BackgroundTransparency", 0.84 },
		{ st.eIcon, "ImageTransparency", 0 },
		{ st.eTag, "TextTransparency", 0 },
		{ st.eTitle, "TextTransparency", 0 },
		{ st.eDesc, "TextTransparency", 0 },
		{ st.eRetry, "BackgroundTransparency", 0 }, { st.eRetry, "TextTransparency", 0 }, { st.errRetryStroke, "Transparency", 0 },
		{ st.eDismiss, "BackgroundTransparency", 0 }, { st.eDismiss, "TextTransparency", 0 }, { st.errDisStroke, "Transparency", 0 },
		{ closeIc, "ImageTransparency", 0 }
	}
	for i = 1, #errFade do errFade[i][1][errFade[i][2]] = 1 end
	local function fadeErr(vis, info)
		for i = 1, #errFade do
			local e = errFade[i]
			tw(e[1], info, { [e[2]] = vis and e[3] or 1 }):Play()
		end
	end

	showError = function(isWarn, titleTxt, descTxt, onRetry)
		isErr, retryCb = true, onRetry
		local acc = isWarn and warnAcc or errAcc
		st.errCardGrad.Color = accSeq[isWarn == true]
		st.eBadge.BackgroundColor3, st.eIcon.Image, st.eIcon.ImageColor3 = acc, isWarn and warnIc or errIc, acc
		st.eTag.Text, st.eTag.TextColor3 = isWarn and "WARNING" or "ERROR", acc
		st.eTitle.Text = (gsub(titleTxt, "^[^—]*—%s*", ""))
		st.eDesc.Text = descTxt
		st.eRetry.Visible = onRetry ~= nil
		eOver.Visible = true
		tw(eOver, twMid, { BackgroundTransparency = 0.4 }):Play()
		tw(eScale, twMid, { Scale = 1 }):Play()
		fadeErr(true, twMid)
	end

	local function hideError()
		if not isErr then return end
		isErr = false
		local tOut = tw(eOver, twFast, { BackgroundTransparency = 1 })
		tOut:Play()
		tw(eScale, twFast, { Scale = 0.94 }):Play()
		fadeErr(false, twFast)
		if fbReset[st.errCloseBtn] then fbReset[st.errCloseBtn]() end
		if fbReset[st.eDismiss] then fbReset[st.eDismiss]() end
		if fbReset[st.eRetry] then fbReset[st.eRetry]() end
		tOut.Completed:Once(function() if not isErr then eOver.Visible = false end end)
	end

	local dHold = st.drawerHolder
	local dOpenGoal, dShutGoal = tFreeze({ Size = u2(0, st.drawerW + 1, 1, 0) }), tFreeze({ Size = u2(0, 0, 1, 0) })
	local hOpenGoal, hShutGoal = tFreeze({ Position = u2o(0, 0) }), tFreeze({ Position = u2o(-(st.drawerW + 1), 0) })
	setDrawerOpen = function(open)
		if open == isOpen then return end
		isOpen = open
		local info = open and twMid or twFast
		if open then dClip.Visible, dBack.Visible = true, true end
		local cTw = tw(dClip, info, open and dOpenGoal or dShutGoal)
		tw(dHold, info, open and hOpenGoal or hShutGoal):Play()
		tw(dBack, info, { BackgroundTransparency = open and 0.25 or 1 }):Play()
		if not open then cTw.Completed:Once(function() if not isOpen then dClip.Visible, dBack.Visible = false, false end end) end
		cTw:Play()
	end

	local veil, veilTw = st.pageVeil, nil
	local function switchPage(toSet)
		if toSet == isSettings then return end
		isSettings = toSet
		local outP, inP = toSet and cPage or sPage, toSet and sPage or cPage
		if veilTw then veilTw:Cancel() end
		veil.Visible = true
		tw(outP, twMid, { Position = u2o(0, 18) }):Play()
		local tOut = tw(veil, twMid, { BackgroundTransparency = 0 })
		veilTw = tOut
		tOut.Completed:Once(function(ps)
			if ps ~= pbDone then return end
			outP.Visible = false
			inP.Visible, inP.Position = true, u2o(0, 18)
			tw(inP, twMid, { Position = u2o(0, 0) }):Play()
			local tIn = tw(veil, twMid, { BackgroundTransparency = 1 })
			veilTw = tIn
			tIn.Completed:Once(function(ps2) if ps2 == pbDone then veil.Visible = false end end)
			tIn:Play()
		end)
		tOut:Play()
	end

	bindFeedback = function(btn, iCol, hCol, iAlp, hAlp, skipIc)
		local ic = not skipIc and btn:FindFirstChildOfClass("ImageLabel") or nil
		local sc = iNew("UIScale")
		sc.Name, sc.Parent = rand(), btn
		local ht = tw(btn, twFast, { BackgroundColor3 = hCol, BackgroundTransparency = hAlp })
		local it = tw(btn, twFast, { BackgroundColor3 = iCol, BackgroundTransparency = iAlp })
		local pt, rt = tw(sc, twFast, { Scale = 0.95 }), tw(sc, twFast, { Scale = 1 })
		local ih, ii = ic and tw(ic, twFast, { ImageColor3 = iconHover }), ic and tw(ic, twFast, { ImageColor3 = iconIdle })
		local hov, prs = false, false
		fbReset[btn] = function()
			if hov then hov = false; it:Play(); if ii then ii:Play() end end
			if prs then prs = false; rt:Play() end
		end
		btn:GetPropertyChangedSignal("GuiState"):Connect(function()
			local gs = btn.GuiState
			local isP = gs == Enum.GuiState.Press
			local isH = isP or gs == Enum.GuiState.Hover
			if isH ~= hov then
				hov = isH
				if isH then ht:Play(); if ih then ih:Play() end else it:Play(); if ii then ii:Play() end end
			end
			if isP ~= prs then
				prs = isP
				if isP then pt:Play() else rt:Play() end
			end
		end)
		return function(nCol, nAlp)
			iCol = nCol
			if nAlp ~= nil then iAlp = nAlp end
			it = tw(btn, twFast, { BackgroundColor3 = nCol, BackgroundTransparency = iAlp })
			if not hov then it:Play() end
		end
	end

	bindFeedback(st.menuButton, darkBox, hoverBg, 1, 0)
	bindFeedback(st.closeButton, darkBox, hoverBg, 1, 0)
	bindFeedback(st.backButton, darkBox, hoverBg, 1, 0)
	bindFeedback(st.settingsButton, darkBox, hoverBg, 1, 0)
	bindFeedback(st.newChatButton, bubbleBg, hoverBg, 0, 0)
	bindFeedback(st.pBtn, hoverBg, hoverBg, 1, 0.35, true)
	bindFeedback(st.mBtn, hoverBg, hoverBg, 1, 0.35, true)
	bindFeedback(st.errCloseBtn, darkBox, hoverBg, 1, 0)
	bindFeedback(st.eDismiss, bubbleBg, hoverBg, 0, 0, true)
	bindFeedback(st.eRetry, selChatBg, hoverBg, 0, 0, true)

	st.errCloseBtn.Activated:Connect(hideError)
	st.eDismiss.Activated:Connect(hideError)
	eOver.Activated:Connect(hideError)
	st.eRetry.Activated:Connect(function()
		local cb = retryCb
		hideError()
		if cb then cb() end
	end)

	do
		local pOpen, mOpen = false, false
		local function dropAnim(frame, arr, grp, stroke, o, h)
			if o then grp.Visible = true end
			local ft = tw(frame, twMid, { Size = u2(1, 0, 0, o and h or 28) })
			ft.Completed:Once(function(ps) if ps == pbDone and not o then grp.Visible = false end end)
			ft:Play()
			tw(arr, twMid, { Rotation = o and 180 or 0, ImageColor3 = o and white or iconIdle }):Play()
			tw(grp, o and twMid or twFast, { Position = u2o(0, o and 28 or 22) }):Play()
		end
		local function setPOpen(o)
			if o == pOpen then return end
			pOpen = o
			dropAnim(st.pFrame, st.pArr, st.pGroup, st.pStroke, o, 150)
		end
		local function setMOpen(o)
			if o == mOpen then return end
			mOpen = o
			dropAnim(st.mFrame, st.mArr, st.mGroup, st.mStroke, o, 128)
		end
		local function setModelMode(hasModels)
			if not hasModels then setMOpen(false) end
			st.mFrame.Visible = hasModels
			st.modelBox.Visible = not hasModels
		end

		local function isTextModel(prov, id, methods)
			local low = lower(id)
			for _, bad in { "embed", "tts", "whisper", "dall%-e", "imagen", "veo", "audio", "realtime", "moderation", "transcribe", "guard", "playai", "orpheus", "aqa" } do
				if match(low, bad) then return false end
			end
			if prov == "Gemini" then
				if type(methods) == "table" then
					local ok = false
					for i = 1, #methods do if methods[i] == "generateContent" then ok = true; break end end
					if not ok then return false end
				end
				return match(low, "^gemini") ~= nil or match(low, "^learnlm") ~= nil or match(low, "^gemma") ~= nil
			elseif prov == "ChatGPT" then
				return match(low, "^gpt%-") ~= nil or match(low, "^o%d") ~= nil or match(low, "^chatgpt%-") ~= nil
			end
			return true
		end

		local function rebuildModels(prov, list)
			local scr = st.mScroll
			local ch = scr:GetChildren()
			for i = 1, #ch do if ch[i]:IsA("TextButton") then ch[i]:Destroy() end end
			local cur = cfg.models[prov] or defModels[prov] or ""
			for idx = 1, #list do
				local mId = list[idx]
				local isS = mId == cur
				local b, ck = mrow(scr, idx, mId)
				if isS then b.BackgroundColor3, b.BackgroundTransparency, b.TextColor3, ck.ImageTransparency = selChatBg, 0, white, 0 end
				bindFeedback(b, isS and selChatBg or darkBox, hoverBg, isS and 0 or 1, 0, true)
				b.Activated:Connect(function()
					cfg.models[prov] = mId
					st.mVal.Text, st.modelBox.Text = mId, mId
					setMOpen(false); saveCfg(); rebuildModels(prov, list)
					if st.refreshEffort then st.refreshEffort() end
				end)
				b.Parent = scr
			end
		end

		local fetching = {}
		local function fetchModels(prov)
			local key = match(cfg.apiKeys[prov] or "", "^%s*(.-)%s*$") or ""
			local cUrl = match(cfg.customUrl or "", "^%s*(.-)%s*$") or ""
			if (prov ~= "Custom" and key == "") or (prov == "Custom" and cUrl == "") then
				st.fetchedModels[prov] = nil
				setModelMode(false)
				return
			end
			if fetching[prov] then return end
			fetching[prov] = true

			spawn(function()
				local url, hdrs
				if prov == "Gemini" then
					url, hdrs = LPH_ENCSTR("https://generativelanguage.googleapis.com/v1beta/models?pageSize=100&key=") .. key, { ["Content-Type"] = "application/json" }
				elseif prov == "Claude" then
					url, hdrs = LPH_ENCSTR("https://api.anthropic.com/v1/models"), { ["x-api-key"] = key, ["anthropic-version"] = "2023-06-01" }
				elseif prov == "ChatGPT" then
					url, hdrs = LPH_ENCSTR("https://api.openai.com/v1/models"), { ["Authorization"] = LPH_ENCSTR("Bearer ") .. key }
				elseif prov == "Groq" then
					url, hdrs = LPH_ENCSTR("https://api.groq.com/openai/v1/models"), { ["Authorization"] = LPH_ENCSTR("Bearer ") .. key }
				else
					url = gsub(cUrl, "/chat/completions.*$", "/models")
					if url == cUrl and not match(url, "/models$") then url = gsub(url, "/+$", "") .. "/models" end
					hdrs = key ~= "" and { ["Authorization"] = "Bearer " .. key } or {}
				end

				if prov == "Claude" then hdrs["anthropic-version"] = "2026-10-21" end
				local code, body = doHttp({ Url = url, Method = "GET", Headers = hdrs })
				if prov == "Claude" and code ~= 200 then
					hdrs["anthropic-version"] = "2023-06-01"
					code, body = doHttp({ Url = url, Method = "GET", Headers = hdrs })
				end
				fetching[prov] = nil
				if code == 200 and type(body) == "string" and #body > 0 then
					local okJ, parsed = pcall(HttpService.JSONDecode, HttpService, body)
					if okJ and type(parsed) == "table" then
						local list, seen, caps = {}, {}, {}
						local items = parsed.models or parsed.data or {}
						for i = 1, #items do
							local it = items[i]
							if type(it) == "table" then
								local rId = it.id or it.name
								if type(rId) == "string" then
									local cId = gsub(rId, "^models/", "")
									if not seen[cId] and isTextModel(prov, cId, it.supportedGenerationMethods) then
										seen[cId] = true
										list[#list + 1] = cId
										if type(it.thinking) == "boolean" then caps[cId] = { thinking = it.thinking } end
										local cp = it.capabilities
										if type(cp) == "table" then
											local c, ef, thk = {}, cp.effort, cp.thinking
											if type(ef) == "table" and ef.supported == true then
												c.effort = {}
												for _, lv in { "low", "medium", "high", "xhigh", "max" } do
													if type(ef[lv]) == "table" and ef[lv].supported == true then c.effort[lv] = true end
												end
											end
											if type(thk) == "table" then
												c.thinking = thk.supported == true
												local ty = type(thk.types) == "table" and thk.types.enabled
												c.budget = type(ty) == "table" and ty.supported == true
											end
											caps[cId] = c
										end
									end
								end
							end
						end
						if #list > 0 then
							tSort(list)
							st.fetchedModels[prov] = list
							st.modelCaps[prov] = caps
							if st.refreshEffort then st.refreshEffort() end
							if cfg.provider == prov then
								rebuildModels(prov, list)
								setModelMode(true)
							end
							return
						end
					end
				end
				st.fetchedModels[prov] = nil
				if cfg.provider == prov then setModelMode(false) end
			end)
		end

		fetchModels(cfg.provider)
		st.pBtn.Activated:Connect(function() setPOpen(not pOpen) end)
		st.mBtn.Activated:Connect(function() setMOpen(not mOpen) end)

		local pSetters = {}
		for pName, item in st.provBtns do
			local isS = pName == cfg.provider
			pSetters[pName] = bindFeedback(item.btn, isS and selChatBg or darkBox, hoverBg, isS and 0 or 1, 0, true)
			item.btn.Activated:Connect(function()
				cfg.provider = pName
				st.pVal.Text, st.pIcon.Image = pName, provIcons[pName] or ""
				st.apiKeyBox.PlaceholderText, st.apiKeyBox.Text = pName .. " API Key", cfg.apiKeys[pName] or ""
				local curM = cfg.models[pName] or defModels[pName] or ""
				st.mVal.Text, st.modelBox.Text = curM, curM
				st.modelBox.PlaceholderText = "Model (" .. (defModels[pName] or "model") .. ")"
				if pName == "Custom" then
					st.urlWrap.Visible = true
					tw(st.urlWrap, twMid, { Size = u2(1, 0, 0, 26) }):Play()
				else
					local cTw = tw(st.urlWrap, twFast, { Size = u2(1, 0, 0, 0) })
					cTw:Play()
					cTw.Completed:Once(function() if cfg.provider ~= "Custom" then st.urlWrap.Visible = false end end)
				end
				for n, e in st.provBtns do
					local s = n == pName
					pSetters[n](s and selChatBg or darkBox, s and 0 or 1)
					tw(e.lbl, twFast, { TextColor3 = s and white or iconIdle }):Play()
					tw(e.chk, twFast, { ImageTransparency = s and 0 or 1 }):Play()
				end
				setPOpen(false); setMOpen(false)
				local cached = st.fetchedModels[pName]
				if cached and #cached > 0 then rebuildModels(pName, cached); setModelMode(true) else setModelMode(false) end
				fetchModels(pName); saveCfg()
				if st.refreshEffort then st.refreshEffort() end
			end)
		end

		st.apiKeyBox.FocusLost:Connect(function()
			cfg.apiKeys[cfg.provider] = st.apiKeyBox.Text
			saveCfg(); fetchModels(cfg.provider)
		end)
		st.modelBox.FocusLost:Connect(function()
			local txt = match(st.modelBox.Text, "^%s*(.-)%s*$") or ""
			if txt == "" then txt = defModels[cfg.provider] or "gpt-4o-mini"; st.modelBox.Text = txt end
			cfg.models[cfg.provider], st.mVal.Text = txt, txt
			saveCfg()
			if st.refreshEffort then st.refreshEffort() end
		end)
		st.urlBox.FocusLost:Connect(function()
			cfg.customUrl = match(st.urlBox.Text, "^%s*(.-)%s*$") or ""
			st.urlBox.Text = cfg.customUrl
			saveCfg()
			if cfg.provider == "Custom" then fetchModels("Custom") end
		end)
		st.sysBox.FocusLost:Connect(function()
			cfg.sysExtra = match(st.sysBox.Text, "^%s*(.-)%s*$") or ""
			st.sysBox.Text = cfg.sysExtra
			saveCfg()
		end)
	end

	st.menuButton.Activated:Connect(function() setDrawerOpen(true) end)
	st.closeButton.Activated:Connect(function() setDrawerOpen(false) end)
	dBack.Activated:Connect(function() if isSettings then switchPage(false) else setDrawerOpen(false) end end)
	st.settingsButton.Activated:Connect(function() switchPage(true) end)
	st.backButton.Activated:Connect(function() switchPage(false) end)
end)()

local runTool, toolBuild, toolParse, jsonEnc, toolPrompt, mentionCtx, mentionSuggest, argSummary, effortLevels
;(function()
	local G = (getgenv and getgenv()) or _G
	local wf, rf, af = G.writefile or writefile, G.readfile or readfile, G.appendfile or appendfile
	local isf, isd, mkd = G.isfile or isfile, G.isfolder or isfolder, G.makefolder or makefolder
	local lsf, dlf, dld = G.listfiles or listfiles, G.delfile or delfile, G.delfolder or delfolder
	local lstr, dcmp = G.loadstring or loadstring, G.decompile or decompile
	local idEx = G.identifyexecutor or G.getexecutorname or identifyexecutor or getexecutorname
	local CollectionService = game:GetService("CollectionService")
	local MarketplaceService = game:GetService("MarketplaceService")
	local floor, huge, upper, gmatch, twait, select, tUnpack, tInsert = math.floor, math.huge, string.upper, string.gmatch, task.wait, select, table.unpack, table.insert
	local LIM, MAXSCAN, HIST, OLDCAP, OLDRES = 4000, 400000, 10, 420, 180

	local P = "bx" .. rand()
	local EOBJ = P .. "e"
	local subPat, subs = '"' .. P .. '(%w+)"', { e = "{}" }
	jsonEnc = function(t) return (gsub(HttpService:JSONEncode(t), subPat, subs)) end

	local function trim(s) return match(s, "^%s*(.-)%s*$") or "" end
	local function cutU(s, n)
		if #s <= n then return s end
		local c = sub(s, 1, n)
		for _ = 1, 3 do
			if uLen(c) then break end
			c = sub(c, 1, #c - 1)
		end
		return c
	end
	local function cap(s, n)
		n = n or LIM
		if #s > n then return cutU(s, n) .. "\n...[truncated " .. (#s - n) .. " more chars]" end
		return s
	end
	local function clean(s)
		if uLen(s) then return s end
		return (gsub(s, "[\128-\255]", "?"))
	end
	local function str(v) return type(v) == "string" and v or (v ~= nil and tostring(v) or nil) end
	local function num(v, def, lo, hi)
		v = tonumber(v)
		if not v then return def end
		v = floor(v)
		if lo and v < lo then v = lo end
		if hi and v > hi then v = hi end
		return v
	end
	local function bool(v) return v == true or v == "true" or v == 1 end
	local function csv(v)
		local out, set = {}, {}
		if type(v) == "table" then
			for _, x in v do if type(x) == "string" then local k = lower(trim(x)); if k ~= "" and not set[k] then set[k] = true; out[#out + 1] = k end end end
		elseif type(v) == "string" then
			for x in gmatch(v, "[^,;%s]+") do local k = lower(x); if not set[k] then set[k] = true; out[#out + 1] = k end end
		end
		return out, set
	end

	local function runTimed(secs, fn, ...)
		local th, done, waiting, res = coroutine.running(), false, false, nil
		local args = table.pack(...)
		spawn(function()
			local r = table.pack(pcall(fn, tUnpack(args, 1, args.n)))
			if done then return end
			done, res = true, r
			if waiting then waiting = false; spawn(th) end
		end)
		if not done then
			waiting = true
			delay(secs, function()
				if done then return end
				done, waiting = true, false
				spawn(th)
			end)
			coroutine.yield()
		end
		return res
	end

	local function pathOf(inst)
		if inst == game then return "game" end
		local segs, n, cur = {}, 0, inst
		while cur and cur ~= game do
			local nm = cur.Name
			n += 1
			if match(nm, "^[%a_][%w_]*$") then segs[n] = "." .. nm
			elseif not find(nm, '"', 1, true) then segs[n] = '["' .. nm .. '"]'
			else segs[n] = "['" .. nm .. "']" end
			cur = cur.Parent
		end
		local out = tCreate(n + 1)
		out[1] = cur == game and "game" or "<nil>"
		for i = n, 1, -1 do out[n - i + 2] = segs[i] end
		return tConcat(out)
	end

	local function child(cur, seg)
		local ls = lower(seg)
		if cur == game then
			if ls == "workspace" then return workspace end
			local c = cur:FindFirstChild(seg)
			if c then return c end
			local ok, sv = pcall(game.GetService, game, seg)
			if ok and typeof(sv) == "Instance" then return sv end
			return nil
		end
		if cur == Players and ls == "localplayer" then return lp end
		if cur == workspace and ls == "currentcamera" then return workspace.CurrentCamera end
		local c = cur:FindFirstChild(seg)
		if c then return c end
		if ls == "character" and cur:IsA("Player") then return cur.Character end
		return nil
	end

	local function resolve(path)
		if path == nil then return game end
		if type(path) ~= "string" then return nil, "path must be a string" end
		local p = trim(path)
		if p == "" then return game end
		local cur, pos, len = game, 1, #p
		if match(p, "^game[%.:%[/]") or p == "game" then pos = 5
		elseif match(p, "^workspace[%.:%[/]") or p == "workspace" then cur, pos = workspace, 10 end
		while pos <= len do
			local c = sub(p, pos, pos)
			if c == "." or c == "/" or c == "\\" then pos += 1; c = sub(p, pos, pos) end
			if pos > len then break end
			local seg
			if c == "[" then
				local q = sub(p, pos + 1, pos + 1)
				if q == '"' or q == "'" then
					local e = find(p, q .. "]", pos + 2, true)
					if not e then return nil, "unclosed [ in path" end
					seg, pos = sub(p, pos + 2, e - 1), e + 2
				else
					local e = find(p, "]", pos, true)
					if not e then return nil, "unclosed [ in path" end
					seg, pos = sub(p, pos + 1, e - 1), e + 1
				end
			elseif c == ":" then
				local arg, e = match(p, "^:%w+%(%s*[\"']([^\"']*)[\"'][^%)]*%)()", pos)
				if not arg then return nil, "unsupported method syntax near '" .. sub(p, pos, pos + 20) .. "'" end
				seg, pos = arg, e
			else
				local s, e = find(p, "^[^%.%[/\\:]+", pos)
				if not s then return nil, "bad path near '" .. sub(p, pos, pos + 20) .. "'" end
				seg, pos = sub(p, s, e), e + 1
			end
			local nx = child(cur, seg)
			if not nx then return nil, "'" .. seg .. "' was not found in " .. pathOf(cur) end
			cur = nx
		end
		return cur
	end

	local function getInst(a, key)
		local inst, err = resolve(a[key or "path"])
		if not inst then error(err, 0) end
		return inst
	end

	local function walk(root, visit)
		local stack, sp, n, t0, tStart = { root }, 1, 0, clock(), clock()
		while sp > 0 do
			local inst = stack[sp]
			stack[sp] = nil
			sp -= 1
			local ok, ch = pcall(inst.GetChildren, inst)
			if ok then
				for i = #ch, 1, -1 do
					local c = ch[i]
					n += 1
					if visit(c) then return n, true end
					sp += 1
					stack[sp] = c
					if n % 256 == 0 then
						if n >= MAXSCAN or clock() - tStart > 25 then return n, false, true end
						if clock() - t0 > 0.003 then twait(); t0 = clock() end
					end
				end
			end
		end
		return n, false
	end

	local function fPath(p)
		if type(p) ~= "string" then return nil, "path must be a string" end
		p = gsub(gsub(trim(p), "\\", "/"), "/+", "/")
		p = gsub(gsub(p, "^%./", ""), "^/", "")
		p = gsub(p, "/$", "")
		if p == "" or p == "." then return nil, "empty path" end
		if find("/" .. p .. "/", "/../", 1, true) or find(p, ":", 1, true) then return nil, "path cannot contain '..' or ':'" end
		if privPath(p) then return nil, "internal folders are protected (they store API keys)" end
		return p
	end
	local function ensureDirs(p)
		if not isd or not mkd then return end
		local i = find(p, "/", 1, true)
		while i do
			local d = sub(p, 1, i - 1)
			local ok, ex = pcall(isd, d)
			if ok and not ex then pcall(mkd, d) end
			i = find(p, "/", i + 1, true)
		end
	end
	local function isFile(p) if not isf then return false end local ok, r = pcall(isf, p) return ok and r end
	local function isDir(p) if not isd then return false end local ok, r = pcall(isd, p) return ok and r end

	local function sliceLines(s, a, b)
		local out, n, pos, ln, len = {}, 0, 1, 0, #s
		while pos <= len do
			ln += 1
			local e = find(s, "\n", pos, true) or (len + 1)
			if ln >= a then
				if ln > b then break end
				n += 1
				out[n] = ln .. ": " .. sub(s, pos, e - 1)
			end
			pos = e + 1
		end
		return tConcat(out, "\n")
	end
	local function lineCount(s)
		local _, c = gsub(s, "\n", "")
		return c + 1
	end

	local function short(v)
		local tv = typeof(v)
		if tv == "Instance" then return pathOf(v) .. " <" .. v.ClassName .. ">" end
		if tv == "string" then return fmt("%q", #v > 300 and sub(v, 1, 300) .. "..." or v) end
		if tv == "number" or tv == "boolean" or tv == "nil" or tv == "EnumItem" then return tostring(v) end
		if tv == "table" then return "table" end
		return tv .. "(" .. gsub(tostring(v), "(%-?%d+%.%d%d)%d+", "%1") .. ")"
	end

	local function serialize(...)
		local buf, n, len, seen = {}, 0, 0, {}
		local function w(s) if len <= LIM then n += 1; buf[n] = s; len += #s end end
		local function rec(v, d)
			local tv = typeof(v)
			if tv ~= "table" then w(tv == "string" and fmt("%q", #v > 2000 and sub(v, 1, 2000) .. "..." or v) or short(v)) return end
			if seen[v] then w("<cycle>") return end
			if d >= 5 then w("{...}") return end
			seen[v] = true
			w("{")
			local cnt = 0
			for k, val in next, v do
				cnt += 1
				if cnt > 60 or len > LIM then w(",...") break end
				if cnt > 1 then w(",") end
				if type(k) == "string" and match(k, "^[%a_][%w_]*$") then w(k) w("=") elseif k ~= cnt then w("[") rec(k, 9) w("]=") end
				rec(val, d + 1)
			end
			w("}")
			seen[v] = nil
		end
		local c = select("#", ...)
		if c == 0 then return "nil" end
		for i = 1, c do
			if i > 1 then w("\n") end
			rec((select(i, ...)), 0)
		end
		return tConcat(buf)
	end

	local function exec(code, asExpr)
		if type(code) ~= "string" or not match(code, "%S") then return nil, "code is empty" end
		if not lstr then return nil, "loadstring is not supported by your executor." end
		local buf, bn, bl = {}, 0, 0
		local function out(pre, ...)
			if bl > LIM then return end
			local c = select("#", ...)
			local t = tCreate(c)
			for i = 1, c do t[i] = tostring((select(i, ...))) end
			local s = pre .. tConcat(t, " ")
			bn += 1; buf[bn] = s; bl += #s + 1
		end
		local function pP(...) out("", ...) end
		local function pW(...) out("[warn] ", ...) end
		local fn, err
		if asExpr then
			local okC, f = pcall(lstr, "local print,warn=...;return " .. code, "=bloxy")
			if okC and type(f) == "function" then fn = f end
		end
		if not fn then
			local okC, f, e = pcall(lstr, "local print,warn=...;" .. code, "=bloxy")
			if okC then fn, err = f, e else err = f end
		end
		if type(fn) ~= "function" then return nil, "Compile error: " .. tostring(err) end
		local res = runTimed(15, fn, pP, pW)
		return res, nil, tConcat(buf, "\n")
	end

	local T = {}

	do
		local ents = { amp = "&", lt = "<", gt = ">", quot = '"', apos = "'", nbsp = " " }
		local function dHtml(h)
			return (gsub(h, "&(#?%w+);", function(e)
				local n = match(e, "^#[xX](%x+)$")
				if n then n = tonumber(n, 16) else n = match(e, "^#(%d+)$"); n = n and tonumber(n) end
				if n then
					local ok, c = pcall(uChar, n)
					return ok and c or ""
				end
				return ents[e]
			end))
		end
		local function noTags(s) return trim(gsub(dHtml(gsub(s, "<[^>]*>", "")), "%s+", " ")) end
		local function urlDec(s) return (gsub(gsub(s, "%+", " "), "%%(%x%x)", function(h) return char(tonumber(h, 16)) end)) end
		local function ciPat(w) return (gsub(w, "%a", function(c) return "[" .. lower(c) .. upper(c) .. "]" end)) end
		local stripPats = {}
		for _, t in { "head", "script", "style", "noscript", "svg", "template", "iframe" } do
			local p = ciPat(t)
			stripPats[#stripPats + 1] = "<" .. p .. "[%s>].-</" .. p .. "%s*>"
		end
		local blockTags = {}
		for _, t in { "br", "p", "div", "li", "ul", "ol", "tr", "table", "section", "article", "header", "footer", "nav", "h1", "h2", "h3", "h4", "h5", "h6", "pre", "blockquote", "hr", "dt", "dd" } do blockTags[t] = true end
		local titlePat = "<" .. ciPat("title") .. "[^>]*>(.-)</" .. ciPat("title") .. ">"
		local function htmlText(h)
			if #h > 800000 then h = sub(h, 1, 800000) end
			local title = match(h, titlePat)
			h = gsub(h, "<!%-%-.-%-%->", "")
			for i = 1, #stripPats do h = gsub(h, stripPats[i], " ") end
			h = gsub(h, "<(/?)(%w+)[^>]*>", function(sl, tg)
				local l = lower(tg)
				if l == "li" and sl == "" then return "\n- " end
				if blockTags[l] then return "\n" end
				return ""
			end)
			h = gsub(h, "<[^>]*>", "")
			h = dHtml(h)
			h = gsub(gsub(gsub(h, "[ \t\r\f\v]+", " "), " *\n *", "\n"), "\n\n\n+", "\n\n")
			return trim(h), title and noTags(title) or nil
		end

		local UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
		local function httpGet(url, extra)
			local h = { ["User-Agent"] = UA, ["Accept-Language"] = "en-US,en;q=0.9" }
			if extra then for k, v in extra do h[k] = v end end
			local code, body = doHttp({ Url = url, Method = "GET", Headers = h })
			if code == 0 then
				local ok, b = pcall(game.HttpGet, game, url)
				if ok and type(b) == "string" then return 200, b end
			end
			return code, body
		end

		local pageCache = { url = nil, text = nil, title = nil }
		T["research"] = function(a)
			local q = str(a.query)
			if not q or trim(q) == "" then return "Error: query is required." end
			q = trim(q)
			local maxN = num(a.maxResults, 4, 1, 10)
			local enc = HttpService:UrlEncode(q)
			local res = {}
			local code, body = doHttp({ Url = "https://html.duckduckgo.com/html/", Method = "POST", Headers = { ["User-Agent"] = UA, ["Content-Type"] = "application/x-www-form-urlencoded", ["Accept-Language"] = "en-US,en;q=0.9" }, Body = "q=" .. enc .. "&kl=us-en" })
			if code == 200 and type(body) == "string" then
				local last
				for attrs, inner in gmatch(body, "<a ([^>]*)>(.-)</a>") do
					if find(attrs, "result__a", 1, true) then
						if #res >= maxN then break end
						local href = dHtml(match(attrs, 'href="([^"]*)"') or "")
						local ud = match(href, "[?&]uddg=([^&]+)")
						if ud then href = urlDec(ud) elseif sub(href, 1, 2) == "//" then href = "https:" .. href end
						if href ~= "" and not find(href, "duckduckgo.com/y.js", 1, true) then
							last = { title = noTags(inner), url = href, snip = "" }
							res[#res + 1] = last
						else
							last = nil
						end
					elseif last and find(attrs, "result__snippet", 1, true) then
						last.snip = noTags(inner)
						last = nil
					end
				end
			end
			if #res == 0 then
				local c2, b2 = httpGet("https://lite.duckduckgo.com/lite/?q=" .. enc)
				if c2 == 200 and type(b2) == "string" then
					local links, snips = {}, {}
					for attrs, inner in gmatch(b2, "<a ([^>]*)>(.-)</a>") do
						if find(attrs, "result%-link") then
							local href = dHtml(match(attrs, "href=[\"']([^\"']*)[\"']") or "")
							local ud = match(href, "[?&]uddg=([^&]+)")
							if ud then href = urlDec(ud) elseif sub(href, 1, 2) == "//" then href = "https:" .. href end
							links[#links + 1] = { title = noTags(inner), url = href }
						end
					end
					for inner in gmatch(b2, "<td[^>]-result%-snippet[^>]*>(.-)</td>") do snips[#snips + 1] = noTags(inner) end
					for i = 1, min(#links, maxN) do
						if not find(links[i].url, "duckduckgo.com/y.js", 1, true) then res[#res + 1] = { title = links[i].title, url = links[i].url, snip = snips[i] or "" } end
					end
				end
			end
			local out = {}
			local c3c, ia = httpGet("https://api.duckduckgo.com/?q=" .. enc .. "&format=json&no_html=1&skip_disambig=1&t=bloxy")
			if c3c == 200 and type(ia) == "string" then
				local ok, d = pcall(HttpService.JSONDecode, HttpService, ia)
				if ok and type(d) == "table" then
					if type(d.Answer) == "string" and d.Answer ~= "" then out[#out + 1] = "Instant answer: " .. d.Answer end
					if type(d.AbstractText) == "string" and d.AbstractText ~= "" then out[#out + 1] = "Summary: " .. d.AbstractText .. (type(d.AbstractURL) == "string" and d.AbstractURL ~= "" and (" (" .. d.AbstractURL .. ")") or "") end
					if type(d.Definition) == "string" and d.Definition ~= "" then out[#out + 1] = "Definition: " .. d.Definition end
				end
			end
			if #res < 3 then
				local c4, wb = httpGet("https://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srlimit=3&srsearch=" .. enc, { ["User-Agent"] = "BloxyAssistant/1.0 (Roblox Luau helper)" })
				if c4 == 200 and type(wb) == "string" then
					local ok, d = pcall(HttpService.JSONDecode, HttpService, wb)
					if ok and type(d) == "table" and d.query and type(d.query.search) == "table" then
						for _, it in d.query.search do
							if type(it) == "table" and type(it.title) == "string" then
								res[#res + 1] = { title = it.title .. " (Wikipedia)", url = "https://en.wikipedia.org/wiki/" .. gsub(it.title, " ", "_"), snip = noTags(tostring(it.snippet or "")) }
							end
						end
					end
				end
			end
			for i = 1, #res do
				local r = res[i]
				out[#out + 1] = i .. ". " .. cutU(r.title, 90) .. " " .. r.url .. (r.snip ~= "" and ("\n" .. cutU(r.snip, 150)) or "")
			end
			if #out == 0 then return "No results for " .. fmt("%q", q) .. " (search may be rate limited, try different words or fetch-url a known page)." end
			return "Results for " .. fmt("%q", q) .. ":\n" .. tConcat(out, "\n")
		end

		T["use-skill"] = function(a)
			if not st.skillGet then return "Error: skills are not available." end
			return st.skillGet(str(a.name), str(a.file), num(a.startChar, 1, 1))
		end

		T["fetch-url"] = function(a)
			local url = str(a.url)
			if not url or not match(url, "^https?://") then return "Error: url must start with http:// or https://" end
			local st0, mx = num(a.startChar, 1, 1), num(a.maxChars, 2500, 500, 10000)
			local text, title
			if pageCache.url == url then
				text, title = pageCache.text, pageCache.title
			else
				local code, body = httpGet(url)
				if code ~= 200 then return "Error: HTTP " .. tostring(code) .. " for " .. url end
				if type(body) ~= "string" or body == "" then return "Error: empty response from " .. url end
				local head = lower(sub(body, 1, 1000))
				if find(head, "<html", 1, true) or find(head, "<!doctype html", 1, true) or find(head, "<body", 1, true) or find(head, "<head", 1, true) then
					text, title = htmlText(body)
				else
					text = body
				end
				pageCache.url, pageCache.text, pageCache.title = url, text, title
			end
			local total = #text
			if st0 > total then return "Error: startChar is past the end (" .. total .. " chars)." end
			local en = min(total, st0 + mx - 1)
			local chunk = sub(text, st0, en)
			return url .. (title and (" | " .. title) or "") .. "\n(chars " .. st0 .. "-" .. en .. " of " .. total .. (en < total and ", use startChar=" .. (en + 1) .. " to continue" or "") .. ")\n\n" .. chunk
		end

	end

	local decCache = setmetatable({}, { __mode = "k" })

	local function isServerScript(inst)
		if inst.ClassName ~= "Script" then return false end
		local ok, rc = pcall(function() return inst.RunContext end)
		return not (ok and rc == Enum.RunContext.Client)
	end
	local function getSource(inst)
		local c = decCache[inst]
		if c then return c end
		if not dcmp then return nil, "decompile is not supported by your executor." end
		local r = runTimed(30, dcmp, inst)
		if not r then return nil, "decompile timed out after 30s." end
		if not r[1] then return nil, "decompile failed: " .. tostring(r[2]) end
		local s = r[2]
		if type(s) ~= "string" then return nil, "decompile returned no source" .. (r[3] and (": " .. tostring(r[3])) or ".") end
		decCache[inst] = s
		return s
	end

	T["write"] = function(a)
		local mode = lower(str(a.mode) or "")
		if mode == "append" then return T["append"](a) end
		if mode == "delete" then return T["delete-file"](a) end
		local p, e = fPath(a.path)
		if not p then return "Error: " .. e end
		if not wf then return "Error: writefile is not supported by your executor." end
		if isDir(p) then return "Error: " .. p .. " is a folder." end
		local c = str(a.content) or ""
		ensureDirs(p)
		wf(p, c)
		return "Wrote " .. #c .. "B to " .. p
	end

	T["read"] = function(a)
		local rp = a.path and trim(tostring(a.path)) or ""
		if rp == "" or rp == "." or rp == "/" or isDir(gsub(gsub(rp, "\\", "/"), "/+$", "")) then return T["list-files"](a) end
		local p, e = fPath(a.path)
		if not p then return "Error: " .. e end
		if not rf then return "Error: readfile is not supported by your executor." end
		if not isFile(p) then return "Error: file not found: " .. p end
		local s = rf(p)
		if type(s) ~= "string" then return "Error: could not read " .. p end
		local a1, b1 = num(a.startLine, nil, 1), num(a.endLine, nil, 1)
		if a1 or b1 then
			local total = lineCount(s)
			a1, b1 = a1 or 1, b1 or huge
			return p .. " (lines " .. a1 .. "-" .. min(b1, total) .. " of " .. total .. "):\n" .. cap(sliceLines(s, a1, b1))
		end
		if #s == 0 then return p .. " is empty." end
		if #s <= LIM then return s end
		return p .. " (" .. lineCount(s) .. " lines, use startLine/endLine):\n" .. cap(s)
	end

	T["append"] = function(a)
		local p, e = fPath(a.path)
		if not p then return "Error: " .. e end
		local c = str(a.content) or ""
		ensureDirs(p)
		if af then
			af(p, c)
		elseif wf then
			local old = (isFile(p) and rf) and rf(p) or ""
			wf(p, (type(old) == "string" and old or "") .. c)
		else
			return "Error: appendfile/writefile are not supported by your executor."
		end
		return "Appended " .. #c .. "B to " .. p
	end

	T["list-files"] = function(a)
		if not lsf then return "Error: listfiles is not supported by your executor." end
		local p = a.path and trim(tostring(a.path)) or ""
		local list
		if p == "" or p == "." or p == "/" then
			local ok, r = pcall(lsf, "")
			if not ok or type(r) ~= "table" then ok, r = pcall(lsf, ".") end
			if not ok or type(r) ~= "table" then return "Error: could not list the workspace root." end
			list, p = r, "(root)"
		else
			local e
			p, e = fPath(p)
			if not p then return "Error: " .. tostring(e) end
			if not isDir(p) then return "Error: folder not found: " .. p end
			local ok, r = pcall(lsf, p)
			if not ok or type(r) ~= "table" then return "Error: could not list " .. p end
			list = r
		end
		tSort(list)
		local out, n = {}, 0
		for i = 1, #list do
			local f = gsub(tostring(list[i]), "\\", "/")
			n += 1
			if n > 300 then out[n] = "... (" .. (#list - 300) .. " more)" break end
			out[n] = f .. (isDir(f) and "/" or "")
		end
		if n == 0 then return p .. " is empty." end
		return tConcat(out, "\n")
	end

	T["delete-file"] = function(a)
		local p, e = fPath(a.path)
		if not p then return "Error: " .. e end
		if isFile(p) then
			if not dlf then return "Error: delfile is not supported by your executor." end
			dlf(p)
			return "Deleted file " .. p
		elseif isDir(p) then
			if not dld then return "Error: delfolder is not supported by your executor." end
			local lp2 = lower(p)
			if lp2 == "bloxy" or lp2 == "bloxy/profiles" or match(lp2, "^bloxy/profiles/[^/]+$") then return "Error: " .. p .. " holds protected profile data; delete specific files instead." end
			dld(p)
			return "Deleted folder " .. p
		end
		return "Error: not found: " .. p
	end

	T["run"] = function(a)
		local res, err, out = exec(a.code, false)
		if err then return "Error: " .. err end
		local parts = {}
		if out ~= "" then parts[#parts + 1] = out end
		if not res then
			parts[#parts + 1] = "(still running after 15s)"
		elseif not res[1] then
			parts[#parts + 1] = "Runtime error: " .. tostring(res[2])
		else
			if res.n > 1 then
				local rv = tCreate(res.n - 1)
				for i = 2, res.n do rv[i - 1] = short(res[i]) end
				parts[#parts + 1] = "Returned: " .. tConcat(rv, ", ")
			end
			if #parts == 0 then parts[1] = "OK" end
		end
		return tConcat(parts, "\n")
	end

	T["get-data-by-code"] = function(a)
		local res, err, out = exec(a.code, true)
		if err then return "Error: " .. err end
		if not res then return "Error: code did not finish within 15s." .. (out ~= "" and ("\nOutput:\n" .. out) or "") end
		if not res[1] then return "Runtime error: " .. tostring(res[2]) .. (out ~= "" and ("\nOutput:\n" .. out) or "") end
		local s = serialize(tUnpack(res, 2, res.n))
		return (out ~= "" and (out .. "\n=> ") or "") .. s
	end

	T["grep-part"] = function(a)
		local root = getInst(a, "root")
		local q = str(a.name)
		q = q and trim(q) ~= "" and lower(trim(q)) or nil
		local cls = str(a.className)
		cls = cls and trim(cls) ~= "" and trim(cls) or nil
		if not q and not cls then return "Error: give name and/or className." end
		local exact, lim = bool(a.exact), num(a.limit, 20, 1, 300)
		local useIsA = cls and pcall(game.IsA, game, cls)
		local res, hits = {}, 0
		local scanned, stopped, partial = walk(root, function(inst)
			if q then
				local ln = lower(inst.Name)
				if exact then if ln ~= q then return end elseif not find(ln, q, 1, true) then return end
			end
			if cls and inst.ClassName ~= cls and not (useIsA and inst:IsA(cls)) then return end
			hits += 1
			res[hits] = (inst.ClassName == cls) and pathOf(inst) or (pathOf(inst) .. " [" .. inst.ClassName .. "]")
			return hits >= lim
		end)
		if hits == 0 then return "No matches (scanned " .. scanned .. ")" .. (partial and ", scan stopped early" or "") end
		return tConcat(res, "\n") .. ((stopped or partial) and ("\n(limit " .. lim .. " reached)") or "")
	end

	do
		local textCls = { TextLabel = true, TextButton = true, TextBox = true }
		local valCls = { StringValue = true, IntValue = true, NumberValue = true, BoolValue = true }

		T["grep"] = function(a)
			local q = str(a.query)
			if not q or q == "" then return "Error: query is required." end
			local cs = bool(a.caseSensitive)
			local qq = cs and q or lower(q)
			local function has(s) if type(s) ~= "string" then return false end return find(cs and s or lower(s), qq, 1, true) ~= nil end
			local tg, tset = csv(a.targets)
			if #tg == 0 then tset = { names = true, text = true, attributes = true } end
			local lim = num(a.limit, 20, 1, 200)
			local root = getInst(a, "root")
			local res, hits = {}, 0
			local function add(s)
				hits += 1
				res[hits] = #s > 300 and (sub(s, 1, 300) .. "...") or s
				return hits >= lim
			end
			local partial = false
			if tset.names or tset.text or tset.attributes then
				local _, _, pt = walk(root, function(inst)
					local cn = inst.ClassName
					if tset.names and has(inst.Name) then if add(pathOf(inst) .. " [" .. cn .. "] name") then return true end end
					if tset.text then
						if textCls[cn] then
							local t = inst.Text
							if has(t) and add(pathOf(inst) .. " [" .. cn .. "] Text: " .. fmt("%q", t)) then return true end
						elseif valCls[cn] then
							local v = tostring(inst.Value)
							if has(v) and add(pathOf(inst) .. " [" .. cn .. "] Value: " .. v) then return true end
						end
					end
					if tset.attributes then
						local ok, at = pcall(inst.GetAttributes, inst)
						if ok and next(at) then
							for k, v in at do
								local vs = tostring(v)
								if (has(k) or has(vs)) and add(pathOf(inst) .. " [" .. cn .. "] attribute " .. k .. " = " .. vs) then return true end
							end
						end
					end
				end)
				partial = pt
			end
			if hits < lim and tset.files and lsf and rf then
				local stack, fCount, t0 = { "" }, 0, clock()
				while #stack > 0 and hits < lim and fCount < 600 do
					local dir = tRemove(stack)
					local ok, l = pcall(lsf, dir)
					if (not ok or type(l) ~= "table") and dir == "" then ok, l = pcall(lsf, ".") end
					if ok and type(l) == "table" then
						for i = 1, #l do
							local f = gsub(tostring(l[i]), "\\", "/")
							local lf = lower(f)
							if not privPath(lf) then
								if isDir(f) then
									stack[#stack + 1] = f
								elseif match(lf, "%.[%w]+$") and not match(lf, "%.png$") and not match(lf, "%.jpe?g$") and not match(lf, "%.ogg$") and not match(lf, "%.mp3$") and not match(lf, "%.ttf$") then
									fCount += 1
									local okR, s = pcall(rf, f)
									if okR and type(s) == "string" and #s < 2000000 then
										local pos, ln, len, per = 1, 0, #s, 0
										if has(s) then
											while pos <= len and per < 3 do
												ln += 1
												local e = find(s, "\n", pos, true) or (len + 1)
												local line = sub(s, pos, e - 1)
												if has(line) then
													per += 1
													if add(f .. ":" .. ln .. ": " .. trim(line)) then break end
												end
												pos = e + 1
											end
										end
									end
									if hits >= lim then break end
									if clock() - t0 > 0.004 then twait(); t0 = clock() end
								end
							end
						end
					end
				end
			end
			if hits < lim and tset.scripts then
				if not dcmp then
					add("(scripts skipped: decompile is not supported by your executor)")
				else
					local list = {}
					walk(root, function(inst)
						local cn = inst.ClassName
						if cn == "LocalScript" or cn == "ModuleScript" or (cn == "Script" and not isServerScript(inst)) then list[#list + 1] = inst end
						return #list >= 40
					end)
					local tStart = clock()
					for i = 1, #list do
						if hits >= lim or clock() - tStart > 60 then break end
						local s = getSource(list[i])
						if s and has(s) then
							local pos, ln, len, per, pth = 1, 0, #s, 0, pathOf(list[i])
							while pos <= len and per < 3 do
								ln += 1
								local e = find(s, "\n", pos, true) or (len + 1)
								local line = sub(s, pos, e - 1)
								if has(line) then
									per += 1
									if add(pth .. ":" .. ln .. ": " .. trim(line)) then break end
								end
								pos = e + 1
							end
						end
						twait()
					end
				end
			end
			if hits == 0 then return "No matches" .. (partial and " (scan stopped early)" or "") end
			return tConcat(res, "\n") .. (hits >= lim and "\n(limit reached)" or "")
		end

	end

	T["get-children"] = function(a)
		local root = getInst(a)
		local depth, lim = num(a.depth, 1, 1, 3), num(a.limit, 100, 1, 400)
		local out, n, more = { pathOf(root) .. " [" .. root.ClassName .. "]" }, 1, false
		local function rec(inst, d, ind)
			local ok, ch = pcall(inst.GetChildren, inst)
			if not ok then return end
			for i = 1, #ch do
				if n > lim then more = true return end
				local c = ch[i]
				local okC, cc = pcall(c.GetChildren, c)
				local cnt = okC and #cc or 0
				n += 1
				out[n] = ind .. c.Name .. " [" .. c.ClassName .. "]" .. (cnt > 0 and (" (" .. cnt .. " children)") or "")
				if d < depth and cnt > 0 then rec(c, d + 1, ind .. "  ") end
			end
		end
		rec(root, 1, "  ")
		if n == 1 then return out[1] .. " has no children." end
		if more then out[n + 1] = "... (limit " .. lim .. " reached)" end
		return tConcat(out, "\n")
	end

	do
		local commonProps = {
			"Position", "Orientation", "CFrame", "Size", "Anchored", "CanCollide", "CanTouch", "CanQuery", "Transparency", "Color", "Material", "Shape", "Locked", "Massless",
			"AssemblyLinearVelocity", "PrimaryPart", "WorldPivot", "Value", "Enabled", "Disabled", "RunContext", "Visible", "Text", "TextColor3", "TextSize", "Image", "BackgroundColor3", "BackgroundTransparency",
			"AbsolutePosition", "AbsoluteSize", "ZIndex", "LayoutOrder", "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight", "UseJumpPower", "HipHeight", "RigType", "MoveDirection", "FloorMaterial",
			"DisplayName", "UserId", "Team", "TeamColor", "Character", "AccountAge", "MeshId", "TextureID", "Texture", "SoundId", "Volume", "Playing", "Looped", "Adornee", "Brightness", "Range",
			"CameraType", "CameraSubject", "FieldOfView", "Gravity", "ClockTime", "Ambient", "MaxActivationDistance", "HoldDuration", "ActionText", "ObjectText", "ResetOnSpawn", "DisplayOrder"
		}

		local defCache = {}
		local function defaultOf(cls)
			local d = defCache[cls]
			if d == nil then
				local ok, inst = pcall(Instance.new, cls)
				d = ok and inst or false
				defCache[cls] = d
			end
			return d or nil
		end
		T["inspect"] = function(a)
			local inst = getInst(a)
			local okC, ch = pcall(inst.GetChildren, inst)
			local out = { pathOf(inst) .. " [" .. inst.ClassName .. "] children=" .. (okC and #ch or 0) }
			local req = {}
			if type(a.properties) == "string" then
				for pn in gmatch(a.properties, "[^,;%s]+") do req[#req + 1] = pn end
			elseif type(a.properties) == "table" then
				for _, pn in a.properties do if type(pn) == "string" and trim(pn) ~= "" then req[#req + 1] = trim(pn) end end
			end
			local list = #req > 0 and req or commonProps
			local base = #req == 0 and defaultOf(inst.ClassName) or nil
			local props = {}
			for i = 1, #list do
				local pn = list[i]
				local ok, v = pcall(function() return inst[pn] end)
				if ok and typeof(v) ~= "RBXScriptSignal" and typeof(v) ~= "function" then
					local same = false
					if base then
						local okD, dv = pcall(function() return base[pn] end)
						same = okD and dv == v
					end
					if not same then props[#props + 1] = pn .. "=" .. short(v) end
				elseif #req > 0 then
					props[#props + 1] = pn .. "=?"
				end
			end
			if #props > 0 then out[#out + 1] = tConcat(props, "; ") end
			local okA, at = pcall(inst.GetAttributes, inst)
			if okA and next(at) then
				local al = {}
				for k, v in at do al[#al + 1] = k .. "=" .. short(v) end
				tSort(al)
				out[#out + 1] = "Attributes: " .. tConcat(al, "; ")
			end
			local okT, tags = pcall(CollectionService.GetTags, CollectionService, inst)
			if okT and #tags > 0 then out[#out + 1] = "Tags: " .. tConcat(tags, ", ") end
			if inst:IsA("LuaSourceContainer") and isServerScript(inst) then out[#out + 1] = "(server Script)" end
			return tConcat(out, "\n")
		end

	end

	T["decompile"] = function(a)
		local inst = getInst(a)
		if not inst:IsA("LuaSourceContainer") then return "Error: " .. pathOf(inst) .. " is a " .. inst.ClassName .. ", not a script." end
		if isServerScript(inst) then return "you cannot use this on a server script." end
		local s, err = getSource(inst)
		if not s then return "Error: " .. err end
		local total = lineCount(s)
		local a1, b1 = num(a.startLine, nil, 1), num(a.endLine, nil, 1)
		if a1 or b1 then
			a1, b1 = a1 or 1, b1 or huge
			return "(" .. total .. " lines)\n" .. cap(sliceLines(s, a1, b1))
		end
		if #s > LIM then return "(" .. total .. " lines, use startLine/endLine)\n" .. cap(s) end
		return s
	end

	T["get-game-info"] = function()
		local out = {}
		local function add(k, v) out[#out + 1] = k .. ": " .. tostring(v) end
		add("PlaceId", game.PlaceId); add("GameId", game.GameId); add("JobId", game.JobId ~= "" and game.JobId or "(studio/none)"); add("PlaceVersion", game.PlaceVersion)
		local okI, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
		if okI and type(info) == "table" and info.Name then add("Game name", info.Name) end
		add("Players", #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
		add("LocalPlayer", lp.Name .. " (@" .. lp.DisplayName .. ", UserId " .. lp.UserId .. ", AccountAge " .. lp.AccountAge .. "d" .. (lp.Team and (", Team " .. lp.Team.Name) or "") .. ")")
		local chr = lp.Character
		if chr then
			add("Character", pathOf(chr))
			local hrp = chr:FindFirstChild("HumanoidRootPart")
			if hrp then add("Position", tostring(hrp.Position)) end
			local hum = chr:FindFirstChildOfClass("Humanoid")
			if hum then
				add("Humanoid", "Health " .. floor(hum.Health) .. "/" .. floor(hum.MaxHealth) .. ", WalkSpeed " .. hum.WalkSpeed .. ", " .. (hum.UseJumpPower and ("JumpPower " .. hum.JumpPower) or ("JumpHeight " .. hum.JumpHeight)) .. ", State " .. hum:GetState().Name .. ", RigType " .. hum.RigType.Name)
			end
		else
			add("Character", "not spawned")
		end
		local cam = workspace.CurrentCamera
		if cam then add("Camera", "Position " .. tostring(cam.CFrame.Position) .. ", FOV " .. cam.FieldOfView .. ", Type " .. cam.CameraType.Name) end
		add("Gravity", workspace.Gravity)
		add("Server time", fmt("%.1fs", workspace.DistributedGameTime))
		if idEx then local ok, n, v = pcall(idEx); if ok and n then add("Executor", tostring(n) .. (v and (" " .. tostring(v)) or "")) end end
		add("Executor functions", (wf and "writefile " or "") .. (rf and "readfile " or "") .. (lsf and "listfiles " or "") .. (lstr and "loadstring " or "") .. (dcmp and "decompile" or ""))
		return tConcat(out, "\n")
	end

	local spec, nameList
	do
		local defs = {
			{ "write", "Write workspace file. mode: append|delete (default overwrite).", { { "path", "string", nil, true }, { "content", "string" }, { "mode", "string" } } },
			{ "read", "Read workspace file, or list folder (empty path = root).", { { "path", "string" }, { "startLine", "integer" }, { "endLine", "integer" } } },
			{ "run", "Run Luau on client; returns prints, returns, errors (15s).", { { "code", "string", nil, true } } },
			{ "get-data-by-code", "Eval Luau expression (or block with return); returns the value serialized.", { { "code", "string", nil, true } } },
			{ "grep-part", "Find instances by name substring and/or IsA class.", { { "name", "string" }, { "className", "string" }, { "root", "string" }, { "exact", "boolean" } } },
			{ "grep", "Find text. targets: names,text,attributes,files,scripts (default first 3).", { { "query", "string", nil, true }, { "targets", "string" }, { "root", "string" }, { "caseSensitive", "boolean" } } },
			{ "get-children", "Child tree of an instance (default game), depth 1-3.", { { "path", "string" }, { "depth", "integer" } } },
			{ "inspect", "Non-default properties, attributes, tags. properties: comma list to read specific ones.", { { "path", "string", nil, true }, { "properties", "string" } } },
			{ "decompile", "Source of a LocalScript/ModuleScript.", { { "path", "string", nil, true }, { "startLine", "integer" }, { "endLine", "integer" } } },
			{ "get-game-info", "Place, players, character, camera, executor info.", {} },
			{ "research", "Web search.", { { "query", "string", nil, true } } },
			{ "fetch-url", "Read a URL as text.", { { "url", "string", nil, true }, { "startChar", "integer" } } }
		}

		local names = tCreate(#defs)
		for i = 1, #defs do names[i] = defs[i][1] end
		nameList = tConcat(names, ", ")

		local function schema(params, up)
			local props, req = {}, {}
			for i = 1, #params do
				local p = params[i]
				props[p[1]] = { type = up and upper(p[2]) or p[2], description = p[3] }
				if p[4] then req[#req + 1] = p[1] end
			end
			local o = { type = up and "OBJECT" or "object", properties = next(props) and props or EOBJ }
			if #req > 0 then o.required = req end
			return o
		end

		local specCache = {}
		local skDef = { "use-skill", "Load an installed skill's instructions, or a file the skill references.", { { "name", "string", nil, true }, { "file", "string", "Relative path in the skill folder" }, { "startChar", "integer" } } }
		spec = function(kind)
			local sk = st.skillCount ~= nil and st.skillCount() > 0
			local ck = sk and (kind .. "s") or kind
			local c = specCache[ck]
			if c then return c end
			local ds = defs
			if sk then ds = table.clone(defs); ds[#ds + 1] = skDef end
			if kind == "g" then
				local decl = tCreate(#ds)
				for i = 1, #ds do
					local d = ds[i]
					decl[i] = { name = d[1], description = d[2], parameters = #d[3] > 0 and schema(d[3], true) or nil }
				end
				c = { { functionDeclarations = decl } }
			elseif kind == "c" then
				c = tCreate(#ds)
				for i = 1, #ds do local d = ds[i]; c[i] = { name = d[1], description = d[2], input_schema = schema(d[3], false) } end
			else
				c = tCreate(#ds)
				for i = 1, #ds do local d = ds[i]; c[i] = { type = "function", ["function"] = { name = d[1], description = d[2], parameters = schema(d[3], false) } } end
			end
			subs[ck] = (gsub(HttpService:JSONEncode(c), subPat, subs))
			c = P .. ck
			specCache[ck] = c
			return c
		end

	end

	runTool = function(name, args)
		name = gsub(tostring(name or ""), "^default_api%.", "")
		local f = T[name]
		if not f then return "Error: unknown tool '" .. name .. "'. Available tools: " .. nameList end
		if type(args) ~= "table" then args = {} end
		local ok, r = pcall(f, args)
		if not ok then r = "Error: " .. tostring(r) end
		r = type(r) == "string" and r or tostring(r)
		if r == "" then r = "(no output)" end
		return clean(cap(r, name == "use-skill" and 9000 or LIM + 300))
	end

	toolPrompt = "\nClient executor in a live game (PlaceId " .. game.PlaceId .. ", player \"" .. lp.Name .. "\"). Use tools, don't guess; check real instances first. Paths: game.Workspace.Map[\"Part\"]. User can't see tool output: reply briefly, code in ```lua. No non-yielding loops or unrequested destructive actions. @path = mentioned instance, details attached."

	local function hist(msgs, conv)
		local n = #msgs
		local s0 = max(1, n - HIST + 1)
		while s0 < n and msgs[s0].role == "assistant" do s0 += 1 end
		local out = tCreate(n - s0 + 1)
		for i = s0, n do
			local m = msgs[i]
			local t = m.text or ""
			local old, short = i <= n - 4 and m.role == "assistant", i < n - 1
			if old or short then
				local hk, hc = (old and 1 or 0) + (short and 2 or 0), m.hc
				local ct = hc and hc[hk]
				if ct then
					t = ct
				else
					if old then t = gsub(t, "```[%w_%-]*[^\n]*\n.-```", "[code omitted]") end
					if short and #t > OLDCAP then t = cutU(t, OLDCAP) .. "...[trimmed]" end
					if not hc then hc = {}; m.hc = hc end
					hc[hk] = t
				end
			end
			if i == n and m.ctx then t ..= m.ctx end
			local imgs = nil
			if m.images and i == n then imgs = m.images elseif m.img then t ..= " [image]" end
			out[#out + 1] = conv(m.role == "assistant", t, imgs)
		end
		return out
	end
	local function res(steps, s, i)
		local r = steps[s].results[i]
		local cl = steps[s].calls[i]
		if s <= #steps - 2 and #r > OLDRES and not (cl and find(tostring(cl.name), "use-skill", 1, true)) then return cutU(r, OLDRES) .. "...[trimmed]" end
		return r
	end

	do
		local function capsOf(prov, mdl)
			local c = st.modelCaps[prov]
			return c and c[mdl]
		end
		local function claudeMode(mdl)
			local c = capsOf("Claude", mdl)
			if c then
				if c.effort and next(c.effort) then return "effort" end
				if c.budget then return "budget" end
				return nil
			end
			local lm = lower(mdl)
			if match(lm, "^claude%-3%-[05]") or match(lm, "^claude%-3%-haiku") or match(lm, "^claude%-3%-opus") or match(lm, "^claude%-3%-sonnet") then return nil end
			if match(lm, "^claude%-3%-7") or match(lm, "^claude%-%a+%-4%-[01]") or match(lm, "^claude%-%a+%-4%-%d%d%d%d") or match(lm, "^claude%-%a+%-4$") then return "budget" end
			return "effort"
		end
		local effortOrder = { "low", "medium", "high", "xhigh", "max" }
		effortLevels = function(prov, mdl)
			local lm = lower(mdl or "")
			if prov == "Gemini" then
				local c = capsOf(prov, mdl)
				if c and c.thinking == false then return { "auto" } end
				if match(lm, "^gemini%-[3-9]") then
					return find(lm, "flash", 1, true) and { "auto", "minimal", "low", "medium", "high" } or { "auto", "low", "high" }
				elseif match(lm, "^gemini%-2%.5") then
					return find(lm, "pro", 1, true) and { "auto", "low", "medium", "high" } or { "auto", "none", "low", "medium", "high" }
				end
				return (c and c.thinking) and { "auto", "low", "medium", "high" } or { "auto" }
			elseif prov == "Claude" then
				local mode = claudeMode(mdl or "")
				if mode == "effort" then
					local c = capsOf(prov, mdl)
					if c and c.effort then
						local t = { "auto" }
						for _, lv in effortOrder do if c.effort[lv] then t[#t + 1] = lv end end
						return t
					end
					return { "auto", "low", "medium", "high", "max" }
				elseif mode == "budget" then
					return { "auto", "low", "medium", "high" }
				end
				return { "auto" }
			elseif prov == "ChatGPT" then
				if match(lm, "^gpt%-5") then return { "auto", "minimal", "low", "medium", "high" } end
				if match(lm, "^o%d") then return { "auto", "low", "medium", "high" } end
				return { "auto" }
			elseif prov == "Groq" then
				if find(lm, "gpt-oss", 1, true) then return { "auto", "low", "medium", "high" } end
				if find(lm, "qwen3", 1, true) or find(lm, "qwen-3", 1, true) then return { "auto", "none", "default" } end
				return { "auto" }
			end
			return { "auto", "low", "medium", "high" }
		end
		local gBudget = { none = 0, minimal = 512, low = 1024, medium = 8192, high = 24576 }
		local cBudget = { low = 2048, medium = 8192, high = 16384 }
		local cMax = { low = 4096, medium = 8192, high = 12288, xhigh = 16384, max = 16384 }

		toolBuild = function(prov, key, mdl, cUrl, msgs, steps, sys, useTools, final, effort)
			local url, hdrs, body
			if prov == "Gemini" then
				url, hdrs = LPH_ENCSTR("https://generativelanguage.googleapis.com/v1beta/models/") .. mdl .. LPH_ENCSTR(":generateContent?key=") .. key, { ["Content-Type"] = "application/json" }
				local cts = hist(msgs, function(isA, t, imgs)
					local parts = { { text = t } }
					if imgs then for k = 1, #imgs do parts[#parts + 1] = { inlineData = { mimeType = imgs[k].mime, data = imgs[k].data } } end end
					return { role = isA and "model" or "user", parts = parts }
				end)
				for s = 1, #steps do
					local sp = steps[s]
					cts[#cts + 1] = { role = "model", parts = sp.raw }
					local fr = tCreate(#sp.calls)
					for i = 1, #sp.calls do
						local c = sp.calls[i]
						local r = { name = c.name, response = { result = res(steps, s, i) } }
						if c.id then r.id = c.id end
						fr[i] = { functionResponse = r }
					end
					cts[#cts + 1] = { role = "user", parts = fr }
				end
				body = { systemInstruction = { parts = { { text = sys } } }, contents = cts }
				if effort then
					local lm = lower(mdl)
					if match(lm, "^gemini%-[3-9]") then
						body.generationConfig = { thinkingConfig = { thinkingLevel = effort } }
					else
						local b = gBudget[effort] or 8192
						if find(lm, "pro", 1, true) then b = max(128, effort == "high" and 32768 or b) end
						body.generationConfig = { thinkingConfig = { thinkingBudget = b } }
					end
				end
				if useTools then
					body.tools = spec("g")
					if final then body.toolConfig = { functionCallingConfig = { mode = "NONE" } } end
				end
			elseif prov == "Claude" then
				url, hdrs = LPH_ENCSTR("https://api.anthropic.com/v1/messages"), { ["Content-Type"] = "application/json", ["x-api-key"] = key, ["anthropic-version"] = "2023-06-01" }
				local cm = hist(msgs, function(isA, t, imgs)
					if not imgs then return { role = isA and "assistant" or "user", content = t } end
					local c = {}
					for k = 1, #imgs do c[#c + 1] = { type = "image", source = { type = "base64", media_type = imgs[k].mime, data = imgs[k].data } } end
					c[#c + 1] = { type = "text", text = t }
					return { role = "user", content = c }
				end)
				local lm = cm[#cm]
				if lm and type(lm.content) == "table" then
					lm.content[#lm.content].cache_control = { type = "ephemeral" }
				elseif lm and lm.content ~= "" then
					lm.content = { { type = "text", text = lm.content, cache_control = { type = "ephemeral" } } }
				end
				for s = 1, #steps do
					local sp = steps[s]
					cm[#cm + 1] = { role = "assistant", content = sp.raw }
					local tr = tCreate(#sp.calls)
					for i = 1, #sp.calls do tr[i] = { type = "tool_result", tool_use_id = sp.calls[i].id, content = res(steps, s, i) } end
					if s == #steps then tr[#tr].cache_control = { type = "ephemeral" } end
					cm[#cm + 1] = { role = "user", content = tr }
				end
				body = { model = mdl, max_tokens = 4096, system = { { type = "text", text = sys, cache_control = { type = "ephemeral" } } }, messages = cm }
				if effort then
					local mode = claudeMode(mdl)
					if mode == "budget" and cBudget[effort] then
						body.thinking = { type = "enabled", budget_tokens = cBudget[effort] }
						body.max_tokens = cBudget[effort] + 4096
					elseif mode == "effort" then
						body.output_config = { effort = effort }
						body.max_tokens = cMax[effort] or 4096
					end
				end
				if useTools then
					body.tools = spec("c")
					if final then body.tool_choice = { type = "none" } end
				end
			else
				url = (prov == "ChatGPT" and LPH_ENCSTR("https://api.openai.com/v1/chat/completions")) or (prov == "Groq" and LPH_ENCSTR("https://api.groq.com/openai/v1/chat/completions")) or cUrl
				hdrs = { ["Content-Type"] = "application/json" }
				if key ~= "" then hdrs["Authorization"] = LPH_ENCSTR("Bearer ") .. key end
				local om = hist(msgs, function(isA, t, imgs)
					if not imgs then return { role = isA and "assistant" or "user", content = t } end
					local c = { { type = "text", text = t } }
					for k = 1, #imgs do c[#c + 1] = { type = "image_url", image_url = { url = "data:" .. imgs[k].mime .. ";base64," .. imgs[k].data } } end
					return { role = "user", content = c }
				end)
				tInsert(om, 1, { role = "system", content = sys })
				for s = 1, #steps do
					local sp = steps[s]
					om[#om + 1] = { role = "assistant", content = sp.text or "", tool_calls = sp.raw }
					for i = 1, #sp.calls do om[#om + 1] = { role = "tool", tool_call_id = sp.calls[i].id, content = res(steps, s, i) } end
				end
				body = { model = mdl, messages = om }
				if effort then body.reasoning_effort = effort end
				if useTools then
					body.tools = spec("o")
					if final then body.tool_choice = "none" end
				end
			end
			return url, hdrs, body
		end

	end

	do
		local function oneLine(v, n)
			local t = gsub(gsub(tostring(v), "%s+", " "), "^ ", "")
			return #t > n and (cutU(t, n) .. "...") or t
		end
		argSummary = function(args)
			if type(args) ~= "table" then return "" end
			local keys = {}
			for k in args do if type(k) == "string" then keys[#keys + 1] = k end end
			tSort(keys)
			local parts = tCreate(#keys)
			for i = 1, #keys do
				local v = args[keys[i]]
				parts[i] = keys[i] .. "=" .. (type(v) == "string" and ('"' .. oneLine(v, 36) .. '"') or oneLine(v, 16))
			end
			return oneLine(tConcat(parts, " "), 110)
		end

		mentionCtx = function(text)
			local ms = scanMentions(text)
			if #ms == 0 then return nil end
			local out, seen = {}, {}
			for i = 1, #ms do
				local p = ms[i][3]
				if not seen[p] and #out < 4 then
					seen[p] = true
					local ok, inst = pcall(resolve, p)
					if ok and inst then
						local info = runTool("inspect", { path = pathOf(inst) })
						local okC, ch = pcall(inst.GetChildren, inst)
						if okC and #ch > 0 then
							local nm = tCreate(min(#ch, 10))
							for j = 1, min(#ch, 10) do nm[j] = ch[j].Name end
							info ..= "\nKids: " .. tConcat(nm, ", ") .. (#ch > 10 and ", ..." or "")
						end
						out[#out + 1] = "[@" .. p .. "] " .. cap(info, 700)
					else
						out[#out + 1] = "[@" .. p .. "] not found"
					end
				end
			end
			return "\n\n" .. tConcat(out, "\n\n")
		end

		local roots = { "game", "workspace", "game.Players.LocalPlayer", "game.Players.LocalPlayer.Character", "game.Players.LocalPlayer.PlayerGui", "game.ReplicatedStorage", "game.Lighting", "workspace.CurrentCamera" }
		mentionSuggest = function(tok)
			local out = {}
			local par, part = match(tok, "^(.*)%.([^%.%[%]]*)$")
			if not par then
				local lt = lower(tok)
				for i = 1, #roots do
					if sub(lower(roots[i]), 1, #lt) == lt then out[#out + 1] = { roots[i], roots[i] } end
				end
				return out
			end
			local ok, inst = pcall(resolve, par)
			if not ok or not inst then return out end
			local lp2 = lower(part)
			if inst == Players and sub("localplayer", 1, #lp2) == lp2 then out[1] = { "LocalPlayer [Player]", par .. ".LocalPlayer" } end
			local okC, ch = pcall(inst.GetChildren, inst)
			if not okC then return out end
			for i = 1, #ch do
				local c = ch[i]
				local nm = c.Name
				if sub(lower(nm), 1, #lp2) == lp2 then
					out[#out + 1] = { nm .. " [" .. c.ClassName .. "]", par .. (match(nm, "^[%a_][%w_]*$") and ("." .. nm) or (find(nm, '"', 1, true) and ("['" .. nm .. "']") or ('["' .. nm .. '"]'))) }
					if #out >= 6 then break end
				end
			end
			return out
		end

	end

	toolParse = function(prov, parsed)
		if type(parsed) ~= "table" then return nil end
		if prov == "Gemini" then
			local cand = type(parsed.candidates) == "table" and parsed.candidates[1]
			local parts = type(cand) == "table" and type(cand.content) == "table" and cand.content.parts
			if type(parts) == "table" then
				local tx, calls = {}, {}
				for i = 1, #parts do
					local p = parts[i]
					if type(p) == "table" then
						local fc = p.functionCall
						if type(fc) == "table" and type(fc.name) == "string" then
							local args = fc.args
							if type(args) ~= "table" or next(args) == nil then args = {}; fc.args = EOBJ end
							calls[#calls + 1] = { id = fc.id, name = fc.name, args = args }
						elseif type(p.text) == "string" and not p.thought then
							tx[#tx + 1] = p.text
						end
					end
				end
				return tConcat(tx), calls, parts
			end
		elseif prov == "Claude" then
			if type(parsed.content) == "table" then
				local tx, calls, raw = {}, {}, {}
				for i = 1, #parsed.content do
					local b = parsed.content[i]
					if type(b) == "table" then
						if b.type == "text" then
							if type(b.text) == "string" and b.text ~= "" then tx[#tx + 1] = b.text; raw[#raw + 1] = b end
						elseif b.type == "tool_use" then
							local inp = b.input
							if type(inp) ~= "table" or next(inp) == nil then inp = {}; b.input = EOBJ end
							calls[#calls + 1] = { id = b.id, name = b.name, args = inp }
							raw[#raw + 1] = b
						else
							raw[#raw + 1] = b
						end
					end
				end
				return tConcat(tx), calls, raw
			end
		end
		local ch = type(parsed.choices) == "table" and parsed.choices[1]
		local msg = type(ch) == "table" and ch.message
		if type(msg) == "table" then
			local calls, raw = {}, {}
			if type(msg.tool_calls) == "table" then
				for i = 1, #msg.tool_calls do
					local tc = msg.tool_calls[i]
					local f = type(tc) == "table" and tc["function"]
					if type(f) == "table" and type(f.name) == "string" then
						local argStr, args = f.arguments, nil
						if type(argStr) == "table" then
							args = argStr
							argStr = next(args) and jsonEnc(args) or "{}"
						else
							argStr = (type(argStr) == "string" and argStr ~= "") and argStr or "{}"
							local ok, d = pcall(HttpService.JSONDecode, HttpService, argStr)
							args = (ok and type(d) == "table") and d or {}
						end
						local id = type(tc.id) == "string" and tc.id ~= "" and tc.id or ("call_" .. i .. rand())
						calls[#calls + 1] = { id = id, name = f.name, args = args }
						raw[#raw + 1] = { id = id, type = "function", ["function"] = { name = f.name, arguments = argStr } }
					end
				end
			end
			return type(msg.content) == "string" and msg.content or "", calls, raw
		end
		if type(parsed.content) == "table" and type(parsed.content[1]) == "table" and type(parsed.content[1].text) == "string" then return parsed.content[1].text, {}, nil end
		if type(parsed.response) == "string" then return parsed.response, {}, nil end
		if type(parsed.text) == "string" then return parsed.text, {}, nil end
		return nil
	end
end)()

;(function()
	local G = (getgenv and getgenv()) or _G
	local wf, rf, isf, isd, mkd, dlf = G.writefile or writefile, G.readfile or readfile, G.isfile or isfile, G.isfolder or isfolder, G.makefolder or makefolder, G.delfile or delfile
	local gmatch = string.gmatch
	local DIR = "Bloxy/skills"
	local IDX = DIR .. "/index.json"
	local MAXF, MAXB = 262144, 8000
	local skills, order, sysTxt = {}, {}, nil
	local lastKey, lastTxt, lastNm = nil, nil, nil

	local function pc(f, ...)
		if not f then return nil end
		local ok, r = pcall(f, ...)
		if ok then return r end
		return nil
	end
	local function trim(v) return match(v, "^%s*(.-)%s*$") or "" end
	local function cutU(v, n)
		if #v <= n then return v end
		local c = sub(v, 1, n)
		for _ = 1, 3 do
			if uLen(c) then break end
			c = sub(c, 1, #c - 1)
		end
		return c .. "..."
	end
	local function norm(src) return (gsub(gsub(src, "^\239\187\191", ""), "\r\n?", "\n")) end
	local function fileOf(nm) return DIR .. "/" .. nm .. ".md" end
	local function ensure()
		if not isd or not mkd then return end
		if not pc(isd, "Bloxy") then pc(mkd, "Bloxy") end
		if not pc(isd, DIR) then pc(mkd, DIR) end
	end
	local function reorder()
		tClear(order)
		for k in skills do order[#order + 1] = k end
		tSort(order)
		sysTxt = nil
	end
	local function saveIdx()
		if not wf then return end
		ensure()
		local t, any = {}, false
		for k, v in skills do t[k], any = { d = v.d, u = v.u }, true end
		pc(wf, IDX, any and HttpService:JSONEncode(t) or "{}")
	end

	do
		local s = pc(isf, IDX) and pc(rf, IDX)
		if type(s) == "string" and s ~= "" then
			local ok, t = pcall(HttpService.JSONDecode, HttpService, s)
			if ok and type(t) == "table" then
				for k, v in t do
					if type(k) == "string" and match(k, "^[a-z0-9%-]+$") and type(v) == "table" and type(v.d) == "string" and pc(isf, fileOf(k)) then
						skills[k] = { d = v.d, u = type(v.u) == "string" and v.u or "" }
					end
				end
			end
		end
		reorder()
	end

	local function get(u)
		if not match(u, "^https?://") then
			local p = gsub(gsub(gsub(trim(u), "\\", "/"), "/+", "/"), "/$", "")
			if p == "" or find("/" .. p .. "/", "/../", 1, true) or find(p, ":", 1, true) or privPath(p) then return nil, p, "invalid path" end
			if pc(isd, p) then p ..= "/SKILL.md" end
			local s = pc(isf, p) and pc(rf, p)
			if type(s) ~= "string" then return nil, p, "file not found" end
			return s, p
		end
		local code, body = doHttp({ Url = u, Method = "GET" })
		if code == 0 then
			local ok, b = pcall(game.HttpGet, game, u)
			if ok and type(b) == "string" then code, body = 200, b end
		end
		if code ~= 200 or type(body) ~= "string" or body == "" then return nil, u, "HTTP " .. tostring(code) end
		return body, u
	end

	local function srcList(u)
		u = gsub(trim(u), "#.*$", "")
		local o, r, rest = match(u, "^https?://github%.com/([^/]+)/([^/?]+)([^?]*)")
		if o then
			r = gsub(r, "%.git$", "")
			local raw = "https://raw.githubusercontent.com/" .. o .. "/" .. r .. "/"
			local kind, path = match(rest, "^/(%a+)/(.-)/*$")
			if kind == "blob" or kind == "raw" then return { raw .. path } end
			if kind == "tree" then return { raw .. path .. "/SKILL.md" } end
			return { raw .. "HEAD/SKILL.md" }
		end
		if match(lower(u), "%.md$") then return { u } end
		return { u, (gsub(u, "/+$", "")) .. "/SKILL.md" }
	end

	local function unq(v)
		v = trim(v)
		local q = sub(v, 1, 1)
		if #v > 1 and (q == '"' or q == "'") and sub(v, -1) == q then v = sub(v, 2, -2) end
		return v
	end
	local function parse(src)
		local fm = match(src, "^%-%-%-[ \t]*\n(.-)\n%-%-%-[ \t]*\n") or match(src, "^%-%-%-[ \t]*\n(.-)\n%-%-%-[ \t]*$")
		if not fm then return nil, "no YAML frontmatter (--- name/description ---)" end
		local f, key = {}, nil
		for line in gmatch(fm .. "\n", "([^\n]*)\n") do
			local k, v = match(line, "^([%w_%-]+):[ \t]*(.-)[ \t]*$")
			if k then
				key = k
				f[k] = (v == "" or match(v, "^[>|][%-+]?$")) and "" or unq(v)
			elseif key and f[key] and match(line, "^%s+%S") then
				local l = trim(line)
				f[key] = f[key] == "" and l or (f[key] .. " " .. l)
			end
		end
		local nm = gsub(gsub(lower(f.name or ""), "[^a-z0-9%-]+", "-"), "%-%-+", "-")
		nm = gsub(gsub(sub(gsub(nm, "^%-+", ""), 1, 64), "%-+$", ""), "^%-+", "")
		local d = trim(gsub(gsub(f.description or "", "<[^>]*>", ""), "%s+", " "))
		if nm == "" then return nil, "frontmatter is missing 'name'" end
		if d == "" then return nil, "frontmatter is missing 'description'" end
		return nm, cutU(d, 1024)
	end

	local box, status, list = st.skBox, st.skStatus, st.skList
	local errCol = c3(0.88, 0.24, 0.30)
	local empty = lbl(list, "No skills installed.", 10, grayName, u2o(0, 0), u2(1, 0, 0, 16))
	empty.LayoutOrder = 0
	local rows = {}
	local function render()
		for i = 1, #rows do rows[i]:Destroy() end
		tClear(rows)
		empty.Visible = #order == 0
		for i = 1, #order do
			local k = order[i]
			local r = iNew("Frame")
			r.Name, r.LayoutOrder, r.BackgroundColor3, r.BackgroundTransparency, r.BorderSizePixel, r.Size = rand(), i, bubbleBg, 0.35, 0, u2(1, 0, 0, 34)
			crn(r, itemRad)
			lbl(r, k, 11, white, u2o(8, 3), u2(1, -36, 0, 15))
			lbl(r, skills[k].d, 9, grayName, u2o(8, 18), u2(1, -36, 0, 12))
			local x = iNew("ImageButton")
			x.Name, x.AutoButtonColor, x.AnchorPoint, x.Position, x.Size, x.BackgroundColor3, x.BackgroundTransparency, x.BorderSizePixel = rand(), false, rAnc, u2(1, -6, 0.5, 0), u2o(20, 20), darkBox, 1, 0
			crn(x, circRad)
			icn(x, decal(109058392374604), 9)
			x.Parent = r
			bindFeedback(x, darkBox, hoverBg, 1, 0)
			x.Activated:Connect(function() st.skillRemove(k) end)
			r.Parent = list
			rows[i] = r
		end
	end

	st.skillCount = function() return #order end
	st.skillsPrompt = function()
		if sysTxt then return sysTxt end
		if #order == 0 then
			sysTxt = ""
			return sysTxt
		end
		local out = tCreate(min(#order, 40) + 1)
		out[1] = "\nSkills (call use-skill before a matching task, then follow it):"
		for i = 1, min(#order, 40) do
			local k = order[i]
			out[i + 1] = "- " .. k .. ": " .. cutU(skills[k].d, 300)
		end
		sysTxt = tConcat(out, "\n")
		return sysTxt
	end

	st.skillGet = function(nm, file, from)
		nm = lower(trim(nm or ""))
		local s = skills[nm]
		if not s then return "Error: no skill '" .. nm .. "'. Installed: " .. (#order > 0 and tConcat(order, ", ") or "none") end
		file = file and gsub(gsub(trim(file), "\\", "/"), "^%./", "") or ""
		local key, txt = nm .. "\0" .. file, nil
		if key == lastKey then
			txt = lastTxt
		elseif file ~= "" and file ~= "SKILL.md" then
			if find("/" .. file .. "/", "/../", 1, true) or sub(file, 1, 1) == "/" or find(file, ":", 1, true) then return "Error: file must be a relative path inside the skill folder." end
			local base = match(s.u, "^(.*)/[^/]*$")
			if not base then return "Error: this skill has no source folder." end
			local body, _, e = get(base .. "/" .. file)
			if not body then return "Error: could not load " .. file .. " (" .. tostring(e) .. ")." end
			txt = norm(body)
		else
			local body = s.src or pc(rf, fileOf(nm))
			if type(body) ~= "string" then return "Error: skill file is missing, reinstall it." end
			txt = gsub(norm(body), "^%-%-%-[ \t]*\n.-\n%-%-%-[ \t]*\n?", "", 1)
		end
		lastKey, lastTxt, lastNm = key, txt, nm
		local total = #txt
		from = from or 1
		if from > total then return "Error: startChar is past the end (" .. total .. " chars)." end
		local en = min(total, from + MAXB - 1)
		local head = (from > 1 or en < total) and ("(chars " .. from .. "-" .. en .. " of " .. total .. (en < total and (", use startChar=" .. (en + 1) .. " for more") or "") .. ")\n") or ""
		return head .. sub(txt, from, en)
	end

	st.skillRemove = function(nm)
		if not skills[nm] then return end
		skills[nm] = nil
		if dlf then pc(dlf, fileOf(nm)) end
		if lastNm == nm then lastKey, lastTxt, lastNm = nil, nil, nil end
		reorder()
		saveIdx()
		render()
	end

	st.skillInstall = function(u, cb)
		spawn(function()
			local tries, err = srcList(u), nil
			for i = 1, #tries do
				local src, at, e = get(tries[i])
				if src then
					if #src > MAXF then
						err = "file is too large (max " .. (MAXF // 1024) .. "KB)"
						break
					end
					src = norm(src)
					local nm, d = parse(src)
					if nm then
						local sk = { d = d, u = at }
						if wf then
							ensure()
							pc(wf, fileOf(nm), src)
						end
						if not pc(isf, fileOf(nm)) then sk.src = src end
						skills[nm] = sk
						if lastNm == nm then lastKey, lastTxt, lastNm = nil, nil, nil end
						reorder()
						saveIdx()
						render()
						cb(true, nm)
						return
					end
					err = d
				else
					err = err or (e .. " for " .. at)
				end
			end
			cb(false, err or "download failed")
		end)
	end

	local sGen, busy = 0, false
	local function setStatus(t, col, hold)
		sGen += 1
		local g = sGen
		status.Text, status.TextColor3, status.Visible = t, col or grayName, true
		if not hold then delay(5, function() if g == sGen then status.Visible = false end end) end
	end
	box.FocusLost:Connect(function(enter)
		if not enter or busy then return end
		local u = trim(box.Text)
		if u == "" then return end
		busy = true
		setStatus("Installing...", nil, true)
		st.skillInstall(u, function(ok, r)
			busy = false
			if ok then
				box.Text = ""
				setStatus("Installed '" .. r .. "'. Only install skills you trust.", green)
			else
				setStatus("Error: " .. r, errCol)
			end
		end)
	end)
	render()
end)()

local whiteSeqs, revSeqs = tCreate(24), tCreate(24)
;(function()
	for i = 1, 24 do
		local c = 1 - (1 - (i / 24)) ^ 3
		whiteSeqs[i] = cSeq(purple:Lerp(white, c), pink:Lerp(white, c))
		revSeqs[i] = cSeq(white:Lerp(purple, c), white:Lerp(pink, c))
	end
	tFreeze(whiteSeqs); tFreeze(revSeqs)

	local promptBox, sendButton, sendIcon, sendStroke, chatScroll = st.promptBox, st.sendButton, st.sendIcon, st.sendStroke, st.chatScroll
	st.textChangedConn = promptBox:GetPropertyChangedSignal("Text"):Connect(function()
		local has = #promptBox.Text > 0
		if has ~= st.showingSend then
			st.showingSend = has
			sendButton.Active, sendButton.Interactable = has, has
			tw(promptBox, twFast, { Size = u2(1, -(26 + st.effortW + st.plusW + (has and 38 or 0)), 0, 32) }):Play()
			tw(st.effortBtn, twFast, { Position = u2(1, has and -48 or -10, 1, -8) }):Play()
			tw(sendButton, twFast, { BackgroundTransparency = has and 0.06 or 1 }):Play()
			tw(sendIcon, twFast, { ImageTransparency = has and 0 or 1 }):Play()
			tw(sendStroke, twFast, { Transparency = has and 0 or 1 }):Play()
		end
	end)

	local tbParams = iNew("GetTextBoundsParams")
	tbParams.Name, tbParams.Font = rand(), interThin
	local tbNew, tbOld, tbCount = {}, {}, 0

	local gZero = tFreeze({ Position = u2o(0, 0) })
	local gVis = tFreeze({ TextTransparency = 0 })
	local gAvVis = tFreeze({ BackgroundTransparency = 0, ImageTransparency = 0 })
	local gBgVis = tFreeze({ BackgroundTransparency = 0 })
	local gStrVis = tFreeze({ Transparency = 0 })
	local gFrVis = tFreeze({ BackgroundTransparency = 0.05 })
	local gImgVis = tFreeze({ ImageTransparency = 0 })
	local gThVis = tFreeze({ BackgroundTransparency = 0.15 })
	local gTxtHid = tFreeze({ TextTransparency = 1 })
	local gBgHid = tFreeze({ BackgroundTransparency = 1 })
	local gImgHid = tFreeze({ ImageTransparency = 1 })
	local gStrHid = tFreeze({ Transparency = 1 })
	local gSink = tFreeze({ Position = u2o(0, 10) })

	local bubRad, rectSz = u1(0, 14), v2(52, 52)
	local avSz, avBg = u2o(28, 28), c3(0.14, 0.12, 0.18)
	local copyAsset, chkAsset, arrowAsset, resendAsset = decal(103287906385313), decal(9754130783), decal(11552476728), decal(93664478442668)
	local msgCount, chatGen = 0, 0

	local chatLayout, stick = st.chatLayout, true
	local function toBottom()
		chatScroll.CanvasPosition = v2(0, max(0, chatScroll.AbsoluteCanvasSize.Y - chatScroll.AbsoluteWindowSize.Y))
	end
	local function scrollBottom()
		stick = true
		toBottom()
	end
	chatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		chatScroll.CanvasSize = u2o(0, chatLayout.AbsoluteContentSize.Y + 12)
	end)
	chatScroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		if stick then toBottom() end
	end)
	chatScroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		if stick then toBottom() end
	end)
	chatScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		stick = chatScroll.CanvasPosition.Y >= chatScroll.AbsoluteCanvasSize.Y - chatScroll.AbsoluteWindowSize.Y - 24
	end)

	local function measureWidth(txt, isRich, maxW, fSz)
		local ck = (isRich and 1 or -1) * (fSz * 4096 + maxW)
		local bn = tbNew[ck]
		local w = bn and bn[txt]
		if w then return w end
		local bo = tbOld[ck]
		w = bo and bo[txt]
		if not w then
			tbParams.Text, tbParams.RichText, tbParams.Width, tbParams.Size = txt, isRich, maxW, fSz
			local ok, b = pcall(TextService.GetTextBoundsAsync, TextService, tbParams)
			w = (ok and b and b.X > 0) and ceil(b.X) or min(maxW, ceil(#txt * (fSz * 0.56)))
			if find(txt, "\n", 1, true) then w = max(w, min(maxW, 140)) end
		end
		if not bn then bn = {}; tbNew[ck] = bn end
		bn[txt] = w
		tbCount += 1
		if tbCount >= 256 then tbOld, tbNew, tbCount = tbNew, {}, 0 end
		return w
	end

	local function apply(t, g) for k, v in g do t[k] = v end end
	local function remVal(list, v)
		for i = #list, 1, -1 do if list[i] == v then tRemove(list, i); break end end
	end

	local function mkCopy(p, txt, pos, anc)
		local cBtn = iNew("TextButton")
		cBtn.Name, cBtn.AutoButtonColor, cBtn.BackgroundTransparency, cBtn.Size, cBtn.Text = rand(), false, 1, u2o(15, 15), ""
		if pos then cBtn.AnchorPoint, cBtn.Position = anc, pos end
		cBtn.Parent = p
		local cIc = icn(cBtn, copyAsset, 13)

		local ckBox = iNew("Frame")
		ckBox.Name, ckBox.BackgroundColor3, ckBox.BackgroundTransparency, ckBox.Size, ckBox.Parent = rand(), green, 1, u2s(1, 1), cBtn
		crn(ckBox, u1(0, 4))
		local cks = strk(ckBox, green, 1)
		local ckIc = icn(ckBox, chkAsset, 10, nil, white)
		ckIc.ImageTransparency = 1

		local h = { btn = cBtn, ic = cIc, busy = false, hid = false }
		cBtn.Activated:Connect(function()
			if setClip then pcall(setClip, txt) end
			if h.busy then return end
			h.busy = true
			tw(cIc, twFast, { ImageTransparency = 1 }):Play()
			tw(ckBox, twFast, { BackgroundTransparency = 0 }):Play()
			tw(cks, twFast, { Transparency = 0 }):Play()
			tw(ckIc, twFast, { ImageTransparency = 0 }):Play()
			delay(1.3, function()
				if ckBox.Parent then
					tw(ckBox, twFast, { BackgroundTransparency = 1 }):Play()
					tw(cks, twFast, { Transparency = 1 }):Play()
					tw(ckIc, twFast, { ImageTransparency = 1 }):Play()
					tw(cIc, twFast, { ImageTransparency = h.hid and 1 or 0 }):Play()
				end
				h.busy = false
			end)
		end)
		return h
	end

	local function addActs(ent, bf, msgTxt, isPlr)
		local acts = iNew("Frame")
		acts.Name, acts.BackgroundTransparency, acts.AnchorPoint, acts.Position, acts.Size, acts.Visible = rand(), 1, isPlr and v2(0, 1) or v2(1, 1), isPlr and u2(1, 6, 1, -2) or u2(0, -6, 1, -2), u2o(isPlr and 36 or 15, 15), false
		lst(acts, fdH, 6, isPlr and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
		local rsIc
		if isPlr then
			local rb = iNew("TextButton")
			rb.Name, rb.AutoButtonColor, rb.LayoutOrder, rb.BackgroundTransparency, rb.Size, rb.Text, rb.Parent = rand(), false, 1, 1, u2o(15, 15), "", acts
			rsIc = icn(rb, resendAsset, 13)
			rsIc.ImageTransparency = 1
			rb.Activated:Connect(function() if st.resend then st.resend(msgTxt) end end)
		end
		local cp = mkCopy(acts, msgTxt)
		cp.btn.LayoutOrder, cp.hid, cp.ic.ImageTransparency = 2, true, 1
		acts.Parent = bf
		local hov = false
		local function setHov(o)
			if o == hov then return end
			hov, cp.hid = o, not o
			if o then acts.Visible = true end
			local g = o and gImgVis or gImgHid
			if not cp.busy then tw(cp.ic, twFast, g):Play() end
			if rsIc then tw(rsIc, twFast, g):Play() end
			if not o then delay(0.2, function() if not hov then acts.Visible = false end end) end
		end
		ent.MouseEnter:Connect(function() setHov(true) end)
		ent.MouseLeave:Connect(function() setHov(false) end)
	end

	local function buildContent(bf, rawTxt, instant, note)
		local segs = parseSegments(rawTxt)
		local maxW = note and measureWidth(note, false, 200, 10) or 0
		for i = 1, #segs do
			local sg = segs[i]
			if sg.kind == "text" then
				local w = measureWidth(sg.rich, true, 200, 13)
				if w > maxW then maxW = w end
			else
				maxW = 204
			end
		end
		local bw = max(42, min(224, maxW + 20))
		bf.Size, bf.AutomaticSize = u2o(bw, 0), autoY

		local hld = iNew("Frame")
		hld.Name, hld.BackgroundTransparency, hld.Size, hld.AutomaticSize, hld.Parent = rand(), 1, u2(1, 0, 0, 0), autoY, bf
		pad(hld, 10, 10, 7, 7); lst(hld, nil, 6)
		if note then
			local nl2 = iNew("TextLabel")
			nl2.Name, nl2.AutoLocalize, nl2.LayoutOrder, nl2.BackgroundTransparency, nl2.Size, nl2.FontFace, nl2.Text, nl2.TextColor3, nl2.TextSize, nl2.TextTruncate, nl2.TextXAlignment, nl2.Parent = rand(), false, 0, 1, u2(1, 0, 0, 13), interThin, note, grayName, 10, trEnd, alL, hld
		end

		for i = 1, #segs do
			local sg = segs[i]
			if sg.kind == "text" then
				local lb = iNew("TextLabel")
				lb.Name, lb.AutoLocalize, lb.RichText, lb.LayoutOrder, lb.BackgroundTransparency, lb.Size, lb.AutomaticSize, lb.FontFace, lb.Text, lb.TextColor3, lb.TextSize, lb.TextWrapped, lb.TextXAlignment, lb.TextYAlignment, lb.Parent = rand(), false, true, i, 1, u2(1, 0, 0, 0), autoY, interThin, sg.rich, white, 13, true, alL, vaT, hld
				if not instant then
					local okL, uL = pcall(uLen, sg.plain)
					local tg = (okL and uL) or #sg.plain
					lb.MaxVisibleGraphemes = 0
					st.typewriters[#st.typewriters + 1] = { label = lb, current = 0, total = tg, speed = max(1, ceil(tg / 45)) }
				end
			else
				local mdl = iNew("Frame")
				mdl.Name, mdl.LayoutOrder, mdl.BackgroundColor3, mdl.BorderSizePixel, mdl.Size, mdl.AutomaticSize, mdl.Parent = rand(), i, darkBox, 0, u2(1, 0, 0, 0), autoY, hld
				crn(mdl, cardRad); strk(mdl); lst(mdl, nil, 0)

				local hdr = iNew("Frame")
				hdr.Name, hdr.LayoutOrder, hdr.BackgroundColor3, hdr.BorderSizePixel, hdr.Size, hdr.Parent = rand(), 1, inputBg, 0, u2(1, 0, 0, 22), mdl
				crn(hdr, cardRad)
				local hDv = iNew("Frame")
				hDv.Name, hDv.BackgroundColor3, hDv.BorderSizePixel, hDv.Position, hDv.Size, hDv.Parent = rand(), bubbleStroke, 0, u2(0, 0, 1, -1), u2(1, 0, 0, 1), hdr
				lbl(hdr, sg.lang, 10, grayName, u2o(8, 0), u2(1, -30, 1, 0))

				mkCopy(hdr, sg.code, u2(1, -5, 0.5, 0), rAnc)

				local cWrap = iNew("Frame")
				cWrap.Name, cWrap.LayoutOrder, cWrap.BackgroundTransparency, cWrap.Size, cWrap.AutomaticSize, cWrap.Parent = rand(), 2, 1, u2(1, 0, 0, 0), autoY, mdl
				pad(cWrap, 8, 8, 6, 7)

				local cLb = iNew("TextLabel")
				cLb.Name, cLb.AutoLocalize, cLb.RichText, cLb.BackgroundTransparency, cLb.Size, cLb.AutomaticSize, cLb.FontFace, cLb.Text, cLb.TextColor3, cLb.TextSize, cLb.TextWrapped, cLb.TextXAlignment, cLb.TextYAlignment, cLb.Parent = rand(), false, false, 1, u2(1, 0, 0, 0), autoY, interThin, sg.code, c3(0.86, 0.82, 1.00), 11, true, alL, vaT, cWrap
				if not instant then
					local okL, uL = pcall(uLen, sg.code)
					local tg = (okL and uL) or #sg.code
					cLb.MaxVisibleGraphemes = 0
					st.typewriters[#st.typewriters + 1] = { label = cLb, current = 0, total = tg, speed = max(1, ceil(tg / 45)) }
				end
			end
		end
	end

	local function createBase(titleTxt, isPlr, avId, prov, bw, bh)
		msgCount += 1
		local ent = iNew("Frame")
		ent.Name, ent.LayoutOrder, ent.BackgroundTransparency, ent.Size, ent.AutomaticSize = rand(), msgCount, 1, u2(1, 0, 0, 0), autoY
		local anm = iNew("Frame")
		anm.Name, anm.BackgroundTransparency, anm.Position, anm.Size, anm.AutomaticSize = rand(), 1, u2o(0, 14), u2(1, 0, 0, 0), autoY
		lst(anm, nil, 3)

		local nl = lbl(anm, titleTxt, 11, grayName, u2o(0, 0), u2(1, -4, 0, 14), isPlr and alL or alR)
		nl.LayoutOrder, nl.TextTransparency = 1, 1

		local row = iNew("Frame")
		row.Name, row.LayoutOrder, row.BackgroundTransparency, row.Size, row.AutomaticSize, row.Parent = rand(), 3, 1, u2(1, 0, 0, 0), autoY, anm

		local av, avIc
		if isPlr then
			av = iNew("ImageLabel")
			av.Name, av.BackgroundColor3, av.BackgroundTransparency, av.Position, av.Size, av.Image, av.ImageTransparency = rand(), avBg, 1, u2o(0, 0), avSz, avId, 1
		else
			local pr = prov or cfg.provider
			av = iNew("Frame")
			av.Name, av.BackgroundColor3, av.BackgroundTransparency, av.BorderSizePixel, av.AnchorPoint, av.Position, av.Size = rand(), avBg, 1, 0, v2(1, 0), u2(1, 0, 0, 0), avSz
			avIc = icn(av, provIcons[pr] or "", 16, nil, white)
			avIc.ImageTransparency = 1
			st.aiAvIcons[#st.aiAvIcons + 1] = { provider = pr, icon = avIc }
		end
		crn(av, circRad)
		local as = strk(av, bubbleStroke, 1)
		av.Parent = row

		local bf = iNew("Frame")
		bf.Name, bf.BackgroundColor3, bf.BackgroundTransparency, bf.BorderSizePixel, bf.Size = rand(), bubbleBg, 1, 0, u2o(bw, bh)
		if isPlr then bf.Position = u2o(34, 0) else bf.AnchorPoint, bf.Position = v2(1, 0), u2(1, -34, 0, 0) end
		crn(bf, bubRad)
		local bs = strk(bf, bubbleStroke, 1)
		bf.Parent = row; anm.Parent = ent; ent.Parent = chatScroll
		scrollBottom()

		return ent, anm, nl, av, avIc, as, bf, bs
	end

	local thW, rowH = 200, 14
	local function escR(t) return (gsub(gsub(gsub(t, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")) end
	local function thoughtTitle(n) return "Thought process · " .. n .. (n == 1 and " tool" or " tools") end
	local function isErrRes(r) return sub(r, 1, 6) == "Error:" or sub(r, 1, 14) == "Runtime error:" or r == "you cannot use this on a server script." end

	local function mkThought(anm, instant)
		local wrap = iNew("Frame")
		wrap.Name, wrap.LayoutOrder, wrap.BackgroundTransparency, wrap.Size = rand(), 2, 1, u2(1, 0, 0, 24)
		local box = iNew("Frame")
		box.Name, box.AnchorPoint, box.Position, box.Size, box.BackgroundColor3, box.BackgroundTransparency, box.BorderSizePixel, box.ClipsDescendants = rand(), v2(1, 0), u2(1, -34, 0, 1), u2o(thW, 22), darkBox, 1, 0, true
		crn(box, cardRad)
		local bst = strk(box, bubbleStroke, 1)
		local hb = iNew("TextButton")
		hb.Name, hb.AutoLocalize, hb.AutoButtonColor, hb.BackgroundColor3, hb.BackgroundTransparency, hb.BorderSizePixel, hb.Size, hb.Text, hb.Parent = rand(), false, false, hoverBg, 1, 0, u2(1, 0, 0, 22), "", box
		crn(hb, cardRad)
		local ttl = lbl(hb, "Thinking...", 10, grayName, u2o(9, 0), u2(1, -30, 1, 0))
		local arr = icn(hb, arrowAsset, 10)
		arr.AnchorPoint, arr.Position = rAnc, u2(1, -8, 0.5, 0)
		local list = iNew("Frame")
		list.Name, list.BackgroundTransparency, list.Position, list.Size, list.Visible, list.Parent = rand(), 1, u2o(0, 22), u2(1, 0, 0, 8), false, box
		div(list, 0)
		bindFeedback(hb, hoverBg, hoverBg, 1, 0.4, true)
		box.Parent = wrap; wrap.Parent = anm

		if instant then
			box.BackgroundTransparency, bst.Transparency = 0.15, 0
		else
			ttl.TextTransparency, arr.ImageTransparency = 1, 1
			tw(box, twMid, gThVis):Play(); tw(bst, twMid, gStrVis):Play(); tw(ttl, twMid, gVis):Play(); tw(arr, twMid, gImgVis):Play()
		end

		local open, n, rows, sizeTw = false, 0, {}, nil
		local function resize(anim)
			local h = 22 + (open and (n * rowH + 8) or 0)
			if sizeTw then sizeTw:Cancel(); sizeTw = nil end
			if anim then
				sizeTw = tw(box, twMid, { Size = u2o(thW, h) })
				sizeTw:Play()
				tw(wrap, twMid, { Size = u2(1, 0, 0, h + 2) }):Play()
			else
				box.Size, wrap.Size = u2o(thW, h), u2(1, 0, 0, h + 2)
			end
			return sizeTw
		end
		hb.Activated:Connect(function()
			stick = false
			open = not open
			if open then list.Visible = true end
			local t = resize(true)
			t.Completed:Once(function(ps) if ps == pbDone and not open then list.Visible = false end end)
			tw(arr, twMid, { Rotation = open and 180 or 0, ImageColor3 = open and white or iconIdle }):Play()
		end)

		local function set(i, err)
			local e = rows[i]
			if not e then return end
			e[1].Text = '<font color="' .. (err == true and "#ff6b78" or (err == false and "#d8bfff" or "#a8a3b3")) .. '">' .. escR(e[2]) .. "</font>  " .. escR(e[3])
		end
		local function add(nm, a, err)
			n += 1
			local r = iNew("TextLabel")
			r.Name, r.AutoLocalize, r.RichText, r.BackgroundTransparency, r.Position, r.Size, r.FontFace, r.TextColor3, r.TextSize, r.TextTruncate, r.TextXAlignment, r.TextYAlignment = rand(), false, true, 1, u2o(9, 4 + (n - 1) * rowH), u2(1, -18, 0, rowH), interThin, grayName, 10, trEnd, alL, vaC
			rows[n] = { r, nm, a or "" }
			set(n, err)
			r.Parent = list
			list.Size = u2(1, 0, 0, n * rowH + 8)
			if open then resize(true) end
			return n
		end
		return { add = add, set = set, title = function(t) ttl.Text = t end }
	end

	local function createThinking(provName, mdlName, instant)
		local pr = provName or cfg.provider
		local md = mdlName or cfg.models[pr] or defModels[pr] or pr
		local ent, anm, nl, av, avIc, as, bf, bs = createBase("AI (" .. md .. "):", false, "", pr, 90, 28)

		local body = iNew("Frame")
		body.Name, body.BackgroundTransparency, body.BorderSizePixel, body.Size = rand(), 1, 0, u2s(1, 1)

		local dots = iNew("ImageLabel")
		dots.Name, dots.BackgroundTransparency, dots.BorderSizePixel, dots.AnchorPoint, dots.Position, dots.Size, dots.ScaleType, dots.ResampleMode, dots.ImageRectSize, dots.ImageRectOffset, dots.ImageColor3, dots.ImageTransparency = rand(), 1, 0, lAnc, u2(0, 10, 0.5, 0), u2o(13, 13), Enum.ScaleType.Stretch, Enum.ResamplerMode.Pixelated, rectSz, st.offsets[1], white, 1
		if st.loaderReady and st.loaderAsset ~= "" then applyLoaderUri(dots, st.loaderAsset) end
		local tgD = iNew("UIGradient")
		tgD.Name, tgD.Color, tgD.Parent = rand(), st.introSeq, dots
		dots.Parent = body
		st.thinkLabels[#st.thinkLabels + 1] = dots

		local thinkLbl = lbl(body, "Thinking...", 12, white, u2o(28, 0), u2(1, -36, 1, 0))
		thinkLbl.TextTransparency = 1
		local tgL = iNew("UIGradient")
		tgL.Name, tgL.Color, tgL.Parent = rand(), st.introSeq, thinkLbl
		st.thinkGrads[#st.thinkGrads + 1] = tgL
		st.thinkGrads[#st.thinkGrads + 1] = tgD
		body.Parent = bf

		if instant then
			apply(anm, gZero); apply(nl, gVis); apply(av, gBgVis); apply(avIc, gImgVis); apply(as, gStrVis); apply(bf, gFrVis); apply(bs, gStrVis); apply(dots, gImgVis); apply(thinkLbl, gVis)
		else
			tw(anm, twMid, gZero):Play(); tw(nl, twMid, gVis):Play(); tw(av, twMid, gBgVis):Play(); tw(avIc, twMid, gImgVis):Play(); tw(as, twMid, gStrVis):Play(); tw(bf, twMid, gFrVis):Play(); tw(bs, twMid, gStrVis):Play(); tw(dots, twMid, gImgVis):Play(); tw(thinkLbl, twMid, gVis):Play()
		end

		local th, cnt = nil, 0
		local function clean()
			remVal(st.thinkLabels, dots); remVal(st.thinkGrads, tgL); remVal(st.thinkGrads, tgD)
		end
		return {
			alive = function() return ent.Parent ~= nil end,
			step = function(nm, a)
				if not ent.Parent then return 0 end
				if not th then th = mkThought(anm, false) end
				cnt += 1
				th.title("Using " .. nm .. "...")
				return th.add(nm, a, nil)
			end,
			stepDone = function(i, err)
				if th and ent.Parent then th.set(i, err) end
			end,
			resolve = function(respTxt, isInst)
				if not ent.Parent then return end
				clean()
				body:Destroy()
				if th then th.title(thoughtTitle(cnt)) end
				buildContent(bf, respTxt, isInst)
				addActs(ent, bf, respTxt, false)
			end,
			destroy = function()
				clean()
				if not ent.Parent then return end
				local t = tw(anm, twFast, gSink)
				t.Completed:Once(function() if ent.Parent then ent:Destroy() end end)
				t:Play()
				tw(nl, twFast, gTxtHid):Play(); tw(av, twFast, gBgHid):Play(); tw(avIc, twFast, gImgHid):Play(); tw(as, twFast, gStrHid):Play(); tw(bf, twFast, gBgHid):Play(); tw(bs, twFast, gStrHid):Play(); tw(dots, twFast, gImgHid):Play(); tw(thinkLbl, twFast, gTxtHid):Play()
			end
		}
	end

	local function createMsgBubble(titleTxt, avId, msgTxt, isPlr, instant, provName, thought, imgName)
		local ent, anm, nl, av, avIc, as, bf, bs = createBase(titleTxt, isPlr, avId, provName, 90, 0)
		if not isPlr and type(thought) == "table" and #thought > 0 then
			local th = mkThought(anm, instant)
			for i = 1, #thought do local e = thought[i]; th.add(e.n, e.a, e.e) end
			th.title(thoughtTitle(#thought))
		end
		buildContent(bf, msgTxt, true, imgName and ("Image: " .. imgName) or nil)
		addActs(ent, bf, msgTxt, isPlr)
		if instant then
			apply(anm, gZero); apply(nl, gVis); apply(as, gStrVis); apply(bf, gFrVis); apply(bs, gStrVis)
			if isPlr then apply(av, gAvVis) else apply(av, gBgVis); apply(avIc, gImgVis) end
		else
			tw(anm, twMid, gZero):Play(); tw(nl, twMid, gVis):Play(); tw(as, twMid, gStrVis):Play(); tw(bf, twMid, gFrVis):Play(); tw(bs, twMid, gStrVis):Play()
			if isPlr then tw(av, twMid, gAvVis):Play() else tw(av, twMid, gBgVis):Play(); tw(avIc, twMid, gImgVis):Play() end
		end
	end

	local pending = {}
	local curChat, actChat, cCount = nil, nil, 0
	local sysPrompt = "You are Bloxy, an expert Roblox Luau and UI scripter. Be concise and accurate."
	local toolSys = sysPrompt .. toolPrompt

	local doneSfx = iNew("Sound")
	doneSfx.Name, doneSfx.SoundId, doneSfx.Parent = rand(), "rbxassetid://98797174600699", screenGui
	local SoundService = game:GetService("SoundService")
	local function setDot(chat, on)
		local dot = chat.dot
		if not dot or on == (chat.unread == true) then return end
		chat.unread = on
		chat.rowPad.PaddingRight = u1(0, on and 20 or 8)
		dot.Position = u2(1, on and 14 or 2, 0.5, 0)
		if on then
			dot.Size, dot.Visible = u2o(0, 0), true
			tw(dot, twMid, { Size = u2o(7, 7) }):Play()
		else
			local t = tw(dot, twFast, { Size = u2o(0, 0) })
			t.Completed:Once(function(ps) if ps == pbDone and not chat.unread then dot.Visible = false end end)
			t:Play()
		end
	end

	local function sendAiReq(chat, uMsg, tHandle)
		local prov = cfg.provider
		local key = match(cfg.apiKeys[prov] or "", "^%s*(.-)%s*$") or ""
		local mdl = match(cfg.models[prov] or "", "^%s*(.-)%s*$") or ""
		if mdl == "" then mdl = defModels[prov] or "gpt-4o-mini" end
		local cUrl = match(cfg.customUrl or "", "^%s*(.-)%s*$") or ""

		local job = { h = tHandle, prov = prov, mdl = mdl, thought = {} }
		chat.job = job
		local function viewing() return curChat == chat and st.phase == 2 end
		local effort = st.getEffort and st.getEffort() or nil
		local function retry()
			if not viewing() then return end
			sendAiReq(chat, uMsg, createThinking(prov, mdl, false))
		end
		local function fail(isWarn, titleTxt, descTxt)
			job.h.destroy()
			if chat.job == job then chat.job = nil end
			if viewing() then showError(isWarn, titleTxt, descTxt, retry) else chat.pendErr = { isWarn, titleTxt, descTxt, retry } end
		end

		if prov ~= "Custom" and key == "" then
			fail(true, "Warning — Missing API Key", "No API Key set for " .. prov .. ". Open Settings in the menu and enter your " .. prov .. " API Key.")
			return
		end
		if prov == "Custom" and cUrl == "" then
			fail(true, "Warning — Missing Endpoint URL", "No Endpoint URL set for Custom provider. Open Settings and enter a valid URL.")
			return
		end

		spawn(function()
			local msgs = chat.messages
			if uMsg and uMsg.ctx == nil then
				local okC, ctx = pcall(mentionCtx, uMsg.text or "")
				uMsg.ctx = (okC and ctx) or false
			end
			local steps, thought = {}, job.thought
			local useTools = true
			local ex = match(cfg.sysExtra or "", "^%s*(.-)%s*$") or ""
			ex = ex ~= "" and ("\n\nUser instructions:\n" .. ex) or ""
			local sysT, sysP = toolSys .. (st.skillsPrompt and st.skillsPrompt() or "") .. ex, sysPrompt .. ex
			while true do
				local url, hdrs, bodyTbl = toolBuild(prov, key, mdl, cUrl, msgs, steps, useTools and sysT or sysP, useTools, false, effort)
				local okE, jBody = pcall(jsonEnc, bodyTbl)
				if not okE then
					fail(false, "Error — Request Encoding", "Failed to serialize request payload.")
					return
				end

				local code, rBody = doHttp({ Url = url, Method = "POST", Headers = hdrs, Body = jBody })

				if code ~= 200 and code >= 400 and code < 500 and uMsg and uMsg.images and type(rBody) == "string" and find(lower(rBody), "image", 1, true) then
					fail(false, "Error " .. code .. " — Image Not Supported", "'" .. mdl .. "' could not read the image. Pick a vision model in Settings or remove the image.")
					return
				end

				if code ~= 200 and effort and code >= 400 and code < 500 and code ~= 401 and code ~= 403 and code ~= 429 and type(rBody) == "string" then
					local lb = lower(rBody)
					if find(lb, "reason", 1, true) or find(lb, "effort", 1, true) or find(lb, "thinking", 1, true) or find(lb, "budget", 1, true) or find(lb, "output_config", 1, true) then
						effort = nil
						continue
					end
				end

				if code ~= 200 and useTools and #steps == 0 and code >= 400 and code < 500 and code ~= 401 and code ~= 403 and code ~= 404 and code ~= 429 and type(rBody) == "string" and (find(lower(rBody), "tool", 1, true) or find(lower(rBody), "function", 1, true)) then
					useTools = false
					continue
				end

				if code == 200 then
					local okD, parsed = pcall(HttpService.JSONDecode, HttpService, rBody)
					local reply, calls, raw = toolParse(prov, okD and parsed or nil)
					if useTools and type(calls) == "table" and #calls > 0 then
						local results = tCreate(#calls)
						for i = 1, #calls do
							local c = calls[i]
							local nm = tostring(c.name)
							local entry = { n = nm, a = argSummary(c.args) }
							thought[#thought + 1] = entry
							local idx = job.h.step(nm, entry.a)
							local r = runTool(nm, c.args)
							entry.e = isErrRes(r)
							job.h.stepDone(idx, entry.e)
							results[i] = r
						end
						steps[#steps + 1] = { calls = calls, raw = raw, text = reply, results = results }
					else
						if (type(reply) ~= "string" or not match(reply, "%S")) and #thought > 0 then
							reply = "Done."
						end
						if type(reply) == "string" and reply ~= "" then
							reply = match(reply, "^%s*(.-)%s*$") or reply
							local th = #thought > 0 and thought or nil
							chat.messages[#chat.messages + 1] = { role = "assistant", text = reply, provider = prov, model = mdl, tools = th }
							if uMsg then uMsg.images = nil end
							saveChats(st.chats)
							if chat.job == job then chat.job = nil end
							if job.h.alive() then
								job.h.resolve(reply, false)
							elseif viewing() then
								createMsgBubble("AI (" .. mdl .. "):", "", reply, false, false, prov, th)
							end
							if curChat ~= chat then
								setDot(chat, true)
								if not pcall(SoundService.PlayLocalSound, SoundService, doneSfx) then pcall(doneSfx.Play, doneSfx) end
							end
						else
							fail(true, "Warning — Empty Response", prov .. " returned an empty response format. Check your model or endpoint.")
						end
						return
					end
				else
					if code == 401 then
						fail(false, "Error 401 — Unauthorized", "Your " .. prov .. " API key is invalid or expired. Open Settings and enter a valid API key.")
					elseif code == 403 then
						fail(false, "Error 403 — Forbidden", "Access denied for '" .. mdl .. "'. Check your API key permissions, billing quota, or switch providers.")
					elseif code == 404 then
						fail(false, "Error 404 — Not Found", "Model '" .. mdl .. "' or endpoint was not found on " .. prov .. ". Check the AI Model in Settings.")
					elseif code == 429 then
						fail(true, "Warning 429 — Rate Limited", "Too many requests sent to " .. prov .. ". Wait a few seconds and click Retry.")
					elseif code == 0 then
						fail(false, "Connection Error", "Could not reach " .. prov .. ". Check your internet connection or Custom URL in Settings.")
					else
						fail(false, "Error " .. tostring(code) .. " — Request Failed", prov .. " rejected the request (HTTP " .. tostring(code) .. "). Verify your model and API key in Settings.")
					end
					return
				end
			end
		end)
	end

	local function mkTitle(txt)
		txt = match(gsub(txt, "%s+", " "), "^ ?(.-) ?$") or ""
		local okL, l = pcall(uLen, txt)
		if okL and l and l > 40 then
			local okO, cut = pcall(uOff, txt, 41)
			if okO and cut then txt = sub(txt, 1, cut - 1) .. "..." end
		elseif #txt > 40 then
			txt = sub(txt, 1, 40) .. "..."
		end
		return txt
	end

	local function setActChat(chat)
		if chat == actChat then return end
		if actChat and actChat.setIdle then actChat.setIdle(darkBox) end
		actChat = chat
		if chat and chat.setIdle then chat.setIdle(selChatBg) end
	end

	local function clearMsgs()
		chatGen += 1
		tClear(pending); tClear(st.thinkLabels); tClear(st.thinkGrads); tClear(st.aiAvIcons); tClear(st.typewriters)
		local ch = chatScroll:GetChildren()
		for i = 1, #ch do if ch[i]:IsA("Frame") then ch[i]:Destroy() end end
		msgCount = 0
		stick = true
		chatScroll.CanvasPosition = v2(0, 0)
	end

	local bloxyLabel, textContainer, helloLabel, exclaimLabel, bloxySpacer = st.bloxyLabel, st.textContainer, st.helloLabel, st.exclaimLabel, st.bloxySpacer
	local tHome, tTop = u2(0.5, 0, 0.42, 0), u2(0.5, 0, 0, 16)
	local gOut, gIn = tFreeze({ TextTransparency = 1 }), tFreeze({ TextTransparency = 0 })
	local moveOut = tw(bloxyLabel, twMid, { Position = tTop, TextSize = 15 })
	local moveIn

	local function renderList(chat, list, isInst)
		local gen = chatGen
		local cProv = (chat and chat.provider) or cfg.provider
		for i = 1, #list do
			if gen ~= chatGen then return end
			local m = list[i]
			if m then
				if m.role == "assistant" then
					local mp = m.provider or cProv
					local mm = m.model or cfg.models[mp] or defModels[mp] or mp
					createMsgBubble("AI (" .. mm .. "):", "", m.text, false, isInst, mp, m.tools)
				else
					createMsgBubble(pName, pThumb, m.text, true, isInst, nil, nil, m.img)
					if not isInst and m.needsReply then
						m.needsReply = nil
						local mp = cfg.provider
						local mm = cfg.models[mp] or defModels[mp] or mp
						sendAiReq(chat, m, createThinking(mp, mm, false))
					end
				end
			end
		end
	end

	local function resume(chat)
		if not chat then return end
		setDot(chat, false)
		local job = chat.job
		if job and not job.h.alive() then
			local h = createThinking(job.prov, job.mdl, false)
			local th = job.thought
			for i = 1, #th do
				local e = th[i]
				local idx = h.step(e.n, e.a)
				if e.e ~= nil then h.stepDone(idx, e.e) end
			end
			job.h = h
		end
		local pe = chat.pendErr
		if pe then
			chat.pendErr = nil
			showError(pe[1], pe[2], pe[3], pe[4])
		end
	end

	moveOut.Completed:Connect(function(s)
		if s ~= pbDone or st.phase ~= 1 then return end
		st.phase = 2
		textContainer.Visible, chatScroll.Visible = false, true
		renderList(curChat, pending, false)
		tClear(pending)
		resume(curChat)
	end)

	local function onInDone(s)
		if s ~= pbDone or st.phase ~= 3 then return end
		bloxyLabel.AnchorPoint, bloxyLabel.Position, bloxyLabel.Parent = v2(0, 0), u2o(0, 0), textContainer
		bloxySpacer.Visible = false
		st.bloxyGradient.Color = st.introSeq
		st.cycleStep, st.phase = (clock() * 60) // 1, 0
	end

	local function playOut()
		st.phase, st.fadeStep = 1, (clock() * 60) // 1
		local mp, ms, bp, bs = mainFrame.AbsolutePosition, mainFrame.AbsoluteSize, bloxyLabel.AbsolutePosition, bloxyLabel.AbsoluteSize
		local home = u2(0.5, (bp.X + bs.X * 0.5) - (mp.X + ms.X * 0.5), 0.42, (bp.Y + bs.Y * 0.5) - (mp.Y + ms.Y * 0.42))
		if home ~= tHome or not moveIn then
			tHome = home
			if moveIn then moveIn:Destroy() end
			moveIn = tw(bloxyLabel, twMid, { Position = home, TextSize = 22 })
			moveIn.Completed:Connect(onInDone)
		end
		bloxySpacer.Size, bloxySpacer.Visible = u2o(bs.X, bs.Y), true
		bloxyLabel.AnchorPoint, bloxyLabel.Position, bloxyLabel.Parent = cAnc, home, mainFrame
		tw(helloLabel, twFast, gOut):Play(); tw(exclaimLabel, twFast, gOut):Play(); moveOut:Play()
	end

	local function playIn()
		if st.phase ~= 2 or not moveIn then return end
		st.phase, st.fadeStep = 3, (clock() * 60) // 1
		chatScroll.Visible = false
		st.exclaimGradient.Color = st.introSeq
		textContainer.Visible = true
		tw(helloLabel, twMid, gIn):Play(); tw(exclaimLabel, twMid, gIn):Play(); moveIn:Play()
	end

	local function openChat(chat)
		setDrawerOpen(false)
		if chat == curChat or st.phase == 1 or st.phase == 3 then return end
		clearMsgs(); curChat = chat; setActChat(chat)
		local ms = chat.messages
		if st.phase == 0 then
			for i = 1, #ms do pending[i] = ms[i] end
			playOut()
		else
			renderList(chat, ms, true)
			resume(chat)
		end
	end

	local function addChatRow(titleTxt, initMsgs, provName, anim)
		cCount += 1
		local chat = { title = titleTxt, provider = provName or cfg.provider, messages = initMsgs or {} }
		st.chats[#st.chats + 1] = chat
		local row = iNew("TextButton")
		row.Name, row.AutoLocalize, row.AutoButtonColor, row.BackgroundColor3, row.BorderSizePixel, row.LayoutOrder, row.Size, row.FontFace, row.Text, row.TextColor3, row.TextSize, row.TextTruncate, row.TextXAlignment = rand(), false, false, darkBox, 0, -cCount, u2(1, 0, 0, 24), interThin, titleTxt, white, 12, trEnd, alL
		crn(row, itemRad); pad(row, 8, 8)
		chat.rowPad = row:FindFirstChildOfClass("UIPadding")
		local dot = iNew("Frame")
		dot.Name, dot.AnchorPoint, dot.Position, dot.Size, dot.BackgroundColor3, dot.BorderSizePixel, dot.Visible = rand(), rAnc, u2(1, 2, 0.5, 0), u2o(0, 0), purple, 0, false
		crn(dot, circRad)
		dot.Parent = row
		chat.dot = dot
		chat.setIdle = bindFeedback(row, darkBox, hoverBg, 0, 0)
		row.Activated:Connect(function() openChat(chat) end)
		if anim then
			row.BackgroundTransparency, row.TextTransparency = 1, 1
			tw(row, twMid, gBgVis):Play()
			tw(row, twMid, gVis):Play()
		end
		row.Parent = st.chatList
		st.noChatsLabel.Visible = false
		return chat
	end

	do
		local saved = loadChats()
		if saved and type(saved) == "table" and #saved > 0 then
			for i = 1, #saved do
				local e = saved[i]
				if type(e) == "table" and type(e.title) == "string" and type(e.messages) == "table" then
					local ml = tCreate(#e.messages)
					for j = 1, #e.messages do
						local rm = e.messages[j]
						if type(rm) == "table" then
							local tl, tools = rm.tools, nil
							if type(tl) == "table" then
								tools = {}
								for _, te in tl do
									if type(te) == "table" and type(te.n) == "string" then tools[#tools + 1] = { n = te.n, a = type(te.a) == "string" and te.a or "", e = te.e == true } end
								end
								if #tools == 0 then tools = nil end
							elseif type(tl) == "string" and tl ~= "" then
								tools = {}
								for nm in string.gmatch(tl, "[^,%s]+") do tools[#tools + 1] = { n = nm, a = "" } end
							end
							ml[j] = { role = type(rm.role) == "string" and rm.role or "user", text = tostring(rm.text or ""), provider = type(rm.provider) == "string" and rm.provider or nil, model = type(rm.model) == "string" and rm.model or nil, tools = tools, img = type(rm.img) == "string" and rm.img or nil }
						else
							ml[j] = { role = "user", text = tostring(rm) }
						end
					end
					addChatRow(e.title, ml, type(e.provider) == "string" and e.provider or nil)
				end
			end
		end
	end

	local function recPrompt(txt, att)
		local chat = curChat
		if not chat then
			chat = addChatRow(mkTitle(txt), nil, cfg.provider, true)
			curChat = chat; setActChat(chat)
		else
			chat.provider = cfg.provider
		end
		local m = { role = "user", text = txt, needsReply = true }
		if att then m.images, m.img = { att }, att.name end
		chat.messages[#chat.messages + 1] = m
		saveChats(st.chats)
		return chat, m
	end

	st.newChatButton.Activated:Connect(function()
		setDrawerOpen(false)
		if curChat and st.phase == 2 then
			clearMsgs(); curChat = nil; setActChat(nil); playIn()
		end
	end)

	local function submit(ov)
		ov = type(ov) == "string" and ov or nil
		local raw = ov or promptBox.Text
		local att = not ov and st.attach or nil
		if st.phase == 3 or (not match(raw, "%S") and not att) then return end
		if not match(raw, "%S") then raw = "Describe this image." end
		if not ov then promptBox.Text = "" end
		if att then
			st.attach = nil
			if st.onAttach then st.onAttach() end
		end
		local chat, m = recPrompt(raw, att)
		if st.phase == 2 then
			m.needsReply = nil
			createMsgBubble(pName, pThumb, raw, true, nil, nil, nil, m.img)
			local pr = cfg.provider
			local md = cfg.models[pr] or defModels[pr] or pr
			sendAiReq(chat, m, createThinking(pr, md, false))
		else
			pending[#pending + 1] = m
			if st.phase ~= 1 then playOut() end
		end
	end

	local function popTo(frame, stroke, w, h, show)
		if show then
			if not frame.Visible then frame.Size, stroke.Transparency, frame.Visible = u2o(w, 0), 1, true end
			tw(frame, twMid, { Size = u2o(w, h) }):Play()
			tw(stroke, twFast, gStrVis):Play()
		elseif frame.Visible then
			local t = tw(frame, twFast, { Size = u2o(w, 0) })
			t.Completed:Once(function(ps) if ps == pbDone then frame.Visible = false end end)
			t:Play()
			tw(stroke, twFast, gStrHid):Play()
		end
	end

	do
		local sugFrame = iNew("Frame")
		sugFrame.Name, sugFrame.Active, sugFrame.AnchorPoint, sugFrame.Position, sugFrame.Size, sugFrame.BackgroundColor3, sugFrame.BorderSizePixel, sugFrame.ClipsDescendants, sugFrame.Visible, sugFrame.ZIndex = rand(), true, v2(0, 1), u2(0, 10 + st.plusW, 1, -44), u2o(210, 0), darkBox, 0, true, false, 4
		crn(sugFrame, cardRad); pad(sugFrame, 4, 4, 4, 4); lst(sugFrame, nil, 2)
		local sugStroke = strk(sugFrame)
		sugFrame.Parent = mainFrame
		st.sugFrame = sugFrame
		local sugBtns, sugData, sugCtx, sugGen, sugShown = tCreate(6), {}, nil, 0, false
		local function hideSug()
			sugCtx = nil
			if sugShown then
				sugShown = false
				popTo(sugFrame, sugStroke, 210, 0, false)
			end
		end
		local function applySug(i)
			local d, cx = sugData[i], sugCtx
			if not d or not cx or promptBox.Text ~= cx.text then hideSug() return end
			local t = cx.text
			hideSug()
			promptBox.Text = sub(t, 1, cx.at) .. d[2] .. sub(t, cx.cur)
			promptBox:CaptureFocus()
			promptBox.CursorPosition = cx.at + #d[2] + 1
		end
		for i = 1, 6 do
			local b = iNew("TextButton")
			b.Name, b.AutoLocalize, b.AutoButtonColor, b.LayoutOrder, b.BackgroundColor3, b.BackgroundTransparency, b.BorderSizePixel, b.Size, b.FontFace, b.Text, b.TextColor3, b.TextSize, b.TextTruncate, b.TextXAlignment, b.Visible = rand(), false, false, i, darkBox, 1, 0, u2(1, 0, 0, 18), interThin, "", white, 11, trEnd, alL, false
			crn(b, itemRad); pad(b, 6, 6)
			bindFeedback(b, darkBox, hoverBg, 1, 0, true)
			b.Activated:Connect(function() applySug(i) end)
			b.Parent = sugFrame
			sugBtns[i] = b
		end
		local function updSug()
			local t = promptBox.Text
			local cur = promptBox.CursorPosition
			if cur < 1 or cur > #t + 1 then cur = #t + 1 end
			local pre = sub(t, 1, cur - 1)
			local at, tok = match(pre, "()@([^%s@]*)$")
			if not at or (at > 1 and not match(sub(pre, at - 1, at - 1), "[%s%(%[,]")) or #tok > 160 then hideSug() return end
			local okS, list = pcall(mentionSuggest, tok)
			if not okS or type(list) ~= "table" then hideSug() return end
			local n = 0
			for i = 1, #list do
				local d = list[i]
				if d[2] ~= tok and n < 6 then n += 1; sugData[n] = d end
			end
			if n == 0 then hideSug() return end
			for i = 1, 6 do
				local b = sugBtns[i]
				if i <= n then b.Text, b.Visible = sugData[i][1], true else b.Visible = false; sugData[i] = nil end
			end
			sugCtx = { text = t, at = at, cur = cur }
			sugShown = true
			popTo(sugFrame, sugStroke, 210, n * 20 + 6, true)
		end
		st.sugConn = promptBox:GetPropertyChangedSignal("Text"):Connect(function()
			sugGen += 1
			if not find(promptBox.Text, "@", 1, true) then
				hideSug()
				return
			end
			local g = sugGen
			delay(0.08, function() if g == sugGen and promptBox:IsFocused() then updSug() end end)
		end)
		st.sugFocusConn = promptBox.FocusLost:Connect(function()
			local g = sugGen
			delay(0.35, function() if g == sugGen and not promptBox:IsFocused() then hideSug() end end)
		end)
	end

	do
		local effortNames = tFreeze({ auto = "Auto", none = "Off", minimal = "Minimal", low = "Low", medium = "Medium", high = "High", xhigh = "X-High", max = "Max", default = "On" })
		local effortBtn, effortLbl, effortArr = st.effortBtn, st.effortLbl, st.effortArr
		local effW = 96
		local effMenu = iNew("Frame")
		effMenu.Name, effMenu.Active, effMenu.AnchorPoint, effMenu.Position, effMenu.Size, effMenu.BackgroundColor3, effMenu.BorderSizePixel, effMenu.ClipsDescendants, effMenu.Visible, effMenu.ZIndex = rand(), true, v2(1, 1), u2(1, 0, 0, -8), u2o(effW, 0), menuBg, 0, true, false, 4
		crn(effMenu, cardRad); pad(effMenu, 4, 4, 4, 4); lst(effMenu, nil, 2)
		local effStroke = strk(effMenu)
		effMenu.Parent = effortBtn
		local effBtns, effVals, effOpen = tCreate(7), {}, false

		local function curEffort()
			local p = cfg.provider
			local m = match(cfg.models[p] or "", "^%s*(.-)%s*$") or ""
			if m == "" then m = defModels[p] or "" end
			local lv = effortLevels(p, m)
			local v = cfg.effort[p] or "auto"
			for i = 1, #lv do if lv[i] == v then return v, lv end end
			return "auto", lv
		end
		st.getEffort = function()
			local v = curEffort()
			return v ~= "auto" and v or nil
		end
		local function fillEff()
			local v, lv = curEffort()
			effVals = lv
			for i = 1, 7 do
				local e = effBtns[i]
				if i <= #lv then
					local sel = lv[i] == v
					e.btn.Text, e.btn.TextColor3, e.btn.Visible = effortNames[lv[i]] or lv[i], sel and white or iconIdle, true
					e.chk.ImageTransparency = sel and 0 or 1
					e.set(sel and selChatBg or darkBox, sel and 0 or 1)
				else
					e.btn.Visible = false
				end
			end
			return min(#lv, 7)
		end
		local function setEffOpen(o)
			if o == effOpen then return end
			effOpen = o
			tw(effortArr, twMid, { Rotation = o and 0 or 180, ImageColor3 = o and white or iconIdle }):Play()
			if o then popTo(effMenu, effStroke, effW, fillEff() * 24 + 6, true) else popTo(effMenu, effStroke, effW, 0, false) end
		end
		st.refreshEffort = function()
			local v, lv = curEffort()
			effortLbl.Text, effortLbl.TextColor3 = effortNames[v] or v, #lv > 1 and white or grayName
			if effOpen then popTo(effMenu, effStroke, effW, fillEff() * 24 + 6, true) end
		end
		for i = 1, 7 do
			local b, ck = mrow(effMenu, i, "")
			b.Visible = false
			local set = bindFeedback(b, darkBox, hoverBg, 1, 0, true)
			b.Activated:Connect(function()
				local v = effVals[i]
				if not v then return end
				cfg.effort[cfg.provider] = v
				saveCfg()
				st.refreshEffort()
				setEffOpen(false)
			end)
			effBtns[i] = { btn = b, set = set, chk = ck }
		end
		bindFeedback(effortBtn, darkBox, hoverBg, 0.06, 0, true)
		st.effortConn = effortBtn.Activated:Connect(function() setEffOpen(not effOpen) end)
		st.effortFocusConn = promptBox.Focused:Connect(function() setEffOpen(false) end)
		st.refreshEffort()
	end

	do
		local plusBtn, plusIcon, badge, badgeStroke = st.plusBtn, st.plusIcon, st.plusBadge, st.plusBadgeStroke
		local mW = 210
		local menu = iNew("Frame")
		menu.Name, menu.Active, menu.AnchorPoint, menu.Position, menu.Size, menu.BackgroundColor3, menu.BorderSizePixel, menu.ClipsDescendants, menu.Visible, menu.ZIndex = rand(), true, v2(0, 1), u2(0, 0, 0, -8), u2o(mW, 0), menuBg, 0, true, false, 4
		crn(menu, cardRad); pad(menu, 4, 4, 4, 4); lst(menu, nil, 2)
		local mStroke = strk(menu)
		menu.Parent = plusBtn

		local function row(ord, txt, img)
			local b = mrow(menu, ord, txt, img, iconIdle)
			bindFeedback(b, darkBox, hoverBg, 1, 0, true)
			return b
		end
		local addBtn = row(1, "Add image", decal(15928997778))
		local remBtn = row(2, "Remove image", decal(109058392374604))
		remBtn.TextColor3, remBtn.Visible = iconIdle, false
		local urlBox = iNew("TextBox")
		urlBox.Name, urlBox.AutoLocalize, urlBox.ClearTextOnFocus, urlBox.LayoutOrder, urlBox.BackgroundColor3, urlBox.BorderSizePixel, urlBox.Size, urlBox.FontFace, urlBox.Text, urlBox.PlaceholderText, urlBox.PlaceholderColor3, urlBox.TextColor3, urlBox.TextSize, urlBox.TextTruncate, urlBox.TextXAlignment, urlBox.Visible = rand(), false, false, 3, inputBg, 0, u2(1, 0, 0, 22), interThin, "", "Image URL (PNG/JPEG/WEBP), Enter", grayName, white, 11, trEnd, alL, false
		crn(urlBox, itemRad); strk(urlBox); pad(urlBox, 8, 8)
		urlBox.Parent = menu
		local status = iNew("TextLabel")
		status.Name, status.AutoLocalize, status.LayoutOrder, status.BackgroundTransparency, status.Size, status.FontFace, status.Text, status.TextColor3, status.TextSize, status.TextTruncate, status.TextXAlignment, status.Visible, status.Parent = rand(), false, 4, 1, u2(1, 0, 0, 14), interThin, "", grayName, 10, trEnd, alL, false, menu
		pad(status, 8, 8)

		local open, gen = false, 0
		local errCol = c3(1, 0.42, 0.47)
		local function height()
			local h, n = 8, 0
			for _, it in { addBtn, remBtn, urlBox, status } do
				if it.Visible then h += it.Size.Y.Offset; n += 1 end
			end
			return h + max(0, n - 1) * 2
		end
		local function setStatus(txt, isErr)
			status.Text, status.TextColor3, status.Visible = txt or "", isErr and errCol or grayName, txt ~= nil
			if open then popTo(menu, mStroke, mW, height(), true) end
		end
		local env2 = (getgenv and getgenv()) or _G
		local wfile, dfile = env2.writefile or writefile, env2.delfile or delfile
		local isfo, mkfo = env2.isfolder or isfolder, env2.makefolder or makefolder
		local gasset = env2.getcustomasset or env2.getsynasset or getcustomasset or getsynasset
		local pvH = 52
		local pv = iNew("Frame")
		pv.Name, pv.AnchorPoint, pv.Position, pv.Size, pv.BackgroundColor3, pv.BorderSizePixel, pv.ClipsDescendants, pv.Visible, pv.ZIndex = rand(), v2(0, 1), u2(0, 10 + st.plusW, 1, -44), u2o(pvH, 0), inputBg, 0, true, false, 3
		crn(pv, cardRad)
		local pvStroke = strk(pv)
		local pvImg = iNew("ImageLabel")
		pvImg.Name, pvImg.BackgroundTransparency, pvImg.BorderSizePixel, pvImg.Size, pvImg.ScaleType, pvImg.Image, pvImg.Parent = rand(), 1, 0, u2s(1, 1), Enum.ScaleType.Crop, "", pv
		crn(pvImg, cardRad)
		local pvTxt = lbl(pv, "", 10, grayName, u2o(0, 0), u2s(1, 1), alC)
		local pvX = iNew("ImageButton")
		pvX.Name, pvX.AutoButtonColor, pvX.AnchorPoint, pvX.Position, pvX.Size, pvX.BackgroundColor3, pvX.BackgroundTransparency, pvX.BorderSizePixel, pvX.Parent = rand(), false, v2(1, 0), u2(1, -3, 0, 3), u2o(16, 16), darkBox, 0.15, 0, pv
		crn(pvX, circRad)
		icn(pvX, decal(109058392374604), 9, nil, white)
		bindFeedback(pvX, darkBox, hoverBg, 0.15, 0, true)
		pv.Parent = mainFrame
		local pvShown, pvFile = false, nil
		local cScroll = st.chatScroll
		local function setPreview(a)
			if a then
				pvImg.Image = a.preview or ""
				pvTxt.Text = a.preview and "" or string.upper(match(a.mime, "/(%w+)$") or "img")
			end
			local show = a ~= nil
			if show == pvShown then return end
			pvShown = show
			local off = show and (pvH + 6) or 0
			tw(cScroll, twMid, { Size = u2(1, -20, 1, -76 - off) }):Play()
			if st.sugFrame then tw(st.sugFrame, twMid, { Position = u2(0, 10 + st.plusW, 1, -44 - off) }):Play() end
			popTo(pv, pvStroke, pvH, show and pvH or 0, show)
		end
		local function dropFile()
			if pvFile and dfile then pcall(dfile, pvFile) end
			pvFile = nil
		end
		local function saveFile(g, mime, body)
			if mime == "image/webp" or not wfile or not gasset then return nil end
			if isfo and mkfo then
				for _, d in { "Bloxy", "Bloxy/cdn" } do
					local okD, ex = pcall(isfo, d)
					if okD and not ex then pcall(mkfo, d) end
				end
			end
			local path = "Bloxy/cdn/attach_" .. g .. (mime == "image/png" and ".png" or ".jpg")
			if not pcall(wfile, path, body) then return nil end
			local okA, id = pcall(gasset, path, true)
			if not okA or type(id) ~= "string" then pcall(dfile or function() end, path) return nil end
			dropFile()
			pvFile = path
			return id
		end

		local function refresh()
			local a = st.attach
			setPreview(a)
			if not a then dropFile() end
			addBtn.Text = a and "Replace image" or "Add image"
			remBtn.Text, remBtn.Visible = a and ("Remove image · " .. a.name) or "Remove image", a ~= nil
			tw(badge, twFast, { BackgroundTransparency = a and 0 or 1 }):Play()
			tw(badgeStroke, twFast, { Transparency = a and 0 or 1 }):Play()
			if open then popTo(menu, mStroke, mW, height(), true) end
		end
		st.onAttach = refresh
		local function setOpen(o)
			if o == open then return end
			open = o
			tw(plusIcon, twMid, { Rotation = o and 45 or 0, ImageColor3 = o and white or iconIdle }):Play()
			if o then
				urlBox.Visible, status.Visible = false, false
				refresh()
				popTo(menu, mStroke, mW, height(), true)
			else
				if urlBox:IsFocused() then urlBox:ReleaseFocus() end
				popTo(menu, mStroke, mW, 0, false)
			end
		end

		local A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		local T2 = nil
		local okEnc, encSvc = pcall(game.GetService, game, "EncodingService")
		if not okEnc then encSvc = nil end
		local bCreate, bW16, bW8, bStr, bFrom = buffer.create, buffer.writeu16, buffer.writeu8, buffer.tostring, buffer.fromstring
		local function b64(data)
			local n = #data
			if n == 0 then return "" end
			if encSvc then
				local okB, out = pcall(encSvc.Base64Encode, encSvc, bFrom(data))
				if okB and type(out) == "buffer" then return bStr(out) end
				encSvc = nil
			end
			if not T2 then
				T2 = tCreate(4096)
				for i = 0, 4095 do T2[i + 1] = byte(A, i // 64 + 1) + byte(A, i % 64 + 1) * 256 end
			end
			local full = n - n % 3
			local out, o, t0 = bCreate((n + 2) // 3 * 4), 0, clock()
			for i = 1, full, 3 do
				local a, b, c = byte(data, i, i + 2)
				local v = a * 65536 + b * 256 + c
				bW16(out, o, T2[v // 4096 + 1])
				bW16(out, o + 2, T2[v % 4096 + 1])
				o += 4
				if i % 12288 == 1 and clock() - t0 > 0.004 then tWait(); t0 = clock() end
			end
			local r = n - full
			if r > 0 then
				local v = byte(data, full + 1) * 65536 + (r == 2 and byte(data, full + 2) * 256 or 0)
				bW16(out, o, T2[v // 4096 + 1])
				bW8(out, o + 2, r == 2 and byte(A, (v % 4096) // 64 + 1) or 61)
				bW8(out, o + 3, 61)
			end
			return bStr(out)
		end
		local function sniff(d)
			if sub(d, 1, 8) == "\137PNG\r\n\26\n" then return "image/png" end
			if sub(d, 1, 3) == "\255\216\255" then return "image/jpeg" end
			if sub(d, 1, 4) == "RIFF" and sub(d, 9, 12) == "WEBP" then return "image/webp" end
			return nil
		end
		local maxBytes = 4 * 1024 * 1024
		local function fetchImage(url)
			gen += 1
			local g = gen
			setStatus("Downloading...", false)
			spawn(function()
				local code, body = doHttp({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0", ["Accept"] = "image/png,image/jpeg,image/webp,image/*" } })
				if code == 0 then
					local ok, b = pcall(game.HttpGet, game, url)
					if ok and type(b) == "string" and #b > 0 then code, body = 200, b end
				end
				if g ~= gen then return end
				if code ~= 200 or type(body) ~= "string" or #body == 0 then
					setStatus("Download failed" .. (code ~= 0 and (" (HTTP " .. tostring(code) .. ")") or ""), true)
					return
				end
				if #body > maxBytes then
					setStatus("Image too big (max 4 MB)", true)
					return
				end
				local mime = sniff(body)
				if not mime then
					setStatus("Not a PNG, JPEG or WEBP image", true)
					return
				end
				setStatus("Encoding...", false)
				local data = b64(body)
				if g ~= gen then return end
				local preview = saveFile(g, mime, body)
				body = nil
				local nm = match(url, "([^/%?#]+)[%?#]?[^/]*$") or "image"
				if #nm > 28 then nm = sub(nm, 1, 25) .. "..." end
				st.attach = { mime = mime, data = data, name = nm, preview = preview }
				urlBox.Text, urlBox.Visible = "", false
				setStatus(nil)
				refresh()
				setOpen(false)
			end)
		end

		addBtn.Activated:Connect(function()
			urlBox.Visible = true
			setStatus(nil)
			popTo(menu, mStroke, mW, height(), true)
			urlBox:CaptureFocus()
		end)
		local function removeAttach()
			gen += 1
			st.attach = nil
			refresh()
			setOpen(false)
		end
		remBtn.Activated:Connect(removeAttach)
		pvX.Activated:Connect(removeAttach)
		urlBox.FocusLost:Connect(function(enter)
			if not enter then return end
			local url = match(urlBox.Text, "^%s*(.-)%s*$") or ""
			if not match(url, "^https?://") then
				setStatus("Enter a full http(s) URL", true)
				return
			end
			fetchImage(url)
		end)
		bindFeedback(plusBtn, darkBox, hoverBg, 0.06, 0, true)
		st.plusConn = plusBtn.Activated:Connect(function() setOpen(not open) end)
		st.plusFocusConn = promptBox.Focused:Connect(function() setOpen(false) end)
		plusIcon.ImageColor3 = iconIdle
	end

	st.resend = submit
	st.sendConn = sendButton.Activated:Connect(submit)
	st.focusConn = promptBox.FocusLost:Connect(function(ent) if ent then submit() end end)
end)()

local dragStartConn, cleanupDrag
do
	local mb1, mmv, tch = Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch
	local actIn, mvConn, edConn
	local sx, sy, pxs, pxo, pys, pyo = 0, 0, 0, 0, 0, 0

	local function onMove(inp)
		if inp == actIn or (inp.UserInputType == mmv and actIn and actIn.UserInputType == mb1) then
			local p = inp.Position
			mainFrame.Position = u2(pxs, pxo + (p.X - sx), pys, pyo + (p.Y - sy))
		end
	end
	local function disc()
		actIn = nil
		if mvConn then mvConn:Disconnect(); mvConn = nil end
		if edConn then edConn:Disconnect(); edConn = nil end
	end
	cleanupDrag = disc

	dragStartConn = mainFrame.InputBegan:Connect(function(inp)
		if actIn then return end
		local it = inp.UserInputType
		if it ~= mb1 and it ~= tch then return end
		actIn = inp
		sx, sy = inp.Position.X, inp.Position.Y
		local fp = mainFrame.Position
		pxs, pxo, pys, pyo = fp.X.Scale, fp.X.Offset, fp.Y.Scale, fp.Y.Offset
		mvConn = UserInputService.InputChanged:Connect(onMove)
		edConn = UserInputService.InputEnded:Connect(function(e) if e == actIn then disc() end end)
	end)
end

local renderConn
do
	local bloxySeqs = tCreate(200)
	local phSeq
	local totFrames = 0
	do
		local stepRad = 0.03141592653589793
		for i = 1, 200 do
			local a = (1 - cos((i - 1) * stepRad)) * 0.5
			bloxySeqs[i] = cSeq(purple:Lerp(pink, a), pink:Lerp(purple, a))
		end
		tFreeze(bloxySeqs)
	end

	do
		local pre, idle = "Bloxy, build me", "Bloxy, build me..."
		local suffs = {
			" an advanced ESP.", " a fly GUI.", " a WalkSpeed slider.", " a JumpPower slider.",
			" a gravity slider.", " a max zoom slider.", " a very cool GUI.", " an auto-farm.",
			" a smooth aimbot.", " a teleport GUI.", " an infinite jump."
		}
		local cnt = 0
		for i = 1, #suffs do cnt += 42 + #suffs[i] * 2 end
		local fr = tCreate(cnt)
		local idx = 0
		for i = 1, #suffs do
			local s = suffs[i]
			local l = #s
			for _ = 1, 14 do idx += 1; fr[idx] = idle end
			for c = 1, l do idx += 1; fr[idx] = pre .. sub(s, 1, c) end
			local full = fr[idx]
			for _ = 1, 28 do idx += 1; fr[idx] = full end
			for c = l - 1, 1, -1 do idx += 1; fr[idx] = pre .. sub(s, 1, c) end
		end
		totFrames = idx
		phSeq = tFreeze(fr)
	end

	local startClk = clock()
	local curFrame = 1
	local lastStep, lastTxtStep = -1, -1
	local sig = RunService.PreRender or RunService.RenderStepped
	local bGrad, eGrad, pBox = st.bloxyGradient, st.exclaimGradient, st.promptBox
	local tLabels, tGrads, tws, offs = st.thinkLabels, st.thinkGrads, st.typewriters, st.offsets
	local totDur = st.totalDur

	renderConn = sig:Connect(function()
		LPH_ATTRIBUTES(VM(NONE))
		local now = clock()
		local lCnt = #tLabels
		if lCnt > 0 and st.loaderReady then
			local f = frameAtTime((now - startClk) % totDur)
			if f ~= curFrame then
				curFrame = f
				local o = offs[f]
				for i = 1, lCnt do tLabels[i].ImageRectOffset = o end
			end
		end

		local step = (now * 60) // 1
		if step == lastStep then return end
		lastStep = step

		local seq = bloxySeqs[(step - st.cycleStep) % 200 + 1]
		local ph = st.phase
		if ph == 0 then
			bGrad.Color, eGrad.Color = seq, seq
		elseif ph == 1 then
			local el = step - st.fadeStep + 1
			if el <= 24 then bGrad.Color = whiteSeqs[el] end
		elseif ph == 3 then
			local el = step - st.fadeStep + 1
			if el <= 24 then bGrad.Color = revSeqs[el] end
		end

		for i = 1, #tGrads do tGrads[i].Color = seq end

		for i = #tws, 1, -1 do
			local it = tws[i]
			local lb = it.label
			if not lb.Parent then
				tRemove(tws, i)
			else
				local nx = it.current + it.speed
				if nx >= it.total then
					lb.MaxVisibleGraphemes = -1
					tRemove(tws, i)
				else
					it.current = nx
					lb.MaxVisibleGraphemes = nx
				end
			end
		end

		if not st.showingSend then
			local ts = step // 3
			if ts ~= lastTxtStep then
				lastTxtStep = ts
				pBox.PlaceholderText = phSeq[ts % totFrames + 1]
			end
		end
	end)
end

do
	screenGui.Destroying:Once(function()
		renderConn:Disconnect()
		st.textChangedConn:Disconnect()
		st.sendConn:Disconnect()
		st.focusConn:Disconnect()
		st.sugConn:Disconnect()
		st.sugFocusConn:Disconnect()
		st.effortConn:Disconnect()
		st.effortFocusConn:Disconnect()
		st.plusConn:Disconnect()
		st.plusFocusConn:Disconnect()
		dragStartConn:Disconnect()
		cleanupDrag()
	end)
end
