-- TripleS GUI by GPT
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- parent gui
local parentGui = lp:WaitForChild("PlayerGui")
if parentGui:FindFirstChild("TripleSGui") then
    parentGui.TripleSGui:Destroy()
end

local screen = Instance.new("ScreenGui")
screen.Name = "TripleSGui"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 320)
frame.Position = UDim2.new(1, -280, 0, 50) -- kanan atas
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Visible = true
frame.Parent = screen
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

-- tombol minimize & close
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,24,0,20)
btnMin.Position = UDim2.new(1,-56,0,6)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 16
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,24,0,20)
btnClose.Position = UDim2.new(1,-28,0,6)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 14
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)

-- input bar
local inputBar = Instance.new("TextBox", frame)
inputBar.Size = UDim2.new(1,-16,0,28)
inputBar.Position = UDim2.new(0,8,0,40)
inputBar.PlaceholderText = "Enter command..."
inputBar.Font = Enum.Font.SourceSans
inputBar.TextSize = 14
inputBar.TextColor3 = Color3.new(1,1,1)
inputBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0,6)

-- content area
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1,-16,1,-110)
content.Position = UDim2.new(0,8,0,76)
content.BackgroundTransparency = 1

-- tombol helper
local function makeBtn(parent, x, y, w, h, text)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0,w,0,h)
    b.Position = UDim2.new(0,x,0,y)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

-- baris tombol besar
local fly = makeBtn(content, 0, 0, 120, 36, "Fly")
local unfly = makeBtn(content, 130, 0, 120, 36, "Unfly")

local fling = makeBtn(content, 0, 44, 120, 36, "Fling")
local unfling = makeBtn(content, 130, 44, 120, 36, "Unfling")

local setspawn = makeBtn(content, 0, 88, 120, 36, "Set Spawn")
local delspawn = makeBtn(content, 130, 88, 120, 36, "Delete Spawn")

local speed = makeBtn(content, 0, 132, 120, 36, "Speed 23")
local speedBox = Instance.new("TextBox", content)
speedBox.Size = UDim2.new(0,120,0,36)
speedBox.Position = UDim2.new(0,130,0,132)
speedBox.Text = "23"
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)

-- footer untuk icon buttons
local footer = Instance.new("Frame", frame)
footer.Size = UDim2.new(1,-16,0,50)
footer.Position = UDim2.new(0,8,1,-58)
footer.BackgroundTransparency = 1

local footerLayout = Instance.new("UIListLayout", footer)
footerLayout.FillDirection = Enum.FillDirection.Horizontal
footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
footerLayout.Padding = UDim.new(0,12)

local function makeIconBtn(name, emoji)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,40,0,40)
    b.Text = emoji
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 22
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    b.Parent = footer
    b.Name = name
    return b
end

local btnSettings  = makeIconBtn("Settings", "⚙️")
local btnCommands  = makeIconBtn("Commands", "📜")
local btnKeybinds  = makeIconBtn("Keybinds", "⌨️")
local btnPlugins   = makeIconBtn("Plugins",  "🔌")

-- mini button SSS
local miniBtn = Instance.new("TextButton", screen)
miniBtn.Size = UDim2.new(0,50,0,50)
miniBtn.Position = UDim2.new(1,-70,0,10)
miniBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
miniBtn.Text = "SSS"
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 14
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)
miniBtn.Visible = false

-- fade helpers
local function fade(obj, goal, dur)
    TweenService:Create(obj, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

-- close
btnClose.MouseButton1Click:Connect(function()
    fade(frame, {BackgroundTransparency = 1}, 0.2)
    wait(0.2)
    screen:Destroy()
end)

-- minimize
btnMin.MouseButton1Click:Connect(function()
    fade(frame, {BackgroundTransparency = 1}, 0.2)
    wait(0.2)
    frame.Visible = false
    miniBtn.Visible = true
    fade(miniBtn, {BackgroundTransparency = 0}, 0.2)
end)

miniBtn.MouseButton1Click:Connect(function()
    fade(miniBtn, {BackgroundTransparency = 1}, 0.2)
    wait(0.2)
    miniBtn.Visible = false
    frame.Visible = true
    fade(frame, {BackgroundTransparency = 0}, 0.2)
end)

-- drag function (frame & miniBtn)
local function dragify(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

dragify(header)   -- drag window lewat header
dragify(miniBtn)  -- drag tombol SSS
