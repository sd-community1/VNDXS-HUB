--[[
    VNDXS HUB - Credits Tab
]]

return function(Window)
    local Library = VNDXS.Interface.Library
    local CreditsTab = Window:AddTab("Credits", "star")

    local LogoGroup = CreditsTab:AddLeftGroupbox("VNDXS HUB")
    LogoGroup:AddImage("HubLogo", {
        Image = "https://i.postimg.cc/bJ1N511k/file-00000000652c82108b4c170e410ab2f2.png",
        Size  = UDim2.new(1, 0, 0, 160),
    })

    local DevGroup = CreditsTab:AddLeftGroupbox("Developer")
    DevGroup:AddImage("DevPhoto", {
        Image = "https://i.postimg.cc/d0jxB8JX/Polish-20260913-130404032.jpg",
        Size  = UDim2.new(0, 60, 0, 60),
    })
    DevGroup:AddLabel("👑  V N D X S", true)
    DevGroup:AddLabel("Developer & Founder", true)
    DevGroup:AddDivider()
    DevGroup:AddLabel("Project:  VNDXS HUB", true)
    DevGroup:AddLabel("Version:  v" .. (VNDXS.Version or "1.0.0"), true)
    DevGroup:AddDivider()
    DevGroup:AddButton("Join Discord", function()
        pcall(toclipboard, "https://dsc.gg/vndxshub")
        Library:Notify("Discord invite copied!")
    end)

    local RatingGroup = CreditsTab:AddRightGroupbox("Logo Rating")
    RatingGroup:AddLabel("⭐⭐⭐⭐⭐⭐⭐⭐⭐⭐", true)
    RatingGroup:AddLabel("10 / 10", true)
    RatingGroup:AddDivider()
    RatingGroup:AddLabel("Design:  10/10 ✅", true)
    RatingGroup:AddLabel("Colors:  10/10 ✅", true)
    RatingGroup:AddLabel("Style:   10/10 ✅", true)
    RatingGroup:AddLabel("Vibe:    10/10 ✅", true)

    local ThanksGroup = CreditsTab:AddRightGroupbox("Special Thanks")
    ThanksGroup:AddLabel("FireBacon — Abysall Hub (Base)", true)
    ThanksGroup:AddLabel("Obsidian — UI Library", true)
    ThanksGroup:AddLabel("Open-source community ❤️", true)
end
