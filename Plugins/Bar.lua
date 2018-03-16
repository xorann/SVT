local _, class = UnitClass("player")
if class ~= "PRIEST" then
	return
end

assert( SVT, "SVT not found!")


------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("SVT")
local paint = AceLibrary("PaintChips-2.0")
local minscale, maxscale = 0.25, 2
local candybar = AceLibrary("CandyBar-2.1")
local surface = AceLibrary("Surface-1.0")

----------------------------------
--      Module Declaration      --
----------------------------------
--local Bar = SVT:NewModule(L["Bar"])
local Bar = SVT:NewModule("Bar")
Bar.revision = 1
Bar.consoleCmd = L["bar"]

Bar.consoleOptions = {
	type = "group",
	name = L["Bar"],
	desc = L["Options for the bar plugin."],
	args   = {
		anchor = {
			type = "execute",
			name = L["Show anchor"],
			desc = L["Show the bar anchor frame."],
            order = 1,
			func = function() Bar:SVT_ShowAnchors() end,
		},
        reset = {
			type = "execute",
			name = L["Reset position"],
			desc = L["Reset the anchor position, moving it to the original position."],
			order = 2,
			func = function() Bar:ResetAnchor() end,
		},
		scale = {
			type = "range",
			name = L["Scale"],
			desc = L["Set the frame scale."],
            order = 15,
			min = 0.2,
			max = 2.0,
			step = 0.1,
			get = function() return Bar.db.profile.scale end,
			set = function(v) Bar.db.profile.scale = v end,
		},
		texture = {
			type = "text",
			name = L["Texture"],
			desc = L["Set the texture for the timerbars."],
            order = 16,
			get = function() return Bar.db.profile.texture end,
			set = function(v) Bar.db.profile.texture = v end,
			validate = surface:List(),
        },
	},
}
SVT.cmdtable.args[L["Bar"]] = Bar.consoleOptions
Bar.defaultDB = {
	scale = 1.0,
	texture = "BantoBar",
    
    posx = nil,
    posy = nil,
	
	bossName = nil,
}
local barId

if Bar.db and Bar.RegisterDefaults and type(Bar.RegisterDefaults) == "function" then
	Bar:RegisterDefaults("profile", Bar.defaultDB or {})
else
	SVT:RegisterDefaults("Bar", "profile", Bar.defaultDB or {})
end

if not Bar.db then
	Bar.db = SVT:AcquireDBNamespace("Bar")
end

------------------------------
--      Initialization      --
------------------------------
function Bar:OnRegister()
	self.consoleOptions.args.texture.validate = surface:List()
    self:RegisterEvent("Surface_Registered", function()
		self.consoleOptions.args.texture.validate = surface:List()
    end)
end

function Bar:OnEnable()
	if not surface:Fetch(self.db.profile.texture) then 
		Bar.db.profile.texture = "BantoBar" 
	end
	
	self:SetupFrames()
    self:RegisterEvent("SVT_Bar", "Start")
    self:RegisterEvent("SVT_BarStop", "Stop")
	self:RegisterEvent("SVT_ShowAnchors")
	self:RegisterEvent("SVT_HideAnchors")
	--self:RegisterEvent("SVT_StartBar")
	--self:RegisterEvent("SVT_StopBar")
	
	if not self:IsEventRegistered("Surface_Registered") then 
	    self:RegisterEvent("Surface_Registered", function()
			self.consoleOptions.args[L["Texture"]].validate = surface:List()
	    end)
	end
end


------------------------------
--      Event Handlers      --
------------------------------

function Bar:Start(text, time, icon)
	if time then
		barId = self:CreateBar(text, time, icon, "purple")
	end
end

function Bar:Stop()
	if barId then
		self:UnregisterCandyBar(barId)
	end
end

function Bar:ChangeColor(text, color)
	local id = "Bar " .. text
	self:SetCandyBarColor(id, color, 1)
end

function Bar:CreateBar(text, time, icon, color)
	if text and time then
		local id = "Bar " .. text
		if not icon then
			icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01"
		end
		
		-- yes we try and register every time, we also set the point every time since people can change their mind midbar.
		self:RegisterCandyBarGroup("SVTBarGroup")
		self:SetCandyBarGroupPoint("SVTBarGroup", "BOTTOM", self.frames.anchor, "TOP", 0, 0)
		self:SetCandyBarGroupGrowth("SVTBarGroup", true)

		self:RegisterCandyBar(id, 15, text, icon, color)
		self:RegisterCandyBarWithGroup(id, "SVTBarGroup")
		self:SetCandyBarTexture(id, surface:Fetch(self.db.profile.texture))

		self:SetCandyBarScale(id, self.db.profile.scale or 1)
		self:SetCandyBarWidth(id, 185)
		self:SetCandyBarFade(id, .5)
		self:StartCandyBar(id, true)
		
		self:SetCandyBarTimeLeft(id, time)
		
		return id
	end
	
	return false
end


function Bar:SVT_ShowAnchors()
	self.frames.anchor:Show()
end

function Bar:SVT_HideAnchors()
	self.frames.anchor:Hide()
end

------------------------------
--      Slash Handlers      --
------------------------------

function Bar:SetScale(msg, supressreport)
	local scale = tonumber(msg)
	if scale and scale >= minscale and scale <= maxscale then
		SVT.db.profile.scale = scale
		if not supressreport then self.core:Print(L["Scale is set to %s"], scale) end
	end
