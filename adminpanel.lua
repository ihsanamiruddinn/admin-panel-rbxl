local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()
end)

if not ok or not WindUI then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "AdminPanel",
            Text = "Failed to load WindUI. Check HTTP and link.",
            Duration = 5
        })
    end)
    return
end

WindUI.TransparencyValue = 0.18
task.spawn(function() WindUI:SetTheme("Dark") end)

local Window = WindUI:CreateWindow({
    Title = "TripleS",
    Image = "https://raw.githubusercontent.com/ihsanamiruddinn/admin-panel-rbxl/main/logo.png",
    Author = "github.com/ihsanamiruddinn",
    Folder = "TripleS_Admin_UI",
    Size = UDim2.fromOffset(360, 300),
    Theme = "Dark",
    Acrylic = true,
    SideBarWidth = 160,
})

pcall(function() if Window.Mount then Window:Mount() end end)

Window:Tag({ Title = "Admin v2.0", Color = Color3.fromHex("#30ff6a") })
local TimeTag = Window:Tag({
    Title = "--:--",
    Radius = 0,
    Color = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0 },
    }, { Rotation = 45 })
})
task.spawn(function()
    while task.wait(1) do
        local now = os.date("*t")
        pcall(function() TimeTag:SetTitle(string.format("%02d:%02d", now.hour, now.min)) end)
    end
end)

local suppressThemeToggle = false

Window:CreateTopbarButton("theme-switcher", "moon", function()
    task.spawn(function()
        local current = WindUI:GetCurrentTheme()
        local target = current == "Dark" and "Light" or "Dark"
        pcall(function()
            suppressThemeToggle = true
            WindUI:SetTheme(target)
            suppressThemeToggle = false
        end)
        WindUI:Notify({ Title = "Theme Changed", Content = "Current theme: "..WindUI:GetCurrentTheme(), Duration = 2 })
    end)
end, 990)

local AdminTab = Window:Tab({ Title = "Admin", Image = "https://raw.githubusercontent.com/ihsanamiruddinn/admin-panel-rbxl/main/logo.png", Desc = "Admin tools" })
local ExecTab = Window:Tab({ Title = "Executor", Icon = "terminal", Desc = "Type commands and press Enter" })
local EmoteTab = Window:Tab({ Title = "Emotes", Icon = "music", Desc = "Play emotes" })
local AppearanceTab = Window:Tab({ Title = "Appearance", Icon = "brush" })
local ConfigTab = Window:Tab({ Title = "Configuration", Icon = "settings" })
local PluginsTab = Window:Tab({ Title = "Plugins", Icon = "package" })
local KeybindTab = Window:Tab({ Title = "Keybinds", Icon = "keyboard" })

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
}

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function GetHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function GetHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function Notify(t) WindUI:Notify(t) end

local flyToggle = AdminTab:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(v)
        state.fly = v
        Notify({ Title = "Fly", Content = v and "Enabled (placeholder)" or "Disabled", Duration = 2 })
    end
})

local flingToggle = AdminTab:Toggle({
    Title = "Fling",
    Value = false,
    Callback = function(v)
        state.fling = v
        Notify({ Title = "Fling", Content = v and "Enabled (placeholder)" or "Disabled", Duration = 2 })
    end
})

local noclipToggle = AdminTab:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(v)
        state.noclip = v
        Notify({ Title = "Noclip", Content = v and "Enabled (placeholder)" or "Disabled", Duration = 2 })
    end
})

local antiFlingToggle = AdminTab:Toggle({
    Title = "Anti-Fling",
    Value = false,
    Callback = function(v)
        state.antiFling = v
        if v then
            task.spawn(function()
                while state.antiFling do
                    local hrp = GetHRP()
                    if hrp and hrp.Velocity.Magnitude > 200 then
                        hrp.Velocity = Vector3.new(0,0,0)
                    end
                    task.wait(0.1)
                end
            end)
        end
        Notify({ Title = "Anti-Fling", Content = v and "Enabled" or "Disabled", Duration = 2 })
    end
})

