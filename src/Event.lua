-- Yipper - Event Module
--
-- Defines all the event handlers responsible for reacting to various in-game situations.
-- These have been separated here to keep the files smaller and have an overview on where
-- to find what.
local _, addonTable = ...
local Events = { }
addonTable.Events = Events

--
-- Event Handlers
--

-- OnTargetChanged Event Handler
--
-- Called by the AddOn whenever the player switches the respective target ingame.
-- The AddOn will react on this and clear the selected target from the overview.
function Events:OnTargetChanged()
    local targetName = UnitName("target")

    if(targetName) and UnitIsPlayer("target") then
        Yipper.TrackedPlayer = targetName
        Yipper.UI.playerFrame.text:SetText(targetName)
        -- TODO: Load tracked messages
    else
        Yipper.TrackedPlayer = nil
        Yipper.UI.playerFrame.text:SetText(nil)
        -- TODO: Clear tracked messages
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
function Events:OnChatMessage(event, ...)
    -- Extract the data we care about
    local msg, playerName, languageName, _, _, _, _, _, _, _, lineId = ...
    local timestamp = time()
    local player, realm = Yipper.Util:getPlayerAndRealm(playerName)

    -- Ensure a table record exists for the player
    if not Yipper.Database[playerName] then
        Yipper.Database[playerName] = { }
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
        print("value: " .. Yipper.Util:dump(v))
    end
end

-- Global Event Handler that parses each incoming, registered event.
-- Will delegate the required arguments to the correct Yipper event for parsing.
-- Relies on Table reference calling since this function will be registered as an event-handler
-- on the parent frame.
function Events:OnEvent(event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        Events:OnTargetChanged()
        return
    end

    if event == "CHAT_MSG_SAY" then
        Events:OnChatMessage(event, ...)
        return
    end
end
