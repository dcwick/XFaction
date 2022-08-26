local XFG, G = unpack(select(2, ...))
local ObjectName = 'LinkCollection'

local ServerTime = GetServerTime

LinkCollection = Factory:newChildConstructor()

function LinkCollection:new()
    local _Object = LinkCollection.parent.new(self)
	_Object.__name = ObjectName
	_Object._EpochTime = 0
	return _Object
end

function LinkCollection:NewObject()
	return Link:new()
end

function LinkCollection:Add(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(not self:Contains(inLink:GetKey())) then
		self.parent.Add(self, inLink)
		inLink:GetFromNode():IncrementLinkCount()
		inLink:GetToNode():IncrementLinkCount()
		if(XFG.DebugFlag) then
			XFG:Info(ObjectName, 'Added link from [%s] to [%s]', inLink:GetFromNode():GetName(), inLink:GetToNode():GetName())
		end
		XFG.DataText.Links:RefreshBroker()	
	end
end

function LinkCollection:Remove(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(self:Contains(inLink:GetKey())) then
		self.parent.Remove(self, inLink:GetKey())
		inLink:GetFromNode():DecrementLinkCount()
		inLink:GetToNode():DecrementLinkCount()
		if(XFG.DebugFlag) then
			XFG:Info(ObjectName, 'Removed link from [%s] to [%s]', inLink:GetFromNode():GetName(), inLink:GetToNode():GetName())		
		end
		XFG.DataText.Links:RefreshBroker()
		XFG.Links:Push(inLink)
	end
end

-- A link message is a reset of the links for that node
function LinkCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be Message object")
	local _LinkStrings = string.Split(inMessage:GetData(), '|')
	local _MessageLinks = {}
	local _FromName = nil
	-- Compile a list of the updated links
    for _, _LinkString in pairs (_LinkStrings) do
		local _NewLink = nil
		try(function ()
			_NewLink = XFG.Links:Pop()
			_NewLink:SetObjectFromString(_LinkString)
			_MessageLinks[_NewLink:GetKey()] = true
			-- Dont process players own links			
			if(not _NewLink:IsMyLink() and not self:Contains(_NewLink:GetKey())) then
				self:Add(_NewLink)
				-- All links in the message should be "From" the same person
				_FromName = _NewLink:GetFromNode():GetName()
			else
				self:Push(_NewLink)
			end
		end).
		catch(function (inErrorMessage)
			XFG:Warn(ObjectName, inErrorMessage)
			self:Push(_NewLink)
		end)
    end
	-- Remove any stale links
	for _, _Link in self:Iterator() do
		-- Consider that we may have gotten link information from the other node
		if(not _Link:IsMyLink() and (_Link:GetFromNode():GetName() == _FromName or _Link:GetToNode():GetName() == _FromName) and _MessageLinks[_Link:GetKey()] == nil) then
			self:Remove(_Link)
			if(XFG.DebugFlag) then
				XFG:Debug(ObjectName, 'Removed link due to node broadcast [%s]', _Link:GetKey())
			end
		end
	end
end

function LinkCollection:Broadcast()
	XFG:Debug(ObjectName, 'Broadcasting links')
	self._EpochTime = ServerTime()
	local _LinksString = ''
	for _, _Link in self:Iterator() do
		if(_Link:IsMyLink()) then
			_LinksString = _LinksString .. '|' .. _Link:GetString()
		end
	end

	if(strlen(_LinksString) > 0) then
		local _NewMessage = nil
		try(function ()
			_NewMessage = XFG.Mailbox.Chat:Pop()
			_NewMessage:Initialize()
			_NewMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
			_NewMessage:SetSubject(XFG.Settings.Network.Message.Subject.LINK)
			_NewMessage:SetData(_LinksString)
			XFG.Mailbox.Chat:Send(_NewMessage)  
		end).
		finally(function ()
			XFG.Mailbox.Chat:Push(_NewMessage)
		end)
	end
end

function LinkCollection:Backup()
	try(function ()
		local _LinksString = ''
		for _, _Link in self:Iterator() do
			_LinksString = _LinksString .. '|' .. _Link:GetString()
		end
		XFG.DB.Backup.Links = _LinksString
	end).
	catch(function (inErrorMessage)
		XFG.DB.Errors[#XFG.DB.Errors + 1] = 'Failed to create links backup before reload: ' .. inErrorMessage
	end)
end

function LinkCollection:Restore()
	
	if(XFG.DB.Backup.Links ~= nil and strlen(XFG.DB.Backup.Links) > 0) then
		try(function ()
			local _Links = string.Split(XFG.DB.Backup.Links, '|')
			for _, _Link in pairs (_Links) do
				if(_Link ~= nil) then
					local _NewLink = nil
					try(function ()
						_NewLink = self:Pop()
						_NewLink:SetObjectFromString(_Link)
						self:Add(_NewLink)
						XFG:Debug(ObjectName, 'Restored link from backup [%s]', _NewLink:GetKey())
					end).
					catch(function (inErrorMessage)
						XFG:Warn(ObjectName, inErrorMessage)
						self:Push(_NewLink)
					end)
				end
			end
		end).
		catch(function (inErrorMessage)
			XFG:Warn(ObjectName, inErrorMessage)
		end)
	end	
end

function LinkCollection:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _, _Link in self:Iterator() do
		if(not _Link:IsMyLink() and _Link:GetTimeStamp() < inEpochTime) then
			XFG:Debug(ObjectName, 'Removing stale link')
			self:Remove(_Link)
		end
	end
end