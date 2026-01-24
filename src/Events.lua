local addonName, Yipper = ...

Yipper.Events = {}

--- Initialises the Chat module and registers the required events
function Yipper.Events:Init()
    for _, event in pairs(Yipper.Constants.ChatEvents) do
        Yipper.mainFrame:RegisterEvent(event)
    end

    -- Register the target changed event, so we can update
    -- our tracked player
    Yipper.mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

--- Handles the incoming chat events
-- @param event The name of the event being triggered
-- @param ... The arguments passed down with the event (message, sender, etc.)
function Yipper.Events:OnEvent(event, ...)
    if (event == "CHAT_MSG_EMOTE") then

    end

    if (event == "CHAT_MSG_SAY") then
        local message, sender, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, sender, lineId, guid, event)
    end
end

--- Stores a message with the required arguments for the specific player.
--- This builds the table with messages and automatically trims it as well
--- when the maximum amount is exceeded.
function Yipper.Events:StoreMessage(message, sender, lineId, guid, event)
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

    table.insert(Yipper.DB.Messages[sender], {
        ["message"] = message,
        ["lineId"] = lineId,
        ["guid"] = guid,
        ["event"] = event
    })

    -- If we have exceeded the maximum amount of messages,
    -- remove the oldest ones.
    if(table.getn(Yipper.DB.Messages) > Yipper.DB.MaxMessages) then
        table.remove(Yipper.DB.Messages, 1)
    end
end

function Yipper.Events:UpdateTrackedPlayer()
    if UnitName("target") ~= nil and UnitIsPlayer("target") then
        local name, realm = UnitName("target")
        Yipper.TrackedPlayer = name .. "-" .. (realm or GetNormalizedRealmName())
    else
        Yipper.TrackedPlayer = nil
    end
end
