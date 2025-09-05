-- TripleS Admin UI - Full Version v2
-- Author: ihsanamiruddinn
-- github.com/ihsanamiruddinn

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("[TripleS Admin UI] Failed to load WindUI library!")
    if game:GetService("StarterGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "TripleS Admin UI",
            Text = "WindUI gagal dimuat! Periksa link GitHub.",
            Duration = 5
        })
    end
    return
end

WindUI:SetTheme("Dark")
WindUI.TransparencyValue = 0.15

-- Main Window
local Window = WindUI:CreateWindow({
    Title = "TripleS Admin UI v2",
    Icon = "shield",
    Author = "github.com/ihsanamiruddinn",
    Folder = "TripleS_Admin_UI",
    Size = UDim2.fromOffset(540, 400),
    Theme = "Dark",
    Acrylic = true,
    SideBarWidth = 200,
})

Window:Tag({ Title = "Admin v2.0", Color = Color3.fromRGB(0, 255, 100) })

-- Sections
local Sections = {
    Features = Window:Section({ Title = "Features", Opened = true }),
    Settings = Window:Section({ Title = "Settings", Opened = true }),
    Config = Window:Section({ Title = "Configuration", Opened = true }),
    Utility = Window:Section({ Title = "Utility", Opened = false })
}

-- Tabs
local Tabs = {
    Admin = Sections.Features:Tab({ Title = "Admin", Icon = "shield" }),
    Executor = Sections.Features:Tab({ Title = "Executor", Icon = "terminal" }),
    Emotes = Sections.Features:Tab({ Title = "Emotes", Icon = "music" }),
    Appearance = Sections.Settings:Tab({ Title = "Appearance", Icon = "brush" }),
    Config = Sections.Config:Tab({ Title = "Config", Icon = "settings" }),
    Plugins = Sections.Config:Tab({ Title = "Plugins", Icon = "package" }),
    Keybinds = Sections.Utility:Tab({ Title = "Keybinds", Icon = "keyboard" })
}

--------------------------------------------------
-- ADMIN COMMANDS
--------------------------------------------------
local walkSpeed = 16

Tabs.Admin:Toggle({
    Title = "Fly (toggle)", Value = false, 
    Callback = function(v) end
})
Tabs.Admin:Toggle({
    Title = "Noclip (toggle)", Value = false, 
    Callback = function(v) end
})
Tabs.Admin:Toggle({
    Title = "Fling (toggle)", Value = false, 
    Callback = function(v) end
})
Tabs.Admin:Toggle({
    Title = "Anti Fling", Value = false, 
    Callback = function(v) end
})

-- Speed Control
Tabs.Admin:Toggle({
    Title = "Speed (set 25)", Value = false,
    Callback = function(v)
        if Humanoid then
            if v then
                Humanoid.WalkSpeed = 25
                walkSpeed = 25
            else
                Humanoid.WalkSpeed = 16
                walkSpeed = 16
            end
        end
    end
})
Tabs.Admin:Button({
    Title = "+ Speed",
    Callback = function()
        if Humanoid then
            walkSpeed = walkSpeed + 5
            Humanoid.WalkSpeed = walkSpeed
        end
    end
})
Tabs.Admin:Button({
    Title = "- Speed",
    Callback = function()
        if Humanoid then
            walkSpeed = math.max(0, walkSpeed - 5)
            Humanoid.WalkSpeed = walkSpeed
        end
    end
})

-- Other Admin Inputs
Tabs.Admin:Input({ Title = "Spectate Player", Placeholder = "Player name", Callback = function(txt) end })
Tabs.Admin:Button({ Title = "Stop Spectate", Callback = function() end })
Tabs.Admin:Input({ Title = "Headsit Player", Placeholder = "Player name", Callback = function(txt) end })
Tabs.Admin:Button({ Title = "Stop Headsit", Callback = function() end })
Tabs.Admin:Input({ Title = "Teleport to Player", Placeholder = "Player name", Callback = function(txt) end })
Tabs.Admin:Input({ Title = "Bring Player", Placeholder = "Player name", Callback = function(txt) end })
Tabs.Admin:Input({ Title = "Goto Part", Placeholder = "Part name", Callback = function(txt) end })
Tabs.Admin:Input({ Title = "Freeze Player", Placeholder = "Player name", Callback = function(txt) end })

--------------------------------------------------
-- EXECUTOR
--------------------------------------------------
Tabs.Executor:Input({ Title = "Command Bar", Placeholder = ";cmd args", Callback = function(txt) end })
Tabs.Executor:Button({ Title = "Rejoin", Callback = function() end })
Tabs.Executor:Toggle({ Title = "Auto Rejoin", Value = false, Callback = function(v) end })

--------------------------------------------------
-- EMOTES
--------------------------------------------------
Tabs.Emotes:Button({ Title = "Play Dance 1", Callback = function() end })
Tabs.Emotes:Button({ Title = "Play Dance 2", Callback = function() end })
Tabs.Emotes:Button({ Title = "Float", Callback = function() end })
Tabs.Emotes:Button({ Title = "Freeze", Callback = function() end })
Tabs.Emotes:Button({ Title = "Stop Emote", Callback = function() end })

