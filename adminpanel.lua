-- adminpanel.lua (patched version) -- Perubahan sesuai instruksi: -- - Hanya 2 tema: Dark & Light -- - Hapus toggle Dark Mode -- - Hapus tombol Create New Theme -- - Hapus expand/collapse section -- - Pertahankan semua kode lain

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/init.lua"))()

WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({ Title = "Admin Panel", Icon = "geist:window", Author = "System", Folder = "AdminPanel", Size = UDim2.fromOffset(580, 490), Theme = "Dark", User = { Enabled = true, Anonymous = true, }, Acrylic = false, HideSearchBar = false, SideBarWidth = 200, })

-- Tabs local Tabs = { Main = Window:Section({ Title = "Main", Opened = true }), Settings = Window:Section({ Title = "Settings", Opened = true }), Utilities = Window:Section({ Title = "Utilities", Opened = true }), }

local TabHandles = { Player = Tabs.Main:Tab({ Title = "Player", Icon = "user" }), Execute = Tabs.Main:Tab({ Title = "Execute", Icon = "code" }), Appearance = Tabs.Settings:Tab({ Title = "Appearance", Icon = "brush" }), Config = Tabs.Utilities:Tab({ Title = "Configuration", Icon = "settings" }) }

-- Player Tab (no expand) TabHandles.Player:Paragraph({ Title = "Player Tools", Desc = "Manage player settings", })

-- Execute Tab (no expand) TabHandles.Execute:Paragraph({ Title = "Execute Commands", Desc = "Run scripts or commands", })

-- Appearance Tab TabHandles.Appearance:Paragraph({ Title = "Customize Interface", Desc = "Switch between Dark and Light themes", Image = "palette", ImageSize = 20, Color = "White" })

-- Theme dropdown (only Dark & Light) local themeDropdown = TabHandles.Appearance:Dropdown({ Title = "Select Theme", Values = { "Dark", "Light" }, Value = "Dark", Callback = function(theme) WindUI:SetTheme(theme) WindUI:Notify({ Title = "Theme Applied", Content = theme, Icon = "palette", Duration = 2 }) end })

-- Transparency slider local transparencySlider = TabHandles.Appearance:Slider({ Title = "Window Transparency", Value = { Min = 0, Max = 1, Default = 0.2 }, Step = 0.1, Callback = function(value) WindUI.TransparencyValue = tonumber(value) Window:ToggleTransparency(tonumber(value) > 0) end })

-- Config Tab tetap dipertahankan utuh TabHandles.Config:Paragraph({ Title = "Configuration Manager", Desc = "Save and load your settings", Image = "save", ImageSize = 20, Color = "White" })

-- Footer local footerSection = Window:Section({ Title = "Admin Panel v1.0" }) footerSection:Paragraph({ Title = "Created with ❤", Desc = "github.com/YourRepo", Image = "github", ImageSize = 20, Color = "Grey", })

Window:OnClose(function() print("Window closed") end)

Window:OnDestroy(function() print("Window destroyed") end)

-- Ensure window opens Window:Open()

