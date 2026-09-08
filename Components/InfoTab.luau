--[[
    VNDXS HUB - Info Tab
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

    local Library     = VNDXS.Interface.Library
    local LocalPlayer = Services.Players.LocalPlayer

    -- ==================== Changelog ====================
    local LatestChangelog = {
        "VNDXS HUB v1.0.0",
        "<font color='rgb(255, 215, 0)'>★ Initial Release</font>",
        "<font color='rgb(30, 144, 255)'>+ Full DOORS support</font>",
        "<font color='rgb(30, 144, 255)'>+ Entity ESP</font>",
        "<font color='rgb(30, 144, 255)'>+ Item Notifier</font>",
        "<font color='rgb(30, 144, 255)'>+ Death Farm</font>",
        "<font color='rgb(30, 144, 255)'>+ Blue & Yellow theme</font>",
    }

    -- ==================== إنشاء التاب ====================
    local InfoTab = Window:AddTab("Info", "user")

    -- ==================== معلومات المستخدم ====================
    local UserGroup = InfoTab:AddLeftGroupbox("User Info")

    pcall(function()
        local thumbnail = Services.Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size420x420
        )
        UserGroup:AddImage("UserIcon", { Image = thumbnail })
    end)

    UserGroup:AddLabel("Username: " .. LocalPlayer.Name,             true)
    UserGroup:AddLabel("User ID: "  .. tostring(LocalPlayer.UserId), true)
    UserGroup:AddLabel("Executions: " .. tostring(VNDXS.TotalExecutions or "N/A"), true)
    UserGroup:AddLabel("Hub: " .. VNDXS.Name .. " v" .. VNDXS.Version, true)

    -- ==================== Changelog ====================
    local ChangelogGroup = InfoTab:AddRightGroupbox("Changelog")
    for _, change in ipairs(LatestChangelog) do
        ChangelogGroup:AddLabel(change, true)
    end

    -- ==================== معلومات الـ Executor ====================
    local ExecutorGroup = InfoTab:AddRightGroupbox("Executor Info")

    if VNDXS.Environment.identifyexecutor then
        local ok, execName, execVer = pcall(VNDXS.Environment.identifyexecutor)
        if ok then
            -- pcall مع دوال ترجع قيمتين
            local n, v = VNDXS.Environment.identifyexecutor()
            ExecutorGroup:AddLabel("Name: "    .. tostring(n),           true)
            ExecutorGroup:AddLabel("Version: " .. tostring(v or "N/A"),  true)
        else
            ExecutorGroup:AddLabel("Executor: Unknown", true)
        end
    else
        ExecutorGroup:AddLabel("identifyexecutor not available", true)
    end

    ExecutorGroup:AddDivider()
    ExecutorGroup:AddLabel("Env Test Results:", true)

    for _, result in ipairs(VNDXS.Environment.Results or {}) do
        local safe = result:gsub("<", "("):gsub(">", ")")
        ExecutorGroup:AddLabel(safe, true)
    end

    -- ==================== مجتمع ====================
    local CommunityGroup = InfoTab:AddLeftGroupbox("Community")

    CommunityGroup:AddButton("Copy Discord", function()
        pcall(toclipboard, "https://dsc.gg/vndxshub")
        Library:Notify("Discord invite copied.")
    end)
end
