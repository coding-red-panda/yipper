local addonName, Yipper = ...

Yipper.Chat = {}

--- Initialises the Chat module and registers the required events
function Yipper.Chat:Init()
    print("Yipper Chat Init")
    
    Yipper.mainFrame:RegisterEvent("CHAT_MSG_EMOTE")
    Yipper.mainFrame:RegisterEvent("CHAT_MSG_GUILD")
    Yipper.mainFrame:RegisterEvent("CHAT_MSG_PARTY")
    Yipper.mainFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
    Yipper.mainFrame:RegisterEvent("CHAT_MSG_RAID")
    Yipper.mainFrame:RegisterEvent("CHAT_MSG_YELL")
end

--- Handles the incoming chat events
-- @param event The name of the event being triggered
-- @param ... The arguments passed down with the event (message, sender, etc.)
function Yipper.Chat:OnEvent(event, ...)
    local message, sender = ...
    print("Yipper Chat Event: " .. event .. " From: " .. (sender or "Unknown") .. " Msg: " .. (message or ""))
    -- Future logic to process the message will go here
end
