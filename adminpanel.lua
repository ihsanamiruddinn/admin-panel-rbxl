local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["WINDUI_EXAMPLE"] = "TripleS", -- (2) Branding full
            ["WELCOME"] = "by saanseventeen | github.com/ihsanamiruddinn", -- (3) Welcome
            ["LIB_DESC"] = "Beautiful UI library for Roblox",
            ["SETTINGS"] = "Settings",
            ["APPEARANCE"] = "Appearance",
            ["KEYBIND"] = "Keybind", -- (5) tambahan
            ["FEATURES"] = "Universal", -- (4) Features
            ["UTILITIES"] = "Utilities",
            ["UI_ELEMENTS"] = "UI Elements",
            ["CONFIGURATION"] = "Configuration",
            ["PLUGINS"] = "Plugins", -- (6) tambahan
            ["SAVE_CONFIG"] = "Save Configuration",
            ["LOAD_CONFIG"] = "Load Configuration",
            ["THEME_SELECT"] = "Select Theme",
            ["TRANSPARENCY"] = "Window Transparency"
        }
    }
})

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "loc:WINDUI_EXAMPLE",
    Icon = "geist:window",
    Author = "loc:WELCOME",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(360, 300), -- (1) ukuran window
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            WindUI:Notify({ Title = "User Profile", Content = "User profile clicked!", Duration = 3 })
        end
    },
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200,
})

-- Bagian Tab
local Tabs = {
    Main = Window:Section({ Title = "loc:FEATURES", Opened = true }),
    Settings = Window:Section({ Title = "loc:SETTINGS", Opened = true }),
    Utilities = Window:Section({ Title = "loc:UTILITIES", Opened = true })
}

local TabHandles = {
    Elements = Tabs.Main:Tab({ Title = "loc:UI_ELEMENTS", Icon = "layout-grid", Desc = "UI Elements Example" }),
    Appearance = Tabs.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
    Keybind = Tabs.Settings:Tab({ Title = "loc:KEYBIND", Icon = "keyboard" }), -- (5) tambahan
    Config = Tabs.Utilities:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" }),
    Plugins = Tabs.Utilities:Tab({ Title = "loc:PLUGINS", Icon = "package" }) -- (6) tambahan
}

-- Tambahan UI di Keybind
TabHandles.Keybind:Paragraph({
    Title = "Keybind Settings",
    Desc = "Set custom shortcuts for actions",
    Image = "keyboard",
    ImageSize = 20,
    Color = "White"
})
TabHandles.Keybind:Input({ Title = "Main Hotkey", Value = "F", Callback = function(val) print("Hotkey set to:", val) end })
TabHandles.Keybind:Toggle({ Title = "Enable Hotkeys", Value = true, Callback = function(state) print("Hotkeys:", state and "Enabled" or "Disabled") end })

-- Tambahan UI di Plugins
TabHandles.Plugins:Paragraph({
    Title = "Plugin Manager",
    Desc = "Enable or disable plugins",
    Image = "package",
    ImageSize = 20,
    Color = "White"
})
TabHandles.Plugins:Button({ Title = "Install Plugin", Icon = "download", Callback = function() WindUI:Notify({ Title = "Plugins", Content = "Plugin installed!", Duration = 2 }) end })
TabHandles.Plugins:Toggle({ Title = "Enable Plugin A", Value = false, Callback = function(state) print("Plugin A:", state and "On" or "Off") end })

-- Tambahan UI di Elements biar panjang kaya WindUI asli
local ElementsSection = TabHandles.Elements:Section({ Title = "Extended Elements", Icon = "grid" })
ElementsSection:Toggle({ Title = "Extra Toggle", Value = false, Callback = function(state) print("Extra Toggle:", state) end })
ElementsSection:Slider({ Title = "Extra Slider", Value = { Min = 0, Max = 10, Default = 5 }, Callback = function(v) print("Extra Slider:", v) end })
ElementsSection:Dropdown({ Title = "Extra Dropdown", Values = { "One", "Two", "Three" }, Value = "One", Callback = function(val) print("Extra Dropdown:", val) end })
ElementsSection:Button({ Title = "Extra Button", Icon = "plus", Callback = function() WindUI:Notify({ Title = "Extra", Content = "Button clicked", Duration = 2 }) end })

-- Footer (7)
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
