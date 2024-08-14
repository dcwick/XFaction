local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'FriendCollection'

XFC.FriendCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.FriendCollection:new()
	local object = XFC.FriendCollection.parent.new(self)
	object.__name = ObjectName
	return object
end

function XFC.FriendCollection:NewObject()
	return XFC.Friend:new()
end

function XFC.FriendCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		XFO.Events:Add({
            name = 'Friend', 
            event = 'BN_FRIEND_INFO_CHANGED', 
            callback = XFO.Friends.RefreshFriends, 
            instance = true,
            groupDelta = XF.Settings.Network.BNet.FriendTimer
        })

        XFO.Timers:Add({
            name = 'Ping', 
            delta = XF.Settings.Network.BNet.Ping.Timer, 
            callback = XFO.Friends.CallbackPing, 
            repeater = true, 
            instance = true
        })

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.FriendCollection:HasFriends()
    return self:Count() > 0
end

function XFC.FriendCollection:RefreshFriends()
	local self = XFO.Friends
	for i = 1, XFF.BNetFriendCount() do
		local friend = nil
		try(function()
			friend = self:Pop()
			friend:Initialize(i)
			
			if(self:Contains(friend:Key())) then
				friend:IsLinked(friend:CanLink() and self:Get(friend:Key()):IsLinked())
			end

			self:Replace(friend)
		end).
		catch(function(err)
			XF:Warn(self:ObjectName(), err)
			self:Push(friend)
		end)
	end	
end

function XFC.FriendCollection:Backup()
	try(function ()
		if(self:IsInitialized()) then
			for _, friend in self:Iterator() do
				if(friend:IsLinked()) then
					XF.Cache.Backup.Friends[#XF.Cache.Backup.Friends + 1] = friend:Key()
				end
			end
		end
	end).
	catch(function (err)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create friend backup before reload: ' .. err
	end)
end

function XFC.FriendCollection:Restore()
	if(XF.Cache.Backup.Friends == nil) then XF.Cache.Backup.Friends = {} end
	for _, key in pairs (XF.Cache.Backup.Friends) do
		try(function ()
			if(self:Contains(key)) then
				local friend = XFO.Friends:Get(key)
				friend:IsLinked(friend:CanLink()) -- They may have logged out during reload, thus why setting it to CanLink
				XF:Info(self:ObjectName(), '  Restored %s friend information from backup', friend:Tag())
			end
		end).
		catch(function (err)
			XF:Warn(self:ObjectName(), 'Failed to restore friend list: ' .. err)
		end)
	end
	XF.Cache.Backup.Friends = {}
end

function XFC.FriendCollection:GetByGUID(inGUID)
	assert(type(inGUID) == 'string')
	for _, friend in self:Iterator() do
		if(friend:GUID() == inGUID) then
			return friend
		end
	end
end

function XFC.FriendCollection:IsLinked(inGUID)
    local friend = self:GetByGUID(inGUID)
    if(friend ~= nil) then
        friend:IsLinked(true)
    end
end

function XFC.FriendCollection:GetByTarget(inTarget)
	assert(type(inTarget) == 'table' and inTarget.__name == 'Target')

    local keys = {}
	for _, friend in self:Iterator() do
        if(friend:IsLinked() and friend:Target():Equals(inTarget)) then
            table.insert(keys, friend:Key())
        end
	end

    if(#keys == 0) then return end
    return self:Get(keys[math.random(#keys)])
end

function XFC.FriendCollection:CallbackPing()
    local self = XFO.Friends
    try(function()
        for _, friend in self:Iterator() do
            if(not friend:IsLinked() and friend:CanLink()) then
                XFO.Mailbox:SendPingMessage(friend)
            end
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion