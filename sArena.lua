local AddonName, sArena = ...

-- Default Settings
sArena.DefaultSettings = {
	Version = GetAddOnMetadata(AddonName, "Version"),
	Lock = false,
	TestMode = false,
	Position = {"RIGHT", "RIGHT", -150, 100},
	Scale = 1,
	GrowUpwards = false,
	ClassColours = {
		Health = true,
		Name = true,
		Frame = false,
	},
}

sArena.Frame = CreateFrame("Frame", nil, UIParent)
sArena.Frame:SetSize(200, 16)
sArena.Frame:SetMovable(true)
sArena.Frame:SetScript("OnEvent", function(self, event, ...) return sArena[event](sArena, ...) end)

sArena.Frame.TitleBar = CreateFrame("Frame", nil, sArena.Frame, "sArenaDragBarTemplate")
sArena.Frame.TitleBar:SetSize(200, 16)
sArena.Frame.TitleBar:SetPoint("TOP")
sArena.Frame.TitleBar:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" and not sArena.Frame.isMoving then
		sArena.Frame:StartMoving()
		sArena.Frame.isMoving = true
	end
end)
sArena.Frame.TitleBar:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" and sArena.Frame.isMoving then
		sArena.Frame:StopMovingOrSizing()
		sArena.Frame.isMoving = false
		sArenaDB.Position[1], _, sArenaDB.Position[2], sArenaDB.Position[3], sArenaDB.Position[4] = sArena.Frame:GetPoint()
	end
end)

sArena.Frame.TitleBar.Text = sArena.Frame.TitleBar:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
sArena.Frame.TitleBar.Text:SetText(AddonName)
sArena.Frame.TitleBar.Text:SetPoint("CENTER")

local function CombatLockdown()
	if InCombatLockdown() then
		print("sArena: Must leave combat before doing that!")
		return true
	end
end

function sArena:ADDON_LOADED(arg1)
	if arg1 == AddonName then
		if not sArenaDB or sArenaDB.Version ~= sArena.DefaultSettings.Version then
			sArenaDB = CopyTable(sArena.DefaultSettings)
			print("First time using sArena? Type /sarena for options!")
		end
		
		sArenaDB.TestMode = false
		
		sArena.Trinkets:ADDON_LOADED()
		sArena.AuraWatch:ADDON_LOADED()
		sArena.Settings:ADDON_LOADED()
		
		sArena.Frame:SetPoint(sArenaDB.Position[1], UIParent, sArenaDB.Position[2], sArenaDB.Position[3], sArenaDB.Position[4])
		sArena.Frame:SetScale(sArenaDB.Scale)
		
		for i = 1, MAX_ARENA_ENEMIES do
			local ArenaFrame = _G["ArenaEnemyFrame"..i]
			local ArenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
			local PrepFrame = _G["ArenaPrepFrame"..i]
			
			ArenaFrame:SetParent(self.Frame)
			ArenaPetFrame:SetParent(self.Frame)
			PrepFrame:SetParent(self.Frame)
			
			-- Improve positioning of class portraits
			ArenaFrame.classPortrait:SetSize(26, 26)
			ArenaFrame.classPortrait:ClearAllPoints()
			ArenaFrame.classPortrait:SetPoint("TOPRIGHT", ArenaFrame, -13, -6)
			PrepFrame.classPortrait:SetSize(26, 26)
			PrepFrame.classPortrait:ClearAllPoints()
			PrepFrame.classPortrait:SetPoint("TOPRIGHT", PrepFrame, -13, -6)
		end
		
		sArena:Lock()
		sArena:GrowUpwards()
	end
end
sArena.Frame:RegisterEvent("ADDON_LOADED")

function sArena:PLAYER_ENTERING_WORLD()
	sArena:TestMode(false)
	sArena.Trinkets:PLAYER_ENTERING_WORLD()
	sArena.AuraWatch:PLAYER_ENTERING_WORLD()
end
sArena.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")

function sArena:Lock(setting)
	if ( setting ) then sArenaDB.Lock = setting end
	
	sArena.Trinkets:Lock()
	
	if ( sArenaDB.Lock ) then
		sArena.Frame.TitleBar:Hide()
	else
		sArena.Frame.TitleBar:Show()
	end
end

