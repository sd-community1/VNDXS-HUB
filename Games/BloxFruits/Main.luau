--[[
    VNDXS HUB - Blox Fruits Main
    Version: 1.0.0
    Supports: First Sea | Second Sea | Third Sea
]]

-- ==================== Services ====================
local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local VirtualUser     = game:GetService("VirtualUser")

local LocalPlayer     = Players.LocalPlayer
local Character       = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid        = Character:WaitForChild("Humanoid")
local RootPart        = Character:WaitForChild("HumanoidRootPart")

local CommF_          = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- ==================== VNDXS Setup ====================
if not VNDXS.Interface or not VNDXS.Interface.Library then
    warn("[VNDXS/BloxFruits] Interface not loaded, retrying...")
    task.wait(2)
    VNDXS.Interface = loadstring(game:HttpGet(VNDXS.BaseUrl .. "Components/Interface.luau"))()
    if not VNDXS.Interface or not VNDXS.Interface.Library then
        error("[VNDXS/BloxFruits] Interface failed. Aborting.")
        return
    end
end

local Library      = VNDXS.Interface.Library
local SaveManager  = VNDXS.Interface.SaveManager
local ThemeManager = VNDXS.Interface.ThemeManager
local Theme        = VNDXS.Theme
local BF           = VNDXS.BloxFruits

-- ==================== Helpers ====================
local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.new(
        tonumber(hex:sub(1,2), 16) / 255,
        tonumber(hex:sub(3,4), 16) / 255,
        tonumber(hex:sub(5,6), 16) / 255
    )
end

local Number = math.random(1, 1000000)

local function round(n)
    return math.floor(tonumber(n) + 0.5)
end

local function isnil(thing)
    return thing == nil
end

local function GetChar()
    return LocalPlayer.Character
end

local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHuman()
    local c = GetChar()
    return c and c:FindFirstChild("Humanoid")
end

-- Tween الحركة
local function Tween(targetCFrame)
    local root = GetRoot()
    if not root then return end
    local tween = TweenService:Create(root,
        TweenInfo.new(0.15, Enum.EasingStyle.Linear),
        { CFrame = targetCFrame }
    )
    tween:Play()
    tween.Completed:Wait()
end

-- تجهيز السلاح
local function EquipTool(toolName)
    pcall(function()
        local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
            or (GetChar() and GetChar():FindFirstChild(toolName))
        if tool then
            LocalPlayer.Character.Humanoid:EquipTool(tool)
        end
    end)
end

-- ==================== Globals ====================
_G.AutoLevel    = false
_G.AutoNear     = false
_G.AutoChest    = false
_G.AutoMastery  = false
_G.Fast_Delay   = 0.1
_G.ServerHop    = false

local ESPPlayer      = false
local DevilFruitESP  = false
local ChestESP       = false
local IslandESP      = false
local FlowerESP      = false
local RealFruitESP   = false

local SelectWeapon   = "Melee"
local ChooseWeapon   = "Melee"
local Ms             = ""
local NameMon        = ""
local NameQuest      = ""
local QuestLv        = 1
local CFrameQ        = CFrame.new(0,0,0)
local CFrameMon      = CFrame.new(0,0,0)
local SelectMonster  = ""
local SelectArea     = ""
local posX, posY, posZ = 0, 2, -5

-- ==================== AntiBan ====================
local function AntiBan()
    pcall(function()
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("LocalScript") then
                local banned = {"General","Shiftlock","FallDamage","4444","CamBob","JumpCD","Looking","Run"}
                for _, name in ipairs(banned) do
                    if v.Name == name then v:Destroy() end
                end
            end
        end
        for _, v in ipairs(LocalPlayer.PlayerScripts:GetDescendants()) do
            if v:IsA("LocalScript") then
                local banned = {"RobloxMotor6DBugFix","Clans","Codes","CustomForceField","MenuBloodSp","PlayerList"}
                for _, name in ipairs(banned) do
                    if v.Name == name then v:Destroy() end
                end
            end
        end
    end)
end
AntiBan()

-- ==================== Anti AFK ====================
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- ==================== Remove Death Effects ====================
pcall(function()
    local container = ReplicatedStorage:FindFirstChild("Effect") and
                      ReplicatedStorage.Effect:FindFirstChild("Container")
    if container then
        if container:FindFirstChild("Death")   then container.Death:Destroy()   end
        if container:FindFirstChild("Respawn") then container.Respawn:Destroy() end
    end
end)

