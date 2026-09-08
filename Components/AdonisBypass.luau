--[[
    VNDXS HUB - Adonis Bypass
]]

return function()
    if not (getgc and hookfunction and debug and debug.info) then
        warn("[VNDXS/AdonisBypass] Required functions not available.")
        return "Unsupported"
    end

    local AdonisFunctions = {}
    local Found = false

    local ok, err = pcall(function()
        for _, data in pairs(getgc(true)) do
            if typeof(data) == "table" then
                if rawget(data, "Detected") or rawget(data, "RLocked") then
                    for _, fn in pairs(data) do
                        if typeof(fn) == "function" then
                            table.insert(AdonisFunctions, fn)
                            Found = true
                            hookfunction(fn, function()
                                return task.wait(9e9)
                            end)
                        end
                    end
                end
            end
        end
    end)

    if not ok then
        warn("[VNDXS/AdonisBypass] GC scan failed: " .. tostring(err))
        return "Error"
    end

    local OldDebugInfo
    OldDebugInfo = hookfunction(debug.info, function(...)
        local args = { ... }
        if typeof(args[1]) == "function" and table.find(AdonisFunctions, args[1]) then
            return task.wait(9e9)
        end
        return OldDebugInfo(...)
    end)

    return Found and "Success" or "Not found"
end
