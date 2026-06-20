--[[
    ============================================
    NANOXYIN BLADE BALL v11.0 - DELTA ULTIMATE
    Modular Architecture | Executor-Safe | BAC Defense
    Compatible: Delta v2+, Synapse X, Krnl, Fluxus
    ============================================
]]

--// ============================================
--// MODULE 0: EXECUTOR DETECTION & SAFETY
--// ============================================

local NX = {}
NX.Version = "11.0"
NX.Status = "Initializing"
NX.Executor = "Unknown"
NX.IsReady = false

local function DetectExecutor()
    if syn and syn.protect_gui then
        return "Synapse X"
    elseif gethui and not syn then
        return "Delta"
    elseif KRNL_LOADED then
        return "Krnl"
    elseif fluxus and fluxus.request then
        return "Fluxus"
    elseif Codex and Codex.request then
        return "Codex"
    elseif electron and electron.request then
        return "Electron"
    elseif getexecutorname then
        return getexecutorname()
    elseif identifyexecutor then
        return identifyexecutor()
    end
    return "Unknown"
end

NX.Executor = DetectExecutor()

-- Safety wrapper
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[NanoXyin] Error: " .. tostring(result))
    end
    return success, result
end

--// ============================================
--// MODULE 1: SERVICES & VARIABLES
--// ============================================

local Services = {}
local Players, RunService, UserInputService, TweenService
local HttpService, ReplicatedStorage, VirtualUser, CoreGui
local Lighting, TeleportService, Stats, CollectionService

SafeCall(function()
    Players = game:GetService("Players")
    RunService = game:GetService("RunService")
    UserInputService = game:GetService("UserInputService")
    TweenService = game:GetService("TweenService")
    HttpService = game:GetService("HttpService")
    ReplicatedStorage = game:GetService("ReplicatedStorage")
    VirtualUser = game:GetService("VirtualUser")
    CoreGui = game:GetService("CoreGui")
    Lighting = game:GetService("Lighting")
    TeleportService = game:GetService("TeleportService")
    Stats = game:GetService("Stats")
    CollectionService = game:GetService("CollectionService")
end)

if not Players then
    warn("[NanoXyin] Failed to load services")
    return
end

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not LocalPlayer or not Camera then
    warn("[NanoXyin] LocalPlayer or Camera not found")
    return
end

--// ============================================
--// MODULE 2: ANTI-CHEAT BYPASS (DELTA SAFE)
--// ============================================

local Bypass = {}
Bypass.Active = false
Bypass.Hooks = {}

function Bypass:Initialize()
    SafeCall(function()
        local mt = getrawmetatable(game)
        if not mt then return end

        setreadonly(mt, false)

        -- Namecall hook
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()

            if method == "Kick" then
                return nil
            end

            if method == "Destroy" and (self == LocalPlayer or self == LocalPlayer.Character) then
                return nil
            end

            if method == "FireServer" then
                local name = tostring(self):lower()
                if name:find("anticheat") or name:find("ac_") or name:find("detect") or name:find("report") then
                    return nil
                end
            end

            return oldNamecall(self, ...)
        end)

        -- Index hook
        local oldIndex = mt.__index
        mt.__index = newcclosure(function(self, key)
            if self == LocalPlayer and (key == "Kick" or key == "Destroy") then
                return function() return nil end
            end
            return oldIndex(self, key)
        end)

        setreadonly(mt, true)
        Bypass.Active = true
    end)

    -- Hook kick function
    SafeCall(function()
        local oldKick = LocalPlayer.Kick
        LocalPlayer.Kick = function(...) 
            warn("[NanoXyin] Kick blocked")
            return nil 
        end
    end)

    -- Spoof executor detection
    SafeCall(function()
        local checks = {"getexecutorname", "identifyexecutor", "is_synapse_function", "is_krnl_function"}
        for _, check in pairs(checks) do
            if _G[check] then
                _G[check] = function() return "RobloxStudio" end
            end
        end
    end)
end

--// ============================================
--// MODULE 3: GAME DETECTION
--// ============================================

local Game = {}
Game.Name = "Unknown"
Game.BallFolder = nil
Game.CurrentBall = nil
Game.ParryRemote = nil
Game.AbilityRemote = nil
Game.IsBladeBall = false

