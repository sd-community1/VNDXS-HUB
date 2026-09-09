--[[
    VNDXS HUB - Blox Fruits Loader
    يكتشف البحر تلقائياً ويحمل الواجهة المناسبة
]]

local placeId = game.PlaceId

-- كشف البحر
VNDXS.BloxFruits = {
    First_Sea  = (placeId == 2753915549),
    Second_Sea = (placeId == 4442272183),
    Third_Sea  = (placeId == 7449423635),
}

local sea = "Unknown"
if VNDXS.BloxFruits.First_Sea  then sea = "First Sea"  end
if VNDXS.BloxFruits.Second_Sea then sea = "Second Sea" end
if VNDXS.BloxFruits.Third_Sea  then sea = "Third Sea"  end

VNDXS.BloxFruits.CurrentSea = sea
VNDXS.SavePath = "BloxFruits"

-- تحميل الـ Main
local ok, err = pcall(function()
    loadstring(game:HttpGet(VNDXS.BaseUrl .. "Games/BloxFruits/Main.luau"))()
end)

if not ok then
    warn("[VNDXS/BloxFruits] Failed to load Main: " .. tostring(err))
end
