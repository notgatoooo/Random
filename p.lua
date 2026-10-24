local url = "https://raw.githubusercontent.com/notgatoooo/Random/refs/heads/main/bootstrapper.lua"
local path = "Ixry Shizuka/files/bootstrapper.lua"

makefolder("Ixry Shizuka")
makefolder("Ixry Shizuka/files")

local success, content = pcall(game.HttpGet, game, url)

if success and content and #content > 0 then
    writefile(path, content)
else
    warn("fail breh", content)
end