function sArena:TestMode(setting)
	if ( setting ~= nil ) then
		sArenaDB.TestMode = setting
		sArenaSettings_TestMode:SetChecked(sArenaDB.TestMode)
	end
	
	local instanceType = select(2, IsInInstance())
	local showArenaEnemyPets = (SHOW_ARENA_ENEMY_PETS == "1")
	local _, class = UnitClass('player')
	local _, _, _, specIcon = GetSpecializationInfo(GetSpecialization() or 1)
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		if ( sArenaDB.TestMode ) then
			ArenaEnemyFrame_SetMysteryPlayer(ArenaFrame)
			ArenaEnemyFrame_Unlock(ArenaFrame)
			ArenaFrame.name:SetText("arena"..i)
			ArenaFrame.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			ArenaFrame.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			ArenaFrame.specBorder:Show()
			SetPortraitToTexture(ArenaFrame.specPortrait, specIcon)
			if showArenaEnemyPets then
				_G["ArenaEnemyFrame"..i.."PetFrame"]:Show()
				_G["ArenaEnemyFrame"..i.."PetFramePortrait"]:SetTexture("Interface\\CharacterFrame\\TempPortrait")
			end
		else
			if ( not instanceType == "pvp" or "arena" ) then
				ArenaFrame:Hide()
				_G["ArenaEnemyFrame"..i.."PetFrame"]:Hide()
			end
		end
	end
		
	sArena.Trinkets:TestMode()
	sArena.AuraWatch:TestMode()
end

function sArena:GrowUpwards(setting)
	if ( CombatLockdown() ) then return end
	if ( setting ~= nil ) then sArenaDB.GrowUpwards = setting end
	
	local instanceType = select(2, IsInInstance())
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		local PrepFrame = _G["ArenaPrepFrame"..i]
		
		ArenaFrame:ClearAllPoints()
		PrepFrame:ClearAllPoints()
		
		if ( sArenaDB.GrowUpwards ) then
			if ( i == 1 ) then
				ArenaFrame:SetPoint("BOTTOM", sArena.Frame, "TOP", 0, 20)
				PrepFrame:SetPoint("BOTTOM", sArena.Frame, "TOP", 0, 20)
			else
				ArenaFrame:SetPoint("BOTTOM", _G["ArenaEnemyFrame"..i-1], "TOP", 0, 20)
				PrepFrame:SetPoint("BOTTOM", _G["ArenaPrepFrame"..i-1], "TOP", 0, 20)
			end
		else
			if ( i == 1 ) then
				ArenaFrame:SetPoint("TOP", sArena.Frame, "BOTTOM")
				PrepFrame:SetPoint("TOP", sArena.Frame, "BOTTOM")
			else
				ArenaFrame:SetPoint("TOP", _G["ArenaEnemyFrame"..i-1], "BOTTOM", 0, -20)
				PrepFrame:SetPoint("TOP", _G["ArenaPrepFrame"..i-1], "BOTTOM", 0, -20)
			end
		end
		
		if instanceType ~= "pvp" then
			ArenaFrame:SetPoint("RIGHT", -2)
			PrepFrame:SetPoint("RIGHT", -2)
		else
			ArenaFrame:SetPoint("RIGHT", -18)
			PrepFrame:SetPoint("RIGHT", -18)
		end
	end
end

local HealthBars = {
	ArenaEnemyFrame1HealthBar = 1,
	ArenaEnemyFrame2HealthBar = 1,
	ArenaEnemyFrame3HealthBar = 1,
	ArenaEnemyFrame4HealthBar = 1,
	ArenaEnemyFrame5HealthBar = 1
}

function sArena:ClassColours(self)
	if HealthBars[self:GetName()] then
		local texture = _G[self:GetParent():GetName() .. "Texture"]
		local petTexture = _G[self:GetParent():GetName() .. "PetFrameTexture"]
		local specBorder = _G[self:GetParent():GetName() .. "SpecBorder"]
		local name = _G[self:GetParent():GetName() .. "Name"]
		local dead = ( UnitIsDead(self.unit) and not UnitAura(self.unit, "Feign Death") )
		
		texture:SetVertexColor(PlayerFrameTexture:GetVertexColor())
		petTexture:SetVertexColor(PlayerFrameTexture:GetVertexColor())
		specBorder:SetVertexColor(PlayerFrameTexture:GetVertexColor())
		name:SetTextColor(1, dead and 0 or 0.82, 0, 1)
		if dead then name:SetText(DEAD) end
		
		local _, class = UnitClass(self.unit)
		if not class then return end
		
		local c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		
		if sArenaDB.ClassColours.Health and not self.lockColor then self:SetStatusBarColor(c.r, c.g, c.b) end
		if sArenaDB.ClassColours.Frame then texture:SetVertexColor(c.r, c.g, c.b) specBorder:SetVertexColor(c.r, c.g, c.b) end
		if sArenaDB.ClassColours.Name and not dead then name:SetTextColor(c.r, c.g, c.b, 1) end
	end
end
hooksecurefunc("HealthBar_OnValueChanged", function(self) sArena:ClassColours(self) end)
hooksecurefunc("UnitFrameHealthBar_Update", function(self) sArena:ClassColours(self) end)
