local AddonName, sArena = ...

local BackdropLayout = { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = { left = 0, right = 0, top = 0, bottom = 0 } }

-- Create the drag frame.
sArena.DragFrame = CreateFrame("Frame", nil, UIParent)
sArena.DragFrame:SetSize(200, 16)
sArena.DragFrame:SetBackdrop(BackdropLayout)
sArena.DragFrame:SetBackdropColor(0, 0, 0, .8)
sArena.DragFrame:SetClampedToScreen(true)
sArena.DragFrame:EnableMouse(true)
sArena.DragFrame:SetMovable(true)
sArena.DragFrame:RegisterForDrag("LeftButton")
sArena.DragFrame:Hide()

sArena.DragFrame.Title = sArena.DragFrame:CreateFontString(nil, "BACKGROUND")
sArena.DragFrame.Title:SetFontObject("GameFontHighlight")
sArena.DragFrame.Title:SetText(AddonName .. " (Click to drag)")
sArena.DragFrame.Title:SetPoint("CENTER", 0, 0)

--[[Create a frame to replace "ArenaEnemyFrames" and "ArenaPrepFrames".
	We replace these frames because they get moved around when
	multi-seater mounts are used or when the repair indicator is shown.]]
sArena.Frame = CreateFrame("Frame", nil, UIParent)
sArena.Frame:SetSize(200, 1)
sArena.Frame:SetPoint("TOPLEFT", sArena.DragFrame, "BOTTOMLEFT", 0, 0)
sArena.Frame:SetPoint("TOPRIGHT", sArena.DragFrame, "BOTTOMRIGHT", 0, 0)
sArena.Frame:SetScript("OnEvent", function(self, event, ...) return sArena[event](sArena, ...) end)

sArena.DragFrame:SetParent(sArena.Frame)

-- Default settings
sArena.Defaults = {
	firstrun = true,
	version = 11,
	position = {},
	lock = false,
	growUpwards = false,
	scale = 1,
	statusTextSize = 10,
	castingBarScale = 1,
	flipCastingBar = false,
	classcolours = {
		health = true,
		name = true,
		frame = false,
	},
}

-- Initialize function. Called by sArena:ADDON_LOADED()
function sArena:Initialize()
	-- Set position and scale of sArena frame.
	self.DragFrame:SetPoint(sArenaDB.position.point or "RIGHT", _G["UIParent"], sArenaDB.position.relativePoint or "RIGHT", sArenaDB.position.x or -100, sArenaDB.position.y or 100)
	self.Frame:SetScale(sArenaDB.scale)
	
	-- Show sArena anchor if it's unlocked in options
	if ( not sArenaDB.lock ) then
		self.DragFrame:Show()
	end
	
	-- Create drag functionality for sArena anchor
	local _
	self.DragFrame:SetScript("OnDragStart", function(s) s:StartMoving() end)
	self.DragFrame:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() sArenaDB.position.point, _, sArenaDB.position.relativePoint, sArenaDB.position.x, sArenaDB.position.y = s:GetPoint() end)
	
	-- Change parent of each arena frame from ArenaEnemyFrames/ArenaPrepFrames to sArena.Frame
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaFrame:SetParent(self.Frame)
		ArenaFrame.classPortrait:SetSize(26, 26)
		ArenaFrame.classPortrait:ClearAllPoints()
		ArenaFrame.classPortrait:SetPoint("TOPRIGHT", ArenaFrame, -13, -6)
		
		local ArenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
		ArenaPetFrame:SetParent(self.Frame)
		
		local PrepFrame = _G["ArenaPrepFrame"..i]
		PrepFrame:SetParent(self.Frame)
		PrepFrame.classPortrait:SetSize(26, 26)
		PrepFrame.classPortrait:ClearAllPoints()
		PrepFrame.classPortrait:SetPoint("TOPRIGHT", PrepFrame, -13, -6)
		
		-- Set status text size
		_G["ArenaEnemyFrame"..i.."HealthBarText"]:SetFont("Fonts\\FRIZQT__.TTF", sArenaDB.statusTextSize, "OUTLINE")
		_G["ArenaEnemyFrame"..i.."ManaBarText"]:SetFont("Fonts\\FRIZQT__.TTF", sArenaDB.statusTextSize, "OUTLINE")
		
		-- Scale and position casting bars
		local CastingBar = _G["ArenaEnemyFrame"..i.."CastingBar"]
		self:CreateCastingBar(CastingBar)
		CastingBar:SetScale(sArenaDB.castingBarScale)
		if sArenaDB.flipCastingBar then
			CastingBar:ClearAllPoints()
			CastingBar:SetPoint("LEFT", ArenaFrame, "RIGHT", 38, -3)
		end
	end
	
	self:Placement()
	
	--[[Prep frames were showing outside of arena after leaving a match before match start.
		Fixed this by hooking ArenaPrepFrames:Hide() and hiding each prep frame]]
	hooksecurefunc(ArenaPrepFrames, "Hide", function()
		if InCombatLockdown() then return end
		for i = 1, MAX_ARENA_ENEMIES do
			_G["ArenaPrepFrame"..i]:Hide()
		end
	end)
	
	hooksecurefunc("ArenaEnemyFrame_Lock", function(self) sArena:ClassColours(self) end)
	
	self.Trinkets:Initialize()
	self.AuraWatch:Initialize()
	self.OptionsPanel:Initialize()
