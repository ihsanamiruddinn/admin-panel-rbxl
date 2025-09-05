-- Fixed adminpanel.lua with simplified Appearance (only Dark & Light themes), removed Dark Mode toggle, and removed expandable sections

local WindUI = require("./src/init")

WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({ Title = "Admin Panel", Icon = "geist:window", Author = "System", Folder = "AdminPanel", Size = UDim2.fromOffset(580, 490), Theme = "Dark", User = { Enabled = true, Anonymous = true, }, Acrylic = false, HideSearchBar = false, SideBarWidth = 200, })

-- Tabs local Tabs = { Main = Window:Section({ Title = "Main", Opened = true }), Settings = Window:Section({ Title = "Settings", Opened = true }), }

local TabHandles = { Player = Tabs.Main:Tab({ Title = "Player", Icon = "user" }), Execute = Tabs.Main:Tab({ Title = "Execute", Icon = "code" }), Appearance = Tabs.Settings:Tab({ Title = "Appearance", Icon = "brush" }), }

-- Player Tab (no expand/collapse) TabHandles.Player:Paragraph({ Title = "Player Tools", Desc = "Manage player settings", })

-- Execute Tab (no expand/collapse) TabHandles.Execute:Paragraph({ Title = "Execute Commands", Desc = "Run scripts or commands", })

-- Appearance Tab TabHandles.Appearance:Paragraph({ Title = "Customize Interface", Desc = "Switch between Dark and Light themes", Image = "palette", ImageSize = 20, Color = "White" })

local themeDropdown = TabHandles.Appearance:Dropdown({ Title = "Select Theme", Values = { "Dark", "Light" }, Value = "Dark", Callback = function(theme) WindUI:SetTheme(theme) WindUI:Notify({ Title = "Theme Applied", Content = theme, Icon = "palette", Duration = 2 }) end })

local transparencySlider = TabHandles.Appearance:Slider({ Title = "Window Transparency", Value = { Min = 0, Max = 1, Default = 0.2 }, Step = 0.1, Callback = function(value) WindUI.TransparencyValue = tonumber(value) Window:ToggleTransparency(tonumber(value) > 0) end })

-- Footer local footerSection = Window:Section({ Title = "Admin Panel v1.0" }) footerSection:Paragraph({ Title = "Created with ❤", Desc = "github.com/YourRepo", Image = "github", ImageSize = 20, Color = "Grey", })

Window:OnClose(function() print("Window closed") end)

Window:OnDestroy(function() print("Window destroyed") end)

