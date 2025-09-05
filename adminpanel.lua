local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["ADMIN_PANEL"] = "Admin Panel",
            ["WELCOME"] = "Welcome, Admin!",
            ["COMMANDS"] = "Admin Controls",
            ["SETTINGS"] = "Settings",
            ["APPEARANCE"] = "Appearance",
            ["CONFIGURATION"] = "Configuration",
        }
    }
})

WindUI:SetTheme("Dark")
WindUI.TransparencyValue = 0.15

-- Window utama
local Window = WindUI:CreateWindow({
    Title = "loc:ADMIN_PANEL",
    Icon = "shield",
    Author = "loc:WELCOME",
    Folder = "Admin_UI",
    Size = UDim2.fromOffset(420, 320),
    Theme = "Dark",
    Acrylic = true
})

-- Bagian Tab
local Tabs = {
    Admin = Window:Section({ Title = "loc:COMMANDS", Opened = true }),
    Settings = Window:Section({ Title = "loc:SETTINGS" })
}

-- ====================
-- ADMIN TAB
-- ====================
local AdminTab = Tabs.Admin:Tab({ Title = "Admin Tools", Icon = "settings" })

-- Fly
AdminTab:Button({
    Title = "Fly",
    Icon = "feather",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        WindUI:Notify({ Title = "Admin", Content = "Fly mode enabled", Duration = 2 })
    end
})

-- Noclip
AdminTab:Button({
    Title = "Noclip",
    Icon = "x",
    Callback = function()
        local plr = game.Players.LocalPlayer
        for _, part in pairs(plr.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        WindUI:Notify({ Title = "Admin", Content = "Noclip enabled", Duration = 2 })
    end
})

-- Teleport to player
AdminTab:Input({
    Title = "Teleport To Player",
    Placeholder = "Enter Player Name",
    Callback = function(name)
        local plr = game.Players:FindFirstChild(name)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character:MoveTo(plr.Character.HumanoidRootPart.Position)
            WindUI:Notify({ Title = "Admin", Content = "Teleported to "..name, Duration = 2 })
        else
            WindUI:Notify({ Title = "Error", Content = "Player not found", Duration = 2 })
        end
    end
})

-- Give Sword
AdminTab:Button({
    Title = "Give Sword",
    Icon = "sword",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local tool = Instance.new("Tool")
        tool.Name = "Admin Sword"
        tool.RequiresHandle = false
        tool.Parent = plr.Backpack
        WindUI:Notify({ Title = "Admin", Content = "Sword given", Duration = 2 })
    end
})

-- Command Bar (digabung di Admin Tab)
AdminTab:Input({
    Title = "Command Bar",
    Placeholder = ";fly / ;noclip / ;tp Player",
    Callback = function(cmd)
        cmd = string.lower(cmd)

        if cmd == ";fly" then
            local plr = game.Players.LocalPlayer
            plr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Physics)
            WindUI:Notify({ Title = "Command", Content = "Fly activated", Duration = 2 })

        elseif cmd == ";noclip" then
            local plr = game.Players.LocalPlayer
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            WindUI:Notify({ Title = "Command", Content = "Noclip activated", Duration = 2 })

        elseif string.sub(cmd,1,4) == ";tp " then
            local targetName = string.sub(cmd,5)
            local target = game.Players:FindFirstChild(targetName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                game.Players.LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position)
                WindUI:Notify({ Title = "Command", Content = "Teleported to "..targetName, Duration = 2 })
            else
                WindUI:Notify({ Title = "Error", Content = "Player not found", Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Unknown command", Duration = 2 })
        end
    end
})

-- ====================
-- SETTINGS TAB
-- ====================
local SettingsTab = Tabs.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "palette" })
SettingsTab:ThemePicker({
    Title = "Theme",
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})
SettingsTab:Slider({
    Title = "Transparency",
    Min = 0,
    Max = 1,
    Value = WindUI.TransparencyValue,
    Callback = function(value)
        WindUI.TransparencyValue = value
    end
})

-- Config tab
local ConfigTab = Tabs.Settings:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" })
ConfigTab:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        WindUI:SaveConfig()
        WindUI:Notify({ Title = "Config", Content = "Configuration saved!", Duration = 2 })
    end
})
ConfigTab:Button({
    Title = "Load Config",
    Icon = "upload",
    Callback = function()
        WindUI:LoadConfig()
        WindUI:Notify({ Title = "Config", Content = "Configuration loaded!", Duration = 2 })
    end
})

-- ====================
-- FOOTER CUSTOM
-- ====================
ConfigTab:Paragraph({
    Title = "Created with ❤️ by ihsanamiruddinn",
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