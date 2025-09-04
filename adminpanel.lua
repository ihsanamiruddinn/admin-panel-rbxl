-- Test GUI: Drag + Minimize + Close (dengan content toggle, aman)
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- auto parent
local parentGui
if type(gethui) == "function" then
    pcall(function() parentGui = gethui() end)
end
if not parentGui and syn and syn.protect_gui then
    local s = Instance.new("ScreenGui")
    s.Name = "TMP_Protect"
    s.Parent = game:GetService("CoreGui")
    pcall(function() syn.protect_gui(s) end)
    parentGui = s
end
if not parentGui then parentGui = lp:WaitForChild("PlayerGui") end

-- cleanup
if parentGui:FindFirstChild("TestGuiFull") then
    pcall(function() parentGui.TestGuiFull:Destroy() end)
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "TestGuiFull"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- main frame
local frame = Instance.new("Frame", screen)
frame.Name = "Main"
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
local fc = Instance.new("UICorner", frame); fc.CornerRadius = UDim.new(0,12)

-- header (drag area)
local header = Instance.new("Frame", frame)
header.Name = "Header"
header.Size = UDim2.new(1,0,0,28)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
local hc = Instance.new("UICorner", header); hc.CornerRadius = UDim.new(0,12)

-- minimize & close buttons (on header)
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,28,0,20)
btnMin.Position = UDim2.new(0,4,0,4)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 18
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
local mcorner = Instance.new("UICorner", btnMin); mcorner.CornerRadius = UDim.new(0,6)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,28,0,20)
btnClose.Position = UDim2.new(1,-32,0,4)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 16
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
local ccorner = Instance.new("UICorner", btnClose); ccorner.CornerRadius = UDim.new(0,6)

-- content frame (semua elemen yang disembunyikan akan jadi child di sini)
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1, -12, 1, -36) -- sisa di bawah header
content.Position = UDim2.new(0, 6, 0, 30)
content.BackgroundTransparency = 1

-- tombol TEST di content
local btn = Instance.new("TextButton", content)
btn.Size = UDim2.new(0, 160, 0, 40)
btn.Position = UDim2.new(0, 20, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
btn.TextColor3 = Color3.fromRGB(0,0,0)
btn.Text = "TEST"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 18
local bc = Instance.new("UICorner", btn); bc.CornerRadius = UDim.new(0,8)

btn.MouseButton1Click:Connect(function()
    btn.Text = "Clicked!"
end)

-- close handler
btnClose.MouseButton1Click:Connect(function()
    pcall(function() screen:Destroy() end)
end)

-- minimize handler (safest: toggle content visible)
local minimized = false
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    if minimized then
        -- shrink to header height (keep same X position)
        frame.Size = UDim2.new(0, 200, 0, 28)
    else
        frame.Size = UDim2.new(0, 200, 0, 120)
    end
end)

-- DRAG (header only)
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
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

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)
