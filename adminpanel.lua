-- GUI Test Super Minimal
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
if parentGui:FindFirstChild("TestGui") then
    parentGui.TestGui:Destroy()
end

-- buat ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "TestGui"
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

-- tombol TEST
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 160, 0, 40)
btn.Position = UDim2.new(0, 20, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
btn.TextColor3 = Color3.fromRGB(0,0,0)
btn.Text = "TEST"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 18
btn.ZIndex = 2
local bc = Instance.new("UICorner", btn); bc.CornerRadius = UDim.new(0,8)

btn.MouseButton1Click:Connect(function()
    btn.Text = "Clicked!"
end)
