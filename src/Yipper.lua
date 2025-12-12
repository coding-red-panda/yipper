print("Yipper successfully loaded!")

--
-- Create the Frame for Yipper so we can listen to events and display stuff
--
local frame = CreateFrame("Frame")

--
-- Define the function to handle the event handling
--
function frame:OnEvent(event, ...)
    print("Yipper received the event: " .. event)

    if Yipper.Utilities:contains(Yipper.Constants.MessageEvents, event) then
        local msg, playerName, _, channelName = ...
        local player, realm = Yipper.Utilities:getPlayerAndRealm(playerName)
        print("Yipper: event='" .. event .. "' | player='" .. player  .. "' | Realm='" .. realm .. "' | channel='" .. channelName .. "' | message='" .. msg .. "'")
    end
end


--
-- Register all events that we are interested in
--
for _, eventName in ipairs(Yipper.Constants.MessageEvents) do
    frame:RegisterEvent(eventName);
end
frame:SetScript("OnEvent", frame.OnEvent)
