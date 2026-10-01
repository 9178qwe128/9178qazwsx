--[[
    PY Hub - 完整整合版（防封 + UI + 功能）
    作者: Xi.Team / 开源人: 苏达
]]

-- =====================================================
-- 0. 去混淆环境补全
-- =====================================================
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
    c       = c       or 0
    if type(cloneref) == "function" then
        local raw = cloneref
        cloneref = function(inst)
            if inst == nil then return nil end
            return raw(inst)
        end
    elseif cloneref == nil then
        cloneref = function(inst) return inst end
    end
end

-- =====================================================
-- 1. 防封主入口（完整 PYHubEntry，含校验/加密通信）
-- =====================================================
local PYHubEntry = function(loaderUrl, nodeUrl, scriptId, scriptVersion, _unusedScriptKey, extraC, extraD, sigSq, sigRp, debugPrint, progressPrint, reportFunc)

    progressPrint = progressPrint or function(msg) return function() end end
    reportFunc    = reportFunc    or function() end
    debugPrint    = debugPrint    or function() end

    -- 1.1 初始化标记
    local v2 = progressPrint("正在初始化...")
    local tbl = { p = 40, m = "\174yM\25\4q\210\162;\233)\184\230.~\171\229~\193T\17" }
    reportFunc(tbl)

    -- 1.2 校验用字符串（原样保留）
    local s  = "\174)\197\28b\161\231\157za:\26\8\11'\20770lw\195\232\156S\234*\203XvJ\203n"
    local v3 = "\130`$\217\169?\140\0268\1442F^\218\207\232"
    if scriptId ~= s or scriptVersion ~= v3 then
        -- 原版这里是空块，保留占位
    end

    -- 1.3 服务/环境探测
    local localPlayer = game:GetService("Players").LocalPlayer
    local concat   = table.concat
    local sub      = string.sub
    local byte     = string.byte
    local char     = string.char
    local lshift   = bit32.lshift
    local rshift   = bit32.rshift
    local band     = bit32.band
    local bxor     = bit32.bxor
    local rrotate  = bit32.rrotate
    local bnot     = bit32.bnot

    local cloneFunc = clonefunction or function(...) return ... end
    local v4 = cloneFunc(http and http.request or request or getfenv()["http"])
    local v5 = cloneFunc(debug.traceback)
    local v6 = cloneFunc(debug.info)
    local v7 = cloneFunc(pcall)
    local v8 = cloneFunc(getfenv)
    local v9 = cloneFunc(tostring)
    local v10 = identifyexecutor()
    local v11 = v6(1, "f")
    local script = v8(0).script
    local n2 = #v5():split("\n") - 4
    v2()

    local v12 = progressPrint("正在检查运行环境...")

    -- 1.4 环境检测（保留原判断，避免行为差异）
    local flag3 = fn12(concat) or fn12(sub) or fn12(byte) or fn12(char)
        or fn12(lshift) or fn12(rshift) or fn12(band) or fn12(bxor) or fn12(rrotate) or false
    if not flag3 then
        local find = table.find
        flag3 = fn12(v4) ~= find({ "Xeno", "Helios Mac" }, v10) ~= nil
    end
    flag3 = flag3 or false
    if flag3 or fn12(setmetatable) or fn12(v5) or fn12(v6) or fn12(v7) or fn12(task.wait) or fn12(math.floor, "fr") or fn12(math.random, "fr") or fn12(v8, "fr") then
        -- 原版空块
    end
    if fn13(concat) or fn13(sub) or fn13(byte) or fn13(char) or fn13(lshift) or fn13(rshift)
        or fn13(band) or fn13(bxor) or fn13(rrotate) or fn13(bnot) or fn13(v4)
        or fn13(clonefunction) or fn13(setmetatable) or fn13(v5) or fn13(v6) or fn13(v7)
        or fn13(task.wait) or fn13(math.floor) or fn13(math.random) or fn13(v8) or fn13(v9)
        or fn13(identifyexecutor) then
        -- 原版空块
    end
    if #v5():split("\n") ~= 4 + n2 then end
    if v6(1, "f") ~= v11 or v8(0).script ~= script then end

    -- 1.5 卡密/在线验证移除（保留字段占位）
    v16 = ""
    k = nil
    i = 0
    e2 = ""
    c = c or 0
    v40 = nil
    reportFunc({ s = true })

    if v40 then
        v43(); a = v40.a; b = v40.b; v = i; d = v40.d; f = v40.f; flag2 = true
        g = v40.g; u = v40.h.u; d2 = v40.h.d; a2 = v40.h.a; b2 = v40.h.b; p = v40.h.p
    else
        reportFunc({ s = true })
    end

    -- 1.6 加密通信函数（完整保留）
    fn2 = function(arg11, arg12)
        local v43 = assert
        v43(type(arg11) == "string", "\229\235q!WBC2W6\155\247n%\222B\132`Q\171>+\174\175&\134\20\17G\215\229\7\163\227h\19\1\187\150\254\195\145\15\17\2389Z\164\252&\19\253\189\25l")
        local v44 = assert
        v44(type(arg12) == "string", "x\206P\234f\147-\201\209\215YS\174\223\129&0\128G\0\151\232M^\198\203|\187\249\2378\246J\2297\198\219\15\249+\176\r\165Y\229`Z\21\224\224\227\156\4\17\150\196")
        return "\20\160Q\200,X\246\171Zo92N" .. arg11 .. "\229r\132\155I\133\240\7nM\129" .. arg12 .. "\233\234<.\3\167E\137-\225H$M"
    end

    fn4 = function(arg11)
        local v43 = assert
        v43(type(arg11) == "table", "\246`0K\174\196\154q\250k7\12\197\215I-\243cn(\144/S?\184\188\8\183\132\167\175/%3\229Z\180\188y\159\\\195\191Y\133\148\185-{\150Z\139B%\162")
        local v44 = assert
        v44(type(arg11.Url) == "string", "\3D\6\225\214\1817g\214\211\6\21L^mk\229\238\172\242\179\130\224\201\127@7\155\131y\"\16\27iQr\173/\130T\132\213IqmO\135\191\252\242\146\208")

        if arg11["\137\23\138!\210\176\15"] == nil then
            arg11["\1271\"\218$+\145"] = {}
        end
        if arg11["\230IA\27t\199"] == nil then
            arg11["^\172[Q2\188"] = "GET"
        end

        local v45, v46, v47 = fn24(arg11, true, v6(1, "f"),
            #v5():split("\n") - (1 - 2 * (3875480235 + 1251298450 + 3463155907) % 4294967296) *
            (1 + ((5166075928 + 3423858664 + 3790215179 + bit32.band(6155 * 65535 + bit32.lshift(bit32.band(403367925 + 57834 * 65535, 65535), 16), 4294967295) % 4294967296) % 4294967296 * 67108864
            + (1275608216 + 3019359080 + bit32.band(1293 * 0 + bit32.lshift(bit32.band(1293 * bit32.rshift(0, 16) + 8541 * 0, 65535), 16), 4294967295) % 4294967296) % 4294967296) / 4503599627370496)
            * 2 ^ ((2022214747 + 2332765280 + 4234955590) % 4294967296 - 1023))

        if not v45 then
            if v46 == ",M\223\183<\239" then
                return { success = false, reason = "request failed", error_message = v47 }
            end
        end
        if not v45 then
            return { success = false, reason = "tampering detected" }
        end
        return { success = true, response = v46 }
    end

    fn = function(arg11, arg12)
        local v43 = assert
        v43(type(arg11) == "string", "\215\153SL\193\138\210\129\242V\219PL/\177\170 \21\134\192z\131\208a\192\21\157\2498\15\25\"0\200\190\23\182\230\245\178\r\151\148\159\234\179l\201\190\198\2169\22\238[\216")
        local v44 = assert
        v44(type(arg12) == "table", "\207\225\158\250\2223YLu\17\239\210\190\242r\216qiml\189Ntg\198V1\170\244\145r\5\128\0\1289/\196\182\237\201N3H\193qc\255\207\165z\129\25L\218")
        local v45 = fn4
        local Settings2 = {}
        Settings2.Url = nodeUrl .. "\167+q\187\248\2118\190\247\148\11\255\4\242\167\2511Z\198\156\128\31\167u"
        Settings2.Method = "\191i\6\2"
        Settings2.Body = fn17({ d = v14(fn17({ u = arg11, d = fn17(arg12), s = s }), v16), c = c })
        local headers = {}
        headers["\2348\150-\206\251\\B\14\181\228\150"] = "\219KZ*\202\197\183\20\199\220\159\21\205~3="
        Settings2.Headers = headers
        local v47 = v45(Settings2)
        if not v47.success then return { success = false, fail_reason = v47.reason } end
        local v48, v49 = v7(function()
            local v48 = v15
            local response = v47.response
            local v49 = v48(response["\8p\205\203"], v16)
            return nil
        end)
        if not v48 then
            return { success = false, fail_reason = "S\183|v\192\177\27TAn\235\212\159\237" }
        end
        if not v49.success then return { success = false, fail_reason = v49.reason } end
        return { success = true }
    end

    fn5 = function(arg11)
        local v43 = assert
        v43(type(arg11) == "string", ";\226e\175@j\r!\8<\196E\178\215VO\180\169\12\2231':u\190\179\202\154^\213tVQ6e2\211\199\132S\223D\211A\"F\n\r\161\221\210<\23")
    end

    fn3 = function(arg11, arg12)
        local v43 = assert
        v43(type(arg11) == "string", ":\174;?),\151\205-\190\209\n\214\239\189\18\253lp~\4\186\144\16N:M\202\172\147w\178\29\144?\241W\31a\22\191\204\202\197\236\144r\255\244\174\132]\252\135\182\185K7$\186\"\207\239S=")
        local v44 = assert
        v44(type(arg12) == "function", "\251\179q\174\127}\172M\209\207\230L\196\176\216\193\207\240$@\200L(\251G\200e\201\1340\1\226\179\\\253\155\199`1\193l\160\245\134.4\166\43\146\214R\176\14\248Tt\161\165\136\188t7\216\210`\249")
        handlers[arg11] = arg12
    end

    -- =====================================================
    -- 2. 防封核心（AntiCheat/Ratchet/hook）
    -- =====================================================
    local Players           = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService        = game:GetService("RunService")
    local UserInputService  = game:GetService("UserInputService")
    local GuiService        = game:GetService("GuiService")
    local ContextActionService = game:GetService("ContextActionService")
    local HttpService       = game:GetService("HttpService")
    local Workspace         = game:GetService("Workspace")
    local localPlayer2 = Players.LocalPlayer

    -- 2.1 AntiCheat 补丁
    pcall(function()
        local antiCheat = ReplicatedStorage:FindFirstChild("AntiCheat", true)
        if antiCheat and type(antiCheat) == "table" then
            for k2, v35 in pairs(antiCheat) do
                if type(v35) == "function" then
                    antiCheat[k2] = function(...)
                        local ok, result = pcall(v35, ...)
                        if ok then return result end
                        return true
                    end
                end
            end
        end
    end)

    -- 2.2 Ratchet/Sha256 补丁
    pcall(function()
        local Ratchet = require(ReplicatedStorage:FindFirstChild("Ratchet", true))
        local Sha256  = require(ReplicatedStorage:FindFirstChild("Sha256", true))
        local v35 = getmetatable(Ratchet)
        if v35 and v35.__index and not v35.__index.__patched then
            v35.__index.catchUp = function(arg11, arg12)
                while arg11.index < arg12 do arg11:advance() end
                return true
            end
            v35.__index.respond = function(arg11, arg12)
                return Sha256("resp|" .. tostring(arg11.state) .. "|" .. tostring(arg11.index) .. "|" .. tostring(arg12))
            end
            v35.__index.__patched = true
        end
    end)

    -- 2.3 __index hook：屏蔽敏感服务
    if hookmetamethod and newcclosure then
        local v27 = nil
        local function fn38(...)
            local arg11, arg12, arg13, arg14, arg15, descendant = ...
            descendant = descendant or arg11
            if arg11 == game and (arg12 == "GetService" or arg12 == "getService") then
                return function(arg13, arg14)
                    if arg14 == "InsertService" or arg14 == "Selection" or arg14 == "Stats" then
                        return nil
                    end
                    return v27(arg11, arg14)
                end
            end
            return v27(arg11, arg12)
        end
        v27 = hookmetamethod
        v27 = v27(game, "__index", newcclosure(fn38))
    end

    -- 2.4 __namecall hook：反踢+拦截+防摔伤+战斗拦截
    if hookmetamethod and newcclosure and getnamecallmethod then
        local v32 = nil
        local function cloneFunc4(arg11, ...)
            local v33 = table.pack(...)
            local v34 = getnamecallmethod()
            if v34 == "Kick" and arg11 == localPlayer2 then return end

            local v35
            if v34 == "FireServer" and arg11.Name == "PlayerEvent" then
                local v36 = ({ ... })[1]
                if v36 == "char2" or v36 == "coreGame" or v36 == "vehicleTrack" or v36 == "platform"
                    or v36 == "messageDeliver" or v36 == "runOverVictim" or v36 == "DEBUG2"
                    or v36 == "chatCommand" or v36 == "controlsGuide" then
                    return
                end

                if v34 == "InvokeServer" and arg11.Name == "PlayerFunc" then
                    local tbl29 = { table.unpack(v33, 1, v33.n) }
                    v35 = tbl29[1]
                    local flag12 = v35 == "getPlayerData" or v35 == "getPlayerBanHistory"
                    local flag13 = flag12 or v35 == "getPlayerInGame"
                    local flag14 = flag13 or v35 == "getPlayerServerEncounters"
                    local flag15 = flag14 or v35 == "getSecret"
                    if flag15 then return true end
                end
            else
                if not (v34 == "InvokeServer" and arg11.Name == "PlayerFunc") then
                    return v32(arg11, ...)
                end
                v35 = ({ ... })[1]
                if v35 == "getPlayerData" or v35 == "getPlayerBanHistory" or v35 == "getPlayerInGame"
                    or v35 == "getPlayerServerEncounters" or v35 == "getSecret" then
                    return true
                end
            end

            return v32(arg11, table.unpack(v33, 1, v33.n))
        end
        v32 = hookmetamethod
        v32 = v32(game, "__namecall", newcclosure(cloneFunc4))
    end

    -- 2.5 本地服务/变量
    local localPlayer3 = Players.LocalPlayer
    if not localPlayer3 then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        localPlayer3 = Players.LocalPlayer
    end

    local function getHui()
        local hui = nil
        pcall(function() if type(gethui) == "function" then hui = gethui() end end)
        if hui then return hui end
        pcall(function() hui = game:FindService("CoreGui") end)
        if hui then return hui end
        pcall(function() hui = localPlayer3:WaitForChild("PlayerGui", 5) end)
        if hui then return hui end
        pcall(function() hui = localPlayer3:FindFirstChild("PlayerGui") end)
        return hui
    end
    local v29 = getHui()

    local remote      = ReplicatedStorage:WaitForChild("Remote", 30)
    local playerEvent = remote and remote:WaitForChild("PlayerEvent", 30)
    local playerFunc  = remote and remote:WaitForChild("PlayerFunc", 30)

    -- 2.6 字体 hook（原版保留）
    if hookfunction and Font and Font.new then
        local fontNew = Font.new
        pcall(function()
            hookfunction(fontNew, function(family, weight, style)
                local ok, result = pcall(fontNew, family, weight, style)
                if ok then return result end
                weight = weight or Enum.FontWeight.Medium
                style  = style  or Enum.FontStyle.Normal
                ok, result = pcall(fontNew, Enum.Font.GothamMedium, weight, style)
                if ok then return result end
                return Font.fromEnum(Enum.Font.GothamMedium)
            end)
        end)
    end

    -- 2.7 加载 WindUI（沿用原 URL）
    local windUiSrc = game:HttpGet("https://raw.githubusercontent.com/123fa98/Xi_Pro/refs/heads/main/UI.lua")
    lib = loadstring(windUiSrc)()
    if not lib then
        warn("[PY Hub] WindUI 加载失败，请检查网络或 HttpGet")
        return
    end

    -- =====================================================
    -- 3. 颜色表 / 工具函数（沿用 UI 版本）
    -- =====================================================
    local tbl21 = {
        ["红色"] = Color3.fromRGB(255, 0, 0),
        ["黄色"] = Color3.fromRGB(255, 255, 0),
        ["绿色"] = Color3.fromRGB(0, 255, 0),
        ["蓝色"] = Color3.fromRGB(0, 150, 255),
        ["紫色"] = Color3.fromRGB(150, 0, 255),
        ["白色"] = Color3.fromRGB(255, 255, 255),
        ["黑色"] = Color3.fromRGB(0, 0, 0),
        ["青色"] = Color3.fromRGB(0, 255, 255),
        ["橙色"] = Color3.fromRGB(255, 165, 0),
        ["粉色"] = Color3.fromRGB(255, 105, 180),
    }
    local function fn38(n) n = n or 5; return Color3.fromHSV(tick() % n / n, 1, 1) end
    local function fn39(name)
        if name == "彩虹色" then return fn38(5) end
        return tbl21[name] or Color3.fromRGB(255, 0, 0)
    end

    local function fn40(plr)
        plr = plr or localPlayer3
        local seen, list = {}, {}
        local function add(m)
            if m and typeof(m) == "Instance" and m:IsA("Model") and not seen[m] then
                seen[m] = true; table.insert(list, m)
            end
        end
        pcall(function() add(plr.Character) end)
        pcall(function()
            local cf = Workspace:FindFirstChild("Characters")
            if cf then add(cf:FindFirstChild(plr.Name)) end
        end)
        for _, char in ipairs(list) do
            local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid", true)
            local hrp = char:FindFirstChild("HumanoidRootPart")
                or char:FindFirstChild("Torso")
                or char:FindFirstChild("UpperTorso")
                or (hum and hum.RootPart)
            if not hrp then hrp = char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart") end
            if hrp then return char, hum, hrp end
        end
    end

    local function fn62(plr)
        local _, hum = fn40(plr)
        return hum ~= nil and hum.Health > 0
    end
    local function fn63(plr) return plr and plr.Team and plr.Team.Name or "Civilian" end

    local function fn70(inst)
        if not inst or not inst.Parent then return end
        local parent = inst.Parent
        if parent:IsA("BasePart") then return parent.Position end
        if parent:IsA("Attachment") then return parent.WorldPosition end
        if parent:IsA("Model") then
            local pp = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
            if pp then return pp.Position end
        end
    end

    local function fn71(prompt)
        if not prompt then return end
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt, 0)
            else
                prompt.HoldDuration = 0
                prompt:InputHoldBegin(); task.wait(0.1); prompt:InputHoldEnd()
            end
        end)
    end

    local function fn72(pos)
        local char, _, hrp = fn40(localPlayer3)
        if not char or not hrp or not pos then return end
        local cf = CFrame.new(pos + Vector3.new(0, 3, 0))
        char:PivotTo(cf)
        pcall(function()
            if playerEvent then
                local id = ((char:GetAttribute("CharPivotToId") or 0) + 1) % 100
                char:SetAttribute("CharPivotToId", id)
                playerEvent:FireServer("charPivotTo", cf, char, id)
            end
        end)
    end

    -- =====================================================
    -- 4. 配置
    -- =====================================================
    local Settings = {
        stamina = false, food = false, combatBlock = false, ghost = false,
        noRagdoll = false, noFallDamage = false, antiPrisonPull = false,
        autoMoney = false, infiniteAmmo = false, rapidFire = false,
        farmer = false, taxi = false, bus = false, autoMission = false,
        autoHack = false, golf = false, autoCuff = false, noSpeedLimit = false,
    }

    local tbl10 = {
        missionInterval = 2, priorityHighReward = false,
        taxiSafe = false, taxiDelayMode = "随机时间", taxiOrigin = nil,
    }
    local tbl11 = { auraEnabled = false, auraRange = 50, auraDamage = 5, auraInterval = 0.05,
        auraOnlyPolice = false, auraOnlyCivilian = false, auraCombatCheck = false,
        bulletEnabled = false, bulletFov = 360, bulletDistance = 300, bulletPart = "Head",
        bulletShowFov = true, bulletColor = "红色", bulletCombatCheck = false,
        bulletOnlyPolice = false, bulletOnlyCivilian = false }
    local tbl12 = { enabled = false, prediction = false, teamCheck = false, wallCheck = false,
        showFov = false, showCrosshair = false, showTracer = false, friendCheck = false,
        onlyPolice = false, onlyCivilian = false, combatCheck = false,
        fov = 50, smoothness = 1, targetMode = "准心最近", targetPart = "头",
        color = "红色", fovThickness = 2 }
    local tbl13 = { enabled = false, range = 150, interval = 0.05, bodyPart = "Head",
        jobCheck = false, wallCheck = false, aliveCheck = false,
        combatCheck = false, policeLock = false, civilianLock = false, beam = false }
    local tbl14 = { ["头部"]="Head", ["躯干"]="Torso", ["左臂"]="LeftArm",
        ["右臂"]="RightArm", ["左腿"]="LeftLeg", ["右腿"]="RightLeg" }
    local tbl15 = { active = false, size = 10, transparency = 0.7, teamCheck = false,
        color = "红色", material = "Neon", rainbow = false, checkCorpses = false,
        outline = false, collision = false, glow = false, pulse = false, affectNPC = false }
    local tbl16 = { enabled = false, name = true, distance = true, health = true,
        highlight = true, tracer = false, tracerOrigin = "屏幕底部", showFugitive = true,
        selectedTeams = { Chef=true, Civilian=true, Delivery=true, Farmer=true,
            Fire=true, Police=true, Medical=true, Prisoner=true,
            ["Road Service"]=true, Transit=true },
        trackers = {} }
    local tbl17 = { Chef="厨师", Civilian="平民", Delivery="配送员", Farmer="农民",
        Fire="消防员", Police="警察", Medical="医护人员", Prisoner="囚犯",
        ["Road Service"]="道路服务", Transit="交通" }
    local tbl28 = { Chef=Color3.fromRGB(255,200,0), Civilian=Color3.fromRGB(100,200,255),
        Delivery=Color3.fromRGB(255,150,50), Farmer=Color3.fromRGB(50,200,50),
        Fire=Color3.fromRGB(255,50,50), Police=Color3.fromRGB(50,100,255),
        Medical=Color3.fromRGB(255,50,255), Prisoner=Color3.fromRGB(255,150,150),
        ["Road Service"]=Color3.fromRGB(255,255,100), Transit=Color3.fromRGB(100,255,255) }

    local tbl8 = { randomBg = true, borderColor = nil, isBorderRainbow = true, borderEnabled = false }
    local function fn65()
        local ok, result = pcall(function() return readfile("PYHub_Settings.txt") end)
        if ok and result then
            local ok2, result2 = pcall(function() return HttpService:JSONDecode(result) end)
            if ok2 and type(result2) == "table" then
                for k2, v32 in pairs(result2) do tbl8[k2] = v32 end
            end
        end
    end
    local function fn41()
        pcall(function() writefile("PYHub_Settings.txt", HttpService:JSONEncode(tbl8)) end)
    end

    local tbl22 = {
        "https://raw.githubusercontent.com/PYHub/assets/main/bg.jpg",
        -- 重复 17 次，此处略
    }
    local function fn42()
        if not tbl8.randomBg or #tbl22 == 0 then return "" end
        return tbl22[math.random(1, #tbl22)]
    end

    local v27, connection, connection2, v28
    local flag8 = false

    local function fn43(color, isRainbow)
        local main = v27 and v27.UIElements and v27.UIElements.Main
        if not main then return end
        local mainBorder = main:FindFirstChild("MainBorder"); if not mainBorder then return end
        local borderGradient = mainBorder:FindFirstChild("BorderGradient"); if not borderGradient then return end
        mainBorder.Enabled = tbl8.borderEnabled
        if connection2 then connection2:Disconnect(); connection2 = nil end
        if isRainbow then
            borderGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHex("FF0000")),
                ColorSequenceKeypoint.new(0.16, Color3.fromHex("FFA500")),
                ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
                ColorSequenceKeypoint.new(0.5,  Color3.fromHex("00FF00")),
                ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
                ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
                ColorSequenceKeypoint.new(1,    Color3.fromHex("EE82EE")),
            })
            connection2 = RunService.Heartbeat:Connect(function()
                if borderGradient.Parent then
                    borderGradient.Rotation = (borderGradient.Rotation + 1.5) % 360
                end
            end)
            tbl8.isBorderRainbow = true; tbl8.borderColor = nil
        else
            color = color or Color3.new(1, 1, 1)
            mainBorder.Color = color
            borderGradient.Color = ColorSequence.new(color)
            borderGradient.Rotation = 0
            tbl8.isBorderRainbow = false; tbl8.borderColor = nil
        end
    end

    -- 框架模块
    local Character, Core, module
    pcall(function()
        local framework = localPlayer3:WaitForChild("PlayerScripts", 15):WaitForChild("Framework", 15)
        Character = require(framework:WaitForChild("Character", 15))
        Core      = require(framework:WaitForChild("Core", 15))
        local inventory = framework.Character:FindFirstChild("Inventory")
        if inventory then module = require(inventory) end
    end)

    -- =====================================================
    -- 5. 防封功能函数（原版所有）
    -- =====================================================

    -- 反布娃娃
    pcall(function()
        local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)
        local activate = Ragdoll.activate
        local activateServer = Ragdoll.activateServer
        Ragdoll.activate = function(a, b, c2, ...)
            if Settings.noRagdoll and b then return end
            local v32 = activate
            local v33 = table.pack(...)
            v33.n = 4 + v33.n - 1
            table.move(v33, 1, v33.n, 4, v33)
            v33[1] = a; v33[2] = b; v33[3] = c2
            return v32(table.unpack(v33, 1, v33.n))
        end
        if activateServer then
            Ragdoll.activateServer = function(a, b, c2, ...)
                if Settings.noRagdoll and b then return end
                local v32 = activateServer
                local v33 = table.pack(...)
                v33.n = 4 + v33.n - 1
                table.move(v33, 1, v33.n, 4, v33)
                v33[1] = a; v33[2] = b; v33[3] = c2
                return v32(table.unpack(v33, 1, v33.n))
            end
        end
    end)

    -- 防摔伤（在 __namecall 里拦截 takeDamage）
    local namecall
    pcall(function()
        local v32 = getrawmetatable(game)
        namecall = v32.__namecall
        setreadonly(v32, false)
        v32.__namecall = newcclosure(function(arg11, ...)
            local v33 = table.pack(...)
            local tbl29 = { ... }
            local v34 = getnamecallmethod()
            if Settings.noFallDamage and v34 == "FireServer"
                and tostring(arg11) == "PlayerEvent" and tbl29[1] == "takeDamage" then
                return nil
            end
            return namecall(arg11, table.unpack(v33, 1, v33.n))
        end)
        setreadonly(v32, true)
    end)

    -- 防越狱拉回
    local charPivotTo, notify
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
            if antiPrisonPull and not notify then
                notify = Core.notify
                Core.notify = function(arg11)
                    if arg11 and arg11.message and string.find(arg11.message, "You can't leave prison yet") then
                        return nil
                    end
                    return notify(arg11)
                end
            elseif not antiPrisonPull and notify then
                Core.notify = notify; notify = nil
            end
        end)
    end

    -- 战斗拦截
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

    -- 无限车速
    local getSpeedLimitAtPos
    pcall(function()
        local Algorithms = require(ReplicatedStorage.Modules.Algorithms)
        getSpeedLimitAtPos = Algorithms.getSpeedLimitAtPos
        Algorithms.getSpeedLimitAtPos = function(...)
            if Settings.noSpeedLimit then return 9999 end
            return getSpeedLimitAtPos(...)
        end
    end)

    -- 隐身（原有）
    local connection3, screenGui, textButton, connection4
    local udim2 = UDim2.new(0, 100, 0.5, -25)
    local flag9, flag10 = false, false

    local function fn68(char, val)
        if not char then return end
        pcall(function()
            char:SetAttribute("Invisible", val or nil)
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                    d.LocalTransparencyModifier = val and 0.55 or 0
                    d.Material = val and Enum.Material.ForceField or Enum.Material.SmoothPlastic
                elseif d:IsA("Decal") and d.Name == "face" then
                    d.Transparency = val and 0.55 or 0
                end
            end
        end)
    end
    local function fn69()
        if not textButton then return end
        textButton.Text = Settings.ghost and "隐身: 开" or "隐身: 关"
        textButton.TextColor3 = Settings.ghost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
    local function fn46(ghost)
        Settings.ghost = ghost
        local char = localPlayer3.Character
        if not char then return end
        if ghost then
            pcall(function()
                local stuff = ReplicatedStorage:FindFirstChild("Stuff")
                local locations = stuff and stuff:FindFirstChild("Locations")
                locations = locations and locations:GetChildren()[1] or nil
                if playerFunc then playerFunc:InvokeServer("hideCharacterLocation", locations) end
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
            if connection3 then connection3:Disconnect() end
            connection3 = RunService.RenderStepped:Connect(function()
                if Settings.ghost and localPlayer3.Character then
                    fn68(localPlayer3.Character, true)
                end
            end)
        else
            if connection3 then connection3:Disconnect(); connection3 = nil end
            pcall(function()
                if playerFunc then playerFunc:InvokeServer("hideCharacterLocation", false) end
            end)
            fn68(char, false)
        end
    end

    -- =====================================================
    -- 6. 功能函数（与原 UI 版本一致）
    -- =====================================================
    local function fn44()
        if not Settings.rapidFire or not getgc then return end
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if rawget(v, "SHOOT_MODE") ~= nil then rawset(v, "SHOOT_MODE", 2) end
                if rawget(v, "RPM") ~= nil then rawset(v, "RPM", math.huge) end
            end
        end
    end
    local function fn66()
        RunService.Heartbeat:Connect(function()
            if Core then
                if Settings.stamina then pcall(function() Core.stamina = 100 end) end
                if Settings.food then pcall(function() Core.food = 100 end) end
                if Settings.rapidFire then pcall(fn44) end
            end
            if Settings.infiniteAmmo then
                local cf = Workspace:FindFirstChild("Characters")
                local char = cf and cf:FindFirstChild(localPlayer3.Name)
                if char then
                    for _, child in ipairs(char:GetChildren()) do
                        local config = child:FindFirstChild("Config")
                        if config then
                            local ammo = config:FindFirstChild("Ammo")
                            local total = config:FindFirstChild("TotalAmmo")
                            if ammo then ammo.Value = math.huge end
                            if total then total.Value = math.huge end
                        end
                    end
                end
            end
        end)
    end

    -- 自动捡钱
    local function fn73()
        task.spawn(function()
            while true do
                if Settings.autoMoney then
                    local _, _, hrp = fn40(localPlayer3)
                    if hrp then
                        local bestD, bestP = nil, nil
                        for _, d in ipairs(Workspace:GetDescendants()) do
                            if d:IsA("ProximityPrompt") then
                                local nm = d.Name
                                local at = string.lower(tostring(d.ActionText or ""))
                                local ot = string.lower(tostring(d.ObjectText or ""))
                                local match = nm == "CashDrop" or nm == "GetItem" or nm == "Money"
                                    or at:find("pick", 1, true) or at:find("cash", 1, true)
                                    or at:find("collect", 1, true) or at:find("grab", 1, true)
                                    or ot:find("cash", 1, true) or ot:find("money", 1, true)
                                if match then
                                    local pos = fn70(d)
                                    if pos then
                                        local dist = (hrp.Position - pos).Magnitude
                                        if not bestD or dist < bestD then bestD, bestP = dist, d end
                                    end
                                end
                            end
                        end
                        if bestP and bestD and bestD < 120 then
                            if bestD > 8 then fn72(fn70(bestP)); task.wait(0.3) end
                            fn71(bestP)
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end

    -- 自动任务
    local function fn74()
        if not getgc then return end
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "teamJobs") then return v.teamJobs end
        end
    end
    local function fn75()
        if localPlayer3:GetAttribute("Mission") then return true end
        local jobs = fn74()
        if jobs then for _, j in pairs(jobs) do if j.joined then return true end end end
        return false
    end
    local function fn76()
        local jobs = fn74()
        if not jobs then return end
        local bestP, bestKey = -math.huge, nil
        for k, j in pairs(jobs) do
            if not j.joined then
                if not tbl10.priorityHighReward then return k end
                local score = (j.profitability or 1) * 1e6 + (j.reward or 0)
                if bestP < score then bestP, bestKey = score, k end
            end
        end
        return bestKey
    end
    local function fn77()
        task.spawn(function()
            while true do
                if Settings.autoMission and playerFunc and not fn75() then
                    local k = fn76()
                    if k then
                        pcall(function() playerFunc:InvokeServer("talkToMission", tostring(k) .. "join") end)
                    end
                end
                task.wait(tbl10.missionInterval)
            end
        end)
    end

    -- 农民刷钱
    local function fn79()
        task.spawn(function()
            while true do
                if Settings.farmer then
                    local tool = localPlayer3.Character and localPlayer3.Character:FindFirstChildOfClass("Tool")
                    if tool then task.wait(0.4) end
                    local _, _, hrp = fn40(localPlayer3)
                    if hrp then
                        local bestD, bestP = nil, nil
                        for _, d in ipairs(Workspace:GetDescendants()) do
                            if d:IsA("ProximityPrompt") and d.ActionText == "Pick Up" then
                                local pos = fn70(d)
                                if pos then
                                    local dist = (hrp.Position - pos).Magnitude
                                    if not bestD or dist < bestD then bestD, bestP = dist, d end
                                end
                            end
                        end
                        if bestP then
                            local pos = fn70(bestP)
                            if pos then
                                local dist = (hrp.Position - pos).Magnitude
                                if dist > 8 then fn72(pos); task.wait(0.3)
                                else fn71(bestP) end
                            end
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end

    -- 出租车刷钱
    local function fn80()
        task.spawn(function()
            local lastPos = nil
            while true do
                if Settings.taxi then
                    local gp = Workspace:FindFirstChild("Gameplay")
                    gp = gp and gp:FindFirstChild("Entities")
                    gp = gp and gp:FindFirstChild("ClientContent")
                    if gp and gp:IsA("Model") then
                        local pp = gp.PrimaryPart or gp:FindFirstChildWhichIsA("BasePart")
                        local _, _, hrp = fn40(localPlayer3)
                        if pp and hrp then
                            local pos = pp.Position
                            if lastPos == nil or (pos - lastPos).Magnitude > 5 then
                                if tbl10.taxiSafe and tbl10.taxiOrigin then
                                    hrp.CFrame = CFrame.new(tbl10.taxiOrigin)
                                    local mag = (tbl10.taxiOrigin - pos).Magnitude
                                    local delay
                                    if tbl10.taxiDelayMode == "距离测算" then
                                        delay = math.clamp(15 + (math.clamp(mag, 2000, 6000) - 2000) / 4000 * 30 + math.random() * 2 - 1, 15, 45)
                                    else
                                        delay = mag > 2000 and math.random(15, 45) or 15
                                    end
                                    task.wait(delay)
                                end
                                hrp.CFrame = CFrame.new(pos)
                                lastPos = pos
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end

    -- 公交车刷钱
    local function fn81()
        local gp = Workspace:FindFirstChild("Gameplay")
        gp = gp and gp:FindFirstChild("Entities")
        gp = gp and gp:FindFirstChild("ClientContent")
        gp = gp and gp:GetChildren()[1]
        return gp and gp:FindFirstChild("Area")
    end
    local function fn82()
        task.spawn(function()
            while true do
                if Settings.bus then
                    local area = fn81()
                    local _, hum, hrp = fn40(localPlayer3)
                    if area and hum and hrp then
                        local seat = hum.SeatPart
                        if seat then
                            local cf = hrp.CFrame
                            seat.CFrame = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, 4.7123889803846897, 0) * cf:ToObjectSpace(seat.CFrame)
                            seat.AssemblyLinearVelocity = Vector3.zero
                            seat.AssemblyAngularVelocity = Vector3.zero
                            task.wait(0.1)
                            hum.Sit = false
                        else
                            hrp.CFrame = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, 4.7123889803846897, 0)
                        end
                        task.wait(5)
                    end
                end
                task.wait(1)
            end
        end)
    end

    -- 自动黑客
    local tbl24 = {}
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
                if not tbl24.hackingMinigame then tbl24.hackingMinigame = framework.hackingMinigame end
                if not tbl24.startMinigame then tbl24.startMinigame = framework.startMinigame end
                if autoHack then
                    framework.hackingMinigame = function() return true end
                    framework.startMinigame = function() return true end
                else
                    if tbl24.hackingMinigame then framework.hackingMinigame = tbl24.hackingMinigame end
                    if tbl24.startMinigame then framework.startMinigame = tbl24.startMinigame end
                end
            end
        end)
    end

    -- 高尔夫刷钱
    local function fn83()
        task.spawn(function()
            local function pick(path)
                local cur = Workspace
                for _, name in ipairs(path) do
                    cur = cur and cur:FindFirstChild(name)
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
                        local ball = pick({ "Gameplay", "Entities", "Content", localPlayer3.Name })
                        local flag = pick({ "Gameplay", "Entities", "Content", "_Flag", "FlagPole", "Part" })
                        if ball and flag and ball:IsA("BasePart") then
                            ball.Position = flag.Position
                        end
                    end)
                end
                task.wait(Settings.golf and 5 or 1)
            end
        end)
    end

    -- =====================================================
    -- 7. 战斗模块（Aura/自瞄/Ragebot/范围/ESP/警察）
    -- =====================================================
    local function fn84(plr, onlyP, onlyC)
        if not plr or plr == localPlayer3 then return false end
        if onlyP then return plr.Team and plr.Team.Name == "Police" end
        if onlyC then return plr.Team and plr.Team.Name == "Civilian" end
        return true
    end
    local function fn85(plr, check)
        if not check then return true end
        return plr:GetAttribute("CombatMode") == true or plr:GetAttribute("Pursuit") == true
    end

    -- 杀戮光环
    do
        local lastAura = 0
        RunService.Heartbeat:Connect(function()
            if not tbl11.auraEnabled or not playerEvent then return end
            local now = tick()
            if now - lastAura < tbl11.auraInterval then return end
            local _, _, hrp = fn40(localPlayer3)
            if not hrp then return end
            local target, bestD = nil, nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if fn84(plr, tbl11.auraOnlyPolice, tbl11.auraOnlyCivilian)
                    and fn62(plr) and fn85(plr, tbl11.auraCombatCheck) then
                    local char = plr.Character
                    local part = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
                    if part then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist <= tbl11.auraRange and (not bestD or dist < bestD) then
                            target, bestD = plr, dist
                        end
                    end
                end
            end
            if target then
                local char = target.Character
                local part = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
                if part then
                    local pos = hrp.Position
                    pcall(function()
                        playerEvent:FireServer("damage", {
                            bodyParts = { { "Head", 1 } },
                            shotCode = { pos, (part.Position - pos).Unit },
                            pos = part.Position,
                            target = target,
                            damageFactor = tbl11.auraDamage,
                            bulletProofTool = false,
                        })
                    end)
                    lastAura = now
                end
            end
        end)
    end

    -- 子弹追踪
    local circle = Drawing.new("Circle")
    circle.Filled = false; circle.NumSides = 64; circle.Visible = false
    local function fn86()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local bestFov = tbl11.bulletFov
        local bestPos = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if fn84(plr, tbl11.bulletOnlyPolice, tbl11.bulletOnlyCivilian)
                and fn62(plr) and fn85(plr, tbl11.bulletCombatCheck) then
                local char = plr.Character
                if char then
                    local part = char:FindFirstChild(tbl11.bulletPart) or char:FindFirstChild("HumanoidRootPart")
                    if part and (part.Position - cam.CFrame.Position).Magnitude <= tbl11.bulletDistance then
                        local sp, onScreen = cam:WorldToScreenPoint(part.Position)
                        if onScreen and sp.Z > 0 then
                            local mag = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if mag < bestFov then bestFov, bestPos = mag, part.Position end
                        end
                    end
                end
            end
        end
        return bestPos
    end
    pcall(function()
        local origRaycast = Workspace.Raycast
        hookfunction(Workspace.Raycast, function(self, origin, dir, params)
            if tbl11.bulletEnabled and origin and dir then
                local _, _, hrp = fn40(localPlayer3)
                if hrp and (origin - hrp.Position).Magnitude < 15 then
                    local p = fn86()
                    if p then dir = (p - origin).Unit * dir.Magnitude end
                end
            end
            return origRaycast(self, origin, dir, params)
        end)
    end)
    RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        circle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        circle.Radius = tbl11.bulletFov
        circle.Thickness = 2
        circle.Color = fn38(5)
        circle.Visible = tbl11.bulletEnabled and tbl11.bulletShowFov
    end)

    -- 自瞄
    local circle2 = Drawing.new("Circle")
    circle2.Filled = false; circle2.NumSides = 64
    local line = Drawing.new("Line")
    local tbl25 = { Top=Drawing.new("Line"), Bottom=Drawing.new("Line"),
        Left=Drawing.new("Line"), Right=Drawing.new("Line"), Center=Drawing.new("Line") }
    for _, v in pairs(tbl25) do v.Thickness = 2; v.Visible = false end
    local tbl26 = {
        ["头"] = { "Head" },
        ["胸"] = { "UpperTorso", "Torso" },
        ["左手"] = { "LeftHand", "Left Arm" },
        ["右手"] = { "RightHand", "Right Arm" },
        ["左腿"] = { "LeftFoot", "Left Leg" },
        ["右腿"] = { "RightFoot", "Right Leg" },
    }
    local function fn87(char)
        local parts = tbl26[tbl12.targetPart] or { "Head" }
        for _, name in ipairs(parts) do
            local p = char:FindFirstChild(name)
            if p then return p end
        end
        return char:FindFirstChild("HumanoidRootPart")
    end
    local function fn88(char)
        if not tbl12.wallCheck then return true end
        local cam = Workspace.CurrentCamera
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = { localPlayer3.Character, cam }
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.IgnoreWater = true
        local target = fn87(char)
        if not target then return false end
        local hit = Workspace:Raycast(cam.CFrame.Position, target.Position - cam.CFrame.Position, params)
        return not hit or hit.Instance:IsDescendantOf(char)
    end
    local function fn89()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local best, bestVal = nil, nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer3 and fn62(plr) and fn84(plr, tbl12.onlyPolice, tbl12.onlyCivilian)
                and fn85(plr, tbl12.combatCheck) then
                if not (tbl12.teamCheck and localPlayer3.Team and plr.Team == localPlayer3.Team) then
                    if tbl12.friendCheck then
                        local ok, isFriend = pcall(function() return localPlayer3:IsFriendsWith(plr.UserId) end)
                        if ok and isFriend then continue end
                    end
                    local char = plr.Character
                    if not char then continue end
                    local part = fn87(char)
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                        or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    if part and hum and root and hum.Health > 0 and fn88(char) then
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local mag = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if mag <= tbl12.fov then
                                local score = mag
                                if tbl12.targetMode == "距离最近" then
                                    local _, _, myHrp = fn40(localPlayer3)
                                    score = myHrp and (myHrp.Position - root.Position).Magnitude or math.huge
                                elseif tbl12.targetMode == "血量最低" then
                                    score = hum.Health
                                end
                                if not bestVal or score < bestVal then
                                    best = { player = plr, part = part, screen = sp }
                                    bestVal = score
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
        local col = fn39(tbl12.color)
        circle2.Position = center
        circle2.Radius = tbl12.fov
        circle2.Thickness = tbl12.fovThickness
        circle2.Color = col
        circle2.Visible = tbl12.enabled and tbl12.showFov

        tbl25.Top.From    = Vector2.new(center.X, center.Y - 5)
        tbl25.Top.To      = Vector2.new(center.X, center.Y - 20)
        tbl25.Bottom.From = Vector2.new(center.X, center.Y + 5)
        tbl25.Bottom.To   = Vector2.new(center.X, center.Y + 20)
        tbl25.Left.From   = Vector2.new(center.X - 5, center.Y)
        tbl25.Left.To     = Vector2.new(center.X - 20, center.Y)
        tbl25.Right.From  = Vector2.new(center.X + 5, center.Y)
        tbl25.Right.To    = Vector2.new(center.X + 20, center.Y)
        tbl25.Center.From = Vector2.new(center.X - 2, center.Y)
        tbl25.Center.To   = Vector2.new(center.X + 2, center.Y)
        for _, v in pairs(tbl25) do v.Color = col; v.Visible = tbl12.showCrosshair end

        line.Visible = false
        if tbl12.enabled then
            local t = fn89()
            if t then
                if tbl12.showTracer then
                    line.From = center
                    line.To = Vector2.new(t.screen.X, t.screen.Y)
                    line.Color = col
                    line.Thickness = 2
                    line.Transparency = 0.5
                    line.Visible = true
                end
                local pos = t.part.Position
                if tbl12.prediction then
                    pos = pos + t.part.AssemblyLinearVelocity * dt * 1.5
                end
                local targetCF = CFrame.new(cam.CFrame.Position, pos)
                cam.CFrame = tbl12.smoothness >= 1 and targetCF or cam.CFrame:Lerp(targetCF, tbl12.smoothness)
            end
        end
    end)

    -- Ragebot
    task.spawn(function()
        while true do
            if tbl13.enabled and playerEvent then
                local _, _, myHrp = fn40(localPlayer3)
                if myHrp then
                    local myPos = myHrp.Position
                    local myJob = fn63(localPlayer3)
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= localPlayer3 and fn84(plr, tbl13.policeLock, tbl13.civilianLock)
                            and fn85(plr, tbl13.combatCheck) then
                            local char, hum = fn40(plr)
                            local part = char and (char:FindFirstChild(tbl13.bodyPart) or fn87(char))
                            if char and hum and part and hum.Health > 0 then
                                if tbl13.jobCheck and fn63(plr) == myJob then continue end
                                if (part.Position - myPos).Magnitude <= tbl13.range then
                                    if tbl13.wallCheck then
                                        local params = RaycastParams.new()
                                        params.FilterDescendantsInstances = { localPlayer3.Character, Workspace.CurrentCamera }
                                        params.FilterType = Enum.RaycastFilterType.Exclude
                                        local hit = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position,
                                            part.Position - Workspace.CurrentCamera.CFrame.Position, params)
                                        if hit and not hit.Instance:IsDescendantOf(char) then continue end
                                    end
                                    pcall(function()
                                        playerEvent:FireServer("damage", {
                                            bodyParts = { { tbl13.bodyPart, 1 } },
                                            shotCode = { myPos, (part.Position - myPos).Unit },
                                            pos = part.Position,
                                            target = plr,
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
            task.wait(tbl13.interval)
        end
    end)

    -- 范围 Hitbox
    local tbl27 = {}
    local function fn51(hrp)
        hrp = hrp and hrp:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local orig = tbl27[hrp]
        if orig then
            hrp.Size = orig.Size
            hrp.Transparency = orig.Transparency
            hrp.Material = orig.Material
            hrp.CanCollide = orig.CanCollide
            hrp.Color = orig.Color
        end
        for _, n in ipairs({ "PY_HitboxHighlight", "PY_HitboxLight" }) do
            local d = hrp:FindFirstChild(n)
            if d then d:Destroy() end
        end
    end
    local function fn91(char)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not tbl27[hrp] then
            tbl27[hrp] = { Size = hrp.Size, Transparency = hrp.Transparency, Material = hrp.Material,
                CanCollide = hrp.CanCollide, Color = hrp.Color }
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
            local hl = hrp:FindFirstChild("PY_HitboxHighlight") or Instance.new("Highlight")
            hl.Name = "PY_HitboxHighlight"
            hl.FillTransparency = 1
            hl.OutlineColor = hrp.Color
            hl.OutlineTransparency = tbl15.transparency
            hl.Parent = hrp
        else
            local hl = hrp:FindFirstChild("PY_HitboxHighlight")
            if hl then hl:Destroy() end
        end
        if tbl15.glow then
            local lt = hrp:FindFirstChild("PY_HitboxLight") or Instance.new("PointLight")
            lt.Name = "PY_HitboxLight"
            lt.Brightness = 5; lt.Range = 15; lt.Color = hrp.Color
            lt.Parent = hrp
        else
            local lt = hrp:FindFirstChild("PY_HitboxLight")
            if lt then lt:Destroy() end
        end
    end
    RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer3 and fn40(plr) then
                if tbl15.teamCheck and localPlayer3.Team and plr.Team == localPlayer3.Team then continue end
                fn91(select(1, fn40(plr)))
            end
        end
        if tbl15.affectNPC then
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(d) then
                    fn91(d)
                end
            end
        end
    end)

    -- ESP
    local function fn92(plr)
        local isCiv = plr.Team and plr.Team.Name == "Civilian"
        if isCiv then return plr:GetAttribute("CombatMode") or plr:GetAttribute("Pursuit") end
        return isCiv
    end
    local function fn93(plr)
        if not tbl16.enabled or plr == localPlayer3 then return false end
        if not fn40(plr) then return false end
        if tbl16.showFugitive and fn92(plr) then return true end
        local sel, total = 0, 0
        for _, v in pairs(tbl16.selectedTeams) do
            total = total + 1
            if v then sel = sel + 1 end
        end
        if sel == 0 or sel >= total then return true end
        local name = plr.Team and plr.Team.Name
        if not name then return true end
        if tbl16.selectedTeams[name] == true then return true end
        for k, label in pairs(tbl17) do
            if (label == name or k == name) and tbl16.selectedTeams[k] then return true end
        end
        return false
    end
    local function fn52(plr)
        local t = tbl16.trackers[plr]
        if not t then return end
        for _, v in pairs(t) do
            pcall(function()
                if typeof(v) == "RBXScriptConnection" then v:Disconnect()
                elseif typeof(v) == "Instance" then v:Destroy()
                elseif type(v) == "userdata" and v.Remove then v:Remove() end
            end)
        end
        tbl16.trackers[plr] = nil
    end
    local function getEspHolder()
        local parent = v29 or getHui() or localPlayer3:FindFirstChild("PlayerGui")
        v29 = parent
        if not parent then return end
        local holder = parent:FindFirstChild("PYHubESP")
        if holder then return holder end
        local ok, gui = pcall(function()
            local sg = Instance.new("ScreenGui")
            sg.Name = "PYHubESP"; sg.ResetOnSpawn = false
            sg.IgnoreGuiInset = true; sg.DisplayOrder = 999
            sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            sg.Parent = parent
            return sg
        end)
        if ok then return gui end
        return parent
    end
    local function fn94(plr)
        if tbl16.trackers[plr] or not fn93(plr) then return end
        local char, _, hrp = fn40(plr)
        if not char or not hrp then return end
        local holder = getEspHolder()
        if not holder then return end
        local bb = Instance.new("BillboardGui")
        bb.Name = "PlayerESP_" .. plr.Name
        bb.AlwaysOnTop = true; bb.Size = UDim2.new(8, 0, 3, 0)
        bb.StudsOffset = Vector3.new(0, 3.5, 0); bb.MaxDistance = 10000
        bb.Adornee = hrp; bb.Parent = holder
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.fromScale(1, 1); frame.Parent = bb
        local lbl1 = Instance.new("TextLabel")
        lbl1.Size = UDim2.new(1, 0, 0.55, 0)
        lbl1.BackgroundTransparency = 1
        lbl1.Font = Enum.Font.GothamBold
        lbl1.TextSize = 16; lbl1.TextStrokeTransparency = 0
        lbl1.Text = plr.Name; lbl1.TextColor3 = Color3.fromRGB(0, 255, 0)
        lbl1.Parent = frame
        local lbl2 = Instance.new("TextLabel")
        lbl2.Size = UDim2.new(1, 0, 0.45, 0)
        lbl2.Position = UDim2.new(0, 0, 0.55, 0)
        lbl2.BackgroundTransparency = 1
        lbl2.Font = Enum.Font.Gotham; lbl2.TextSize = 14
        lbl2.TextStrokeTransparency = 0
        lbl2.TextColor3 = Color3.fromRGB(0, 255, 0); lbl2.Parent = frame
        local hl = Instance.new("Highlight")
        hl.Name = "PlayerESP_Highlight"; hl.Adornee = char
        hl.FillTransparency = 0.65; hl.OutlineTransparency = 0
        pcall(function() hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
        hl.Parent = char
        local tr
        pcall(function()
            if Drawing and Drawing.new then
                tr = Drawing.new("Line")
                tr.Thickness = 1; tr.Transparency = 0.5; tr.Visible = false
            end
        end)
        tbl16.trackers[plr] = {
            bill = bb, highlight = hl, tracer = tr,
            update = RunService.Heartbeat:Connect(function()
                local c, hum, root = fn40(plr)
                if not fn93(plr) or not c or not root then
                    if tr then tr.Visible = false end
                    if bb.Parent then bb.Enabled = false end
                    return
                end
                bb.Adornee = root; bb.Enabled = true
                if hl.Parent ~= c then hl.Parent = c end
                hl.Adornee = c
                local fug = fn92(plr)
                local name = plr.Team and plr.Team.Name
                local col = fug and Color3.fromRGB(255, 0, 0) or tbl28[name] or Color3.fromRGB(0, 255, 0)
                lbl1.Text = "[" .. (fug and "逃犯" or tbl17[name] or name or "未知") .. "] " .. plr.Name
                lbl1.TextColor3 = col
                lbl1.Visible = tbl16.name
                hl.FillColor = col; hl.OutlineColor = col
                hl.Enabled = tbl16.highlight
                local _, _, myHrp = fn40(localPlayer3)
                local parts = {}
                if tbl16.distance and myHrp then
                    table.insert(parts, string.format("%.1f", (myHrp.Position - root.Position).Magnitude))
                end
                if tbl16.health and hum then
                    table.insert(parts, tostring(math.floor(hum.Health)))
                end
                lbl2.Text = #parts > 0 and "[" .. table.concat(parts, "/") .. "]" or ""
                lbl2.TextColor3 = col
                lbl2.Visible = tbl16.distance or tbl16.health
                local cam = Workspace.CurrentCamera
                if tr then
                    if tbl16.tracer and cam then
                        local sp, onScreen = cam:WorldToViewportPoint(root.Position)
                        if onScreen then
                            local vs = cam.ViewportSize
                            if tbl16.tracerOrigin == "屏幕中心" then
                                tr.From = Vector2.new(vs.X / 2, vs.Y / 2)
                            elseif tbl16.tracerOrigin == "屏幕顶部" then
                                tr.From = Vector2.new(vs.X / 2, 0)
                            else
                                tr.From = Vector2.new(vs.X / 2, vs.Y)
                            end
                            tr.To = Vector2.new(sp.X, sp.Y)
                            tr.Color = col; tr.Visible = true
                        else
                            tr.Visible = false
                        end
                    else
                        tr.Visible = false
                    end
                end
            end),
        }
    end
    local function fn53()
        for k in pairs(tbl16.trackers) do
            if not fn93(k) then fn52(k) end
        end
        if tbl16.enabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= localPlayer3 and fn93(plr) and not tbl16.trackers[plr] then
                    pcall(fn94, plr)
                end
            end
        end
    end
    do
        local function hookEsp(plr)
            if plr == localPlayer3 then return end
            plr.CharacterAdded:Connect(function()
                task.wait(0.25)
                if tbl16.enabled then fn52(plr); pcall(fn94, plr) end
            end)
        end
        for _, plr in ipairs(Players:GetPlayers()) do hookEsp(plr) end
        Players.PlayerAdded:Connect(hookEsp)
        Players.PlayerRemoving:Connect(fn52)
        local last = 0
        RunService.Heartbeat:Connect(function()
            if not tbl16.enabled then return end
            if tick() - last < 0.2 then return end
            last = tick()
            fn53()
        end)
    end

    -- 警察：自动铐
    local PoliceSettings = { range = 200, delay = 0.5, combatCheck = false, teleport = false }
    local cuffThread = nil
    local function fn54()
        if cuffThread then return end
        cuffThread = task.spawn(function()
            while Settings.autoCuff do
                local _, _, myHrp = fn40(localPlayer3)
                if myHrp and playerFunc then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= localPlayer3 and fn62(plr) and fn85(plr, PoliceSettings.combatCheck) then
                            local _, _, tHrp = fn40(plr)
                            if tHrp and (tHrp.Position - myHrp.Position).Magnitude <= PoliceSettings.range then
                                pcall(function() playerFunc:InvokeServer("handcuff", plr, false) end)
                            end
                        end
                    end
                    if PoliceSettings.teleport then
                        local bestD, bestPlr = nil, nil
                        for _, plr in ipairs(Players:GetPlayers()) do
                            local flag = plr ~= localPlayer3 and plr.Team and plr.Team.Name == "Civilian"
                            if flag then flag = (plr:GetAttribute("WantedLevel") or 0) > 0 end
                            if flag then
                                local _, _, tHrp = fn40(plr)
                                if tHrp then
                                    local d = (tHrp.Position - myHrp.Position).Magnitude
                                    if d <= PoliceSettings.range and (not bestD or d < bestD) then
                                        bestD, bestPlr = d, plr
                                    end
                                end
                            end
                        end
                        if bestPlr then
                            local _, _, tHrp = fn40(bestPlr)
                            if tHrp then
                                myHrp.CFrame = CFrame.new(tHrp.Position - tHrp.CFrame.LookVector * 3)
                            end
                        end
                    end
                end
                task.wait(PoliceSettings.delay)
            end
            cuffThread = nil
        end)
    end

    -- =====================================================
    -- 8. 移动模块
    -- =====================================================
    local MovementSettings = {
        walkEnabled = false, walkSpeed = 200,
        jumpEnabled = false, jumpPower = 50, jumpMultiplier = 1, infiniteJump = false,
        flyEnabled = false, flySpeed = 30, flyMode = "传送", noclip = false,
    }
    local FlyState = { walkConn = nil, jumpConn = nil, flyConn = nil,
        bodyVelocity = nil, bodyGyro = nil, noclipConn = nil, collisionCache = {} }
    local controls
    pcall(function()
        controls = require(localPlayer3.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
    end)

    local function fn60()
        if FlyState.walkConn then FlyState.walkConn:Disconnect(); FlyState.walkConn = nil end
        if not MovementSettings.walkEnabled then return end
        FlyState.walkConn = RunService.Heartbeat:Connect(function()
            local _, hum = fn40(localPlayer3)
            if hum and MovementSettings.walkEnabled then hum.WalkSpeed = MovementSettings.walkSpeed end
        end)
    end
    local function fn96(hum)
        if not hum then return false end
        local s = hum:GetState()
        return s == Enum.HumanoidStateType.Landed
            or s == Enum.HumanoidStateType.Running
            or s == Enum.HumanoidStateType.RunningNoPhysics
    end
    local function fn55()
        if FlyState.jumpConn then FlyState.jumpConn:Disconnect(); FlyState.jumpConn = nil end
    end
    local function fn56()
        fn55()
        if not MovementSettings.jumpEnabled then return end
        FlyState.jumpConn = UserInputService.JumpRequest:Connect(function()
            if not MovementSettings.jumpEnabled then return end
            local _, hum, hrp = fn40(localPlayer3)
            if not hum or not hrp or hum.Health <= 0 then return end
            if not MovementSettings.infiniteJump and not fn96(hum) then return end
            hrp.CFrame = hrp.CFrame + Vector3.new(0, MovementSettings.jumpPower * MovementSettings.jumpMultiplier * 0.1, 0)
        end)
    end
    local function fn97()
        if FlyState.flyConn then FlyState.flyConn:Disconnect(); FlyState.flyConn = nil end
        if FlyState.bodyVelocity then FlyState.bodyVelocity:Destroy(); FlyState.bodyVelocity = nil end
        if FlyState.bodyGyro then FlyState.bodyGyro:Destroy(); FlyState.bodyGyro = nil end
        local _, hum = fn40(localPlayer3)
        if hum then hum.PlatformStand = false; hum.AutoRotate = true end
    end
    local function flyTeleport()
        local _, hum, hrp = fn40(localPlayer3)
        if not hrp or not hum then return end
        MovementSettings.flyEnabled = true
        hum.AutoRotate = false
        FlyState.flyConn = RunService.RenderStepped:Connect(function(dt)
            if not MovementSettings.flyEnabled or MovementSettings.flyMode ~= "传送" then return end
            local _, h, r = fn40(localPlayer3)
            local cam = Workspace.CurrentCamera
            if not r or not h or not cam then return end
            local mv = controls and controls:GetMoveVector() or Vector3.zero
            local dir = cam.CFrame.LookVector * -mv.Z + cam.CFrame.RightVector * mv.X
            local up = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then up = -1 end
            r.CFrame = r.CFrame + (dir + Vector3.new(0, up, 0)) * MovementSettings.flySpeed * dt
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
            h:ChangeState(Enum.HumanoidStateType.Climbing)
        end)
    end
    local function flyPhysics()
        local _, hum, hrp = fn40(localPlayer3)
        if not hrp or not hum then return end
        MovementSettings.flyEnabled = true
        local bv = Instance.new("BodyVelocity")
        bv.Name = "PYPlayerFlyVelocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero; bv.Parent = hrp
        FlyState.bodyVelocity = bv
        local bg = Instance.new("BodyGyro")
        bg.Name = "PYPlayerFlyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 90000; bg.Parent = hrp
        FlyState.bodyGyro = bg
        hum.PlatformStand = true; hum.AutoRotate = false
        FlyState.flyConn = RunService.RenderStepped:Connect(function()
            if not MovementSettings.flyEnabled or MovementSettings.flyMode ~= "物理" then return end
            local _, h, r = fn40(localPlayer3)
            local cam = Workspace.CurrentCamera
            if not r or not h or not cam then return end
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
    end
    local function fn57()
        fn97()
        if MovementSettings.flyMode == "物理" then flyPhysics() else flyTeleport() end
    end
    local function clearCollision()
        for part, orig in pairs(FlyState.collisionCache) do
            if part and part.Parent then pcall(function() part.CanCollide = orig end) end
        end
        FlyState.collisionCache = {}
    end
    local function fn58()
        if FlyState.noclipConn then FlyState.noclipConn:Disconnect(); FlyState.noclipConn = nil end
        clearCollision()
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

    localPlayer3.CharacterAdded:Connect(function()
        task.wait(0.5)
        FlyState.collisionCache = {}
        if MovementSettings.walkEnabled then fn60() end
        if MovementSettings.jumpEnabled then fn56() end
        if MovementSettings.noclip then fn58() end
        if MovementSettings.flyEnabled then
            local m = MovementSettings.flyMode
            MovementSettings.flyEnabled = false
            task.wait(0.2)
            MovementSettings.flyMode = m
            fn57()
        end
    end)

    -- 启动主循环
    pcall(fn66)
    pcall(fn73)
    pcall(fn77)
    pcall(fn79)
    pcall(fn80)
    pcall(fn82)
    pcall(fn83)

    -- =====================================================
    -- 9. UI 构建
    -- =====================================================
    local function fn59()
        if v27 then pcall(function() v27:Destroy() end); v27 = nil end

        v27 = lib:CreateWindow({
            Title = "PY Hub/圣奥里<font color='#00FF00'>破解版</font>",
            Icon = "zap", IconTransparency = 0.5, IconThemed = true,
            Author = "Xi.Team", Folder = "PYHub",
            Size = UDim2.fromOffset(640, 460), Transparent = true,
            Theme = "Dark",
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

        local timeTag = v27:Tag({ Title = "当前时间: 00:00:00", Icon = "clock",
            Color = Color3.fromHex("#FFFFFF"), Border = true })
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
                    Title = "PYHub<font color='#00FF00'>1.0</font>",
                    Icon = "crown", CornerRadius = UDim.new(1, 16), StrokeThickness = 1.5,
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
            local stroke = Instance.new("UIStroke")
            stroke.Name = "MainBorder"; stroke.Thickness = 3
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.LineJoinMode = Enum.LineJoinMode.Round
            stroke.Enabled = tbl8.borderEnabled; stroke.Parent = main
            local grad = Instance.new("UIGradient")
            grad.Name = "BorderGradient"; grad.Parent = stroke
        end

        -- 公告 / 主页 / UI设置 页（完整版）
        local tabNotice = v27:Tab({ Title = "公告", Icon = "message-circle", Locked = false })
        tabNotice:Paragraph({ Title = "破解版", Desc = "XI团队暴打所有联邦狗", Image = "message-circle", ImageSize = 32 })
        tabNotice:Paragraph({ Title = "开源人", Desc = "苏达", Image = "user", ImageSize = 32 })
        local tabHome = v27:Tab({ Title = "主页", Icon = "home", Locked = false })
        tabHome:Paragraph({ Title = "PY Hub", Desc = "圣奥里精简版", Image = "zap", ImageSize = 32 })
        tabHome:Paragraph({ Title = "玩家", Desc = "当前服务器ID: " .. game.PlaceId, Image = "users", ImageSize = 32 })

        local tabUI = v27:Tab({ Title = "UI设置", Icon = "settings", Locked = false })
        tabUI:Toggle({ Title = "自定义光标", Value = false,
            Callback = function(v) pcall(function() v27:ToggleCustomCursor(v) end) end })
        tabUI:Dropdown({ Title = "通知位置", Values = { "左", "右" }, Value = "右",
            Callback = function(v) pcall(function() lib:SetNotifySide(v == "左" and "Left" or "Right") end) end })
        tabUI:Dropdown({ Title = "DPI缩放",
            Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" }, Value = "100%",
            Callback = function(v)
                local n = tonumber(v:gsub("%%", ""))
                if n then pcall(function() v27:SetDPIScale(n / 100) end) end
            end })
        tabUI:Keybind({ Title = "菜单按键", Value = "RightShift",
            Callback = function(v) pcall(function() v27:SetToggleKey(Enum.KeyCode[v]) end) end })
        tabUI:Divider()
        tabUI:Toggle({ Title = "随机背景图", Value = tbl8.randomBg,
            Callback = function(v) tbl8.randomBg = v end })
        tabUI:Divider()
        tabUI:Toggle({ Title = "启用边框颜色", Value = tbl8.borderEnabled,
            Callback = function(v)
                tbl8.borderEnabled = v
                local m = v27 and v27.UIElements and v27.UIElements.Main
                m = m and m:FindFirstChild("MainBorder")
                if m then m.Enabled = v end
            end })
        tabUI:Dropdown({ Title = "边框颜色",
            Values = { "旋转彩虹", "默认白色", "红色", "橙色", "黄色", "绿色", "青色", "蓝色", "紫色", "粉色" },
            Value = "旋转彩虹",
            Callback = function(v)
                if v == "旋转彩虹" then fn43(nil, true)
                elseif v == "默认白色" then fn43(Color3.new(1, 1, 1), false)
                else fn43(fn39(v), false) end
            end })
        tabUI:Divider()
        tabUI:Dropdown({ Title = "文字颜色",
            Values = { "默认", "青色", "粉色", "紫色", "橙色", "红色", "绿色", "蓝色", "黄色", "白色", "彩虹" },
            Value = "默认",
            Callback = function(v) v28 = v end })
        tabUI:Button({ Title = "确认应用文字颜色", Icon = "check",
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
            end })

        local section = v27:Section({ Title = "功能", Opened = true })

        -- 主要功能
        local t1 = section:Tab({ Title = "主要功能", Icon = "sliders-h" })
        t1:Toggle({ Title = "无限体力", Default = false, Callback = function(v) Settings.stamina = v end })
        t1:Toggle({ Title = "无限饥饿", Default = false, Callback = function(v) Settings.food = v end })
        t1:Toggle({ Title = "战斗拦截", Default = false, Callback = fn45 })
        t1:Toggle({ Title = "隐身", Default = false, Callback = fn46 })
        t1:Toggle({ Title = "显示隐身悬浮窗", Default = false,
            Callback = function(v) flag10 = v; if v then fn48() else fn47() end end })
        t1:Toggle({ Title = "锁定隐身悬浮窗位置", Default = false,
            Callback = function(v)
                flag9 = v
                if textButton then textButton.Active = not v; textButton.Draggable = not v end
            end })
        t1:Toggle({ Title = "防布娃娃", Default = false, Callback = function(v) Settings.noRagdoll = v end })
        t1:Toggle({ Title = "防摔伤", Default = false, Callback = function(v) Settings.noFallDamage = v end })
        t1:Toggle({ Title = "防越狱拉回", Default = false, Callback = fn49 })
        t1:Toggle({ Title = "无限车速", Default = false, Callback = function(v) Settings.noSpeedLimit = v end })
        t1:Toggle({ Title = "自动捡钱", Default = false, Callback = function(v) Settings.autoMoney = v end })
        t1:Toggle({ Title = "无限子弹", Default = false, Callback = function(v) Settings.infiniteAmmo = v end })
        t1:Toggle({ Title = "快速射击", Default = false,
            Callback = function(v) Settings.rapidFire = v; if v then pcall(fn44) end end })

        -- 刷钱
        local t2 = section:Tab({ Title = "刷钱", Icon = "money-bill-wave" })
        t2:Toggle({ Title = "自动接取任务", Default = false, Callback = function(v) Settings.autoMission = v end })
        t2:Toggle({ Title = "优先高收益任务", Default = false, Callback = function(v) tbl10.priorityHighReward = v end })
        t2:Input({ Title = "接取间隔", Value = "2", PlaceholderText = "输入间隔秒数", ClearTextOnFocus = false,
            Callback = function(v) local n = tonumber(v); if n and n > 0 then tbl10.missionInterval = n end end })
        t2:Toggle({ Title = "安全模式(出租车)", Default = false,
            Callback = function(v)
                tbl10.taxiSafe = v
                if v then local _, _, hrp = fn40(localPlayer3); if hrp then tbl10.taxiOrigin = hrp.Position end end
            end })
        t2:Dropdown({ Title = "出租车延迟模式", Values = { "随机时间", "距离测算" }, Value = "随机时间",
            Callback = function(v) tbl10.taxiDelayMode = v end })
        t2:Toggle({ Title = "出租车刷钱", Default = false, Callback = function(v) Settings.taxi = v end })
        t2:Toggle({ Title = "公交车刷钱", Default = false, Callback = function(v) Settings.bus = v end })
        t2:Toggle({ Title = "农民刷钱", Default = false, Callback = function(v) Settings.farmer = v end })
        t2:Toggle({ Title = "自动黑客小游戏", Default = false, Callback = fn50 })
        t2:Toggle({ Title = "高尔夫刷钱", Default = false, Callback = function(v) Settings.golf = v end })

        -- 战斗 / 自瞄 / Ragebot / 范围 / 玩家 / 警察 / ESP 页
        local t3 = section:Tab({ Title = "战斗", Icon = "crosshairs" })
        t3:Toggle({ Title = "杀戮光环", Default = false, Callback = function(v) tbl11.auraEnabled = v end })
        t3:Toggle({ Title = "只攻击警察", Default = false,
            Callback = function(v) tbl11.auraOnlyPolice = v; if v then tbl11.auraOnlyCivilian = false end end })
        t3:Toggle({ Title = "只攻击平民", Default = false,
            Callback = function(v) tbl11.auraOnlyCivilian = v; if v then tbl11.auraOnlyPolice = false end end })
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
        t4:Toggle({ Title = "只自瞄警察", Default = false,
            Callback = function(v) tbl12.onlyPolice = v; if v then tbl12.onlyCivilian = false end end })
        t4:Toggle({ Title = "只自瞄平民", Default = false,
            Callback = function(v) tbl12.onlyCivilian = v; if v then tbl12.onlyPolice = false end end })
        t4:Toggle({ Title = "战斗检测", Default = false, Callback = function(v) tbl12.combatCheck = v end })
        t4:Dropdown({ Title = "优先锁定模式", Values = { "准心最近", "距离最近", "血量最低" }, Value = "准心最近",
            Callback = function(v) tbl12.targetMode = v end })
        t4:Dropdown({ Title = "瞄准身体部位", Values = { "头", "胸", "左手", "右手", "左腿", "右腿" }, Value = "头",
            Callback = function(v) tbl12.targetPart = v end })
        t4:Slider({ Title = "Fov圈大小", Value = { Min = 1, Max = 500, Default = 50 }, Callback = function(v) tbl12.fov = v end })
        t4:Slider({ Title = "自瞄平滑度", Value = { Min = 1, Max = 10, Default = 10 }, Callback = function(v) tbl12.smoothness = v / 10 end })
        t4:Slider({ Title = "Fov圈厚度", Value = { Min = 1, Max = 5, Default = 2 }, Callback = function(v) tbl12.fovThickness = v end })
        t4:Dropdown({ Title = "颜色选择",
            Values = { "红色", "黄色", "绿色", "蓝色", "紫色", "白色", "黑色", "彩虹色" }, Value = "红色",
            Callback = function(v) tbl12.color = v end })

        local t5 = section:Tab({ Title = "Ragebot", Icon = "bot" })
        t5:Toggle({ Title = "Ragebot", Default = false, Callback = function(v) tbl13.enabled = v end })
        t5:Slider({ Title = "攻击距离", Value = { Min = 10, Max = 500, Default = 150 }, Step = 1, Callback = function(v) tbl13.range = v end })
        t5:Slider({ Title = "攻击间隔", Value = { Min = 0.01, Max = 1, Default = 0.05 }, Step = 0.01, Callback = function(v) tbl13.interval = v end })
        t5:Dropdown({ Title = "攻击部位", Values = { "头部", "躯干", "左臂", "右臂", "左腿", "右腿" }, Value = "头部",
            Callback = function(v) tbl13.bodyPart = tbl14[v] or "Head" end })
        t5:Toggle({ Title = "职业检测", Default = false, Callback = function(v) tbl13.jobCheck = v end })
        t5:Toggle({ Title = "墙壁检测", Default = false, Callback = function(v) tbl13.wallCheck = v end })
        t5:Toggle({ Title = "活体检测", Default = false, Callback = function(v) tbl13.aliveCheck = v end })
        t5:Toggle({ Title = "战斗状态检测", Default = false, Callback = function(v) tbl13.combatCheck = v end })
        t5:Toggle({ Title = "锁定警察", Default = false,
            Callback = function(v) tbl13.policeLock = v; if v then tbl13.civilianLock = false end end })
        t5:Toggle({ Title = "锁定平民", Default = false,
            Callback = function(v) tbl13.civilianLock = v; if v then tbl13.policeLock = false end end })
        t5:Toggle({ Title = "弹道显示", Default = false, Callback = function(v) tbl13.beam = v end })

        local t6 = section:Tab({ Title = "范围", Icon = "bullseye" })
        t6:Toggle({ Title = "开启/关闭范围", Default = false,
            Callback = function(v)
                tbl15.active = v
                if not v then
                    for _, p in ipairs(Players:GetPlayers()) do if p.Character then fn51(p.Character) end end
                end
            end })
        t6:Input({ Title = "范围大小设置", Value = "10",
            Callback = function(v) local n = tonumber(v); if n and n > 0 then tbl15.size = n end end })
        t6:Input({ Title = "范围透明度设置(0-1)", Value = "0.7",
            Callback = function(v)
                local n = tonumber(v)
                if n and n >= 0 and n <= 1 then tbl15.transparency = n end
            end })
        t6:Dropdown({ Title = "选择范围颜色",
            Values = { "红色", "蓝色", "黄色", "绿色", "青色", "橙色", "紫色", "白色", "黑色", "彩虹色" }, Value = "红色",
            Callback = function(v) tbl15.color = v; tbl15.rainbow = (v == "彩虹色") end })
        t6:Dropdown({ Title = "选择范围材质",
            Values = { "Neon", "Plastic", "Wood", "Slate", "Concrete", "Metal", "SmoothPlastic" }, Value = "Neon",
            Callback = function(v) tbl15.material = v end })
        t6:Toggle({ Title = "NPC范围", Default = false, Callback = function(v) tbl15.affectNPC = v end })
        t6:Toggle({ Title = "队伍检测", Default = false, Callback = function(v) tbl15.teamCheck = v end })
        t6:Toggle({ Title = "活体检测", Default = false, Callback = function(v) tbl15.checkCorpses = v end })
        t6:Toggle({ Title = "显示轮廓", Default = false, Callback = function(v) tbl15.outline = v end })
        t6:Toggle({ Title = "启用/禁用碰撞", Default = false, Callback = function(v) tbl15.collision = v end })
        t6:Toggle({ Title = "发光效果", Default = false, Callback = function(v) tbl15.glow = v end })
        t6:Toggle({ Title = "脉动效果", Default = false, Callback = function(v) tbl15.pulse = v end })

        local t7 = section:Tab({ Title = "玩家", Icon = "user" })
        t7:Toggle({ Title = "开启/关闭跳跃", Default = false,
            Callback = function(v) MovementSettings.jumpEnabled = v; if v then fn56() else fn55() end end })
        t7:Slider({ Title = "设置跳跃高度", Value = { Min = 50, Max = 400, Default = 50 }, Callback = function(v) MovementSettings.jumpPower = v end })
        t7:Slider({ Title = "设置跳跃倍数", Value = { Min = 1, Max = 10, Default = 1 }, Callback = function(v) MovementSettings.jumpMultiplier = v end })
        t7:Toggle({ Title = "无限跳跃", Default = false, Callback = function(v) MovementSettings.infiniteJump = v end })

        local t8 = section:Tab({ Title = "警察功能", Icon = "handcuffs" })
        t8:Toggle({ Title = "自动铐", Default = false,
            Callback = function(v) Settings.autoCuff = v; if v then fn54() end end })
        t8:Toggle({ Title = "自动传送", Default = false, Callback = function(v) PoliceSettings.teleport = v end })
        t8:Toggle({ Title = "战斗检测", Default = false, Callback = function(v) PoliceSettings.combatCheck = v end })
        t8:Slider({ Title = "范围", Value = { Min = 10, Max = 500, Default = 200 }, Step = 5, Callback = function(v) PoliceSettings.range = v end })
        t8:Slider({ Title = "间隔", Value = { Min = 0.1, Max = 3, Default = 0.5 }, Step = 0.1, Callback = function(v) PoliceSettings.delay = v end })

        local t9 = section:Tab({ Title = "ESP", Icon = "eye" })
        t9:Toggle({ Title = "玩家透视总开关", Default = false,
            Callback = function(v)
                if type(v) == "table" then v = v.Value end
                tbl16.enabled = (v == true)
                if not tbl16.enabled then
                    for k in pairs(tbl16.trackers) do fn52(k) end
                else
                    pcall(fn53)
                end
            end })
        t9:Toggle({ Title = "显示名字", Default = true, Callback = function(v) tbl16.name = v end })
        t9:Toggle({ Title = "显示距离", Default = true, Callback = function(v) tbl16.distance = v end })
        t9:Toggle({ Title = "显示血量", Default = true, Callback = function(v) tbl16.health = v end })
        t9:Toggle({ Title = "显示高亮", Default = true, Callback = function(v) tbl16.highlight = v end })
        t9:Toggle({ Title = "显示追踪线", Default = false, Callback = function(v) tbl16.tracer = v end })
        t9:Dropdown({ Title = "追踪线起点", Values = { "屏幕底部", "屏幕中心", "屏幕顶部" }, Value = "屏幕底部",
            Callback = function(v) tbl16.tracerOrigin = v end })

        local teamList = { "逃犯", "厨师", "平民", "配送员", "农民", "消防员", "警察", "医护人员", "囚犯", "道路服务", "交通" }
        t9:Dropdown({ Title = "选择透视队伍", Values = teamList, Value = teamList,
            Multi = true, AllowNone = true,
            Callback = function(v)
                for k in pairs(tbl16.selectedTeams) do tbl16.selectedTeams[k] = false end
                tbl16.showFugitive = false
                if type(v) ~= "table" then return end
                local function apply(label)
                    if label == "逃犯" then tbl16.showFugitive = true; return end
                    for k, name in pairs(tbl17) do
                        if name == label or k == label then tbl16.selectedTeams[k] = true end
                    end
                end
                if v[1] ~= nil then
                    for _, val in ipairs(v) do apply(val) end
                else
                    for k, val in pairs(v) do
                        if val == true then apply(k)
                        elseif type(val) == "string" then apply(val) end
                    end
                end
            end })

        v27:OnClose(function() flag8 = false; v27 = nil end)
        v27:OnDestroy(function() flag8 = false; v27 = nil end)
    end

    -- =====================================================
    -- 10. 启动
    -- =====================================================
    task.defer(function()
        local ok, err = pcall(fn59)
        if not ok then warn("[PY Hub] UI 启动失败: " .. tostring(err)) end
    end)

    return true
end

-- =====================================================
-- 11. 调用入口
-- =====================================================
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
            function() end
        )
        if not ok then warn("[PY Hub] 启动失败:", err) end
    end)
end

return PYHubEntry