-- ==================== Auto Weapon Selector ====================
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if v.ToolTip == ChooseWeapon then
                    SelectWeapon = v.Name
                end
            end
        end)
    end
end)

-- ==================== CheckLevel (Auto Farm) ====================
local function CheckLevel()
    pcall(function()
        local Lv = LocalPlayer.Data.Level.Value

        if BF.First_Sea then
            if     Lv <= 9   then Ms="Bandit";            NameQuest="BanditQuest1";   QuestLv=1; NameMon="Bandit";            CFrameQ=CFrame.new(1060,16,1547);   CFrameMon=CFrame.new(1038,41,1576)
            elseif Lv <= 14  then Ms="Monkey";            NameQuest="JungleQuest";    QuestLv=1; NameMon="Monkey";            CFrameQ=CFrame.new(-1601,36,153);   CFrameMon=CFrame.new(-1448,50,63)
            elseif Lv <= 29  then Ms="Gorilla";           NameQuest="JungleQuest";    QuestLv=2; NameMon="Gorilla";           CFrameQ=CFrame.new(-1601,36,153);   CFrameMon=CFrame.new(-1142,40,-515)
            elseif Lv <= 39  then Ms="Pirate";            NameQuest="BuggyQuest1";    QuestLv=1; NameMon="Pirate";            CFrameQ=CFrame.new(-1140,4,3827);   CFrameMon=CFrame.new(-1201,40,3857)
            elseif Lv <= 59  then Ms="Brute";             NameQuest="BuggyQuest1";    QuestLv=2; NameMon="Brute";             CFrameQ=CFrame.new(-1140,4,3827);   CFrameMon=CFrame.new(-1387,24,4100)
            elseif Lv <= 74  then Ms="Desert Bandit";     NameQuest="DesertQuest";    QuestLv=1; NameMon="Desert Bandit";     CFrameQ=CFrame.new(896,6,4390);     CFrameMon=CFrame.new(984,16,4417)
            elseif Lv <= 89  then Ms="Desert Officer";    NameQuest="DesertQuest";    QuestLv=2; NameMon="Desert Officer";    CFrameQ=CFrame.new(896,6,4390);     CFrameMon=CFrame.new(1547,14,4381)
            elseif Lv <= 99  then Ms="Snow Bandit";       NameQuest="SnowQuest";      QuestLv=1; NameMon="Snow Bandit";       CFrameQ=CFrame.new(1386,87,-1298);  CFrameMon=CFrame.new(1356,105,-1328)
            elseif Lv <= 119 then Ms="Snowman";           NameQuest="SnowQuest";      QuestLv=2; NameMon="Snowman";           CFrameQ=CFrame.new(1386,87,-1298);  CFrameMon=CFrame.new(1218,138,-1488)
            elseif Lv <= 149 then Ms="Chief Petty Officer";NameQuest="MarineQuest2";  QuestLv=1; NameMon="Chief Petty Officer";CFrameQ=CFrame.new(-5035,28,4324); CFrameMon=CFrame.new(-4931,65,4121)
            elseif Lv <= 174 then Ms="Sky Bandit";        NameQuest="SkyQuest";       QuestLv=1; NameMon="Sky Bandit";        CFrameQ=CFrame.new(-4842,717,-2623);CFrameMon=CFrame.new(-4955,365,-2908)
            elseif Lv <= 189 then Ms="Dark Master";       NameQuest="SkyQuest";       QuestLv=2; NameMon="Dark Master";       CFrameQ=CFrame.new(-4842,717,-2623);CFrameMon=CFrame.new(-5148,439,-2332)
            elseif Lv <= 209 then Ms="Prisoner";          NameQuest="PrisonerQuest";  QuestLv=1; NameMon="Prisoner";          CFrameQ=CFrame.new(5310,0,474);     CFrameMon=CFrame.new(4937,0,649)
            elseif Lv <= 249 then Ms="Dangerous Prisoner";NameQuest="PrisonerQuest";  QuestLv=2; NameMon="Dangerous Prisoner";CFrameQ=CFrame.new(5310,0,474);     CFrameMon=CFrame.new(5099,0,1055)
            elseif Lv <= 274 then Ms="Toga Warrior";      NameQuest="ColosseumQuest"; QuestLv=1; NameMon="Toga Warrior";      CFrameQ=CFrame.new(-1577,7,-2984);  CFrameMon=CFrame.new(-1872,49,-2913)
            elseif Lv <= 299 then Ms="Gladiator";         NameQuest="ColosseumQuest"; QuestLv=2; NameMon="Gladiator";         CFrameQ=CFrame.new(-1577,7,-2984);  CFrameMon=CFrame.new(-1521,81,-3066)
            elseif Lv <= 324 then Ms="Military Soldier";  NameQuest="MagmaQuest";     QuestLv=1; NameMon="Military Soldier";  CFrameQ=CFrame.new(-5316,12,8517);  CFrameMon=CFrame.new(-5369,61,8556)
            elseif Lv <= 374 then Ms="Military Spy";      NameQuest="MagmaQuest";     QuestLv=2; NameMon="Military Spy";      CFrameQ=CFrame.new(-5316,12,8517);  CFrameMon=CFrame.new(-5787,75,8651)
            elseif Lv <= 399 then Ms="Fishman Warrior";   NameQuest="FishmanQuest";   QuestLv=1; NameMon="Fishman Warrior";   CFrameQ=CFrame.new(61122,18,1569);  CFrameMon=CFrame.new(60844,98,1298)
            elseif Lv <= 449 then Ms="Fishman Commando";  NameQuest="FishmanQuest";   QuestLv=2; NameMon="Fishman Commando";  CFrameQ=CFrame.new(61122,18,1569);  CFrameMon=CFrame.new(61738,64,1433)
            elseif Lv <= 524 then Ms="Shanda";            NameQuest="SkyExp1Quest";   QuestLv=2; NameMon="Shanda";            CFrameQ=CFrame.new(-7863,5545,-378);CFrameMon=CFrame.new(-7685,5601,-441)
            elseif Lv <= 624 then Ms="Royal Soldier";     NameQuest="SkyExp2Quest";   QuestLv=2; NameMon="Royal Soldier";     CFrameQ=CFrame.new(-7903,5635,-1410);CFrameMon=CFrame.new(-7760,5679,-1884)
            elseif Lv >= 625 then Ms="Galley Captain";    NameQuest="FountainQuest";  QuestLv=2; NameMon="Galley Captain";    CFrameQ=CFrame.new(5258,38,4050);   CFrameMon=CFrame.new(5677,92,4966)
            end

        elseif BF.Second_Sea then
            if     Lv <= 724 then Ms="Raider";         NameQuest="Area1Quest";     QuestLv=1; NameMon="Raider";         CFrameQ=CFrame.new(-4208,251,1006);  CFrameMon=CFrame.new(-4191,260,970)
            elseif Lv <= 774 then Ms="Mercenary";      NameQuest="Area1Quest";     QuestLv=2; NameMon="Mercenary";      CFrameQ=CFrame.new(-4208,251,1006);  CFrameMon=CFrame.new(-3855,252,818)
            elseif Lv <= 849 then Ms="Swan Pirate";    NameQuest="FountainCityQuest";QuestLv=1;NameMon="Swan Pirate";   CFrameQ=CFrame.new(1141,60,-3236);   CFrameMon=CFrame.new(1093,107,-3247)
            elseif Lv <= 924 then Ms="Zombie";         NameQuest="HalloweenQuest"; QuestLv=1; NameMon="Zombie";         CFrameQ=CFrame.new(-4608,27,4171);   CFrameMon=CFrame.new(-4584,58,4196)
            elseif Lv <= 999 then Ms="Snow Trooper";   NameQuest="SnowHQQuest";    QuestLv=1; NameMon="Snow Trooper";   CFrameQ=CFrame.new(-5216,400,1265);  CFrameMon=CFrame.new(-5179,413,1247)
            elseif Lv <= 1049 then Ms="Lab Subordinate";NameQuest="LabQuest";      QuestLv=1; NameMon="Lab Subordinate";CFrameQ=CFrame.new(3044,100,3107);   CFrameMon=CFrame.new(3036,117,3059)
            elseif Lv <= 1099 then Ms="Horned Warrior";NameQuest="ForgottenQuest"; QuestLv=1; NameMon="Horned Warrior"; CFrameQ=CFrame.new(-4875,389,-2099); CFrameMon=CFrame.new(-4782,411,-2014)
            elseif Lv <= 1174 then Ms="Lava Pirate";   NameQuest="LavaQuest";      QuestLv=1; NameMon="Lava Pirate";    CFrameQ=CFrame.new(4474,152,1843);   CFrameMon=CFrame.new(4404,167,1818)
            elseif Lv >= 1175 then Ms="Sea Soldier";   NameQuest="SeaQuest";       QuestLv=1; NameMon="Sea Soldier";    CFrameQ=CFrame.new(-265,12,-1548);   CFrameMon=CFrame.new(-267,18,-1601)
            end

        elseif BF.Third_Sea then
            if     Lv <= 1299 then Ms="Forest Pirate";  NameQuest="ForestQuest";   QuestLv=1; NameMon="Forest Pirate";  CFrameQ=CFrame.new(4818,6,1016);     CFrameMon=CFrame.new(4829,59,1085)
            elseif Lv <= 1374 then Ms="Marine Recruits";NameQuest="MarineQuest";   QuestLv=1; NameMon="Marine Recruits";CFrameQ=CFrame.new(-4628,5,3447);    CFrameMon=CFrame.new(-4645,63,3381)
            elseif Lv <= 1449 then Ms="Sea Soldier";    NameQuest="SeaQuest";      QuestLv=1; NameMon="Sea Soldier";    CFrameQ=CFrame.new(-265,12,-1548);   CFrameMon=CFrame.new(-267,18,-1601)
            elseif Lv <= 1524 then Ms="Guard";          NameQuest="GuardQuest";    QuestLv=1; NameMon="Guard";          CFrameQ=CFrame.new(3258,22,3090);    CFrameMon=CFrame.new(3284,75,3150)
            elseif Lv >= 1525 then Ms="Demonic Soul";   NameQuest="SoulQuest";     QuestLv=1; NameMon="Demonic Soul";   CFrameQ=CFrame.new(-2893,798,6283);  CFrameMon=CFrame.new(-2909,840,6210)
            end
        end
    end)
