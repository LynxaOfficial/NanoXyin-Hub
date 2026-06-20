--// Native Module | Build 2026.06.20
--// No external libs, pure Roblox API

local _s = game:GetService
local plrs = _s("Players")
local rs = _s("RunService")
local ws = _s("Workspace")
local uis = _s("UserInputService")
local vim = _s("VirtualInputManager")
local sg = _s("StarterGui")
local lp = plrs.LocalPlayer
local cam = ws.CurrentCamera
local rnd = Random.new(tick() * 1337)

--// Stealth Config (all single chars)
local c = {
    a = {e = true, k = Enum.UserInputType.MouseButton2, f = 200, s = 0.15, p = "Head", t = true, w = false, pr = 0.12, acc = 0.80, rmin = 0.1, rmax = 0.3, jit = 0.1, shk = 0.05},
    af = {e = true, k = Enum.KeyCode.F, a = false, dmin = 0.08, dmax = 0.2, ls = 0},
    e = {en = true, b = true, bf = true, bc = Color3.fromRGB(255, 50, 50), bfc = Color3.fromRGB(255, 50, 50), bft = 0.3, n = true, nc = Color3.fromRGB(255, 255, 255), ns = 12, dist = true, h = true, hb = true, md = 2500},
    x = {e = true, k = Enum.KeyCode.X, a = true, wt = 0.4, ehc = Color3.fromRGB(255, 0, 0), eoc = Color3.fromRGB(255, 255, 0)},
    f = {v = true, c = Color3.fromRGB(255, 255, 255), t = 0.4, th = 1}
}

--// State
local _t = nil
local _rt = false
local _rd = 0
local _mo = Vector2.new(0, 0)
local _so = Vector2.new(0, 0)
local _eo = {}
local _xh = {}
local _fc = nil
local _lastShot = 0

--// Bypass Layer (no getrawmetatable)
local function _bl()
    -- Method 1: Hook namecall via hookmetamethod if available
    if hookmetamethod then
        pcall(function()
            local old = hookmetamethod(game, "__namecall", function(self, ...)
                local m = getnamecallmethod()
                if m == "Kick" or m == "Destroy" then
                    local s = tostring(self):lower()
                    if s:find("kick") or s:find("ban") or s:find("anti") or s:find("ac") or s:find("det") then
                        return wait(9e9)
                    end
                end
                return old(self, ...)
            end)
        end)
    end
    
    -- Method 2: Hook Kick directly
    if hookfunction then
        pcall(function()
            local oldKick = hookfunction(lp.Kick, function(self, msg)
                if self == lp then
                    return wait(9e9)
                end
                return oldKick(self, msg)
            end)
        end)
    end
    
    -- Method 3: Block common AC remotes
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = v.Name:lower()
                if n:find("kick") or n:find("ban") or n:find("det") or n:find("check") or n:find("verify") or n:find("ac") then
                    if v:IsA("RemoteEvent") then
                        local oldFire = v.FireServer
                        v.FireServer = function(...) return nil end
                    elseif v:IsA("RemoteFunction") then
                        local oldInvoke = v.InvokeServer
                        v.InvokeServer = function(...) return nil end
                    end
                end
            end
        end
    end)
    
    -- Method 4: Remove loading screens
    pcall(function()
        for _, v in pairs(lp.PlayerGui:GetChildren()) do
            if v:IsA("ScreenGui") then
                local n = v.Name:lower()
                if n:find("load") or n:find("anti") or n:find("ac") or n:find("det") or n:find("check") then
                    v.Enabled = false
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end)
end

_bl()

--// Helpers
local function _gc(p) return p.Character end
local function _gh(c) return c:FindFirstChildOfClass("Humanoid") end
local function _gt(c) return c:FindFirstChild(c.a.p) or c:FindFirstChild("Head") end
local function _ia(c) local h = _gh(c) return h and h.Health > 0 end
local function _it(p) if not c.a.t then return false end return p.Team == lp.Team end

