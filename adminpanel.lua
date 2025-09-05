local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()
local Window = library:Window({
    Title = "TripleS",
    Author = "By saanseventeen",
    Description = "github.com/saanseventeen",
    Size = UDim2.fromOffset(300, 360),
    Theme = "Dark",
    Tags = {
        { "TripleS v1.0", Color3.fromRGB(255, 128, 64) },
        { "Stable", Color3.fromRGB(64, 200, 255) },
    }
})

local FeaturesTab = Window:Tab({ Title = "Features" })
local UniversalSection = FeaturesTab:Section({ Title = "Universal" })
UniversalSection:Toggle({ Title = "Enable Universal", Default = false })
UniversalSection:Slider({ Title = "Execution Delay", Min = 0, Max = 10, Default = 2 })
UniversalSection:Dropdown({ Title = "Select Mode", Values = { "Mode A", "Mode B", "Mode C" }, Default = "Mode A" })

local SettingsTab = Window:Tab({ Title = "Settings" })
local AppearanceSection = SettingsTab:Section({ Title = "Appearance" })
AppearanceSection:Dropdown({ Title = "Theme", Values = { "Dark", "Light", "Amethyst", "Ocean" }, Default = "Dark" })
AppearanceSection:Slider({ Title = "Transparency", Min = 0, Max = 1, Default = 0.1, Precise = true })
local KeybindSection = SettingsTab:Section({ Title = "Keybind" })
KeybindSection:Bind({ Title = "Open/Close UI", Default = Enum.KeyCode.RightShift, Callback = function() Window:Toggle() end })

local UtilitiesTab = Window:Tab({ Title = "Utilities" })
local ConfigurationSection = UtilitiesTab:Section({ Title = "Configuration" })
ConfigurationSection:Button({ Title = "Save Settings", Callback = function() library:SaveConfig("TripleS_Config") end })
ConfigurationSection:Button({ Title = "Load Settings", Callback = function() library:LoadConfig("TripleS_Config") end })
local PluginsSection = UtilitiesTab:Section({ Title = "Plugins" })
PluginsSection:Button({ Title = "Load Plugin", Callback = function() print("Plugin Loaded") end })

Window:Initialize()
