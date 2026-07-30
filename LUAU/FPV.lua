-- HI SKID :)
local v1, v2, v3, v4, v92 = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("SoundService"), game:GetService("Debris")
local v5, v6 = v1.LocalPlayer, workspace.CurrentCamera
local v7 = v5:WaitForChild("PlayerScripts")
local v8 = v7:WaitForChild("PlayerModule")
local v9 = require(v8):GetControls()
local v10, v11, v12, v13, v14 = false, Vector3.new(), CFrame.new(), Vector3.new(), Vector3.new()
local v15, v16, v17 = 80, 8, 0.95
local v18, v19 = 0, 80
local v20, v21, v22, v93
local v23, v24, v27, v29, v30
local v84 = RaycastParams.new()
local v89 = {"138817960173178", "114519021371172", "108753671021202", "112882659630233", "99436839773375", "124695435769496", "128763165071133"}
-- Handler shit stuff related
local function v31()
	v20, v21, v22, v93 = Instance.new("Sound"), Instance.new("Sound"), Instance.new("Sound"), Instance.new("Sound")
	v20.Name, v20.SoundId, v20.Looped, v20.Volume, v20.Parent = "DroneIdleSFX", "rbxassetid://117540327070109", true, 0, v4
	v21.Name, v21.SoundId, v21.Looped, v21.Volume, v21.PlaybackSpeed, v21.Parent = "DroneFlySFX", "rbxassetid://136704576012970", true, 0, 0.8, v4
	v22.Name, v22.SoundId, v22.Looped, v22.Volume, v22.Parent = "DroneHitSFX", "rbxassetid://139520673393967", false, 1, v4
	v93.Name, v93.SoundId, v93.Looped, v93.Volume, v93.Parent = "DroneClickSFX", "rbxassetid://139695696073793", false, 1, v4
end
v31()
local function v32()
	v84.FilterType, v84.RespectCanCollide = Enum.RaycastFilterType.Exclude, true
	v23 = Instance.new("ScreenGui")
	v23.Name, v23.ResetOnSpawn, v23.IgnoreGuiInset, v23.DisplayOrder, v23.ZIndexBehavior = "DroneHUD", false, true, 2147483647, Enum.ZIndexBehavior.Sibling
	local v33 = if gethui then gethui() else v5:WaitForChild("PlayerGui")
	v23.Parent = v33
	v24 = Instance.new("Frame")
	v24.Size, v24.BackgroundTransparency, v24.Visible, v24.ZIndex, v24.Parent = UDim2.new(1, 0, 1, 0), 1, false, 2147483647, v23
	local v34 = Instance.new("ImageLabel")
	v34.Size, v34.BackgroundTransparency, v34.Image, v34.ImageColor3, v34.ImageTransparency, v34.ZIndex, v34.Parent = UDim2.new(1, 0, 1, 0), 1, "rbxassetid://4576475446", Color3.fromRGB(0, 0, 0), 0.2, 2147483647, v24
	local v35 = Instance.new("ImageLabel")
	v35.Size, v35.Position, v35.BackgroundTransparency, v35.Image, v35.ZIndex, v35.Parent = UDim2.new(0, 64, 0, 64), UDim2.new(0.5, -32, 0.5, -32), 1, "rbxassetid://9524023207", 2147483647, v24
	local v36 = Instance.new("Frame")
	v36.Size, v36.Position, v36.BackgroundTransparency, v36.ZIndex, v36.Parent = UDim2.new(0, 120, 0, 40), UDim2.new(0, 10, 0, 10), 1, 2147483647, v24
	v29 = Instance.new("ImageLabel")
	v29.Size, v29.Position, v29.BackgroundTransparency, v29.Image, v29.ZIndex, v29.Parent = UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 1, "rbxassetid://123502662921632", 2147483647, v36
	local v37, v38, v39 = Instance.new("ImageButton"), Instance.new("ImageButton"), Instance.new("ImageButton")
	v37.Size, v37.Position, v37.BackgroundTransparency, v37.ZIndex, v37.Parent = UDim2.new(0.33, 0, 1, 0), UDim2.new(0, 0, 0, 0), 1, 2147483647, v36
	v38.Size, v38.Position, v38.BackgroundTransparency, v38.ZIndex, v38.Parent = UDim2.new(0.34, 0, 1, 0), UDim2.new(0.33, 0, 0, 0), 1, 2147483647, v36
	v39.Size, v39.Position, v39.BackgroundTransparency, v39.ZIndex, v39.Parent = UDim2.new(0.33, 0, 1, 0), UDim2.new(0.67, 0, 0, 0), 1, 2147483647, v36
	v37.MouseButton1Click:Connect(function()
		v29.Image, v18 = "rbxassetid://119725161346101", -1
	end)
	v38.MouseButton1Click:Connect(function()
		v29.Image, v18 = "rbxassetid://123502662921632", 0
	end)
	v39.MouseButton1Click:Connect(function()
		v29.Image, v18 = "rbxassetid://130547561514059", 1
	end)
	local v40 = Instance.new("Frame")
	v40.Size, v40.Position, v40.BackgroundTransparency, v40.ZIndex, v40.Parent = UDim2.new(0, 180, 0, 30), UDim2.new(1, -185, 1, -35), 1, 2147483647, v24
	v27 = Instance.new("TextLabel")
	v27.Size, v27.Position, v27.BackgroundTransparency, v27.Text, v27.TextColor3, v27.TextSize, v27.Font, v27.TextStrokeTransparency, v27.TextStrokeColor3, v27.TextXAlignment, v27.ZIndex, v27.Parent = UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 1, "SPD: 0.0m/s", Color3.fromRGB(255, 255, 255), 15, Enum.Font.RobotoMono, 0.35, Color3.fromRGB(0, 0, 0), Enum.TextXAlignment.Right, 2147483647, v40
	v30 = Instance.new("ImageButton")
	v30.Size, v30.Position, v30.BackgroundTransparency, v30.Image, v30.ZIndex, v30.Parent = UDim2.new(0, 50, 0, 50), UDim2.new(0.5, -25, 0.92, -25), 1, "rbxassetid://117548703728060", 2147483647, v23
