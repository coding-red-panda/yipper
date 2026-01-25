-- Yipper - Minimap Button
--
-- This file is responsible for creating and managing the minimap button.
-- The minimap button has two functions:
--      1. Toggling the main window when clicked
--      2. Toggling the settings window when clicked
--
local addonName, Yipper = ...

-- Initialize the Minimap table
Yipper.Minimap = {}

-- Yipper.Minimap - Init
--
--- Initializes the plugin for the AddOn,
--- constructing the button and attaching it to the minimap
--- as well as registering the mouse behavior
function Yipper.Minimap:Init()
    -- Button Frame
    local button = CreateFrame("Button", "YipperButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("HIGH")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    button:SetPoint("CENTER", 0, 0)
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton", "RightButton");
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp");

    -- Button Texture
    button.texture = button:CreateTexture(nil, "ARTWORK");
    button.texture:SetSize(20, 20)
    button.texture:SetPoint("TOPLEFT", 7, -6)
    button.texture:SetTexture("Interface\\Icons\\ability_racial_nosefortrouble")

    -- Button Overlay (Border)
    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    -- Button Background
    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", 7, -5)

    -- Mask it to have a circular shape
    button.mask = button:CreateMaskTexture()
    button.mask:SetAllPoints(button.texture)
    button.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    button.texture:AddMaskTexture(button.mask)

    -- Button Configuration
    local position = Yipper.DB.MinimapButtonAngle or 180

    button.update = function(self)
        local angle = math.rad(position)
        local x, y = math.cos(angle), math.sin(angle)
        local width = (Minimap:GetWidth() * 0.53)
        local height = (Minimap:GetHeight() * 0.53)

        -- Calculate dimensions
        x, y = x * width, y * height;

        -- Update our point
        self:SetPoint("CENTER", "Minimap", "CENTER", math.floor(x), math.floor(y));
    end

    -- Define the update function to assign to the button for calculating the
    -- the position based on the mouse cursor during drag of the button.
    -- Uses basic math to calculate the angle from the Minimap center.
    local update = function(self)
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()

        -- Store the position to persist on reload
        position = math.deg(math.atan2((py / scale) - my, (px / scale) - mx)) % 360
        Yipper.DB.MinimapButtonAngle = position

        self:Raise()
        self:update()
    end

    -- Register the Frame events
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", update)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:SetText("Yipper");
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function(self, mouseButton, down)
        Yipper.Minimap:OnMouseClick(mouseButton)
    end)
    button:SetScript("OnEvent", button.update)
    button:RegisterEvent("LOADING_SCREEN_DISABLED")

    -- Calculate the position and show the button.
    button:update()
    button:Show()

    -- Store the reference
    Yipper.Minimap.frame = button
end

-- Yipper.Minimap - OnMouseClick
--
-- Registered as event-handler for the OnClick event of the minimap button.
-- When the user uses the left mouse button, we toggle the main window.
-- When the user uses the right mouse button, we toggle the settings window.
function Yipper.Minimap:OnMouseClick(button)
    if button == "RightButton" then
        -- TODO: Open the Settings Menu
    else
        if Yipper.mainFrame:IsShown() then
            Yipper.mainFrame:Hide()
        else
            Yipper.mainFrame:Show()
        end
    end
end
