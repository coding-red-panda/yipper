-- Yipper - Data Module
--
-- Defines the Database constant for Yipper where all important data is being tracked/stored.
-- Also tracks the default values we rely on when something isn't initialized or configured.
local _, addonTable = ...

-- Define the default values for Yipper.
-- These will be used as fallback when something is missing to avoid errors.
addonTable.DefaultData = {
    MaxMessages = 50,

    -- Backdrop Info
    --
    -- Used by our frames for a consistent look and feel.
    BackdropInfo = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1
    }
}

-- Defines the Database table that we'll use as a dynamic database for storing all the data.
-- Yipper will call this with direct reference to update, read or delete data as needed.
-- Structure:
--[[
    [max_messages] = { -- previous message history
        id = line identifier
        t = timestamp the message was received
        e = event type
        m = message
        r = message has been read or not
        s = sender
    }
]]--
addonTable.Database = { }

-- Track the last activity of the user, defaults to the current timestamp.
addonTable.LastActivity = time()
addonTable.TrackedPlayer = nil
