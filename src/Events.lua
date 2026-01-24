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

    -- Register the event for hovering over units,
    -- so we can update the tracked player from hovering
    Yipper.mainFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

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
    end
end
