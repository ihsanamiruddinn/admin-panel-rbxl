-- TripleS GUI (fixed): header drags the FRAME (not itself), miniBtn draggable, fade animation
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- parent: try gethui/syn then fallback to PlayerGui
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
local NAME = "TripleSUI_fixed"
local old = parentGui:FindFirstChild(NAME)
if old then old:Destroy() end

local screen = Instance.new("ScreenGui")
screen.Name = NAME
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- constants
local DEFAULT_SIZE = UDim2.new(0, 300, 0, 380)
local DEFAULT_POS  = UDim2.new(0.72, 0, 0.06, 0) -- start near top-right but not stuck corner
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
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- header (drag handle) — IMPORTANT: dragging header will move 'frame'
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,46)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-110,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "TripleS"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- close & minimize
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,36,0,30)
btnMin.Position = UDim2.new(1,-92,0,8)
btnMin.Text = "–"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 20
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,8)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,36,0,30)
btnClose.Position = UDim2.new(1,-48,0,8)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 18
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,8)

-- input bar (full width under header)
local inputBar = Instance.new("TextBox", frame)
inputBar.Size = UDim2.new(1,-24,0,36)
inputBar.Position = UDim2.new(0,12,0,56)
inputBar.PlaceholderText = "Masukkan perintah..."
inputBar.Text = ""
inputBar.Font = Enum.Font.SourceSans
inputBar.TextSize = 16
inputBar.TextColor3 = Color3.new(1,1,1)
inputBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0,8)

-- content + grid
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Position = UDim2.new(0,12,0,104)
content.Size = UDim2.new(1,-24,1,-156)
content.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", content)
grid.CellPadding = UDim2.new(0,10,0,10)
grid.CellSize = UDim2.new(0.5,-15,0,48)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center

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

-- footer icon buttons (small round)
local footer = Instance.new("Frame", frame)
footer.Size = UDim2.new(1,-24,0,56)
footer.Position = UDim2.new(0,12,1,-68)
footer.BackgroundTransparency = 1
local footerLayout = Instance.new("UIListLayout", footer)
footerLayout.FillDirection = Enum.FillDirection.Horizontal
footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
footerLayout.Padding = UDim.new(0,12)

local function makeIconBtn(name, emoji)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,44,0,44)
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

-- mini SSS button (movable)
local miniBtn = Instance.new("TextButton", screen)
miniBtn.Name = "MiniSSS"
miniBtn.Size = MINI_SIZE
miniBtn.Position = UDim2.new(0.88, 0, 0.08, 0)
miniBtn.AnchorPoint = Vector2.new(0.5,0.5)
miniBtn.BackgroundColor3 = Color3.new(0,0,0)
miniBtn.Text = "SSS"
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 16
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Visible = false
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)

-- state
local isMinimized = false
local lastFramePos = frame.Position
local lastFrameSize = frame.Size

-- tween helper
local function tween(obj, props, t)
    local info = TweenInfo.new(t or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

-- MAKE DRAGGABLE (handle -> target)
local function makeDraggable(handle, target)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

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

    -- Each draggable registers its own listener; they won't step on each other due to closure
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput and dragStart and startPos then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            target.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

-- apply draggable: header moves the FRAME, miniBtn moves itself
makeDraggable(header, frame)
makeDraggable(miniBtn, miniBtn)

-- close action: fade then destroy
btnClose.MouseButton1Click:Connect(function()
    tween(frame, {BackgroundTransparency = 1}, 0.18)
    tween(miniBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.18)
    task.delay(0.18, function()
        if screen and screen.Parent then screen:Destroy() end
    end)
end)

-- minimize -> show miniBtn with fade; we shrink frame for visual effect then hide it
btnMin.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isMinimized = true
    lastFramePos = frame.Position
    lastFrameSize = frame.Size

    -- ensure mini visible and transparent first
    miniBtn.Visible = true
    miniBtn.BackgroundTransparency = 1
    miniBtn.TextTransparency = 1

    -- tween frame to small size & move near mini position (visual)
    tween(frame, {Size = MINI_SIZE, Position = miniBtn.Position, BackgroundTransparency = 1}, 0.22)
    tween(miniBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.22)

    task.delay(0.22, function()
        frame.Visible = false
    end)
end)

-- restore from miniBtn
miniBtn.MouseButton1Click:Connect(function()
    if not isMinimized then return end
    isMinimized = false
    -- show frame at miniBtn pos/size then tween back to last
    frame.Position = miniBtn.Position
    frame.Size = MINI_SIZE
    frame.BackgroundTransparency = 1
    frame.Visible = true

    -- hide miniBtn
    tween(miniBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.18).Completed:Connect(function()
        miniBtn.Visible = false
    end)

    -- animate frame back
    tween(frame, {Size = lastFrameSize, Position = lastFramePos, BackgroundTransparency = 0}, 0.26)
end)

-- initial state
frame.Visible = true
miniBtn.Visible = false
