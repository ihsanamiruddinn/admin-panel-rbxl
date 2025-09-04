-- adminpanel.lua
-- Compact Admin Panel (IY-like size) - KRNL friendly
-- Paste to repo, call via:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/adminpanel.lua"))()

-- ========== ENV & HELPERS ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- notification helper (lightweight)
local function notify(text, time)
	time = time or 2.2
	local container = workspace:FindFirstChild("__AdminNotifContainer")
	if not container then
		container = Instance.new("Folder")
		container.Name = "__AdminNotifContainer"
		container.Parent = game:GetService("CoreGui")
	end
	local sg = Instance.new("ScreenGui")
	sg.Name = "TMP_NOTIF"
	sg.ResetOnSpawn = false
	sg.Parent = container

	local lbl = Instance.new("TextLabel", sg)
	lbl.Size = UDim2.new(0, 230, 0, 34)
	lbl.Position = UDim2.new(0.5, -115, 0.08, 0)
	lbl.BackgroundColor3 = Color3.fromRGB(28,28,28)
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Text = text
	lbl.Font = Enum.Font.SourceSansSemibold
	lbl.TextSize = 16
	lbl.ZIndex = 50
	lbl.TextWrapped = true
	local c = Instance.new("UICorner", lbl); c.CornerRadius = UDim.new(0,8)
	lbl.Parent = sg

	lbl.TextTransparency = 1
	TweenService:Create(lbl, TweenInfo.new(0.14), {TextTransparency = 0}):Play()
	task.delay(time, function()
		TweenService:Create(lbl, TweenInfo.new(0.12), {TextTransparency = 1}):Play()
		task.delay(0.14, function() pcall(function() sg:Destroy() end) end)
	end)
end

-- ========== PARENT GUI (auto-detect for KRNL) ==========
local parentGui
if type(gethui) == "function" then
	pcall(function() parentGui = gethui() end)
end
if not parentGui then
	-- try syn.protect_gui approach then parent to CoreGui
	if syn and syn.protect_gui then
		local s = Instance.new("ScreenGui")
		s.Name = "AdminPanel_Protected"
		s.Parent = game:GetService("CoreGui")
		pcall(function() syn.protect_gui(s) end)
		parentGui = s
	end
end
if not parentGui then
	-- fallback to PlayerGui (safe)
	parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- clear old if exists
local EXIST_NAME = "MiniAdminPanel_Compact"
if parentGui:FindFirstChild(EXIST_NAME) then
	pcall(function() parentGui[EXIST_NAME]:Destroy() end)
end

-- ========== STATE ==========
local state = {
	fly = false,
	fling = false,
	flyConn = nil,
	desiredSpeed = 23,
	spawnCFrame = nil
}

-- helper to get character references
local function getChar()
	local c = LocalPlayer.Character
	if not c then return nil end
	local hum = c:FindFirstChild("Humanoid")
	local root = c:FindFirstChild("HumanoidRootPart")
	return c, hum, root
end

-- persist speed after respawn
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.45)
	local _, hum = getChar()
	if hum and state.desiredSpeed then
		pcall(function() hum.WalkSpeed = state.desiredSpeed end)
	end
end)

-- ========== BUILD GUI (compact IY-like size) ==========
local screen = Instance.new("ScreenGui")
screen.Name = EXIST_NAME
screen.ResetOnSpawn = false
screen.Parent = parentGui

local frame = Instance.new("Frame", screen)
frame.Name = "Main"
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(36,36,37)
frame.Active = true
frame.ZIndex = 9999
local frameCorner = Instance.new("UICorner", frame); frameCorner.CornerRadius = UDim.new(0,10)

-- Header (command bar + min/close)
local header = Instance.new("Frame", frame)
header.Name = "Header"
header.Size = UDim2.new(1, -12, 0, 36)
header.Position = UDim2.new(0, 6, 0, 6)
header.BackgroundTransparency = 1

local headerBG = Instance.new("Frame", header)
headerBG.Size = UDim2.new(1, 0, 1, 0)
headerBG.Position = UDim2.new(0,0,0,0)
headerBG.BackgroundColor3 = Color3.fromRGB(28,28,28)
local headerCorner = Instance.new("UICorner", headerBG); headerCorner.CornerRadius = UDim.new(0,8)

local cmdBox = Instance.new("TextBox", headerBG)
cmdBox.Size = UDim2.new(0.76, 0, 0, 28)
cmdBox.Position = UDim2.new(0, 8, 0, 4)
cmdBox.PlaceholderText = "Command Bar (prefix: ;)"
cmdBox.ClearTextOnFocus = false
cmdBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
cmdBox.Font = Enum.Font.SourceSans
cmdBox.TextSize = 14
cmdBox.TextColor3 = Color3.new(1,1,1)
local cmdCorner = Instance.new("UICorner", cmdBox); cmdCorner.CornerRadius = UDim.new(0,6)

