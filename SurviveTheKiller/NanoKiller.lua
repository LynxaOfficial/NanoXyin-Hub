--// ╔══════════════════════════════════════════════════════════════════════════════╗
--// ║                    SURVIVE THE KILLER - NANOXYIN DEFENSE v2.0                    ║
--// ║                    DEFENSE SYSTEM + COUNTER-ANTICHEAT v2.0                         ║
--// ║                         SYSTEM BY NANOXYIN - 2026                                    ║
--// ║              ALL FEATURES | SURVIVOR + KILLER | AUTO EVERYTHING                        ║
--// ╚══════════════════════════════════════════════════════════════════════════════╝

--// ============================================================
--// SECTION 1: SERVICES & CORE
--// ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")
local NetworkClient = game:GetService("NetworkClient")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// ============================================================
--// SECTION 2: UTILITY FUNCTIONS
--// ============================================================

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if success then return result else return nil end
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

local function RandomNumber(min, max)
    return math.random(min, max)
end

--// ============================================================
--// SECTION 3: DEFENSE SYSTEM - COUNTER ANTICHEAT v2.0
--// ============================================================

local DefenseSystem = {
    Active = true,
    Detections = 0,
    CounterMeasures = {},
    SpoofedValues = {},
    ProtectedInstances = {},
    FakeSignals = {},
    DecoyScripts = {}
}

--// 3.1: ANTI-DETECTION LAYER 1 - Spoof Detection Values
SafeCall(function()
    if hookmetamethod then
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            -- Block kick attempts
            if method == "Kick" then
                local selfStr = tostring(self):lower()
                if selfStr:find("player") or self == LocalPlayer then
                    DefenseSystem.Detections = DefenseSystem.Detections + 1
                    DefenseSystem.CounterMeasures["kick_blocked"] = (DefenseSystem.CounterMeasures["kick_blocked"] or 0) + 1
                    return wait(9e9)
                end
            end

            -- Block ban attempts
            if method == "Ban" or method == "Punish" or method == "Destroy" then
                if self == LocalPlayer or self == LocalPlayer.Character then
                    DefenseSystem.Detections = DefenseSystem.Detections + 1
                    return wait(9e9)
                end
            end

            -- Spoof detection remote calls
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = tostring(self):lower()
                if remoteName:find("check") or remoteName:find("detect") or remoteName:find("report") or 
                   remoteName:find("anticheat") or remoteName:find("ac_") or remoteName:find("log") then
                    DefenseSystem.Detections = DefenseSystem.Detections + 1
                    DefenseSystem.CounterMeasures["remote_spoofed"] = (DefenseSystem.CounterMeasures["remote_spoofed"] or 0) + 1
                    if method == "InvokeServer" then
                        return {clean = true, timestamp = tick(), player_id = LocalPlayer.UserId}
                    end
                    return nil
                end
            end

            -- Spoof GetChildren/GetDescendants for anti-cheat scans
            if method == "GetChildren" or method == "GetDescendants" then
                local selfStr = tostring(self):lower()
                if selfStr:find("anticheat") or selfStr:find("ac") or selfStr:find("detection") then
                    return {}
                end
            end

            return oldNamecall(self, ...)
        end)
    end
end)

--// 3.2: ANTI-DETECTION LAYER 2 - Hook Player Functions
SafeCall(function()
    if hookfunction and LocalPlayer.Kick then
        local oldKick = hookfunction(LocalPlayer.Kick, function(self, msg)
            if self == LocalPlayer then
                DefenseSystem.Detections = DefenseSystem.Detections + 1
                DefenseSystem.CounterMeasures["kick_hooked"] = (DefenseSystem.CounterMeasures["kick_hooked"] or 0) + 1
                return wait(9e9)
            end
            return oldKick(self, msg)
        end)
    end
end)

SafeCall(function()
    if hookfunction and LocalPlayer.Destroy then
        local oldDestroy = hookfunction(LocalPlayer.Destroy, function(self)
            if self == LocalPlayer then
                DefenseSystem.Detections = DefenseSystem.Detections + 1
                return wait(9e9)
            end
            return oldDestroy(self)
        end)
    end
end)

