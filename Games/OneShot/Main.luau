--[[
    VNDXS HUB - One Shot
    Features: ESP, Aimbot, Silent Aim, Triggerbot, No Recoil, Prediction
]]

-- ==================== Interface Check ====================
if not VNDXS.Interface or not VNDXS.Interface.Library then
    warn("[VNDXS/OneShot] Interface not loaded, retrying...")
    task.wait(2)
    VNDXS.Interface = loadstring(game:HttpGet(VNDXS.BaseUrl .. "Components/Interface.luau"))()
    if not VNDXS.Interface or not VNDXS.Interface.Library then
        error("[VNDXS/OneShot] Interface failed.")
        return
    end
end

-- ==================== Services ====================
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local Camera        = workspace.CurrentCamera

local LocalPlayer   = Players.LocalPlayer
local Library       = VNDXS.Interface.Library
local SaveManager   = VNDXS.Interface.SaveManager
local ThemeManager  = VNDXS.Interface.ThemeManager
local Theme         = VNDXS.Theme

-- ==================== Helpers ====================
local function HexToColor3(hex)
    hex = hex:gsub("#","")
    return Color3.new(
        tonumber(hex:sub(1,2),16)/255,
        tonumber(hex:sub(3,4),16)/255,
        tonumber(hex:sub(5,6),16)/255
    )
end

local function WorldToViewport(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetCharParts(player)
    local char = player.Character
    if not char then return nil end
    return {
        Head       = char:FindFirstChild("Head"),
        UpperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
        LowerTorso = char:FindFirstChild("LowerTorso"),
        Root       = char:FindFirstChild("HumanoidRootPart"),
        Humanoid   = char:FindFirstChild("Humanoid"),
        LeftArm    = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm"),
        RightArm   = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm"),
        LeftLeg    = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg"),
        RightLeg   = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg"),
    }
end

local function IsAlive(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function IsVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, workspace.CurrentCamera})
    if not hit then return true end
    local char = part:FindFirstAncestorOfClass("Model")
    return hit:IsDescendantOf(char or workspace)
end

local function GetDistance(part)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not part then return 0 end
    return math.floor((root.Position - part.Position).Magnitude)
end

local function GetThreatLevel(player)
    -- يحسب مستوى الخطر للـ Tactical ESP
    local parts = GetCharParts(player)
    if not parts or not parts.Humanoid then return 0 end
    local hp = parts.Humanoid.Health / parts.Humanoid.MaxHealth
    local dist = GetDistance(parts.Root)
    local threat = 0
    if hp < 0.3 then threat = threat + 3 end   -- صحة منخفضة = هدف سهل
    if dist < 30 then threat = threat + 2 end   -- قريب = خطر
    if IsVisible(parts.Head) then threat = threat + 2 end -- مرئي
    return threat
end

-- ==================== State ====================
local ESPEnabled        = false
local ESPBoxes          = false
local ESPTracers        = false
local ESPSkeleton       = false
local ESPInfo           = false
local ESPOffScreen      = false
local ESPProjectile     = false
local TacticalESP       = false

local AimbotEnabled     = false
local AimbotFOV         = 120
local AimbotSmooth      = 0.15
local AimbotPart        = "Head"
local AimbotVisCheck    = true
local AimbotDynFOV      = false

local SilentAimEnabled  = false
local TriggerbotEnabled = false
local NoRecoilEnabled   = false
local NoSpreadEnabled   = false
local PredictionEnabled = false
local BulletSpeed       = 300

-- ==================== Drawing ====================
local Drawings = {}

local function NewDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do d[k] = v end
    table.insert(Drawings, d)
    return d
end

local function ClearDrawings()
    for _, d in ipairs(Drawings) do
        pcall(function() d:Remove() end)
    end
    Drawings = {}
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible   = false
FOVCircle.Color     = HexToColor3(Theme.AccentColor)
FOVCircle.Thickness = 1.5
FOVCircle.Filled    = false
FOVCircle.NumSides  = 64
FOVCircle.Position  = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
FOVCircle.Radius    = AimbotFOV

-- ==================== ESP Rendering ====================
local ESPObjects = {}