end
v32()
local function v42(v43)
	v93:Play()
	v10, v24.Visible = v43, v43
	v30.Image = if v43 then "rbxassetid://95460951309516" else "rbxassetid://117548703728060"
	local v44 = v5.Character
	if v44 then
		local v45, v46 = v44:FindFirstChildOfClass("Humanoid"), v44:FindFirstChild("HumanoidRootPart")
		if v45 and v46 then
			v46.Anchored = v43
		end
	end
	if v43 then
		v6.CameraType = Enum.CameraType.Scriptable
		if v5.Character and v5.Character:FindFirstChild("Head") then
			v11 = v5.Character.Head.Position + Vector3.new(0, 3, 0)
		else
			v11 = v6.CFrame.Position
		end
		v12, v13, v14, v18, v19, v29.Image = v6.CFrame.Rotation, Vector3.new(), Vector3.new(), 0, 80, "rbxassetid://123502662921632"
		v20:Play()
		v21:Play()
	else
		v6.CameraType = Enum.CameraType.Custom
		if v5.Character and v5.Character:FindFirstChildOfClass("Humanoid") then
			v6.CameraSubject = v5.Character:FindFirstChildOfClass("Humanoid")
		end
		v20:Stop()
		v21:Stop()
	end
end
v5.CharacterAdded:Connect(function(v86)
	if v10 then
		task.wait(0.1)
		local v87 = v86:WaitForChild("HumanoidRootPart", 5)
		if v87 then
			v87.Anchored = true
		end
	end
end)
v30.MouseButton1Click:Connect(function()
	v42(not v10)
end)
v3.InputBegan:Connect(function(v47, v48)
	if v48 then return end
	if v47.KeyCode == Enum.KeyCode.F then
		v42(not v10)
	end
end)
v3.InputChanged:Connect(function(v49, v50)
	if not v10 then return end
	local v51, v52 = 0, 0
	if v49.UserInputType == Enum.UserInputType.MouseMovement then
		v51, v52 = v49.Delta.X * 0.0035, v49.Delta.Y * 0.0035
	elseif v49.UserInputType == Enum.UserInputType.Touch then
		if v49.Position.X > (v6.ViewportSize.X * 0.35) then
			v51, v52 = v49.Delta.X * 0.0045, v49.Delta.Y * 0.0045
		end
	end
	if v51 ~= 0 or v52 ~= 0 then
		v12 = v12 * CFrame.Angles(-v52, -v51, 0)
	end
end)
v2.RenderStepped:Connect(function(v54)
	if not v10 then return end
	local v55 = v9:GetMoveVector()
	local v56, v57 = v55.X, v55.Z
	if v56 == 0 and v57 == 0 then
		if v3:IsKeyDown(Enum.KeyCode.W) then v57 = v57 - 1 end
		if v3:IsKeyDown(Enum.KeyCode.S) then v57 = v57 + 1 end
		if v3:IsKeyDown(Enum.KeyCode.A) then v56 = v56 - 1 end
		if v3:IsKeyDown(Enum.KeyCode.D) then v56 = v56 + 1 end
	end
	local v58, v59 = v12.LookVector, v12.RightVector
	local v60 = Vector3.new()
	if math.abs(v56) > 0.05 or math.abs(v57) > 0.05 then
		v60 = (v58 * (-v57) + v59 * v56)
		if v60.Magnitude > 0 then
			v60 = v60.Unit
		end
	end
	local v61 = v60 * v15
	local v88 = math.clamp(v54 * v16, 0, 1)
	v14 = v14:Lerp(v61, v88)
	v13 = v13:Lerp(v14, v88) * v17
	local v62 = v13 * v54
	if v62.Magnitude > 0.001 then
		local v64 = {}
		if v5.Character then
			table.insert(v64, v5.Character)
		end
		local v65, v66, v85 = nil, v62 + v62.Unit * 0.8, 0
		while v85 < 8 do
			v85 = v85 + 1
			v84.FilterDescendantsInstances = v64
			local v67 = workspace:Raycast(v11, v66, v84)
			if not v67 then break end
			local v68 = v67.Instance
			if v68 and (v68.Transparency > 0.98 or not v68.CanCollide) then
				table.insert(v64, v68)
			else
				v65 = v67
				break
			end
		end
		if v65 then
			local v69 = v13.Magnitude
			local v68 = v65.Instance
			if v68 and v68.Transparency >= 0.4 and v68.Transparency <= 0.9 and v69 >= 40 then
				local v90 = v89[math.random(1, #v89)]
				local v91 = Instance.new("Sound")
				v91.SoundId, v91.Volume, v91.Parent = "rbxassetid://" .. v90, 1, v4
				v91:Play()
				v92:AddItem(v91, 3)
				v68:Destroy()
				v11 = v11 + v62
			else
				v22.PlaybackSpeed = math.clamp(0.8 + (v69 / v15) * 1.5, 0.7, 2.5)
				v22.Volume = math.clamp(v69 / v15, 0.3, 1)
				v22:Play()
				v11 = v65.Position + v65.Normal * 0.6
				v13 = v13 - 1.35 * (v13:Dot(v65.Normal)) * v65.Normal
				v14 = Vector3.new()
			end
		else
			v11 = v11 + v62
		end
	end
	local v70 = v13.Magnitude
	local v71 = math.clamp(v70 / v15, 0, 1)
	v20.Volume = math.clamp(1 - v71 * 1.2, 0.15, 1)
	v20.PlaybackSpeed = 1 + v71 * 0.3
	v21.Volume = math.clamp(v71 * 1.2, 0, 1)
	v21.PlaybackSpeed = 0.8 + v71 * 1.4
	if v18 == -1 then
		v19 = math.max(15, v19 - v54 * 35)
	elseif v18 == 1 then
		v19 = math.min(110, v19 + v54 * 35)
	end
	v6.CFrame = CFrame.new(v11) * v12
	v6.FieldOfView = math.clamp(v19 + v71 * 8, 15, 120)
	v27.Text = string.format("SPEED: %.1fm/s", v70)
end)