end

-- Called by sArena:Initialize() or when some options are changed.
function sArena:Placement()
	local instanceType = select(2, IsInInstance())
	
	-- Set position of each arena and prep frame. Position changes depending on growUpwards option.
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		local PrepFrame = _G["ArenaPrepFrame"..i]
		
		ArenaFrame:ClearAllPoints()
		PrepFrame:ClearAllPoints()
		
		if sArenaDB.growUpwards then
			if ( i == 1 ) then
				ArenaFrame:SetPoint("BOTTOM", self.Frame, "TOP", 0, 40)
				PrepFrame:SetPoint("BOTTOM", self.Frame, "TOP", 0, 40)
			else
				ArenaFrame:SetPoint("BOTTOM", _G["ArenaEnemyFrame"..i-1], "TOP", 0, 20)
				PrepFrame:SetPoint("BOTTOM", _G["ArenaPrepFrame"..i-1], "TOP", 0, 20)
			end
		else
			if ( i == 1 ) then
				ArenaFrame:SetPoint("TOP", self.Frame, "BOTTOM", 0, -8)
				PrepFrame:SetPoint("TOP", self.Frame, "BOTTOM", 0, -8)
			else
				ArenaFrame:SetPoint("TOP", _G["ArenaEnemyFrame"..i-1], "BOTTOM", 0, -20)
				PrepFrame:SetPoint("TOP", _G["ArenaPrepFrame"..i-1], "BOTTOM", 0, -20)
			end
		end
		
		PrepFrame:SetPoint("RIGHT", self.Frame, "RIGHT", -2, 0)
		
		-- Frames are moved a little bit when inside of battlegrounds to make room for faction icons.
		if ( instanceType ~= "pvp" ) then
			ArenaFrame:SetPoint("RIGHT", ArenaFrame:GetParent(), "RIGHT", -2, 0)
		else
			ArenaFrame:SetPoint("RIGHT", ArenaFrame:GetParent(), "RIGHT", -18, 0)
		end
	end
end

-- Used when handling secure frames.
function sArena:CombatLockdown()
	if ( InCombatLockdown() ) then
		print("sArena: Must leave combat before doing that!")
		return true
	end
end

function sArena:HideArenaEnemyFrames()
	if ( self:CombatLockdown() ) then return end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaEnemyFrame_Unlock(ArenaFrame)
		ArenaFrame:Hide()
		_G["ArenaEnemyFrame"..i.."PetFrame"]:Hide()
		self["TestCastingBar"..i]:Hide()
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame)
	end
end