local speedToggle = AdminTab:Toggle({
    Title = "Enable Speed (25)",
    Value = false,
    Callback = function(v)
        state.speedEnabled = v
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = v and state.speedValue or 16
        end
        Notify({ Title = "Speed", Content = v and ("Enabled: "..state.speedValue) or "Disabled", Duration = 2 })
    end
})

AdminTab:Button({
    Title = "Increase Speed",
    Callback = function()
        state.speedValue = state.speedValue + 5
        local hum = GetHumanoid()
        if hum and state.speedEnabled then hum.WalkSpeed = state.speedValue end
        Notify({ Title = "Speed", Content = "Speed set to "..state.speedValue, Duration = 2 })
    end
})

AdminTab:Button({
    Title = "Decrease Speed",
    Callback = function()
        state.speedValue = math.max(0, state.speedValue - 5)
        local hum = GetHumanoid()
        if hum and state.speedEnabled then hum.WalkSpeed = state.speedValue end
        Notify({ Title = "Speed", Content = "Speed set to "..state.speedValue, Duration = 2 })
    end
})

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

local currentSpectate = nil
AdminTab:Input({
    Title = "Spectate Player",
    Placeholder = "Player name, press Enter",
    Callback = function(name)
        if not name or name == "" then return end
        local target = findPlayerByName(name)
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                currentSpectate = target
                Notify({ Title = "Spectate", Content = "Now spectating "..target.Name, Duration = 2 })
            end
        else
            Notify({ Title = "Spectate", Content = "Player not found", Duration = 2 })
        end
    end
})

AdminTab:Button({
    Title = "Stop Spectate",
    Callback = function()
        local hum = GetHumanoid()
        if hum then
            workspace.CurrentCamera.CameraSubject = hum
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            currentSpectate = nil
            Notify({ Title = "Spectate", Content = "Stopped spectating", Duration = 2 })
        end
    end
})

AdminTab:Input({
    Title = "HeadSit Player",
    Placeholder = "Player name, press Enter",
    Callback = function(name)
        if not name or name == "" then return end
        local target = findPlayerByName(name)
        if target then
            Notify({ Title = "HeadSit", Content = "HeadSit requested for "..target.Name.." (placeholder)", Duration = 2 })
        else
            Notify({ Title = "HeadSit", Content = "Player not found", Duration = 2 })
        end
    end
})

AdminTab:Button({
    Title = "Stop HeadSit",
    Callback = function()
        Notify({ Title = "HeadSit", Content = "Stop HeadSit (placeholder)", Duration = 2 })
    end
})

AdminTab:Input({
    Title = "Teleport to Player (tp)",
    Placeholder = "Player name, press Enter",
    Callback = function(name)
        if not name or name == "" then return end
        local target = findPlayerByName(name)
        if target and target.Character then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local hrp = GetHRP()
            if targetHRP and hrp then
                hrp.CFrame = targetHRP.CFrame + Vector3.new(0,2,0)
                Notify({ Title = "Teleport", Content = "Teleported to "..target.Name, Duration = 2 })
            else
                Notify({ Title = "Teleport", Content = "HRP not found", Duration = 2 })
            end
        else
            Notify({ Title = "Teleport", Content = "Player not found", Duration = 2 })
        end
    end
})

AdminTab:Input({
    Title = "Bring Player (goto)",
    Placeholder = "Player name, press Enter",
    Callback = function(name)
        if not name or name == "" then return end
        local target = findPlayerByName(name)
        local hrp = GetHRP()
        if target and target.Character and hrp then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                pcall(function() target.Character:MoveTo(hrp.Position + Vector3.new(0,2,0)) end)
                Notify({ Title = "Goto", Content = "Requested bring for "..target.Name, Duration = 2 })
            else
                Notify({ Title = "Goto", Content = "Target HRP not found", Duration = 2 })
            end
        else
            Notify({ Title = "Goto", Content = "Player not found or HRP missing", Duration = 2 })
        end
    end
})

