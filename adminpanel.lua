-- TripleS GUI - mobile friendly (drag + SSS pojok kanan atas)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- parent
local parentGui = lp:WaitForChild("PlayerGui")
local old = parentGui:FindFirstChild("TripleSUI")
if old then old:Destroy() end

local screen = Instance.new("ScreenGui")
screen.Name = "TripleSUI"
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 340)
frame.Position = UDim2.new(1, -300, 0, 20) -- kanan atas
frame.AnchorPoint = Vector2.new(0,0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Parent = screen
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,8,0,0)
title.Text = "TripleS"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- tombol minimize
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,26,0,24)
btnMin.Position = UDim2.new(1,-56,0,8)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 16
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)

-- tombol close
local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,26,0,24)
btnClose.Position = UDim2.new(1,-28,0,8)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 14
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)

-- input bar
local inputBar = Instance.new("TextBox", frame)
inputBar.Size = UDim2.new(1,-20,0,28)
inputBar.Position = UDim2.new(0,10,0,48)
inputBar.PlaceholderText = "Masukkan perintah..."
inputBar.Text = ""
inputBar.Font = Enum.Font.SourceSans
inputBar.TextSize = 14
inputBar.TextColor3 = Color3.new(1,1,1)
inputBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0,6)

-- content
local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1,-20,1,-90)
content.Position = UDim2.new(0,10,0,84)
content.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", content)
grid.CellPadding = UDim2.new(0,10,0,10)
grid.CellSize = UDim2.new(0.5,-5,0,40)

local function makeBtn(name)
    local b = Instance.new("TextButton")
    b.Text = name
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.Parent = content
    return b
end

for _,name in ipairs({"Fly","Unfly","Fling","Unfling","Set Spawn","Delete Spawn","Speed 23","Reset Speed","Settings","Commands","Keybinds","Plugins"}) do
    makeBtn(name)
end

-- tombol SSS
local miniBtn = Instance.new("TextButton", screen)
miniBtn.Size = UDim2.new(0,50,0,50)
miniBtn.AnchorPoint = Vector2.new(1,0)
miniBtn.Position = UDim2.new(1,-10,0,10) -- pojok kanan atas
miniBtn.BackgroundColor3 = Color3.new(0,0,0)
miniBtn.Text = "SSS"
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 14
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)
miniBtn.Visible = false

-- tombol aksi
btnClose.MouseButton1Click:Connect(function() screen:Destroy() end)

btnMin.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    miniBtn.Visible = false
    frame.Visible = true
end)

-- DRAG support (mouse + mobile)
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
        0, startPos.X.Offset + delta.X,
        0, startPos.Y.Offset + delta.Y
    )
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
