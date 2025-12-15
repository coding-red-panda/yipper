-- Yipper - Utilities
--
-- This section defines special methods that can be called to handle miscellaneous operations inside
-- the AddOn. These methods are part of the Util namespace of our AddOn.
local _, addonTable = ...
local Util = { }
addonTable.Util = Util

-- Extracts the player's name and realm from the provided string the AddOn code gives us.
-- The expected format is <PlayerName>-<RealmName>.
-- In case we just receive the player's name, we return the player's name as is.
function Util:getPlayerAndRealm(input)
    local player, realm = input:match("^(.-)%-(.-)$")

    if player then
        return player, realm
    end

    return input, nil
end

-- Debug method for dumping a table to a readable string.
-- Used for outputting data to verify information.
function Util:dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. self:dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
