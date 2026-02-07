-- Yipper - UI
--
-- This file is responsible for registering the entire UI of Yipper.
-- The code will build up the required interface for the main window
-- and make sure it can be displayed.
local _, Yipper = ...
local backdropConfiguration = {
    bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
    edgeSize = 16,
    insets = { left = 4, right = 3, top = 4, bottom = 3 }
}

-- Initialize the Yipper.UI module before defining the functions
Yipper.UI = { }

-- Constructs the mainframe using the mainFrame already registered in Yipper.
-- Requires Yipper to be initialized so the calling code does not trigger any
-- errors.
function Yipper.UI:Init()
    -- Apply the required Mixin to our frame so we have access to the
    -- needed functions.
    Mixin(Yipper.mainFrame, BackdropTemplateMixin)

    local backgroundColor = Yipper.DB.BackgroundColor or Yipper.Constants.BlackColor
    local borderColor = Yipper.DB.BorderColor or Yipper.Constants.BlackColor
    local alpha = Yipper.DB.WindowAlpha or Yipper.Constants.Alpha

    -- Configure the frame
    Yipper.mainFrame:SetSize(200, 150)
    Yipper.mainFrame:SetBackdrop(backdropConfiguration)
    Yipper.mainFrame:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, alpha / 100)
    Yipper.mainFrame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, alpha / 100)

    -- Add behavior to our frame
    -- Make it movable
    Yipper.mainFrame:SetMovable(true)
    Yipper.mainFrame:EnableMouse(true)
    Yipper.mainFrame:RegisterForDrag("LeftButton")
    Yipper.mainFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    Yipper.mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Yipper.UI:SavePosition()  -- Save after moving
    end)
    Yipper.mainFrame:SetScript("OnShow", function()
        Yipper.DB.ShowWindow = true
        Yipper.UI:UpdateDisplayedText()
    end)

    -- Make it resizable
    Yipper.mainFrame:SetResizable(true)
    Yipper.mainFrame:SetResizeBounds(200, 150, 800, 600)  -- minWidth, minHeight, maxWidth, maxHeight

    -- Create close button (top-right corner)
    local closeButton = CreateFrame("Button", nil, Yipper.mainFrame, "UIPanelCloseButton")

    closeButton:SetPoint("TOPRIGHT", Yipper.mainFrame, "TOPRIGHT", -2, -2)
    closeButton:SetSize(20, 20)
    closeButton:SetScript("OnClick", function()
        Yipper.mainFrame:Hide()
        Yipper.DB.ShowWindow = false
    end)

    -- Hide the closeButton when not used
    if not Yipper.DB.ShowHeader then
        closeButton:Hide()
    end

    -- Header (tracks Yipper.TrackedPlayer)
    local headerHeight = 30
    local headerRightInset = 45 -- keeps text clear of close button and the scrollbar gutter

    local headerFrame = CreateFrame("Frame", nil, Yipper.mainFrame)
    headerFrame:SetHeight(headerHeight)
    headerFrame:SetPoint("TOPLEFT", Yipper.mainFrame, "TOPLEFT", 6, -4)
    headerFrame:SetPoint("TOPRIGHT", Yipper.mainFrame, "TOPRIGHT", -headerRightInset, -4)

    local headerText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerText:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 0, 0)
    headerText:SetPoint("BOTTOMRIGHT", headerFrame, "BOTTOMRIGHT", 0, 0)
    headerText:SetJustifyH("LEFT")
    headerText:SetJustifyV("MIDDLE")

    headerFrame:SetScript("OnShow", function()
        Yipper.UI:UpdateHeaderText()
    end)
    headerFrame:SetScript("OnUpdate", function()
        Yipper.UI:UpdateHeaderText()
    end)

    -- Hide the headerFrame if the option is disabled
    if not Yipper.DB.ShowHeader then
        headerFrame:Hide()
    end

    -- Create scroll frame
    local messageFrame = CreateFrame("ScrollingMessageFrame", nil, Yipper.mainFrame)

    Mixin(messageFrame, BackdropTemplateMixin)

    messageFrame:SetPoint("TOPLEFT", Yipper.mainFrame, "TOPLEFT", 10, -(headerHeight + 10))     -- below header
    messageFrame:SetPoint("BOTTOMRIGHT", Yipper.mainFrame, "BOTTOMRIGHT", -10, 24)              -- above resize grip area
    messageFrame:SetFont(Yipper.Constants.Fonts.FrizQuadrata, Yipper.DB.FontSize or Yipper.Constants.FontSize, "")
    messageFrame:SetJustifyH("LEFT")
    messageFrame:SetInsertMode("BOTTOM")
    messageFrame:SetFading(false)
    messageFrame:SetMaxLines(Yipper.DB.MaxMessages)
    messageFrame:SetHyperlinksEnabled(true) -- Allow links

    -- Assume the user is at the bottom by default
    messageFrame.isAtBottom = true

    -- Enable Scroll behavior with the mouse wheel
    messageFrame:EnableMouseWheel(true)
    messageFrame:SetScript("OnMouseWheel", function(self, delta)

        if delta > 0 then
            self:ScrollUp()
            self.isAtBottom = false -- User scrolled up, so we're not at the bottom.
        else
            self:ScrollDown()
            self.isAtBottom = self:AtBottom() -- Let the frame determine if we're at the bottom
        end
    end)

    messageFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
    messageFrame:SetBackdropColor(0, 0, 0, 0)
    messageFrame:Show()

    -- Store references for later use
    Yipper.messageFrame = messageFrame
    Yipper.headerFrame = headerFrame
    Yipper.headerText = headerText
    Yipper.closeButton = closeButton

    -- Create resize button (bottom-right corner)
    local resizeButton = CreateFrame("Button", nil, Yipper.mainFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", Yipper.mainFrame, "BOTTOMRIGHT", -2, 2)
    resizeButton:EnableMouse(true)
    resizeButton:RegisterForDrag("LeftButton")

    -- Visual indicator for resize handle
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetScript("OnDragStart", function()
        Yipper.mainFrame:StartSizing("BOTTOMRIGHT")
    end)
    resizeButton:SetScript("OnDragStop", function()
        Yipper.mainFrame:StopMovingOrSizing()
        Yipper.UI:SavePosition()  -- Save after resizing
    end)

    -- define a custom toggle function to easily toggle the frame.
    Yipper.mainFrame.Toggle = function(self)
        if self:IsShown() then
            self:Hide()
        else
            self:Show()
        end
    end

    -- Restore saved position/size or use defaults
    Yipper.UI:RestorePosition()

    -- Show the window if the window was previously shown
    if Yipper.DB.ShowWindow then
        Yipper.mainFrame:Show()
    else
        Yipper.mainFrame:Hide()
    end
end

-- Yipper.UI - SavePosition
--
-- Stores the reference point of the mainFrame, as well as its dimensions
-- inside the Yipper.DB so the game can save these values on exit.
function Yipper.UI:SavePosition()
    local point, _, relativePoint, xOfs, yOfs = Yipper.mainFrame:GetPoint()
    local width, height = Yipper.mainFrame:GetSize()

    Yipper.DB.framePosition = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
        width = width,
        height = height
    }
