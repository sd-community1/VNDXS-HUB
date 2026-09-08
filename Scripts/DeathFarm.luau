--[[
    VNDXS Hub - Death Farm (DOORS)
    يُزرع الموت تلقائياً للحصول على الـ XP/Knobs بسرعة.
    
    الخطوات:
    1. يتحقق من الـ PlaceId الصحيح
    2. ينتقل إلى الـ Hotel lobby إن لم يكن فيه
    3. يبدأ run جديد، يحصل على المفتاح، يفتح الباب، يموت
    4. يُعيد تشغيل نفسه تلقائياً
]]

while not game:IsLoaded() do
    task.wait(1)
end

-- ==================== Constants ====================
local SCRIPT_URL    = "https://raw.githubusercontent.com/YOUR_USERNAME/VNDXS-HUB/refs/heads/main/Scripts/DeathFarm.luau"
local HOTEL_PLACE   = 6516141723   -- Lobby
local MAIN_PLACE    = 6839171747   -- Hotel Floor 1

-- ==================== Services ====================
local Services = setmetatable({}, {
    __index = function(_, key)
        return game:GetService(key)
    end
})

-- ==================== Helpers ====================
local QueueTeleport = queue_on_teleport or queueonteleport

if not QueueTeleport then
    warn("[DeathFarm] queue_on_teleport not available. Farm requires this function.")
    return
end

local function QueueSelf()
    QueueTeleport(([[loadstring(game:HttpGet(%q))()]]):format(SCRIPT_URL))
end

local function SendCaption(text)
    local remotes = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
    if not remotes then return end
    pcall(function()
        if firesignal then
            firesignal(remotes.Caption.OnClientEvent, "[VNDXS] " .. text)
        else
            remotes.CaptionClient:Fire("[VNDXS] " .. text)
        end
    end)
end

local function CreateNewRun(remotes)
    remotes.CreateElevator:FireServer({
        Mods        = {},
        Settings    = {},
        Destination = "Hotel",
        FriendsOnly = false,
        MaxPlayers  = "1",
    })
end

local function WalkTo(targetPos)
    local char      = Services.Players.LocalPlayer.Character
    local rootPart  = char and char:WaitForChild("HumanoidRootPart", 10)
    local humanoid  = char and char:WaitForChild("Humanoid", 10)
    if not (rootPart and humanoid) then return false end

    local done = false
    local conn = Services.RunService.RenderStepped:Connect(function()
        humanoid:MoveTo(targetPos)
        if (rootPart.Position - targetPos).Magnitude < 6 then
            done = true
        end
    end)

    local timeout = 30
    while not done and timeout > 0 do
        task.wait(0.1)
        timeout = timeout - 0.1
    end
    conn:Disconnect()
    return done
end

-- ==================== Main Logic ====================
local CurrentPlace = game.PlaceId
local LocalPlayer  = Services.Players.LocalPlayer
local RemotesFolder, CurrentRooms, GameData

-- محاولة الوصول للـ remotes بشكل آمن
pcall(function()
    RemotesFolder = Services.ReplicatedStorage:WaitForChild("RemotesFolder", 10)
    CurrentRooms  = Services.Workspace:FindFirstChild("CurrentRooms")
    GameData      = Services.ReplicatedStorage:FindFirstChild("GameData")
end)

-- ========== الحالة 1: في الـ Lobby ===========
if CurrentPlace == HOTEL_PLACE then
    if not RemotesFolder then
        warn("[DeathFarm] RemotesFolder not found in Lobby.")
        return
    end
    SendCaption("Joining a run...")
    QueueSelf()
    CreateNewRun(RemotesFolder)
    return
end

-- ========== الحالة 2: في Floor غير Hotel ===========
if GameData and GameData.Floor and GameData.Floor.Value ~= "Hotel" then
    QueueSelf()
    SendCaption("Returning to Hotel floor...")
    pcall(function() RemotesFolder.Lobby:FireServer() end)
    return