end

-- ==================== Attack Loop ====================
task.spawn(function()
    while task.wait(_G.Fast_Delay or 0.1) do
        if _G.AutoLevel or _G.AutoNear then
            pcall(function()
                local char = GetChar()
                if not char then return end
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local remote = tool:FindFirstChild("RemoteEvent")
                            or tool:FindFirstChild("RemoteFunction")
                        if remote then
                            pcall(function() remote:FireServer() end)
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== Auto Farm Loop ====================
task.spawn(function()
    while task.wait() do
        if not _G.AutoLevel then continue end
        pcall(function()
            CheckLevel()
            local questGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
            local questVisible = questGui and questGui:FindFirstChild("Quest") and questGui.Quest.Visible

            if not questVisible or not string.find(questGui.Quest.Container.QuestTitle.Title.Text, NameMon) then
                CommF_:InvokeServer("AbandonQuest")
                Tween(CFrameQ)
                if (CFrameQ.Position - RootPart.Position).Magnitude <= 5 then
                    CommF_:InvokeServer("StartQuest", NameQuest, QuestLv)
                end
            else
                for _, v in ipairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
                       and v.Humanoid.Health > 0 and v.Name == Ms then
                        repeat
                            task.wait(_G.Fast_Delay)
                            EquipTool(SelectWeapon)
                            Tween(v.HumanoidRootPart.CFrame * CFrame.new(posX, posY, posZ))
                            pcall(function()
                                v.HumanoidRootPart.Size = Vector3.new(60,60,60)
                                v.HumanoidRootPart.Transparency = 1
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.Humanoid.JumpPower = 0
                            end)
                        until not _G.AutoLevel
                            or not v.Parent
                            or v.Humanoid.Health <= 0
                        break
                    end
                end
            end
        end)
    end
end)

-- ==================== Kill Aura ====================
task.spawn(function()
    while task.wait(0.1) do
        if not _G.AutoNear then continue end
        pcall(function()
            for _, v in ipairs(workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0
                   and (RootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 30 then
                    EquipTool(SelectWeapon)
                    Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 2, -3))
                end
            end
        end)
    end
end)

-- ==================== ESP Functions ====================
local function MakeESP(adornee, text, color)
    if adornee:FindFirstChild("VNDXS_ESP"..Number) then
        adornee["VNDXS_ESP"..Number].TextLabel.Text = text
        return
    end
    local bill = Instance.new("BillboardGui", adornee)
    bill.Name = "VNDXS_ESP"..Number
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(1,200,1,30)
    bill.ExtentsOffset = Vector3.new(0,1,0)
    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextWrapped = true
    label.TextColor3 = color or Color3.new(1,1,1)
    label.Text = text
end

local function RemoveESP(adornee)
    local esp = adornee:FindFirstChild("VNDXS_ESP"..Number)
    if esp then esp:Destroy() end
end

-- ESP Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- Player ESP
        for _, v in ipairs(Players:GetChildren()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                local dist = round((RootPart.Position - head.Position).Magnitude / 3)
                local hp = round(v.Character.Humanoid.Health * 100 / v.Character.Humanoid.MaxHealth)
                local color = v.Team == LocalPlayer.Team
                    and HexToColor3("1E90FF") or HexToColor3("FF4444")
                if ESPPlayer then
                    MakeESP(head, v.Name.." | "..dist.." studs\nHP: "..hp.."%", color)
                else RemoveESP(head) end
            end
        end

        -- Devil Fruit ESP
        for _, v in ipairs(workspace:GetChildren()) do
            if string.find(v.Name, "Fruit") and v:FindFirstChild("Handle") then
                local dist = round((RootPart.Position - v.Handle.Position).Magnitude / 3)
                if DevilFruitESP then
                    MakeESP(v.Handle, v.Name.."\n"..dist.." studs", HexToColor3("FFD700"))
                else RemoveESP(v.Handle) end
            end
        end

        -- Chest ESP
        for _, v in ipairs(workspace:GetChildren()) do
            if string.find(v.Name, "Chest") or string.find(v.Name, "chest") then
                local pos = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if pos then
                    local dist = round((RootPart.Position - pos.Position).Magnitude / 3)
                    if ChestESP then
                        MakeESP(pos, "Chest\n"..dist.." studs", HexToColor3("FFD700"))
                    else RemoveESP(pos) end
                end
            end
        end

        -- Island ESP
        local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
        if worldOrigin and worldOrigin:FindFirstChild("Locations") then
            for _, v in ipairs(worldOrigin.Locations:GetChildren()) do
                if v.Name ~= "Sea" then
                    local dist = round((RootPart.Position - v.Position).Magnitude / 3)
                    if IslandESP then
                        MakeESP(v, v.Name.."\n"..dist.." studs", HexToColor3("00E5FF"))
                    else RemoveESP(v) end
                end
            end
        end
    end)
end)

-- ==================== Server Hop ====================
task.spawn(function()
    while task.wait(5) do
        if not _G.ServerHop then continue end
        pcall(function()
            local servers = {}
            local ok, result = pcall(function()
                return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
            end)
            if ok then
                local data = game:GetService("HttpService"):JSONDecode(result)
                for _, s in ipairs(data.data or {}) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(servers, s.id)
                    end
                end
                if #servers > 0 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)])
                end
            end
        end)
    end
end)

-- ==================== Window ====================
local Window = Library:CreateWindow({
    Title        = "VNDXS HUB  •  BLOX FRUITS",
    Footer       = "v"..VNDXS.Version.."  |  "..BF.CurrentSea.."  |  dsc.gg/vndxshub",
    NotifySide   = "Right",
    ShowCustomCursor = false,
    AutoShow     = true,
    Center       = true,
    TabPadding   = 3,
    MenuFadeTime = 0,
    CornerRadius = 2,
})

-- تطبيق الثيم
if Library.Scheme then
    Library.Scheme.FontColor       = HexToColor3(Theme.FontColor)
    Library.Scheme.Main            = HexToColor3(Theme.MainColor)
    Library.Scheme.Accent          = HexToColor3(Theme.AccentColor)
    Library.Scheme.Background      = HexToColor3(Theme.BackgroundColor)
    Library.Scheme.Outline         = HexToColor3(Theme.OutlineColor)
end
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
    Info     = Window:AddTab("Info",      "user"),
    Farm     = Window:AddTab("Auto Farm", "home"),
    ESP      = Window:AddTab("ESP",       "eye"),
    Teleport = Window:AddTab("Teleport",  "map-pin"),
    Player   = Window:AddTab("Player",    "zap"),
    Dungeon  = Window:AddTab("Dungeon",   "swords"),
    Misc     = Window:AddTab("Misc",      "list-plus"),
    Server   = Window:AddTab("Server",    "wifi"),
    Settings = Window:AddTab("Settings",  "settings"),
}

