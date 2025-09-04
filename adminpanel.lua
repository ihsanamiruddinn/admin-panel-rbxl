-- adminpanel.lua
-- Roblox Admin Panel (flat modern) - KRNL friendly
-- Paste this file to your repo and use:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/adminpanel.lua"))()

-- ======================
-- Helper / Environment
-- ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then return end

-- small utility
local function notify(text, time)
	time = time or 2.5
	local gui = script:FindFirstChild("TMP_NOTIF_CONTAINER")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "TMP_NOTIF_CONTAINER"
		gui.ResetOnSpawn = false
		gui.Parent = game:GetService("CoreGui")
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 300, 0, 36)
	label.Position = UDim2.new(0.5, -150, 0.06, 0)
	label.BackgroundTransparency = 0
	label.BackgroundColor3 = Color3.fromRGB(28,28,28)
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.SourceSansSemibold
	label.TextSize = 16
	label.Text = text
	label.BackgroundTransparency = 0
	label.Parent = gui
	label.ZIndex = 10000

	local corner = Instance.new("UICorner", label)
	corner.CornerRadius = UDim.new(0,8)

	label.TextWrapped = true
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextXAlignment = Enum.TextXAlignment.Center

	label.LayoutOrder = 1
	label.BackgroundTransparency = 0
	label.TextTransparency = 1

	TweenService:Create(label, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
	task.delay(time, function()
		TweenService:Create(label, TweenInfo.new(0.18), {TextTransparency = 1}):Play()
		task.delay(0.22, function() pcall(function() label:Destroy() end) end)
	end)
end

-- ======================
-- State variables
-- ======================
local guiName = "MiniAdminPanel_Flat"
-- avoid duplicate
if game:GetService("CoreGui"):FindFirstChild(guiName) then
	pcall(function() game:GetService("CoreGui")[guiName]:Destroy() end)
end

local panelState = {
	fly = false,
	fling = false,
	flyConn = nil,
	previousSpeed = 16,
	desiredSpeed = 23,
	spawnCFrame = nil
}

-- keep current character refs (update at CharacterAdded)
local function getChar()
	local c = LocalPlayer.Character
	if not c then return nil end
	local h = c:FindFirstChild("Humanoid")
	local root = c:FindFirstChild("HumanoidRootPart")
	return c, h, root
end

-- ensure speed persists after respawn if desired
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local _, hum = getChar()
	if hum and panelState.desiredSpeed then
		pcall(function() hum.WalkSpeed = panelState.desiredSpeed end)
	end
end)

-- ======================
-- Main GUI
-- ======================
local screen = Instance.new("ScreenGui")
screen.Name = guiName
screen.ResetOnSpawn = false
screen.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame", screen)
mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
mainFrame.Position = UDim2.new(0.5,0.5)
mainFrame.Size = UDim2.new(0, 560, 0, 620)
mainFrame.BackgroundColor3 = Color3.fromRGB(12,12,12)
mainFrame.Active = true
mainFrame.ZIndex = 9999

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 14)

-- Header (drag area) with command bar and min/close
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, -24, 0, 72)
header.Position = UDim2.new(0, 12, 0, 12)
header.BackgroundTransparency = 1

local headerBG = Instance.new("Frame", header)
headerBG.BackgroundColor3 = Color3.fromRGB(22,22,22)
headerBG.Size = UDim2.new(1,0,1,0)
headerBG.Position = UDim2.new(0,0,0,0)
headerBG.ZIndex = 10000
local headerCorner = Instance.new("UICorner", headerBG)
headerCorner.CornerRadius = UDim.new(0,10)

local commandBox = Instance.new("TextBox", headerBG)
commandBox.Size = UDim2.new(0.86, -10, 0, 44)
commandBox.Position = UDim2.new(0, 12, 0, 14)
commandBox.PlaceholderText = "Command Bar (prefix: ;)"
commandBox.Font = Enum.Font.SourceSans
commandBox.TextSize = 18
commandBox.TextColor3 = Color3.new(1,1,1)
commandBox.BackgroundColor3 = Color3.fromRGB(28,28,28)
commandBox.ClearTextOnFocus = false
local cmdCorner = Instance.new("UICorner", commandBox)
cmdCorner.CornerRadius = UDim.new(0,8)

