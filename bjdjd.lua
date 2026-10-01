--[[
    PY Hub UI - 独立运行版（含完整功能）
    用法：复制到漏洞执行器执行
    依赖：WindUI (自动从 GitHub 加载)
]]

-- ============ 0. 防风 ============
do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lp = Players.LocalPlayer

    -- AntiCheat 表函数替换
    pcall(function()
        local antiCheat = ReplicatedStorage:FindFirstChild("AntiCheat", true)
        if antiCheat and type(antiCheat) == "table" then
            for k, v in pairs(antiCheat) do
                if type(v) == "function" then
                    antiCheat[k] = function(...)
                        local ok, result = pcall(v, ...)
                        if ok then return result end
                        return true
                    end
                end
            end
        end
    end)

    -- Ratchet / Sha256 补丁
    pcall(function()
        local Ratchet = require(ReplicatedStorage:FindFirstChild("Ratchet", true))
        local Sha256 = require(ReplicatedStorage:FindFirstChild("Sha256", true))
        local mt = getmetatable(Ratchet)
        if mt and mt.__index and not mt.__index.__patched then
            mt.__index.catchUp = function(self, target)
                while self.index < target do self:advance() end
                return true
            end
            mt.__index.respond = function(self, arg)
                return Sha256("resp|" .. tostring(self.state) .. "|" .. tostring(self.index) .. "|" .. tostring(arg))
            end
            mt.__index.__patched = true
        end
    end)

    -- 拦截 GetService("InsertService"/"Selection"/"Stats")
    if hookmetamethod and newcclosure then
        local orig
        local function indexHook(self, key)
            if self == game and (key == "GetService" or key == "getService") then
                return function(_, name)
                    if name == "InsertService" or name == "Selection" or name == "Stats" then
                        return nil
                    end
                    return orig(self, name)
                end
            end
            return orig(self, key)
        end
        orig = hookmetamethod(game, "__index", newcclosure(indexHook))
    end

    -- 拦截 Kick / PlayerEvent / PlayerFunc 部分方法
    if hookmetamethod and newcclosure and getnamecallmethod then
        local orig
        local function namecallHook(self, ...)
            local args = table.pack(...)
            local method = getnamecallmethod()

            if method == "Kick" and self == lp then
                return
            end

            if method == "FireServer" and self.Name == "PlayerEvent" then
                local first = args[1]
                if first == "char2" or first == "coreGame" or first == "vehicleTrack"
                    or first == "platform" or first == "messageDeliver" or first == "runOverVictim"
                    or first == "DEBUG2" or first == "chatCommand" or first == "controlsGuide" then
                    return
                end
            elseif method == "InvokeServer" and self.Name == "PlayerFunc" then
                local first = args[1]
                if first == "getPlayerData" or first == "getPlayerBanHistory" or first == "getPlayerInGame"
                    or first == "getPlayerServerEncounters" or first == "getSecret" then
                    return true
                end
            end

            return orig(self, table.unpack(args, 1, args.n))
        end
        orig = hookmetamethod(game, "__namecall", newcclosure(namecallHook))
    end

    -- Font.new 兜底
    if hookfunction and Font and Font.new then
        local fontNew = Font.new
        pcall(function()
            hookfunction(fontNew, function(family, weight, style)
                local ok, result = pcall(fontNew, family, weight, style)
                if ok then return result end
                weight = weight or Enum.FontWeight.Medium
                style = style or Enum.FontStyle.Normal
                ok, result = pcall(fontNew, Enum.Font.GothamMedium, weight, style)
                if ok then return result end
                return Font.fromEnum(Enum.Font.GothamMedium)
            end)
        end)
    end
end

-- ============ 1. 加载 WindUI ============
local lib
do
    local ok, err = pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/123fa98/Xi_Pro/refs/heads/main/UI.lua")
        lib = loadstring(src)()
    end)
    if not ok or not lib then
        warn("[PY Hub] WindUI 加载失败: " .. tostring(err))
        return
    end
end

-- ============ 2. 服务 ============
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local localPlayer3 = Players.LocalPlayer

local v29
do
    local ok, hui = pcall(function()
        if type(gethui) == "function" then return gethui() end
    end)
    if ok and hui then v29 = hui
    else
        local ok2, cg = pcall(function() return game:FindService("CoreGui") end)
        if ok2 and cg then v29 = cg
        else v29 = localPlayer3:WaitForChild("PlayerGui", 5) end
    end
end

-- ============ 3. 状态变量 ============
local v27
local v28
local connection
local connection2
local flag8 = false
local flag9 = false
local flag10 = false
local textButton

-- ============ 4. 配置表 ============
local tbl8 = { randomBg = true, borderColor = nil, isBorderRainbow = true, borderEnabled = false }

local Settings = {
    stamina = false, food = false, combatBlock = false, ghost = false,
    noRagdoll = false, noFallDamage = false, antiPrisonPull = false,
    autoMoney = false, infiniteAmmo = false, rapidFire = false,
    farmer = false, taxi = false, bus = false, autoMission = false,
    autoHack = false, golf = false, autoCuff = false,
}

local tbl10 = {
    missionInterval = 2, priorityHighReward = false,
    taxiSafe = false, taxiDelayMode = "随机时间", taxiOrigin = nil,
}

local tbl11 = {
    auraEnabled = false, auraRange = 50, auraDamage = 5, auraInterval = 0.05,
    auraOnlyPolice = false, auraOnlyCivilian = false, auraCombatCheck = false,
    bulletEnabled = false, bulletFov = 360, bulletDistance = 300,
    bulletPart = "Head", bulletShowFov = true, bulletColor = "红色",
    bulletCombatCheck = false, bulletOnlyPolice = false, bulletOnlyCivilian = false,
}

local tbl12 = {
    enabled = false, prediction = false, teamCheck = false, wallCheck = false,
    showFov = false, showCrosshair = false, showTracer = false, friendCheck = false,
    onlyPolice = false, onlyCivilian = false, combatCheck = false,
    fov = 50, smoothness = 1, targetMode = "准心最近", targetPart = "头",
    color = "红色", fovThickness = 2,
}

local tbl13 = {
    enabled = false, range = 150, interval = 0.05, bodyPart = "Head",
    jobCheck = false, wallCheck = false, aliveCheck = false,
    combatCheck = false, policeLock = false, civilianLock = false, beam = false,
}

local tbl14 = {
    ["头部"] = "Head", ["躯干"] = "Torso", ["左臂"] = "LeftArm",
    ["右臂"] = "RightArm", ["左腿"] = "LeftLeg", ["右腿"] = "RightLeg",
}

local tbl15 = {
    active = false, size = 10, transparency = 0.7, teamCheck = false,
    color = "红色", material = "Neon", rainbow = false,
    checkCorpses = false, outline = false, collision = false,
    glow = false, pulse = false, affectNPC = false,
}

local tbl16 = {
    enabled = false, name = true, distance = true, health = true,
    highlight = true, tracer = false, tracerOrigin = "屏幕底部",
    showFugitive = true,
    selectedTeams = {
        Chef = true, Civilian = true, Delivery = true, Farmer = true,
        Fire = true, Police = true, Medical = true, Prisoner = true,
        ["Road Service"] = true, Transit = true,
    },
    trackers = {},
}

local tbl17 = {
    Chef = "厨师", Civilian = "平民", Delivery = "配送员", Farmer = "农民",
    Fire = "消防员", Police = "警察", Medical = "医护人员",
    Prisoner = "囚犯", ["Road Service"] = "道路服务", Transit = "交通",
}

local tbl21 = {
    ["红色"] = Color3.fromRGB(255, 0, 0), ["黄色"] = Color3.fromRGB(255, 255, 0),
    ["绿色"] = Color3.fromRGB(0, 255, 0), ["蓝色"] = Color3.fromRGB(0, 150, 255),
    ["紫色"] = Color3.fromRGB(150, 0, 255), ["白色"] = Color3.fromRGB(255, 255, 255),
    ["黑色"] = Color3.fromRGB(0, 0, 0), ["青色"] = Color3.fromRGB(0, 255, 255),
    ["橙色"] = Color3.fromRGB(255, 165, 0), ["粉色"] = Color3.fromRGB(255, 105, 180),
}

local tbl22 = {
    "https://raw.githubusercontent.com/PYHub/assets/main/bg.jpg",
    "https://raw.githubusercontent.com/PYHub/assets/main/bg.jpg",
    "https://raw.githubusercontent.com/PYHub/assets/main/bg.jpg",
    "https://raw.githubusercontent.com/PYHub/assets/main/bg.jpg",
    "https://raw.githubusercontent.com/PYHub/assets/main/bg.jpg",
}

local tbl28 = {
    Chef = Color3.fromRGB(255, 200, 0), Civilian = Color3.fromRGB(100, 200, 255),
    Delivery = Color3.fromRGB(255, 150, 50), Farmer = Color3.fromRGB(50, 200, 50),
    Fire = Color3.fromRGB(255, 50, 50), Police = Color3.fromRGB(50, 100, 255),
    Medical = Color3.fromRGB(255, 50, 255), Prisoner = Color3.fromRGB(255, 150, 150),
    ["Road Service"] = Color3.fromRGB(255, 255, 100), Transit = Color3.fromRGB(100, 255, 255),
}

local MovementSettings = {
    walkEnabled = false, walkSpeed = 200,
    jumpEnabled = false, jumpPower = 50, jumpMultiplier = 1, infiniteJump = false,
    flyEnabled = false, flySpeed = 30, flyMode = "传送", noclip = false,
}

local PoliceSettings = { range = 200, delay = 0.5, combatCheck = false, teleport = false }

-- 框架模块（可能不存在）
local Character, Core, module
pcall(function()
    local framework = localPlayer3:WaitForChild("PlayerScripts", 15):WaitForChild("Framework", 15)
    Character = require(framework:WaitForChild("Character", 15))
    Core = require(framework:WaitForChild("Core", 15))
    local inventory = framework.Character:FindFirstChild("Inventory")
    if inventory then module = require(inventory) end
end)