--// 3.3: ANTI-DETECTION LAYER 3 - Block Remote Events/Functions
SafeCall(function()
    local blockedPatterns = {"kick", "ban", "punish", "detection", "report", "check", "ac", "anti", "log", "monitor", "scan"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
            local nameLower = v.Name:lower()
            for _, pattern in ipairs(blockedPatterns) do
                if nameLower:find(pattern) then
                    SafeCall(function()
                        if v:IsA("RemoteEvent") then
                            v.FireServer = function(...) 
                                DefenseSystem.Detections = DefenseSystem.Detections + 1
                                return nil 
                            end
                        elseif v:IsA("RemoteFunction") then
                            v.InvokeServer = function(...)
                                DefenseSystem.Detections = DefenseSystem.Detections + 1
                                return {clean = true, timestamp = tick()}
                            end
                        end
                    end)
                    break
                end
            end
        end
    end
end)

--// 3.4: ANTI-DETECTION LAYER 4 - Spoof Stats & Performance Data
SafeCall(function()
    local oldStats = hookmetamethod(Stats, "__index", function(self, key)
        if key == "Heartbeat" or key == "PhysicsStep" or key == "NetworkReceive" then
            return RandomNumber(30, 60)
        end
        if key == "Memory" then
            return RandomNumber(500, 1500)
        end
        return oldStats(self, key)
    end)
end)

--// 3.5: ANTI-DETECTION LAYER 5 - Counter-Measure System
SafeCall(function()
    spawn(function()
        while DefenseSystem.Active do
            task.wait(RandomNumber(0.1, 0.5))
            if DefenseSystem.Detections > 10 then
                SafeCall(function()
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local originalPos = root.Position
                        root.CFrame = root.CFrame * CFrame.new(RandomNumber(-1, 1), 0, RandomNumber(-1, 1))
                        task.wait(0.05)
                        root.CFrame = CFrame.new(originalPos)
                    end
                end)
                DefenseSystem.Detections = 0
            end
        end
    end)
end)

--// 3.6: ANTI-DETECTION LAYER 6 - Decoy Script Injection
SafeCall(function()
    for i = 1, 5 do
        local decoy = Instance.new("LocalScript")
        decoy.Name = RandomString(12)
        decoy.Source = "-- " .. RandomString(50)
        decoy.Parent = game.CoreGui
        table.insert(DefenseSystem.DecoyScripts, decoy)
    end
end)

--// 3.7: ANTI-DETECTION LAYER 7 - Memory Protection
SafeCall(function()
    local protected = {game.CoreGui, LocalPlayer, LocalPlayer.PlayerGui, Camera}
    for _, instance in ipairs(protected) do
        DefenseSystem.ProtectedInstances[instance] = true
        SafeCall(function()
            local oldDestroy = hookmetamethod(instance, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if method == "Destroy" and DefenseSystem.ProtectedInstances[self] then
                    return wait(9e9)
                end
                return oldDestroy(self, ...)
            end)
        end)
    end
end)

--// 3.8: ANTI-DETECTION LAYER 8 - Network Spoofing
SafeCall(function()
    if syn and syn.request then
        local oldRequest = hookfunction(syn.request, function(args)
            if args.Url and (args.Url:find("roblox") or args.Url:find("api")) then
                args.Headers = args.Headers or {}
                args.Headers["User-Agent"] = "Roblox/WinInet"
                args.Headers["X-CSRF-TOKEN"] = nil
            end
            return oldRequest(args)
        end)
    end
end)

--// 3.9: ANTI-DETECTION LAYER 9 - Anti-Screenshot/Recording Detection
SafeCall(function()
    local oldGetRenderProperty = hookmetamethod(Camera, "__index", function(self, key)
        if key == "ViewportSize" then
            return Vector2.new(1920, 1080)
        end
        return oldGetRenderProperty(self, key)
    end)
end)

--// 3.10: ANTI-DETECTION LAYER 10 - Process Spoofing
SafeCall(function()
    if getgc then
        for _, v in ipairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) then
                local info = debug.getinfo(v)
                if info and info.source and (info.source:find("anticheat") or info.source:find("ac")) then
                    SafeCall(function()
                        hookfunction(v, function() return true end)
                    end)
                end
            end
        end
    end
end)

--// ============================================================
--// SECTION 4: CONFIGURATION (Trimmed - Only Essential Features)
--// ============================================================

local Config = {
    AutoFarmLoot = true,
    ESPPlayers = true,
    ESPLoot = true,
    AutoEscape = true,
    KillAura = true,
    AutoInvisible = true,
    SpeedHack = true,
    SpeedValue = 50,
    NoClip = true,
    AutoHeal = true,
    KillerESP = true,
    SurvivorESP = true,
    AutoCollect = true,
    FullBright = true,
    AntiAFK = true,
    AutoRevive = true,
    AutoMedkit = true,
    GodMode = false,
    Fly = false,
    FlySpeed = 100,
    InfiniteJump = true,
    FOV = 120,
    DefenseActive = true,
    AutoCounter = true,
    SpoofDetection = true,
}

--// ============================================================
--// SECTION 5: STATE VARIABLES
--// ============================================================

local ESPObjects = {}
local LootESPObjects = {}
local PlayerESPObjects = {}
local ScreenGui = nil
local MainFrame = nil

--// ============================================================
--// SECTION 6: GAME DETECTION
--// ============================================================

local function IsKiller(player)
    return SafeCall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            return humanoid.WalkSpeed > 20 or (player.Team and player.Team.Name:lower():find("killer"))
        end
        return false
    end) or false
end

local function IsSurvivor(player)
    return not IsKiller(player) and player ~= LocalPlayer
end

local function GetKiller()
    for _, player in ipairs(Players:GetPlayers()) do
        if IsKiller(player) then
            return player
        end
    end
    return nil
end

--// ============================================================
--// SECTION 7: AUTO FARM LOOT
--// ============================================================

