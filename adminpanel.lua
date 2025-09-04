local parentGui
if gethui then
    parentGui = gethui()
elseif syn and syn.protect_gui then
    parentGui = Instance.new("ScreenGui")
    syn.protect_gui(parentGui)
    parentGui.Parent = game.CoreGui
elseif game:GetService("CoreGui") then
    parentGui = game:GetService("CoreGui")
else
    parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
ende:lower()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find(name, 1, true) then
			return obj
		end
	end
	return nil
end

local Commands = {
	["fly"] = function(args)
		-- call same as Fly button
		pcall(function() leftBtns[1]:GetAttribute("doClick")() end)
	end,
	["unfly"] = function(args)
		pcall(function() rightBtns[1]:GetAttribute("doClick")() end)
	end,
	["fling"] = function(args)
		pcall(function() leftBtns[2]:GetAttribute("doClick")() end)
	end,
	["unfling"] = function(args)
		pcall(function() rightBtns[2]:GetAttribute("doClick")() end)
	end,
	["setspawn"] = function(args)
		pcall(function() leftBtns[3]:GetAttribute("doClick")() end)
	end,
	["delspawn"] = function(args)
		pcall(function() rightBtns[3]:GetAttribute("doClick")() end)
	end,
	["speed"] = function(args)
		local n = tonumber(args[1])
		if n and n > 0 then
			panelState.desiredSpeed = n
			local _, h = getChar()
			if h then pcall(function() h.WalkSpeed = n end) end
			notify("Speed set to "..n)
		else
			notify("Masukkan angka valid untuk speed")
		end
	end,
	["tp"] = function(args)
		local target = args[1]
		if not target then notify("Masukkan nama player") return end
		local p = findPlayerByName(target)
		if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local _,_, root = getChar()
			if root then root.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0); notify("Teleported to "..p.Name) end
		else
			notify("Player tidak ditemukan")
		end
	end,
	["gotopart"] = function(args)
		local target = args[1]
		if not target then notify("Masukkan nama part") return end
		local part = findPartByName(target)
		if part then
			local _,_, root = getChar()
			if root then root.CFrame = part.CFrame + Vector3.new(0,5,0); notify("Teleported to part "..part.Name) end
		else
			notify("Part tidak ditemukan")
		end
	end
}

