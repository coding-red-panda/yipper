print("Yipper successfully loaded!")

-- Global Components
local backdropInfo = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1
}
--
-- Create the Frame for Yipper so we can listen to events and display stuff
--
local frame = CreateFrame("Frame", "Yipper", ParentUI,  BackdropTemplateMixin and "BackdropTemplate")
frame:SetSize(200, 400)
frame:SetPoint("CENTER")
frame:SetBackdrop(backdropInfo)
frame:SetBackdropColor(0,0,0,1) -- Black background
frame:SetBackdropBorderColor(1,1,1,1) -- White border
frame:RegisterForDrag("LeftButton")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetResizable(true)

--
-- Resizing Capabilities
--
-- We want the Window to be resizeable, so configure the frame to allow it to be
-- resized by the user. We'll define a minimum and maximum size so nothing too crazy
-- can be applied.
-- To not interfere with general events, we'll add a resize button at the bottom right of
-- frame that the user can use to resize the window.
local resizeHandle = CreateFrame("Button", nil, frame)
resizeHandle:EnableMouse(true)
resizeHandle:SetPoint("BOTTOMRIGHT")
resizeHandle:SetSize(16, 16)
resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeHandle:SetScript("OnMouseDown", function(self) self:GetParent():StartSizing("BOTTOMRIGHT") end)
resizeHandle:SetScript("OnMouseUp", function() frame:StopMovingOrSizing("BOTTOMRIGHT") end)

-- Close Button
--
-- We want the user to also hide the frame when it's no longer needed.
-- So add a small close button to the top right corner with the functionality
-- to hide our main window.
local closeButton = CreateFrame("Button", "YipperCloseButton", frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
closeButton:SetScript("OnClick", function() frame:Hide()  end)

-- Player Tracking
--
-- We want to properly display which player is currently being tracked.
-- For this we need to have a display bar on the top of the frame that shows
-- the currently tracked player and their messages.
local playerFrame = CreateFrame("Frame", "YipperPlayerTracking", frame, BackdropTemplateMixin and "BackdropTemplate")
playerFrame:SetSize(frame:GetWidth() - closeButton:GetWidth() - 1, closeButton:GetHeight() - 1)
playerFrame:SetPoint("TOPLEFT", 1, -1)
playerFrame:SetBackdrop(backdropInfo)
playerFrame:SetBackdropColor(0,0,0,1)
playerFrame:SetBackdropBorderColor(0,0,0,0) -- No Border
playerFrame.text = playerFrame:CreateFontString("YipperTrackedPlayer", "ARTWORK", "ChatFontNormal")
playerFrame.text:SetPoint("TOPLEFT", 5, -5) -- Position the header text within the frame
playerFrame.text:SetTextColor(1, 1, 1, 1) -- Set the text color
playerFrame.text:SetTextHeight(14)

-- Event Handling
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetScript("OnHide", frame.StopMovingOrSizing)

--
-- Define the function to handle the event handling
-- Passes the event through to the correct method, since we only have this
-- event handler registered.
--
function frame:OnEvent(event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        frame:OnTargetChanged()
        return
    end

    if Yipper.Utilities:eventSupported(Yipper.Constants.MessageEvents, event) then
        local handler = self[Yipper.Constants.MessageEvents[event]]

        if handler then
            handler(self, event, ...)
        else
            print("Handler not supported for now")
        end
    end
end

--
-- Handles the PLAYER_TARGET_CHANGED event
--
-- Doesn't need/take arguments, since we just inquire who's currently the target we have
-- focused and track that player instead.
function frame:OnTargetChanged()
    local targetName = UnitName("target")

    if(targetName) and UnitIsPlayer("target") then
        Yipper.TrackedPlayer = targetName
        playerFrame.text:SetText(targetName)
    else
        Yipper.TrackedPlayer = nil
        playerFrame.text:SetText(nil)
    end
end

--
-- Handles the CHAT_MSG_SAY event internally.
-- Takes the entire payload of the event and processes the data.
--
-- The event contains the following payload:
--      - 1. text: The chat message
--      - 2. playerName: The name + realm of the player
--      - 3. languageName: The name of the language used for the message, e.g "Common"
--      - 4. channelName: The channel name with index, e.g "2. Trade - City"
--      - 5. playerName2: The target player name when two users are involved, otherwise same as playerName.
--      - 6. specialFlags: User flags if applicable, e.g "GM", "DND", "AFK"
--      - 7. zoneChannelID: The static number of the zone channel, 1 for General, 2 for Trade
--      - 8. channelIndex: Channel Index, depends on join order of channels
--      - 9. channelBaseName: Channel name without the index number, e.g. "Trade - City"
--      - 10. languageID: Number presenting the languageID: https://wowpedia.fandom.com/wiki/LanguageID
--      - 11. lineID: Unique identifier for the chat message
--      - 12. guid: Sender's unit GUID
--      - 13. bnSenderID: ID of the battle.net friend
--      - 14. isMobile: If sender is using the mobile app.
--      - 15. isSubtitle: ??
--      - 16. hideSenderInLetterBox: Whether to show in CinematicFrame only or not.
--      - 17. supressRaidIcons: Whether target marker expressions should not be rendered.
--
function frame:OnChatMessage(event, ...)
    -- Extract the data we care about
    local msg, playerName, languageName, _, _, _, _, _, _, _, lineId = ...
    local timestamp = time()
    local player, realm = Yipper.Utilities:getPlayerAndRealm(playerName)

    -- Ensure a table record exists for the player
    if not Yipper.Database[playerName] then
        Yipper.Database[playerName] = {}
    end

    -- Store the data in the database.
    table.insert(Yipper.Database[playerName], {
        ["id"] = lineId,
        ["timestamp"] = timestamp,
        ["eventType"] = event,
        ["message"] = msg,
        ["read"] = timestamp < Yipper.LastActivity,
        ["sender"] = player,
        ["realm"] = realm
    })

    for k,v in pairs(Yipper.Database[playerName]) do
        print("key: " .. k)
        print("value: " .. Yipper.Utilities:dump(v))
    end
end

--
-- Register all events that we are interested in
--
for eventName, _ in pairs(Yipper.Constants.MessageEvents) do
    frame:RegisterEvent(eventName);
end
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:SetScript("OnEvent", frame.OnEvent)