--[[
    VNDXS HUB - Analytics (opt-in only)
    ما يُرسَل: اسم الحساب، الـ executor، اسم اللعبة، PlaceId، عدد التشغيلات.
    لا يُرسَل: IP، HWID، أي بيانات شخصية.
]]

local function CloneRef(obj)
    if VNDXS.Environment.cloneref then return VNDXS.Environment.cloneref(obj) end
    return obj
end

local Services = setmetatable({}, {
    __index = function(_, name) return CloneRef(game:GetService(name)) end
})

if VNDXS.UserData.AnalyticsOptIn ~= true then return end
if not (VNDXS.Environment.identifyexecutor and VNDXS.Environment.request) then return end

local Player = Services.Players.LocalPlayer
local ok, gameName = pcall(function()
    return Services.MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local payload = {
    Hub        = VNDXS.Name,
    Version    = VNDXS.Version,
    Account    = Player.Name,
    Executor   = VNDXS.Environment.identifyexecutor(),
    Executions = tonumber(VNDXS.TotalExecutions) or 0,
    GameName   = ok and gameName or "Unknown",
    PlaceId    = tostring(game.PlaceId),
}

task.spawn(function()
    pcall(function()
        VNDXS.Environment.request({
            Url    = "https://abysall.wispbyte.org/api/send",  -- غيّر للـ endpoint الخاص بك
            Method = "POST",
            Headers = { ["content-type"] = "application/json" },
            Body   = Services.HttpService:JSONEncode(payload),
        })
    end)
end)
