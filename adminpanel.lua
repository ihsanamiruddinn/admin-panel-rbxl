local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "TripleS",
    Author = "by saanseventeen",
    Size = UDim2.fromOffset(360, 300),
    Folder = "TripleS_Config",
    Theme = "Dark",
})

-- Tabs
local Tabs = {
    Universal = Window:Section({ Title = "Universal", Opened = true }),
    Settings  = Window:Section({ Title = "Settings", Opened = true }),
    Utilities = Window:Section({ Title = "Utilities", Opened = true }),
    Misc      = Window:Section({ Title = "Misc", Opened = true }),
}

-- Universal Tab
local Universal = Tabs.Universal:Tab({ Title = "Features", Icon = "zap" })
Universal:Button({
    Title = "Auto Farm",
    Icon = "cpu",
    Callback = function()
        WindUI:Notify({ Title = "Universal", Content = "Auto Farm aktif!" })
    end
})
Universal:Toggle({
    Title = "God Mode",
    Value = false,
    Callback = function(state)
        WindUI:Notify({ Title = "Universal", Content = "God Mode: "..tostring(state) })
    end
})
Universal:Slider({
    Title = "WalkSpeed",
    Value = {Min = 16, Max = 100, Default = 16},
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- Settings Tab
local Settings = Tabs.Settings:Tab({ Title = "Options", Icon = "settings" })
Settings:Button({
    Title = "Appearance",
    Callback = function()
        WindUI:Notify({ Title = "Settings", Content = "Appearance settings opened" })
    end
})
Settings:Keybind({
    Title = "UI Toggle",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        Window:Toggle()
    end
})

-- Utilities Tab
local Utils = Tabs.Utilities:Tab({ Title = "Tools", Icon = "wrench" })
Utils:Button({
    Title = "Configuration",
    Callback = function()
        WindUI:Notify({ Title = "Utilities", Content = "Configuration opened" })
    end
})
Utils:Button({
    Title = "Plugins",
    Callback = function()
        WindUI:Notify({ Title = "Utilities", Content = "Plugins list opened" })
    end
})

-- Misc Tab
local Misc = Tabs.Misc:Tab({ Title = "Extra", Icon = "more-horizontal" })
Misc:Button({
    Title = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})
Misc:Button({
    Title = "Server Hop",
    Callback = function()
        WindUI:Notify({ Title = "Misc", Content = "Server Hop jalan" })
    end
})
Misc:Button({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})
