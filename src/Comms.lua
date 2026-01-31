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
function Yipper.Comms:BroadcastMessage(message)
    --local channelId, _ = GetChannelName(Yipper.Constants.CommsChannel)
    --C_ChatInfo.SendAddonMessageLogged(addonName, message, "CHANNEL", channelId)
    if GetNumSubgroupMembers() > 4 then
        C_ChatInfo.SendAddonMessageLogged(addonName, message, "RAID", channelId)
    else
        C_ChatInfo.SendAddonMessageLogged(addonName, message, "PARTY", channelId)
    end
end