local remote = ReplicatedStorage:WaitForChild("Remote", 30)
local playerEvent = remote and remote:WaitForChild("PlayerEvent", 30)
local playerFunc = remote and remote:WaitForChild("PlayerFunc", 30)

-- ============ 5. 辅助函数 ============
local fn38 = function(arg11)
    local n11 = arg11 or 5
    return Color3.fromHSV(tick() % n11 / n11, 1, 1)
end

local fn39 = function(arg11)
    if arg11 == "彩虹色" then return fn38(5) end
    return tbl21[arg11] or Color3.fromRGB(255, 0, 0)
end

local fn40 = function(arg11)
    arg11 = arg11 or localPlayer3
    local seen, list = {}, {}
    local function add(model)
        if model and typeof(model) == "Instance" and model:IsA("Model") and not seen[model] then
            seen[model] = true
            table.insert(list, model)
        end
    end
    pcall(function() add(arg11.Character) end)
    pcall(function()
        local cf = workspace:FindFirstChild("Characters")
        if cf then add(cf:FindFirstChild(arg11.Name)) end
    end)
    for _, character in ipairs(list) do
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("Humanoid", true)
        local hrp = character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("UpperTorso")
            or (humanoid and humanoid.RootPart)
        if not hrp then hrp = character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart") end
        if hrp then return character, humanoid, hrp end
    end
end

local fn42 = function()
    if not tbl8.randomBg or #tbl22 == 0 then return "" end
    return tbl22[math.random(1, #tbl22)]
end

local fn43 = function(color, isRainbow)
    local main = v27 and v27.UIElements and v27.UIElements.Main
    if not main then return end
    local mainBorder = main:FindFirstChild("MainBorder")
    if not mainBorder then return end
    local borderGradient = mainBorder:FindFirstChild("BorderGradient")
    if not borderGradient then return end
    mainBorder.Enabled = tbl8.borderEnabled

    if connection2 then connection2:Disconnect(); connection2 = nil end

    if isRainbow then
        borderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
            ColorSequenceKeypoint.new(0.16, Color3.fromHex("FFA500")),
            ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
            ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
            ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("EE82EE")),
        })
        connection2 = RunService.Heartbeat:Connect(function()
            if borderGradient.Parent then
                borderGradient.Rotation = (borderGradient.Rotation + 1.5) % 360
            end
        end)
        tbl8.isBorderRainbow = true
        tbl8.borderColor = nil
    else
        color = color or Color3.new(1, 1, 1)
        mainBorder.Color = color
        borderGradient.Color = ColorSequence.new(color)
        borderGradient.Rotation = 0
        tbl8.isBorderRainbow = false
        tbl8.borderColor = nil
    end
end

-- 角色判定
local fn62 = function(arg11)
    local _, v33 = fn40(arg11)
    return v33 ~= nil and v33.Health > 0
end

local fn63 = function(arg11)
    return arg11 and arg11.Team and arg11.Team.Name or "Civilian"
end

local fn70 = function(arg11)
    if not arg11 or not arg11.Parent then return end
    local parent = arg11.Parent
    if parent:IsA("BasePart") then return parent.Position end
    if parent:IsA("Attachment") then return parent.WorldPosition end
    if parent:IsA("Model") then
        local primaryPart = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
        if primaryPart then return primaryPart.Position end
    end
end

local fn71 = function(arg11)
    if not arg11 then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(arg11, 0)
        else
            arg11.HoldDuration = 0
            arg11:InputHoldBegin()
            task.wait(0.1)
            arg11:InputHoldEnd()
        end
    end)
end

local fn72 = function(arg11)
    local v32, v33, v34 = fn40(localPlayer3)
    if not v32 or not v34 or not arg11 then return end
    local cframe = CFrame.new(arg11 + Vector3.new(0, 3, 0))
    v32:PivotTo(cframe)
    pcall(function()
        if playerEvent then
            local n11 = ((v32:GetAttribute("CharPivotToId") or 0) + 1) % 100
            v32:SetAttribute("CharPivotToId", n11)
            playerEvent:FireServer("charPivotTo", cframe, v32, n11)
        end
    end)
end

local fn84 = function(arg11, arg12, arg13)
    if not arg11 or arg11 == localPlayer3 then return false end
    if arg12 then return arg11.Team and arg11.Team.Name == "Police" end
    if arg13 then return arg11.Team and arg11.Team.Name == "Civilian" end
    return true
end

local fn85 = function(arg11, arg12)
    if not arg12 then return true end
    return arg11:GetAttribute("CombatMode") == true or arg11:GetAttribute("Pursuit") == true
end

local fn92 = function(arg11)
    local isCivilian = arg11.Team and arg11.Team.Name == "Civilian"
    if isCivilian then
        return arg11:GetAttribute("CombatMode") or arg11:GetAttribute("Pursuit")
    end
    return isCivilian
end

local tbl26 = {
    ["头"] = { "Head" },
    ["胸"] = { "UpperTorso", "Torso" },
    ["左手"] = { "LeftHand", "Left Arm" },
    ["右手"] = { "RightHand", "Right Arm" },
    ["左腿"] = { "LeftFoot", "Left Leg" },
    ["右腿"] = { "RightFoot", "Right Leg" },
}

local fn87 = function(arg11)
    local tbl29 = tbl26[tbl12.targetPart] or { "Head" }
    for _, v33 in ipairs(tbl29) do
        local v34 = arg11:FindFirstChild(v33)
        if v34 then return v34 end
    end
    return arg11:FindFirstChild("HumanoidRootPart")
end

local fn96 = function(arg11)
    if not arg11 then return false end
    local state = arg11:GetState()
    return state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running
        or state == Enum.HumanoidStateType.RunningNoPhysics
end

-- ============ 6. 功能实现 ============
-- 6.1 快速射击
local function rapidFireTick()
    if not Settings.rapidFire or not getgc then return end
    for _, v32 in pairs(getgc(true)) do
        if type(v32) == "table" then
            if rawget(v32, "SHOOT_MODE") ~= nil then rawset(v32, "SHOOT_MODE", 2) end
            if rawget(v32, "RPM") ~= nil then rawset(v32, "RPM", math.huge) end
        end
    end
end

-- 6.2 主循环：体力/饥饿/弹药/快速射击
RunService.Heartbeat:Connect(function()
    if Core then
        if Settings.stamina then pcall(function() Core.stamina = 100 end) end
        if Settings.food then pcall(function() Core.food = 100 end) end
        if Settings.rapidFire then pcall(rapidFireTick) end
    end
    if Settings.infiniteAmmo then
        local chars = workspace:FindFirstChild("Characters")
        local me = chars and chars:FindFirstChild(localPlayer3.Name)
        if me then
            for _, child in ipairs(me:GetChildren()) do
                local config = child:FindFirstChild("Config")
                if config then
                    local ammo = config:FindFirstChild("Ammo")
                    local totalAmmo = config:FindFirstChild("TotalAmmo")
                    if ammo then ammo.Value = math.huge end
                    if totalAmmo then totalAmmo.Value = math.huge end
                end
            end
        end
    end
end)

-- 6.3 战斗拦截
local v30
local function fn45(combatBlock)
    Settings.combatBlock = combatBlock
    if combatBlock and not v30 and hookmetamethod and newcclosure then
        v30 = hookmetamethod(game, "__namecall", newcclosure(function(arg11, ...)
            local v32 = table.pack(...)
            local tbl29 = { ... }
            local v33 = getnamecallmethod()
            if Settings.combatBlock and v33 == "FireServer" and tbl29[1] == "combatMode" then
                return nil
            end
            return v30(arg11, table.unpack(v32, 1, v32.n))
        end))
    end
end

-- 6.4 隐身
local tbl23 = {}
local connection3, screenGui, connection4
local udim2 = UDim2.new(0, 100, 0.5, -25)

local fn68 = function(arg11, arg12)
    if not arg11 then return end
    pcall(function()
        arg11:SetAttribute("Invisible", arg12 or nil)
        for _, descendant in ipairs(arg11:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
                descendant.LocalTransparencyModifier = arg12 and 0.55 or 0
                descendant.Material = arg12 and Enum.Material.ForceField or Enum.Material.SmoothPlastic
            elseif descendant:IsA("Decal") and descendant.Name == "face" then
                descendant.Transparency = arg12 and 0.55 or 0
            end
        end
    end)
end

local fn69 = function()
    if not textButton then return end
    textButton.Text = Settings.ghost and "隐身: 开" or "隐身: 关"
    textButton.TextColor3 = Settings.ghost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

local fn46 = function(ghost)
    Settings.ghost = ghost
    local character = localPlayer3.Character
    if not character then return end
    if ghost then
        pcall(function()
            local stuff = ReplicatedStorage:FindFirstChild("Stuff")
            local locations = stuff and stuff:FindFirstChild("Locations")
            locations = locations and locations:GetChildren()[1] or nil
            if playerFunc then playerFunc:InvokeServer("hideCharacterLocation", locations) end
        end)
        if module and module.canEquipSlot then
            pcall(function() module.canEquipSlot(true) end)
        end
        if Character and Character.lockHumanoidState then
            pcall(function() Character.lockHumanoidState("ghostMode", nil) end)
        end
        pcall(function()
            GuiService.TouchControlsEnabled = true
            ContextActionService:UnbindAction("LoadingGuiNoResetOnDeath")
            ContextActionService:UnbindAction("DisableCameraMovementNoResetOnDeath")
        end)
        fn68(character, true)
        if connection3 then connection3:Disconnect() end
        connection3 = RunService.RenderStepped:Connect(function()
            if Settings.ghost and localPlayer3.Character then
                -- 保持隐身状态
            end
        end)
    else
        if connection3 then connection3:Disconnect(); connection3 = nil end
        pcall(function()
            if playerFunc then playerFunc:InvokeServer("hideCharacterLocation", false) end
        end)
        fn68(character, false)
    end
end

local fn47 = function()
    if connection4 then connection4:Disconnect(); connection4 = nil end
    if screenGui then screenGui:Destroy(); screenGui = nil; textButton = nil end
end

local fn48 = function()
    if not flag10 then return end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GhostQuickSwitch"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = v29
    textButton = Instance.new("TextButton")
    textButton.Size = UDim2.new(0, 80, 0, 35)
    textButton.Position = udim2
    textButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    textButton.BackgroundTransparency = 0.4
    textButton.BorderSizePixel = 0
    textButton.Font = Enum.Font.GothamSemibold
    textButton.TextSize = 12
    textButton.Parent = screenGui
    textButton.Active = not flag9
    textButton.Draggable = not flag9
    local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0, 8); uiCorner.Parent = textButton
    local uiStroke = Instance.new("UIStroke"); uiStroke.Name = "RainbowStroke"; uiStroke.Thickness = 1.5; uiStroke.Parent = textButton
    connection4 = RunService.RenderStepped:Connect(function()
        if uiStroke.Parent then uiStroke.Color = fn38(5) end
    end)
    textButton.MouseButton1Click:Connect(function() end)
    textButton:GetPropertyChangedSignal("Position"):Connect(function()
        if not flag9 then udim2 = textButton.Position end
    end)
    fn69()