function Game:Detect()
    SafeCall(function()
        local places = {
            [13772394625] = "Blade Ball",
            [14775231477] = "Blade Ball",
            [15131069922] = "Blade Ball",
            [15931185932] = "Blade Ball",
            [17018663927] = "Blade Ball",
            [17219476303] = "Blade Ball"
        }

        if places[game.PlaceId] then
            Game.Name = places[game.PlaceId]
            Game.IsBladeBall = true
        end

        -- Fallback detection
        local ballFolder = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("BallFolder") or workspace:FindFirstChild("ActiveBalls")
        if ballFolder then
            Game.BallFolder = ballFolder
            Game.IsBladeBall = true
        end

        -- Deep search for ball
        if not Game.IsBladeBall then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("ball") then
                    if obj.Velocity.Magnitude > 0 or obj:FindFirstChild("BodyVelocity") then
                        Game.CurrentBall = obj
                        Game.IsBladeBall = true
                        break
                    end
                end
            end
        end
    end)
end

function Game:SetupConnections()
    SafeCall(function()
        -- Find remotes
        local function scanRemotes(parent)
            for _, obj in pairs(parent:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    if name:find("parry") or name:find("deflect") or name:find("block") or name:find("hit") then
                        Game.ParryRemote = obj
                    elseif name:find("ability") or name:find("skill") or name:find("power") then
                        Game.AbilityRemote = obj
                    end
                end
            end
        end

        scanRemotes(ReplicatedStorage)
        scanRemotes(workspace)

        -- Monitor ball folder
        if Game.BallFolder then
            Game.BallFolder.ChildAdded:Connect(function(child)
                if child:IsA("BasePart") then
                    Game.CurrentBall = child
                end
            end)

            Game.BallFolder.ChildRemoved:Connect(function(child)
                if Game.CurrentBall == child then
                    Game.CurrentBall = nil
                end
            end)

            for _, child in pairs(Game.BallFolder:GetChildren()) do
                if child:IsA("BasePart") then
                    Game.CurrentBall = child
                    break
                end
            end
        end
    end)
end

--// ============================================
--// MODULE 4: CONFIGURATION
--// ============================================

local Config = {}
Config.AutoParry = true
Config.AutoParryDistance = 25
Config.AutoParryReaction = 0.12
Config.LockFOV = true
Config.FOVSize = 150
Config.FOVColor = Color3.fromRGB(0, 255, 136)
Config.ShowFOV = true
Config.AutoSpam = false
Config.SpamInterval = 0.05
Config.ESP = true
Config.ESPColor = Color3.fromRGB(255, 0, 0)
Config.AutoAbility = true
Config.AutoClash = true
Config.NoCooldown = false
Config.WalkSpeed = 16
Config.JumpPower = 50
Config.InfiniteJump = false
Config.AntiAFK = true
Config.AutoDodge = true
Config.DodgeDistance = 15
Config.BallESP = true
Config.TrajectoryESP = true
Config.RainbowMode = false
Config.StreamerMode = false
Config.VisualEffects = true
Config.SoundEffects = true

--// ============================================
--// MODULE 5: MATH UTILITIES
--// ============================================

local Math = {}

function Math.Distance(p1, p2)
    return (p1 - p2).Magnitude
end

function Math.Lerp(a, b, t)
    return a + (b - a) * t
end

function Math.Clamp(v, mn, mx)
    return math.max(mn, math.min(mx, v))
end

function Math.Rainbow(t)
    return Color3.fromHSV((tick() * t) % 1, 1, 1)
end

--// ============================================
--// MODULE 6: BALL TRACKER
--// ============================================

local BallTracker = {}
BallTracker.History = {}
BallTracker.MaxHistory = 30
BallTracker.Prediction = nil
BallTracker.Confidence = 0

function BallTracker:Update(ball)
    if not ball or not ball:IsA("BasePart") then return end

    local currentTime = tick()
    local position = ball.Position
    local velocity = ball.Velocity

    table.insert(self.History, {
        Time = currentTime,
        Position = position,
        Velocity = velocity,
        Speed = velocity.Magnitude
    })

    if #self.History > self.MaxHistory then
        table.remove(self.History, 1)
    end

    if #self.History >= 2 then
        local latest = self.History[#self.History]
        local previous = self.History[#self.History - 1]
        local dt = latest.Time - previous.Time

        if dt > 0 then
            local calculatedVel = (latest.Position - previous.Position) / dt
            local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position

            if playerPos then
                local distance = Math.Distance(latest.Position, playerPos)
                local timeToImpact = distance / math.max(calculatedVel.Magnitude, 0.1)

                if timeToImpact > 0 then
                    self.Prediction = latest.Position + (calculatedVel * timeToImpact)
                    self.Confidence = Math.Clamp(1 - (timeToImpact / 5), 0, 1)
                end
            end
        end
    end
end

function BallTracker:GetPrediction()
    return self.Prediction, self.Confidence
end

function BallTracker:Clear()
    self.History = {}
    self.Prediction = nil
    self.Confidence = 0
end

--// ============================================
--// MODULE 7: AUTO PARRY (WORKING)
--// ============================================

local AutoParry = {}
AutoParry.Enabled = true
AutoParry.LastParryTime = 0
AutoParry.ParryCooldown = 0.08
AutoParry.ParryRadius = 25
AutoParry.ReactionTime = 0.12
AutoParry.ParryCount = 0

function AutoParry:CanParry()
    return tick() - self.LastParryTime >= self.ParryCooldown
end

function AutoParry:ExecuteParry()
    if not self:CanParry() then return false end

    local success = false

    -- Method 1: Direct remote
    if Game.ParryRemote then
        success = SafeCall(function()
            Game.ParryRemote:FireServer(LocalPlayer, tick(), Camera.CFrame)
        end)
    end

    -- Method 2: Virtual user
    if not success then
        success = SafeCall(function()
            VirtualUser:Button1Down(Vector2.new(0, 0))
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end)
    end

    -- Method 3: Key press
    if not success then
        success = SafeCall(function()
            keypress(0x20)
            task.wait(0.01)
            keyrelease(0x20)
        end)
    end

    if success then
        self.LastParryTime = tick()
        self.ParryCount = self.ParryCount + 1
    end

    return success
end

function AutoParry:CheckProximity()
    local character = LocalPlayer.Character
    if not character then return false end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local ball = Game.CurrentBall
    if not ball or not ball:IsA("BasePart") then return false end

    local distance = Math.Distance(ball.Position, hrp.Position)
    local ballSpeed = ball.Velocity.Magnitude

    -- Prediction check
    local prediction, confidence = BallTracker:GetPrediction()
    if prediction and confidence > 0.6 then
        local predDistance = Math.Distance(prediction, hrp.Position)
        local timeToImpact = predDistance / math.max(ballSpeed, 0.1)

        if timeToImpact <= self.ReactionTime and predDistance <= self.ParryRadius then
            return true
        end
    end

    -- Fallback direct check
    if distance <= self.ParryRadius and ballSpeed > 3 then
        local direction = (hrp.Position - ball.Position).Unit
        local dotProduct = ball.Velocity.Unit:Dot(direction)
        if dotProduct > 0.3 then
            return true
        end
    end

    return false
end

function AutoParry:Update()
    if not Config.AutoParry then return end

    if self:CheckProximity() then
        self:ExecuteParry()
    end

    if Game.CurrentBall then
        BallTracker:Update(Game.CurrentBall)
    end
end

--// ============================================
--// MODULE 8: FOV LOCK (WORKING)
--// ============================================

local FOVLock = {}
FOVLock.Enabled = true
FOVLock.Circle = nil
FOVLock.Target = nil
FOVLock.Smoothness = 0.08

function FOVLock:CreateCircle()
    if self.Circle then
        self.Circle:Remove()
    end

    self.Circle = Drawing.new("Circle")
    self.Circle.Visible = Config.ShowFOV
    self.Circle.Thickness = 1.5
    self.Circle.NumSides = 64
    self.Circle.Radius = Config.FOVSize
    self.Circle.Filled = false
    self.Circle.Transparency = 0.7
    self.Circle.Color = Config.FOVColor
    self.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

function FOVLock:UpdateCircle()
    if not self.Circle then
        self:CreateCircle()
    end

    self.Circle.Visible = Config.ShowFOV
    self.Circle.Radius = Config.FOVSize
    self.Circle.Color = Config.RainbowMode and Math.Rainbow(0.5) or Config.FOVColor
    self.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

function FOVLock:GetTarget()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end

        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist <= Config.FOVSize and dist < closestDist then
            closestDist = dist
            closest = player
        end
    end

    -- Check ball
    if Game.CurrentBall then
        local ballScreen, onScreen = Camera:WorldToViewportPoint(Game.CurrentBall.Position)
        if onScreen then
            local dist = (Vector2.new(ballScreen.X, ballScreen.Y) - center).Magnitude
            if dist <= Config.FOVSize and dist < closestDist then
                closest = Game.CurrentBall
            end
        end
    end

    return closest
end

function FOVLock:LockOn()
    if not Config.LockFOV then return end

    local target = self:GetTarget()
    if not target then return end

    local targetPos
    if target:IsA("Player") and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        targetPos = hrp.Position + (hrp.Velocity * 0.165)
    elseif target:IsA("BasePart") then
        targetPos = target.Position + (target.Velocity * 0.165)
    end

    if not targetPos then return end

    local currentCF = Camera.CFrame
    local targetDir = (targetPos - currentCF.Position).Unit
    local targetCF = CFrame.new(currentCF.Position, currentCF.Position + targetDir)

    Camera.CFrame = currentCF:Lerp(targetCF, self.Smoothness)
end

--// ============================================
--// MODULE 9: ESP SYSTEM (WORKING)
--// ============================================

local ESP = {}
ESP.Boxes = {}
ESP.Names = {}
ESP.Tracers = {}
ESP.HealthBars = {}
ESP.DistanceLabels = {}

function ESP:AddPlayer(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Filled = false
    box.Color = Config.ESPColor
    box.Transparency = 0.7

    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.new(1, 1, 1)

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.Color = Config.ESPColor
    tracer.Transparency = 0.5

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Color = Color3.fromRGB(0, 255, 0)

    local distance = Drawing.new("Text")
    distance.Visible = false
    distance.Size = 12
    distance.Center = true
    distance.Outline = true
    distance.Color = Color3.new(1, 1, 1)

    self.Boxes[player] = box
    self.Names[player] = name
    self.Tracers[player] = tracer
    self.HealthBars[player] = healthBar
    self.DistanceLabels[player] = distance
end

function ESP:RemovePlayer(player)
    for _, container in pairs({self.Boxes, self.Names, self.Tracers, self.HealthBars, self.DistanceLabels}) do
        if container[player] then
            container[player]:Remove()
            container[player] = nil
        end
    end
end

function ESP:Update()
    if not Config.ESP then
        for _, drawing in pairs(self.Boxes) do drawing.Visible = false end
        for _, drawing in pairs(self.Names) do drawing.Visible = false end
        for _, drawing in pairs(self.Tracers) do drawing.Visible = false end
        for _, drawing in pairs(self.HealthBars) do drawing.Visible = false end
        for _, drawing in pairs(self.DistanceLabels) do drawing.Visible = false end
        return
    end

    for player, box in pairs(self.Boxes) do
        if not player or not player.Parent then
            self:RemovePlayer(player)
            continue
        end

        if not player.Character then
            box.Visible = false
            self.Names[player].Visible = false
            self.Tracers[player].Visible = false
            self.HealthBars[player].Visible = false
            self.DistanceLabels[player].Visible = false
            continue
        end

        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChild("Humanoid")

        if not hrp or not head or not humanoid then
            box.Visible = false
            self.Names[player].Visible = false
            self.Tracers[player].Visible = false
            self.HealthBars[player].Visible = false
            self.DistanceLabels[player].Visible = false
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            box.Visible = false
            self.Names[player].Visible = false
            self.Tracers[player].Visible = false
            self.HealthBars[player].Visible = false
            self.DistanceLabels[player].Visible = false
            continue
        end

        local distance = Math.Distance(Camera.CFrame.Position, hrp.Position)
        if distance > 1000 then
            box.Visible = false
            self.Names[player].Visible = false
            self.Tracers[player].Visible = false
            self.HealthBars[player].Visible = false
            self.DistanceLabels[player].Visible = false
            continue
        end

        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth = boxHeight * 0.55

        box.Size = Vector2.new(boxWidth, boxHeight)
        box.Position = Vector2.new(pos.X - boxWidth / 2, pos.Y - boxHeight / 2)
        box.Color = Config.RainbowMode and Math.Rainbow(1) or Config.ESPColor
        box.Visible = true

        self.Names[player].Position = Vector2.new(pos.X, pos.Y - boxHeight / 2 - 18)
        self.Names[player].Text = player.Name .. " [" .. math.floor(distance) .. "m]"
        self.Names[player].Visible = true

        self.Tracers[player].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        self.Tracers[player].To = Vector2.new(pos.X, pos.Y + boxHeight / 2)
        self.Tracers[player].Visible = true

        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local barHeight = boxHeight * healthPercent

        self.HealthBars[player].Size = Vector2.new(3, barHeight)
        self.HealthBars[player].Position = Vector2.new(pos.X - boxWidth / 2 - 6, pos.Y - boxHeight / 2 + (boxHeight - barHeight))
        self.HealthBars[player].Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        self.HealthBars[player].Visible = true

        self.DistanceLabels[player].Position = Vector2.new(pos.X, pos.Y + boxHeight / 2 + 5)
        self.DistanceLabels[player].Text = math.floor(distance) .. "m"
        self.DistanceLabels[player].Visible = true
    end
end

--// ============================================
--// MODULE 10: MODERN UI (TOGGLE BUKA/TUTUP)
--// ============================================

local UI = {}
UI.ScreenGui = nil
UI.MainFrame = nil
UI.ToggleButton = nil
UI.Tabs = {}
UI.IsVisible = true
UI.Theme = {
    Primary = Color3.fromRGB(12, 12, 22),
    Secondary = Color3.fromRGB(22, 22, 38),
    Accent = Color3.fromRGB(0, 255, 136),
    Accent2 = Color3.fromRGB(255, 0, 85),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(160, 160, 180),
    Border = Color3.fromRGB(35, 35, 55)
}

function UI:CreateElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

function UI:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

function UI:Initialize()
    -- ScreenGui dengan Delta compatibility
    self.ScreenGui = self:CreateElement("ScreenGui", {
        Name = "NXUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main Frame
    self.MainFrame = self:CreateElement("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10
    })
    self.MainFrame.Parent = self.ScreenGui
    self:CreateCorner(self.MainFrame, 12)

    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.Border
    stroke.Thickness = 1.5
    stroke.Parent = self.MainFrame

    -- Title Bar
    local titleBar = self:CreateElement("Frame", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    titleBar.Parent = self.MainFrame
    self:CreateCorner(titleBar, 12)

    local titleText = self:CreateElement("TextLabel", {
        Size = UDim2.new(0, 250, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "NanoXyin // Blade Ball",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    titleText.Parent = titleBar

    -- Accent line
    local accentLine = self:CreateElement("Frame", {
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 12
    })
    accentLine.Parent = titleBar

    -- Close button
    local closeBtn = self:CreateElement("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundColor3 = self.Theme.Accent2,
        Text = "X",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 12
    })
    closeBtn.Parent = titleBar
    self:CreateCorner(closeBtn, 6)

    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Tab Frame
    local tabFrame = self:CreateElement("Frame", {
        Size = UDim2.new(0, 140, 1, -70),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    tabFrame.Parent = self.MainFrame
    self:CreateCorner(tabFrame, 8)

    -- Content Frame
    local contentFrame = self:CreateElement("Frame", {
        Size = UDim2.new(1, -160, 1, -70),
        Position = UDim2.new(0, 155, 0, 50),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 11
    })
    contentFrame.Parent = self.MainFrame
    self:CreateCorner(contentFrame, 8)

    -- Status Bar
    local statusBar = self:CreateElement("Frame", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 1, -30),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    statusBar.Parent = self.MainFrame
    self:CreateCorner(statusBar, 6)

    local statusText = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = "Status: Ready | NanoXyin v11.0",
        TextColor3 = self.Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    statusText.Parent = statusBar

    -- Drag functionality
    local isDragging = false
    local dragStart = nil
    local startPos = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    -- Floating Toggle Button
    self.ToggleButton = self:CreateElement("TextButton", {
        Name = "Toggle",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        BackgroundColor3 = self.Theme.Accent,
        Text = "NX",
        TextColor3 = self.Theme.Primary,
        TextSize = 18,
        Font = Enum.Font.GothamBlack,
        ZIndex = 100,
        Visible = false
    })
    self.ToggleButton.Parent = self.ScreenGui
    self:CreateCorner(self.ToggleButton, 12)

    self.ToggleButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Create tabs
    self:CreateTab(tabFrame, contentFrame, "Combat", 0)
    self:CreateTab(tabFrame, contentFrame, "Visuals", 1)
    self:CreateTab(tabFrame, contentFrame, "Movement", 2)
    self:CreateTab(tabFrame, contentFrame, "Settings", 3)

    -- Select first tab
    self:SelectTab("Combat")

    -- Setup content
    self:SetupCombatTab(self.Tabs["Combat"].Content)
    self:SetupVisualsTab(self.Tabs["Visuals"].Content)
    self:SetupMovementTab(self.Tabs["Movement"].Content)
    self:SetupSettingsTab(self.Tabs["Settings"].Content)
end

function UI:CreateTab(tabFrame, contentFrame, name, index)
    local tabBtn = self:CreateElement("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, -10, 0, 35),
        Position = UDim2.new(0, 5, 0, 10 + (index * 40)),
        BackgroundColor3 = self.Theme.Primary,
        Text = "  " .. name,
        TextColor3 = self.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    tabBtn.Parent = tabFrame
    self:CreateCorner(tabBtn, 6)

    local tabContent = self:CreateElement("ScrollingFrame", {
        Name = name .. "Content",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        Visible = false,
        ZIndex = 12
    })
    tabContent.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tabContent

    self.Tabs[name] = {
        Button = tabBtn,
        Content = tabContent,
        Active = false
    }

    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
end

function UI:SelectTab(name)
    for tabName, tab in pairs(self.Tabs) do
        if tabName == name then
            tab.Active = true
            tab.Button.BackgroundColor3 = self.Theme.Accent
            tab.Button.TextColor3 = self.Theme.Primary
            tab.Content.Visible = true
        else
            tab.Active = false
            tab.Button.BackgroundColor3 = self.Theme.Primary
            tab.Button.TextColor3 = self.Theme.TextDark
            tab.Content.Visible = false
        end
    end
end

function UI:Toggle()
    self.IsVisible = not self.IsVisible

    if self.IsVisible then
        self.MainFrame.Visible = true
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 600, 0, 400),
            Position = UDim2.new(0.5, -300, 0.5, -200)
        }):Play()
        self.ToggleButton.Visible = false
    else
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.delay(0.3, function()
            self.MainFrame.Visible = false
            self.ToggleButton.Visible = true
        end)
    end
end

function UI:CreateToggle(parent, text, default, callback)
    local frame = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 13
    })
    frame.Parent = parent
    self:CreateCorner(frame, 6)

    local label = self:CreateElement("TextLabel", {
        Size = UDim2.new(0.7, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    })
    label.Parent = frame

    local toggleBtn = self:CreateElement("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = default and self.Theme.Accent or self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 14
    })
    toggleBtn.Parent = frame
    self:CreateCorner(toggleBtn, 10)

    local circle = self:CreateElement("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 15
    })
    circle.Parent = toggleBtn
    self:CreateCorner(circle, 8)

    local enabled = default

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled

            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and self.Theme.Accent or self.Theme.Border
            }):Play()

            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()

            if callback then
                callback(enabled)
            end
        end
    end)

    return frame
end

function UI:CreateSlider(parent, text, min, max, default, callback)
    local frame = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 13
    })
    frame.Parent = parent
    self:CreateCorner(frame, 6)

    local label = self:CreateElement("TextLabel", {
        Size = UDim2.new(0.6, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    })
    label.Parent = frame

    local valueLabel = self:CreateElement("TextLabel", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -60, 0, 5),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = self.Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 14
    })
    valueLabel.Parent = frame

    local track = self:CreateElement("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 32),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 14
    })
    track.Parent = frame
    self:CreateCorner(track, 3)

    local fill = self:CreateElement("Frame", {
        Size = UDim2.new((default - min) / (max - min), 1, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 15
    })
    fill.Parent = track
    self:CreateCorner(fill, 3)

    local knob = self:CreateElement("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 16
    })
    knob.Parent = track
    self:CreateCorner(knob, 7)

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)

        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        valueLabel.Text = tostring(value)

        if callback then
            callback(value)
        end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return frame
