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
