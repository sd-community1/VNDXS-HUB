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
           
