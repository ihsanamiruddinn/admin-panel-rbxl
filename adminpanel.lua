-- TripleS GUI (standalone final, Fly normal + safer Fling, full script)
-- Paste sekali: GUI + semua fungsi sudah ada di sini

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local lp  = Players.LocalPlayer

-- ===== helpers karakter =====
local function getChar()
    local c = lp.Character or lp.CharacterAdded:Wait()
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

local function safeTeleport(cf)
    local c, hrp, hum = getChar()
    if not hrp then return end
    local model = c
    if model and model.PrimaryPart == nil then
        model.PrimaryPart = hrp
    end
    if model and model.PrimaryPart then
        model:PivotTo(cf)
    else
        hrp.CFrame = cf
    end
    if hum then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

-- ===== state umum =====
local flying = false
local flyBV, flyBG, flyConn
local ascend, descend = 0, 0
local flySpeed = 50

local flingActive = false
local flingConn = nil
local flingCooldown = 0.7 -- cooldown per target (s)
local lastFlingAt = {}    -- map player -> time

local checkpointCF = nil
local respawnConn = nil

-- ===== INPUT (ascend / descend) =====
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Space then
            ascend = 1
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            descend = 1
        end
    end
end)

UIS.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Space then
            ascend = 0
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            descend = 0
        end
    end
end)

-- ===== FLY (normal, not noclip) =====
local function startFly()
    if flying then return end
    local c, hrp, hum = getChar()
    if not hrp or not hum then return end
    flying = true

    -- clear velocities
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)

    -- BodyVelocity (pushes but still collides)
    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "TripleS_FlyBV"
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.P = 1250
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "TripleS_FlyBG"
    flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    flyBG.P = 1e4
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp

    if flyConn then flyConn:Disconnect() flyConn = nil end
    flyConn = RS.RenderStepped:Connect(function()
        if not flying then return end
        local c2, hrp2, hum2 = getChar()
        if not hrp2 or not hum2 then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        -- MoveDirection supports analog + WASD
        local move = hum2.MoveDirection or Vector3.new(0,0,0)
        local y = (ascend - descend)
        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
        local forward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
        local dir = Vector3.new(0,0,0)
        if move.Magnitude > 0 then
            -- compose camera-relative direction
            local composed = (right.Unit * move.X) + (forward.Unit * move.Z)
            if composed.Magnitude > 0 then dir = composed.Unit end
        end

        -- apply velocity (preserve collisions)
        local targetVel = dir * flySpeed + Vector3.new(0, y * flySpeed, 0)
        -- if no input but ascend/descend exists, allow vertical only
        if dir.Magnitude == 0 and y ~= 0 then
            flyBV.Velocity = Vector3.new(0, y * flySpeed, 0)
        else
            flyBV.Velocity = targetVel
        end

        -- orient to camera
        flyBG.CFrame = CFrame.new(hrp2.Position, hrp2.Position + cam.CFrame.LookVector)
    end)
end

local function stopFly()
    if not flying then return end
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV and flyBV.Parent then flyBV:Destroy(); flyBV = nil end
    if flyBG and flyBG.Parent then flyBG:Destroy(); flyBG = nil end
end

-- ===== FLING (safer approach) =====
-- This implementation tries to mimic "IY-like" fling by applying velocity to nearby players,
-- instead of aggressively manipulating our own physics (reduces self-fling).
local function startFling()
    if flingActive then return end
    local c, hrp = getChar()
    if not hrp then return end
    flingActive = true
    lastFlingAt = {}

    if flingConn then flingConn:Disconnect() flingConn = nil end
    flingConn = RS.Heartbeat:Connect(function()
        if not flingActive then return end
        local _, hrpNow = getChar()
        if not hrpNow then return end
        local pos = hrpNow.Position

        -- iterate players and apply a single strong impulse if they're close and off cooldown
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= lp and pl.Character and pl.Character.Parent then
                local theirHRP = pl.Character:FindFirstChild("HumanoidRootPart")
                if theirHRP then
                    local dist = (theirHRP.Position - pos).Magnitude
                    if dist <= 10 then
                        local t = tick()
                        local last = lastFlingAt[pl] or 0
                        if t - last >= flingCooldown then
                            -- direction away from you
                            local dir = (theirHRP.Position - pos)
                            if dir.Magnitude > 0 then
                                dir = dir.Unit
                            else
                                dir = Vector3.new(0,1,0)
                            end
                            -- apply a strong velocity to target (up + away)
                            pcall(function()
                                theirHRP.AssemblyLinearVelocity = dir * 140 + Vector3.new(0, 120, 0)
                            end)
                            lastFlingAt[pl] = t
                        end
                    end
                end
            end
        end
    end)