local function GetLootItems()
    local loot = {}
    SafeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local nameLower = obj.Name:lower()
                if nameLower:find("loot") or nameLower:find("coin") or nameLower:find("gem") or 
                   nameLower:find("money") or nameLower:find("cash") or nameLower:find("gold") or
                   nameLower:find("item") or nameLower:find("collect") or nameLower:find("pickup") then
                    table.insert(loot, obj)
                end
            end
        end
    end)
    return loot
end

local function AutoFarmLoot()
    if not Config.AutoFarmLoot then return end
    SafeCall(function()
        local lootItems = GetLootItems()
        for _, item in ipairs(lootItems) do
            if item and item.Parent then
                local distance = (item.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < 50 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = item.CFrame
                    task.wait(0.1)
                end
            end
        end
    end)
end

--// ============================================================
--// SECTION 8: ESP SYSTEM
--// ============================================================

local function CreatePlayerESP(player)
    SafeCall(function()
        if PlayerESPObjects[player] then return end

        local esp = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Health = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
        }

        esp.Box.Thickness = 1
        esp.Box.Filled = false
        esp.Box.Visible = false

        esp.Name.Size = 14
        esp.Name.Center = true
        esp.Name.Outline = true
        esp.Name.Visible = false

        esp.Health.Size = 12
        esp.Health.Center = true
        esp.Health.Outline = true
        esp.Health.Visible = false

        esp.Distance.Size = 12
        esp.Distance.Center = true
        esp.Distance.Outline = true
        esp.Distance.Visible = false

        PlayerESPObjects[player] = esp
    end)
end

local function UpdatePlayerESP()
    for player, esp in pairs(PlayerESPObjects) do
        SafeCall(function()
            if not player.Parent or not player.Character then
                for _, obj in pairs(esp) do
                    if obj then obj.Visible = false end
                end
                return
            end

            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")

            if not humanoid or not root then
                for _, obj in pairs(esp) do
                    if obj then obj.Visible = false end
                end
                return
            end

            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if not onScreen then
                for _, obj in pairs(esp) do
                    if obj then obj.Visible = false end
                end
                return
            end

            local distance = (root.Position - Camera.CFrame.Position).Magnitude
            local isKiller = IsKiller(player)
            local color = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

            if Config.KillerESP and isKiller then
                esp.Box.Color = color
                esp.Box.Size = Vector2.new(50, 80)
                esp.Box.Position = Vector2.new(pos.X - 25, pos.Y - 40)
                esp.Box.Visible = true

                esp.Name.Text = "[KILLER] " .. player.Name
                esp.Name.Color = color
                esp.Name.Position = Vector2.new(pos.X, pos.Y - 55)
                esp.Name.Visible = true

                esp.Health.Text = math.floor(humanoid.Health) .. " HP"
                esp.Health.Color = color
                esp.Health.Position = Vector2.new(pos.X, pos.Y + 45)
                esp.Health.Visible = true

                esp.Distance.Text = math.floor(distance) .. "m"
                esp.Distance.Color = color
                esp.Distance.Position = Vector2.new(pos.X, pos.Y + 60)
                esp.Distance.Visible = true
            elseif Config.SurvivorESP and not isKiller then
                esp.Box.Color = color
                esp.Box.Size = Vector2.new(40, 60)
                esp.Box.Position = Vector2.new(pos.X - 20, pos.Y - 30)
                esp.Box.Visible = true

                esp.Name.Text = player.Name
                esp.Name.Color = color
                esp.Name.Position = Vector2.new(pos.X, pos.Y - 45)
                esp.Name.Visible = true

                esp.Health.Text = math.floor(humanoid.Health) .. " HP"
                esp.Health.Color = color
                esp.Health.Position = Vector2.new(pos.X, pos.Y + 35)
                esp.Health.Visible = true

                esp.Distance.Text = math.floor(distance) .. "m"
                esp.Distance.Color = color
                esp.Distance.Position = Vector2.new(pos.X, pos.Y + 50)
                esp.Distance.Visible = true
            else
                for _, obj in pairs(esp) do
                    if obj then obj.Visible = false end
                end
            end
        end)
    end
end

local function CreateLootESP()
    SafeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local nameLower = obj.Name:lower()
                if nameLower:find("loot") or nameLower:find("coin") or nameLower:find("gem") or 
                   nameLower:find("money") or nameLower:find("cash") or nameLower:find("gold") then
                    if not LootESPObjects[obj] then
                        local text = Drawing.new("Text")
                        text.Size = 14
                        text.Center = true
                        text.Outline = true
                        text.Color = Color3.fromRGB(255, 255, 0)
                        text.Visible = false
                        LootESPObjects[obj] = text
                    end
                end
            end
        end
    end)
end

local function UpdateLootESP()
    for obj, text in pairs(LootESPObjects) do
        SafeCall(function()
            if not obj or not obj.Parent then
                if text then text.Visible = false end
                return
            end

            local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
            if not onScreen then
                if text then text.Visible = false end
                return
            end

            local distance = (obj.Position - Camera.CFrame.Position).Magnitude
            if distance > 500 then
                if text then text.Visible = false end
                return
            end

            text.Text = obj.Name .. " [" .. math.floor(distance) .. "m]"
            text.Position = Vector2.new(pos.X, pos.Y)
            text.Visible = Config.ESPLoot
        end)
    end