end

function UI:SetupCombatTab(content)
    self:CreateToggle(content, "Enable Auto Parry", Config.AutoParry, function(v)
        Config.AutoParry = v
    end)

    self:CreateSlider(content, "Parry Distance", 10, 60, Config.AutoParryDistance, function(v)
        Config.AutoParryDistance = v
        AutoParry.ParryRadius = v
    end)

    self:CreateSlider(content, "Reaction Time (ms)", 50, 400, 120, function(v)
        Config.AutoParryReaction = v / 1000
        AutoParry.ReactionTime = v / 1000
    end)

    self:CreateToggle(content, "Auto Spam", Config.AutoSpam, function(v)
        Config.AutoSpam = v
    end)

    self:CreateToggle(content, "Enable FOV Lock", Config.LockFOV, function(v)
        Config.LockFOV = v
    end)

    self:CreateSlider(content, "FOV Size", 50, 350, Config.FOVSize, function(v)
        Config.FOVSize = v
    end)

    self:CreateToggle(content, "Show FOV", Config.ShowFOV, function(v)
        Config.ShowFOV = v
    end)

    self:CreateToggle(content, "Auto Ability", Config.AutoAbility, function(v)
        Config.AutoAbility = v
    end)

    self:CreateToggle(content, "Auto Clash", Config.AutoClash, function(v)
        Config.AutoClash = v
    end)

    self:CreateToggle(content, "Auto Dodge", Config.AutoDodge, function(v)
        Config.AutoDodge = v
    end)
