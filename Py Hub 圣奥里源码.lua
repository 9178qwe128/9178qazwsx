--[[ PY Hub 完整修复版
     必须在「圣奥里」游戏内用漏洞执行器运行
     不依赖 WindUI：加载失败自动用内置简易 UI ]]

-- ============ 安全工具 ============
local function isFn(v) return type(v) == "function" end
local function call(fn, ...) if not isFn(fn) then return false end return pcall(fn, ...) end

local EXECUTOR = "Unknown"
if isFn(identifyexecutor) then local ok, n = pcall(identifyexecutor); if ok then EXECUTOR = n end end
print("[PY Hub] 执行器: " .. tostring(EXECUTOR))

-- ============ 服务 ============
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    localPlayer = Players.LocalPlayer
end

-- ============ 反作弊绕过 ============
pcall(function()
    local ac = ReplicatedStorage:FindFirstChild("AntiCheat", true)
    if ac and type(ac) == "table" then
        for k, v in pairs(ac) do
            if isFn(v) then
                ac[k] = function(...)
                    local ok, r = pcall(v, ...)
                    if ok then return r end
                    return true
                end
            end
        end
    end
end)

pcall(function()
    local Ratchet = require(ReplicatedStorage:FindFirstChild("Ratchet", true))
    local Sha256 = require(ReplicatedStorage:FindFirstChild("Sha256", true))
    local mt = getmetatable(Ratchet)
    if mt and mt.__index and not mt.__index.__patched then
        mt.__index.catchUp = function(self, t) while self.index < t do self:advance() end return true end
        mt.__index.respond = function(self, a)
            return Sha256("resp|" .. tostring(self.state) .. "|" .. tostring(self.index) .. "|" .. tostring(a))
        end
        mt.__index.__patched = true
    end
end)

if isFn(hookmetamethod) and isFn(newcclosure) then
    local old
    old = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if self == game and (key == "GetService" or key == "getService") then
            return function(_, svc)
                if svc == "InsertService" or svc == "Selection" or svc == "Stats" then return nil end
                return old(self, svc)
            end
        end
        return old(self, key)
    end))
end

if isFn(hookmetamethod) and isFn(newcclosure) and isFn(getnamecallmethod) then
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local p = table.pack(...)
        local m = getnamecallmethod()
        if m == "Kick" and self == localPlayer then return end
        if m == "FireServer" and self.Name == "PlayerEvent" then
            local f = ({...})[1]
            local blk = {char2=1, coreGame=1, vehicleTrack=1, platform=1, messageDeliver=1,
                runOverVictim=1, DEBUG2=1, chatCommand=1, controlsGuide=1}
            if blk[f] then return end
        end
        if m == "InvokeServer" and self.Name == "PlayerFunc" then
            local f = ({...})[1]
            local blk = {getPlayerData=1, getPlayerBanHistory=1, getPlayerInGame=1,
                getPlayerServerEncounters=1, getSecret=1}
            if blk[f] then return true end
        end
        return old(self, table.unpack(p, 1, p.n))
    end))
end

-- 速度限制绕过
local flag11 = false
pcall(function()
    local Alg = require(ReplicatedStorage.Modules.Algorithms)
    local orig = Alg.getSpeedLimitAtPos
    Alg.getSpeedLimitAtPos = function(...) if flag11 then return 9999 end return orig(...) end
end)

-- ============ GUI 容器 ============
local function getHui()
    if isFn(gethui) then local ok, r = pcall(gethui); if ok and r then return r end end
    local ok, r = pcall(function() return game:FindService("CoreGui") end)
    if ok and r then return r end
    return localPlayer:WaitForChild("PlayerGui", 5)
end
local v29 = getHui()

-- ============ Remote ============
local remote = ReplicatedStorage:FindFirstChild("Remote")
if not remote then local ok, r = pcall(function() return ReplicatedStorage:WaitForChild("Remote", 15) end); if ok then remote = r end end
local playerEvent = remote and remote:FindFirstChild("PlayerEvent")
local playerFunc = remote and remote:FindFirstChild("PlayerFunc")
print("[PY Hub] Remote: " .. tostring(remote and "OK" or "缺失"))

-- ============ 颜色工具 ============
local tbl21 = {
    ["红色"]=Color3.fromRGB(255,0,0), ["黄色"]=Color3.fromRGB(255,255,0),
    ["绿色"]=Color3.fromRGB(0,255,0), ["蓝色"]=Color3.fromRGB(0,150,255),
    ["紫色"]=Color3.fromRGB(150,0,255), ["白色"]=Color3.fromRGB(255,255,255),
    ["黑色"]=Color3.fromRGB(0,0,0), ["青色"]=Color3.fromRGB(0,255,255),
    ["橙色"]=Color3.fromRGB(255,165,0), ["粉色"]=Color3.fromRGB(255,105,180),
}
local fn38 = function(n) n = n or 5; return Color3.fromHSV(tick() % n / n, 1, 1) end
local fn39 = function(name)
    if name == "彩虹色" then return fn38(5) end
    return tbl21[name] or Color3.fromRGB(255,0,0)
end

-- ============ 玩家查找 ============
local fn40 = function(target)
    target = target or localPlayer
    local seen, list = {}, {}
    local function add(m)
        if m and typeof(m) == "Instance" and m:IsA("Model") and not seen[m] then
            seen[m] = true; table.insert(list, m)
        end
    end
    pcall(function() add(target.Character) end)
    pcall(function()
        local cf = Workspace:FindFirstChild("Characters")
        if cf then add(cf:FindFirstChild(target.Name)) end
    end)
    for _, c in ipairs(list) do
        local h = c:FindFirstChildOfClass("Humanoid") or c:FindFirstChild("Humanoid", true)
        local hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
            or c:FindFirstChild("UpperTorso") or (h and h.RootPart)
        if not hrp then hrp = c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart") end
        if hrp then return c, h, hrp end
    end
end
local fn62 = function(p) local _, h = fn40(p); return h ~= nil and h.Health > 0 end
local fn63 = function(p) return p and p.Team and p.Team.Name or "Civilian" end

