task.spawn(function()
    local v1, v2, v3, v4, v6, v7, v8 = odh_shared_plugins, {}, game:GetService("ReplicatedStorage"), game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("Workspace")
    local v5 = v4.LocalPlayer

    if v1.game_name ~= "Murder Mystery 2" then
        return
    end

    v2.__index = v2

    function v2.new()
        return setmetatable({_tasks = {}, _destroyed = false}, v2)
    end

    function v2:GiveTask(v33)
        if self._destroyed then self:_cleanupTask(v33) return end
        table.insert(self._tasks, v33)
        return v33
    end

    function v2:GiveTasks(...)
        for _, v34 in {...} do self:GiveTask(v34) end
    end

    function v2:_cleanupTask(v35)
        local v36 = typeof(v35)
        if v36 == "RBXScriptConnection" then v35:Disconnect()
        elseif v36 == "Instance" then v35:Destroy()
        elseif v36 == "function" then v35()
        elseif v36 == "table" and type(v35.Destroy) == "function" then v35:Destroy()
        end
    end

    function v2:DoCleaning()
        if self._destroyed then return end
        self._destroyed = true
        for _, v37 in self._tasks do self:_cleanupTask(v37) end
        table.clear(self._tasks)
    end

    function v2:Destroy() self:DoCleaning() end

    local v9, v10, v11, v12, v13, v14, v15 = nil, {}, {}, false, 15, 3, 0.15
    local v16, v17 = {loopPlr = nil, loopAll = nil, clickReset = nil, resetAura = nil, autoSheriff = nil, autoMurderer = nil, autoStealGun = nil}, {}
    local v38 = v2.new()

    local function v20(v43)
        if not v43 then return false end
        local v44 = v43:FindFirstChild("Gun")
        return v44 and v44:IsA("Tool")
    end

    local function v21()
        for _, v45 in v4:GetPlayers() do
            if v45 ~= v5 then
                if v20(v45.Character) or v20(v45.Backpack) then return v45 end
            end
        end
        return nil
    end

    local function v22(v46) return v11[v46.UserId] == true end

    local function v23(v47)
        for _, v48 in v10 do
            if v48.UserId == v47.UserId then return true end
        end
        return false
    end

    local function v24(v49, v50)
        if not (v49 and v50) then return end
        firetouchinterest(v49, v50, 0)
        firetouchinterest(v49, v50, 1)
        firetouchinterest(v49, v50, 0)
        firetouchinterest(v49, v50, 1)
        firetouchinterest(v49, v50, 0)
        firetouchinterest(v49, v50, 1)
    end

    local function v25(v51, v52, v53)
        if not v51 or not v52 then v8.FallenPartsDestroyHeight = v53 return end
        local v54, v55 = v51:FindFirstChildOfClass("Humanoid"), v51:FindFirstChild("HumanoidRootPart")
        if not v54 or not v55 then v8.FallenPartsDestroyHeight = v53 return end

        v8.FallenPartsDestroyHeight, v55.CFrame = v53, v52.cframe
        v55.AssemblyLinearVelocity, v55.AssemblyAngularVelocity, v55.Velocity, v55.RotVelocity = Vector3.zero, Vector3.zero, Vector3.zero, Vector3.zero
        v54.PlatformStand = false
        v54:ChangeState(Enum.HumanoidStateType.GettingUp)
        if v54.Health < v54.MaxHealth then v54.Health = v54.MaxHealth end
        for _, v56 in v51:GetDescendants() do
            if v56:IsA("BasePart") then v56.CanCollide = true end
        end
    end

    local v26, v57, v58, v59, v60 = 6, Vector3.new(math.huge, math.huge, math.huge), Vector3.new(0, -200000, 0), Vector3.new(15000, 15000, 15000), Vector3.new(0, 2.5, 0)

    local function v27()
        local v61 = 0
        for _ in v17 do v61 += 1 end
        return v61
    end

    local function v28(v62, v63, v76_override)
        if v62 == v5 or v22(v62) or v17[v62.UserId] then return end
        v63 = v63 or 0
        if v27() >= v26 then
            task.defer(function() task.wait(0.05 * (v63 + 1)) v28(v62, v63, v76_override) end)
            return
        end

        local v64 = v5.Character
        if not v64 then return end
        local v65 = v64:FindFirstChildOfClass("Humanoid")
        local v66 = v65 and v65.RootPart
        local v67 = v62.Character
        if not (v65 and v66 and v67) then return end

        local v68, v69 = v67:FindFirstChild("HumanoidRootPart"), v67:FindFirstChild("Head")
        if not v68 then return end

        local v70, v71, v72 = {}, {}, {"HumanoidRootPart", "Head", "UpperTorso", "Torso"}
        for _, v73 in v67:GetChildren() do if v73:IsA("BasePart") then table.insert(v70, v73) end end
        for _, v74 in v72 do
            local v75 = v67:FindFirstChild(v74)
            if v75 and v75:IsA("BasePart") then table.insert(v71, v75) end
            if #v71 >= 4 then break end
        end
        if #v71 == 0 then v71 = v70 end

        local v76, v77 = {cframe = v76_override or v66.CFrame}, v8.FallenPartsDestroyHeight
        v8.FallenPartsDestroyHeight, v65.PlatformStand = -math.huge, true

        local v78, v79 = Instance.new("BodyVelocity"), Instance.new("BodyGyro")
        v78.MaxForce, v78.Velocity, v78.Parent = v57, v58, v66
        v79.MaxTorque, v79.P, v79.Parent = v57, 9e8, v66

        local v80, v81, v82, v83 = os.clock(), 0.35, false, {bv = v78, bg = v79, conn = nil}
        v17[v62.UserId] = v83

        local function v84(v85)
            if v82 then return end
            v82, v17[v62.UserId] = true, nil
            if v83.conn then v83.conn:Disconnect() v83.conn = nil end
            if v78 then v78:Destroy() end
            if v79 then v79:Destroy() end
            v25(v64, v76, v77)
            if not v85 and v63 < v14 then
                task.delay(v15, function() if v62.Parent and not v22(v62) then v28(v62, v63 + 1, v76_override) end end)
            end
        end

        local v86 = 0
        v83.conn = v7.Heartbeat:Connect(function()
            v86 += 1
            if not v62.Character or not v68.Parent then v84(true) return end
            if os.clock() - v80 >= v81 then v84(false) return end
            if not v64.Parent or not v66.Parent then v84(true) return end

            local v87 = v69 and v69.Position or (v68.Position + v60)
            v66.CFrame, v66.AssemblyLinearVelocity, v66.AssemblyAngularVelocity = CFrame.new(v87), v58, v59

            if v86 % 2 == 1 then
                for _ = 1, 5 do for _, v88 in v71 do v24(v66, v88) end end
            else
                for _ = 1, 3 do v24(v66, v68) if v69 then v24(v66, v69) end end
            end

            if sethiddenproperty then pcall(sethiddenproperty, v66, "PhysicsRepRootPart", v68) end
            if v65.Health < v65.MaxHealth * 0.5 then v65.Health = v65.MaxHealth end
        end)
    end

    local function v29(v89)
        if v22(v89) then return end
        task.spawn(v28, v89)
    end

    local function v30()
        local roles
        local success, err = pcall(function()
            roles = v3:FindFirstChild("GetPlayerData", true):InvokeServer()
        end)
        if success and roles then
            for i, v in pairs(roles) do
                if (v.Role == "Sheriff" or v.Role == "Hero") and not v.Killed and not v.Dead then
                    local plr = v4:FindFirstChild(i)
                    if plr and plr ~= v5 and not v22(plr) then
                        return plr
                    end
                end
            end
        end
        local v90 = v21()
        if v90 and v90 ~= v5 and not v22(v90) then return v90 end
        return nil
    end

    local function v31()
        local roles
        local success, err = pcall(function()
            roles = v3:FindFirstChild("GetPlayerData", true):InvokeServer()
        end)
        if success and roles then
            for i, v in pairs(roles) do
                if v.Role == "Murderer" and not v.Killed and not v.Dead then
                    local plr = v4:FindFirstChild(i)
                    if plr and plr ~= v5 and not v22(plr) then
                        return plr
                    end
                end
            end
        end
        for _, v45 in v4:GetPlayers() do
            if v45 ~= v5 and not v22(v45) then
                local char = v45.Character
                local bp = v45.Backpack
                local hasKnife = (char and char:FindFirstChild("Knife") and char.Knife:IsA("Tool")) or (bp and bp:FindFirstChild("Knife") and bp.Knife:IsA("Tool"))
                if hasKnife then
                    return v45
                end
            end
        end
        return nil
    end

    local v32_reset = v1.AddSection("Reset Options")

    v32_reset:AddLabel("Reset Player Options")

    v32_reset:AddButton("Reset Sheriff", function()
        local v99 = v30()
        if v99 then v28(v99) else v1.Notify("Error: No Sheriff / Gun Holder Found", 2) end
    end)

    v32_reset:AddButton("Steal Gun", function()
        local sheriff = v30()
        local gunDrop = v8:FindFirstChild("GunDrop", true)

        if not sheriff and gunDrop then
            local char = v5.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                if gunDrop:IsA("BasePart") then
                    gunDrop.CFrame = root.CFrame
                else
                    gunDrop:PivotTo(root.CFrame)
                end
                v1.Notify("Gun teleported to you!", 2)
            end
            return
        end

        if sheriff then
            v28(sheriff)
            task.spawn(function()
                local start = os.clock()
                local found = false
                while (os.clock() - start) < 60 do
                    local gun = v8:FindFirstChild("GunDrop", true)
                    if gun then
                        local char = v5.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            if gun:IsA("BasePart") then
                                gun.CFrame = root.CFrame
                            else
                                gun:PivotTo(root.CFrame)
                            end
                            found = true
                            break
                        end
                    end
                    task.wait(0.2)
                end
                if not found then
                    v1.Notify("Failed to get the Gun :(", 2)
                end
            end)
        else
            v1.Notify("Error: No Sheriff or GunDrop found", 2)
        end
    end)

    v32_reset:AddLabel("<b>Auto Steal Gun</b> automatically gets the gun once the sheriff dies, <b>Reset</b> Sheriff doesnt!")

    v32_reset:AddButton("Reset Murderer", function()
        local v100 = v31()
        if v100 then v28(v100) else v1.Notify("Error: No Murderer Found", 2) end
    end)

    v32_reset:AddButton("Reset All", function()
        local char = v5.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local origCFrame = root and root.CFrame

        for _, v101 in v4:GetPlayers() do
            if v101 ~= v5 and not v22(v101) then task.spawn(v28, v101, nil, origCFrame) end
        end

        if origCFrame then
            task.spawn(function()
                local start = os.clock()
                while next(v17) and (os.clock() - start) < 4 do
                    task.wait(0.1)
                end
                if root and root.Parent then
                    root.CFrame = origCFrame
                end
            end)
        end
    end)

    v32_reset:AddPlayerDropdown("Reset Player", function(v102)
        v9 = v102
        if v102 and v102 ~= v5 and not v22(v102) then v28(v102)
        elseif v102 and v22(v102) then v1.Notify("Whitelist: " .. v102.Name .. " is whitelisted!", 3) end
    end)

    v32_reset:AddLabel("Auto Reset Roles Options")

    v32_reset:AddToggle("Auto Reset Sheriff", function(v106)
        if v16.autoSheriff then v16.autoSheriff:Destroy() end
        if v106 then
            v16.autoSheriff = v2.new()
            local v107 = task.spawn(function()
                while true do
                    local v108 = v30()
                    if v108 then v28(v108) end
                    task.wait(0.25)
                end
            end)
            v16.autoSheriff:GiveTask(function() task.cancel(v107) end)
        end
    end)

    v32_reset:AddToggle("Auto Steal Gun", function(v_asg)
        if v16.autoStealGun then v16.autoStealGun:Destroy() end
        if v_asg then
            v16.autoStealGun = v2.new()
            local v107_asg = task.spawn(function()
                while true do
                    local gunDrop = v8:FindFirstChild("GunDrop", true)
                    if gunDrop then
                        local char = v5.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            if gunDrop:IsA("BasePart") then
                                gunDrop.CFrame = root.CFrame
                            else
                                gunDrop:PivotTo(root.CFrame)
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
            v16.autoStealGun:GiveTask(function() task.cancel(v107_asg) end)
        end
    end)

    v32_reset:AddToggle("Auto Reset Murderer", function(v109)
        if v16.autoMurderer then v16.autoMurderer:Destroy() end
        if v109 then
            v16.autoMurderer = v2.new()
            local v110 = task.spawn(function()
                while true do
                    local v111 = v31()
                    if v111 then v28(v111) end
                    task.wait(0.4)
                end
            end)
            v16.autoMurderer:GiveTask(function() task.cancel(v110) end)
        end
    end)

    v32_reset:AddLabel("Other Stuff(s)")

    v32_reset:AddToggle("Loop Reset Player(s)", function(v112)
        if v16.loopPlr then v16.loopPlr:Destroy() end
        if v112 then
            v16.loopPlr = v2.new()
            local v113 = task.spawn(function()
                while true do
                    if v9 and v9.Parent and not v22(v9) then task.spawn(v28, v9) end
                    for _, v114 in v10 do if v114 and v114.Parent and not v22(v114) then task.spawn(v28, v114) end end
                    task.wait(0.4)
                end
            end)
            v16.loopPlr:GiveTask(function() task.cancel(v113) end)
        end
    end)

    v32_reset:AddToggle("Loop Reset All", function(v115)
        if v16.loopAll then v16.loopAll:Destroy() end
        if v115 then
            v16.loopAll = v2.new()
            local v116 = task.spawn(function()
                while true do
                    for _, v117 in v4:GetPlayers() do if v117 ~= v5 and v117.Parent and not v22(v117) then task.spawn(v28, v117) end end
                    task.wait(0.4)
                end
            end)
            v16.loopAll:GiveTask(function() task.cancel(v116) end)
        end
    end)

    v32_reset:AddToggle("Click Reset", function(v118)
        if v16.clickReset then v16.clickReset:Destroy() end
        if v118 then
            v16.clickReset = v2.new()
            local function v119(v120, v121)
                if v121 then return end
                if v120.UserInputType == Enum.UserInputType.MouseButton1 or v120.UserInputType == Enum.UserInputType.Touch then
                    local v122, v123 = v5:GetMouse(), nil
                    v123 = v122.Target
                    if v123 then
                        local v124 = v123:FindFirstAncestorWhichIsA("Model")
                        if v124 then
                            local v125 = v4:GetPlayerFromCharacter(v124)
                            if v125 and v125 ~= v5 and not v22(v125) then
                                v28(v125)
                                v1.Notify("Click Reset: Resetting " .. v125.Name, 1)
                            elseif v125 and v22(v125) then
                                v1.Notify("Click Reset: " .. v125.Name .. " is whitelisted!", 3)
                            end
                        end
                    end
                end
            end
            if v6.TouchEnabled then v16.clickReset:GiveTask(v6.TouchTap:Connect(v119)) end
            v16.clickReset:GiveTask(v6.InputBegan:Connect(v119))
        end
    end)

    v32_reset:AddToggle("Reset Aura", function(v126)
        v12 = v126
        if v16.resetAura then v16.resetAura:Destroy() end
        if v126 then
            v16.resetAura = v2.new()
            local v127 = task.spawn(function()
                while v12 do
                    local v128, v129 = v5.Character, nil
                    v129 = v128 and v128:FindFirstChild("HumanoidRootPart")
                    if v129 then
                        for _, v130 in v4:GetPlayers() do
                            if v130 ~= v5 and not v22(v130) then
                                local v131, v132 = v130.Character, nil
                                v132 = v131 and v131:FindFirstChild("HumanoidRootPart")
                                if v132 and (v129.Position - v132.Position).Magnitude <= v13 then task.spawn(v28, v130) end
                            end
                        end
                    end
                    task.wait(0.4)
                end
            end)
            v16.resetAura:GiveTask(function() task.cancel(v127) end)
        end
    end)

    local v32_config = v1.AddSection("Configurations")

    v32_config:AddPlayerDropdown("Select Players", function(v103)
        if v103 and v103 ~= v5 and not v23(v103) then
            table.insert(v10, v103)
            v1.Notify("Selected: " .. v103.Name .. " added to reset list", 1)
        elseif v103 and v23(v103) then
            v1.Notify("Error: " .. v103.Name .. " is already selected", 2)
        end
    end)

    v32_config:AddButton("Clear Selected Players", function() table.clear(v10) v1.Notify("Cleared: All selected players removed", 1) end)
    v32_config:AddSlider("Max Retries", 0, 5, 3, function(v104) v14 = v104 end)
    v32_config:AddSlider("Retry Delay (x0.1s)", 1, 10, 2, function(v105) v15 = v105 * 0.1 end)
    v32_config:AddSlider("Aura Studs", 5, 50, 15, function(v133) v13 = v133 end)

    v32_config:AddPlayerDropdown("Add to Whitelist", function(v134)
        if v134 and v134 ~= v5 then
            v11[v134.UserId] = true
            v1.Notify("Whitelist: " .. v134.Name .. " added to whitelist", 1)
        end
    end)

    v32_config:AddButton("Clear Whitelist", function() table.clear(v11) v1.Notify("Whitelist: Whitelist cleared!", 1) end)

    v38:GiveTask(function()
        for _, v135 in v16 do if v135 then v135:Destroy() end end
        for _, v136 in v17 do
            if v136.conn then v136.conn:Disconnect() end
            if v136.bv then v136.bv:Destroy() end
            if v136.bg then v136.bg:Destroy() end
        end
        table.clear(v17)
    end)
end)
