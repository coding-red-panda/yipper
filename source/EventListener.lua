--- EventListener
--
-- The EventListener is an object that runs when the AddOn starts and handles all the incoming events that
-- Yipper is listening to. By isolating the logic for the event handling in a stand-alone class, we can focus
-- objects to specific purposes and maintain the code better.
--
-- Depends on Database, Comms, API
local addonName, Yipper = ...
local events = {
    -- Global AddOn events
    "ADDON_LOADED",

    -- Chat events
    "CHAT_MSG_EMOTE",
    "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_YELL",
    "CHAT_MSG_SAY",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_ADDON_LOGGED",

    -- Loading screen events
    "LOADING_SCREEN_ENABLED",
    "LOADING_SCREEN_DISABLED",

    -- Player related events
    "PLAYER_LOGOUT",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",

    -- Yipper Custom Events
    "YIPPER_TRACKED_PLAYER_CHANGED"
}

-- Initialize the module and set the function look up.
local EventListener = {}
EventListener.__index = EventListener

--- Creates a new instance of the EventListener.
--- @return table An instance of the EventListener class.
function EventListener.new()
    local newObject = setmetatable({}, self)

    -- Object initialization
    newObject:Initialize()

    return newObject
end

--- Initializes the instance, ensuring the frame and event handling is in place.
---@return nil
---@private
function EventListener:Initialize()
    self._frame = CreateFrame("Frame", "Yipper_EventFrame", UIParent)

    -- Register Events
    for _, event in pairs(events) do
        self._frame:RegisterEvent(event)
    end

    -- Capture the EventListener instance so the handler can reach it.
    -- WoW calls OnEvent with the *frame* as the first argument, so we
    -- must not rely on `self` inside the callback -- it would be the frame.
    local instance = self

    self._frame:SetScript("OnEvent", function(_, event, ...)
        instance:OnEvent(event, ...)
    end)
end

