--[[
    VNDXS HUB - Blade Ball
    Version: 1.0.0

    كيف يعمل Auto Parry:
    1. يبحث عن الكرة في workspace.Balls
    2. يحسب المسافة والسرعة واتجاه الكرة
    3. يحسب وقت الوصول (TimeToHit = Distance / Speed)
    4. يضيف تعويض الـ Ping (PingOffset)
    5. لو وقت الوصول أقل من الـ threshold يضغط تلقائياً
    6. في حالة Clash (الكرة قريبة جداً) يضغط بسرعة أكبر
]]

-- ==================== Interface Check ====================
if not VNDXS.Interface or not VNDXS.Interface.Library then
    warn("[VNDXS/BladeBall] Interface not loaded, retrying...")
    task.wait(2)
    VNDXS.Interface = loadstring(game:HttpGet(VNDXS.BaseUrl .. "Components/Interface.luau"))()
    if not VNDXS.Interface or not VNDXS.Interface.Library then
        error("[VNDXS/BladeBall] Interface failed.")
        return
    end
end

-- ==================== Services ====================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local Stats               = game:GetService("Stats")
local UserInputService    = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Library     = VNDXS.Interface.Library
local SaveManager = VNDXS.Interface.SaveManager
local Theme       = VNDXS.Theme

-- ==================== Helpers ====================
local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.new(
        tonumber(hex:sub(1,2), 16) / 255,
        tonumber(hex:sub(3,4), 16) / 255,
        tonumber(hex:sub(5,6), 16) / 255
    )
end

-- ==================== Settings ====================
local Settings = {
    AutoParry        = false,
    PingBased        = true,
    PingOffset       = 1.95,    -- مضاعف تعويض الـ Ping
    ParryThreshold   = 0.65,    -- ثانية — متى يضغط قبل وصول الكرة
    EmergencyRadius  = 10,      -- مسافة الضغط الطاريء
    ClashDistance    = 22,      -- مسافة الـ Clash
    ClashSpeed       = 0.01,    -- سرعة الضغط في Clash
    NormalSpeed      = 0.05,    -- سرعة الضغط العادية
    Visuals          = true,    -- دائرة ESP تحت اللاعب
    ShowFOV          = true,    -- دائرة مجال الكشف
}

-- ==================== State ====================
local LastClick   = 0
local LastBallHit = nil
local IsParrying  = false
local FrameCount  = 0

-- ==================== Ping ====================
local NetworkStats = Stats:FindFirstChild("Network")
    and Stats.Network:FindFirstChild("ServerStatsItem")
    and Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")

local function GetPing()
    if not Settings.PingBased then return 0.04 end
    return (NetworkStats and NetworkStats.Value / 1000) or 0.04
end

-- ==================== Ball Finder ====================
local BallsFolder = workspace:FindFirstChild("Balls") or workspace:WaitForChild("Balls", 10)

local function GetBall()
    if not BallsFolder then return nil end
    -- أولاً: نبحث عن الكرة الحقيقية بالـ Attribute
    for _, v in ipairs(BallsFolder:GetChildren()) do
        if v:GetAttribute("realBall") == true then return v end
    end
    -- ثانياً: fallback — أي كرة تتحرك بسرعة
    for _, v in ipairs(BallsFolder:GetChildren()) do
        if v:IsA("BasePart") and v.AssemblyLinearVelocity.Magnitude > 15 then
            return v
        end
    end
    return nil
end

-- ==================== Target Check ====================
-- يتحقق هل الكرة تستهدفنا نحن
local function IsTargeted()
    local char = LocalPlayer.Character
    if not char then return false end
    return char:GetAttribute("Targeted") == true
        or char:FindFirstChild("Highlight") ~= nil
end

-- ==================== Auto Click ====================
local function SendClick(isClashing, ball)
    if not Settings.AutoParry or IsParrying then return end
    local now  = tick()
    local cd   = isClashing and Settings.ClashSpeed or Settings.NormalSpeed

    -- منع الضغط المزدوج على نفس الكرة
    if not isClashing and LastBallHit == ball and (now - LastClick) < 0.5 then return end
    if (now - LastClick) < cd then return end

    IsParrying    = true
    LastClick     = now
    LastBallHit   = ball

    -- محاكاة ضغطة ماوس يسار
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true,  game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

    task.delay(cd, function() IsParrying = false end)
