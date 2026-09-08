--[[
    VNDXS HUB - Settings Tab
    الثيم مقفول على أزرق/أصفر — لا يوجد خيار لتغييره.
]]

return function(Window)

    local function CloneRef(obj)
        if VNDXS and VNDXS.Environment.cloneref then
            return VNDXS.Environment.cloneref(obj)
        end
        return obj
    end

    local Services = setmetatable({}, {
        __index = function(_, name) return CloneRef(game:GetService(name)) end
    })

    local Library      = VNDXS.Interface.Library
    local SaveManager  = VNDXS.Interface.SaveManager
    local ThemeManager = VNDXS.Interface.ThemeManager
    local Options      = Library.Options
    local Theme        = VNDXS.Theme

    -- ==================== دالة تحويل Hex -> Color3 ====================
    local function HexToColor3(hex)
        hex = hex:gsub("#", "")
        return Color3.new(
            tonumber(hex:sub(1,2), 16) / 255,
            tonumber(hex:sub(3,4), 16) / 255,
            tonumber(hex:sub(5,6), 16) / 255
        )
    end

    -- ==================== تطبيق الثيم الإجباري ====================
    local function ApplyForcedTheme()
        if ThemeManager and ThemeManager.SetTheme then
            pcall(function() ThemeManager:SetTheme("VNDXS") end)
        end
        -- تطبيق مباشر كـ backup
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
    end

    -- ==================== إنشاء التاب ====================
    local SettingsTab = Window:AddTab("Settings", "settings")

    -- ==================== مجموعة القائمة ====================
    local MenuGroup = SettingsTab:AddLeftGroupbox("Menu")

    MenuGroup:AddToggle("KeybindMenuOpen", {
        Default  = Library.KeybindFrame.Visible,
        Text     = "Open Keybind Menu",
        Callback = function(value)
            Library.KeybindFrame.Visible = value
        end,
    })

    MenuGroup:AddToggle("ShowCustomCursor", {
        Text     = "Custom Cursor",
        Default  = false,
        Callback = function(value)
            Library.ShowCustomCursor = value
        end,
    })

    MenuGroup:AddDropdown("DPIDropdown", {
        Values   = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
        Default  = "100%",
        Text     = "DPI Scale",
        Callback = function(value)
            Library:SetDPIScale(tonumber(value:gsub("%%", "")))
        end,
    })

    -- ==================== مجموعة الثيم (قراءة فقط) ====================
    local ThemeGroup = SettingsTab:AddLeftGroupbox("Theme")

    ThemeGroup:AddLabel("Theme: VNDXS (Locked)", true)
    ThemeGroup:AddLabel("Primary:    #1E90FF  (Blue)",   true)
    ThemeGroup:AddLabel("Text:       #FFD700  (Yellow)", true)
    ThemeGroup:AddLabel("Background: #050A1A  (Dark)",   true)

    -- زر لإعادة تطبيق الثيم لو تغير بطريقة ما
    ThemeGroup:AddButton("Re-apply Theme", function()
        ApplyForcedTheme()
        Library:Notify("VNDXS theme applied!")
    end)

    -- ==================== مجموعة الخصوصية ====================
    local PrivacyGroup = SettingsTab:AddRightGroupbox("Privacy")

    PrivacyGroup:AddLabel("Analytics: username, executor,\ngame name, execution count.\nNo IP or HWID collected.", true)

    PrivacyGroup:AddToggle("AnalyticsOptIn", {
        Text     = "Enable Analytics (opt-in)",
        Default  = (VNDXS.UserData.AnalyticsOptIn == true),
        Callback = function(value)
            local userData = VNDXS.UserData
            userData.AnalyticsOptIn = value
            VNDXS.SaveUserData(userData)
            Library:Notify(value and "Analytics enabled!" or "Analytics disabled.")
        end,
    })

    -- ==================== مجموعة عامة ====================
    local GeneralGroup = SettingsTab:AddRightGroupbox("General")

    GeneralGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI    = true,
        Text    = "Menu keybind",
    })

    GeneralGroup:AddButton("Copy Discord", function()
        pcall(toclipboard, "https://dsc.gg/vndxshub")
        Library:Notify("Discord invite copied.")
    end)

    GeneralGroup:AddButton("Unload", function()
        Library:Unload()
    end)

    -- ==================== ربط المكونات ====================
    Library.ToggleKeybind = Options.MenuKeybind

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()   -- الثيم مقفول، نتجاهل أي theme settings محفوظة
    SaveManager:SetIgnoreIndexes({ "AnalyticsOptIn" })
    ThemeManager:SetFolder("VNDXS")
    SaveManager:SetFolder("VNDXS/" .. (VNDXS.SavePath or "Global"))
    SaveManager:BuildConfigSection(SettingsTab)
    SaveManager:LoadAutoloadConfig()

    -- تطبيق الثيم الإجباري بعد كل إعداد
    ApplyForcedTheme()
end
