--[[
    VNDXS HUB - Interface
    يُطبّق ثيم الأزرق والأصفر بشكل إجباري على كل عناصر الـ UI.
]]

local BaseUrl    = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local VNDXSUrl   = VNDXS.BaseUrl
local Theme      = VNDXS.Theme

local function SafeLoad(url, label)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("[VNDXS/Interface] Failed to load " .. (label or url))
        return nil
    end
    return result
end

-- ==================== تحميل المكونات ====================
local Interface = {
    Library      = SafeLoad(BaseUrl .. "Library.lua",             "UI Library"),
    SaveManager  = SafeLoad(BaseUrl .. "addons/SaveManager.lua",  "SaveManager"),
    ThemeManager = SafeLoad(BaseUrl .. "addons/ThemeManager.lua", "ThemeManager"),

    ApplyInfoTab     = SafeLoad(VNDXSUrl .. "Components/InfoTab.luau",     "InfoTab"),
    ApplySettingsTab = SafeLoad(VNDXSUrl .. "Components/SettingsTab.luau", "SettingsTab"),
}

if not Interface.Library then
    warn("[VNDXS] Obsidian failed, trying fallback...")
    task.wait(1)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
    end)
    if ok then
        Interface.Library = result
    else
        error("[VNDXS] UI Library failed completely. Check your internet connection.")
        return
    end
end

-- ==================== ثيم VNDXS الإجباري ====================
-- ثيم واحد فقط هو VNDXS — لا يمكن تغييره
if Interface.ThemeManager then
    Interface.ThemeManager.BuiltInThemes = {
        ["VNDXS"] = {
            1,
            {
                FontColor       = Theme.FontColor,
                MainColor       = Theme.MainColor,
                AccentColor     = Theme.AccentColor,
                BackgroundColor = Theme.BackgroundColor,
                OutlineColor    = Theme.OutlineColor,
            }
        },
    }
end

-- ==================== تطبيق الثيم فوراً على المكتبة ====================
-- نستخدم SetColors مباشرة لضمان تطبيق الألوان حتى قبل أي window
task.spawn(function()
    task.wait()  -- ننتظر لحظة حتى تتهيأ المكتبة
    local lib = Interface.Library
    if not lib then return end

    -- تطبيق الألوان مباشرة على المكتبة
    local function HexToColor3(hex)
        hex = hex:gsub("#", "")
        local r = tonumber(hex:sub(1,2), 16) / 255
        local g = tonumber(hex:sub(3,4), 16) / 255
        local b = tonumber(hex:sub(5,6), 16) / 255
        return Color3.new(r, g, b)
    end

    if lib.SetColors then
        lib:SetColors({
            Font            = HexToColor3(Theme.FontColor),
            Main            = HexToColor3(Theme.MainColor),
            Accent          = HexToColor3(Theme.AccentColor),
            Background      = HexToColor3(Theme.BackgroundColor),
            Outline         = HexToColor3(Theme.OutlineColor),
        })
    end
end)

return Interface
