local addonName, Yipper = ...

Yipper.Events = {}

--- Initialises the Chat module and registers the required events
function Yipper.Events:Init()
    for _, event in pairs(Yipper.Constants.ChatEvents) do
        Yipper.mainFrame:RegisterEvent(event)
    end

    -- Set up a timer that will trigger our tracking update
    -- This helps us in checking whether the mouse has actually
    -- left the unit as well.
    if not self._trackedPlayerTicker then
        self._trackedPlayerTicker = C_Timer.NewTicker(0.1, function()
            self:UpdateTrackedPlayer()
        end)
    end
end

--- Handles the incoming chat events
-- @param event The name of the event being triggered
-- @param ... The arguments passed down with the event (message, sender, etc.)
--
-- The code is identical for most events, but we keep the splitting separate,
-- just in case we need to account for special situation, so we can isolate the
-- problem message's logic in the future.
function Yipper.Events:OnEvent(event, ...)
    if event == "CHAT_MSG_SAY" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_EMOTE" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_GUILD" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_OFFICER" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_PARTY" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_PARTY_LEADER" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_RAID" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_RAID_LEADER" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_YELL" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_WHISPER" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_RAID_WARNING" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_SYSTEM" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...

        -- Do not attempt to process messages when they are secret.
        -- If we're dealing with a secret system message, just ignore it.
        -- Means the player is in combat, and these messages are useless for us.
        if Yipper.Utils:IsSecret(message) then
            return
        end

        -- If the event doesn't include "rolls", it's not a roll event
        -- and we can discard it
        if not string.find(message, "rolls") then
            return
        end

        local author, rollResult, rollMin, rollMax = string.match(message, "(.+) rolls (%d+) %((%d+)-(%d+)%)");

        -- Only broadcast our own messages, otherwise every single roll event will be broadcast as "us".
        -- We don't want that, we want the AddOn to receive rolls from other people and process them
        -- accordingly.
        if author == UnitName("player") then
            -- Because Blizzard in all their wisdom decided not to include the realm or anything
            -- tangible for these events, we'll do it ourselves with a custom event.
            -- If we rolled, just broadcast the roll over the Comms and let the listening
            -- addons handle it to parse the roll message properly with the needed data.
            Yipper.Comms:BroadcastMessage(message.."||"..UnitGUID("player"))
        end
    elseif event == "CHAT_MSG_ADDON_LOGGED" then
        local prefix, message, channel, sender, target, zoneChannelId, localID, name, instanceID = ...

        -- We only care about messages for Yipper, ignore everything else.
        if prefix == addonName then
            -- Since this will just be a roll broadcast by someone,
            -- Add it to the message list as a system message.
            local actualMessage, guid = message:match("^(.+)||(.+)$")
            self:StoreMessage(actualMessage, guid, GetChatTypeIndex("SYSTEM"), "CHAT_MSG_SYSTEM")
        end
    elseif event == "CHAT_MSG_TEXT_EMOTE" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...

        -- Because actual emotes work different,
        -- we need to fix the sender in both cases.
        -- If we're the sender, just construct it using the realm.
        if sender == UnitName("player") then
            guid = UnitGUID("player")
        end

        self:StoreMessage(message, guid, lineId, event)
    end
end

--- Stores a message with the required arguments for the specific player.
--- This builds the table with messages and automatically trims it as well
--- when the maximum amount is exceeded.
function Yipper.Events:StoreMessage(message, guid, lineId, event)
    -- Since our entire logic hinges on the guid not being a secret,
    -- we will drop the entire message in case the guid is flagged as secret.
    -- When you're in combat, you really don't care about RP anyways.
    if Yipper.Utils:IsSecret(guid) then
        return
    end

    -- Sanity check, to ensure nothing bad happens in case
    -- the table is not set...
    if not Yipper.DB.Messages then
        Yipper.DB.Messages = {}
    end

    -- Check if the sender has a record table, might be the first time they're sending
    -- a message.
    if not Yipper.DB.Messages[guid] then
        Yipper.DB.Messages[guid] = { }
    end

    -- Timestamp the message
    message = Yipper.Utils:TimestampMessage(message)

    -- Inject the record in the table.
    table.insert(Yipper.DB.Messages[guid], {
        ["message"] = message,
        ["lineId"] = lineId,
        ["event"] = event
    })

    -- If we have exceeded the maximum amount of messages,
    -- remove the oldest ones.
    if(table.getn(Yipper.DB.Messages) > Yipper.DB.MaxMessages) then
        table.remove(Yipper.DB.Messages, 1)
    end

    -- Play the notification sound, if applicable.
    Yipper.Utils:PlayNotification(message, guid)

    -- Push the message into the messageFrame if the sender is the user currently
    -- being tracked.
    if guid == Yipper.TrackedPlayerGuid then
        local colorCodes = Yipper.Constants.ChatColors[event]

        -- Check if we're at the bottom
        local wasAtBottom = Yipper.messageFrame:AtBottom()

        -- Colorize the message before displaying it
        local coloredMessage = Yipper.Utils:ColorizeMessage(message)

        -- Add the message with the correct color codes.
        -- The method needs values between 0 - 1, so divide the values by 255.
        Yipper.messageFrame:AddMessage(coloredMessage, colorCodes.r / 255, colorCodes.g / 255, colorCodes.b / 255, lineId)

        if not wasAtBottom then
            Yipper.messageFrame:ScrollUp()
        end
    end
end

-- Yipper.Events - UpdateTrackedPlayer
--
-- Updates the tracked player based on the following order:
--- 1. Are we hovering over someone with the the mouse?
--- 2. Do we have someone selected?
--- 3. Set to nil in all other cases.
--
-- Important: This method is called by a Ticker every 0.1 seconds!
function Yipper.Events:UpdateTrackedPlayer()
    -- Variable for tracking the new potential target
    local newTrackedPlayerGuid

    -- Hovering takes precedence, if we're hovering over a player,
    -- that will be our new target.
    -- Otherwise check if the target we have currently have is a player.
    if UnitGUID("mouseover") ~= nil and UnitIsPlayer("mouseover") then
        newTrackedPlayerGuid = UnitGUID("mouseover")
    elseif UnitGUID("target") ~= nil and UnitIsPlayer("target") then
        newTrackedPlayerGuid = UnitGUID("target")
    end

    -- Only update if the newTrackedPlayer is different from the one we're
    -- currently tracking. This accounts for hover, deselect or selecting
    -- a target.
    if newTrackedPlayerGuid ~= Yipper.TrackedPlayerGuid then
        Yipper.TrackedPlayerGuid = newTrackedPlayerGuid

        -- If we have a target or hover, show their messages.
        -- If not, clear the messages.
        if Yipper.TrackedPlayerGuid then
            Yipper.UI.UpdateDisplayedText()
        else
            Yipper.messageFrame:Clear()
        end
    end
end