end

-- ==================== Visuals ====================
local Circle, CircleMesh, FOVCircle

local function CreateVisuals()
    -- دائرة تحت اللاعب (حالة الكرة)
    Circle = Instance.new("Part")
    Circle.Name        = "VNDXS_BladeBall_Circle"
    Circle.Anchored    = true
    Circle.CanCollide  = false
    Circle.Transparency = 1
    Circle.Material    = Enum.Material.Neon
    Circle.Parent      = workspace

    CircleMesh = Instance.new("SpecialMesh", Circle)
    CircleMesh.MeshId = "rbxassetid://3270017"

    -- دائرة FOV
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible   = false
    FOVCircle.Filled    = false
    FOVCircle.Color     = HexToColor3(Theme.AccentColor)
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides  = 64
    FOVCircle.Radius    = 80
end

CreateVisuals()

local function UpdateVisuals(root, distance, state)
    if not Settings.Visuals or not Circle then return end

    Circle.CFrame = root.CFrame * CFrame.new(0, -2.6, 0) * CFrame.Angles(math.rad(90), 0, 0)
    local targetSize = math.clamp(distance * 0.8, 5, 65)
    CircleMesh.Scale = CircleMesh.Scale:Lerp(Vector3.new(targetSize, targetSize, 0.5), 0.5)

    if state == "clash" then
        -- أحمر = خطر — Clash
        Circle.Color        = HexToColor3("FF0000")
        Circle.Transparency = 0.05
    elseif state == "target" then
        -- أزرق سماوي = مستهدف
        Circle.Color        = HexToColor3("00FFFF")
        Circle.Transparency = 0.1
    else
        -- أزرق فاتح = محايد
        Circle.Color        = HexToColor3(Theme.AccentColor)
        Circle.Transparency = 0.5
    end
end

local function HideVisuals()
    if Circle then Circle.Transparency = 1 end
    if FOVCircle then FOVCircle.Visible = false end
end

-- ==================== Main Loop ====================
RunService.PostSimulation:Connect(function()
    if not Settings.AutoParry then
        HideVisuals()
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        HideVisuals()
        return
    end

    local ball = GetBall()
    if not ball then
        HideVisuals()
        return
    end

    local ballPos   = ball.Position
    local playerPos = root.Position
    local velocity  = ball.AssemblyLinearVelocity
    local speed     = velocity.Magnitude
    local distance  = (playerPos - ballPos).Magnitude

    -- حساب اتجاه الكرة نحونا
    local dirToPlayer  = (playerPos - ballPos).Unit
    local velDirection = velocity.Unit
    local dot          = dirToPlayer:Dot(velDirection)

    -- لو الكرة تبتعد عنا نعيد ضبط LastBallHit
    if dot < 0 then LastBallHit = nil end

    local targeted  = IsTargeted()
    local isClashing = targeted and distance <= Settings.ClashDistance

    -- تحديث الـ Visuals كل frame ثاني لتوفير الأداء
    FrameCount = FrameCount + 1
    if FrameCount % 2 == 0 then
        Circle.Transparency = 0.3
        UpdateVisuals(
            root,
            distance,
            isClashing and "clash" or (targeted and "target" or "neutral")
        )
    end

    -- ===== منطق الـ Parry =====
    if isClashing then
        -- Clash: الكرة قريبة جداً — اضغط بأقصى سرعة
        SendClick(true, ball)

    elseif targeted and dot > 0 then
        -- الكرة تتجه نحونا ونحن مستهدفون
        local ping          = GetPing()
        local timeToHit     = distance / math.max(speed, 1)
        local threshold     = Settings.ParryThreshold + (ping * Settings.PingOffset)

        -- زيادة الـ threshold للكرات فائقة السرعة
        if speed > 150 then
            threshold = threshold * 1.15
        end

        if timeToHit <= threshold or distance <= Settings.EmergencyRadius then
            SendClick(false, ball)
        end
    end
end)

-- إعادة ضبط عند الموت
LocalPlayer.CharacterAdded:Connect(function()
    LastBallHit = nil
    IsParrying  = false
end)

-- ==================== Window ====================
local Window = Library:CreateWindow({
    Title        = "VNDXS HUB  •  BLADE BALL",
    Footer       = "v" .. VNDXS.Version .. "  |  dsc.gg/vndxshub",
    NotifySide   = "Right",
    ShowCustomCursor = false,
    AutoShow     = true,
    Center       = true,
    TabPadding   = 3,
    MenuFadeTime = 0,
    CornerRadius = 2,
})

-- تطبيق الثيم
pcall(function()
    if Library.SetColors then
        Library:SetColors({
            Font       = HexToColor3(Theme.FontColor),
            Main       = HexToColor3(Theme.MainColor),
            Accent     = HexToColor3(Theme.AccentColor),
            Background = HexToColor3(Theme.BackgroundColor),
            Outline    = HexToColor3(Theme.OutlineColor),
        })
    end
end)

-- ==================== Tabs ====================
local Tabs = {
    Info     = Window:AddTab("Info",       "user"),
    Parry    = Window:AddTab("Auto Parry", "shield"),
    Visuals  = Window:AddTab("Visuals",    "eye"),
    Settings = Window:AddTab("Settings",   "settings"),
}

-- ==================== INFO TAB ====================
do
    local UserGroup = Tabs.Info:AddLeftGroupbox("Player Info")
    pcall(function()
        local thumb = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size420x420
        )
        UserGroup:AddImage("Avatar", { Image = thumb })
    end)
    UserGroup:AddLabel("Username: " .. LocalPlayer.Name, true)
    UserGroup:AddLabel("User ID: "  .. tostring(LocalPlayer.UserId), true)
    UserGroup:AddLabel("Game: Blade Ball", true)
    UserGroup:AddLabel("Hub: VNDXS HUB v" .. VNDXS.Version, true)

    local HowGroup = Tabs.Info:AddRightGroupbox("How It Works")
    HowGroup:AddLabel("1. Finds the ball in workspace", true)
    HowGroup:AddLabel("2. Checks if you are targeted", true)
    HowGroup:AddLabel("3. Calculates time to hit", true)
    HowGroup:AddLabel("4. Compensates for your ping", true)
    HowGroup:AddLabel("5. Auto-clicks at perfect timing", true)
    HowGroup:AddDivider()
    HowGroup:AddLabel("Toggle: L key", true)

    local LogGroup = Tabs.Info:AddRightGroupbox("Changelog")
    for _, v in ipairs({
        "VNDXS HUB v1.0.0",
        "<font color='rgb(255,215,0)'>★ Blade Ball Support</font>",
        "<font color='rgb(30,144,255)'>+ Auto Parry (Ping-based)</font>",
        "<font color='rgb(30,144,255)'>+ Clash Detection</font>",
        "<font color='rgb(30,144,255)'>+ Emergency Radius</font>",
        "<font color='rgb(30,144,255)'>+ Speed Compensation</font>",
        "<font color='rgb(30,144,255)'>+ Visual Circle ESP</font>",
    }) do LogGroup:AddLabel(v, true) end
end

