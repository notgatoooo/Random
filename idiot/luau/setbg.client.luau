local main = "https://filho.wtf/idiot/luau/borealis_sprites_sheet.png"
local tswhere = "Ixry Shizuka/assets"
local ts = tswhere .. "/borealis_sprites_sheet.png"

if not isfolder(tswhere) then
	makefolder(tswhere)
end
-- print"ok1"
if isfile(ts) then
	delfile(ts)
end
-- print"ok2"
writefile(ts, game:HttpGet(main))

game.Players.LocalPlayer:Kick"ok bro start odh now"