end

local function stopFling()
    if not flingActive then return end
    flingActive = false
    if flingConn then flingConn:Disconnect() flingConn = nil end
    lastFlingAt = {}
end

-- ===== SPAWN / CHECKPOINT =====
local function setCheckpoint()
    local _, hrp = getChar()
    if not hrp then return end
    checkpointCF = hrp.CFrame
    if respawnConn then respawnConn:Disconnect() respawnConn = nil end
    respawnConn = lp.CharacterAdded:Connect(function(char)
        local hrp2 = char:WaitForChild("HumanoidRootPart", 10)
        local hum2 = char:WaitForChild("Humanoid", 10)
        if checkpointCF and hrp2 then
            task.wait(0.25)
            pcall(function()
                if hum2 then hum2:ChangeState(Enum.HumanoidStateType.Physics) end
            end)
            char:PivotTo(checkpointCF)
            task.wait(0.05)
            pcall(function()
                if hum2 then hum2:ChangeState(Enum.HumanoidStateType.GettingUp) end
            end)
        end
    end)
end

local function clearCheckpoint()
    checkpointCF = nil
    if respawnConn then respawnConn:Disconnect() respawnConn = nil end
end

-- ===== SPEED =====
local function setSpeed(v)
    local _, _, hum = getChar()
    if hum then
        hum.WalkSpeed = v
    end
end

-- ===== TP TOOL =====
local function ensureTpTool()
    local backpack = lp:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild("TpTool") or (lp.Character and lp.Character:FindFirstChild("TpTool")) then return end
    local tool = Instance.new("Tool")
    tool.Name = "TpTool"
    tool.RequiresHandle = false
    local mouse = lp:GetMouse()
    tool.Activated:Connect(function()
        if mouse and mouse.Hit then
            local pos = mouse.Hit.Position
            safeTeleport(CFrame.new(pos + Vector3.new(0,3,0)))
        end
    end)
    tool.Parent = backpack
end

-- ===== TGoto =====
local function gotoPlayer(partialName)
    if not partialName or partialName == "" then return end
    partialName = partialName:lower()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= lp and pl.Name:lower():find(partialName, 1, true) then
            if pl.Character and pl.Character.Parent then
                local theirHRP = pl.Character:FindFirstChild("HumanoidRootPart")
                if theirHRP then
                    safeTeleport(theirHRP.CFrame + Vector3.new(0,3,0))
                    return
                end
            end
        end
    end
end

-- ===== GotoPart =====
local function gotoPartByName(partName)
    if not partName or partName == "" then return end
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name:lower() == partName:lower() then
            safeTeleport(desc.CFrame + Vector3.new(0,3,0))
            return
        end
    end
end

-- ===== Command Router =====
local function runCommand(cmd)
    if not cmd or cmd == "" then return end
    local args = {}
    for token in string.gmatch(cmd, "%S+") do table.insert(args, token) end
    local h = (args[1] or ""):lower()

    if h == "fly" then startFly()
    elseif h == "unfly" then stopFly()
    elseif h == "fling" then startFling()
    elseif h == "unfling" then stopFling()
    elseif h == "spawn" then setCheckpoint()
    elseif h == "nospawn" then clearCheckpoint()
    elseif h == "speed" then
        local v = tonumber(args[2] or "")
        if v then setSpeed(v) end
    elseif h == "tptool" then ensureTpTool()
    elseif h == "tgoto" then gotoPlayer(args[2] and table.concat(args, " ", 2) or "")
    elseif h == "gotopart" then gotoPartByName(args[2] and table.concat(args, " ", 2) or "")
    end
end

-- ========== GUI ========== (keutuhan layout dipertahankan)
-- auto parent
local parentGui
if type(gethui) == "function" then
    pcall(function() parentGui = gethui() end)
end
if not parentGui and syn and syn.protect_gui then
    local s = Instance.new("ScreenGui")
    syn.protect_gui(s)
    s.Parent = game:GetService("CoreGui")
    parentGui = s
end
if not parentGui then parentGui = lp:WaitForChild("PlayerGui") end

-- cleanup
if parentGui:FindFirstChild("TripleSGUI") then
    parentGui.TripleSGUI:Destroy()
