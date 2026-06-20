--// NANOXYIN BYPASS WRAPPER v3.0
--// SCRIPT BY XYIN
--// Load this FIRST, then original script runs inside protected environment

--// PROTECTION LAYER 1: Environment Setup
local _env = getfenv()
local _game = game
local _gs = _game.GetService

local Players = _gs(_game, "Players")
local RunService = _gs(_game, "RunService")
local Workspace = _gs(_game, "Workspace")
local UserInputService = _gs(_game, "UserInputService")
local TweenService = _gs(_game, "TweenService")
local Lighting = _gs(_game, "Lighting")
local CoreGui = _gs(_game, "CoreGui")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// PROTECTION LAYER 2: Anti-Detection Hooks
local function SetupBypass()
    local success = pcall(function()
        -- Hook 1: Block Kick method
        local mt = getrawmetatable(game)
        if mt then
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" then
                    local selfStr = tostring(self):lower()
                    if selfStr:find("player") or selfStr == tostring(LocalPlayer):lower() then
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
            
            setreadonly(mt, true)
        end
        
        -- Hook 2: Block RemoteEvents that kick/ban
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local name = v.Name:lower()
                if name:find("kick") or name:find("ban") or name:find("punish") or name:find("detection") or name:find("report") or name:find("log") then
                    if v:IsA("RemoteEvent") then
                        local oldFire = v.FireServer
                        v.FireServer = function(...)
                            return nil
                        end
                    elseif v:IsA("RemoteFunction") then
                        local oldInvoke = v.InvokeServer
                        v.InvokeServer = function(...)
                            return nil
                        end
                    end
                end
            end
        end
        
        -- Hook 3: Block loading screens
        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if v:IsA("ScreenGui") then
                local name = v.Name:lower()
                if name:find("loading") or name:find("anticheat") or name:find("ac") or name:find("detection") or name:find("verification") or name:find("check") then
                    v.Enabled = false
                    pcall(function() v:Destroy() end)
                end
            end
        end
        
        -- Hook 4: Spoof execution context
        local oldGetfenv = getfenv
        if oldGetfenv then
            getfenv = function(level)
                local env = oldGetfenv(level)
                if env and env.script then
                    -- Hide script identity
                    pcall(function()
                        env.script.Name = "LocalScript"
                    end)
                end
                return env
            end
        end
        
        -- Hook 5: Block common anti-cheat modules
        local modules = {
            "AntiCheat", "AntiExploit", "AntiHack", "ACDetector", 
            "CheatDetection", "ExploitDetection", "SecurityModule"
        }
        for _, modName in ipairs(modules) do
            local module = game:FindFirstChild(modName, true)
            if module then
                pcall(function()
                    module:Destroy()
                end)
            end
        end
    end)
    
    return success
end

SetupBypass()

--// PROTECTION LAYER 3: String Encryption Helper
local function DecryptString(encrypted)
    -- Simple XOR decryption
    local key = 42
    local result = ""
    for i = 1, #encrypted do
        local char = string.byte(encrypted:sub(i, i))
        result = result .. string.char(bit32.bxor(char, key))
    end
    return result
end

--// PROTECTION LAYER 4: Delayed Execution (bypass immediate scan)
task.wait(0.5)

