--[[
Skrip GUI Minimalis oleh Gemini
Deskripsi:
Ini adalah skrip GUI Lua untuk Roblox yang dirancang agar terlihat modern,
minimalis, dan mobile-friendly. Fitur utamanya meliputi:
- Tampilan yang halus dan sudut membulat.
- Tombol minimize yang mengubah GUI menjadi bola kecil.
- Tombol close dengan dialog konfirmasi.
- Animasi halus menggunakan TweenService.
- Tata letak yang responsif.

--]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
-- === Konfigurasi GUI ===
local settings = {
mainBackgroundColor = Color3.fromRGB(40, 44, 52),
headerColor = Color3.fromRGB(52, 58, 64),
buttonColor = Color3.fromRGB(64, 70, 78),
textColor = Color3.fromRGB(255, 255, 255),
accentColor = Color3.fromRGB(90, 180, 255),
cornerRadius = 10,
animationTime = 0.25
}
-- === Fungsi Tweening ===
local function tweenGui(instance, properties)
local tweenInfo = TweenInfo.new(settings.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(instance, tweenInfo, properties)
tween:Play()
end
-- === Membuat GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TripleS_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.3, 0, 0.6, 0) -- Ukuran 1:3 dari layar (disesuaikan)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = settings.mainBackgroundColor
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, settings.cornerRadius)
corner.Parent = mainFrame
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 10)
layout.Parent = mainFrame
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = mainFrame
-- === Bagian Header ===
local headerFrame = Instance.new("Frame")
headerFrame.Name = "HeaderFrame"
headerFrame.Size = UDim2.new(1, 0, 0, 40)
headerFrame.BackgroundColor3 = settings.headerColor
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame
headerFrame.LayoutOrder = 1
local headerLayout = Instance.new("UIListLayout")
headerLayout.FillDirection = Enum.FillDirection.Horizontal
headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
headerLayout.Padding = UDim.new(0, 10)
headerLayout.Parent = headerFrame
local headerPadding = Instance.new("UIPadding")
headerPadding.PaddingLeft = UDim.new(0, 10)
headerPadding.PaddingRight = UDim.new(0, 10)
headerPadding.Parent = headerFrame
local tripleSLabel = Instance.new("TextLabel")
tripleSLabel.Name = "TripleSLabel"
tripleSLabel.Text = "TripleS"
tripleSLabel.Size = UDim2.new(0.3, 0, 1, 0)
tripleSLabel.BackgroundTransparency = 1
tripleSLabel.TextColor3 = settings.textColor
tripleSLabel.TextScaled = true
tripleSLabel.Font = Enum.Font.SourceSansBold
tripleSLabel.Parent = headerFrame
local headerInput = Instance.new("TextBox")
headerInput.Name = "HeaderInput"
headerInput.PlaceholderText = "Input di Header"
headerInput.Size = UDim2.new(0.7, 0, 1, 0)
headerInput.BackgroundColor3 = settings.buttonColor
headerInput.BorderSizePixel = 0
headerInput.TextColor3 = settings.textColor
headerInput.TextScaled = true
headerInput.Parent = headerFrame
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 5)
inputCorner.Parent = headerInput
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeButton.BorderSizePixel = 0
closeButton.TextColor3 = settings.textColor
closeButton.Parent = mainFrame
closeButton.ZIndex = 2 -- Pastikan di atas yang lain
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Text = "-"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -65, 0, 0)
minimizeButton.AnchorPoint = Vector2.new(1, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
minimizeButton.BorderSizePixel = 0
minimizeButton.TextColor3 = settings.textColor
minimizeButton.Parent = mainFrame
minimizeButton.ZIndex = 2
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 5)
buttonCorner.Parent = minimizeButton
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton
-- === Bagian Konten Utama ===
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame
contentFrame.LayoutOrder = 2
local contentLayout = Instance.new("UIListLayout")
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Padding = UDim.new(0, 10)
contentLayout.Parent = contentFrame
-- Baris 1: Dua tombol
local buttonRow1 = Instance.new("Frame")
buttonRow1.Name = "ButtonRow1"
buttonRow1.Size = UDim2.new(1, 0, 0, 40)
buttonRow1.BackgroundTransparency = 1
buttonRow1.Parent = contentFrame
local buttonRow1Layout = Instance.new("UIListLayout")
buttonRow1Layout.FillDirection = Enum.FillDirection.Horizontal
buttonRow1Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonRow1Layout.Padding = UDim.new(0, 10)
buttonRow1Layout.Parent = buttonRow1
local btn1 = Instance.new("TextButton")
btn1.Name = "Tombol1"
btn1.Text = "Tombol 1"
btn1.Size = UDim2.new(0.5, -5, 1, 0)
btn1.BackgroundColor3 = settings.buttonColor
btn1.BorderSizePixel = 0
btn1.TextColor3 = settings.textColor
btn1.Parent = buttonRow1
local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, settings.cornerRadius)
corner1.Parent = btn1
local btn2 = Instance.new("TextButton")
btn2.Name = "Tombol2"
btn2.Text = "Tombol 2"
btn2.Size = UDim2.new(0.5, -5, 1, 0)
btn2.BackgroundColor3 = settings.buttonColor
btn2.BorderSizePixel = 0
btn2.TextColor3 = settings.textColor
btn2.Parent = buttonRow1
local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, settings.cornerRadius)
corner2.Parent = btn2
-- Baris 2: Dua tombol
local buttonRow2 = Instance.new("Frame")
buttonRow2.Name = "ButtonRow2"
buttonRow2.Size = UDim2.new(1, 0, 0, 40)
buttonRow2.BackgroundTransparency = 1
buttonRow2.Parent = contentFrame
local buttonRow2Layout = Instance.new("UIListLayout")
buttonRow2Layout.FillDirection = Enum.FillDirection.Horizontal
buttonRow2Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonRow2Layout.Padding = UDim.new(0, 10)
buttonRow2Layout.Parent = buttonRow2
local btn3 = Instance.new("TextButton")
btn3.Name = "Tombol3"
btn3.Text = "Tombol 3"
btn3.Size = UDim2.new(0.5, -5, 1, 0)
btn3.BackgroundColor3 = settings.buttonColor
btn3.BorderSizePixel = 0
btn3.TextColor3 = settings.textColor
btn3.Parent = buttonRow2
local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, settings.cornerRadius)
corner3.Parent = btn3
local btn4 = Instance.new("TextButton")
btn4.Name = "Tombol4"
btn4.Text = "Tombol 4"
btn4.Size = UDim2.new(0.5, -5, 1, 0)
btn4.BackgroundColor3 = settings.buttonColor
btn4.BorderSizePixel = 0
btn4.TextColor3 = settings.textColor
btn4.Parent = buttonRow2
local corner4 = Instance.new("UICorner")
corner4.CornerRadius = UDim.new(0, settings.cornerRadius)
corner4.Parent = btn4
-- Baris 3: Dua textbox
local textboxRow1 = Instance.new("Frame")
textboxRow1.Name = "TextboxRow1"
textboxRow1.Size = UDim2.new(1, 0, 0, 40)
textboxRow1.BackgroundTransparency = 1
textboxRow1.Parent = contentFrame
local textboxRow1Layout = Instance.new("UIListLayout")
textboxRow1Layout.FillDirection = Enum.FillDirection.Horizontal
textboxRow1Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
textboxRow1Layout.Padding = UDim.new(0, 10)
textboxRow1Layout.Parent = textboxRow1
local input1 = Instance.new("TextBox")
input1.Name = "Input1"
input1.PlaceholderText = "Input 1"
input1.Size = UDim2.new(0.5, -5, 1, 0)
input1.BackgroundColor3 = settings.buttonColor
input1.BorderSizePixel = 0
input1.TextColor3 = settings.textColor
input1.Parent = textboxRow1
local input1Corner = Instance.new("UICorner")
input1Corner.CornerRadius = UDim.new(0, settings.cornerRadius)
input1Corner.Parent = input1
local input2 = Instance.new("TextBox")
input2.Name = "Input2"
input2.PlaceholderText = "Input 2"
input2.Size = UDim2.new(0.5, -5, 1, 0)
input2.BackgroundColor3 = settings.buttonColor
input2.BorderSizePixel = 0
input2.TextColor3 = settings.textColor
input2.Parent = textboxRow1
local input2Corner = Instance.new("UICorner")
input2Corner.CornerRadius = UDim.new(0, settings.cornerRadius)
input2Corner.Parent = input2
-- Baris 4: Satu textbox
local input3 = Instance.new("TextBox")
input3.Name = "Input3"
input3.PlaceholderText = "Input Terakhir"
input3.Size = UDim2.new(1, -20, 0, 40)
input3.BackgroundColor3 = settings.buttonColor
input3.BorderSizePixel = 0
input3.TextColor3 = settings.textColor
input3.Parent = contentFrame
local input3Corner = Instance.new("UICorner")
input3Corner.CornerRadius = UDim.new(0, settings.cornerRadius)
input3Corner.Parent = input3
-- === Bagian Footer ===
local footerFrame = Instance.new("Frame")
footerFrame.Name = "FooterFrame"
footerFrame.Size = UDim2.new(1, 0, 0, 30)
footerFrame.BackgroundTransparency = 1
footerFrame.Parent = mainFrame
footerFrame.LayoutOrder = 3
local footerLayout = Instance.new("UIListLayout")
footerLayout.FillDirection = Enum.FillDirection.Horizontal
footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
footerLayout.Padding = UDim.new(0, 10)
footerLayout.Parent = footerFrame
local footerPadding = Instance.new("UIPadding")
footerPadding.PaddingLeft = UDim.new(0, 10)
footerPadding.PaddingRight = UDim.new(0, 10)
footerPadding.Parent = footerFrame
local function createFooterButton(name, text)
local button = Instance.new("TextButton")
button.Name = name
button.Text = text
button.Size = UDim2.new(0.25, -10, 1, 0)
button.BackgroundColor3 = settings.buttonColor
button.BorderSizePixel = 0
button.TextColor3 = settings.textColor
button.Font = Enum.Font.SourceSansBold
button.Parent = footerFrame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, settings.cornerRadius)
corner.Parent = button
return button
end
local settingsBtn = createFooterButton("SettingsBtn", "SETTING")
local infoBtn = createFooterButton("InfoBtn", "INFO")
local keybindBtn = createFooterButton("KeybindBtn", "KEYBIND")
local rejoinBtn = createFooterButton("RejoinBtn", "REJOIN")
-- === Fungsi Minimize ===
local isMinimized = false
local originalSize = mainFrame.Size
local originalPosition = mainFrame.Position
local function minimize()
if not isMinimized then
isMinimized = true
tweenGui(mainFrame, {
Size = UDim2.new(0, 50, 0, 50),
Position = UDim2.new(1, -70, 1, -70),
CornerRadius = UDim.new(1, 0) -- Menjadi lingkaran
})
headerFrame.Visible = false
contentFrame.Visible = false
footerFrame.Visible = false
closeButton.Visible = false
minimizeButton.Text = "+"
else
	isMinimized = false
	tweenGui(mainFrame, {
		Size = originalSize,
		Position = originalPosition,
		CornerRadius = UDim.new(0, settings.cornerRadius)
	})
	headerFrame.Visible = true
	contentFrame.Visible = true
	footerFrame.Visible = true
	closeButton.Visible = true
	minimizeButton.Text = "-"
