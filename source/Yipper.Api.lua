--- Yipper API
--
-- This file represents the API of Yipper and the methods exposed towards other AddOns running in the client.
-- For more documentation, please check out our wiki on the usage of the methods.
--
local addonName, Yipper = ...

-- Define the table for the API so that other AddOns can simply call Yipper.API when the AddOn has been
-- loaded by the client.
Yipper.API = {}

------------------------------------------------------------------------------------------------------------------------
-- API Definition
------------------------------------------------------------------------------------------------------------------------

--- Returns all messages for the specified player
---@param guid string The GUID identifying the player.
---@return table An array of messages for the player
---@return nil If the GUID is secret or the table is empty
function Yipper.API:MessagesForPlayer(guid)
    if self:IsSecret(guid) then
        return nil
    end

    if not Yipper.DB.Messages[guid] ~= nil then
        return nil
    end

    return Yipper.DB.Messages[guid]
end

--- Determines whether the provided value is considered a secret or not.
--- @param value any The value to check for being a secret.
--- @return bool True if the value is a secret; otherwise false
function Yipper.API:IsSecret(value)
    return issecretvalue(value) and not canaccessvalue(value)
end
