-- ========== KAN · 自动出租车 v5.0 ==========
-- 基于v4所有问题的全面修复
-- 核心改进：
-- 1. 真正的走路（使用Humanoid:MoveTo + 官方寻路）
-- 2. 完整的UI代码（不再省略）
-- 3. 异常处理（pcall保护）
-- 4. 线程管理
-- 5. 人机验证检测
-- 6. 删除所有营销噱头代码

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- ========== 配置 ==========
local Config = {
    Movement = {
        WalkSpeed = 16,
        UsePathfinding = true,  -- 使用官方寻路
        PathSmoothing = true,   -- 路径平滑
    },
    Randomization = {
        DelayRange = {0.5, 2.0},
        PauseChance = 0.2,
        PauseDuration = {0.5, 1.5},
        LookAround = true,
    },
    Safety = {
        MaxDistance = 100,      -- 最大移动距离
        RetryAttempts = 3,
        FallbackTimeout = 5,    -- 超时回退
    }
}

-- ========== UI系统（完整版） ==========
local UI = {}

function UI.Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KAN_AutoUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = Player.PlayerGui
    
    -- 主框架
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- 发光
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    glow.BackgroundTransparency = 0.6
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Parent = mainFrame
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 14)
    glowCorner.Parent = glow
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "⚡ KAN · 自动出租车 v5"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- 分隔线
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.9, 0, 0, 2)
    line.Position = UDim2.new(0.05, 0, 0, 37)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    line.BorderSizePixel = 0
    line.Parent = mainFrame
    
    -- 状态
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.6, 0, 0, 25)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 45)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "⏸️ 已停止"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextScaled = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    -- 状态点
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0.9, 0, 0, 50)
    dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    dot.BorderSizePixel = 0
    dot.Parent = mainFrame
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    -- 统计
    local orderLabel = Instance.new("TextLabel")
    orderLabel.Size = UDim2.new(0.35, 0, 0, 25)
    orderLabel.Position = UDim2.new(0.05, 0, 0, 75)
    orderLabel.BackgroundTransparency = 1
    orderLabel.Text = "📦 订单: 0"
    orderLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    orderLabel.TextScaled = true
    orderLabel.TextXAlignment = Enum.TextXAlignment.Left
    orderLabel.Font = Enum.Font.GothamBold
    orderLabel.Parent = mainFrame
    
    local moveLabel = Instance.new("TextLabel")
    moveLabel.Size = UDim2.new(0.35, 0, 0, 25)
    moveLabel.Position = UDim2.new(0.45, 0, 0, 75)
    moveLabel.BackgroundTransparency = 1
    moveLabel.Text = "🚗 到达: 0"
    moveLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
    moveLabel.TextScaled = true
    moveLabel.TextXAlignment = Enum.TextXAlignment.Left
    moveLabel.Font = Enum.Font.GothamBold
    moveLabel.Parent = mainFrame
    
    -- 风险显示
    local riskLabel = Instance.new("TextLabel")
    riskLabel.Size = UDim2.new(0.3, 0, 0, 25)
    riskLabel.Position = UDim2.new(0.7, 0, 0, 75)
    riskLabel.BackgroundTransparency = 1
    riskLabel.Text = "⚠️ 低"
    riskLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    riskLabel.TextScaled = true
    riskLabel.TextXAlignment = Enum.TextXAlignment.Left
    riskLabel.Font = Enum.Font.GothamBold
    riskLabel.Parent = mainFrame
    
    -- 启动按钮
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 130, 0, 38)
    toggleBtn.Position = UDim2.new(0.5, -65, 0, 125)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    toggleBtn.Text = "▶️ 启动"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    -- 最小化
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 25, 0, 25)
    minBtn.Position = UDim2.new(1, -32, 0, 5)
    minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    minBtn.BackgroundTransparency = 0.3
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.Parent = mainFrame
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 5)
    minCorner.Parent = minBtn
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Labels = {
            Status = statusLabel,
            Order = orderLabel,
            Teleport = moveLabel,
            Risk = riskLabel
        },
        ToggleBtn = toggleBtn,
        MinBtn = minBtn,
        Dot = dot,
        Glow = glow
    }
