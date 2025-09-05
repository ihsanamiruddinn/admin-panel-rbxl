
-- TripleS Admin UI - Full (generated)
-- Author: ihsanamiruddinn (footer credit)
-- Features included (UI + partial safe behaviors):
--  - UI structure: Features (Admin, Executor, Emotes), Settings (Appearance), Utilities (Configuration + Plugins + Keybind)
--  - Executor: press Enter in input to "execute" (prints & not actually evaluating by default). Includes Rejoin button and Auto-Rejoin toggle.
--  - Admin: toggles and inputs (Enter to run). Spectate includes Stop Spectate button. Anti-Fling toggle implemented naive.
--  - Emotes: placeholder buttons. Appearance & Config fully integrated (uses Window.ConfigManager if available).
--  - Plugin manager: load from URL or raw code, list/unload plugins.
-- Note: Some actions (teleporting players, forcing other players actions) require server permissions and may not work in all games.
-- For safety, executor does NOT evaluate code by default. To enable actual execution, uncomment the loadstring line where noted.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Load WindUI (use your fork)
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Failed to load WindUI. Check the URL or your executor's HTTP permissions.")
    return
end

-- Basic localization / theme
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
            ["EMOTES"] = "Emotes",
            ["EXECUTOR"] = "Executor"
        }
    }
})

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

-- Create window
local Window = WindUI:CreateWindow({
    Title = "TripleS Admin UI",
    Icon = "geist:window",
    Author = "github.com/ihsanamiruddinn",
    Folder = "TripleS_Admin_UI",
    Size = UDim2.fromOffset(520, 360),
    Theme = "Dark",
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200,
    User = { Enabled = true, Anonymous = true }
})

-- Ensure window mounts (some WindUI versions require this)
if Window and Window.Mount then
    pcall(function() Window:Mount() end)
end

-- Time tag
Window:Tag({ Title = "Admin v1.0", Color = Color3.fromHex("#30ff6a") })
local TimeTag = Window:Tag({ Title = "--:--", Radius = 0, Color = WindUI:Gradient({ ["0"] = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 }, ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0 } }, { Rotation = 45 }) })
task.spawn(function()
    while task.wait(1) do
        local now = os.date("*t")
        pcall(function() TimeTag:SetTitle(string.format("%02d:%02d", now.hour, now.min)) end)
    end
end)

Window:CreateTopbarButton("theme-switcher", "moon", function()
    WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
    WindUI:Notify({ Title = "Theme Changed", Content = "Current theme: "..WindUI:GetCurrentTheme(), Duration = 2 })
end, 990)

-- Sections
local Features = Window:Section({ Title = "Features", Opened = true })
local Settings = Window:Section({ Title = "Settings", Opened = true })
local Utilities = Window:Section({ Title = "Utilities", Opened = true })

-- Tab handles
local AdminTab = Features:Tab({ Title = "Admin", Icon = "shield", Desc = "Admin tools & commands" })
local ExecTab = Features:Tab({ Title = "Executor", Icon = "terminal", Desc = "Type and press Enter" })
local EmoteTab = Features:Tab({ Title = "Emotes", Icon = "smile", Desc = "Emote list" })

local AppearanceTab = Settings:Tab({ Title = "Appearance", Icon = "brush" })
local ConfigTab = Utilities:Tab({ Title = "Configuration", Icon = "settings" })
local KeybindTab = Utilities:Tab({ Title = "Keybinds", Icon = "keyboard" })

-- ---------- STATE ----------
local state = {
    fly = false,
    fling = false,
    noclip = false,
    antiFling = false,
    autoRejoin = false,
    autoRejoinConnection = nil,
    autoRejoinJob = nil,
    plugins = {}, -- { name = str, code = str, env = table, thread = thread }
    keybinds = {}, -- { key = Enum.KeyCode, action = function, enabled = bool, name = str }
}
-- Helper
local function Notify(t) WindUI:Notify(t) end

