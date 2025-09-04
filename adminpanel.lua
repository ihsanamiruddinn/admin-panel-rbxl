-- Test: Minimize jadi bundaran "SSS" (fixed & cleaned)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- ===== parent (gethui/syn/CoreGui/PlayerGui) =====
local parentGui
pcall(function()
    if typeof(gethui) == "function" then
        parentGui = gethui()
    end
end)
if not parentGui and syn and syn.protect_gui then
    local s = Instance.new("ScreenGui")
    syn.protect_gui(s)
    s.Parent = game:GetService("CoreGui")
    parentGui = s
end
if not parentGui then
    parentGui = lp:WaitForChild("PlayerGui")
end

-- cleanup
local old = parentGui:FindFirstChild("TestMiniSSS")
if old then old:Destroy() end

-- ===== root screen =====
local screen = Instance.new("ScreenGui")
screen.Name = "TestMiniSSS"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- ===== main frame (ukuran konsisten) =====
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Parent = screen
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0,12)
fc.Parent = frame

-- ===== header (single) =====
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(28,28,28)
header.Parent = frame
local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0,12)
hc.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -64, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "COMMAND BAR"
title.Font = Enum.Font.SourceSansBold