end

-- 6.5 防布娃娃
pcall(function()
    local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)
    local activate = Ragdoll.activate
    local activateServer = Ragdoll.activateServer
    Ragdoll.activate = function(arg11, arg12, arg13, ...)
        if Settings.noRagdoll and arg12 then return end
        local v33 = table.pack(...)
        v33.n = 4 + v33.n - 1
        table.move(v33, 1, v33.n, 4, v33)
        v33[1] = arg11; v33[2] = arg12; v33[3] = arg13
        return activate(table.unpack(v33, 1, v33.n))
    end
    if activateServer then
        Ragdoll.activateServer = function(arg11, arg12, arg13, ...)
            if Settings.noRagdoll and arg12 then return end
            local v33 = table.pack(...)
            v33.n = 4 + v33.n - 1
            table.move(v33, 1, v33.n, 4, v33)
            v33[1] = arg11; v33[2] = arg12; v33[3] = arg13
            return activateServer(table.unpack(v33, 1, v33.n))
        end
    end
end)

-- 6.6 防摔伤（namecall 拦截）
pcall(function()
    local rawmt = getrawmetatable(game)
    local namecall = rawmt.__namecall
    setreadonly(rawmt, false)
    rawmt.__namecall = newcclosure(function(arg11, ...)
        local v33 = table.pack(...)
        local tbl29 = { ... }
        local v34 = getnamecallmethod()
        if Settings.noFallDamage and v34 == "FireServer" and tostring(arg11) == "PlayerEvent" and tbl29[1] == "takeDamage" then
            return nil
        end
        return namecall(arg11, table.unpack(v33, 1, v33.n))
    end)
    setreadonly(rawmt, true)
end)

-- 6.7 防越狱拉回
local charPivotTo, notifyFunc
local function fn49(antiPrisonPull)
    Settings.antiPrisonPull = antiPrisonPull
    pcall(function()
        local Algorithms = require(ReplicatedStorage.Modules.Algorithms)
        if antiPrisonPull and not charPivotTo then
            charPivotTo = Algorithms.charPivotTo
            Algorithms.charPivotTo = function() return nil end
        elseif not antiPrisonPull and charPivotTo then
            Algorithms.charPivotTo = charPivotTo
            charPivotTo = nil
        end
    end)
    pcall(function()
        if not Core then return end
        if antiPrisonPull and not notifyFunc then
            notifyFunc = Core.notify
            Core.notify = function(arg11)
                if arg11 and arg11.message and string.find(arg11.message, "You can't leave prison yet") then
                    return nil
                end
                return notifyFunc(arg11)
            end
        elseif not antiPrisonPull and notifyFunc then
            Core.notify = notifyFunc
            notifyFunc = nil
        end
    end)
end

-- 6.8 自动捡钱
task.spawn(function()
    while true do
        if Settings.autoMoney then
            local v32, v33, v34 = fn40(localPlayer3)
            if v34 then
                local nearest, nearestPrompt
                for _, descendant in ipairs(workspace:GetDescendants()) do
                    local isPrompt = descendant:IsA("ProximityPrompt")
                    local match
                    if isPrompt then
                        local pn = descendant.Name
                        local at = string.lower(tostring(descendant.ActionText or ""))
                        local ot = string.lower(tostring(descendant.ObjectText or ""))
                        match = pn == "CashDrop" or pn == "GetItem" or pn == "Money"
                            or at:find("pick", 1, true) or at:find("cash", 1, true)
                            or at:find("collect", 1, true) or at:find("grab", 1, true)
                            or ot:find("cash", 1, true) or ot:find("money", 1, true)
                    end
                    if match then
                        local pos = fn70(descendant)
                        if pos then
                            local dist = (v34.Position - pos).Magnitude
                            if not nearest or dist < nearest then
                                nearest = dist; nearestPrompt = descendant
                            end
                        end
                    end
                end
                if nearestPrompt and nearest and nearest < 120 then
                    if nearest > 8 then
                        fn72(fn70(nearestPrompt))
                        task.wait(0.3)
                    end
                    fn71(nearestPrompt)
                end
            end
        end
        task.wait(0.3)
    end
end)

-- 6.9 自动任务
local function getTeamJobs()
    if not getgc then return end
    for _, v32 in pairs(getgc(true)) do
        if type(v32) == "table" and rawget(v32, "teamJobs") then
            return v32.teamJobs
        end
    end
end

local function isOnMission()
    if localPlayer3:GetAttribute("Mission") then return true end
    local jobs = getTeamJobs()
    if jobs then
        for _, v33 in pairs(jobs) do
            if v33.joined then return true end
        end
    end
    return false
end

local function pickBestJob()
    local jobs = getTeamJobs()
    if not jobs then return end
    local best, bestVal = nil, -math.huge
    for k2, v34 in pairs(jobs) do
        if not v34.joined then
            if not tbl10.priorityHighReward then return k2 end
            local score = (v34.profitability or 1) * 1000000 + (v34.reward or 0)
            if bestVal < score then bestVal = score; best = k2 end
        end
    end
    return best
end

task.spawn(function()
    while true do
        if Settings.autoMission and playerFunc and not isOnMission() then
            local job = pickBestJob()
            if job then
                pcall(function()
                    playerFunc:InvokeServer("talkToMission", tostring(job) .. "join")
                end)
            end
        end
        task.wait(tbl10.missionInterval)
    end
end)

-- 6.10 农民刷钱
task.spawn(function()
    while true do
        if Settings.farmer then
            local v32 = localPlayer3.Character and localPlayer3.Character:FindFirstChildOfClass("Tool")
            if v32 then task.wait(0.4) end
            local v33, v34, v35 = fn40(localPlayer3)
            if v35 then
                local nearest, nearestPrompt
                for _, descendant in ipairs(workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") and descendant.ActionText == "Pick Up" then
                        local pos = fn70(descendant)
                        if pos then
                            local dist = (v35.Position - pos).Magnitude
                            if not nearest or dist < nearest then nearest = dist; nearestPrompt = descendant end
                        end
                    end
                end
                if nearestPrompt then
                    local pp = fn70(nearestPrompt)
                    if pp then
                        local pd = (v35.Position - pp).Magnitude
                        if pd > 8 then fn72(pp); task.wait(0.3) else fn71(nearestPrompt) end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- 6.11 出租车刷钱
task.spawn(function()
    local lastPos
    while true do
        if Settings.taxi then
            local gameplay = workspace:FindFirstChild("Gameplay")
            gameplay = gameplay and gameplay:FindFirstChild("Entities")
            gameplay = gameplay and gameplay:FindFirstChild("ClientContent")
            if gameplay and gameplay:IsA("Model") then
                local primaryPart = gameplay.PrimaryPart or gameplay:FindFirstChildWhichIsA("BasePart")
                local v33, v34, v35 = fn40(localPlayer3)
                if primaryPart and v35 then
                    local position = primaryPart.Position
                    if lastPos == nil or (position - lastPos).Magnitude > 5 then
                        if tbl10.taxiSafe and tbl10.taxiOrigin then
                            v35.CFrame = CFrame.new(tbl10.taxiOrigin)
                            local magnitude = (tbl10.taxiOrigin - position).Magnitude
                            local n11
                            if tbl10.taxiDelayMode == "距离测算" then
                                n11 = math.clamp(15 + (math.clamp(magnitude, 2000, 6000) - 2000) / 4000 * 30 + math.random() * 2 - 1, 15, 45)
                            else
                                n11 = magnitude > 2000 and math.random(15, 45) or 15
                            end
                            task.wait(n11)
                        end
                        v35.CFrame = CFrame.new(position)
                        lastPos = position
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 6.12 公交车刷钱
local function getBusArea()
    local gameplay = workspace:FindFirstChild("Gameplay")
    gameplay = gameplay and gameplay:FindFirstChild("Entities")
    gameplay = gameplay and gameplay:FindFirstChild("ClientContent")
    gameplay = gameplay and gameplay:GetChildren()[1]
    return gameplay and gameplay:FindFirstChild("Area")
end

task.spawn(function()
    while true do
        if Settings.bus then
            local v32 = getBusArea()
            local v33, v34, v35 = fn40(localPlayer3)
            if v32 and v34 and v35 then
                local seatPart = v34.SeatPart
                if seatPart then
                    local cFrame = v35.CFrame
                    seatPart.CFrame = v32.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, 4.7123889803846897, 0) * cFrame:ToObjectSpace(seatPart.CFrame)
                    seatPart.AssemblyLinearVelocity = Vector3.zero
                    seatPart.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.1)
                    v34.Sit = false
                else
                    v35.CFrame = v32.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, 4.7123889803846897, 0)
                end
                task.wait(5)
            end
        end
        task.wait(1)
    end
end)