local function GetESPForPlayer(player)
    if not ESPObjects[player] then
        ESPObjects[player] = {
            Box       = Drawing.new("Square"),
            BoxOutline= Drawing.new("Square"),
            Tracer    = Drawing.new("Line"),
            NameText  = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"),
            HealthFill= Drawing.new("Square"),
            DistText  = Drawing.new("Text"),
            WeaponText= Drawing.new("Text"),
            -- Skeleton lines
            Skeleton  = {
                Drawing.new("Line"), -- Head → Torso
                Drawing.new("Line"), -- Torso → LowerTorso
                Drawing.new("Line"), -- LowerTorso → LeftLeg
                Drawing.new("Line"), -- LowerTorso → RightLeg
                Drawing.new("Line"), -- Torso → LeftArm
                Drawing.new("Line"), -- Torso → RightArm
            },
            -- Off-screen arrow
            Arrow     = Drawing.new("Triangle"),
        }
        -- تهيئة الإعدادات
        local o = ESPObjects[player]
        o.Box.Thickness       = 1.5
        o.BoxOutline.Thickness= 3
        o.BoxOutline.Color    = Color3.new(0,0,0)
        o.Tracer.Thickness    = 1
        o.NameText.Size       = 13
        o.NameText.Font       = 2
        o.NameText.Center     = true
        o.NameText.Outline    = true
        o.DistText.Size       = 11
        o.DistText.Center     = true
        o.DistText.Outline    = true
        o.WeaponText.Size     = 11
        o.WeaponText.Center   = true
        o.WeaponText.Outline  = true
        o.HealthBar.Color     = Color3.new(0,0,0)
        o.Arrow.Filled        = true
        for _, line in ipairs(o.Skeleton) do
            line.Thickness = 1
            line.Visible   = false
        end
    end
    return ESPObjects[player]
end

local function HideESP(obj)
    obj.Box.Visible        = false
    obj.BoxOutline.Visible = false
    obj.Tracer.Visible     = false
    obj.NameText.Visible   = false
    obj.HealthBar.Visible  = false
    obj.HealthFill.Visible = false
    obj.DistText.Visible   = false
    obj.WeaponText.Visible = false
    obj.Arrow.Visible      = false
    for _, line in ipairs(obj.Skeleton) do line.Visible = false end
end

local function RemoveESPForPlayer(player)
    if ESPObjects[player] then
        local o = ESPObjects[player]
        pcall(function()
            o.Box:Remove(); o.BoxOutline:Remove(); o.Tracer:Remove()
            o.NameText:Remove(); o.HealthBar:Remove(); o.HealthFill:Remove()
            o.DistText:Remove(); o.WeaponText:Remove(); o.Arrow:Remove()
            for _, line in ipairs(o.Skeleton) do line:Remove() end
        end)
        ESPObjects[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESPForPlayer)

-- ==================== Aimbot ====================
local function GetCurrentFOV(dist)
    if AimbotDynFOV then
        -- Dynamic FOV: يتسع للقريب ويضيق للبعيد
        if dist < 20      then return AimbotFOV * 1.5
        elseif dist > 100 then return AimbotFOV * 0.5
        else return AimbotFOV end
    end
    return AimbotFOV
end

local function GetBestTarget()
    local bestPlayer = nil
    local bestDist   = math.huge
    local center     = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not IsAlive(player) then continue end
        local parts = GetCharParts(player)
        if not parts then continue end
        local targetPart = parts[AimbotPart] or parts.Head
        if not targetPart then continue end
        if AimbotVisCheck and not IsVisible(targetPart) then continue end
        local screenPos, onScreen = WorldToViewport(targetPart.Position)
        if not onScreen then continue end
        local dist = (center - screenPos).Magnitude
        local fov  = GetCurrentFOV(GetDistance(targetPart))
        if dist < fov and dist < bestDist then
            bestDist   = dist
            bestPlayer = player
        end
    end
    return bestPlayer
end

-- Prediction
local PlayerVelocities = {}
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local parts = GetCharParts(player)
        if parts and parts.Root then
            local prev = PlayerVelocities[player] and PlayerVelocities[player].pos
            PlayerVelocities[player] = {
                pos = parts.Root.Position,
                vel = prev and (parts.Root.Position - prev) / (1/60) or Vector3.new()
            }
        end
    end