--------------------------------------------------
-- APPEARANCE
--------------------------------------------------
Tabs.Appearance:Dropdown({
    Title = "Theme",
    Values = {"Dark","Light"},
    Value = "Dark",
    Callback = function(v) WindUI:SetTheme(v) end
})
Tabs.Appearance:Slider({
    Title = "Transparency",
    Value = { Min = 0, Max = 1, Default = 0.15 },
    Step = 0.05,
    Callback = function(val) WindUI.TransparencyValue = val end
})

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------
Tabs.Config:Button({ Title = "Save Config", Callback = function() end })
Tabs.Config:Button({ Title = "Load Config", Callback = function() end })

--------------------------------------------------
-- PLUGINS
--------------------------------------------------
Tabs.Plugins:Paragraph({ Title = "Plugins", Desc = "Support for extra modules" })
Tabs.Plugins:Input({
    Title = "Add Plugin",
    Placeholder = "Enter plugin link",
    Callback = function(link)
        if link and link ~= "" then
            pcall(function()
                loadstring(game:HttpGet(link))()
            end)
        end
    end
})

--------------------------------------------------
-- KEYBINDS
--------------------------------------------------
Tabs.Keybinds:Paragraph({ Title = "Admin Toggles Keybind", Desc = "Bind keys to admin features" })
Tabs.Keybinds:Keybind({
    Title = "Toggle Fly",
    Key = Enum.KeyCode.F,
    Callback = function() end
})
Tabs.Keybinds:Keybind({
    Title = "Toggle Noclip",
    Key = Enum.KeyCode.N,
    Callback = function() end
})
Tabs.Keybinds:Keybind({
    Title = "Toggle Fling",
    Key = Enum.KeyCode.G,
    Callback = function() end
})
Tabs.Keybinds:Keybind({
    Title = "Toggle Anti Fling",
    Key = Enum.KeyCode.H,
    Callback = function() end
})
Tabs.Keybinds:Keybind({
    Title = "Toggle Speed",
    Key = Enum.KeyCode.J,
    Callback = function() end
})

--------------------------------------------------
-- FOOTER
--------------------------------------------------
Tabs.Config:Paragraph({
    Title = "Created with ❤️ by ihsanamiruddinn",
    Desc = "github.com/ihsanamiruddinn",
    Image = "github"
})


-- Injected from Example_modified.lua
    Appearance = Tabs.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
    Config = Tabs.Utilities:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" })
}

TabHandles.Elements:Paragraph({
    Title = "Interactive Components",
    Desc = "Explore WindUI's powerful elements",
    Image = "component",
    ImageSize = 20,
    Color = Color3.fromHex("#30ff6a"),
})

TabHandles.Elements:Divider()

local ElementsSection = TabHandles.Elements:Section({
    Title = "Section Example",
    Icon = "bird",
})