-- ==================== PARRY TAB ====================
do
    local ParryGroup = Tabs.Parry:AddLeftGroupbox("Auto Parry")

    ParryGroup:AddToggle("AutoParryToggle", {
        Text    = "Enable Auto Parry  (L key)",
        Default = false,
        Callback = function(v)
            Settings.AutoParry = v
            if not v then HideVisuals() end
        end,
    })

    ParryGroup:AddDivider()

    ParryGroup:AddToggle("PingBasedToggle", {
        Text    = "Ping Compensation",
        Default = true,
        Callback = function(v) Settings.PingBased = v end,
    })
    ParryGroup:AddLabel("Adjusts timing based on your\ncurrent ping automatically.", true)

    ParryGroup:AddDivider()

    ParryGroup:AddSlider("PingOffsetSlider", {
        Text     = "Ping Offset Multiplier",
        Default  = 195,
        Min      = 50,
        Max      = 400,
        Rounding = 0,
        Callback = function(v) Settings.PingOffset = v / 100 end,
    })
    ParryGroup:AddLabel("Higher = parry earlier\nLower = parry later", true)

    ParryGroup:AddSlider("ThresholdSlider", {
        Text     = "Parry Threshold (ms)",
        Default  = 65,
        Min      = 10,
        Max      = 200,
        Rounding = 0,
        Callback = function(v) Settings.ParryThreshold = v / 100 end,
    })

    local ClashGroup = Tabs.Parry:AddRightGroupbox("Clash Settings")

    ClashGroup:AddSlider("ClashDistSlider", {
        Text     = "Clash Detection Distance",
        Default  = 22,
        Min      = 5,
        Max      = 50,
        Rounding = 0,
        Callback = function(v) Settings.ClashDistance = v end,
    })
    ClashGroup:AddLabel("Distance to switch to\nfast Clash mode.", true)

    ClashGroup:AddSlider("EmergencySlider", {
        Text     = "Emergency Radius",
        Default  = 10,
        Min      = 3,
        Max      = 30,
        Rounding = 0,
        Callback = function(v) Settings.EmergencyRadius = v end,
    })
    ClashGroup:AddLabel("Force parry when ball is\nthis close regardless of timing.", true)

    ClashGroup:AddSlider("ClashSpeedSlider", {
        Text     = "Clash Click Speed (ms)",
        Default  = 1,
        Min      = 1,
        Max      = 50,
        Rounding = 0,
        Callback = function(v) Settings.ClashSpeed = v / 100 end,
    })

    ClashGroup:AddSlider("NormalSpeedSlider", {
        Text     = "Normal Click Speed (ms)",
        Default  = 5,
        Min      = 1,
        Max      = 100,
        Rounding = 0,
        Callback = function(v) Settings.NormalSpeed = v / 100 end,
    })
end

-- ==================== VISUALS TAB ====================
do
    local VisGroup = Tabs.Visuals:AddLeftGroupbox("Circle Indicator")

    VisGroup:AddToggle("VisualsToggle", {
        Text    = "Show Circle Indicator",
        Default = true,
        Callback = function(v)
            Settings.Visuals = v
            if not v and Circle then Circle.Transparency = 1 end
        end,
    })
    VisGroup:AddLabel("Circle under your character:\n🔵 Blue = Ball nearby\n🔷 Cyan = Ball targeting you\n🔴 Red = Clash mode", true)

    local InfoGroup = Tabs.Visuals:AddRightGroupbox("Live Stats")

    -- يتحدث كل ثانية
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local ping = math.floor((GetPing() * 1000))
                local ball = GetBall()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local dist = ball and root and math.floor((root.Position - ball.Position).Magnitude) or 0

                InfoGroup:Clear()
                InfoGroup:AddLabel("Ping: " .. ping .. " ms", true)
                InfoGroup:AddLabel("Ball Distance: " .. dist .. " studs", true)
                InfoGroup:AddLabel("Targeted: " .. tostring(IsTargeted()), true)
                InfoGroup:AddLabel("Auto Parry: " .. (Settings.AutoParry and "ON" or "OFF"), true)
            end)
        end
    end)
end

-- ==================== SETTINGS TAB ====================
VNDXS.Interface.ApplySettingsTab(Window)

-- Credits Tab
pcall(function()
    local applyCredits = loadstring(game:HttpGet(VNDXS.BaseUrl .. "Components/CreditsTab.luau"))()
    if type(applyCredits) == "function" then applyCredits(Window) end
end)

Library:Notify("VNDXS HUB | Blade Ball loaded! ⚔️", 5)

-- تنظيف عند الإغلاق
Library.Unloaded:Connect(function()
    if Circle then Circle:Destroy() end
    if FOVCircle then FOVCircle:Remove() end
end)