-- ==================== INFO TAB ====================
do
    local UserGroup = Tabs.Info:AddLeftGroupbox("Player Info")
    pcall(function()
        local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        UserGroup:AddImage("Avatar", { Image = thumb })
    end)
    UserGroup:AddLabel("Username: "   .. LocalPlayer.Name, true)
    UserGroup:AddLabel("User ID: "    .. tostring(LocalPlayer.UserId), true)
    UserGroup:AddLabel("Current Sea: ".. BF.CurrentSea, true)
    UserGroup:AddLabel("Hub: VNDXS HUB v"..VNDXS.Version, true)

    local ChangelogGroup = Tabs.Info:AddRightGroupbox("Changelog")
    local changelog = {
        "VNDXS HUB v1.0.0",
        "<font color='rgb(255,215,0)'>★ Blox Fruits Support Added</font>",
        "<font color='rgb(30,144,255)'>+ Auto Farm (3 Seas)</font>",
        "<font color='rgb(30,144,255)'>+ Kill Aura</font>",
        "<font color='rgb(30,144,255)'>+ Full ESP System</font>",
        "<font color='rgb(30,144,255)'>+ Teleport All Islands</font>",
        "<font color='rgb(30,144,255)'>+ Server Hop</font>",
        "<font color='rgb(30,144,255)'>+ Player Mods</font>",
    }
    for _, v in ipairs(changelog) do
        ChangelogGroup:AddLabel(v, true)
    end
