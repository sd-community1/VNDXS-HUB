--[[
    VNDXS HUB - Murder Mystery 2
    Version: 1.0.0

    المزايا:
    - Role Detector: كشف القاتل والشريف فوراً مع إشعار بصورتهم
    - ESP متكامل: ألوان حسب الدور + تغير عند الهجوم
    - Silent Aim: للسكين (Throw) وللمسدس (ShootGun) نحو القاتل
    - Attack Detector: يكشف متى القاتل يهجم ويغير لون الـ ESP
    - Gun Drop ESP: يظهر المسدس المتساقط على الأرض
    - Coin Farm: يجمع العملات تلقائياً
    - Speed Toggle: تغيير السرعة
    - Anti-AFK: يمنع الكيك
    - Role History: يحفظ تاريخ القتلة والشرفاء في الجولة
]]

-- ==================== Interface Check ====================
if not VNDXS.Interface or not VNDXS.Interface.Library then
    warn("[VNDXS/MM2] Interface not loaded, retrying...")
    task.wait(2)
    VNDXS.Interface = loadstring(game:HttpGet(VNDXS.BaseUrl .. "Components/Interface.luau"))()
    if not VNDXS.Interface or not VNDXS.Interface.Library then
        error("[VNDXS/MM2] Interface failed.")
        return
    end
end

-- ==================== Services ====================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Library     = VNDXS.Interface.Library
local SaveManager = VNDXS.Interface.SaveManager
local Theme       = VNDXS.Theme

-- ==================== Helpers ====================
local function HexToColor3(hex)
    hex = hex:gsub("#","")
    return Color3.new(
        tonumber(hex:sub(1,2),16)/255,
        tonumber(hex:sub(3,4),16)/255,
        tonumber(hex:sub(5,6),16)/255
    )
end

local function GetChar(player)
    return player and player.Character
end

local function GetRoot(player)
    local c = GetChar(player)
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(player)
    local c = GetChar(player)
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ==================== Role System ====================
local Roles = {
    Murderer = nil,
    Sheriff  = nil,
}

local RoleHistory = {}  -- يحفظ تاريخ الأدوار في الجولة

local WeaponNames = {
    Knife = { Role = "Murderer", Color = HexToColor3("FF3333") },
    Gun   = { Role = "Sheriff",  Color = HexToColor3("3399FF") },
}

local AttackAnimations = {
    "rbxassetid://2467567750",
    "rbxassetid://1957618848",
    "rbxassetid://2470501967",
    "rbxassetid://2467577524",
}

-- ==================== Settings ====================
local Settings = {
    ESP            = false,
    ESPGunDrop     = false,
    ESPCoins       = false,
    SilentAim      = false,
    SilentAimKnife = false,
    SilentAimGun   = false,
    SpeedEnabled   = false,
    SpeedValue     = 20,
    CoinFarm       = false,
    AntiAFK        = true,
    NotifyRoles    = true,
    AttackAlert    = true,
    Prediction     = 0.5,
}

-- ==================== ESP System ====================
local ESPObjects = {}

