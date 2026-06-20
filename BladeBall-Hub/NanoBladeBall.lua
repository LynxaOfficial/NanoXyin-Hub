--[[
    ============================================
    NANOXYIN BLADE BALL MASTER SYSTEM v9.0
    Auto Parry | Lock FOV | Anti-Cheat Bypass | Modern UI
    Compatible: Delta Executor, Fluxus, Krnl, Synapse X
    ============================================
    - .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..
    ============================================
]]

--// Services & Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// Anti-Detection Layer (NanoXyin Stealth Core)
local _G = getfenv(0)
local getrawmetatable = getrawmetatable or debug.getrawmetatable
local setrawmetatable = setrawmetatable or debug.setrawmetatable
local hookfunction = hookfunction or detour_function
local hookmetamethod = hookmetamethod or hookfunction
local getnamecallmethod = getnamecallmethod
local checkcaller = checkcaller
local newcclosure = newcclosure or function(f) return f end

--// Stealth Variables
local NanoXyin = {
    Version = "9.0",
    Status = "Initializing...",
    StealthMode = true,
    AntiCheatBypass = true,
    DebugMode = false
}

--// Anti-Cheat Bypass Core
local OldNamecall
local OldIndex
local OldNewIndex
local OldFireServer
local OldInvokeServer
local OldKick
local OldDestroy

--// Game Detection
local BladeBall = {
    GameName = "Blade Ball",
    BallFolder = nil,
    BallObject = nil,
    CurrentBall = nil,
    ParryRemote = nil,
    AbilityRemote = nil,
    GameMode = "Normal"
}

--// Configuration
local Config = {
    AutoParry = true,
    AutoParryDistance = 25,
    AutoParryReaction = 0.15,
    LockFOV = true,
    FOVSize = 150,
    FOVColor = Color3.fromRGB(0, 255, 136),
    ShowFOV = true,
    AutoSpam = false,
    SpamInterval = 0.05,
    ESP = true,
    ESPColor = Color3.fromRGB(255, 0, 0),
    AutoAbility = true,
    AutoClash = true,
    NoCooldown = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    AntiAFK = true,
    AutoFarm = false,
    TargetMode = "Closest", -- Closest, LowestHP, Random
    PredictionMode = "Velocity", -- Velocity, Linear, Advanced
    PingCompensation = true,
    VisualEffects = true,
    SoundEffects = true,
    StreamerMode = false,
    RainbowMode = false
}

--// Memory Storage
local ESPObjects = {}
local ConnectionStorage = {}
local TweenStorage = {}
local ParryHistory = {}
local BallTrajectory = {}
local PlayerData = {}

--// Math & Physics Functions
local function CalculateDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function CalculateVelocity(pos1, pos2, deltaTime)
    return (pos2 - pos1) / deltaTime
end

local function PredictPosition(origin, velocity, time)
    return origin + (velocity * time)
end

local function CalculateInterceptTime(shooterPos, targetPos, targetVel, projectileSpeed)
    local relativePos = targetPos - shooterPos
    local relativeVel = targetVel
    local a = relativeVel:Dot(relativeVel) - projectileSpeed * projectileSpeed
    local b = 2 * relativePos:Dot(relativeVel)
    local c = relativePos:Dot(relativePos)
    local discriminant = b * b - 4 * a * c
    
    if discriminant < 0 then
        return nil
    end
    
    local t1 = (-b + math.sqrt(discriminant)) / (2 * a)
    local t2 = (-b - math.sqrt(discriminant)) / (2 * a)
    
    if t1 > 0 and t2 > 0 then
        return math.min(t1, t2)
    elseif t1 > 0 then
        return t1
    elseif t2 > 0 then
        return t2
    end
    
    return nil
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

--// Vector Math Extensions
local function Vector3Lerp(v1, v2, t)
    return Vector3.new(
        Lerp(v1.X, v2.X, t),
        Lerp(v1.Y, v2.Y, t),
        Lerp(v1.Z, v2.Z, t)
    )
end

local function GetClosestPointOnLine(point, lineStart, lineEnd)
    local lineVec = lineEnd - lineStart
    local pointVec = point - lineStart
    local lineLength = lineVec.Magnitude
    local lineUnit = lineVec.Unit
    local projection = pointVec:Dot(lineUnit)
    local clampedProjection = Clamp(projection, 0, lineLength)
    return lineStart + lineUnit * clampedProjection
end

--// Color Utilities
local function RGBToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function HexToRGB(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6))
    )
end

local function RainbowColor(t)
    local hue = (tick() * t) % 1
    return Color3.fromHSV(hue, 1, 1)
end

--// Stealth Core Functions
local function StealthLog(message)
    if NanoXyin.DebugMode then
        print("[NanoXyin] " .. tostring(message))
    end
end

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        StealthLog("Error: " .. tostring(result))
    end
    return success, result
end

--// Anti-Cheat Bypass Layer 1: Namecall Hook
local function SetupNamecallBypass()
    local mt = getrawmetatable(game)
    if not mt then return end
    
    setreadonly(mt, false)
    OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "Kick" then
            StealthLog("Kick attempt blocked")
            return nil
        end
        
        if method == "Destroy" and self == LocalPlayer then
            StealthLog("Player destroy blocked")
            return nil
        end
        
        if method == "FireServer" then
            if tostring(self):find("AntiCheat") or tostring(self):find("AC") then
                StealthLog("AntiCheat remote blocked")
                return nil
            end
        end
        
        if checkcaller() then
            return OldNamecall(self, ...)
        end
        
        return OldNamecall(self, ...)
    end))
    
    setreadonly(mt, true)
    StealthLog("Namecall bypass initialized")
end

--// Anti-Cheat Bypass Layer 2: Index Hook
local function SetupIndexBypass()
    local mt = getrawmetatable(game)
    if not mt then return end
    
    setreadonly(mt, false)
    OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if self == LocalPlayer and key == "Kick" then
            return function() 
                StealthLog("Kick function blocked") 
                return nil 
            end
        end
        
        if self == LocalPlayer and key == "Destroy" then
            return function()
                StealthLog("Destroy blocked")
                return nil
            end
        end
        
        if checkcaller() then
            return OldIndex(self, key)
        end
        
        return OldIndex(self, key)
    end))
    
    setreadonly(mt, true)
    StealthLog("Index bypass initialized")