end)

local function GetPredictedPosition(player, part)
    if not PredictionEnabled or not part then return part and part.Position end
    local data = PlayerVelocities[player]
    if not data then return part.Position end
    local dist    = GetDistance(part)
    local travelT = dist / BulletSpeed
    return part.Position + (data.vel * travelT)
end

-- ==================== Main Render Loop ====================
RunService.RenderStepped:Connect(function()
    local center    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local myChar    = LocalPlayer.Character
    local myRoot    = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- FOV Circle
    FOVCircle.Visible  = AimbotEnabled
    FOVCircle.Radius   = AimbotFOV
    FOVCircle.Position = center

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local obj = GetESPForPlayer(player)

        if not ESPEnabled or not IsAlive(player) then
            HideESP(obj)
            continue
        end

        local parts = GetCharParts(player)
        if not parts or not parts.Head or not parts.Root then
            HideESP(obj)
            continue
        end

        local headScreen, headOn = WorldToViewport(parts.Head.Position + Vector3.new(0,0.7,0))
        local rootScreen, rootOn = WorldToViewport(parts.Root.Position - Vector3.new(0,2.5,0))

        -- ===== Off-Screen Arrow =====
        if not headOn and ESPOffScreen then
            local dir = (parts.Head.Position - Camera.CFrame.Position)
            local flat = Vector2.new(dir.X, dir.Z).Unit
            local angle = math.atan2(flat.Y, flat.X)
            local margin = 40
            local arrowPos = Vector2.new(
                center.X + math.cos(angle) * (center.X - margin),
                center.Y + math.sin(angle) * (center.Y - margin)
            )
            obj.Arrow.Visible   = true
            obj.Arrow.PointA    = arrowPos + Vector2.new(math.cos(angle)*10, math.sin(angle)*10)
            obj.Arrow.PointB    = arrowPos + Vector2.new(math.cos(angle+2.3)*8, math.sin(angle+2.3)*8)
            obj.Arrow.PointC    = arrowPos + Vector2.new(math.cos(angle-2.3)*8, math.sin(angle-2.3)*8)
            local dist = GetDistance(parts.Root)
            -- لون يتغير حسب المسافة
            if     dist < 20  then obj.Arrow.Color = Color3.new(1,0,0)
            elseif dist < 50  then obj.Arrow.Color = Color3.new(1,0.5,0)
            else                    obj.Arrow.Color = HexToColor3(Theme.AccentColor) end
        else
            obj.Arrow.Visible = false
        end

        if not headOn and not rootOn then
            obj.Box.Visible = false; obj.BoxOutline.Visible = false
            obj.Tracer.Visible = false; obj.NameText.Visible = false
            obj.HealthBar.Visible = false; obj.HealthFill.Visible = false
            obj.DistText.Visible = false; obj.WeaponText.Visible = false
            for _, line in ipairs(obj.Skeleton) do line.Visible = false end
            continue
        end

        -- لون ESP حسب الحالة (مرئي / خلف جدار / تهديد)
        local visible = IsVisible(parts.Head)
        local threat  = TacticalESP and GetThreatLevel(player) or 0
        local espColor
        if     threat >= 5 then espColor = Color3.new(1,0,0)         -- خطر جداً
        elseif threat >= 3 then espColor = Color3.new(1,0.5,0)       -- تهديد متوسط
        elseif visible      then espColor = HexToColor3(Theme.AccentColor)
        else                     espColor = Color3.new(0.5,0.5,0.5)  -- خلف جدار
        end

        -- ===== Box =====
        local boxH = math.abs(headScreen.Y - rootScreen.Y)
        local boxW = boxH * 0.65
        local boxX = headScreen.X - boxW/2
        local boxY = headScreen.Y

        if ESPBoxes then
            obj.BoxOutline.Visible  = true
            obj.BoxOutline.Position = Vector2.new(boxX-1, boxY-1)
            obj.BoxOutline.Size     = Vector2.new(boxW+2, boxH+2)
            obj.BoxOutline.Filled   = false

            obj.Box.Visible  = true
            obj.Box.Position = Vector2.new(boxX, boxY)
            obj.Box.Size     = Vector2.new(boxW, boxH)
            obj.Box.Color    = espColor
            obj.Box.Filled   = false
        else
            obj.Box.Visible = false; obj.BoxOutline.Visible = false
        end

        -- ===== Tracer =====
        if ESPTracers then
            obj.Tracer.Visible = true
            obj.Tracer.From    = Vector2.new(center.X, Camera.ViewportSize.Y)
            obj.Tracer.To      = Vector2.new(headScreen.X, headScreen.Y)
            obj.Tracer.Color   = espColor
        else
            obj.Tracer.Visible = false
        end

        -- ===== Info Overlay (Name / Distance / Weapon) =====
        if ESPInfo then
            local dist = GetDistance(parts.Root)
            local hum  = parts.Humanoid
            local hp   = hum and math.floor(hum.Health) or 0
            local maxHp= hum and math.floor(hum.MaxHealth) or 100

            obj.NameText.Visible   = true
            obj.NameText.Text      = player.Name
            obj.NameText.Color     = HexToColor3(Theme.FontColor)
            obj.NameText.Position  = Vector2.new(headScreen.X, boxY - 16)

            obj.DistText.Visible   = true
            obj.DistText.Text      = dist .. " studs | HP: " .. hp .. "/" .. maxHp
            obj.DistText.Color     = Color3.new(0.8,0.8,0.8)
            obj.DistText.Position  = Vector2.new(headScreen.X, boxY + boxH + 2)

            -- سلاح الخصم الحالي
            local tool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
            obj.WeaponText.Visible  = tool ~= nil
            obj.WeaponText.Text     = tool and ("🔫 "..tool.Name) or ""
            obj.WeaponText.Color    = HexToColor3(Theme.AccentColor)
            obj.WeaponText.Position = Vector2.new(headScreen.X, boxY + boxH + 14)

            -- Health Bar
            local barX    = boxX - 5
            local barH    = boxH
            local fillH   = barH * (hp / maxHp)
            local fillColor = Color3.new(1 - hp/maxHp, hp/maxHp, 0)

            obj.HealthBar.Visible  = true
            obj.HealthBar.Position = Vector2.new(barX - 3, boxY)
            obj.HealthBar.Size     = Vector2.new(3, barH)
            obj.HealthBar.Filled   = true
            obj.HealthBar.Color    = Color3.new(0.1,0.1,0.1)

            obj.HealthFill.Visible  = true
            obj.HealthFill.Position = Vector2.new(barX - 3, boxY + barH - fillH)
            obj.HealthFill.Size     = Vector2.new(3, fillH)
            obj.HealthFill.Filled   = true
            obj.HealthFill.Color    = fillColor
        else
            obj.NameText.Visible  = false
            obj.DistText.Visible  = false
            obj.WeaponText.Visible= false
            obj.HealthBar.Visible = false
            obj.HealthFill.Visible= false
        end

        -- ===== Skeleton =====
        if ESPSkeleton then
            local bones = {
                { parts.Head,       parts.UpperTorso },
                { parts.UpperTorso, parts.LowerTorso },
                { parts.LowerTorso, parts.LeftLeg    },
                { parts.LowerTorso, parts.RightLeg   },
                { parts.UpperTorso, parts.LeftArm    },
                { parts.UpperTorso, parts.RightArm   },
            }
            for i, bone in ipairs(bones) do
                local line = obj.Skeleton[i]
                if bone[1] and bone[2] then
                    local a, aOn = WorldToViewport(bone[1].Position)
                    local b, bOn = WorldToViewport(bone[2].Position)
                    line.Visible = aOn or bOn
                    line.From    = a
                    line.To      = b
                    line.Color   = espColor
                else
                    line.Visible = false
                end
            end
        else
            for _, line in ipairs(obj.Skeleton) do line.Visible = false end
        end
    end

    -- ===== Aimbot =====
    if AimbotEnabled and UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetBestTarget()
        if target then
            local parts = GetCharParts(target)
            local tPart = parts and parts[AimbotPart] or (parts and parts.Head)
            if tPart then
                local predPos        = GetPredictedPosition(target, tPart)
                local screenTarget, onScreen = WorldToViewport(predPos)
                if onScreen then
                    local screenCenter   = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local delta          = screenTarget - screenCenter
                    -- mousemoverel يحرك الماوس فعلياً مما يحرك الكاميرا
                    mousemoverel(
                        delta.X * AimbotSmooth,
                        delta.Y * AimbotSmooth
                    )
                end
            end
        end
    end

    -- ===== Triggerbot =====
    if TriggerbotEnabled then
        pcall(function()
            local unitRay = Camera:ScreenPointToRay(center.X, center.Y)
            local ray     = Ray.new(unitRay.Origin, unitRay.Direction * 1000)
            local hit     = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
            if hit then
                local model = hit:FindFirstAncestorOfClass("Model")
                local player = model and Players:GetPlayerFromCharacter(model)
                if player and player ~= LocalPlayer then
                    -- محاكاة إطلاق النار
                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                    if tool then
                        local remote = tool:FindFirstChildWhichIsA("RemoteEvent")
                        if remote then pcall(function() remote:FireServer() end) end
                    end
                end
            end
        end)
    end
end)

