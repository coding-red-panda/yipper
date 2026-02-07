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
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_EMOTE" then
        local message, sender, _, _, _, _, _, _, _, _, lineId, guid = ...

        -- Fix the message to include the sender's name.
        -- TODO: Support TRP3 Profiles
        local _, _, _, _, _, name, _ = GetPlayerInfoByGUID(guid)
        message = name .. " " .. message

        -- Before storing the message, find the quoted parts
        -- and colorize them with the correct color.
        message = Yipper.Utils:ColorizeQuotes(message)

        -- Store the message and process it
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_GUILD" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_OFFICER" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_PARTY" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_PARTY_LEADER" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_RAID" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_RAID_LEADER" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_YELL" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_WHISPER" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_RAID_WARNING" then
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
        self:StoreMessage(message, sender, lineId, event)
    elseif event == "CHAT_MSG_SYSTEM" then
        local message, _, _, _, _, _, _, _, _, _, lineId = ...

        -- Do not attempt to process messages when they are secret.
        -- If we're dealing with a secret system message, just ignore it.
        -- Means the player is in combat, and these messages are useless for us.
        if issecretvalue(message) and not canaccessvalue(message) then
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
            Yipper.Comms:BroadcastMessage(message)
        end
    elseif event == "CHAT_MSG_ADDON_LOGGED" then
        local prefix, message, channel, sender, target, zoneChannelId, localID, name, instanceID = ...

        -- We only care about messages for Yipper, ignore everything else.
        if prefix == addonName then
            -- Since this will just be a roll broadcast by someone,
            -- Add it to the message list as a system message.
            self:StoreMessage(message, sender, GetChatTypeIndex("SYSTEM"), "CHAT_MSG_SYSTEM")
        end
    elseif event == "CHAT_MSG_TEXT_EMOTE" then
        local message, sender, _, _, _, _, _, _, _, _, lineId, guid = ...

        -- Because actual emotes work different,
        -- we need to fix the sender in both cases.
        -- If we're the sender, just construct it using the realm.
        if sender == UnitName("player") then
            sender = UnitName("player") .. "-" .. GetNormalizedRealmName()
        else
            -- If the sender is someone else, use their GUID to get the player info.
            local _, _, _, _, _, name, realmName = GetPlayerInfoByGUID(guid)

            -- Sadly realmName is not returned on same realm emotes
            -- so manually set it.
            if realmName == nil or realmName == "" then
                -- Is nil/empty on the same realm
                realmName = GetNormalizedRealmName()
            end

            sender = name .. "-" .. realmName
        end

        self:StoreMessage(message, sender, lineId, event)
    end
end

--- Stores a message with the required arguments for the specific player.
--- This builds the table with messages and automatically trims it as well
--- when the maximum amount is exceeded.
function Yipper.Events:StoreMessage(message, sender, lineId, event)
    -- Sanity check, to ensure nothing bad happens in case
    -- the table is not set...
    if not Yipper.DB.Messages then
        Yipper.DB.Messages = {}
    end

    -- Check if the sender has a record table, might be the first time they're sending
    -- a message.
    if not Yipper.DB.Messages[sender] then
        Yipper.DB.Messages[sender] = { }
    end

    -- Timestamp the message
    message = Yipper.Utils:TimestampMessage(message)

    -- Inject the record in the table.
    table.insert(Yipper.DB.Messages[sender], {
        ["message"] = message,
        ["lineId"] = lineId,
        ["event"] = event
    })

    -- If we have exceeded the maximum amount of messages,
    -- remove the oldest ones.
    if(table.getn(Yipper.DB.Messages) > Yipper.DB.MaxMessages) then
        table.remove(Yipper.DB.Messages, 1)
    end

    local function ShouldPlayNotification(origin)
        local name, realm = UnitName("player")
        local me = name.."-"..(realm or GetNormalizedRealmName())

        return origin ~= me
    end

    -- Play the notification sound if required.
    if ShouldPlayNotification(sender) then
        Yipper.Utils:PlayNotification(message)
    end

    -- Push the message into the messageFrame if the sender is the user currently
    -- being tracked.
    if sender == Yipper.TrackedPlayer then
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
    local newTrackedPlayer

    -- Hovering takes precedence, if we're hovering over a player,
    -- that will be our new target.
    -- Otherwise check if the target we have currently have is a player.
    if UnitName("mouseover") ~= nil and UnitIsPlayer("mouseover") then
        local name, realm = UnitName("mouseover")
        newTrackedPlayer = name .. "-" .. (realm or GetNormalizedRealmName())
    elseif UnitName("target") ~= nil and UnitIsPlayer("target") then
        local name, realm = UnitName("target")
        newTrackedPlayer = name .. "-" .. (realm or GetNormalizedRealmName())
    end

    -- Only update if the newTrackedPlayer is different from the one we're
    -- currently tracking. This accounts for hover, deselect or selecting
    -- a target.
    if newTrackedPlayer ~= Yipper.TrackedPlayer then
        Yipper.TrackedPlayer = newTrackedPlayer

        -- If we have a target or hover, show their messages.
        -- If not, clear the messages.
        if Yipper.TrackedPlayer then
            Yipper.UI.UpdateDisplayedText()
        else
            -- No player tracked, clear the frame
            Yipper.messageFrame:Clear()
        end
    end
end