-- 6.13 自动黑客
local hackBackup = {}
local function fn50(autoHack)
    Settings.autoHack = autoHack
    pcall(function()
        local framework = localPlayer3.PlayerScripts:FindFirstChild("Framework")
        framework = framework and require(framework:FindFirstChild("Character"))
        local GameRules = require(ReplicatedStorage.Modules.GameRules)
        if GameRules then
            GameRules.disableHacking = autoHack
            GameRules.disableMinigames = autoHack
        end
        if framework then
            if not hackBackup.hackingMinigame then hackBackup.hackingMinigame = framework.hackingMinigame end
            if not hackBackup.startMinigame then hackBackup.startMinigame = framework.startMinigame end
            if autoHack then
                framework.hackingMinigame = function() return true end
                framework.startMinigame = function() return true end
            else
                if hackBackup.hackingMinigame then framework.hackingMinigame = hackBackup.hackingMinigame end
                if hackBackup.startMinigame then framework.startMinigame = hackBackup.startMinigame end
            end
        end
    end)
end

-- 6.14 高尔夫刷钱
task.spawn(function()
    local function findPath(names)
        local cur = workspace
        for _, n in ipairs(names) do
            cur = cur and cur:FindFirstChild(n)
            if not cur then return end
        end
        return cur
    end
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
                local ball = findPath({ "Gameplay", "Entities", "Content", localPlayer3.Name })
                local flag = findPath({ "Gameplay", "Entities", "Content", "_Flag", "FlagPole", "Part" })
                if ball and flag and ball:IsA("BasePart") then ball.Position = flag.Position end
            end)
        end
        task.wait(Settings.golf and 5 or 1)
    end
end)

-- 6.15 杀戮光环
local n10 = 0
RunService.Heartbeat:Connect(function()
    if not tbl11.auraEnabled or not playerEvent then return end
    local now = tick()
    if now - n10 < tbl11.auraInterval then return end
    local v32, v33, v34 = fn40(localPlayer3)
    if not v34 then return end
    local target, targetDist
    for _, player in ipairs(Players:GetPlayers()) do
        if fn84(player, tbl11.auraOnlyPolice, tbl11.auraOnlyCivilian) and fn62(player) and fn85(player, tbl11.auraCombatCheck) then
            local char = player.Character
            local part = char and fn87(char)
            if part then
                local dist = (part.Position - v34.Position).Magnitude
                if dist <= tbl11.auraRange and (not targetDist or dist < targetDist) then
                    target = player; targetDist = dist
                end
            end
        end
    end
    if target then
        local part = target.Character and fn87(target.Character)
        local position = v34.Position
        if not part then return end
        pcall(function()
            playerEvent:FireServer("damage", {
                bodyParts = { { "Head", 1 } },
                shotCode = { position, (part.Position - position).Unit },
                pos = part.Position,
                target = target,
                damageFactor = tbl11.auraDamage,
                bulletProofTool = false,
            })
        end)
        n10 = now
    end
end)

-- 6.16 子弹追踪
local circle = Drawing.new("Circle")
circle.Filled = false; circle.NumSides = 64; circle.Visible = false

local function fn86()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestFov = tbl11.bulletFov
    local bestPos
    for _, player in ipairs(Players:GetPlayers()) do
        if fn84(player, tbl11.bulletOnlyPolice, tbl11.bulletOnlyCivilian) and fn62(player) and fn85(player, tbl11.bulletCombatCheck) then
            local character = player.Character
            if character then
                character = character:FindFirstChild(tbl11.bulletPart) or character:FindFirstChild("HumanoidRootPart")
            end
            if character and (character.Position - cam.CFrame.Position).Magnitude <= tbl11.bulletDistance then
                local sp, onScreen = cam:WorldToScreenPoint(character.Position)
                if onScreen and sp.Z > 0 then
                    local mag = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if mag < bestFov then bestPos = character.Position; bestFov = mag end
                end
            end
        end
    end
    return bestPos
end

pcall(function()
    local raycast = workspace.Raycast
    hookfunction(workspace.Raycast, function(arg11, arg12, arg13, arg14)
        if tbl11.bulletEnabled and arg12 and arg13 then
            local _, _, v34 = fn40(localPlayer3)
            if v34 and (arg12 - v34.Position).Magnitude < 15 then
                local v35 = fn86()
                if v35 then arg13 = (v35 - arg12).Unit * arg13.Magnitude end
            end
        end
        return raycast(arg11, arg12, arg13, arg14)
    end)
end)

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    circle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    circle.Radius = tbl11.bulletFov
    circle.Thickness = 2
    circle.Color = fn38(5)
    circle.Visible = tbl11.bulletEnabled and tbl11.bulletShowFov
end)

-- 6.17 自瞄
local circle2 = Drawing.new("Circle"); circle2.Filled = false; circle2.NumSides = 64
local line = Drawing.new("Line")
local tbl25 = {
    Top = Drawing.new("Line"), Bottom = Drawing.new("Line"),
    Left = Drawing.new("Line"), Right = Drawing.new("Line"), Center = Drawing.new("Line"),
}
for _, v32 in pairs(tbl25) do v32.Thickness = 2; v32.Visible = false end

local function fn88(arg11)
    if not tbl12.wallCheck then return true end
    local cam = workspace.CurrentCamera
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = { localPlayer3.Character, cam }
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    local hit = workspace:Raycast(cam.CFrame.Position, arg11.Position - cam.CFrame.Position, rp)
    return not hit or hit.Instance:IsDescendantOf(arg11.Parent)
end

local function fn89()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestVal, bestTarget
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer3 and fn62(player) and fn84(player, tbl12.onlyPolice, tbl12.onlyCivilian) and fn85(player, tbl12.combatCheck) then
            if not (tbl12.teamCheck and localPlayer3.Team and player.Team == localPlayer3.Team) then
                local skip = false
                if tbl12.friendCheck then
                    local ok, res = pcall(function() return localPlayer3:IsFriendsWith(player.UserId) end)
                    if ok and res then skip = true end
                end
                if not skip then
                    local character = player.Character
                    if character then
                        local part = fn87(character)
                        local hum = character:FindFirstChildOfClass("Humanoid")
                        local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                        if part and hum and hrp and hum.Health > 0 and fn88(part) then
                            local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local mag = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if mag <= tbl12.fov then
                                    if tbl12.targetMode == "距离最近" then
                                        local _, _, v40 = fn40(localPlayer3)
                                        mag = v40 and (v40.Position - hrp.Position).Magnitude or math.huge
                                    elseif tbl12.targetMode == "血量最低" then
                                        mag = hum.Health
                                    end
                                    if not bestVal or mag < bestVal then
                                        bestTarget = { player = player, part = part, screen = sp }
                                        bestVal = mag
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

RunService.RenderStepped:Connect(function(deltaTime)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local color = fn39(tbl12.color)
    circle2.Position = center
    circle2.Radius = tbl12.fov
    circle2.Thickness = tbl12.fovThickness
    circle2.Color = color
    circle2.Visible = tbl12.enabled and tbl12.showFov

    tbl25.Top.From = Vector2.new(center.X, center.Y - 5); tbl25.Top.To = Vector2.new(center.X, center.Y - 20)
    tbl25.Bottom.From = Vector2.new(center.X, center.Y + 5); tbl25.Bottom.To = Vector2.new(center.X, center.Y + 20)
    tbl25.Left.From = Vector2.new(center.X - 5, center.Y); tbl25.Left.To = Vector2.new(center.X - 20, center.Y)
    tbl25.Right.From = Vector2.new(center.X + 5, center.Y); tbl25.Right.To = Vector2.new(center.X + 20, center.Y)
    tbl25.Center.From = Vector2.new(center.X - 2, center.Y); tbl25.Center.To = Vector2.new(center.X + 2, center.Y)
    for _, v33 in pairs(tbl25) do v33.Color = color; v33.Visible = tbl12.showCrosshair end

    line.Visible = false
    if tbl12.enabled then
        local target = fn89()
        if target then
            if tbl12.showTracer then
                line.From = center
                line.To = Vector2.new(target.screen.X, target.screen.Y)
                line.Color = color
                line.Thickness = 2
                line.Transparency = 0.5
                line.Visible = true
            end
            local position = target.part.Position
            if tbl12.prediction then
                position = position + target.part.AssemblyLinearVelocity * deltaTime * 1.5
            end
            local cframe = CFrame.new(cam.CFrame.Position, position)
            cam.CFrame = tbl12.smoothness >= 1 and cframe or cam.CFrame:Lerp(cframe, tbl12.smoothness)
        end
    end
end)

-- 6.18 Ragebot
task.spawn(function()
    while true do
        if tbl13.enabled and playerEvent then
            local v32, v33, v34 = fn40(localPlayer3)
            if v34 then
                local position = v34.Position
                local myJob = fn63(localPlayer3)
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= localPlayer3 and fn84(player, tbl13.policeLock, tbl13.civilianLock) and fn85(player, tbl13.combatCheck) then
                        local char, hum, _ = fn40(player)
                        local part = char and (char:FindFirstChild(tbl13.bodyPart) or fn87(char))
                        if char and hum and part and hum.Health > 0 then
                            if not (tbl13.jobCheck and fn63(player) == myJob) then
                                if (part.Position - position).Magnitude <= tbl13.range then
                                    if tbl13.wallCheck then
                                        local rp = RaycastParams.new()
                                        rp.FilterDescendantsInstances = { localPlayer3.Character, workspace.CurrentCamera }
                                        rp.FilterType = Enum.RaycastFilterType.Exclude
                                        local hit = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, part.Position - workspace.CurrentCamera.CFrame.Position, rp)
                                        if hit and not hit.Instance:IsDescendantOf(char) then continue end
                                    end
                                    pcall(function()
                                        playerEvent:FireServer("damage", {
                                            bodyParts = { { tbl13.bodyPart, 1 } },
                                            shotCode = { position, (part.Position - position).Unit },
                                            pos = part.Position,
                                            target = player,
                                            damageFactor = 1.5,
                                            bulletProofTool = false,
                                        })
                                    end)
                                    continue
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

