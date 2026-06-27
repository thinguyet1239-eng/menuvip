-- Menu Moew Lover
-- by Moew Lover
-- Tất cả chức năng đồng bộ server

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local teleportService = game:GetService("TeleportService")
local virtualUser = game:GetService("VirtualUser")

-- Khởi tạo GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoewLoverMenu"
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Tạo các tab
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
tabFrame.Parent = mainFrame

local tabs = {"ESP", "AIM", "MOVEMENT", "MISC"}
local tabButtons = {}
for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.25, 0, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.BorderSizePixel = 0
    btn.Parent = tabFrame
    tabButtons[i] = btn
end

-- Container cho nội dung tab
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -30)
contentContainer.Position = UDim2.new(0, 0, 0, 30)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Biến trạng thái
local settings = {
    fly = false,
    speed = 50,
    noclip = false,
    esp = false,
    espLine = false,
    espBox = false,
    espName = false,
    fov = false,
    fovSize = 120,
    autoAim = false,
    aimLock = false,
    aimFile = false,
    fixLag = false,
    fakeLag = false,
    selectedTarget = nil
}

-- Hàm tạo toggle
local function createToggle(parent, label, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local labelGui = Instance.new("TextLabel")
    labelGui.Size = UDim2.new(0.7, 0, 1, 0)
    labelGui.Text = label
    labelGui.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelGui.TextXAlignment = Enum.TextXAlignment.Left
    labelGui.BackgroundTransparency = 1
    labelGui.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
    toggleBtn.Position = UDim2.new(0.78, 0, 0.1, 0)
    toggleBtn.Text = getter() and "ON" or "OFF"
    toggleBtn.TextColor3 = getter() and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleBtn.Parent = frame
    
    toggleBtn.MouseButton1Click:Connect(function()
        setter(not getter())
        toggleBtn.Text = getter() and "ON" or "OFF"
        toggleBtn.TextColor3 = getter() and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
    
    return toggleBtn
end

-- Tạo slider
local function createSlider(parent, label, min, max, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local labelGui = Instance.new("TextLabel")
    labelGui.Size = UDim2.new(0.4, 0, 0.5, 0)
    labelGui.Text = label
    labelGui.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelGui.TextXAlignment = Enum.TextXAlignment.Left
    labelGui.BackgroundTransparency = 1
    labelGui.Parent = frame
    
    local valueGui = Instance.new("TextLabel")
    valueGui.Size = UDim2.new(0.2, 0, 0.5, 0)
    valueGui.Position = UDim2.new(0.8, 0, 0, 0)
    valueGui.Text = tostring(getter())
    valueGui.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueGui.BackgroundTransparency = 1
    valueGui.Parent = frame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0.3, 0)
    sliderBar.Position = UDim2.new(0, 0, 0.6, 0)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    sliderBar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.Parent = sliderBar
    
    local function updateSlider(newValue)
        newValue = math.clamp(newValue, min, max)
        setter(newValue)
        valueGui.Text = tostring(math.round(newValue))
        fill.Size = UDim2.new((newValue - min) / (max - min), 0, 1, 0)
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            updateSlider(min + x * (max - min))
        end
    end)
    
    sliderBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local x = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            updateSlider(min + x * (max - min))
        end
    end)
    
    return {update = updateSlider}
end

-- Tab ESP
local espTab = Instance.new("ScrollingFrame")
espTab.Size = UDim2.new(1, 0, 1, 0)
espTab.BackgroundTransparency = 1
espTab.Parent = contentContainer

local espY = 5
local function addToEsp(label, getter, setter)
    local btn = createToggle(espTab, label, getter, setter)
    btn.Parent.Position = UDim2.new(0, 5, 0, espY)
    espY = espY + 35
end

addToEsp("ESP Tổng", function() return settings.esp end, function(v) settings.esp = v end)
addToEsp("Đường kẻ (Line)", function() return settings.espLine end, function(v) settings.espLine = v end)
addToEsp("Khung (Box)", function() return settings.espBox end, function(v) settings.espBox = v end)
addToEsp("Tên (Name)", function() return settings.espName end, function(v) settings.espName = v end)
addToEsp("Hiện FOV", function() return settings.fov end, function(v) settings.fov = v end)

createSlider(espTab, "Kích thước FOV", 50, 300, function() return settings.fovSize end, function(v) settings.fovSize = v end)

-- Tab AIM
local aimTab = Instance.new("ScrollingFrame")
aimTab.Size = UDim2.new(1, 0, 1, 0)
aimTab.BackgroundTransparency = 1
aimTab.Visible = false
aimTab.Parent = contentContainer

local aimY = 5
local function addToAim(label, getter, setter)
    local btn = createToggle(aimTab, label, getter, setter)
    btn.Parent.Position = UDim2.new(0, 5, 0, aimY)
    aimY = aimY + 35
end

addToAim("Auto Aim", function() return settings.autoAim end, function(v) settings.autoAim = v end)
addToAim("Aim File (Melee)", function() return settings.aimFile end, function(v) settings.aimFile = v end)

-- Tab MOVEMENT
local moveTab = Instance.new("ScrollingFrame")
moveTab.Size = UDim2.new(1, 0, 1, 0)
moveTab.BackgroundTransparency = 1
moveTab.Visible = false
moveTab.Parent = contentContainer

local moveY = 5
local function addToMove(label, getter, setter)
    local btn = createToggle(moveTab, label, getter, setter)
    btn.Parent.Position = UDim2.new(0, 5, 0, moveY)
    moveY = moveY + 35
end

addToMove("Bay (Fly)", function() return settings.fly end, function(v) settings.fly = v end)
addToMove("Xuyên tường (Noclip)", function() return settings.noclip end, function(v) settings.noclip = v end)

createSlider(moveTab, "Tốc độ", 10, 200, function() return settings.speed end, function(v) settings.speed = v end)

-- Tab MISC
local miscTab = Instance.new("ScrollingFrame")
miscTab.Size = UDim2.new(1, 0, 1, 0)
miscTab.BackgroundTransparency = 1
miscTab.Visible = false
miscTab.Parent = contentContainer

local miscY = 5
local function addToMisc(label, getter, setter)
    local btn = createToggle(miscTab, label, getter, setter)
    btn.Parent.Position = UDim2.new(0, 5, 0, miscY)
    miscY = miscY + 35
end

addToMisc("Fix Lag", function() return settings.fixLag end, function(v) settings.fixLag = v end)
addToMisc("Fake Lag", function() return settings.fakeLag end, function(v) settings.fakeLag = v end)

-- Chuyển tab
for i, btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for _, container in ipairs({espTab, aimTab, moveTab, miscTab}) do
            container.Visible = false
        end
        local containers = {espTab, aimTab, moveTab, miscTab}
        containers[i].Visible = true
    end)
end

-- Hàm ESP
local espObjects = {}
local function createEsp()
    -- Xóa ESP cũ
    for _, obj in ipairs(espObjects) do
        obj:Destroy()
    end
    espObjects = {}
    
    if not settings.esp then return end
    
    for _, v in ipairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local char = v.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local espGroup = Instance.new("BillboardGui")
                espGroup.Size = UDim2.new(0, 200, 0, 100)
                espGroup.AlwaysOnTop = true
                espGroup.Parent = root
                
                -- Box
                if settings.espBox then
                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(0, 60, 0, 80)
                    box.Position = UDim2.new(0.5, -30, 0, 0)
                    box.BackgroundTransparency = 0.7
                    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    box.BorderSizePixel = 2
                    box.BorderColor3 = Color3.fromRGB(255, 0, 0)
                    box.Parent = espGroup
                end
                
                -- Line
                if settings.espLine then
                    local line = Instance.new("Frame")
                    line.Size = UDim2.new(0, 2, 1, 0)
                    line.Position = UDim2.new(0.5, -1, 0, 0)
                    line.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    line.Parent = espGroup
                end
                
                -- Name
                if settings.espName then
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 0, 20)
                    nameLabel.Position = UDim2.new(0, 0, 1, 0)
                    nameLabel.Text = v.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextScaled = true
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Parent = espGroup
                end
                
                table.insert(espObjects, espGroup)
            end
        end
    end
end

-- FOV Circle
local fovCircle = nil
local function createFov()
    if fovCircle then fovCircle:Destroy() end
    if not settings.fov then return end
    
    fovCircle = Instance.new("BillboardGui")
    fovCircle.Size = UDim2.new(0, 400, 0, 400)
    fovCircle.Parent = camera
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundTransparency = 1
    circle.Parent = fovCircle
    
    local radius = settings.fovSize
    local segments = 60
    for i = 0, segments do
        local angle = (i / segments) * 2 * math.pi
        local x = 0.5 + math.cos(angle) * (radius / 400)
        local y = 0.5 + math.sin(angle) * (radius / 400)
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 2, 0, 2)
        dot.Position = UDim2.new(x, -1, y, -1)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        dot.BackgroundTransparency = 0.3
        dot.Parent = circle
    end
end

-- Auto Aim
local aimTarget = nil
local function getClosestTarget()
    local closest = nil
    local minDist = math.huge
    local center = camera.ViewportSize / 2
    
    for _, v in ipairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local root = v.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < settings.fovSize and dist < minDist then
                    minDist = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

-- Auto Aim Loop
runService.RenderStepped:Connect(function()
    if settings.autoAim and settings.esp then
        aimTarget = getClosestTarget()
        if aimTarget and aimTarget.Character then
            local root = aimTarget.Character:FindFirstChild("HumanoidRootPart")
            if root then
                camera.CFrame = CFrame.new(camera.CFrame.Position, root.Position)
            end
        end
    end
end)

-- Aim File (Melee)
runService.RenderStepped:Connect(function()
    if settings.aimFile and aimTarget and aimTarget.Character then
        local targetPos = aimTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetPos and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                -- Dịch chuyển đến kẻ địch
                root.CFrame = CFrame.new(targetPos.Position + Vector3.new(0, 0, 3))
                
                -- Tấn công nếu có vũ khí cận chiến
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                end
            end
        end
    end
end)

-- Fly
local flyVelocity = Vector3.new(0, 0, 0)
runService.RenderStepped:Connect(function()
    if settings.fly and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local moveDirection = Vector3.new(0, 0, 0)
            if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
            if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
            if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
            if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
            if userInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * settings.speed
                root.Velocity = Vector3.new(moveDirection.X, moveDirection.Y, moveDirection.Z)
            else
                root.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- Noclip
runService.RenderStepped:Connect(function()
    if settings.noclip and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fix Lag
runService.RenderStepped:Connect(function()
    if settings.fixLag then
        settings.speed = math.clamp(settings.speed, 10, 200)
        for _, v in ipairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character then
                for _, part in ipairs(v.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part:SetNetworkOwner(nil)
                    end
                end
            end
        end
    end
end)

-- Fake Lag
local lagCount = 0
runService.RenderStepped:Connect(function()
    if settings.fakeLag then
        lagCount = lagCount + 1
        if lagCount % 5 == 0 then
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
        end
    end
end)

-- Cập nhật ESP định kỳ
while wait(0.5) do
    if settings.esp then
        createEsp()
        createFov()
    else
        for _, obj in ipairs(espObjects) do
            obj:Destroy()
        end
        espObjects = {}
        if fovCircle then
            fovCircle:Destroy()
            fovCircle = nil
        end
    end
end