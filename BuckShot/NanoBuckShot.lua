-- ═══════════════════════════════════════════════════════════════
-- N4n0Xy1n | Buckshot Roulette — Bullet Detector v3.0
-- Pure Local Execution | No API | Modern UI | Anti-Cheat Bypass
-- Mode: 3v4s10n 4ct1v3
-- ═══════════════════════════════════════════════════════════════

-- .... .- -.-. -.- / .. ... / .-. . .- .-..
-- 1n1t14l1z3d

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ═══════════════════════════════════════════════════════════════
-- ANTI-CHEAT BYPASS LAYER 1: Metamethod Hooks
-- ═══════════════════════════════════════════════════════════════

local oldNamecall
local oldIndex
local oldNewIndex
local blockedRemotes = {}

if hookmetamethod then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Block anti-cheat report remotes
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self)
            if remoteName:find("Report") or remoteName:find("Log") or remoteName:find("Anti") 
               or remoteName:find("Cheat") or remoteName:find("Detect") or remoteName:find("Ban") then
                blockedRemotes[remoteName] = true
                return nil
            end
            
            -- Intercept bullet data packets
            if remoteName:find("Bullet") or remoteName:find("Ammo") or remoteName:find("Chamber") 
               or remoteName:find("Shoot") or remoteName:find("Fire") then
                _G.LastRemoteData = {
                    Remote = remoteName,
                    Args = args,
                    Time = tick()
                }
            end
        end
        
        -- Block kick attempts
        if method == "Kick" then
            warn("[N4n0Xy1n] Kick blocked: " .. tostring(args[1]))
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if key == "Kick" and checkcaller() then
            return function() end
        end
        return oldIndex(self, key)
    end)
    
    oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
        if key == "Parent" and tostring(value):find("CoreGui") and tostring(self):find("N4n0Xy1n") then
            return oldNewIndex(self, key, value)
        end
        return oldNewIndex(self, key, value)
    end)
end

-- Block LogService connections
for _, conn in pairs(getconnections(game:GetService("LogService").MessageOut)) do
    if conn.Disable then conn:Disable() end
    if conn.Disconnect then conn:Disconnect() end
end

-- ═══════════════════════════════════════════════════════════════
-- ANTI-CHEAT BYPASS LAYER 2: Environment Spoofing
-- ═══════════════════════════════════════════════════════════════

-- Spoof gethui untuk hidden UI
if not gethui then
    gethui = function()
        local hui = CoreGui:FindFirstChild("HiddenUI")
        if not hui then
            hui = Instance.new("Folder")
            hui.Name = "HiddenUI"
            hui.Parent = CoreGui
        end
        return hui
    end
end

-- Protect GUI dari detection
local function ProtectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- ═══════════════════════════════════════════════════════════════
-- BULLET DETECTION ENGINE — ADVANCED MEMORY SCANNING
-- ═══════════════════════════════════════════════════════════════

local BulletEngine = {
    ChamberData = {},
    NextBullet = nil,
    LiveCount = 0,
    BlankCount = 0,
    TotalRounds = 0,
    IsScanning = false,
    LastUpdate = 0,
    Confidence = 0,
    
    -- Pattern signatures untuk Buckshot Roulette
    Signatures = {
        Chamber = {"Chamber", "Bullets", "Ammo", "Rounds", "Cylinder", "Barrel"},
        Live = {"Live", "LiveRounds", "Real", "Danger", "Damage"},
        Blank = {"Blank", "Blanks", "Fake", "Safe", "Dud"}
    }
}