-- ============ 尝试加载 WindUI（失败不退出） ============
local lib
do
    if isFn(hookfunction) and Font and Font.new then
        pcall(function()
            local fnew = Font.new
            hookfunction(fnew, function(f, w, s)
                local ok, r = pcall(fnew, f, w, s)
                if ok then return r end
                return Font.fromEnum(Enum.Font.GothamMedium)
            end)
        end)
    end
    local ok, err = pcall(function()
        local httpGet
        if isFn(game.HttpGet) then httpGet = function(u) return game:HttpGet(u) end
        elseif isFn(request) then httpGet = function(u) return request({Url=u, Method="GET"}).Body end
        elseif isFn(http_request) then httpGet = function(u) return http_request({Url=u, Method="GET"}).Body end
        elseif isFn(HttpGet) then httpGet = HttpGet end
        if not httpGet then error("无 HttpGet") end
        if not isFn(loadstring) then error("无 loadstring") end
        local src = httpGet("https://raw.githubusercontent.com/123fa98/Xi_Pro/refs/heads/main/UI.lua")
        if type(src) ~= "string" or #src < 100 then error("UI.lua 空") end
        lib = loadstring(src)()
    end)
    if not ok or not lib then
        warn("[PY Hub] WindUI 加载失败: " .. tostring(err))
        warn("[PY Hub] 使用内置简易 UI")
        -- 内置极简 UI（仅有开关）
        lib = (function()
            local api = {}
            local gui = Instance.new("ScreenGui")
            gui.Name = "PYHubBuiltin"
            gui.ResetOnSpawn = false
            gui.Parent = v29 or localPlayer:WaitForChild("PlayerGui", 5)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.fromOffset(300, 400)
            frame.Position = UDim2.fromOffset(20, 100)
            frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
            frame.BorderSizePixel = 0
            frame.Active = true
            frame.Draggable = true
            frame.Parent = gui
            local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,8); corner.Parent = frame
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 30)
            title.BackgroundColor3 = Color3.fromRGB(40,40,50)
            title.Text = "PY Hub (内置)"
            title.TextColor3 = Color3.fromRGB(0,255,0)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 14
            title.Parent = frame
            local scroll = Instance.new("ScrollingFrame")
            scroll.Size = UDim2.new(1, 0, 1, -30)
            scroll.Position = UDim2.fromOffset(0, 30)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 4
            scroll.Parent = frame
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 4)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = scroll
            local y = 0
            function api:CreateWindow() return api end
            function api:Toggle(opts)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -8, 0, 26)
                btn.Position = UDim2.fromOffset(4, y); y = y + 30
                btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
                btn.Text = opts.Title .. ": 关"
                btn.TextColor3 = Color3.fromRGB(255,80,80)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.Parent = scroll
                local state = false
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.Text = opts.Title .. ": " .. (state and "开" or "关")
                    btn.TextColor3 = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,80,80)
                    if opts.Callback then pcall(opts.Callback, state) end
                end)
                return btn
            end
            function api:Slider(opts) return api:Toggle({Title=opts.Title, Callback=opts.Callback}) end
            function api:Dropdown(opts) return api:Toggle({Title=opts.Title, Callback=opts.Callback}) end
            function api:Input(opts) return api:Toggle({Title=opts.Title, Callback=opts.Callback}) end
            function api:Button(opts)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -8, 0, 26)
                btn.Position = UDim2.fromOffset(4, y); y = y + 30
                btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
                btn.Text = opts.Title
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.Parent = scroll
                btn.MouseButton1Click:Connect(function() if opts.Callback then pcall(opts.Callback) end end)
                return btn
            end
            function api:Paragraph() end
            function api:Divider() end
            function api:Keybind() end
            function api:Tab() return api end
            function api:Section() return api end
            function api:Tag() return { SetTitle = function() end } end
            function api:SetToggleKey() end
            function api:SetDPIScale() end
            function api:SetNotifySide() end
            function api:ToggleCustomCursor() end
            function api:SetTheme() end
            function api:GetThemes() return { Dark = {} } end
            function api:OnClose() end
            function api:OnDestroy() end
            function api:EditOpenButton() end
            api.UIElements = { Main = frame }
            api.Parent = gui
            return api
        end)()
    end
    if lib then print("[PY Hub] UI 已加载") end
end

-- ============ 配置 ============
local tbl8 = { randomBg = true, borderColor = nil, isBorderRainbow = true, borderEnabled = false }
pcall(function()
    if isFn(readfile) then
        local ok, c = pcall(readfile, "PYHub_Settings.txt")
        if ok and c then
            local ok2, d = pcall(function() return HttpService:JSONDecode(c) end)
            if ok2 and type(d) == "table" then for k,v in pairs(d) do tbl8[k] = v end end
        end
    end
end)
local function saveSettings()
    pcall(function()
        if isFn(writefile) then writefile("PYHub_Settings.txt", HttpService:JSONEncode(tbl8)) end
    end)
end

-- ============ 状态表 ============
local Settings = {
    stamina=false, food=false, combatBlock=false, ghost=false,
    noRagdoll=false, noFallDamage=false, antiPrisonPull=false,
    autoMoney=false, infiniteAmmo=false, rapidFire=false,
    farmer=false, taxi=false, bus=false, autoMission=false,
    autoHack=false, golf=false, autoCuff=false,
}
local tbl10 = { missionInterval=2, priorityHighReward=false, taxiSafe=false, taxiDelayMode="随机时间", taxiOrigin=nil }
local tbl11 = { auraEnabled=false, auraRange=50, auraDamage=5, auraInterval=0.05,
    auraOnlyPolice=false, auraOnlyCivilian=false, auraCombatCheck=false,
    bulletEnabled=false, bulletFov=360, bulletDistance=300, bulletPart="Head",
    bulletShowFov=true, bulletColor="红色",
    bulletCombatCheck=false, bulletOnlyPolice=false, bulletOnlyCivilian=false }
local tbl12 = { enabled=false, prediction=false, teamCheck=false, wallCheck=false,
    showFov=false, showCrosshair=false, showTracer=false, friendCheck=false,
    onlyPolice=false, onlyCivilian=false, combatCheck=false,
    fov=50, smoothness=1, targetMode="准心最近", targetPart="头",
    color="红色", fovThickness=2 }
local tbl13 = { enabled=false, range=150, interval=0.05, bodyPart="Head",
    jobCheck=false, wallCheck=false, aliveCheck=false,
    combatCheck=false, policeLock=false, civilianLock=false, beam=false }
local tbl14 = { ["头部"]="Head", ["躯干"]="Torso", ["左臂"]="LeftArm", ["右臂"]="RightArm", ["左腿"]="LeftLeg", ["右腿"]="RightLeg" }
local tbl15 = { active=false, size=10, transparency=0.7, teamCheck=false,
    color="红色", material="Neon", rainbow=false,
    checkCorpses=false, outline=false, collision=false, glow=false, pulse=false, affectNPC=false }
local tbl16 = { enabled=false, name=true, distance=true, health=true,
    highlight=true, tracer=false, tracerOrigin="屏幕底部", showFugitive=true,
    selectedTeams = { Chef=true, Civilian=true, Delivery=true, Farmer=true, Fire=true,
        Police=true, Medical=true, Prisoner=true, ["Road Service"]=true, Transit=true },
    trackers = {} }
local tbl17 = { Chef="厨师", Civilian="平民", Delivery="配送员", Farmer="农民", Fire="消防员",
    Police="警察", Medical="医护人员", Prisoner="囚犯", ["Road Service"]="道路服务", Transit="交通" }
local tbl28 = { Chef=Color3.fromRGB(255,200,0), Civilian=Color3.fromRGB(100,200,255),
    Delivery=Color3.fromRGB(255,150,50), Farmer=Color3.fromRGB(50,200,50),
    Fire=Color3.fromRGB(255,50,50), Police=Color3.fromRGB(50,100,255),
    Medical=Color3.fromRGB(255,50,255), Prisoner=Color3.fromRGB(255,150,150),
    ["Road Service"]=Color3.fromRGB(255,255,100), Transit=Color3.fromRGB(100,255,255) }
local PoliceSettings = { range=200, delay=0.5, combatCheck=false, teleport=false }
local MovementSettings = { walkEnabled=false, walkSpeed=200,
    jumpEnabled=false, jumpPower=50, jumpMultiplier=1, infiniteJump=false,
    flyEnabled=false, flySpeed=30, flyMode="传送", noclip=false }
local FlyState = { walkConn=nil, jumpConn=nil, flyConn=nil,
    bodyVelocity=nil, bodyGyro=nil, noclipConn=nil, collisionCache={} }

local Character, Core, module
pcall(function()
    local fw = localPlayer:WaitForChild("PlayerScripts", 10):WaitForChild("Framework", 10)
    Character = require(fw:WaitForChild("Character", 10))
    Core = require(fw:WaitForChild("Core", 10))
    local inv = fw.Character:FindFirstChild("Inventory")
    if inv then module = require(inv) end
end)

-- ============ 功能实现 ============

-- 无限体力/饥饿/子弹/快速射击
local function rapidFire()
    if not Settings.rapidFire or not isFn(getgc) then return end
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" then
            if rawget(v, "SHOOT_MODE") ~= nil then rawset(v, "SHOOT_MODE", 2) end
            if rawget(v, "RPM") ~= nil then rawset(v, "RPM", math.huge) end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Core then
        if Settings.stamina then pcall(function() Core.stamina = 100 end) end
        if Settings.food then pcall(function() Core.food = 100 end) end
        if Settings.rapidFire then pcall(rapidFire) end
    end
    if Settings.infiniteAmmo then
        local c = Workspace:FindFirstChild("Characters") and Workspace.Characters:FindFirstChild(localPlayer.Name)
        if c then
            for _, ch in ipairs(c:GetChildren()) do
                local cfg = ch:FindFirstChild("Config")
                if cfg then
                    local a = cfg:FindFirstChild("Ammo"); if a then a.Value = math.huge end
                    local t = cfg:FindFirstChild("TotalAmmo"); if t then t.Value = math.huge end
                end
            end
        end
    end
