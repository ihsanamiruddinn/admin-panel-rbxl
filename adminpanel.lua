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
task.spawn(function()
    pcall(function() WindUI:SetTheme("Dark") end)
end)

local Window = WindUI:CreateWindow({
    Title = "TripleS",
    Author = "github.com/ihsanamiruddinn",
    Folder = "TripleS_Admin_UI",
    Size = UDim2.fromOffset(360, 300),
    Theme = "Dark",
    Acrylic = true,
    SideBarWidth = 160,
})

if Window.Mount then
    pcall(function() Window:Mount() end)
end

local _origNotify = WindUI.Notify
local notifyAllowed = false
task.spawn(function()
    task.wait(3)
    notifyAllowed = true
end)

local function Notify(t)
    if not notifyAllowed then return end
    pcall(function() _origNotify(WindUI, t) end)
end

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
        Notify({ Title = "Theme Changed", Content = "Current theme: "..WindUI:GetCurrentTheme(), Duration = 2 })
    end)
end, 990)

local AdminTab = Window:Tab({ Title = "Admin", Icon = "shield", Desc = "Admin tools" })
local ExecTab = Window:Tab({ Title = "Executor", Icon = "terminal", Desc = "Type commands and press Enter" })
local EmoteTab = Window:Tab({ Title = "Emotes", Icon = "music", Desc = "Play emotes" })
local AppearanceTab = Window:Tab({ Title = "Appearance", Icon = "brush" })
local ConfigTab = Window:Tab({ Title = "Configuration", Icon = "settings" })
local PluginsTab = Window:Tab({ Title = "Plugins", Icon = "package" })
local KeybindTab = Window:Tab({ Title = "Keybinds", Icon = "keyboard" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "users" })

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
    selectedPlayerName = nil,
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

local Commands = {}

Commands.fly = {
    run = function(args)
        state.fly = not state.fly
        local hum = GetHumanoid()
        if hum then
            hum.PlatformStand = false
        end
    end,
    desc = "Membuat player bisa terbang"
}

Commands.fling = {
    run = function(args)
        local targetName = args and args[1] or ""
        local target = findPlayerByName(targetName)
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0,200,0)
            end
        end
    end,
    desc = "Membuat player lain terpental"
}

Commands.clip = {
    run = function(args)
        local hum = GetHumanoid()
        if hum and hum.Parent then
            for _,p in pairs(hum.Parent:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end,
    desc = "Membuat player dapat menembus objek"
}

Commands.noclip = {
    run = function(args)
        state.noclip = not state.noclip
    end,
    desc = "Toggle noclip"
}

Commands.antifling = {
    run = function(args)
        state.antiFling = not state.antiFling
    end,
    desc = "Toggle anti-fling"
}

Commands.speed = {
    run = function(args)
        state.speedEnabled = not state.speedEnabled
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = state.speedEnabled and state.speedValue or 16
        end
    end,
    desc = "Toggle speed"
}

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

local function NotifyImmediate(t)
    pcall(function() _origNotify(WindUI, t) end)
end

local flyToggle = AdminTab:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(v)
        state.fly = v
        Notify({ Title = "Fly", Content = v and "Enabled" or "Disabled", Duration = 2 })
    end
})

local flingToggle = AdminTab:Toggle({
    Title = "Fling",
    Value = false,
    Callback = function(v)
        state.fling = v
        Notify({ Title = "Fling", Content = v and "Enabled" or "Disabled", Duration = 2 })
    end
})

local noclipToggle = AdminTab:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(v)
        state.noclip = v
        Notify({ Title = "Noclip", Content = v and "Enabled" or "Disabled", Duration = 2 })
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
                Notify({ Title = "Spectate", Content = "Now spectating "..target.Name, Duration = 2 })
            end
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
            end
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
            end
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
            Notify({ Title = "Freeze", Content = "Anchored "..target.Name.." (client-side)", Duration = 2 })
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

ExecTab:Input({
    Title = "Command Bar",
    Placeholder = "Type command and press Enter (no prefix)",
    Callback = function(txt)
        if not txt or txt == "" then return end
        executeCommandLine(txt)
    end
})

