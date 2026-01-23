local addonName, Yipper = ...

Yipper.Chat = {}

--- Initialises the Chat module and registers the required events
function Yipper.Chat:Init()
    if not Yipper.Constants or not Yipper.Constants.ChatEvents then
        print("Yipper Error: Constants not loaded")
        return
    end

    for _, event in pairs(Yipper.Constants.ChatEvents) do
        Yipper.mainFrame:RegisterEvent(event)
    end
end

--- Handles the incoming chat events
-- @param event The name of the event being triggered
-- @param ... The arguments passed down with the event (message, sender, etc.)
function Yipper.Chat:OnEvent(event, ...)
    local message, sender = ...
    print("Yipper Chat Event: " .. event .. " From: " .. (sender or "Unknown") .. " Msg: " .. (message or ""))
    -- Future logic to process the message will go here
end