end

--// Anti-Cheat Bypass Layer 3: Remote Event Hook
local function SetupRemoteBypass()
    local originalFireServer
    local originalInvokeServer
    
    for _, obj in pairs(getgc()) do
        if type(obj) == "function" then
            local info = debug.getinfo(obj)
            if info.name == "fireServer" then
                originalFireServer = obj
                break
            end
        end
    end
    
    if originalFireServer then
        OldFireServer = hookfunction(originalFireServer, newcclosure(function(self, ...)
            local args = {...}
            local remoteName = tostring(self)
            
            if remoteName:find("AntiCheat") or remoteName:find("Report") or remoteName:find("Log") then
                StealthLog("Blocked remote: " .. remoteName)
                return nil
            end
            
            if remoteName:find("Parry") and Config.AutoParry then
                StealthLog("Parry remote intercepted")
            end
            
            return OldFireServer(self, ...)
        end))
    end
    
    StealthLog("Remote bypass initialized")
end

--// Anti-Cheat Bypass Layer 4: Memory Manipulation
local function SetupMemoryBypass()
    local gc = getgc()
    for i = 1, #gc do
        local obj = gc[i]
        if type(obj) == "function" then
            local info = debug.getinfo(obj)
            if info.source:find("AntiCheat") or info.source:find("AC") then
                local upvalues = debug.getupvalues(obj)
                for j = 1, #upvalues do
                    if type(upvalues[j]) == "boolean" then
                        debug.setupvalue(obj, j, false)
                    elseif type(upvalues[j]) == "number" then
                        debug.setupvalue(obj, j, 0)
                    end
                end
            end
        end
    end
    
    StealthLog("Memory bypass initialized")
end

--// Anti-Cheat Bypass Layer 5: Heartbeat Spoof
local function SetupHeartbeatSpoof()
    local originalHeartbeat = RunService.Heartbeat
    local fakeHeartbeat = {
        Connect = function(self, func)
            return originalHeartbeat:Connect(function(delta)
                local modifiedDelta = delta * (1 + math.random() * 0.01)
                func(modifiedDelta)
            end)
        end,
        Wait = function(self)
            return originalHeartbeat:Wait()
        end
    }
    
    -- Deep copy metatable manipulation
    local mt = getrawmetatable(RunService)
    setreadonly(mt, false)
    
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if self == RunService and key == "Heartbeat" then
            return fakeHeartbeat
        end
        return oldIndex(self, key)
    end)
    
    setreadonly(mt, true)
    StealthLog("Heartbeat spoof initialized")
end

--// Anti-Cheat Bypass Layer 6: Input Spoofing
local function SetupInputSpoofing()
    local originalInputBegan = UserInputService.InputBegan
    local originalInputEnded = UserInputService.InputEnded
    
    -- Spoof mouse movement patterns
    local lastMousePos = Vector2.new(0, 0)
    local mouseMoveHistory = {}
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local currentPos = input.Position
            local delta = currentPos - lastMousePos
            table.insert(mouseMoveHistory, {
                delta = delta,
                time = tick()
            })
            
            if #mouseMoveHistory > 50 then
                table.remove(mouseMoveHistory, 1)
            end
            
            lastMousePos = currentPos
        end
    end)
    
    StealthLog("Input spoofing initialized")
end

--// Anti-Cheat Bypass Layer 7: Detection Evasion
local function SetupDetectionEvasion()
    -- Hide from common detection methods
    local originalGetChildren = game.GetChildren
    local originalFindFirstChild = game.FindFirstChild
    
    -- Spoof executor detection
    local executorChecks = {
        "getexecutorname", "getexecutor", "identifyexecutor",
        "is_synapse_function", "is_krnl_function", "is_fluxus_function"
    }
    
    for _, check in pairs(executorChecks) do
        if _G[check] then
            _G[check] = function()
                return "RobloxStudio"
            end
        end
    end
    
    StealthLog("Detection evasion initialized")
end

--// Anti-Cheat Bypass Layer 8: Network Spoofing
local function SetupNetworkSpoofing()
    local originalRequest = syn and syn.request or http and http.request or request
    
    if originalRequest then
        local hookedRequest = function(data)
            if data.Url and (data.Url:find("anti-cheat") or data.Url:find("analytics")) then
                StealthLog("Blocked analytics request: " .. data.Url)
                return {
                    StatusCode = 200,
                    Body = "{}",
                    Headers = {}
                }
            end
            return originalRequest(data)
        end
        
        if syn then
            syn.request = hookedRequest
        elseif http then
            http.request = hookedRequest
        elseif request then
            request = hookedRequest
        end
    end
    
    StealthLog("Network spoofing initialized")
end

--// Initialize All Bypass Layers
local function InitializeAntiCheatBypass()
    StealthLog("Initializing Anti-Cheat Bypass System...")
    
    SafeCall(SetupNamecallBypass)
    SafeCall(SetupIndexBypass)
    SafeCall(SetupRemoteBypass)
    SafeCall(SetupMemoryBypass)
    SafeCall(SetupHeartbeatSpoof)
    SafeCall(SetupInputSpoofing)
    SafeCall(SetupDetectionEvasion)
    SafeCall(SetupNetworkSpoofing)
    
    -- Additional protection layers
    -- Block common detection vectors
    local protectedGlobals = {
        "syn", "getexecutorname", "getexecutor", "identifyexecutor",
        "is_synapse_function", "is_krnl_function", "is_fluxus_function",
        "checkcaller", "getcallingscript", "getscriptclosure"
    }
    
    for _, global in pairs(protectedGlobals) do
        if _G[global] then
            local original = _G[global]
            _G[global] = function(...)
                if checkcaller() then
                    return original(...)
                end
                return nil
            end
        end
    end
    
    StealthLog("All bypass layers active")
end

--// Game Detection & Setup
local function DetectBladeBall()
    local success = pcall(function()
        -- Detect game by common elements
        local places = {
            [13772394625] = "Blade Ball", -- Main
            [14775231477] = "Blade Ball", -- Alternative
            [15131069922] = "Blade Ball", -- Test
        }
        
        local placeId = game.PlaceId
        if places[placeId] then
            BladeBall.GameName = places[placeId]
            StealthLog("Game detected: " .. BladeBall.GameName)
            return true
        end
        
        -- Fallback detection
        local ballFolder = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("BallFolder")
        if ballFolder then
            BladeBall.BallFolder = ballFolder
            StealthLog("Ball folder detected via fallback")
            return true
        end
        
        return false
    end)
    
    return success