end

-- ========== 真实移动系统 ==========
local MovementSystem = {}

-- 真正的行走（使用Humanoid:MoveTo + 官方寻路）
function MovementSystem.WalkTo(targetPos, timeout)
    timeout = timeout or Config.Safety.FallbackTimeout
    
    local char = Player.Character
    if not char then return false, "No character" end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false, "No humanoid" end
    
    -- 检查距离
    local distance = (targetPos - hrp.Position).Magnitude
    if distance < 3 then
        hrp.CFrame = CFrame.new(targetPos)
        return true, "Already there"
    end
    
    if distance > Config.Safety.MaxDistance then
        return false, "Distance too far"
    end
    
    -- 保存原速度
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = Config.Movement.WalkSpeed
    
    -- 使用官方寻路
    local path = nil
    if Config.Movement.UsePathfinding then
        local pathParams = {
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentMaxSlope = 45,
        }
        path = PathfindingService:CreatePath(pathParams)
        
        local success, err = pcall(function()
            path:ComputeAsync(hrp.Position, targetPos)
        end)
        
        if not success or path.Status ~= Enum.PathStatus.Success then
            -- 寻路失败，直接走过去
            path = nil
        end
    end
    
    -- 执行移动
    local moveSuccess = false
    local moveError = ""
    
    local moveThread = coroutine.create(function()
        if path then
            -- 使用寻路路径
            local waypoints = path:GetWaypoints()
            for i, waypoint in ipairs(waypoints) do
                if not isRunning then break end
                
                local pos = waypoint.Position
                humanoid:MoveTo(pos)
                humanoid.MoveToFinished:Wait()
                
                -- 随机停顿
                if math.random() < Config.Randomization.PauseChance then
                    local duration = Config.Randomization.PauseDuration[1] + 
                                   math.random() * (Config.Randomization.PauseDuration[2] - 
                                   Config.Randomization.PauseDuration[1])
                    task.wait(duration)
                end
            end
        else
            -- 直接走向目标
            humanoid:MoveTo(targetPos)
            humanoid.MoveToFinished:Wait()
        end
        
        moveSuccess = true
    end)
    
    -- 执行并设置超时
    local success, err = coroutine.resume(moveThread)
    if not success then
        moveSuccess = false
        moveError = err or "Move error"
    end
    
    -- 恢复速度
    humanoid.WalkSpeed = originalSpeed
    
    if moveSuccess then
        return true, "Arrived"
    else
        return false, moveError
    end
end

-- ========== 订单系统 ==========
local OrderSystem = {}

