-- Yipper - Utils
--
-- Contains methods to be used elsewhere.

local addonName, Yipper = ...

-- Initialize the module
Yipper.Utils = {}

-- Yipper.Utils - ColorizeMessage
--
-- Colors the message by finding the player's name and making sure it pops out.
-- Helps in readability when people are talking about your character.
-- TODO: Expand to include the TRP3 Profile at some point.
function Yipper.Utils:ColorizeMessage(message)
    -- Don't bother editing the message if we can't work with it.
    if issecretvalue(message) and not canaccessvalue(message) then
        return message
    end

    local playerName = UnitName("player")
    local color = Yipper.DB.NotificationColor or Yipper.Constants.NotificationColor
    local colorCode = string.format("%02X%02X%02X", color.r, color.g, color.b)
    local tagStart = "\124cFF"
    local tagEnd = "\124r"

    -- Colorize player name
    if string.find(string.lower(message), string.lower(playerName), 1, true) then
        message = self:ReplaceInsensitiveWithColor(message, playerName, tagStart .. colorCode, tagEnd)
    end

    -- Safeguard the keywords missing/empty
    if Yipper.DB.Keywords == nil or Yipper.DB.Keywords == "" then
        return message
    end

    -- Colorize keywords
    if Yipper.DB.Keywords then
        local keywords = self:SplitString(Yipper.DB.Keywords, ",")

        for i, keyword in ipairs(keywords) do
            if string.find(string.lower(message), string.lower(keyword), 1, true) then
                message = self:ReplaceInsensitiveWithColor(message, keyword, tagStart .. colorCode, tagEnd)
            end
        end
    end

    return message
end

-- Yipper.Utils - ColorizeMessage
--
-- Plays the configured notification sound when the message contains the player's name.
-- TODO: Expand to include the TRP3 Profile at some point.
function Yipper.Utils:PlayNotification(message)
    -- If no notification sound has been set,
    -- return as we can't notify the user with a sound.
    if not Yipper.DB.NotificationSound then
        return
    end

    local playerName = UnitName("player")
    local shouldNotify = false

    if string.find(string.lower(message), string.lower(playerName), 1, true) then
        shouldNotify = true
    end

    if not shouldNotify and Yipper.DB.Keywords and Yipper.DB.Keywords ~= "" then
        local keywords = self:SplitString(Yipper.DB.Keywords, ",")

        for i, value in ipairs(keywords) do
            if string.find(string.lower(message), string.lower(value), 1, true) then
                shouldNotify = true
                break  -- No need to check more keywords
            end
        end
    end

    -- Play the notification sound if we have to.
    if shouldNotify then
        PlaySound(Yipper.DB.NotificationSound)
    end
end

-- Yipper.Utils - SplitString
--
-- Splits the given string using the delimiter into an array of strings.
function Yipper.Utils:SplitString(str, delimiter)
    local result = {}

    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        -- Trim leading and trailing whitespace
        match = match:match("^%s*(.-)%s*$")
        table.insert(result, match)
    end

    return result
end

-- Yipper.Utils - ReplaceInsensitive
--
-- Helper function for case-insensitive replace of the specified string.
--
-- str: The string to perform the replacement on.
-- find: The value we're looking for, case-insensitive
-- colorStart: The color starting tag to apply to the replaced value.
-- colorEnd: The color ending tag to apply the replaced value.
function Yipper.Utils:ReplaceInsensitiveWithColor(str, find, colorStart, colorEnd)
    -- Escape special pattern characters
    local findEscaped = string.gsub(find, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

    -- Create case-insensitive pattern
    local pattern = string.gsub(findEscaped, "%a", function(c)
        return string.format("[%s%s]", string.lower(c), string.upper(c))
    end)

    -- Replace while preserving the original matched case
    return string.gsub(str, pattern, function(matched)
        return colorStart .. matched .. colorEnd
    end)
end
