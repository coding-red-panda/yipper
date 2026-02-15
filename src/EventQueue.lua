-- Yipper - EventQueue
--
-- Between the events LOADING_SCREEN_ENABLED and LOADING_SCREEN_DISABLED,
-- we cannot process events because the required methods that are responsible
-- for returning the required data cannot be trusted to return sensible information.
--
-- To offset this problem, we have this EventQueue where events can be stored into
-- and when the loading screen ends, we process all captured events.
local addonName, Yipper = ...

-- Initialize the EventQueue
Yipper.EventQueue = {
    IsLoadingScreenOrCombat = false,
    queue = {}
}

-- Stores the event for processing later on.
-- We simply preserve the event name, and the arguments that were passed as it was
-- received by the client.
function Yipper.EventQueue:QueueEvent(event, ...)
    table.insert(self.queue, {
        event = event,
        args = {...}
    })
end

-- Process the events.
-- This will simply take every event and feed it into Yipper itself for
-- processing, using the standard way.
function Yipper.EventQueue:ProcessQueue()
    if #self.queue == 0 then
        return
    end

    for i, eventData in ipairs(self.queue) do
        Yipper.Events:OnEvent(eventData.event, unpack(eventData.args))
    end

    -- Clear the Queue when done
    self.queue = {}
end