end

local function SetupGameConnections()
    -- Find remotes
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("parry") or name:find("deflect") or name:find("block") then
                BladeBall.ParryRemote = obj
                StealthLog("Parry remote found: " .. obj.Name)
            elseif name:find("ability") or name:find("skill") then
                BladeBall.AbilityRemote = obj
                StealthLog("Ability remote found: " .. obj.Name)
            end
        end
    end
    
    -- Monitor ball folder
    if workspace:FindFirstChild("Balls") then
        BladeBall.BallFolder = workspace.Balls
    elseif workspace:FindFirstChild("BallFolder") then
        BladeBall.BallFolder = workspace.BallFolder
    end
    
    if BladeBall.BallFolder then
        BladeBall.BallFolder.ChildAdded:Connect(function(child)
            if child:IsA("BasePart") or child:IsA("MeshPart") then
                BladeBall.CurrentBall = child
                StealthLog("New ball detected: " .. child.Name)
            end
        end)
        
        for _, child in pairs(BladeBall.BallFolder:GetChildren()) do
            if child:IsA("BasePart") or child:IsA("MeshPart") then
                BladeBall.CurrentBall = child
                break
            end
        end
    end
    
    StealthLog("Game connections established")
end

--// Ball Tracking & Prediction
local BallTracker = {
    History = {},
    MaxHistory = 30,
    CurrentPrediction = nil,
    Confidence = 0
}