local function _iv(t, p)
    if not c.a.w then return true end
    local o = cam.CFrame.Position
    local d = (p.Position - o).Unit * (p.Position - o).Magnitude
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {lp.Character, cam}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local r = ws:Raycast(o, d, rp)
    return r == nil or r.Instance:IsDescendantOf(t.Character)
end

local function _cp()
    local cl = nil
    local sd = c.a.f
    for _, p in ipairs(plrs:GetPlayers()) do
        if p == lp then continue end
        if _it(p) then continue end
        local ch = _gc(p)
        if not ch then continue end
        if not _ia(ch) then continue end
        local h = _gt(ch)
        if not h then continue end
        local sp, os = cam:WorldToViewportPoint(h.Position)
        if not os then continue end
        local d = (Vector2.new(sp.X, sp.Y) - uis:GetMouseLocation()).Magnitude
        if d < sd then
            if _iv(p, h) then
                sd = d
                cl = p
            end
        end
    end
    return cl
end

local function _pp(t)
    local ch = _gc(t)
    if not ch then return nil end
    local h = _gt(ch)
    if not h then return nil end
    local hu = _gh(ch)
    if not hu then return h.Position end
    local v = hu.MoveDirection * hu.WalkSpeed
    return h.Position + (v * c.a.pr)
end

--// Human Behavior
local function _sm() return rnd:NextNumber() > c.a.acc end
local function _gmo() local a = rnd:NextNumber() * math.pi * 2 local d = rnd:NextNumber(20, 50) return Vector2.new(math.cos(a)*d, math.sin(a)*d) end
local function _gso() return Vector2.new(rnd:NextNumber(-c.a.shk, c.a.shk)*10, rnd:NextNumber(-c.a.shk, c.a.shk)*10) end
local function _grd() return rnd:NextNumber(c.a.rmin, c.a.rmax) end

--// Wall Vision (Highlight-based, no Drawing)
local function _sx()
    for _, o in ipairs(ws:GetDescendants()) do
        if o:IsA("BasePart") and not o:IsDescendantOf(lp.Character) then
            local n = o.Name:lower()
            if n:find("wall") or n:find("door") or n:find("barrier") or n:find("cover") then
                local ot = o:GetAttribute("_o")
                if not ot then o:SetAttribute("_o", o.Transparency) end
                if c.x.a then o.Transparency = c.x.wt else o.Transparency = o:GetAttribute("_o") or 0 end
            end
        end
    end
end

local function _ux()
    for _, h in pairs(_xh) do if h then pcall(function() h:Destroy() end) end end
    _xh = {}
    if not c.x.a then return end
    for _, p in ipairs(plrs:GetPlayers()) do
        if p == lp then continue end
        if _it(p) then continue end
        local ch = _gc(p)
        if not ch then continue end
        if not _ia(ch) then continue end
        for _, pt in ipairs(ch:GetDescendants()) do
            if pt:IsA("BasePart") then
                local hl = Instance.new("Highlight")
                hl.Name = "_" .. tostring(rnd:NextInteger(10, 99))
                hl.Adornee = pt
                hl.FillColor = c.x.ehc
                hl.OutlineColor = c.x.eoc
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = pt
                table.insert(_xh, hl)
            end
        end
    end
end

local function _tx()
    c.x.a = not c.x.a
    _sx()
    _ux()
end

--// FOV Ring (using Part + BillboardGui instead of Drawing)
local function _cf()
    local part = Instance.new("Part")
    part.Name = "_f_" .. tostring(rnd:NextInteger(100, 999))
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Parent = ws
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "_b_" .. tostring(rnd:NextInteger(100, 999))
    bb.Size = UDim2.new(0, c.a.f * 2, 0, c.a.f * 2)
    bb.AlwaysOnTop = true
    bb.Parent = part
    
    local frame = Instance.new("Frame")
    frame.Name = "_fr_" .. tostring(rnd:NextInteger(100, 999))
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = bb
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = c.f.c
    stroke.Thickness = c.f.th
    stroke.Transparency = c.f.t
    stroke.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
    
    _fc = {part = part, bb = bb, frame = frame, stroke = stroke}
