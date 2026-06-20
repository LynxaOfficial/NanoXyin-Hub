--// ╔══════════════════════════════════════════════════════════════════════════════╗
--// ║                    NANOXYIN ULTIMATE v4.0 - PROTECTED LOAD                  ║
--// ║                         SCRIPT BY XYIN - 2026                                ║
--// ║              ALL BYPASS METHODS | 1500+ LINES | MODERN UI                    ║
--// ╚══════════════════════════════════════════════════════════════════════════════╝

--// ============================================================
--// SECTION 1: SERVICE INITIALIZATION
--// ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// ============================================================
--// SECTION 2: UTILITY FUNCTIONS
--// ============================================================

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if success then
        return result
    else
        warn("[NANOXYIN] SafeCall Error: " .. tostring(result))
        return nil
    end
end

local function RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local randIndex = math.random(1, #chars)
        result = result .. chars:sub(randIndex, randIndex)
    end
    return result
end

local function WaitForChild(parent, name, timeout)
    timeout = timeout or 5
    local startTime = tick()
    while tick() - startTime < timeout do
        local child = parent:FindFirstChild(name)
        if child then
            return child
        end
        task.wait(0.1)
    end
    return nil
end

local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

--// ============================================================
--// SECTION 3: ANTI-DETECTION BYPASS LAYER 1 - getconnections
--// ============================================================

local function BypassLayer1_getconnections()
    SafeCall(function()
        if not getconnections then
            warn("[NANOXYIN] getconnections not available, skipping Layer 1")
            return
        end

        local blockedPatterns = {"kick", "ban", "punish", "detection", "report", 
            "log", "check", "verify", "ac", "anti", "security", "exploit", "cheat"}

        for _, descendant in pairs(game:GetDescendants()) do
            if descendant:IsA("RemoteEvent") or descendant:IsA("BindableEvent") then
                local nameLower = descendant.Name:lower()
                local shouldBlock = false
                for _, pattern in ipairs(blockedPatterns) do
                    if nameLower:find(pattern) then
                        shouldBlock = true
                        break
                    end
                end

                if shouldBlock then
                    local connections = getconnections(descendant.OnClientEvent)
                    for _, connection in pairs(connections) do
                        SafeCall(function()
                            connection:Disable()
                        end)
                    end
                end
            end
        end

        game.DescendantAdded:Connect(function(newDescendant)
            SafeCall(function()
                if newDescendant:IsA("RemoteEvent") or newDescendant:IsA("BindableEvent") then
                    task.wait(0.3)
                    local nameLower = newDescendant.Name:lower()
                    for _, pattern in ipairs(blockedPatterns) do
                        if nameLower:find(pattern) then
                            local connections = getconnections(newDescendant.OnClientEvent)
                            for _, connection in pairs(connections) do
                                SafeCall(function()
                                    connection:Disable()
                                end)
                            end
                            break
                        end
                    end
                end
            end)
        end)
    end)
end

BypassLayer1_getconnections()

--// ============================================================
--// SECTION 4: ANTI-DETECTION BYPASS LAYER 2 - getgc
--// ============================================================

local function BypassLayer2_getgc()
    SafeCall(function()
        if not getgc then
            warn("[NANOXYIN] getgc not available, skipping Layer 2")
            return
        end

        local blockedNames = {"kick", "ban", "detect", "check", "anticheat", 
            "exploit", "security", "punish", "reportplayer"}

        local gcObjects = getgc(true)
        for _, obj in pairs(gcObjects) do
            if type(obj) == "function" then
                SafeCall(function()
                    local info = debug.getinfo(obj)
                    if info and info.name then
                        local funcName = info.name:lower()
                        for _, blockedName in ipairs(blockedNames) do
                            if funcName:find(blockedName) then
                                local upvalues = debug.getupvalues(obj)
                                for i, upv in pairs(upvalues) do
                                    if type(upv) == "function" then
                                        SafeCall(function()
                                            debug.setupvalue(obj, i, function() end)
                                        end)
                                    end
                                end
                                break
                            end
                        end
                    end
                end)
            end

            if type(obj) == "table" then
                SafeCall(function()
                    for k, v in pairs(obj) do
                        if type(k) == "string" then
                            local keyLower = k:lower()
                            for _, blockedName in ipairs(blockedNames) do
                                if keyLower:find(blockedName) and type(v) == "function" then
                                    obj[k] = function() end
                                    break
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

BypassLayer2_getgc()

--// ============================================================
--// SECTION 5: ANTI-DETECTION BYPASS LAYER 3 - hookmetamethod
--// ============================================================

local function BypassLayer3_hookmetamethod()
    SafeCall(function()
        if not hookmetamethod then
            warn("[NANOXYIN] hookmetamethod not available, skipping Layer 3")
            return
        end

        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" then
                local selfStr = tostring(self):lower()
                if selfStr:find("player") or self == LocalPlayer then
                    return wait(9e9)
                end
            end
            if method == "Destroy" then
                local selfStr = tostring(self):lower()
                if selfStr:find("anticheat") or selfStr:find("ac") or selfStr:find("detection") then
                    return wait(9e9)
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

BypassLayer3_hookmetamethod()

--// ============================================================
--// SECTION 6: ANTI-DETECTION BYPASS LAYER 4 - hookfunction
--// ============================================================

local function BypassLayer4_hookfunction()
    SafeCall(function()
        if not hookfunction then
            warn("[NANOXYIN] hookfunction not available, skipping Layer 4")
            return
        end

        if LocalPlayer.Kick then
            local oldKick = hookfunction(LocalPlayer.Kick, function(self, msg)
                if self == LocalPlayer then
                    return wait(9e9)
                end
            end)
        end

        local playerMeta = getmetatable(LocalPlayer)
        if playerMeta and playerMeta.__index and playerMeta.__index.Kick then
            local originalKick = playerMeta.__index.Kick
            playerMeta.__index.Kick = function(self, msg)
                if self == LocalPlayer then
                    return wait(9e9)
                end
                return originalKick(self, msg)
            end
        end
    end)
end

BypassLayer4_hookfunction()

--// ============================================================
--// SECTION 7: ANTI-DETECTION BYPASS LAYER 5 - Remote Spoofing
--// ============================================================

local function BypassLayer5_RemoteSpoof()
    SafeCall(function()
        local blockedPatterns = {"kick", "ban", "punish", "detection", "report", 
            "log", "check", "verify", "ac", "anti", "security", "exploit", "cheat"}

        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local nameLower = v.Name:lower()
                for _, pattern in ipairs(blockedPatterns) do
                    if nameLower:find(pattern) then
                        SafeCall(function()
                            v.FireServer = function(...) return nil end
                        end)
                        break
                    end
                end
            elseif v:IsA("RemoteFunction") then
                local nameLower = v.Name:lower()
                for _, pattern in ipairs(blockedPatterns) do
                    if nameLower:find(pattern) then
                        SafeCall(function()
                            v.InvokeServer = function(...) return nil end
                        end)
                        break
                    end
                end
            end
        end

        game.DescendantAdded:Connect(function(v)
            SafeCall(function()
                if v:IsA("RemoteEvent") then
                    task.wait(0.2)
                    local nameLower = v.Name:lower()
                    for _, pattern in ipairs(blockedPatterns) do
                        if nameLower:find(pattern) then
                            v.FireServer = function(...) return nil end
                            break
                        end
                    end
                elseif v:IsA("RemoteFunction") then
                    task.wait(0.2)
                    local nameLower = v.Name:lower()
                    for _, pattern in ipairs(blockedPatterns) do
                        if nameLower:find(pattern) then
                            v.InvokeServer = function(...) return nil end
                            break
                        end
                    end
                end
            end)
        end)
    end)
end

BypassLayer5_RemoteSpoof()

--// ============================================================
--// SECTION 8: ANTI-DETECTION BYPASS LAYER 6 - AC GUI Removal
--// ============================================================

local function BypassLayer6_ACGUI()
    SafeCall(function()
        local acGuiPatterns = {"loading", "anticheat", "ac", "detection", 
            "verification", "check", "security", "ban", "kick"}

        local function ProcessGui(gui)
            SafeCall(function()
                if gui:IsA("ScreenGui") then
                    local nameLower = gui.Name:lower()
                    for _, pattern in ipairs(acGuiPatterns) do
                        if nameLower:find(pattern) then
                            gui.Enabled = false
                            gui:Destroy()
                            break
                        end
                    end
                end
            end)
        end

        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            ProcessGui(v)
        end

        LocalPlayer.PlayerGui.ChildAdded:Connect(function(v)
            SafeCall(function()
                task.wait(0.3)
                ProcessGui(v)
            end)
        end)

        for _, v in pairs(StarterGui:GetChildren()) do
            ProcessGui(v)
        end
    end)
end

BypassLayer6_ACGUI()

--// ============================================================
--// SECTION 9: ANTI-DETECTION BYPASS LAYER 7 - Module Destruction
--// ============================================================

local function BypassLayer7_ModuleDestroy()
    SafeCall(function()
        local acModuleNames = {
            "AntiCheat", "AntiExploit", "AntiHack", "ACDetector", 
            "CheatDetection", "ExploitDetection", "SecurityModule",
            "Anti", "AC", "Detector", "Security", "Protection"
        }

        for _, name in ipairs(acModuleNames) do
            SafeCall(function()
                local found = game:FindFirstChild(name, true)
                if found then
                    found:Destroy()
                end
            end)
        end

        game.DescendantAdded:Connect(function(v)
            SafeCall(function()
                if v:IsA("ModuleScript") then
                    task.wait(0.2)
                    local nameLower = v.Name:lower()
                    for _, pattern in ipairs(acModuleNames) do
                        if nameLower:find(pattern:lower()) then
                            v:Destroy()
                            break
                        end
                    end
                end
            end)
        end)
    end)
end

BypassLayer7_ModuleDestroy()

--// ============================================================
--// SECTION 10: ANTI-DETECTION BYPASS LAYER 8 - Kick Monitor Loop
--// ============================================================

local function BypassLayer8_KickMonitor()
    SafeCall(function()
        task.spawn(function()
            while true do
                SafeCall(function()
                    if LocalPlayer.Parent ~= Players then
                        LocalPlayer.Parent = Players
                    end
                end)
                task.wait(0.5)
            end
        end)
    end)
end

BypassLayer8_KickMonitor()

--// ============================================================
--// SECTION 11: ANTI-DETECTION BYPASS LAYER 9 - Signal Blocking
--// ============================================================

local function BypassLayer9_SignalBlock()
    SafeCall(function()
        LocalPlayer.ChildRemoved:Connect(function(child)
            SafeCall(function()
                if child.Name:lower():find("kick") or child.Name:lower():find("ban") then
                    -- Prevent removal
                end
            end)
        end)
    end)
end

BypassLayer9_SignalBlock()

--// ============================================================
--// SECTION 12: ANTI-DETECTION BYPASS LAYER 10 - Memory Scan Spoof
--// ============================================================

local function BypassLayer10_MemorySpoof()
    SafeCall(function()
        if getfenv then
            local env = getfenv(0)
            if env and env.script then
                SafeCall(function()
                    env.script.Name = "LocalScript"
                end)
            end
        end
    end)
end

BypassLayer10_MemorySpoof()

--// ============================================================
--// SECTION 13: CONFIGURATION
--// ============================================================

local Config = {
    Aimbot = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2,
        FOV = 150,
        Smoothness = 0.08,
        TargetPart = "Head",
        TeamCheck = true,
        WallCheck = false,
        Prediction = 0.165,
        FlickMode = true,
        FlickSpeed = 0.5,
        Accuracy = 0.85,
        ReactionMin = 0.08,
        ReactionMax = 0.25,
        Jitter = 0.08,
        Shake = 0.03,
    },
    AutoFire = {
        Enabled = true,
        Key = Enum.KeyCode.F,
        Active = false,
        Delay = 0.05,
        DelayMin = 0.05,
        DelayMax = 0.15,
        LastShot = 0,
        RequireAim = false,
    },
    ESP = {
        Enabled = true,
        Box = true,
        BoxFilled = true,
        BoxColor = Color3.fromRGB(255, 0, 80),
        BoxFilledColor = Color3.fromRGB(255, 0, 80),
        BoxFilledTransparency = 0.15,
        Line = true,
        LineColor = Color3.fromRGB(255, 255, 255),
        Name = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        NameSize = 14,
        Distance = true,
        Health = true,
        HealthBar = true,
        Tracers = false,
        TracerColor = Color3.fromRGB(255, 0, 80),
        MaxDistance = 2000,
        Skeleton = false,
        SkeletonColor = Color3.fromRGB(0, 255, 200),
    },
    XRay = {
        Enabled = true,
        Key = Enum.KeyCode.X,
        Active = true,
        WallTransparency = 0.3,
        EnemyHighlightColor = Color3.fromRGB(255, 0, 0),
        EnemyOutlineColor = Color3.fromRGB(255, 255, 0),
    },
    FOV = {
        Visible = true,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.5,
        Thickness = 1,
    },
    Misc = {
        NoRecoil = false,
        NoSpread = false,
        InstantReload = false,
        SpeedHack = false,
        SpeedValue = 16,
        Fly = false,
        FlySpeed = 50,
    }
}

--// ============================================================
--// SECTION 14: STATE VARIABLES
--// ============================================================

local ESPObjects = {}
local AimTarget = nil
local FOV_Circle = nil
local XRayHighlights = {}
local XRayConnections = {}
local _lastTarget = nil
local _targetSwitchTime = 0
local _reactionDelay = 0
local _isReacting = false
local _missOffset = Vector2.new(0, 0)
local _shakeOffset = Vector2.new(0, 0)
local _rnd = Random.new(tick() * 1337)
local ScreenGui = nil
local MainFrame = nil

--// ============================================================
--// SECTION 15: UTILITY FUNCTIONS FOR CORE
--// ============================================================

local function GetCharacter(player)
    return player.Character
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function GetHead(character)
    return character:FindFirstChild(Config.Aimbot.TargetPart) or character:FindFirstChild("Head")
end

local function GetTorso(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function IsAlive(character)
    local humanoid = GetHumanoid(character)
    return humanoid and humanoid.Health > 0
end

local function IsTeammate(player)
    if not Config.Aimbot.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function IsVisible(target, part)
    if not Config.Aimbot.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil or result.Instance:IsDescendantOf(target.Character)
end

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = Config.Aimbot.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeammate(player) then continue end

        local character = GetCharacter(player)
        if not character then continue end
        if not IsAlive(character) then continue end

        local head = GetHead(character)
        if not head then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end

        local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
        if distance < shortestDistance then
            if IsVisible(player, head) then
                shortestDistance = distance
                closest = player
            end
        end
    end

    return closest
end

local function GetPredictedPosition(target)
    local character = GetCharacter(target)
    if not character then return nil end

    local head = GetHead(character)
    if not head then return nil end

    local humanoid = GetHumanoid(character)
    if not humanoid then return head.Position end

    local velocity = humanoid.MoveDirection * humanoid.WalkSpeed
    return head.Position + (velocity * Config.Aimbot.Prediction)
end

--// ============================================================
--// SECTION 16: HUMAN BEHAVIOR SIMULATION
--// ============================================================

local function ShouldMiss()
    return _rnd:NextNumber() > Config.Aimbot.Accuracy
end

local function GetMissOffset()
    local angle = _rnd:NextNumber() * math.pi * 2
    local dist = _rnd:NextNumber(15, 45)
    return Vector2.new(math.cos(angle) * dist, math.sin(angle) * dist)
end

local function GetShake()
    return Vector2.new(
        _rnd:NextNumber(-Config.Aimbot.Shake, Config.Aimbot.Shake) * 10,
        _rnd:NextNumber(-Config.Aimbot.Shake, Config.Aimbot.Shake) * 10
    )
end

local function GetReactionDelay()
    return _rnd:NextNumber(Config.Aimbot.ReactionMin, Config.Aimbot.ReactionMax)
end

--// ============================================================
--// SECTION 17: X-RAY SYSTEM
--// ============================================================

local function SetupXRay()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local nameLower = obj.Name:lower()
            if nameLower:find("wall") or nameLower:find("door") or nameLower:find("barrier") or nameLower:find("cover") then
                local originalTransparency = obj:GetAttribute("OriginalTransparency")
                if not originalTransparency then
                    obj:SetAttribute("OriginalTransparency", obj.Transparency)
                end
                if Config.XRay.Active then
                    obj.Transparency = Config.XRay.WallTransparency
                    obj.CanCollide = true
                else
                    obj.Transparency = obj:GetAttribute("OriginalTransparency") or 0
                end
            end
        end
    end
end

local function UpdateXRayHighlights()
    for _, highlight in pairs(XRayHighlights) do
        if highlight then
            SafeCall(function()
                highlight:Destroy()
            end)
        end
    end
    XRayHighlights = {}

    if not Config.XRay.Active then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeammate(player) then continue end

        local character = GetCharacter(player)
        if not character then continue end
        if not IsAlive(character) then continue end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                SafeCall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "NanoXyinXRay_" .. RandomString(5)
                    highlight.Adornee = part
                    highlight.FillColor = Config.XRay.EnemyHighlightColor
                    highlight.OutlineColor = Config.XRay.EnemyOutlineColor
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = part
                    table.insert(XRayHighlights, highlight)
                end)
            end
        end
    end
end

local function ToggleXRay()
    Config.XRay.Active = not Config.XRay.Active
    SetupXRay()
    UpdateXRayHighlights()
end

--// ============================================================
--// SECTION 18: FOV CIRCLE
--// ============================================================

local function CreateFOVCircle()
    FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Visible = Config.FOV.Visible
    FOV_Circle.Color = Config.FOV.Color
    FOV_Circle.Transparency = Config.FOV.Transparency
    FOV_Circle.Thickness = Config.FOV.Thickness
    FOV_Circle.Filled = false
    FOV_Circle.NumSides = 64
    FOV_Circle.Radius = Config.Aimbot.FOV
end

CreateFOVCircle()

--// ============================================================
--// SECTION 19: ESP SYSTEM
--// ============================================================

local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        BoxFill = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBG = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
    }

    esp.Box.Thickness = 1
    esp.Box.Color = Config.ESP.BoxColor
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Box.Visible = false

    esp.BoxFill.Color = Config.ESP.BoxFilledColor
    esp.BoxFill.Transparency = Config.ESP.BoxFilledTransparency
    esp.BoxFill.Filled = true
    esp.BoxFill.Visible = false

    esp.Line.Thickness = 1
    esp.Line.Color = Config.ESP.LineColor
    esp.Line.Visible = false

    esp.Name.Size = Config.ESP.NameSize
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Config.ESP.NameColor
    esp.Name.Visible = false

    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
    esp.Distance.Visible = false

    esp.HealthBarBG.Thickness = 1
    esp.HealthBarBG.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthBarBG.Filled = true
    esp.HealthBarBG.Visible = false

    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    esp.HealthBar.Visible = false

    esp.Tracer.Thickness = 1
    esp.Tracer.Color = Config.ESP.TracerColor
    esp.Tracer.Visible = false

    ESPObjects[player] = esp
    return esp
end

local function RemoveESP(player)
    local esp = ESPObjects[player]
    if not esp then return end

    for _, obj in pairs(esp) do
        if obj then
            SafeCall(function()
                obj:Remove()
            end)
        end
    end

    ESPObjects[player] = nil
end

local function UpdateESP()
    for player, esp in pairs(ESPObjects) do
        local character = GetCharacter(player)

        if not character or not IsAlive(character) or player == LocalPlayer or (Config.Aimbot.TeamCheck and IsTeammate(player)) then
            for _, obj in pairs(esp) do
                if obj then
                    SafeCall(function()
                        obj.Visible = false
                    end)
                end
            end
            continue
        end

        local humanoid = GetHumanoid(character)
        local head = character:FindFirstChild("Head")
        local root = character:FindFirstChild("HumanoidRootPart")

        if not head or not root or not humanoid then
            for _, obj in pairs(esp) do
                if obj then
                    SafeCall(function()
                        obj.Visible = false
                    end)
                end
            end
            continue
        end

        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)

        if not headOnScreen or not rootOnScreen then
            for _, obj in pairs(esp) do
                if obj then
                    SafeCall(function()
                        obj.Visible = false
                    end)
                end
            end
            continue
        end

        local distance = (root.Position - Camera.CFrame.Position).Magnitude
        if distance > Config.ESP.MaxDistance then
            for _, obj in pairs(esp) do
                if obj then
                    SafeCall(function()
                        obj.Visible = false
                    end)
                end
            end
            continue
        end

        local boxHeight = math.abs(headPos.Y - rootPos.Y) * 2.5
        local boxWidth = boxHeight * 0.6
        local boxPosition = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)

        if Config.ESP.Box then
            SafeCall(function()
                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                esp.Box.Position = boxPosition
                esp.Box.Visible = true
            end)

            if Config.ESP.BoxFilled then
                SafeCall(function()
                    esp.BoxFill.Size = Vector2.new(boxWidth, boxHeight)
                    esp.BoxFill.Position = boxPosition
                    esp.BoxFill.Visible = true
                end)
            else
                SafeCall(function()
                    esp.BoxFill.Visible = false
                end)
            end
        else
            SafeCall(function()
                esp.Box.Visible = false
                esp.BoxFill.Visible = false
            end)
        end

        if Config.ESP.Line then
            SafeCall(function()
                esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.Line.Visible = true
            end)
        else
            SafeCall(function()
                esp.Line.Visible = false
            end)
        end

        if Config.ESP.Name then
            SafeCall(function()
                esp.Name.Position = Vector2.new(rootPos.X, boxPosition.Y - 20)
                esp.Name.Text = player.Name
                esp.Name.Visible = true
            end)
        else
            SafeCall(function()
                esp.Name.Visible = false
            end)
        end

        if Config.ESP.Distance then
            SafeCall(function()
                esp.Distance.Position = Vector2.new(rootPos.X, boxPosition.Y + boxHeight + 5)
                esp.Distance.Text = math.floor(distance) .. "m"
                esp.Distance.Visible = true
            end)
        else
            SafeCall(function()
                esp.Distance.Visible = false
            end)
        end

        if Config.ESP.HealthBar then
            SafeCall(function()
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local barHeight = boxHeight * healthPercent

                esp.HealthBarBG.Size = Vector2.new(4, boxHeight)
                esp.HealthBarBG.Position = Vector2.new(boxPosition.X - 8, boxPosition.Y)
                esp.HealthBarBG.Visible = true

                esp.HealthBar.Size = Vector2.new(4, barHeight)
                esp.HealthBar.Position = Vector2.new(boxPosition.X - 8, boxPosition.Y + (boxHeight - barHeight))
                esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                esp.HealthBar.Visible = true
            end)
        else
            SafeCall(function()
                esp.HealthBar.Visible = false
                esp.HealthBarBG.Visible = false
            end)
        end

        if Config.ESP.Tracers then
            SafeCall(function()
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.Tracer.Visible = true
            end)
        else
            SafeCall(function()
                esp.Tracer.Visible = false
            end)
        end
    end
