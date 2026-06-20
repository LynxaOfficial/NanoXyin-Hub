--[[
    ============================================
    NANOXYIN BLADE BALL v13.0 - MESIN KERJA
    Hanya Fitur WORK & Sering Dipakai
    Toggle: Aktif = Hijau | Nonaktif = Merah
    ============================================
]]

--// ============================================
--// DEFENSE: NATIVE REPLACEMENT (NO HOOK)
--// ============================================

local _game = game
local _tick = tick
local _pcall = pcall
local _type = type
local _tostring = tostring
local _math = math
local _string = string
local _table = table
local _wait = task.wait
local _spawn = task.spawn
local _delay = task.delay

_math.randomseed(_tick() * 1000000)

-- Services
local Players = _game:GetService("Players")
local RunService = _game:GetService("RunService")
local UserInputService = _game:GetService("UserInputService")
local TweenService = _game:GetService("TweenService")
local ReplicatedStorage = _game:GetService("ReplicatedStorage")
local VirtualUser = _game:GetService("VirtualUser")
local CoreGui = _game:GetService("CoreGui")
local Stats = _game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not LocalPlayer or not Camera then return end

-- Anti-kick native replacement
LocalPlayer.Kick = function(self, ...)
    if self == LocalPlayer then return nil end
    return game.Players.LocalPlayer.Kick(self, ...)
end

-- Anti-destroy
LocalPlayer.Destroy = function(self, ...)
    if self == LocalPlayer then return nil end
    return Instance.new("Part").Destroy(self, ...)
end

-- Remote interception
local BlockedNames = {"anticheat", "ac_", "detect", "report", "log", "telemetry", "tracking", "ban", "kick"}

local function IsBlocked(name)
    name = name:lower()
    for _, blocked in ipairs(BlockedNames) do
        if string.find(name, blocked) then return true end
    end
    return false
end

_spawn(function()
    _wait(1)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local orig = obj.FireServer
            obj.FireServer = function(self, ...)
                if IsBlocked(tostring(self)) then return nil end
                return orig(self, ...)
            end
        elseif obj:IsA("RemoteFunction") then
            local orig = obj.InvokeServer
            obj.InvokeServer = function(self, ...)
                if IsBlocked(tostring(self)) then return nil end
                return orig(self, ...)
            end
        end
    end
end)

-- Executor spoof
local checks = {"getexecutorname", "identifyexecutor", "is_synapse_function", "is_krnl_function", "is_fluxus_function"}
for _, check in ipairs(checks) do
    if getfenv(0)[check] then
        getfenv(0)[check] = function() return "RobloxStudio" end
    end
end

