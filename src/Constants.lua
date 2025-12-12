--[[
    This defines all the constants that Yipper needs access to.
    To ensure that we do not pollute other AddOns, or others pollute
    our AddOn, we will isolate our constants to a namespace.
]]--
Yipper.LastActivity = time()
Yipper.Constants = { }
Yipper.Constants.MaxMessage = 50

-- The message events we care about
-- Stored as eventName - Function
Yipper.Constants.MessageEvents = {
    -- Standard Chat
    ["CHAT_MSG_SAY"] = "OnChatMessage",
    ["CHAT_MSG_EMOTE"] = "OnCustomEmoteMessage",
    ["CHAT_MSG_TEXT_EMOTE"] = "OnEmoteMessage",
    ["CHAT_MSG_YELL"] = "OnYellMessage",
    -- Whispers
    ["CHAT_MSG_WHISPER"] = "OnReceiveWhisper",
    ["CHAT_MSG_WHISPER_INFORM"] = "OnSendWhisper",
    -- Party Chat
    ["CHAT_MSG_PARTY"] = "OnPartyMessage",
    ["CHAT_MSG_PARTY_LEADER"] = "OnPartyLeaderMessage",
    -- Raid Chat
    ["CHAT_MSG_RAID"] = "OnRaidMessage",
    ["CHAT_MSG_RAID_LEADER"] = "OnRaidLeaderMessage",
    ["CHAT_MSG_RAID_WARNING"] = "OnRaidWarningMessage",
    -- Guild Chat
    ["CHAT_MSG_GUILD"] = "OnGuildMessage",
    ["CHAT_MSG_OFFICER"] = "OnOfficerMessage"
    -- Channels
    -- "CHAT_MSG_CHANNEL", -- We don't care about trade/service channel spam really.
    -- "CHAT_MSG_CHANNEL_JOIN", -- triggered when someone joins a channel we're in, not important for now.
    -- "CHAT_MSG_CHANNEL_LEAVE", -- triggered when someone leaves a channel we're in, not important for now.
    -- Instance Chat
    -- "CHAT_MSG_INSTANCE_CHAT", -- Triggered when instance chat messages happen
    -- "CHAT_MSG_INSTANCE_CHAT_LEADER", -- Triggered when instance leader messages happen
    -- Communities Chat
    -- "CHAT_MSG_COMMUNITIES_CHANNEL" -- Triggered when community message happens
}

--[[
 Used for storing all the messages, per player.
 The following layout will be used:
    [max_messages] = { -- previous message history
        id = line identifier
        t = timestamp the message was received
        e = event type
        m = message
        r = message has been read or not
        s = sender
    }
]]--
Yipper.Database = {}