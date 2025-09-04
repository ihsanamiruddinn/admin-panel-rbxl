-- ADMIN PANEL CUSTOM - MOBILE FRIENDLY + NOTIFIKASI
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "MiniAdminPanel"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true

-- NOTIFIKASI
local function notify(msg)
    local notif = Instance.new("TextLabel", gui)
    notif.Size = UDim2.new(0, 250, 0, 30)
    notif.Position = UDim2.new(0.5, -125, 0, 50)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.TextSize = 16
    notif.Font = Enum.Font.SourceSansBold
    notif.Text = msg
    notif.BackgroundTransparency = 0.2
    notif.BorderSizePixel = 0

    game:GetService("TweenService"):Create(notif, TweenInfo.new(0.5), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    task.delay(2, function()
        game:GetService("TweenService"):Create(notif, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.delay(0.6, function() notif:Destroy() end)
    end)
end

-- Utility button
local function makeButton(name, posY, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 280, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- VARIABEL
local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local flyToggled, flingToggled, spawnPoint = false, false, nil

-- === FITUR ===
makeButton("Fly", 10, function()
    if flyToggled then return end
    flyToggled = true
    local bv = Instance.new("BodyVelocity", root)
    bv.Velocity = Vector3.new()
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    local bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    notify("✈️ Fly Activated")

    game:GetService("RunService").RenderStepped:Connect(function()
        if not flyToggled then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.new()
        local uis = game:GetService("UserInputService")
        if uis:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        bv.Velocity = move * 50
    end)
end)

makeButton("Unfly", 50, function()
    flyToggled = false
    for _, v in pairs(root:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
    end
    notify("❌ Fly Disabled")
end)

makeButton("Speed 23", 90, function()
    hum.WalkSpeed = 23
    notify("🏃 Speed set to 23")
end)

makeButton("Fling", 130, function()
    if flingToggled then return end
    flingToggled = true
    local fling = Instance.new("BodyAngularVelocity", root)
    fling.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    fling.AngularVelocity = Vector3.new(0, 99999, 0)
    notify("💥 Fling Activated")
end)

makeButton("Unfling", 170, function()
    flingToggled = false
    for _, v in pairs(root:GetChildren()) do
        if v:IsA("BodyAngularVelocity") then v:Destroy() end
    end
    notify("❌ Fling Disabled")
end)

makeButton("Rejoin", 210, function()
    notify("🔄 Rejoining...")
    game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
end)

makeButton("Set Spawn", 250, function()
    spawnPoint = root.CFrame
    notify("📍 Spawn Point Set")
end)

makeButton("Goto Spawn", 290, function()
    if spawnPoint then
        root.CFrame = spawnPoint
        notify("📍 Returned to Spawn Point")
    else
        notify("⚠️ No spawn point set")
    end
end)

-- === INPUT BAR PLAYER ===
local playerBox = Instance.new("TextBox", frame)
playerBox.Size = UDim2.new(0, 200, 0, 30)
playerBox.Position = UDim2.new(0, 10, 0, 340)
playerBox.PlaceholderText = "Nama Player"
playerBox.Text = ""
playerBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
playerBox.TextColor3 = Color3.new(1,1,1)

local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(0, 80, 0, 30)
tpBtn.Position = UDim2.new(0, 220, 0, 340)
tpBtn.Text = "TP"
tpBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
tpBtn.TextColor3 = Color3.new(1,1,1)

tpBtn.MouseButton1Click:Connect(function()
    local target = game.Players:FindFirstChild(playerBox.Text)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
        notify("🔀 Teleported to "..target.Name)
    else
        notify("⚠️ Player not found")
    end
end)

-- === INPUT BAR PART ===
local partBox = Instance.new("TextBox", frame)
partBox.Size = UDim2.new(0, 200, 0, 30)
partBox.Position = UDim2.new(0, 10, 0, 380)
partBox.PlaceholderText = "Nama Part"
partBox.Text = ""
partBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
partBox.TextColor3 = Color3.new(1,1,1)

local partBtn = Instance.new("TextButton", frame)
partBtn.Size = UDim2.new(0, 80, 0, 30)
partBtn.Position = UDim2.new(0, 220, 0, 380)
partBtn.Text = "Goto"
partBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
partBtn.TextColor3 = Color3.new(1,1,1)

partBtn.MouseButton1Click:Connect(function()
    local part = workspace:FindFirstChild(partBox.Text, true)
    if part and part:IsA("BasePart") then
        root.CFrame = part.CFrame + Vector3.new(0,5,0)
        notify("🧩 Teleported to Part: "..part.Name)
    else
        notify("⚠️ Part not found")
    end
end)