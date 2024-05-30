local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Chat'

XFC.Chat = XFC.Mailbox:newChildConstructor()

--#region Constructors
function XFC.Chat:new()
    local object = XFC.Chat.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.Chat:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XF.Enum.Tag.LOCAL = XFO.Confederate:Key() .. 'XF'

        XF.Events:Add({
            name = 'ChatMsg', 
            event = 'CHAT_MSG_ADDON', 
            callback = XFO.Chat.CallbackChatReceive, 
            instance = true
        })
        XF.Events:Add({
            name = 'GuildChat', 
            event = 'CHAT_MSG_GUILD', 
            callback = XFO.Chat.CallbackGuildMessage, 
            instance = true
        })

        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Methods
function XFC.Chat:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if(not XF.Settings.System.Roster and inMessage:GetSubject() == XF.Enum.Message.DATA) then return end

    XF:Debug(self:ObjectName(), 'Attempting to send message')
    inMessage:Print()

    --#region BNet messaging for BNET/BROADCAST types
    if(inMessage:Type() == XF.Enum.Network.BROADCAST or inMessage:Type() == XF.Enum.Network.BNET) then
        XFO.BNet:Send(inMessage)
        -- Failed to bnet to all targets, broadcast to leverage others links
        if(inMessage:HasTargets() and inMessage:IsMyMessage() and inMessage:Type() == XF.Enum.Network.BNET) then
            inMessage:Type(XF.Enum.Network.BROADCAST)
        -- Successfully bnet to all targets and only were supposed to bnet, were done
        elseif(inMessage:Type() == XF.Enum.Network.BNET) then
            return
        -- Successfully bnet to all targets and was broadcast, switch to local only
        elseif(not inMessage:HasTargets() and inMessage:Type() == XF.Enum.Network.BROADCAST) then
            XF:Debug(self:ObjectName(), "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
            inMessage:Type(XF.Enum.Network.LOCAL)        
        end
    end
    --#endregion

    --#region Chat channel messaging for BROADCAST/LOCAL types
    local messageData = inMessage:Serialize()
    local packets = self:SegmentMessage(messageData, inMessage:Key(), XF.Settings.Network.Chat.PacketSize)
    self:Add(inMessage:Key())

    -- If only guild on target, broadcast to GUILD
    local channelName, channelID
    -- Otherwise broadcast to custom channel
    if(XFO.Channels:HasLocalChannel()) then
        channelName = 'CHANNEL'
        channelID = XFO.Channels:LocalChannel():ID()
    else
        channelName = 'GUILD'
        channelID = nil
    end
    for index, packet in ipairs (packets) do
        XF:Debug(self:ObjectName(), 'Sending packet [%d:%d:%s] on channel [%s] with tag [%s] of length [%d]', index, #packets, inMessage:Key(), channelName, XF.Enum.Tag.LOCAL, strlen(packet))
        XF.Lib.BCTL:SendAddonMessage('NORMAL', XF.Enum.Tag.LOCAL, packet, channelName, channelID)
        XFO.Metrics:Get(XF.Enum.Metric.ChannelSend):Increment()
    end
    --#endregion
end

local function _SendMessage(inSubject, inData)
    local self = XFO.Chat
    local message = self:Pop()
    try(function ()
        message:Initialize()
        message:Type(XF.Enum.Network.BROADCAST)
        message:Subject(inSubject)
        message:From(XF.Player.Unit:GUID())
        message:FromUnit(XF.Player.Unit)
        message:TimeStamp(XFF.TimeGetCurrent())
        message:SetAllTargets()
        message:Version(XF.Version)
        message:Faction(XF.Player.Faction)
        message:Guild(XF.Player.Guild)
        message:Links(XFO.Links:Serialize())
        message:Data(inData)
        self:Send(message)
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end).
    finally(function ()
        self:Push(message)
    end)
end

function XFC.Chat:SendOrderMessage(inOrder)
    assert(type(inOrder) == 'table' and inOrder.__name == 'Order')
    XF:Info(self:ObjectName(), 'Sending order message')
    inOrder:Print()
    _SendMessage(XF.Enum.Message.ORDER, inOrder:Encode())
end

function XFC.Chat:SendDataMessage(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    XF:Info(self:ObjectName(), 'Sending data message for unit [%s]', inUnit:UnitName())
    _SendMessage(XF.Enum.Message.DATA, inUnit)
end

function XFC.Chat:SendLoginMessage(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    XF:Info(self:ObjectName(), 'Sending login message for unit [%s]', inUnit:UnitName())
    _SendMessage(XF.Enum.Message.LOGIN, inUnit)
end

function XFC.Chat:SendAchievementMessage(inID)
    assert(type(inID) == 'number')
    XF:Info(self:ObjectName(), 'Sending achievement message for [%d]', inID)
    _SendMessage(XF.Enum.Message.ACHIEVEMENT, inID)
end

function XFC.Chat:SendLogoutMessage()
    _SendMessage(XF.Enum.Message.LOGOUT, '')
end

-- Deprecated, remove after 4.13
function XFC.Chat:SendLinkMessage(inLinks)
    assert(type(inLinks) == 'string')
    XF:Info(self:ObjectName(), 'Sending links message')
    _SendMessage(XF.Enum.Message.LINK, inLinks)
end

function XFC.Chat:SendChatMessage(inText)
    assert(type(inText) == 'string')
    XF:Info(self:ObjectName(), 'Sending guild chat message [%s]', inText)
    _SendMessage(XF.Enum.Message.GCHAT, inText)
end

function XFC.Chat:DecodeMessage(inMsg)
    local message = self:Pop()
    try(function()
        message:Deserialize(inMsg)
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
        self:Push(message)
    end)
    return message
end

function XFC.Chat:CallbackChatReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    local self = XFO.Chat
    try(function ()
        self:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.Chat:CallbackGuildMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    local self = XFO.Chat
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XF.Player.GUID == inSenderGUID and XF.Player.Unit:CanGuildSpeak()) then
            self:SendChatMessage(inText)
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion