-- TripleS GUI Final Version

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- parent GUI
local parentGui
if type(gethui) == "function" then
    pcall(function() parentGui = gethui() end)
end
if not parentGui and syn and syn.protect_gui then
    local s = Instance.new("ScreenGui")
    syn.protect_gui(s)
    s.Parent = game:GetService("CoreGui")
    parentGui = s
end
if not parentGui then parentGui = lp:WaitForChild("PlayerGui") end

-- cleanup
if parentGui:FindFirstChild("TripleSGUI") then
    parentGui.TripleSGUI:Destroy()
end

-- screen
local screen = Instance.new("ScreenGui")
screen.Name = "TripleSGUI"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- main frame
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 280, 0, 340)
frame.Position = UDim2.new(1,-300,0,40) -- pojok kanan atas
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.BackgroundTransparency = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,32)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,8,0,0)
title.Text = "TripleS"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- input bar
local inputBox = Instance.new("TextBox", frame)
inputBox.Size = UDim2.new(1,-20,0,28)
inputBox.Position = UDim2.new(0,10,0,40)
inputBox.PlaceholderText = "Enter command..."
inputBox.Font = Enum.Font.SourceSans
inputBox.TextSize = 14
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,6)

-- content area
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1,-20,1,-120)
content.Position = UDim2.new(0,10,0,75)
content.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", content)
grid.CellPadding = UDim2.new(0,10,0,10)
grid.CellSize = UDim2.new(0.5,-15,0,40) -- tombol utama lebih pendek
grid.FillDirection = Enum.FillDirection.Horizontal
grid.SortOrder = Enum.SortOrder.LayoutOrder

-- padding dinamis
local pad = Instance.new("UIPadding", content)
pad.PaddingBottom = UDim.new(0, grid.CellSize.Y.Offset/4)

-- big buttons
local function makeBtn(text)
    local b = Instance.new("TextButton")
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.Parent = content
    return b
end

local bigButtons = {"Fly","Unfly","Fling","Unfling","Set Spawn","Delete Spawn","Speed 23","Reset Speed"}
for _,v in ipairs(bigButtons) do makeBtn(v) end

-- footer bar
local footer = Instance.new("Frame", frame)
footer.Size = UDim2.new(1,-24,0,50)
footer.Position = UDim2.new(0,12,1,-56)
footer.BackgroundTransparency = 1

local footerLayout = Instance.new("UIListLayout", footer)
footerLayout.FillDirection = Enum.FillDirection.Horizontal
footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
footerLayout.Padding = UDim.new(0,12)

local function makeIconBtn(txt, emoji)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,40,0,40)
    b.Text = emoji
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 22
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    b.Parent = footer
    b.Name = txt
    return b
end

local btnSettings  = makeIconBtn("Settings", "⚙️")
local btnCommands  = makeIconBtn("Commands", "📜")
local btnKeybinds  = makeIconBtn("Keybinds", "⌨️")
local btnPlugins   = makeIconBtn("Plugins",  "🔌")

-- close & minimize
local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,24,0,20)
btnClose.Position = UDim2.new(1,-28,0,6)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 14
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)

local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,24,0,20)
btnMin.Position = UDim2.new(1,-56,0,6)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 16
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)

-- mini button (SSS)
local miniBtn = Instance.new("TextButton", screen)
miniBtn.Size = UDim2.new(0,50,0,50)
miniBtn.Position = UDim2.new(1,-60,0,10)
miniBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
miniBtn.Text = "SSS"
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 16
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)
miniBtn.Visible = false

-- close
btnClose.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- minimize
btnMin.MouseButton1Click:Connect(function()
    TS:Create(frame,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play()
    for _,c in ipairs(frame:GetDescendants()) do
        if c:IsA("GuiObject") then
            TS:Create(c,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play()
        end
    end
    task.wait(0.25)
    frame.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    for _,c in ipairs(frame:GetDescendants()) do
        if c:IsA("GuiObject") then
            c.BackgroundTransparency = 1
        end
    end
    frame.BackgroundTransparency = 1
    TS:Create(frame,TweenInfo.new(0.25),{BackgroundTransparency=0}):Play()
    for _,c in ipairs(frame:GetDescendants()) do
        if c:IsA("GuiObject") and c ~= inputBox and c ~= title then
            TS:Create(c,TweenInfo.new(0.25),{BackgroundTransparency=0}):Play()
        end
    end
    miniBtn.Visible = false
end)

-- draggable frame
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

-- draggable miniBtn
local draggingMini, dragInputMini, dragStartMini, startPosMini
local function updateMini(input)
    local delta = input.Position - dragStartMini
    miniBtn.Position = UDim2.new(startPosMini.X.Scale, startPosMini.X.Offset + delta.X, startPosMini.Y.Scale, startPosMini.Y.Offset + delta.Y)
end

miniBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMini = true
        dragStartMini = input.Position
        startPosMini = miniBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMini = false
            end
        end)
    end
end)

miniBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputMini = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInputMini and draggingMini then
        updateMini(input)
    end
end)