-- Test mode
function sArena:Test(numOpps)
	if ( self:CombatLockdown() ) then return end
	if ( not numOpps or not (numOpps > 0 and numOpps < 6) ) then return end
	
	self:HideArenaEnemyFrames()
	
	local showArenaEnemyPets = (SHOW_ARENA_ENEMY_PETS == "1")
	local instanceType = select(2, IsInInstance())
	local factionGroup = UnitFactionGroup('player')
	local _, class = UnitClass('player')
	local _, _, _, specIcon = GetSpecializationInfo(GetSpecialization())
	
	for i = 1, numOpps do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		local PVPIcon = _G["ArenaEnemyFrame"..i.."PVPIcon"]
		if ( instanceType ~= "pvp" ) then
			ArenaFrame:SetPoint("RIGHT", ArenaFrame:GetParent(), "RIGHT", -2, 0)
			PVPIcon:Hide()
		else
			ArenaFrame:SetPoint("RIGHT", ArenaFrame:GetParent(), "RIGHT", -18, 0)
			PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
			PVPIcon:Show()
		end
		ArenaEnemyFrame_SetMysteryPlayer(ArenaFrame)
		ArenaEnemyFrame_Unlock(ArenaFrame)
		ArenaFrame.name:SetText("arena"..i)
		ArenaFrame.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
		ArenaFrame.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
		ArenaFrame.specBorder:Show()
		self["TestCastingBar"..i]:Show()
		SetPortraitToTexture(ArenaFrame.specPortrait, specIcon)
		if ( showArenaEnemyPets ) then
			_G["ArenaEnemyFrame"..i.."PetFrame"]:Show()
			_G["ArenaEnemyFrame"..i.."PetFramePortrait"]:SetTexture("Interface\\CharacterFrame\\TempPortrait")
		end
	end
end

function sArena:ADDON_LOADED(arg1)
	if ( arg1 == AddonName ) then
		-- Create database for options, or update database for new version of sArena.
		if ( not sArenaDB or sArenaDB.version ~= sArena.Defaults.version ) then
			sArenaDB = CopyTable(sArena.Defaults)
		end
		-- Load Blizzard_ArenaUI.
		if ( not IsAddOnLoaded("Blizzard_ArenaUI") ) then
			LoadAddOn("Blizzard_ArenaUI")
		end
		self:Initialize()
		if ( sArenaDB.firstrun ) then
			sArenaDB.firstrun = false
			print("Looks like this is your first time running this version of sArena! Type /sarena for options.")
		end
	end
end
sArena.Frame:RegisterEvent("ADDON_LOADED")

local HealthBars = {
	ArenaEnemyFrame1HealthBar = 1,
	ArenaEnemyFrame2HealthBar = 1,
	ArenaEnemyFrame3HealthBar = 1,
	ArenaEnemyFrame4HealthBar = 1,
	ArenaEnemyFrame5HealthBar = 1
}

function sArena:ClassColours(self)
	-- Check if self == an arena frame health bar
	if (HealthBars[self:GetName()]) then
		local texture = _G[self:GetParent():GetName() .. "Texture"]
		local specBorder = _G[self:GetParent():GetName() .. "SpecBorder"]
		local name = _G[self:GetParent():GetName() .. "Name"]
		
		-- Set default colours
		texture:SetVertexColor(1, 1, 1)
		specBorder:SetVertexColor(1, 1, 1)
		name:SetTextColor(1, 0.82, 0, 1)
		
		local _, class = UnitClass(self.unit)
		if not class then return end
		
		local c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		
		-- Set colours if options are enabled
		if sArenaDB.classcolours.health and not self.lockColor then self:SetStatusBarColor(c.r, c.g, c.b) end
		if sArenaDB.classcolours.frame then texture:SetVertexColor(c.r, c.g, c.b) specBorder:SetVertexColor(c.r, c.g, c.b) end
		if sArenaDB.classcolours.name then name:SetTextColor(c.r, c.g, c.b, 1) end
	end
end
hooksecurefunc("HealthBar_OnValueChanged", function(self) sArena:ClassColours(self) end)
hooksecurefunc("UnitFrameHealthBar_Update", function(self) sArena:ClassColours(self) end)

function sArena:CreateCastingBar(frame)
	local castingbar = CreateFrame("StatusBar", nil, frame:GetParent())
	castingbar:SetAllPoints(frame)
	castingbar:SetMinMaxValues(0, 100)
	castingbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	castingbar:SetStatusBarColor(1.0, 0.7, 0.0)
	castingbar:SetValue(100)
	castingbar:Hide()
	
	castingbar.Icon = castingbar:CreateTexture(nil, "ARTWORK")
	castingbar.Icon:SetAllPoints(_G[frame:GetName().."Icon"])
	castingbar.Icon:SetPoint("RIGHT", castingbar, "LEFT", -5, 0)
	castingbar.Icon:SetTexture("Interface\\Icons\\spell_shadow_possession")
	
	local id = frame:GetParent():GetID()
	self["TestCastingBar"..id] = castingbar
end
