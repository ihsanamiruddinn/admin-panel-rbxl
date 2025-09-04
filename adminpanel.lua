-- TripleS GUI (final fix)

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- === MAIN FRAME ===
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,280,0,360)
frame.Position = UDim2.new(0.5,-140,0.5,-180)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- === HEADER ===
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,30)
header.BackgroundColor3 = Color3.fromRGB(35,35,35)
header.BorderSizePixel = 0
header.Active = true
header.Draggable = true
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Text = "TripleS"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,8,0,0)
title.Size = UDim2.new(1,-60,1,0)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize button
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,24,0,24)
btnMin.Position = UDim2.new(1,-28,0.5,-12)
btnMin.BackgroundColor3 = Color3.fromRGB(200,0,0)
btnMin.Text = "─"
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 16
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(1,0)

-- === INPUT BOX ===
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1,-24,0,28)
input.Position = UDim2.new(0,12,0,40)
input.PlaceholderText = "Type here..."
input.Text = ""
input.Font = Enum.Font.SourceSans
input.TextSize = 16
input.TextColor3 = Color3.new(1,1,1)
input.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", input).CornerRadius = UDim.new(0,8)

-- === CONTENT AREA ===
local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1,-24,1,-120)
content.Position = UDim2.new(0,12,0,80)
content.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", content)
grid.CellPadding = UDim2.new(0,10,0,10)
grid.CellSize = UDim2.new(0.5,-15,0,40)
grid.FillDirection = Enum.FillDirection.Horizontal
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Top

local pad = Instance.new("UIPadding", content)
pad.PaddingBottom = UDim.new(0,grid.CellSize.Y.Offset/4) -- dinamis

-- fungsi buat tombol utama
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

-- === FOOTER BAR ===
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

-- === MINI BUTTON ===
local miniBtn = Instance.new("TextButton", gui)
miniBtn.Size = UDim2.new(0,40,0,40)
miniBtn.Position = UDim2.new(1,-60,0,20)
miniBtn.BackgroundColor3 = Color3.new(0,0,0)
miniBtn.Text = "SSS"
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 14
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)
miniBtn.Visible = false
miniBtn.Active = true
miniBtn.Draggable = true

-- === MINIMIZE & RESTORE ===
btnMin.MouseButton1Click:Connect(function()
    for _,c in ipairs(frame:GetDescendants()) do
        if c:IsA("GuiObject") and c ~= header and c ~= btnMin then
            TS:Create(c,TweenInfo.new(0.25),{BackgroundTransparency=1, TextTransparency=1}):Play()
        end
    end
    task.wait(0.25)
    frame.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    for _,c in ipairs(frame:GetDescendants()) do
        if c:IsA("GuiObject") and c ~= header and c ~= btnMin then
            c.BackgroundTransparency = 1
            if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                c.TextTransparency = 1
            end
            TS:Create(c,TweenInfo.new(0.25),{BackgroundTransparency=0, TextTransparency=0}):Play()
        end
    end
    miniBtn.Visible = false
end)