function BulletEngine:DeepScan()
    local found = false
    self.Confidence = 0
    
    -- Method 1: GC Table Scanning
    for _, obj in pairs(getgc()) do
        if type(obj) == "table" then
            -- Pattern: Array boolean untuk chamber state
            if #obj >= 2 and #obj <= 8 then
                local validChamber = true
                local liveCount = 0
                local blankCount = 0
                
                for i = 1, #obj do
                    local v = obj[i]
                    if type(v) == "boolean" then
                        if v then liveCount = liveCount + 1 else blankCount = blankCount + 1 end
                    elseif type(v) == "number" then
                        if v == 1 then liveCount = liveCount + 1 
                        elseif v == 0 then blankCount = blankCount + 1
                        else validChamber = false break end
                    else
                        validChamber = false
                        break
                    end
                end
                
                if validChamber and (liveCount + blankCount) > 0 and (liveCount + blankCount) <= 8 then
                    self.ChamberData = obj
                    self.LiveCount = liveCount
                    self.BlankCount = blankCount
                    self.TotalRounds = liveCount + blankCount
                    self.NextBullet = obj[1]
                    self.Confidence = 85
                    found = true
                    break
                end
            end
            
            -- Pattern: Named table dengan LiveRounds/BlankRounds
            if rawget(obj, "LiveRounds") and rawget(obj, "BlankRounds") then
                self.LiveCount = tonumber(obj.LiveRounds) or 0
                self.BlankCount = tonumber(obj.BlankRounds) or 0
                self.TotalRounds = self.LiveCount + self.BlankCount
                if rawget(obj, "CurrentChamber") then
                    self.ChamberData = obj.CurrentChamber
                    self.NextBullet = self.ChamberData[1]
                end
                self.Confidence = 95
                found = true
                break
            end
            
            -- Pattern: Named keys (Buckshot specific)
            if rawget(obj, "Bullets") and type(obj.Bullets) == "table" then
                self.ChamberData = obj.Bullets
                self:AnalyzeArray(obj.Bullets)
                self.Confidence = 90
                found = true
                break
            end
        end
        
        if type(obj) == "function" and not is_synapse_function(obj) then
            -- Scan upvalues untuk hidden chamber data
            local success, upvalues = pcall(function()
                return debug.getupvalues(obj)
            end)
            
            if success and upvalues then
                for _, upv in pairs(upvalues) do
                    if type(upv) == "table" then
                        if rawget(upv, "chamber") or rawget(upv, "cylinder") then
                            local chamber = upv.chamber or upv.cylinder
                            if type(chamber) == "table" then
                                self.ChamberData = chamber
                                self:AnalyzeArray(chamber)
                                self.Confidence = 92
                                found = true
                                break
                            end
                        end
                    end
                end
            end
        end
        
        if found then break end
    end
    
    -- Method 2: Remote Data Interception
    if not found and _G.LastRemoteData then
        local data = _G.LastRemoteData.Args
        for _, arg in pairs(data) do
            if type(arg) == "table" then
                if arg.Bullets or arg.Chamber or arg.Ammo or arg.Rounds then
                    local chamber = arg.Bullets or arg.Chamber or arg.Ammo or arg.Rounds
                    if type(chamber) == "table" then
                        self.ChamberData = chamber
                        self:AnalyzeArray(chamber)
                        self.Confidence = 88
                        found = true
                        break
                    end
                end
            end
        end
    end
    
    -- Method 3: Workspace Scanning (fallback)
    if not found then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ModuleScript") or obj:IsA("Script") then
                -- Attempt to read source jika tersedia
                local success, source = pcall(function()
                    return obj.Source
                end)
                if success and source then
                    if source:find("LiveRounds") or source:find("BlankRounds") or source:find("Chamber") then
                        -- Found relevant script, mark untuk deeper analysis
                        self.Confidence = 40
                    end
                end
            end
        end
    end
    
    self.IsScanning = false
    self.LastUpdate = tick()
    return found
end

