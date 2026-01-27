-- Yipper - Constants
--
-- This file is responsible for defining constants that are used across multiple
-- files in the Addon. It should be loaded first.

local addonName, Yipper = ...

Yipper.Constants = {}

-- Define the list of chat events we want to listen to
Yipper.Constants.ChatEvents = {
    "CHAT_MSG_EMOTE",           -- custom emotes
    "CHAT_MSG_TEXT_EMOTE",      -- command emotes like /dance
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
    "CHAT_MSG_SYSTEM"
}

Yipper.Constants.ChatColors = {
    ["CHAT_MSG_EMOTE"] = { ["r"] = 255, ["g"] = 128, ["b"] = 64 },
    ["CHAT_MSG_TEXT_EMOTE"] = { ["r"] = 255, ["g"] = 128, ["b"] = 64 },
    ["CHAT_MSG_GUILD"] = { ["r"] = 64, ["g"] = 255, ["b"] = 64 },
    ["CHAT_MSG_OFFICER"] = { ["r"] = 64, ["g"] = 192, ["b"] = 64 },
    ["CHAT_MSG_PARTY"] = { ["r"] = 170, ["g"] = 170, ["b"] = 255 },
    ["CHAT_MSG_PARTY_LEADER"] = { ["r"] = 118, ["g"] = 200, ["b"] = 255 },
    ["CHAT_MSG_RAID"] = { ["r"] = 255, ["g"] = 127, ["b"] = 0 },
    ["CHAT_MSG_RAID_LEADER"] = { ["r"] = 255, ["g"] = 72, ["b"] = 9 },
    ["CHAT_MSG_RAID_WARNING"] = { ["r"] = 255, ["g"] = 72, ["b"] = 0 },
    ["CHAT_MSG_YELL"] = { ["r"] = 255, ["g"] = 64, ["b"] = 64 },
    ["CHAT_MSG_SAY"] = { ["r"] = 255, ["g"] = 255, ["b"] = 255 },
    ["CHAT_MSG_WHISPER"] = { ["r"] = 255, ["g"] = 128, ["b"] = 255 },
    ["CHAT_MSG_SYSTEM"] = { ["r"] = 255, ["g"] = 255, ["b"] = 0 }
}

Yipper.Constants.BlackColor = { ["r"] = 0, ["g"] = 0, ["b"] = 0 }
Yipper.Constants.Alpha = 100
