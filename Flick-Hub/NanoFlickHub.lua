--// Build: 2026.06.20 | Module: InputAssist
--// Compiled for: Phantom Forces / Bad Business / Counter Blox

local _s = game:GetService
local plrs = _s("Players")
local rs = _s("RunService")
local ws = _s("Workspace")
local uis = _s("UserInputService")
local ts = _s("TweenService")
local rnd = Random.new(tick() * 1000)

local cam = ws.CurrentCamera
local lp = plrs.LocalPlayer

--// Anti-Layer
local function _al()
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
    
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if m == "Kick" or m == "Destroy" then
                local s = tostring(self):lower()
                if s:find("load") or s:find("anti") or s:find("ac") or s:find("det") or s:find("check") or s:find("ban") then
                    return wait(9e9)
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end

_al()

--// Splash
local function _sp()
    local sg = Instance.new("ScreenGui")
    sg.Name = "Init_" .. tostring(rnd:NextInteger(1000, 9999))
    sg.Parent = game.CoreGui
    
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 400, 0, 200)
    fr.Position = UDim2.new(0.5, -200, 0.5, -100)
    fr.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    fr.BorderSizePixel = 0
    fr.Parent = sg
    
    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, 12)
    cr.Parent = fr
    
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 0.4, 0)
    tl.Position = UDim2.new(0, 0, 0.1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "InputAssist"
    tl.TextColor3 = Color3.fromRGB(0, 255, 200)
    tl.TextSize = 48
    tl.Font = Enum.Font.GothamBold
    tl.Parent = fr
    
    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, 0, 0.2, 0)
    sl.Position = UDim2.new(0, 0, 0.5, 0)
    sl.BackgroundTransparency = 1
    sl.Text = "v2.1.0"
    sl.TextColor3 = Color3.fromRGB(200, 200, 200)
    sl.TextSize = 24
    sl.Font = Enum.Font.Gotham
    sl.Parent = fr
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, 0, 0.15, 0)
    st.Position = UDim2.new(0, 0, 0.75, 0)
    st.BackgroundTransparency = 1
    st.Text = "Initializing..."
    st.TextColor3 = Color3.fromRGB(0, 255, 200)
    st.TextSize = 18
    st.Font = Enum.Font.Gotham
    st.Parent = fr
    
    local mods = {"Render", "Input", "Network", "Physics"}
    for _, m in ipairs(mods) do
        st.Text = "Loading " .. m .. "..."
        wait(0.25)
    end
    
    st.Text = "Ready!"
    st.TextColor3 = Color3.fromRGB(0, 255, 100)
    wait(0.4)
    
    ts:Create(fr, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -200, 0, -250)}):Play()
    wait(0.6)
    sg:Destroy()
end

_sp()

--// Config
local cfg = {
    a = {
        e = true,
        k = Enum.UserInputType.MouseButton2,
        f = 180,
        s = 0.12,
        p = "Head",
        t = true,
        w = false,
        pr = 0.14,
        acc = 0.80, -- 80% accuracy
        missRate = 0.20,
        reactionMin = 0.08,
        reactionMax = 0.25,
        overshoot = 0.15,
        jitter = 0.08,
        shake = 0.03,
    },
    af = {
        e = true,
        k = Enum.KeyCode.F,
        a = false,
        d = 0.08,
        ls = 0,
        ra = false,
        delayMin = 0.05,
        delayMax = 0.15,
    },
    e = {
        en = true,
        b = true,
        bf = true,
        bc = Color3.fromRGB(255, 0, 80),
        bfc = Color3.fromRGB(255, 0, 80),
        bft = 0.15,
        l = true,
        lc = Color3.fromRGB(255, 255, 255),
        n = true,
        nc = Color3.fromRGB(255, 255, 255),
        ns = 14,
        dist = true,
        h = true,
        hb = true,
        tr = false,
        trc = Color3.fromRGB(255, 0, 80),
        md = 2000,
    },
    x = {
        e = true,
        k = Enum.KeyCode.X,
        a = true,
        wt = 0.3,
        ehc = Color3.fromRGB(255, 0, 0),
        eoc = Color3.fromRGB(255, 255, 0),
    },
    f = {
        v = true,
        c = Color3.fromRGB(255, 255, 255),
        t = 0.5,
        th = 1,
    }
}

--// State
local _eo = {}
local _at = nil
local _fc = nil
local _xh = {}
local _lastTarget = nil
local _targetSwitchTime = 0
local _reactionDelay = 0
local _isReacting = false
local _missOffset = Vector2.new(0, 0)
local _shakeOffset = Vector2.new(0, 0)

