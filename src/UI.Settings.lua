-- Yipper - UI.Settings
--
-- This file controls the settings Window of Yipper.
-- The Settings UI will be registered under the main AddOn
-- but is only invoked through commands from the command line
-- or minimap.
local addonName, Yipper = ...
local backdropConfiguration = {
    bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
    edgeSize = 16,
    insets = { left = 4, right = 3, top = 4, bottom = 3 }
}

-- Initialize the module
Yipper.UI.Settings = { }

-- Initializes the UI.Settings module, constructing the main frame for
-- the module, and registering the desired behavior for the buttons and
-- events.
function Yipper.UI.Settings:Init()
    -- Create the main frame for us to draw all components in.
    local frame = CreateFrame("Frame", nil, UIParent)
    local backgroundColor = Yipper.DB.BackgroundColor or Yipper.Constants.BlackColor
    local borderColor = Yipper.DB.BorderColor or Yipper.Constants.BlackColor
    local alpha = Yipper.DB.WindowAlpha or Yipper.Constants.Alpha

    -- Apply the required Mixin to our frame so we have access to the
    -- needed functions.
    Mixin(frame, BackdropTemplateMixin)

    -- Configure the frame
    frame:SetSize(400, 600)
    frame:SetBackdrop(backdropConfiguration)
    frame:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, alpha / 100)
    frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, alpha / 100)

    -- Add behavior to our frame
    -- Make it movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Yipper.UI.Settings:SavePosition()  -- Save after moving
    end)

    -- Create close button (top-right corner)
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")

    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeButton:SetSize(20, 20)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Header
    local headerHeight = 30
    local headerRightInset = 45 -- keeps text clear of close button and the scrollbar gutter

    local headerFrame = CreateFrame("Frame", nil, frame)
    headerFrame:SetHeight(headerHeight)
    headerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -4)
    headerFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -headerRightInset, -4)

    local headerText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerText:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 0, 0)
    headerText:SetPoint("BOTTOMRIGHT", headerFrame, "BOTTOMRIGHT", 0, 0)
    headerText:SetText(addonName .. " Settings")
    headerText:SetJustifyH("LEFT")
    headerText:SetJustifyV("MIDDLE")

    -- Store the reference
    Yipper.settingsFrame = frame

    -- Offload the creation of settings to specific functions
    -- Keeps our code here manageable
    self:AddMinimapSettings()
    self:AddAlphaSettings()
    self:AddBackgroundColorPicker()
    self:AddBorderColorPicker()

    -- Define a custom toggle function
    Yipper.settingsFrame.Toggle = function(self)
        if self:IsShown() then
            self:Hide()
        else
            self:Show()
        end
    end

    -- Restore saved position/size or use defaults
    self:RestorePosition()

    -- Do not show the settings frame by default
    Yipper.settingsFrame:Hide()
end

-- Yipper.UI - SavePosition
--
-- Stores the reference point of the mainFrame, as well as its dimensions
-- inside the Yipper.DB so the game can save these values on exit.
function Yipper.UI.Settings:SavePosition()
    local point, _, relativePoint, xOfs, yOfs = Yipper.settingsFrame:GetPoint()
    local width, height = Yipper.settingsFrame:GetSize()

    Yipper.DB.SettingsFramePosition = {
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
function Yipper.UI.Settings:RestorePosition()
    local pos = Yipper.DB.SettingsFramePosition

    if pos then
        -- Restore saved position and size
        Yipper.settingsFrame:ClearAllPoints()
        Yipper.settingsFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        Yipper.settingsFrame:SetSize(pos.width, pos.height)
    else
        -- Use default position and size
        Yipper.settingsFrame:SetSize(400, 600)
        Yipper.settingsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

-- Yipper.UI.Settings - AddMinimapSettings
--
-- Responsible for hooking up the UI components to be able to toggle
-- the minimap button of the AddOn. Some users like buttons, some don't.
function Yipper.UI.Settings:AddMinimapSettings()
    local checkbox = CreateFrame("CheckButton", nil, Yipper.settingsFrame, "ChatConfigCheckButtonTemplate")

    checkbox:SetChecked(Yipper.DB.EnableMinimapButton)
    checkbox:SetPoint("TOPLEFT", 30, -35)
    checkbox.Text:SetText("Toggle Minimap Button")
    checkbox.tooltip = "Toggle the visibility of the Yipper Minimap Button"
    checkbox:HookScript("OnClick", function(self)
        Yipper.DB.EnableMinimapButton = self:GetChecked()

        if self:GetChecked() then
            Yipper.Minimap.frame:Show()
        else
            Yipper.Minimap.frame:Hide()
        end
    end)
end

-- Yipper.UI.Settings - AddAlphaSettings
--
-- Responsible for hooking up the UI components to be able to control the
-- alpha levels of the windows to set their transparency.
function Yipper.UI.Settings:AddAlphaSettings()
    local minvalue = 0
    local maxValue = 100
    local stepValue = 1
    local options = Settings.CreateSliderOptions(minvalue, maxValue, stepValue)

    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function(_) return maxValue end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function(_) return minvalue end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Top, function(_) return "Window Alpha" end);

    local slider = CreateFrame("Frame", nil, Yipper.settingsFrame, "MinimalSliderWithSteppersTemplate")

    slider:SetWidth(300)
    slider:SetPoint("TOPLEFT", 30, -70)
    slider:Init(Yipper.DB.WindowAlpha or 100, options.minValue, options.maxValue, options.steps, options.formatters)
    slider:RegisterCallback("OnValueChanged", function(_, value)
        Yipper.DB.WindowAlpha = value

        Yipper.mainFrame:SetBackdropColor(0, 0, 0, value / 100)
        Yipper.mainFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, (Yipper.DB.WindowAlpha or 100) / 100)
        Yipper.settingsFrame:SetBackdropColor(0, 0, 0, value / 100)
        Yipper.settingsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, (Yipper.DB.WindowAlpha or 100) / 100)
    end, slider)