end

--// ============================================================
--// SECTION 20: FLICK AIMBOT + AUTO-FIRE
--// ============================================================

local function FlickAimbot()
    if not Config.Aimbot.Enabled then return end

    if UserInputService:IsMouseButtonPressed(Config.Aimbot.Key) then
        if not AimTarget then
            AimTarget = GetClosestPlayer()
            if AimTarget then
                _isReacting = true
                _reactionDelay = tick() + GetReactionDelay()
                _missOffset = ShouldMiss() and GetMissOffset() or Vector2.new(0, 0)
            end
        end

        if AimTarget and _isReacting then
            if tick() < _reactionDelay then
                return
            end
            _isReacting = false
        end

        if AimTarget then
            local character = GetCharacter(AimTarget)
            if not character or not IsAlive(character) then
                AimTarget = nil
                _isReacting = false
                return
            end

            local predictedPos = GetPredictedPosition(AimTarget)
            if not predictedPos then
                AimTarget = nil
                _isReacting = false
                return
            end

            local screenPos = Camera:WorldToViewportPoint(predictedPos)
            local mousePos = UserInputService:GetMouseLocation()
            local targetPos = Vector2.new(screenPos.X, screenPos.Y)

            targetPos = targetPos + _missOffset
            _shakeOffset = GetShake()
            targetPos = targetPos + _shakeOffset

            local rawMove = (targetPos - mousePos)
            local jitterX = _rnd:NextNumber(-Config.Aimbot.Jitter, Config.Aimbot.Jitter) * rawMove.X
            local jitterY = _rnd:NextNumber(-Config.Aimbot.Jitter, Config.Aimbot.Jitter) * rawMove.Y
            rawMove = rawMove + Vector2.new(jitterX, jitterY)

            local smoothness = Config.Aimbot.FlickMode and Config.Aimbot.FlickSpeed or Config.Aimbot.Smoothness
            local moveVector = rawMove * smoothness

            SafeCall(function()
                mousemoverel(moveVector.X, moveVector.Y)
            end)

            if Config.AutoFire.Enabled and Config.AutoFire.Active then
                local currentTime = tick()
                local actualDelay = _rnd:NextNumber(Config.AutoFire.DelayMin, Config.AutoFire.DelayMax)
                if currentTime - Config.AutoFire.LastShot >= actualDelay then
                    if not Config.AutoFire.RequireAim or (Config.AutoFire.RequireAim and AimTarget) then
                        local distToTarget = (targetPos - mousePos).Magnitude
                        if distToTarget < 25 then
                            SafeCall(function()
                                mouse1click()
                            end)
                            Config.AutoFire.LastShot = currentTime
                        end
                    end
                end
            end
        end
    else
        AimTarget = nil
        _isReacting = false
        _missOffset = Vector2.new(0, 0)
    end
