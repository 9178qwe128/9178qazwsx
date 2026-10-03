--========================================================
--  WindUI 初始化（源码1）
--========================================================
local WindUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua'))()

WindUI.TransparencyValue = 0.2
WindUI:SetTheme('Dark')

local Window = WindUI:CreateWindow({
    User = { Enabled = true, Callback = function() end },
    Author = "暗风",
    Folder = "NinjaLegends",
    Title = "暗风",
    ScrollBarEnabled = true,
    SideBarWidth = 220,
    Theme = "Dark",
    Icon = "sword",
    Size = UDim2.fromOffset(650, 520),
})

--========================================================
--  源码2的桩函数 / 环境变量
--========================================================
do
    local stubFalse = function() return false end
    local stubNoop  = function() end
    if type(fn12) ~= "function" then fn12 = stubFalse end
    if type(fn13) ~= "function" then fn13 = stubFalse end
    if type(fn17) ~= "function" then fn17 = function() return "{}" end end
    if type(fn14) ~= "function" then fn14 = function(p) return p end end
    if type(fn21) ~= "function" then fn21 = stubNoop end
    if type(fn22) ~= "function" then fn22 = stubNoop end
    if type(fn23) ~= "function" then fn23 = stubNoop end
    if type(fn24) ~= "function" then fn24 = function() return true, { Body = "{}" } end end
    if type(fn25) ~= "function" then fn25 = function() return true end end
    if type(fn19) ~= "function" then fn19 = function(s) return s end end
    if type(handlers) ~= "table" then handlers = {} end
    placeId = placeId or game.PlaceId
    jobId   = jobId   or game.JobId
    c = c or 0
    if type(cloneref) == "function" then
        local raw = cloneref
        cloneref = function(i) if i == nil then return nil end return raw(i) end
    elseif cloneref == nil then
        cloneref = function(i) return i end
    end
end

