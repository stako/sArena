local AddonName = ...
sArena = CreateFrame("Frame", nil, UIParent)
sArena:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
local BackdropLayout = { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = { left = 0, right = 0, top = 0, bottom = 0 } }

sArena.AddonName = AddonName

sArena:SetSize(200, 16)
sArena:SetBackdrop(BackdropLayout)
sArena:SetBackdropColor(0, 0, 0, .8)
sArena:SetClampedToScreen(true)
sArena:EnableMouse(true)
sArena:SetMovable(true)
sArena:RegisterForDrag("LeftButton")
sArena:Hide()

sArena.Title = sArena:CreateFontString(nil, "BACKGROUND")
sArena.Title:SetFontObject("GameFontHighlight")
sArena.Title:SetText(AddonName .. " (Click to drag)")
sArena.Title:SetPoint("CENTER", 0, 0)

sArena.Frame = CreateFrame("Frame", nil, UIParent)
sArena.Frame:SetSize(200, 1)
sArena.Frame:SetPoint("TOPLEFT", sArena, "BOTTOMLEFT", 0, 0)
sArena.Frame:SetPoint("TOPRIGHT", sArena, "BOTTOMRIGHT", 0, 0)

sArena:SetParent(sArena.Frame)

sArena.Defaults = {
	firstrun = true,
	version = 9,
	position = {},
	lock = false,
	scale = 1,
	castingBarScale = 1,
	flipCastingBar = false,
	classcolours = {
		health = true,
		name = true,
		frame = false,
	},
}

function sArena:Initialize()
	self.OptionsPanel:Initialize()
	
	self:SetPoint(sArenaDB.position.point or "RIGHT", _G["UIParent"], sArenaDB.position.relativePoint or "RIGHT", sArenaDB.position.x or -100, sArenaDB.position.y or 100)
	self.Frame:SetScale(sArenaDB.scale)
	
	if ( not sArenaDB.lock ) then
		self:Show()
	end
	
	local _
	self:SetScript("OnDragStart", function(s) s:StartMoving() end)
	self:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() sArenaDB.position.point, _, sArenaDB.position.relativePoint, sArenaDB.position.x, sArenaDB.position.y = s:GetPoint() end)
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaFrame:SetParent(self.Frame)
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame, true)
		
		local ArenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
		ArenaPetFrame:SetParent(self.Frame)
		
		local PrepFrame = _G["ArenaPrepFrame"..i]
		PrepFrame:SetParent(self.Frame)
		PrepFrame:SetPoint("RIGHT", self.Frame, "RIGHT", -2, 0)
		
		local CastingBar = _G["ArenaEnemyFrame"..i.."CastingBar"]
		CastingBar:SetScale(sArenaDB.castingBarScale)
		if sArenaDB.flipCastingBar then
			CastingBar:ClearAllPoints()
			CastingBar:SetPoint("LEFT", ArenaFrame, "RIGHT", 38, -3)
		end
		
		if ( i == 1 ) then
			ArenaFrame:SetPoint("TOP", self.Frame, "BOTTOM", 0, -8)
			PrepFrame:SetPoint("TOP", self.Frame, "BOTTOM", 0, -8)
		end
	end
	
	hooksecurefunc(ArenaPrepFrames, "Hide", function()
		if InCombatLockdown() then return end
		for i = 1, MAX_ARENA_ENEMIES do
			_G["ArenaPrepFrame"..i]:Hide()
		end
	end)
	
	hooksecurefunc("ArenaEnemyFrame_Lock", function(self) sArena:ColourHealthBars(self) end)
end

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
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame)
	end
end

function sArena:Test(numOpps)
	if ( self:CombatLockdown() ) then return end
	if ( not numOpps or not (numOpps > 0 and numOpps < 6) ) then return end
	
	self:HideArenaEnemyFrames()
	
	local showArenaEnemyPets = (SHOW_ARENA_ENEMY_PETS == "1")
	local instanceType = select(2, IsInInstance())
	local factionGroup = UnitFactionGroup('player')
	local _, class = UnitClass('player')
	local _, _, _,specIcon = GetSpecializationInfo(GetSpecialization())
	
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
		ArenaFrame.name:SetText(GetUnitName('player', false))
		ArenaFrame.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
		ArenaFrame.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
		ArenaFrame.specBorder:Show()
		SetPortraitToTexture(ArenaFrame.specPortrait, specIcon)
		if ( showArenaEnemyPets ) then
			_G["ArenaEnemyFrame"..i.."PetFrame"]:Show()
			_G["ArenaEnemyFrame"..i.."PetFramePortrait"]:SetTexture("Interface\\CharacterFrame\\TempPortrait")
		end
	end
end

function sArena:ADDON_LOADED(arg1)
	if ( arg1 == AddonName ) then
		if ( not sArenaDB or sArenaDB.version < sArena.Defaults.version ) then
			sArenaDB = CopyTable(sArena.Defaults)
		end
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
sArena:RegisterEvent("ADDON_LOADED")

local HealthBars = {
	ArenaEnemyFrame1HealthBar = 1,
	ArenaEnemyFrame2HealthBar = 1,
	ArenaEnemyFrame3HealthBar = 1,
	ArenaEnemyFrame4HealthBar = 1,
	ArenaEnemyFrame5HealthBar = 1
}
function sArena:ColourHealthBars(self)
	if (HealthBars[self:GetName()]) then
		local texture = _G[self:GetParent():GetName() .. "Texture"]
		local specBorder = _G[self:GetParent():GetName() .. "SpecBorder"]
		local name = _G[self:GetParent():GetName() .. "Name"]
		
		texture:SetVertexColor(1, 1, 1)
		specBorder:SetVertexColor(1, 1, 1)
		name:SetTextColor(1, 0.82, 0, 1)
		
		local _, class = UnitClass(self.unit)
		if not class then return end
		
		local c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		
		if sArenaDB.classcolours.health and not self.lockColor then self:SetStatusBarColor(c.r, c.g, c.b) end
		if sArenaDB.classcolours.frame then texture:SetVertexColor(c.r, c.g, c.b) specBorder:SetVertexColor(c.r, c.g, c.b) end
		if sArenaDB.classcolours.name then name:SetTextColor(c.r, c.g, c.b, 1) end
	end
end
hooksecurefunc("HealthBar_OnValueChanged", function(self) sArena:ColourHealthBars(self) end)
hooksecurefunc("UnitFrameHealthBar_Update", function(self) sArena:ColourHealthBars(self) end)