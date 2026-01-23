-- Yipper - Constants
--
-- This file is responsible for defining constants that are used across multiple
-- files in the Addon. It should be loaded first.

local addonName, Yipper = ...

Yipper.Constants = {}

-- Define the list of chat events we want to listen to
Yipper.Constants.ChatEvents = {
    "CHAT_MSG_EMOTE",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_YELL",
    "CHAT_MSG_SAY",
    "CHAT_MSG_WHISPER"
}