end

-- Yipper.UI.Settings - AddBackgroundColorPicker
--
-- Responsible for hooking up the UI components to be able to select the background
-- color of the windows.
function Yipper.UI.Settings:AddBackgroundColorPicker()
    local color = Yipper.DB.BackgroundColor or { ["r"] = 0, ["g"] = 0, ["b"] = 0 }
    local alpha = Yipper.DB.WindowAlpha or Yipper.Constant.Alpha
    local colorButton = CreateFrame("Button", nil, Yipper.settingsFrame, "UIPanelButtonTemplate")

    colorButton:SetSize(340, 20)
    colorButton:SetPoint("TOPLEFT", 30, -140)
    colorButton:SetText("Set Background Color")
    colorButton.Texture = colorButton:CreateTexture()
    colorButton.Texture:SetAllPoints()
    colorButton.Texture:SetTexture("Interface\\BUTTONS\\WHITE8X8")-- just a white square but could be anything (presumably white)
    colorButton.Texture:SetVertexColor(color.r, color.g, color.b)

    colorButton:SetScript("OnClick", function(_)
        local function OnColorChanged()
            local red, green, blue = ColorPickerFrame:GetColorRGB()

            -- Store the selected color
            Yipper.DB.BackgroundColor = { ["r"] = red, ["g"] = green, ["b"] = blue }

            -- Update UI components
            colorButton.Texture:SetVertexColor(red, green, blue)
            Yipper.settingsFrame:SetBackdropColor(red, green, blue, alpha / 100)
            Yipper.mainFrame:SetBackdropColor(red, green, blue, alpha / 100)
        end

        local function OnCancel()
            local red, green, blue = ColorPickerFrame:GetPreviousValues()
            local colorBox = ColorPickerFrame.colorBox.Texture

            colorBox:SetVertexColor(red, green, blue)
        end

        local options = {
            swatchFunc = OnColorChanged,
            opacityFunc = OnColorChanged,
            cancelFunc = OnCancel,
            hasOpacity = false,
            opacity = 100,
            r = color.r,
            g = color.g,
            b = color.b,
        }

        ColorPickerFrame:SetupColorPickerAndShow(options)
    end)
end

-- Yipper.UI.Settings - AddBackgroundColorPicker
--
-- Responsible for hooking up the UI components to be able to select the background
-- color of the windows.
function Yipper.UI.Settings:AddBorderColorPicker()
    local color = Yipper.DB.BorderColor or Yipper.Constants.BlackColor
    local alpha = Yipper.DB.WindowAlpha or Yipper.Constant.Alpha
    local colorButton = CreateFrame("Button", nil, Yipper.settingsFrame, "UIPanelButtonTemplate")

    colorButton:SetSize(340, 20)
    colorButton:SetPoint("TOPLEFT", 30, -170)
    colorButton:SetText("Set Border Color")
    colorButton.Texture = colorButton:CreateTexture()
    colorButton.Texture:SetAllPoints()
    colorButton.Texture:SetTexture("Interface\\BUTTONS\\WHITE8X8")-- just a white square but could be anything (presumably white)
    colorButton.Texture:SetVertexColor(color.r, color.g, color.b)

    colorButton:SetScript("OnClick", function(_)
        local function OnColorChanged()
            local red, green, blue = ColorPickerFrame:GetColorRGB()

            -- Store the selected color
            Yipper.DB.BackgroundColor = { ["r"] = red, ["g"] = green, ["b"] = blue }

            -- Update UI components
            colorButton.Texture:SetVertexColor(red, green, blue)
            Yipper.settingsFrame:SetBackdropBorderColor(red, green, blue, alpha / 100)
            Yipper.mainFrame:SetBackdropBorderColor(red, green, blue, alpha / 100)
        end

        local function OnCancel()
            local red, green, blue = ColorPickerFrame:GetPreviousValues()
            local colorBox = ColorPickerFrame.colorBox.Texture

            colorBox:SetVertexColor(red, green, blue)
        end

        local options = {
            swatchFunc = OnColorChanged,
            opacityFunc = OnColorChanged,
            cancelFunc = OnCancel,
            hasOpacity = false,
            opacity = 100,
            r = color.r,
            g = color.g,
            b = color.b,
        }

        ColorPickerFrame:SetupColorPickerAndShow(options)
    end)
end
