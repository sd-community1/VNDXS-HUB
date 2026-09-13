--[[
    VNDXS HUB - Murder Mystery 2 Loader
]]

VNDXS.SavePath = "MM2"

local ok, err = pcall(function()
    loadstring(game:HttpGet(VNDXS.BaseUrl .. "Games/MM2/Main.luau"))()
end)

if not ok then
    warn("[VNDXS/MM2] Failed to load: " .. tostring(err))
end