-- 6.19 Hitbox
local tbl27 = {}
local function resetHitbox(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local saved = tbl27[hrp]
    if saved then
        hrp.Size = saved.Size; hrp.Transparency = saved.Transparency
        hrp.Material = saved.Material; hrp.CanCollide = saved.CanCollide; hrp.Color = saved.Color
    end
    local h = hrp:FindFirstChild("PY_HitboxHighlight"); if h then h:Destroy() end
    local l = hrp:FindFirstChild("PY_HitboxLight"); if l then l:Destroy() end
end

local function applyHitbox(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not tbl27[hrp] then
        tbl27[hrp] = { Size = hrp.Size, Transparency = hrp.Transparency, Material = hrp.Material, CanCollide = hrp.CanCollide, Color = hrp.Color }
    end
    if not tbl15.active then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if tbl15.checkCorpses and hum and hum.Health <= 0 then return end
    local size = tbl15.size
    if tbl15.pulse then size = size * (math.sin(tick() * 2) * 0.2 + 1) end
    hrp.Size = Vector3.new(size, size, size)
    hrp.Transparency = tbl15.transparency
    hrp.Material = Enum.Material[tbl15.material] or Enum.Material.Neon
    hrp.CanCollide = tbl15.collision
    hrp.Color = tbl15.rainbow and fn38(5) or fn39(tbl15.color)
    if tbl15.outline then
        local h = hrp:FindFirstChild("PY_HitboxHighlight") or Instance.new("Highlight")
        h.Name = "PY_HitboxHighlight"; h.FillTransparency = 1
        h.OutlineColor = hrp.Color; h.OutlineTransparency = tbl15.transparency
        h.Parent = hrp
    else
        local h = hrp:FindFirstChild("PY_HitboxHighlight"); if h then h:Destroy() end
    end
    if tbl15.glow then
        local l = hrp:FindFirstChild("PY_HitboxLight") or Instance.new("PointLight")
        l.Name = "PY_HitboxLight"; l.Brightness = 5; l.Range = 15; l.Color = hrp.Color; l.Parent = hrp
    else
        local l = hrp:FindFirstChild("PY_HitboxLight"); if l then l:Destroy() end
    end
end

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer3 and fn40(player) then
            if not (tbl15.teamCheck and localPlayer3.Team and player.Team == localPlayer3.Team) then
                applyHitbox(fn40(player))
            end
        end
    end
    if tbl15.affectNPC then
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(descendant) then
                applyHitbox(descendant)
            end
        end
    end
end)

-- 6.20 ESP
local fn93 = function(arg11)
    if not tbl16.enabled or arg11 == localPlayer3 then return false end
    if not fn40(arg11) then return false end
    if tbl16.showFugitive and fn92(arg11) then return true end
    local selected, total = 0, 0
    for _, sel in pairs(tbl16.selectedTeams) do
        total = total + 1
        if sel then selected = selected + 1 end
    end
    if selected == 0 or selected >= total then return true end
    local name = arg11.Team and arg11.Team.Name
    if not name then return true end
    if tbl16.selectedTeams[name] == true then return true end
    for teamName, teamLabel in pairs(tbl17) do
        if (teamLabel == name or teamName == name) and tbl16.selectedTeams[teamName] then return true end
    end
    return false
end

local function fn52(player)
    local v32 = tbl16.trackers[player]
    if not v32 then return end
    for _, v33 in pairs(v32) do
        pcall(function()
            if typeof(v33) == "RBXScriptConnection" then v33:Disconnect()
            elseif typeof(v33) == "Instance" then v33:Destroy()
            elseif type(v33) == "userdata" and v33.Remove then v33:Remove() end
        end)
    end
    tbl16.trackers[player] = nil
end

local function getEspHolder()
    local parent = v29 or localPlayer3:FindFirstChild("PlayerGui")
    v29 = parent
    if not parent then return end
    local holder = parent:FindFirstChild("PYHubESP")
    if holder then return holder end
    local ok, gui = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "PYHubESP"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
        sg.DisplayOrder = 999; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = parent
        return sg
    end)
    if ok then return gui end
    return parent
end

local function fn94(arg11)
    if tbl16.trackers[arg11] or not fn93(arg11) then return end
    local character, _, humanoidRootPart = fn40(arg11)
    if not character or not humanoidRootPart then return end
    local holder = getEspHolder()
    if not holder then return end

    local bill = Instance.new("BillboardGui")
    bill.Name = "PlayerESP_" .. arg11.Name
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(8, 0, 3, 0)
    bill.StudsOffset = Vector3.new(0, 3.5, 0)
    bill.MaxDistance = 10000
    bill.Adornee = humanoidRootPart
    bill.Parent = holder

    local frame = Instance.new("Frame"); frame.BackgroundTransparency = 1; frame.Size = UDim2.fromScale(1, 1); frame.Parent = bill
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.55, 0); textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold; textLabel.TextSize = 16; textLabel.TextStrokeTransparency = 0
    textLabel.Text = arg11.Name; textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    textLabel.Parent = frame
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.Size = UDim2.new(1, 0, 0.45, 0); textLabel2.Position = UDim2.new(0, 0, 0.55, 0)
    textLabel2.BackgroundTransparency = 1; textLabel2.Font = Enum.Font.Gotham
    textLabel2.TextSize = 14; textLabel2.TextStrokeTransparency = 0; textLabel2.TextColor3 = Color3.fromRGB(0, 255, 0)
    textLabel2.Parent = frame
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP_Highlight"; highlight.Adornee = character
    highlight.FillTransparency = 0.65; highlight.OutlineTransparency = 0
    pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
    highlight.Parent = character

    local line2
    pcall(function()
        if Drawing and Drawing.new then
            line2 = Drawing.new("Line"); line2.Thickness = 1; line2.Transparency = 0.5; line2.Visible = false
        end
    end)

    tbl16.trackers[arg11] = {
        bill = bill, highlight = highlight, tracer = line2,
        update = RunService.Heartbeat:Connect(function()
            local curChar, hum, curRoot = fn40(arg11)
            if not fn93(arg11) or not curChar or not curRoot then
                if line2 then line2.Visible = false end
                if bill.Parent then bill.Enabled = false end
                return
            end
            humanoidRootPart = curRoot
            bill.Adornee = humanoidRootPart
            bill.Enabled = true
            if highlight.Parent ~= curChar then highlight.Parent = curChar end
            highlight.Adornee = curChar
            local isFug = fn92(arg11)
            local name = arg11.Team and arg11.Team.Name
            local color = isFug and Color3.fromRGB(255, 0, 0) or tbl28[name] or Color3.fromRGB(0, 255, 0)
            textLabel.Text = "[" .. (isFug and "逃犯" or tbl17[name] or name or "未知") .. "] " .. arg11.Name
            textLabel.TextColor3 = color
            textLabel.Visible = tbl16.name
            highlight.FillColor = color; highlight.OutlineColor = color
            highlight.Enabled = tbl16.highlight
            local _, _, v38 = fn40(localPlayer3)
            local parts = {}
            if tbl16.distance and v38 then
                parts[#parts + 1] = string.format("%.1f", (v38.Position - humanoidRootPart.Position).Magnitude)
            end
            if tbl16.health and hum then parts[#parts + 1] = tostring(math.floor(hum.Health)) end
            textLabel2.Text = #parts > 0 and "[" .. table.concat(parts, "/") .. "]" or ""
            textLabel2.TextColor3 = color
            textLabel2.Visible = tbl16.distance or tbl16.health
            local cam = workspace.CurrentCamera
            if line2 then
                if tbl16.tracer and cam then
                    local sp, onScreen = cam:WorldToViewportPoint(humanoidRootPart.Position)
                    if onScreen then
                        local vp = cam.ViewportSize
                        if tbl16.tracerOrigin == "屏幕中心" then line2.From = Vector2.new(vp.X / 2, vp.Y / 2)
                        elseif tbl16.tracerOrigin == "屏幕顶部" then line2.From = Vector2.new(vp.X / 2, 0)
                        else line2.From = Vector2.new(vp.X / 2, vp.Y) end
                        line2.To = Vector2.new(sp.X, sp.Y); line2.Color = color; line2.Visible = true
                    else line2.Visible = false end
                else line2.Visible = false end
            end
        end),
    }
end

local function fn53()
    for k2 in pairs(tbl16.trackers) do
        if not fn93(k2) then fn52(k2) end
    end
    if tbl16.enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer3 and fn93(player) and not tbl16.trackers[player] then
                pcall(fn94, player)
            end
        end
    end
end

local function hookEspPlayer(player)
    if player == localPlayer3 then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.25)
        if tbl16.enabled then fn52(player); pcall(fn94, player) end
    end)
end
for _, player in ipairs(Players:GetPlayers()) do hookEspPlayer(player) end
Players.PlayerAdded:Connect(hookEspPlayer)
Players.PlayerRemoving:Connect(fn52)

local lastEspScan = 0
RunService.Heartbeat:Connect(function()
    if not tbl16.enabled then return end
    if tick() - lastEspScan < 0.2 then return end
    lastEspScan = tick()
    fn53()
end)

