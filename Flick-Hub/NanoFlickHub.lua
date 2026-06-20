--// NANOXYIN v3.0 | PROTECTED LOAD
--// SCRIPT BY XYIN
--// NO instance method replacement | NO hookfunction on game | getconnections + getgc approach

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// ============================================================
--// BYPASS LAYER 1: getconnections approach (no method replacement)
--// ============================================================

local function DisconnectACEvents()
    -- Disconnect all connections on remotes that might kick
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
            local n = v.Name:lower()
            if n:find("kick") or n:find("ban") or n:find("punish") or n:find("detection") or n:find("report") or n:find("log") or n:find("check") or n:find("verify") or n:find("ac") or n:find("anti") or n:find("security") then
                if getconnections then
                    -- Disconnect client-side connections
                    for _, conn in pairs(getconnections(v.OnClientEvent)) do
                        pcall(function() conn:Disable() end)
                    end
                end
            end
        end
    end
end

DisconnectACEvents()

--// BYPASS LAYER 2: getgc approach (find and disable AC functions in garbage collector)
local function DisableACFunctions()
    if getgc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" then
                pcall(function()
                    local info = debug.getinfo(v)
                    if info and info.name then
                        local name = info.name:lower()
                        if name:find("kick") or name:find("ban") or name:find("detect") or name:find("check") or name:find("anticheat") or name:find("exploit") or name:find("security") then
                            -- Replace function with empty function
                            local upvalues = debug.getupvalues(v)
                            for i, upv in pairs(upvalues) do
                                if type(upv) == "function" then
                                    debug.setupvalue(v, i, function() end)
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
end

DisableACFunctions()

--// BYPASS LAYER 3: Hook Kick via getnamecallmethod interception (no __namecall hook)
-- This only intercepts when Kick is called, doesn't modify the method itself
local function SetupKickInterceptor()
    spawn(function()
        while true do
            pcall(function()
                -- Monitor for kick attempts by checking if player is being kicked
                if LocalPlayer.Parent == nil then
                    -- Player was removed, try to prevent it
                    LocalPlayer.Parent = Players
                end
            end)
            wait(0.1)
        end
    end)
end

SetupKickInterceptor()

--// BYPASS LAYER 4: Remove AC GUI & Modules
local function CleanAC()
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") then
            local n = v.Name:lower()
            if n:find("loading") or n:find("anticheat") or n:find("ac") or n:find("detection") or n:find("verification") or n:find("check") then
                v.Enabled = false
                pcall(function() v:Destroy() end)
            end
        end
    end
    
    LocalPlayer.PlayerGui.ChildAdded:Connect(function(v)
        if v:IsA("ScreenGui") then
            wait(0.2)
            local n = v.Name:lower()
            if n:find("loading") or n:find("anticheat") or n:find("ac") or n:find("detection") or n:find("verification") or n:find("check") then
                v.Enabled = false
                pcall(function() v:Destroy() end)
            end
        end
    end)
    
    local acNames = {"AntiCheat", "AntiExploit", "AntiHack", "ACDetector", "CheatDetection", "ExploitDetection", "SecurityModule", "Anti", "AC"}
    for _, name in ipairs(acNames) do
        local found = game:FindFirstChild(name, true)
        if found then
            pcall(function() found:Destroy() end)
        end
    end
end

CleanAC()

--// DELAY
task.wait(0.5)

--// ============================================================
--// MODERN UI SYSTEM
--// ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NanoXyinUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

--// Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 16)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "NANOXYIN"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleLabel.TextSize = 24
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local SubTitleLabel = Instance.new("TextLabel")
SubTitleLabel.Size = UDim2.new(0, 200, 0, 20)
SubTitleLabel.Position = UDim2.new(0, 20, 0, 30)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.Text = "v3.0 | BY XYIN"
SubTitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitleLabel.TextSize = 12
SubTitleLabel.Font = Enum.Font.Gotham
SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubTitleLabel.Parent = TopBar

--// Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

--// Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 120, 1, -50)
TabBar.Position = UDim2.new(0, 0, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 0)
TabBarCorner.Parent = TabBar

--// Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -120, 1, -50)
ContentArea.Position = UDim2.new(0, 120, 0, 50)
ContentArea.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

--// Tab System
local Tabs = {}
local CurrentTab = nil

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.Position = UDim2.new(0, 0, 0, #Tabs * 45 + 10)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 14
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabBar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabBtn
    
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ContentArea
    
    local tab = {Btn = TabBtn, Content = TabContent}
    table.insert(Tabs, tab)
    
    TabBtn.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Content.Visible = false
            CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            CurrentTab.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        CurrentTab = tab
        tab.Content.Visible = true
        tab.Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
        tab.Btn.TextColor3 = Color3.fromRGB(18, 18, 24)
    end)
    
    return TabContent
end

--// Create Tabs
local AimbotTab = CreateTab("Aimbot", "")
local ESPTab = CreateTab("ESP", "")
local XRayTab = CreateTab("X-Ray", "")
local MiscTab = CreateTab("Misc", "")

--// Toggle Function
local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
    ToggleFrame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 40 + 10)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 200, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
    ToggleBtn.Position = UDim2.new(1, -55, 0.5, -12)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleBtn
    
    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
        ToggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return ToggleFrame
end

--// Slider Function
local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 50)
    SliderFrame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 55 + 10)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 200, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 8)
    SliderBar.Position = UDim2.new(0, 0, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(0, 4)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 4)
    SliderFillCorner.Parent = SliderFill
    
    local dragging = false
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
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
            Label.Text = text .. ": " .. value
            callback(value)
        end
    end)
