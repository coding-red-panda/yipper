--- PlayerTracker
--
-- The PlayerTracker is responsible for keeping track of which player is currently tracked.
-- The user can have multiple windows open to track additional players, but one window will always
-- be used for the tracked player, and that is handled by this class to access the data.
local addonName, Yipper = ...

-- Initialize the module and set the function look up.
local PlayerTracker = {}
PlayerTracker.__index = PlayerTracker

--- Creates a new instance of the PlayerTracker.
--- @return table An instance of the PlayerTracker class.
function PlayerTracker.new()
    local newObject = setmetatable({}, self)

    -- Object initialization
    newObject:Initialize()

    return newObject
end

--- Initializes the instance, ensuring the frame and event handling is in place.
---@return nil
---@private
function PlayerTracker:Initialize()
    -- Create the ticket that tracks the player every 0.1 seconds.
    self._ticker = C_Timer.NewTicker(0.1, function() self:UpdateTrackedPlayer() end)
    self._trackedPlayer = nil
end

--- Updates the tracked player by checking if we're hovering over someone, or
--- have someone selected as target.
---@return nil
---@private
function PlayerTracker:UpdateTrackedPlayer()
    -- Variable for tracking the new potential target
    local newTrackedPlayerGuid

    -- Hovering takes precedence, if we're hovering over a player,
    -- that will be our new target.
    -- Otherwise check if the target we have currently have is a player.
    if UnitGUID("mouseover") ~= nil and UnitIsPlayer("mouseover") then
        newTrackedPlayerGuid = UnitGUID("mouseover")
    elseif UnitGUID("target") ~= nil and UnitIsPlayer("target") then
        newTrackedPlayerGuid = UnitGUID("target")
    end

    -- Do not proceed if the Guid is a secret.
    -- In PropHunt we're able to track players, but their values are secret.
    -- Attempting anything will just break the AddOn.
    if Yipper.API:IsSecret(newTrackedPlayerGuid) then
        return
    end

    -- Only update if the newTrackedPlayer is different from the one we're
    -- currently tracking. This accounts for hover, deselect or selecting
    -- a target.
    if newTrackedPlayerGuid ~= self._trackedPlayer then
        self._trackedPlayer = newTrackedPlayerGuid

        -- Raise a custom event that the player changed.
        C_Event.TriggerEvent("YIPPER_TRACKED_PLAYER_CHANGED", self._trackedPlayer)
    end
end