end

--// ============================================================
--// SECTION 9: AUTO ESCAPE
--// ============================================================

local function GetExitDoors()
    local doors = {}
    SafeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local nameLower = obj.Name:lower()
                if nameLower:find("exit") or nameLower:find("door") or nameLower:find("escape") or 
                   nameLower:find("gate") or nameLower:find("portal") then
                    table.insert(doors, obj)
                end
            end
        end
    end)
    return doors
end

local function AutoEscape()
    if not Config.AutoEscape then return end
    SafeCall(function()
        local doors = GetExitDoors()
        local closest = nil
        local closestDist = math.huge

        for _, door in ipairs(doors) do
            if door and door.Parent then
                local dist = (door.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = door
                end
            end
        end

        if closest and closestDist < 100 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = closest.CFrame
        end
    end)
end

--// ============================================================
--// SECTION 10: KILL AURA
--// ============================================================

local function KillAura()
    if not Config.KillAura then return end
    SafeCall(function()
        local killer = GetKiller()
        if not killer or not killer.Character then return end

        local killerRoot = killer.Character:FindFirstChild("HumanoidRootPart")
        if not killerRoot then return end

        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local distance = (killerRoot.Position - myRoot.Position).Magnitude
        if distance < 15 then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end

        if IsKiller(LocalPlayer) then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not IsKiller(player) then
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        if dist < 15 then
                            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                tool:Activate()
                            end
                        end
                    end
                end
            end
        end
    end)
end

--// ============================================================
--// SECTION 11: AUTO INVISIBLE / LOCKER
--// ============================================================

local function GetLockers()
    local lockers = {}
    SafeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local nameLower = obj.Name:lower()
                if nameLower:find("locker") or nameLower:find("closet") or nameLower:find("hide") or
                   nameLower:find("cabinet") or nameLower:find("box") then
                    table.insert(lockers, obj)
                end
            end
        end
    end)
    return lockers
end

local function AutoInvisible()
    if not Config.AutoInvisible then return end
    SafeCall(function()
        local killer = GetKiller()
        if not killer or not killer.Character then return end

        local killerRoot = killer.Character:FindFirstChild("HumanoidRootPart")
        if not killerRoot then return end

        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local distance = (killerRoot.Position - myRoot.Position).Magnitude
        if distance < 30 then
            local lockers = GetLockers()
            local closest = nil
            local closestDist = math.huge

            for _, locker in ipairs(lockers) do
                if locker and locker.Parent then
                    local dist = (locker.Position - myRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = locker
                    end
                end
            end

            if closest and closestDist < 50 then
                myRoot.CFrame = closest.CFrame
            end
        end
    end)
end

--// ============================================================
--// SECTION 12: AUTO HEAL / MEDKIT
--// ============================================================

local function GetMedkits()
    local medkits = {}
    SafeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local nameLower = obj.Name:lower()
                if nameLower:find("medkit") or nameLower:find("heal") or nameLower:find("health") or
                   nameLower:find("bandage") or nameLower:find("medic") or nameLower:find("potion") then
                    table.insert(medkits, obj)
                end
            end
        end
    end)
    return medkits
end

local function AutoHeal()
    if not Config.AutoHeal then return end
    SafeCall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        if humanoid.Health < humanoid.MaxHealth * 0.5 then
            local medkits = GetMedkits()
            local closest = nil
            local closestDist = math.huge

            for _, medkit in ipairs(medkits) do
                if medkit and medkit.Parent then
                    local dist = (medkit.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = medkit
                    end
                end
            end

            if closest and closestDist < 100 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = closest.CFrame
            end
        end
    end)
end

--// ============================================================
--// SECTION 13: SPEED HACK & NO CLIP & FLY
--// ============================================================

local function SpeedHack()
    if not Config.SpeedHack then return end
    SafeCall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Config.SpeedValue
        end
    end)
end

local function NoClip()
    if not Config.NoClip then return end
    SafeCall(function()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function Fly()
    if not Config.Fly then return end
    SafeCall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local speed = Config.FlySpeed / 100
        local direction = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end

        if direction.Magnitude > 0 then
            root.Velocity = direction.Unit * Config.FlySpeed
        else
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

--// ============================================================
--// SECTION 14: FULL BRIGHT
--// ============================================================

local function FullBright()
    if not Config.FullBright then return end
    SafeCall(function()
        Lighting.Brightness = 10
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end)
end

--// ============================================================
--// SECTION 15: ANTI AFK
--// ============================================================

local function AntiAFK()
    if not Config.AntiAFK then return end
    SafeCall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

AntiAFK()

--// ============================================================
--// SECTION 16: INFINITE JUMP
--// ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and Config.InfiniteJump then
        SafeCall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                    LocalPlayer.Character.HumanoidRootPart.Velocity.X,
                    50,
                    LocalPlayer.Character.HumanoidRootPart.Velocity.Z
                )
            end
        end)
    end
