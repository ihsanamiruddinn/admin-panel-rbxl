local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

-- 🌐 Localization
WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["WINDUI_EXAMPLE"] = "WindUI Example",
            ["WELCOME"] = "Welcome to WindUI!",
            ["LIB_DESC"] = "Beautiful UI library for Roblox",
            ["SETTINGS"] = "Settings",
            ["APPEARANCE"] = "Appearance",
            ["FEATURES"] = "Features",
            ["UTILITIES"] = "Utilities",
            ["UI_ELEMENTS"] = "UI Elements",
            ["CONFIGURATION"] = "Configuration",
            ["SAVE_CONFIG"] = "Save Configuration",
            ["LOAD_CONFIG"] = "Load Configuration",
            ["THEME_SELECT"] = "Select Theme",
            ["TRANSPARENCY"] = "Window Transparency",
            ["PLUGINS"] = "Plugins",
            ["KEYBINDS"] = "Keybinds"
        }
    }
})

-- 🌙 Theme + transparency default
WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

-- 🌟 Main Window
local Window = WindUI:CreateWindow({
    Title = "loc:WINDUI_EXAMPLE",
    Icon = "geist:window",
    Author = "loc:WELCOME",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(300, 260),
    Theme = "Dark",
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200
})

-- 🏷️ Tabs
local Tabs = {
    Features = Window:Section({ Title = "loc:FEATURES", Opened = true }),
    Settings = Window:Section({ Title = "loc:SETTINGS", Opened = true }),
    Utilities = Window:Section({ Title = "loc:UTILITIES", Opened = true })
}

-- 🔖 Sub Tabs
local TabHandles = {
    Admin = Tabs.Features:Tab({ Title = "Admin", Icon = "shield", Desc = "Admin Commands" }),
    Executor = Tabs.Features:Tab({ Title = "Executor", Icon = "terminal", Desc = "Command Bar" }),
    Emotes = Tabs.Features:Tab({ Title = "Emotes", Icon = "smile", Desc = "Fun Animations" }),
    Appearance = Tabs.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
    Config = Tabs.Utilities:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" }),
    Plugins = Tabs.Utilities:Tab({ Title = "loc:PLUGINS", Icon = "package" }),
    Keybinds = Tabs.Utilities:Tab({ Title = "loc:KEYBINDS", Icon = "keyboard" })
}

------------------------------------------------
-- 🛠️ Admin Commands (with input/toggle)
------------------------------------------------
local AdminSection = TabHandles.Admin:Section({ Title = "Player Commands", Icon = "user" })

AdminSection:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(state) print("Fly:", state) end
})

AdminSection:Toggle({
    Title = "Fling",
    Value = false,
    Callback = function(state) print("Fling:", state) end
})

AdminSection:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(state) print("Noclip:", state) end
})

AdminSection:Input({
    Title = "Spectate Player",
    Placeholder = "Enter player name",
    Callback = function(name) print("Spectate:", name) end
})

AdminSection:Button({
    Title = "Stop Spectating",
    Callback = function() print("Spectate stopped") end
})

AdminSection:Input({
    Title = "HeadSit Player",
    Placeholder = "Enter player name",
    Callback = function(name) print("HeadSit:", name) end
})

AdminSection:Input({
    Title = "Teleport To Player",
    Placeholder = "Enter player name",
    Callback = function(name) print("TP to:", name) end
})

AdminSection:Input({
    Title = "Goto Part",
    Placeholder = "Enter part name",
    Callback = function(part) print("Goto part:", part) end
})

AdminSection:Input({
    Title = "Freeze Player",
    Placeholder = "Enter player name",
    Callback = function(name) print("Freeze:", name) end
})

-- Speed Controls
local speedValue = 25
AdminSection:Toggle({
    Title = "Enable Speed (25)",
    Value = false,
    Callback = function(state) print("Speed enabled:", state, "Value:", speedValue) end
})

