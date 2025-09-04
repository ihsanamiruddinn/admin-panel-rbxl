-- TripleS GUI (fix header + add TpTool & GotoPart)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local TS = game:GetService("TweenService")

-- auto parent
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

local screen = Instance.new("ScreenGui")
screen.Name = "TripleSGUI"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- panel utama
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 280, 0, 380)
frame.Position = UDim2.new(0.5, -140, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- header (nempel di frame)
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,32)
header.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

-- title (brand jadi tombol minimize)
local title = Instance.new("TextButton", header)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,8,0,0)
title.Text = "TripleS by Saanseventeen"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- tombol close
local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,24,0,24)
btnClose.Position = UDim2.new(1,-28,0,4)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 14
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)

btnClose.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- input bar
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

-- content (tombol utama)
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1,-24,1,-150)
content.Position = UDim2.new(0,12,0,80)
content.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", content)
grid.CellPadding = UDim2.new(0,10,0,10)
grid.CellSize = UDim2.new(0.5,-15,0,36)
grid.FillDirection = Enum.FillDirection.Horizontal
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Top

-- helper tombol
local function makeBtn(parent, text)
    local b = Instance.new("TextButton", parent)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

-- tombol utama
makeBtn(content,"Fly")
makeBtn(content,"Unfly")
makeBtn(content,"Fling")
makeBtn(content,"Unfling")
makeBtn(content,"Set Spawn")
makeBtn(content,"Delete Spawn")
makeBtn(content,"Speed 23")
makeBtn(content,"Tptool")

-- tambahan 2 tombol baru (paling bawah sebelum footer)
makeBtn(content,"TGoto")
makeBtn(content,"GotoPart")

-- footer tombol kecil
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

makeIconBtn("Settings", "⚙️")
makeIconBtn("Commands", "📜")
makeIconBtn("Keybinds", "⌨️")
makeIconBtn("Plugins",  "🔌")

-- mini button (SSS)
local miniBtn = Instance.new("TextButton", screen)
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

-- minimize (brand jadi tombol)
title.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtn.Visible = true
end)

-- restore
miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniBtn.Visible = false
end)