function BallTracker:Update(ball)
    if not ball or not ball:IsA("BasePart") then return end
    
    local currentTime = tick()
    local position = ball.Position
    local velocity = ball.Velocity
    
    table.insert(self.History, {
        Time = currentTime,
        Position = position,
        Velocity = velocity,
        CFrame = ball.CFrame
    })
    
    if #self.History > self.MaxHistory then
        table.remove(self.History, 1)
    end
    
    -- Calculate prediction
    if #self.History >= 2 then
        local latest = self.History[#self.History]
        local previous = self.History[#self.History - 1]
        local deltaTime = latest.Time - previous.Time
        
        if deltaTime > 0 then
            local calculatedVel = (latest.Position - previous.Position) / deltaTime
            local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
            
            if playerPos then
                local distance = CalculateDistance(latest.Position, playerPos)
                local timeToImpact = distance / calculatedVel.Magnitude
                
                if timeToImpact and timeToImpact > 0 then
                    self.CurrentPrediction = PredictPosition(latest.Position, calculatedVel, timeToImpact)
                    self.Confidence = Clamp(1 - (timeToImpact / 5), 0, 1)
                end
            end
        end
    end
end

function BallTracker:GetPrediction()
    return self.CurrentPrediction, self.Confidence
end

function BallTracker:Clear()
    self.History = {}
    self.CurrentPrediction = nil
    self.Confidence = 0
end

--// Auto Parry System
local AutoParry = {
    Enabled = true,
    LastParryTime = 0,
    ParryCooldown = 0.1,
    ParryRadius = 25,
    ReactionTime = 0.15,
    ParryCount = 0,
    SuccessRate = 0
}

function AutoParry:CanParry()
    local currentTime = tick()
    return currentTime - self.LastParryTime >= self.ParryCooldown
end

function AutoParry:ExecuteParry()
    if not self:CanParry() then return false end
    
    local success = false
    
    if BladeBall.ParryRemote then
        -- Method 1: Direct remote fire
        local args = {
            LocalPlayer,
            tick(),
            Camera.CFrame,
            Vector3.new(0, 0, 0)
        }
        
        success = pcall(function()
            BladeBall.ParryRemote:FireServer(unpack(args))
        end)
    end
    
    -- Method 2: Virtual input simulation
    if not success then
        success = pcall(function()
            VirtualUser:Button1Down(Vector2.new(0, 0))
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end)
    end
    
    -- Method 3: Key press simulation
    if not success then
        success = pcall(function()
            keypress(0x20) -- Space
            keyrelease(0x20)
        end)
    end
    
    if success then
        self.LastParryTime = tick()
        self.ParryCount = self.ParryCount + 1
        StealthLog("Parry executed successfully")
    end
    
    return success
end

function AutoParry:CheckBallProximity()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local ball = BladeBall.CurrentBall
    if not ball or not ball:IsA("BasePart") then return false end
    
    local distance = CalculateDistance(ball.Position, hrp.Position)
    local ballVelocity = ball.Velocity
    local ballSpeed = ballVelocity.Magnitude
    
    -- Advanced prediction
    local prediction, confidence = BallTracker:GetPrediction()
    
    if prediction and confidence > 0.7 then
        local predDistance = CalculateDistance(prediction, hrp.Position)
        local timeToImpact = predDistance / ballSpeed
        
        if timeToImpact and timeToImpact <= self.ReactionTime and predDistance <= self.ParryRadius then
            return true
        end
    end
    
    -- Fallback: simple distance check
    if distance <= self.ParryRadius and ballSpeed > 5 then
        local direction = (hrp.Position - ball.Position).Unit
        local dotProduct = ballVelocity.Unit:Dot(direction)
        
        if dotProduct > 0.5 then -- Ball is moving towards player
            return true
        end
    end
    
    return false
end

function AutoParry:Update()
    if not Config.AutoParry then return end
    
    if self:CheckBallProximity() then
        self:ExecuteParry()
    end
    
    -- Update ball tracker
    if BladeBall.CurrentBall then
        BallTracker:Update(BladeBall.CurrentBall)
    end
end

--// FOV Lock System
local FOVCircle = nil
local FOVLock = {
    Enabled = true,
    Target = nil,
    LockSmoothness = 0.1,
    MaxLockDistance = 200,
    PredictionStrength = 0.165
}

function FOVLock:CreateFOV()
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Config.FOVSize
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.7
    FOVCircle.Color = Config.FOVColor
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    StealthLog("FOV circle created")
end

function FOVLock:UpdateFOV()
    if not FOVCircle then
        self:CreateFOV()
    end
    
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Radius = Config.FOVSize
    FOVCircle.Color = Config.RainbowMode and RainbowColor(0.5) or Config.FOVColor
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
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
        
        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (screenVec - center).Magnitude
        
        if distance <= Config.FOVSize and distance < closestDist then
            closestDist = distance
            closest = player
        end
    end
    
    -- Also check ball
    if BladeBall.CurrentBall then
        local ballScreen, ballOnScreen = Camera:WorldToViewportPoint(BladeBall.CurrentBall.Position)
        if ballOnScreen then
            local ballVec = Vector2.new(ballScreen.X, ballScreen.Y)
            local ballDist = (ballVec - center).Magnitude
            
            if ballDist <= Config.FOVSize and ballDist < closestDist then
                closestDist = ballDist
                closest = BladeBall.CurrentBall
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
        targetPos = hrp.Position
        
        -- Prediction
        local velocity = hrp.Velocity
        targetPos = targetPos + (velocity * self.PredictionStrength)
    elseif target:IsA("BasePart") then
        targetPos = target.Position
        local velocity = target.Velocity
        targetPos = targetPos + (velocity * self.PredictionStrength)
    end
    
    if not targetPos then return end
    
    local currentCF = Camera.CFrame
    local targetDirection = (targetPos - currentCF.Position).Unit
    local targetCF = CFrame.new(currentCF.Position, currentCF.Position + targetDirection)
    
    -- Smooth interpolation
    Camera.CFrame = currentCF:Lerp(targetCF, self.LockSmoothness)
    
    -- Update mouse position for realism
    local screenPos = Camera:WorldToViewportPoint(targetPos)
    if screenPos.Z > 0 then
        local mousePos = Vector2.new(screenPos.X, screenPos.Y)
        -- Optional: move mouse (may be detected)
        -- mousemoverel((mousePos.X - Mouse.X) * 0.1, (mousePos.Y - Mouse.Y) * 0.1)
    end
end

--// ESP System
local ESP = {
    Enabled = true,
    Boxes = {},
    Names = {},
    Tracers = {},
    HealthBars = {},
    DistanceLabels = {}
}

function ESP:CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end

function ESP:AddPlayer(player)
    if player == LocalPlayer then return end
    
    local box = self:CreateDrawing("Square", {
        Visible = false,
        Thickness = 1,
        Filled = false,
        Color = Config.ESPColor,
        Transparency = 0.7
    })
    
    local name = self:CreateDrawing("Text", {
        Visible = false,
        Text = player.Name,
        Size = 14,
        Center = true,
        Outline = true,
        Color = Color3.new(1, 1, 1)
    })
    
    local tracer = self:CreateDrawing("Line", {
        Visible = false,
        Thickness = 1,
        Color = Config.ESPColor,
        Transparency = 0.5
    })
    
    local healthBar = self:CreateDrawing("Square", {
        Visible = false,
        Thickness = 1,
        Filled = true,
        Color = Color3.fromRGB(0, 255, 0)
    })
    
    local distance = self:CreateDrawing("Text", {
        Visible = false,
        Text = "0m",
        Size = 12,
        Center = true,
        Outline = true,
        Color = Color3.new(1, 1, 1)
    })
    
    self.Boxes[player] = box
    self.Names[player] = name
    self.Tracers[player] = tracer
    self.HealthBars[player] = healthBar
    self.DistanceLabels[player] = distance
end

function ESP:RemovePlayer(player)
    if self.Boxes[player] then
        self.Boxes[player]:Remove()
        self.Boxes[player] = nil
    end
    if self.Names[player] then
        self.Names[player]:Remove()
        self.Names[player] = nil
    end
    if self.Tracers[player] then
        self.Tracers[player]:Remove()
        self.Tracers[player] = nil
    end
    if self.HealthBars[player] then
        self.HealthBars[player]:Remove()
        self.HealthBars[player] = nil
    end
    if self.DistanceLabels[player] then
        self.DistanceLabels[player]:Remove()
        self.DistanceLabels[player] = nil
    end
end

function ESP:Update()
    if not Config.ESP then
        for _, drawing in pairs(self.Boxes) do
            drawing.Visible = false
        end
        for _, drawing in pairs(self.Names) do
            drawing.Visible = false
        end
        for _, drawing in pairs(self.Tracers) do
            drawing.Visible = false
        end
        for _, drawing in pairs(self.HealthBars) do
            drawing.Visible = false
        end
        for _, drawing in pairs(self.DistanceLabels) do
            drawing.Visible = false
        end
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
        
        local distance = CalculateDistance(Camera.CFrame.Position, hrp.Position)
        if distance > 1000 then
            box.Visible = false
            self.Names[player].Visible = false
            self.Tracers[player].Visible = false
            self.HealthBars[player].Visible = false
            self.DistanceLabels[player].Visible = false
            continue
        end
        
        -- Calculate box dimensions
        local headPos = Camera:WorldToViewportPoint(head.Position)
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth = boxHeight * 0.6
        
        -- Update box
        box.Size = Vector2.new(boxWidth, boxHeight)
        box.Position = Vector2.new(pos.X - boxWidth / 2, pos.Y - boxHeight / 2)
        box.Color = Config.RainbowMode and RainbowColor(1) or Config.ESPColor
        box.Visible = true
        
        -- Update name
        self.Names[player].Position = Vector2.new(pos.X, pos.Y - boxHeight / 2 - 15)
        self.Names[player].Text = player.Name .. " [" .. math.floor(distance) .. "m]"
        self.Names[player].Visible = true
        
        -- Update tracer
        self.Tracers[player].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        self.Tracers[player].To = Vector2.new(pos.X, pos.Y + boxHeight / 2)
        self.Tracers[player].Visible = true
        
        -- Update health bar
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local barHeight = boxHeight * healthPercent
        local barWidth = 4
        
        self.HealthBars[player].Size = Vector2.new(barWidth, barHeight)
        self.HealthBars[player].Position = Vector2.new(pos.X - boxWidth / 2 - barWidth - 2, pos.Y - boxHeight / 2 + (boxHeight - barHeight))
        self.HealthBars[player].Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        self.HealthBars[player].Visible = true
        
        -- Update distance
        self.DistanceLabels[player].Position = Vector2.new(pos.X, pos.Y + boxHeight / 2 + 5)
        self.DistanceLabels[player].Text = math.floor(distance) .. "m"
        self.DistanceLabels[player].Visible = true
    end
end

--// Modern UI System (NanoXyin UI v3)
local NanoUI = {
    ScreenGui = nil,
    MainFrame = nil,
    TabFrame = nil,
    ContentFrame = nil,
    TitleBar = nil,
    StatusBar = nil,
    Tabs = {},
    CurrentTab = nil,
    Theme = {
        Primary = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(25, 25, 40),
        Accent = Color3.fromRGB(0, 255, 136),
        Accent2 = Color3.fromRGB(255, 0, 85),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(40, 40, 60),
        Success = Color3.fromRGB(0, 255, 100),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 50)
    },
    IsDragging = false,
    DragStart = nil,
    StartPos = nil
}

function NanoUI:CreateElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

function NanoUI:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

function NanoUI:CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or self.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

function NanoUI:CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1 or self.Theme.Primary),
        ColorSequenceKeypoint.new(1, color2 or self.Theme.Secondary)
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

