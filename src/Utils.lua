-- Yipper - Utils
--
-- Contains methods to be used elsewhere.

local _, Yipper = ...

-- Initialize the module
Yipper.Utils = {}

-- Yipper.Utils - IsSecret
--
-- Function that returns true when the passed in data is a secret
-- and not accessible for safe usage.
function Yipper.Utils:IsSecret(value)
    return issecretvalue(value) and not canaccessvalue(value)
end

-- Yipper.Utils - Debug
--
-- TEMPORARY DIAGNOSTICS. Prints a line to the default chat frame, but only
-- while debugging is enabled with `/yip debug`, so a normal session stays quiet.
-- Never pass a value that might be secret: tostring() on one will error.
function Yipper.Utils:Debug(...)
    if not Yipper.DB or not Yipper.DB.Debug then
        return
    end

    -- The chat frame treats "|" as an escape character when rendering, so a
    -- payload would display differently from what actually went over the wire.
    -- Double every pipe in the arguments so the output is literal.
    local args = { ... }

    for i = 1, select("#", ...) do
        if type(args[i]) == "string" then
            args[i] = args[i]:gsub("|", "||")
        end
    end

    print("|cFF2A84EB[Yipper]|r", unpack(args))
end

-- Yipper.Utils - IsFromDiscord
--
-- Returns true when the given chat payload originates from Discord through
-- WoW's guild <-> Discord integration (Patch 12.1). These messages are relayed
-- into guild/officer chat with a nil player GUID and no in-world unit, so they
-- cannot be hovered, targeted or tracked by Yipper's GUID-based model.
function Yipper.Utils:IsFromDiscord(discordInfo)
    -- The payload itself can be flagged as a secret, and comparing a secret
    -- value throws "attempt to compare a secret value (execution tainted)".
    if self:IsSecret(discordInfo) or discordInfo == nil then
        return false
    end

    -- Every field is flagged separately, so the flag can be secret even when
    -- the table itself is readable. We cannot inspect it, so report "not from
    -- Discord" and leave the call to StoreMessage: Discord-relayed messages
    -- carry no player GUID, and those are dropped there already.
    if self:IsSecret(discordInfo.fromDiscord) then
        return false
    end

    return discordInfo.fromDiscord == true
end

-- Yipper.Utils - IsUpdated
--
-- Returns a boolean if Yipper has been updated.
-- Takes a semantic version, and returns true if the provided version is older than the
-- Yipper version.
function Yipper.Utils:IsUpdated(version)
    -- Parse the input version
    local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")

    -- If we can't extract the version somehow, return false.
    if not major then
        return false
    end

    -- Parse Yipper.VERSION
    local yipper_major, yipper_minor, yipper_patch = Yipper.Constants.VERSION:match("^(%d+)%.(%d+)%.(%d+)$")

    -- Convert to numbers for comparison
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
    yipper_major, yipper_minor, yipper_patch = tonumber(yipper_major), tonumber(yipper_minor), tonumber(yipper_patch)

    -- Compare versions
    if yipper_major > major then
        return true
    elseif yipper_major < major then
        return false
    end

    -- Major versions are equal, check minor
    if yipper_minor > minor then
        return true
    elseif yipper_minor < minor then
        return false
    end

    -- Major and minor are equal, check patch
    return yipper_patch > patch
end

-- Yipper.Utils - ColorizeQuotes
--
-- Finds quoted text in the message and ensures that it is displayed in the color
-- of a normal say message.
-- This function should only be called when dealing with emote messages.
function Yipper.Utils:ColorizeQuotes(message)
    -- Don't bother editing the message if we can't work with it.
    if issecretvalue(message) and not canaccessvalue(message) then
        return message
    end

    -- Get the color for quoted text (CHAT_MSG_SAY)
    local color = Yipper.Constants.ChatColors["CHAT_MSG_SAY"]
    local colorCode = string.format("%02X%02X%02X", color.r, color.g, color.b)
    local tagStart = "\124cFF"
    local tagEnd = "\124r"

    -- Pattern to match text within quotes
    -- This will match both "double quotes" and handle escaped quotes if needed
    local pattern = '"([^"]+)"'

    -- Replace all quoted text with colorized version
    message = string.gsub(message, pattern, function(quotedText)
        return '"' .. tagStart .. colorCode .. quotedText .. tagEnd .. '"'
    end)

    return message
