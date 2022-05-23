local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'TimerEvent'
local LogCategory = 'HETimer'
local TotalChannels = 10  -- Ceiling set by Blizz

TimerEvent = {}

function TimerEvent:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Initialized = false
    end

    return Object
end

function TimerEvent:Initialize()
	if(self:IsInitialized() == false) then
		CON:ScheduleTimer(self.CallbackChannelTimer, 15) -- config
        CON:ScheduleRepeatingTimer(self.CallbackGarbageTimer, 60) -- config
        CON:Info(LogCategory, "Scheduled memory garbage collection to occur every %d seconds", 60)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function TimerEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function TimerEvent:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

-- Wait for General chat to grab #1
function TimerEvent:CallbackChannelTimer()
    CON.Handlers.ChannelEvent = ChannelEvent:new(); CON.Handlers.ChannelEvent:Initialize()
    if(CON.Network.Sender:GetLocalChannel() == nil) then
        -- This will fire an event that ChannelEvent handler catches and updates
        JoinChannelByName(CON.Network.ChannelName)
    end
end

-- Force garbage cleanup
function TimerEvent:CallbackGarbageTimer()
    collectgarbage() -- This identifies objects to clean and calls finalizers
    collectgarbage() -- The second call actually deletes the objects
end