AdminTab:Input({
    Title = "Goto Part (workspace name)",
    Placeholder = "Part name, press Enter",
    Callback = function(name)
        if not name or name == "" then return end
        local found = nil
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower() == name:lower() then found = obj break end
        end
        local hrp = GetHRP()
        if found and hrp then
            hrp.CFrame = found.CFrame + Vector3.new(0,3,0)
            Notify({ Title = "GotoPart", Content = "Moved to "..found.Name, Duration = 2 })
        else
            Notify({ Title = "GotoPart", Content = "Part not found or HRP missing", Duration = 2 })
        end
    end
})

AdminTab:Input({
    Title = "Freeze Player",
    Placeholder = "Player name, press Enter",
    Callback = function(name)
        if not name or name == "" then return end
        local target = findPlayerByName(name)
        if target and target.Character then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = true end
            end
            Notify({ Title = "Freeze", Content = "Anchored "..target.Name.." (client-side)", Duration = 3 })
        else
            Notify({ Title = "Freeze", Content = "Player not found", Duration = 2 })
        end
    end
})

AdminTab:Button({
    Title = "Unfreeze All (client-side)",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                for _, part in pairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
        end
        Notify({ Title = "Freeze", Content = "Unfreeze attempted (client-side)", Duration = 2 })
    end
})

local lastCommand = ""

