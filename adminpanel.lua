-- GUI TripleS dengan tombol SSS (pojok kanan atas + animasi)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- parent
local parentGui
pcall(function() if typeof(gethui) == "function" then parentGui = gethui() end end)
if not parentGui and syn and syn.protect_gui then
    local s = Instance.new("ScreenGui")
    syn.protect_gui(s)
    s.Parent = game:GetService("CoreGui")
    parentGui = s
end
if not parentGui then parentGui = lp:WaitForChild("PlayerGui") end

-- cleanup
local old = parentGui:FindFirstChild("TripleSUI")
if old then old:Destroy() end

-- screen
local screen = Instance.new("ScreenGui")
screen.Name = "TripleSUI"
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- frame utama
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 280, 0, 340)
frame.Position = UDim2.new(1, -300, 0, 20) -- pojok kanan atas
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Visible = true
local fc = Instance.new("UICorner", frame); fc.CornerRadius = UDim.new(0,12)

-- header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
local hc = Instance.new("UICorner", header); hc.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,8,0,0)
title.Text = "TripleS"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,26,0,24)
btnMin.Position = UDim2.new(1,-56,0,8)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 16
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
local mcorner = Instance.new("UICorner", btnMin); mcorner.CornerRadius = UDim.new(0,6)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,26,0,24)
btnClose.Position = UDim2.new(1,-28,0,8)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 14
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
local cc = Instance.new("UICorner", btnClose); cc.CornerRadius = UDim.new(0,6)

-- text input bar (di bawah title)
local inputBar = Instance.new("TextBox", frame)
inputBar.Size = UDim2.new(1,-20,0,28)
inputBar.Position = UDim2.new(0,10,0,48)
inputBar.PlaceholderText = "Masukkan perintah..."
inputBar.Text = ""
inputBar.Font = Enum.Font.SourceSans
inputBar.TextSize = 14
inputBar.TextColor3 = Color3.new(1,1,1)
inputBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
local ibc = Instance.new("UICorner", inputBar); ibc.CornerRadius = UDim.new(0,6)

-- content
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1,-20,1,-90)
content.Position = UDim2.new(0,10,0,84)
content.BackgroundTransparency = 1

-- grid tombol
local uiGrid = Instance.new("UIGridLayout", content)
uiGrid.CellPadding = UDim2.new(0,10,0,10)
uiGrid.CellSize = UDim2.new(0.5,-5,0,40) -- dua kolom
uiGrid.FillDirection = Enum.FillDirection.Horizontal
uiGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeBtn(text)
    local b = Instance.new("TextButton")
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0,6)
    b.Parent = content
    return b
end

-- isi tombol
makeBtn("Fly")
makeBtn("Unfly")
makeBtn("Fling")
makeBtn("Unfling")
makeBtn("Set Spawn")
makeBtn("Delete Spawn")
makeBtn("Speed 23")
makeBtn("Reset Speed")
makeBtn("Settings")
makeBtn("Commands")
makeBtn("Keybinds")
makeBtn("Plugins")

-- miniBtn (SSS)
local miniBtn = Instance.new("TextButton", screen)
miniBtn.Size = UDim2.new(0,50,0,50)
miniBtn.Position = UDim2.new(1,-70,0,20) -- kanan atas
miniBtn.BackgroundColor3 = Color3.new(0,0,0) -- hitam
miniBtn.Text = "SSS"
miniBtn.TextColor3 = Color3.new(1,1,1) -- putih
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 14
local mc = Instance.new("UICorner", miniBtn); mc.CornerRadius = UDim.new(1,0)
miniBtn.Visible = false

-- animasi
local function fade(obj, goalProps, duration)
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goalProps):Play()
end

-- aksi close
btnClose.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- aksi minimize (tutup frame → munculin tombol SSS)
btnMin.MouseButton1Click:Connect(function()
    fade(frame, {Size = UDim2.new(0,280,0,0)}, 0.3)
    task.wait(0.3)
    frame.Visible = false
    miniBtn.Visible = true
    miniBtn.BackgroundTransparency = 1
    fade(miniBtn, {BackgroundTransparency = 0}, 0.3)
end)

-- aksi miniBtn (balikin frame)
miniBtn.MouseButton1Click:Connect(function()
    miniBtn.Visible = false
    frame.Visible = true
    frame.Size = UDim2.new(0,280,0,0)
    fade(frame, {Size = UDim2.new(0,280,0,340)}, 0.3)
end)
