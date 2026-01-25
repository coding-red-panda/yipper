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
        local message, sender, _, _, _, _, _, _, _, _, lineId = ...
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
        local message, _, _, _, _, _, _, _, _, lineId = ...

        -- We only care about rolls.
        if message:match("^(%w+) rolls (%d+) %(1 %- (%d+)%)$") then
            local sender = UnitName("player") .. "-" .. GetNormalizedRealmName()

            self:StoreMessage(message, sender, lineId, event)
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

        print("correct?" .. sender)
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
end

-- Updates the tracked player based on the following order:
--- 1. Are we hovering over someone with the the mouse?
--- 2. Do we have someone selected?
--- 3. Set to nil in all other cases.
function Yipper.Events:UpdateTrackedPlayer()
    if UnitName("mouseover") ~= nil and UnitIsPlayer("mouseover") then
        local name, realm = UnitName("mouseover")
        Yipper.TrackedPlayer = name .. "-" .. (realm or GetNormalizedRealmName())
    elseif UnitName("target") ~= nil and UnitIsPlayer("target") then
        local name, realm = UnitName("target")
        Yipper.TrackedPlayer = name .. "-" .. (realm or GetNormalizedRealmName())
    else
        Yipper.TrackedPlayer = nil
        Yipper.messageFrame:Clear()
    end
end