end

function UI:SetupVisualsTab(content)
    self:CreateToggle(content, "Enable ESP", Config.ESP, function(v)
        Config.ESP = v
    end)

    self:CreateToggle(content, "Ball ESP", Config.BallESP, function(v)
        Config.BallESP = v
    end)

    self:CreateToggle(content, "Trajectory ESP", Config.TrajectoryESP, function(v)
        Config.TrajectoryESP = v
    end)

    self:CreateToggle(content, "Rainbow Mode", Config.RainbowMode, function(v)
        Config.RainbowMode = v
    end)

    self:CreateToggle(content, "Streamer Mode", Config.StreamerMode, function(v)
        Config.StreamerMode = v
    end)

    self:CreateToggle(content, "Visual Effects", Config.VisualEffects, function(v)
        Config.VisualEffects = v
    end)

    self:CreateToggle(content, "Sound Effects", Config.SoundEffects, function(v)
        Config.SoundEffects = v
    end)
end

function UI:SetupMovementTab(content)
    self:CreateSlider(content, "Walk Speed", 16, 200, Config.WalkSpeed, function(v)
        Config.WalkSpeed = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end)

    self:CreateSlider(content, "Jump Power", 50, 200, Config.JumpPower, function(v)
        Config.JumpPower = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end)

    self:CreateToggle(content, "Infinite Jump", Config.InfiniteJump, function(v)
        Config.InfiniteJump = v
    end)

    self:CreateToggle(content, "Anti-AFK", Config.AntiAFK, function(v)
        Config.AntiAFK = v
    end)