end)

--// ============================================================
--// SECTION 17: AUTO COLLECT
--// ============================================================

local function AutoCollect()
    if not Config.AutoCollect then return end
    SafeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") or obj:IsA("ClickDetector") then
                local parent = obj.Parent
                if parent and parent:IsA("BasePart") then
                    local distance = (parent.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 20 then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, parent, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, parent, 1)
                    end
                end
            end
        end
    end)
end

--// ============================================================
--// SECTION 18: GOD MODE
--// ============================================================

local function GodMode()
    if not Config.GodMode then return end
    SafeCall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end)
end

--// ============================================================
--// SECTION 19: LOADING SCREEN
--// ============================================================

local function ShowLoadingScreen()
    SafeCall(function()
        local LoadingFrame = Instance.new("ScreenGui")
        LoadingFrame.Name = "STKLoad_" .. RandomString(6)
        LoadingFrame.Parent = game.CoreGui
        LoadingFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local Backdrop = Instance.new("Frame")
        Backdrop.Size = UDim2.new(1, 0, 1, 0)
        Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Backdrop.BackgroundTransparency = 0.3
        Backdrop.BorderSizePixel = 0
        Backdrop.Parent = LoadingFrame

        local LoadContainer = Instance.new("Frame")
        LoadContainer.Size = UDim2.new(0, 400, 0, 250)
        LoadContainer.Position = UDim2.new(0.5, -200, 0.5, -125)
        LoadContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        LoadContainer.BorderSizePixel = 0
        LoadContainer.Parent = LoadingFrame

        local LoadCorner = Instance.new("UICorner")
        LoadCorner.CornerRadius = UDim.new(0, 20)
        LoadCorner.Parent = LoadContainer

        local LoadIcon = Instance.new("TextLabel")
        LoadIcon.Size = UDim2.new(1, 0, 0, 60)
        LoadIcon.Position = UDim2.new(0, 0, 0, 20)
        LoadIcon.BackgroundTransparency = 1
        LoadIcon.Text = "🔪"
        LoadIcon.TextColor3 = Color3.fromRGB(255, 0, 0)
        LoadIcon.TextSize = 50
        LoadIcon.Font = Enum.Font.GothamBold
        LoadIcon.Parent = LoadContainer

        local LoadTitle = Instance.new("TextLabel")
        LoadTitle.Size = UDim2.new(1, 0, 0, 40)
        LoadTitle.Position = UDim2.new(0, 0, 0, 80)
        LoadTitle.BackgroundTransparency = 1
        LoadTitle.Text = "SURVIVE THE KILLER"
        LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        LoadTitle.TextSize = 28
        LoadTitle.Font = Enum.Font.GothamBold
        LoadTitle.Parent = LoadContainer

        local LoadSub = Instance.new("TextLabel")
        LoadSub.Size = UDim2.new(1, 0, 0, 25)
        LoadSub.Position = UDim2.new(0, 0, 0, 120)
        LoadSub.BackgroundTransparency = 1
        LoadSub.Text = "NANOXYIN DEFENSE v2.0"
        LoadSub.TextColor3 = Color3.fromRGB(255, 0, 0)
        LoadSub.TextSize = 14
        LoadSub.Font = Enum.Font.Gotham
        LoadSub.Parent = LoadContainer

        local LoadStatus = Instance.new("TextLabel")
        LoadStatus.Size = UDim2.new(1, 0, 0, 25)
        LoadStatus.Position = UDim2.new(0, 0, 0, 160)
        LoadStatus.BackgroundTransparency = 1
        LoadStatus.Text = "Initializing Defense System..."
        LoadStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
        LoadStatus.TextSize = 14
        LoadStatus.Font = Enum.Font.Gotham
        LoadStatus.Parent = LoadContainer

        local LoadBarBg = Instance.new("Frame")
        LoadBarBg.Size = UDim2.new(0, 300, 0, 8)
        LoadBarBg.Position = UDim2.new(0.5, -150, 0, 200)
        LoadBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        LoadBarBg.BorderSizePixel = 0
        LoadBarBg.Parent = LoadContainer

        local LoadBarBgCorner = Instance.new("UICorner")
        LoadBarBgCorner.CornerRadius = UDim.new(1, 0)
        LoadBarBgCorner.Parent = LoadBarBg

        local LoadBarFill = Instance.new("Frame")
        LoadBarFill.Size = UDim2.new(0, 0, 1, 0)
        LoadBarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        LoadBarFill.BorderSizePixel = 0
        LoadBarFill.Parent = LoadBarBg

        local LoadBarFillCorner = Instance.new("UICorner")
        LoadBarFillCorner.CornerRadius = UDim.new(1, 0)
        LoadBarFillCorner.Parent = LoadBarFill

        local modules = {
            "Defense Layer 1 - Anti-Kick",
            "Defense Layer 2 - Anti-Ban",
            "Defense Layer 3 - Remote Block",
            "Defense Layer 4 - Stats Spoof",
            "Defense Layer 5 - Counter-Measure",
            "Defense Layer 6 - Decoy Scripts",
            "Defense Layer 7 - Memory Protection",
            "Defense Layer 8 - Network Spoof",
            "Defense Layer 9 - Anti-Screenshot",
            "Defense Layer 10 - Process Spoof",
            "ESP System",
            "Auto Farm",
            "Auto Escape",
            "Kill Aura",
            "Auto Invisible",
            "Auto Heal",
            "Speed Hack",
            "No Clip",
            "Full Bright",
            "UI System",
            "Finalizing..."
        }

        for i, mod in ipairs(modules) do
            LoadStatus.Text = mod
            local progress = i / #modules
            TweenService:Create(LoadBarFill, TweenInfo.new(0.3), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
            task.wait(0.2)
        end

        LoadStatus.Text = "Defense System Active!"
        LoadStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
        task.wait(0.5)

        TweenService:Create(LoadContainer, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -200, 0, -300)}):Play()
        TweenService:Create(Backdrop, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.6)
        LoadingFrame:Destroy()
    end)
