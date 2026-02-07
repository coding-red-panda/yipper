-- Yipper - Constants
--
-- This file is responsible for defining constants that are used across multiple
-- files in the Addon. It should be loaded first.

local addonName, Yipper = ...

Yipper.Constants = {}

-- Track our version in case we need to do something breaking
Yipper.Constants.VERSION = "1.5.1"

-- Define the list of chat events we want to listen to
Yipper.Constants.ChatEvents = {
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
    "LOADING_SCREEN_ENABLED",
    "LOADING_SCREEN_DISABLED"
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

Yipper.Constants.Fonts = {
    ["TypeWriter"] = "Interface\\AddOns\\Yipper\\Fonts\\atwriter.ttf",
    ["BlueWinter"] = "Interface\\AddOns\\Yipper\\Fonts\\Blue Winter.ttf",
    ["FrizQuadrata"] = "Interface\\AddOns\\Yipper\\Fonts\\Friz Quadrata Regular.ttf",
    ["Morpheus"] = "Interface\\AddOns\\Yipper\\Fonts\\MORPHEUS.ttf"
}

Yipper.Constants.Sounds = {
    ["TellMessage"] = { ["id"] = 3081, ["name"] = "Tell Message" },
    ["MapPing"] = { ["id"] = 3175, ["name"] = "Map Ping" },
    ["TutorialPopUp"] = { ["id"] = 7355, ["name"] = "Tutorial Popup" },
    ["KeyringOpen"] = { ["id"] = 8938, ["name"] = "Keyring Open" },
    ["KeyringClose"] = { ["id"] = 8939, ["name"] = "Keyring Close" },
    ["AlarmTwo"] = { ["id"] = 12867, ["name"] = "Alarm 2" },
    ["AlarmThree"] = { ["id"] = 12889, ["name"] = "Alarm 3" },
    ["SilithidAggro"] = { ["id"] = 719, ["name"] = "Silithid Wasp Aggro" },
    ["SuccubusStand"] = { ["id"] = 1121, ["name"] = "Succubus Stand" }
}

Yipper.Constants.BlackColor = { ["r"] = 0, ["g"] = 0, ["b"] = 0 }
Yipper.Constants.NotificationColor = { ["r"] = 1, ["g"] = 0, ["b"] = 0 }
Yipper.Constants.Alpha = 100
Yipper.Constants.FontSize = 12
Yipper.Constants.CommsChannel = "YipperComms"