commandBox.FocusLost:Connect(function(enter)
	if enter then
		local text = commandBox.Text
		if text == "" then return end
		if string.sub(text,1,#prefix) == prefix then
			local without = string.sub(text,#prefix+1)
			local split = {}
			for s in without:gmatch("%S+") do table.insert(split, s) end
			local cmd = split[1] and split[1]:lower()
			table.remove(split,1)
			if cmd and Commands[cmd] then
				Commands[cmd](split)
			else
				notify("Command tidak ditemukan: "..tostring(cmd))
			end
		else
			-- fallback: just try to send as chat (optional)
			notify("Gunakan prefix '"..prefix.."' untuk command")
		end
		commandBox.Text = ""
	end
end)

-- ======================
-- Button logic (Fly / Fling / Spawn / Speed)
-- ======================

-- safe function to clear physics children
local function clearPhysics(root)
	for _, v in pairs(root:GetChildren()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") then
			pcall(function() v:Destroy() end)
		end
	end
end

-- FLY implementation (with connection)
local function toggleFly(enable)
	local char, hum, root = getChar()
	if not char or not hum or not root then notify("Character not ready") return end
	if enable then
		if panelState.fly then return end
		panelState.fly = true
		-- ensure previous removed
		clearPhysics(root)
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bv.Velocity = Vector3.new()
		bv.Parent = root
		local bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
		bg.Parent = root
		-- store connection
		panelState.flyConn = RunService.RenderStepped:Connect(function()
			if not panelState.fly then return end
			local cam = workspace.CurrentCamera
			local uis = UserInputService
			local dir = Vector3.new()
			if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			-- vertical
			if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
			if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
			if dir.Magnitude > 0.01 then
				dir = dir.Unit * (panelState.desiredSpeed or 50)
			else
				dir = Vector3.new(0,0,0)
			end
			pcall(function() bv.Velocity = dir end)
		end)
		notify("✈ Fly activated")
	else
		panelState.fly = false
		if panelState.flyConn then
			pcall(function() panelState.flyConn:Disconnect() end)
			panelState.flyConn = nil
		end
		if root then clearPhysics(root) end
		notify("✈ Fly disabled")
	end
end

-- FLING implementation (BodyAngularVelocity)
local function toggleFling(enable)
	local char, hum, root = getChar()
	if not char or not hum or not root then notify("Character not ready") return end
	if enable then
		if panelState.fling then return end
		panelState.fling = true
		clearPhysics(root)
		local bav = Instance.new("BodyAngularVelocity")
		bav.MaxTorque = Vector3.new(9e9,9e9,9e9)
		bav.AngularVelocity = Vector3.new(0,120,0)
		bav.Parent = root
		notify("💥 Fling enabled")
	else
		panelState.fling = false
		if root then
			for _, v in pairs(root:GetChildren()) do
				if v:IsA("BodyAngularVelocity") then
					pcall(function() v:Destroy() end)
				end
			end
		end
		notify("💥 Fling disabled")
	end
end

-- Spawn set / delete
local function setSpawnPoint()
	local _,_,root = getChar()
	if root then
		panelState.spawnCFrame = root.CFrame
		notify("📍 Spawn set")
	else
		notify("Character not ready")
	end
end

local function deleteSpawnPoint()
	panelState.spawnCFrame = nil
	notify("📍 Spawn deleted")
end

-- Speed set function
local function setSpeed(n)
	n = tonumber(n)
	if not n or n <= 0 then notify("Masukkan angka speed valid") return end
	panelState.desiredSpeed = n
	local _, hum = getChar()
	if hum then
		pcall(function() hum.WalkSpeed = n end)
	end
	notify("🏃 Speed set to "..n)
end

-- teleport helpers (TP to player & goto part)
local function tpToPlayer(name)
	local p = findPlayerByName(name)
	if not p then notify("Player tidak ditemukan") return end
	if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then notify("Target tidak dapat diakses") return end
	local _,_,root = getChar()
	if root then
		root.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
		notify("🔀 Teleported to "..p.Name)
	end
end

local function gotoPart(name)
	local part = findPartByName(name)
	if not part then notify("Part tidak ditemukan") return end
	local _,_,root = getChar()
	if root then
		root.CFrame = part.CFrame + Vector3.new(0,5,0)
		notify("🧭 Teleported to part "..part.Name)
	end
end

-- ======================
-- Connect UI buttons to functions
-- ======================

-- assign attributes (so Commands parser can call)
leftBtns[1]:SetAttribute("doClick", function() toggleFly(true) end)
rightBtns[1]:SetAttribute("doClick", function() toggleFly(false) end)
leftBtns[2]:SetAttribute("doClick", function() toggleFling(true) end)
rightBtns[2]:SetAttribute("doClick", function() toggleFling(false) end)
leftBtns[3]:SetAttribute("doClick", function() setSpawnPoint() end)
rightBtns[3]:SetAttribute("doClick", function() deleteSpawnPoint() end)

-- local click handlers (also handle visual pressed)
leftBtns[1].MouseButton1Click:Connect(function() toggleFly(true) end)
rightBtns[1].MouseButton1Click:Connect(function() toggleFly(false) end)
leftBtns[2].MouseButton1Click:Connect(function() toggleFling(true) end)
rightBtns[2].MouseButton1Click:Connect(function() toggleFling(false) end)
leftBtns[3].MouseButton1Click:Connect(function() setSpawnPoint() end)
rightBtns[3].MouseButton1Click:Connect(function() deleteSpawnPoint() end)

-- speed input & button behavior: if user edits number and presses Enter, set speed
speedInput.FocusLost:Connect(function(enter)
	if enter then
		local v = tonumber(speedInput.Text)
		if v then
			setSpeed(v)
		else
			notify("Masukkan angka valid")
		end
	end
end)
speedRow.MouseButton1Click:Connect(function() -- clicking label sets default 23
	setSpeed(23)
	speedInput.Text = "23"
end)

-- bottom squares open modals
sq1.MouseButton1Click:Connect(function() settingsModal.Visible = true end)
sq2.MouseButton1Click:Connect(function() commandsModal.Visible = true end)
sq3.MouseButton1Click:Connect(function() keybindModal.Visible = true end)
sq4.MouseButton1Click:Connect(function() pluginModal.Visible = true end)

-- close & minimize behavior
closeBtn.MouseButton1Click:Connect(function()
	pcall(function() screen:Destroy() end)
end)

local minimized = false
miniBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	content.Visible = not minimized
	if minimized then
		miniBtn.Text = "+"
	else
		miniBtn.Text = "–"
	end
end)

-- ======================
-- Dragging (mouse + touch)
-- ======================
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

headerBG.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		dragInput = input
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

headerBG.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- ======================
-- Final touches & initial state
-- ======================
-- small reposition for mobile sensible default
mainFrame.Size = UDim2.new(0,420,0,640)
mainFrame.Position = UDim2.new(0.5, -210, 0.45, -320)

notify("Admin panel loaded — prefix: "..prefix)

-- end of file