local function CreateESP(player, color)
    local char = GetChar(player)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if ESPObjects[player] then
        pcall(function() ESPObjects[player]:Destroy() end)
    end

    local bill = Instance.new("BillboardGui")
    bill.Name            = "VNDXS_MM2_ESP"
    bill.AlwaysOnTop     = true
    bill.Size            = UDim2.new(0, 130, 0, 45)  -- حجم مرئي
    bill.StudsOffset     = Vector3.new(0, 3.5, 0)
    bill.LightInfluence  = 0
    bill.Parent          = root

    local frame = Instance.new("Frame", bill)
    frame.Size                   = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3       = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel        = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local bar = Instance.new("Frame", frame)
    bar.Size             = UDim2.new(0, 4, 1, 0)
    bar.Position         = UDim2.new(0, 0, 0, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel  = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Size                   = UDim2.new(1, -8, 0.5, 0)
    nameLabel.Position               = UDim2.new(0, 8, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3             = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font                   = Enum.Font.GothamBold
    nameLabel.TextSize               = 12
    nameLabel.TextXAlignment         = Enum.TextXAlignment.Left
    nameLabel.TextYAlignment         = Enum.TextYAlignment.Center
    nameLabel.Text                   = player.Name

    local roleLabel = Instance.new("TextLabel", frame)
    roleLabel.Size                   = UDim2.new(1, -8, 0.5, 0)
    roleLabel.Position               = UDim2.new(0, 8, 0.5, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.TextColor3             = color
    roleLabel.TextStrokeTransparency = 0.5
    roleLabel.Font                   = Enum.Font.Gotham
    roleLabel.TextSize               = 11
    roleLabel.TextXAlignment         = Enum.TextXAlignment.Left
    roleLabel.TextYAlignment         = Enum.TextYAlignment.Center

    local role = Roles.Murderer == player and "Murderer 🔪"
        or Roles.Sheriff == player and "Sheriff 🔫"
        or "Innocent"
    roleLabel.Text = role

    ESPObjects[player] = bill

    -- مسافة ديناميكية
    task.spawn(function()
        while bill and bill.Parent do
            task.wait(0.5)
            pcall(function()
                local myRoot = GetRoot(LocalPlayer)
                local theirRoot = GetRoot(player)
                if myRoot and theirRoot then
                    local dist = math.floor((myRoot.Position - theirRoot.Position).Magnitude)
                    nameLabel.Text = player.Name .. " [" .. dist .. "m]"
                end
            end)
        end
    end)

    return { Bill = bill, Bar = bar, RoleLabel = roleLabel }
end

local function RemoveESP(player)
    if ESPObjects[player] then
        pcall(function() ESPObjects[player]:Destroy() end)
        ESPObjects[player] = nil
    end
end

local function RefreshAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.ESP then
            local color = Roles.Murderer == player and HexToColor3("FF3333")
                or Roles.Sheriff == player and HexToColor3("3399FF")
                or HexToColor3("AAAAAA")
            CreateESP(player, color)
        else
            RemoveESP(player)
        end
    end
end

-- ESP loop يتحدث كل ثانيتين ليلتقط الأبرياء الجدد
task.spawn(function()
    while task.wait(2) do
        if not Settings.ESP then continue end
        RefreshAllESP()
    end
end)

-- ==================== Gun Drop ESP ====================
local GunDropESPs = {}

local function AddGunDropESP(obj)
    if not Settings.ESPGunDrop then return end
    if GunDropESPs[obj] then return end

    local bill = Instance.new("BillboardGui")
    bill.AlwaysOnTop = true
    bill.Size        = UDim2.new(0,80,0,25)
    bill.StudsOffset = Vector3.new(0,2,0)
    bill.Parent      = obj

    local lbl = Instance.new("TextLabel", bill)
    lbl.Size                 = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 0.4
    lbl.BackgroundColor3     = Color3.new(0,0,0)
    lbl.TextColor3           = HexToColor3("FFD700")
    lbl.Font                 = Enum.Font.GothamBold
    lbl.TextSize             = 13
    lbl.Text                 = "GUN DROP"
    lbl.TextStrokeTransparency = 0.5
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0,4)

    GunDropESPs[obj] = bill
end

-- ==================== Coin Farm ====================
local function FarmCoins()
    task.spawn(function()
        while Settings.CoinFarm do
            task.wait(0.15)
            pcall(function()
                local myRoot = GetRoot(LocalPlayer)
                if not myRoot then return end

                -- MM2 يضع العملات في مجلد معين أو مباشرة في workspace
                local coinFolders = {
                    workspace:FindFirstChild("Coins"),
                    workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Coins"),
                    workspace,
                }

                for _, folder in ipairs(coinFolders) do
                    if not folder then continue end
                    for _, obj in ipairs(folder:GetChildren()) do
                        -- أسماء العملات الممكنة في MM2
                        if obj.Name == "Coin"
                            or obj.Name == "GoldCoin"
                            or obj.Name == "CoinPickup"
                            or (obj:IsA("BasePart") and string.find(obj.Name:lower(), "coin"))
                        then
                            myRoot.CFrame = CFrame.new(obj.Position)
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
    end)
end

-- ==================== Anti AFK ====================
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end)
    end
end)

-- ==================== Role Detector ====================
local function NotifyRole(roleType, player)
    if not Settings.NotifyRoles then return end
    pcall(function()
        local image = Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size420x420
        )
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = roleType == "Murderer" and "MURDERER DETECTED" or "SHERIFF DETECTED",
            Text     = player.Name,
            Icon     = image,
            Duration = 6,
        })
    end)

    table.insert(RoleHistory, {
        Round    = os.time(),
        Role     = roleType,
        Player   = player.Name,
    })

    Library:Notify(roleType .. ": " .. player.Name, 5)