end

-- Yipper.Utils - ColorizeMessage
--
-- Colors the message by finding the player's name and making sure it pops out.
-- Helps in readability when people are talking about your character.
-- TODO: Expand to include the TRP3 Profile at some point.
function Yipper.Utils:ColorizeMessage(message)
    -- Don't bother editing the message if we can't work with it.
    if self:IsSecret(message) then
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
    if Yipper.DB.Keywords == nil or Yipper.DB.Keywords == { } or Yipper.DB.Keywords == "" then
        return message
    end

    -- Colorize keywords
    for _, keyword in ipairs(Yipper.DB.Keywords) do
        if keyword ~= nil and keyword ~= "" and string.find(message, keyword, 1, true) then
            message = self:ReplaceSensitiveWithColor(message, keyword, tagStart .. colorCode, tagEnd)
        end
    end

    -- Colorize emotes, currently hardcoded to *
    local emoteColor = Yipper.Constants.ChatColors["CHAT_MSG_EMOTE"]
    local emoteColorCode = string.format("%02X%02X%02X", emoteColor.r, emoteColor.g, emoteColor.b)
    local seenEmotes = {}

    for emote in string.gmatch(message, "%*[^%*]+%*") do
        if not seenEmotes[emote] then
            seenEmotes[emote] = true
            message = self:ReplaceInsensitiveWithColor(message, emote, tagStart .. emoteColorCode, tagEnd)
        end
    end

    return message
end

-- Yipper.Utils - ColorizeMessage
--
-- Plays the configured notification sound when the message contains the player's name.
-- TODO: Expand to include the TRP3 Profile at some point.
function Yipper.Utils:PlayNotification(message, guid)
    -- If no notification sound has been set,
    -- return as we can't notify the user with a sound.
    if not Yipper.DB.NotificationSound then
        return
    end

    local _, _, _, _, _, _, _ = GetPlayerInfoByGUID(guid)
    local playerName = UnitName("player")

    -- Do not play the notification sound for our own messages.
    if guid == UnitGUID("player") then
        return
    end

    local shouldNotify = false

    if string.find(string.lower(message), string.lower(playerName), 1, true) then
        shouldNotify = true
    end

    -- If the sender is currently being tracked, notify the player.
    -- The caller checks already if this is not us to avoid spam.
    if not shouldNotify and Yipper.DB.PingTrackedPlayer and guid == Yipper.TrackedPlayerGuid then
        shouldNotify = true
    end

    if not shouldNotify and Yipper.DB.Keywords and next(Yipper.DB.Keywords) ~= nil then
        for _, value in ipairs(Yipper.DB.Keywords) do
            -- Account for the value being nil or an empty string.
            -- If we have a match otherwise, set the flag to true and break the loop.
            if value ~= nil and value ~= "" and string.find(message, value, 1, true) then
                shouldNotify = true
                break  -- No need to check more keywords
            end
        end
    end

    -- Play the notification sound if we have to.
    -- And also highlight the taskbar icon briefly.
    if shouldNotify then
        PlaySound(Yipper.DB.NotificationSound)
        FlashClientIcon(true)
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

--- Yipper.Utils - ReplaceSensitiveWithColor
--
-- Helper function for case-sensitive replace of the specified string.
--
-- str: The string to perform the replacement on.
-- find: The value we're looking for, case-sensitive
-- colorStart: The color starting tag to apply to the replaced value.
-- colorEnd: The color ending tag to apply the replaced value.
function Yipper.Utils:ReplaceSensitiveWithColor(str, find, colorStart, colorEnd)
    -- Escape special pattern characters
    local findEscaped = string.gsub(find, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

    -- Replace while preserving the original matched case
    return string.gsub(str, findEscaped, function(matched)
        return colorStart .. matched .. colorEnd
    end)
end

-- Yipper.Utils - GetNormalizedRealmName
--
-- Returns the normalized Realm name using the standard GetRealmName()
-- and applying the correct cleanup logic, since we cannot rely on Blizzard's
-- API to always return a value.
function Yipper.Utils:GetNormalizedRealmName()
    local realmName = GetRealmName()

    return realmName:gsub("[%s%.%-]", "")
end