end

-- Yipper.UI - RestorePosition
--
-- Loads the relative point of the mainFrame, as well as its dimensions
-- from the Yipper.DB and applies them to the mainFrame when loaded.
function Yipper.UI:RestorePosition()
    local pos = Yipper.DB.framePosition

    if pos then
        -- Restore saved position and size
        Yipper.mainFrame:ClearAllPoints()
        Yipper.mainFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        Yipper.mainFrame:SetSize(pos.width, pos.height)

        -- Show the window if the window was previously shown
        if Yipper.DB.ShowWindow then
            Yipper.mainFrame:Show()
        else
            Yipper.mainFrame:Hide()
        end
    else
        -- Use default position and size
        Yipper.mainFrame:SetSize(300, 200)
        Yipper.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        Yipper.mainFrame:Show()
        Yipper.DB.ShowWindow = true
    end
end

-- Updates the text display of the header frame
-- Trigger on update and uses the value of the `TrackedPlayer` field.
function Yipper.UI:UpdateHeaderText()
    local tracked = Yipper.TrackedPlayer

    if tracked and tracked ~= "" then
        Yipper.headerText:SetText("Tracking: " .. tracked)
    else
        Yipper.headerText:SetText("Tracking: (none)")
    end
end

-- Updates the displayed text in the mainFrame,
-- using the data stored in the AddOn.
function Yipper.UI:UpdateDisplayedText()
    -- Return if there's no player tracked,
    -- or there's no messages for the player
    if Yipper.TrackedPlayer == nil or   -- No player tracked
        Yipper.DB.Messages == nil or    -- new character, no messages yet initializes
        Yipper.DB.Messages[Yipper.TrackedPlayer] == nil then -- Player has not produced messages
        return
    end

    -- Clear messages first
    Yipper.messageFrame:Clear()

    -- We have a tracked player, display their messages
    for _, messageData in pairs(Yipper.DB.Messages[Yipper.TrackedPlayer]) do
        local colorCodes = Yipper.Constants.ChatColors[messageData.event]
        local message = messageData.message

        -- Safety check, we might have corrupt data in the table
        -- Will resolve over time as table clears out, but don't want to crash users.
        if colorCodes then
            -- In case of an emote, we need to inject the player's name before the emote
            -- to make it make sense.
            -- Use Regex, to strip out the Realm name (After the last -)
            if messageData.event == "CHAT_MSG_EMOTE" then
                local player = Yipper.TrackedPlayer:match("^(.*)%-.+$")
                message = player .. " " .. messageData.message
            end

            local colorizedMessage = Yipper.Utils:ColorizeMessage(messageData.message)

            -- Add the message with the correct color codes.
            -- The method needs values between 0 - 1, so divide the values by 255.
            Yipper.messageFrame:AddMessage(
                colorizedMessage,
                colorCodes.r / 255,
                colorCodes.g / 255,
                colorCodes.b / 255,
                messageData.lineId
            )
        end
    end
end