end

-- ==================== AUTO FARM TAB ====================
do
    local FarmGroup = Tabs.Farm:AddLeftGroupbox("Farming")

    FarmGroup:AddDropdown("WeaponSelect", {
        Text   = "Weapon Type",
        Values = { "Melee", "Sword", "Blox Fruit" },
        Default = 1,
        Callback = function(v) ChooseWeapon = v end,
    })

    FarmGroup:AddDropdown("AttackSpeed", {
        Text   = "Attack Speed",
        Values = { "Normal", "Fast", "Super Fast" },
        Default = 2,
        Callback = function(v)
            if v == "Normal"     then _G.Fast_Delay = 0.5
            elseif v == "Fast"   then _G.Fast_Delay = 0.1
            else                      _G.Fast_Delay = 0
            end
        end,
    })

    FarmGroup:AddToggle("AutoFarm", {
        Text    = "Auto Farm Level",
        Default = false,
        Callback = function(v)
            _G.AutoLevel = v
            if not v then Tween(RootPart.CFrame) end
        end,
    })

    FarmGroup:AddToggle("KillAura", {
        Text    = "Kill Aura (Near Mobs)",
        Default = false,
        Callback = function(v) _G.AutoNear = v end,
    })

    FarmGroup:AddToggle("AutoChest", {
        Text    = "Auto Farm Chest",
        Default = false,
        Callback = function(v) _G.AutoChest = v end,
    })

    FarmGroup:AddToggle("AutoMastery", {
        Text    = "Auto Mastery",
        Default = false,
        Callback = function(v) _G.AutoMastery = v end,
    })

    -- اختيار المنطقة اليدوي
    local AreaGroup = Tabs.Farm:AddRightGroupbox("Manual Area")

    local firstSeaAreas  = {"Bandit","Monkey","Gorilla","Pirate","Brute","Desert Bandit","Desert Officer","Snow Bandit","Snowman","Chief Petty Officer","Sky Bandit","Dark Master","Prisoner","Dangerous Prisoner","Toga Warrior","Gladiator","Military Soldier","Military Spy","Fishman Warrior","Fishman Commando","Shanda","Royal Soldier","Galley Captain"}
    local secondSeaAreas = {"Raider","Mercenary","Swan Pirate","Zombie","Snow Trooper","Lab Subordinate","Horned Warrior","Lava Pirate","Sea Soldier"}
    local thirdSeaAreas  = {"Forest Pirate","Marine Recruits","Sea Soldier","Guard","Demonic Soul"}

    local currentAreas = BF.First_Sea and firstSeaAreas or BF.Second_Sea and secondSeaAreas or thirdSeaAreas

    AreaGroup:AddDropdown("AreaSelect", {
        Text   = "Select Monster",
        Values = currentAreas,
        Default = 1,
        Callback = function(v)
            SelectMonster = v
            CheckLevel()
        end,
    })