--// Helpers
local function _gc(p) return p.Character end
local function _gh(c) return c:FindFirstChildOfClass("Humanoid") end
local function _gt(c) return c:FindFirstChild(cfg.a.p) or c:FindFirstChild("Head") end
local function _ia(c) local h = _gh(c) return h and h.Health > 0 end
local function _it(p) if not cfg.a.t then return false end return p.Team == lp.Team end

local function _iv(t, p)
    if not cfg.a.w then return true end
    local o = cam.CFrame.Position
    local d = (p.Position - o).Unit * (p.Position - o).Magnitude
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {lp.Character, cam}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local r = ws:Raycast(o, d, rp)
    return r == nil or r.Instance:IsDescendantOf(t.Character)
end

local function _cp()
    local c = nil
    local sd = cfg.a.f
    
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
                c = p
            end
        end
    end
    
    return c
end

local function _pp(t)
    local ch = _gc(t)
    if not ch then return nil end
    local h = _gt(ch)
    if not h then return nil end
    local hu = _gh(ch)
    if not hu then return h.Position end
    local v = hu.MoveDirection * hu.WalkSpeed
    return h.Position + (v * cfg.a.pr)
end

--// Human-like behavior generators
local function _shouldMiss()
    return rnd:NextNumber() > cfg.a.acc
end

local function _getMissOffset()
    local angle = rnd:NextNumber() * math.pi * 2
    local dist = rnd:NextNumber(15, 45)
    return Vector2.new(math.cos(angle) * dist, math.sin(angle) * dist)
end

local function _getShake()
    return Vector2.new(
        rnd:NextNumber(-cfg.a.shake, cfg.a.shake) * 10,
        rnd:NextNumber(-cfg.a.shake, cfg.a.shake) * 10
    )
end

local function _getReactionDelay()
    return rnd:NextNumber(cfg.a.reactionMin, cfg.a.reactionMax)
end

local function _getOvershoot(target, current)
    local dir = (target - current).Unit
    local dist = (target - current).Magnitude
    local overshootDist = dist * cfg.a.overshoot
    return dir * overshootDist
end

--// Wall Vision
local function _sx()
    for _, o in ipairs(ws:GetDescendants()) do
        if o:IsA("BasePart") and not o:IsDescendantOf(lp.Character) then
            local n = o.Name:lower()
            if n:find("wall") or n:find("door") or n:find("barrier") or n:find("cover") or n:find("block") then
                local ot = o:GetAttribute("_ot")
                if not ot then o:SetAttribute("_ot", o.Transparency) end
                if cfg.x.a then
                    o.Transparency = cfg.x.wt
                else
                    o.Transparency = o:GetAttribute("_ot") or 0
                end
            end
        end
    end
end

local function _ux()
    for _, h in pairs(_xh) do
        if h then pcall(function() h:Destroy() end) end
    end
    _xh = {}
    
    if not cfg.x.a then return end
    
    for _, p in ipairs(plrs:GetPlayers()) do
        if p == lp then continue end
        if _it(p) then continue end
        local ch = _gc(p)
        if not ch then continue end
        if not _ia(ch) then continue end
        
        for _, pt in ipairs(ch:GetDescendants()) do
            if pt:IsA("BasePart") then
                local hl = Instance.new("Highlight")
                hl.Name = "_hl_" .. tostring(rnd:NextInteger(100, 999))
                hl.Adornee = pt
                hl.FillColor = cfg.x.ehc
                hl.OutlineColor = cfg.x.eoc
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = pt
                table.insert(_xh, hl)
            end
        end
    end
end

local function _tx()
    cfg.x.a = not cfg.x.a
    _sx()
    _ux()
end

--// FOV Ring
local function _cf()
    _fc = Drawing.new("Circle")
    _fc.Visible = cfg.f.v
    _fc.Color = cfg.f.c
    _fc.Transparency = cfg.f.t
    _fc.Thickness = cfg.f.th
    _fc.Filled = false
    _fc.NumSides = 64
    _fc.Radius = cfg.a.f
end

_cf()

