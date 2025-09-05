
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

-- 🌟 Main Window
local Window = WindUI:CreateWindow({
    Title = "Admin Panel",
    Icon = "shield",
    Author = "WindUI",
    Folder = "AdminPanel_Config",
    Size = UDim2.fromOffset(300, 260),
    Theme = "Dark",
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200
})

-- 🏷️ Tabs
local Tabs = {
    Features = Window:Section({ Title = "Features", Opened = true }),
    Settings = Window:Section({ Title = "Settings", Opened = true }),
    Utilities = Window:Section({ Title = "Utilities", Opened = true })
}

-- 🔖 Sub Tabs
local TabHandles = {
    Admin = Tabs.Features:Tab({ Title = "Admin", Icon = "shield", Desc = "Admin Commands" }),
    Executor = Tabs.Features:Tab({ Title = "Executor", Icon = "terminal", Desc = "Command Bar" }),
    Emotes = Tabs.Features:Tab({ Title = "Emotes", Icon = "smile", Desc = "Fun Animations" }),
    Appearance = Tabs.Settings:Tab({ Title = "Appearance", Icon = "brush" }),
    Config = Tabs.Utilities:Tab({ Title = "Configuration", Icon = "settings" }),
    Plugins = Tabs.Utilities:Tab({ Title = "Plugins", Icon = "package" }),
    Keybinds = Tabs.Utilities:Tab({ Title = "Keybinds", Icon = "keyboard" })
}

------------------------------------------------
-- 🛠️ Admin Commands
------------------------------------------------
local AdminSection = TabHandles.Admin:Section({ Title = "Player Commands", Icon = "user" })

local speedValue = 25

AdminSection:Toggle({ Title = "Fly", Value = false, Callback = function(v) print("Fly", v) end })
AdminSection:Toggle({ Title = "Fling", Value = false, Callback = function(v) print("Fling", v) end })
AdminSection:Toggle({ Title = "Noclip", Value = false, Callback = function(v) print("Noclip", v) end })
AdminSection:Input({ Title = "Spectate Player", Placeholder = "Enter name", Callback = function(n) print("Spectate", n) end })
AdminSection:Button({ Title = "Stop Spectating", Callback = function() print("Stop spectating") end })
AdminSection:Input({ Title = "HeadSit Player", Placeholder = "Enter name", Callback = function(n) print("HeadSit", n) end })
AdminSection:Input({ Title = "Teleport To Player", Placeholder = "Enter name", Callback = function(n) print("TP to", n) end })
AdminSection:Input({ Title = "Goto Part", Placeholder = "Enter part name", Callback = function(n) print("Goto Part", n) end })
AdminSection:Input({ Title = "Freeze Player", Placeholder = "Enter name", Callback = function(n) print("Freeze", n) end })

AdminSection:Toggle({
    Title = "Enable Speed (25)",
    Value = false,
    Callback = function(state) print("Speed enabled", state, "Value", speedValue) end
})
AdminSection:Button({
    Title = "Increase Speed",
    Callback = function() speedValue = speedValue + 5; print("Speed:", speedValue) end
})
AdminSection:Button({
    Title = "Decrease Speed",
    Callback = function() speedValue = math.max(0, speedValue - 5); print("Speed:", speedValue) end
})
AdminSection:Toggle({ Title = "Anti-Fling", Value = false, Callback = function(v) print("Anti-Fling", v) end })

------------------------------------------------
-- 💻 Executor
------------------------------------------------
local ExecutorSection = TabHandles.Executor:Section({ Title = "Command Executor", Icon = "terminal" })

ExecutorSection:Input({
    Title = "Enter Command",
    Placeholder = "Type command and press Enter",
    ClearTextOnFocus = true,
    Callback = function(cmd) print("Executed:", cmd) end
})
ExecutorSection:Button({ Title = "Rejoin", Callback = function() print("Rejoin server") end })
ExecutorSection:Toggle({ Title = "Auto Rejoin", Value = false, Callback = function(v) print("Auto Rejoin", v) end })

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
local AppearanceSection = TabHandles.Appearance:Section({ Title = "Theme & Transparency", Icon = "brush" })
AppearanceSection:Dropdown({
    Title = "Select Theme",
    Values = WindUI:GetThemes(),
    Multi = false,
    Default = "Dark",
    Callback = function(theme) WindUI:SetTheme(theme) end
})
AppearanceSection:Slider({
    Title = "Transparency",
    Value = { Min = 0, Max = 1, Default = 0.2 },
    Step = 0.05,
    Callback = function(val)
        WindUI.TransparencyValue = tonumber(val)
        Window:UpdateTransparency()
    end
})

------------------------------------------------
-- ⚙️ Configuration
------------------------------------------------
local ConfigSection = TabHandles.Config:Section({ Title = "Config Manager", Icon = "settings" })
ConfigSection:Button({ Title = "Save Configuration", Callback = function() print("Config saved") end })
ConfigSection:Button({ Title = "Load Configuration", Callback = function() print("Config loaded") end })

------------------------------------------------
-- 📦 Plugins
------------------------------------------------
local PluginSection = TabHandles.Plugins:Section({ Title = "Manage Plugins", Icon = "package" })
PluginSection:Button({ Title = "Add Plugin", Callback = function() print("Plugin added") end })

------------------------------------------------
-- ⌨️ Keybinds
------------------------------------------------
local KeybindSection = TabHandles.Keybinds:Section({ Title = "Manage Keybinds", Icon = "keyboard" })
KeybindSection:Button({ Title = "Add Keybind", Callback = function() print("Keybind added") end })

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
                    Content = "GitHub link copied",
                    Duration = 2
                })
            end
        }
    }
})