end)

-- 战斗拦截
local v30
local function setCombatBlock(on)
    Settings.combatBlock = on
    if on and not v30 and isFn(hookmetamethod) and isFn(newcclosure) then
        v30 = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local p = table.pack(...); local a = {...}
            if Settings.combatBlock and getnamecallmethod() == "FireServer" and a[1] == "combatMode" then return nil end
            return v30(self, table.unpack(p, 1, p.n))
        end))
    end
end

-- 隐身
local connGhost
local function setGhost(on)
    Settings.ghost = on
    if not localPlayer.Character then return end
    if on then
        pcall(function()
            local s = ReplicatedStorage:FindFirstChild("Stuff")
            local l = s and s:FindFirstChild("Locations")
            l = l and l:GetChildren()[1] or nil
            if playerFunc then playerFunc:InvokeServer("hideCharacterLocation", l) end
        end)
        if module and module.canEquipSlot then pcall(function() module.canEquipSlot(true) end) end
        if Character and Character.lockHumanoidState then pcall(function() Character.lockHumanoidState("ghostMode", nil) end) end
        pcall(function()
            GuiService.TouchControlsEnabled = true
            ContextActionService:UnbindAction("LoadingGuiNoResetOnDeath")
            ContextActionService:UnbindAction("DisableCameraMovementNoResetOnDeath")
        end)
        if connGhost then connGhost:Disconnect() end
        connGhost = RunService.RenderStepped:Connect(function() end)
    else
        if connGhost then connGhost:Disconnect(); connGhost = nil end
        pcall(function() if playerFunc then playerFunc:InvokeServer("hideCharacterLocation", false) end end)
    end
end

-- 防布娃娃
pcall(function()
    local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)
    local act, actS = Ragdoll.activate, Ragdoll.activateServer
    Ragdoll.activate = function(a, b, c, ...)
        if Settings.noRagdoll and b then return end
        local p = table.pack(...); p.n = 4 + p.n - 1; table.move(p, 1, p.n, 4, p)
        p[1]=a; p[2]=b; p[3]=c
        return act(table.unpack(p, 1, p.n))
    end
    if actS then
        Ragdoll.activateServer = function(a, b, c, ...)
            if Settings.noRagdoll and b then return end
            local p = table.pack(...); p.n = 4 + p.n - 1; table.move(p, 1, p.n, 4, p)
            p[1]=a; p[2]=b; p[3]=c
            return actS(table.unpack(p, 1, p.n))
        end
    end
end)

-- 防摔伤
pcall(function()
    if not isFn(getrawmetatable) or not isFn(setreadonly) or not isFn(newcclosure) then return end
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local p = table.pack(...); local a = {...}
        if Settings.noFallDamage and getnamecallmethod() == "FireServer"
            and tostring(self) == "PlayerEvent" and a[1] == "takeDamage" then return nil end
        return old(self, table.unpack(p, 1, p.n))
    end)
    setreadonly(mt, true)
end)

-- 防越狱拉回
local charPivotTo, notifyOrig
local function setAntiPrisonPull(on)
    Settings.antiPrisonPull = on
    pcall(function()
        local Alg = require(ReplicatedStorage.Modules.Algorithms)
        if on and not charPivotTo then
            charPivotTo = Alg.charPivotTo
            Alg.charPivotTo = function() return nil end
        elseif not on and charPivotTo then
            Alg.charPivotTo = charPivotTo; charPivotTo = nil
        end
    end)
    pcall(function()
        if not Core then return end
        if on and not notifyOrig then
            notifyOrig = Core.notify
            Core.notify = function(a)
                if a and a.message and string.find(a.message, "You can't leave prison yet") then return nil end
                return notifyOrig(a)
            end
        elseif not on and notifyOrig then
            Core.notify = notifyOrig; notifyOrig = nil
        end
    end)
end

-- 通用工具
local function getWorldPos(inst)
    if not inst or not inst.Parent then return end
    local p = inst.Parent
    if p:IsA("BasePart") then return p.Position end
    if p:IsA("Attachment") then return p.WorldPosition end
    if p:IsA("Model") then
        local pp = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")
        if pp then return pp.Position end
    end
end
local function firePrompt(prompt)
    if not prompt then return end
    pcall(function()
        if isFn(fireproximityprompt) then fireproximityprompt(prompt, 0)
        else prompt.HoldDuration = 0; prompt:InputHoldBegin(); task.wait(0.1); prompt:InputHoldEnd() end
    end)
end
local function teleportTo(pos)
    local char, _, hrp = fn40(localPlayer)
    if not char or not hrp or not pos then return end
    local cf = CFrame.new(pos + Vector3.new(0, 3, 0))
    char:PivotTo(cf)
    pcall(function()
        if playerEvent then
            local n = ((char:GetAttribute("CharPivotToId") or 0) + 1) % 100
            char:SetAttribute("CharPivotToId", n)
            playerEvent:FireServer("charPivotTo", cf, char, n)
        end
    end)
end

-- 自动捡钱
task.spawn(function()
    while true do
        if Settings.autoMoney then
            local _, _, hrp = fn40(localPlayer)
            if hrp then
                local bd, bp
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") then
                        local n, a, o = d.Name, string.lower(tostring(d.ActionText or "")), string.lower(tostring(d.ObjectText or ""))
                        local m = n=="CashDrop" or n=="GetItem" or n=="Money"
                            or a:find("pick",1,true) or a:find("cash",1,true) or a:find("collect",1,true) or a:find("grab",1,true)
                            or o:find("cash",1,true) or o:find("money",1,true)
                        if m then
                            local pos = getWorldPos(d)
                            if pos then
                                local dist = (hrp.Position - pos).Magnitude
                                if not bd or dist < bd then bd = dist; bp = d end
                            end
                        end
                    end
                end
                if bp and bd and bd < 120 then
                    if bd > 8 then teleportTo(getWorldPos(bp)); task.wait(0.3) end
                    firePrompt(bp)
                end
            end
        end
        task.wait(0.3)
    end
end)

-- 自动任务
local function getTeamJobs()
    if not isFn(getgc) then return end
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "teamJobs") then return v.teamJobs end
    end
end
local function hasMission()
    if localPlayer:GetAttribute("Mission") then return true end
    local j = getTeamJobs()
    if j then for _, v in pairs(j) do if v.joined then return true end end end
    return false
end
local function pickMission()
    local j = getTeamJobs(); if not j then return end
    local best, bid = -math.huge, nil
    for id, job in pairs(j) do
        if not job.joined then
            if not tbl10.priorityHighReward then return id end
            local s = (job.profitability or 1) * 1000000 + (job.reward or 0)
            if best < s then best = s; bid = id end
        end
    end
    return bid
end
task.spawn(function()
    while true do
        if Settings.autoMission and playerFunc and not hasMission() then
            local id = pickMission()
            if id then pcall(function() playerFunc:InvokeServer("talkToMission", tostring(id).."join") end) end
        end
        task.wait(tbl10.missionInterval)
    end
end)