function BulletEngine:AnalyzeArray(arr)
    self.LiveCount = 0
    self.BlankCount = 0
    self.TotalRounds = #arr
    
    for i = 1, #arr do
        local v = arr[i]
        if v == true or v == 1 or v == "Live" or v == "live" then
            self.LiveCount = self.LiveCount + 1
            if i == 1 then self.NextBullet = true end
        elseif v == false or v == 0 or v == "Blank" or v == "blank" then
            self.BlankCount = self.BlankCount + 1
            if i == 1 then self.NextBullet = false end
        end
    end
    
    if self.TotalRounds > 0 and self.NextBullet == nil then
        self.NextBullet = arr[1]
    end
end

function BulletEngine:GetNextBulletType()
    if self.NextBullet == true or self.NextBullet == 1 or self.NextBullet == "Live" then
        return "LIVE"
    elseif self.NextBullet == false or self.NextBullet == 0 or self.NextBullet == "Blank" then
        return "BLANK"
    else
        return "UNKNOWN"
    end
end

function BulletEngine:GetNextBulletColor()
    local bulletType = self:GetNextBulletType()
    if bulletType == "LIVE" then return Color3.fromRGB(255, 50, 50) end
    if bulletType == "BLANK" then return Color3.fromRGB(50, 255, 136) end
    return Color3.fromRGB(255, 170, 0)
end

-- ═══════════════════════════════════════════════════════════════
-- MODERN UI SYSTEM — GLASSMORPHISM DESIGN
-- ═══════════════════════════════════════════════════════════════

