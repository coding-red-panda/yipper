-- Yipper - YipperSettingsFrameTemplate (code-behind)
--
-- Companion script for ui/YipperSettingsFrameTemplate.xml. The XML
-- declares the static structure of the settings window; this file
-- exposes the Yipper.SettingsFrame module and the per-widget wiring
-- functions that the template's OnLoad scripts call into.
local addonName, Yipper = ...

-- Initialize the module
Yipper.SettingsFrame = { }

-- Initializes the SettingsFrame module by instantiating the XML
-- template, storing the reference, and applying runtime state
-- that the template can't express declaratively.
function Yipper.SettingsFrame:Init()
    local frame = CreateFrame("Frame", "Yipper_SettingsFrame_Mainframe", UIParent, "Yipper_SettingsFrame_Template")

    Yipper.settingsFrame = frame

    frame.Toggle = function(self)
        if self:IsShown() then
            self:Hide()
        else
            self:Show()
        end
    end

    self:RestorePosition()
    frame:Hide()
end

-- Applies the backdrop colors from the DB. Runs as the template's
-- OnLoad, before Yipper.settingsFrame has been assigned, so we
-- operate on the frame argument directly.
function Yipper.SettingsFrame:OnTemplateLoaded(frame)
    local backgroundColor = Yipper.DB.BackgroundColor or Yipper.Constants.BlackColor
    local borderColor = Yipper.DB.BorderColor or Yipper.Constants.BlackColor
    local alpha = Yipper.DB.WindowAlpha or Yipper.Constants.Alpha

    frame:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, alpha / 100)
    frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, alpha / 100)
end

-- Yipper.UI - SavePosition
--
-- Stores the reference point of the mainFrame, as well as its dimensions
-- inside the Yipper.DB so the game can save these values on exit.
function Yipper.SettingsFrame:SavePosition()
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
function Yipper.SettingsFrame:RestorePosition()
    local pos = Yipper.DB.SettingsFramePosition

    if pos then
        Yipper.settingsFrame:ClearAllPoints()
        Yipper.settingsFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        Yipper.settingsFrame:SetSize(pos.width, pos.height)
    else
        Yipper.settingsFrame:SetSize(400, 600)
        Yipper.settingsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

-- Yipper.SettingsFrame - AddMinimapSettings
--
-- Wires the minimap-visibility checkbox to the DB and the
-- minimap frame.
function Yipper.SettingsFrame:AddMinimapSettings(checkbox)
    checkbox:SetChecked(Yipper.DB.EnableMinimapButton)
    checkbox.Text:SetText("Toggle Minimap Visibility")
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

-- Yipper.SettingsFrame - AddHeaderSettings
--
-- Wires the header-visibility checkbox to the DB and the
-- header frame.
function Yipper.SettingsFrame:AddHeaderSettings(checkbox)
    checkbox:SetChecked(Yipper.DB.ShowHeader)
    checkbox.Text:SetText("Toggle Header Visibility")
    checkbox.tooltip = "Toggle the visibility of the Yipper Header"
    checkbox:HookScript("OnClick", function(self)
        Yipper.DB.ShowHeader = self:GetChecked()

        if self:GetChecked() then
            Yipper.headerFrame:Show()
            Yipper.messageFrame:SetPoint("TOPLEFT", Yipper.mainFrame, "TOPLEFT", 10, -30)
        else
            Yipper.headerFrame:Hide()
            Yipper.messageFrame:SetPoint("TOPLEFT", Yipper.mainFrame, "TOPLEFT", 10, -5)
        end
    end)
end

-- Yipper.SettingsFrame - AddTrackerSettings
--
-- Wires the tracker-notification checkbox to the DB.
function Yipper.SettingsFrame:AddTrackerSettings(checkbox)
    checkbox:SetChecked(Yipper.DB.PingTrackedPlayer)
    checkbox.Text:SetText("Notify on message")
    checkbox.tooltip = "Sends notification sounds when the tracked player sends a message."
    checkbox:HookScript("OnClick", function(self)
        Yipper.DB.PingTrackedPlayer = self:GetChecked()
    end)
end

-- Yipper.SettingsFrame - AddAlphaSettings
--
-- Configures the window-alpha slider with formatters and binds
-- value changes back to the DB and main frame.
function Yipper.SettingsFrame:AddAlphaSettings(slider)
    local minvalue = 0
    local maxValue = 100
    local stepValue = 1
    local options = Settings.CreateSliderOptions(minvalue, maxValue, stepValue)

    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function(_) return maxValue end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function(_) return minvalue end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Top, function(_) return "Window Alpha" end);

    slider:Init(Yipper.DB.WindowAlpha or 100, options.minValue, options.maxValue, options.steps, options.formatters)
    slider:RegisterCallback("OnValueChanged", function(_, value)
        Yipper.DB.WindowAlpha = value

        local color = Yipper.DB.BackgroundColor or Yipper.Constants.BlackColor

        Yipper.mainFrame:SetBackdropColor(color.r, color.g, color.b, value / 100)
        Yipper.mainFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, (Yipper.DB.WindowAlpha or 100) / 100)
    end, slider)