--// Overlay
local function _ce(p)
    local o = {
        b = Drawing.new("Square"),
        bf = Drawing.new("Square"),
        l = Drawing.new("Line"),
        n = Drawing.new("Text"),
        d = Drawing.new("Text"),
        hb = Drawing.new("Square"),
        hbb = Drawing.new("Square"),
        tr = Drawing.new("Line"),
    }
    
    o.b.Thickness = 1
    o.b.Color = cfg.e.bc
    o.b.Transparency = 1
    o.b.Filled = false
    o.b.Visible = false
    
    o.bf.Color = cfg.e.bfc
    o.bf.Transparency = cfg.e.bft
    o.bf.Filled = true
    o.bf.Visible = false
    
    o.l.Thickness = 1
    o.l.Color = cfg.e.lc
    o.l.Visible = false
    
    o.n.Size = cfg.e.ns
    o.n.Center = true
    o.n.Outline = true
    o.n.Color = cfg.e.nc
    o.n.Visible = false
    
    o.d.Size = 12
    o.d.Center = true
    o.d.Outline = true
    o.d.Color = Color3.fromRGB(255, 255, 255)
    o.d.Visible = false
    
    o.hbb.Thickness = 1
    o.hbb.Color = Color3.fromRGB(0, 0, 0)
    o.hbb.Filled = true
    o.hbb.Visible = false
    
    o.hb.Thickness = 1
    o.hb.Filled = true
    o.hb.Visible = false
    
    o.tr.Thickness = 1
    o.tr.Color = cfg.e.trc
    o.tr.Visible = false
    
    _eo[p] = o
    return o
end

local function _re(p)
    local o = _eo[p]
    if not o then return end
    for _, obj in pairs(o) do
        if obj then obj:Remove() end
    end
    _eo[p] = nil
end

local function _ue()
    for p, o in pairs(_eo) do
        local ch = _gc(p)
        
        if not ch or not _ia(ch) or p == lp or (cfg.a.t and _it(p)) then
            for _, obj in pairs(o) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local hu = _gh(ch)
        local h = ch:FindFirstChild("Head")
        local r = ch:FindFirstChild("HumanoidRootPart")
        
        if not h or not r or not hu then
            for _, obj in pairs(o) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local hp, ho = cam:WorldToViewportPoint(h.Position)
        local rp, ro = cam:WorldToViewportPoint(r.Position)
        
        if not ho or not ro then
            for _, obj in pairs(o) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local dist = (r.Position - cam.CFrame.Position).Magnitude
        if dist > cfg.e.md then
            for _, obj in pairs(o) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local bh = math.abs(hp.Y - rp.Y) * 2.5
        local bw = bh * 0.6
        local bp = Vector2.new(rp.X - bw / 2, rp.Y - bh / 2)
        
        if cfg.e.b then
            o.b.Size = Vector2.new(bw, bh)
            o.b.Position = bp
            o.b.Visible = true
            
            if cfg.e.bf then
                o.bf.Size = Vector2.new(bw, bh)
                o.bf.Position = bp
                o.bf.Visible = true
            else
                o.bf.Visible = false
            end
        else
            o.b.Visible = false
            o.bf.Visible = false
        end
        
        if cfg.e.l then
            o.l.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
            o.l.To = Vector2.new(rp.X, rp.Y)
            o.l.Visible = true
        else
            o.l.Visible = false
        end
        
        if cfg.e.n then
            o.n.Position = Vector2.new(rp.X, bp.Y - 20)
            o.n.Text = p.Name
            o.n.Visible = true
        else
            o.n.Visible = false
        end
        
        if cfg.e.dist then
            o.d.Position = Vector2.new(rp.X, bp.Y + bh + 5)
            o.d.Text = math.floor(dist) .. "m"
            o.d.Visible = true
        else
            o.d.Visible = false
        end
        
        if cfg.e.hb then
            local hpct = hu.Health / hu.MaxHealth
            local bht = bh * hpct
            
            o.hbb.Size = Vector2.new(4, bh)
            o.hbb.Position = Vector2.new(bp.X - 8, bp.Y)
            o.hbb.Visible = true
            
            o.hb.Size = Vector2.new(4, bht)
            o.hb.Position = Vector2.new(bp.X - 8, bp.Y + (bh - bht))
            o.hb.Color = Color3.fromRGB(255 * (1 - hpct), 255 * hpct, 0)
            o.hb.Visible = true
        else
            o.hb.Visible = false
            o.hbb.Visible = false
        end
        
        if cfg.e.tr then
            o.tr.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
            o.tr.To = Vector2.new(rp.X, rp.Y)
            o.tr.Visible = true
        else
            o.tr.Visible = false
        end
    end
end

