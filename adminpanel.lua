-- TripleS draggable + movable mini button + fade animation (mobile friendly)
-- Paste ke LocalScript (StarterPlayerScripts / PlayerGui)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- parent: coba gethui/syn, fallback ke PlayerGui
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
local NAME = "TripleSUI"
local old = parentGui:FindFirstChild(NAME)
if old then old:Destroy() end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = NAME
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- default sizes/positions (pixel-based so mobile is predictable)
local DEFAULT_SIZE = UDim2.new(0, 300, 0, 380)
local DEFAULT_POS  = UDim2.new(0.75, 0, 0.05, 0) -- awal: kanan-atas area (bukan terpaku pojok)
local MINI_SIZE    = UDim2.new(0, 56, 0, 56)

-- main frame
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = DEFAULT_SIZE
frame.Position = DEFAULT_POS
frame.AnchorPoint = Vector2.new(0,0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Parent = screen
local fc = Instance.new("UICorner", frame); fc.CornerRadius = UDim.new(0,12)

-- header (drag handle)
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,44)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
local hc = Instance.new("UICorner", header); hc.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-100,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "TripleS"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- close & minimize buttons
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,32,0,28)
btnMin.Position = UDim2.new(1,-72,0,8)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 18
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,8)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,32,0,28)
btnClose.Position = UDim2.new(1,-36,0,8)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 16
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,8)

-- input bar full width under header
local inputBar = Instance.new("TextBox", frame)
inputBar.Size = UDim2.new(1,-24,0,34)
inputBar.Position = UDim2.new(0,12,0,52)
inputBar.PlaceholderText = "Masukkan perintah..."
inputBar.Text = ""
inputBar.Font = Enum.Font.SourceSans
inputBar.TextSize = 16
inputBar.TextColor3 = Color3.new(1,1,1)
inputBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0,8)

-- content area (grid)
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Position = UDim2.new(0,12,0,96)
content.Size = UDim2.new(1,-24,1,-108)
content.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", content)
grid.CellPadding = UDim2.new(0,10,0,10)
grid.CellSize = UDim2.new(0.5,-15,0,46) -- dua kolom, lebih lebar untuk mobile
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeBtn(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,1,0)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.Parent = content
    return b
end

-- contoh tombol (sesuaikan sendiri)
local buttons = {"Fly","Unfly","Fling","Unfling","Set Spawn","Delete Spawn","Speed 23","Reset Speed","Settings","Commands","Keybinds","Plugins"}
for _,v in ipairs(buttons) do makeBtn(v) end

-- mini button (SSS) — draggable (tidak menempel ke pojok)
local miniBtn = Instance.new("TextButton", screen)
miniBtn.Name = "MiniSSS"
miniBtn.Size = MINI_SIZE
miniBtn.Position = UDim2.new(0.9, 0, 0.08, 0) -- awal agak di kanan atas, tapi movable
miniBtn.AnchorPoint = Vector2.new(0.5,0.5) -- nyaman untuk drag
miniBtn.BackgroundColor3 = Color3.new(0,0,0)
miniBtn.Text = "SSS"
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 16
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Visible = false
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)

-- state holders
local lastFramePos = frame.Position
local lastFrameSize = frame.Size
local isMinimized = false

-- helper tween
local function tween(obj, props, time)
    local ti = TweenInfo.new(time or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- make draggable (works for mouse & touch)
local function makeDraggable(handle, target)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    -- separate InputChanged listener per draggable to avoid cross interference
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            -- preserve scale (usually 0) and adjust offsets
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            target.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

-- apply draggable: header drags the whole window, miniBtn drags itself
makeDraggable(header, frame)
makeDraggable(miniBtn, miniBtn)

-- minimize (shrink into mini button with fade)
btnMin.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isMinimized = true
    -- save current pos/size
    lastFramePos = frame.Position
    lastFrameSize = frame.Size

    -- ensure miniBtn visible (start transparent)
    miniBtn.Visible = true
    miniBtn.BackgroundTransparency = 1
    miniBtn.TextTransparency = 1

    -- tween frame to miniBtn position/size
    local tw = tween(frame, {Position = miniBtn.Position, Size = miniBtn.Size}, 0.22)
    -- fade in mini button while shrinking
    tween(miniBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.22)

    tw.Completed:Connect(function()
        frame.Visible = false
    end)
end)

-- restore from miniBtn
miniBtn.MouseButton1Click:Connect(function()
    if not isMinimized then return end
    isMinimized = false
    -- set frame at miniBtn pos/size and show, then animate back
    frame.Position = miniBtn.Position
    frame.Size = miniBtn.Size
    frame.Visible = true

    -- hide miniBtn with fade
    tween(miniBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.18).Completed:Connect(function()
        miniBtn.Visible = false
    end)

    -- animate frame back to last saved pos/size
    tween(frame, {Position = lastFramePos, Size = lastFrameSize}, 0.24)
end)

-- close action
btnClose.MouseButton1Click:Connect(function()
    -- animate fade out then destroy
    tween(frame, {BackgroundTransparency = 1}, 0.18)
    tween(miniBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.18)
    task.delay(0.18, function()
        if screen and screen.Parent then screen:Destroy() end
    end)
end)

-- optional: if user clicks outside and wants to hide, you can implement later
-- initial focus: frame visible, mini hidden
frame.Visible = true
miniBtn.Visible = false