local btnMin = Instance.new("TextButton", headerBG)
btnMin.Size = UDim2.new(0,28,0,28)
btnMin.Position = UDim2.new(0.78, 8, 0, 4)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 18
btnMin.BackgroundColor3 = Color3.fromRGB(36,36,36)
local minCorner = Instance.new("UICorner", btnMin); minCorner.CornerRadius = UDim.new(0,6)

local btnClose = Instance.new("TextButton", headerBG)
btnClose.Size = UDim2.new(0,28,0,28)
btnClose.Position = UDim2.new(0.9, 8, 0, 4)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 16
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
local closeCorner = Instance.new("UICorner", btnClose); closeCorner.CornerRadius = UDim.new(0,6)

-- content area
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1, -12, 1, -60)
content.Position = UDim2.new(0, 6, 0, 48)
content.BackgroundTransparency = 1

-- left & right columns
local leftCol = Instance.new("Frame", content)
leftCol.Size = UDim2.new(0.5, -6, 1, -46)
leftCol.Position = UDim2.new(0, 0, 0, 0)
leftCol.BackgroundTransparency = 1

local rightCol = Instance.new("Frame", content)
rightCol.Size = UDim2.new(0.5, -6, 1, -46)
rightCol.Position = UDim2.new(0.5, 6, 0, 0)
rightCol.BackgroundTransparency = 1

-- small function to create compact big button (height 40)
local function makeBtn(parent, top, text)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1, 0, 0, 40)
	b.Position = UDim2.new(0, 0, 0, top)
	b.BackgroundColor3 = Color3.fromRGB(44,44,44)
	b.Text = text
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	b.TextColor3 = Color3.new(1,1,1)
	local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,8)
	return b
end

local gap = 8
local rowh = 40

local Lbtn1 = makeBtn(leftCol, 0*(rowh+gap), "Fly")
local Rbtn1 = makeBtn(rightCol, 0*(rowh+gap), "Unfly")
local Lbtn2 = makeBtn(leftCol, 1*(rowh+gap), "Fling")
local Rbtn2 = makeBtn(rightCol, 1*(rowh+gap), "Unfling")
local Lbtn3 = makeBtn(leftCol, 2*(rowh+gap), "Set Spawn")
local Rbtn3 = makeBtn(rightCol, 2*(rowh+gap), "Delete Spawn")
-- Speed row: left has the button, right column can hold the input area
local speedBtn = makeBtn(leftCol, 3*(rowh+gap), "Speed 23")
speedBtn.Size = UDim2.new(1, -86, 0, 40)
local speedInput = Instance.new("TextBox", leftCol)
speedInput.Size = UDim2.new(0, 78, 0, 40)
speedInput.Position = UDim2.new(1, -78, 0, 3 + 3*(rowh+gap))
speedInput.PlaceholderText = "23"
speedInput.Text = tostring(state.desiredSpeed)
speedInput.BackgroundColor3 = Color3.fromRGB(44,44,44)
speedInput.Font = Enum.Font.SourceSans
speedInput.TextSize = 16
speedInput.TextColor3 = Color3.new(1,1,1)
local spc = Instance.new("UICorner", speedInput); spc.CornerRadius = UDim.new(0,8)

-- bottom small squares (4)
local bottomRow = Instance.new("Frame", content)
bottomRow.Size = UDim2.new(1, 0, 0, 40)
bottomRow.Position = UDim2.new(0, 0, 1, -40)
bottomRow.BackgroundTransparency = 1

local function makeSquare(parent, x, label)
	local s = Instance.new("TextButton", parent)
	s.Size = UDim2.new(0, 40, 0, 40)
	s.Position = UDim2.new(x, 0, 0, 0)
	s.BackgroundColor3 = Color3.fromRGB(30,30,30)
	s.Text = label
	s.Font = Enum.Font.SourceSans
	s.TextSize = 12
	s.TextColor3 = Color3.new(1,1,1)
	local c = Instance.new("UICorner", s); c.CornerRadius = UDim.new(0,8)
	return s
end

local sm1 = makeSquare(bottomRow, 0.06, "Settings")
local sm2 = makeSquare(bottomRow, 0.32, "Commands")
local sm3 = makeSquare(bottomRow, 0.58, "Keybinds")
local sm4 = makeSquare(bottomRow, 0.84, "Plugins")