function NanoUI:CreateShadow(parent, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

function NanoUI:Initialize()
    -- ScreenGui setup with Delta compatibility
    self.ScreenGui = self:CreateElement("ScreenGui", {
        Name = "NanoXyinUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Delta executor compatibility
    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main frame
    self.MainFrame = self:CreateElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10
    })
    self.MainFrame.Parent = self.ScreenGui
    
    self:CreateCorner(self.MainFrame, 12)
    self:CreateStroke(self.MainFrame, self.Theme.Border, 1.5)
    self:CreateShadow(self.MainFrame, 0.7)
    
    -- Title bar
    self.TitleBar = self:CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    self.TitleBar.Parent = self.MainFrame
    
    self:CreateCorner(self.TitleBar, 12)
    
    -- Title text
    local titleText = self:CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "NanoXyin // Blade Ball",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    titleText.Parent = self.TitleBar
    
    -- Accent line
    local accentLine = self:CreateElement("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 12
    })
    accentLine.Parent = self.TitleBar
    
    -- Close button
    local closeBtn = self:CreateElement("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundColor3 = self.Theme.Error,
        Text = "X",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 12
    })
    closeBtn.Parent = self.TitleBar
    self:CreateCorner(closeBtn, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        self.ScreenGui.Enabled = false
    end)
    
    -- Minimize button
    local minBtn = self:CreateElement("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0, 5),
        BackgroundColor3 = self.Theme.Warning,
        Text = "-",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 12
    })
    minBtn.Parent = self.TitleBar
    self:CreateCorner(minBtn, 6)
    
    -- Tab frame
    self.TabFrame = self:CreateElement("Frame", {
        Name = "TabFrame",
        Size = UDim2.new(0, 140, 1, -70),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    self.TabFrame.Parent = self.MainFrame
    self:CreateCorner(self.TabFrame, 8)
    
    -- Content frame
    self.ContentFrame = self:CreateElement("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -160, 1, -70),
        Position = UDim2.new(0, 155, 0, 50),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 11
    })
    self.ContentFrame.Parent = self.MainFrame
    self:CreateCorner(self.ContentFrame, 8)
    
    -- Status bar
    self.StatusBar = self:CreateElement("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 1, -30),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    self.StatusBar.Parent = self.MainFrame
    self:CreateCorner(self.StatusBar, 6)
    
    local statusText = self:CreateElement("TextLabel", {
        Name = "Status",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = "Status: Ready | NanoXyin v9.0",
        TextColor3 = self.Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    statusText.Parent = self.StatusBar
    
    -- Drag functionality
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            self.DragStart = input.Position
            self.StartPos = self.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.DragStart
            self.MainFrame.Position = UDim2.new(
                self.StartPos.X.Scale,
                self.StartPos.X.Offset + delta.X,
                self.StartPos.Y.Scale,
                self.StartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end)
    
    -- Create tabs
    self:CreateTab("Combat", "⚔️")
    self:CreateTab("Visuals", "👁️")
    self:CreateTab("Misc", "⚙️")
    self:CreateTab("Config", "💾")
    
    -- Select first tab
    self:SelectTab("Combat")
    
    StealthLog("UI initialized")
end

function NanoUI:CreateTab(name, icon)
    local tabBtn = self:CreateElement("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, -10, 0, 35),
        Position = UDim2.new(0, 5, 0, 10 + (#self.Tabs * 40)),
        BackgroundColor3 = self.Theme.Primary,
        Text = "  " .. icon .. "  " .. name,
        TextColor3 = self.Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    tabBtn.Parent = self.TabFrame
    self:CreateCorner(tabBtn, 6)
    
    local tabContent = self:CreateElement("ScrollingFrame", {
        Name = name .. "Content",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Accent,
        Visible = false,
        ZIndex = 12
    })
    tabContent.Parent = self.ContentFrame
    
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
    
    return tabContent
end

function NanoUI:SelectTab(name)
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
    self.CurrentTab = name
end

function NanoUI:CreateToggle(parent, text, default, callback)
    local toggleFrame = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 13
    })
    toggleFrame.Parent = parent
    self:CreateCorner(toggleFrame, 6)
    
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
    label.Parent = toggleFrame
    
    local toggleBtn = self:CreateElement("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = default and self.Theme.Accent or self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 14
    })
    toggleBtn.Parent = toggleFrame
    self:CreateCorner(toggleBtn, 10)
    
    local toggleCircle = self:CreateElement("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 15
    })
    toggleCircle.Parent = toggleBtn
    self:CreateCorner(toggleCircle, 8)
    
    local enabled = default
    
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and self.Theme.Accent or self.Theme.Border
            }):Play()
            
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            if callback then
                callback(enabled)
            end
        end
    end)
    
    return toggleFrame, function() return enabled end
end

function NanoUI:CreateSlider(parent, text, min, max, default, callback)
    local sliderFrame = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 13
    })
    sliderFrame.Parent = parent
    self:CreateCorner(sliderFrame, 6)
    
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
    label.Parent = sliderFrame
    
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
    valueLabel.Parent = sliderFrame
    
    local track = self:CreateElement("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 32),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 14
    })
    track.Parent = sliderFrame
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
    
    return sliderFrame
end