-- GC manipulation
_spawn(function()
    while true do
        _wait(5)
        local gc = getgc and getgc() or {}
        for i = 1, math.min(#gc, 30) do
            local obj = gc[math.random(1, #gc)]
            if type(obj) == "function" then
                local info = debug.getinfo(obj)
                if info and info.source then
                    local src = info.source:lower()
                    if string.find(src, "anticheat") or string.find(src, "security") then
                        local upvalues = debug.getupvalues(obj)
                        for j = 1, #upvalues do
                            if type(upvalues[j]) == "boolean" then
                                pcall(function() debug.setupvalue(obj, j, false) end)
                            elseif type(upvalues[j]) == "number" then
                                pcall(function() debug.setupvalue(obj, j, 0) end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

--// ============================================
--// GAME DETECTION
--// ============================================

local GameData = {
    CurrentBall = nil,
    ParryRemote = nil,
    BallFolder = nil
}

local function DetectGame()
    local places = {[13772394625]=true,[14775231477]=true,[15131069922]=true,[15931185932]=true,[17018663927]=true,[17219476303]=true}

    local isBB = places[game.PlaceId] or false

    local bf = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("BallFolder") or workspace:FindFirstChild("ActiveBalls")
    if bf then
        GameData.BallFolder = bf
        isBB = true
    end

    if not isBB then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("ball") and obj.Velocity.Magnitude > 0 then
                GameData.CurrentBall = obj
                isBB = true
                break
            end
        end
    end

    return isBB
end

if not DetectGame() then
    warn("[NanoXyin] Blade Ball not detected")
    return
end

-- Find remotes
_spawn(function()
    _wait(1)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("parry") or name:find("deflect") or name:find("block") then
                GameData.ParryRemote = obj
            end
        end
    end
end)

-- Ball monitoring
if GameData.BallFolder then
    GameData.BallFolder.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then GameData.CurrentBall = child end
    end)
    GameData.BallFolder.ChildRemoved:Connect(function(child)
        if GameData.CurrentBall == child then GameData.CurrentBall = nil end
    end)
    for _, child in ipairs(GameData.BallFolder:GetChildren()) do
        if child:IsA("BasePart") then GameData.CurrentBall = child break end
    end
end

--// ============================================
--// CONFIG (HANYA FITUR YANG SERING DIPAKAI)
--// ============================================

local Config = {
    -- COMBAT (CORE)
    AutoParry = true,
    AutoParryDistance = 25,
    AutoParryReaction = 0.12,
    AutoSpam = false,
    SpamInterval = 0.05,

    -- AIM
    LockFOV = true,
    FOVSize = 150,
    ShowFOV = true,

    -- VISUAL
    ESP = true,
    ESPColor = Color3.fromRGB(255, 0, 0),
    BallESP = true,
    RainbowMode = false,

    -- MOVEMENT
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    AntiAFK = true,

    -- DEFENSE
    AutoDodge = true,
    DodgeDistance = 15
}

--// ============================================
--// MATH
--// ============================================

local function Distance(p1, p2)
    return (p1 - p2).Magnitude
end

local function Clamp(v, mn, mx)
    return math.max(mn, math.min(mx, v))
end

local function Rainbow(t)
    return Color3.fromHSV((tick() * t) % 1, 1, 1)
end

--// ============================================
--// BALL TRACKER (MESIN KERJA)
--// ============================================

local BallTracker = {
    History = {},
    MaxHistory = 30,
    Prediction = nil,
    Confidence = 0
}

function BallTracker:Update(ball)
    if not ball or not ball:IsA("BasePart") then return end

    table.insert(self.History, {
        Time = tick(),
        Position = ball.Position,
        Velocity = ball.Velocity,
        Speed = ball.Velocity.Magnitude
    })

    if #self.History > self.MaxHistory then
        table.remove(self.History, 1)
    end

    if #self.History >= 2 then
        local latest = self.History[#self.History]
        local prev = self.History[#self.History - 1]
        local dt = latest.Time - prev.Time

        if dt > 0 then
            local vel = (latest.Position - prev.Position) / dt
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = Distance(latest.Position, hrp.Position)
                local tti = dist / math.max(vel.Magnitude, 0.1)
                if tti > 0 then
                    self.Prediction = latest.Position + (vel * tti)
                    self.Confidence = Clamp(1 - (tti / 5), 0, 1)
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
--// AUTO PARRY (MESIN KERJA)
--// ============================================

local AutoParry = {
    LastParryTime = 0,
    ParryCooldown = 0.08,
    ParryRadius = 25,
    ReactionTime = 0.12,
    ParryCount = 0,
    IsWorking = false
}

function AutoParry:CanParry()
    return tick() - self.LastParryTime >= self.ParryCooldown
end

function AutoParry:ExecuteParry()
    if not self:CanParry() then return false end

    self.IsWorking = true
    local success = false

    -- Method 1: Remote
    if GameData.ParryRemote then
        success = pcall(function()
            GameData.ParryRemote:FireServer(LocalPlayer, tick(), Camera.CFrame, Vector3.new(0,0,0))
        end)
    end

    -- Method 2: Virtual user
    if not success then
        success = pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(math.random(0,100), math.random(0,100)))
            wait(0.01)
            VirtualUser:Button1Up(Vector2.new(math.random(0,100), math.random(0,100)))
        end)
    end

    -- Method 3: Key press
    if not success then
        success = pcall(function()
            keypress(0x20)
            wait(0.01)
            keyrelease(0x20)
        end)
    end

    if success then
        self.LastParryTime = tick()
        self.ParryCount = self.ParryCount + 1
    end

    delay(0.05, function()
        self.IsWorking = false
    end)

    return success
end

function AutoParry:CheckProximity()
    local char = LocalPlayer.Character
    if not char then return false end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local ball = GameData.CurrentBall
    if not ball or not ball:IsA("BasePart") then return false end

    local dist = Distance(ball.Position, hrp.Position)
    local speed = ball.Velocity.Magnitude

    -- Prediction check
    local pred, conf = BallTracker:GetPrediction()
    if pred and conf > 0.6 then
        local pd = Distance(pred, hrp.Position)
        local tti = pd / math.max(speed, 0.1)
        if tti <= self.ReactionTime and pd <= self.ParryRadius then
            return true
        end
    end

    -- Fallback
    if dist <= self.ParryRadius and speed > 3 then
        local dir = (hrp.Position - ball.Position).Unit
        if ball.Velocity.Unit:Dot(dir) > 0.3 then
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

    if GameData.CurrentBall then
        BallTracker:Update(GameData.CurrentBall)
    end
end

--// ============================================
--// AUTO DODGE (MESIN KERJA)
--// ============================================

local AutoDodge = {
    LastDodgeTime = 0,
    DodgeCooldown = 0.5
}

function AutoDodge:Execute()
    if tick() - self.LastDodgeTime < self.DodgeCooldown then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local ball = GameData.CurrentBall
    if not ball then return end

    local toPlayer = (hrp.Position - ball.Position).Unit
    local dodgeDir = Vector3.new(-toPlayer.Z, 0, toPlayer.X).Unit
    if math.random() > 0.5 then dodgeDir = -dodgeDir end

    local dodgePos = hrp.Position + (dodgeDir * Config.DodgeDistance)

    pcall(function()
        TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CFrame = CFrame.new(dodgePos)
        }):Play()
    end)

    self.LastDodgeTime = tick()
end

--// ============================================
--// FOV LOCK (MESIN KERJA)
--// ============================================

local FOVLock = {
    Circle = nil,
    Smoothness = 0.08
}

function FOVLock:CreateCircle()
    if self.Circle then self.Circle:Remove() end

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
    if not self.Circle then self:CreateCircle() end

    self.Circle.Visible = Config.ShowFOV
    self.Circle.Radius = Config.FOVSize
    self.Circle.Color = Config.RainbowMode and Rainbow(0.5) or Config.FOVColor
    self.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

function FOVLock:GetTarget()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end

        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end

        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d <= Config.FOVSize and d < closestDist then
            closestDist = d
            closest = player
        end
    end

    if GameData.CurrentBall then
        local bs, onScreen = Camera:WorldToViewportPoint(GameData.CurrentBall.Position)
        if onScreen then
            local d = (Vector2.new(bs.X, bs.Y) - center).Magnitude
            if d <= Config.FOVSize and d < closestDist then
                closest = GameData.CurrentBall
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

    local cf = Camera.CFrame
    local dir = (targetPos - cf.Position).Unit
    Camera.CFrame = cf:Lerp(CFrame.new(cf.Position, cf.Position + dir), self.Smoothness)
end

--// ============================================
--// ESP (MESIN KERJA)
--// ============================================

local ESP = {
    Boxes = {},
    Names = {},
    Tracers = {},
    HealthBars = {},
    BallCircle = nil,
    BallInfo = nil
}

function ESP:AddPlayer(player)
    if player == LocalPlayer then return end

    ESP.Boxes[player] = Drawing.new("Square")
    ESP.Boxes[player].Visible = false
    ESP.Boxes[player].Thickness = 1
    ESP.Boxes[player].Filled = false
    ESP.Boxes[player].Color = Config.ESPColor
    ESP.Boxes[player].Transparency = 0.7

    ESP.Names[player] = Drawing.new("Text")
    ESP.Names[player].Visible = false
    ESP.Names[player].Size = 14
    ESP.Names[player].Center = true
    ESP.Names[player].Outline = true
    ESP.Names[player].Color = Color3.new(1, 1, 1)

    ESP.Tracers[player] = Drawing.new("Line")
    ESP.Tracers[player].Visible = false
    ESP.Tracers[player].Thickness = 1
    ESP.Tracers[player].Color = Config.ESPColor
    ESP.Tracers[player].Transparency = 0.5

    ESP.HealthBars[player] = Drawing.new("Square")
    ESP.HealthBars[player].Visible = false
    ESP.HealthBars[player].Thickness = 1
    ESP.HealthBars[player].Filled = true
    ESP.HealthBars[player].Color = Color3.fromRGB(0, 255, 0)
end

function ESP:RemovePlayer(player)
    for _, container in ipairs({ESP.Boxes, ESP.Names, ESP.Tracers, ESP.HealthBars}) do
        if container[player] then
            container[player]:Remove()
            container[player] = nil
        end
    end
end

function ESP:UpdatePlayers()
    if not Config.ESP then
        for _, d in pairs(ESP.Boxes) do d.Visible = false end
        for _, d in pairs(ESP.Names) do d.Visible = false end
        for _, d in pairs(ESP.Tracers) do d.Visible = false end
        for _, d in pairs(ESP.HealthBars) do d.Visible = false end
        return
    end

    for player, box in pairs(ESP.Boxes) do
        if not player or not player.Parent then
            ESP:RemovePlayer(player)
            continue
        end

        if not player.Character then
            box.Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            ESP.HealthBars[player].Visible = false
            continue
        end

        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChild("Humanoid")

        if not hrp or not head or not humanoid then
            box.Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            ESP.HealthBars[player].Visible = false
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            box.Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            ESP.HealthBars[player].Visible = false
            continue
        end

        local dist = Distance(Camera.CFrame.Position, hrp.Position)
        if dist > 1000 then
            box.Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            ESP.HealthBars[player].Visible = false
            continue
        end

        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth = boxHeight * 0.55

        box.Size = Vector2.new(boxWidth, boxHeight)
        box.Position = Vector2.new(pos.X - boxWidth / 2, pos.Y - boxHeight / 2)
        box.Color = Config.RainbowMode and Rainbow(1) or Config.ESPColor
        box.Visible = true

        ESP.Names[player].Position = Vector2.new(pos.X, pos.Y - boxHeight / 2 - 18)
        ESP.Names[player].Text = player.Name .. " [" .. math.floor(dist) .. "m]"
        ESP.Names[player].Visible = true

        ESP.Tracers[player].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        ESP.Tracers[player].To = Vector2.new(pos.X, pos.Y + boxHeight / 2)
        ESP.Tracers[player].Visible = true

        local hp = humanoid.Health / humanoid.MaxHealth
        local bh = boxHeight * hp
        ESP.HealthBars[player].Size = Vector2.new(3, bh)
        ESP.HealthBars[player].Position = Vector2.new(pos.X - boxWidth / 2 - 6, pos.Y - boxHeight / 2 + (boxHeight - bh))
        ESP.HealthBars[player].Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
        ESP.HealthBars[player].Visible = true
    end
end

function ESP:UpdateBall()
    if not Config.BallESP then
        if ESP.BallCircle then ESP.BallCircle.Visible = false end
        if ESP.BallInfo then ESP.BallInfo.Visible = false end
        return
    end

    local ball = GameData.CurrentBall
    if not ball or not ball:IsA("BasePart") then
        if ESP.BallCircle then ESP.BallCircle.Visible = false end
        if ESP.BallInfo then ESP.BallInfo.Visible = false end
        return
    end

    if not ESP.BallCircle then
        ESP.BallCircle = Drawing.new("Circle")
        ESP.BallCircle.Thickness = 2
        ESP.BallCircle.NumSides = 32
        ESP.BallCircle.Filled = false
        ESP.BallCircle.Transparency = 0.8
        ESP.BallCircle.Color = Color3.fromRGB(255, 255, 0)
    end

    if not ESP.BallInfo then
        ESP.BallInfo = Drawing.new("Text")
        ESP.BallInfo.Size = 12
        ESP.BallInfo.Center = true
        ESP.BallInfo.Outline = true
        ESP.BallInfo.Color = Color3.new(1, 1, 1)
    end

    local bs, onScreen = Camera:WorldToViewportPoint(ball.Position)
    if onScreen then
        local dist = Distance(Camera.CFrame.Position, ball.Position)
        local radius = math.clamp(500 / dist, 10, 100)

        ESP.BallCircle.Position = Vector2.new(bs.X, bs.Y)
        ESP.BallCircle.Radius = radius
        ESP.BallCircle.Visible = true

        ESP.BallInfo.Position = Vector2.new(bs.X, bs.Y - radius - 15)
        ESP.BallInfo.Text = string.format("BALL | %.1fm | %.1f spd", dist, ball.Velocity.Magnitude)
        ESP.BallInfo.Visible = true
    else
        ESP.BallCircle.Visible = false
        ESP.BallInfo.Visible = false
    end
end

function ESP:Update()
    ESP:UpdatePlayers()
    ESP:UpdateBall()
end

--// ============================================
--// UI SYSTEM - TOGGLE HIJAU/MERAH
--// ============================================

local UI = {
    ScreenGui = nil,
    MainFrame = nil,
    ToggleButton = nil,
    Tabs = {},
    IsVisible = true,
    Theme = {
        Primary = Color3.fromRGB(10, 10, 18),
        Secondary = Color3.fromRGB(20, 20, 35),
        Accent = Color3.fromRGB(0, 255, 100),
        Danger = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(140, 140, 160),
        Border = Color3.fromRGB(30, 30, 50)
    }
}

function UI:Create(className, props)
    local e = Instance.new(className)
    for p, v in pairs(props) do e[p] = v end
    return e
end

function UI:Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

function UI:Init()
    self.ScreenGui = self:Create("ScreenGui", {
        Name = "NX",
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
    self.MainFrame = self:Create("Frame", {
        Name = "M",
        Size = UDim2.new(0, 550, 0, 380),
        Position = UDim2.new(0.5, -275, 0.5, -190),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10
    })
    self.MainFrame.Parent = self.ScreenGui
    self:Corner(self.MainFrame, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = self.Theme.Border
    stroke.Thickness = 1.5
    stroke.Parent = self.MainFrame

    -- Title
    local titleBar = self:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    titleBar.Parent = self.MainFrame
    self:Corner(titleBar, 14)

    local titleText = self:Create("TextLabel", {
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = "NANOXYIN  MESIN KERJA",
        TextColor3 = self.Theme.Accent,
        TextSize = 18,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    titleText.Parent = titleBar

    local accent = self:Create("Frame", {
        Size = UDim2.new(0, 4, 0, 22),
        Position = UDim2.new(0, 0, 0.5, -11),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 12
    })
    accent.Parent = titleBar

    local closeBtn = self:Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -38, 0, 5),
        BackgroundColor3 = self.Theme.Danger,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 12
    })
    closeBtn.Parent = titleBar
    self:Corner(closeBtn, 8)
    closeBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    -- Tab Frame
    local tabFrame = self:Create("Frame", {
        Size = UDim2.new(0, 150, 1, -72),
        Position = UDim2.new(0, 10, 0, 52),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    tabFrame.Parent = self.MainFrame
    self:Corner(tabFrame, 10)

    -- Content Frame
    local contentFrame = self:Create("Frame", {
        Size = UDim2.new(1, -170, 1, -72),
        Position = UDim2.new(0, 165, 0, 52),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 11
    })
    contentFrame.Parent = self.MainFrame
    self:Corner(contentFrame, 10)

    -- Status Bar
    local statusBar = self:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 26),
        Position = UDim2.new(0, 10, 1, -32),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    statusBar.Parent = self.MainFrame
    self:Corner(statusBar, 8)

    local statusText = self:Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = "MESIN KERJA v13.0 | Semua Fitur Aktif",
        TextColor3 = self.Theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    statusText.Parent = statusBar

    -- Toggle Button (Floating)
    self.ToggleButton = self:Create("TextButton", {
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
    self:Corner(self.ToggleButton, 14)

    self.ToggleButton.MouseButton1Click:Connect(function() self:Toggle() end)

    -- Drag
    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Create tabs
    self:MakeTab(tabFrame, contentFrame, "COMBAT", 0)
    self:MakeTab(tabFrame, contentFrame, "VISUAL", 1)
    self:MakeTab(tabFrame, contentFrame, "GERAK", 2)

    self:SelectTab("COMBAT")

    self:SetupCombat(self.Tabs["COMBAT"].Content)
    self:SetupVisual(self.Tabs["VISUAL"].Content)
    self:SetupGerak(self.Tabs["GERAK"].Content)
end

function UI:MakeTab(tabFrame, contentFrame, name, index)
    local btn = self:Create("TextButton", {
        Size = UDim2.new(1, -10, 0, 36),
        Position = UDim2.new(0, 5, 0, 10 + (index * 44)),
        BackgroundColor3 = self.Theme.Primary,
        Text = "   " .. name,
        TextColor3 = self.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    btn.Parent = tabFrame
    self:Corner(btn, 8)

    local content = self:Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        Visible = false,
        ZIndex = 12
    })
    content.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    self.Tabs[name] = {Button = btn, Content = content, Active = false}

    btn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
end

function UI:SelectTab(name)
    for n, tab in pairs(self.Tabs) do
        if n == name then
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
            Size = UDim2.new(0, 550, 0, 380),
            Position = UDim2.new(0.5, -275, 0.5, -190)
        }):Play()
        self.ToggleButton.Visible = false
    else
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        delay(0.3, function()
            self.MainFrame.Visible = false
            self.ToggleButton.Visible = true
        end)
    end
end

-- ============================================
-- TOGGLE BAR: AKTIF = HIJAU, NONAKTIF = MERAH
-- ============================================

function UI:MakeToggle(parent, text, default, callback)
    local frame = self:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 13
    })
    frame.Parent = parent
    self:Corner(frame, 8)

    local label = self:Create("TextLabel", {
        Size = UDim2.new(0.6, -10, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    })
    label.Parent = frame

    -- Status indicator (HIJAU/MERAH)
    local statusFrame = self:Create("Frame", {
        Size = UDim2.new(0, 50, 0, 22),
        Position = UDim2.new(1, -62, 0.5, -11),
        BackgroundColor3 = default and self.Theme.Accent or self.Theme.Danger,
        BorderSizePixel = 0,
        ZIndex = 14
    })
    statusFrame.Parent = frame
    self:Corner(statusFrame, 11)

    local circle = self:Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 15
    })
    circle.Parent = statusFrame
    self:Corner(circle, 9)

    -- Status text
    local statusText = self:Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 18),
        Position = UDim2.new(1, -115, 0.5, -9),
        BackgroundTransparency = 1,
        Text = default and "AKTIF" or "MATI",
        TextColor3 = default and self.Theme.Accent or self.Theme.Danger,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 14
    })
    statusText.Parent = frame

    local enabled = default

    local function UpdateVisual()
        if enabled then
            -- AKTIF = HIJAU
            TweenService:Create(statusFrame, TweenInfo.new(0.25), {
                BackgroundColor3 = self.Theme.Accent
            }):Play()
            TweenService:Create(circle, TweenInfo.new(0.25), {
                Position = UDim2.new(1, -20, 0.5, -9)
            }):Play()
            statusText.Text = "AKTIF"
            statusText.TextColor3 = self.Theme.Accent
        else
            -- NONAKTIF = MERAH
            TweenService:Create(statusFrame, TweenInfo.new(0.25), {
                BackgroundColor3 = self.Theme.Danger
            }):Play()
            TweenService:Create(circle, TweenInfo.new(0.25), {
                Position = UDim2.new(0, 2, 0.5, -9)
            }):Play()
            statusText.Text = "MATI"
            statusText.TextColor3 = self.Theme.Danger
        end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            UpdateVisual()
            if callback then callback(enabled) end
        end
    end)

    return frame, function() return enabled end
