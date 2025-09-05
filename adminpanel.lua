-- Admin UI (WindUI) - Final Script
-- Author: ihsanamiruddinn (footer credit)
-- Features:
--  - Smooth Fly (toggle)
--  - Fling (toggle)
--  - Noclip (toggle)
--  - Spectate / Headsit / TP / Goto / GotoPart (inputs)
--  - Command bar (integrated in Admin tab)
--  - Emote Tab + emote list (play / stop)
--  - Appearance & Configuration kept intact
--  - Footer changed to github.com/ihsanamiruddinn

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- load WindUI (uses your fork link)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()

-- Localization (keep as original but trimmed)
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
            ["EMOTES"] = "Emotes"
        }
    }
})

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

-- helper: safe get char/humanoid/root
local function GetCharacter(plr)
    if not plr then return nil end
    return plr.Character or plr.CharacterAdded:Wait()
end

local function GetHRP(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(char)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- Simple gradient helper (copied from original)
local function gradient(text, startColor, endColor)
    local result = ""
    if #text == 0 then return result end
    for i = 1, #text do
        local t = (#text == 1) and 0 or ((i - 1) / (#text - 1))
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

WindUI:Popup({
    Title = gradient("Admin Panel", Color3.fromHex("#6A11CB"), Color3.fromHex("#2575FC")),
    Icon = "sparkles",
    Content = "loc:LIB_DESC",
    Buttons = {
        {
            Title = "Get Started",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function() end
        }
    }
})

-- Create main window (keeps appearance/config)
local Window = WindUI:CreateWindow({
    Title = "loc:ADMIN_PANEL",
    Icon = "shield",
    Author = "loc:WELCOME",
    Folder = "Admin_UI",
    Size = UDim2.fromOffset(520, 380),
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            WindUI:Notify({
                Title = "User Profile",
                Content = "User profile clicked!",
                Duration = 3
            })
        end
    },
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200,
})

-- Time tag and small UI niceties
Window:Tag({ Title = "Admin v1.0", Color = Color3.fromHex("#30ff6a") })
local TimeTag = Window:Tag({
    Title = "--:--",
    Radius = 0,
    Color = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0 },
    }, { Rotation = 45 }),
})

task.spawn(function()
    while true do
        local now = os.date("*t")
        TimeTag:SetTitle(string.format("%02d:%02d", now.hour, now.min))
        task.wait(1)
    end
end)

Window:CreateTopbarButton("theme-switcher", "moon", function()
    WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
    WindUI:Notify({
        Title = "Theme Changed",
        Content = "Current theme: "..WindUI:GetCurrentTheme(),
        Duration = 2
    })
end, 990)

-- Sections / Tabs
local Sections = {
    Main = Window:Section({ Title = "loc:FEATURES", Opened = true }),
    Settings = Window:Section({ Title = "loc:SETTINGS", Opened = true }),
    Emotes = Window:Section({ Title = "loc:EMOTES", Opened = false })
}

local TabHandles = {
    Admin = Sections.Main:Tab({ Title = "Admin", Icon = "layout-grid", Desc = "Admin Tools & Commands" }),
    Appearance = Sections.Settings:Tab({ Title = "Appearance", Icon = "brush" }),
    Config = Sections.Settings:Tab({ Title = "Configuration", Icon = "settings" }),
    EmoteTab = Sections.Emotes:Tab({ Title = "Emotes", Icon = "music", Desc = "Play Emotes" })
}

-- ==============
-- Admin Controls (Main tab)
-- ==============
TabHandles.Admin:Paragraph({
    Title = "Admin Controls",
    Desc = "Fly / Fling / Noclip (toggles). Spectate / Headsit / TP / Goto / GotoPart (inputs). Command bar available.",
    Image = "shield-check",
    ImageSize = 18,
    Color = Color3.fromHex("#ffffff")
})

TabHandles.Admin:Divider()

-- -- State holders
local flyEnabled = false
local flyData = { BV = nil, BG = nil, connection = nil, speed = 80 } -- speed adjustable
local noclipEnabled = false
local noclipConn = nil
local flingEnabled = false
local flingConnection = nil