end

-- ==================== ESP TAB ====================
do
    local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP Settings")

    ESPGroup:AddToggle("ESPPlayerToggle", {
        Text    = "Player ESP",
        Default = false,
        Callback = function(v) ESPPlayer = v end,
    })

    ESPGroup:AddToggle("FruitESPToggle", {
        Text    = "Devil Fruit ESP",
        Default = false,
        Callback = function(v) DevilFruitESP = v end,
    })

    ESPGroup:AddToggle("ChestESPToggle", {
        Text    = "Chest ESP",
        Default = false,
        Callback = function(v) ChestESP = v end,
    })

    ESPGroup:AddToggle("IslandESPToggle", {
        Text    = "Island ESP",
        Default = false,
        Callback = function(v) IslandESP = v end,
    })

    ESPGroup:AddToggle("FlowerESPToggle", {
        Text    = "Flower ESP",
        Default = false,
        Callback = function(v) FlowerESP = v end,
    })
end

-- ==================== TELEPORT TAB ====================
do
    local TpGroup = Tabs.Teleport:AddLeftGroupbox(BF.CurrentSea .. " Islands")

    local teleports = {}

    if BF.First_Sea then
        teleports = {
            { "Starter Island",    CFrame.new(1038, 41, 1576)   },
            { "Jungle",            CFrame.new(-1448, 50, 63)    },
            { "Pirate Village",    CFrame.new(-1201, 40, 3857)  },
            { "Desert",            CFrame.new(984, 16, 4417)    },
            { "Snow Island",       CFrame.new(1356, 105, -1328) },
            { "Marine Fortress",   CFrame.new(-4931, 65, 4121)  },
            { "Sky Island",        CFrame.new(-4955, 365, -2908)},
            { "Prison",            CFrame.new(4937, 0, 649)     },
            { "Colosseum",         CFrame.new(-1872, 49, -2913) },
            { "Magma Village",     CFrame.new(-5369, 61, 8556)  },
            { "Fishman Island",    CFrame.new(60844, 98, 1298)  },
            { "Skypiea",           CFrame.new(-7685, 5601, -441)},
            { "Fountain City",     CFrame.new(5677, 92, 4966)   },
        }
    elseif BF.Second_Sea then
        teleports = {
            { "Kingdom of Rose",   CFrame.new(-4191, 260, 970)  },
            { "Fountain City",     CFrame.new(1093, 107, -3247) },
            { "Graveyard",         CFrame.new(-4584, 58, 4196)  },
            { "Snow Mountain",     CFrame.new(-5179, 413, 1247) },
            { "Hot & Cold",        CFrame.new(3036, 117, 3059)  },
            { "Forgotten Island",  CFrame.new(-4782, 411, -2014)},
            { "Lava Island",       CFrame.new(4404, 167, 1818)  },
            { "Underwater City",   CFrame.new(-267, 18, -1601)  },
        }
    elseif BF.Third_Sea then
        teleports = {
            { "Ushanka Bear",      CFrame.new(4829, 59, 1085)   },
            { "Port Town",         CFrame.new(-4645, 63, 3381)  },
            { "Floating Turtle",   CFrame.new(-267, 18, -1601)  },
            { "Haunted Castle",    CFrame.new(3284, 75, 3150)   },
            { "Sea of Treats",     CFrame.new(-2909, 840, 6210) },
        }
    end

    for _, tp in ipairs(teleports) do
        TpGroup:AddButton(tp[1], function()
            pcall(function()
                RootPart.CFrame = tp[2]
            end)
            Library:Notify("Teleported to " .. tp[1])
        end)
    end