-- small modals
local function makeModal(title, contentText)
	local m = Instance.new("Frame", screen)
	m.Size = UDim2.new(0, 240, 0, 160)
	m.Position = UDim2.new(0.5, -120, 0.5, -80)
	m.BackgroundColor3 = Color3.fromRGB(22,22,22)
	local c = Instance.new("UICorner", m); c.CornerRadius = UDim.new(0,8)
	m.Visible = false
	local h = Instance.new("TextLabel", m)
	h.Size = UDim2.new(1,0,0,30); h.Position = UDim2.new(0,0,0,0)
	h.BackgroundColor3 = Color3.fromRGB(26,26,26)
	h.Text = title; h.Font = Enum.Font.SourceSansBold; h.TextSize = 14; h.TextColor3 = Color3.new(1,1,1)
	local body = Instance.new("TextLabel", m)
	body.Size = UDim2.new(1,-16,1,-60); body.Position = UDim2.new(0,8,0,36)
	body.Text = contentText; body.Font = Enum.Font.SourceSans; body.TextSize = 13; body.TextWrapped = true; body.TextColor3 = Color3.new(1,1,1)
	local close = Instance.new("TextButton", m); close.Size = UDim2.new(0,70,0,28); close.Position = UDim2.new(1,-78,1,-36); close.Text="Close"; close.Font=Enum.Font.SourceSans; close.TextSize=13; close.BackgroundColor3=Color3.fromRGB(40,40,40)
	local cc = Instance.new("UICorner", close); cc.CornerRadius = UDim.new(0,6)
	close.MouseButton1Click:Connect(function() m.Visible = false end)
	return m
end

local modalSettings = makeModal("Settings", "Settings placeholder")
local modalCommands = makeModal("Commands", "Commands:\n;fly ;unfly ;fling ;unfling ;setspawn ;delspawn ;speed <num> ;tp <player> ;gotopart <name>")
local modalKeybinds = makeModal("Keybinds", "Keybind editor placeholder")
local modalPlugins = makeModal("Plugins", "Add plugins (.iy) via exploit workspace (placeholder)")

-- ========== COMMAND PARSER ==========
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
	local f = workspace:FindFirstChild(name, true)
	if f then return f end
	name = name:lower()
	for _, d in pairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") and d.Name:lower():find(name,1,true) then return d end
	end
	return nil
end

local Commands = {}
Commands["fly"] = function() pcall(function() Lbtn1:Fire() end) end
Commands["unfly"] = function() pcall(function() Rbtn1:Fire() end) end
Commands["fling"] = function() pcall(function() Lbtn2:Fire() end) end
Commands["unfling"] = function() pcall(function() Rbtn2:Fire() end) end
Commands["setspawn"] = function() pcall(function() Lbtn3:Fire() end) end
Commands["delspawn"] = function() pcall(function() Rbtn3:Fire() end) end
Commands["speed"] = function(args) if tonumber(args[1]) then state.desiredSpeed = tonumber(args[1]); local _,h = getChar(); if h then pcall(function() h.WalkSpeed = state.desiredSpeed end) end; notify("Speed set to "..tostring(state.desiredSpeed)) else notify("Masukkan angka valid") end end
Commands["tp"] = function(args) if args[1] then local p = findPlayerByName(args[1]); if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local _,_,r = getChar(); if r then r.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0); notify("Teleported to "..p.Name) end else notify("Player tidak ditemukan") end else notify("Masukkan target") end end
Commands["gotopart"] = function(args) if args[1] then local part = findPartByName(args[1]); if part then local _,_,r = getChar(); if r then r.CFrame = part.CFrame + Vector3.new(0,5,0); notify("Teleported to part "..part.Name) end else notify("Part tidak ditemukan") end else notify("Masukkan nama part") end end

