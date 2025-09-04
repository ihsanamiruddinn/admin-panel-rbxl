-- TripleS GUI (standalone final, patched Fly & Fling)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ===== helpers karakter =====
local function getChar()
    local c = lp.Character or lp.CharacterAdded:Wait()
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

local function safeTeleport(cf)
    local c, hrp, hum = getChar()
    if hrp then
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
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- ===== state umum =====
local flying = false
local flyBV, flyBG, flyConn
local ascend, descend = 0
local flySpeed = 60

local flingActive = false
local flingPart

local checkpointCF = nil
local respawnConn = nil

-- ===== FLY (patched) =====
local function startFly()
    if flying then return end
    local c, hrp, hum = getChar()
    if not hrp or not hum then return end

    flying = true
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hum.PlatformStand = false

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    flyBG.P = 1e5
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp

    if flyConn then flyConn:Disconnect() end
    flyConn = RS.RenderStepped:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local dir = hum.MoveDirection
        local y = (ascend - descend)
        flyBV.Velocity = (dir * flySpeed) + Vector3.new(0,y*flySpeed,0)
        flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
    end)
end

local function stopFly()
    if not flying then return end
    flying = false
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if flyBV then flyBV:Destroy() flyBV=nil end
    if flyBG then flyBG:Destroy() flyBG=nil end
end

-- ===== FLING (patched) =====
local function startFling()
    if flingActive then return end
    local _, hrp = getChar()
    if not hrp then return end
    flingActive = true

    flingPart = Instance.new("Part")
    flingPart.Size = Vector3.new(5,5,5)
    flingPart.Transparency = 1
    flingPart.Anchored = false
    flingPart.CanCollide = false
    flingPart.Massless = true
    flingPart.Parent = workspace

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = flingPart
    weld.Part1 = hrp
    weld.Parent = flingPart

    local flingBV = Instance.new("BodyVelocity")
    flingBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    flingBV.Velocity = Vector3.new(9e5,9e5,9e5)
    flingBV.Parent = flingPart
end

local function stopFling()
    if not flingActive then return end
    flingActive = false
    if flingPart then flingPart:Destroy() flingPart=nil end
end

-- ===== SPAWN / CHECKPOINT =====
local function setCheckpoint()
    local _, hrp = getChar()
    if not hrp then return end
    checkpointCF = hrp.CFrame
    if respawnConn then respawnConn:Disconnect() respawnConn=nil end
    respawnConn = lp.CharacterAdded:Connect(function(char)
        local hrp2 = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if checkpointCF and hrp2 then
            task.wait(0.25)
            if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
            char:PivotTo(checkpointCF)
            task.wait()
            if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
    end)
end

local function clearCheckpoint()
    checkpointCF = nil
    if respawnConn then respawnConn:Disconnect() respawnConn=nil end
end

-- ===== SPEED =====
local function setSpeed(v)
    local _, _, hum = getChar()
    if hum then hum.WalkSpeed = v end
end

-- ===== TP TOOL =====
local function ensureTpTool()
    local backpack = lp:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    local tool = backpack:FindFirstChild("TpTool") or (lp.Character and lp.Character:FindFirstChild("TpTool"))
    if tool then return end

    tool = Instance.new("Tool")
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
    local target
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= lp and pl.Name:lower():find(partialName, 1, true) then
            target = pl break
        end
    end
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then safeTeleport(hrp.CFrame + Vector3.new(0,3,0)) end
    end
end

-- ===== GotoPart =====
local function gotoPartByName(partName)
    if not partName or partName == "" then return end
    for _,desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name:lower() == partName:lower() then
            safeTeleport(desc.CFrame + Vector3.new(0,3,0))
            break
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
    elseif h == "speed" then local v=tonumber(args[2] or ""); if v then setSpeed(v) end
    elseif h == "tptool" then ensureTpTool()
    elseif h == "tgoto" then gotoPlayer(args[2] and table.concat(args," ",2) or "")
    elseif h == "gotopart" then gotoPartByName(args[2] and table.concat(args," ",2) or "")
    end
end

-- ========== GUI ========== (unchanged layout)
-- (GUI code kamu tetap sama seperti versi standalone sebelumnya,
-- cuma bagian command mapping pakai runCommand)