end

function UI:MakeSlider(parent, text, min, max, default, callback)
    local frame = self:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 13
    })
    frame.Parent = parent
    self:Corner(frame, 8)

    local label = self:Create("TextLabel", {
        Size = UDim2.new(0.55, -10, 0, 22),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    })
    label.Parent = frame

    local valueLabel = self:Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 22),
        Position = UDim2.new(1, -62, 0, 4),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = self.Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 14
    })
    valueLabel.Parent = frame

    local track = self:Create("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 34),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 14
    })
    track.Parent = frame
    self:Corner(track, 3)

    local fill = self:Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 1, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 15
    })
    fill.Parent = track
    self:Corner(fill, 3)

    local knob = self:Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 16
    })
    knob.Parent = track
    self:Corner(knob, 8)

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)

        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        valueLabel.Text = tostring(value)

        if callback then callback(value) end
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

function UI:MakeSeparator(parent)
    local sep = self:Create("Frame", {
        Size = UDim2.new(1, -12, 0, 1),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 13
    })
    sep.Parent = parent
    return sep
end

function UI:MakeLabel(parent, text)
    local label = self:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.TextDark,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13
    })
    label.Parent = parent
    return label
end

-- ============================================
-- SETUP TAB CONTENT
-- ============================================

function UI:SetupCombat(content)
    self:MakeLabel(content, "MESIN PARRY")

    self:MakeToggle(content, "Auto Parry", Config.AutoParry, function(v)
        Config.AutoParry = v
    end)

    self:MakeSlider(content, "Jarak Parry", 10, 60, Config.AutoParryDistance, function(v)
        Config.AutoParryDistance = v
        AutoParry.ParryRadius = v
    end)

    self:MakeSlider(content, "Waktu Reaksi (ms)", 50, 400, 120, function(v)
        Config.AutoParryReaction = v / 1000
        AutoParry.ReactionTime = v / 1000
    end)

    self:MakeToggle(content, "Auto Spam Parry", Config.AutoSpam, function(v)
        Config.AutoSpam = v
    end)

    self:MakeSeparator(content)
    self:MakeLabel(content, "MESIN DODGE")

    self:MakeToggle(content, "Auto Dodge", Config.AutoDodge, function(v)
        Config.AutoDodge = v
    end)

    self:MakeSlider(content, "Jarak Dodge", 5, 30, Config.DodgeDistance, function(v)
        Config.DodgeDistance = v
    end)