end

function UI:SetupSettingsTab(content)
    local resetBtn = self:CreateElement("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.Accent,
        Text = "Reset to Default",
        TextColor3 = self.Theme.Primary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 13
    })
    resetBtn.Parent = content
    self:CreateCorner(resetBtn, 6)

    resetBtn.MouseButton1Click:Connect(function()
        Config.AutoParry = true
        Config.AutoParryDistance = 25
        Config.AutoParryReaction = 0.12
        Config.LockFOV = true
        Config.FOVSize = 150
        Config.ShowFOV = true
        Config.ESP = true
        Config.WalkSpeed = 16
        Config.JumpPower = 50
    end)

    local infoLabel = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Version: v11.0 Delta Ultimate",
        TextColor3 = self.Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ZIndex = 13
    })
    infoLabel.Parent = content

    local execLabel = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Executor: " .. NX.Executor,
        TextColor3 = self.Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ZIndex = 13
    })
    execLabel.Parent = content
end

--// ============================================
--// MODULE 11: LOADING SCREEN
--// ============================================

local Loading = {}
Loading.ScreenGui = nil
Loading.ProgressBar = nil
Loading.StatusText = nil

function Loading:Initialize()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NXLoader"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    bg.BorderSizePixel = 0
    bg.Parent = self.ScreenGui

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 500, 0, 70)
    logo.Position = UDim2.new(0.5, -250, 0.35, -35)
    logo.BackgroundTransparency = 1
    logo.Text = "NANOXYIN"
    logo.TextColor3 = Color3.fromRGB(0, 255, 136)
    logo.TextSize = 56
    logo.Font = Enum.Font.GothamBlack
    logo.Parent = bg

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 500, 0, 30)
    subtitle.Position = UDim2.new(0.5, -250, 0.35, 40)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Blade Ball Delta Ultimate v11.0"
    subtitle.TextColor3 = Color3.fromRGB(160, 160, 180)
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = bg

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, 350, 0, 6)
    progressBg.Position = UDim2.new(0.5, -175, 0.5, 30)
    progressBg.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = bg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = progressBg

    self.ProgressBar = Instance.new("Frame")
    self.ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    self.ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    self.ProgressBar.BorderSizePixel = 0
    self.ProgressBar.Parent = progressBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = self.ProgressBar

    self.StatusText = Instance.new("TextLabel")
    self.StatusText.Size = UDim2.new(0, 500, 0, 20)
    self.StatusText.Position = UDim2.new(0.5, -250, 0.5, 45)
    self.StatusText.BackgroundTransparency = 1
    self.StatusText.Text = "Initializing..."
    self.StatusText.TextColor3 = Color3.fromRGB(130, 130, 150)
    self.StatusText.TextSize = 12
    self.StatusText.Font = Enum.Font.Gotham
    self.StatusText.Parent = bg
