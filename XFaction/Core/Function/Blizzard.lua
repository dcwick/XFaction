local XF, G = unpack(select(2, ...))
local XFF = XF.Function

-- Time
XFF.TimeCurrent = GetServerTime
XFF.TimeLocal = C_DateAndTime.GetServerTimeLocal
XFF.TimeCalendar = C_DateAndTime.GetCurrentCalendarTime

-- Timer
XFF.TimerStart = C_Timer.NewTicker

-- Chat / Channel
XFF.ChatFrameFilter = ChatFrame_AddMessageEventFilter
XFF.ChatChannelColor = ChangeChatColor
XFF.ChatSwapChannels = C_ChatInfo.SwapChatChannelsByChannelIndex
XFF.ChatChannels = GetChannelList
XFF.ChatChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier
XFF.ChatJoinChannel = JoinChannelByName
XFF.ChatGetWindow = GetChatWindowMessages
XFF.ChatHandler = ChatFrame_MessageEventHandler

-- Guild
XFF.GuildGetMembers = C_Club.GetClubMembers
XFF.GuildQueryServer = C_GuildInfo.GuildRoster
XFF.GuildGetInfo = C_Club.GetClubInfo
XFF.GuildGetStreams = C_Club.GetStreams
XFF.GuildGetMember = C_Club.GetMemberInfo
XFF.GuildGetMyself = C_Club.GetMemberInfoForSelf
XFF.GuildGetPermissions = C_GuildInfo.GuildControlGetRankFlags
XFF.GuildID = C_Club.GetGuildClubId
XFF.GuildFrame = ToggleGuildFrame
XFF.GuildGetMOTD = GetGuildRosterMOTD
XFF.GuildEditPermission = CanEditGuildInfo

-- Realm
XFF.RealmAPIName = GetNormalizedRealmName
XFF.RealmID = GetRealmID
XFF.RealmName = GetRealmName

-- Region
XFF.RegionCurrent = GetCurrentRegion

-- Spec
XFF.SpecGetGroupID = GetSpecialization
XFF.SpecID = GetSpecializationInfo

-- Player
XFF.PlayerGetIlvl = GetAverageItemLevel
XFF.PlayerGetAchievement = GetAchievementInfo
XFF.PlayerGetAchievementLink = GetAchievementLink
XFF.PlayerGUID = UnitGUID
XFF.PlayerIsInGuild = IsInGuild
XFF.PlayerIsInCombat = InCombatLockdown
XFF.PlayerIsInInstance = IsInInstance
XFF.PlayerFaction = UnitFactionGroup
XFF.PlayerGetPvPRating = GetPersonalRatedInfo
XFF.PlayerGetGuild = GetGuildInfo

-- BNet
XFF.BNetGetPlayerInfo = BNGetInfo
XFF.BNetGetFriendCount = BNGetNumFriends
XFF.BNetGetFriendInfo = C_BattleNet.GetFriendAccountInfo

-- Client
XFF.ClientVersion = GetBuildInfo
XFF.ClientAddonCount = C_AddOns.GetNumAddOns
XFF.ClientAddonInfo = C_AddOns.GetAddOnInfo
XFF.ClientIsAddonLoaded = C_AddOns.IsAddOnLoaded
XFF.ClientAddonState = C_AddOns.GetAddOnEnableState

-- UI
XFF.UIOptionsFrame = InterfaceOptionsFrame
XFF.UIOptionsFrameCategory = InterfaceOptionsFrame_OpenToCategory
XFF.UIIsMouseOver = MouseIsOver
XFF.UICreateLink = SetItemRef
XFF.UICreateFont = CreateFont
XFF.UIIsShiftDown = IsShiftKeyDown
XFF.UIIsCtrlDown = IsControlKeyDown
XFF.UISystemMessage = SendSystemMessage
XFF.UISystemSound = PlaySound

-- Party
XFF.PartySendInvite = C_PartyInfo.InviteUnit
XFF.PartyRequestInvite = C_PartyInfo.RequestInviteFromUnit

-- Crafting
XFF.CraftingGetItem = C_TooltipInfo.GetRecipeResultItem