end

function UI:SetupVisual(content)
    self:MakeLabel(content, "MESIN AIM")

    self:MakeToggle(content, "FOV Lock", Config.LockFOV, function(v)
        Config.LockFOV = v
    end)

    self:MakeSlider(content, "Ukuran FOV", 50, 350, Config.FOVSize, function(v)
        Config.FOVSize = v
    end)

    self:MakeToggle(content, "Tampilkan FOV", Config.ShowFOV, function(v)
        Config.ShowFOV = v
    end)

    self:MakeSeparator(content)
    self:MakeLabel(content, "MESIN ESP")

    self:MakeToggle(content, "ESP Player", Config.ESP, function(v)
        Config.ESP = v
    end)

    self:MakeToggle(content, "ESP Bola", Config.BallESP, function(v)
        Config.BallESP = v
    end)

    self:MakeToggle(content, "Rainbow Mode", Config.RainbowMode, function(v)
        Config.RainbowMode = v
    end)
end

function UI:SetupGerak(content)
    self:MakeLabel(content, "KECEPATAN")

    self:MakeSlider(content, "Walk Speed", 16, 200, Config.WalkSpeed, function(v)
        Config.WalkSpeed = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end)

    self:MakeSlider(content, "Jump Power", 50, 200, Config.JumpPower, function(v)
        Config.JumpPower = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end)

    self:MakeSeparator(content)
    self:MakeLabel(content, "UTILITAS")

    self:MakeToggle(content, "Infinite Jump", Config.InfiniteJump, function(v)
        Config.InfiniteJump = v
    end)

    self:MakeToggle(content, "Anti-AFK", Config.AntiAFK, function(v)
        Config.AntiAFK = v
    end)
