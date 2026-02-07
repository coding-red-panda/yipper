-- Yipper - Core
--
--- Responsible for hooking the required events and trigger the AddOn logic.
--- We only care about creating the core frame for Yipper here, and hooking
--- up the ADDON_LOADED event, so we know all files are ready and we can
--- invoke the code as needed.

local addonName, Yipper = ...

-- Create a frame to hook events on and act as our core anchor.
Yipper.mainFrame = CreateFrame("Frame", nil, UIParent)

-- Register the events we care about for now
Yipper.mainFrame:RegisterEvent("ADDON_LOADED")
Yipper.mainFrame:RegisterEvent("PLAYER_LOGOUT")

-- Initialize the core properties of our AddOn.
Yipper.Messages = { }

-- Yipper - OnEvent
--
-- EventHandler for Yipper to handle all incoming events raised by the client.
-- We will check the arguments to determine what to do based on the event name.
--
-- @param event The name of the event being triggered
-- @param ... The arguments passed down with the event
function Yipper:OnEvent(event, ...)
    local name = ...

    if (event == "ADDON_LOADED" and addonName == name) then
        -- If the YipperDB is nil, it means this is the first time loading
        -- the Addon. In that case, assign the default values for the AddOn
        -- to the DB.
        if YipperDB == nil then
            Yipper.DB = {
                ["Messages"] = {},
                ["MaxMessages"] = 50,
                ["BackgroundColor"] = Yipper.Constants.BlackColor,
                ["BorderColor"] = Yipper.Constants.BlackColor,
                ["Alpha"] = Yipper.Constants.Alpha,
                ["FontSize"] = Yipper.Constants.FontSize,
                ["SelectedFont"] = Yipper.Constants.Fonts.FrizQuadrata,
                ["NotificationSound"] = nil,
                ["NotificationColor"] = Yipper.Constants.NotificationColor
            }
        -- If the YipperDB variable has been loaded for the character,
        -- assign it to the internal DB so the AddOn has its settings
        -- loaded and available.
        elseif YipperDB then
            Yipper.DB = YipperDB

            -- Wipe the past messages if Yipper has been updated.
            -- This avoids weird behavior in updates when we change stuff.
            if (not Yipper.DB.Version) or Yipper.Utils:IsUpdated(Yipper.DB.Version) then
                Yipper.DB.Version = Yipper.Constants.VERSION
                Yipper.DB.Messages = { }
            end
        end

        if Yipper.Comms then
            Yipper.Comms:Init()
        end

        -- If the Yipper UI is available, initialize it
        if Yipper.UI then
            Yipper.UI:Init()
        end

        -- If the Yipper UI Settings is available, initialize it
        if Yipper.UI.Settings then
            Yipper.UI.Settings:Init()
        end

        -- If the Yipper minimap is available, initialize it
        if Yipper.Minimap then
            Yipper.Minimap:Init()
        end

        -- If the Yipper Chat is available, initialize it
        if Yipper.Events then
            Yipper.Events:Init()
        end
    elseif event == "PLAYER_LOGOUT" then
        YipperDB = Yipper.DB
    elseif event == "LOADING_SCREEN_ENABLED" then
        Yipper.EventQueue.isLoadingScreen = true
    elseif event == "LOADING_SCREEN_DISABLED" then
        Yipper.EventQueue.isLoadingScreen = false
        Yipper.EventQueue:ProcessQueue()
    else
        -- Check if it is a chat event
        local isChatEvent = false
        if Yipper.Constants and Yipper.Constants.ChatEvents then
            for _, chatEvent in pairs(Yipper.Constants.ChatEvents) do
                if event == chatEvent then
                    isChatEvent = true
                    break
                end
            end
        end

        -- Only process the event if it's a chat event, and processing has not been
        -- disabled because we're in a loading screen.
        -- In Loading screens, we cannot rely on methods like GetNormalizedRealmName
        -- to return information.
        if isChatEvent and Yipper.Events then
            if Yipper.EventQueue.isLoadingScreen then
                Yipper.EventQueue:QueueEvent(event, ...)
            else
                Yipper.Events:OnEvent(event, ...)
            end
        end
    end
end

Yipper.mainFrame:SetScript("OnEvent", function(self, event, ...) Yipper:OnEvent(event, ...); end)

-- Register the slash command for our AddOn
SLASH_YIPPER1 = "/yip"
SLASH_YIPPER2 = "/yipper"

function SlashCmdList.YIPPER(msg, editBox)
    if msg == "config" then
        Yipper.settingsFrame:Toggle()
    elseif msg == "help" then
        print("Yipper supports the following options:")
        print("help - this explanation")
        print("config - Show the settings page")
        print("no args - toggle the main window")
    else
        Yipper.mainFrame:Toggle()
    end
end