end

-- Yipper.SettingsFrame - AddFontSizeSettings
--
-- Configures the font-size slider with formatters and binds
-- value changes back to the DB and message frame.
function Yipper.SettingsFrame:AddFontSizeSettings(slider)
    local minvalue = 8
    local maxValue = 64
    local stepValue = 2
    local options = Settings.CreateSliderOptions(minvalue, maxValue, stepValue)

    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function(_) return maxValue end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function(_) return minvalue end);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Top, function(_) return "Font Size" end);

    slider:Init(
            Yipper.DB.FontSize or Yipper.Constants.FontSize,
            options.minValue,
            options.maxValue,
            options.steps,
            options.formatters
    )
    slider:RegisterCallback("OnValueChanged", function(_, value)
        Yipper.DB.FontSize = value
        Yipper.messageFrame:SetFont(Yipper.DB.SelectedFont, value, "");
    end, slider)
end

-- Yipper.SettingsFrame - AddBackgroundColorPicker
--
-- Wires the background color button to ColorPickerFrame and to
-- the DB. The tinted texture lives in the XML.
function Yipper.SettingsFrame:AddBackgroundColorPicker(colorButton)
    local color = Yipper.DB.BackgroundColor or Yipper.Constants.BlackColor
    local alpha = Yipper.DB.WindowAlpha or Yipper.Constants.Alpha

    colorButton.Texture:SetVertexColor(color.r, color.g, color.b)

    colorButton:SetScript("OnClick", function(_)
        local function OnColorChanged()
            local red, green, blue = ColorPickerFrame:GetColorRGB()

            Yipper.DB.BackgroundColor = { ["r"] = red, ["g"] = green, ["b"] = blue }

            colorButton.Texture:SetVertexColor(red, green, blue)
            Yipper.settingsFrame:SetBackdropColor(red, green, blue, alpha / 100)
            Yipper.mainFrame:SetBackdropColor(red, green, blue, alpha / 100)
        end

        local function OnCancel()
            local red, green, blue = ColorPickerFrame:GetPreviousValues()

            Yipper.DB.BackgroundColor = { ["r"] = red, ["g"] = green, ["b"] = blue }

            colorButton.Texture:SetVertexColor(red, green, blue)
            Yipper.settingsFrame:SetBackdropColor(red, green, blue, alpha / 100)
            Yipper.mainFrame:SetBackdropColor(red, green, blue, alpha / 100)
        end

        local storedColor = Yipper.DB.BackgroundColor or Yipper.Constants.BlackColor
        local options = {
            swatchFunc = OnColorChanged,
            opacityFunc = OnColorChanged,
            cancelFunc = OnCancel,
            hasOpacity = false,
            r = storedColor.r,
            g = storedColor.g,
            b = storedColor.b,
        }

        ColorPickerFrame:SetupColorPickerAndShow(options)
    end)
end

-- Yipper.SettingsFrame - AddBorderColorPicker
--
-- Wires the border color button to ColorPickerFrame and to the DB.
function Yipper.SettingsFrame:AddBorderColorPicker(colorButton)
    local color = Yipper.DB.BorderColor or Yipper.Constants.BlackColor
    local alpha = Yipper.DB.WindowAlpha or Yipper.Constants.Alpha

    colorButton.Texture:SetVertexColor(color.r, color.g, color.b)

    colorButton:SetScript("OnClick", function(_)
        local function OnColorChanged()
            local red, green, blue = ColorPickerFrame:GetColorRGB()

            Yipper.DB.BorderColor = { ["r"] = red, ["g"] = green, ["b"] = blue }

            colorButton.Texture:SetVertexColor(red, green, blue)
            Yipper.settingsFrame:SetBackdropBorderColor(red, green, blue, alpha / 100)
            Yipper.mainFrame:SetBackdropBorderColor(red, green, blue, alpha / 100)
        end

        local function OnCancel()
            local red, green, blue = ColorPickerFrame:GetPreviousValues()

            Yipper.DB.BorderColor = { ["r"] = red, ["g"] = green, ["b"] = blue }

            colorButton.Texture:SetVertexColor(red, green, blue)
            Yipper.settingsFrame:SetBackdropBorderColor(red, green, blue, alpha / 100)
            Yipper.mainFrame:SetBackdropBorderColor(red, green, blue, alpha / 100)
        end

        local storedColor = Yipper.DB.BorderColor or Yipper.Constants.BlackColor
        local options = {
            swatchFunc = OnColorChanged,
            opacityFunc = OnColorChanged,
            cancelFunc = OnCancel,
            hasOpacity = false,
            r = storedColor.r,
            g = storedColor.g,
            b = storedColor.b,
        }

        ColorPickerFrame:SetupColorPickerAndShow(options)
    end)
