--[[
    VNDXS HUB - Blade Ball Loader
]]

VNDXS.SavePath = "BladeBall"

local ok, err = pcall(function()
    loadstring(game:HttpGet(VNDXS.BaseUrl .. "Games/BladeBall/BladeBall_Main.luau"))()
end)

if not ok then
    warn("[VNDXS/BladeBall] Failed to load: " .. tostring(err))
end