-- Utility: ensure local character ready
local function EnsureChar()
    local char = GetCharacter(LocalPlayer)
    local hrp = GetHRP(char)
    local hum = GetHumanoid(char)
    return char, hrp, hum
end

-- =============
-- Smooth Fly (toggle)
-- =============
local function enableFly(speed)
    if flyEnabled then return end
    local char, hrp, hum = EnsureChar()
    if not hrp or not hum then return end

    flyEnabled = true
    speed = speed or flyData.speed

    -- Remove existing BV/BG if any
    if flyData.BV then flyData.BV:Destroy() end
    if flyData.BG then flyData.BG:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.P = 1250
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 3000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    flyData.BV = bv
    flyData.BG = bg

    local forward = Vector3.new()
    local up = 0

    -- keyboard control
    local UserInputService = game:GetService("UserInputService")
    local keys = {W=false,A=false,S=false,D=false,Space=false,LeftShift=false}
    local function setKey(action, pressed)
        if action == Enum.KeyCode.W then keys.W = pressed end
        if action == Enum.KeyCode.A then keys.A = pressed end
        if action == Enum.KeyCode.S then keys.S = pressed end
        if action == Enum.KeyCode.D then keys.D = pressed end
        if action == Enum.KeyCode.Space then keys.Space = pressed end
        if action == Enum.KeyCode.LeftShift then keys.LeftShift = pressed end
    end

    local inputBegan, inputEnded
    inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            setKey(input.KeyCode, true)
        end
    end)
    inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            setKey(input.KeyCode, false)
        end
    end)

    flyData.connection = RunService.RenderStepped:Connect(function(delta)
        if not flyEnabled or not hrp then return end
        -- compute movement vector
        local cam = workspace.CurrentCamera
        local look = cam.CFrame
        local move = Vector3.new()

        if keys.W then move = move + look.LookVector end
        if keys.S then move = move - look.LookVector end
        if keys.A then move = move - look.RightVector end
        if keys.D then move = move + look.RightVector end

        local mv = Vector3.new(move.X, 0, move.Z)
        if keys.Space then up = up + 1 else if keys.LeftShift then up = up - 1 else up = 0 end end

        local final = (mv.unit ~= mv.unit) and Vector3.new(0, up * 5, 0) or (mv.unit * speed)
        final = Vector3.new(final.X, up * speed * 0.5, final.Z)

        -- smooth velocity
        local currentVel = flyData.BV.Velocity
        flyData.BV.Velocity = currentVel:Lerp(final, math.clamp(delta * 8, 0, 1))

        -- keep orientation stable
        flyData.BG.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
    end)

    -- cleanup on disable (will be handled elsewhere)
end

local function disableFly()
    flyEnabled = false
    if flyData.connection then flyData.connection:Disconnect() flyData.connection = nil end
    if flyData.BV then flyData.BV:Destroy() flyData.BV = nil end
    if flyData.BG then flyData.BG:Destroy() flyData.BG = nil end
end

-- Fly Toggle UI
local flyToggle = TabHandles.Admin:Toggle({
    Title = "Smooth Fly",
    Value = false,
    Callback = function(state)
        if state then
            enableFly()
        else
            disableFly()
        end
    end
})

-- =============
-- Noclip (toggle)
-- =============
local function setNoclip(enabled)
    noclipEnabled = enabled
    local char = GetCharacter(LocalPlayer)
    if not char then return end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not enabled and true or false
        end
    end

    if enabled then
        -- attempt to keep CanCollide false while enabled
        if noclipConn and noclipConn.Connected then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local ch = GetCharacter(LocalPlayer)
            if ch then
                for _, p in pairs(ch:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end

local noclipToggle = TabHandles.Admin:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(state)
        setNoclip(state)
    end
})

-- =============
-- Fling (toggle)
-- =============
-- Simple fling: apply strong velocity to target when touching them
local flingTarget = nil
local flingForceValue = 1000