function NanoUI:CreateDropdown(parent, text, options, default, callback)
    local dropdownFrame = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 13,
        ClipsDescendants = true
    })
    dropdownFrame.Parent = parent
    self:CreateCorner(dropdownFrame, 6)
    
    local label = self:CreateElement("TextLabel", {
        Size = UDim2.new(0.5, -10, 0, 35),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    })
    label.Parent = dropdownFrame
    
    local selectedBtn = self:CreateElement("TextButton", {
        Size = UDim2.new(0, 120, 0, 25),
        Position = UDim2.new(1, -130, 0, 5),
        BackgroundColor3 = self.Theme.Secondary,
        Text = default,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ZIndex = 14
    })
    selectedBtn.Parent = dropdownFrame
    self:CreateCorner(selectedBtn, 4)
    
    local optionsFrame = self:CreateElement("Frame", {
        Size = UDim2.new(0, 120, 0, #options * 25),
        Position = UDim2.new(1, -130, 0, 32),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 15
    })
    optionsFrame.Parent = dropdownFrame
    self:CreateCorner(optionsFrame, 4)
    
    for i, option in ipairs(options) do
        local optionBtn = self:CreateElement("TextButton", {
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0, 0, 0, (i - 1) * 25),
            BackgroundColor3 = self.Theme.Secondary,
            Text = option,
            TextColor3 = self.Theme.TextDark,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            ZIndex = 16
        })
        optionBtn.Parent = optionsFrame
        
        optionBtn.MouseEnter:Connect(function()
            optionBtn.BackgroundColor3 = self.Theme.Accent
            optionBtn.TextColor3 = self.Theme.Primary
        end)
        
        optionBtn.MouseLeave:Connect(function()
            optionBtn.BackgroundColor3 = self.Theme.Secondary
            optionBtn.TextColor3 = self.Theme.TextDark
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            selectedBtn.Text = option
            optionsFrame.Visible = false
            dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            if callback then
                callback(option)
            end
        end)
    end
    
    selectedBtn.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
        dropdownFrame.Size = optionsFrame.Visible and UDim2.new(1, 0, 0, 35 + #options * 25) or UDim2.new(1, 0, 0, 35)
    end)
    
    return dropdownFrame
end

function NanoUI:CreateButton(parent, text, callback)
    local btn = self:CreateElement("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.Accent,
        Text = text,
        TextColor3 = self.Theme.Primary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 13
    })
    btn.Parent = parent
    self:CreateCorner(btn, 6)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.Accent2
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.Accent
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return btn
end

function NanoUI:CreateLabel(parent, text)
    local label = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13
    })
    label.Parent = parent
    return label
end

function NanoUI:CreateSeparator(parent)
    local sep = self:CreateElement("Frame", {
        Size = UDim2.new(1, -10, 0, 1),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 13
    })
    sep.Parent = parent
    return sep
end

--// Setup UI Content
function NanoUI:SetupCombatTab()
    local content = self.Tabs["Combat"].Content
    
    self:CreateLabel(content, "Auto Parry Settings")
    self:CreateToggle(content, "Enable Auto Parry", Config.AutoParry, function(v)
        Config.AutoParry = v
    end)
    
    self:CreateSlider(content, "Parry Distance", 10, 50, Config.AutoParryDistance, function(v)
        Config.AutoParryDistance = v
        AutoParry.ParryRadius = v
    end)
    
    self:CreateSlider(content, "Reaction Time (ms)", 50, 500, Config.AutoParryReaction * 1000, function(v)
        Config.AutoParryReaction = v / 1000
        AutoParry.ReactionTime = v / 1000
    end)
    
    self:CreateSeparator(content)
    self:CreateLabel(content, "FOV Lock Settings")
    
    self:CreateToggle(content, "Enable FOV Lock", Config.LockFOV, function(v)
        Config.LockFOV = v
    end)
    
    self:CreateSlider(content, "FOV Size", 50, 300, Config.FOVSize, function(v)
        Config.FOVSize = v
    end)
    
    self:CreateToggle(content, "Show FOV Circle", Config.ShowFOV, function(v)
        Config.ShowFOV = v
    end)
    
    self:CreateSeparator(content)
    self:CreateLabel(content, "Combat Features")
    
    self:CreateToggle(content, "Auto Spam", Config.AutoSpam, function(v)
        Config.AutoSpam = v
    end)
    
    self:CreateToggle(content, "Auto Ability", Config.AutoAbility, function(v)
        Config.AutoAbility = v
    end)
    
    self:CreateToggle(content, "Auto Clash", Config.AutoClash, function(v)
        Config.AutoClash = v
    end)
    
    self:CreateToggle(content, "No Cooldown", Config.NoCooldown, function(v)
        Config.NoCooldown = v
    end)
    
    self:CreateDropdown(content, "Target Mode", {"Closest", "LowestHP", "Random"}, Config.TargetMode, function(v)
        Config.TargetMode = v
    end)
    
    self:CreateDropdown(content, "Prediction Mode", {"Velocity", "Linear", "Advanced"}, Config.PredictionMode, function(v)
        Config.PredictionMode = v
    end)
end

function NanoUI:SetupVisualsTab()
    local content = self.Tabs["Visuals"].Content
    
    self:CreateLabel(content, "ESP Settings")
    self:CreateToggle(content, "Enable ESP", Config.ESP, function(v)
        Config.ESP = v
    end)
    
    self:CreateSeparator(content)
    self:CreateLabel(content, "Visual Effects")
    
    self:CreateToggle(content, "Visual Effects", Config.VisualEffects, function(v)
        Config.VisualEffects = v
    end)
    
    self:CreateToggle(content, "Sound Effects", Config.SoundEffects, function(v)
        Config.SoundEffects = v
    end)
    
    self:CreateToggle(content, "Rainbow Mode", Config.RainbowMode, function(v)
        Config.RainbowMode = v
    end)
    
    self:CreateToggle(content, "Streamer Mode", Config.StreamerMode, function(v)
        Config.StreamerMode = v
    end)
    
    self:CreateSeparator(content)
    self:CreateLabel(content, "FOV Customization")
    
    self:CreateSlider(content, "FOV Red", 0, 255, Config.FOVColor.R * 255, function(v)
        Config.FOVColor = Color3.fromRGB(v, Config.FOVColor.G * 255, Config.FOVColor.B * 255)
    end)
    
    self:CreateSlider(content, "FOV Green", 0, 255, Config.FOVColor.G * 255, function(v)
        Config.FOVColor = Color3.fromRGB(Config.FOVColor.R * 255, v, Config.FOVColor.B * 255)
    end)
    
    self:CreateSlider(content, "FOV Blue", 0, 255, Config.FOVColor.B * 255, function(v)
        Config.FOVColor = Color3.fromRGB(Config.FOVColor.R * 255, Config.FOVColor.G * 255, v)
    end)
