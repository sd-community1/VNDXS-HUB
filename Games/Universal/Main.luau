--[[
    VNDXS HUB - Universal
    يعمل في أي لعبة غير مدعومة رسمياً
    يوفر أدوات عامة: Speed، Jump، ESP بسيط
]]

local LocalPlayer = game:GetService("Players").LocalPlayer
local Library     = VNDXS.Interface.Library

-- إشعار بسيط بدون رسالة "sorry"
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title    = "VNDXS HUB",
    Text     = "Running in general mode. Join DOORS or Blox Fruits for full features.",
    Duration = 6,
})

Library:Notify("General mode active.", 4)