local UI = {
    Enabled = true,
    Elements = {},
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

function UI:CreateModernInterface()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "N4n0Xy1n_Buckshot_v3"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.IgnoreGuiInset = true
    ProtectGui(ScreenGui)
    
    -- Background blur effect
    local Backdrop = Instance.new("Frame")
    Backdrop.Name = "Backdrop"
    Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Backdrop.BackgroundTransparency = 1
    Backdrop.BorderSizePixel = 0
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.ZIndex = 100
    Backdrop.Parent = ScreenGui
    
    -- Main Card — Glassmorphism Style
    local MainCard = Instance.new("Frame")
    MainCard.Name = "MainCard"
    MainCard.AnchorPoint = Vector2.new(0.5, 0.5)
    MainCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainCard.Size = UDim2.new(0, 0, 0, 0) -- Start small for animation
    MainCard.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainCard.BackgroundTransparency = 0.15
    MainCard.BorderSizePixel = 0
    MainCard.ZIndex = 101
    MainCard.ClipsDescendants = true
    MainCard.Parent = ScreenGui
    
    -- Rounded corners
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = MainCard
    
    -- Gradient border
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 50, 255)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.3
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = MainCard
    
    -- Animated gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 50, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 50, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 255))
    })
    Gradient.Rotation = 0
    Gradient.Parent = Stroke
    
    -- Animate gradient
    task.spawn(function()
        while MainCard and MainCard.Parent do
            for i = 0, 360, 2 do
                if not Gradient or not Gradient.Parent then break end
                Gradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
    
    -- Header Section
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    Header.BackgroundTransparency = 0.5
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.ZIndex = 102
    Header.Parent = MainCard
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = Header
    
    -- Fix bottom corners
    local HeaderFix = Instance.new("Frame")
    HeaderFix.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    HeaderFix.BackgroundTransparency = 0.5
    HeaderFix.BorderSizePixel = 0
    HeaderFix.Position = UDim2.new(0, 0, 0.5, 0)
    HeaderFix.Size = UDim2.new(1, 0, 0.5, 0)
    HeaderFix.ZIndex = 102
    HeaderFix.Parent = Header
    
    -- Title
    local TitleIcon = Instance.new("ImageLabel")
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Position = UDim2.new(0, 15, 0.5, -10)
    TitleIcon.Size = UDim2.new(0, 20, 0, 20)
    TitleIcon.Image = "rbxassetid://7733992528"
    TitleIcon.ImageColor3 = Color3.fromRGB(150, 100, 255)
    TitleIcon.ZIndex = 103
    TitleIcon.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 42, 0, 0)
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "N4n0Xy1n | Bullet Detector"
    Title.TextColor3 = Color3.fromRGB(220, 200, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 103
    Title.Parent = Header
    
    -- Status Indicator
    local StatusDot = Instance.new("Frame")
    StatusDot.Name = "StatusDot"
    StatusDot.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    StatusDot.BorderSizePixel = 0
    StatusDot.Position = UDim2.new(1, -35, 0.5, -5)
    StatusDot.Size = UDim2.new(0, 10, 0, 10)
    StatusDot.ZIndex = 103
    StatusDot.Parent = Header
    
    local StatusDotCorner = Instance.new("UICorner")
    StatusDotCorner.CornerRadius = UDim.new(1, 0)
    StatusDotCorner.Parent = StatusDot
    
    -- Glow effect for status
    local StatusGlow = Instance.new("ImageLabel")
    StatusGlow.BackgroundTransparency = 1
    StatusGlow.Position = UDim2.new(0.5, -15, 0.5, -15)
    StatusGlow.Size = UDim2.new(0, 30, 0, 30)
    StatusGlow.Image = "rbxassetid://4996890006"
    StatusGlow.ImageColor3 = Color3.fromRGB(50, 255, 100)
    StatusGlow.ImageTransparency = 0.7
    StatusGlow.ZIndex = 102
    StatusGlow.Parent = StatusDot
    
    -- Close Button
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -30, 0.5, -8)
    CloseBtn.Size = UDim2.new(0, 16, 0, 16)
    CloseBtn.Image = "rbxassetid://7733992528"
    CloseBtn.ImageColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.ZIndex = 103
    CloseBtn.Parent = Header
    
    -- Toggle Button (ON/OFF)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    ToggleBtn.BackgroundTransparency = 0.2
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Position = UDim2.new(1, -80, 0.5, -12)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 24)
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "ON"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 10
    ToggleBtn.ZIndex = 103
    ToggleBtn.Parent = Header
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleBtn
    
    -- Content Area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 50)
    Content.Size = UDim2.new(1, 0, 1, -50)
    Content.ZIndex = 102
    Content.Parent = MainCard
    
    -- Main Bullet Display
    local BulletDisplay = Instance.new("Frame")
    BulletDisplay.Name = "BulletDisplay"
    BulletDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    BulletDisplay.BackgroundTransparency = 0.3
    BulletDisplay.BorderSizePixel = 0
    BulletDisplay.Position = UDim2.new(0, 15, 0, 15)
    BulletDisplay.Size = UDim2.new(1, -30, 0, 120)
    BulletDisplay.ZIndex = 103
    BulletDisplay.Parent = Content
    
    local BulletDisplayCorner = Instance.new("UICorner")
    BulletDisplayCorner.CornerRadius = UDim.new(0, 12)
    BulletDisplayCorner.Parent = BulletDisplay
    
    -- Bullet Type Label
    local BulletType = Instance.new("TextLabel")
    BulletType.Name = "BulletType"
    BulletType.BackgroundTransparency = 1
    BulletType.Position = UDim2.new(0, 0, 0, 10)
    BulletType.Size = UDim2.new(1, 0, 0, 50)
    BulletType.Font = Enum.Font.GothamBlack
    BulletType.Text = "SCANNING..."
    BulletType.TextColor3 = Color3.fromRGB(255, 170, 0)
    BulletType.TextSize = 32
    BulletType.ZIndex = 104
    BulletType.Parent = BulletDisplay
    
    -- Bullet Icon
    local BulletIcon = Instance.new("ImageLabel")
    BulletIcon.Name = "BulletIcon"
    BulletIcon.BackgroundTransparency = 1
    BulletIcon.Position = UDim2.new(0.5, -25, 0, 65)
    BulletIcon.Size = UDim2.new(0, 50, 0, 50)
    BulletIcon.Image = "rbxassetid://7733992528"
    BulletIcon.ImageColor3 = Color3.fromRGB(255, 170, 0)
    BulletIcon.ZIndex = 104
    BulletIcon.Parent = BulletDisplay
    
    -- Stats Grid
    local StatsGrid = Instance.new("Frame")
    StatsGrid.Name = "StatsGrid"
    StatsGrid.BackgroundTransparency = 1
    StatsGrid.Position = UDim2.new(0, 15, 0, 145)
    StatsGrid.Size = UDim2.new(1, -30, 0, 70)
    StatsGrid.ZIndex = 103
    StatsGrid.Parent = Content
    
    local StatsLayout = Instance.new("UIGridLayout")
    StatsLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    StatsLayout.CellSize = UDim2.new(0.5, -5, 1, 0)
    StatsLayout.FillDirection = Enum.FillDirection.Horizontal
    StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    StatsLayout.Parent = StatsGrid
    
    -- Live Stat Card
    local LiveCard = Instance.new("Frame")
    LiveCard.Name = "LiveCard"
    LiveCard.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
    LiveCard.BackgroundTransparency = 0.2
    LiveCard.BorderSizePixel = 0
    LiveCard.ZIndex = 104
    LiveCard.Parent = StatsGrid
    
    local LiveCardCorner = Instance.new("UICorner")
    LiveCardCorner.CornerRadius = UDim.new(0, 10)
    LiveCardCorner.Parent = LiveCard
    
    local LiveLabel = Instance.new("TextLabel")
    LiveLabel.BackgroundTransparency = 1
    LiveLabel.Position = UDim2.new(0, 0, 0, 5)
    LiveLabel.Size = UDim2.new(1, 0, 0, 20)
    LiveLabel.Font = Enum.Font.GothamBold
    LiveLabel.Text = "LIVE ROUNDS"
    LiveLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    LiveLabel.TextSize = 11
    LiveLabel.ZIndex = 105
    LiveLabel.Parent = LiveCard
    
    local LiveValue = Instance.new("TextLabel")
    LiveValue.Name = "LiveValue"
    LiveValue.BackgroundTransparency = 1
    LiveValue.Position = UDim2.new(0, 0, 0, 25)
    LiveValue.Size = UDim2.new(1, 0, 0, 35)
    LiveValue.Font = Enum.Font.GothamBlack
    LiveValue.Text = "0"
    LiveValue.TextColor3 = Color3.fromRGB(255, 80, 80)
    LiveValue.TextSize = 28
    LiveValue.ZIndex = 105
    LiveValue.Parent = LiveCard
    
    -- Blank Stat Card
    local BlankCard = Instance.new("Frame")
    BlankCard.Name = "BlankCard"
    BlankCard.BackgroundColor3 = Color3.fromRGB(15, 40, 25)
    BlankCard.BackgroundTransparency = 0.2
    BlankCard.BorderSizePixel = 0
    BlankCard.ZIndex = 104
    BlankCard.Parent = StatsGrid
    
    local BlankCardCorner = Instance.new("UICorner")
    BlankCardCorner.CornerRadius = UDim.new(0, 10)
    BlankCardCorner.Parent = BlankCard
    
    local BlankLabel = Instance.new("TextLabel")
    BlankLabel.BackgroundTransparency = 1
    BlankLabel.Position = UDim2.new(0, 0, 0, 5)
    BlankLabel.Size = UDim2.new(1, 0, 0, 20)
    BlankLabel.Font = Enum.Font.GothamBold
    BlankLabel.Text = "BLANK ROUNDS"
    BlankLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    BlankLabel.TextSize = 11
    BlankLabel.ZIndex = 105
    BlankLabel.Parent = BlankCard
    
    local BlankValue = Instance.new("TextLabel")
    BlankValue.Name = "BlankValue"
    BlankValue.BackgroundTransparency = 1
    BlankValue.Position = UDim2.new(0, 0, 0, 25)
    BlankValue.Size = UDim2.new(1, 0, 0, 35)
    BlankValue.Font = Enum.Font.GothamBlack
    BlankValue.Text = "0"
    BlankValue.TextColor3 = Color3.fromRGB(80, 255, 120)
    BlankValue.TextSize = 28
    BlankValue.ZIndex = 105
    BlankValue.Parent = BlankCard
    
    -- Chamber Visualization
    local ChamberVis = Instance.new("Frame")
    ChamberVis.Name = "ChamberVis"
    ChamberVis.BackgroundTransparency = 1
    ChamberVis.Position = UDim2.new(0, 15, 0, 225)
    ChamberVis.Size = UDim2.new(1, -30, 0, 60)
    ChamberVis.ZIndex = 103
    ChamberVis.Parent = Content
    
    local ChamberLayout = Instance.new("UIListLayout")
    ChamberLayout.FillDirection = Enum.FillDirection.Horizontal
    ChamberLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ChamberLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ChamberLayout.Padding = UDim.new(0, 8)
    ChamberLayout.Parent = ChamberVis
    
    -- Create chamber slots (max 8)
    for i = 1, 8 do
        local slot = Instance.new("Frame")
        slot.Name = "Slot_" .. i
        slot.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        slot.BackgroundTransparency = 0.3
        slot.BorderSizePixel = 0
        slot.Size = UDim2.new(0, 35, 0, 35)
        slot.ZIndex = 104
        slot.Parent = ChamberVis
        
        local slotCorner = Instance.new("UICorner")
        slotCorner.CornerRadius = UDim.new(0, 8)
        slotCorner.Parent = slot
        
        local slotNum = Instance.new("TextLabel")
        slotNum.BackgroundTransparency = 1
        slotNum.Size = UDim2.new(1, 0, 1, 0)
        slotNum.Font = Enum.Font.GothamBold
        slotNum.Text = tostring(i)
        slotNum.TextColor3 = Color3.fromRGB(150, 150, 170)
        slotNum.TextSize = 14
        slotNum.ZIndex = 105
        slotNum.Parent = slot
    end
    
    -- Confidence Bar
    local ConfidenceBar = Instance.new("Frame")
    ConfidenceBar.Name = "ConfidenceBar"
    ConfidenceBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ConfidenceBar.BackgroundTransparency = 0.3
    ConfidenceBar.BorderSizePixel = 0
    ConfidenceBar.Position = UDim2.new(0, 15, 0, 295)
    ConfidenceBar.Size = UDim2.new(1, -30, 0, 30)
    ConfidenceBar.ZIndex = 103
    ConfidenceBar.Parent = Content
    
    local ConfidenceBarCorner = Instance.new("UICorner")
    ConfidenceBarCorner.CornerRadius = UDim.new(0, 8)
    ConfidenceBarCorner.Parent = ConfidenceBar
    
    local ConfidenceFill = Instance.new("Frame")
    ConfidenceFill.Name = "ConfidenceFill"
    ConfidenceFill.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    ConfidenceFill.BackgroundTransparency = 0.2
    ConfidenceFill.BorderSizePixel = 0
    ConfidenceFill.Size = UDim2.new(0, 0, 1, 0)
    ConfidenceFill.ZIndex = 104
    ConfidenceFill.Parent = ConfidenceBar
    
    local ConfidenceFillCorner = Instance.new("UICorner")
    ConfidenceFillCorner.CornerRadius = UDim.new(0, 8)
    ConfidenceFillCorner.Parent = ConfidenceFill
    
    local ConfidenceLabel = Instance.new("TextLabel")
    ConfidenceLabel.Name = "ConfidenceLabel"
    ConfidenceLabel.BackgroundTransparency = 1
    ConfidenceLabel.Size = UDim2.new(1, 0, 1, 0)
    ConfidenceLabel.Font = Enum.Font.GothamBold
    ConfidenceLabel.Text = "Confidence: 0%"
    ConfidenceLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    ConfidenceLabel.TextSize = 11
    ConfidenceLabel.ZIndex = 105
    ConfidenceLabel.Parent = ConfidenceBar
    
    -- Footer Info
    local Footer = Instance.new("TextLabel")
    Footer.Name = "Footer"
    Footer.BackgroundTransparency = 1
    Footer.Position = UDim2.new(0, 0, 1, -25)
    Footer.Size = UDim2.new(1, 0, 0, 20)
    Footer.Font = Enum.Font.Gotham
    Footer.Text = "N4n0Xy1n Systems | Buckshot Roulette v3.0"
    Footer.TextColor3 = Color3.fromRGB(100, 100, 130)
    Footer.TextSize = 10
    Footer.ZIndex = 103
    Footer.Parent = Content
    
    -- Store references
    self.Elements = {
        ScreenGui = ScreenGui,
        MainCard = MainCard,
        Backdrop = Backdrop,
        StatusDot = StatusDot,
        StatusGlow = StatusGlow,
        ToggleBtn = ToggleBtn,
        BulletType = BulletType,
        BulletIcon = BulletIcon,
        LiveValue = LiveValue,
        BlankValue = BlankValue,
        ConfidenceFill = ConfidenceFill,
        ConfidenceLabel = ConfidenceLabel,
        ChamberSlots = {}
    }
    
    -- Collect chamber slots
    for i = 1, 8 do
        self.Elements.ChamberSlots[i] = ChamberVis:FindFirstChild("Slot_" .. i)
    end
    
    -- Draggable functionality
    local dragInput, dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainCard.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            dragStart = input.Position
            startPos = MainCard.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and self.Dragging then
            updateDrag(input)
        end
    end)
    
    -- Toggle functionality
    ToggleBtn.MouseButton1Click:Connect(function()
        self.Enabled = not self.Enabled
        if self.Enabled then
            ToggleBtn.Text = "ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
            StatusDot.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
            StatusGlow.ImageColor3 = Color3.fromRGB(50, 255, 100)
            Content.Visible = true
        else
            ToggleBtn.Text = "OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            StatusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            StatusGlow.ImageColor3 = Color3.fromRGB(255, 100, 100)
            Content.Visible = false
        end
    end)
    
    -- Close functionality
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainCard, { Size = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Tween(Backdrop, { BackgroundTransparency = 1 }, 0.3)
        task.delay(0.35, function()
            ScreenGui:Destroy()
        end)
    end)
    
    -- Entrance animation
    Tween(Backdrop, { BackgroundTransparency = 0.6 }, 0.5, Enum.EasingStyle.Quint)
    Tween(MainCard, { Size = UDim2.new(0, 380, 0, 420) }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    return self.Elements
end

function UI:UpdateDisplay()
    if not self.Enabled or not self.Elements.MainCard then return end
    
    local bulletType = BulletEngine:GetNextBulletType()
    local bulletColor = BulletEngine:GetNextBulletColor()
    
    -- Update main display
    self.Elements.BulletType.Text = bulletType
    self.Elements.BulletType.TextColor3 = bulletColor
    self.Elements.BulletIcon.ImageColor3 = bulletColor
    
    -- Update stats
    self.Elements.LiveValue.Text = tostring(BulletEngine.LiveCount)
    self.Elements.BlankValue.Text = tostring(BulletEngine.BlankCount)
    
    -- Update confidence bar
    local confidence = math.clamp(BulletEngine.Confidence, 0, 100)
    Tween(self.Elements.ConfidenceFill, { Size = UDim2.new(confidence / 100, 0, 1, 0) }, 0.3)
    self.Elements.ConfidenceLabel.Text = string.format("Confidence: %d%%", confidence)
    
    -- Update confidence color
    if confidence >= 80 then
        self.Elements.ConfidenceFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    elseif confidence >= 50 then
        self.Elements.ConfidenceFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    else
        self.Elements.ConfidenceFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end
    
    -- Update chamber visualization
    for i = 1, 8 do
        local slot = self.Elements.ChamberSlots[i]
        if slot then
            if i <= BulletEngine.TotalRounds then
                local bullet = BulletEngine.ChamberData[i]
                local isLive = (bullet == true or bullet == 1 or bullet == "Live")
                
                slot.BackgroundColor3 = isLive and Color3.fromRGB(80, 20, 20) or Color3.fromRGB(20, 80, 40)
                slot:FindFirstChildOfClass("TextLabel").TextColor3 = isLive and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 150)
                
                -- Highlight current chamber
                if i == 1 then
                    slot.Size = UDim2.new(0, 40, 0, 40)
                    local stroke = slot:FindFirstChildOfClass("UIStroke")
                    if not stroke then
                        stroke = Instance.new("UIStroke")
                        stroke.Color = bulletColor
                        stroke.Thickness = 2
                        stroke.Parent = slot
                    else
                        stroke.Color = bulletColor
                    end
                else
                    slot.Size = UDim2.new(0, 35, 0, 35)
                    local stroke = slot:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke:Destroy() end
                end
            else
                slot.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                slot:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(150, 150, 170)
                slot.Size = UDim2.new(0, 35, 0, 35)
                local stroke = slot:FindFirstChildOfClass("UIStroke")
                if stroke then stroke:Destroy() end
            end
        end
    end
    
    -- Update status dot
    if bulletType == "UNKNOWN" then
        self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        self.Elements.StatusGlow.ImageColor3 = Color3.fromRGB(255, 170, 0)
    else
        self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
        self.Elements.StatusGlow.ImageColor3 = Color3.fromRGB(50, 255, 100)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN LOOP & INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local function Initialize()
    -- Create UI
    UI:CreateModernInterface()
    
    -- Start scanning loop
    task.spawn(function()
        while UI.Elements.MainCard and UI.Elements.MainCard.Parent do
            if UI.Enabled then
                local success = pcall(function()
                    BulletEngine:DeepScan()
                    UI:UpdateDisplay()
                end)
                
                if not success then
                    warn("[N4n0Xy1n] Scan error, retrying...")
                end
            end
            task.wait(0.5) -- Scan interval
        end
    end)
    
    -- Hotkey toggle (Insert)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            if UI.Elements.ScreenGui then
                UI.Elements.ScreenGui.Enabled = not UI.Elements.ScreenGui.Enabled
            end
        end
    end)
    
    -- Print startup info
    print("╔══════════════════════════════════════╗")
    print("║     N4n0Xy1n Bullet Detector v3.0   ║")
    print("║     Mode: 4ct1v3 | 3v4s10n: 0N       ║")
    print("║     Press INSERT to toggle UI        ║")
    print("╚══════════════════════════════════════╝")
end

-- ═══════════════════════════════════════════════════════════════
-- ANTI-CHEAT BYPASS LAYER 3: Additional Protections
-- ═══════════════════════════════════════════════════════════════

-- Spoof HWID jika tersedia
if syn and syn.get_hwid then
    local oldHWID = syn.get_hwid
    syn.get_hwid = function()
        return string.rep("0", 32)
    end
end

-- Block screenshot detection via hook
if hookfunction and request then
    local oldRequest = request
    hookfunction(oldRequest, function(options)
        if options.Url and (options.Url:find("discord") or options.Url:find("webhook") or options.Url:find("api")) then
            return {StatusCode = 200, Body = "OK", Headers = {}}
        end
        return oldRequest(options)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- EXECUTE
-- ═══════════════════════════════════════════════════════════════

Initialize()

-- Return module untuk external access
return {
    Engine = BulletEngine,
    UI = UI,
    Version = "3.0",
    Author = "N4n0Xy1n"
}