cmdBox.FocusLost:Connect(function(enter)
	if not enter then return end
	local text = cmdBox.Text
	if text == "" then return end
	if text:sub(1, #prefix) == prefix then
		local body = text:sub(#prefix+1)
		local parts = {}
		for w in body:gmatch("%S+") do table.insert(parts, w) end
		local cmd = parts[1] and parts[1]:lower()
		table.remove(parts,1)
		if cmd and Commands[cmd] then
			pcall(function() Commands[cmd](parts) end)
		else
			notify("Command tidak ditemukan: "..tostring(cmd))
		end
	else
		notify("Gunakan prefix '"..prefix.."' untuk command")
	end
	cmdBox.Text = ""
end)

-- ========== PHYSICS HELPERS ==========
local function clearPhysics(root)
	for _, v in pairs(root:GetChildren()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") then
			pcall(function() v:Destroy() end)
		end
	end
end

-- FLY toggle (safe connection handling)
local function toggleFly(enable)
	local char, hum, root = getChar()
	if not char or not hum or not root then notify("Character not ready") return end
	if enable then
		if state.fly then return end
		state.fly = true
		clearPhysics(root)
		local bv = Instance.new("BodyVelocity", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bv.Velocity = Vector3.new()
		local bg = Instance.new("BodyGyro", root)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
		state.flyConn = RunService.RenderStepped:Connect(function()
			if not state.fly then return end
			local cam = workspace.CurrentCamera
			local uis = UserInputService
			local dir = Vector3.new()
			if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
			if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
			if dir.Magnitude > 0.01 then dir = dir.Unit * (state.desiredSpeed or 50) else dir = Vector3.new(0,0,0) end
			pcall(function() bv.Velocity = dir end)
		end)
		notify("✈ Fly activated")
	else
		state.fly = false
		if state.flyConn then pcall(function() state.flyConn:Disconnect() end) state.flyConn = nil end
		local _,_,root2 = getChar()
		if root2 then clearPhysics(root2) end
		notify("✈ Fly disabled")
	end
end

-- FLING toggle
local function toggleFling(enable)
	local char, hum, root = getChar()
	if not char or not hum or not root then notify("Character not ready") return end
	if enable then
		if state.fling then return end
		state.fling = true
		clearPhysics(root)
		local bav = Instance.new("BodyAngularVelocity", root)
		bav.MaxTorque = Vector3.new(9e9,9e9,9e9)
		bav.AngularVelocity = Vector3.new(0,120,0)
		notify("💥 Fling enabled")
	else
		state.fling = false
		local _,_,root2 = getChar()
		if root2 then
			for _, v in pairs(root2:GetChildren()) do
				if v:IsA("BodyAngularVelocity") then pcall(function() v:Destroy() end) end
			end
		end
		notify("💥 Fling disabled")
	end
end

-- spawn control
local function setSpawn()
	local _,_,root = getChar()
	if root then state.spawnCFrame = root.CFrame; notify("📍 Spawn set") else notify("Character not ready") end
end
local function delSpawn()
	state.spawnCFrame = nil; notify("📍 Spawn deleted")
end

-- set speed
local function setSpeed(n)
	n = tonumber(n)
	if not n or n <= 0 then notify("Masukkan angka valid") return end
	state.desiredSpeed = n
	local _, hum = getChar()
	if hum then pcall(function() hum.WalkSpeed = n end) end
	notify("🏃 Speed set to "..tostring(n))
end

-- tp & goto part helpers
local function tpToPlayer(name)
	local p = findPlayerByName(name)
	if not p then notify("Player tidak ditemukan") return end
	if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then notify("Target tidak dapat diakses") return end
	local _,_,r = getChar()
	if r then r.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0); notify("Teleported to "..p.Name) end
end
local function gotoPart(name)
	local part = findPartByName(name)
	if not part then notify("Part tidak ditemukan") return end
	local _,_,r = getChar()
	if r then r.CFrame = part.CFrame + Vector3.new(0,5,0); notify("Teleported to part "..part.Name) end
end

-- ========== WIRE BUTTONS ==========
-- Use MouseButton1Click to call functions
Lbtn1.MouseButton1Click:Connect(function() toggleFly(true) end)
Rbtn1.MouseButton1Click:Connect(function() toggleFly(false) end)
Lbtn2.MouseButton1Click:Connect(function() toggleFling(true) end)
Rbtn2.MouseButton1Click:Connect(function() toggleFling(false) end)
Lbtn3.MouseButton1Click:Connect(function() setSpawn() end)
Rbtn3.MouseButton1Click:Connect(function() delSpawn() end)

speedBtn.MouseButton1Click:Connect(function() setSpeed(23); speedInput.Text = "23" end)
speedInput.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(speedInput.Text)
		if val then setSpeed(val) else notify("Masukkan angka valid") end
	end
end)

sm1.MouseButton1Click:Connect(function() modalSettings.Visible = true end)
sm2.MouseButton1Click:Connect(function() modalCommands.Visible = true end)
sm3.MouseButton1Click:Connect(function() modalKeybinds.Visible = true end)
sm4.MouseButton1Click:Connect(function() modalPlugins.Visible = true end)

-- close & minimize
btnClose.MouseButton1Click:Connect(function() pcall(function() screen:Destroy() end) end)
local minimized = false
btnMin.MouseButton1Click:Connect(function()
	minimized = not minimized
	content.Visible = not minimized
	if minimized then btnMin.Text = "+" else btnMin.Text = "–" end
end)

-- ========== DRAGGING SUPPORT ==========
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

headerBG.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		dragInput = input
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
headerBG.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then update(input) end
end)

-- ========== FINALIZE ==========
notify("Admin panel loaded — prefix: "..prefix)
-- end of file