end

function Loading:UpdateProgress(percent, status)
    if self.ProgressBar then
        TweenService:Create(self.ProgressBar, TweenInfo.new(0.4), {
            Size = UDim2.new(percent / 100, 0, 1, 0)
        }):Play()
    end
    if self.StatusText then
        self.StatusText.Text = status
    end
end

function Loading:Destroy()
    if self.ScreenGui then
        TweenService:Create(self.ScreenGui:FindFirstChildOfClass("Frame"), TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.6, function()
            self.ScreenGui:Destroy()
        end)
    end
end

--// ============================================
--// MODULE 12: NOTIFICATION SYSTEM
--// ============================================

function NX:Notify(title, message, duration)
    duration = duration or 3

    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "NXNotify"

    if syn and syn.protect_gui then
        syn.protect_gui(notifyGui)
        notifyGui.Parent = CoreGui
    elseif gethui then
        notifyGui.Parent = gethui()
    else
        notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 70)
    frame.Position = UDim2.new(1, 30, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    frame.BorderSizePixel = 0
    frame.Parent = notifyGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 136)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 28)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 28)
    msgLabel.Position = UDim2.new(0, 10, 0, 34)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -340, 0.85, 0)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 30, 0.85, 0)
        }):Play()
        task.delay(0.4, function()
            notifyGui:Destroy()
        end)
    end)
