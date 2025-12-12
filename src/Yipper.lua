print("Yipper successfully loaded!")

--
-- Create the Frame for Yipper so we can listen to events and display stuff
--
local frame = CreateFrame("Frame", "Yipper", ParentUI, "BackdropTemplate")
frame:SetSize(200, 400)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1
})
frame:SetBackdropColor(0, 0, 0, 0.5)
frame:SetBackdropBorderColor(0, 0, 0)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetScript("OnHide", frame.StopMovingOrSizing)

local closeButton = CreateFrame("Button", "YipperCloseButton", frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
closeButton:SetScript("OnClick", function() frame:Hide()  end)

--
-- Define the function to handle the event handling
-- Passes the event through to the correct method, since we only have this
-- event handler registered.
--
function frame:OnEvent(event, ...)
    if Yipper.Utilities:eventSupported(Yipper.Constants.MessageEvents, event) then
        local handler = self[Yipper.Constants.MessageEvents[event]]

        if handler then
            handler(self, event, ...)
        else
            print("Handler not supported for now")
        end
    end
end

--
-- Handles the CHAT_MSG_SAY event internally.
-- Takes the entire payload of the event and processes the data.
--
-- The event contains the following payload:
--      - 1. text: The chat message
--      - 2. playerName: The name + realm of the player
--      - 3. languageName: The name of the language used for the message, e.g "Common"
--      - 4. channelName: The channel name with index, e.g "2. Trade - City"
--      - 5. playerName2: The target player name when two users are involved, otherwise same as playerName.
--      - 6. specialFlags: User flags if applicable, e.g "GM", "DND", "AFK"
--      - 7. zoneChannelID: The static number of the zone channel, 1 for General, 2 for Trade
--      - 8. channelIndex: Channel Index, depends on join order of channels
--      - 9. channelBaseName: Channel name without the index number, e.g. "Trade - City"
--      - 10. languageID: Number presenting the languageID: https://wowpedia.fandom.com/wiki/LanguageID
--      - 11. lineID: Unique identifier for the chat message
--      - 12. guid: Sender's unit GUID
--      - 13. bnSenderID: ID of the battle.net friend
--      - 14. isMobile: If sender is using the mobile app.
--      - 15. isSubtitle: ??
--      - 16. hideSenderInLetterBox: Whether to show in CinematicFrame only or not.
--      - 17. supressRaidIcons: Whether target marker expressions should not be rendered.
--
function frame:OnChatMessage(event, ...)
    -- Extract the data we care about
    local msg, playerName, languageName, _, _, _, _, _, _, _, lineId = ...
    local timestamp = time()
    local player, realm = Yipper.Utilities:getPlayerAndRealm(playerName)

    -- Ensure a table record exists for the player
    if not Yipper.Database[playerName] then
        Yipper.Database[playerName] = {}
    end

    -- Store the data in the database.
    table.insert(Yipper.Database[playerName], {
        ["id"] = lineId,
        ["timestamp"] = timestamp,
        ["eventType"] = event,
        ["message"] = msg,
        ["read"] = timestamp < Yipper.LastActivity,
        ["sender"] = player,
        ["realm"] = realm
    })

    for k,v in pairs(Yipper.Database[playerName]) do
        print("key: " .. k)
        print("value: " .. Yipper.Utilities:dump(v))
    end
end

--
-- Register all events that we are interested in
--
for eventName, _ in pairs(Yipper.Constants.MessageEvents) do
    frame:RegisterEvent(eventName);
end
frame:SetScript("OnEvent", frame.OnEvent)
