--[[
    VNDXS HUB - One Shot Loader
]]

VNDXS.SavePath = "OneShot"

local ok, err = pcall(function()
    loadstring(game:HttpGet(VNDXS.BaseUrl .. "Games/OneShot/Main.luau"))()
end)

if not ok then
    warn("[VNDXS/OneShot] Failed to load Main: " .. tostring(err))
end