end

-- Yipper.SettingsFrame - AddNotificationColorPicker
--
-- Wires the notification color button to ColorPickerFrame and to
-- the DB. Colors are stored in 0-255 range to match other constants.
function Yipper.SettingsFrame:AddNotificationColorPicker(colorButton)
    local color = Yipper.DB.NotificationColor or Yipper.Constants.NotificationColor

    colorButton.Texture:SetVertexColor(color.r / 255, color.g / 255, color.b / 255)

    colorButton:SetScript("OnClick", function(_)
        local function OnColorChanged()
            local red, green, blue = ColorPickerFrame:GetColorRGB()

            Yipper.DB.NotificationColor = { ["r"] = red * 255, ["g"] = green * 255, ["b"] = blue * 255 }

            colorButton.Texture:SetVertexColor(red, green, blue)
        end

        local function OnCancel()
            local red, green, blue = ColorPickerFrame:GetPreviousValues()

            Yipper.DB.NotificationColor = { ["r"] = red * 255, ["g"] = green * 255, ["b"] = blue * 255 }

            colorButton.Texture:SetVertexColor(red, green, blue)
        end

        local storedColor = Yipper.DB.NotificationColor or Yipper.Constants.NotificationColor
        local options = {
            swatchFunc = OnColorChanged,
            opacityFunc = OnColorChanged,
            cancelFunc = OnCancel,
            hasOpacity = false,
            opacity = 100,
            r = storedColor.r / 255,
            g = storedColor.g / 255,
            b = storedColor.b / 255,
        }

        ColorPickerFrame:SetupColorPickerAndShow(options)
    end)
end

-- Yipper.SettingsFrame - NotificationSelectionSettings
--
-- Wires the notification-sound dropdown's generator to its
-- backing DB value.
function Yipper.SettingsFrame:NotificationSelectionSettings(dropdown)
    local function IsSelected(index)
        if index == "None" then
            return Yipper.DB.NotificationSound == nil
        else
            return Yipper.DB.NotificationSound == Yipper.Constants.Sounds[index].id
        end
    end

    local function SetSelected(index)
        if index == "None" then
            Yipper.DB.NotificationSound = nil
        else
            local soundId = Yipper.Constants.Sounds[index].id

            Yipper.DB.NotificationSound = soundId

            if soundId then
                PlaySound(soundId)
            end
        end
    end

    local function GeneratorFunction(owner, rootDescription)
        rootDescription:CreateTitle("Notification Sound Selection")

        for key, sound in pairs(Yipper.Constants.Sounds) do
            rootDescription:CreateRadio(sound.name, IsSelected, SetSelected, key)
        end

        rootDescription:CreateDivider()
        rootDescription:CreateRadio("None", IsSelected, SetSelected, "None")
    end

    dropdown:SetupMenu(GeneratorFunction)
    dropdown.Texture:SetVertexColor(0, 0, 0)
end

-- Yipper.SettingsFrame - AddFontSelectionSettings
--
-- Wires the font-selection dropdown's generator to the available
-- fonts and the message frame.
function Yipper.SettingsFrame:AddFontSelectionSettings(dropdown)
    local createButton = function(root, display, font)
        root:CreateButton(display, function(data)
            local fontSize = Yipper.DB.FontSize

            Yipper.DB.SelectedFont = font
            Yipper.messageFrame:SetFont(font, fontSize, "")
        end)
    end

    local function GeneratorFunction(owner, rootDescription)
        rootDescription:CreateTitle("Font Selection")
        for name, path in pairs(Yipper.Constants.Fonts) do
            createButton(rootDescription, name, path)
        end
    end

    dropdown:SetupMenu(GeneratorFunction)
    dropdown.Texture:SetVertexColor(0, 0, 0)
end

-- Yipper.SettingsFrame - KeywordSettings
--
-- Populates the keyword editbox from the DB and persists edits
-- when focus is lost.
function Yipper.SettingsFrame:KeywordSettings(editBox)
    editBox:SetFontObject(ChatFontNormal)

    local keywords = ""

    if Yipper.DB.Keywords then
        keywords = table.concat(Yipper.DB.Keywords or {}, ",")
    end
    editBox:SetText(keywords or "", ",")

    editBox:SetScript("OnEditFocusLost", function(self)
        local cleanKeywords = (self:GetText() or ""):gsub(",$", "")

        if cleanKeywords == nil or cleanKeywords == "" then
            Yipper.DB.Keywords = {}
        else
            self:SetText(cleanKeywords)
            Yipper.DB.Keywords = Yipper.Utils:SplitString(cleanKeywords, ",")
        end
    end)
end