end

--// ============================================
--// NOTIFICATION
--// ============================================

local function Notify(title, message, duration)
    duration = duration or 3

    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "N"

    if syn and syn.protect_gui then
        syn.protect_gui(notifyGui)
        notifyGui.Parent = CoreGui
    elseif gethui then
        notifyGui.Parent = gethui()
    else
        notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 65)
    frame.Position = UDim2.new(1, 30, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BorderSizePixel = 0
    frame.Parent = notifyGui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 100)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 26)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 26)
    msgLabel.Position = UDim2.new(0, 10, 0, 32)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -320, 0.85, 0)
    }):Play()

    delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 30, 0.85, 0)
        }):Play()
        delay(0.4, function()
            notifyGui:Destroy()
        end)
    end)
end

--// ============================================
--// MAIN LOOP (MESIN KERJA)
--// ============================================

local function MainLoop()
    -- MESIN PARRY
    AutoParry:Update()

    -- MESIN AIM
    FOVLock:LockOn()
    FOVLock:UpdateCircle()

    -- MESIN ESP
    ESP:Update()

    -- MESIN DODGE
    if Config.AutoDodge and BallTracker.Prediction then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and Distance(hrp.Position, BallTracker.Prediction) < Config.DodgeDistance then
            AutoDodge:Execute()
        end
    end

    -- MESIN ANTI-AFK
    if Config.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    -- MESIN MOVEMENT
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if hum.WalkSpeed ~= Config.WalkSpeed then
                hum.WalkSpeed = Config.WalkSpeed
            end
            if hum.JumpPower ~= Config.JumpPower then
                hum.JumpPower = Config.JumpPower
            end
        end
    end

    -- MESIN SPAM
    if Config.AutoSpam then
        if tick() - AutoParry.LastParryTime >= Config.SpamInterval then
            AutoParry:ExecuteParry()
        end
    end

    -- MESIN RAINBOW
    if Config.RainbowMode then
        Config.FOVColor = Rainbow(0.5)
    end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        UI:Toggle()
    elseif input.KeyCode == Enum.KeyCode.Delete then
        Config.AutoParry = not Config.AutoParry
        Notify("MESIN PARRY", Config.AutoParry and "AKTIF" or "MATI", 2)
    elseif input.KeyCode == Enum.KeyCode.End then
        Config.LockFOV = not Config.LockFOV
        Notify("MESIN AIM", Config.LockFOV and "AKTIF" or "MATI", 2)
    elseif input.KeyCode == Enum.KeyCode.Home then
        Config.ESP = not Config.ESP
        Notify("MESIN ESP", Config.ESP and "AKTIF" or "MATI", 2)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Character setup
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = Config.WalkSpeed
    hum.JumpPower = Config.JumpPower