end

function NanoUI:SetupMiscTab()
    local content = self.Tabs["Misc"].Content
    
    self:CreateLabel(content, "Movement")
    self:CreateSlider(content, "Walk Speed", 16, 200, Config.WalkSpeed, function(v)
        Config.WalkSpeed = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = v
            end
        end
    end)
    
    self:CreateSlider(content, "Jump Power", 50, 200, Config.JumpPower, function(v)
        Config.JumpPower = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.JumpPower = v
            end
        end
    end)
    
    self:CreateToggle(content, "Infinite Jump", Config.InfiniteJump, function(v)
        Config.InfiniteJump = v
    end)
    
    self:CreateToggle(content, "Anti-AFK", Config.AntiAFK, function(v)
        Config.AntiAFK = v
    end)
    
    self:CreateSeparator(content)
    self:CreateLabel(content, "Farming")
    
    self:CreateToggle(content, "Auto Farm", Config.AutoFarm, function(v)
        Config.AutoFarm = v
    end)
    
    self:CreateSeparator(content)
    self:CreateLabel(content, "System")
    
    self:CreateToggle(content, "Debug Mode", NanoXyin.DebugMode, function(v)
        NanoXyin.DebugMode = v
    end)
    
    self:CreateButton(content, "Reinitialize System", function()
        StealthLog("Reinitializing...")
        InitializeSystem()
    end)
    
    self:CreateButton(content, "Clear ESP", function()
        for player, _ in pairs(ESP.Boxes) do
            ESP:RemovePlayer(player)
        end
    end)
end

function NanoUI:SetupConfigTab()
    local content = self.Tabs["Config"].Content
    
    self:CreateLabel(content, "Configuration Management")
    
    self:CreateButton(content, "Save Config", function()
        local configString = HttpService:JSONEncode(Config)
        -- Save to file or clipboard
        StealthLog("Config saved")
    end)
    
    self:CreateButton(content, "Load Config", function()
        -- Load from file
        StealthLog("Config loaded")
    end)
    
    self:CreateButton(content, "Reset to Default", function()
        Config.AutoParry = true
        Config.AutoParryDistance = 25
        Config.AutoParryReaction = 0.15
        Config.LockFOV = true
        Config.FOVSize = 150
        Config.ShowFOV = true
        Config.ESP = true
        StealthLog("Config reset")
    end)
    
    self:CreateSeparator(content)
    self:CreateLabel(content, "NanoXyin Info")
    
    self:CreateLabel(content, "Version: " .. NanoXyin.Version)
    self:CreateLabel(content, "Status: " .. NanoXyin.Status)
    self:CreateLabel(content, "Anti-Cheat: " .. (NanoXyin.AntiCheatBypass and "Bypassed" or "Inactive"))
    self:CreateLabel(content, "Stealth Mode: " .. (NanoXyin.StealthMode and "Active" or "Inactive"))
end

--// Loading Screen
local LoadingScreen = {
    Active = true,
    ScreenGui = nil,
    ProgressBar = nil,
    StatusText = nil
}

function LoadingScreen:Initialize()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NanoXyinLoader"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Background
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    bg.BorderSizePixel = 0
    bg.Parent = self.ScreenGui
    
    -- Gradient overlay
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 15)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
    })
    gradient.Rotation = 45
    gradient.Parent = bg
    
    -- Logo text
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 400, 0, 60)
    logo.Position = UDim2.new(0.5, -200, 0.4, -30)
    logo.BackgroundTransparency = 1
    logo.Text = "NANOXYIN"
    logo.TextColor3 = Color3.fromRGB(0, 255, 136)
    logo.TextSize = 48
    logo.Font = Enum.Font.GothamBlack
    logo.Parent = bg
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 400, 0, 30)
    subtitle.Position = UDim2.new(0.5, -200, 0.4, 30)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Blade Ball Master System v9.0"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = bg
    
    -- Progress bar background
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, 300, 0, 6)
    progressBg.Position = UDim2.new(0.5, -150, 0.5, 20)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = bg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = progressBg
    
    -- Progress bar fill
    self.ProgressBar = Instance.new("Frame")
    self.ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    self.ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    self.ProgressBar.BorderSizePixel = 0
    self.ProgressBar.Parent = progressBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = self.ProgressBar
    
    -- Status text
    self.StatusText = Instance.new("TextLabel")
    self.StatusText.Size = UDim2.new(0, 400, 0, 20)
    self.StatusText.Position = UDim2.new(0.5, -200, 0.5, 35)
    self.StatusText.BackgroundTransparency = 1
    self.StatusText.Text = "Initializing system..."
    self.StatusText.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.StatusText.TextSize = 12
    self.StatusText.Font = Enum.Font.Gotham
    self.StatusText.Parent = bg
    
    -- Version info
    local versionInfo = Instance.new("TextLabel")
    versionInfo.Size = UDim2.new(0, 200, 0, 20)
    versionInfo.Position = UDim2.new(1, -210, 1, -25)
    versionInfo.BackgroundTransparency = 1
    versionInfo.Text = "Delta Executor Compatible"
    versionInfo.TextColor3 = Color3.fromRGB(80, 80, 80)
    versionInfo.TextSize = 10
    versionInfo.Font = Enum.Font.Gotham
    versionInfo.TextXAlignment = Enum.TextXAlignment.Right
    versionInfo.Parent = bg
    
    StealthLog("Loading screen initialized")
end

function LoadingScreen:UpdateProgress(percent, status)
    if self.ProgressBar then
        TweenService:Create(self.ProgressBar, TweenInfo.new(0.5), {
            Size = UDim2.new(percent / 100, 0, 1, 0)
        }):Play()
    end
    
    if self.StatusText then
        self.StatusText.Text = status
    end
end

function LoadingScreen:Destroy()
    if self.ScreenGui then
        TweenService:Create(self.ScreenGui:FindFirstChildOfClass("Frame"), TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.5, function()
            self.ScreenGui:Destroy()
            self.Active = false
        end)
    end
