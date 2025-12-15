-- Yipper - UI
--
-- This section defines everything related to the UI of the AddOn and is responsible for defining
-- the functions needed to build and handle the UI as well as the event-handling to react on the correct
-- situations.
local _, addonTable = ...
local UI = { }
addonTable.UI = UI

-- Init
--
-- Takes the parent Frame that wraps the entire AddOn and builds the required UI components.
-- Once the UI components have been initialized, the respective events and handlers will be
-- registered on each component to control the behavior of the AddOn.
function UI:Init(parentFrame)
    self.parentFrame = parentFrame -- track the reference to the parentFrame.

    self:ConfigureParentFrame()
    self:AddResizeHandler()
    self:AddCloseButton()
    self:AddPlayerTracking()
    self:RegisterEvents()
end

-- Configures the parent frame, ensuring the required properties and event handlers
-- are registered for the AddOn.
function UI:ConfigureParentFrame()
    self.parentFrame:SetSize(200, 400) -- TODO: Load/Store to database
    self.parentFrame:SetPoint("CENTER")
    self.parentFrame:SetBackdrop(Yipper.DefaultData.BackdropInfo)
    self.parentFrame:SetBackdropBorderColor(1, 1, 1, 1) -- white, 100% alpha
    self.parentFrame:SetBackdropColor(0, 0, 0, 1) -- black, 100% alpha
    self.parentFrame:EnableMouse(true)
    self.parentFrame:SetMovable(true)
    self.parentFrame:SetResizable(true)
    self.parentFrame:RegisterForDrag("LeftButton")

    -- Register the required events to allow the parent frame to be moved.
    self.parentFrame:SetScript("OnDragStart", self.parentFrame.StartMoving)
    self.parentFrame:SetScript("OnDragStop", self.parentFrame.StopMovingOrSizing)
    self.parentFrame:SetScript("OnHide", self.parentFrame.StopMovingOrSizing)
end

-- Builds and configure the resize handler for the parent frame,
-- allowing the user to resize the window to the desired size.
function UI:AddResizeHandler()
    local handle = CreateFrame("Button", nil, self.parentFrame)

    handle:EnableMouse(true)
    handle:SetPoint("BOTTOMRIGHT")
    handle:SetSize(16, 16)
    handle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    handle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    handle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

    -- Set the required behavior for when the mouse is pressed/released on our handle,
    -- triggering or stopping the resize behavior of the parent.
    -- Function takes caller as argument, which is the self, or the button in this case.
    -- TODO: Add logic for storing position and size when resizing ends
    handle:SetScript("OnMouseDown", function(self) self:GetParent():StartSizing("BOTTOMRIGHT") end)
    handle:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing("BOTTOMRIGHT") end)
end

-- Builds and configure the close button for the parent frame,
-- allowing the user to close the window when it is no longer required.
function UI:AddCloseButton()
    self.closeButton = CreateFrame("Button", "YipperCloseButton", self.parentFrame, "UIPanelCloseButton")

    self.closeButton:SetPoint("TOPRIGHT", self.parentFrame, "TOPRIGHT")
    self.closeButton:SetSize(16, 16) -- TODO: Load/Store in database.

    -- Set the required behavior for when the button is clicked,
    -- closing the parent frame. Function takes caller as argument,
    -- which is the self, or the button in this case.
    self.closeButton:SetScript("OnClick", function(self) self:GetParent():Hide()  end)
end

-- Builds and configure the player tracking frame to display who's messages are
-- currently being displayed by the AddOn.
function UI:AddPlayerTracking()
    self.playerFrame = CreateFrame("Frame", "YipperPlayerTracking", self.parentFrame, BackdropTemplateMixin and "BackdropTemplate")

    self.playerFrame:SetSize(self.parentFrame:GetWidth() - self.closeButton:GetWidth() - 1, self.closeButton:GetHeight() - 1)
    self.playerFrame:SetPoint("TOPLEFT", 1, -1)
    self.playerFrame:SetBackdrop(Yipper.DefaultData.BackdropInfo)
    self.playerFrame:SetBackdropColor(0,0,0,1)
    self.playerFrame:SetBackdropBorderColor(0,0,0,0) -- No Border

    self.playerFrame.text = self.playerFrame:CreateFontString("YipperTrackedPlayer", "ARTWORK", "ChatFontNormal")
    self.playerFrame.text:SetPoint("TOPLEFT", 5, -5) -- Position the header text within the frame
    self.playerFrame.text:SetTextColor(1, 1, 1, 1) -- Set the text color
    self.playerFrame.text:SetTextHeight(12)
end

-- Registers all important events that the AddOn cares about and adds the global
-- event handler to the parentFrame to process events.
function UI:RegisterEvents()
    self.parentFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.parentFrame:RegisterEvent("CHAT_MSG_SAY")
    self.parentFrame:RegisterEvent("CHAT_MSG_EMOTE")
    self.parentFrame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
    self.parentFrame:RegisterEvent("CHAT_MSG_YELL")
    self.parentFrame:RegisterEvent("CHAT_MSG_WHISPER")
    self.parentFrame:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
    self.parentFrame:RegisterEvent("CHAT_MSG_PARTY")
    self.parentFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
    self.parentFrame:RegisterEvent("CHAT_MSG_RAID")
    self.parentFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
    self.parentFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
    self.parentFrame:RegisterEvent("CHAT_MSG_GUILD")
    self.parentFrame:RegisterEvent("CHAT_MSG_OFFICER")

    -- Register the event handler responsible for dealing with all events.
    self.parentFrame:SetScript("OnEvent", Yipper.Events.OnEvent)
end
