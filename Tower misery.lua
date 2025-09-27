local placeId = game.PlaceId
local rs = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end
setclipboard("https://discord.gg/ZrV9Zdn6qR")

if placeId == 4954752502 then
    notify("Auto Join", "Joining server...", 5)
    wait(3)
    local args = {
        {
            1, true, true, false, false, false,
            300, 5, false, true, "en-us", "ID", true, 3583469565
        }
    }
    rs:WaitForChild("Remote_Events"):WaitForChild("Join Server"):FireServer(unpack(args))

elseif placeId == 11829844120 or placeId == 13601824094 then
    notify("Auto Purchase", "Attempting purchase...", 5)

    rs.BloxbizRemotes.CatalogOnPromptPurchase:InvokeServer(87459153015556)

else
    notify("Script Info", "Unsupported game.", 5)
end
