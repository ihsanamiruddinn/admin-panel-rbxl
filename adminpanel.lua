--[[
	Replika Pustaka Orion oleh Gemini
	
	Skrip ini meniru fungsi inti dari Orion Library, memungkinkan Anda untuk membuat
	antarmuka pengguna dengan API yang familiar, tanpa perlu memuat pustaka dari luar.
	Ini adalah solusi lengkap dalam satu file.
]]

-- === Bagian Replika Pustaka (Jangan diubah) ===
local OrionLib = {}
OrionLib.Flags = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local currentWindow
local currentTabs = {}
local introScreen

-- Fungsi internal untuk membuat transisi halus
local function tweenGui(instance, properties)
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
end

-- === Metode Pustaka Utama ===

-- Membuat jendela utama
function OrionLib:MakeWindow(config)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "OrionWindow"
	screenGui.ResetOnSpawn = false
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 300, 0, 400)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 44, 52)
	mainFrame.BorderSizePixel = 0
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = mainFrame
	
	-- Dragging
	local isDragging = false
	local dragStartPos
	local initialPos
	
	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragStartPos = input.Position
			initialPos = mainFrame.Position
			UserInputService.InputChanged:Wait()
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStartPos
			mainFrame.Position = UDim2.new(initialPos.X.Scale, initialPos.X.Offset + delta.X, initialPos.Y.Scale, initialPos.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)
	
	-- Tabs
	local tabFrame = Instance.new("Frame")
	tabFrame.Name = "TabFrame"
	tabFrame.Size = UDim2.new(0.25, 0, 1, 0)
	tabFrame.BackgroundColor3 = Color3.fromRGB(32, 35, 41)
	tabFrame.BorderSizePixel = 0
	tabFrame.Parent = mainFrame
	
	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Vertical
	tabList.VerticalAlignment = Enum.VerticalAlignment.Top
	tabList.Padding = UDim.new(0, 5)
	tabList.Parent = tabFrame
	
	local tabContent = Instance.new("Frame")
	tabContent.Name = "TabContent"
	tabContent.Size = UDim2.new(0.75, 0, 1, 0)
	tabContent.Position = UDim2.new(0.25, 0, 0, 0)
	tabContent.BackgroundColor3 = Color3.fromRGB(40, 44, 52)
	tabContent.BorderSizePixel = 0
	tabContent.Parent = mainFrame
	
	local contentList = Instance.new("UIListLayout")
	contentList.FillDirection = Enum.FillDirection.Vertical
	contentList.HorizontalAlignment = Enum.HorizontalAlignment.Left
	contentList.Padding = UDim.new(0, 10)
	contentList.Parent = tabContent
	
	mainFrame.Parent = screenGui
	currentWindow = {
		screenGui = screenGui,
		mainFrame = mainFrame,
		tabFrame = tabFrame,
		tabContent = tabContent,
		tabs = {}
	}
	
	-- Intro
	if config.IntroEnabled then
		introScreen = Instance.new("Frame")
		introScreen.Size = UDim2.new(1, 0, 1, 0)
		introScreen.BackgroundColor3 = Color3.fromRGB(32, 35, 41)
		introScreen.Parent = screenGui
		
		local introLabel = Instance.new("TextLabel")
		introLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
		introLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		introLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		introLabel.Text = config.IntroText
		introLabel.BackgroundTransparency = 1
		introLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		introLabel.TextScaled = true
		introLabel.Parent = introScreen
	end
	
	return {
		MakeTab = function(tabConfig)
			return OrionLib:MakeTab(tabConfig, tabFrame, tabContent)
		end
	}
end