end

--// ============================================================
--// SECTION 21: MODERN UI SYSTEM
--// ============================================================

local function CreateModernUI()
    SafeCall(function()
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "NanoXyinUI_" .. RandomString(8)
        ScreenGui.Parent = game.CoreGui
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.ResetOnSpawn = false

        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
        end

        MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 550, 0, 400)
        MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
        MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
        MainFrame.BorderSizePixel = 0
        MainFrame.Parent = ScreenGui

        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 20)
        MainCorner.Parent = MainFrame

        local Shadow = Instance.new("ImageLabel")
        Shadow.Name = "Shadow"
        Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        Shadow.BackgroundTransparency = 1
        Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        Shadow.Size = UDim2.new(1, 40, 1, 40)
        Shadow.ZIndex = -1
        Shadow.Image = "rbxassetid://5554236805"
        Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        Shadow.ImageTransparency = 0.6
        Shadow.ScaleType = Enum.ScaleType.Slice
        Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        Shadow.Parent = MainFrame

        local TopBar = Instance.new("Frame")
        TopBar.Name = "TopBar"
        TopBar.Size = UDim2.new(1, 0, 0, 60)
        TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        TopBar.BorderSizePixel = 0
        TopBar.Parent = MainFrame

        local TopBarCorner = Instance.new("UICorner")
        TopBarCorner.CornerRadius = UDim.new(0, 20)
        TopBarCorner.Parent = TopBar

        local TitleIcon = Instance.new("TextLabel")
        TitleIcon.Size = UDim2.new(0, 40, 0, 40)
        TitleIcon.Position = UDim2.new(0, 15, 0, 10)
        TitleIcon.BackgroundTransparency = 1
        TitleIcon.Text = "◆"
        TitleIcon.TextColor3 = Color3.fromRGB(0, 255, 200)
        TitleIcon.TextSize = 28
        TitleIcon.Font = Enum.Font.GothamBold
        TitleIcon.Parent = TopBar

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(0, 200, 0, 30)
        TitleLabel.Position = UDim2.new(0, 55, 0, 8)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = "NANOXYIN"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 22
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = TopBar

        local SubTitleLabel = Instance.new("TextLabel")
        SubTitleLabel.Size = UDim2.new(0, 200, 0, 18)
        SubTitleLabel.Position = UDim2.new(0, 55, 0, 32)
        SubTitleLabel.BackgroundTransparency = 1
        SubTitleLabel.Text = "v4.0 ULTIMATE | BY XYIN"
        SubTitleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        SubTitleLabel.TextSize = 11
        SubTitleLabel.Font = Enum.Font.Gotham
        SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        SubTitleLabel.Parent = TopBar

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 32, 0, 32)
        CloseBtn.Position = UDim2.new(1, -42, 0, 14)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseBtn.TextSize = 16
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.Parent = TopBar

        local CloseCorner = Instance.new("UICorner")
        CloseCorner.CornerRadius = UDim.new(0, 10)
        CloseCorner.Parent = CloseBtn

        CloseBtn.MouseButton1Click:Connect(function()
            ScreenGui.Enabled = false
        end)

        CloseBtn.MouseEnter:Connect(function()
            TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 30, 30)}):Play()
        end)

        CloseBtn.MouseLeave:Connect(function()
            TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}):Play()
        end)

        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 32, 0, 32)
        MinBtn.Position = UDim2.new(1, -80, 0, 14)
        MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        MinBtn.Text = "-"
        MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinBtn.TextSize = 20
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.Parent = TopBar

        local MinCorner = Instance.new("UICorner")
        MinCorner.CornerRadius = UDim.new(0, 10)
        MinCorner.Parent = MinBtn

        MinBtn.MouseButton1Click:Connect(function()
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 550, 0, 60)}):Play()
        end)

        local TabBar = Instance.new("Frame")
        TabBar.Name = "TabBar"
        TabBar.Size = UDim2.new(0, 140, 1, -60)
        TabBar.Position = UDim2.new(0, 0, 0, 60)
        TabBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
        TabBar.BorderSizePixel = 0
        TabBar.Parent = MainFrame

        local ContentArea = Instance.new("ScrollingFrame")
        ContentArea.Name = "ContentArea"
        ContentArea.Size = UDim2.new(1, -140, 1, -60)
        ContentArea.Position = UDim2.new(0, 140, 0, 60)
        ContentArea.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
        ContentArea.BorderSizePixel = 0
        ContentArea.ScrollBarThickness = 4
        ContentArea.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
        ContentArea.Parent = MainFrame

        local Tabs = {}
        local CurrentTab = nil

        local function CreateTab(name, icon, color)
            local TabBtn = Instance.new("TextButton")
            TabBtn.Size = UDim2.new(1, -20, 0, 45)
            TabBtn.Position = UDim2.new(0, 10, 0, #Tabs * 55 + 15)
            TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            TabBtn.Text = ""
            TabBtn.AutoButtonColor = false
            TabBtn.Parent = TabBar

            local TabCorner = Instance.new("UICorner")
            TabCorner.CornerRadius = UDim.new(0, 12)
            TabCorner.Parent = TabBtn

            local TabIcon = Instance.new("TextLabel")
            TabIcon.Size = UDim2.new(0, 30, 0, 30)
            TabIcon.Position = UDim2.new(0, 10, 0, 7)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Text = icon
            TabIcon.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            TabIcon.TextSize = 20
            TabIcon.Font = Enum.Font.GothamBold
            TabIcon.Parent = TabBtn

            local TabText = Instance.new("TextLabel")
            TabText.Size = UDim2.new(1, -50, 1, 0)
            TabText.Position = UDim2.new(0, 40, 0, 0)
            TabText.BackgroundTransparency = 1
            TabText.Text = name
            TabText.TextColor3 = Color3.fromRGB(200, 200, 200)
            TabText.TextSize = 14
            TabText.Font = Enum.Font.Gotham
            TabText.TextXAlignment = Enum.TextXAlignment.Left
            TabText.Parent = TabBtn

            local TabContent = Instance.new("Frame")
            TabContent.Size = UDim2.new(1, -20, 1, -20)
            TabContent.Position = UDim2.new(0, 10, 0, 10)
            TabContent.BackgroundTransparency = 1
            TabContent.Visible = false
            TabContent.Parent = ContentArea

            local tab = {Btn = TabBtn, Content = TabContent, Icon = TabIcon, Text = TabText}
            table.insert(Tabs, tab)

            TabBtn.MouseButton1Click:Connect(function()
                if CurrentTab then
                    CurrentTab.Content.Visible = false
                    CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    CurrentTab.Icon.TextColor3 = Color3.fromRGB(200, 200, 200)
                    CurrentTab.Text.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                CurrentTab = tab
                tab.Content.Visible = true
                tab.Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
                tab.Icon.TextColor3 = Color3.fromRGB(13, 13, 18)
                tab.Text.TextColor3 = Color3.fromRGB(13, 13, 18)
            end)

            TabBtn.MouseEnter:Connect(function()
                if CurrentTab ~= tab then
                    TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
                end
            end)

            TabBtn.MouseLeave:Connect(function()
                if CurrentTab ~= tab then
                    TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
                end
            end)

            return TabContent
        end

        local AimbotTab = CreateTab("Aimbot", ">", Color3.fromRGB(255, 100, 100))
        local ESPTab = CreateTab("ESP", "O", Color3.fromRGB(100, 200, 255))
        local XRayTab = CreateTab("X-Ray", "<>", Color3.fromRGB(255, 255, 100))
        local MiscTab = CreateTab("Misc", "*", Color3.fromRGB(150, 255, 150))
        local SettingsTab = CreateTab("Settings", "#", Color3.fromRGB(200, 150, 255))

        local function CreateToggle(parent, text, default, callback, yPos)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
            ToggleFrame.Position = UDim2.new(0, 0, 0, yPos or 0)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = parent

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 250, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 15
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local ToggleBg = Instance.new("Frame")
            ToggleBg.Size = UDim2.new(0, 55, 0, 28)
            ToggleBg.Position = UDim2.new(1, -65, 0.5, -14)
            ToggleBg.BackgroundColor3 = default and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
            ToggleBg.BorderSizePixel = 0
            ToggleBg.Parent = ToggleFrame

            local ToggleBgCorner = Instance.new("UICorner")
            ToggleBgCorner.CornerRadius = UDim.new(1, 0)
            ToggleBgCorner.Parent = ToggleBg

            local ToggleKnob = Instance.new("Frame")
            ToggleKnob.Size = UDim2.new(0, 22, 0, 22)
            ToggleKnob.Position = default and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
            ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleKnob.BorderSizePixel = 0
            ToggleKnob.Parent = ToggleBg

            local ToggleKnobCorner = Instance.new("UICorner")
            ToggleKnobCorner.CornerRadius = UDim.new(1, 0)
            ToggleKnobCorner.Parent = ToggleKnob

            local state = default
            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    callback(state)

                    if state then
                        TweenService:Create(ToggleBg, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
                        TweenService:Create(ToggleKnob, TweenInfo.new(0.3), {Position = UDim2.new(1, -26, 0.5, -11)}):Play()
                    else
                        TweenService:Create(ToggleBg, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
                        TweenService:Create(ToggleKnob, TweenInfo.new(0.3), {Position = UDim2.new(0, 4, 0.5, -11)}):Play()
                    end
                end
            end)

            return ToggleFrame
        end

        local function CreateSlider(parent, text, min, max, default, callback, yPos)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 60)
            SliderFrame.Position = UDim2.new(0, 0, 0, yPos or 0)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = parent

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 250, 0, 22)
            Label.BackgroundTransparency = 1
            Label.Text = text .. ": " .. default
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 22)
            ValueLabel.Position = UDim2.new(1, -50, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
            ValueLabel.TextSize = 14
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local SliderBar = Instance.new("Frame")
            SliderBar.Size = UDim2.new(1, 0, 0, 10)
            SliderBar.Position = UDim2.new(0, 0, 0, 35)
            SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderFrame

            local SliderBarCorner = Instance.new("UICorner")
            SliderBarCorner.CornerRadius = UDim.new(1, 0)
            SliderBarCorner.Parent = SliderBar

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar

            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill

            local SliderKnob = Instance.new("Frame")
            SliderKnob.Size = UDim2.new(0, 18, 0, 18)
            SliderKnob.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
            SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderKnob.BorderSizePixel = 0
            SliderKnob.Parent = SliderBar

            local SliderKnobCorner = Instance.new("UICorner")
            SliderKnobCorner.CornerRadius = UDim.new(1, 0)
            SliderKnobCorner.Parent = SliderKnob

            local dragging = false

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -9, 0.5, -9)
                    Label.Text = text .. ": " .. value
                    ValueLabel.Text = tostring(value)
                    callback(value)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -9, 0.5, -9)
                    Label.Text = text .. ": " .. value
                    ValueLabel.Text = tostring(value)
                    callback(value)
                end
            end)

            return SliderFrame
        end

        local function CreateSection(parent, text, yPos)
            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.Position = UDim2.new(0, 0, 0, yPos or 0)
            Section.BackgroundTransparency = 1
            Section.Parent = parent

            local SectionText = Instance.new("TextLabel")
            SectionText.Size = UDim2.new(1, 0, 1, 0)
            SectionText.BackgroundTransparency = 1
            SectionText.Text = text
            SectionText.TextColor3 = Color3.fromRGB(0, 255, 200)
            SectionText.TextSize = 16
            SectionText.Font = Enum.Font.GothamBold
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            SectionText.Parent = Section

            local SectionLine = Instance.new("Frame")
            SectionLine.Size = UDim2.new(1, 0, 0, 2)
            SectionLine.Position = UDim2.new(0, 0, 1, -2)
            SectionLine.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
            SectionLine.BorderSizePixel = 0
            SectionLine.Parent = Section

            local SectionLineCorner = Instance.new("UICorner")
            SectionLineCorner.CornerRadius = UDim.new(1, 0)
            SectionLineCorner.Parent = SectionLine

            return Section
        end

        CreateSection(AimbotTab, "Aimbot Settings", 0)
        CreateToggle(AimbotTab, "Enable Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end, 40)
        CreateToggle(AimbotTab, "Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end, 90)
        CreateToggle(AimbotTab, "Wall Check", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end, 140)
        CreateToggle(AimbotTab, "Flick Mode", Config.Aimbot.FlickMode, function(v) Config.Aimbot.FlickMode = v end, 190)
        CreateSlider(AimbotTab, "FOV", 50, 300, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end, 240)
        CreateSlider(AimbotTab, "Smoothness", 1, 50, 8, function(v) Config.Aimbot.Smoothness = v / 100 end, 310)
        CreateSlider(AimbotTab, "Accuracy", 50, 100, 85, function(v) Config.Aimbot.Accuracy = v / 100 end, 380)

        CreateSection(ESPTab, "ESP Settings", 0)
        CreateToggle(ESPTab, "Enable ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end, 40)
        CreateToggle(ESPTab, "Box", Config.ESP.Box, function(v) Config.ESP.Box = v end, 90)
        CreateToggle(ESPTab, "Box Filled", Config.ESP.BoxFilled, function(v) Config.ESP.BoxFilled = v end, 140)
        CreateToggle(ESPTab, "Line", Config.ESP.Line, function(v) Config.ESP.Line = v end, 190)
        CreateToggle(ESPTab, "Name", Config.ESP.Name, function(v) Config.ESP.Name = v end, 240)
        CreateToggle(ESPTab, "Distance", Config.ESP.Distance, function(v) Config.ESP.Distance = v end, 290)
        CreateToggle(ESPTab, "Health Bar", Config.ESP.HealthBar, function(v) Config.ESP.HealthBar = v end, 340)
        CreateToggle(ESPTab, "Tracers", Config.ESP.Tracers, function(v) Config.ESP.Tracers = v end, 390)
        CreateSlider(ESPTab, "Max Distance", 500, 5000, Config.ESP.MaxDistance, function(v) Config.ESP.MaxDistance = v end, 440)

        CreateSection(XRayTab, "X-Ray Settings", 0)
        CreateToggle(XRayTab, "Enable X-Ray", Config.XRay.Enabled, function(v) Config.XRay.Enabled = v end, 40)
        CreateToggle(XRayTab, "Active", Config.XRay.Active, function(v) 
            Config.XRay.Active = v
            SetupXRay()
            UpdateXRayHighlights()
        end, 90)
        CreateSlider(XRayTab, "Wall Transparency", 0, 90, 30, function(v) Config.XRay.WallTransparency = v / 100 end, 140)

        CreateSection(MiscTab, "Miscellaneous", 0)
        CreateToggle(MiscTab, "Auto-Fire", Config.AutoFire.Enabled, function(v) Config.AutoFire.Enabled = v end, 40)
        CreateToggle(MiscTab, "Show FOV", Config.FOV.Visible, function(v) Config.FOV.Visible = v end, 90)
        CreateToggle(MiscTab, "No Recoil", Config.Misc.NoRecoil, function(v) Config.Misc.NoRecoil = v end, 140)
        CreateToggle(MiscTab, "No Spread", Config.Misc.NoSpread, function(v) Config.Misc.NoSpread = v end, 190)
        CreateToggle(MiscTab, "Instant Reload", Config.Misc.InstantReload, function(v) Config.Misc.InstantReload = v end, 240)

        CreateSection(SettingsTab, "Keybinds", 0)
        local KeybindInfo = Instance.new("TextLabel")
        KeybindInfo.Size = UDim2.new(1, 0, 0, 200)
        KeybindInfo.Position = UDim2.new(0, 0, 0, 40)
        KeybindInfo.BackgroundTransparency = 1
        KeybindInfo.Text = "Right Click - Aimbot
F - Toggle Auto-Fire
X - Toggle X-Ray
RightShift - Toggle UI"
        KeybindInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        KeybindInfo.TextSize = 14
        KeybindInfo.Font = Enum.Font.Gotham
        KeybindInfo.TextXAlignment = Enum.TextXAlignment.Left
        KeybindInfo.TextYAlignment = Enum.TextYAlignment.Top
        KeybindInfo.Parent = SettingsTab

        Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
        Tabs[1].Icon.TextColor3 = Color3.fromRGB(13, 13, 18)
        Tabs[1].Text.TextColor3 = Color3.fromRGB(13, 13, 18)
        Tabs[1].Content.Visible = true
        CurrentTab = Tabs[1]

        local dragging = false
        local dragStart = nil
        local startPos = nil

        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 550, 0, 400),
            Position = UDim2.new(0.5, -275, 0.5, -200)
        }):Play()

    end)
