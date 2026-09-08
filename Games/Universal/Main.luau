local Services = setmetatable({}, {
    __index = function(self, Name)
        if VNDXS.Environment.cloneref then
            return VNDXS.Environment.cloneref(game:GetService(Name))
        else
            return game:GetService(Name)
        end
    end
})

local Bindable = Instance.new("BindableFunction")
Bindable.OnInvoke = function(Response)
    local Success, Result = pcall(function()
        toclipboard("https://dsc.gg/vndxshub")
    end)
    if not Success then
        Services.LocalPlayer:Kick("Failed to copy invite.\nhttps://dsc.gg/vndxshub")
    end
end

Services.StarterGui:SetCore("SendNotification", {
    Title = "VNDXS Hub",
    Text = "Only DOORS is supported right now, sorry :)",
    Duration = 10,
    Button1 = "Copy Discord Invite",
    Callback = Bindable,
})