local miniBtn = Instance.new("TextButton", headerBG)
miniBtn.Size = UDim2.new(0,28,0,28)
miniBtn.Position = UDim2.new(0.86, 6, 0, 14)
miniBtn.Text = "–"
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 20
miniBtn.BackgroundColor3 = Color3.fromRGB(33,33,33)
local miniCorner = Instance.new("UICorner", miniBtn)
miniCorner.CornerRadius = UDim.new(0,6)

local closeBtn = Instance.new("TextButton", headerBG)
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(0.92, 6, 0, 14)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.BackgroundColor3 = Color3.fromRGB(220,60,60)
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0,6)

-- Content container that can be minimized
local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1, -24, 1, -110)
content.Position = UDim2.new(0, 12, 0, 96)
content.BackgroundTransparency = 1

-- Left and Right columns for big buttons
local leftCol = Instance.new("Frame", content)
leftCol.Size = UDim2.new(0.5, -8, 1, 0)
leftCol.Position = UDim2.new(0,0,0,0)
leftCol.BackgroundTransparency = 1

local rightCol = Instance.new("Frame", content)
rightCol.Size = UDim2.new(0.5, -8, 1, 0)
rightCol.Position = UDim2.new(0.5, 8, 0, 0)
rightCol.BackgroundTransparency = 1

-- function to create big button
local function makeBigBtn(parent, y, text)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, 0, 0, 90)
	btn.Position = UDim2.new(0, 0, 0, y)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 28
	btn.BackgroundColor3 = Color3.fromRGB(34,34,34)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.AutoButtonColor = true
	local cr = Instance.new("UICorner", btn)
	cr.CornerRadius = UDim.new(0,12)
	return btn
end

-- create pairs of big buttons (4 rows x 2 columns)
local spacing = 12
local rowHeight = 90
local leftBtns = {}
local rightBtns = {}

leftBtns[1] = makeBigBtn(leftCol, 0*(rowHeight+spacing), "Fly")
rightBtns[1] = makeBigBtn(rightCol, 0*(rowHeight+spacing), "Unfly")

leftBtns[2] = makeBigBtn(leftCol, 1*(rowHeight+spacing), "Fling / Tendang")
rightBtns[2] = makeBigBtn(rightCol, 1*(rowHeight+spacing), "Unfling")

leftBtns[3] = makeBigBtn(leftCol, 2*(rowHeight+spacing), "Set Spawn")
rightBtns[3] = makeBigBtn(rightCol, 2*(rowHeight+spacing), "Delete Spawn")

-- Speed row: make wide button and small input on right
local speedRow = makeBigBtn(leftCol, 3*(rowHeight+spacing), "Speed Run")
speedRow.Size = UDim2.new(1, -90, 0, rowHeight)
local speedInput = Instance.new("TextBox", leftCol)
speedInput.Size = UDim2.new(0, 80, 0, rowHeight)
speedInput.Position = UDim2.new(1, 6, 0, 3 + 3*(rowHeight+spacing))
speedInput.PlaceholderText = "23"
speedInput.Text = tostring(panelState.desiredSpeed)
speedInput.Font = Enum.Font.SourceSansBold
speedInput.TextSize = 28
speedInput.TextColor3 = Color3.new(1,1,1)
speedInput.BackgroundColor3 = Color3.fromRGB(34,34,34)
local spCorner = Instance.new("UICorner", speedInput)
spCorner.CornerRadius = UDim.new(0,12)

-- bottom row: 4 small square buttons
local bottomRow = Instance.new("Frame", content)
bottomRow.Size = UDim2.new(1,0,0,92)
bottomRow.Position = UDim2.new(0,0,1,-100)
bottomRow.BackgroundTransparency = 1