AdminSection:Button({
    Title = "Increase Speed",
    Callback = function()
        speedValue = speedValue + 5
        print("Speed increased to:", speedValue)
    end
})

AdminSection:Button({
    Title = "Decrease Speed",
    Callback = function()
        speedValue = math.max(0, speedValue - 5)
        print("Speed decreased to:", speedValue)
    end
})

AdminSection:Toggle({
    Title = "Anti-Fling",
    Value = false,
    Callback = function(state) print("Anti-Fling:", state) end
})

------------------------------------------------
-- 💻 Executor
------------------------------------------------
local ExecutorSection = TabHandles.Executor:Section({ Title = "Command Executor", Icon = "terminal" })

ExecutorSection:Input({
    Title = "Enter Command",
    Placeholder = "Type command here and press Enter",
    ClearTextOnFocus = true,
    Callback = function(command)
        print("Executed command:", command)
    end
})

ExecutorSection:Button({
    Title = "Rejoin",
    Callback = function() print("Rejoining server...") end
})

ExecutorSection:Toggle({
    Title = "Auto Rejoin",
    Value = false,
    Callback = function(state) print("Auto Rejoin:", state) end
})

------------------------------------------------
-- 😎 Emotes
------------------------------------------------
local EmoteSection = TabHandles.Emotes:Section({ Title = "Dance Emotes", Icon = "music" })

EmoteSection:Button({ Title = "Dance 1", Callback = function() print("Dance 1") end })
EmoteSection:Button({ Title = "Dance 2", Callback = function() print("Dance 2") end })
EmoteSection:Button({ Title = "Dance Crazy", Callback = function() print("Dance Crazy") end })
EmoteSection:Button({ Title = "Float Dance", Callback = function() print("Float Dance") end })
EmoteSection:Button({ Title = "Freeze Fly", Callback = function() print("Freeze Fly") end })

------------------------------------------------
-- 🎨 Appearance
------------------------------------------------
local transparencySlider = TabHandles.Appearance:Slider({
    Title = "loc:TRANSPARENCY",
    Value = { Min = 0, Max = 1, Default = 0.2 },
    Step = 0.1,
    Callback = function(value)
        WindUI.TransparencyValue = tonumber(value)
        Window:UpdateTransparency()
    end
})

------------------------------------------------
-- ⚙️ Configuration
------------------------------------------------
local ConfigSection = TabHandles.Config:Section({ Title = "Config Manager", Icon = "settings" })
ConfigSection:Button({
    Title = "Save Configuration",
    Callback = function() print("Config Saved") end
})
ConfigSection:Button({
    Title = "Load Configuration",
    Callback = function() print("Config Loaded") end
})

------------------------------------------------
-- 📦 Plugins
------------------------------------------------
local PluginSection = TabHandles.Plugins:Section({ Title = "Manage Plugins", Icon = "package" })
PluginSection:Button({
    Title = "Add Plugin",
    Callback = function() print("Plugin Added") end
})

------------------------------------------------
-- ⌨️ Keybinds
------------------------------------------------
local KeybindSection = TabHandles.Keybinds:Section({ Title = "Manage Keybinds", Icon = "keyboard" })
KeybindSection:Button({
    Title = "Add Keybind",
    Callback = function() print("Keybind Added") end
})

------------------------------------------------
-- ❤️ Footer
------------------------------------------------
local footerSection = Window:Section({ Title = "WindUI " .. WindUI.Version })
footerSection:Paragraph({
    Title = "Created with ❤️",
    Desc = "github.com/ihsanamiruddinn",
    Image = "github",
    ImageSize = 20,
    Color = "Grey",
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "copy",
            Variant = "Tertiary",
            Callback = function()
                setclipboard("https://github.com/ihsanamiruddinn")
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "GitHub link copied to clipboard",
                    Duration = 2
                })
            end
        }
    }
})