-- 农民刷钱
task.spawn(function()
    while true do
        if Settings.farmer then
            local char = localPlayer.Character
            if char and char:FindFirstChildOfClass("Tool") then task.wait(0.4) end
            local _, _, hrp = fn40(localPlayer)
            if hrp then
                local bd, bp
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.ActionText == "Pick Up" then
                        local pos = getWorldPos(d)
                        if pos then
                            local dist = (hrp.Position - pos).Magnitude
                            if not bd or dist < bd then bd = dist; bp = d end
                        end
                    end
                end
                if bp then
                    local pos = getWorldPos(bp)
                    if pos then
                        local dist = (hrp.Position - pos).Magnitude
                        if dist > 8 then teleportTo(pos); task.wait(0.3) else firePrompt(bp) end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- 出租车
task.spawn(function()
    local last = nil
    while true do
        if Settings.taxi then
            local g = Workspace:FindFirstChild("Gameplay")
            g = g and g:FindFirstChild("Entities")
            g = g and g:FindFirstChild("ClientContent")
            if g and g:IsA("Model") then
                local pp = g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
                local _, _, hrp = fn40(localPlayer)
                if pp and hrp then
                    local pos = pp.Position
                    if last == nil or (pos - last).Magnitude > 5 then
                        if tbl10.taxiSafe and tbl10.taxiOrigin then
                            hrp.CFrame = CFrame.new(tbl10.taxiOrigin)
                            local d = (tbl10.taxiOrigin - pos).Magnitude
                            local t
                            if tbl10.taxiDelayMode == "距离测算" then
                                t = math.clamp(15 + (math.clamp(d,2000,6000)-2000)/4000*30 + math.random()*2-1, 15, 45)
                            else
                                t = d > 2000 and math.random(15,45) or 15
                            end
                            task.wait(t)
                        end
                        hrp.CFrame = CFrame.new(pos)
                        last = pos
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 公交车
local function getBusArea()
    local g = Workspace:FindFirstChild("Gameplay")
    g = g and g:FindFirstChild("Entities")
    g = g and g:FindFirstChild("ClientContent")
    g = g and g:GetChildren()[1]
    return g and g:FindFirstChild("Area")
end
task.spawn(function()
    while true do
        if Settings.bus then
            local area = getBusArea()
            local _, hum, hrp = fn40(localPlayer)
            if area and hum and hrp then
                local seat = hum.SeatPart
                if seat then
                    seat.CFrame = area.CFrame * CFrame.new(17.5,3,6.5) * CFrame.Angles(0, 4.7123889803846897, 0) * hrp.CFrame:ToObjectSpace(seat.CFrame)
                    seat.AssemblyLinearVelocity = Vector3.zero
                    seat.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.1); hum.Sit = false
                else
                    hrp.CFrame = area.CFrame * CFrame.new(17.5,3,6.5) * CFrame.Angles(0, 4.7123889803846897, 0)
                end
                task.wait(5)
            end
        end
        task.wait(1)
    end
end)

-- 自动黑客
local tbl24 = {}
local function setAutoHack(on)
    Settings.autoHack = on
    pcall(function()
        local fw = localPlayer.PlayerScripts:FindFirstChild("Framework")
        fw = fw and require(fw:FindFirstChild("Character"))
        local GR = require(ReplicatedStorage.Modules.GameRules)
        if GR then GR.disableHacking = on; GR.disableMinigames = on end
        if fw then
            if not tbl24.hm then tbl24.hm = fw.hackingMinigame end
            if not tbl24.sm then tbl24.sm = fw.startMinigame end
            if on then
                fw.hackingMinigame = function() return true end
                fw.startMinigame = function() return true end
            else
                if tbl24.hm then fw.hackingMinigame = tbl24.hm end
                if tbl24.sm then fw.startMinigame = tbl24.sm end
            end
        end
    end)
end

-- 高尔夫
task.spawn(function()
    local function fp(path)
        local c = Workspace
        for _, n in ipairs(path) do c = c and c:FindFirstChild(n); if not c then return end end
        return c
    end
    while true do
        if Settings.golf and playerFunc then
            pcall(function()
                playerFunc:InvokeServer("miniGolf", "createLobby"); task.wait(0.1)
                playerFunc:InvokeServer("miniGolf", "setLobbyBid", { bid = 500 }); task.wait(0.1)
                playerFunc:InvokeServer("miniGolf", "setLobbyReady"); task.wait(4)
                playerFunc:InvokeServer("miniGolf", "shot"); task.wait(0.5)
                local ball = fp({ "Gameplay","Entities","Content", localPlayer.Name })
                local flag = fp({ "Gameplay","Entities","Content","_Flag","FlagPole","Part" })
                if ball and flag and ball:IsA("BasePart") then ball.Position = flag.Position end
            end)
        end
        task.wait(Settings.golf and 5 or 1)
    end
end)

-- ============ 战斗 ============
local tbl26 = { ["头"]={"Head"}, ["胸"]={"UpperTorso","Torso"}, ["左手"]={"LeftHand","Left Arm"},
    ["右手"]={"RightHand","Right Arm"}, ["左腿"]={"LeftFoot","Left Leg"}, ["右腿"]={"RightFoot","Right Leg"} }
local function getTargetPart(char)
    local list = tbl26[tbl12.targetPart] or { "Head" }
    for _, n in ipairs(list) do local p = char:FindFirstChild(n); if p then return p end end
    return char:FindFirstChild("HumanoidRootPart")
end
local function teamFilter(p, op, oc)
    if not p or p == localPlayer then return false end
    if op then return p.Team and p.Team.Name == "Police" end
    if oc then return p.Team and p.Team.Name == "Civilian" end
    return true
end
local function combatFilter(p, c)
    if not c then return true end
    return p:GetAttribute("CombatMode") == true or p:GetAttribute("Pursuit") == true
end

-- 杀戮光环
local n10 = 0
RunService.Heartbeat:Connect(function()
    if not tbl11.auraEnabled or not playerEvent then return end
    local now = tick()
    if now - n10 < tbl11.auraInterval then return end
    local _, _, hrp = fn40(localPlayer); if not hrp then return end
    local bp, bd
    for _, p in ipairs(Players:GetPlayers()) do
        if teamFilter(p, tbl11.auraOnlyPolice, tbl11.auraOnlyCivilian) and fn62(p) and combatFilter(p, tbl11.auraCombatCheck) then
            local ch = p.Character
            local t = ch and getTargetPart(ch)
            if t then
                local d = (t.Position - hrp.Position).Magnitude
                if d <= tbl11.auraRange and (not bd or d < bd) then bp = p; bd = d end
            end
        end
    end
    if bp then
        local ch = bp.Character
        local t = ch and getTargetPart(ch)
        if t then
            local pos = hrp.Position
            pcall(function()
                playerEvent:FireServer("damage", {
                    bodyParts = {{ "Head", 1 }},
                    shotCode = { pos, (t.Position - pos).Unit },
                    pos = t.Position, target = bp,
                    damageFactor = tbl11.auraDamage, bulletProofTool = false,
                })
            end)
            n10 = now
        end
    end
end)

-- 子弹追踪
local circle = Drawing.new("Circle"); circle.Filled=false; circle.NumSides=64; circle.Visible=false
local function findBulletTarget()
    local cam = Workspace.CurrentCamera; if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local bf, bp = tbl11.bulletFov, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if teamFilter(p, tbl11.bulletOnlyPolice, tbl11.bulletOnlyCivilian) and fn62(p) and combatFilter(p, tbl11.bulletCombatCheck) then
            local ch = p.Character
            if ch then ch = ch:FindFirstChild(tbl11.bulletPart) or ch:FindFirstChild("HumanoidRootPart") end
            if ch and (ch.Position - cam.CFrame.Position).Magnitude <= tbl11.bulletDistance then
                local sp, vis = cam:WorldToScreenPoint(ch.Position)
                if vis and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bf then bp = ch.Position; bf = d end
                end
            end
        end
    end
    return bp
end
pcall(function()
    if not isFn(hookfunction) then return end
    local rc = Workspace.Raycast
    hookfunction(Workspace.Raycast, function(self, o, d, p)
        if tbl11.bulletEnabled and o and d then
            local _, _, hrp = fn40(localPlayer)
            if hrp and (o - hrp.Position).Magnitude < 15 then
                local t = findBulletTarget()
                if t then d = (t - o).Unit * d.Magnitude end
            end
        end
        return rc(self, o, d, p)
    end)
end)
RunService.RenderStepped:Connect(function()
    local cam = Workspace.CurrentCamera; if not cam then return end
    circle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    circle.Radius = tbl11.bulletFov; circle.Thickness = 2
    circle.Color = fn38(5)
    circle.Visible = tbl11.bulletEnabled and tbl11.bulletShowFov
end)

-- 自瞄
local circle2 = Drawing.new("Circle"); circle2.Filled=false; circle2.NumSides=64
local line = Drawing.new("Line")
local cross = { Top=Drawing.new("Line"), Bottom=Drawing.new("Line"), Left=Drawing.new("Line"),
    Right=Drawing.new("Line"), Center=Drawing.new("Line") }
for _, v in pairs(cross) do v.Thickness = 2; v.Visible = false end

local function wallCheck(part)
    if not tbl12.wallCheck then return true end
    local cam = Workspace.CurrentCamera
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = { localPlayer.Character, cam }
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    local h = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rp)
    return not h or h.Instance:IsDescendantOf(part.Parent)
