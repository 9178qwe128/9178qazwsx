-- ========== KAN · 自动出租车（防封增强版） ==========
-- 在原版基础上添加：随机延迟、鼠标偏移、人机验证检测、风险控制

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- ========== 防封配置 ==========
local AntiBan = {
    Enabled = true,
    MinDelay = 0.6,      -- 最小延迟（秒）
    MaxDelay = 1.8,      -- 最大延迟（秒）
    OffsetRange = 20,    -- 鼠标偏移范围
    ErrorRate = 0.05,    -- 错误率（5%概率点偏）
    BreakInterval = 120, -- 休息间隔（秒）
    BreakDuration = 20,  -- 休息时长（秒）
}

-- ========== UI创建（保持原样） ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = Player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 220)
mainFrame.Position = UDim2.new(0.5, -120, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local outerGlow = Instance.new("Frame")
outerGlow.Size = UDim2.new(1, 12, 1, 12)
outerGlow.Position = UDim2.new(0, -6, 0, -6)
outerGlow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
outerGlow.BackgroundTransparency = 0.7
outerGlow.BorderSizePixel = 0
outerGlow.ZIndex = 0
outerGlow.Parent = mainFrame

local outerGlowCorner = Instance.new("UICorner")
outerGlowCorner.CornerRadius = UDim.new(0, 16)
outerGlowCorner.Parent = outerGlow

local glowBorder = Instance.new("Frame")
glowBorder.Size = UDim2.new(1, 6, 1, 6)
glowBorder.Position = UDim2.new(0, -3, 0, -3)
glowBorder.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
glowBorder.BackgroundTransparency = 0.4
glowBorder.BorderSizePixel = 0
glowBorder.ZIndex = 1
glowBorder.Parent = mainFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 14)
glowCorner.Parent = glowBorder

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 100, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 100, 255)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(200, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
})
gradient.Rotation = 0
gradient.Parent = glowBorder

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "⚡ KAN · 自动出租车"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(0.8, 0, 0, 3)
titleLine.Position = UDim2.new(0.1, 0, 0, 40)
titleLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleLine.BorderSizePixel = 0
titleLine.Parent = mainFrame

local titleLineGlow = Instance.new("Frame")
titleLineGlow.Size = UDim2.new(1, 10, 1, 6)
titleLineGlow.Position = UDim2.new(0, -5, 0, -1.5)
titleLineGlow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleLineGlow.BackgroundTransparency = 0.6
titleLineGlow.BorderSizePixel = 0
titleLineGlow.Parent = titleLine

local lineGradient = Instance.new("UIGradient")
lineGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 100, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
})
lineGradient.Parent = titleLine

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 48)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⏸️ 已停止"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextScaled = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local orderCountLabel = Instance.new("TextLabel")
orderCountLabel.Size = UDim2.new(0.5, 0, 0, 25)
orderCountLabel.Position = UDim2.new(0, 10, 0, 78)
orderCountLabel.BackgroundTransparency = 1
orderCountLabel.Text = "📦 接单: 0"
orderCountLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
orderCountLabel.TextScaled = true
orderCountLabel.TextXAlignment = Enum.TextXAlignment.Left
orderCountLabel.Font = Enum.Font.GothamBold
orderCountLabel.Parent = mainFrame

local teleportCountLabel = Instance.new("TextLabel")
teleportCountLabel.Size = UDim2.new(0.5, 0, 0, 25)
teleportCountLabel.Position = UDim2.new(0.5, 0, 0, 78)
teleportCountLabel.BackgroundTransparency = 1
teleportCountLabel.Text = "🚗 传送: 0"
teleportCountLabel.TextColor3 = Color3.fromRGB(70, 150, 255)
teleportCountLabel.TextScaled = true
teleportCountLabel.TextXAlignment = Enum.TextXAlignment.Left
teleportCountLabel.Font = Enum.Font.GothamBold
teleportCountLabel.Parent = mainFrame

local orderStatusLabel = Instance.new("TextLabel")
orderStatusLabel.Size = UDim2.new(1, 0, 0, 22)
orderStatusLabel.Position = UDim2.new(0, 10, 0, 105)
orderStatusLabel.BackgroundTransparency = 1
orderStatusLabel.Text = "🔄 等待接单..."
orderStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
orderStatusLabel.TextScaled = true
orderStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
orderStatusLabel.Font = Enum.Font.Gotham
orderStatusLabel.Parent = mainFrame