--// PROTECTION LAYER 5: Load Original Script in Protected Mode
local function LoadOriginal()
    -- Original NANOXYIN Script v2.0
    -- SCRIPT BY XYIN
    -- Features: Flick Aimbot, Auto-Fire, ESP (Box/Line/Name/Health), X-Ray Wallhack, FOV Lock, Loading Bypass
    
    --// SERVICES
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Camera = Workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local TweenService = game:GetService("TweenService")
    
    --// LOADING BYPASS & INTRO
    local function LoadingBypass()
        local success, err = pcall(function()
            -- Bypass common anti-cheat loading screens
            for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if v:IsA("ScreenGui") and (v.Name:lower():match("loading") or v.Name:lower():match("anticheat") or v.Name:lower():match("ac") or v.Name:lower():match("detection")) then
                    v.Enabled = false
                    v:Destroy()
                end
            end
            
            -- Hook loading modules
            local mt = getrawmetatable(game)
            if mt then
                local oldNamecall = mt.__namecall
                setreadonly(mt, false)
                
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if method == "Kick" or method == "Destroy" then
                        if tostring(self):lower():match("loading") or tostring(self):lower():match("anticheat") or tostring(self):lower():match("ac") then
                            return wait(9e9)
                        end
                    end
                    return oldNamecall(self, ...)
                end)
                
                setreadonly(mt, true)
            end
        end)
        
        -- Intro Screen
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "NanoXyinIntro"
        ScreenGui.Parent = game.CoreGui
        
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 400, 0, 200)
        Frame.Position = UDim2.new(0.5, -200, 0.5, -100)
        Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        Frame.BorderSizePixel = 0
        Frame.Parent = ScreenGui
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 12)
        Corner.Parent = Frame
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0.4, 0)
        Title.Position = UDim2.new(0, 0, 0.1, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "NANOXYIN"
        Title.TextColor3 = Color3.fromRGB(0, 255, 200)
        Title.TextSize = 48
        Title.Font = Enum.Font.GothamBold
        Title.Parent = Frame
        
        local SubTitle = Instance.new("TextLabel")
        SubTitle.Size = UDim2.new(1, 0, 0.2, 0)
        SubTitle.Position = UDim2.new(0, 0, 0.5, 0)
        SubTitle.BackgroundTransparency = 1
        SubTitle.Text = "SCRIPT BY XYIN"
        SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        SubTitle.TextSize = 24
        SubTitle.Font = Enum.Font.Gotham
        SubTitle.Parent = Frame
        
        local Status = Instance.new("TextLabel")
        Status.Size = UDim2.new(1, 0, 0.15, 0)
        Status.Position = UDim2.new(0, 0, 0.75, 0)
        Status.BackgroundTransparency = 1
        Status.Text = "Loading modules..."
        Status.TextColor3 = Color3.fromRGB(0, 255, 200)
        Status.TextSize = 18
        Status.Font = Enum.Font.Gotham
        Status.Parent = Frame
        
        -- Loading animation
        local modules = {"ESP", "Aimbot", "FOV Lock", "Auto-Fire", "X-Ray Wallhack", "Anti-Cheat Bypass", "Render Engine"}
        for i, mod in ipairs(modules) do
            Status.Text = "Loading " .. mod .. "..."
            wait(0.3)
        end
        
        Status.Text = "Ready!"
        Status.TextColor3 = Color3.fromRGB(0, 255, 100)
        wait(0.5)
        
        TweenService:Create(Frame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -200, 0, -250)}):Play()
        wait(0.6)
        ScreenGui:Destroy()
        
        return success
    end
    
    LoadingBypass()
    
    --// CONFIG
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
        },
        
        AutoFire = {
            Enabled = true,
            Key = Enum.KeyCode.F,
            Active = false,
            Delay = 0.05,
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
        }
    }
    
    --// VARIABLES
    local ESPObjects = {}
    local AimTarget = nil
    local FOV_Circle = nil
    local XRayHighlights = {}
    local XRayConnections = {}
    
    --// UTILITY FUNCTIONS
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
    
    --// X-RAY WALLHACK SYSTEM
    local function SetupXRay()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                if obj.Name:lower():match("wall") or obj.Name:lower():match("door") or obj.Name:lower():match("barrier") or obj.Name:lower():match("cover") then
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
            if highlight then highlight:Destroy() end
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
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "NanoXyinXRay"
                    highlight.Adornee = part
                    highlight.FillColor = Config.XRay.EnemyHighlightColor
                    highlight.OutlineColor = Config.XRay.EnemyOutlineColor
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = part
                    table.insert(XRayHighlights, highlight)
                end
            end
        end
    end
    
    local function ToggleXRay()
        Config.XRay.Active = not Config.XRay.Active
        SetupXRay()
        UpdateXRayHighlights()
    end
    
    --// FOV CIRCLE
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
    
    --// ESP SYSTEM
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
            if obj then obj:Remove() end
        end
        
        ESPObjects[player] = nil
    end
    
    local function UpdateESP()
        for player, esp in pairs(ESPObjects) do
            local character = GetCharacter(player)
            
            if not character or not IsAlive(character) or player == LocalPlayer or (Config.Aimbot.TeamCheck and IsTeammate(player)) then
                for _, obj in pairs(esp) do
                    if obj then obj.Visible = false end
                end
                continue
            end
            
            local humanoid = GetHumanoid(character)
            local head = character:FindFirstChild("Head")
            local root = character:FindFirstChild("HumanoidRootPart")
            
            if not head or not root or not humanoid then
                for _, obj in pairs(esp) do
                    if obj then obj.Visible = false end
                end
                continue
            end
            
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
            
            if not headOnScreen or not rootOnScreen then
                for _, obj in pairs(esp) do
                    if obj then obj.Visible = false end
                end
                continue
            end
            
            local distance = (root.Position - Camera.CFrame.Position).Magnitude
            if distance > Config.ESP.MaxDistance then
                for _, obj in pairs(esp) do
                    if obj then obj.Visible = false end
                end
                continue
            end
            
            local boxHeight = math.abs(headPos.Y - rootPos.Y) * 2.5
            local boxWidth = boxHeight * 0.6
            local boxPosition = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
            
            if Config.ESP.Box then
                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                esp.Box.Position = boxPosition
                esp.Box.Visible = true
                
                if Config.ESP.BoxFilled then
                    esp.BoxFill.Size = Vector2.new(boxWidth, boxHeight)
                    esp.BoxFill.Position = boxPosition
                    esp.BoxFill.Visible = true
                else
                    esp.BoxFill.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.BoxFill.Visible = false
            end
            
            if Config.ESP.Line then
                esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.Line.Visible = true
            else
                esp.Line.Visible = false
            end
            
            if Config.ESP.Name then
                esp.Name.Position = Vector2.new(rootPos.X, boxPosition.Y - 20)
                esp.Name.Text = player.Name
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
            
            if Config.ESP.Distance then
                esp.Distance.Position = Vector2.new(rootPos.X, boxPosition.Y + boxHeight + 5)
                esp.Distance.Text = math.floor(distance) .. "m"
                esp.Distance.Visible = true
            else
                esp.Distance.Visible = false
            end
            
            if Config.ESP.HealthBar then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local barHeight = boxHeight * healthPercent
                
                esp.HealthBarBG.Size = Vector2.new(4, boxHeight)
                esp.HealthBarBG.Position = Vector2.new(boxPosition.X - 8, boxPosition.Y)
                esp.HealthBarBG.Visible = true
                
                esp.HealthBar.Size = Vector2.new(4, barHeight)
                esp.HealthBar.Position = Vector2.new(boxPosition.X - 8, boxPosition.Y + (boxHeight - barHeight))
                esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                esp.HealthBar.Visible = true
            else
                esp.HealthBar.Visible = false
                esp.HealthBarBG.Visible = false
            end
            
            if Config.ESP.Tracers then
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end
        end
    end
    
    --// FLICK AIMBOT + AUTO-FIRE
    local function FlickAimbot()
        if not Config.Aimbot.Enabled then return end
        
        if UserInputService:IsMouseButtonPressed(Config.Aimbot.Key) then
            if not AimTarget then
                AimTarget = GetClosestPlayer()
            end
            
            if AimTarget then
                local character = GetCharacter(AimTarget)
                if not character or not IsAlive(character) then
                    AimTarget = nil
                    return
                end
                
                local predictedPos = GetPredictedPosition(AimTarget)
                if not predictedPos then
                    AimTarget = nil
                    return
                end
                
                local screenPos = Camera:WorldToViewportPoint(predictedPos)
                local mousePos = UserInputService:GetMouseLocation()
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                
                local smoothness = Config.Aimbot.FlickMode and Config.Aimbot.FlickSpeed or Config.Aimbot.Smoothness
                local moveVector = (targetPos - mousePos) * smoothness
                mousemoverel(moveVector.X, moveVector.Y)
                
                if Config.AutoFire.Enabled and Config.AutoFire.Active then
                    local currentTime = tick()
                    if currentTime - Config.AutoFire.LastShot >= Config.AutoFire.Delay then
                        if not Config.AutoFire.RequireAim or (Config.AutoFire.RequireAim and AimTarget) then
                            local distToTarget = (targetPos - mousePos).Magnitude
                            if distToTarget < 20 then
                                mouse1click()
                                Config.AutoFire.LastShot = currentTime
                            end
                        end
                    end
                end
            end
        else
            AimTarget = nil
        end
    end
    
    --// INPUT HANDLING
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Config.AutoFire.Key then
            Config.AutoFire.Active = not Config.AutoFire.Active
            
            local notif = Instance.new("TextLabel")
            notif.Size = UDim2.new(0, 200, 0, 40)
            notif.Position = UDim2.new(0.5, -100, 0.1, 0)
            notif.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            notif.TextColor3 = Config.AutoFire.Active and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            notif.Text = "Auto-Fire: " .. (Config.AutoFire.Active and "ON" or "OFF")
            notif.TextSize = 18
            notif.Font = Enum.Font.GothamBold
            notif.Parent = game.CoreGui
            notif.BorderSizePixel = 0
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = notif
            
            TweenService:Create(notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0.15, 0)}):Play()
            wait(2)
            TweenService:Create(notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0, -50)}):Play()
            wait(0.6)
            notif:Destroy()
        end
        
        if input.KeyCode == Config.XRay.Key then
            ToggleXRay()
            
            local notif = Instance.new("TextLabel")
            notif.Size = UDim2.new(0, 200, 0, 40)
            notif.Position = UDim2.new(0.5, -100, 0.1, 0)
            notif.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            notif.TextColor3 = Config.XRay.Active and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            notif.Text = "X-Ray: " .. (Config.XRay.Active and "ON" or "OFF")
            notif.TextSize = 18
            notif.Font = Enum.Font.GothamBold
            notif.Parent = game.CoreGui
            notif.BorderSizePixel = 0
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = notif
            
            TweenService:Create(notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0.15, 0)}):Play()
            wait(2)
            TweenService:Create(notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0, -50)}):Play()
            wait(0.6)
            notif:Destroy()
        end
    end)
    
    --// MAIN LOOP
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
    
    --// PLAYER ADDED/REMOVED
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer and Config.ESP.Enabled then
            CreateESP(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    
    --// INITIAL SETUP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    SetupXRay()
    UpdateXRayHighlights()
    
    print("NANOXYIN v2.0 | SCRIPT BY XYIN | Loaded successfully")
    print("Right Click = Flick Aimbot | F = Toggle Auto-Fire | X = Toggle X-Ray")
    print("ESP Active | FOV Lock Ready | X-Ray Wallhack Ready")
end

--// EXECUTE
LoadOriginal()