local function enableFling()
    if flingEnabled then return end
    flingEnabled = true

    local char, hrp = EnsureChar()
    if not hrp then return end

    flingConnection = hrp.Touched:Connect(function(other)
        if not flingEnabled then return end
        local otherParent = other and other.Parent
        local otherHum = otherParent and otherParent:FindFirstChildOfClass("Humanoid")
        if otherHum and otherParent ~= char then
            local otherHrp = otherParent:FindFirstChild("HumanoidRootPart")
            if otherHrp then
                -- apply a one-time bodyvelocity to other
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                bv.P = 20000
                bv.Velocity = (otherHrp.Position - hrp.Position).unit * flingForceValue + Vector3.new(0, 50, 0)
                bv.Parent = otherHrp
                game:GetService("Debris"):AddItem(bv, 0.35)
            end
        end
    end)
end

local function disableFling()
    flingEnabled = false
    if flingConnection then flingConnection:Disconnect() flingConnection = nil end
end

local flingToggle = TabHandles.Admin:Toggle({
    Title = "Fling",
    Value = false,
    Callback = function(state)
        if state then enableFling() else disableFling() end
    end
})

-- =============
-- Spectate, Headsit, TP/Goto/GotoPart inputs
-- =============
-- Helper: find player by partial name (case-insensitive)
local function findPlayerByName(part)
    if not part or part == "" then return nil end
    part = part:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(part) or (p.DisplayName and p.DisplayName:lower():find(part)) then
            return p
        end
    end
    return nil
end

-- Spectate input
TabHandles.Admin:Input({
    Title = "Spectate (player name)",
    Placeholder = "Player name",
    Callback = function(name)
        local target = findPlayerByName(name)
        if not target or not target.Character then
            WindUI:Notify({ Title = "Spectate", Content = "Player not found.", Duration = 2 })
            return
        end
        local cam = workspace.CurrentCamera
        local targetHum = GetHumanoid(target.Character)
        if targetHum then
            cam.CameraSubject = targetHum
            cam.CameraType = Enum.CameraType.Custom
            WindUI:Notify({ Title = "Spectate", Content = "Now spectating "..target.Name, Duration = 2 })
        else
            WindUI:Notify({ Title = "Spectate", Content = "Unable to spectate.", Duration = 2 })
        end
    end
})

-- Un-spectate button (restore)
TabHandles.Admin:Button({
    Title = "Stop Spectate",
    Icon = "eye-off",
    Callback = function()
        local cam = workspace.CurrentCamera
        cam.CameraSubject = GetHumanoid(GetCharacter(LocalPlayer)) or LocalPlayer.Character
        cam.CameraType = Enum.CameraType.Custom
        WindUI:Notify({ Title = "Spectate", Content = "Stopped spectating.", Duration = 2 })
    end
})

-- Headsit: weld player to target's head
local headsitWeld = nil
local function doHeadsit(targetPlayer)
    local localChar, localHrp, localHum = EnsureChar()
    if not localChar or not localHrp then
        WindUI:Notify({ Title = "Headsit", Content = "Your character not ready.", Duration = 2 })
        return
    end
    if not targetPlayer or not targetPlayer.Character then
        WindUI:Notify({ Title = "Headsit", Content = "Target not found.", Duration = 2 })
        return
    end
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head then
        WindUI:Notify({ Title = "Headsit", Content = "Target head not found.", Duration = 2 })
        return
    end

    -- cleanup previous weld
    if headsitWeld and headsitWeld.Parent then
        headsitWeld:Destroy()
        headsitWeld = nil
    end

    -- create weld between our HumanoidRootPart and target head (position slightly above)
    local ourHrp = localHrp
    -- move us above the head and weld
    ourHrp.CFrame = head.CFrame * CFrame.new(0, 1.6, 0)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ourHrp
    weld.Part1 = head
    weld.Parent = ourHrp
    headsitWeld = weld

    WindUI:Notify({ Title = "Headsit", Content = "Headsit attached to "..targetPlayer.Name, Duration = 3 })
end

TabHandles.Admin:Input({
    Title = "Headsit (player name)",
    Placeholder = "Player name",
    Callback = function(name)
        local target = findPlayerByName(name)
        if target then
            doHeadsit(target)
        else
            WindUI:Notify({ Title = "Headsit", Content = "Player not found.", Duration = 2 })
        end
    end
})

