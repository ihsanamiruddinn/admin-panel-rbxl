-- Test GUI Compact - untuk cek apakah muncul di KRNL

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Cari parent GUI (auto detect biar aman di KRNL)
local parentGui
if gethui then
    parentGui = gethui()
elseif syn and syn.protect_gui then
    parentGui = Instance.new("ScreenGui")
    syn.protect_gui(parentGui)
    parentGui.Parent = game.CoreGui
elseif game:GetService("CoreGui") then
    parentGui = game:GetService("CoreGui")
else
    parentGui = lp:WaitForChild("PlayerGui")
end

-- ScreenGui utama
local screen = Instance.new("ScreenGui")
screen.Name = "AdminPanel_Test"
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- Frame utama (kecil, 200x120)
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- Tombol test
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -20, 0, 40)
btn.Position = UDim2.new(0, 10, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
btn.Text = "Klik Test"
btn.TextColor3 = Color3.new(1,1,1)

local btnCorner = Instance.new("UICorner", btn)
btnCorner.CornerRadius = UDim.new(0, 8)

-- Drag support
local dragging = false
local dragInput, dragStart, startPos
local UIS = game:GetService("UserInputService")

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		dragInput = input
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Event tombol
btn.MouseButton1Click:Connect(function()
	print("✅ Tombol berhasil ditekan!")
	btn.Text = "Sudah diklik"
end)