end

_cf()

--// ESP using BillboardGui (native, no Drawing)
local function _ce(p)
    local ch = _gc(p)
    if not ch then return end
    
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Main ESP Billboard
    local bb = Instance.new("BillboardGui")
    bb.Name = "_e_" .. tostring(rnd:NextInteger(100, 999))
    bb.Size = UDim2.new(0, 200, 0, 300)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = hrp
    
    -- Box
    local box = Instance.new("Frame")
    box.Name = "_bx_" .. tostring(rnd:NextInteger(100, 999))
    box.Size = UDim2.new(0, 80, 0, 120)
    box.Position = UDim2.new(0.5, -40, 0.5, -60)
    box.BackgroundColor3 = c.e.bc
    box.BackgroundTransparency = c.e.bft
    box.BorderSizePixel = 0
    box.Parent = bb
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = c.e.bc
    boxStroke.Thickness = 1
    boxStroke.Parent = box
    
    -- Name
    local name = Instance.new("TextLabel")
    name.Name = "_n_" .. tostring(rnd:NextInteger(100, 999))
    name.Size = UDim2.new(1, 0, 0, 20)
    name.Position = UDim2.new(0, 0, 0, -25)
    name.BackgroundTransparency = 1
    name.Text = p.Name
    name.TextColor3 = c.e.nc
    name.TextSize = c.e.ns
    name.Font = Enum.Font.GothamBold
    name.Parent = bb
    
    -- Distance
    local dist = Instance.new("TextLabel")
    dist.Name = "_d_" .. tostring(rnd:NextInteger(100, 999))
    dist.Size = UDim2.new(1, 0, 0, 20)
    dist.Position = UDim2.new(0, 0, 1, 5)
    dist.BackgroundTransparency = 1
    dist.Text = "0m"
    dist.TextColor3 = Color3.fromRGB(255, 255, 255)
    dist.TextSize = 12
    dist.Font = Enum.Font.Gotham
    dist.Parent = bb
    
    -- Health Bar
    local hpBar = Instance.new("Frame")
    hpBar.Name = "_hp_" .. tostring(rnd:NextInteger(100, 999))
    hpBar.Size = UDim2.new(0, 4, 0, 120)
    hpBar.Position = UDim2.new(0, -10, 0.5, -60)
    hpBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = bb
    
    local hpFill = Instance.new("Frame")
    hpFill.Name = "_hf_" .. tostring(rnd:NextInteger(100, 999))
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBar
    
    _eo[p] = {bb = bb, box = box, name = name, dist = dist, hpBar = hpBar, hpFill = hpFill}
end

local function _re(p)
    local o = _eo[p]
    if not o then return end
    pcall(function() o.bb:Destroy() end)
    _eo[p] = nil
end

local function _ue()
    for p, o in pairs(_eo) do
        local ch = _gc(p)
        if not ch or not _ia(ch) or p == lp or (c.a.t and _it(p)) then
            pcall(function() o.bb.Enabled = false end)
            continue
        end
        
        local hu = _gh(ch)
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hu or not hrp then
            pcall(function() o.bb.Enabled = false end)
            continue
        end
        
        local dist = (hrp.Position - cam.CFrame.Position).Magnitude
        if dist > c.e.md then
            pcall(function() o.bb.Enabled = false end)
            continue
        end
        
        pcall(function()
            o.bb.Enabled = true
            o.dist.Text = math.floor(dist) .. "m"
            
            local hp = hu.Health / hu.MaxHealth
            o.hpFill.Size = UDim2.new(1, 0, hp, 0)
            o.hpFill.Position = UDim2.new(0, 0, 1 - hp, 0)
            o.hpFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
        end)
    end
end

