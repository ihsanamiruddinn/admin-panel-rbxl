--[[
	Replika GUI dari Skrip YARHM
	
	Skrip ini membuat ulang antarmuka pengguna (GUI) yang ditemukan
	dalam file yang Anda berikan. Ini adalah skrip mandiri, yang berarti
	Anda dapat menyalin dan mengeksekusi seluruhnya tanpa perlu file eksternal.
]]

-- === Layanan dan Variabel ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui

-- === Membuat GUI Utama ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YARHM_Replica"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Kotak dialog utama
local floatingButton = Instance.new("Frame")
floatingButton.Name = "FloatingButton"
floatingButton.Size = UDim2.new(0, 50, 0, 50)
floatingButton.Position = UDim2.new(0, 15, 0.5, 0)
floatingButton.AnchorPoint = Vector2.new(0, 0.5)
floatingButton.BackgroundColor3 = Color3.fromRGB(24, 25, 29)
floatingButton.BorderSizePixel = 0
floatingButton.Parent = screenGui

local cornerButton = Instance.new("UICorner")
cornerButton.CornerRadius = UDim.new(0, 8)
cornerButton.Parent = floatingButton

-- Tombol buka/tutup GUI
local openButton = Instance.new("TextButton")
openButton.Name = "Open"
openButton.Text = ">"
openButton.Size = UDim2.new(1, 0, 1, 0)
openButton.BackgroundTransparency = 1
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Font = Enum.Font.SourceSansBold
openButton.TextSize = 24
openButton.Parent = floatingButton

-- Jendela utama saat GUI dibuka
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(32, 33, 38)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Text = "YARHM"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = mainFrame

-- Kontainer untuk tab
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 1, -30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabContainer

-- === Fungsi dan Logika ===

local isVisible = false
local isDragging = false
local dragStartPos
local initialPos

-- Fungsi untuk membuat tab
local function createTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Text = name
    tabButton.Size = UDim2.new(0.25, 0, 1, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 41, 46)
    tabButton.BorderSizePixel = 0
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Parent = tabContainer

    return tabButton
end

-- Fungsi untuk membuka/menutup GUI
local function toggleGui()
    isVisible = not isVisible
    mainFrame.Visible = isVisible
    openButton.Text = isVisible and "<" or ">"
end

-- Menangani drag pada jendela utama
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = input.Position
        initialPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        mainFrame.Position = UDim2.new(initialPos.X.Scale, initialPos.X.Offset + delta.X, initialPos.Y.Scale, initialPos.Y.Offset + delta.Y)
    end
end)

-- Menghubungkan tombol buka/tutup
openButton.MouseButton1Click:Connect(toggleGui)

-- Menghubungkan tombol silang di jendela utama (menutup GUI)
local exitButton = Instance.new("TextButton")
exitButton.Name = "Exit"
exitButton.Text = "X"
exitButton.Size = UDim2.new(0, 25, 0, 25)
exitButton.Position = UDim2.new(1, -30, 0, 5)
exitButton.AnchorPoint = Vector2.new(1, 0)
exitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
exitButton.BorderSizePixel = 0
exitButton.Parent = mainFrame
exitButton.MouseButton1Click:Connect(toggleGui)

-- Membuat tab-tab
createTab("Tab 1")
createTab("Tab 2")
createTab("Tab 3")
createTab("Tab 4")

-- Menginisialisasi GUI agar dapat diseret
mainFrame.Active = true
mainFrame.Draggable = true