end

end
minimizeButton.MouseButton1Click:Connect(minimize)
-- === Dialog Konfirmasi Close ===
local confirmFrame = Instance.new("Frame")
confirmFrame.Name = "ConfirmFrame"
confirmFrame.Size = UDim2.new(0.3, 0, 0.2, 0)
confirmFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
confirmFrame.AnchorPoint = Vector2.new(0.5, 0.5)
confirmFrame.BackgroundColor3 = settings.mainBackgroundColor
confirmFrame.BorderSizePixel = 0
confirmFrame.Parent = screenGui
confirmFrame.ZIndex = 3
confirmFrame.Visible = false
local confirmCorner = Instance.new("UICorner")
confirmCorner.CornerRadius = UDim.new(0, settings.cornerRadius)
confirmCorner.Parent = confirmFrame
local confirmLayout = Instance.new("UIListLayout")
confirmLayout.FillDirection = Enum.FillDirection.Vertical
confirmLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
confirmLayout.Padding = UDim.new(0, 10)
confirmLayout.Parent = confirmFrame
local confirmLabel = Instance.new("TextLabel")
confirmLabel.Name = "ConfirmLabel"
confirmLabel.Text = "Yakin untuk keluar?"
confirmLabel.Size = UDim2.new(1, -20, 0.5, 0)
confirmLabel.BackgroundTransparency = 1
confirmLabel.TextColor3 = settings.textColor
confirmLabel.TextScaled = true
confirmLabel.Parent = confirmFrame
local confirmButtonRow = Instance.new("Frame")
confirmButtonRow.Name = "ConfirmButtonRow"
confirmButtonRow.Size = UDim2.new(1, 0, 0.5, 0)
confirmButtonRow.BackgroundTransparency = 1
confirmButtonRow.Parent = confirmFrame
local confirmButtonLayout = Instance.new("UIListLayout")
confirmButtonLayout.FillDirection = Enum.FillDirection.Horizontal
confirmButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
confirmButtonLayout.Padding = UDim.new(0, 10)
confirmButtonLayout.Parent = confirmButtonRow
local yesButton = Instance.new("TextButton")
yesButton.Name = "YesButton"
yesButton.Text = "Ya"
yesButton.Size = UDim2.new(0.5, -5, 1, 0)
yesButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
yesButton.BorderSizePixel = 0
yesButton.TextColor3 = settings.textColor
yesButton.Parent = confirmButtonRow
local yesCorner = Instance.new("UICorner")
yesCorner.CornerRadius = UDim.new(0, 5)
yesCorner.Parent = yesButton
local noButton = Instance.new("TextButton")
noButton.Name = "NoButton"
noButton.Text = "Tidak"
noButton.Size = UDim2.new(0.5, -5, 1, 0)
noButton.BackgroundColor3 = settings.buttonColor
noButton.BorderSizePixel = 0
noButton.TextColor3 = settings.textColor
noButton.Parent = confirmButtonRow
local noCorner = Instance.new("UICorner")
noCorner.CornerRadius = UDim.new(0, 5)
noCorner.Parent = noButton
local backgroundFade = Instance.new("Frame")
backgroundFade.Name = "BackgroundFade"
backgroundFade.Size = UDim2.new(1, 0, 1, 0)
backgroundFade.BackgroundTransparency = 1
backgroundFade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backgroundFade.ZIndex = 2
backgroundFade.Parent = screenGui
backgroundFade.Visible = false
closeButton.MouseButton1Click:Connect(function()
backgroundFade.Visible = true
confirmFrame.Visible = true
tweenGui(backgroundFade, { BackgroundTransparency = 0.5 })
tweenGui(confirmFrame, { Size = UDim2.new(0.3, 0, 0.2, 0) })
end)
yesButton.MouseButton1Click:Connect(function()
tweenGui(mainFrame, { Position = UDim2.new(0.5, 0, 1.5, 0) })
tweenGui(backgroundFade, { BackgroundTransparency = 1 })
wait(settings.animationTime)
screenGui:Destroy()
end)
noButton.MouseButton1Click:Connect(function()
tweenGui(backgroundFade, { BackgroundTransparency = 1 })
tweenGui(confirmFrame, { Size = UDim2.new(0.3, 0, 0, 0) })
wait(settings.animationTime)
backgroundFade.Visible = false
confirmFrame.Visible = false
end)
-- === Fungsi Drag GUI ===
local isDragging = false
local dragStartPos
local initialPos
local function onInputBegan(input, gameProcessed)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
local pos = UserInputService:GetMouseLocation()
if not isMinimized and mainFrame:IsA("GuiObject") and pos.X >= mainFrame.AbsolutePosition.X and pos.X <= mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X and pos.Y >= mainFrame.AbsolutePosition.Y and pos.Y <= mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y then
isDragging = true
dragStartPos = pos
initialPos = mainFrame.Position
end
end
end
local function onInputChanged(input, gameProcessed)
if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
local mousePos = UserInputService:GetMouseLocation()
local delta = mousePos - dragStartPos
local newX = initialPos.X.Scale + delta.X / game.Workspace.CurrentCamera.ViewportSize.X
local newY = initialPos.Y.Scale + delta.Y / game.Workspace.CurrentCamera.ViewportSize.Y
mainFrame.Position = UDim2.new(newX, 0, newY, 0)
end
end
local function onInputEnded(input, gameProcessed)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
isDragging = false
end
end
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)
-- === Mobile Friendly Resize ===
local function onScreenSizeChanged()
local viewportSize = game.Workspace.CurrentCamera.ViewportSize
local newWidth = viewportSize.X * 0.9 -- Untuk mobile, bisa lebih lebar
local newHeight = viewportSize.Y * 0.6
if viewportSize.X > 1000 then -- Desktop
newWidth = viewportSize.X * 0.3
end
mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
originalSize = mainFrame.Size

end
game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onScreenSizeChanged)
onScreenSizeChanged() -- Panggil saat pertama kali