--- Handles the incoming events from the client.
---@return nil
---@private
function EventListener:OnEvent(event, ...)
    if (event == "ADDON_LOADED" and addonName == name) then
        -- If the YipperDB is nil, it means this is the first time loading
        -- the Addon. In that case, assign the default values for the AddOn
        -- to the DB.
        if YipperDB == nil then
            Yipper.DB = {
                ["Messages"] = {},
                ["MaxMessages"] = 50,
                ["BackgroundColor"] = Yipper.Constants.BlackColor,
                ["BorderColor"] = Yipper.Constants.BlackColor,
                ["Alpha"] = Yipper.Constants.Alpha,
                ["FontSize"] = Yipper.Constants.FontSize,
                ["SelectedFont"] = Yipper.Constants.Fonts.FrizQuadrata,
                ["NotificationSound"] = nil,
                ["NotificationColor"] = Yipper.Constants.NotificationColor,
                ["ShowHeader"] = true,
                ["PingTrackedPlayer"] = false,
                ["EnableMinimapButton"] = true
            }
            -- If the YipperDB variable has been loaded for the character,
            -- assign it to the internal DB so the AddOn has its settings
            -- loaded and available.
        elseif YipperDB then
            Yipper.DB = YipperDB

            -- Wipe the past messages if Yipper has been updated.
            -- This avoids weird behavior in updates when we change stuff.
            if (not Yipper.DB.Version) or Yipper.Utils:IsUpdated(Yipper.DB.Version) then
                Yipper.DB.Version = Yipper.Constants.VERSION
                Yipper.DB.Messages = { }
            end

            -- Fix the keywords, they should be an array
            -- Apply this for any version after 1.5.6 to fix the data.
            if Yipper.Utils:IsUpdated("1.5.6") then
                if Yipper.DB.Keywords and type(Yipper.DB.Keywords) == "string" then
                    local keywords = Yipper.DB.Keywords or ""
                    Yipper.DB.Keywords = Yipper.Utils:SplitString(keywords, ",")
                end
            end

            -- Migrate the NotificationColor from the 0-1 range to the 0-255 range.
            -- Older versions stored the color components as 0-1, but the constants now
            -- use the 0-255 range to stay consistent with the other color constants.
            local c = Yipper.DB.NotificationColor
            if c ~= nil and c.r ~= nil and c.g ~= nil and c.b ~= nil
                    and c.r <= 1 and c.g <= 1 and c.b <= 1 then
                Yipper.DB.NotificationColor = {
                    ["r"] = c.r * 255,
                    ["g"] = c.g * 255,
                    ["b"] = c.b * 255
                }
            end
        end
    elseif event == "PLAYER_LOGOUT" then
        YipperDB = Yipper.DB
    -- Loading screen has started, put events in the queue and process later.
    elseif event == "LOADING_SCREEN_ENABLED" then
        Yipper.EventQueue.IsLoadingScreenOrCombat = true
    -- Loading screen has ended, process events like normal and process the queue.
    elseif event == "LOADING_SCREEN_DISABLED" then
        Yipper.EventQueue.IsLoadingScreenOrCombat = false
        Yipper.EventQueue:ProcessQueue()
    -- Combat has started, put events in the event queue and process later.
    elseif event == "PLAYER_REGEN_DISABLED" then
        Yipper.EventQueue.IsLoadingScreenOrCombat = true
    -- Combat has ended, process events light normal, and process the queue.
    elseif event == "PLAYER_REGEN_ENABLED" then
        Yipper.EventQueue.IsLoadingScreenOrCombat = false
        Yipper.EventQueue:ProcessQueue()
    elseif event == "CHAT_MSG_SAY" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...
        self:StoreMessage(message, guid, lineId, event)
    elseif event == "CHAT_MSG_EMOTE" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...

        -- NPC Emotes in instances do not have a GUID.
        -- Ignore these events
        if guid == nil then
            return
        end

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
        local message, _, _, _, _, _, _, _, _, _, lineId, _ = ...

        -- Do not attempt to process messages when they are secret.
        -- If we're dealing with a secret system message, just ignore it.
        -- Means the player is in combat, and these messages are useless for us.
        if Yipper.API:IsSecret(message) then
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
            Yipper.Comms:BroadcastMessage(message.."||"..UnitGUID("player").."||"..lineId)
        end
    elseif event == "CHAT_MSG_ADDON_LOGGED" then
        local prefix, message, channel, sender, target, zoneChannelId, localID, name, instanceID = ...

        -- We only care about messages for Yipper, ignore everything else.
        if prefix == addonName then
            -- Since this will just be a roll broadcast by someone,
            -- Add it to the message list as a system message.
            local actualMessage, guid, lineId = message:match("^(.+)||(.+)||(.+)$")
            self:StoreMessage(actualMessage, guid, lineId, "CHAT_MSG_SYSTEM")
        end
    elseif event == "CHAT_MSG_TEXT_EMOTE" then
        local message, _, _, _, _, _, _, _, _, _, lineId, guid = ...

        -- NPC Emotes in instances do not have a GUID.
        -- Ignore these events
        if guid == nil then
            return
        end

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
---@param message string The message received through the chat events
---@param guid string The GUID of the sender
---@param lineId number The line identifier of the message in the main chat
---@param event string The event that triggered the message
---@return nil
---@private
function EventListener:StoreMessage(message, guid, lineId, event)
    -- Since our entire logic hinges on the guid not being a secret,
    -- we will drop the entire message in case the guid is flagged as secret.
    -- When you're in combat, you really don't care about RP anyways.
    if Yipper.API:IsSecret(guid) then
        return
    end

    -- Sanity check, to ensure nothing bad happens in case the table is not set...
    if not Yipper.DB.Messages then
        Yipper.DB.Messages = {}
    end

    -- Check if the sender has a record table, might be the first time they're sending a message.
    if not Yipper.DB.Messages[guid] then
        Yipper.DB.Messages[guid] = { }
    end

    -- Inject the record in the table.
    table.insert(Yipper.DB.Messages[guid], {
        ["message"] = message,
        ["lineId"] = lineId,
        ["event"] = event,
        ["timestamp"] = date("%H:%M"),
        ["epoch"] = time()
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
        -- Check if we're at the bottom
        local wasAtBottom = Yipper.messageFrame:AtBottom()

        -- Push the message into the frame.
        Yipper.UI:AddMessageToFrame({
            ["message"] = message,
            ["lineId"] = lineId,
            ["event"] = event,
            ["timestamp"] = date("%H:%M"),
            ["epoch"] = time()
        })

        if not wasAtBottom then
            Yipper.messageFrame:ScrollUp()
        end
    end
end

-- Create the instance and store it in Yipper to make it available.
Yipper.EventListener = EventListener.new()