local toggleState = false
local featureToggle = ElementsSection:Toggle({
    Title = "Enable Features",
    --Desc = "Unlocks additional functionality",
    Value = false,
    Callback = function(state) 
        toggleState = state
        WindUI:Notify({
            Title = "Features",
            Content = state and "Features Enabled" or "Features Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local intensitySlider = ElementsSection:Slider({
    Title = "Effect Intensity",
    Desc = "Adjust the effect strength",
    Value = { Min = 0, Max = 100, Default = 50 },
    Callback = function(value)
        print("Intensity set to:", value)
    end
})

local modeDropdown = ElementsSection:Dropdown({
    Title = "Select Mode",
    Values = { "Standard", "Advanced", "Expert" },
    Value = "Standard",
    Callback = function(option)
        WindUI:Notify({
            Title = "Mode Changed",
            Content = "Selected: "..option,
            Duration = 2
        })
    end
})

ElementsSection:Divider()

ElementsSection:Button({
    Title = "Show Notification",
    Icon = "bell",
    Callback = function()
        WindUI:Notify({
            Title = "Hello WindUI!",
            Content = "This is a sample notification",
            Icon = "bell",
            Duration = 3
        })
    end
})

ElementsSection:Colorpicker({
    Title = "Select Color",
    --Desc = "Select coloe",
    Default = Color3.fromHex("#30ff6a"),
    Transparency = 0, -- enable transparency
    Callback = function(color, transparency)
        WindUI:Notify({
            Title = "Color Changed",
            Content = "New color: "..color:ToHex().."\nTransparency: "..transparency,
            Duration = 2
        })
    end
})

ElementsSection:Code({
    Title = "my_code.luau",
    Code = [[print("Hello world!")]],
    OnCopy = function()
        print("Copied to clipboard!")
    end
})

TabHandles.Appearance:Paragraph({
    Title = "Customize Interface",
    Desc = "Personalize your experience",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

local themes = {}
for themeName, _ in pairs(WindUI:GetThemes()) do
    table.insert(themes, themeName)
end
table.sort(themes)

local canchangetheme = true
local canchangedropdown = true



local themeDropdown = TabHandles.Appearance:Dropdown({
    Title = "loc:THEME_SELECT",
    Values = themes,
    Value = "Dark",
    Callback = function(theme)
        canchangedropdown = false
        WindUI:SetTheme(theme)
        WindUI:Notify({
            Title = "Theme Applied",
            Content = theme,
            Icon = "palette",
            Duration = 2
        })
        canchangedropdown = true
    end
})

local transparencySlider = TabHandles.Appearance:Slider({
    Title = "loc:TRANSPARENCY",
    Value = { 
        Min = 0,
        Max = 1,
        Default = 0.2,
    },
    Step = 0.1,
    Callback = function(value)
        WindUI.TransparencyValue = tonumber(value)
        Window:ToggleTransparency(tonumber(value) > 0)
    end
})

local ThemeToggle = TabHandles.Appearance:Toggle({
    Title = "Enable Dark Mode",
    Desc = "Use dark color scheme",
    Value = true,
    Callback = function(state)
        if canchangetheme then
            WindUI:SetTheme(state and "Dark" or "Light")
        end
        if canchangedropdown then
            themeDropdown:Select(state and "Dark" or "Light")
        end
    end
})

WindUI:OnThemeChange(function(theme)
    canchangetheme = false
    ThemeToggle:Set(theme == "Dark")
    canchangetheme = true
end)


TabHandles.Appearance:Button({
    Title = "Create New Theme",
    Icon = "plus",
    Callback = function()
        Window:Dialog({
            Title = "Create Theme",
            Content = "This feature is coming soon!",
            Buttons = {
                {
                    Title = "OK",
                    Variant = "Primary"
                }
            }
        })
    end
})

TabHandles.Config:Paragraph({
    Title = "Configuration Manager",
    Desc = "Save and load your settings",
    Image = "save",
    ImageSize = 20,
    Color = "White"
})

local configName = "default"
local configFile = nil
local MyPlayerData = {
    name = "Player1",
    level = 1,
    inventory = { "sword", "shield", "potion" }
}

TabHandles.Config:Input({
    Title = "Config Name",
    Value = configName,
    Callback = function(value)
        configName = value or "default"
    end
})

local ConfigManager = Window.ConfigManager
if ConfigManager then
    ConfigManager:Init(Window)
    
    TabHandles.Config:Button({
        Title = "loc:SAVE_CONFIG",
        Icon = "save",
        Variant = "Primary",
        Callback = function()
            configFile = ConfigManager:CreateConfig(configName)
            
            configFile:Register("featureToggle", featureToggle)
            configFile:Register("intensitySlider", intensitySlider)
            configFile:Register("modeDropdown", modeDropdown)
            configFile:Register("themeDropdown", themeDropdown)
            configFile:Register("transparencySlider", transparencySlider)
            
            configFile:Set("playerData", MyPlayerData)
            configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
            
            if configFile:Save() then
                WindUI:Notify({ 
                    Title = "loc:SAVE_CONFIG", 
                    Content = "Saved as: "..configName,
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Failed to save config",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })

    TabHandles.Config:Button({
        Title = "loc:LOAD_CONFIG",
        Icon = "folder",
        Callback = function()
            configFile = ConfigManager:CreateConfig(configName)
            local loadedData = configFile:Load()
            
            if loadedData then
                if loadedData.playerData then
                    MyPlayerData = loadedData.playerData
                end
                
                local lastSave = loadedData.lastSave or "Unknown"
                WindUI:Notify({ 
                    Title = "loc:LOAD_CONFIG", 
                    Content = "Loaded: "..configName.."\nLast save: "..lastSave,
                    Icon = "refresh-cw",
                    Duration = 5
                })
                
                TabHandles.Config:Paragraph({
                    Title = "Player Data",
                    Desc = string.format("Name: %s\nLevel: %d\nInventory: %s", 
                        MyPlayerData.name, 
                        MyPlayerData.level, 
                        table.concat(MyPlayerData.inventory, ", "))
                })
            else
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Failed to load config",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
else
    TabHandles.Config:Paragraph({
        Title = "Config Manager Not Available",
        Desc = "This feature requires ConfigManager",
        Image = "alert-triangle",
        ImageSize = 20,
        Color = "White"
    })
end


local footerSection = Window:Section({ Title = "WindUI " .. WindUI.Version })
TabHandles.Config:Paragraph({
    Title = "Created with ❤️",
    Desc = "github.com/Footagesus/WindUI",
    Image = "github",
    ImageSize = 20,
    Color = "Grey",
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "copy",
            Variant = "Tertiary",
            Callback = function()
                setclipboard("https://github.com/Footagesus/WindUI")
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "GitHub link copied to clipboard",
                    Duration = 2
                })
            end
        }
    }
})

Window:OnClose(function()
    print("Window closed")
    
    if ConfigManager and configFile then
        configFile:Set("playerData", MyPlayerData)
        configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
        configFile:Save()
        print("Config auto-saved on close")
    end
end)

Window:OnDestroy(function()
    print("Window destroyed")
end)