end

-- ========== الحالة 3: في PlaceId خاطئ ===========
if CurrentPlace ~= MAIN_PLACE then
    QueueSelf()
    SendCaption("Teleporting to Hotel...")
    Services.TeleportService:Teleport(HOTEL_PLACE)
    return
end

-- ========== الحالة 4: الـ run بدأ بالفعل ===========
if not CurrentRooms then
    warn("[DeathFarm] CurrentRooms not found.")
    return
end

if #CurrentRooms:GetChildren() > 1 or LocalPlayer.Character then
    SendCaption("Run started, restarting for clean state...")
    QueueSelf()
    pcall(function() RemotesFolder.PlayAgain:FireServer() end)
    return
end

-- ========== انتظار بداية الـ run ===========
local waitTime = 0
while (#CurrentRooms:GetChildren() < 1 or not LocalPlayer.Character) and waitTime < 60 do
    task.wait(1)
    waitTime = waitTime + 1
end

if waitTime >= 60 then
    warn("[DeathFarm] Timed out waiting for run to start.")
    return
end

-- ========== تخطي الـ shop ===========
local mainUI = LocalPlayer.PlayerGui:WaitForChild("MainUI", 15)
if mainUI then
    local itemShop = mainUI:FindFirstChild("ItemShop")
    if itemShop then
        itemShop.Visible = false
        pcall(function() RemotesFolder.PreRunShop:FireServer({}, true) end)
    end
end

task.wait(1)

-- ========== تخطي الـ prompts الأولية ===========
pcall(function()
    local skipPrompt = Services.Workspace:FindFirstChild("SkipPrompt", true)
    if skipPrompt then fireproximityprompt(skipPrompt) end
end)

pcall(function()
    local cart = Services.Workspace:FindFirstChild("Luggage_Cart_Crouch", true)
    if cart then cart:Destroy() end
end)

-- ========== الحصول على المفتاح وفتح الباب ===========
local room0 = CurrentRooms:FindFirstChild("0")
if not room0 then
    warn("[DeathFarm] Room 0 not found.")
    return
end

-- إزالة collision من النباتات
for _, obj in ipairs(room0.Assets:GetChildren()) do
    if obj.Name == "Potted_Plant" then
        pcall(function() obj.Collision.CanCollide = false end)
    end
end

local door = room0:FindFirstChild("Door")
if door and door:FindFirstChild("Lock") then
    door.Lock.CanCollide = false
    WalkTo(door.Lock.Position)
end

local keyObtain = room0:FindFirstChild("KeyObtain", true)
if keyObtain and keyObtain:FindFirstChild("Hitbox") then
    SendCaption("Getting the key...")
    WalkTo(keyObtain.Hitbox.Position)
    pcall(function()
        fireproximityprompt(keyObtain:FindFirstChild("ModulePrompt", true))
    end)
end

-- فتح الباب
if door and door:FindFirstChild("Lock") then
    SendCaption("Opening the door...")
    door.Lock.CanCollide = false
    WalkTo(door.Lock.Position)
    pcall(function()
        fireproximityprompt(door:FindFirstChild("UnlockPrompt", true))
    end)
end

-- انتظار Room 2
local roomWait = 0
while not CurrentRooms:FindFirstChild("2") and roomWait < 30 do
    task.wait(0.5)
    roomWait = roomWait + 0.5
end

-- ========== الموت ===========
QueueSelf()

if replicatesignal then
    replicatesignal(LocalPlayer.Kill)
else
    SendCaption("Drowning... (~20 seconds)")
    pcall(function() RemotesFolder.Underwater:FireServer(true) end)
end

-- انتظار الموت
LocalPlayer:GetAttributeChangedSignal("Alive"):Wait()
SendCaption("Died! Starting new run...")
pcall(function() RemotesFolder.PlayAgain:FireServer() end)
