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

    if string.find(message, playerName) then
        local color = Yipper.DB.NotificationColor or Yipper.Constants.NotificationColor
        local tagStart = "\124cFF"
        local tagEnd = "\124r"

        -- Values are stored as 0 - 1 range, so multiply by 255 first for proper decimal
        -- to hex conversions using core lua.
        local colorCode = string.format("%02X", (color.r * 255)) ..
                          string.format("%02X", (color.g * 255)) ..
                          string.format("%02X", (color.b * 255))
        local coloredPlayerName = tagStart .. colorCode .. UnitName("player") .. tagEnd

        return string.gsub(message, playerName, coloredPlayerName)
    end

    return message
end

-- Yipper.Utils - ColorizeMessage
--
-- Plays the configured notification sound when the message contains the player's name.
-- TODO: Expand to include the TRP3 Profile at some point.
function Yipper.Utils:PlayNotification(message)
    local playerName = UnitName("player")

    if string.find(message, playerName) and Yipper.DB.NotificationSound then
        PlaySound(Yipper.DB.NotificationSound);
    end
end
