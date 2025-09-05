local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "TripleS",
    Author = "by saanseventeen",
    Size = UDim2.fromOffset(360, 300),
    Folder = "TripleS_Config",
    Theme = "Dark"
})

local TabUniversal = Window:Tab({ Title = "Universal" })
TabUniversal:Paragraph({
    Title = "by saanseventeen",
    Desc = ""
})
TabUniversal:Button({
    Title = "Auto Farm",
    Callback = function() end
})
TabUniversal:Button({
    Title = "ESP",
    Callback = function() end
})
TabUniversal:Button({
    Title = "Teleport",
    Callback = function() end
})
TabUniversal:Toggle({
    Title = "Enable Features",
    Default = false,
    Callback = function(state) end
})
TabUniversal:Slider({
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 100,
    Callback = function(value) end
})

local TabSettings = Window:Tab({ Title = "Settings" })
TabSettings:Paragraph({
    Title = "Appearance",
    Desc = ""
})
TabSettings:Dropdown({
    Title = "Theme",
    Values = { "Dark", "Light" },
    Value = "Dark",
    Callback = function(option) end
})
TabSettings:Slider({
    Title = "Transparency",
    Default = 0.2,
    Min = 0,
    Max = 1,
    Step = 0.1,
    Callback = function(value) end
})
TabSettings:Paragraph({
    Title = "Keybind",
    Desc = ""
})
TabSettings:Keybind({
    Title = "UI Toggle",
    Default = Enum.KeyCode.RightControl,
    Callback = function() end
})

local TabUtilities = Window:Tab({ Title = "Utilities" })
TabUtilities:Paragraph({
    Title = "Configuration",
    Desc = "Save and load your settings"
})
TabUtilities:Button({
    Title = "Save Settings",
    Callback = function() end
})
TabUtilities:Button({
    Title = "Load Settings",
    Callback = function() end
})
TabUtilities:Paragraph({
    Title = "Plugins",
    Desc = ""
})
TabUtilities:Button({
    Title = "Open Plugins",
    Callback = function() end
})
TabUtilities:Paragraph({
    Title = "Created with ❤️",
    Desc = "https://github.com/ihsanamiruddinn/TripleS-UI"
})

local TabMisc = Window:Tab({ Title = "Misc" })
TabMisc:Button({
    Title = "Rejoin",
    Callback = function() end
})
TabMisc:Button({
    Title = "Server Hop",
    Callback = function() end
})
TabMisc:Button({
    Title = "Destroy UI",
    Callback = function() end
})
