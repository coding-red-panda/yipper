--[[
    This defines all the constants that Yipper needs access to.
    To ensure that we do not pollute other AddOns, or others pollute
    our AddOn, we will isolate our constants to a namespace.
]]--
Yipper.Constants = { }
Yipper.Constants.MaxMessage = 50

-- The message events we care about
Yipper.Constants.MessageEvents = {
    -- Standard Chat
    "CHAT_MSG_SAY",
    "CHAT_MSG_EMOTE",
    "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_YELL",
    -- Whispers
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    -- Party Chat
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    -- Raid Chat
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    -- Guild Chat
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    -- Channels
    -- "CHAT_MSG_CHANNEL", -- We don't care about trade/service channel spam really.
    -- "CHAT_MSG_CHANNEL_JOIN", -- triggered when someone joins a channel we're in, not important for now.
    -- "CHAT_MSG_CHANNEL_LEAVE", -- triggered when someone leaves a channel we're in, not important for now.
    -- Instance Chat
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    -- Communities Chat
    "CHAT_MSG_COMMUNITIES_CHANNEL"
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