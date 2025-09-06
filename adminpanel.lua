local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()
end)
if not ok or not WindUI then
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "AdminPanel", Text = "Failed to load WindUI. Check HTTP.", Duration = 5 }) end)
    return
end

WindUI.TransparencyValue = 0.18
WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "TripleS",
    Icon = "https://raw.githubusercontent.com/ihsanamiruddinn/admin-panel-rbxl/main/logo.png",
    Author = "github.com/ihsanamiruddinn",
    Folder = "TripleS_Admin_UI",
    Size = UDim2.fromOffset(360, 300),
    Theme = "Dark",
    Acrylic = true,
    SideBarWidth = 160,
})

pcall(function() if Window.Mount then Window:Mount() end end)

local _origNotify = WindUI.Notify
local notifyAllowed = false
task.spawn(function() task.wait(3) notifyAllowed = true end)
local function Notify(t) if not notifyAllowed then return end pcall(function() _origNotify(WindUI, t) end) end

Window:CreateTopbarButton("theme-switcher", "moon", function()
    local current = WindUI:GetCurrentTheme()
    local target = current == "Dark" and "Light" or "Dark"
    pcall(function() WindUI:SetTheme(target) end)
end, 990)

local Features = Window:Section({ Title = "Features", Opened = true })
local Settings = Window:Section({ Title = "Settings", Opened = true })
local Utilities = Window:Section({ Title = "Utilities", Opened = true })

local AdminTab = Features:Tab({ Title = "Admin", Icon = "shield", Desc = "Admin tools" })
local ExecTab = Features:Tab({ Title = "Executor", Icon = "terminal", Desc = "Type commands and press Enter" })
local EmoteTab = Features:Tab({ Title = "Emotes", Icon = "music", Desc = "Play emotes" })
local AppearanceTab = Settings:Tab({ Title = "Appearance", Icon = "brush" })
local ConfigTab = Utilities:Tab({ Title = "Configuration", Icon = "settings" })
local PluginsTab = Utilities:Tab({ Title = "Plugins", Icon = "package" })
local KeybindTab = Utilities:Tab({ Title = "Keybinds", Icon = "keyboard" })
local PlayerTab = Features:Tab({ Title = "Player", Icon = "users", Desc = "Player viewer & actions" })

