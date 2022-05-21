local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Guild'
local LogCategory = 'O' .. ObjectName

Guild = {}

function Guild:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

    assert(inObject == nil or 
          (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
          "argument must be nil, string or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Name = nil
        self._Units = {}
        self._NumberOfUnits = 0
        self._Initialized = false
    end

    return Object
end

function Guild:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', "argument needs to be nil or boolean")
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Guild:Initialize()
	if(self:IsInitialized() == false) then
        self:SetName(GetGuildInfo('player'))
        self:SetKey(self:GetName())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Guild:Print(inPrintOffline)
    CON:DoubleLine(LogCategory)
    CON:Debug(LogCategory, "Guild Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    CON:Debug(LogCategory, "  _Units (" .. type(self._Units) .. "): ")
    for _, _Unit in pairs (self._Units) do
        if(_PrintOffline == true or _Unit:IsOnline()) then
            _Unit:Print()
        end
    end
end

function Guild:GetKey()
    return self._Key
end

function Guild:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Guild:GetName()
    return self._Name
end

function Guild:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Guild:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey] ~= nil
end

function Guild:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', "argument must be Unit object")

    if(self:Contains(inUnit:GetKey()) == false) then
        self._Units[inUnit:GetKey()] = inUnit
        self._NumberOfUnits = self._NumberOfUnits + 1
    end

    return self:Contains(inUnit:GetKey())
end