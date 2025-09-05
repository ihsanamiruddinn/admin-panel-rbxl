-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

WindUI:SetTheme("Dark")
WindUI.TransparencyValue = 0.2

-- Create Main Window
local Window = WindUI:CreateWindow({
    Title = "TripleS Admin UI",
    Icon = "geist:window",
    Author = "github.com/ihsanamiruddinn",
    Theme = "Dark",
    Size = UDim2.fromOffset(450, 340),
    Acrylic = true,
    SideBarWidth = 200
})

--------------------------------------------------
-- 📌 FEATURES SECTION
--------------------------------------------------
local Features = Window:Section({ Title = "Features", Opened = true })

-- ========== ADMIN TAB ==========
local AdminTab = Features:Tab({ Title = "Admin", Icon = "shield" })

AdminTab:Toggle({ Title = "Fly", Value = false, Callback = function(v) print("Fly:", v) end })
AdminTab:Toggle({ Title = "Fling", Value = false, Callback = function(v) print("Fling:", v) end })
AdminTab:Toggle({ Title = "Noclip", Value = false, Callback = function(v) print("Noclip:", v) end })

-- HeadSit
AdminTab:Input({ Title = "HeadSit Player", Placeholder = "Enter player name", Callback = function(txt) print("HeadSit:", txt) end })
AdminTab:Button({ Title = "Execute HeadSit", Icon = "user", Callback = function() WindUI:Notify({ Title = "HeadSit", Content = "Executed (placeholder)", Duration = 2 }) end })

-- Freeze
AdminTab:Input({ Title = "Freeze Player", Placeholder = "Enter player name", Callback = function(txt) print("Freeze:", txt) end })
AdminTab:Button({ Title = "Execute Freeze", Icon = "snowflake", Callback = function() WindUI:Notify({ Title = "Freeze", Content = "Executed (placeholder)", Duration = 2 }) end })

-- Spectate
AdminTab:Input({ Title = "Spectate Player", Placeholder = "Enter player name", Callback = function(txt) print("Spectate:", txt) end })
AdminTab:Button({ Title = "Start Spectating", Icon = "eye", Callback = function() WindUI:Notify({ Title = "Spectate", Content = "Watching player (placeholder)", Duration = 2 }) end })

-- Teleport
AdminTab:Input({ Title = "Teleport to Player", Placeholder = "Enter player name", Callback = function(txt) print("Teleport:", txt) end })
AdminTab:Button({ Title = "Teleport", Icon = "map-pin", Callback = function() WindUI:Notify({ Title = "Teleport", Content = "Executed (placeholder)", Duration = 2 }) end })

-- Goto Part
AdminTab:Input({ Title = "Goto Part", Placeholder = "Enter part name", Callback = function(txt) print("Goto Part:", txt) end })
AdminTab:Button({ Title = "Goto Part", Icon = "box", Callback = function() WindUI:Notify({ Title = "Goto Part", Content = "Executed (placeholder)", Duration = 2 }) end })

-- ========== EXECUTOR TAB ==========
local ExecTab = Features:Tab({ Title = "Executor", Icon = "terminal" })
ExecTab:Input({
    Title = "Code Input",
    Placeholder = "Enter script here, press Enter to run",
    Callback = function(txt)
        if txt ~= "" then
            WindUI:Notify({
                Title = "Executor",
                Content = "Executed: "..txt,
                Duration = 3
            })
            print("Executed code:", txt)
            -- Kalau mau beneran: loadstring(txt)()
        end
    end
})

-- ========== EMOTES TAB ==========
local EmoteTab = Features:Tab({ Title = "Emotes", Icon = "smile" })
EmoteTab:Paragraph({ Title = "Emote List", Desc = "Click to perform emote (placeholder)" })
local emotes = { "Dance 1", "Dance 2", "Crazy Spin", "Freeze Air", "Float Up" }
for _, e in ipairs(emotes) do
    EmoteTab:Button({
        Title = e,
        Icon = "music",
        Callback = function()
            WindUI:Notify({ Title = "Emote", Content = e.." played (placeholder)", Duration = 2 })
        end
    })
end

--------------------------------------------------
-- ⚙️ SETTINGS SECTION (ACTIVE)
--------------------------------------------------
local Settings = Window:Section({ Title = "Settings", Opened = true })
local AppTab = Settings:Tab({ Title = "Appearance", Icon = "brush" })

-- Theme Dropdown
local themes = {}
for k,_ in pairs(WindUI:GetThemes()) do table.insert(themes, k) end
table.sort(themes)
AppTab:Dropdown({
    Title = "Select Theme",
    Values = themes,
    Value = "Dark",
    Callback = function(theme)
        WindUI:SetTheme(theme)
        WindUI:Notify({ Title = "Theme Applied", Content = theme, Duration = 2 })
    end
})

-- Transparency
AppTab:Slider({
    Title = "Transparency",
    Value = { Min = 0, Max = 1, Default = 0.2 },
    Step = 0.1,
    Callback = function(v)
        WindUI.TransparencyValue = tonumber(v)
        Window:ToggleTransparency(tonumber(v) > 0)
    end
})

-- Dark Mode Toggle
AppTab:Toggle({
    Title = "Dark Mode",
    Value = true,
    Callback = function(state)
        WindUI:SetTheme(state and "Dark" or "Light")
    end
})

--------------------------------------------------
-- 🛠 UTILITIES SECTION (ACTIVE)
--------------------------------------------------
local Utils = Window:Section({ Title = "Utilities", Opened = true })
local ConfigTab = Utils:Tab({ Title = "Configuration", Icon = "settings" })

ConfigTab:Paragraph({
    Title = "Configuration Manager",
    Desc = "Save and load settings"
})

local ConfigManager = Window.ConfigManager
local configFile, configName = nil, "default"

if ConfigManager then
    ConfigManager:Init(Window)

    ConfigTab:Input({
        Title = "Config Name",
        Value = configName,
        Callback = function(v) configName = v end
    })

    ConfigTab:Button({
        Title = "Save Config",
        Icon = "save",
        Variant = "Primary",
        Callback = function()
            configFile = ConfigManager:CreateConfig(configName)
            configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
            configFile:Save()
            WindUI:Notify({
                Title = "Config",
                Content = "Saved as "..configName,
                Duration = 3
            })
        end
    })

    ConfigTab:Button({
        Title = "Load Config",
        Icon = "folder",
        Callback = function()
            configFile = ConfigManager:CreateConfig(configName)
            local loaded = configFile:Load()
            WindUI:Notify({
                Title = "Config",
                Content = loaded and "Loaded "..configName or "Failed to load",
                Duration = 3
            })
        end
    })
end

--------------------------------------------------
-- 🔻 FOOTER
--------------------------------------------------
local Footer = Window:Section({ Title = "Credits" })
Footer:Paragraph({
    Title = "Created with ❤️",
    Desc = "github.com/ihsanamiruddinn",
    Icon = "github"
})