ExecTab:Input({
    Title = "Command Bar",
    Placeholder = "Type command and press Enter (no eval by default)",
    Callback = function(txt)
        if not txt or txt == "" then return end
        lastCommand = txt
        local lower = txt:lower()
        if lower == ";rejoin" or lower == "rejoin" then
            pcall(function() Notify({ Title = "Rejoin", Content = "Attempting to rejoin...", Duration = 2 }) TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
            return
        end
        if lower:sub(1,4) == ";tp " then
            local name = txt:sub(5)
            local target = findPlayerByName(name)
            local hrp = GetHRP()
            if target and target.Character and hrp then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then hrp.CFrame = targetHRP.CFrame + Vector3.new(0,2,0) Notify({ Title = "Cmd", Content = "Teleported to "..target.Name, Duration = 2 }) end
            end
            return
        end
        Notify({ Title = "Executor", Content = "Executed (placeholder): "..txt, Duration = 3 })
        print("[Executor] "..txt)
    end
})

ExecTab:Button({
    Title = "Rejoin",
    Icon = "corner-down-right",
    Callback = function() pcall(function() Notify({ Title = "Rejoin", Content = "Teleporting...", Duration = 2 }) TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end
})

ExecTab:Toggle({
    Title = "Auto Rejoin (on kick/disconnect)",
    Value = false,
    Callback = function(v)
        state.autoRejoin = v
        Notify({ Title = "AutoRejoin", Content = v and "Enabled" or "Disabled", Duration = 2 })
        if v then
            if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end
            state.autoRejoinConn = Players.PlayerRemoving:Connect(function(p)
                if p == LocalPlayer then
                    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
                end
            end)
        else
            if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end
        end
    end
})

local emotes = {
    { Name = "Dance 1" },
    { Name = "Dance 2" },
    { Name = "Dance Crazy" },
    { Name = "Float Dance" },
    { Name = "Freeze Fly" },
}
for _, e in ipairs(emotes) do
    EmoteTab:Button({ Title = e.Name, Icon = "music", Callback = function() Notify({ Title = "Emote", Content = e.Name.." (placeholder)", Duration = 2 }) end })
end
EmoteTab:Button({ Title = "Stop Emote", Icon = "stop-circle", Callback = function() Notify({ Title = "Emote", Content = "Stopped (placeholder)", Duration = 2 }) end })

AppearanceTab:Paragraph({ Title = "Customize Interface", Desc = "Theme & Transparency", Image = "palette", ImageSize = 20 })
local themes = {}
for name, _ in pairs(WindUI:GetThemes()) do table.insert(themes, name) end
table.sort(themes)
local themeDropdown = AppearanceTab:Dropdown({
    Title = "Select Theme",
    Values = themes,
    Value = WindUI:GetCurrentTheme(),
    Callback = function(theme)
        task.spawn(function()
            suppressThemeToggle = true
            pcall(function() WindUI:SetTheme(theme) end)
            suppressThemeToggle = false
            Notify({ Title = "Theme", Content = theme, Duration = 2 })
        end)
    end
})

local transparencySlider = AppearanceTab:Slider({
    Title = "Window Transparency",
    Value = { Min = 0, Max = 1, Default = WindUI.TransparencyValue or 0.18 },
    Step = 0.01,
    Callback = function(value)
        WindUI.TransparencyValue = tonumber(value)
        if Window.UpdateTransparency then
            pcall(function() Window:UpdateTransparency() end)
        else
            pcall(function() Window:ToggleTransparency(tonumber(value) > 0) end)
        end
    end
})

WindUI:OnThemeChange(function(newTheme)
    if suppressThemeToggle then return end
end)

ConfigTab:Paragraph({ Title = "Configuration Manager", Desc = "Save and load your settings", Image = "save", ImageSize = 20 })
local ConfigManager = Window.ConfigManager
local configName = "default"
local configFile = nil

if ConfigManager then
    ConfigManager:Init(Window)

    ConfigTab:Input({ Title = "Config Name", Value = configName, Callback = function(v) configName = v or "default" end })
    ConfigTab:Button({ Title = "Save Configuration", Icon = "save", Variant = "Primary", Callback = function()
        configFile = ConfigManager:CreateConfig(configName)
        pcall(function()
            configFile:Register("themeDropdown", themeDropdown)
            configFile:Register("transparencySlider", transparencySlider)
            configFile:Register("speedToggle", speedToggle)
            configFile:Register("flyToggle", flyToggle)
            configFile:Register("noclipToggle", noclipToggle)
            configFile:Register("flingToggle", flingToggle)
        end)
        configFile:Set("speedValue", state.speedValue)
        configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
        if configFile:Save() then Notify({ Title = "Config", Content = "Saved: "..configName, Duration = 3 }) end
    end })
    ConfigTab:Button({ Title = "Load Configuration", Icon = "folder", Callback = function()
        configFile = ConfigManager:CreateConfig(configName)
        local loaded = configFile:Load()
        if loaded then
            state.speedValue = loaded.speedValue or state.speedValue
            Notify({ Title = "Config", Content = "Loaded: "..configName, Duration = 3 })
        else
            Notify({ Title = "Config", Content = "Failed to load: "..configName, Duration = 3 })
        end
    end })
else
    ConfigTab:Paragraph({ Title = "Config Manager Not Available", Desc = "This feature requires ConfigManager", Image = "alert-triangle", ImageSize = 20 })
end

PluginsTab:Paragraph({ Title = "Plugin Loader", Desc = "Load plugin code from a URL or paste raw Lua", Image = "plug", ImageSize = 18 })
local pluginInput = ""
PluginsTab:Input({ Title = "Plugin URL or Code", Placeholder = "https://... or raw code", Callback = function(v) pluginInput = v end })
PluginsTab:Button({ Title = "Add Plugin", Icon = "download", Callback = function()
    if not pluginInput or pluginInput == "" then Notify({ Title = "Plugin", Content = "No input", Duration = 2 }) return end
    local code = pluginInput
    if tostring(pluginInput):match("^https?://") then
        local ok, res = pcall(function() return game:HttpGet(pluginInput) end)
        if ok and res then code = res else Notify({ Title = "Plugin", Content = "Failed to fetch URL", Duration = 2 }) return end
    end
    local ok, fn = pcall(function() return loadstring(code) end)
    if not ok or not fn then Notify({ Title = "Plugin", Content = "Invalid code", Duration = 2 }) return end
    local name = "Plugin#" .. tostring(#state.plugins + 1)
    local thread = coroutine.create(function() pcall(fn) end)
    table.insert(state.plugins, { name = name, code = code, thread = thread })
    local suc, err = pcall(function() coroutine.resume(thread) end)
    if not suc then Notify({ Title = "Plugin", Content = "Plugin error: "..tostring(err), Duration = 3 }) end
    Notify({ Title = "Plugin", Content = "Loaded "..name, Duration = 2 })
end })
PluginsTab:Button({ Title = "List Plugins (refresh)", Icon = "refresh-cw", Callback = function()
    for i,pl in ipairs(state.plugins) do
        PluginsTab:Paragraph({ Title = pl.name, Desc = "Loaded plugin", Image = "plug", ImageSize = 14 })
        PluginsTab:Button({ Title = "Unload "..pl.name, Icon = "trash", Callback = (function(idx) return function()
            table.remove(state.plugins, idx)
            Notify({ Title = "Plugin", Content = "Unloaded plugin", Duration = 2 })
        end end)(i) })
    end
end })

KeybindTab:Paragraph({ Title = "Keybinds", Desc = "Add keybinds to toggle admin features", Image = "keyboard", ImageSize = 18 })
local keyNameInput = ""
KeybindTab:Input({ Title = "Key (e.g. K)", Placeholder = "Key letter or name", Callback = function(v) keyNameInput = v end })
local actionNameInput = ""
KeybindTab:Input({ Title = "Action (Fly/Noclip/Fling/AntiFling/Speed)", Placeholder = "Action name", Callback = function(v) actionNameInput = v end })
KeybindTab:Button({ Title = "Add Keybind", Icon = "plus", Callback = function()
    if keyNameInput == "" or not keyNameInput then Notify({ Title = "Keybind", Content = "Key required", Duration = 2 }) return end
    if actionNameInput == "" or not actionNameInput then Notify({ Title = "Keybind", Content = "Action required", Duration = 2 }) return end
    local kc = nil
    local up = string.upper(keyNameInput)
    kc = Enum.KeyCode[up] or Enum.KeyCode[keyNameInput] or Enum.KeyCode[string.upper(keyNameInput)]
    if not kc then Notify({ Title = "Keybind", Content = "Unknown key", Duration = 2 }) return end
    local action = string.lower(actionNameInput)
    local function callback()
        if action == "fly" then flyToggle:Set(not flyToggle:Get()) end
        if action == "noclip" then noclipToggle:Set(not noclipToggle:Get()) end
        if action == "fling" then flingToggle:Set(not flingToggle:Get()) end
        if action == "antifling" or action == "anti-fling" then antiFlingToggle:Set(not antiFlingToggle:Get()) end
        if action == "speed" then speedToggle:Set(not speedToggle:Get()) end
    end
    table.insert(state.keybinds, { name = actionNameInput, key = kc, callback = callback, enabled = true })
    Notify({ Title = "Keybind", Content = "Added "..actionNameInput.." on "..tostring(kc), Duration = 2 })
end })

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for _,kb in ipairs(state.keybinds) do
        if kb.enabled and input.KeyCode == kb.key then
            pcall(function() kb.callback() end)
        end
    end
end)

Window:OnClose(function()
    if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end
    Notify({ Title = "AdminPanel", Content = "Closed", Duration = 2 })
end)

Window:OnDestroy(function()
    if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end
end)

pcall(function()
    if Window.UpdateTransparency then Window:UpdateTransparency()
    else Window:ToggleTransparency(WindUI.TransparencyValue > 0) end
end)
