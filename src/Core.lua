-- Yipper - Core
--
--- Responsible for hooking the required events and trigger the AddOn logic.
--- We only care about creating the core frame for Yipper here, and hooking
--- up the ADDON_LOADED event, so we know all files are ready and we can
--- invoke the code as needed.

local addonName, Yipper = ...
Yipper.mainFrame = CreateFrame("Frame", nil, UIParent)

-- Register the events we care about for now
Yipper.mainFrame:RegisterEvent("ADDON_LOADED")
Yipper.mainFrame:RegisterEvent("PLAYER_LOGOUT")

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
                ["MaxMessages"] = 50
            }
        end

        -- If the YipperDB variable has been loaded for the character,
        -- assign it to the internal DB so the AddOn has its settings
        -- loaded and available.
        if YipperDB then
            Yipper.DB = YipperDB
        end

        -- If the Yipper UI is available, initialize it
        if Yipper.UI then
            Yipper.UI:Init()
        end

        -- If the Yipper minimap is available, initialize it
        if Yipper.Minimap then
            Yipper.Minimap:Init()
        end

        -- If the Yipper Chat is available, initialize it
        if Yipper.Chat then
            Yipper.Chat:Init()
        end
    elseif event == "PLAYER_LOGOUT" then
        YipperDB = Yipper.DB
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

        if isChatEvent and Yipper.Chat then
            Yipper.Chat:OnEvent(event, ...)
        end
    end
end

Yipper.mainFrame:SetScript("OnEvent", function(self, event, ...) Yipper:OnEvent(event, ...); end)
