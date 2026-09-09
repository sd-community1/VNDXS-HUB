--[[
    VNDXS HUB - Credits Tab
    يُضاف لكل لعبة
]]

return function(Window)

    local Library = VNDXS.Interface.Library

    local CreditsTab = Window:AddTab("Credits", "star")

    -- ==================== شعار المجموعة ====================
    local LogoGroup = CreditsTab:AddLeftGroupbox("VNDXS HUB")

    -- الصورة من GitHub
    LogoGroup:AddImage("HubLogo", {
        Image = "https://raw.githubusercontent.com/sd-community1/VNDXS-HUB/refs/heads/main/Assets/logo.png",
        Size  = UDim2.new(1, 0, 0, 160),
    })

    -- ==================== معلومات المطور ====================
    local DevGroup = CreditsTab:AddLeftGroupbox("Developer")

    DevGroup:AddLabel("👑  Developer", true)
    DevGroup:AddLabel("VNDXS", true)
    DevGroup:AddDivider()
    DevGroup:AddLabel("🔧  Project", true)
    DevGroup:AddLabel("VNDXS HUB", true)
    DevGroup:AddDivider()
    DevGroup:AddLabel("📅  Version", true)
    DevGroup:AddLabel("v" .. (VNDXS.Version or "1.0.0"), true)
    DevGroup:AddDivider()
    DevGroup:AddButton("Join Discord", function()
        pcall(toclipboard, "https://dsc.gg/vndxshub")
        Library:Notify("Discord invite copied!")
    end)

    -- ==================== تقييم الشعار ====================
    local RatingGroup = CreditsTab:AddRightGroupbox("Logo Rating")

    RatingGroup:AddLabel("⭐⭐⭐⭐⭐⭐⭐⭐⭐⭐", true)
    RatingGroup:AddLabel("10 / 10", true)
    RatingGroup:AddDivider()
    RatingGroup:AddLabel("Design: 10/10 ✅", true)
    RatingGroup:AddLabel("Colors: 10/10 ✅", true)
    RatingGroup:AddLabel("Style: 10/10 ✅", true)
    RatingGroup:AddLabel("Vibe: 10/10 ✅", true)
    RatingGroup:AddDivider()
    RatingGroup:AddLabel("\"Absolutely fire 🔥\"", true)

    -- ==================== Special Thanks ====================
    local ThanksGroup = CreditsTab:AddRightGroupbox("Special Thanks")
    ThanksGroup:AddLabel("FireBacon — Abysall Hub (Base)", true)
    ThanksGroup:AddLabel("Obsidian — UI Library", true)
    ThanksGroup:AddLabel("W_Skinny — BF Reference", true)

end
