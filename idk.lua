local v65 = task
v65.spawn(function()
    local v1 = table.insert  
    local v2 = table.find  
    local v3 = math.abs  
      
    local v4 = {}  
    v4.__index = v4  
      
    function v4.new()   
        return setmetatable({_tasks = {}, _destroyed = false}, v4)   
    end  
      
    function v4.GiveTask(v66, v65)  
        if v66._destroyed then  
            v66:_cleanupTask(v65)  
            return  
        end  
        v1(v66._tasks, v65)  
        return v65  
    end  
      
    function v4.GiveTasks(v66, ...)  
        for v85, v65 in ipairs({...}) do  
            v66:GiveTask(v65)  
        end  
    end  
      
    function v4._cleanupTask(v66, v65)  
        local v50 = typeof(v65)  
        if v50 == "RBXScriptConnection" then  
            v65:Disconnect()  
        elseif v50 == "Instance" then  
            v65:Destroy()  
        elseif v50 == "function" then  
            v65()  
        elseif v50 == "table" and type(v65.Destroy) == "function" then  
            v65:Destroy()  
        end  
    end  
      
    function v4.DoCleaning(v66)  
        if v66._destroyed then return end  
        v66._destroyed = true  
        for v85, v65 in ipairs(v66._tasks) do  
            v66:_cleanupTask(v65)  
        end  
        v66._tasks = {}  
    end  
      
    function v4.Destroy(v66)   
        v66:DoCleaning()   
    end  
      
    local v5 = v4.new()  
      
    local v6 = odh_shared_plugins  
    if not v6 or v6.game_name ~= "Murder Mystery 2" then return end  
      
    local function v7(v86)  
        local v79, v78 = pcall(function() return game:GetService(v86) end)  
        if v79 and v78 then return v78 end  
        v79, v78 = pcall(function() return game:FindService(v86) end)  
        if v79 and v78 then return v78 end  
        return game[v86]  
    end  
      
    local v8 = v7("Players")  
    local v9 = v7("ReplicatedStorage")  
    local v10 = v7("RunService")  
    local v11 = v7("HttpService")  
      
    local v12 = v8.LocalPlayer  
      
    local v13 = v6.AddSection("Configurations")  
    local v14 = v6.AddSection("Spray Options")  
    
    local v15 = "saved_decals.json"  
    local v16 = {  
        ["BEST NSFW"] = 127671269169979, ["GOOD NSFW"] = 78704349540567, ["GROUP NSFW"] = 120749379081216,  
        ["ODH ON TOP"] = 119795719290739, ["TT Dad Jizz"] = 10318831749, ["Racist Ice Cream"] = 14868523054,  
        ["Nigga"] = 109017596954035, ["Roblox Ban"] = 16272310274, ["dsgcj"] = 13896748164,  
        ["Ra ist"] = 17059177886, ["Edp Ironic"] = 84041995770527, ["Ragebait"] = 118997417727905,  
        ["Clown"] = 3277992656, ["Job App"] = 131353391074818  
    }  
      
    if isfile and isfile(v15) then  
        local v79, v67 = pcall(function() return v11:JSONDecode(readfile(v15)) end)  
        if v79 and type(v67) == "table" then v16 = v67 end  
    end  
      
    local function v17()  
        if writefile then writefile(v15, v11:JSONEncode(v16)) end  
    end  
      
    local v18, v19, v20 = 0, "Nearest Player", nil  
    local v21, v22, v23 = nil, false, false  
    local v24 = "Front"  
    local v25, v26, v27, v30, v30_janitor  
    local v29 = false  
      
    v30 = {}  
    local v31 = workspace.DescendantAdded:Connect(function(v51)  
        if v51:IsA("Decal") or v51:IsA("Texture") then  
            v1(v30, v51)  
            if #v30 > 35 then  
                local v52 = table.remove(v30, 1)  
                if v52 and v52.Parent then  
                    pcall(function() v52:Destroy() end)  
                end  
            end  
        end  
    end)  
    v5:GiveTask(v31)  
    v5:GiveTask(function()  
        for v85, v96 in ipairs(v30) do  
            if v96 and v96.Parent then pcall(function() v96:Destroy() end) end  
        end  
        table.clear(v30)  
    end)  
      
    local function v32()  
        local v84 = v12.Character  
        return (v84 and v84:FindFirstChild("SprayPaint")) or (v12.Backpack and v12.Backpack:FindFirstChild("SprayPaint"))  
    end  
      
    local function v33()  
        local v68 = v32()  
        if v68 then return v68 end  
          
        pcall(function()  
            v9.Remotes.Extras.ReplicateToy:InvokeServer("SprayPaint")  
        end)  
          
        local v69 = tick()  
        while tick() - v69 < 3 do  
            v68 = v32()  
            if v68 then return v68 end  
            v65.wait()  
        end  
        return nil  
    end  
      
    local function v34()  
        local v53 = v12.Character  
        if v53 then  
            for v85, v70 in ipairs(v53:GetChildren()) do  
                if v70:IsA("Tool") then  
                    pcall(function() v70:Destroy() end)  
                end  
            end  
            local v82 = v12:FindFirstChildOfClass("Backpack")  
            if v82 then  
                for v85, v70 in ipairs(v82:GetChildren()) do  
                    if v70:IsA("Tool") then  
                        pcall(function() v70:Destroy() end)  
                    end  
                end  
            end  
              
            local v81 = v53:FindFirstChildOfClass("Humanoid")  
            if v81 then  
                pcall(function()   
                    v81:ChangeState(Enum.HumanoidStateType.Dead)  
                    v81.Health = 0   
                end)  
            end  
        end  
          
        local v83 = nil  
        local v54 = tick()  
          
        while tick() - v54 < 4 do  
            local v71 = v12.Character  
            if v71 and v71 ~= v53 and v71.Parent == workspace then  
                local v81 = v71:FindFirstChildOfClass("Humanoid")  
                local v72 = v71:FindFirstChild("HumanoidRootPart")  
                if v81 and v81.Health > 0 and v72 then  
                    v83 = v71  
                    break  
                end  
            end  
            v65.wait(0.02)  
        end  
          
        if not v83 then  
            local v55  
            local v44 = Instance.new("BindableEvent")  
            v55 = v12.CharacterAdded:Connect(function(v71)  
                v65.spawn(function()  
                    v71:WaitForChild("Humanoid", 3)  
                    v71:WaitForChild("HumanoidRootPart", 3)  
                    if v71.Parent == workspace then  
                        v44:Fire(v71)  
                    else  
                        local v45  
                        v45 = v71.AncestryChanged:Connect(function()  
                            if v71.Parent == workspace then  
                                v45:Disconnect()  
                                v44:Fire(v71)  
                            end  
                        end)  
                        v65.delay(3, function() v45:Disconnect() end)  
                    end  
                end)  
            end)  
              
            v83 = v44.Event:Wait()  
            v55:Disconnect()  
        end  
          
        v83:WaitForChild("HumanoidRootPart", 5)  
        v83:WaitForChild("Humanoid", 5)  
        v65.wait(0.1)  
    end  
      
    local function v35()  
        local v73 = v12.Character and v12.Character:FindFirstChild("HumanoidRootPart")  
        if not v73 then return nil end  
          
        if v19 == "Nearest Player" then  
            local v74, v56 = nil, math.huge  
            local v57 = v73.Position  
              
            for v85, v88 in ipairs(v8:GetPlayers()) do  
                if v88 ~= v12 and v88.Character then  
                    local v93 = v88.Character:FindFirstChild("HumanoidRootPart")  
                    if v93 then  
                        local v96 = (v57 - v93.Position).Magnitude  
                        if v96 < v56 then   
                            v56 = v96   
                            v74 = v88   
                        end  
                    end  
                end  
            end  
            return v74  
        elseif v19 == "Random" then  
            local v46 = {}  
            for v85, v88 in ipairs(v8:GetPlayers()) do  
                if v88 ~= v12 and v88.Character then  
                    v1(v46, v88)  
                end  
            end  
            return #v46 > 0 and v46[math.random(#v46)] or nil  
        else  
            return v20  
        end  
    end  
      
    local function v36(v80, v60, v75)  
        if not v80 or not v80.Character then return end  
          
        local v68 = v33()  
        if not v68 then return end  
          
        local v71 = v12.Character  
        if not v71 or v71.Parent ~= workspace then return end  
          
        local v81 = v71:FindFirstChildOfClass("Humanoid")  
        if v81 and v81.Health > 0 then  
            v68.Parent = v71  
            pcall(function()  
                v81:EquipTool(v68)  
            end)  
        else  
            return  
        end  
          
        local v58 = v75 or v80.Character:FindFirstChild("UpperTorso")   
            or v80.Character:FindFirstChild("Torso")   
            or v80.Character:FindFirstChild("HumanoidRootPart")  
              
        if not v58 then return end  
          
        local v47  
        local v76 = v60  
        if not v76 then  
            local v77 = v24  
            if v77 == "Random" then  
                local v59 = {"Front", "Back", "Right", "Left", "Up"}  
                v77 = v59[math.random(1, #v59)]  
            end  
              
            if v77 == "Front" then  
                v76 = v23 and Enum.NormalId.Back or Enum.NormalId.Front  
            elseif v77 == "Back" then  
                v76 = Enum.NormalId.Back  
            elseif v77 == "Right" then  
                v76 = Enum.NormalId.Right  
            elseif v77 == "Left" then  
                v76 = Enum.NormalId.Left  
            elseif v77 == "Up" then  
                v76 = Enum.NormalId.Top  
            else  
                v76 = v23 and Enum.NormalId.Back or Enum.NormalId.Front  
            end  
        end  
          
        if v76 == Enum.NormalId.Front then  
            v47 = v58.CFrame + v58.CFrame.LookVector * 0.6  
        elseif v76 == Enum.NormalId.Back then  
            v47 = v58.CFrame - v58.CFrame.LookVector * 1.2  
        elseif v76 == Enum.NormalId.Left then  
            v47 = v58.CFrame - v58.CFrame.RightVector * 1.2  
        elseif v76 == Enum.NormalId.Right then  
            v47 = v58.CFrame + v58.CFrame.RightVector * 1.2  
        elseif v76 == Enum.NormalId.Top then  
            v47 = v58.CFrame + v58.CFrame.UpVector * 1.2  
        else  
            v47 = v58.CFrame  
        end  
          
        local v64 = v68:FindFirstChildWhichIsA("RemoteEvent")  
        if v64 then  
            pcall(function()  
                v64:FireServer(v18, v76, 2048, v58, v47)  
            end)  
        end  
          
        if v81 then   
            pcall(function()  
                v81:UnequipTools()   
            end)  
        end  
    end  
      
    local function v37()  
        while v22 do  
            local v93 = v35()  
            if v93 then v36(v93) end  
            v65.wait(14)  
        end  
    end  
      
    v13:AddToggle("Loop Spray Paint", function(v86)  
        if v26 then v26:Destroy() end  
        v22 = v86  
          
        if v86 then  
            local v48 = v4.new()  
            v26 = v48  
            local v61 = v65.spawn(v37)  
            v26:GiveTask(function() v65.cancel(v61) end)  
        end  
    end)  
      
    v5:GiveTask(function() if v26 then v26:Destroy() end end)  
    v13:AddToggle("Spray Behind Target", function(v86) v23 = v86 end)  
    v13:AddDropdown("Target Type", {"Nearest Player", "Random", "Select Player"}, function(v87) v19 = tostring(v87) end)  
    v13:AddPlayerDropdown("Select Player", function(v88) if v88 then v20 = v88 v19 = "Select Player" end end)  
      
    local v62 = {}  
    for v89 in pairs(v16) do v1(v62, v89) end  
      
    v25 = v13:AddDropdown("Select Decal", v62, function(v86)   
        v21 = v86   
        v18 = v16[v86] or 0   
        v17()   
    end)  
      
    v13:AddTextBox("Add Decal (Name:ID)", function(v93)  
        local v92, v90 = v93:match("(.+):(%d+)")  
        if v92 and v90 then  
            v16[v92] = tonumber(v90)  
            local v94 = {}  
            for v89 in pairs(v16) do v1(v94, v89) end  
            v25.Change(v94)  
            v17()  
        end  
    end)  
      
    v13:AddButton("Delete Selected Decal", function()  
        if v21 and v16[v21] then  
            v16[v21] = nil  
            local v95 = {}  
            for v89 in pairs(v16) do v1(v95, v89) end  
            v25.Change(v95)  
            v21 = nil  
            v18 = 0  
            v17()  
        end  
    end)  
      
    v13:AddDropdown("Spray Paint Location", {"Front", "Back", "Right", "Left", "Up", "Random"}, function(v86)  
        v24 = v86  
    end)  
    
    v13:AddToggle("Auto-Get Spray Tool", function(v86)  
        if v30_janitor then v30_janitor:Destroy() end  
        v29 = v86  
          
        if v86 then  
            v30_janitor = v4.new()  
            v30_janitor:GiveTask(v12.CharacterAdded:Connect(function()  
                v65.wait(1.5)  
                pcall(function()  
                    v9.Remotes.Extras.ReplicateToy:InvokeServer("SprayPaint")  
                end)  
            end))  
        end  
    end)  
      
    v5:GiveTask(function() if v30_janitor then v30_janitor:Destroy() end end)  
      
    v13:AddButton("Get Spray Tool", function()  
        pcall(function()  
            v9.Remotes.Extras.ReplicateToy:InvokeServer("SprayPaint")  
        end)  
    end)  
      
    v14:AddButton("Spray Paint Player", function() v36(v35()) end)  
      
    local v38 = false  
    local v39  
      
    local function v40()  
        while v38 do  
            local v43 = {}  
            for v85, v88 in ipairs(v8:GetPlayers()) do  
                if v88 ~= v12 and v88.Character and v88.Character:FindFirstChild("HumanoidRootPart") then  
                    v1(v43, v88)  
                end  
            end  
              
            for v85, v80 in ipairs(v43) do  
                if not v38 then break end  
                if not v8:FindFirstChild(v80.Name) then continue end  
                  
                local v71 = v12.Character  
                local v73 = v71 and v71:FindFirstChild("HumanoidRootPart")  
                local v81 = v71 and v71:FindFirstChildOfClass("Humanoid")  
                if not v71 or not v73 or not v81 or v81.Health <= 0 or v71.Parent ~= workspace then  
                    v34()  
                end  
                  
                if not v80 or not v80.Character or not v80.Character:FindFirstChild("HumanoidRootPart") then  
                    continue  
                end  
                  
                v36(v80)  
                v65.wait(0.02)  
                  
                if v38 then  
                    v34()  
                end  
            end  
            v65.wait(1)  
        end  
    end  
      
    v14:AddToggle("Spray Paint All", function(v86)  
        if v39 then v39:Destroy() end  
        v38 = v86  
          
        if v86 then  
            v39 = v4.new()  
            local v61 = v65.spawn(v40)  
            v39:GiveTask(function() v65.cancel(v61) end)  
        end  
    end)  
      
    v5:GiveTask(function() if v39 then v39:Destroy() end end)  
      
    v14:AddButton("Box Player", function()  
        local v80 = v35()  
        if not v80 then return end  
          
        local v63 = {Enum.NormalId.Front, Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Back, Enum.NormalId.Top}  
          
        v65.spawn(function()  
            for v90, v91 in ipairs(v63) do  
                local v71 = v12.Character  
                local v73 = v71 and v71:FindFirstChild("HumanoidRootPart")  
                local v81 = v71 and v71:FindFirstChildOfClass("Humanoid")  
                if not v71 or not v73 or not v81 or v81.Health <= 0 or v71.Parent ~= workspace then  
                    v34()  
                end  
                  
                if not v80 or not v80.Character or not v80.Character:FindFirstChild("HumanoidRootPart") then  
                    break  
                end  
                  
                v36(v80, v91)  
                v65.wait(0.02)  
                  
                if v90 < #v63 then  
                    v34()  
                end  
            end  
        end)  
    end)  
      
    local v41  
    local v42 = false  
      
    v14:AddToggle("Box All", function(v86)  
        if v41 then v41:Destroy() end  
        v42 = v86  
          
        if v86 then  
            v41 = v4.new()  
            local v61 = v65.spawn(function()  
                while v42 do  
                    local v43 = {}  
                    for v85, v88 in ipairs(v8:GetPlayers()) do  
                        if v88 ~= v12 and v88.Character and v88.Character:FindFirstChild("HumanoidRootPart") then  
                            v1(v43, v88)  
                        end  
                    end  
                      
                    for v85, v80 in ipairs(v43) do  
                        if not v42 then break end  
                        if not v8:FindFirstChild(v80.Name) then continue end  
                          
                        local v63 = {Enum.NormalId.Front, Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Back, Enum.NormalId.Top}  
                          
                        for v90, v91 in ipairs(v63) do  
                            if not v42 then break end  
                              
                            local v71 = v12.Character  
                            local v73 = v71 and v71:FindFirstChild("HumanoidRootPart")  
                            local v81 = v71 and v71:FindFirstChildOfClass("Humanoid")  
                            if not v71 or not v73 or not v81 or v81.Health <= 0 or v71.Parent ~= workspace then  
                                v34()  
                            end  
                              
                            if not v80 or not v80.Character or not v80.Character:FindFirstChild("HumanoidRootPart") then  
                                break  
                            end  
                              
                            v36(v80, v91)  
                            v65.wait(0.02)  
                              
                            if v90 < #v63 then  
                                v34()  
                            end  
                        end  
                        v65.wait(0.1)  
                    end  
                    task.wait(1)  
                end  
            end)  
            v41:GiveTask(function() v65.cancel(v61) end)  
        end  
    end)  
      
    v5:GiveTask(function() if v41 then v41:Destroy() end end)  
      
    v14:AddToggle("Box Player Stealth Mode", function(v86)  
        if v27 then v27:Destroy() end  
          
        if v86 then  
            v27 = v4.new()  
            local function v49(v71)  
                v65.spawn(function()  
                    local v72 = v71:WaitForChild("HumanoidRootPart", 3)  
                    if v72 then v72.CFrame = CFrame.new(0, 2000000, 0) end  
                end)  
            end  
              
            if v12.Character then v49(v12.Character) end  
            v27:GiveTask(v12.CharacterAdded:Connect(v49))  
        end  
    end)  
      
    v5:GiveTask(function() if v27 then v27:Destroy() end end)

    local custom_spray_positions = {}
    local add_custom_mode = false
    local remove_custom_mode = false
    local mouse = v12:GetMouse()

    v14:AddToggle("Add Custom Position", function(state)
        add_custom_mode = state
    end)

    v14:AddToggle("Remove Custom Position", function(state)
        remove_custom_mode = state
    end)

    v14:AddToggle("Remove All Positions", function(state)
        if state then
            table.clear(custom_spray_positions)
        end
    end)

    v14:AddButton("Put (Use with Add/Remove Toggle)", function()
        if add_custom_mode then
            local hit_pos = mouse.Hit
            local target_part = mouse.Target
            
            if hit_pos and target_part then
                v1(custom_spray_positions, {
                    CFrame = hit_pos,
                    Part = target_part
                })
            end
        elseif remove_custom_mode then
            local hit_pos = mouse.Hit
            if not hit_pos then return end
            
            local nearest_idx = nil
            local min_dist = 15
            
            for i, dat in ipairs(custom_spray_positions) do
                local dist = (dat.CFrame.Position - hit_pos.Position).Magnitude
                if dist < min_dist then
                    min_dist = dist
                    nearest_idx = i
                end
            end
            
            if nearest_idx then
                table.remove(custom_spray_positions, nearest_idx)
            end
        end
    end)

    v14:AddButton("Spray Paint Places", function()
        v65.spawn(function()
            for i, dat in ipairs(custom_spray_positions) do
                local char = v12.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if not char or not hrp or not hum or hum.Health <= 0 or char.Parent ~= workspace then
                    v34() 
                end
                
                local target_part = dat.Part
                local target_cframe = dat.CFrame
                
                if not target_part or not target_part.Parent then
                    continue
                end
                
                local tool = v33()
                if tool then
                    char = v12.Character
                    hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if char and hum and hum.Health > 0 then
                        tool.Parent = char
                        pcall(function() hum:EquipTool(tool) end)
                        
                        local remote = tool:FindFirstChildWhichIsA("RemoteEvent")
                        if remote then
                            pcall(function()
                                remote:FireServer(v18, Enum.NormalId.Top, 2048, target_part, target_cframe)
                            end)
                        end
                        
                        pcall(function() hum:UnequipTools() end)
                    end
                end
                
                v65.wait(0.05)
                
                if i < #custom_spray_positions then
                    v34() 
                end
            end
        end)
    end)
end)