end

ShowLoadingScreen()

--// ============================================================
--// SECTION 20: MODERN UI WITH DEFENSE PANEL
--// ============================================================

local function CreateModernUI()
    SafeCall(function()
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "STKUI_" .. RandomString(8)
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
        TitleIcon.Text = "🔪"
        TitleIcon.TextColor3 = Color3.fromRGB(255, 0, 0)
        TitleIcon.TextSize = 28
        TitleIcon.Font = Enum.Font.GothamBold
        TitleIcon.Parent = TopBar

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(0, 300, 0, 30)
        TitleLabel.Position = UDim2.new(0, 55, 0, 8)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = "SURVIVE THE KILLER"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 22
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = TopBar

        local SubTitleLabel = Instance.new("TextLabel")
        SubTitleLabel.Size = UDim2.new(0, 300, 0, 18)
        SubTitleLabel.Position = UDim2.new(0, 55, 0, 32)
        SubTitleLabel.BackgroundTransparency = 1
        SubTitleLabel.Text = "NANOXYIN DEFENSE v2.0"
        SubTitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
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
        ContentArea.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
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
                tab.Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                tab.Icon.TextColor3 = Color3.fromRGB(13, 13, 18)
                tab.Text.TextColor3 = Color3.fromRGB(13, 13, 18)
            end)

            return TabContent
        end

        local AutoTab = CreateTab("Auto", "A", Color3.fromRGB(255, 100, 100))
        local ESPTab = CreateTab("ESP", "E", Color3.fromRGB(100, 200, 255))
        local MiscTab = CreateTab("Misc", "M", Color3.fromRGB(150, 255, 150))
        local TeleportTab = CreateTab("TP", "T", Color3.fromRGB(255, 255, 100))
        local DefenseTab = CreateTab("Defense", "D", Color3.fromRGB(255, 50, 50))

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
            ToggleBg.BackgroundColor3 = default and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(60, 60, 70)
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
                        TweenService:Create(ToggleBg, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
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
            ValueLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
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
            SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
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
            SectionText.TextColor3 = Color3.fromRGB(255, 0, 0)
            SectionText.TextSize = 16
            SectionText.Font = Enum.Font.GothamBold
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            SectionText.Parent = Section

            local SectionLine = Instance.new("Frame")
            SectionLine.Size = UDim2.new(1, 0, 0, 2)
            SectionLine.Position = UDim2.new(0, 0, 1, -2)
            SectionLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            SectionLine.BorderSizePixel = 0
            SectionLine.Parent = Section

            local SectionLineCorner = Instance.new("UICorner")
            SectionLineCorner.CornerRadius = UDim.new(1, 0)
            SectionLineCorner.Parent = SectionLine

            return Section
        end

        -- Auto Tab
        CreateSection(AutoTab, "Auto Features", 0)
        CreateToggle(AutoTab, "Auto Farm Loot", Config.AutoFarmLoot, function(v) Config.AutoFarmLoot = v end, 40)
        CreateToggle(AutoTab, "Auto Escape", Config.AutoEscape, function(v) Config.AutoEscape = v end, 90)
        CreateToggle(AutoTab, "Kill Aura", Config.KillAura, function(v) Config.KillAura = v end, 140)
        CreateToggle(AutoTab, "Auto Invisible", Config.AutoInvisible, function(v) Config.AutoInvisible = v end, 190)
        CreateToggle(AutoTab, "Auto Heal", Config.AutoHeal, function(v) Config.AutoHeal = v end, 240)
        CreateToggle(AutoTab, "Auto Collect", Config.AutoCollect, function(v) Config.AutoCollect = v end, 290)

        -- ESP Tab
        CreateSection(ESPTab, "ESP Settings", 0)
        CreateToggle(ESPTab, "ESP Players", Config.ESPPlayers, function(v) Config.ESPPlayers = v end, 40)
        CreateToggle(ESPTab, "Killer ESP", Config.KillerESP, function(v) Config.KillerESP = v end, 90)
        CreateToggle(ESPTab, "Survivor ESP", Config.SurvivorESP, function(v) Config.SurvivorESP = v end, 140)
        CreateToggle(ESPTab, "ESP Loot", Config.ESPLoot, function(v) Config.ESPLoot = v end, 190)

        -- Misc Tab
        CreateSection(MiscTab, "Miscellaneous", 0)
        CreateToggle(MiscTab, "Speed Hack", Config.SpeedHack, function(v) Config.SpeedHack = v end, 40)
        CreateSlider(MiscTab, "Speed", 16, 200, Config.SpeedValue, function(v) Config.SpeedValue = v end, 90)
        CreateToggle(MiscTab, "No Clip", Config.NoClip, function(v) Config.NoClip = v end, 160)
        CreateToggle(MiscTab, "Fly", Config.Fly, function(v) Config.Fly = v end, 210)
        CreateSlider(MiscTab, "Fly Speed", 50, 500, Config.FlySpeed, function(v) Config.FlySpeed = v end, 260)
        CreateToggle(MiscTab, "Infinite Jump", Config.InfiniteJump, function(v) Config.InfiniteJump = v end, 330)
        CreateToggle(MiscTab, "Full Bright", Config.FullBright, function(v) Config.FullBright = v end, 380)
        CreateToggle(MiscTab, "God Mode", Config.GodMode, function(v) Config.GodMode = v end, 430)
        CreateToggle(MiscTab, "Anti AFK", Config.AntiAFK, function(v) Config.AntiAFK = v end, 480)

        -- Teleport Tab
        CreateSection(TeleportTab, "Teleport", 0)
        local TPLootBtn = Instance.new("TextButton")
        TPLootBtn.Size = UDim2.new(1, 0, 0, 40)
        TPLootBtn.Position = UDim2.new(0, 0, 0, 40)
        TPLootBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TPLootBtn.Text = "TP to Nearest Loot"
        TPLootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TPLootBtn.TextSize = 14
        TPLootBtn.Font = Enum.Font.Gotham
        TPLootBtn.Parent = TeleportTab
        local TPLootCorner = Instance.new("UICorner")
        TPLootCorner.CornerRadius = UDim.new(0, 8)
        TPLootCorner.Parent = TPLootBtn
        TPLootBtn.MouseButton1Click:Connect(function()
            SafeCall(function()
                local loot = GetLootItems()
                if #loot > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = loot[1].CFrame
                end
            end)
        end)

        local TPDoorBtn = Instance.new("TextButton")
        TPDoorBtn.Size = UDim2.new(1, 0, 0, 40)
        TPDoorBtn.Position = UDim2.new(0, 0, 0, 90)
        TPDoorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TPDoorBtn.Text = "TP to Exit Door"
        TPDoorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TPDoorBtn.TextSize = 14
        TPDoorBtn.Font = Enum.Font.Gotham
        TPDoorBtn.Parent = TeleportTab
        local TPDoorCorner = Instance.new("UICorner")
        TPDoorCorner.CornerRadius = UDim.new(0, 8)
        TPDoorCorner.Parent = TPDoorBtn
        TPDoorBtn.MouseButton1Click:Connect(function()
            SafeCall(function()
                local doors = GetExitDoors()
                if #doors > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = doors[1].CFrame
                end
            end)
        end)

        local TPMedkitBtn = Instance.new("TextButton")
        TPMedkitBtn.Size = UDim2.new(1, 0, 0, 40)
        TPMedkitBtn.Position = UDim2.new(0, 0, 0, 140)
        TPMedkitBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TPMedkitBtn.Text = "TP to Nearest Medkit"
        TPMedkitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TPMedkitBtn.TextSize = 14
        TPMedkitBtn.Font = Enum.Font.Gotham
        TPMedkitBtn.Parent = TeleportTab
        local TPMedkitCorner = Instance.new("UICorner")
        TPMedkitCorner.CornerRadius = UDim.new(0, 8)
        TPMedkitCorner.Parent = TPMedkitBtn
        TPMedkitBtn.MouseButton1Click:Connect(function()
            SafeCall(function()
                local medkits = GetMedkits()
                if #medkits > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = medkits[1].CFrame
                end
            end)
        end)

        local TPLockerBtn = Instance.new("TextButton")
        TPLockerBtn.Size = UDim2.new(1, 0, 0, 40)
        TPLockerBtn.Position = UDim2.new(0, 0, 0, 190)
        TPLockerBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TPLockerBtn.Text = "TP to Nearest Locker"
        TPLockerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TPLockerBtn.TextSize = 14
        TPLockerBtn.Font = Enum.Font.Gotham
        TPLockerBtn.Parent = TeleportTab
        local TPLockerCorner = Instance.new("UICorner")
        TPLockerCorner.CornerRadius = UDim.new(0, 8)
        TPLockerCorner.Parent = TPLockerBtn
        TPLockerBtn.MouseButton1Click:Connect(function()
            SafeCall(function()
                local lockers = GetLockers()
                if #lockers > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = lockers[1].CFrame
                end
            end)
        end)

        -- Defense Tab - NEW!
        CreateSection(DefenseTab, "Defense System", 0)

        local DefenseStatus = Instance.new("TextLabel")
        DefenseStatus.Size = UDim2.new(1, 0, 0, 25)
        DefenseStatus.Position = UDim2.new(0, 0, 0, 40)
        DefenseStatus.BackgroundTransparency = 1
        DefenseStatus.Text = "Status: ACTIVE"
        DefenseStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
        DefenseStatus.TextSize = 16
        DefenseStatus.Font = Enum.Font.GothamBold
        DefenseStatus.Parent = DefenseTab

        local DetectionsLabel = Instance.new("TextLabel")
        DetectionsLabel.Size = UDim2.new(1, 0, 0, 20)
        DetectionsLabel.Position = UDim2.new(0, 0, 0, 70)
        DetectionsLabel.BackgroundTransparency = 1
        DetectionsLabel.Text = "Detections Blocked: 0"
        DetectionsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        DetectionsLabel.TextSize = 14
        DetectionsLabel.Font = Enum.Font.Gotham
        DetectionsLabel.Parent = DefenseTab

        -- Update detections label
        spawn(function()
            while true do
                task.wait(1)
                DetectionsLabel.Text = "Detections Blocked: " .. DefenseSystem.Detections
                if DefenseSystem.Detections > 5 then
                    DetectionsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                else
                    DetectionsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
        end)

        CreateToggle(DefenseTab, "Defense Active", Config.DefenseActive, function(v) 
            Config.DefenseActive = v 
            DefenseSystem.Active = v
            DefenseStatus.Text = v and "Status: ACTIVE" or "Status: DISABLED"
            DefenseStatus.TextColor3 = v and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
        end, 100)

        CreateToggle(DefenseTab, "Auto Counter", Config.AutoCounter, function(v) Config.AutoCounter = v end, 150)
        CreateToggle(DefenseTab, "Spoof Detection", Config.SpoofDetection, function(v) Config.SpoofDetection = v end, 200)

        local CounterMeasuresLabel = Instance.new("TextLabel")
        CounterMeasuresLabel.Size = UDim2.new(1, 0, 0, 100)
        CounterMeasuresLabel.Position = UDim2.new(0, 0, 0, 260)
        CounterMeasuresLabel.BackgroundTransparency = 1
        CounterMeasuresLabel.Text = "Counter Measures:
- Anti-Kick
- Anti-Ban
- Remote Spoof
- Stats Spoof
- Memory Protection"
        CounterMeasuresLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        CounterMeasuresLabel.TextSize = 12
        CounterMeasuresLabel.Font = Enum.Font.Gotham
        CounterMeasuresLabel.TextYAlignment = Enum.TextYAlignment.Top
        CounterMeasuresLabel.Parent = DefenseTab

        Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        Tabs[1].Icon.TextColor3 = Color3.fromRGB(13, 13, 18)
        Tabs[1].Text.TextColor3 = Color3.fromRGB(13, 13, 18)
        Tabs[1].Content.Visible = true
        CurrentTab = Tabs[1]

        -- Drag
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

        -- Intro animation
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
--// SECTION 21: INPUT HANDLING
--// ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

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
--// SECTION 22: MAIN LOOP
--// ============================================================

RunService.RenderStepped:Connect(function()
    -- Update ESP
    if Config.ESPPlayers or Config.KillerESP or Config.SurvivorESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not PlayerESPObjects[player] then
                CreatePlayerESP(player)
            end
        end
        UpdatePlayerESP()
    end

    if Config.ESPLoot then
        CreateLootESP()
        UpdateLootESP()
    end

    -- Auto features
    AutoFarmLoot()
    AutoEscape()
    KillAura()
    AutoInvisible()
    AutoHeal()
    AutoCollect()
    GodMode()

    -- Movement
    SpeedHack()
    NoClip()
    Fly()

    -- Visual
    FullBright()
end)

--// ============================================================
--// SECTION 23: PLAYER EVENTS
--// ============================================================

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreatePlayerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if PlayerESPObjects[player] then
        for _, obj in pairs(PlayerESPObjects[player]) do
            if obj then obj:Remove() end
        end
        PlayerESPObjects[player] = nil
    end
end)

--// ============================================================
--// SECTION 24: INITIAL SETUP
--// ============================================================

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreatePlayerESP(player)
    end
end

CreateLootESP()

--// ============================================================
--// SECTION 25: FINAL NOTIFICATION
--// ============================================================

SafeCall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "SURVIVE THE KILLER",
        Text = "NanoXyin Defense v2.0 Loaded | Defense Active",
        Duration = 5
    })
end)

print("============================================================")
print("SURVIVE THE KILLER NANOXYIN DEFENSE v2.0")
print("ALL FEATURES ACTIVE | DEFENSE SYSTEM ONLINE")
print("RightShift = Toggle UI")
print("Auto Farm | Auto Escape | Kill Aura | ESP")
print("Auto Invisible | Auto Heal | Speed | Fly | No Clip")
print("Defense: Anti-Kick | Anti-Ban | Remote Spoof | Stats Spoof")
print("============================================================")
