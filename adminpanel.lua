local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

local win = WindUI:CreateWindow({
    Title = "TripleS",
    Size = UDim2.fromOffset(360, 300),
    ConfigFolder = "TripleS-Config",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- Tab Welcome
local welcomeTab = win:AddTab("Welcome")
welcomeTab:AddParagraph("by saanseventeen", "Created with: https://github.com/ihsanamiruddinn/TripleS-UI")

-- Tab Main
local mainTab = win:AddTab("Main")
mainTab:AddButton("Auto Farm", function()
    print("Auto Farm dijalankan!")
end)
mainTab:AddButton("ESP", function()
    print("ESP diaktifkan!")
end)
mainTab:AddButton("Teleport", function()
    print("Teleport aktif!")
end)

-- Tab Universal
local universalTab = win:AddTab("Universal")
universalTab:AddButton("Speed Hack", function()
    print("Speed Hack aktif!")
end)
universalTab:AddButton("Infinite Jump", function()
    print("Infinite Jump aktif!")
end)

-- Tab Settings
local settingsTab = win:AddTab("Settings")
settingsTab:AddButton("Appearance", function()
    print("Appearance settings")
end)
settingsTab:AddButton("Keybind", function()
    print("Keybind settings")
end)

-- Tab Utilities
local utilitiesTab = win:AddTab("Utilities")
utilitiesTab:AddButton("Configuration", function()
    print("Configuration panel")
end)
utilitiesTab:AddButton("Plugins", function()
    print("Plugins panel")
end)

-- Tab Misc
local miscTab = win:AddTab("Misc")
miscTab:AddButton("Destroy UI", function()
    win:Destroy()
end)