ExecTab:Button({
    Title = "Rejoin",
    Icon = "corner-down-right",
    Callback = function()
        pcall(function()
            Notify({ Title = "Rejoin", Content = "Teleporting...", Duration = 2 })
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

ExecTab:Toggle({
    Title = "Auto Rejoin (on kick/disconnect)",
    Value = false,
    Callback = function(v)
        state.autoRejoin = v
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
    EmoteTab:Button({ Title = e.Name, Icon = "music", Callback = function()
        Notify({ Title = "Emote", Content = e.Name.." (placeholder)", Duration = 2 })
    end })
end

EmoteTab:Button({ Title = "Stop Emote", Icon = "stop-circle", Callback = function() Notify({ Title = "Emote", Content = "Stopped (placeholder)", Duration = 2 }) end })

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

if Window.ConfigManager then
    local ConfigManager = Window.ConfigManager
    local configName = "default"
    local configFile = nil
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
end

local pluginInput = ""

PluginsTab:Paragraph({ Title = "Plugin Loader", Desc = "Load plugin code from a URL or paste raw Lua", Image = "plug", ImageSize = 18 })
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
    refreshPluginList()
end })

PluginsTab:Button({ Title = "Refresh Plugin List", Icon = "refresh-cw", Callback = function() refreshPluginList() end })

local function refreshPluginList()
    if #state.plugins == 0 then
        PluginsTab:Paragraph({ Title = "No plugins loaded", Desc = "Add plugin code or URL", Image = "plug", ImageSize = 14 })
        return
    end
    for i,pl in ipairs(state.plugins) do
        PluginsTab:Paragraph({ Title = pl.name, Desc = "Loaded plugin", Image = "plug", ImageSize = 14 })
        PluginsTab:Button({ Title = "Unload "..pl.name, Icon = "trash", Callback = (function(idx) return function() table.remove(state.plugins, idx) Notify({ Title = "Plugin", Content = "Unloaded plugin", Duration = 2 }) refreshPluginList() end end)(i) })
    end
end

local keyNameDisplay = Instance.new("StringValue")
local actionNameInput = ""
KeybindTab:Input({ Title = "Action (Fly/Noclip/Fling/AntiFling/Speed)", Placeholder = "Action name", Callback = function(v) actionNameInput = v end })
KeybindTab:Button({ Title = "Listen For Key (click then press)", Icon = "keyboard", Callback = function() state.listening = true Notify({ Title = "Keybind", Content = "Press any key to bind...", Duration = 2 }) end })
KeybindTab:Button({ Title = "Add Keybind", Icon = "plus", Callback = function()
    if not keyNameDisplay.Value or keyNameDisplay.Value == "" then Notify({ Title = "Keybind", Content = "No key selected", Duration = 2 }) return end
    if actionNameInput == "" or not actionNameInput then Notify({ Title = "Keybind", Content = "Action required", Duration = 2 }) return end
    local kc = Enum.KeyCode[keyNameDisplay.Value] or Enum.KeyCode[string.upper(keyNameDisplay.Value)]
    if not kc then Notify({ Title = "Keybind", Content = "Unknown key", Duration = 2 }) return end
    local action = string.lower(actionNameInput)
    local function callback()
        if action == "fly" then flyToggle:Set(not flyToggle:Get()) end
        if action == "noclip" then noclipToggle:Set(not noclipToggle:Get()) end
        if action == "fling" then flingToggle:Set(not flingToggle:Get()) end
        if action == "antifling" or action == "anti-fling" then antiFlingToggle:Set(not antiFlingToggle:Get()) end
        if action == "speed" then speedToggle:Set(not speedToggle:Get()) end
    end
    table.insert(state.keybinds, { name = actionNameInput, key = kc, keyName = keyNameDisplay.Value, callback = callback, enabled = true })
    Notify({ Title = "Keybind", Content = "Added "..actionNameInput.." on "..tostring(kc), Duration = 2 })
end })

local function refreshKeybindList()
    if #state.keybinds == 0 then
        KeybindTab:Paragraph({ Title = "No keybinds", Desc = "Add some using the controls above", Image = "info", ImageSize = 14 })
        return
    end
    for i,kb in ipairs(state.keybinds) do
        KeybindTab:Paragraph({ Title = (kb.keyName or tostring(kb.key)).." → "..kb.name, Desc = "Enabled: "..tostring(kb.enabled), Image = "keyboard", ImageSize = 12 })
        KeybindTab:Button({ Title = "Remove "..kb.name, Icon = "trash", Callback = (function(idx) return function() table.remove(state.keybinds, idx) Notify({ Title = "Keybind", Content = "Removed", Duration = 2 }) end end)(i) })
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if state.listening and input.UserInputType == Enum.UserInputType.Keyboard then
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.","")
        keyNameDisplay.Value = keyName
        state.listening = false
        Notify({ Title = "Keybind", Content = "Key selected: "..keyName, Duration = 2 })
        return
    end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for _,kb in ipairs(state.keybinds) do
        if kb.enabled and input.KeyCode == kb.key then
            pcall(function() kb.callback() end)
        end
    end
end)

ExecTab:Paragraph({ Title = "Commands", Desc = "Available commands (dynamic)", Image = "list", ImageSize = 14 })

local function refreshCommandList()
    local merged = ""
    for name,info in pairs(Commands) do
        merged = merged .. name .. " - " .. (type(info) == "table" and (info.desc or "") or info) .. "\n"
    end
    ExecTab:Paragraph({ Title = "Command List", Desc = merged })
end
refreshCommandList()

PluginsTab:Button({ Title = "Refresh Plugin List", Icon = "refresh-cw", Callback = function() refreshPluginList() end })

Window:OnClose(function() end)

Window:OnDestroy(function()
    if state.autoRejoinConn then state.autoRejoinConn:Disconnect() state.autoRejoinConn = nil end
end)

pcall(function()
    if Window.UpdateTransparency then Window:UpdateTransparency()
    else Window:ToggleTransparency(WindUI.TransparencyValue > 0) end
end)

pcall(function()
    local topbar = Window:GetTopbar()
    if topbar then
        local logo = Instance.new("ImageLabel")
        logo.Name = "CustomLogo"
        logo.Size = UDim2.fromOffset(20,20)
        logo.Position = UDim2.new(0,8,0.5,0)
        logo.AnchorPoint = Vector2.new(0,0.5)
        logo.BackgroundTransparency = 1
        logo.Image = "https://raw.githubusercontent.com/ihsanamiruddinn/admin-panel-rbxl/main/logo.png"
        logo.Parent = topbar

        local ver = Instance.new("TextLabel")
        ver.Name = "VersionTag"
        ver.Size = UDim2.new(0,60,0,20)
        ver.AnchorPoint = Vector2.new(1,0.5)
        ver.Position = UDim2.new(1,-56,0.5,0)
        ver.BackgroundTransparency = 1
        ver.Text = "v4.0"
        ver.Font = Enum.Font.SourceSansSemibold
        ver.TextSize = 14
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