-- 防封状态标签（新增）
local antiBanLabel = Instance.new("TextLabel")
antiBanLabel.Size = UDim2.new(0.5, 0, 0, 18)
antiBanLabel.Position = UDim2.new(0.5, 0, 0, 48)
antiBanLabel.BackgroundTransparency = 1
antiBanLabel.Text = "🛡️"
antiBanLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
antiBanLabel.TextScaled = true
antiBanLabel.TextXAlignment = Enum.TextXAlignment.Right
antiBanLabel.Font = Enum.Font.Gotham
antiBanLabel.Parent = mainFrame

local dotIndicator = Instance.new("Frame")
dotIndicator.Size = UDim2.new(0, 14, 0, 14)
dotIndicator.Position = UDim2.new(0, 0, 0, 48)
dotIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
dotIndicator.BorderSizePixel = 0
dotIndicator.Parent = mainFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dotIndicator

local dotGlow = Instance.new("Frame")
dotGlow.Size = UDim2.new(1, 12, 1, 12)
dotGlow.Position = UDim2.new(0, -6, 0, -6)
dotGlow.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
dotGlow.BackgroundTransparency = 0.6
dotGlow.BorderSizePixel = 0
dotGlow.Parent = dotIndicator

local dotGlowCorner = Instance.new("UICorner")
dotGlowCorner.CornerRadius = UDim.new(1, 0)
dotGlowCorner.Parent = dotGlow

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 140, 0, 40)
toggleButton.Position = UDim2.new(0.5, -70, 0, 150)
toggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
toggleButton.Text = "▶️ 启动"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BorderSizePixel = 0
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

local btnOuterGlow = Instance.new("Frame")
btnOuterGlow.Size = UDim2.new(1, 12, 1, 12)
btnOuterGlow.Position = UDim2.new(0, -6, 0, -6)
btnOuterGlow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
btnOuterGlow.BackgroundTransparency = 0.7
btnOuterGlow.BorderSizePixel = 0
btnOuterGlow.ZIndex = 0
btnOuterGlow.Parent = toggleButton

local btnOuterCorner = Instance.new("UICorner")
btnOuterCorner.CornerRadius = UDim.new(0, 11)
btnOuterCorner.Parent = btnOuterGlow

local btnGlow = Instance.new("Frame")
btnGlow.Size = UDim2.new(1, 6, 1, 6)
btnGlow.Position = UDim2.new(0, -3, 0, -3)
btnGlow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
btnGlow.BackgroundTransparency = 0.5
btnGlow.BorderSizePixel = 0
btnGlow.ZIndex = 0
btnGlow.Parent = toggleButton

local btnGlowCorner = Instance.new("UICorner")
btnGlowCorner.CornerRadius = UDim.new(0, 10)
btnGlowCorner.Parent = btnGlow

-- ========== 防封核心函数 ==========

-- 获取随机延迟
local function GetRandomDelay()
    if not AntiBan.Enabled then return 0.05 end
    return AntiBan.MinDelay + math.random() * (AntiBan.MaxDelay - AntiBan.MinDelay)
end

-- 获取随机偏移
local function GetRandomOffset()
    if not AntiBan.Enabled then return 0 end
    return math.random(-AntiBan.OffsetRange, AntiBan.OffsetRange)
end

-- 防封点击（替代原来的ClickAt）
local function SafeClick(x, y)
    if not AntiBan.Enabled then
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        return
    end
    
    -- 随机偏移
    local offsetX = GetRandomOffset()
    local offsetY = GetRandomOffset()
    local clickX = x + offsetX
    local clickY = y + offsetY
    
    -- 模拟鼠标移动（更自然的轨迹）
    local steps = math.random(3, 6)
    for i = 1, steps do
        local progress = i / steps
        local currentX = x + offsetX * progress + math.random(-3, 3)
        local currentY = y + offsetY * progress + math.random(-3, 3)
        VirtualInputManager:SendMouseMoveEvent(currentX, currentY, game, 0)
        task.wait(GetRandomDelay() * 0.1)
    end
    
    -- 随机错误（点偏）
    if math.random() < AntiBan.ErrorRate then
        clickX = clickX + math.random(-15, 15)
        clickY = clickY + math.random(-15, 15)
    end
    
    -- 按下
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
    
    -- 随机点击持续时间（模拟人类）
    local duration = 0.05 + math.random() * 0.15
    task.wait(duration)
    
    -- 释放
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
    
    -- 释放后延迟
    task.wait(GetRandomDelay() * 0.2)