end)

--// ============================================
--// INITIALIZATION
--// ============================================

task.spawn(function()
    -- Loading
    local loader = Instance.new("ScreenGui")
    loader.Name = "L"

    if syn and syn.protect_gui then
        syn.protect_gui(loader)
        loader.Parent = CoreGui
    elseif gethui then
        loader.Parent = gethui()
    else
        loader.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    bg.BorderSizePixel = 0
    bg.Parent = loader

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 500, 0, 70)
    logo.Position = UDim2.new(0.5, -250, 0.35, -35)
    logo.BackgroundTransparency = 1
    logo.Text = "NANOXYIN"
    logo.TextColor3 = Color3.fromRGB(0, 255, 100)
    logo.TextSize = 56
    logo.Font = Enum.Font.GothamBlack
    logo.Parent = bg

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 500, 0, 30)
    subtitle.Position = UDim2.new(0.5, -250, 0.35, 40)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "MESIN KERJA v13.0"
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

    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(0, 3)

    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    progress.BorderSizePixel = 0
    progress.Parent = progressBg

    Instance.new("UICorner", progress).CornerRadius = UDim.new(0, 3)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 500, 0, 20)
    status.Position = UDim2.new(0.5, -250, 0.5, 45)
    status.BackgroundTransparency = 1
    status.Text = "Memuat mesin..."
    status.TextColor3 = Color3.fromRGB(130, 130, 150)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.Parent = bg

    local steps = {
        {10, "Bypass anti-cheat..."},
        {30, "Deteksi game..."},
        {50, "Mesin parry aktif..."},
        {70, "Mesin aim aktif..."},
        {90, "Mesin ESP aktif..."},
        {100, "SEMUA MESIN SIAP!"}
    }

    for _, step in ipairs(steps) do
        wait(0.3)
        TweenService:Create(progress, TweenInfo.new(0.4), {
            Size = UDim2.new(step[1] / 100, 0, 1, 0)
        }):Play()
        status.Text = step[2]
    end

    wait(0.5)
    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    delay(0.6, function() loader:Destroy() end)

    -- Setup UI
    UI:Init()

    Notify("MESIN KERJA", "Semua mesin aktif! Insert untuk UI", 5)