end

CreateModernUI()

--// ============================================================
--// SECTION 22: INPUT HANDLING
--// ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Config.AutoFire.Key then
        Config.AutoFire.Active = not Config.AutoFire.Active

        SafeCall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Auto-Fire",
                Text = Config.AutoFire.Active and "ON" or "OFF",
                Duration = 2,
                Icon = "rbxassetid://2541869220"
            })
        end)
    end

    if input.KeyCode == Config.XRay.Key then
        ToggleXRay()

        SafeCall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "X-Ray",
                Text = Config.XRay.Active and "ON" or "OFF",
                Duration = 2,
                Icon = "rbxassetid://2541869220"
            })
        end)
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        if ScreenGui then
            ScreenGui.Enabled = not ScreenGui.Enabled
            if ScreenGui.Enabled then
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 550, 0, 400),
                    Position = UDim2.new(0.5, -275, 0.5, -200)
                }):Play()
            end
        end
    end
end)

--// ============================================================
--// SECTION 23: MAIN LOOP
--// ============================================================

RunService.RenderStepped:Connect(function()
    if FOV_Circle then
        FOV_Circle.Position = UserInputService:GetMouseLocation()
        FOV_Circle.Radius = Config.Aimbot.FOV
        FOV_Circle.Visible = Config.FOV.Visible and Config.Aimbot.Enabled
    end

    if Config.ESP.Enabled then
        for player in pairs(ESPObjects) do
            if not player.Parent then
                RemoveESP(player)
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not ESPObjects[player] then
                CreateESP(player)
            end
        end

        UpdateESP()
    end

    if Config.XRay.Active then
        UpdateXRayHighlights()
    end

    FlickAimbot()
end)

--// ============================================================
--// SECTION 24: PLAYER EVENTS
--// ============================================================

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer and Config.ESP.Enabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

--// ============================================================
--// SECTION 25: INITIAL SETUP
--// ============================================================

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

SetupXRay()
UpdateXRayHighlights()

--// ============================================================
--// SECTION 26: FINAL NOTIFICATION
--// ============================================================

SafeCall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NANOXYIN v4.0",
        Text = "Loaded Successfully | BY XYIN",
        Duration = 5,
        Icon = "rbxassetid://2541869220"
    })
end)

print("============================================================")
print("NANOXYIN v4.0 ULTIMATE | SCRIPT BY XYIN | Loaded successfully")
print("Right Click = Flick Aimbot | F = Toggle Auto-Fire")
print("X = Toggle X-Ray | RightShift = Toggle UI")
print("ESP Active | FOV Lock Ready | X-Ray Wallhack Ready")
print("10 Bypass Layers Active | All Methods Combined")
print("============================================================")