TabHandles.Admin:Button({
    Title = "Stop Headsit",
    Icon = "x",
    Callback = function()
        if headsitWeld and headsitWeld.Parent then
            headsitWeld:Destroy()
            headsitWeld = nil
            WindUI:Notify({ Title = "Headsit", Content = "Headsit stopped.", Duration = 2 })
        else
            WindUI:Notify({ Title = "Headsit", Content = "No headsit active.", Duration = 2 })
        end
    end
})

-- Teleport / TP (teleport *you* to target player)
TabHandles.Admin:Input({
    Title = "Teleport to Player (tp)",
    Placeholder = "Player name",
    Callback = function(name)
        local target = findPlayerByName(name)
        local char, hrp = EnsureChar()
        if target and target.Character and hrp then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                hrp.CFrame = targetHRP.CFrame + Vector3.new(0,2,0)
                WindUI:Notify({ Title = "Teleport", Content = "Teleported to "..target.Name, Duration = 2 })
            else
                WindUI:Notify({ Title = "Teleport", Content = "Target HRP not found.", Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Teleport", Content = "Player not found or char not ready.", Duration = 2 })
        end
    end
})

-- Goto: move target player to you (requires permissions on server; will attempt MoveTo)
TabHandles.Admin:Input({
    Title = "Bring Player to Me (goto)",
    Placeholder = "Player name",
    Callback = function(name)
        local target = findPlayerByName(name)
        local char, hrp = EnsureChar()
        if target and target.Character and hrp then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                -- attempt MoveTo (server may deny)
                target.Character:MoveTo(hrp.Position + Vector3.new(0,2,0))
                WindUI:Notify({ Title = "Goto", Content = "Requested bring for "..target.Name, Duration = 2 })
            else
                WindUI:Notify({ Title = "Goto", Content = "Target HRP not found.", Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Goto", Content = "Player not found or char not ready.", Duration = 2 })
        end
    end
})

-- GotoPart: move you to a workspace part name (exact name)
TabHandles.Admin:Input({
    Title = "Goto Part (workspace path/name)",
    Placeholder = "PartName or folder/part",
    Callback = function(path)
        if not path or path == "" then
            WindUI:Notify({ Title = "GotoPart", Content = "Please enter a part name.", Duration = 2 })
            return
        end
        -- try find by name in workspace (first match)
        local found = nil
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower() == path:lower() then
                found = obj
                break
            end
        end
        local char, hrp = EnsureChar()
        if not hrp then
            WindUI:Notify({ Title = "GotoPart", Content = "Your character not ready.", Duration = 2 })
            return
        end
        if found then
            hrp.CFrame = found.CFrame + Vector3.new(0, 3, 0)
            WindUI:Notify({ Title = "GotoPart", Content = "Moved to "..found.Name, Duration = 2 })
        else
            WindUI:Notify({ Title = "GotoPart", Content = "Part not found in workspace", Duration = 2 })
        end
    end
})

TabHandles.Admin:Divider()

-- =============
-- Command Bar (integrated)
-- =============
TabHandles.Admin:Input({
    Title = "Command Bar",
    Placeholder = ";fly / ;noclip / ;fling / ;tp Name / ;bring Name / ;headsit Name / ;spectate Name",
    Callback = function(input)
        local cmd = tostring(input or ""):gsub("%s+$","")
        if cmd == "" then return end
        local lower = cmd:lower()

        if lower == ";fly" then
            flyToggle:Set(true)
        elseif lower == ";fly off" or lower == ";flyfalse" or lower == ";flyfalse" then
            flyToggle:Set(false)
        elseif lower == ";noclip" then
            noclipToggle:Set(true)
        elseif lower == ";noclip off" or lower == ";noclipfalse" then
            noclipToggle:Set(false)
        elseif lower == ";fling" then
            flingToggle:Set(true)
        elseif lower == ";fling off" then
            flingToggle:Set(false)
        elseif lower:sub(1,4) == ";tp " then
            local name = cmd:sub(5)
            -- reuse teleport input callback behavior
            local target = findPlayerByName(name)
            local char, hrp = EnsureChar()
            if target and target.Character and hrp then
             