-- Membuat tab
function OrionLib:MakeTab(tabConfig, tabFrame, tabContent)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = "Tab_" .. tabConfig.Name
	tabButton.Text = tabConfig.Name
	tabButton.Size = UDim2.new(1, 0, 0, 40)
	tabButton.BackgroundColor3 = Color3.fromRGB(40, 44, 52)
	tabButton.BorderSizePixel = 0
	tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabButton.Font = Enum.Font.SourceSansBold
	tabButton.Parent = tabFrame
	
	local tabContentFrame = Instance.new("Frame")
	tabContentFrame.Name = "Content_" .. tabConfig.Name
	tabContentFrame.Size = UDim2.new(1, 0, 1, 0)
	tabContentFrame.BackgroundTransparency = 1
	tabContentFrame.Parent = tabContent
	tabContentFrame.Visible = false
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Vertical
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	contentLayout.Padding = UDim.new(0, 10)
	contentLayout.Parent = tabContentFrame
	
	local currentTab = {
		Name = tabConfig.Name,
		Frame = tabContentFrame
	}
	
	currentTabs[tabConfig.Name] = currentTab
	
	tabButton.MouseButton1Click:Connect(function()
		for _, tab in pairs(currentTabs) do
			tab.Frame.Visible = false
		end
		tabContentFrame.Visible = true
	end)
	
	return {
		AddSection = function(sectionConfig)
			return OrionLib:AddSection(sectionConfig, tabContentFrame)
		end,
		AddButton = function(buttonConfig)
			return OrionLib:AddButton(buttonConfig, tabContentFrame)
		end,
		AddLabel = function(text)
			return OrionLib:AddLabel(text, tabContentFrame)
		end,
		AddTextbox = function(textboxConfig)
			return OrionLib:AddTextbox(textboxConfig, tabContentFrame)
		end,
		AddParagraph = function(title, content)
			return OrionLib:AddParagraph(title, content, tabContentFrame)
		end,
		AddToggle = function(toggleConfig)
			return OrionLib:AddToggle(toggleConfig, tabContentFrame)
		end,
		AddColorpicker = function(colorpickerConfig)
			return OrionLib:AddColorpicker(colorpickerConfig, tabContentFrame)
		end,
		AddSlider = function(sliderConfig)
			return OrionLib:AddSlider(sliderConfig, tabContentFrame)
		end,
		AddBind = function(bindConfig)
			return OrionLib:AddBind(bindConfig, tabContentFrame)
		end,
		AddDropdown = function(dropdownConfig)
			return OrionLib:AddDropdown(dropdownConfig, tabContentFrame)
		end,
	}
end

-- Membuat bagian (section)
function OrionLib:AddSection(sectionConfig, parent)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Name = sectionConfig.Name .. "Section"
	sectionFrame.Size = UDim2.new(1, 0, 0, 30)
	sectionFrame.BackgroundTransparency = 1
	sectionFrame.Parent = parent
	
	local sectionLabel = Instance.new("TextLabel")
	sectionLabel.Name = "SectionLabel"
	sectionLabel.Text = "=== " .. sectionConfig.Name .. " ==="
	sectionLabel.Size = UDim2.new(1, 0, 1, 0)
	sectionLabel.BackgroundTransparency = 1
	sectionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	sectionLabel.Font = Enum.Font.SourceSansBold
	sectionLabel.TextScaled = true
	sectionLabel.Parent = sectionFrame
	
	return sectionFrame
end

-- Membuat tombol
function OrionLib:AddButton(buttonConfig, parent)
	local button = Instance.new("TextButton")
	button.Name = "Button_" .. buttonConfig.Name
	button.Text = buttonConfig.Name
	button.Size = UDim2.new(1, 0, 0, 30)
	button.BackgroundColor3 = Color3.fromRGB(64, 70, 78)
	button.BorderSizePixel = 0
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSansBold
	button.Parent = parent
	
	if buttonConfig.Callback then
		button.MouseButton1Click:Connect(buttonConfig.Callback)
	end
	return button
end

-- Membuat label
function OrionLib:AddLabel(text, parent)
	local label = Instance.new("TextLabel")
	label.Text = text
	label.Size = UDim2.new(1, 0, 0, 30)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true
	label.Parent = parent
	
	return { Set = function(newText) label.Text = newText end }
end

-- Membuat paragraf
function OrionLib:AddParagraph(title, content, parent)
	local label = Instance.new("TextLabel")
	label.Text = title .. "\n" .. content
	label.Size = UDim2.new(1, 0, 0, 60)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Parent = parent
	
	return { Set = function(newTitle, newContent) label.Text = newTitle .. "\n" .. newContent end }
end

-- Membuat textbox
function OrionLib:AddTextbox(textboxConfig, parent)
	local textbox = Instance.new("TextBox")
	textbox.Name = "Textbox_" .. textboxConfig.Name
	textbox.PlaceholderText = textboxConfig.Default
	textbox.Size = UDim2.new(1, 0, 0, 30)
	textbox.BackgroundColor3 = Color3.fromRGB(52, 58, 64)
	textbox.BorderSizePixel = 0
	textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textbox.Parent = parent
	
	if textboxConfig.Callback then
		textbox.FocusLost:Connect(function()
			textboxConfig.Callback(textbox.Text)
		end)
	end
	return textbox
end

