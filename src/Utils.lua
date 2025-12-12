--[[
    Utilities to simplify certain operations that do not exist in Lua by default.
    See the documentation above each function to determine what it does.
--]]

Yipper = {}
Yipper.Utilities = {}

-- Checks whether the given table contains the specified value.
-- Returns true when the value is found; otherwise false.
function Yipper.Utilities:eventSupported(eventsTable, eventName)
    for i, v in pairs(eventsTable) do
        if i == eventName then
            return true
        end
    end

    return false
end

--[[
    Splits the given string on the "-" separator and returns the player and realm
    as separate values to be used in the code.
    This accounts for the input not having the Realm appended to the value.
--]]
function Yipper.Utilities:getPlayerAndRealm(input)
    local player, realm = input:match("^(.-)%-(.-)$")

    if player then
        return player, realm
    end

    return input, nil
end

--[[
      Simple function to dump objects to string
--]]
function Yipper.Utilities:dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. Yipper.Utilities:dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