--========================================================
--  主入口
--========================================================
local PYHubEntry = function(loaderUrl, nodeUrl, scriptId, scriptVersion, _k, extraC, extraD, sigSq, sigRp, debugPrint, progressPrint, reportFunc)
    progressPrint = progressPrint or function(_) return function() end end
    reportFunc   = reportFunc   or function() end
    debugPrint   = debugPrint   or function() end

    local v2 = progressPrint("正在初始化...")
    reportFunc({ p = 40, m = "init" })
    local v3 = progressPrint("正在检查运行环境...")

    local localPlayer = game:GetService("Players").LocalPlayer
    local concat = table.concat
    local sub, byte, char = string.sub, string.byte, string.char
    local lshift, rshift, band, bxor, rrotate, bnot = bit32.lshift, bit32.rshift, bit32.band, bit32.bxor, bit32.rrotate, bit32.bnot

    local cloneFunc = clonefunction or function(...) return ... end
    local v4 = cloneFunc(http and http.request or request or getfenv()["http"])
    local v5 = cloneFunc(debug.traceback)
    local v6 = cloneFunc(debug.info)
    local v7 = cloneFunc(pcall)
    local v8 = cloneFunc(getfenv)
    local v9 = cloneFunc(tostring)
    local v10 = identifyexecutor and identifyexecutor() or "Unknown"
    local v11 = v6(1, "f")
    local script = v8(0).script
    local n2 = #v5():split("\n") - 4
    v2(); v3()
    reportFunc({ s = true })

    --============= 环境引用 =============
    local Players          = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local GuiService       = game:GetService("GuiService")
    local ContextActionService = game:GetService("ContextActionService")
    local HttpService      = game:GetService("HttpService")
    local Workspace        = game:GetService("Workspace")

    local localPlayer2 = Players.LocalPlayer
    if not localPlayer2 then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        localPlayer2 = Players.LocalPlayer
    end
    localPlayer3 = localPlayer2

    local function getHui()
        local h
        pcall(function() if type(gethui) == "function" then h = gethui() end end)
        if h then return h end
        pcall(function() h = game:FindService("CoreGui") end)
        if h then return h end
        pcall(function() h = localPlayer2:WaitForChild("PlayerGui", 5) end)
        if h then return h end
        pcall(function() h = localPlayer2:FindFirstChild("PlayerGui") end)
        return h
    end
    local v29 = getHui()

    local remote = ReplicatedStorage:WaitForChild("Remote", 30)
    local playerEvent = remote and remote:WaitForChild("PlayerEvent", 30)
    local playerFunc  = remote and remote:WaitForChild("PlayerFunc", 30)

    --============= 反作弊 hook =============
    if hookmetamethod and newcclosure and getnamecallmethod then
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local packed = table.pack(...)
            local method = getnamecallmethod()
            if method == "Kick" and self == localPlayer2 then return end
            if method == "FireServer" and self.Name == "PlayerEvent" then
                local a = packed[1]
                if a == "char2" or a == "coreGame" or a == "vehicleTrack" or a == "platform"
                    or a == "messageDeliver" or a == "runOverVictim" or a == "DEBUG2"
                    or a == "chatCommand" or a == "controlsGuide" then return end
            end
            if method == "InvokeServer" and self.Name == "PlayerFunc" then
                local a = packed[1]
                if a == "getPlayerData" or a == "getPlayerBanHistory" or a == "getPlayerInGame"
                    or a == "getPlayerServerEncounters" or a == "getSecret" then
                    return true
                end
            end
            return old(self, table.unpack(packed, 1, packed.n))
        end))
    end

    pcall(function()
        local ac = ReplicatedStorage:FindFirstChild("AntiCheat", true)
        if ac and type(ac) == "table" then
            for k, v in pairs(ac) do
                if type(v) == "function" then
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
        local Sha256  = require(ReplicatedStorage:FindFirstChild("Sha256", true))
        local mt = getmetatable(Ratchet)
        if mt and mt.__index and not mt.__index.__patched then
            mt.__index.catchUp = function(self, target)
                while self.index < target do self:advance() end
                return true
            end
            mt.__index.respond = function(self, v)
                return Sha256("resp|" .. tostring(self.state) .. "|" .. tostring(self.index) .. "|" .. tostring(v))
            end
            mt.__index.__patched = true
        end
    end)

    --============= 工具函数 =============
    local tbl21 = {
        ["红色"] = Color3.fromRGB(255, 0, 0),   ["黄色"] = Color3.fromRGB(255, 255, 0),
        ["绿色"] = Color3.fromRGB(0, 255, 0),   ["蓝色"] = Color3.fromRGB(0, 150, 255),
        ["紫色"] = Color3.fromRGB(150, 0, 255), ["白色"] = Color3.fromRGB(255, 255, 255),
        ["黑色"] = Color3.fromRGB(0, 0, 0),     ["青色"] = Color3.fromRGB(0, 255, 255),
        ["橙色"] = Color3.fromRGB(255, 165, 0), ["粉色"] = Color3.fromRGB(255, 105, 180),
    }
    local function rainbowColor(period)
        period = period or 5
        return Color3.fromHSV(tick() % period / period, 1, 1)
    end
    local function colorByName(name)
        if name == "彩虹色" or name == "彩虹" then return rainbowColor(5) end
        return tbl21[name] or Color3.fromRGB(255, 0, 0)
    end

    local function getChar(player)
        player = player or localPlayer2
        local seen, list = {}, {}
        local function add(m)
            if m and typeof(m) == "Instance" and m:IsA("Model") and not seen[m] then
                seen[m] = true; table.insert(list, m)
            end
        end
        pcall(function() add(player.Character) end)
        pcall(function()
            local f = Workspace:FindFirstChild("Characters")
            if f then add(f:FindFirstChild(player.Name)) end
        end)
        for _, ch in ipairs(list) do
            local hum = ch:FindFirstChildOfClass("Humanoid") or ch:FindFirstChild("Humanoid", true)
            local root = ch:FindFirstChild("HumanoidRootPart")
                or ch:FindFirstChild("Torso")
                or ch:FindFirstChild("UpperTorso")
                or (hum and hum.RootPart)
                or ch.PrimaryPart
                or ch:FindFirstChildWhichIsA("BasePart")
            if root then return ch, hum, root end
        end
    end
    local function isAlive(player)
        local _, hum = getChar(player)
        return hum ~= nil and hum.Health > 0
    end
    local function teamName(player)
        return player and player.Team and player.Team.Name or "Civilian"
    end
    local function passesFilter(player, onlyPolice, onlyCivilian)
        if not player or player == localPlayer2 then return false end
        if onlyPolice then return player.Team and player.Team.Name == "Police" end
        if onlyCivilian then return player.Team and player.Team.Name == "Civilian" end
        return true
    end
    local function inCombat(player, check)
        if not check then return true end
        return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
    end

    -- 小地图光标注入
    local function ensureMinimapCursor(root)
        if not root then return end
        local minimap = root.Name == "Minimap" and root or root:FindFirstChild("Minimap", true)
        if not minimap or not minimap:IsA("Frame") or minimap:FindFirstChild("Cursor") then return end
        local cursor = Instance.new("ImageLabel")
        cursor.Name = "Cursor"
        cursor.BackgroundTransparency = 1
        cursor.ImageTransparency = 1
        cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        cursor.Position = UDim2.fromScale(0.5, 0.5)
        cursor.Size = UDim2.fromOffset(10, 10)
        cursor.ZIndex = minimap.ZIndex + 1
        cursor.Parent = minimap
    end
    task.spawn(function()
        local pg = localPlayer2:FindFirstChild("PlayerGui") or localPlayer2:WaitForChild("PlayerGui", 10)
        ensureMinimapCursor(pg)
        if pg then
            pg.DescendantAdded:Connect(function(d)
                if d.Name == "Minimap" then task.defer(ensureMinimapCursor, d) end
            end)
        end
    end)

    --============= 状态表 =============
    Settings = {
        stamina = false, food = false, combatBlock = false, ghost = false,
        noRagdoll = false, noFallDamage = false, antiPrisonPull = false,
        autoMoney = false, infiniteAmmo = false, rapidFire = false,
        farmer = false, taxi = false, bus = false, autoMission = false,
        autoHack = false, golf = false, autoCuff = false,
    }

    local Character, Core, module
    pcall(function()
        local fw = localPlayer2:WaitForChild("PlayerScripts", 15):WaitForChild("Framework", 15)
        Character = require(fw:WaitForChild("Character", 15))
        Core      = require(fw:WaitForChild("Core", 15))
        local inv = fw.Character:FindFirstChild("Inventory")
        if inv then module = require(inv) end
    end)

    --============= 主循环 =============
    RunService.Heartbeat:Connect(function()
        if Core then
            if Settings.stamina then pcall(function() Core.stamina = 100 end) end
            if Settings.food    then pcall(function() Core.food    = 100 end) end
            if Settings.rapidFire then pcall(function()
                if not getgc then return end
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" then
                        if rawget(v, "SHOOT_MODE") ~= nil then rawset(v, "SHOOT_MODE", 2) end
                        if rawget(v, "RPM") ~= nil then rawset(v, "RPM", math.huge) end
                    end
                end
            end) end
        end
        if Settings.infiniteAmmo then
            local f = Workspace:FindFirstChild("Characters")
            local c = f and f:FindFirstChild(localPlayer2.Name)
            if c then
                for _, ch in ipairs(c:GetChildren()) do
                    local cfg = ch:FindFirstChild("Config")
                    if cfg then
                        local a = cfg:FindFirstChild("Ammo")
                        local ta = cfg:FindFirstChild("TotalAmmo")
                        if a then a.Value = math.huge end
                        if ta then ta.Value = math.huge end
                    end
                end
            end
        end
    end)

    --============= 战斗拦截 =============
    local combatHook
    local function setCombatBlock(on)
        Settings.combatBlock = on
        if on and not combatHook and hookmetamethod and newcclosure then
            combatHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local packed = table.pack(...)
                if Settings.combatBlock and getnamecallmethod() == "FireServer" and packed[1] == "combatMode" then
                    return nil
                end
                return combatHook(self, table.unpack(packed, 1, packed.n))
            end))
        end
    end

    --============= 隐身 =============
    local ghostConn, ghostBtnGui, ghostBtn, ghostBtnStrokeConn
    local ghostLocked = false
    local ghostBtnPos = UDim2.new(0, 100, 0.5, -25)

    local function refreshGhostBtn()
        if not ghostBtn then return end
        ghostBtn.Text = Settings.ghost and "隐身: 开" or "隐身: 关"
        ghostBtn.TextColor3 = Settings.ghost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end

    local function setGhost(on)
        Settings.ghost = on
        local ch = localPlayer2.Character
        if not ch then refreshGhostBtn(); return end
        if on then
            pcall(function()
                local stuff = ReplicatedStorage:FindFirstChild("Stuff")
                local locs  = stuff and stuff:FindFirstChild("Locations")
                local first = locs and locs:GetChildren()[1]
                if playerFunc then playerFunc:InvokeServer("hideCharacterLocation", first) end
            end)
            if module and module.canEquipSlot then pcall(function() module.canEquipSlot(true) end) end
            if Character and Character.lockHumanoidState then
                pcall(function() Character.lockHumanoidState("ghostMode", nil) end)
            end
            pcall(function()
                GuiService.TouchControlsEnabled = true
                ContextActionService:UnbindAction("LoadingGuiNoResetOnDeath")
                ContextActionService:UnbindAction("DisableCameraMovementNoResetOnDeath")
            end)
            if ghostConn then ghostConn:Disconnect() end
            ghostConn = RunService.RenderStepped:Connect(function() end)
        else
            if ghostConn then ghostConn:Disconnect(); ghostConn = nil end
            pcall(function()
                if playerFunc then playerFunc:InvokeServer("hideCharacterLocation", false) end
            end)
        end
        refreshGhostBtn()
    end

    local function createGhostBtn()
        if ghostBtnGui then return end
        local parent = v29 or getHui() or localPlayer2:FindFirstChild("PlayerGui")
        if not parent then return end
        ghostBtnGui = Instance.new("ScreenGui")
        ghostBtnGui.Name = "GhostQuickSwitch"
        ghostBtnGui.ResetOnSpawn = false
        ghostBtnGui.Parent = parent
        ghostBtn = Instance.new("TextButton")
        ghostBtn.Size = UDim2.new(0, 80, 0, 35)
        ghostBtn.Position = ghostBtnPos
        ghostBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ghostBtn.BackgroundTransparency = 0.4
        ghostBtn.BorderSizePixel = 0
        ghostBtn.Font = Enum.Font.GothamSemibold
        ghostBtn.TextSize = 12
        ghostBtn.Text = Settings.ghost and "隐身: 开" or "隐身: 关"
        ghostBtn.TextColor3 = Settings.ghost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ghostBtn.Active = not ghostLocked
        ghostBtn.Draggable = not ghostLocked
        ghostBtn.Parent = ghostBtnGui
        local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(0, 8); uc.Parent = ghostBtn
        local us = Instance.new("UIStroke"); us.Name = "RainbowStroke"; us.Thickness = 1.5; us.Parent = ghostBtn
        ghostBtnStrokeConn = RunService.RenderStepped:Connect(function()
            if us.Parent then us.Color = rainbowColor(5) end
        end)
        ghostBtn.MouseButton1Click:Connect(function()
            setGhost(not Settings.ghost)
        end)
        ghostBtn:GetPropertyChangedSignal("Position"):Connect(function()
            if not ghostLocked then ghostBtnPos = ghostBtn.Position end
        end)
    end

    local function destroyGhostBtn()
        if ghostBtnStrokeConn then ghostBtnStrokeConn:Disconnect(); ghostBtnStrokeConn = nil end
        if ghostBtnGui then ghostBtnGui:Destroy(); ghostBtnGui = nil end
        ghostBtn = nil
    end

    --============= 布娃娃 / 摔伤 =============
    pcall(function()
        local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)
        local act, actS = Ragdoll.activate, Ragdoll.activateServer
        Ragdoll.activate = function(a, b, c_, ...)
            if Settings.noRagdoll and b then return end
            local packed = table.pack(...)
            packed.n = 4 + packed.n - 1
            table.move(packed, 1, packed.n, 4, packed)
            packed[1], packed[2], packed[3] = a, b, c_
            return act(table.unpack(packed, 1, packed.n))
        end
        if actS then
            Ragdoll.activateServer = function(a, b, c_, ...)
                if Settings.noRagdoll and b then return end
                local packed = table.pack(...)
                packed.n = 4 + packed.n - 1
                table.move(packed, 1, packed.n, 4, packed)
                packed[1], packed[2], packed[3] = a, b, c_
                return actS(table.unpack(packed, 1, packed.n))
            end
        end
    end)

    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local packed = table.pack(...)
            if Settings.noFallDamage and getnamecallmethod() == "FireServer"
                and tostring(self) == "PlayerEvent" and packed[1] == "takeDamage" then
                return nil
            end
            return old(self, table.unpack(packed, 1, packed.n))
        end)
        setreadonly(mt, true)
    end)

    --============= 防越狱拉回 =============
    local savedPivot, savedNotify
    local function setAntiPull(on)
        Settings.antiPrisonPull = on
        pcall(function()
            local A = require(ReplicatedStorage.Modules.Algorithms)
            if on and not savedPivot then
                savedPivot = A.charPivotTo
                A.charPivotTo = function() return nil end
            elseif not on and savedPivot then
                A.charPivotTo = savedPivot; savedPivot = nil
            end
        end)
        pcall(function()
            if not Core then return end
            if on and not savedNotify then
                savedNotify = Core.notify
                Core.notify = function(a)
                    if a and a.message and string.find(a.message, "You can't leave prison yet") then return nil end
                    return savedNotify(a)
                end
            elseif not on and savedNotify then
                Core.notify = savedNotify; savedNotify = nil
            end
        end)
    end

    --============= 自动捡钱 =============
    task.spawn(function()
        while true do
            if Settings.autoMoney then
                local _, _, root = getChar(localPlayer2)
                if root then
                    local best, bestP
                    for _, d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            local n = d.Name
                            local at = string.lower(tostring(d.ActionText or ""))
                            local ot = string.lower(tostring(d.ObjectText or ""))
                            local hit = n == "CashDrop" or n == "GetItem" or n == "Money"
                                or at:find("pick") or at:find("cash") or at:find("collect") or at:find("grab")
                                or ot:find("cash") or ot:find("money")
                            if hit then
                                local p
                                if d.Parent and d.Parent:IsA("BasePart") then p = d.Parent.Position
                                elseif d.Parent and d.Parent:IsA("Attachment") then p = d.Parent.WorldPosition end
                                if p then
                                    local mag = (root.Position - p).Magnitude
                                    if not best or mag < best then best, bestP = mag, { pos = p, prompt = d } end
                                end
                            end
                        end
                    end
                    if bestP and best and best < 120 then
                        if best > 8 then
                            local cframe = CFrame.new(bestP.pos + Vector3.new(0, 3, 0))
                            local ch = localPlayer2.Character
                            if ch then
                                ch:PivotTo(cframe)
                                pcall(function()
                                    if playerEvent then
                                        local id = ((ch:GetAttribute("CharPivotToId") or 0) + 1) % 100
                                        ch:SetAttribute("CharPivotToId", id)
                                        playerEvent:FireServer("charPivotTo", cframe, ch, id)
                                    end
                                end)
                            end
                            task.wait(0.3)
                        end
                        pcall(function()
                            if fireproximityprompt then fireproximityprompt(bestP.prompt, 0)
                            else bestP.prompt.HoldDuration = 0
                                bestP.prompt:InputHoldBegin(); task.wait(0.1); bestP.prompt:InputHoldEnd()
                            end
                        end)
                    end
                end
            end
            task.wait(0.3)
        end
    end)

    --============= 刷钱相关 =============
    local missionCfg = { missionInterval = 2, priorityHighReward = false,
        taxiSafe = false, taxiDelayMode = "随机时间", taxiOrigin = nil }

    local function getTeamJobs()
        if not getgc then return end
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "teamJobs") then return v.teamJobs end
        end
    end
    local function inMission()
        if localPlayer2:GetAttribute("Mission") then return true end
        local tj = getTeamJobs()
        if tj then for _, j in pairs(tj) do if j.joined then return true end end end
        return false
    end
    local function pickJob()
        local tj = getTeamJobs()
        if not tj then return end
        local bestKey, bestVal = nil, -math.huge
        for k, j in pairs(tj) do
            if not j.joined then
                if not missionCfg.priorityHighReward then return k end
                local v = (j.profitability or 1) * 1e6 + (j.reward or 0)
                if v > bestVal then bestVal, bestKey = v, k end
            end
        end
        return bestKey
    end
    task.spawn(function()
        while true do
            if Settings.autoMission and playerFunc and not inMission() then
                local k = pickJob()
                if k then pcall(function() playerFunc:InvokeServer("talkToMission", tostring(k) .. "join") end) end
            end
            task.wait(missionCfg.missionInterval)
        end
    end)

    task.spawn(function()
        while true do
            if Settings.farmer then
                local _, _, root = getChar(localPlayer2)
                if root then
                    local best, bestP
                    for _, d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.ActionText == "Pick Up" then
                            local p = d.Parent and d.Parent:IsA("BasePart") and d.Parent.Position
                            if p then
                                local mag = (root.Position - p).Magnitude
                                if not best or mag < best then best, bestP = mag, { p = p, prompt = d } end
                            end
                        end
                    end
                    if bestP then
                        if best > 8 then
                            local ch = localPlayer2.Character
                            if ch then ch:PivotTo(CFrame.new(bestP.p + Vector3.new(0,3,0))) end
                            task.wait(0.3)
                        else
                            pcall(function()
                                if fireproximityprompt then fireproximityprompt(bestP.prompt, 0) end
                            end)
                        end
                    end
                end
            end
            task.wait(0.3)
        end
    end)

    task.spawn(function()
        local last
        while true do
            if Settings.taxi then
                local g = Workspace:FindFirstChild("Gameplay")
                g = g and g:FindFirstChild("Entities")
                g = g and g:FindFirstChild("ClientContent")
                if g and g:IsA("Model") then
                    local pp = g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
                    local _, _, root = getChar(localPlayer2)
                    if pp and root then
                        local pos = pp.Position
                        if last == nil or (pos - last).Magnitude > 5 then
                            if missionCfg.taxiSafe and missionCfg.taxiOrigin then
                                root.CFrame = CFrame.new(missionCfg.taxiOrigin)
                                local mag = (missionCfg.taxiOrigin - pos).Magnitude
                                local delay = mag > 2000 and math.random(15, 45) or 15
                                task.wait(delay)
                            end
                            root.CFrame = CFrame.new(pos)
                            last = pos
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        while true do
            if Settings.bus then
                local g = Workspace:FindFirstChild("Gameplay")
                g = g and g:FindFirstChild("Entities")
                g = g and g:FindFirstChild("ClientContent")
                g = g and g:GetChildren()[1]
                local area = g and g:FindFirstChild("Area")
                local _, hum, root = getChar(localPlayer2)
                if area and hum and root then
                    local seat = hum.SeatPart
                    if seat then
                        local cf = root.CFrame
                        seat.CFrame = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, 4.7123889803846897, 0) * cf:ToObjectSpace(seat.CFrame)
                        seat.AssemblyLinearVelocity = Vector3.zero
                        seat.AssemblyAngularVelocity = Vector3.zero
                        task.wait(0.1)
                        hum.Sit = false
                    else
                        root.CFrame = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, 4.7123889803846897, 0)
                    end
                    task.wait(5)
                end
            end
            task.wait(1)
        end
    end)

    task.spawn(function()
        while true do
            if Settings.golf and playerFunc then
                pcall(function()
                    playerFunc:InvokeServer("miniGolf", "createLobby")
                    task.wait(0.1)
                    playerFunc:InvokeServer("miniGolf", "setLobbyBid", { bid = 500 })
                    task.wait(0.1)
                    playerFunc:InvokeServer("miniGolf", "setLobbyReady")
                    task.wait(4)
                    playerFunc:InvokeServer("miniGolf", "shot")
                    task.wait(0.5)
                    local function find(path)
                        local cur = Workspace
                        for _, n in ipairs(path) do
                            cur = cur and cur:FindFirstChild(n)
                            if not cur then return end
                        end
                        return cur
                    end
                    local ball = find({ "Gameplay", "Entities", "Content", localPlayer2.Name })
                    local flag = find({ "Gameplay", "Entities", "Content", "_Flag", "FlagPole", "Part" })
                    if ball and flag and ball:IsA("BasePart") then ball.Position = flag.Position end
                end)
            end
            task.wait(Settings.golf and 5 or 1)
        end
    end)

    --============= 自动黑客 =============
    local hackSaved = {}
    local function setAutoHack(on)
        Settings.autoHack = on
        pcall(function()
            local fw = localPlayer2.PlayerScripts:FindFirstChild("Framework")
            fw = fw and require(fw:FindFirstChild("Character"))
            local GR = require(ReplicatedStorage.Modules.GameRules)
            if GR then GR.disableHacking = on; GR.disableMinigames = on end
            if fw then
                if not hackSaved.hacking then hackSaved.hacking = fw.hackingMinigame end
                if not hackSaved.start   then hackSaved.start   = fw.startMinigame end
                if on then
                    fw.hackingMinigame = function() return true end
                    fw.startMinigame   = function() return true end
                else
                    if hackSaved.hacking then fw.hackingMinigame = hackSaved.hacking end
                    if hackSaved.start   then fw.startMinigame   = hackSaved.start   end
                end
            end
        end)
    end

    --============= 杀戮光环 =============
    local auraCfg = {
        enabled = false, range = 50, damage = 5, interval = 0.05,
        onlyPolice = false, onlyCivilian = false, combatCheck = false,
    }
    local lastAura = 0
    RunService.Heartbeat:Connect(function()
        if not auraCfg.enabled or not playerEvent then return end
        local now = tick()
        if now - lastAura < auraCfg.interval then return end
        local _, _, root = getChar(localPlayer2)
        if not root then return end
        local best, bestMag
        for _, p in ipairs(Players:GetPlayers()) do
            if passesFilter(p, auraCfg.onlyPolice, auraCfg.onlyCivilian)
                and isAlive(p) and inCombat(p, auraCfg.combatCheck) then
                local ch = p.Character
                local head = ch and (ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart"))
                if head then
                    local mag = (head.Position - root.Position).Magnitude
                    if mag <= auraCfg.range and (not bestMag or mag < bestMag) then
                        best, bestMag = p, mag
                    end
                end
            end
        end
        if best then
            local ch = best.Character
            local head = ch and (ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart"))
            local pos = root.Position
            if head then
                pcall(function()
                    playerEvent:FireServer("damage", {
                        bodyParts = { { "Head", 1 } },
                        shotCode = { pos, (head.Position - pos).Unit },
                        pos = head.Position,
                        target = best,
                        damageFactor = auraCfg.damage,
                        bulletProofTool = false,
                    })
                end)
                lastAura = now
            end
        end
    end)

    --============= 自瞄 =============
    local aimCfg = {
        enabled = false, prediction = false, teamCheck = false, wallCheck = false,
        showFov = false, showCrosshair = false, showTracer = false, friendCheck = false,
        onlyPolice = false, onlyCivilian = false, combatCheck = false,
        fov = 50, smoothness = 1, targetMode = "准心最近", targetPart = "头",
        color = "红色", fovThickness = 2,
        bulletEnabled = false, bulletFov = 360, bulletDistance = 300,
        bulletPart = "Head", bulletShowFov = true, bulletColor = "红色",
        bulletCombatCheck = false, bulletOnlyPolice = false, bulletOnlyCivilian = false,
    }
    local aimParts = {
        ["头"] = { "Head" },
        ["胸"] = { "UpperTorso", "Torso" },
        ["左手"] = { "LeftHand", "Left Arm" },
        ["右手"] = { "RightHand", "Right Arm" },
        ["左腿"] = { "LeftFoot", "Left Leg" },
        ["右腿"] = { "RightFoot", "Right Leg" },
    }
    local fovCircle = Drawing.new("Circle")
    fovCircle.Filled = false
    fovCircle.NumSides = 64
    fovCircle.Visible = false
    local crosshair = {
        Top    = Drawing.new("Line"), Bottom = Drawing.new("Line"),
        Left   = Drawing.new("Line"), Right  = Drawing.new("Line"),
        Center = Drawing.new("Line"),
    }
    for _, l in pairs(crosshair) do l.Thickness = 2; l.Visible = false end
    local tracer = Drawing.new("Line")

    local function findAimPart(ch, partName)
        local list = aimParts[partName or aimCfg.targetPart] or { "Head" }
        for _, n in ipairs(list) do
            local p = ch:FindFirstChild(n)
            if p then return p end
        end
        return ch:FindFirstChild("HumanoidRootPart")
    end

    local function wallClear(part)
        if not aimCfg.wallCheck then return true end
        local cam = Workspace.CurrentCamera
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = { localPlayer2.Character, cam }
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.IgnoreWater = true
        local hit = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rp)
        return not hit or hit.Instance:IsDescendantOf(part.Parent)
    end

    local function pickTarget()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local best, bestMag
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer2 and isAlive(p)
                and passesFilter(p, aimCfg.onlyPolice, aimCfg.onlyCivilian)
                and inCombat(p, aimCfg.combatCheck) then
                if not (aimCfg.teamCheck and localPlayer2.Team and p.Team == localPlayer2.Team) then
                    local skip = false
                    if aimCfg.friendCheck then
                        local ok, res = pcall(function() return localPlayer2:IsFriendsWith(p.UserId) end)
                        if ok and res then skip = true end
                    end
                    if not skip then
                        local ch = p.Character
                        if ch then
                            local part = findAimPart(ch)
                            local hum = ch:FindFirstChildOfClass("Humanoid")
                            local root = ch:FindFirstChild("HumanoidRootPart")
                                or ch:FindFirstChild("Torso")
                                or ch:FindFirstChild("UpperTorso")
                            if part and hum and root and hum.Health > 0 and wallClear(part) then
                                local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local mag = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                    if mag <= aimCfg.fov then
                                        if aimCfg.targetMode == "距离最近" then
                                            local _, _, me = getChar(localPlayer2)
                                            mag = me and (me.Position - root.Position).Magnitude or math.huge
                                        elseif aimCfg.targetMode == "血量最低" then
                                            mag = hum.Health
                                        end
                                        if not best or mag < bestMag then
                                            best = { player = p, part = part, screen = sp }
                                            bestMag = mag
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    RunService.RenderStepped:Connect(function(dt)
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local col = colorByName(aimCfg.color)
        fovCircle.Position = center
        fovCircle.Radius = aimCfg.fov
        fovCircle.Thickness = aimCfg.fovThickness
        fovCircle.Color = col
        fovCircle.Visible = aimCfg.enabled and aimCfg.showFov
        crosshair.Top.From    = Vector2.new(center.X, center.Y - 5);  crosshair.Top.To    = Vector2.new(center.X, center.Y - 20)
        crosshair.Bottom.From = Vector2.new(center.X, center.Y + 5);  crosshair.Bottom.To = Vector2.new(center.X, center.Y + 20)
        crosshair.Left.From   = Vector2.new(center.X - 5, center.Y);  crosshair.Left.To   = Vector2.new(center.X - 20, center.Y)
        crosshair.Right.From  = Vector2.new(center.X + 5, center.Y);  crosshair.Right.To  = Vector2.new(center.X + 20, center.Y)
        crosshair.Center.From = Vector2.new(center.X - 2, center.Y);  crosshair.Center.To = Vector2.new(center.X + 2, center.Y)
        for _, l in pairs(crosshair) do
            l.Color = col; l.Visible = aimCfg.showCrosshair
        end
        tracer.Visible = false
        if aimCfg.enabled then
            local t = pickTarget()
            if t then
                if aimCfg.showTracer then
                    tracer.From = center
                    tracer.To = Vector2.new(t.screen.X, t.screen.Y)
                    tracer.Color = col
                    tracer.Thickness = 2
                    tracer.Transparency = 0.5
                    tracer.Visible = true
                end
                local pos = t.part.Position
                if aimCfg.prediction then
                    pos = pos + t.part.AssemblyLinearVelocity * dt * 1.5
                end
                local cf = CFrame.new(cam.CFrame.Position, pos)
                cam.CFrame = aimCfg.smoothness >= 1 and cf or cam.CFrame:Lerp(cf, aimCfg.smoothness)
            end
        end
    end)

    -- 静默瞄准 hook
    pcall(function()
        local origRay = Workspace.Raycast
        hookfunction(Workspace.Raycast, function(a, b, c2, d)
            if aimCfg.bulletEnabled and b and c2 then
                local _, _, me = getChar(localPlayer2)
                if me and (b - me.Position).Magnitude < 15 then
                    local target = pickTarget()
                    if target then
                        c2 = (target.part.Position - b).Unit * c2.Magnitude
                    end
                end
            end
            return origRay(a, b, c2, d)
        end)
    end)

    --============= Ragebot =============
    local rageCfg = {
        enabled = false, range = 150, interval = 0.05, bodyPart = "Head",
        jobCheck = false, wallCheck = false, aliveCheck = false, combatCheck = false,
        policeLock = false, civilianLock = false, beam = false,
    }
    local bodyMap = {
        ["头部"] = "Head", ["躯干"] = "Torso", ["左臂"] = "LeftArm",
        ["右臂"] = "RightArm", ["左腿"] = "LeftLeg", ["右腿"] = "RightLeg",
    }
    task.spawn(function()
        while true do
            if rageCfg.enabled and playerEvent then
                local _, _, root = getChar(localPlayer2)
                if root then
                    local meTeam = teamName(localPlayer2)
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= localPlayer2
                            and passesFilter(p, rageCfg.policeLock, rageCfg.civilianLock)
                            and inCombat(p, rageCfg.combatCheck) then
                            local ch, hum = getChar(p)
                            if ch and hum and hum.Health > 0 then
                                local part = ch:FindFirstChild(rageCfg.bodyPart) or findAimPart(ch)
                                if part and not (rageCfg.jobCheck and teamName(p) == meTeam) then
                                    if (part.Position - root.Position).Magnitude <= rageCfg.range then
                                        local blocked = false
                                        if rageCfg.wallCheck then
                                            local cam = Workspace.CurrentCamera
                                            local rp = RaycastParams.new()
                                            rp.FilterDescendantsInstances = { localPlayer2.Character, cam }
                                            rp.FilterType = Enum.RaycastFilterType.Exclude
                                            local hit = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rp)
                                            if hit and not hit.Instance:IsDescendantOf(ch) then blocked = true end
                                        end
                                        if not blocked then
                                            pcall(function()
                                                playerEvent:FireServer("damage", {
                                                    bodyParts = { { rageCfg.bodyPart, 1 } },
                                                    shotCode = { root.Position, (part.Position - root.Position).Unit },
                                                    pos = part.Position,
                                                    target = p,
                                                    damageFactor = 1.5,
                                                    bulletProofTool = false,
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
            task.wait(rageCfg.interval)
        end
    end)

    --============= Hitbox 范围 =============
    local hbCfg = {
        active = false, size = 10, transparency = 0.7, teamCheck = false,
        color = "红色", material = "Neon", rainbow = false,
        checkCorpses = false, outline = false, collision = false,
        glow = false, pulse = false, affectNPC = false,
    }
    local hbSaved = {}

    local function restoreHb(ch)
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local s = hbSaved[root]
        if s then
            root.Size = s.Size
            root.Transparency = s.Transparency
            root.Material = s.Material
            root.CanCollide = s.CanCollide
            root.Color = s.Color
        end
        local hl = root:FindFirstChild("PY_HitboxHighlight"); if hl then hl:Destroy() end
        local li = root:FindFirstChild("PY_HitboxLight");     if li then li:Destroy() end
    end

    local function applyHb(ch)
        if not ch then return end
        local root = ch:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if not hbSaved[root] then
            hbSaved[root] = {
                Size = root.Size, Transparency = root.Transparency,
                Material = root.Material, CanCollide = root.CanCollide, Color = root.Color,
            }
        end
        if not hbCfg.active then return end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hbCfg.checkCorpses and hum and hum.Health <= 0 then return end
        local sz = hbCfg.size
        if hbCfg.pulse then sz = sz * (math.sin(tick() * 2) * 0.2 + 1) end
        root.Size = Vector3.new(sz, sz, sz)
        root.Transparency = hbCfg.transparency
        root.Material = Enum.Material[hbCfg.material] or Enum.Material.Neon
        root.CanCollide = hbCfg.collision
        root.Color = hbCfg.rainbow and rainbowColor(5) or colorByName(hbCfg.color)
        if hbCfg.outline then
            local hl = root:FindFirstChild("PY_HitboxHighlight") or Instance.new("Highlight")
            hl.Name = "PY_HitboxHighlight"
            hl.FillTransparency = 1
            hl.OutlineColor = root.Color
            hl.OutlineTransparency = hbCfg.transparency
            hl.Parent = root
        end
        if hbCfg.glow then
            local li = root:FindFirstChild("PY_HitboxLight") or Instance.new("PointLight")
            li.Name = "PY_HitboxLight"
            li.Brightness = 5
            li.Range = 15
            li.Color = root.Color
            li.Parent = root
        end
    end

    RunService.Heartbeat:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer2 and getChar(p) then
                if not (hbCfg.teamCheck and localPlayer2.Team and p.Team == localPlayer2.Team) then
                    applyHb(getChar(p))
                end
            end
        end
        if hbCfg.affectNPC then
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(d) then
                    applyHb(d)
                end
            end
        end
    end)

    --============= ESP =============
    local espCfg = {
        enabled = false, name = true, distance = true, health = true, highlight = true,
        tracer = false, tracerOrigin = "屏幕底部", showFugitive = true,
        selectedTeams = {
            Chef = true, Civilian = true, Delivery = true, Farmer = true, Fire = true,
            Police = true, Medical = true, Prisoner = true, ["Road Service"] = true, Transit = true,
        },
        trackers = {},
    }
    local teamLabel = {
        Chef = "厨师", Civilian = "平民", Delivery = "配送员", Farmer = "农民",
        Fire = "消防员", Police = "警察", Medical = "医护人员", Prisoner = "囚犯",
        ["Road Service"] = "道路服务", Transit = "交通",
    }
    local teamColor = {
        Chef = Color3.fromRGB(255,200,0), Civilian = Color3.fromRGB(100,200,255),
        Delivery = Color3.fromRGB(255,150,50), Farmer = Color3.fromRGB(50,200,50),
        Fire = Color3.fromRGB(255,50,50), Police = Color3.fromRGB(50,100,255),
        Medical = Color3.fromRGB(255,50,255), Prisoner = Color3.fromRGB(255,150,150),
        ["Road Service"] = Color3.fromRGB(255,255,100), Transit = Color3.fromRGB(100,255,255),
    }

    local function isFugitive(p)
        local isCiv = p.Team and p.Team.Name == "Civilian"
        if isCiv then
            return p:GetAttribute("CombatMode") or p:GetAttribute("Pursuit")
        end
        return isCiv
    end

    local function espVisible(p)
        if not espCfg.enabled or p == localPlayer2 then return false end
        if not getChar(p) then return false end
        if espCfg.showFugitive and isFugitive(p) then return true end
        local cnt, total = 0, 0
        for _, v in pairs(espCfg.selectedTeams) do
            total = total + 1
            if v then cnt = cnt + 1 end
        end
        if cnt == 0 or cnt >= total then return true end
        local n = p.Team and p.Team.Name
        if not n then return true end
        if espCfg.selectedTeams[n] then return true end
        for k, lbl in pairs(teamLabel) do
            if (lbl == n or k == n) and espCfg.selectedTeams[k] then return true end
        end
        return false
    end

    local function removeEsp(p)
        local t = espCfg.trackers[p]
        if not t then return end
        for _, v in pairs(t) do
            pcall(function()
                if typeof(v) == "RBXScriptConnection" then v:Disconnect()
                elseif typeof(v) == "Instance" then v:Destroy()
                elseif type(v) == "userdata" and v.Remove then v:Remove() end
            end)
        end
        espCfg.trackers[p] = nil
    end

    local function getEspHolder()
        local parent = v29 or getHui() or localPlayer2:FindFirstChild("PlayerGui")
        v29 = parent
        if not parent then return end
        local h = parent:FindFirstChild("PYHubESP")
        if h then return h end
        local ok, gui = pcall(function()
            local g = Instance.new("ScreenGui")
            g.Name = "PYHubESP"
            g.ResetOnSpawn = false
            g.IgnoreGuiInset = true
            g.DisplayOrder = 999
            g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            g.Parent = parent
            return g
        end)
        if ok then return gui end
        return parent
    end

    local function createEsp(p)
        if espCfg.trackers[p] or not espVisible(p) then return end
        local ch, hum, root = getChar(p)
        if not ch or not root then return end
        local holder = getEspHolder()
        if not holder then return end
        local bb = Instance.new("BillboardGui")
        bb.Name = "PlayerESP_" .. p.Name
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(8, 0, 3, 0)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.MaxDistance = 10000
        bb.Adornee = root
        bb.Parent = holder
        local fr = Instance.new("Frame")
        fr.BackgroundTransparency = 1
        fr.Size = UDim2.fromScale(1, 1)
        fr.Parent = bb
        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1, 0, 0.55, 0)
        t1.BackgroundTransparency = 1
        t1.Font = Enum.Font.GothamBold
        t1.TextSize = 16
        t1.TextStrokeTransparency = 0
        t1.Text = p.Name
        t1.TextColor3 = Color3.fromRGB(0, 255, 0)
        t1.Parent = fr
        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1, 0, 0.45, 0)
        t2.Position = UDim2.new(0, 0, 0.55, 0)
        t2.BackgroundTransparency = 1
        t2.Font = Enum.Font.Gotham
        t2.TextSize = 14
        t2.TextStrokeTransparency = 0
        t2.TextColor3 = Color3.fromRGB(0, 255, 0)
        t2.Parent = fr
        local hl = Instance.new("Highlight")
        hl.Name = "PlayerESP_Highlight"
        hl.Adornee = ch
        hl.FillTransparency = 0.65
        hl.OutlineTransparency = 0
        pcall(function() hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
        hl.Parent = ch
        local line
        pcall(function()
            if Drawing and Drawing.new then
                line = Drawing.new("Line")
                line.Thickness = 1
                line.Transparency = 0.5
                line.Visible = false
            end
        end)
        espCfg.trackers[p] = {
            bill = bb, highlight = hl, tracer = line,
            update = RunService.Heartbeat:Connect(function()
                local cch, chum, croot = getChar(p)
                if not espVisible(p) or not cch or not croot then
                    if line then line.Visible = false end
                    if bb.Parent then bb.Enabled = false end
                    return
                end
                root = croot
                bb.Adornee = root
                bb.Enabled = true
                if hl.Parent ~= cch then hl.Parent = cch end
                hl.Adornee = cch
                local fug = isFugitive(p)
                local tn = p.Team and p.Team.Name
                local col = fug and Color3.fromRGB(255, 0, 0) or teamColor[tn] or Color3.fromRGB(0, 255, 0)
                t1.Text = "[" .. (fug and "逃犯" or teamLabel[tn] or tn or "未知") .. "] " .. p.Name
                t1.TextColor3 = col
                t1.Visible = espCfg.name
                hl.FillColor = col
                hl.OutlineColor = col
                hl.Enabled = espCfg.highlight
                local _, _, me = getChar(localPlayer2)
                local parts = {}
                if espCfg.distance and me then
                    table.insert(parts, string.format("%.1f", (me.Position - root.Position).Magnitude))
                end
                if espCfg.health and chum then
                    table.insert(parts, tostring(math.floor(chum.Health)))
                end
                t2.Text = #parts > 0 and ("[" .. table.concat(parts, "/") .. "]") or ""
                t2.TextColor3 = col
                t2.Visible = espCfg.distance or espCfg.health
                local cam = Workspace.CurrentCamera
                if line then
                    if espCfg.tracer and cam then
                        local sp, on = cam:WorldToViewportPoint(root.Position)
                        if on then
                            local vp = cam.ViewportSize
                            if espCfg.tracerOrigin == "屏幕中心" then
                                line.From = Vector2.new(vp.X / 2, vp.Y / 2)
                            elseif espCfg.tracerOrigin == "屏幕顶部" then
                                line.From = Vector2.new(vp.X / 2, 0)
                            else
                                line.From = Vector2.new(vp.X / 2, vp.Y)
                            end
                            line.To = Vector2.new(sp.X, sp.Y)
                            line.Color = col
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
            end),
        }
    end

    local function refreshEsp()
        for k in pairs(espCfg.trackers) do
            if not espVisible(k) then removeEsp(k) end
        end
        if espCfg.enabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer2 and espVisible(p) and not espCfg.trackers[p] then
                    pcall(createEsp, p)
                end
            end
        end
    end

    local function hookEspPlayer(p)
        if p == localPlayer2 then return end
        p.CharacterAdded:Connect(function()
            task.wait(0.25)
            if espCfg.enabled then removeEsp(p); pcall(createEsp, p) end
        end)
    end
    for _, p in ipairs(Players:GetPlayers()) do hookEspPlayer(p) end
    Players.PlayerAdded:Connect(hookEspPlayer)
    Players.PlayerRemoving:Connect(removeEsp)

    local lastEspScan = 0
    RunService.Heartbeat:Connect(function()
        if not espCfg.enabled then return end
        if tick() - lastEspScan < 0.2 then return end
        lastEspScan = tick()
        refreshEsp()
    end)

    --============= 警察自动铐 =============
    local policeCfg = { range = 200, delay = 0.5, combatCheck = false, teleport = false }
    task.spawn(function()
        while Settings.autoCuff do
            local _, _, root = getChar(localPlayer2)
            if root and playerFunc then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer2 and isAlive(p) and inCombat(p, policeCfg.combatCheck) then
                        local _, _, proot = getChar(p)
                        if proot and (proot.Position - root.Position).Magnitude <= policeCfg.range then
                            pcall(function() playerFunc:InvokeServer("handcuff", p, false) end)
                        end
                    end
                end
                if policeCfg.teleport then
                    local best, bestMag
                    for _, p in ipairs(Players:GetPlayers()) do
                        local wanted = p ~= localPlayer2 and p.Team and p.Team.Name == "Civilian"
                        if wanted then wanted = (p:GetAttribute("WantedLevel") or 0) > 0 end
                        if wanted then
                            local _, _, proot = getChar(p)
                            if proot then
                                local mag = (proot.Position - root.Position).Magnitude
                                if mag <= policeCfg.range and (not bestMag or mag < bestMag) then
                                    best, bestMag = p, mag
                                end
                            end
                        end
                    end
                    if best then
                        local _, _, proot = getChar(best)
                        if proot then root.CFrame = CFrame.new(proot.Position - proot.CFrame.LookVector * 3) end
                    end
                end
            end
            task.wait(policeCfg.delay)
        end
    end)

    --============= 移动（跳跃） =============
    MovementSettings = {
        walkEnabled = false, walkSpeed = 200,
        jumpEnabled = false, jumpPower = 50, jumpMultiplier = 1,
        infiniteJump = false,
        flyEnabled = false, flySpeed = 30, flyMode = "传送",
        noclip = false,
    }
    local FlyState = {
        walkConn = nil, jumpConn = nil, flyConn = nil,
        bodyVelocity = nil, bodyGyro = nil, noclipConn = nil, collisionCache = {},
    }
    local controls
    pcall(function()
        controls = require(localPlayer2.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
    end)

    local function stopJump()
        if FlyState.jumpConn then FlyState.jumpConn:Disconnect(); FlyState.jumpConn = nil end
    end
    local function startJump()
        stopJump()
        if not MovementSettings.jumpEnabled then return end
        FlyState.jumpConn = UserInputService.JumpRequest:Connect(function()
            if not MovementSettings.jumpEnabled then return end
            local _, hum, root = getChar(localPlayer2)
            if not hum or not root or hum.Health <= 0 then return end
            local st = hum:GetState()
            local canJump = MovementSettings.infiniteJump
                or st == Enum.HumanoidStateType.Landed
                or st == Enum.HumanoidStateType.Running
                or st == Enum.HumanoidStateType.RunningNoPhysics
            if not canJump then return end
            root.CFrame = root.CFrame + Vector3.new(0, MovementSettings.jumpPower * MovementSettings.jumpMultiplier * 0.1, 0)
        end)
    end

    localPlayer2.CharacterAdded:Connect(function()
        task.wait(0.5)
        FlyState.collisionCache = {}
        if MovementSettings.jumpEnabled then startJump() end
    end)

    --========================================================
    --  WindUI 界面（只保留源码1的UI，加载源码2的功能）
    --========================================================

    -- 公告
    local AnnounceTab = Window:Tab({ Title = "公告", Icon = "message-circle", Locked = false })
    AnnounceTab:Paragraph({ Title = "破解版", Desc = "XI团队暴打所有联邦狗", Image = "message-circle", ImageSize = 32 })
    AnnounceTab:Paragraph({ Title = "开源人", Desc = "苏达", Image = "user", ImageSize = 32 })

    -- 主页
    local HomeTab = Window:Tab({ Title = "主页", Icon = "home", Locked = false })
    HomeTab:Paragraph({ Title = "PY Hub", Desc = "圣奥里精简版", Image = "zap", ImageSize = 32 })
    HomeTab:Paragraph({ Title = "玩家", Desc = "当前服务器ID: " .. game.PlaceId, Image = "users", ImageSize = 32 })

    -- 主要功能
    local MainTab = Window:Tab({ Title = "主要功能", Icon = "sliders-h", Locked = false })
    MainTab:Toggle({ Title = "无限体力", Default = false, Callback = function(v) Settings.stamina = v end })
    MainTab:Toggle({ Title = "无限饥饿", Default = false, Callback = function(v) Settings.food = v end })
    MainTab:Toggle({ Title = "战斗拦截", Default = false, Callback = function(v) setCombatBlock(v) end })
    MainTab:Toggle({ Title = "隐身", Default = false, Callback = function(v) setGhost(v) end })
    MainTab:Toggle({
        Title = "显示隐身悬浮窗",
        Default = false,
        Callback = function(v)
            if v then createGhostBtn() else destroyGhostBtn() end
        end,
    })
    MainTab:Toggle({
        Title = "锁定隐身悬浮窗位置",
        Default = false,
        Callback = function(v)
            ghostLocked = v
            if ghostBtn then
                ghostBtn.Active = not v
                ghostBtn.Draggable = not v
            end
        end,
    })
    MainTab:Toggle({ Title = "防布娃娃", Default = false, Callback = function(v) Settings.noRagdoll = v end })
    MainTab:Toggle({ Title = "防摔伤", Default = false, Callback = function(v) Settings.noFallDamage = v end })
    MainTab:Toggle({ Title = "防越狱拉回", Default = false, Callback = function(v) setAntiPull(v) end })
    MainTab:Toggle({ Title = "自动捡钱", Default = false, Callback = function(v) Settings.autoMoney = v end })
    MainTab:Toggle({ Title = "无限子弹", Default = false, Callback = function(v) Settings.infiniteAmmo = v end })
    MainTab:Toggle({ Title = "快速射击", Default = false, Callback = function(v) Settings.rapidFire = v end })

    -- 刷钱
    local MoneyTab = Window:Tab({ Title = "刷钱", Icon = "money-bill-wave", Locked = false })
    MoneyTab:Toggle({ Title = "自动接取任务", Default = false, Callback = function(v) Settings.autoMission = v end })
    MoneyTab:Toggle({ Title = "优先高收益任务", Default = false, Callback = function(v) missionCfg.priorityHighReward = v end })
    MoneyTab:Input({
        Title = "接取间隔",
        Value = "2",
        PlaceholderText = "输入间隔秒数",
        ClearTextOnFocus = false,
        Callback = function(v)
            local n = tonumber(v)
            if n and n > 0 then missionCfg.missionInterval = n end
        end,
    })
    MoneyTab:Toggle({
        Title = "安全模式(出租车)",
        Default = false,
        Callback = function(v)
            missionCfg.taxiSafe = v
            if v then
                local _, _, root = getChar(localPlayer2)
                if root then missionCfg.taxiOrigin = root.Position end
            end
        end,
    })
    MoneyTab:Dropdown({
        Title = "出租车延迟模式",
        Values = { "随机时间", "距离测算" },
        Value = "随机时间",
        Callback = function(v) missionCfg.taxiDelayMode = v end,
    })
    MoneyTab:Toggle({ Title = "出租车刷钱", Default = false, Callback = function(v) Settings.taxi = v end })
    MoneyTab:Toggle({ Title = "公交车刷钱", Default = false, Callback = function(v) Settings.bus = v end })
    MoneyTab:Toggle({ Title = "农民刷钱", Default = false, Callback = function(v) Settings.farmer = v end })
    MoneyTab:Toggle({ Title = "自动黑客小游戏", Default = false, Callback = function(v) setAutoHack(v) end })
    MoneyTab:Toggle({ Title = "高尔夫刷钱", Default = false, Callback = function(v) Settings.golf = v end })

    -- 战斗
    local CombatTab = Window:Tab({ Title = "战斗", Icon = "crosshairs", Locked = false })
    CombatTab:Toggle({ Title = "杀戮光环", Default = false, Callback = function(v) auraCfg.enabled = v end })
    CombatTab:Toggle({
        Title = "只攻击警察", Default = false,
        Callback = function(v) auraCfg.onlyPolice = v; if v then auraCfg.onlyCivilian = false end end,
    })
    CombatTab:Toggle({
        Title = "只攻击平民", Default = false,
        Callback = function(v) auraCfg.onlyCivilian = v; if v then auraCfg.onlyPolice = false end end,
    })
    CombatTab:Toggle({ Title = "战斗检测", Default = false, Callback = function(v) auraCfg.combatCheck = v end })
    CombatTab:Slider({
        Title = "攻击范围", Value = { Min = 10, Max = 500, Default = 50 },
        Callback = function(v) auraCfg.range = v end,
    })
    CombatTab:Slider({
        Title = "伤害倍率", Value = { Min = 1, Max = 100, Default = 5 },
        Callback = function(v) auraCfg.damage = v end,
    })

    -- 自瞄
    local AimTab = Window:Tab({ Title = "自瞄", Icon = "crosshairs", Locked = false })
    AimTab:Toggle({ Title = "开启/关闭自瞄", Default = false, Callback = function(v) aimCfg.enabled = v end })
    AimTab:Toggle({ Title = "显示Fov圈", Default = false, Callback = function(v) aimCfg.showFov = v end })
    AimTab:Toggle({ Title = "显示准心", Default = false, Callback = function(v) aimCfg.showCrosshair = v end })
    AimTab:Toggle({ Title = "显示追踪线", Default = false, Callback = function(v) aimCfg.showTracer = v end })
    AimTab:Toggle({ Title = "队伍检测", Default = false, Callback = function(v) aimCfg.teamCheck = v end })
    AimTab:Toggle({ Title = "好友检测", Default = false, Callback = function(v) aimCfg.friendCheck = v end })
    AimTab:Toggle({ Title = "墙壁检测", Default = false, Callback = function(v) aimCfg.wallCheck = v end })
    AimTab:Toggle({ Title = "预判自瞄", Default = false, Callback = function(v) aimCfg.prediction = v end })
    AimTab:Toggle({
        Title = "只自瞄警察", Default = false,
        Callback = function(v) aimCfg.onlyPolice = v; if v then aimCfg.onlyCivilian = false end end,
    })
    AimTab:Toggle({
        Title = "只自瞄平民", Default = false,
        Callback = function(v) aimCfg.onlyCivilian = v; if v then aimCfg.onlyPolice = false end end,
    })
    AimTab:Toggle({ Title = "战斗检测", Default = false, Callback = function(v) aimCfg.combatCheck = v end })
    AimTab:Dropdown({
        Title = "优先锁定模式",
        Values = { "准心最近", "距离最近", "血量最低" },
        Value = "准心最近",
        Callback = function(v) aimCfg.targetMode = v end,
    })
    AimTab:Dropdown({
        Title = "瞄准身体部位",
        Values = { "头", "胸", "左手", "右手", "左腿", "右腿" },
        Value = "头",
        Callback = function(v) aimCfg.targetPart = v end,
    })
    AimTab:Slider({
        Title = "Fov圈大小", Value = { Min = 1, Max = 500, Default = 50 },
        Callback = function(v) aimCfg.fov = v end,
    })
    AimTab:Slider({
        Title = "自瞄平滑度", Value = { Min = 1, Max = 10, Default = 10 },
        Callback = function(v) aimCfg.smoothness = v / 10 end,
    })
    AimTab:Slider({
        Title = "Fov圈厚度", Value = { Min = 1, Max = 5, Default = 2 },
        Callback = function(v) aimCfg.fovThickness = v end,
    })
    AimTab:Dropdown({
        Title = "颜色选择",
        Values = { "红色", "黄色", "绿色", "蓝色", "紫色", "白色", "黑色", "彩虹色" },
        Value = "红色",
        Callback = function(v) aimCfg.color = v end,
    })

    -- Ragebot
    local RageTab = Window:Tab({ Title = "Ragebot", Icon = "bot", Locked = false })
    RageTab:Toggle({ Title = "Ragebot", Default = false, Callback = function(v) rageCfg.enabled = v end })
    RageTab:Slider({ Title = "攻击距离", Value = { Min = 10, Max = 500, Default = 150 }, Step = 1,
        Callback = function(v) rageCfg.range = v end })
    RageTab:Slider({ Title = "攻击间隔", Value = { Min = 0.01, Max = 1, Default = 0.05 }, Step = 0.01,
        Callback = function(v) rageCfg.interval = v end })
    RageTab:Dropdown({
        Title = "攻击部位",
        Values = { "头部", "躯干", "左臂", "右臂", "左腿", "右腿" },
        Value = "头部",
        Callback = function(v) rageCfg.bodyPart = bodyMap[v] or "Head" end,
    })
    RageTab:Toggle({ Title = "职业检测", Default = false, Callback = function(v) rageCfg.jobCheck = v end })
    RageTab:Toggle({ Title = "墙壁检测", Default = false, Callback = function(v) rageCfg.wallCheck = v end })
    RageTab:Toggle({ Title = "活体检测", Default = false, Callback = function(v) rageCfg.aliveCheck = v end })
    RageTab:Toggle({ Title = "战斗状态检测", Default = false, Callback = function(v) rageCfg.combatCheck = v end })
    RageTab:Toggle({
        Title = "锁定警察", Default = false,
        Callback = function(v) rageCfg.policeLock = v; if v then rageCfg.civilianLock = false end end,
    })
    RageTab:Toggle({
        Title = "锁定平民", Default = false,
        Callback = function(v) rageCfg.civilianLock = v; if v then rageCfg.policeLock = false end end,
    })
    RageTab:Toggle({ Title = "弹道显示", Default = false, Callback = function(v) rageCfg.beam = v end })

    -- 范围
    local HitboxTab = Window:Tab({ Title = "范围", Icon = "bullseye", Locked = false })
    HitboxTab:Toggle({
        Title = "开启/关闭范围", Default = false,
        Callback = function(v)
            hbCfg.active = v
            if not v then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then restoreHb(p.Character) end
                end
            end
        end,
    })
    HitboxTab:Input({
        Title = "范围大小设置", Value = "10",
        Callback = function(v) local n = tonumber(v); if n and n > 0 then hbCfg.size = n end end,
    })
    HitboxTab:Input({
        Title = "范围透明度设置(0-1)", Value = "0.7",
        Callback = function(v) local n = tonumber(v); if n and n >= 0 and n <= 1 then hbCfg.transparency = n end end,
    })
    HitboxTab:Dropdown({
        Title = "选择范围颜色",
        Values = { "红色", "蓝色", "黄色", "绿色", "青色", "橙色", "紫色", "白色", "黑色", "彩虹色" },
        Value = "红色",
        Callback = function(v) hbCfg.color = v; hbCfg.rainbow = (v == "彩虹色") end,
    })
    HitboxTab:Dropdown({
        Title = "选择范围材质",
        Values = { "Neon", "Plastic", "Wood", "Slate", "Concrete", "Metal", "SmoothPlastic" },
        Value = "Neon",
        Callback = function(v) hbCfg.material = v end,
    })
    HitboxTab:Toggle({ Title = "NPC范围", Default = false, Callback = function(v) hbCfg.affectNPC = v end })
    HitboxTab:Toggle({ Title = "队伍检测", Default = false, Callback = function(v) hbCfg.teamCheck = v end })
    HitboxTab:Toggle({ Title = "活体检测", Default = false, Callback = function(v) hbCfg.checkCorpses = v end })
    HitboxTab:Toggle({ Title = "显示轮廓", Default = false, Callback = function(v) hbCfg.outline = v end })
    HitboxTab:Toggle({ Title = "启用/禁用碰撞", Default = false, Callback = function(v) hbCfg.collision = v end })
    HitboxTab:Toggle({ Title = "发光效果", Default = false, Callback = function(v) hbCfg.glow = v end })
    HitboxTab:Toggle({ Title = "脉动效果", Default = false, Callback = function(v) hbCfg.pulse = v end })

    -- 玩家
    local PlayerTab = Window:Tab({ Title = "玩家", Icon = "user", Locked = false })
    PlayerTab:Toggle({
        Title = "开启/关闭跳跃", Default = false,
        Callback = function(v)
            MovementSettings.jumpEnabled = v
            if v then startJump() else stopJump() end
        end,
    })
    PlayerTab:Slider({
        Title = "设置跳跃高度", Value = { Min = 50, Max = 400, Default = 50 },
        Callback = function(v) MovementSettings.jumpPower = v end,
    })
    PlayerTab:Slider({
        Title = "设置跳跃倍数", Value = { Min = 1, Max = 10, Default = 1 },
        Callback = function(v) MovementSettings.jumpMultiplier = v end,
    })
    PlayerTab:Toggle({ Title = "无限跳跃", Default = false, Callback = function(v) MovementSettings.infiniteJump = v end })

    -- 警察功能
    local PoliceTab = Window:Tab({ Title = "警察功能", Icon = "handcuffs", Locked = false })
    PoliceTab:Toggle({ Title = "自动铐", Default = false, Callback = function(v) Settings.autoCuff = v end })
    PoliceTab:Toggle({ Title = "自动传送", Default = false, Callback = function(v) policeCfg.teleport = v end })
    PoliceTab:Toggle({ Title = "战斗检测", Default = false, Callback = function(v) policeCfg.combatCheck = v end })
    PoliceTab:Slider({
        Title = "范围", Value = { Min = 10, Max = 500, Default = 200 }, Step = 5,
        Callback = function(v) policeCfg.range = v end,
    })
    PoliceTab:Slider({
        Title = "间隔", Value = { Min = 0.1, Max = 3, Default = 0.5 }, Step = 0.1,
        Callback = function(v) policeCfg.delay = v end,
    })

    -- ESP
    local EspTab = Window:Tab({ Title = "ESP", Icon = "eye", Locked = false })
    EspTab:Toggle({
        Title = "玩家透视总开关", Default = false,
        Callback = function(v)
            if type(v) == "table" then v = v.Value end
            espCfg.enabled = v == true
            if not espCfg.enabled then
                for k in pairs(espCfg.trackers) do removeEsp(k) end
            else
                pcall(refreshEsp)
            end
        end,
    })
    EspTab:Toggle({ Title = "显示名字", Default = true, Callback = function(v) espCfg.name = v end })
    EspTab:Toggle({ Title = "显示距离", Default = true, Callback = function(v) espCfg.distance = v end })
    EspTab:Toggle({ Title = "显示血量", Default = true, Callback = function(v) espCfg.health = v end })
    EspTab:Toggle({ Title = "显示高亮", Default = true, Callback = function(v) espCfg.highlight = v end })
    EspTab:Toggle({ Title = "显示追踪线", Default = false, Callback = function(v) espCfg.tracer = v end })
    EspTab:Dropdown({
        Title = "追踪线起点",
        Values = { "屏幕底部", "屏幕中心", "屏幕顶部" },
        Value = "屏幕底部",
        Callback = function(v) espCfg.tracerOrigin = v end,
    })
    local teamValues = { "逃犯", "厨师", "平民", "配送员", "农民", "消防员", "警察", "医护人员", "囚犯", "道路服务", "交通" }
    EspTab:Dropdown({
        Title = "选择透视队伍",
        Values = teamValues,
        Value = teamValues,
        Multi = true,
        AllowNone = true,
        Callback = function(v)
            for k in pairs(espCfg.selectedTeams) do espCfg.selectedTeams[k] = false end
            espCfg.showFugitive = false
            if type(v) ~= "table" then return end
            local function apply(label)
                if label == "逃犯" then espCfg.showFugitive = true; return end
                for k, lbl in pairs(teamLabel) do
                    if lbl == label or k == label then espCfg.selectedTeams[k] = true end
                end
            end
            if v[1] ~= nil then
                for _, x in ipairs(v) do apply(x) end
            else
                for k, x in pairs(v) do
                    if x == true then apply(k)
                    elseif type(x) == "string" then apply(x) end
                end
            end
        end,
    })
end

--========================================================
--  启动
--========================================================
if getgenv().PYHubAutoRun ~= false then
    task.defer(function()
        local ok, err = pcall(PYHubEntry, "", "", "", "", "", nil, {}, nil, nil,
            function() end,
            function(msg)
                local step = tostring(msg or "")
                return function()
                    if step ~= "" then print("[PY Hub]", step) end
                end
            end,
            function() end)
        if not ok then warn("[PY Hub] 启动失败:", err) end
    end)
end