-- Membuat toggle
function OrionLib:AddToggle(toggleConfig, parent)
	local toggle = Instance.new("Frame")
	toggle.Name = "Toggle_" .. toggleConfig.Name
	toggle.Size = UDim2.new(1, 0, 0, 30)
	toggle.BackgroundTransparency = 1
	toggle.Parent = parent
	
	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0.2, 0, 1, 0)
	toggleButton.Position = UDim2.new(0.8, 0, 0, 0)
	toggleButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	toggleButton.BorderSizePixel = 0
	toggleButton.Parent = toggle
	
	local toggleLabel = Instance.new("TextLabel")
	toggleLabel.Text = toggleConfig.Name
	toggleLabel.Size = UDim2.new(0.8, 0, 1, 0)
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.Parent = toggle
	
	local currentValue = toggleConfig.Default
	
	local function updateToggle()
		if currentValue then
			tweenGui(toggleButton, {BackgroundColor3 = Color3.fromRGB(90, 180, 255)})
		else
			tweenGui(toggleButton, {BackgroundColor3 = Color3.fromRGB(150, 150, 150)})
		end
		if toggleConfig.Callback then
			toggleConfig.Callback(currentValue)
		end
		if toggleConfig.Save and toggleConfig.Flag then
			OrionLib.Flags[toggleConfig.Flag] = { Value = currentValue }
		end
	end
	
	toggleButton.MouseButton1Click:Connect(function()
		currentValue = not currentValue
		updateToggle()
	end)
	
	updateToggle()
	return { Set = function(value) currentValue = value; updateToggle() end }
end

-- Membuat slider
function OrionLib:AddSlider(sliderConfig, parent)
	local slider = Instance.new("Frame")
	slider.Name = "Slider_" .. sliderConfig.Name
	slider.Size = UDim2.new(1, 0, 0, 40)
	slider.BackgroundTransparency = 1
	slider.Parent = parent
	
	local sliderLabel = Instance.new("TextLabel")
	sliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
	sliderLabel.BackgroundTransparency = 1
	sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
	sliderLabel.Parent = slider
	
	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(1, 0, 0, 5)
	sliderBar.BackgroundColor3 = Color3.fromRGB(64, 70, 78)
	sliderBar.Position = UDim2.new(0, 0, 0.5, 0)
	sliderBar.Parent = slider
	
	local sliderHandle = Instance.new("Frame")
	sliderHandle.Size = UDim2.new(0, 10, 0, 15)
	sliderHandle.BackgroundColor3 = Color3.fromRGB(90, 180, 255)
	sliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
	sliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
	sliderHandle.Parent = sliderBar
	
	local currentValue = sliderConfig.Default or sliderConfig.Min
	local isDragging = false
	
	local function updateSlider(pos)
		local newX = math.clamp(pos, 0, 1)
		local value = sliderConfig.Min + (sliderConfig.Max - sliderConfig.Min) * newX
		value = math.round(value / sliderConfig.Increment) * sliderConfig.Increment
		currentValue = value
		
		sliderHandle.Position = UDim2.new((value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 0.5, 0)
		sliderLabel.Text = string.format("%s: %s %s", sliderConfig.Name, tostring(currentValue), sliderConfig.ValueName or "")
		
		if sliderConfig.Callback then
			sliderConfig.Callback(currentValue)
		end
	end
	
	sliderHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			UserInputService.InputChanged:Wait()
		end
	end)
	
	sliderHandle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging then
			local mousePos = UserInputService:GetMouseLocation()
			local relativePos = (mousePos.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
			updateSlider(relativePos)
		end
	end)
	
	updateSlider()
	return { Set = function(value) updateSlider((value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)) end }
end