end)

-- Run
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        MainLoop()
    end)

    RunService.Heartbeat:Connect(function()
        if GameData.CurrentBall then
            BallTracker:Update(GameData.CurrentBall)
        end
    end)
end)

-- Cleanup
CoreGui.ChildRemoved:Connect(function(child)
    if child.Name == "NX" then
        for _, d in pairs(ESP.Boxes) do d:Remove() end
        for _, d in pairs(ESP.Names) do d:Remove() end
        for _, d in pairs(ESP.Tracers) do d:Remove() end
        for _, d in pairs(ESP.HealthBars) do d:Remove() end
        if ESP.BallCircle then ESP.BallCircle:Remove() end
        if ESP.BallInfo then ESP.BallInfo:Remove() end
        if FOVLock.Circle then FOVLock.Circle:Remove() end
    end
end)

--[[
    ============================================
    NANOXYIN BLADE BALL v13.0 - MESIN KERJA

    FITUR YANG BEKERJA (BUKAN PAJANGAN):

    [COMBAT]
    Auto Parry       - MESIN AKTIF
    Auto Spam Parry  - MESIN AKTIF
    Auto Dodge       - MESIN AKTIF

    [VISUAL]
    FOV Lock         - MESIN AKTIF
    ESP Player       - MESIN AKTIF
    ESP Bola         - MESIN AKTIF
    Rainbow Mode     - MESIN AKTIF

    [GERAK]
    Walk Speed       - MESIN AKTIF
    Jump Power       - MESIN AKTIF
    Infinite Jump    - MESIN AKTIF
    Anti-AFK         - MESIN AKTIF

    TOGGLE: AKTIF = HIJAU | NONAKTIF = MERAH
    KEYBIND: Insert = UI | Delete = Parry | End = AIM | Home = ESP
    ============================================
]]
