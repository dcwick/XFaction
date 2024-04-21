local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Faction'

XFC.Faction = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Faction:new()
    local object = XFC.Faction.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    object.language = nil
    return object
end

function XFC.Faction:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        if(self:Name() ~= nil) then
            if(self.name == 'Horde') then
                self:IconID(XF.Icons.Horde)
                self:Language('Orcish')
                self:ID('H')
            elseif(self:Name() == 'Alliance') then
                self:IconID(XF.Icons.Alliance)
                self:Language('Common')
                self:ID('A')
            else
                self:IconID(XF.Icons.Neutral)
                self:Language('Common')
                self:ID('N')
            end
        end
        self:IsInitialized(true)
    end
end
--#endregion

--#region Properties
function XFC.Faction:IconID(inIconID)
    assert(type(inIconID) == 'number' or inIconID == nil, 'argument must be number or nil')
    if(inIconID ~= nil) then
        self.iconID = inIconID
    end
    return self.iconID
end

function XFC.Faction:Language(inLanguage)
    assert(type(inLanguage) == 'string' or inLanguage == nil, 'argument must be string or nil')
    if(inLanguage ~= nil) then
        self.language = inLanguage
    end
    return self.language
end

function XFC.Faction:IsAlliance()
    return self:ID() == 'A'
end

function XFC.Faction:IsHorde()
    return self:ID() == 'H'
end

function XFC.Faction:IsNeutral()
    return self:ID() == 'N'
end
--#endregion

--#region Methods
function XFC.Faction:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    XF:Debug(self:ObjectName(), '  language (' .. type(self.language) .. '): ' .. tostring(self.language))
end
--#endregion