-- ===== Silent Aim =====
if SilentAimEnabled then
    local mt = getrawmetatable(game)
    local old= mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and SilentAimEnabled then
            local args = {...}
            local target = GetBestTarget()
            if target then
                local parts  = GetCharParts(target)
                local tPart  = parts and parts[AimbotPart] or parts and parts.Head
                if tPart then
                    local predPos = GetPredictedPosition(target, tPart)
                    for i, v in ipairs(args) do
                        if typeof(v) == "Vector3" then
                            args[i] = predPos
                        elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                            args[i] = tPart
                        end
                    end
                end
            end
            return old(self, table.unpack(args))
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end

-- ===== No Recoil =====
local LastCameraCF = Camera.CFrame
RunService.RenderStepped:Connect(function()
    if NoRecoilEnabled then
        pcall(function()
            local currentLook = Camera.CFrame.LookVector
            local lastLook    = LastCameraCF.LookVector
            -- نحسب الارتداد الرأسي ونعوضه
            local recoilY = math.asin(currentLook.Y) - math.asin(lastLook.Y)
            if math.abs(recoilY) > 0.001 then
                mousemoverel(0, math.deg(recoilY) * 10)
            end
        end)
    end
    LastCameraCF = Camera.CFrame
end)

-- ==================== Window ====================
local Window = Library:CreateWindow({
    Title        = "VNDXS HUB  •  ONE SHOT",
    Footer       = "v"..VNDXS.Version.."  |  dsc.gg/vndxshub",
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
    Info     = Window:AddTab("Info",        "user"),
    ESP      = Window:AddTab("ESP",         "eye"),
    Aimbot   = Window:AddTab("Aimbot",      "crosshair"),
    Silent   = Window:AddTab("Silent Aim",  "zap"),
    Weapon   = Window:AddTab("Weapon",      "shield"),
    Predict  = Window:AddTab("Prediction",  "activity"),
    Settings = Window:AddTab("Settings",    "settings"),
}

-- ==================== INFO TAB ====================
do
    local UserGroup = Tabs.Info:AddLeftGroupbox("Player Info")
    pcall(function()
        local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        UserGroup:AddImage("Avatar", { Image = thumb })
    end)
    UserGroup:AddLabel("Username: " .. LocalPlayer.Name, true)
    UserGroup:AddLabel("User ID: "  .. tostring(LocalPlayer.UserId), true)
    UserGroup:AddLabel("Game: One Shot", true)
    UserGroup:AddLabel("Hub: VNDXS HUB v"..VNDXS.Version, true)

    local LogGroup = Tabs.Info:AddRightGroupbox("Changelog")
    for _, v in ipairs({
        "VNDXS HUB v1.0.0",
        "<font color='rgb(255,215,0)'>★ One Shot Support</font>",
        "<font color='rgb(30,144,255)'>+ Full ESP System</font>",
        "<font color='rgb(30,144,255)'>+ Aimbot + Dynamic FOV</font>",
        "<font color='rgb(30,144,255)'>+ Silent Aim Adaptive</font>",
        "<font color='rgb(30,144,255)'>+ Triggerbot</font>",
        "<font color='rgb(30,144,255)'>+ No Recoil / No Spread</font>",
        "<font color='rgb(30,144,255)'>+ Predictive Aiming</font>",
        "<font color='rgb(30,144,255)'>+ Off-Screen Arrows</font>",
        "<font color='rgb(30,144,255)'>+ Tactical Threat ESP</font>",
    }) do LogGroup:AddLabel(v, true) end
end

-- ==================== ESP TAB ====================
do
    local MainESP = Tabs.ESP:AddLeftGroupbox("ESP")

    MainESP:AddToggle("ESPToggle", {
        Text    = "Enable ESP",
        Default = false,
        Callback = function(v) ESPEnabled = v end,
    })

    MainESP:AddToggle("ESPBoxToggle", {
        Text    = "Boxes (Corner)",
        Default = false,
        Callback = function(v) ESPBoxes = v end,
    })

    MainESP:AddToggle("ESPTracerToggle", {
        Text    = "Tracers",
        Default = false,
        Callback = function(v) ESPTracers = v end,
    })

    MainESP:AddToggle("ESPSkeletonToggle", {
        Text    = "Skeleton",
        Default = false,
        Callback = function(v) ESPSkeleton = v end,
    })

    MainESP:AddToggle("ESPInfoToggle", {
        Text    = "Info Overlay (Name / HP / Distance / Weapon)",
        Default = false,
        Callback = function(v) ESPInfo = v end,
    })

    local AdvESP = Tabs.ESP:AddRightGroupbox("Advanced ESP")

    AdvESP:AddToggle("TacticalESPToggle", {
        Text    = "Tactical Threat Priority",
        Default = false,
        Callback = function(v) TacticalESP = v end,
    })
    AdvESP:AddLabel("🔴 Red = High Threat\n🟠 Orange = Medium\n🔵 Blue = Normal", true)
    AdvESP:AddDivider()

    AdvESP:AddToggle("OffScreenToggle", {
        Text    = "Off-Screen Danger Arrows",
        Default = false,
        Callback = function(v) ESPOffScreen = v end,
    })
    AdvESP:AddLabel("Arrows change color by distance.", true)
    AdvESP:AddDivider()

    AdvESP:AddToggle("ProjectileESPToggle", {
        Text    = "Projectile & Grenade ESP",
        Default = false,
        Callback = function(v)
            ESPProjectile = v
            -- تتبع القنابل
            if v then
                task.spawn(function()
                    while ESPProjectile do
                        task.wait(0.1)
                        pcall(function()
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj:IsA("BasePart") and (
                                    string.find(obj.Name:lower(), "grenade") or
                                    string.find(obj.Name:lower(), "bomb") or
                                    string.find(obj.Name:lower(), "throwable")
                                ) then
                                    if not obj:FindFirstChild("VNDXS_ProjESP") then
                                        local bill = Instance.new("BillboardGui", obj)
                                        bill.Name = "VNDXS_ProjESP"
                                        bill.AlwaysOnTop = true
                                        bill.Size = UDim2.new(0,80,0,40)
                                        local lbl = Instance.new("TextLabel", bill)
                                        lbl.Size = UDim2.new(1,0,1,0)
                                        lbl.BackgroundTransparency = 1
                                        lbl.TextColor3 = Color3.new(1,0,0)
                                        lbl.TextStrokeTransparency = 0
                                        lbl.Font = Enum.Font.GothamBold
                                        lbl.TextSize = 14
                                        lbl.Text = "💣 " .. obj.Name
                                    end
                                end
                            end
                        end)
                    end
                end)
            end
        end,
    })
end

-- ==================== AIMBOT TAB ====================
do
    local AimGroup = Tabs.Aimbot:AddLeftGroupbox("Aimbot")

    AimGroup:AddToggle("AimbotToggle", {
        Text    = "Enable Aimbot",
        Default = false,
        Callback = function(v) AimbotEnabled = v end,
    })
    AimGroup:AddLabel("Hold Right Click to aim", true)

    AimGroup:AddSlider("FOVSlider", {
        Text     = "FOV Size",
        Default  = 120,
        Min      = 10,
        Max      = 500,
        Rounding = 0,
        Callback = function(v)
            AimbotFOV    = v
            FOVCircle.Radius = v
        end,
    })

    AimGroup:AddSlider("SmoothSlider", {
        Text     = "Smoothness",
        Default  = 15,
        Min      = 1,
        Max      = 100,
        Rounding = 0,
        Callback = function(v)
            AimbotSmooth = v / 100
        end,
    })

    AimGroup:AddDropdown("TargetPart", {
        Text   = "Target Part",
        Values = { "Head", "UpperTorso", "HumanoidRootPart" },
        Default = 1,
        Callback = function(v) AimbotPart = v end,
    })

    AimGroup:AddToggle("VisCheckToggle", {
        Text    = "Visibility Check",
        Default = true,
        Callback = function(v) AimbotVisCheck = v end,
    })

    local AdvAim = Tabs.Aimbot:AddRightGroupbox("Dynamic FOV")

    AdvAim:AddToggle("DynFOVToggle", {
        Text    = "Dynamic FOV (Auto-adjust)",
        Default = false,
        Callback = function(v) AimbotDynFOV = v end,
    })
    AdvAim:AddLabel("Wide at close range\nNarrow at long range", true)
end

-- ==================== SILENT AIM TAB ====================
do
    local SilentGroup = Tabs.Silent:AddLeftGroupbox("Silent Aim")

    SilentGroup:AddToggle("SilentAimToggle", {
        Text    = "Enable Silent Aim",
        Default = false,
        Callback = function(v) SilentAimEnabled = v end,
    })
    SilentGroup:AddLabel("Redirects bullets to target\nwithout moving camera.", true)

    SilentGroup:AddDivider()

    SilentGroup:AddToggle("TriggerbotToggle", {
        Text    = "Triggerbot",
        Default = false,
        Callback = function(v) TriggerbotEnabled = v end,
    })
    SilentGroup:AddLabel("Auto-fires when crosshair\nis on an enemy.", true)
end

-- ==================== WEAPON TAB ====================
do
    local WeaponGroup = Tabs.Weapon:AddLeftGroupbox("Weapon Mods")

    WeaponGroup:AddToggle("NoRecoilToggle", {
        Text    = "No Recoil",
        Default = false,
        Callback = function(v) NoRecoilEnabled = v end,
    })

    WeaponGroup:AddToggle("NoSpreadToggle", {
        Text    = "No Spread",
        Default = false,
        Callback = function(v)
            NoSpreadEnabled = v
            pcall(function()
                if v then
                    local mt  = getrawmetatable(game)
                    local old = mt.__index
                    setreadonly(mt, false)
                    mt.__index = newcclosure(function(self, key)
                        if key == "Spread" or key == "MaxSpread" or key == "MinSpread" then
                            return 0
                        end
                        return old(self, key)
                    end)
                    setreadonly(mt, true)
                end
            end)
        end,
    })
end

-- ==================== PREDICTION TAB ====================
do
    local PredGroup = Tabs.Predict:AddLeftGroupbox("Predictive Aiming")

    PredGroup:AddToggle("PredictionToggle", {
        Text    = "Enable Prediction",
        Default = false,
        Callback = function(v) PredictionEnabled = v end,
    })
    PredGroup:AddLabel("Calculates enemy movement\nand leads the target.", true)

    PredGroup:AddSlider("BulletSpeedSlider", {
        Text     = "Bullet Speed (studs/s)",
        Default  = 300,
        Min      = 50,
        Max      = 2000,
        Rounding = 0,
        Callback = function(v) BulletSpeed = v end,
    })
    PredGroup:AddLabel("Adjust to match your\ncurrent weapon's bullet speed.", true)
end

-- ==================== SETTINGS TAB ====================
VNDXS.Interface.ApplySettingsTab(Tabs.Settings and Window or Window)

-- Credits Tab
local ok, applyCredits = pcall(function()
    return loadstring(game:HttpGet(VNDXS.BaseUrl .. "Components/CreditsTab.luau"))()
end)
if ok and type(applyCredits) == "function" then
    applyCredits(Window)
end

Library:Notify("VNDXS HUB | One Shot loaded! 🎯", 5)

-- تنظيف عند الإغلاق
Library.Unloaded:Connect(function()
    ClearDrawings()
    FOVCircle:Remove()
    for player, _ in pairs(ESPObjects) do
        RemoveESPForPlayer(player)
    end
end)