end

-- ==================== Attack Detector ====================
local function WatchAttack(player, chamRef)
    pcall(function()
        local animator = GetHumanoid(player) and GetHumanoid(player):WaitForChild("Animator", 5)
        if not animator then return end

        animator.AnimationPlayed:Connect(function(track)
            if not track or not track.Animation then return end
            if not table.find(AttackAnimations, track.Animation.AnimationId) then return end
            if not Settings.AttackAlert then return end

            -- يغير لون الـ ESP للبنفسجي عند الهجوم
            if chamRef and chamRef.Bar then
                chamRef.Bar.BackgroundColor3 = HexToColor3("FF00FF")
                chamRef.RoleLabel.Text = "ATTACKING!"
            end

            Library:Notify(player.Name .. " is attacking!", 3)

            task.spawn(function()
                while true do
                    task.wait(0.05)
                    local playing = animator:GetPlayingAnimationTracks()
                    local still = false
                    for _, t in ipairs(playing) do
                        if table.find(AttackAnimations, t.Animation.AnimationId) then
                            still = true
                        end
                    end
                    if not still then break end
                end
                -- يرجع اللون الأصلي
                if chamRef and chamRef.Bar then
                    chamRef.Bar.BackgroundColor3 = HexToColor3("FF3333")
                    chamRef.RoleLabel.Text = "Murderer 🔪"
                end
            end)
        end)
    end)
end

-- ==================== Player Initializer ====================
local function InitPlayer(player)
    if player == LocalPlayer then return end

    -- نراقب الـ Backpack لكشف الأسلحة
    local function onCharacter(char)
        local backpack = player:WaitForChild("Backpack", 10)
        if not backpack then return end

        backpack.ChildAdded:Connect(function(tool)
            local weaponData = WeaponNames[tool.Name]
            if not weaponData then return end

            Roles[weaponData.Role] = player
            NotifyRole(weaponData.Role, player)

            -- نصنع ESP للاعب
            local color = weaponData.Color
            local espRef = CreateESP(player, color)

            -- نراقب هجمات القاتل
            if weaponData.Role == "Murderer" then
                WatchAttack(player, espRef)
            end
        end)

        -- نمسح الدور عند الموت
        char:WaitForChild("Humanoid", 5).Died:Connect(function()
            if Roles.Murderer == player then Roles.Murderer = nil end
            if Roles.Sheriff  == player then Roles.Sheriff  = nil end
            RemoveESP(player)
        end)
    end

    if player.Character then onCharacter(player.Character) end
    player.CharacterAdded:Connect(onCharacter)
end

-- تهيئة اللاعبين الحاليين
for _, p in ipairs(Players:GetPlayers()) do InitPlayer(p) end
Players.PlayerAdded:Connect(InitPlayer)
Players.PlayerRemoving:Connect(function(p)
    if Roles.Murderer == p then Roles.Murderer = nil end
    if Roles.Sheriff  == p then Roles.Sheriff  = nil end
    RemoveESP(p)
end)

-- Gun Drop في الـ Workspace
workspace.ChildAdded:Connect(function(child)
    if child.Name == "GunDrop" then
        AddGunDropESP(child)
        child.AncestryChanged:Connect(function()
            if not child.Parent then
                if GunDropESPs[child] then
                    pcall(function() GunDropESPs[child]:Destroy() end)
                    GunDropESPs[child] = nil
                end
            end
        end)
    end
end)

-- ==================== Remote Sniffer (لمعرفة اسم Remote المسدس) ====================
-- شغّل السكريبت ثم استخدم المسدس مرة واحدة — سيظهر الاسم في الكونسول
pcall(function()
    local sniffMT  = getrawmetatable(game)
    local sniffOld = sniffMT.__namecall
    setreadonly(sniffMT, false)
    sniffMT.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            pcall(function()
                warn("[VNDXS/MM2] Remote: " .. self.Name .. " | Method: " .. method)
            end)
        end
        return sniffOld(self, ...)
    end)
    setreadonly(sniffMT, true)

    -- نوقف الـ sniffer بعد 30 ثانية عشان لا يثقل
    task.delay(30, function()
        pcall(function()
            setreadonly(sniffMT, false)
            sniffMT.__namecall = sniffOld
            setreadonly(sniffMT, true)
        end)
        warn("[VNDXS/MM2] Remote sniffer stopped.")
    end)