end
local function findAimTarget()
    local cam = Workspace.CurrentCamera; if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local bs, bt
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and fn62(p) and teamFilter(p, tbl12.onlyPolice, tbl12.onlyCivilian) and combatFilter(p, tbl12.combatCheck) then
            if not (tbl12.teamCheck and localPlayer.Team and p.Team == localPlayer.Team) then
                local skip = false
                if tbl12.friendCheck then
                    local ok, r = pcall(function() return localPlayer:IsFriendsWith(p.UserId) end)
                    if ok and r then skip = true end
                end
                if not skip then
                    local ch = p.Character
                    if ch then
                        local part = getTargetPart(ch)
                        local hum = ch:FindFirstChildOfClass("Humanoid")
                        local hrp = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
                        if part and hum and hrp and hum.Health > 0 and wallCheck(part) then
                            local sp, vis = cam:WorldToViewportPoint(part.Position)
                            if vis then
                                local sc = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if sc <= tbl12.fov then
                                    if tbl12.targetMode == "距离最近" then
                                        local _, _, my = fn40(localPlayer)
                                        sc = my and (my.Position - hrp.Position).Magnitude or math.huge
                                    elseif tbl12.targetMode == "血量最低" then sc = hum.Health end
                                    if not bs or sc < bs then bt = { player=p, part=part, screen=sp }; bs = sc end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bt
end
RunService.RenderStepped:Connect(function(dt)
    local cam = Workspace.CurrentCamera; if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local col = fn39(tbl12.color)
    circle2.Position = center; circle2.Radius = tbl12.fov
    circle2.Thickness = tbl12.fovThickness; circle2.Color = col
    circle2.Visible = tbl12.enabled and tbl12.showFov
    cross.Top.From = Vector2.new(center.X, center.Y-5); cross.Top.To = Vector2.new(center.X, center.Y-20)
    cross.Bottom.From = Vector2.new(center.X, center.Y+5); cross.Bottom.To = Vector2.new(center.X, center.Y+20)
    cross.Left.From = Vector2.new(center.X-5, center.Y); cross.Left.To = Vector2.new(center.X-20, center.Y)
    cross.Right.From = Vector2.new(center.X+5, center.Y); cross.Right.To = Vector2.new(center.X+20, center.Y)
    cross.Center.From = Vector2.new(center.X-2, center.Y); cross.Center.To = Vector2.new(center.X+2, center.Y)
    for _, v in pairs(cross) do v.Color = col; v.Visible = tbl12.showCrosshair end
    line.Visible = false
    if tbl12.enabled then
        local t = findAimTarget()
        if t then
            if tbl12.showTracer then
                line.From = center; line.To = Vector2.new(t.screen.X, t.screen.Y)
                line.Color = col; line.Thickness = 2; line.Transparency = 0.5; line.Visible = true
            end
            local pos = t.part.Position
            if tbl12.prediction then pos = pos + t.part.AssemblyLinearVelocity * dt * 1.5 end
            local cf = CFrame.new(cam.CFrame.Position, pos)
            cam.CFrame = tbl12.smoothness >= 1 and cf or cam.CFrame:Lerp(cf, tbl12.smoothness)
        end
    end
end)

-- Ragebot
task.spawn(function()
    while true do
        if tbl13.enabled and playerEvent then
            local _, _, hrp = fn40(localPlayer)
            if hrp then
                local pos = hrp.Position
                local myJob = fn63(localPlayer)
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer and teamFilter(p, tbl13.policeLock, tbl13.civilianLock) and combatFilter(p, tbl13.combatCheck) then
                        local ch, hum = fn40(p)
                        local part = ch and (ch:FindFirstChild(tbl13.bodyPart) or getTargetPart(ch))
                        if ch and hum and part and hum.Health > 0 then
                            if not (tbl13.jobCheck and fn63(p) == myJob) then
                                if (part.Position - pos).Magnitude <= tbl13.range then
                                    local blocked = false
                                    if tbl13.wallCheck then
                                        local rp = RaycastParams.new()
                                        rp.FilterDescendantsInstances = { localPlayer.Character, Workspace.CurrentCamera }
                                        rp.FilterType = Enum.RaycastFilterType.Exclude
                                        local h = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position, part.Position - Workspace.CurrentCamera.CFrame.Position, rp)
                                        if h and not h.Instance:IsDescendantOf(ch) then blocked = true end
                                    end
                                    if not blocked then
                                        pcall(function()
                                            playerEvent:FireServer("damage", {
                                                bodyParts = {{ tbl13.bodyPart, 1 }},
                                                shotCode = { pos, (part.Position - pos).Unit },
                                                pos = part.Position, target = p,
                                                damageFactor = 1.5, bulletProofTool = false,
                                            })
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(tbl13.interval)
    end
end)

-- 范围
local tbl27 = {}
local function applyHitbox(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if not tbl27[hrp] then
        tbl27[hrp] = { Size=hrp.Size, Transparency=hrp.Transparency, Material=hrp.Material,
            CanCollide=hrp.CanCollide, Color=hrp.Color }
    end
    if not tbl15.active then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if tbl15.checkCorpses and hum and hum.Health <= 0 then return end
    local size = tbl15.size
    if tbl15.pulse then size = size * (math.sin(tick()*2)*0.2 + 1) end
    hrp.Size = Vector3.new(size, size, size)
    hrp.Transparency = tbl15.transparency
    hrp.Material = Enum.Material[tbl15.material] or Enum.Material.Neon
    hrp.CanCollide = tbl15.collision
    hrp.Color = tbl15.rainbow and fn38(5) or fn39(tbl15.color)
    if tbl15.outline then
        local h = hrp:FindFirstChild("PY_HitboxHighlight") or Instance.new("Highlight")
        h.Name="PY_HitboxHighlight"; h.FillTransparency=1
        h.OutlineColor=hrp.Color; h.OutlineTransparency=tbl15.transparency
        h.Parent = hrp
    else
        local h = hrp:FindFirstChild("PY_HitboxHighlight"); if h then h:Destroy() end
    end
    if tbl15.glow then
        local l = hrp:FindFirstChild("PY_HitboxLight") or Instance.new("PointLight")
        l.Name="PY_HitboxLight"; l.Brightness=5; l.Range=15; l.Color=hrp.Color; l.Parent=hrp
    else
        local l = hrp:FindFirstChild("PY_HitboxLight"); if l then l:Destroy() end
    end
end
RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and fn40(p) then
            if tbl15.teamCheck and localPlayer.Team and p.Team == localPlayer.Team then continue end
            applyHitbox(fn40(p))
        end
    end
    if tbl15.affectNPC then
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(d) then
                applyHitbox(d)
            end
        end
    end
end)

-- ESP
local function isFugitive(p)
    local isCiv = p.Team and p.Team.Name == "Civilian"
    if isCiv then return p:GetAttribute("CombatMode") or p:GetAttribute("Pursuit") end
    return isCiv
end
local function shouldTrack(p)
    if not tbl16.enabled or p == localPlayer then return false end
    if not fn40(p) then return false end
    if tbl16.showFugitive and isFugitive(p) then return true end
    local sc, tc = 0, 0
    for _, v in pairs(tbl16.selectedTeams) do tc = tc + 1; if v then sc = sc + 1 end end
    if sc == 0 or sc >= tc then return true end
    local n = p.Team and p.Team.Name
    if not n then return true end
    if tbl16.selectedTeams[n] == true then return true end
    for k, v in pairs(tbl17) do if (v == n or k == n) and tbl16.selectedTeams[k] then return true end end
    return false
