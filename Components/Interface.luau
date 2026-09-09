--[[
    VNDXS HUB - Interface
    يحمّل مكتبة الـ UI ويطبق ثيم VNDXS الإجباري
]]

local ObsidianUrl = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local VNDXSUrl    = VNDXS.BaseUrl
local Theme       = VNDXS.Theme

-- ==================== SafeLoad ====================
local function SafeLoad(url, label)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("[VNDXS/Interface] Failed: " .. (label or url))
        return nil
    end
    return result
end

-- ==================== تحميل المكتبة مع إعادة المحاولة ====================
local function LoadLibrary()
    local lib = SafeLoad(ObsidianUrl .. "Library.lua", "UI Library")
    if lib then return lib end
    warn("[VNDXS] Retrying library load in 2s...")
    task.wait(2)
    return SafeLoad(ObsidianUrl .. "Library.lua", "UI Library Retry")
end

local Library = LoadLibrary()

if not Library then
    warn("[VNDXS] UI Library completely failed. Script cannot continue.")
    return nil
end

-- ==================== تحميل باقي المكونات ====================
local Interface = {
    Library      = Library,
    SaveManager  = SafeLoad(ObsidianUrl .. "addons/SaveManager.lua",  "SaveManager"),
    ThemeManager = SafeLoad(ObsidianUrl .. "addons/ThemeManager.lua", "ThemeManager"),
    ApplyInfoTab     = SafeLoad(VNDXSUrl .. "Components/InfoTab.luau",     "InfoTab"),
    ApplySettingsTab = SafeLoad(VNDXSUrl .. "Components/SettingsTab.luau", "SettingsTab"),
    ApplyCreditsTab  = SafeLoad(VNDXSUrl .. "Components/CreditsTab.luau",  "CreditsTab"),
}

-- ==================== ثيم VNDXS الإجباري ====================
if Interface.ThemeManager then
    Interface.ThemeManager.BuiltInThemes = {
        ["VNDXS"] = {
            1, {
                FontColor       = Theme.FontColor,
                MainColor       = Theme.MainColor,
                AccentColor     = Theme.AccentColor,
                BackgroundColor = Theme.BackgroundColor,
                OutlineColor    = Theme.OutlineColor,
            }
        },
    }
end

-- ==================== تطبيق الألوان ====================
local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.new(
        tonumber(hex:sub(1,2), 16) / 255,
        tonumber(hex:sub(3,4), 16) / 255,
        tonumber(hex:sub(5,6), 16) / 255
    )
end

task.spawn(function()
    task.wait()
    if Library.SetColors then
        pcall(function()
            Library:SetColors({
                Font       = HexToColor3(Theme.FontColor),
                Main       = HexToColor3(Theme.MainColor),
                Accent     = HexToColor3(Theme.AccentColor),
                Background = HexToColor3(Theme.BackgroundColor),
                Outline    = HexToColor3(Theme.OutlineColor),
            })
        end)
    end
end)

return Interface