end)

-- ==================== Silent Aim (hookmetamethod) ====================
local RayParams = RaycastParams.new()
RayParams.IgnoreWater  = true
RayParams.FilterType   = Enum.RaycastFilterType.Blacklist
RayParams.FilterDescendantsInstances = {LocalPlayer.Character}

local function GetClosestEnemy()
    -- نستهدف القاتل أولاً، وإذا لم يوجد نستهدف أقرب لاعب
    if Roles.Murderer and GetRoot(Roles.Murderer) then
        return Roles.Murderer
    end
    local best, bestDist = nil, math.huge
    local myRoot = GetRoot(LocalPlayer)
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and GetRoot(p) then
            local d = (myRoot.Position - GetRoot(p).Position).Magnitude
            if d < bestDist then bestDist = d; best = p end
        end
    end
    return best
end

pcall(function()
    local mt    = getrawmetatable(game)
    local old   = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if Settings.SilentAim then
            local selfName = ""
            pcall(function() selfName = self.Name end)

            -- Silent Aim للسكين (Throw)
            if Settings.SilentAimKnife
                and (method == "FireServer" or method == "InvokeServer")
                and (selfName == "Throw" or selfName == "ThrowKnife" or selfName == "KnifeThrow")
            then
                pcall(function()
                    local target = GetClosestEnemy()
                    if not target then return end
                    local root   = GetRoot(target)
                    local myRoot = GetRoot(LocalPlayer)
                    if not root or not myRoot then return end
                    local vel  = root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
                    local dist = (root.Position - myRoot.Position).Magnitude
                    local pred = vel * Settings.Prediction * dist / 100
                    RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    local ray = workspace:Raycast(
                        myRoot.Position,
                        (root.Position - myRoot.Position + pred).Unit * 500,
                        RayParams
                    )
                    -- نبدّل الـ argument الأول أو الثاني حسب نوع الـ remote
                    if ray then
                        if typeof(args[1]) == "Vector3" then args[1] = ray.Position
                        elseif typeof(args[2]) == "Vector3" then args[2] = ray.Position
                        else args[1] = ray.Position end
                    end
                end)
            end

            -- Silent Aim للمسدس (Sheriff → Murderer)
            if Settings.SilentAimGun
                and (method == "FireServer" or method == "InvokeServer")
                and (selfName == "ShootGun" or selfName == "Shoot" or selfName == "GunShoot" or selfName == "Fire")
            then
                pcall(function()
                    local target = Roles.Murderer and GetRoot(Roles.Murderer) and Roles.Murderer
                        or GetClosestEnemy()
                    if not target then return end
                    local root = GetRoot(target)
                    if not root then return end
                    local pred = root.AssemblyLinearVelocity / 40
                    local aimPos = root.Position
                        + (math.abs(root.AssemblyLinearVelocity.Y) < 10 and pred or Vector3.zero)
                    -- نبدّل أول Vector3 في الـ args
                    local replaced = false
                    for i, v in ipairs(args) do
                        if typeof(v) == "Vector3" then
                            args[i] = aimPos
                            replaced = true
                            break
                        end
                    end
                    if not replaced then
                        args[1] = aimPos
                    end
                end)
            end
        end

        return old(self, table.unpack(args))
    end)
    setreadonly(mt, true)
end)

-- ==================== Round Reset ====================
-- نمسح الأدوار عند بداية جولة جديدة
pcall(function()
    local status = workspace:WaitForChild("Status", 10)
    if status then
        status:GetPropertyChangedSignal("Value"):Connect(function()
            if status.Value:find("Intermission") or status.Value:find("Starting") then
                Roles.Murderer = nil
                Roles.Sheriff  = nil
                -- نمسح كل الـ ESP
                for _, p in ipairs(Players:GetPlayers()) do
                    RemoveESP(p)
                end
            end
        end)
    end
end)

