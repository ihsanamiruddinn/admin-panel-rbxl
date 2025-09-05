local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["ADMIN_PANEL"] = "Admin Panel",
            ["WELCOME"] = "Welcome, Admin!",
            ["COMMANDS"] = "Commands",
            ["UTILITIES"] = "Utilities",
            ["COMMAND_BAR"] = "Command Bar"
        }
    }
})

WindUI:SetTheme("Dark")
WindUI.TransparencyValue = 0.15

-- Buat window utama
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
    Commands = Window:Section({ Title = "loc:COMMANDS", Opened = true }),
    Utilities = Window:Section({ Title = "loc:UTILITIES" })
}

-- Tab Commands (fitur admin)
local Cmds = Tabs.Commands:Tab({ Title = "Admin Tools", Icon = "settings" })

-- Fly
Cmds:Button({
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
Cmds:Button({
    Title = "Noclip",
    Icon = "x",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        WindUI:Notify({ Title = "Admin", Content = "Noclip enabled", Duration = 2 })
    end
})

-- Teleport
Cmds:Input({
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

-- Tab Utilities
local Utils = Tabs.Utilities:Tab({ Title = "Fun", Icon = "smile" })

Utils:Button({
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

-- ======================
-- COMMAND BAR
-- ======================
local CmdBar = Window:Section({ Title = "loc:COMMAND_BAR", Opened = true })
local CmdTab = CmdBar:Tab({ Title = "Executor", Icon = "terminal" })

CmdTab:Input({
    Title = "Enter Command",
    Placeholder = ";fly / ;noclip / ;tp Player",
    Callback = function(cmd)
        cmd = string.lower(cmd)

        if cmd == ";fly" then
            local plr = game.Players.LocalPlayer
            local char = plr.Character or plr.CharacterAdded:Wait()
            char:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Physics)
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