-- 6.21 自动铐
local cuffThread
local function fn54()
    if cuffThread then return end
    cuffThread = task.spawn(function()
        while Settings.autoCuff do
            local v32, v33, v34 = fn40(localPlayer3)
            if v34 and playerFunc then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= localPlayer3 and fn62(player) and fn85(player, PoliceSettings.combatCheck) then
                        local _, _, v37 = fn40(player)
                        if v37 and (v37.Position - v34.Position).Magnitude <= PoliceSettings.range then
                            pcall(function() playerFunc:InvokeServer("handcuff", player, false) end)
                        end
                    end
                end
                if PoliceSettings.teleport then
                    local best, bestPlayer
                    for _, player in ipairs(Players:GetPlayers()) do
                        local isCrim = player ~= localPlayer3 and player.Team and player.Team.Name == "Civilian"
                        if isCrim then isCrim = (player:GetAttribute("WantedLevel") or 0) > 0 end
                        if isCrim then
                            local _, _, v39 = fn40(player)
                            if v39 then
                                local mag = (v39.Position - v34.Position).Magnitude
                                if mag <= PoliceSettings.range and (not best or mag < best) then best = mag; bestPlayer = player end
                            end
                        end
                    end
                    if bestPlayer then
                        local _, _, v39 = fn40(bestPlayer)
                        if v39 then v34.CFrame = CFrame.new(v39.Position - v39.CFrame.LookVector * 3) end
                    end
                end
            end
            task.wait(PoliceSettings.delay)
        end
        cuffThread = nil
    end)
end

