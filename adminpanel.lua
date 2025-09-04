-- Admin Panel Layout Test
-- Hanya layout UI, tanpa fungsi fly/fling
-- Tujuan: cek apakah tombol kelihatan (tidak ketimpa kotak hitam)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- parent GUI auto detect
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

-- clear lama
if parentGui:FindFirstChild("AdminPanel_LayoutTest") then
    parentGui.AdminPanel_LayoutTest:Destroy()
end

local screen = Instance.new("ScreenGui")
screen.Name = "AdminPanel_LayoutTest"
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- frame utama
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35) -- abu tipis
frame.Active = true
local c = Instance.new("UICorner", frame); c.CornerRadius = UDim.new(0,10)

-- header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,36)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
local hc = Instance.new("UICorner", header); hc.CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.Text = "COMMAND BAR"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,28,0,28)
btnClose.Position = UDim2.new(1,-34,0,4)
btnClose.Text = "✕"
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 16
local cc = Instance.new("UICorner", btnClose); cc.CornerRadius = UDim.new(0,6)

-- content area
local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1,-12,1,-48)
content.Position = UDim2.new(0,6,0,42)
content.BackgroundTransparency = 1

-- helper tombol
local function makeBtn(y,text)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(0.45,0,0,36)
    b.Position = UDim2.new(0.05,y,0,0)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSans
    b.TextSize = 14
    b.ZIndex = 2
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0,6)
    return b
end

-- baris tombol
local fly = makeBtn(0.0,"Fly")
local unfly = makeBtn(0.55,"Unfly")
unfly.Position = UDim2.new(0.5,0,0,0)

local fling = makeBtn(0.0+0.2,"Fling")
local unfling = makeBtn(0.5,0.2,"Unfling")
unfling.Position = UDim2.new(0.5,0,0,40)

local spawn = makeBtn(0.0+0.4,"Set Spawn")
spawn.Position = UDim2.new(0,0,0,80)
local delspawn = makeBtn(0.5,0.4,"Delete Spawn")
delspawn.Position = UDim2.new(0.5,0,0,80)

local speed = makeBtn(0.0+0.6,"Speed 23")
speed.Size = UDim2.new(0.65,0,0,36)
speed.Position = UDim2.new(0,0,0,120)

local speedBox = Instance.new("TextBox", content)
speedBox.Size = UDim2.new(0.3,0,0,36)
speedBox.Position = UDim2.new(0.68,0,0,120)
speedBox.Text = "23"
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14
local sbc = Instance.new("UICorner", speedBox); sbc.CornerRadius = UDim.new(0,6)

-- kotak bawah
for i,name in ipairs({"Settings","Commands","Keybinds","Plugins"}) do
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(0,40,0,40)
    b.Position = UDim2.new(0.05+(i-1)*0.23,0,1,-44)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSans
    b.TextSize = 12
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0,6)
end