-- Membuat pemberitahuan
function OrionLib:MakeNotification(notificationConfig)
	local notification = Instance.new("Frame")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0.2, 0, 0, 80)
	notification.Position = UDim2.new(1.1, 0, 0.1, 0)
	notification.AnchorPoint = Vector2.new(1, 0)
	notification.BackgroundColor3 = Color3.fromRGB(40, 44, 52)
	notification.BorderSizePixel = 0
	notification.Parent = currentWindow.screenGui
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = notification
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = notificationConfig.Name
	titleLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
	titleLabel.Size = UDim2.new(0.8, 0, 0.4, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextScaled = true
	titleLabel.Parent = notification
	
	local contentLabel = Instance.new("TextLabel")
	contentLabel.Text = notificationConfig.Content
	contentLabel.Position = UDim2.new(0.1, 0, 0.5, 0)
	contentLabel.Size = UDim2.new(0.8, 0, 0.4, 0)
	contentLabel.BackgroundTransparency = 1
	contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	contentLabel.Font = Enum.Font.SourceSans
	contentLabel.TextScaled = true
	contentLabel.Parent = notification
	
	tweenGui(notification, {Position = UDim2.new(0.95, 0, 0.1, 0)})
	
	delay(notificationConfig.Time, function()
		tweenGui(notification, {Position = UDim2.new(1.1, 0, 0.1, 0)})
		delay(0.5, function()
			notification:Destroy()
		end)
	end)
end

-- Fungsi inisialisasi
function OrionLib:Init()
	currentWindow.screenGui.Parent = player:WaitForChild("PlayerGui")
	if currentTabs and next(currentTabs) then
		local firstTab = currentTabs[next(currentTabs)]
		firstTab.Frame.Visible = true
	end
	
	if introScreen then
		delay(2, function()
			tweenGui(introScreen, {BackgroundTransparency = 1})
			wait(0.5)
			introScreen:Destroy()
		end)
	end
end

-- Fungsi hancurkan
function OrionLib:Destroy()
	if currentWindow and currentWindow.screenGui then
		currentWindow.screenGui:Destroy()
	end
end

-- === Bagian Antarmuka Pengguna (GUI) ===
-- Ini adalah kode yang menggunakan replika pustaka di atas.

local Window = OrionLib:MakeWindow({
	Name = "TripleS Hub",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "TripleSConfig",
	IntroEnabled = true,
	IntroText = "Selamat Datang, TripleS!",
	IntroIcon = "rbxassetid://4483345998",
	CloseCallback = function()
		OrionLib:MakeNotification({
			Name = "Keluar",
			Content = "Jendela GUI telah ditutup.",
			Image = "rbxassetid://4483345998",
			Time = 5
		})
	end
})

local MainTab = Window:MakeTab({
	Name = "Utama",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MainTab:AddTextbox({
	Name = "Input",
	Default = "Masukkan teks...",
	TextDisappear = true,
	Callback = function(Value)
		print("Kotak teks utama: " .. Value)
	end	  
})

local ButtonSection1 = MainTab:AddSection({ Name = "Tombol Berdampingan 1" })
ButtonSection1:AddButton({
	Name = "Tombol 1",
	Callback = function() print("Tombol 1 ditekan") end    
})
ButtonSection1:AddButton({
	Name = "Tombol 2",
	Callback = function() print("Tombol 2 ditekan") end    
})

local ButtonSection2 = MainTab:AddSection({ Name = "Tombol Berdampingan 2" })
ButtonSection2:AddButton({
	Name = "Tombol 3",
	Callback = function() print("Tombol 3 ditekan") end    
})
ButtonSection2:AddButton({
	Name = "Tombol 4",
	Callback = function() print("Tombol 4 ditekan") end    
})

local TextboxSection1 = MainTab:AddSection({ Name = "Kotak Teks 1" })
TextboxSection1:AddTextbox({
	Name = "Kotak 1",
	Default = "Input 1",
	TextDisappear = false,
	Callback = function(Value) print("Kotak Teks 1: " .. Value) end	  
})
TextboxSection1:AddTextbox({
	Name = "Kotak 2",
	Default = "Input 2",
	TextDisappear = false,
	Callback = function(Value) print("Kotak Teks 2: " .. Value) end	  
})

local TextboxSection2 = MainTab:AddSection({ Name = "Kotak Teks 2" })
TextboxSection2:AddTextbox({
	Name = "Kotak 3",
	Default = "Input 3",
	TextDisappear = false,
	Callback = function(Value) print("Kotak Teks 3: " .. Value) end	  
})

MainTab:AddSection({ Name = "Pilihan Cepat"})

MainTab:AddButton({
	Name = "SETTING",
	Callback = function()
		OrionLib:MakeNotification({Name = "Notifikasi", Content = "Tombol SETTING ditekan!", Time = 3})
	end
})
MainTab:AddButton({
	Name = "INFO",
	Callback = function()
		OrionLib:MakeNotification({Name = "Notifikasi", Content = "Tombol INFO ditekan!", Time = 3})
	end
})
MainTab:AddButton({
	Name = "KEYBIND",
	Callback = function()
		OrionLib:MakeNotification({Name = "Notifikasi", Content = "Tombol KEYBIND ditekan!", Time = 3})
	end
})
MainTab:AddButton({
	Name = "REJOIN",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
	end
})

-- === Wajib: Menginisialisasi Pustaka ===
OrionLib:Init()

