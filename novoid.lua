local _ = odh_shared_plugins
local _2 = workspace.FallenPartsDestroyHeight

local _3 = _.CreateTab("No Void", "/notgatoooo/Random/refs/heads/main/Assets/NoVoid")
local _4 = _3:AddSection("No Void", "MADE BY GATO 😎")

_4:AddToggle("No Void", function(state)
    workspace.FallenPartsDestroyHeight = state and (0 / 0) or _2
    -- print("ok", state)
end)