-- ==================== Window ====================
local Window = Library:CreateWindow({
    Title        = "VNDXS HUB  •  MURDER MYSTERY 2",
    Footer       = "v"..VNDXS.Version.."  |  dsc.gg/vndxshub",
    NotifySide   = "Right",
    ShowCustomCursor = false,
    AutoShow     = true,
    Center       = true,
    TabPadding   = 3,
    MenuFadeTime = 0,
    CornerRadius = 2,
})

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
    Info     = Window:AddTab("Info",     "user"),
    ESP      = Window:AddTab("ESP",      "eye"),
    Combat   = Window:AddTab("Combat",   "crosshair"),
    Player   = Window:AddTab("Player",   "zap"),
    Roles    = Window:AddTab("Roles",    "shield"),
    Settings = Window:AddTab("Settings", "settings"),
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
    UserGroup:AddLabel("Game: Murder Mystery 2", true)
    UserGroup:AddLabel("Hub: VNDXS HUB v"..VNDXS.Version, true)

    local LogGroup = Tabs.Info:AddRightGroupbox("Changelog")
    for _, v in ipairs({
        "VNDXS HUB v1.0.0",
        "<font color='rgb(255,215,0)'>★ MM2 Support Added</font>",
        "<font color='rgb(30,144,255)'>+ Role Detector + Notify</font>",
        "<font color='rgb(30,144,255)'>+ ESP (Murderer/Sheriff/Innocent)</font>",
        "<font color='rgb(30,144,255)'>+ Attack Detector (color change)</font>",
        "<font color='rgb(30,144,255)'>+ Silent Aim (Knife + Gun)</font>",
        "<font color='rgb(30,144,255)'>+ Gun Drop ESP</font>",
        "<font color='rgb(30,144,255)'>+ Coin Farm</font>",
        "<font color='rgb(30,144,255)'>+ Role History</font>",
        "<font color='rgb(30,144,255)'>+ Round Auto-Reset</font>",
    }) do LogGroup:AddLabel(v, true) end
end

-- ==================== ESP TAB ====================
do
    local ESPGroup = Tabs.ESP:AddLeftGroupbox("Player ESP")

    ESPGroup:AddToggle("ESPToggle", {
        Text    = "Enable ESP",
        Default = false,
        Callback = function(v)
            Settings.ESP = v
            RefreshAllESP()
        end,
    })
    ESPGroup:AddLabel("🔴 Red = Murderer\n🔵 Blue = Sheriff\n⚪ Gray = Innocent\n🟣 Purple = Attacking", true)
    ESPGroup:AddDivider()

    ESPGroup:AddToggle("GunDropESP", {
        Text    = "Gun Drop ESP",
        Default = false,
        Callback = function(v)
            Settings.ESPGunDrop = v
            if not v then
                for obj, bill in pairs(GunDropESPs) do
                    pcall(function() bill:Destroy() end)
                    GunDropESPs[obj] = nil
                end
            end
        end,
    })
    ESPGroup:AddLabel("Shows dropped guns on the map.", true)

    local NotifyGroup = Tabs.ESP:AddRightGroupbox("Notifications")

    NotifyGroup:AddToggle("NotifyRolesToggle", {
        Text    = "Role Notifications",
        Default = true,
        Callback = function(v) Settings.NotifyRoles = v end,
    })
    NotifyGroup:AddLabel("Shows popup with player photo\nwhen Murderer/Sheriff detected.", true)

    NotifyGroup:AddToggle("AttackAlertToggle", {
        Text    = "Attack Alert",
        Default = true,
        Callback = function(v) Settings.AttackAlert = v end,
    })
    NotifyGroup:AddLabel("ESP turns purple when\nMurderer swings knife.", true)
end

-- ==================== COMBAT TAB ====================
do
    local SilentGroup = Tabs.Combat:AddLeftGroupbox("Silent Aim")

    SilentGroup:AddToggle("SilentAimToggle", {
        Text    = "Enable Silent Aim",
        Default = false,
        Callback = function(v) Settings.SilentAim = v end,
    })

    SilentGroup:AddToggle("SilentKnifeToggle", {
        Text    = "Knife Silent Aim (Throw)",
        Default = false,
        Callback = function(v) Settings.SilentAimKnife = v end,
    })
    SilentGroup:AddLabel("Redirects knife throw\nto closest enemy.", true)

    SilentGroup:AddToggle("SilentGunToggle", {
        Text    = "Gun Silent Aim (Sheriff)",
        Default = false,
        Callback = function(v) Settings.SilentAimGun = v end,
    })
    SilentGroup:AddLabel("Auto-aims gun at\nMurderer (if known).", true)

    SilentGroup:AddSlider("PredictionSlider", {
        Text     = "Prediction Strength",
        Default  = 50,
        Min      = 0,
        Max      = 100,
        Rounding = 0,
        Callback = function(v) Settings.Prediction = v / 100 end,
    })
    SilentGroup:AddLabel("Higher = more lead on moving targets.", true)