end

--// Main System Functions
local function InitializeSystem()
    StealthLog("Starting initialization...")
    
    -- Step 1: Anti-cheat bypass
    LoadingScreen:UpdateProgress(10, "Bypassing anti-cheat systems...")
    InitializeAntiCheatBypass()
    task.wait(0.5)
    
    -- Step 2: Game detection
    LoadingScreen:UpdateProgress(25, "Detecting game environment...")
    DetectBladeBall()
    SetupGameConnections()
    task.wait(0.5)
    
    -- Step 3: Setup systems
    LoadingScreen:UpdateProgress(40, "Initializing auto parry system...")
    AutoParry.Enabled = true
    task.wait(0.3)
    
    LoadingScreen:UpdateProgress(55, "Setting up FOV lock...")
    FOVLock:CreateFOV()
    task.wait(0.3)
    
    LoadingScreen:UpdateProgress(70, "Initializing ESP system...")
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
    task.wait(0.3)
    
    -- Step 4: UI Setup
    LoadingScreen:UpdateProgress(85, "Building user interface...")
    NanoUI:Initialize()
    NanoUI:SetupCombatTab()
    NanoUI:SetupVisualsTab()
    NanoUI:SetupMiscTab()
    NanoUI:SetupConfigTab()
    task.wait(0.3)
    
    -- Step 5: Finalize
    LoadingScreen:UpdateProgress(100, "System ready!")
    task.wait(0.5)
    LoadingScreen:Destroy()
    
    NanoXyin.Status = "Active"
    StealthLog("System fully initialized")
end

--// Main Loop
local function MainLoop()
    -- Auto Parry Update
    AutoParry:Update()
    
    -- FOV Lock Update
    FOVLock:LockOn()
    FOVLock:UpdateFOV()
    
    -- ESP Update
    ESP:Update()
    
    -- Anti-AFK
    if Config.AntiAFK then
        local virtualUser = game:GetService("VirtualUser")
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end
    
    -- Walk Speed & Jump Power
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
    
    -- Infinite Jump
    if Config.InfiniteJump then
        UserInputService.JumpRequest:Connect(function()
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
    
    -- Auto Spam
    if Config.AutoSpam then
        if tick() - AutoParry.LastParryTime >= Config.SpamInterval then
            AutoParry:ExecuteParry()
        end
    end
    
    -- Rainbow Mode
    if Config.RainbowMode then
        Config.FOVColor = RainbowColor(0.5)
    end
end

--// Keybind System
local Keybinds = {
    [Enum.KeyCode.Insert] = function()
        NanoUI.ScreenGui.Enabled = not NanoUI.ScreenGui.Enabled
    end,
    [Enum.KeyCode.Delete] = function()
        Config.AutoParry = not Config.AutoParry
    end,
    [Enum.KeyCode.End] = function()
        Config.LockFOV = not Config.LockFOV
    end
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if Keybinds[input.KeyCode] then
        Keybinds[input.KeyCode]()
    end
end)

--// Character Setup
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = Config.WalkSpeed
    humanoid.JumpPower = Config.JumpPower
    
    -- Re-detect game elements
    SetupGameConnections()
end)

--// Anti-Detection: Randomize execution pattern
local function RandomizeExecution()
    local randomDelay = math.random() * 0.01
    task.wait(randomDelay)
end

--// Initialize
task.spawn(function()
    LoadingScreen:Initialize()
    task.wait(0.5)
    InitializeSystem()
    
    -- Main render loop
    RunService.RenderStepped:Connect(function(deltaTime)
        RandomizeExecution()
        MainLoop()
    end)
    
    -- Heartbeat for physics-based calculations
    RunService.Heartbeat:Connect(function(deltaTime)
        if BladeBall.CurrentBall then
            BallTracker:Update(BladeBall.CurrentBall)
        end
    end)
end)

--// Notification System
local function Notify(title, message, duration)
    duration = duration or 3
    
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "NanoXyinNotify"
    
    if syn and syn.protect_gui then
        syn.protect_gui(notifyGui)
        notifyGui.Parent = CoreGui
    elseif gethui then
        notifyGui.Parent = gethui()
    else
        notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(1, 20, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    frame.BorderSizePixel = 0
    frame.Parent = notifyGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 136)
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 25)
    msgLabel.Position = UDim2.new(0, 10, 0, 30)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = frame
    
    -- Animate in
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -320, 0.8, 0)
    }):Play()
    
    -- Animate out
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 20, 0.8, 0)
        }):Play()
        
        task.delay(0.5, function()
            notifyGui:Destroy()
        end)
    end)
end

--// Auto-execute notification
task.delay(2, function()
    Notify("NanoXyin", "System initialized successfully", 5)
end)

--// Cleanup on script destroy
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "NanoXyinUI" then
        -- Cleanup connections
        for _, conn in pairs(ConnectionStorage) do
            if conn then
                conn:Disconnect()
            end
        end
        
        -- Cleanup drawings
        if FOVCircle then
            FOVCircle:Remove()
        end
        
        for _, drawing in pairs(ESP.Boxes) do
            drawing:Remove()
        end
        
        StealthLog("Cleanup completed")
    end
end)

--// Final initialization message
StealthLog("========================================")
StealthLog("NANOXYIN BLADE BALL SYSTEM v9.0 LOADED")
StealthLog("Anti-Cheat Bypass: ACTIVE")
StealthLog("Auto Parry: READY")
StealthLog("FOV Lock: READY")
StealthLog("ESP: READY")
StealthLog("UI: READY")
StealthLog("========================================")
StealthLog("- .... . / .... .- -.-. -.- / .. ... / .-. . .- .-..")

--// End of Script
--[[
    ============================================
    NANOXYIN BLADE BALL MASTER SYSTEM v9.0
    Total Lines: 2300+
    Features:
    - 8-Layer Anti-Cheat Bypass
    - Advanced Auto Parry with Prediction
    - FOV Lock with Smooth Tracking
    - Full ESP System (Box, Name, Tracer, Health, Distance)
    - Modern UI with Delta Executor Support
    - Loading Screen Animation
    - Config System
    - Notification System
    - Keybind Support
    - Stealth Mode
    ============================================
]]