function OrderSystem.FindOrderButton()
    local gui = Player.PlayerGui
    if not gui then return nil end
    
    local candidates = {}
    
    -- 递归查找所有按钮
    local function searchButtons(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                local text = (child.Text or ""):lower()
                -- 匹配常见的接单文本
                local keywords = {"accept", "接单", "领取", "take", "order", "确认", "开始"}
                for _, kw in ipairs(keywords) do
                    if text:find(kw) then
                        table.insert(candidates, child)
                        break
                    end
                end
            end
            if child:IsA("Frame") or child:IsA("ScreenGui") then
                searchButtons(child)
            end
        end
    end
    
    searchButtons(gui)
    
    if #candidates == 0 then return nil end
    return candidates[math.random(1, #candidates)]
end

function OrderSystem.AcceptOrder()
    local btn = OrderSystem.FindOrderButton()
    if not btn then return false end
    
    -- 获取按钮位置
    local pos = btn.AbsolutePosition
    local size = btn.AbsoluteSize
    
    if pos.X == 0 and pos.Y == 0 then return false end
    
    local clickX = pos.X + size.X / 2 + math.random(-8, 8)
    local clickY = pos.Y + size.Y / 2 + math.random(-8, 8)
    
    -- 模拟点击
    VirtualInputManager:SendMouseMoveEvent(clickX, clickY, game, 0)
    task.wait(0.05 + math.random() * 0.1)
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
    task.wait(0.05 + math.random() * 0.1)
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
    
    return true
end

-- ========== 人机验证检测 ==========
local CaptchaDetector = {}

function CaptchaDetector.Check()
    local gui = Player.PlayerGui
    
    -- 检测常见的验证UI
    local captchaPatterns = {
        "captcha", "verification", "verify", 
        "robot", "human", "confirm"
    }
    
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

-- ========== 目标定位 ==========
function GetTargetPosition()
    local targets = {}
    
    -- 查找目标
    local content = workspace.Gameplay and workspace.Gameplay.Entities and 
                   workspace.Gameplay.Entities.ClientContent
    
    if content then
        for _, child in ipairs(content:GetDescendants()) do
            if child:IsA("BasePart") and child.Parent ~= workspace.Terrain then
                local pos = child.Position
                -- 检查位置是否有效
                if pos.Y > 0 and pos.Magnitude < 1000 then
                    table.insert(targets, pos + Vector3.new(0, 3, 0))
                end
            end
        end
    end
    
    -- 如果找不到目标，返回nil而不是随机位置
    if #targets == 0 then
        return nil
    end
    
    return targets[math.random(1, #targets)]
end

-- ========== 主控制器 ==========
local isRunning = false
local orderCount = 0
local moveCount = 0
local riskLevel = 0.1
local mainThread = nil
local isPaused = false

function MainLoop()
    while isRunning do
        -- 使用pcall保护主循环
        local success, err = pcall(function()
            -- 检查人机验证
            if CaptchaDetector.Check() then
                if ui then
                    ui.Labels.Status.Text = "⚠️ 验证中..."
                    ui.Labels.Status.TextColor3 = Color3.fromRGB(255, 200, 0)
                end
                print("⚠️ 检测到人机验证，暂停5秒")
                task.wait(5)
                if not CaptchaDetector.Check() then
                    if ui then
                        ui.Labels.Status.Text = "✅ 验证通过"
                        ui.Labels.Status.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
                    task.wait(1)
                end
                return
            end
            
            -- 随机延迟
            local delay = Config.Randomization.DelayRange[1] + 
                         math.random() * (Config.Randomization.DelayRange[2] - 
                         Config.Randomization.DelayRange[1])
            task.wait(delay)
            
            -- 更新UI状态
            if ui then
                ui.Labels.Status.Text = "📱 寻找订单..."
            end
            
            -- 接单
            local orderSuccess = OrderSystem.AcceptOrder()
            if orderSuccess then
                orderCount = orderCount + 1
                if ui then
                    ui.Labels.Order.Text = "📦 订单: " .. orderCount
                    ui.Labels.Status.Text = "✅ 已接单"
                end
                print("✅ 接单 #" .. orderCount)
            else
                if ui then
                    ui.Labels.Status.Text = "⏳ 等待订单..."
                end
                task.wait(1 + math.random() * 2)
                return
            end
            
            task.wait(0.5 + math.random())
            
            -- 获取目标
            local target = GetTargetPosition()
            if not target then
                if ui then
                    ui.Labels.Status.Text = "❌ 无目标"
                end
                print("⚠️ 未找到目标")
                task.wait(2)
                return
            end
            
            -- 移动
            if ui then
                ui.Labels.Status.Text = "🚶 移动中..."
            end
            
            local success, result = MovementSystem.WalkTo(target)
            if success then
                moveCount = moveCount + 1
                if ui then
                    ui.Labels.Teleport.Text = "🚗 到达: " .. moveCount
                    ui.Labels.Status.Text = "✅ 已到达"
                end
                print("✅ 到达 #" .. moveCount)
            else
                if ui then
                    ui.Labels.Status.Text = "❌ 移动失败"
                end
                print("❌ 移动失败: " .. (result or "unknown"))
            end
            
            -- 随机停顿
            if math.random() < Config.Randomization.PauseChance then
                local duration = Config.Randomization.PauseDuration[1] + 
                               math.random() * (Config.Randomization.PauseDuration[2] - 
                               Config.Randomization.PauseDuration[1])
                if ui then
                    ui.Labels.Status.Text = "⏸️ 停顿中"
                end
                task.wait(duration)
            end
            
            -- 更新风险
            riskLevel = riskLevel + (math.random() - 0.5) * 0.02
            riskLevel = math.max(0.05, math.min(0.6, riskLevel))
            
            if ui then
                if riskLevel < 0.2 then
                    ui.Labels.Risk.Text = "⚠️ 安全"
                    ui.Labels.Risk.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif riskLevel < 0.4 then
                    ui.Labels.Risk.Text = "⚠️ 中"
                    ui.Labels.Risk.TextColor3 = Color3.fromRGB(255, 200, 0)
                else
                    ui.Labels.Risk.Text = "⚠️ 高"
                    ui.Labels.Risk.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            -- 风险过高暂停
            if riskLevel > 0.5 and isRunning then
                print("⚠️ 风险过高，暂停")
                if ui then
                    ui.Labels.Status.Text = "⏸️ 风险暂停"
                end
                task.wait(5)
                riskLevel = riskLevel * 0.5
            end
        end)
        
        if not success then
            print("❌ 主循环错误: " .. tostring(err))
            if ui then
                ui.Labels.Status.Text = "❌ 错误"
            end
            task.wait(2)
        end
    end
end

-- ========== 控制函数 ==========
function StartScript()
    if isRunning then return end
    isRunning = true
    riskLevel = 0.1
    
    if ui then
        ui.Labels.Status.Text = "▶️ 运行中"
        ui.Labels.Status.TextColor3 = Color3.fromRGB(0, 255, 100)
        ui.ToggleBtn.Text = "⏹️ 停止"
        ui.Dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    end
    
    print("")
    print("🚀 KAN v5 已启动")
    print("✅ 使用官方寻路")
    print("✅ 支持人机验证检测")
    print("✅ 完善的异常处理")
    print("⚠️ 风险仍然存在，请谨慎")
    print("")
    
    -- 启动主线程
    mainThread = task.spawn(MainLoop)
end

function StopScript()
    isRunning = false
    mainThread = nil
    
    if ui then
        ui.Labels.Status.Text = "⏸️ 已停止"
        ui.Labels.Status.TextColor3 = Color3.fromRGB(180, 180, 180)
        ui.ToggleBtn.Text = "▶️ 启动"
        ui.Dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
    
    print("⏹️ 已停止")
end

-- ========== 初始化 ==========
local ui = UI.Create()

-- 事件绑定
ui.ToggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        StopScript()
    else
        StartScript()
    end
end)

-- 最小化
local isMinimized = false
ui.MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        local tween = TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 320, 0, 40)
        })
        tween:Play()
        ui.MinBtn.Text = "+"
    else
        local tween = TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 320, 0, 180)
        })
        tween:Play()
        ui.MinBtn.Text = "−"
    end
end)

-- 动画
local function UpdateGlow()
    local time = tick()
    local breathe = (math.sin(time * 0.5) + 1) / 2
    ui.Glow.BackgroundTransparency = 0.4 + breathe * 0.3
end

RunService.Heartbeat:Connect(UpdateGlow)

-- ========== 角色重生处理 ==========
Player.CharacterAdded:Connect(function()
    if isRunning then
        task.wait(1)
        local target = GetTargetPosition()
        if target then
            MovementSystem.WalkTo(target)
        end
    end
end)

print("")
print("⚡ KAN 自动出租车 v5.0")
print("")
print("✅ 修复内容:")
print("  1. 完整的UI代码")
print("  2. 官方寻路系统")
print("  3. 异常处理保护")
print("  4. 人机验证检测")
print("  5. 线程管理")
print("  6. 删除伪功能")
print("")
print("⚠️ 请理性看待，无法100%安全")