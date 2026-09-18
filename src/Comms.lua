-- Yipper - Comms
--
-- Hooks up the required comms and allows add-on communication using our
-- own custom channel
local addonName, Yipper = ...

-- Initialize the module
Yipper.Comms = {}

-- Initializes the Comms system, allowing us to send messages using the
-- private channels for AddOn communication.
function Yipper.Comms:Init()
    -- Register the prefix for our AddOn so we can use it.
    -- This will persist reloads in our approach.
    C_ChatInfo.RegisterAddonMessagePrefix(addonName)

    -- Join the permanent Yipper Channel so we can communicate properly.
    -- Not needed for now, since these are not cross-realm
    -- JoinPermanentChannel(Yipper.Constants.CommsChannel)
end

-- Yipper.Comms - BroadcastMessage
--
-- Broadcasts a message using the RAID or PARTY comms.
-- Only options at the moment to send messages across the realms.
--
-- The channel has to match the group we are actually in. GetNumSubgroupMembers()
-- only counts our own subgroup, so it never exceeds 4 and a raid would have been
-- addressed as "PARTY" - which only reaches our own subgroup of five and drops
-- the message for everyone else in the raid.
function Yipper.Comms:BroadcastMessage(message)
    --local channelId, _ = GetChannelName(Yipper.Constants.CommsChannel)
    --C_ChatInfo.SendAddonMessageLogged(addonName, message, "CHANNEL", channelId)
    local channel

    -- Guard the constant: if it were ever nil, IsInGroup(nil) falls back to the
    -- home category and we would route a normal party to INSTANCE_CHAT.
    local instanceCategory = LE_PARTY_CATEGORY_INSTANCE or (Enum.PartyCategory and Enum.PartyCategory.Instance)

    if instanceCategory and IsInGroup(instanceCategory) then
        channel = "INSTANCE_CHAT"
    elseif IsInRaid() then
        channel = "RAID"
    elseif IsInGroup() then
        channel = "PARTY"
    end

    Yipper.Utils:Debug("send: channel =", channel or "(no group)", "payload =", message)

    -- Without a group there is nobody to broadcast to, and the client would
    -- silently discard the message anyway.
    if channel == nil then
        return
    end

    C_ChatInfo.SendAddonMessageLogged(addonName, message, channel)
end