-- 6.22 移动：跳跃/飞行/穿墙
local FlyState = {
    walkConn = nil, jumpConn = nil, flyConn = nil,
    bodyVelocity = nil, bodyGyro = nil, noclipConn = nil, collisionCache = {},
}
local v31
local controls
pcall(function()
    controls = require(localPlayer3.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end)

local function fn55()
    if FlyState.jumpConn then FlyState.jumpConn:Disconnect(); FlyState.jumpConn = nil end
end

local function fn56()
    fn55()
    if not MovementSettings.jumpEnabled then return end
    FlyState.jumpConn = UserInputService.JumpRequest:Connect(function()
        if not MovementSettings.jumpEnabled then return end
        local v32, v33, v34 = fn40(localPlayer3)
        if not v33 or not v34 or v33.Health <= 0 then return end
        if not MovementSettings.infiniteJump and not fn96(v33) then return end
        v34.CFrame = v34.CFrame + Vector3.new(0, MovementSettings.jumpPower * MovementSettings.jumpMultiplier * 0.1, 0)
    end)
end

local function flyCleanup()
    if FlyState.flyConn then FlyState.flyConn:Disconnect(); FlyState.flyConn = nil end
    if FlyState.bodyVelocity then FlyState.bodyVelocity:Destroy(); FlyState.bodyVelocity = nil end
    if FlyState.bodyGyro then FlyState.bodyGyro:Destroy(); FlyState.bodyGyro = nil end
    local _, v33 = fn40(localPlayer3)
    if v33 then v33.PlatformStand = false; v33.AutoRotate = true end
end

local function flyStart()
    flyCleanup()
    local v32, v33, v34 = fn40(localPlayer3)
    if not v34 or not v33 then return end
    MovementSettings.flyEnabled = true
    if MovementSettings.flyMode == "物理" then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "PYPlayerFlyVelocity"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.zero; bv.Parent = v34
        FlyState.bodyVelocity = bv
        local bg = Instance.new("BodyGyro")
        bg.Name = "PYPlayerFlyGyro"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 90000; bg.Parent = v34
        FlyState.bodyGyro = bg
        v33.PlatformStand = true; v33.AutoRotate = false
        FlyState.flyConn = RunService.RenderStepped:Connect(function()
            if not MovementSettings.flyEnabled or MovementSettings.flyMode ~= "物理" then return end
            local _, v36, v37 = fn40(localPlayer3)
            local cam = workspace.CurrentCamera
            if not v37 or not v36 or not cam then return end
            if FlyState.bodyVelocity and FlyState.bodyGyro then
                local mv = controls and controls:GetMoveVector() or Vector3.zero
                local dir = cam.CFrame.LookVector * -mv.Z + cam.CFrame.RightVector * mv.X
                local up = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up = 1
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then up = -1 end
                FlyState.bodyVelocity.Velocity = (dir + Vector3.new(0, up, 0)) * MovementSettings.flySpeed
                FlyState.bodyGyro.CFrame = cam.CFrame
            end
        end)
    else
        v33.AutoRotate = false
        FlyState.flyConn = RunService.RenderStepped:Connect(function(deltaTime)
            if not MovementSettings.flyEnabled or MovementSettings.flyMode ~= "传送" then return end
            local _, v36, v37 = fn40(localPlayer3)
            local cam = workspace.CurrentCamera
            if not v37 or not v36 or not cam then return end
            local mv = controls and controls:GetMoveVector() or Vector3.zero
            local dir = cam.CFrame.LookVector * -mv.Z + cam.CFrame.RightVector * mv.X
            local up = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then up = -1 end
            v37.CFrame = v37.CFrame + (dir + Vector3.new(0, up, 0)) * MovementSettings.flySpeed * deltaTime
            v37.AssemblyLinearVelocity = Vector3.zero
            v37.AssemblyAngularVelocity = Vector3.zero
            v36:ChangeState(Enum.HumanoidStateType.Climbing)
        end)
    end
end

local function noclipStop()
    if FlyState.noclipConn then FlyState.noclipConn:Disconnect(); FlyState.noclipConn = nil end
    for k2, v32 in pairs(FlyState.collisionCache) do
        if k2 and k2.Parent then pcall(function() k2.CanCollide = v32 end) end
    end
    FlyState.collisionCache = {}
end

local function noclipStart()
    noclipStop()
    if not MovementSettings.noclip then return end
    FlyState.noclipConn = RunService.Stepped:Connect(function()
        if not MovementSettings.noclip then return end
        local char = localPlayer3.Character
        if not char then return end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                if FlyState.collisionCache[d] == nil then FlyState.collisionCache[d] = d.CanCollide end
                d.CanCollide = false
            end
        end
    end)
end

local function fn60()
    if FlyState.walkConn then FlyState.walkConn:Disconnect(); FlyState.walkConn = nil end
    if not MovementSettings.walkEnabled then return end
    FlyState.walkConn = RunService.Heartbeat:Connect(function()
        local _, v33 = fn40(localPlayer3)
        if v33 and MovementSettings.walkEnabled then v33.WalkSpeed = MovementSettings.walkSpeed end
    end)
end

localPlayer3.CharacterAdded:Connect(function()
    task.wait(0.5)
    FlyState.collisionCache = {}
    if MovementSettings.walkEnabled then fn60() end
    if MovementSettings.jumpEnabled then fn56() end
    if MovementSettings.noclip then noclipStart() end
    if MovementSettings.flyEnabled then
        local mode = MovementSettings.flyMode
        MovementSettings.flyEnabled = false
        task.wait(0.2)
        MovementSettings.flyMode = mode
        flyStart()
    end
end)

-- 6.23 限速绕过
local flag11 = false
pcall(function()
    local Algorithms = require(ReplicatedStorage.Modules.Algorithms)
    local getSpeedLimitAtPos = Algorithms.getSpeedLimitAtPos
    Algorithms.getSpeedLimitAtPos = function(...)
        if flag11 then return 9999 end
        return getSpeedLimitAtPos(...)
    end
end)

-- ============ 7. UI 构建 ============
local function buildUI()
    if v27 then pcall(function() v27:Destroy() end); v27 = nil end

    v27 = lib:CreateWindow({
        Title = "PY Hub/圣奥里<font color='#00FF00'>破解版</font>",
        Icon = "zap", IconTransparency = 0.5, IconThemed = true,
        Author = "Xi.Team", Folder = "PYHub",
        Size = UDim2.fromOffset(640, 460), Transparent = true, Theme = "Dark",
        User = { Enabled = false, Callback = function() end, Anonymous = false },
        SideBarWidth = 200, ScrollBarEnabled = true,
        Background = fn42(), BackgroundImageTransparency = 0.4,
    })

    flag8 = true

    local parent = v27.Parent
    if parent then
        local function changeFont(d)
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                if d.Font ~= Enum.Font.Code then d.Font = Enum.Font.PermanentMarker end
            end
        end
        for _, d in ipairs(parent:GetDescendants()) do changeFont(d) end
        parent.DescendantAdded:Connect(changeFont)
    end

    local timeTag = v27:Tag({ Title = "当前时间: 00:00:00", Icon = "clock", Color = Color3.fromHex("#FFFFFF"), Border = true })
    local lastTick = 0
    RunService.Heartbeat:Connect(function()
        if tick() - lastTick >= 0.1 then
            timeTag:SetTitle("当前时间: " .. os.date("!%H:%M:%S", os.time() + 28800))
            lastTick = tick()
        end
    end)

    local editOpenButton = v27.EditOpenButton
    if editOpenButton then
        pcall(function()
            editOpenButton(v27, {
                Title = "PYHub<font color='#00FF00'>1.0</font>", Icon = "crown",
                CornerRadius = UDim.new(1, 16), StrokeThickness = 1.5,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHex("FF1493")),
                    ColorSequenceKeypoint.new(0.3, Color3.fromHex("FF69B4")),
                    ColorSequenceKeypoint.new(0.6, Color3.fromHex("FFB6C1")),
                    ColorSequenceKeypoint.new(1, Color3.fromHex("FFC0CB")),
                }),
                Draggable = true,
            })
        end)
    end

    local main = v27.UIElements.Main
    if main then
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Name = "MainBorder"; uiStroke.Thickness = 3
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        uiStroke.LineJoinMode = Enum.LineJoinMode.Round
        uiStroke.Enabled = tbl8.borderEnabled; uiStroke.Parent = main
        local uiGradient = Instance.new("UIGradient")
        uiGradient.Name = "BorderGradient"; uiGradient.Parent = uiStroke
    end

    local tabNotice = v27:Tab({ Title = "公告", Icon = "message-circle", Locked = false })
    tabNotice:Paragraph({ Title = "破解版", Desc = "XI团队暴打所有联邦狗", Image = "message-circle", ImageSize = 32 })
    tabNotice:Paragraph({ Title = "开源人", Desc = "苏达", Image = "user", ImageSize = 32 })

    local tabHome = v27:Tab({ Title = "主页", Icon = "home", Locked = false })
    tabHome:Paragraph({ Title = "PY Hub", Desc = "圣奥里精简版", Image = "zap", ImageSize = 32 })
    tabHome:Paragraph({ Title = "玩家", Desc = "当前服务器ID: " .. game.PlaceId, Image = "users", ImageSize = 32 })

    local tabUI = v27:Tab({ Title = "UI设置", Icon = "settings", Locked = false })
    tabUI:Toggle({ Title = "自定义光标", Value = false, Callback = function(v) pcall(function() v27:ToggleCustomCursor(v) end) end })
    tabUI:Dropdown({ Title = "通知位置", Values = { "左", "右" }, Value = "右", Callback = function(v) pcall(function() lib:SetNotifySide(v == "左" and "Left" or "Right") end) end })
    tabUI:Dropdown({
        Title = "DPI缩放", Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" }, Value = "100%",
        Callback = function(v) local n = tonumber(v:gsub("%%", "")); if n then pcall(function() v27:SetDPIScale(n / 100) end) end end,
    })
    tabUI:Keybind({ Title = "菜单按键", Value = "RightShift", Callback = function(v) pcall(function() v27:SetToggleKey(Enum.KeyCode[v]) end) end })
    tabUI:Divider()
    tabUI:Toggle({ Title = "随机背景图", Value = tbl8.randomBg, Callback = function(v) tbl8.randomBg = v end })
    tabUI:Divider()
    tabUI:Toggle({
        Title = "启用边框颜色", Value = tbl8.borderEnabled,
        Callback = function(v)
            tbl8.borderEnabled = v
            local m = v27 and v27.UIElements and v27.UIElements.Main
            m = m and m:FindFirstChild("MainBorder")
            if m then m.Enabled = v end
        end,
    })
    tabUI:Dropdown({
        Title = "边框颜色",
        Values = { "旋转彩虹", "默认白色", "红色", "橙色", "黄色", "绿色", "青色", "蓝色", "紫色", "粉色" },
        Value = "旋转彩虹",
        Callback = function(v)
            if v == "旋转彩虹" then fn43(nil, true)
            elseif v == "默认白色" then fn43(Color3.new(1, 1, 1), false)
            else fn43(fn39(v), false) end
        end,
    })
    tabUI:Divider()
    tabUI:Dropdown({
        Title = "文字颜色",
        Values = { "默认", "青色", "粉色", "紫色", "橙色", "红色", "绿色", "蓝色", "黄色", "白色", "彩虹" },
        Value = "默认",
        Callback = function(v) v28 = v end,
    })
    tabUI:Button({
        Title = "确认应用文字颜色", Icon = "check",
        Callback = function()
            local themes = lib.GetThemes and lib.GetThemes()
            if not themes or not themes.Dark then return end
            if connection then connection:Disconnect(); connection = nil end
            if v28 == "彩虹" then
                connection = RunService.Heartbeat:Connect(function()
                    local c = fn38(5)
                    themes.Dark.Text = c; themes.Dark.Placeholder = c
                    themes.Dark.Button = c; themes.Dark.TabTitle = c
                    lib:SetTheme("Dark")
                end)
            elseif v28 and v28 ~= "默认" then
                local c = fn39(v28)
                themes.Dark.Text = c; themes.Dark.Placeholder = c
                themes.Dark.Button = c; themes.Dark.TabTitle = c
                lib:SetTheme("Dark")
            else lib:SetTheme("Dark") end
        end,
    })

    local section = v27:Section({ Title = "功能", Opened = true })

    local t1 = section:Tab({ Title = "主要功能", Icon = "sliders-h" })
    t1:Toggle({ Title = "无限体力", Default = false, Callback = function(v) Settings.stamina = v end })
    t1:Toggle({ Title = "无限饥饿", Default = false, Callback = function(v) Settings.food = v end })
    t1:Toggle({ Title = "战斗拦截", Default = false, Callback = fn45 })
    t1:Toggle({ Title = "隐身", Default = false, Callback = fn46 })
    t1:Toggle({ Title = "显示隐身悬浮窗", Default = false, Callback = function(v) flag10 = v; if v then fn48() else fn47() end end })
    t1:Toggle({
        Title = "锁定隐身悬浮窗位置", Default = false,
        Callback = function(v)
            flag9 = v
            if textButton then textButton.Active = not v; textButton.Draggable = not v end
        end,
    })
    t1:Toggle({ Title = "防布娃娃", Default = false, Callback = function(v) Settings.noRagdoll = v end })
    t1:Toggle({ Title = "防摔伤", Default = false, Callback = function(v) Settings.noFallDamage = v end })
    t1:Toggle({ Title = "防越狱拉回", Default = false, Callback = fn49 })
    t1:Toggle({ Title = "自动捡钱", Default = false, Callback = function(v) Settings.autoMoney = v end })
    t1:Toggle({ Title = "无限子弹", Default = false, Callback = function(v) Settings.infiniteAmmo = v end })
    t1:Toggle({ Title = "快速射击", Default = false, Callback = function(v) Settings.rapidFire = v end })

    local t2 = section:Tab({ Title = "刷钱", Icon = "money-bill-wave" })
    t2:Toggle({ Title = "自动接取任务", Default = false, Callback = function(v) Settings.autoMission = v end })
    t2:Toggle({ Title = "优先高收益任务", Default = false, Callback = function(v) tbl10.priorityHighReward = v end })
    t2:Input({
        Title = "接取间隔", Value = "2", PlaceholderText = "输入间隔秒数", ClearTextOnFocus = false,
        Callback = function(v) local n = tonumber(v); if n and n > 0 then tbl10.missionInterval = n end end,
    })
    t2:Toggle({
        Title = "安全模式(出租车)", Default = false,
        Callback = function(v)
            tbl10.taxiSafe = v
            if v then
                local _, _, hrp = fn40(localPlayer3)
                if hrp then tbl10.taxiOrigin = hrp.Position end
            end
        end,
    })
    t2:Dropdown({ Title = "出租车延迟模式", Values = { "随机时间", "距离测算" }, Value = "随机时间", Callback = function(v) tbl10.taxiDelayMode = v end })
    t2:Toggle({ Title = "出租车刷钱", Default = false, Callback = function(v) Settings.taxi = v end })
    t2:Toggle({ Title = "公交车刷钱", Default = false, Callback = function(v) Settings.bus = v end })
    t2:Toggle({ Title = "农民刷钱", Default = false, Callback = function(v) Settings.farmer = v end })
    t2:Toggle({ Title = "自动黑客小游戏", Default = false, Callback = fn50 })
    t2:Toggle({ Title = "高尔夫刷钱", Default = false, Callback = function(v) Settings.golf = v end })

    local t3 = section:Tab({ Title = "战斗", Icon = "crosshairs" })
    t3:Toggle({ Title = "杀戮光环", Default = false, Callback = function(v) tbl11.auraEnabled = v end })
    t3:Toggle({ Title = "只攻击警察", Default = false, Callback = function(v) tbl11.auraOnlyPolice = v; if v then tbl11.auraOnlyCivilian = false end end })
    t3:Toggle({ Title = "只攻击平民", Default = false, Callback = function(v) tbl11.auraOnlyCivilian = v; if v then tbl11.auraOnlyPolice = false end end })
    t3:Toggle({ Title = "战斗检测", Default = false, Callback = function(v) tbl11.auraCombatCheck = v end })
    t3:Slider({ Title = "攻击范围", Value = { Min = 10, Max = 500, Default = 50 }, Callback = function(v) tbl11.auraRange = v end })
    t3:Slider({ Title = "伤害倍率", Value = { Min = 1, Max = 100, Default = 5 }, Callback = function(v) tbl11.auraDamage = v end })

    local t4 = section:Tab({ Title = "自瞄", Icon = "crosshairs" })
    t4:Toggle({ Title = "开启/关闭自瞄", Default = false, Callback = function(v) tbl12.enabled = v end })
    t4:Toggle({ Title = "显示Fov圈", Default = false, Callback = function(v) tbl12.showFov = v end })
    t4:Toggle({ Title = "显示准心", Default = false, Callback = function(v) tbl12.showCrosshair = v end })
    t4:Toggle({ Title = "显示追踪线", Default = false, Callback = function(v) tbl12.showTracer = v end })
    t4:Toggle({ Title = "队伍检测", Default = false, Callback = function(v) tbl12.teamCheck = v end })
    t4:Toggle({ Title = "好友检测", Default = false, Callback = function(v) tbl12.friendCheck = v end })
    t4:Toggle({ Title = "墙壁检测", Default = false, Callback = function(v) tbl12.wallCheck = v end })
    t4:Toggle({ Title = "预判自瞄", Default = false, Callback = function(v) tbl12.prediction = v end })
    t4:Toggle({ Title = "只自瞄警察", Default = false, Callback = function(v) tbl12.onlyPolice = v; if v then tbl12.onlyCivilian = false end end })
    t4:Toggle({ Title = "只自瞄平民", Default = false, Callback = function(v) tbl12.onlyCivilian = v; if v then tbl12.onlyPolice = false end end })
    t4:Toggle({ Title = "战斗检测", Default = false, Callback = function(v) tbl12.combatCheck = v end })
    t4:Dropdown({ Title = "优先锁定模式", Values = { "准心最近", "距离最近", "血量最低" }, Value = "准心最近", Callback = function(v) tbl12.targetMode = v end })
    t4:Dropdown({ Title = "瞄准身体部位", Values = { "头", "胸", "左手", "右手", "左腿", "右腿" }, Value = "头", Callback = function(v) tbl12.targetPart = v end })
    t4:Slider({ Title = "Fov圈大小", Value = { Min = 1, Max = 500, Default = 50 }, Callback = function(v) tbl12.fov = v end })
    t4:Slider({ Title = "自瞄平滑度", Value = { Min = 1, Max = 10, Default = 10 }, Callback = function(v) tbl12.smoothness = v / 10 end })
    t4:Slider({ Title = "Fov圈厚度", Value = { Min = 1, Max = 5, Default = 2 }, Callback = function(v) tbl12.fovThickness = v end })
    t4:Dropdown({ Title = "颜色选择", Values = { "红色", "黄色", "绿色", "蓝色", "紫色", "白色", "黑色", "彩虹色" }, Value = "红色", Callback = function(v) tbl12.color = v end })

    local t5 = section:Tab({ Title = "Ragebot", Icon = "bot" })
    t5:Toggle({ Title = "Ragebot", Default = false, Callback = function(v) tbl13.enabled = v end })
    t5:Slider({ Title = "攻击距离", Value = { Min = 10, Max = 500, Default = 150 }, Step = 1, Callback = function(v) tbl13.range = v end })
    t5:Slider({ Title = "攻击间隔", Value = { Min = 0.01, Max = 1, Default = 0.05 }, Step = 0.01, Callback = function(v) tbl13.interval = v end })
    t5:Dropdown({ Title = "攻击部位", Values = { "头部", "躯干", "左臂", "右臂", "左腿", "右腿" }, Value = "头部", Callback = function(v) tbl13.bodyPart = tbl14[v] or "Head" end })
    t5:Toggle({ Title = "职业检测", Default = false, Callback = function(v) tbl13.jobCheck = v end })
    t5:Toggle({ Title = "墙壁检测", Default = false, Callback = function(v) tbl13.wallCheck = v end })
    t5:Toggle({ Title = "活体检测", Default = false, Callback = function(v) tbl13.aliveCheck = v end })
    t5:Toggle({ Title = "战斗状态检测", Default = false, Callback = function(v) tbl13.combatCheck = v end })
    t5:Toggle({ Title = "锁定警察", Default = false, Callback = function(v) tbl13.policeLock = v; if v then tbl13.civilianLock = false end end })
    t5:Toggle({ Title = "锁定平民", Default = false, Callback = function(v) tbl13.civilianLock = v; if v then tbl13.policeLock = false end end })
    t5:Toggle({ Title = "弹道显示", Default = false, Callback = function(v) tbl13.beam = v end })

    local t6 = section:Tab({ Title = "范围", Icon = "bullseye" })
    t6:Toggle({ Title = "开启/关闭范围", Default = false, Callback = function(v) tbl15.active = v end })
    t6:Input({ Title = "范围大小设置", Value = "10", Callback = function(v) local n = tonumber(v); if n and n > 0 then tbl15.size = n end end })
    t6:Input({ Title = "范围透明度设置(0-1)", Value = "0.7", Callback = function(v) local n = tonumber(v); if n and n >= 0 and n <= 1 then tbl15.transparency = n end end })
    t6:Dropdown({ Title = "选择范围颜色", Values = { "红色", "蓝色", "黄色", "绿色", "青色", "橙色", "紫色", "白色", "黑色", "彩虹色" }, Value = "红色", Callback = function(v) tbl15.color = v; tbl15.rainbow = (v == "彩虹色") end })
    t6:Dropdown({ Title = "选择范围材质", Values = { "Neon", "Plastic", "Wood", "Slate", "Concrete", "Metal", "SmoothPlastic" }, Value = "Neon", Callback = function(v) tbl15.material = v end })
    t6:Toggle({ Title = "NPC范围", Default = false, Callback = function(v) tbl15.affectNPC = v end })
    t6:Toggle({ Title = "队伍检测", Default = false, Callback = function(v) tbl15.teamCheck = v end })
    t6:Toggle({ Title = "活体检测", Default = false, Callback = function(v) tbl15.checkCorpses = v end })
    t6:Toggle({ Title = "显示轮廓", Default = false, Callback = function(v) tbl15.outline = v end })
    t6:Toggle({ Title = "启用/禁用碰撞", Default = false, Callback = function(v) tbl15.collision = v end })
    t6:Toggle({ Title = "发光效果", Default = false, Callback = function(v) tbl15.glow = v end })
    t6:Toggle({ Title = "脉动效果", Default = false, Callback = function(v) tbl15.pulse = v end })

    local t7 = section:Tab({ Title = "玩家", Icon = "user" })
    t7:Toggle({
        Title = "开启/关闭移动加速", Default = false,
        Callback = function(v) MovementSettings.walkEnabled = v; if v then fn60() end end,
    })
    t7:Slider({ Title = "移动速度", Value = { Min = 16, Max = 500, Default = 200 }, Callback = function(v) MovementSettings.walkSpeed = v end })
    t7:Toggle({
        Title = "开启/关闭跳跃", Default = false,
        Callback = function(v) MovementSettings.jumpEnabled = v; if v then fn56() else fn55() end end,
    })
    t7:Slider({ Title = "设置跳跃高度", Value = { Min = 50, Max = 400, Default = 50 }, Callback = function(v) MovementSettings.jumpPower = v end })
    t7:Slider({ Title = "设置跳跃倍数", Value = { Min = 1, Max = 10, Default = 1 }, Callback = function(v) MovementSettings.jumpMultiplier = v end })
    t7:Toggle({ Title = "无限跳跃", Default = false, Callback = function(v) MovementSettings.infiniteJump = v end })
    t7:Toggle({
        Title = "开启飞行", Default = false,
        Callback = function(v)
            MovementSettings.flyEnabled = v
            if v then flyStart() else flyCleanup() end
        end,
    })
    t7:Dropdown({ Title = "飞行模式", Values = { "传送", "物理" }, Value = "传送", Callback = function(v) MovementSettings.flyMode = v end })
    t7:Slider({ Title = "飞行速度", Value = { Min = 10, Max = 300, Default = 30 }, Callback = function(v) MovementSettings.flySpeed = v end })
    t7:Toggle({
        Title = "穿墙", Default = false,
        Callback = function(v) MovementSettings.noclip = v; if v then noclipStart() else noclipStop() end end,
    })
    t7:Toggle({
        Title = "解除限速", Default = false,
        Callback = function(v) flag11 = v end,
    })

    local t8 = section:Tab({ Title = "警察功能", Icon = "handcuffs" })
    t8:Toggle({ Title = "自动铐", Default = false, Callback = function(v) Settings.autoCuff = v; if v then fn54() end end })
    t8:Toggle({ Title = "自动传送", Default = false, Callback = function(v) PoliceSettings.teleport = v end })
    t8:Toggle({ Title = "战斗检测", Default = false, Callback = function(v) PoliceSettings.combatCheck = v end })
    t8:Slider({ Title = "范围", Value = { Min = 10, Max = 500, Default = 200 }, Step = 5, Callback = function(v) PoliceSettings.range = v end })
    t8:Slider({ Title = "间隔", Value = { Min = 0.1, Max = 3, Default = 0.5 }, Step = 0.1, Callback = function(v) PoliceSettings.delay = v end })

    local t9 = section:Tab({ Title = "ESP", Icon = "eye" })
    t9:Toggle({
        Title = "玩家透视总开关", Default = false,
        Callback = function(v)
            if type(v) == "table" then v = v.Value end
            tbl16.enabled = (v == true)
            if not tbl16.enabled then
                for k in pairs(tbl16.trackers) do fn52(k) end
            else pcall(fn53) end
        end,
    })
    t9:Toggle({ Title = "显示名字", Default = true, Callback = function(v) tbl16.name = v end })
    t9:Toggle({ Title = "显示距离", Default = true, Callback = function(v) tbl16.distance = v end })
    t9:Toggle({ Title = "显示血量", Default = true, Callback = function(v) tbl16.health = v end })
    t9:Toggle({ Title = "显示高亮", Default = true, Callback = function(v) tbl16.highlight = v end })
    t9:Toggle({ Title = "显示追踪线", Default = false, Callback = function(v) tbl16.tracer = v end })
    t9:Dropdown({ Title = "追踪线起点", Values = { "屏幕底部", "屏幕中心", "屏幕顶部" }, Value = "屏幕底部", Callback = function(v) tbl16.tracerOrigin = v end })
    local teamList = { "逃犯", "厨师", "平民", "配送员", "农民", "消防员", "警察", "医护人员", "囚犯", "道路服务", "交通" }
    t9:Dropdown({
        Title = "选择透视队伍", Values = teamList, Value = teamList, Multi = true, AllowNone = true,
        Callback = function(v)
            for k in pairs(tbl16.selectedTeams) do tbl16.selectedTeams[k] = false end
            tbl16.showFugitive = false
            if type(v) ~= "table" then return end
            local function applyTeam(label)
                if label == "逃犯" then tbl16.showFugitive = true; return end
                for k, name in pairs(tbl17) do
                    if name == label or k == label then tbl16.selectedTeams[k] = true end
                end
            end
            if v[1] ~= nil then
                for _, val in ipairs(v) do applyTeam(val) end
            else
                for k, val in pairs(v) do
                    if val == true then applyTeam(k)
                    elseif type(val) == "string" then applyTeam(val) end
                end
            end
        end,
    })

    v27:OnClose(function() flag8 = false; v27 = nil end)
    v27:OnDestroy(function() flag8 = false; v27 = nil end)
end

-- ============ 8. 启动 ============
task.defer(function()
    local ok, err = pcall(buildUI)
    if not ok then warn("[PY Hub] UI 启动失败: " .. tostring(err)) end
end)