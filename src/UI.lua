-- Yipper - UI
--
-- This file is responsible for registering the entire UI of Yipper.
-- The code will build up the required interface for the main window
-- and make sure it can be displayed.
local addonName, Yipper = ...
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
    print("Yipper UI Init")

    -- Apply the required Mixin to our frame so we have access to the
    -- needed functions.
    Mixin(Yipper.mainFrame, BackdropTemplateMixin)

    -- Configure the frame
    Yipper.mainFrame:SetSize(200, 150)
    Yipper.mainFrame:SetBackdrop(backdropConfiguration)
    Yipper.mainFrame:SetBackdropColor(0, 0, 0)
    Yipper.mainFrame:SetBackdropBorderColor(0.4, 0.4, 0.4)

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

    -- Make it resizable
    Yipper.mainFrame:SetResizable(true)
    Yipper.mainFrame:SetResizeBounds(200, 150, 800, 600)  -- minWidth, minHeight, maxWidth, maxHeight

    -- Create close button (top-right corner)
    local closeButton = CreateFrame("Button", nil, Yipper.mainFrame, "UIPanelCloseButton")

    closeButton:SetPoint("TOPRIGHT", Yipper.mainFrame, "TOPRIGHT", -2, -2)
    closeButton:SetSize(20, 20)
    closeButton:SetScript("OnClick", function()
        Yipper.mainFrame:Hide()
    end)

    -- Create scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, Yipper.mainFrame, "UIPanelScrollFrameTemplate")

    scrollFrame:SetPoint("TOPLEFT", Yipper.mainFrame, "TOPLEFT", 0, -22)  -- Leave space for close button
    scrollFrame:SetPoint("BOTTOMRIGHT", Yipper.mainFrame, "BOTTOMRIGHT", -23, 20)  -- Leave space for scrollbar and resize grip

    -- Create scroll child (content container)
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)

    scrollChild:SetSize(scrollFrame:GetWidth(), 1)  -- Height will grow with content
    scrollFrame:SetScrollChild(scrollChild)

    -- Make the scrollbar thinner
    local scrollBar = scrollFrame.ScrollBar

    if scrollBar then
        scrollBar:SetWidth(12)  -- Make it thin (default is ~18)
    end

    -- Store references for later use
    Yipper.scrollFrame = scrollFrame
    Yipper.scrollChild = scrollChild

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
    resizeButton:SetScript("OnDragStart", function(self)
        Yipper.mainFrame:StartSizing("BOTTOMRIGHT")
    end)
    resizeButton:SetScript("OnDragStop", function(self)
        Yipper.mainFrame:StopMovingOrSizing()
        Yipper.UI:SavePosition()  -- Save after resizing
    end)

    -- Restore saved position/size or use defaults
    Yipper.UI:RestorePosition()

    -- Make the frame visible for now
    Yipper.mainFrame:Show()
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
    else
        -- Use default position and size
        Yipper.mainFrame:SetSize(300, 200)
        Yipper.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end