-- ---------- ADMIN TAB (UI) ----------
AdminTab:Paragraph({ Title = "Admin Controls", Desc = "Toggles and inputs; press Enter in inputs to execute.", Image = "shield-check", ImageSize = 18 })

AdminTab:Divider()

-- Toggles
local flyToggle = AdminTab:Toggle({ Title = "Fly (placeholder)", Value = false, Callback = function(v) state.fly = v Notify({ Title = "Fly", Content = v and "Enabled" or "Disabled", Duration = 2 }) end })
local flingToggle = AdminTab:Toggle({ Title = "Fling (placeholder)", Value = false, Callback = function(v) state.fling = v Notify({ Title = "Fling", Content = v and "Enabled" or "Disabled", Duration = 2 }) end })
local noclipToggle = AdminTab:Toggle({ Title = "Noclip (placeholder)", Value = false, Callback = function(v) state.noclip = v Notify({ Title = "Noclip", Content = v and "Enabled" or "Disabled", Duration = 2 }) end })
local antiFlingToggle = AdminTab:Toggle({ Title = "Anti-Fling (naive)", Value = false, Callback = function(v) state.antiFling = v Notify({ Title = "Anti-Fling", Content = v and "Enabled" or "Disabled", Duration = 2 }) end })

-- Spectate input + stop button
local spectateInputValue = ""
local specInput = AdminTab:Input({ Title = "Spectate Player", Placeholder = "Player name, press Enter to spectate", Callback = function(txt) spectateInputValue = txt if txt ~= "" then -- attempt spectate pcall(function()
        local target = nil
        local q = txt:lower()
        for _,p in pairs(Players:GetPlayers()) do if p.Name:lower():find(q) or (p.DisplayName and p.DisplayName:lower():find(q)) then target = p break end end
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum then local cam = workspace.CurrentCamera cam.CameraSubject = hum cam.CameraType = Enum.CameraType.Custom Notify({ Title = "Spectate", Content = "Now spectating "..target.Name, Duration = 2 }) end
        else Notify({ Title = "Spectate", Content = "Player not found.", Duration = 2 }) end end) end end })
AdminTab:Button({ Title = "Stop Spectate", Icon = "eye-off", Callback = function() local cam = workspace.CurrentCamera cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or LocalPlayer.Character cam.CameraType = Enum.CameraType.Custom Notify({ Title = "Spectate", Content = "Stopped spectating.", Duration = 2 }) end })

-- HeadSit input (placeholder)
local headsitValue = ""
AdminTab:Input({ Title = "HeadSit Player", Placeholder = "Player name, press Enter to headsit", Callback = function(txt) headsitValue = txt if txt ~= "" then Notify({ Title = "HeadSit", Content = "HeadSit requested for: "..txt, Duration = 2 }) end end })
AdminTab:Button({ Title = "Stop HeadSit", Icon = "x", Callback = function() Notify({ Title = "HeadSit", Content = "Stop headsit (placeholder)", Duration = 2 }) end })

-- Freeze player input
local freezeValue = ""
AdminTab:Input({ Title = "Freeze Player", Placeholder = "Player name, press Enter to freeze", Callback = function(txt) freezeValue = txt if txt ~= "" then Notify({ Title = "Freeze", Content = "Freeze requested: "..txt, Duration = 2 }) end end })
AdminTab:Button({ Title = "Unfreeze All (placeholder)", Icon = "x", Callback = function() Notify({ Title = "Freeze", Content = "Unfreeze all (placeholder)", Duration = 2 }) end })

-- Teleport to player input
local tpValue = ""
AdminTab:Input({ Title = "Teleport to Player (tp)", Placeholder = "Player name, press Enter to teleport", Callback = function(txt) tpValue = txt if txt ~= "" then Notify({ Title = "Teleport", Content = "Teleport requested: "..txt, Duration = 2 }) end end })

-- Bring/Move player to you input
local bringValue = ""
AdminTab:Input({ Title = "Bring Player (goto)", Placeholder = "Player name, press Enter to request bring", Callback = function(txt) bringValue = txt if txt ~= "" then Notify({ Title = "Goto", Content = "Bring requested: "..txt, Duration = 2 }) end end })

