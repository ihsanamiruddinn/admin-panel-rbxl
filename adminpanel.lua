-- GUI Test Drag + Minimize + Close
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- auto parent
local parentGui
if gethui then
    parentGui = gethui()
elseif syn and syn.protect_gui then
    local s = Instance.new("ScreenGui")
    syn.protect_gui(s)
    s.Parent = game.CoreGui
    parentGui = s
else
    parentGui = lp:WaitForChild("PlayerGui")
end

-- hapus lama
if parentGui:FindFirstChild("TestGuiFull") then
    parentGui.TestGuiFull:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "TestGuiFull"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- frame utama
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
local c = Instance.new("UICorner", frame); c.CornerRadius = UDim.new(0,12)

-- header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,28)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
local hc = Instance.new("UICorner", header); hc.CornerRadius = UDim.new(0,12)

-- tombol minimize
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,28,0,20)
btnMin.Position = UDim2.new(0,4,0,4)
btnMin.Text = "–"
btnMin.TextSize = 18
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
local minc = Instance.new("UICorner", btnMin); minc.CornerRadius = UDim.new(0,6)

-- tombol close
local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,28,0,20)
btnClose.Position = UDim2.new(1,-32,0,4)
btnClose.Text = "✕"
btnClose.TextSize = 16
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
local cc = Instance.new("UICorner", btnClose); cc.CornerRadius = UDim.new(0,6)

-- tombol TEST
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 160, 0, 40)
btn.Position = UDim2.new(0, 20, 0, 50)
btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
btn.TextColor3 = Color3.fromRGB(0,0,0)
btn.Text = "TEST"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 18
local bc = Instance.new("UICorner", btn); bc.CornerRadius = UDim.new(0,8)

btn.MouseButton1Click:Connect(function()
    btn.Text = "Clicked!"
end)

-- fungsi close
btnClose.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- fungsi minimize
local minimized = false
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,child in pairs(frame:GetChildren()) do
        if child ~= header then
            child.Visible = not minimized
        end
    end
    if minimized then
        frame.Size = UDim2.new(0,200,0,28)
    else
        frame.Size = UDim2.new(0,200,0,120)
    end
end)

-- drag support
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
