local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["WINDUI_EXAMPLE"] = "TripleS",
            ["WELCOME"] = "by saanseventeen",
            ["LIB_DESC"] = "https://github.com/ihsanamiruddinn/TripleS-UI",
            ["SETTINGS"] = "Settings",
            ["APPEARANCE"] = "Appearance",
            ["FEATURES"] = "Features",
            ["UTILITIES"] = "Utilities",
            ["UI_ELEMENTS"] = "Universal",
            ["CONFIGURATION"] = "Configuration",
            ["SAVE_CONFIG"] = "Save Configuration",
            ["LOAD_CONFIG"] = "Load Configuration",
            ["THEME_SELECT"] = "Select Theme",
            ["TRANSPARENCY"] = "Window Transparency"
        }
    }
})

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

local function gradient(text, startColor, endColor)
    local result = ""
    if #text == 0 then return "" end
    for i = 1, #text do
        local t = (#text == 1) and 0 or (i - 1) / (#text - 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

local Window = WindUI:CreateWindow({
    Title = "TripleS",
    Icon = "geist:window",
    Author = "by saanseventeen",
    Folder = "TripleS_Config",
    Size = UDim2.fromOffset(360, 300),
    Theme = "Dark",
    User = { Enabled = true, Anonymous = true }
})

Window:Tag({ Title = "v1.0", Color = Color3.fromHex("#30ff6a") })
Window:Tag({ Title = "Stable", Color = Color3.fromHex("#315dff") })

Window:CreateTopbarButton("theme-switcher", "moon", function()
    WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
    WindUI:Notify({
        Title = "Theme Changed",
        Content = "Current theme: "..WindUI:GetCurrentTheme(),
        Duration = 2
    })
end, 990)

Window:CreateTopbarButton("minimize-btn", "minus", function()
    Window:Toggle()
end, 991)

Window:CreateTopbarButton("close-btn", "x", function()
    Window:Destroy()
end, 992)

local Tabs = {
    Main = Window:Section({ Title = "loc:FEATURES", Opened = true }),
    Settings = Window:Section({ Title = "loc:SETTINGS", Opened = true }),
    Utilities = Window:Section({ Title = "loc:UTILITIES", Opened = true })
}

local TabHandles = {
    Elements = Tabs.Main:Tab({ Title = "loc:UI_ELEMENTS", Icon = "layout-grid", Desc = "Universal features" }),
    Appearance = Tabs.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
    Config = Tabs.Utilities:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" })
}

TabHandles.Elements:Paragraph({
    Title = "Interactive Components",
    Desc = "Universal tools (no action assigned unless you request)",
    Image = "component",
    ImageSize = 20,
    Color = Color3.fromHex("#30ff6a"),
})

TabHandles.Elements:Divider()

local ElementsSection = TabHandles.Elements:Section({
    Title = "Section Example",
    Icon = "bird",
})

local featureToggle = ElementsSection:Toggle({
    Title = "Enable Features",
    Value = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Universal",
            Content = "No action assigned for this toggle",
            Duration = 2
        })
    end
})

local intensitySlider = ElementsSection:Slider({
    Title = "Effect Intensity",
    Desc = "Adjust the effect strength (placeholder)",
    Value = { Min = 0, Max = 100, Default = 50 },
    Callback = function(value)
        WindUI:Notify({
            Title = "Universal",
            Content = "No action assigned for slider",
            Duration = 1
        })
    end
})

local modeDropdown = ElementsSection:Dropdown({
    Title = "Select Mode",
    Values = { "Standard", "Advanced", "Expert" },
    Value = "Standard",
    Callback = function(option)
        WindUI:Notify({
            Title = "Universal",
            Content = "Selected: "..option.." (no action)",
            Duration = 1
        })
    end
})

ElementsSection:Divider()

ElementsSection:Button({
    Title = "Show Notification",
    Icon = "bell",
    Callback = function()
        WindUI:Notify({
            Title = "Hello TripleS!",
            Content = "No operation assigned.",
            Icon = "bell",
            Duration = 3
        })
    end
})

ElementsSection:Colorpicker({
    Title = "Select Color",
    Default = Color3.fromHex("#30ff6a"),
    Transparency = 0,
    Callback = function(color, transparency)
        WindUI:Notify({
            Title = "Universal",
            Content = "Color selected (no action): "..color:ToHex(),
            Duration = 2
        })
    end
})

ElementsSection:Code({
    Title = "example_code.lua",
    Code = [[print("TripleS")]],
    OnCopy = function()
        WindUI:Notify({ Title = "Clipboard", Content = "Code copied (placeholder)", Duration = 2 })
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
    Value = WindUI:GetCurrentTheme() or "Dark",
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
    Value = { Min = 0, Max = 1, Default = WindUI.TransparencyValue or 0.2 },
    Step = 0.1,
    Callback = function(value)
        WindUI.TransparencyValue = tonumber(value)
        Window:ToggleTransparency(tonumber(value) > 0)
    end
})

local ThemeToggle = TabHandles.Appearance:Toggle({
    Title = "Enable Dark Mode",
    Desc = "Use dark color scheme",
    Value = (WindUI:GetCurrentTheme() == "Dark"),
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
                { Title = "OK", Variant = "Primary" }
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

local ConfigManager = Window.ConfigManager
if ConfigManager then
    ConfigManager:Init(Window)

    TabHandles.Config:Input({
        Title = "Config Name",
        Value = configName,
        Callback = function(value)
            configName = value or "default"
        end
    })

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

TabHandles.Config:Paragraph({
    Title = "Created with ❤️",
    Desc = "https://github.com/ihsanamiruddinn/TripleS-UI",
    Image = "github",
    ImageSize = 20,
    Color = "Grey",
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "copy",
            Variant = "Tertiary",
            Callback = function()
                setclipboard("https://github.com/ihsanamiruddinn/TripleS-UI")
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
    if ConfigManager and configFile then
        configFile:Set("playerData", MyPlayerData)
        configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
        configFile:Save()
    end
end)

Window:OnDestroy(function()
end)