-- Goto Part input
local partValue = ""
AdminTab:Input({ Title = "Goto Part", Placeholder = "Part name (workspace), press Enter", Callback = function(txt) partValue = txt if txt ~= "" then Notify({ Title = "GotoPart", Content = "GotoPart requested: "..txt, Duration = 2 }) end end })

AdminTab:Divider()

-- ---------- EXECUTOR TAB ----------
ExecTab:Paragraph({ Title = "Executor", Desc = "Type code/command and press Enter to run (placeholder - does not evaluate by default)", Image = "terminal" })
local execInputValue = ""
ExecTab:Input({ Title = "Code Input", Placeholder = "Type command and press Enter", Callback = function(txt) execInputValue = txt if txt ~= "" then -- "execute" (placeholder) Notify({ Title = "Executor", Content = "Executed (placeholder): "..tostring(txt), Duration = 3 }) print("[Executor] "..tostring(txt)) -- To enable real execution, uncomment the next line with caution: -- -- loadstring(txt)() end end })

-- Rejoin button + Auto-Rejoin toggle
ExecTab:Button({ Title = "Rejoin", Icon = "corner-down-right", Callback = function()
    pcall(function()
        Notify({ Title = "Rejoin", Content = "Attempting to rejoin...", Duration = 2 })
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end })

local autoRejoinToggle = ExecTab:Toggle({ Title = "Auto Rejoin (on kick/disconnect)", Value = false, Callback = function(v)
    state.autoRejoin = v
    Notify({ Title = "AutoRejoin", Content = v and "Enabled" or "Disabled", Duration = 2 })
    if v then
        -- Listen for PlayerRemoving or disconnect attempts
        if state.autoRejoinConnection then state.autoRejoinConnection:Disconnect() state.autoRejoinConnection = nil end
        state.autoRejoinConnection = Players.PlayerRemoving:Connect(function(removed)
            if removed == LocalPlayer then
                -- Attempt to teleport back to same place (may or may not work depending on context)
                pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
            end
        end)
    else
        if state.autoRejoinConnection then state.autoRejoinConnection:Disconnect() state.autoRejoinConnection = nil end
    end
end })

-- ---------- EMOTES TAB (placeholder) ----------
EmoteTab:Paragraph({ Title = "Emotes", Desc = "Placeholder emote buttons (replace animation IDs if you want)", Image = "music" })
local emoteList = { "Dance 1", "Dance 2", "Spin", "Float Up (placeholder)", "Freeze Air (placeholder)" }
for _, name in ipairs(emoteList) do
    EmoteTab:Button({ Title = name, Icon = "music", Callback = function() Notify({ Title = "Emote", Content = name.." (placeholder)", Duration = 2 }) end })
end
EmoteTab:Button({ Title = "Stop Emote", Icon = "stop-circle", Callback = function() Notify({ Title = "Emote", Content = "Stopped (placeholder)", Duration = 2 }) end })

-- ---------- APPEARANCE TAB (active) ----------
AppearanceTab:Paragraph({ Title = "Customize Interface", Desc = "Theme & Transparency", Image = "palette", ImageSize = 20 })
local themes = {}
for k,_ in pairs(WindUI:GetThemes()) do table.insert(themes, k) end
table.sort(themes)
local themeDropdown = AppearanceTab:Dropdown({ Title = "Select Theme", Values = themes, Value = WindUI:GetCurrentTheme(), Callback = function(theme) WindUI:SetTheme(theme) Notify({ Title = "Theme", Content = theme, Duration = 2 }) end })
local transparencySlider = AppearanceTab:Slider({ Title = "Window Transparency", Value = { Min = 0, Max = 1, Default = WindUI.TransparencyValue or 0.2 }, Step = 0.05, Callback = function(v) WindUI.TransparencyValue = tonumber(v) Window:ToggleTransparency(tonumber(v) > 0) end })
local themeToggle = AppearanceTab:Toggle({ Title = "Dark Mode", Value = (WindUI:GetCurrentTheme() == "Dark"), Callback = function(s) WindUI:SetTheme(s and "Dark" or "Light") end })
WindUI:OnThemeChange(function(t) themeToggle:Set(t == "Dark") end)

-- ---------- CONFIGURATION (active) ----------
ConfigTab:Paragraph({ Title = "Configuration Manager", Desc = "Save/Load settings and manage plugins", Image = "save", ImageSize = 20 })
local ConfigManager = Window.ConfigManager
local configName = "default"
local configFile = nil

if ConfigManager then
    ConfigManager:Init(Window)

    ConfigTab:Input({ Title = "Config Name", Value = configName, Callback = function(v) configName = v or "default" end })
    ConfigTab:Button({ Title = "Save Configuration", Icon = "save", Variant = "Primary", Callback = function()
        configFile = ConfigManager:CreateConfig(configName)
        configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
        configFile:Save()
        Notify({ Title = "Config", Content = "Saved: "..configName, Duration = 3 })
    end })
    ConfigTab:Button({ Title = "Load Configuration", Icon = "folder", Callback = function()
        configFile = ConfigManager:CreateConfig(configName)
        local loaded = configFile:Load()
        Notify({ Title = "Config", Content = loaded and "Loaded: "..configName or "Failed to load", Duration = 3 })
    end })

    -- Plugin manager UI (simple)
    ConfigTab:Divider()
    ConfigTab:Paragraph({ Title = "Plugins", Desc = "Load plugin from URL or paste raw code. Loaded plugins appear below.", Image = "plug", ImageSize = 16 })
    local pluginInput = ""
    ConfigTab:Input({ Title = "Plugin URL or Code", Placeholder = "https://... or raw Lua code", Callback = function(v) pluginInput = v end })
    ConfigTab:Button({ Title = "Load Plugin", Icon = "download", Callback = function()
        if not pluginInput or pluginInput == "" then Notify({ Title = "Plugin", Content = "No input provided", Duration = 2 }) return end
        -- try fetch if URL-like
        local code = pluginInput
        if tostring(pluginInput):match("^https?://") then
            local ok, res = pcall(function() return game:HttpGet(pluginInput) end)
            if ok and res then code = res else Notify({ Title = "Plugin", Content = "Failed to fetch URL", Duration = 2 }) return end
        end
        -- attempt to load
        local ok, fn = pcall(function() return loadstring(code) end)
        if not ok or not fn then Notify({ Title = "Plugin", Content = "Invalid code", Duration = 2 }) return end
        local pluginName = "Plugin#" .. tostring(#state.plugins + 1)
        local env = {}
        setfenv = setfenv or function(f,e) debug.setupvalue(f,1,e) return f end
        pcall(function() setfenv(fn, env) end)
        local ok2, threadOrErr = pcall(function() return coroutine.create(fn) end)
        if not ok2 then Notify({ Title = "Plugin", Content = "Failed to create thread", Duration = 2 }) return end
        table.insert(state.plugins, { name = pluginName, code = code, env = env, thread = threadOrErr })
        -- start plugin
        local suc, startErr = pcall(function() coroutine.resume(threadOrErr) end)
        if not suc then Notify({ Title = "Plugin", Content = "Plugin error: "..tostring(startErr), Duration = 3 }) end
        Notify({ Title = "Plugin", Content = "Loaded "..pluginName, Duration = 2 })
    end })

    -- plugin list & unload
    local function refreshPluginList()
        -- clear existing simple list by adding a new paragraph with buttons
        for i,pl in ipairs(state.plugins) do
            ConfigTab:Paragraph({ Title = pl.name, Desc = "Loaded plugin", Image = "plug", ImageSize = 14 })
            ConfigTab:Button({ Title = "Unload "..pl.name, Icon = "trash", Callback = (function(idx) return function()
                local p = state.plugins[idx]
                if p then
                    -- try to stop coroutine if alive
                    if p.thread and coroutine.status(p.thread) == "suspended" then p.thread = nil end
                    table.remove(state.plugins, idx)
                    Notify({ Title = "Plugin", Content = "Unloaded "..p.name, Duration = 2 })
                end
            end end)(i) })
        end
    end

    ConfigTab:Button({ Title = "Refresh Plugin List", Icon = "refresh-cw", Callback = function() refreshPluginList() end })
else
    ConfigTab:Paragraph({ Title = "Config Manager Not Available", Desc = "This feature requires ConfigManager", Image = "alert-triangle", ImageSize = 20 })
end

-- ---------- KEYBINDS ----------
KeybindTab:Paragraph({ Title = "Keybinds", Desc = "Create simple keybinds for actions (example: toggle UI with K).", Image = "keyboard" })
local keyInput = ""
KeybindTab:Input({ Title = "Key (name, e.g. K, F, LeftControl)", Placeholder = "Key name", Callback = function(v) keyInput = v end })
local actionInput = ""
KeybindTab:Input({ Title = "Action (name)", Placeholder = "Action name, e.g. ToggleUI", Callback = function(v) actionInput = v end })
KeybindTab:Button({ Title = "Add Keybind", Icon = "plus", Callback = function()
    if not keyInput or keyInput == "" or not actionInput or actionInput == "" then Notify({ Title = "Keybind", Content = "Key or action missing", Duration = 2 }) return end
    local keyEnum = Enum.KeyCode[keyInput] or Enum.KeyCode[string.upper(keyInput)]
    if not keyEnum then Notify({ Title = "Keybind", Content = "Unknown key", Duration = 2 }) return end
    local name = actionInput
    local kb = { key = keyEnum, action = name, enabled = true, name = name }
    table.insert(state.keybinds, kb)
    Notify({ Title = "Keybind", Content = "Added "..name.." on "..tostring(keyEnum), Duration = 2 })
end })

KeybindTab:Divider()
KeybindTab:Paragraph({ Title = "Existing Keybinds (toggle to enable/disable after adding)", Desc = "", Image = "list" })
local function refreshKeybindsUI()
    -- naive UI: just list current keybinds with toggle
    for i,kb in ipairs(state.keybinds) do
        KeybindTab:Paragraph({ Title = kb.name, Desc = "Key: "..tostring(kb.key), Image = "key", ImageSize = 14 })
        KeybindTab:Toggle({ Title = "Enabled", Value = kb.enabled, Callback = function(v) kb.enabled = v end })
    end
end
KeybindTab:Button({ Title = "Refresh Keybinds", Icon = "refresh-cw", Callback = function() refreshKeybindsUI() end })

-- Capture keybinds globally
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for _,kb in ipairs(state.keybinds) do
            if kb.enabled and input.KeyCode == kb.key then
                -- example actions: ToggleUI, Print, etc.
                if kb.action == "ToggleUI" then
                    pcall(function() Window:Toggle() end)
                else
                    Notify({ Title = "Keybind", Content = "Action: "..kb.action.." triggered", Duration = 2 })
                end
            end
        end
    end
end)

-- Anti-fling naive: if enabled, zero out large velocities on your character
local function enableAntiFling(enable)
    if not enable then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- simple loop to clamp velocities
    local conn; conn = RunService.Stepped:Connect(function()
        if not state.antiFling then if conn then conn:Disconnect() end return end
        if hrp and hrp.Velocity and hrp.Velocity.Magnitude > 200 then
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end)
end

-- Cleanup & OnClose
Window:OnClose(function()
    -- disable listeners, coroutines if any
    if state.autoRejoinConnection then state.autoRejoinConnection:Disconnect() state.autoRejoinConnection = nil end
    Notify({ Title = "Window", Content = "Closed - cleaned up", Duration = 2 })
end)

Window:OnDestroy(function()
    if state.autoRejoinConnection then state.autoRejoinConnection:Disconnect() state.autoRejoinConnection = nil end
end)

-- Mount again (if needed)
pcall(function() if Window.Mount then Window:Mount() end end)

-- End of file
