-- GUI Test Mini SSS (fix bug versi minimal)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- auto parent
local parentGui
pcall(function()
    if typeof(gethui) == "function" then
        parentGui = gethui()
    end
end)
if not parentGui and syn and syn.protect_gui then
    local s = Instance.new("ScreenGui")
    syn.protect_gui(s)
    s.Parent = game:GetService("CoreGui")
    parentGui = s
end
if not parentGui then parentGui = lp:WaitForChild("PlayerGui") end

-- cleanup
if parentGui:FindFirstChild("TestMiniSSS") then
    parentGui.TestMiniSSS:Destroy()
end

local screen = Instance.new("ScreenGui")
screen.Name = "TestMiniSSS"
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- ukuran awal diperbaiki (250x300)
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
local fc = Instance.new("UICorner", frame); fc.CornerRadius = UDim.new(0,12)

-- header (cuma sekali)
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,28)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
local hc = Instance.new("UICorner", header); hc.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,8,0,0)
title.Text = "COMMAND BAR"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,24,0,20)
btnMin.Position = UDim2.new(1,-56,0,4)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 16
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
local mcorner = Instance.new("UICorner", btnMin); mcorner.CornerRadius = UDim.new(0,6)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,24,0,20)
btnClose.Position = UDim2.new(1,-28,0,4)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 14
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
local cc = Instance.new("UICorner", btnClose); cc.CornerRadius = UDim.new(0,6)

-- mini button (SSS)
local miniBtn = Instance.new("TextButton", screen)
miniBtn.Size = UDim2.new(0,50,0,50)
miniBtn.Position = UDim2.new(0,20,1,-70) -- kiri bawah
miniBtn.BackgroundColor3 = Color3.fromRGB(60,60,200)
miniBtn.Text = "SSS"
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 14
local mc = Instance.new("UICorner", miniBtn); mc.CornerRadius = UDim.new(1,0)
miniBtn.Visible = false

-- content
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1,-12,1,-36)
content.Position = UDim2.new(0,6,0,30)
content.BackgroundTransparency = 1

-- helper buat tombol
local function makeBtn(parent, x, y, w, h, text)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0,w,0,h)
    b.Position = UDim2.new(0,x,0,y)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0,6)
    return b
end

-- baris tombol (rapi manual)
local fly = makeBtn(content, 0, 0, 110, 36, "Fly")
local unfly = makeBtn(content, 120, 0, 110, 36, "Unfly")

local fling = makeBtn(content, 0, 44, 110, 36, "Fling")
local unfling = makeBtn(content, 120, 44, 110, 36, "Unfling")

local setspawn = makeBtn(content, 0, 88, 110, 36, "Set Spawn")
local delspawn = makeBtn(content, 120, 88, 110, 36, "Delete Spawn")

-- baris speed
local speed = makeBtn(content, 0, 132, 140, 36, "Speed 23")
local speedBox = Instance.new("TextBox", content)
speedBox.Size = UDim2.new(0, 100, 0, 36)
speedBox.Position = UDim2.new(0, 150, 0, 132)
speedBox.Text = "23"
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
local sbc = Instance.new("UICorner", speedBox); sbc.CornerRadius = UDim.new(0,6)

-- tabs
local names = {"Settings","Commands","Keybinds","Plugins"}
for i,name in ipairs(names) do
    local b = makeBtn(content, (i-1)*60, 180, 55, 40, name)
    b.TextSize = 11
end

-- aksi close
btnClose.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- aksi minimize
btnMin.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniBtn.Visible = false
end)

-- drag
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
