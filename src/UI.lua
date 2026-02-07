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

    --------------------------------------------------------------------------------------------------------------------
    -- Header Frame
    --
    -- Tracks Yipper.TrackedPlayer
    --------------------------------------------------------------------------------------------------------------------
    Yipper.headerFrame = CreateFrame("Frame", nil, Yipper.mainFrame)

    -- Give it a background color
    Yipper.headerBg = Yipper.headerFrame:CreateTexture(nil, "BACKGROUND")
    Yipper.headerBg:SetAllPoints(Yipper.headerFrame)
    Yipper.headerBg:SetColorTexture(0.16, 0.52, 0.92, 0.5) -- #2A84EB with 50% Alpha

    -- Set the points of the Frame.
    Yipper.headerFrame:SetPoint("TOPLEFT", Yipper.mainFrame, "TOPLEFT", 4, -3)
    Yipper.headerFrame:SetPoint("BOTTOMRIGHT", Yipper.mainFrame, "TOPRIGHT", -4, -30)

    -- Add the header text, this will be used for tracking the player.
    Yipper.headerText = Yipper.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    Yipper.headerText:SetPoint("TOPLEFT", Yipper.headerFrame, "TOPLEFT", 10, 0)
    Yipper.headerText:SetPoint("BOTTOMRIGHT", Yipper.headerFrame, "BOTTOMRIGHT", -30, 0)
    Yipper.headerText:SetJustifyH("LEFT")
    Yipper.headerText:SetJustifyV("MIDDLE")

    -- Set the scripts for the text
    Yipper.headerFrame:SetScript("OnShow", function()
        Yipper.UI:UpdateHeaderText()
    end)
    Yipper.headerFrame:SetScript("OnUpdate", function()
        Yipper.UI:UpdateHeaderText()
    end)

    -- Create close button (top-right corner)
    Yipper.closeButton = CreateFrame("Button", nil, Yipper.headerFrame)
    Yipper.closeButton:SetPoint("TOPRIGHT", Yipper.headerFrame, "TOPRIGHT", -2, -5)
    Yipper.closeButton:SetSize(20, 20)

    -- Add the "X" text to close the button
    local closeText = Yipper.closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeText:SetText("|cffffffff×|r")  -- or use "X" for a regular X
    closeText:SetPoint("CENTER")

    Yipper.closeButton:SetScript("OnClick", function()
        Yipper.mainFrame:Hide()
        Yipper.DB.ShowWindow = false
    end)

    -- Hide the headerFrame if the option is disabled
    if not Yipper.DB.ShowHeader then
        Yipper.headerFrame:Hide()
    end

    -- Create scroll frame
    Yipper.messageFrame = CreateFrame("ScrollingMessageFrame", nil, Yipper.mainFrame)

    Mixin(Yipper.messageFrame, BackdropTemplateMixin)

    Yipper.messageFrame:SetPoint("TOPLEFT", Yipper.mainFrame, "TOPLEFT", 10, -(Yipper.headerFrame:GetHeight() + 10))
    Yipper.messageFrame:SetPoint("BOTTOMRIGHT", Yipper.mainFrame, "BOTTOMRIGHT", -10, 24)
    Yipper.messageFrame:SetFont(Yipper.Constants.Fonts.FrizQuadrata, Yipper.DB.FontSize or Yipper.Constants.FontSize, "")
    Yipper.messageFrame:SetJustifyH("LEFT")
    Yipper.messageFrame:SetInsertMode("BOTTOM")
    Yipper.messageFrame:SetFading(false)
    Yipper.messageFrame:SetMaxLines(Yipper.DB.MaxMessages)
    Yipper.messageFrame:SetHyperlinksEnabled(true) -- Allow links

    -- Assume the user is at the bottom by default
    Yipper.messageFrame.isAtBottom = true

    -- Enable Scroll behavior with the mouse wheel
    Yipper.messageFrame:EnableMouseWheel(true)
    Yipper.messageFrame:SetScript("OnMouseWheel", function(self, delta)

        if delta > 0 then
            self:ScrollUp()
            self.isAtBottom = false -- User scrolled up, so we're not at the bottom.
        else
            self:ScrollDown()
            self.isAtBottom = self:AtBottom() -- Let the frame determine if we're at the bottom
        end
    end)

    Yipper.messageFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
    Yipper.messageFrame:SetBackdropColor(0, 0, 0, 0)
    Yipper.messageFrame:Show()

    -- Create resize button (bottom-right corner)
    Yipper.resizeButton = CreateFrame("Button", nil, Yipper.mainFrame)
    Yipper.resizeButton:SetSize(16, 16)
    Yipper.resizeButton:SetPoint("BOTTOMRIGHT", Yipper.mainFrame, "BOTTOMRIGHT", -2, 2)
    Yipper.resizeButton:EnableMouse(true)
    Yipper.resizeButton:RegisterForDrag("LeftButton")

    -- Visual indicator for resize handle
    Yipper.resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    Yipper.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    Yipper.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    Yipper.resizeButton:SetScript("OnDragStart", function()
        Yipper.mainFrame:StartSizing("BOTTOMRIGHT")
    end)
    Yipper.resizeButton:SetScript("OnDragStop", function()
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