end

-- ==================== PLAYER TAB ====================
do
    local PlayerGroup = Tabs.Player:AddLeftGroupbox("Movement")

    PlayerGroup:AddSlider("WalkSpeedSlider", {
        Text    = "Walk Speed",
        Default = 16,
        Min     = 16,
        Max     = 100,
        Rounding = 0,
        Callback = function(v)
            pcall(function()
                GetHuman().WalkSpeed = v
            end)
        end,
    })

    PlayerGroup:AddSlider("JumpPowerSlider", {
        Text    = "Jump Power",
        Default = 50,
        Min     = 50,
        Max     = 300,
        Rounding = 0,
        Callback = function(v)
            pcall(function()
                GetHuman().JumpPower = v
            end)
        end,
    })

    PlayerGroup:AddToggle("InfiniteJump", {
        Text    = "Infinite Jump",
        Default = false,
        Callback = function(v)
            _G.InfiniteJump = v
        end,
    })

    -- Infinite Jump handler
    UserInputService_InfiniteJump = game:GetService("UserInputService")
    task.spawn(function()
        UserInputService_InfiniteJump.JumpRequest:Connect(function()
            if _G.InfiniteJump then
                pcall(function() GetHuman():ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end)
    end)

    local ProtectGroup = Tabs.Player:AddRightGroupbox("Protection")

    ProtectGroup:AddToggle("AntiBanToggle", {
        Text    = "Anti Ban",
        Default = true,
        Callback = function(v)
            if v then AntiBan() end
        end,
    })

    ProtectGroup:AddToggle("AntiAFKToggle", {
        Text    = "Anti AFK",
        Default = true,
    })
end

-- ==================== DUNGEON TAB ====================
do
    local DungeonGroup = Tabs.Dungeon:AddLeftGroupbox("Raid")

    DungeonGroup:AddToggle("AutoRaid", {
        Text    = "Auto Raid",
        Default = false,
        Callback = function(v)
            _G.AutoRaid = v
            if v then
                task.spawn(function()
                    while _G.AutoRaid do
                        pcall(function()
                            CommF_:InvokeServer("AutoRaid")
                        end)
                        task.wait(1)
                    end
                end)
            end
        end,
    })

    DungeonGroup:AddButton("Start Raid", function()
        pcall(function()
            CommF_:InvokeServer("StartRaid", "Pirates Millitary")
        end)
        Library:Notify("Raid started!")
    end)
end

-- ==================== MISC TAB ====================
do
    local MiscGroup = Tabs.Misc:AddLeftGroupbox("Miscellaneous")

    MiscGroup:AddToggle("FPSBoost", {
        Text    = "FPS Boost",
        Default = false,
        Callback = function(v)
            settings().Rendering.QualityLevel = v and 1 or 10
        end,
    })

    MiscGroup:AddButton("Redeem All Codes", function()
        local codes = {
            "STAFFEL","Sub2UncleKizaru","Enyu_is_Pro","Magicbus",
            "JCWK","Starcodeheo","Sub2Daigrock","Bluxxy",
            "Sub2OfficialNoobie","Fudd10","BIGNEWS","Sub2Fer999",
        }
        task.spawn(function()
            for _, code in ipairs(codes) do
                pcall(function()
                    CommF_:InvokeServer("Redeem", code)
                end)
                task.wait(0.5)
            end
            Library:Notify("All codes redeemed!")
        end)
    end)

    MiscGroup:AddToggle("AutoMasteryToggle", {
        Text    = "Auto Mastery Farm",
        Default = false,
        Callback = function(v) _G.AutoMastery = v end,
    })

    local MiscRight = Tabs.Misc:AddRightGroupbox("Stats Boost")

    MiscRight:AddButton("Max Stats", function()
        pcall(function()
            CommF_:InvokeServer("AddStat", "Defense",  LocalPlayer.Data.StatPoints.Value)
            CommF_:InvokeServer("AddStat", "Melee",    LocalPlayer.Data.StatPoints.Value)
            CommF_:InvokeServer("AddStat", "Sword",    LocalPlayer.Data.StatPoints.Value)
            CommF_:InvokeServer("AddStat", "Gun",      LocalPlayer.Data.StatPoints.Value)
            CommF_:InvokeServer("AddStat", "BloxFruit",LocalPlayer.Data.StatPoints.Value)
        end)
        Library:Notify("Stats maxed!")
    end)
end

-- ==================== SERVER TAB ====================
do
    local ServerGroup = Tabs.Server:AddLeftGroupbox("Server Hop")

    ServerGroup:AddToggle("ServerHopToggle", {
        Text    = "Auto Server Hop",
        Default = false,
        Callback = function(v) _G.ServerHop = v end,
    })

    ServerGroup:AddButton("Hop Now", function()
        pcall(function()
            local result = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
            local data   = game:GetService("HttpService"):JSONDecode(result)
            local servers = {}
            for _, s in ipairs(data.data or {}) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(servers, s.id)
                end
            end
            if #servers > 0 then
                Library:Notify("Hopping to new server...")
                task.wait(1)
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)])
            else
                Library:Notify("No servers found.")
            end
        end)
    end)

    local StatsGroup = Tabs.Server:AddRightGroupbox("Server Info")
    pcall(function()
        StatsGroup:AddLabel("Place ID: "..tostring(game.PlaceId), true)
        StatsGroup:AddLabel("Job ID: "..tostring(game.JobId):sub(1,12).."...", true)
        StatsGroup:AddLabel("Players: "..tostring(#Players:GetChildren()), true)
    end)
end

-- ==================== SETTINGS TAB ====================
VNDXS.Interface.ApplySettingsTab(Window)

-- Credits Tab
local ok, applyCredits = pcall(function()
    return loadstring(game:HttpGet(VNDXS.BaseUrl .. "Components/CreditsTab.luau"))()
end)
if ok and type(applyCredits) == "function" then
    applyCredits(Window)
end

Library:Notify("VNDXS HUB loaded!  |  "..BF.CurrentSea, 5)