--// Human-like Snap Assist
local function _sa()
    if not cfg.a.e then return end
    
    if uis:IsMouseButtonPressed(cfg.a.k) then
        if not _at then
            _at = _cp()
            if _at then
                _isReacting = true
                _reactionDelay = tick() + _getReactionDelay()
                _missOffset = _shouldMiss() and _getMissOffset() or Vector2.new(0, 0)
            end
        end
        
        if _at and _isReacting then
            if tick() < _reactionDelay then
                return -- Still "reacting", don't move yet
            end
            _isReacting = false
        end
        
        if _at then
            local ch = _gc(_at)
            if not ch or not _ia(ch) then
                _at = nil
                _isReacting = false
                return
            end
            
            local pp = _pp(_at)
            if not pp then
                _at = nil
                _isReacting = false
                return
            end
            
            local sp = cam:WorldToViewportPoint(pp)
            local mp = uis:GetMouseLocation()
            local tp = Vector2.new(sp.X, sp.Y)
            
            -- Add miss offset
            tp = tp + _missOffset
            
            -- Add shake (human hand tremor)
            _shakeOffset = _getShake()
            tp = tp + _shakeOffset
            
            -- Calculate movement with jitter
            local rawMove = (tp - mp)
            local jitterX = rnd:NextNumber(-cfg.a.jitter, cfg.a.jitter) * rawMove.X
            local jitterY = rnd:NextNumber(-cfg.a.jitter, cfg.a.jitter) * rawMove.Y
            rawMove = rawMove + Vector2.new(jitterX, jitterY)
            
            -- Apply smoothness
            local mv = rawMove * cfg.a.s
            mousemoverel(mv.X, mv.Y)
            
            -- Auto-Trigger with human delay
            if cfg.af.e and cfg.af.a then
                local ct = tick()
                local actualDelay = rnd:NextNumber(cfg.af.delayMin, cfg.af.delayMax)
                if ct - cfg.af.ls >= actualDelay then
                    if not cfg.af.ra or (cfg.af.ra and _at) then
                        local dt = (tp - mp).Magnitude
                        if dt < 25 then
                            mouse1click()
                            cfg.af.ls = ct
                        end
                    end
                end
            end
        end
    else
        _at = nil
        _isReacting = false
        _missOffset = Vector2.new(0, 0)
    end
end

--// Input
uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == cfg.af.k then
        cfg.af.a = not cfg.af.a
        
        local nf = Instance.new("TextLabel")
        nf.Size = UDim2.new(0, 200, 0, 40)
        nf.Position = UDim2.new(0.5, -100, 0.1, 0)
        nf.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        nf.TextColor3 = cfg.af.a and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        nf.Text = "Auto: " .. (cfg.af.a and "ON" or "OFF")
        nf.TextSize = 18
        nf.Font = Enum.Font.GothamBold
        nf.Parent = game.CoreGui
        nf.BorderSizePixel = 0
        
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(0, 8)
        cr.Parent = nf
        
        ts:Create(nf, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0.15, 0)}):Play()
        wait(2)
        ts:Create(nf, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0, -50)}):Play()
        wait(0.6)
        nf:Destroy()
    end
    
    if input.KeyCode == cfg.x.k then
        _tx()
        
        local nf = Instance.new("TextLabel")
        nf.Size = UDim2.new(0, 200, 0, 40)
        nf.Position = UDim2.new(0.5, -100, 0.1, 0)
        nf.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        nf.TextColor3 = cfg.x.a and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        nf.Text = "Vision: " .. (cfg.x.a and "ON" or "OFF")
        nf.TextSize = 18
        nf.Font = Enum.Font.GothamBold
        nf.Parent = game.CoreGui
        nf.BorderSizePixel = 0
        
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(0, 8)
        cr.Parent = nf
        
        ts:Create(nf, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0.15, 0)}):Play()
        wait(2)
        ts:Create(nf, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -100, 0, -50)}):Play()
        wait(0.6)
        nf:Destroy()
    end
end)

--// Main
rs.RenderStepped:Connect(function()
    if _fc then
        _fc.Position = uis:GetMouseLocation()
        _fc.Radius = cfg.a.f
        _fc.Visible = cfg.f.v and cfg.a.e
    end
    
    if cfg.e.en then
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
    
    if cfg.x.a then
        _ux()
    end
    
    _sa()
end)

--// Events
plrs.PlayerAdded:Connect(function(p)
    if p ~= lp and cfg.e.en then
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

print("InputAssist v2.1.0 | Ready")
print("RMB = Snap | F = Auto | X = Vision")
print("Accuracy: 80% | Human-like behavior active")