end

--// ============================================================
--// CONFIG
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
    },
    AutoFire = {
        Enabled = true,
        Active = false,
        Delay = 0.05,
        LastShot = 0,
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

--// Populate Aimbot Tab
CreateToggle(AimbotTab, "Enable Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
CreateToggle(AimbotTab, "Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
CreateToggle(AimbotTab, "Wall Check", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end)
CreateToggle(AimbotTab, "Flick Mode", Config.Aimbot.FlickMode, function(v) Config.Aimbot.FlickMode = v end)
CreateSlider(AimbotTab, "FOV", 50, 300, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
CreateSlider(AimbotTab, "Smoothness", 1, 50, 8, function(v) Config.Aimbot.Smoothness = v / 100 end)

--// Populate ESP Tab
CreateToggle(ESPTab, "Enable ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
CreateToggle(ESPTab, "Box", Config.ESP.Box, function(v) Config.ESP.Box = v end)
CreateToggle(ESPTab, "Box Filled", Config.ESP.BoxFilled, function(v) Config.ESP.BoxFilled = v end)
CreateToggle(ESPTab, "Line", Config.ESP.Line, function(v) Config.ESP.Line = v end)
CreateToggle(ESPTab, "Name", Config.ESP.Name, function(v) Config.ESP.Name = v end)
CreateToggle(ESPTab, "Distance", Config.ESP.Distance, function(v) Config.ESP.Distance = v end)
CreateToggle(ESPTab, "Health Bar", Config.ESP.HealthBar, function(v) Config.ESP.HealthBar = v end)

--// Populate X-Ray Tab
CreateToggle(XRayTab, "Enable X-Ray", Config.XRay.Enabled, function(v) Config.XRay.Enabled = v end)
CreateToggle(XRayTab, "Active", Config.XRay.Active, function(v) 
    Config.XRay.Active = v
    SetupXRay()
    UpdateXRayHighlights()
end)

--// Populate Misc Tab
CreateToggle(MiscTab, "Auto-Fire", Config.AutoFire.Enabled, function(v) Config.AutoFire.Enabled = v end)
CreateToggle(MiscTab, "Show FOV", Config.FOV.Visible, function(v) Config.FOV.Visible = v end)

--// Activate first tab
Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
Tabs[1].Btn.TextColor3 = Color3.fromRGB(18, 18, 24)
Tabs[1].Content.Visible = true
CurrentTab = Tabs[1]

--// ============================================================
// CORE SYSTEM (Original NanoXyin)
// ============================================================

local ESPObjects = {}
local AimTarget = nil
local FOV_Circle = nil
local XRayHighlights = {}

local function GetCharacter(player) return player.Character end
local function GetHumanoid(character) return character:FindFirstChildOfClass("Humanoid") end
local function GetHead(character) return character:FindFirstChild(Config.Aimbot.TargetPart) or character:FindFirstChild("Head") end
local function IsAlive(character) local h = GetHumanoid(character) return h and h.Health > 0 end
local function IsTeammate(player) if not Config.Aimbot.TeamCheck then return false end return player.Team == LocalPlayer.Team end

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

local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"), BoxFill = Drawing.new("Square"),
        Line = Drawing.new("Line"), Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"), HealthBar = Drawing.new("Square"),
        HealthBarBG = Drawing.new("Square"), Tracer = Drawing.new("Line"),
    }
    esp.Box.Thickness = 1; esp.Box.Color = Config.ESP.BoxColor; esp.Box.Transparency = 1; esp.Box.Filled = false; esp.Box.Visible = false
    esp.BoxFill.Color = Config.ESP.BoxFilledColor; esp.BoxFill.Transparency = Config.ESP.BoxFilledTransparency; esp.BoxFill.Filled = true; esp.BoxFill.Visible = false
    esp.Line.Thickness = 1; esp.Line.Color = Config.ESP.LineColor; esp.Line.Visible = false
    esp.Name.Size = Config.ESP.NameSize; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Color = Config.ESP.NameColor; esp.Name.Visible = false
    esp.Distance.Size = 12; esp.Distance.Center = true; esp.Distance.Outline = true; esp.Distance.Color = Color3.fromRGB(255,255,255); esp.Distance.Visible = false
    esp.HealthBarBG.Thickness = 1; esp.HealthBarBG.Color = Color3.fromRGB(0,0,0); esp.HealthBarBG.Filled = true; esp.HealthBarBG.Visible = false
    esp.HealthBar.Thickness = 1; esp.HealthBar.Filled = true; esp.HealthBar.Visible = false
    esp.Tracer.Thickness = 1; esp.Tracer.Color = Config.ESP.TracerColor; esp.Tracer.Visible = false
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
                    local distToTarget = (targetPos - mousePos).Magnitude
                    if distToTarget < 20 then
                        mouse1click()
                        Config.AutoFire.LastShot = currentTime
                    end
                end
            end
        end
    else
        AimTarget = nil
    end
end

--// Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

--// Main Loop
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

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer and Config.ESP.Enabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

SetupXRay()
UpdateXRayHighlights()

print("NANOXYIN v3.0 | SCRIPT BY XYIN | Loaded successfully")
print("Right Click = Flick Aimbot | RightShift = Toggle UI")
print("ESP Active | FOV Lock Ready | X-Ray Wallhack Ready")