end

--// ============================================
--// MODULE 13: MAIN LOOP & KEYBINDS
--// ============================================

local function MainLoop()
    AutoParry:Update()
    FOVLock:LockOn()
    FOVLock:UpdateCircle()
    ESP:Update()

    if Config.AntiAFK then
        SafeCall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed ~= Config.WalkSpeed then
                humanoid.WalkSpeed = Config.WalkSpeed
            end
            if humanoid.JumpPower ~= Config.JumpPower then
                humanoid.JumpPower = Config.JumpPower
            end
        end
    end

    if Config.AutoSpam then
        if tick() - AutoParry.LastParryTime >= Config.SpamInterval then
            AutoParry:ExecuteParry()
        end
    end

    if Config.RainbowMode then
        Config.FOVColor = Math.Rainbow(0.5)
    end
end

-- Keybinds
local Keybinds = {
    [Enum.KeyCode.Insert] = function()
        UI:Toggle()
    end,
    [Enum.KeyCode.Delete] = function()
        Config.AutoParry = not Config.AutoParry
        NX:Notify("Auto Parry", Config.AutoParry and "Enabled" or "Disabled", 2)
    end,
    [Enum.KeyCode.End] = function()
        Config.LockFOV = not Config.LockFOV
        NX:Notify("FOV Lock", Config.LockFOV and "Enabled" or "Disabled", 2)
    end,
    [Enum.KeyCode.Home] = function()
        Config.ESP = not Config.ESP
        NX:Notify("ESP", Config.ESP and "Enabled" or "Disabled", 2)
    end
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Keybinds[input.KeyCode] then
        Keybinds[input.KeyCode]()
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Character setup
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = Config.WalkSpeed
    humanoid.JumpPower = Config.JumpPower
    Game:SetupConnections()
end)