end
local function removeTracker(p)
    local t = tbl16.trackers[p]; if not t then return end
    for _, o in pairs(t) do
        pcall(function()
            if typeof(o) == "RBXScriptConnection" then o:Disconnect()
            elseif typeof(o) == "Instance" then o:Destroy()
            elseif type(o) == "userdata" and o.Remove then o:Remove() end
        end)
    end
    tbl16.trackers[p] = nil
end
local espHolder
local function getEspHolder()
    local parent = v29 or getHui() or localPlayer:FindFirstChild("PlayerGui")
    if not parent then return end
    if espHolder and espHolder.Parent then return espHolder end
    local ok, gui = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name="PYHubESP"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
        sg.DisplayOrder=999; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        sg.Parent=parent; return sg
    end)
    if ok then espHolder = gui; return gui end
end
local function addTracker(p)
    if tbl16.trackers[p] or not shouldTrack(p) then return end
    local ch, _, hrp = fn40(p); if not ch or not hrp then return end
    local holder = getEspHolder(); if not holder then return end
    local bill = Instance.new("BillboardGui")
    bill.Name = "PlayerESP_"..p.Name; bill.AlwaysOnTop=true
    bill.Size = UDim2.new(8,0,3,0); bill.StudsOffset = Vector3.new(0,3.5,0)
    bill.MaxDistance = 10000; bill.Adornee = hrp; bill.Parent = holder
    local frame = Instance.new("Frame"); frame.BackgroundTransparency=1
    frame.Size = UDim2.fromScale(1,1); frame.Parent = bill
    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1,0,0.55,0)
    nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBold; nl.TextSize=16
    nl.TextStrokeTransparency=0; nl.Text=p.Name; nl.Parent=frame
    local il = Instance.new("TextLabel"); il.Size = UDim2.new(1,0,0.45,0)
    il.Position = UDim2.new(0,0,0.55,0); il.BackgroundTransparency=1
    il.Font=Enum.Font.Gotham; il.TextSize=14; il.TextStrokeTransparency=0; il.Parent=frame
    local hl = Instance.new("Highlight"); hl.Name="PlayerESP_Highlight"
    hl.Adornee=ch; hl.FillTransparency=0.65; hl.OutlineTransparency=0
    pcall(function() hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
    hl.Parent = ch
    local tline
    pcall(function()
        if Drawing and Drawing.new then
            tline = Drawing.new("Line"); tline.Thickness=1; tline.Transparency=0.5; tline.Visible=false
        end
    end)
    tbl16.trackers[p] = {
        bill=bill, highlight=hl, tracer=tline,
        update = RunService.Heartbeat:Connect(function()
            local cc, chum, chrp = fn40(p)
            if not shouldTrack(p) or not cc or not chrp then
                if tline then tline.Visible = false end
                bill.Enabled = false; return
            end
            hrp = chrp
            bill.Adornee = hrp; bill.Enabled = true
            if hl.Parent ~= cc then hl.Parent = cc end
            hl.Adornee = cc
            local fug = isFugitive(p)
            local tn = p.Team and p.Team.Name
            local col = fug and Color3.fromRGB(255,0,0) or tbl28[tn] or Color3.fromRGB(0,255,0)
            nl.Text = "["..(fug and "逃犯" or tbl17[tn] or tn or "未知").."] "..p.Name
            nl.TextColor3 = col; nl.Visible = tbl16.name
            hl.FillColor = col; hl.OutlineColor = col; hl.Enabled = tbl16.highlight
            local _, _, my = fn40(localPlayer)
            local parts = {}
            if tbl16.distance and my then
                table.insert(parts, string.format("%.1f", (my.Position - hrp.Position).Magnitude))
            end
            if tbl16.health and chum then table.insert(parts, tostring(math.floor(chum.Health))) end
            il.Text = #parts > 0 and "["..table.concat(parts,"/").."]" or ""
            il.TextColor3 = col; il.Visible = tbl16.distance or tbl16.health
            local cam = Workspace.CurrentCamera
            if tline then
                if tbl16.tracer and cam then
                    local sp, vis = cam:WorldToViewportPoint(hrp.Position)
                    if vis then
                        local vp = cam.ViewportSize
                        if tbl16.tracerOrigin == "屏幕中心" then tline.From = Vector2.new(vp.X/2, vp.Y/2)
                        elseif tbl16.tracerOrigin == "屏幕顶部" then tline.From = Vector2.new(vp.X/2, 0)
                        else tline.From = Vector2.new(vp.X/2, vp.Y) end
                        tline.To = Vector2.new(sp.X, sp.Y); tline.Color = col; tline.Visible = true
                    else tline.Visible = false end
                else tline.Visible = false end
            end
        end),
    }
end
local function scanEsp()
    for k in pairs(tbl16.trackers) do if not shouldTrack(k) then removeTracker(k) end end
    if tbl16.enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and shouldTrack(p) and not tbl16.trackers[p] then
                pcall(addTracker, p)
            end
        end
    end
end
local function hookEspPlayer(p)
    if p == localPlayer then return end
    p.CharacterAdded:Connect(function()
        task.wait(0.25)
        if tbl16.enabled then removeTracker(p); pcall(addTracker, p) end
    end)
end
for _, p in ipairs(Players:GetPlayers()) do hookEspPlayer(p) end
Players.PlayerAdded:Connect(hookEspPlayer)
Players.PlayerRemoving:Connect(removeTracker)
local lastScan = 0
RunService.Heartbeat:Connect(function()
    if not tbl16.enabled then return end
    if tick() - lastScan < 0.2 then return end
    lastScan = tick()
    scanEsp()
end)

-- 自动铐
local cuffThread
local function startAutoCuff()
    if cuffThread then return end
    cuffThread = task.spawn(function()
        while Settings.autoCuff do
            local _, _, hrp = fn40(localPlayer)
            if hrp and playerFunc then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer and fn62(p) and combatFilter(p, PoliceSettings.combatCheck) then
                        local _, _, th = fn40(p)
                        if th and (th.Position - hrp.Position).Magnitude <= PoliceSettings.range then
                            pcall(function() playerFunc:InvokeServer("handcuff", p, false) end)
                        end
                    end
                end
                if PoliceSettings.teleport then
                    local bd, bp
                    for _, p in ipairs(Players:GetPlayers()) do
                        local t = p ~= localPlayer and p.Team and p.Team.Name == "Civilian"
                        if t then t = (p:GetAttribute("WantedLevel") or 0) > 0 end
                        if t then
                            local _, _, th = fn40(p)
                            if th then
                                local d = (th.Position - hrp.Position).Magnitude
                                if d <= PoliceSettings.range and (not bd or d < bd) then bd=d; bp=p end
                            end
                        end
                    end
                    if bp then
                        local _, _, th = fn40(bp)
                        if th then hrp.CFrame = CFrame.new(th.Position - th.CFrame.LookVector * 3) end
                    end
                end
            end
            task.wait(PoliceSettings.delay)
        end
        cuffThread = nil
    end)
end

-- ============ 移动 ============
local controls
pcall(function()
    controls = require(localPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end)
local function stopWalk()
    if FlyState.walkConn then FlyState.walkConn:Disconnect(); FlyState.walkConn = nil end
end
local function startWalk()
    stopWalk()
    if not MovementSettings.walkEnabled then return end
    FlyState.walkConn = RunService.Heartbeat:Connect(function()
        local _, hum = fn40(localPlayer)
        if hum and MovementSettings.walkEnabled then hum.WalkSpeed = MovementSettings.walkSpeed end
    end)
end
local function isGrounded(hum)
    if not hum then return false end
    local s = hum:GetState()
    return s == Enum.HumanoidStateType.Landed or s == Enum.HumanoidStateType.Running or s == Enum.HumanoidStateType.RunningNoPhysics
end
local function stopJump()
    if FlyState.jumpConn then FlyState.jumpConn:Disconnect(); FlyState.jumpConn = nil end
end
local function startJump()
    stopJump()
    if not MovementSettings.jumpEnabled then return end
    FlyState.jumpConn = UserInputService.JumpRequest:Connect(function()
        if not MovementSettings.jumpEnabled then return end
        local _, hum, hrp = fn40(localPlayer)
        if not hum or not hrp or hum.Health <= 0 then return end
        if not MovementSettings.infiniteJump and not isGrounded(hum) then return end
        hrp.CFrame = hrp.CFrame + Vector3.new(0, MovementSettings.jumpPower * MovementSettings.jumpMultiplier * 0.1, 0)
    end)
end
local function stopFly()
    if FlyState.flyConn then FlyState.flyConn:Disconnect(); FlyState.flyConn = nil end
    if FlyState.bodyVelocity then FlyState.bodyVelocity:Destroy(); FlyState.bodyVelocity = nil end
    if FlyState.bodyGyro then FlyState.bodyGyro:Destroy(); FlyState.bodyGyro = nil end
    local _, hum = fn40(localPlayer)
    if hum then hum.PlatformStand = false; hum.AutoRotate = true end
end
local function flyTeleport()
    local _, hum, hrp = fn40(localPlayer); if not hrp or not hum then return end
    MovementSettings.flyEnabled = true; hum.AutoRotate = false
    FlyState.flyConn = RunService.RenderStepped:Connect(function(dt)
        if not MovementSettings.flyEnabled or MovementSettings.flyMode ~= "传送" then return end
        local _, h, r = fn40(localPlayer)
        local cam = Workspace.CurrentCamera
        if not r or not h or not cam then return end
        local mv = controls and controls:GetMoveVector() or Vector3.zero
        local dir = cam.CFrame.LookVector * -mv.Z + cam.CFrame.RightVector * mv.X
        local y = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then y = 1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then y = -1 end
        r.CFrame = r.CFrame + (dir + Vector3.new(0, y, 0)) * MovementSettings.flySpeed * dt
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        h:ChangeState(Enum.HumanoidStateType.Climbing)
    end)
end
local function flyPhysics()
    local _, hum, hrp = fn40(localPlayer); if not hrp or not hum then return end
    MovementSettings.flyEnabled = true
    local bv = Instance.new("BodyVelocity")
    bv.Name="PYPlayerFlyVelocity"; bv.MaxForce=Vector3.new(9e9,9e9,9e9)
    bv.Velocity=Vector3.zero; bv.Parent=hrp; FlyState.bodyVelocity=bv
    local bg = Instance.new("BodyGyro")
    bg.Name="PYPlayerFlyGyro"; bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
    bg.P=90000; bg.Parent=hrp; FlyState.bodyGyro=bg
    hum.PlatformStand=true; hum.AutoRotate=false
    FlyState.flyConn = RunService.RenderStepped:Connect(function()
        if not MovementSettings.flyEnabled or MovementSettings.flyMode ~= "物理" then return end
        local _, _, r = fn40(localPlayer)
        local cam = Workspace.CurrentCamera
        if not r or not cam then return end
        if FlyState.bodyVelocity and FlyState.bodyGyro then
            local mv = controls and controls:GetMoveVector() or Vector3.zero
            local dir = cam.CFrame.LookVector * -mv.Z + cam.CFrame.RightVector * mv.X
            local y = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then y = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then y = -1 end
            FlyState.bodyVelocity.Velocity = (dir + Vector3.new(0, y, 0)) * MovementSettings.flySpeed
            FlyState.bodyGyro.CFrame = cam.CFrame
        end
    end)
end
local function startFly()
    if MovementSettings.flyMode == "物理" then flyPhysics() else flyTeleport() end
end
local function restoreCollision()
    for part, v in pairs(FlyState.collisionCache) do
        if part and part.Parent then pcall(function() part.CanCollide = v end) end
    end
    FlyState.collisionCache = {}
end
local function stopNoclip()
    if FlyState.noclipConn then FlyState.noclipConn:Disconnect(); FlyState.noclipConn = nil end
    restoreCollision()
end
local function startNoclip()
    stopNoclip()
    if not MovementSettings.noclip then return end
    FlyState.noclipConn = RunService.Stepped:Connect(function()
        if not MovementSettings.noclip then return end
        local char = localPlayer.Character; if not char then return end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                if FlyState.collisionCache[d] == nil then FlyState.collisionCache[d] = d.CanCollide end
                d.CanCollide = false
            end
        end
    end)
end
localPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    FlyState.collisionCache = {}
    if MovementSettings.walkEnabled then startWalk() end
    if MovementSettings.jumpEnabled then startJump() end
    if MovementSettings.noclip then startNoclip() end
    if MovementSettings.flyEnabled then
        local mode = MovementSettings.flyMode
        MovementSettings.flyEnabled = false
        task.wait(0.2)
        MovementSettings.flyMode = mode
        startFly()
    end
end)

-- ============ UI ============
local function buildUI()
    local win = lib:CreateWindow({
        Title = "PY Hub/圣奥里<font color='#00FF00'>破解版</font>",
        Icon = "zap", Author = "Xi.Team", Folder = "PYHub",
        Size = UDim2.fromOffset(640, 460),
        Theme = "Dark",
        Background = tbl8.randomBg and "https://raw.githubusercontent.com/PYHub/assets/main/bg.jpg" or "",
        BackgroundImageTransparency = 0.4,
        Transparent = true,
    })

    if win.Tab then
        -- ===== 内置简易UI（WindUI失败时）=====
        win:Tab({Title="主要功能"})
        win:Toggle({Title="无限体力", Callback=function(v) Settings.stamina = v end})
        win:Toggle({Title="无限饥饿", Callback=function(v) Settings.food = v end})
        win:Toggle({Title="战斗拦截", Callback=setCombatBlock})
        win:Toggle({Title="隐身", Callback=setGhost})
        win:Toggle({Title="防布娃娃", Callback=function(v) Settings.noRagdoll = v end})
        win:Toggle({Title="防摔伤", Callback=function(v) Settings.noFallDamage = v end})
        win:Toggle({Title="防越狱拉回", Callback=setAntiPrisonPull})
        win:Toggle({Title="自动捡钱", Callback=function(v) Settings.autoMoney = v end})
        win:Toggle({Title="无限子弹", Callback=function(v) Settings.infiniteAmmo = v end})
        win:Toggle({Title="快速射击", Callback=function(v) Settings.rapidFire = v end})
        win:Tab({Title="刷钱"})
        win:Toggle({Title="自动任务", Callback=function(v) Settings.autoMission = v end})
        win:Toggle({Title="出租车刷钱", Callback=function(v) Settings.taxi = v end})
        win:Toggle({Title="公交车刷钱", Callback=function(v) Settings.bus = v end})
        win:Toggle({Title="农民刷钱", Callback=function(v) Settings.farmer = v end})
        win:Toggle({Title="自动黑客", Callback=setAutoHack})
        win:Toggle({Title="高尔夫刷钱", Callback=function(v) Settings.golf = v end})
        win:Tab({Title="战斗"})
        win:Toggle({Title="杀戮光环", Callback=function(v) tbl11.auraEnabled = v end})
        win:Toggle({Title="自瞄", Callback=function(v) tbl12.enabled = v end})
        win:Toggle({Title="Ragebot", Callback=function(v) tbl13.enabled = v end})
        win:Toggle({Title="范围修改", Callback=function(v) tbl15.active = v end})
        win:Tab({Title="ESP"})
        win:Toggle({Title="玩家透视", Callback=function(v)
            tbl16.enabled = v
            if not v then for k in pairs(tbl16.trackers) do removeTracker(k) end else scanEsp() end
        end})
        win:Tab({Title="警察功能"})
        win:Toggle({Title="自动铐", Callback=function(v) Settings.autoCuff = v; if v then startAutoCuff() end end})
        win:Tab({Title="玩家"})
        win:Toggle({Title="跳跃增强", Callback=function(v) MovementSettings.jumpEnabled = v; if v then startJump() else stopJump() end end})
        win:Toggle({Title="无限跳跃", Callback=function(v) MovementSettings.infiniteJump = v end})
        win:Toggle({Title="飞行", Callback=function(v)
            MovementSettings.flyEnabled = v
            if v then startFly() else stopFly() end
        end})
        win:Toggle({Title="无碰撞", Callback=function(v)
            MovementSettings.noclip = v
            if v then startNoclip() else stopNoclip() end
        end})
        win:Toggle({Title="行走加速", Callback=function(v)
            MovementSettings.walkEnabled = v
            if v then startWalk() else stopWalk() end
        end})
        print("[PY Hub] UI 构建完成（内置）")
        return
    end

    -- ===== WindUI 完整界面 =====
    local tab1 = win:Tab({Title="主要功能", Icon="sliders-h"})
    tab1:Toggle({Title="无限体力", Callback=function(v) Settings.stamina = v end})
    tab1:Toggle({Title="无限饥饿", Callback=function(v) Settings.food = v end})
    tab1:Toggle({Title="战斗拦截", Callback=setCombatBlock})
    tab1:Toggle({Title="隐身", Callback=setGhost})
    tab1:Toggle({Title="防布娃娃", Callback=function(v) Settings.noRagdoll = v end})
    tab1:Toggle({Title="防摔伤", Callback=function(v) Settings.noFallDamage = v end})
    tab1:Toggle({Title="防越狱拉回", Callback=setAntiPrisonPull})
    tab1:Toggle({Title="自动捡钱", Callback=function(v) Settings.autoMoney = v end})
    tab1:Toggle({Title="无限子弹", Callback=function(v) Settings.infiniteAmmo = v end})
    tab1:Toggle({Title="快速射击", Callback=function(v) Settings.rapidFire = v end})

    local tab2 = win:Tab({Title="刷钱", Icon="money-bill-wave"})
    tab2:Toggle({Title="自动任务", Callback=function(v) Settings.autoMission = v end})
    tab2:Toggle({Title="优先高收益", Callback=function(v) tbl10.priorityHighReward = v end})
    tab2:Toggle({Title="出租车刷钱", Callback=function(v) Settings.taxi = v end})
    tab2:Toggle({Title="公交车刷钱", Callback=function(v) Settings.bus = v end})
    tab2:Toggle({Title="农民刷钱", Callback=function(v) Settings.farmer = v end})
    tab2:Toggle({Title="自动黑客", Callback=setAutoHack})
    tab2:Toggle({Title="高尔夫刷钱", Callback=function(v) Settings.golf = v end})

    local tab3 = win:Tab({Title="战斗", Icon="crosshairs"})
    tab3:Toggle({Title="杀戮光环", Callback=function(v) tbl11.auraEnabled = v end})
    tab3:Toggle({Title="只打警察", Callback=function(v) tbl11.auraOnlyPolice = v; if v then tbl11.auraOnlyCivilian=false end end})
    tab3:Toggle({Title="只打平民", Callback=function(v) tbl11.auraOnlyCivilian = v; if v then tbl11.auraOnlyPolice=false end end})
    tab3:Slider({Title="范围", Value={Min=10,Max=500,Default=50}, Callback=function(v) tbl11.auraRange = v end})
    tab3:Slider({Title="伤害", Value={Min=1,Max=100,Default=5}, Callback=function(v) tbl11.auraDamage = v end})

    local tab4 = win:Tab({Title="自瞄", Icon="crosshairs"})
    tab4:Toggle({Title="自瞄", Callback=function(v) tbl12.enabled = v end})
    tab4:Toggle({Title="显示Fov圈", Callback=function(v) tbl12.showFov = v end})
    tab4:Toggle({Title="显示准心", Callback=function(v) tbl12.showCrosshair = v end})
    tab4:Toggle({Title="追踪线", Callback=function(v) tbl12.showTracer = v end})
    tab4:Toggle({Title="队伍检测", Callback=function(v) tbl12.teamCheck = v end})
    tab4:Toggle({Title="墙壁检测", Callback=function(v) tbl12.wallCheck = v end})
    tab4:Toggle({Title="预判", Callback=function(v) tbl12.prediction = v end})
    tab4:Slider({Title="Fov大小", Value={Min=1,Max=500,Default=50}, Callback=function(v) tbl12.fov = v end})
    tab4:Slider({Title="平滑度", Value={Min=1,Max=10,Default=10}, Callback=function(v) tbl12.smoothness = v/10 end})

    local tab5 = win:Tab({Title="Ragebot", Icon="bot"})
    tab5:Toggle({Title="Ragebot", Callback=function(v) tbl13.enabled = v end})
    tab5:Slider({Title="距离", Value={Min=10,Max=500,Default=150}, Callback=function(v) tbl13.range = v end})
    tab5:Slider({Title="间隔", Value={Min=0.01,Max=1,Default=0.05,Step=0.01}, Callback=function(v) tbl13.interval = v end})

    local tab6 = win:Tab({Title="范围", Icon="bullseye"})
    tab6:Toggle({Title="范围修改", Callback=function(v) tbl15.active = v end})
    tab6:Toggle({Title="轮廓", Callback=function(v) tbl15.outline = v end})
    tab6:Toggle({Title="发光", Callback=function(v) tbl15.glow = v end})
    tab6:Slider({Title="大小", Value={Min=1,Max=50,Default=10}, Callback=function(v) tbl15.size = v end})

    local tab7 = win:Tab({Title="ESP", Icon="eye"})
    tab7:Toggle({Title="玩家透视", Callback=function(v)
        tbl16.enabled = v
        if not v then for k in pairs(tbl16.trackers) do removeTracker(k) end else scanEsp() end
    end})
    tab7:Toggle({Title="名字", Callback=function(v) tbl16.name = v end})
    tab7:Toggle({Title="距离", Callback=function(v) tbl16.distance = v end})
    tab7:Toggle({Title="血量", Callback=function(v) tbl16.health = v end})
    tab7:Toggle({Title="高亮", Callback=function(v) tbl16.highlight = v end})
    tab7:Toggle({Title="追踪线", Callback=function(v) tbl16.tracer = v end})

    local tab8 = win:Tab({Title="警察", Icon="handcuffs"})
    tab8:Toggle({Title="自动铐", Callback=function(v) Settings.autoCuff = v; if v then startAutoCuff() end end})
    tab8:Toggle({Title="自动传送", Callback=function(v) PoliceSettings.teleport = v end})
    tab8:Slider({Title="范围", Value={Min=10,Max=500,Default=200}, Callback=function(v) PoliceSettings.range = v end})

    local tab9 = win:Tab({Title="玩家", Icon="user"})
    tab9:Toggle({Title="跳跃增强", Callback=function(v) MovementSettings.jumpEnabled = v; if v then startJump() else stopJump() end end})
    tab9:Toggle({Title="无限跳跃", Callback=function(v) MovementSettings.infiniteJump = v end})
    tab9:Toggle({Title="飞行", Callback=function(v)
        MovementSettings.flyEnabled = v
        if v then startFly() else stopFly() end
    end})
    tab9:Toggle({Title="无碰撞", Callback=function(v)
        MovementSettings.noclip = v
        if v then startNoclip() else stopNoclip() end
    end})
    tab9:Toggle({Title="行走加速", Callback=function(v)
        MovementSettings.walkEnabled = v
        if v then startWalk() else stopWalk() end
    end})
    tab9:Slider({Title="行走速度", Value={Min=16,Max=500,Default=200}, Callback=function(v) MovementSettings.walkSpeed = v end})
    tab9:Slider({Title="飞行速度", Value={Min=10,Max=500,Default=30}, Callback=function(v) MovementSettings.flySpeed = v end})

    if win.OnClose then win:OnClose(function() saveSettings() end) end
    if win.OnDestroy then win:OnDestroy(function() saveSettings() end) end
    print("[PY Hub] UI 构建完成")
end

-- ============ 启动 ============
task.defer(function()
    local ok, err = pcall(buildUI)
    if not ok then
        warn("[PY Hub] UI 启动失败: " .. tostring(err))
    end
end)