--// Aim using CFrame offset (no mousemoverel)
local function _sa()
    if not c.a.e then return end
    
    if uis:IsMouseButtonPressed(c.a.k) then
        if not _t then
            _t = _cp()
            if _t then
                _rt = true
                _rd = tick() + _grd()
                _mo = _sm() and _gmo() or Vector2.new(0, 0)
            end
        end
        
        if _t and _rt then
            if tick() < _rd then return end
            _rt = false
        end
        
        if _t then
            local ch = _gc(_t)
            if not ch or not _ia(ch) then
                _t = nil
                _rt = false
                return
            end
            
            local pp = _pp(_t)
            if not pp then
                _t = nil
                _rt = false
                return
            end
            
            -- CFrame-based aim (stealthier than mousemoverel)
            local targetCF = CFrame.new(cam.CFrame.Position, pp)
            local currentCF = cam.CFrame
            local diff = targetCF.LookVector - currentCF.LookVector
            
            -- Add jitter and shake
            local jitterX = rnd:NextNumber(-c.a.jit, c.a.jit) * diff.X
            local jitterY = rnd:NextNumber(-c.a.jit, c.a.jit) * diff.Y
            diff = diff + Vector3.new(jitterX, jitterY, 0)
            
            -- Add miss offset
            local missX = _mo.X / 1000
            local missY = _mo.Y / 1000
            diff = diff + Vector3.new(missX, missY, 0)
            
            -- Smooth transition
            local newLook = currentCF.LookVector + (diff * c.a.s)
            cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + newLook)
            
            -- Auto-fire with VirtualInputManager
            if c.af.e and c.af.a then
                local ct = tick()
                local actualDelay = rnd:NextNumber(c.af.dmin, c.af.dmax)
                if ct - _lastShot >= actualDelay then
                    if not c.af.ra or (c.af.ra and _t) then
                        local sp = cam:WorldToViewportPoint(pp)
                        local mp = uis:GetMouseLocation()
                        local tp = Vector2.new(sp.X, sp.Y) + _mo
                        local dt = (tp - mp).Magnitude
                        if dt < 30 then
                            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(rnd:NextNumber(0.02, 0.08))
                            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            _lastShot = ct
                        end
                    end
                end
            end
        end
    else
        _t = nil
        _rt = false
        _mo = Vector2.new(0, 0)
    end
end

--// Input
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == c.af.k then
        c.af.a = not c.af.a
        sg:SetCore("SendNotification", {
            Title = "Auto",
            Text = c.af.a and "ON" or "OFF",
            Duration = 2
        })
    end
    
    if input.KeyCode == c.x.k then
        _tx()
        sg:SetCore("SendNotification", {
            Title = "Vision",
            Text = c.x.a and "ON" or "OFF",
            Duration = 2
        })
    end
end)

--// Main Loop
rs.RenderStepped:Connect(function()
    -- Update FOV ring position
    if _fc and _fc.part then
        local mouseRay = cam:ViewportPointToRay(uis:GetMouseLocation().X, uis:GetMouseLocation().Y)
        _fc.part.CFrame = CFrame.new(mouseRay.Origin + mouseRay.Direction * 10)
        _fc.bb.Size = UDim2.new(0, c.a.f * 2, 0, c.a.f * 2)
        _fc.stroke.Transparency = c.f.t
        _fc.part.Transparency = c.f.v and 1 or 1
    end
    
    -- Update ESP
    if c.e.en then
        for p in pairs(_eo) do
            if not p.Parent then
                _re(p)
            end
        end
        
        for _, p in ipairs(plrs:GetPlayers()) do
            if p ~= lp and not _eo[p] then
                _ce(p)
            end
        end
        
        _ue()
    end
    
    -- Update X-Ray
    if c.x.a then
        _ux()
    end
    
    -- Run aim
    _sa()
end)

--// Events
plrs.PlayerAdded:Connect(function(p)
    if p ~= lp and c.e.en then
        _ce(p)
    end
end)

plrs.PlayerRemoving:Connect(function(p)
    _re(p)
end)

--// Init
for _, p in ipairs(plrs:GetPlayers()) do
    if p ~= lp then
        _ce(p)
    end
end

_sx()
_ux()

print("Module loaded | v2.2.0")
print("RMB = Snap | F = Auto | X = Vision")
print("Native API | No Drawing | CFrame aim")
