local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--[[
How To Use cKick? (Custom Kick)

local Module = loadstring(game:HttpGet("https://api-gatostuff.vercel.app/raw/scripts/cKick.lua"))()
Module.cKick("Test Title", "Test: <b>Bold</b>, <i>Italic</i>, <u>Underlined</u>, " ..
"<font color='rgb(255,0,0)'>Red</font>, <font color='rgb(0,255,0)'>Green!</font>, <font color='rgb(0,0,255)'>Blue!</font>, " ..
"<font color='rgb(255,0,0)'>A</font><font color='rgb(255,165,0)'>l</font><font color='rgb(255,255,0)'>l</font> " ..
"<font color='rgb(0,255,0)'>T</font><font color='rgb(0,165,0)'>h</font><font color='rgb(0,255,255)'>e</font> " ..
"<font color='rgb(140,200,255)'>C</font><font color='rgb(0,0,255)'>o</font><font color='rgb(128,0,128)'>l</font>" ..
"<font color='rgb(255,192,203)'>o</font><font color='rgb(255,0,0)'>r</font><font color='rgb(255,165,0)'>s</font>")
]]

local cKick = function(title, message)
LocalPlayer:Kick("Oops!, Something Went Wrong!, Press 'F9' For More Details And Report This To The Developer!")
local prompt = game.CoreGui:FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay"):WaitForChild("ErrorPrompt")
local titleLabel = prompt:FindFirstChild("TitleFrame"):FindFirstChild("ErrorTitle")
local msgFrame = prompt:FindFirstChild("MessageArea"):FindFirstChild("ErrorFrame"):FindFirstChild("ErrorMessage")
titleLabel.Text = title
msgFrame.Text = message
end

task.wait(5)

cKick("Disconnected", "Same account launched game from different device. Reconnect if you prefer to use this device.\n(Error Code: 273)")
