--[[
    Addon created by Dorann
	
	SVT - Shadow Vulnerability Tracker
--]]

-----------------------------------------------------------------------
--      Addon Declaration
-----------------------------------------------------------------------
local _, class = UnitClass("player")
if class ~= "PRIEST" then
	return
end

local L = AceLibrary("AceLocale-2.2"):new("SVT")

SVT = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceModuleCore-2.0", "AceDB-2.0", "AceDebug-2.0", "FuBarPlugin-2.0")
SVT:SetModuleMixins("AceDebug-2.0", "AceEvent-2.0", "CandyBar-2.1")
SVT.revision = 1
SVT:RegisterDB("SVTDB")
SVT.cmdtable = {
	type = "group",
	handler = SVT,
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"],
			desc = L["Enable timers."],
			order = 1,
			get = function() return SVT.db.profile.enable end,
			set = function(v) SVT.db.profile.enable = v end,
		},
		currentonly = {
			type = "toggle",
			name = L["Target only"],
			desc = L["Show timer only for the current target."],
			order = 2,
			get = function() return SVT.db.profile.currentonly end,
			set = function(v) SVT.db.profile.currentonly = v end,
		},
		spacer = {
			type = "header",
			name = " ",
			order = 4,
		}
	}
}
SVT:RegisterChatCommand({"/svt"}, SVT.cmdtable)

SVT.defaultDB = {
	posx = nil,
	posy = nil,
	visible = nil,	
	
	enable = true,
	currentonly = true,
}


-----------------------------------------------------------------------
--      Initialization
-----------------------------------------------------------------------
function SVT:OnInitialize()
	-- Called when the addon is loaded
end

function SVT:OnEnable()
	AceLibrary("PaintChips-2.0"):RegisterColor("purple", "9041FF")
	-- Called when the addon is enabled
	self:RegisterEvent("SpellStatus_SpellCastInstant")
	self:RegisterEvent("SpellStatus_SpellCastChannelingStart")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF", "PlayerDamageEvents")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("SVT_Test", "TestBar")
end

function SVT:OnDisable()
	-- Called when the addon is disabled
end

------------------------------
-- FuBar	     			--
------------------------------
local tablet = AceLibrary("Tablet-2.0")
function SVT:OnTooltipUpdate()
	tablet:SetHint(L["|cffeda55fRight click|r to show the options menu."])
end

function SVT:OnClick()
	--self:ToggleFrame()
end

SVT.hasIcon = "Interface\\Icons\\Spell_Shadow_BlackPlague"
SVT.defaultMinimapPosition = 170
SVT.OnMenuRequest = SVT.cmdtable

------------------------------
-- Variables     			--
------------------------------
local BS = AceLibrary("Babble-Spell-2.2")

SVT.target = nil
SVT.lastResist = GetTime()
SVT.lastVictim = nil
SVT.debuffs = {}


----------------------
-- Event Handlers  	--
----------------------
function SVT:SpellStatus_SpellCastChannelingStart(sId, sName, sRank, sFullName, sCastTime)
	if self.db.profile.enable then
		if sName == BS["Mind Flay"] then
			local tmpTime = GetTime() - self.lastResist
			if tmpTime > 0.1 then
				self.lastVictim = UnitName("target");
				self:ScheduleEvent("ShadowVulneDelayedBar", self.DelayedBar, 0.2, self)
				--self:DebugMessage("Mind Flay - ".. self.lastVictim.." "..GetTime())
			end
		end
	end
end

function SVT:SpellStatus_SpellCastInstant(sId, sName, sRank, sFullName, sCastTime)
	if self.db.profile.enable then
		if sName == BS["Shadow Word: Pain"] then
			local tmpTime = GetTime()-self.lastResist
			if tmpTime > 0.1 then
				self.lastVictim = UnitName("target");
				self:ScheduleEvent("ShadowVulneDelayedBar", self.DelayedBar, 0.2, self)
				--self:DebugMessage("Mind Flay - ".. self.lastVictim.." "..GetTime())
			end
		end
	end
end

function SVT:PlayerDamageEvents(msg)
	if self.db.profile.enable then
		local start, ending, victim = string.find(msg, L["mindblast_test"])
		if victim then
			--self:Print("MindBlast - ".. victim)
			self.lastVictim = victim
			self:ScheduleEvent("ShadowVulneDelayedBar", self.DelayedBar, 0.2, self)
		end
		
		local start, ending, victim = string.find(msg, L["mindblastCrit_test"])
		if victim then
			--self:Print("MindBlast - ".. victim)
			self.lastVictim = victim
			self:ScheduleEvent("ShadowVulneDelayedBar", self.DelayedBar, 0.2, self)
		end

		local start, ending, victim = string.find(msg, L["vulneResist_test"])
		if victim then
			--self:DebugMessage("Shadow vulne resist - ".. victim.." "..GetTime())
			self.lastResist = GetTime()
			self:CancelScheduledEvent("ShadowVulneDelayedBar")
		end

		local start, ending, victim = string.find(msg, L["swpResist_test"])
		if victim then
			--self:DebugMessage("swp resist - ".. victim.." "..GetTime())
			self.lastResist = GetTime()
			self:CancelScheduledEvent("ShadowVulneDelayedBar")
		end

		local start, ending, victim = string.find(msg, L["mindflay_test"])
		if victim then
			--self:DebugMessage("mindflay resist - ".. victim.." "..GetTime())
			self.lastResist = GetTime()
			self:CancelScheduledEvent("ShadowVulneDelayedBar")
		end

	end
end

function SVT:DelayedBar()
	self.debuffs[self.lastVictim] = GetTime() - 0.2
	SVT:GetModule("Bar"):Start(self.lastVictim, 15 - 0.2, "Interface\\Icons\\Spell_Shadow_BlackPlague")
end

function SVT:PLAYER_REGEN_ENABLED()
	self.target = nil
	SVT:GetModule("Bar"):Stop()
	self.debuffs = {}
end

function SVT:RecheckTargetChange()
	local target = UnitName("target")
	if target ~= self.target then
		if self.db.profile.currentonly then
			SVT:GetModule("Bar"):Stop()
		end
		
		self.target = target
		local victim, timeleft = self:GetTargetInfo()
		if victim and timeleft and self.db.profile.enable then
			SVT:GetModule("Bar"):Start(victim, timeleft, "Interface\\Icons\\Spell_Shadow_BlackPlague")
		end
	end
end

-- reset data if you change your target
function SVT:PLAYER_TARGET_CHANGED(msg)
	if not self:IsEventScheduled("ShadowVulneReckeckTargetChange") then
		self:ScheduleEvent("ShadowVulneReckeckTargetChange", self.RecheckTargetChange, 0.1, self)
	end
end


-----------------------
-- Utility Functions --
-----------------------
function SVT:GetTargetInfo()
	for k, v in pairs(self.debuffs) do
		if k == self.target then
			local timeleft = 15 - (GetTime() - v)
			if timeleft > 0 then
				return k, timeleft
			end
		end
	end
	return false
end

function SVT:HasDebuff(iconPath)
	for i = 1, 16 do
		local debuff = UnitDebuff("target", i)
		if debuff and debuff == iconPath then
			return true
		end
	end
	
	return false
end

function SVT:HasShadowVulnerability()
	return SVT:HasDebuff("Interface\\Icons\\Spell_Shadow_BlackPlague")
end

function SVT:TestBar()
	SVT:GetModule("Bar"):Start("Test", 15, "Interface\\Icons\\Spell_Shadow_BlackPlague")
end