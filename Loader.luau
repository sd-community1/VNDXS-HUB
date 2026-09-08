--[[
    VNDXS HUB - Loader
    Version: 1.0.0
    Theme: Blue & Yellow
]]

if getgenv().VNDXS then
    warn("[VNDXS] Already loaded, skipping.")
    return
end

-- ==================== Config ====================
local VERSION = "1.0.0"
local HUB_NAME = "VNDXS HUB"
local BaseUrl = "https://raw.githubusercontent.com/sd-community1/VNDXS-HUB/refs/heads/main/"

-- قائمة الألعاب المدعومة
local GameList = {
    [2440500124] = "Doors"
}

-- ==================== SafeLoad ====================
local function SafeLoad(url, label)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("[VNDXS] Failed to load " .. (label or url) .. ": " .. tostring(result))
        return nil
    end
    return result
end

-- ==================== تهيئة الـ Global ====================
getgenv().VNDXS = {
    Name        = HUB_NAME,
    Version     = VERSION,
    BaseUrl     = BaseUrl,
    Legit       = true,

    -- ألوان VNDXS الثابتة (أزرق وأصفر)
    Theme = {
        FontColor       = "FFD700",   -- ذهبي/أصفر للنصوص
        MainColor       = "0A0F2E",   -- أزرق غامق جداً للخلفية الرئيسية
        AccentColor     = "1E90FF",   -- أزرق ساطع للـ accent
        BackgroundColor = "050A1A",   -- أزرق شبه أسود للخلفية الداخلية
        OutlineColor    = "1E3A8A",   -- أزرق متوسط للحدود
    }
}

-- ==================== تحميل البيئة ====================
VNDXS.Environment = SafeLoad(BaseUrl .. "Components/Environment.luau", "Environment")
VNDXS.ESPLibrary  = SafeLoad(BaseUrl .. "Components/ESP.luau",         "ESPLibrary")

if not VNDXS.Environment then
    error("[VNDXS] Critical: Environment failed to load.")
    return
end

-- ==================== CloneRef + Services ====================
local function CloneRef(obj)
    if VNDXS.Environment.cloneref then
        return VNDXS.Environment.cloneref(obj)
    end
    return obj
end

local Services = setmetatable({}, {
    __index = function(_, name)
        return CloneRef(game:GetService(name))
    end
})

-- ==================== UserData ====================
local DEFAULT_USER_DATA = {
    TotalExecutions = 0,
    UILibrary       = "Obsidian",
    AnalyticsOptIn  = nil,
}

local function LoadUserData()
    local env = VNDXS.Environment
    if not (env.writefile and env.readfile and env.isfile) then
        return DEFAULT_USER_DATA
    end
    if env.makefolder and not env.isfolder("VNDXS") then
        env.makefolder("VNDXS")
    end
    local path = "VNDXS/UserData.json"
    if not env.isfile(path) then
        env.writefile(path, Services.HttpService:JSONEncode(DEFAULT_USER_DATA))
        return DEFAULT_USER_DATA
    end
    local ok, decoded = pcall(function()
        return Services.HttpService:JSONDecode(env.readfile(path))
    end)
    if not ok or type(decoded) ~= "table" then
        warn("[VNDXS] Corrupt UserData, resetting.")
        env.writefile(path, Services.HttpService:JSONEncode(DEFAULT_USER_DATA))
        return DEFAULT_USER_DATA
    end
    for key, default in pairs(DEFAULT_USER_DATA) do
        if decoded[key] == nil then decoded[key] = default end
    end
    return decoded
end

local function SaveUserData(data)
    local env = VNDXS.Environment
    if not env.writefile then return end
    pcall(function()
        env.writefile("VNDXS/UserData.json", Services.HttpService:JSONEncode(data))
    end)
end

local userData = LoadUserData()
userData.TotalExecutions = (userData.TotalExecutions or 0) + 1
SaveUserData(userData)

VNDXS.TotalExecutions = userData.TotalExecutions
VNDXS.UILibrary       = userData.UILibrary
VNDXS.UserData        = userData
VNDXS.SaveUserData    = SaveUserData

-- ==================== تحميل الواجهة ====================
VNDXS.Interface = SafeLoad(BaseUrl .. "Components/Interface.luau", "Interface")
VNDXS.Analytics = SafeLoad(BaseUrl .. "Components/Analytics.luau", "Analytics")

-- ==================== تشغيل اللعبة المناسبة ====================
local currentGame = GameList[game.GameId]
if currentGame then
    SafeLoad(BaseUrl .. "Games/" .. currentGame .. "/Loader.luau", currentGame .. " Loader")
else
    SafeLoad(BaseUrl .. "Games/Universal/Loader.luau", "Universal Loader")
end