local state = {
    fly = false,
    fling = false,
    noclip = false,
    antiFling = false,
    speedEnabled = false,
    speedValue = 25,
    autoRejoin = false,
    plugins = {},
    keybinds = {},
    listening = false,
    selectedPlayer = nil,
    targetName = "",
    notifyAllowed = notifyAllowed,
}

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function GetHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function GetHRP(plr)
    local char = plr and (plr.Character or plr.CharacterAdded:Wait()) or (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
    return char and char:FindFirstChild("HumanoidRootPart")
end

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

AdminTab:Toggle({ Title = "Fly", Value = false, Callback = function(v) state.fly = v Notify({ Title = "Fly", Content = v and "Enabled (placeholder)" or "Disabled", Duration = 2 }) end })
AdminTab:Toggle({ Title = "Fling", Value = false, Callback = function(v) state.fling = v Notify({ Title = "Fling", Content = v and "Enabled (placeholder)" or "Disabled", Duration = 2 }) end })
AdminTab:Toggle({ Title = "Noclip", Value = false, Callback = function(v) state.noclip = v Notify({ Title = "Noclip", Content = v and "Enabled (placeholder)" or "Disabled", Duration = 2 }) end })
AdminTab:Toggle({ Title = "Anti-Fling", Value = false, Callback = function(v) state.antiFling = v if v then task.spawn(function() while state.antiFling do local hrp = GetHRP(LocalPlayer) if hrp and hrp.Velocity.Magnitude > 200 then hrp.Velocity = Vector3.new(0,0,0) end task.wait(0.1) end end) end Notify({ Title = "Anti-Fling", Content = v and "Enabled" or "Disabled", Duration = 2 }) end })
AdminTab:Toggle({ Title = "Enable Speed (25)", Value = false, Callback = function(v) state.speedEnabled = v local hum = GetHumanoid() if hum then hum.WalkSpeed = v and state.speedValue or 16 end Notify({ Title = "Speed", Content = v and ("Enabled: "..state.speedValue) or "Disabled", Duration = 2 }) end })
AdminTab:Button({ Title = "Increase Speed", Callback = function() state.speedValue = state.speedValue + 5 local hum = GetHumanoid() if hum and state.speedEnabled then hum.WalkSpeed = state.speedValue end Notify({ Title = "Speed", Content = "Speed set to "..state.speedValue, Duration = 2 }) end })
AdminTab:Button({ Title = "Decrease Speed", Callback = function() state.speedValue = math.max(0, state.speedValue - 5) local hum = GetHumanoid() if hum and state.speedEnabled then hum.WalkSpeed = state.speedValue end Notify({ Title = "Speed", Content = "Speed set to "..state.speedValue, Duration = 2 }) end })

local execSection = ExecTab
local lastCommand = ""
local Commands = {}
Commands.fly = { run = function(args) state.fly = not state.fly local hum = GetHumanoid() if hum then hum.PlatformStand = false end end, desc = "Membuat player bisa terbang" }
Commands.fling = { run = function(args) local targetName = args and args[1] or "" local target = findPlayerByName(targetName) if target and target.Character then local hrp = target.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.Velocity = Vector3.new(0,200,0) end end end, desc = "Membuat player lain terpental" }
Commands.clip = { run = function(args) local hum = GetHumanoid() if hum and hum.Parent then for _,p in pairs(hum.Parent:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end, desc = "Membuat player dapat menembus objek" }
Commands.noclip = { run = function(args) state.noclip = not state.noclip end, desc = "Toggle noclip" }
Commands.antifling = { run = function(args) state.antiFling = not state.antiFling end, desc = "Toggle anti-fling" }
Commands.speed = { run = function(args) state.speedEnabled = not state.speedEnabled local hum = GetHumanoid() if hum then hum.WalkSpeed = state.speedEnabled and state.speedValue or 16 end end, desc = "Toggle speed" }

local function executeCommandLine(txt)
    if not txt or txt == "" then return end
    local parts = {}
    for w in txt:gmatch("%S+") do table.insert(parts, w) end
    local cmd = parts[1] and parts[1]:lower() or ""
    table.remove(parts,1)
    local args = parts
    if Commands[cmd] and Commands[cmd].run then
        pcall(function() Commands[cmd].run(args) end)
        Notify({ Title = "Executor", Content = "Executed: "..cmd, Duration = 2 })
    else
        Notify({ Title = "Executor", Content = "Unknown command: "..cmd, Duration = 2 })
    end
end

ExecTab:Input({ Title = "Command Bar", Placeholder = "Type command and press Enter (no prefix)", Callback = function(txt) if not txt or txt == "" then return end lastCommand = txt executeCommandLine(txt) end })
ExecTab:Button({ Title = "Rejoin", Icon = "corner-down-right", Callback = function() pcall(function() Notify({ Title = "Rejoin", Content = "Teleporting...", Duration = 2 }) TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end })
ExecTab:Toggle({ Title = "Auto Rejoin (on kick/disconnect)", Value = false, Callback = function(v) state.autoRejoin = v Notify({ Title = "AutoRejoin", Content = v and "Enabled" or "Disabled", Duration = 2 }) if v then if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end state.autoRejoinConn = Players.PlayerRemoving:Connect(function(p) if p == LocalPlayer then pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end end) else if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end end end })

local emotes = { { Name = "Dance 1" }, { Name = "Dance 2" }, { Name = "Dance Crazy" }, { Name = "Float Dance" }, { Name = "Freeze Fly" } }
for _, e in ipairs(emotes) do EmoteTab:Button({ Title = e.Name, Icon = "music", Callback = function() Notify({ Title = "Emote", Content = e.Name, Duration = 2 }) end }) end
EmoteTab:Button({ Title = "Stop Emote", Icon = "stop-circle", Callback = function() Notify({ Title = "Emote", Content = "Stopped", Duration = 2 }) end })

AppearanceTab:Paragraph({ Title = "Customize Interface", Desc = "Theme & Transparency", Image = "palette", ImageSize = 20 })
local themes = {}
for name, _ in pairs(WindUI:GetThemes()) do table.insert(themes, name) end
table.sort(themes)
local themeDropdown = AppearanceTab:Dropdown({ Title = "Select Theme", Values = themes, Value = WindUI:GetCurrentTheme(), Callback = function(theme) WindUI:SetTheme(theme) Notify({ Title = "Theme", Content = theme, Duration = 2 }) end })
local transparencySlider = AppearanceTab:Slider({ Title = "Window Transparency", Value = { Min = 0, Max = 1, Default = WindUI.TransparencyValue or 0.18 }, Step = 0.01, Callback = function(value) WindUI.TransparencyValue = tonumber(value) if Window.UpdateTransparency then pcall(function() Window:UpdateTransparency() end) else pcall(function() Window:ToggleTransparency(tonumber(value) > 0) end) end end })

local ConfigManager = Window.ConfigManager
local configName = "default"
local configFile = nil

if ConfigManager then
    ConfigManager:Init(Window)
    ConfigTab:Input({ Title = "Config Name", Value = configName, Callback = function(v) configName = v or "default" end })
    ConfigTab:Button({ Title = "Save Configuration", Icon = "save", Variant = "Primary", Callback = function() configFile = ConfigManager:CreateConfig(configName) pcall(function() configFile:Register("themeDropdown", themeDropdown) configFile:Register("transparencySlider", transparencySlider) configFile:Register("speedToggle", speedToggle) configFile:Register("flyToggle", flyToggle) configFile:Register("noclipToggle", noclipToggle) configFile:Register("flingToggle", flingToggle) end) configFile:Set("speedValue", state.speedValue) configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S")) if configFile:Save() then Notify({ Title = "Config", Content = "Saved: "..configName, Duration = 3 }) end end })
    ConfigTab:Button({ Title = "Load Configuration", Icon = "folder", Callback = function() configFile = ConfigManager:CreateConfig(configName) local loaded = configFile:Load() if loaded then state.speedValue = loaded.speedValue or state.speedValue Notify({ Title = "Config", Content = "Loaded: "..configName, Duration = 3 }) else Notify({ Title = "Config", Content = "Failed to load: "..configName, Duration = 3 }) end end })
else
    ConfigTab:Paragraph({ Title = "Config Manager Not Available", Desc = "This feature requires ConfigManager", Image = "alert-triangle", ImageSize = 20 })
end

PluginsTab:Paragraph({ Title = "Plugin Loader", Desc = "Load plugin code from a URL or paste raw Lua", Image = "plug", ImageSize = 18 })
local pluginInput = ""
PluginsTab:Input({ Title = "Plugin URL or Code", Placeholder = "https://... or raw code", Callback = function(v) pluginInput = v end })
PluginsTab:Button({ Title = "Add Plugin", Icon = "download", Callback = function() if not pluginInput or pluginInput == "" then Notify({ Title = "Plugin", Content = "No input", Duration = 2 }) return end local code = pluginInput if tostring(pluginInput):match("^https?://") then local ok, res = pcall(function() return game:HttpGet(pluginInput) end) if ok and res then code = res else Notify({ Title = "Plugin", Content = "Failed to fetch URL", Duration = 2 }) return end end local ok, fn = pcall(function() return loadstring(code) end) if not ok or not fn then Notify({ Title = "Plugin", Content = "Invalid code", Duration = 2 }) return end local name = "Plugin#" .. tostring(#state.plugins + 1) local thread = coroutine.create(function() pcall(fn) end) table.insert(state.plugins, { name = name, code = code, thread = thread }) local suc, err = pcall(function() coroutine.resume(thread) end) if not suc then Notify({ Title = "Plugin", Content = "Plugin error: "..tostring(err), Duration = 3 }) end Notify({ Title = "Plugin", Content = "Loaded "..name, Duration = 2 }) end })
PluginsTab:Button({ Title = "List Plugins (refresh)", Icon = "refresh-cw", Callback = function() for i,pl in ipairs(state.plugins) do PluginsTab:Paragraph({ Title = pl.name, Desc = "Loaded plugin", Image = "plug", ImageSize = 14 }) PluginsTab:Button({ Title = "Unload "..pl.name, Icon = "trash", Callback = (function(idx) return function() table.remove(state.plugins, idx) Notify({ Title = "Plugin", Content = "Unloaded plugin", Duration = 2 }) end end)(i) }) end end })

KeybindTab:Paragraph({ Title = "Keybinds", Desc = "Add keybinds to toggle admin features", Image = "keyboard", ImageSize = 18 })
local keyNameInput = ""
KeybindTab:Input({ Title = "Key (e.g. K)", Placeholder = "Key letter or name", Callback = function(v) keyNameInput = v end })
local actionNameInput = ""
KeybindTab:Input({ Title = "Action (Fly/Noclip/Fling/AntiFling/Speed)", Placeholder = "Action name", Callback = function(v) actionNameInput = v end })
KeybindTab:Button({ Title = "Add Keybind", Icon = "plus", Callback = function() if keyNameInput == "" or not keyNameInput then Notify({ Title = "Keybind", Content = "Key required", Duration = 2 }) return end if actionNameInput == "" or not actionNameInput then Notify({ Title = "Keybind", Content = "Action required", Duration = 2 }) return end local kc = nil local up = string.upper(keyNameInput) kc = Enum.KeyCode[up] or Enum.KeyCode[keyNameInput] or Enum.KeyCode[string.upper(keyNameInput)] if not kc then Notify({ Title = "Keybind", Content = "Unknown key", Duration = 2 }) return end local action = string.lower(actionNameInput) local function callback() if action == "fly" then flyToggle:Set(not flyToggle:Get()) end if action == "noclip" then noclipToggle:Set(not noclipToggle:Get()) end if action == "fling" then flingToggle:Set(not flingToggle:Get()) end if action == "antifling" or action == "anti-fling" then antiFlingToggle:Set(not antiFlingToggle:Get()) end if action == "speed" then speedToggle:Set(not speedToggle:Get()) end end table.insert(state.keybinds, { name = actionNameInput, key = kc, callback = callback, enabled = true }) Notify({ Title = "Keybind", Content = "Added "..actionNameInput.." on "..tostring(kc), Duration = 2 }) end })

UserInputService.InputBegan:Connect(function(input, gp) if gp then return end if input.UserInputType ~= Enum.UserInputType.Keyboard then return end for _,kb in ipairs(state.keybinds) do if kb.enabled and input.KeyCode == kb.key then pcall(function() kb.callback() end) end end end)

Window:OnClose(function() if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end end)
Window:OnDestroy(function() if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end end)

pcall(function() if Window.UpdateTransparency then Window:UpdateTransparency() else Window:ToggleTransparency(WindUI.TransparencyValue > 0) end end)

pcall(function()
    local topbar = Window:GetTopbar()
    if topbar then
        local logo = Instance.new("ImageLabel")
        logo.Name = "CustomLogo"
        logo.Size = UDim2.fromOffset(18,18)
        logo.Position = UDim2.new(0,6,0.5,0)
        logo.AnchorPoint = Vector2.new(0,0.5)
        logo.BackgroundTransparency = 1
        logo.Image = "https://raw.githubusercontent.com/ihsanamiruddinn/admin-panel-rbxl/main/logo.png"
        logo.Parent = topbar

        local ver = Instance.new("TextLabel")
        ver.Name = "VersionTag"
        ver.Size = UDim2.new(0,58,0,18)
        ver.AnchorPoint = Vector2.new(1,0.5)
        ver.Position = UDim2.new(1,-52,0.5,0)
        ver.BackgroundTransparency = 1
        ver.Text = "v4.0"
        ver.Font = Enum.Font.SourceSansSemibold
        ver.TextSize = 12
        ver.TextColor3 = Color3.fromRGB(200,200,200)
        ver.Parent = topbar
    end
end)

pcall(function()
    local stroke = Window:GetMain():FindFirstChildWhichIsA("UIStroke", true)
    if stroke then
        Window.OnMinimize:Connect(function() pcall(function() stroke.Color = Color3.fromRGB(57,255,20) end) end)
        Window.OnRestore:Connect(function() pcall(function() stroke.Color = Color3.fromRGB(0,200,0) end) end)
    end
end)

do
    local topPara = PlayerTab:Paragraph({ Title = LocalPlayer.Name, Desc = "Bio: Loading...", Image = "rbxasset://textures/ui/GuiImagePlaceholder.png", ImageSize = 56 })
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size100x100
    task.spawn(function()
        local okThumb, url = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize) end)
        if okThumb and url and url ~= "" then pcall(function() topPara:SetImage(url) end) end
    end)
    task.spawn(function()
        local okDesc, desc = pcall(function() return Players:GetUserDescriptionAsync(LocalPlayer.UserId) end)
        if okDesc and desc and desc ~= "" then pcall(function() topPara:SetDesc("Bio: "..desc) end) else pcall(function() topPara:SetDesc("Bio: No bio") end) end
    end)

    local gotoInputText = ""
    local targetInputText = ""

    PlayerTab:Input({ Title = "Goto Part (type name and press Enter)", Placeholder = "Part name", Callback = function(txt)
        if not txt or txt == "" then Notify({ Title = "GotoPart", Content = "No part name", Duration = 2 }) return end
        local found = nil
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower() == txt:lower() then found = obj break end
        end
        local hrp = GetHRP(LocalPlayer)
        if found and hrp then
            pcall(function() hrp.CFrame = found.CFrame + Vector3.new(0,3,0) end)
            Notify({ Title = "GotoPart", Content = "Moved to "..found.Name, Duration = 2 })
        else
            Notify({ Title = "GotoPart", Content = "Part not found or HRP missing", Duration = 2 })
        end
    end })

    PlayerTab:Input({ Title = "Target Player (type name)", Placeholder = "Player name", Callback = function(txt)
        targetInputText = txt or ""
        if not targetInputText or targetInputText == "" then state.selectedPlayer = nil return end
        local target = findPlayerByName(targetInputText)
        state.selectedPlayer = target
    end })

    local function getTarget()
        return state.selectedPlayer
    end

    local function safeGetHRPfor(plr)
        if not plr then return nil end
        local ok, hrp = pcall(function() return plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") end)
        if ok then return hrp end
        return nil
    end
    local function safeGetHeadFor(plr)
        if not plr then return nil end
        local ok, head = pcall(function() return plr.Character and plr.Character:FindFirstChild("Head") end)
        if ok then return head end
        return nil
    end

    local function makeGridButton(title, icon, cb)
        PlayerTab:Button({ Title = title, Icon = icon, Callback = cb })
    end

    makeGridButton("View", "eye", function()
        local t = getTarget()
        if not t then Notify({ Title = "Player", Content = "No player selected", Duration = 2 }) return end
        local ok, hum = pcall(function() return t.Character and t.Character:FindFirstChildOfClass("Humanoid") end)
        if ok and hum then
            workspace.CurrentCamera.CameraSubject = hum
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            Notify({ Title = "Spectate", Content = "Now spectating "..t.Name, Duration = 2 })
        else
            Notify({ Title = "Spectate", Content = "Target has no humanoid", Duration = 2 })
        end
    end)

    makeGridButton("HeadSit", "user-check", function()
        local t = getTarget()
        if not t then Notify({ Title = "Player", Content = "No player selected", Duration = 2 }) return end
        local head = safeGetHeadFor(t)
        if head and LocalPlayer.Character then
            pcall(function() LocalPlayer.Character:MoveTo(head.Position + Vector3.new(0,2,0)) end)
            Notify({ Title = "HeadSit", Content = "Moved above "..t.Name, Duration = 2 })
        else
            Notify({ Title = "HeadSit", Content = "Cannot locate head or your character", Duration = 2 })
        end
    end)

    makeGridButton("Teleport", "navigation", function()
        local t = getTarget()
        if not t then Notify({ Title = "Player", Content = "No player selected", Duration = 2 }) return end
        local thrp = safeGetHRPfor(t)
        local hrp = safeGetHRPfor(LocalPlayer)
        if thrp and hrp then
            pcall(function() hrp.CFrame = thrp.CFrame + Vector3.new(0,2,0) end)
            Notify({ Title = "Teleport", Content = "Teleported to "..t.Name, Duration = 2 })
        else
            Notify({ Title = "Teleport", Content = "HRP missing for target or you", Duration = 2 })
        end
    end)

    makeGridButton("Bring", "corner-down-right", function()
        local t = getTarget()
        local hrp = safeGetHRPfor(LocalPlayer)
        if not t or not hrp then Notify({ Title = "Bring", Content = "Missing selection or your HRP", Duration = 2 }) return end
        if t and t.Character then
            pcall(function() t.Character:MoveTo(hrp.Position + Vector3.new(0,2,0)) end)
            Notify({ Title = "Bring", Content = "Requested bring for "..t.Name, Duration = 2 })
        end
    end)

    makeGridButton("Fling", "maximize", function()
        local t = getTarget()
        if not t then Notify({ Title = "Fling", Content = "No player selected", Duration = 2 }) return end
        local thrp = safeGetHRPfor(t)
        if thrp then
            pcall(function() thrp.Velocity = Vector3.new(0,500,0) end)
            Notify({ Title = "Fling", Content = "Flinged "..t.Name, Duration = 2 })
        else
            Notify({ Title = "Fling", Content = "Target HRP not found", Duration = 2 })
        end
    end)

    makeGridButton("Freeze", "slash", function()
        local t = getTarget()
        if not t then Notify({ Title = "Freeze", Content = "No player selected", Duration = 2 }) return end
        if t and t.Character then
            pcall(function()
                for _, part in ipairs(t.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.Anchored = true end
                end
            end)
            Notify({ Title = "Freeze", Content = "Anchored "..t.Name, Duration = 2 })
        end
    end)
end

pcall(function() if Window.UpdateTransparency then Window:UpdateTransparency() else Window:ToggleTransparency(WindUI.TransparencyValue > 0) end end)