end


------------------------------
--    Create the Anchor     --
------------------------------

function Bar:SetupFrames()
	local f, t	

	f, _, _ = GameFontNormal:GetFont()

	self.frames = {}
	self.frames.anchor = CreateFrame("Frame", "SVTBarAnchor", UIParent)
	self.frames.anchor.owner = self
	self.frames.anchor:Hide()

	self.frames.anchor:SetWidth(175)
	self.frames.anchor:SetHeight(75)
	self.frames.anchor:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
	self.frames.anchor:SetBackdropBorderColor(.5, .5, .5)
	self.frames.anchor:SetBackdropColor(0,0,0)
	self.frames.anchor:ClearAllPoints()
	self.frames.anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	self.frames.anchor:EnableMouse(true)
	self.frames.anchor:RegisterForDrag("LeftButton")
	self.frames.anchor:SetMovable(true)
	self.frames.anchor:SetScript("OnDragStart", function() this:StartMoving() end)
	self.frames.anchor:SetScript("OnDragStop", function() this:StopMovingOrSizing() this.owner:SavePosition() end)


	self.frames.cfade = self.frames.anchor:CreateTexture(nil, "BORDER")
	self.frames.cfade:SetWidth(169)
	self.frames.cfade:SetHeight(25)
	self.frames.cfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	self.frames.cfade:SetPoint("TOP", self.frames.anchor, "TOP", 0, -4)
	self.frames.cfade:SetBlendMode("ADD")
	self.frames.cfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .25, .25, .25, 1)
	self.frames.anchor.Fade = self.frames.fade

	self.frames.cheader = self.frames.anchor:CreateFontString(nil,"OVERLAY")
	self.frames.cheader:SetFont(f, 14)
	self.frames.cheader:SetWidth(150)
	self.frames.cheader:SetText(L["Bar"])
	self.frames.cheader:SetTextColor(1, .8, 0)
	self.frames.cheader:ClearAllPoints()
	self.frames.cheader:SetPoint("TOP", self.frames.anchor, "TOP", 0, -10)
	
	self.frames.leftbutton = CreateFrame("Button", nil, self.frames.anchor)
	self.frames.leftbutton.owner = self
	self.frames.leftbutton:SetWidth(40)
	self.frames.leftbutton:SetHeight(25)
	self.frames.leftbutton:SetPoint("RIGHT", self.frames.anchor, "CENTER", -10, -15)
	self.frames.leftbutton:SetScript( "OnClick", function()  self:TriggerEvent("SVT_Test") end )

	
	t = self.frames.leftbutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", self.frames.leftbutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	self.frames.leftbutton:SetNormalTexture(t)

	t = self.frames.leftbutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(self.frames.leftbutton)
	self.frames.leftbutton:SetPushedTexture(t)
	
	t = self.frames.leftbutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(self.frames.leftbutton)
	t:SetBlendMode("ADD")
	self.frames.leftbutton:SetHighlightTexture(t)
	self.frames.leftbuttontext = self.frames.leftbutton:CreateFontString(nil,"OVERLAY")
	self.frames.leftbuttontext:SetFontObject(GameFontHighlight)
	self.frames.leftbuttontext:SetText(L["Test"])
	self.frames.leftbuttontext:SetAllPoints(self.frames.leftbutton)
    
	self.frames.rightbutton = CreateFrame("Button", nil, self.frames.anchor)
	self.frames.rightbutton.owner = self
	self.frames.rightbutton:SetWidth(40)
	self.frames.rightbutton:SetHeight(25)
	self.frames.rightbutton:SetPoint("LEFT", self.frames.anchor, "CENTER", 10, -15)
	self.frames.rightbutton:SetScript( "OnClick", function() self:SVT_HideAnchors() end )
    

	
	t = self.frames.rightbutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", self.frames.rightbutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	self.frames.rightbutton:SetNormalTexture(t)

	t = self.frames.rightbutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(self.frames.rightbutton)
	self.frames.rightbutton:SetPushedTexture(t)
	
	t = self.frames.rightbutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(self.frames.rightbutton)
	t:SetBlendMode("ADD")
	self.frames.rightbutton:SetHighlightTexture(t)
	self.frames.rightbuttontext = self.frames.rightbutton:CreateFontString(nil,"OVERLAY")
	self.frames.rightbuttontext:SetFontObject(GameFontHighlight)
	self.frames.rightbuttontext:SetText(L["Close"])
	self.frames.rightbuttontext:SetAllPoints(self.frames.rightbutton)

	self:RestorePosition()
end


function Bar:SavePosition()
	local f = self.frames.anchor
	local s = f:GetEffectiveScale()
		
	self.db.profile.posx = f:GetLeft() * s
	self.db.profile.posy = f:GetTop() * s	
end


function Bar:RestorePosition()
	local x = self.db.profile.posx
	local y = self.db.profile.posy
		
	if not x or not y then return end
				
	local f = self.frames.anchor
	local s = f:GetEffectiveScale()

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
end

function Bar:ResetAnchor()
	if not self.frames.anchor then 
		self:SetupFrames() 
	end
	
	self.frames.anchor:ClearAllPoints()
	self.frames.anchor:SetPoint("CENTER", UIParent, "CENTER")
	self.db.profile.posx = nil
	self.db.profile.posy = nil
end