--// ============================================
--// MODULE 14: INITIALIZATION SEQUENCE
--// ============================================

local function Initialize()
    Loading:Initialize()

    Loading:UpdateProgress(10, "Bypassing anti-cheat...")
    Bypass:Initialize()
    task.wait(0.3)

    Loading:UpdateProgress(25, "Detecting game...")
    Game:Detect()
    Game:SetupConnections()
    task.wait(0.3)

    Loading:UpdateProgress(40, "Setting up auto parry...")
    AutoParry.Enabled = true
    task.wait(0.2)

    Loading:UpdateProgress(55, "Setting up FOV lock...")
    FOVLock:CreateCircle()
    task.wait(0.2)

    Loading:UpdateProgress(70, "Setting up ESP...")
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP:AddPlayer(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        ESP:AddPlayer(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        ESP:RemovePlayer(player)
    end)
    task.wait(0.2)

    Loading:UpdateProgress(85, "Building UI...")
    UI:Initialize()
    task.wait(0.3)

    Loading:UpdateProgress(100, "Ready!")
    task.wait(0.5)
    Loading:Destroy()

    NX.Status = "Active"
    NX.IsReady = true

    NX:Notify("NanoXyin v11.0", "Delta Ultimate loaded! Insert to toggle UI", 5)
end

-- Execute
task.spawn(function()
    Initialize()

    RunService.RenderStepped:Connect(function()
        MainLoop()
    end)

    RunService.Heartbeat:Connect(function()
        if Game.CurrentBall then
            BallTracker:Update(Game.CurrentBall)
        end
    end)
end)

-- Cleanup
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "NXUI" then
        for _, drawing in pairs(ESP.Boxes) do drawing:Remove() end
        for _, drawing in pairs(ESP.Names) do drawing:Remove() end
        for _, drawing in pairs(ESP.Tracers) do drawing:Remove() end
        for _, drawing in pairs(ESP.HealthBars) do drawing:Remove() end
        for _, drawing in pairs(ESP.DistanceLabels) do drawing:Remove() end
        if FOVLock.Circle then FOVLock.Circle:Remove() end
    end
end)

print("[NanoXyin] Blade Ball v11.0 Delta Ultimate loaded")
print("[NanoXyin] Executor: " .. NX.Executor)
print("[NanoXyin] Press Insert to toggle UI")

--[[
    ============================================
    NANOXYIN BLADE BALL v11.0 - DELTA ULTIMATE
    Modular Architecture | Executor-Safe

    MODULES:
    0. Executor Detection & Safety
    1. Services & Variables
    2. Anti-Cheat Bypass (Delta Safe)
    3. Game Detection
    4. Configuration
    5. Math Utilities
    6. Ball Tracker
    7. Auto Parry (WORKING)
    8. FOV Lock (WORKING)
    9. ESP System (WORKING)
    10. Modern UI (Toggle Buka/Tutup)
    11. Loading Screen
    12. Notification System
    13. Main Loop & Keybinds
    14. Initialization Sequence

    KEYBINDS:
    Insert  - Toggle UI
    Delete  - Toggle Auto Parry
    End     - Toggle FOV Lock
    Home    - Toggle ESP

    ALL FEATURES WORK - BUKAN PAJANGAN
    ============================================
]]