local function makeSquare(parent, x, labelText)
	local sq = Instance.new("TextButton", parent)
	sq.Size = UDim2.new(0, 88, 0, 88)
	sq.Position = UDim2.new(0, x, 0, 0)
	sq.BackgroundColor3 = Color3.fromRGB(30,30,30)
	local c = Instance.new("UICorner", sq); c.CornerRadius = UDim.new(0,14)
	sq.Font = Enum.Font.SourceSans
	sq.TextSize = 14
	sq.TextColor3 = Color3.new(1,1,1)
	sq.Text = labelText
	return sq
end

local sq1 = makeSquare(bottomRow, 0.055, "Settings")
local sq2 = makeSquare(bottomRow, 0.285, "Commands")
local sq3 = makeSquare(bottomRow, 0.515, "Keybinds")
local sq4 = makeSquare(bottomRow, 0.745, "Add Plugin")

-- small helper frames for modular panels (Settings / Commands / Keybind / Plugins)
local function makeModal(title, bodyText)
	local modal = Instance.new("Frame", screen)
	modal.Size = UDim2.new(0,420,0,360)
	modal.Position = UDim2.new(0.5, -210, 0.5, -180)
	modal.BackgroundColor3 = Color3.fromRGB(20,20,20)
	local c = Instance.new("UICorner", modal); c.CornerRadius = UDim.new(0,10)
	modal.Visible = false
	local header = Instance.new("TextLabel", modal)
	header.Size = UDim2.new(1,0,0,44); header.Position = UDim2.new(0,0,0,0)
	header.BackgroundColor3 = Color3.fromRGB(28,28,28)
	header.Text = title; header.Font = Enum.Font.SourceSansBold; header.TextSize = 18; header.TextColor3 = Color3.new(1,1,1)
	local body = Instance.new("TextLabel", modal)
	body.Size = UDim2.new(1, -20, 1, -70); body.Position = UDim2.new(0,10,0,54)
	body.Text = bodyText; body.TextColor3 = Color3.new(1,1,1); body.Font = Enum.Font.SourceSans; body.TextSize = 14
	body.TextXAlignment = Enum.TextXAlignment.Left; body.TextYAlignment = Enum.TextYAlignment.Top; body.TextWrapped = true
	local close = Instance.new("TextButton", modal)
	close.Size = UDim2.new(0,80,0,32); close.Position = UDim2.new(1,-90,1,-42)
	close.Text = "Close"; close.Font = Enum.Font.SourceSans; close.TextSize = 14
	close.BackgroundColor3 = Color3.fromRGB(50,50,50)
	local cr = Instance.new("UICorner", close); cr.CornerRadius = UDim.new(0,8)
	close.MouseButton1Click:Connect(function() modal.Visible = false end)
	return modal
end

local settingsModal = makeModal("Settings", "Settings panel.\n- Option A\n- Option B\n(Placeholder)")
local commandsModal = makeModal("Commands", "List of available commands:\n;fly ;unfly ;fling ;unfling ;setspawn ;delspawn ;speed <num> ;tp <player> ;gotopart <name>")
local keybindModal = makeModal("Keybinds", "Keybind editor (placeholder)\nYou can bind toggles to keys here.")
local pluginModal = makeModal("Add Plugin", "Place plugin (.iy) files in your exploit workspace folder. (placeholder)")

-- ======================
-- Command parsing (simple)
-- ======================
local prefix = ";"
local function findPlayerByName(name)
	if not name then return nil end
	name = name:lower()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Name:lower():find(name, 1, true) or (p.DisplayName and p.DisplayName:lower():find(name,1,true)) then
			return p
		end
	end
	return nil
end

local function findPartByName(name)
	if not name then return nil end
	local found = workspace:FindFirstChild(name, true)
	if found then return found end
	-- case-insensitive search fallback
	name = name:lower()
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