end

-- ==================== PLAYER TAB ====================
do
    local MoveGroup = Tabs.Player:AddLeftGroupbox("Movement")

    MoveGroup:AddToggle("SpeedToggle", {
        Text    = "Speed Boost",
        Default = false,
        Callback = function(v)
            Settings.SpeedEnabled = v
            pcall(function()
                local hum = GetHumanoid(LocalPlayer)
                if hum then
                    hum.WalkSpeed = v and Settings.SpeedValue or 16
                end
            end)
        end,
    })

    MoveGroup:AddSlider("SpeedSlider", {
        Text     = "Walk Speed",
        Default  = 20,
        Min      = 16,
        Max      = 60,
        Rounding = 0,
        Callback = function(v)
            Settings.SpeedValue = v
            if Settings.SpeedEnabled then
                pcall(function()
                    local hum = GetHumanoid(LocalPlayer)
                    if hum then hum.WalkSpeed = v end
                end)
            end
        end,
    })

    MoveGroup:AddToggle("InfJumpToggle", {
        Text    = "Infinite Jump",
        Default = false,
        Callback = function(v) Settings.InfJump = v end,
    })

    UserInputService.JumpRequest:Connect(function()
        if Settings.InfJump then
            pcall(function()
                local hum = GetHumanoid(LocalPlayer)
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end)

    local FarmGroup = Tabs.Player:AddRightGroupbox("Farm")

    FarmGroup:AddToggle("CoinFarmToggle", {
        Text    = "Auto Coin Farm",
        Default = false,
        Callback = function(v)
            Settings.CoinFarm = v
            if v then FarmCoins() end
        end,
    })
    FarmGroup:AddLabel("Teleports to coins automatically.\nMay look suspicious.", true)

    FarmGroup:AddToggle("AntiAFKToggle", {
        Text    = "Anti AFK",
        Default = true,
        Callback = function(v) Settings.AntiAFK = v end,
    })
end

-- ==================== ROLES TAB ====================
do
    local LiveGroup = Tabs.Roles:AddLeftGroupbox("Live Roles")

    -- يتحدث كل ثانيتين
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                LiveGroup:Clear()
                LiveGroup:AddLabel("Murderer:", true)
                LiveGroup:AddLabel(Roles.Murderer and Roles.Murderer.Name or "Unknown", true)
                LiveGroup:AddDivider()
                LiveGroup:AddLabel("Sheriff:", true)
                LiveGroup:AddLabel(Roles.Sheriff and Roles.Sheriff.Name or "Unknown", true)
            end)
        end
    end)

    local HistoryGroup = Tabs.Roles:AddRightGroupbox("Round History")

    task.spawn(function()
        while task.wait(3) do
            pcall(function()
                HistoryGroup:Clear()
                local count = math.min(#RoleHistory, 6)
                for i = #RoleHistory, #RoleHistory - count + 1, -1 do
                    local entry = RoleHistory[i]
                    if entry then
                        local icon = entry.Role == "Murderer" and "🔪" or "🔫"
                        HistoryGroup:AddLabel(icon.." "..entry.Player.." ("..entry.Role..")", true)
                    end
                end
                if #RoleHistory == 0 then
                    HistoryGroup:AddLabel("No roles detected yet.", true)
                end
            end)
        end
    end)
end

-- ==================== SETTINGS TAB ====================
VNDXS.Interface.ApplySettingsTab(Window)

pcall(function()
    local applyCredits = loadstring(game:HttpGet(VNDXS.BaseUrl .. "Components/CreditsTab.luau"))()
    if type(applyCredits) == "function" then applyCredits(Window) end
end)

Library:Notify("VNDXS HUB | Murder Mystery 2 loaded!", 5)

if Library.Unloaded and typeof(Library.Unloaded) ~= "boolean" then
    Library.Unloaded:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            RemoveESP(p)
        end
    end)
end