end

-- ========== 人机验证检测 ==========
local function CheckCaptcha()
    local gui = Player.PlayerGui
    if not gui then return false end
    
    local captchaPatterns = {"captcha", "verification", "verify", "robot", "human", "confirm"}
    
    for _, child in ipairs(gui:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            local name = (child.Name or ""):lower()
            local text = (child.Text or ""):lower()
            
            for _, pattern in ipairs(captchaPatterns) do
                if name:find(pattern) or text:find(pattern) then
                    return true
                end
            end
        end
    end
    return false
end

-- ========== 休息管理 ==========
local lastBreakTime = 0

local function ShouldTakeBreak()
    if not AntiBan.Enabled then return false end
    local currentTime = tick()
    if currentTime - lastBreakTime > AntiBan.BreakInterval then
        lastBreakTime = currentTime
        return true
    end
    return false
end

-- ========== 原功能函数（修改为使用SafeClick） ==========

local isRunning = false
local loopThread = nil
local orderCount = 0
local teleportCount = 0
local isPaused = false

local screenSize = workspace.CurrentCamera.ViewportSize
local phoneX = screenSize.X * 0.85
local phoneY = screenSize.Y * 0.35

local function AcceptOrder()
    -- 检测人机验证
    if CheckCaptcha() then
        orderStatusLabel.Text = "⚠️ 验证中..."
        print("⚠️ 检测到人机验证，暂停5秒")
        task.wait(5)
        if CheckCaptcha() then
            orderStatusLabel.Text = "❌ 请手动验证"
            task.wait(3)
        end
        return
    end
    
    -- 使用防封点击
    SafeClick(phoneX, phoneY)
    task.wait(GetRandomDelay())
    SafeClick(phoneX, phoneY + 100)
    task.wait(GetRandomDelay())
    SafeClick(phoneX, phoneY + 160)
    task.wait(GetRandomDelay())
    SafeClick(phoneX, phoneY + 240)
    task.wait(GetRandomDelay())
    
    orderCount = orderCount + 1
    orderCountLabel.Text = "📦 接单: " .. orderCount
    print("✅ 已接单")
end

local function GetTargetPosition()
    local targetFolder = workspace.Gameplay.Entities.ClientContent
    if not targetFolder then return nil end
    
    local targets = {}
    for _, child in ipairs(targetFolder:GetDescendants()) do
        if child:IsA("BasePart") then
            table.insert(targets, child.Position + Vector3.new(0, 3, 0))
        end
    end
    
    if #targets == 0 then return nil end
    return targets[math.random(1, #targets)]
end

local function TeleportCharacter(targetPos)
    local char = Player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        humanoid.Sit = false
        task.wait(0.1)
    end
    
    -- 随机延迟再传送
    task.wait(GetRandomDelay() * 0.5)
    
    hrp.CFrame = CFrame.new(targetPos)
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
    return true
end

local function UpdateUI(isActive)
    if isActive then
        statusLabel.Text = "▶️ 运行中"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        toggleButton.Text = "⏹️ 停止"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        dotIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        dotGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        antiBanLabel.Text = "🛡️ 防护开启"
        antiBanLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        statusLabel.Text = "⏸️ 已停止"
        statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        toggleButton.Text = "▶️ 启动"
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        dotIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        dotGlow.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        orderStatusLabel.Text = "🔄 等待接单..."
        antiBanLabel.Text = "🛡️"
        antiBanLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end

local function StartLoop()
    if isRunning then return end
    isRunning = true
    isPaused = false
    lastBreakTime = tick()
    UpdateUI(true)
    
    loopThread = coroutine.create(function()
        print("🔄 自动出租车已启动 [防封模式开启]")
        print("🛡️ 随机延迟: " .. AntiBan.MinDelay .. "-" .. AntiBan.MaxDelay .. "秒")
        print("🛡️ 鼠标偏移: ±" .. AntiBan.OffsetRange .. "px")
        
        while isRunning do
            -- 检测人机验证
            if CheckCaptcha() then
                orderStatusLabel.Text = "⚠️ 验证中..."
                print("⚠️ 检测到人机验证，暂停")
                task.wait(5)
                if CheckCaptcha() then
                    orderStatusLabel.Text = "❌ 请手动验证"
                    task.wait(3)
                end
                continue
            end
            
            -- 检查是否需要休息
            if ShouldTakeBreak() then
                orderStatusLabel.Text = "☕ 休息中..."
                print("☕ 休息 " .. AntiBan.BreakDuration .. " 秒")
                task.wait(AntiBan.BreakDuration)
                orderStatusLabel.Text = "🔄 继续运行"
                continue
            end
            
            orderStatusLabel.Text = "📱 正在自动接单..."
            AcceptOrder()
            task.wait(GetRandomDelay() * 1.5)
            
            -- 第一次传送
            orderStatusLabel.Text = "🚶 第1次传送..."
            local targetPos1 = GetTargetPosition()
            if targetPos1 then
                TeleportCharacter(targetPos1)
                teleportCount = teleportCount + 1
                teleportCountLabel.Text = "🚗 传送: " .. teleportCount
                print("✅ 第1次传送完成")
            else
                warn("⚠️ 未找到目标位置")
            end
            task.wait(GetRandomDelay() * 2)
            
            -- 第二次传送
            orderStatusLabel.Text = "🏁 第2次传送..."
            local targetPos2 = GetTargetPosition()
            if targetPos2 then
                TeleportCharacter(targetPos2)
                teleportCount = teleportCount + 1
                teleportCountLabel.Text = "🚗 传送: " .. teleportCount
                print("✅ 第2次传送完成")
            else
                warn("⚠️ 未找到目标位置")
            end
            
            orderStatusLabel.Text = "✅ 订单完成，等待下一单..."
            task.wait(GetRandomDelay() * 2)
        end
    end)
    
    coroutine.resume(loopThread)
end

local function StopLoop()
    isRunning = false
    isPaused = false
    UpdateUI(false)
    loopThread = nil
end

-- ========== 事件绑定 ==========
toggleButton.MouseButton1Click:Connect(function()
    if isRunning then
        StopLoop()
    else
        StartLoop()
    end
end)

Player.CharacterAdded:Connect(function()
    if isRunning then
        task.wait(1)
        local pos = GetTargetPosition()
        if pos then
            pcall(function() TeleportCharacter(pos) end)
        end
    end
end)

-- ========== 动画更新 ==========
local hue = 0

local function UpdateGlow()
    hue = (hue + 0.8) % 360
    local angle = (hue / 360) * 360
    gradient.Rotation = angle
    lineGradient.Rotation = angle
    
    local r = math.floor((math.sin(hue * math.pi / 180) * 0.5 + 0.5) * 255)
    local g = math.floor((math.sin((hue + 120) * math.pi / 180) * 0.5 + 0.5) * 255)
    local b = math.floor((math.sin((hue + 240) * math.pi / 180) * 0.5 + 0.5) * 255)
    
    local borderColor = Color3.fromRGB(r, g, b)
    mainFrame.BorderColor3 = borderColor
    glowBorder.BackgroundColor3 = borderColor
    outerGlow.BackgroundColor3 = borderColor
    btnGlow.BackgroundColor3 = borderColor
    btnOuterGlow.BackgroundColor3 = borderColor
    titleLine.BackgroundColor3 = borderColor
    titleLineGlow.BackgroundColor3 = borderColor
end

RunService.Heartbeat:Connect(UpdateGlow)

-- ========== 初始化 ==========
UpdateUI(false)
print("")
print("✅ KAN 自动出租车（防封增强版）已加载")
print("🛡️ 防封功能:")
print("  • 随机延迟: " .. AntiBan.MinDelay .. "-" .. AntiBan.MaxDelay .. "秒")
print("  • 鼠标偏移: ±" .. AntiBan.OffsetRange .. "px")
print("  • 错误率: " .. (AntiBan.ErrorRate * 100) .. "%")
print("  • 智能休息: 每" .. AntiBan.BreakInterval .. "秒休息" .. AntiBan.BreakDuration .. "秒")
print("  • 人机验证检测: 开启")
print("")
print("⚠️ 点击「启动」开始，风险自负")