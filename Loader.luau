--[[
    VNDXS HUB - Loader
    Version: 1.0.0
]]

if getgenv().VNDXS then
    warn("[VNDXS] Already loaded.")
    return
end

local VERSION = "1.0.0"
local BaseUrl = "https://raw.githubusercontent.com/sd-community1/VNDXS-HUB/refs/heads/main/"

local GameList = {
    -- DOORS
    [2440500124] = "Doors",
    -- BLOX FRUITS (3 بحار)
    [2753915549] = "BloxFruits",  -- First Sea
    [4442272183] = "BloxFruits",  -- Second Sea
    [7449423635] = "BloxFruits",  -- Third Sea
}

-- SafeLoad
local function SafeLoad(url, label)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("[VNDXS] Failed: " .. (label or url) .. " >> " .. tostring(result))
        return nil
    end
    return result
end

-- تهيئة الـ global
getgenv().VNDXS = {
    Name    = "VNDXS HUB",
    Version = VERSION,
    BaseUrl = BaseUrl,
    Theme = {
        FontColor       = "FFD700",
        MainColor       = "0A0F2E",
        AccentColor     = "1E90FF",
        BackgroundColor = "050A1A",
        OutlineColor    = "1E3A8A",
    }
}

-- تحميل Environment
VNDXS.Environment = SafeLoad(BaseUrl .. "Components/Environment.luau", "Environment")
VNDXS.ESPLibrary  = SafeLoad(BaseUrl .. "Components/ESP.luau",         "ESPLibrary")

if not VNDXS.Environment then
    error("[VNDXS] Environment failed to load. Aborting.")
    return
end

-- ==================== UserData (بسيط وآمن) ====================
local DEFAULT_USER_DATA = {
    TotalExecutions = 0,
    UILibrary       = "Obsidian",
    AnalyticsOptIn  = false,
}

local userData = {}
for k, v in pairs(DEFAULT_USER_DATA) do
    userData[k] = v
end

-- محاولة القراءة من الملف بشكل آمن تماماً
pcall(function()
    local env = VNDXS.Environment
    if not (env and env.isfile and env.readfile and env.writefile) then return end

    if env.makefolder and not env.isfolder("VNDXS") then
        pcall(env.makefolder, "VNDXS")
    end

    local path = "VNDXS/UserData.json"
    local hs = game:GetService("HttpService")

    if env.isfile(path) then
        local ok, decoded = pcall(function()
            return hs:JSONDecode(env.readfile(path))
        end)
        if ok and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                userData[k] = v
            end
        end
    end

    userData.TotalExecutions = (tonumber(userData.TotalExecutions) or 0) + 1

    pcall(function()
        env.writefile(path, hs:JSONEncode(userData))
    end)
end)

-- لو فشل كل شيء، نزيد العداد يدوياً فقط
userData.TotalExecutions = (tonumber(userData.TotalExecutions) or 0)

VNDXS.TotalExecutions = userData.TotalExecutions
VNDXS.UILibrary       = userData.UILibrary or "Obsidian"
VNDXS.UserData        = userData
VNDXS.SaveUserData    = function(data)
    pcall(function()
        local env = VNDXS.Environment
        if not (env and env.writefile) then return end
        local hs = game:GetService("HttpService")
        env.writefile("VNDXS/UserData.json", hs:JSONEncode(data))
    end)
end

-- ==================== تحميل الواجهة ====================
VNDXS.Interface = SafeLoad(BaseUrl .. "Components/Interface.luau", "Interface")
VNDXS.Analytics = SafeLoad(BaseUrl .. "Components/Analytics.luau", "Analytics")

-- ==================== تشغيل اللعبة ====================
local currentGame = GameList[game.GameId]
if currentGame then
    SafeLoad(BaseUrl .. "Games/" .. currentGame .. "/Loader.luau", currentGame)
else
    SafeLoad(BaseUrl .. "Games/Universal/Loader.luau", "Universal")
end