end

local screen = Instance.new("ScreenGui")
screen.Name = "TripleSGUI"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.ResetOnSpawn = false
screen.Parent = parentGui

-- panel utama
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 280, 0, 380)
frame.Position = UDim2.new(0.5, -140, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- header (nempel di frame)
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,32)
header.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

-- title (brand jadi tombol minimize)
local title = Instance.new("TextButton", header)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,8,0,0)
title.Text = "TripleS by Saanseventeen"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- tombol close
local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,24,0,24)
btnClose.Position = UDim2.new(1,-28,0,4)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 14
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)
btnClose.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- input bar (tetap ada)
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1,-24,0,28)
input.Position = UDim2.new(0,12,0,40)
input.PlaceholderText = "Type here..."
input.Text = ""
input.Font = Enum.Font.SourceSans
input.TextSize = 16
input.TextColor3 = Color3.new(1,1,1)
input.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", input).CornerRadius = UDim.new(0,8)
input.FocusLost:Connect(function(enter)
    if enter and input.Text ~= "" then
        runCommand(input.Text)
        input.Text = ""
    end
end)

-- content (tombol utama) — kept as Frame to preserve layout
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1,-24,1,-150)
content.Position = UDim2.new(0,12,0,80)
content.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", content)
grid.CellPadding = UDim2.new(0,10,0,10)
grid.CellSize = UDim2.new(0.5,-15,0,36)
grid.FillDirection = Enum.FillDirection.Horizontal
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Top

-- helper tombol
local function makeBtn(parent, text, command)
    local b = Instance.new("TextButton", parent)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    if command then
        b.MouseButton1Click:Connect(function()
            runCommand(command)
        end)
    end
    return b
end

-- helper input (TextBox mirip tombol)
local function makeInput(parent, placeholder, baseCommand)
    local box = Instance.new("TextBox", parent)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 14
    box.TextColor3 = Color3.new(1,1,1)
    box.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
    box.ClearTextOnFocus = false
    box.FocusLost:Connect(function(enter)
        if enter and box.Text ~= "" then
            runCommand(baseCommand .. " " .. box.Text)
            box.Text = ""
        end
    end)
    return box
end

-- tombol utama (mapping sesuai permintaanmu)
makeBtn(content,"Fly","fly")
makeBtn(content,"Unfly","unfly")
makeBtn(content,"Fling","fling")
makeBtn(content,"Unfling","unfling")
makeBtn(content,"Set Spawn","spawn")
makeBtn(content,"Delete Spawn","nospawn")
makeBtn(content,"Speed 23","speed 23")
makeBtn(content,"Tptool","tptool")
makeInput(content,"TGoto","tgoto")
makeInput(content,"GotoPart","gotopart")

-- footer tombol kecil
local footer = Instance.new("Frame", frame)
footer.Size = UDim2.new(1,-24,0,50)
footer.Position = UDim2.new(0,12,1,-56)
footer.BackgroundTransparency = 1

local footerLayout = Instance.new("UIListLayout", footer)
footerLayout.FillDirection = Enum.FillDirection.Horizontal
footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
footerLayout.Padding = UDim.new(0,12)

local function makeIconBtn(txt, emoji)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,40,0,40)
    b.Text = emoji
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 22
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    b.Parent = footer
    b.Name = txt
    return b
end

makeIconBtn("Settings", "⚙️")
makeIconBtn("Commands", "📜")
makeIconBtn("Keybinds", "⌨️")
makeIconBtn("Plugins",  "🔌")

-- mini button (SSS)
local miniBtn = Instance.new("TextButton", screen)
miniBtn.Size = UDim2.new(0,40,0,40)
miniBtn.Position = UDim2.new(1,-60,0,20)
miniBtn.BackgroundColor3 = Color3.new(0,0,0)
miniBtn.Text = "SSS"
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 14
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)
miniBtn.Visible = false
miniBtn.Active = true
miniBtn.Draggable = true

-- minimize (brand jadi tombol)
title.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtn.Visible = true
end)

-- restore
miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniBtn.Visible = false
end)

-- safety: cleanup on script unload / character removal
local function cleanupAll()
    stopFly()
    stopFling()
    clearCheckpoint()
    -- remove any created objects if needed (we didn't create persistent parts)
end

-- try to cleanup when player leaves or script destroyed
lp.AncestryChanged:Connect(function()
    if not lp:IsDescendantOf(game) then
        cleanupAll()
    end
end)

-- done
