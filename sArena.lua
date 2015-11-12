local AddonName, sArena = ...

-- Default Settings
sArena.DefaultSettings = {
	Version = "1.2.1", -- Last version of sArena in which the settings table changed
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
	CastingBar = {
		Scale = 1,
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
		
		self.Trinkets:ADDON_LOADED()
		self.AuraWatch:ADDON_LOADED()
		self.Settings:ADDON_LOADED()
		
		self.Frame:SetPoint(sArenaDB.Position[1], UIParent, sArenaDB.Position[2], sArenaDB.Position[3], sArenaDB.Position[4])
		self.Frame:SetScale(sArenaDB.Scale)
		
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
			
			self.CastingBar:CreateTestBar(_G["ArenaEnemyFrame"..i.."CastingBar"])
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
	if ( setting ~= nil ) then
		sArenaDB.Lock = setting
		sArenaSettings_Lock:SetChecked(sArenaDB.Lock)
	end
	
	sArena.Trinkets:Lock()
	
	if ( sArenaDB.Lock ) then
		sArena.Frame.TitleBar:Hide()
		sArena.CastingBar.TitleBar:Hide()
	else
		sArena.Frame.TitleBar:Show()
		sArena.CastingBar.TitleBar:Show()
	end
end

function sArena:TestMode(setting)
	if ( setting ~= nil ) then
		sArenaDB.TestMode = setting
		sArenaSettings_TestMode:SetChecked(sArenaDB.TestMode)
	end
	
	if ( CombatLockdown() ) then return end
	
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
			
			local _, class = UnitClass('player')
			if class then
				local c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				if sArenaDB.ClassColours.Health then ArenaFrame.healthbar:SetStatusBarColor(c.r, c.g, c.b) end
				if sArenaDB.ClassColours.Name then ArenaFrame.name:SetTextColor(c.r, c.g, c.b, 1) else ArenaFrame.name:SetTextColor(1, 0.82, 0, 1) end
				if sArenaDB.ClassColours.Frame then _G["ArenaEnemyFrame"..i.."Texture"]:SetVertexColor(c.r, c.g, c.b, 1) else _G["ArenaEnemyFrame"..i.."Texture"]:SetVertexColor(PlayerFrameTexture:GetVertexColor()) end
			end
			
			sArena.CastingBar["arena"..i]:Show()
		else
			if ( not instanceType == "pvp" or "arena" ) then
				ArenaFrame:Hide()
				_G["ArenaEnemyFrame"..i.."PetFrame"]:Hide()
			end
			
			sArena.CastingBar["arena"..i]:Hide()
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
		
		-- Need to figure out how to tell when hunters are truly dead
		--local dead = ( UnitIsDead(self.unit) and not UnitAura(self.unit, "Feign Death") )
		local dead = false
		
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

sArena.CastingBar = {}
function sArena.CastingBar:CreateTestBar(frame)
	local id = frame:GetParent():GetID()
	local CastingBar = CreateFrame("StatusBar", "sArenaCastingBar"..id, frame:GetParent(), "sArenaCastingBarTemplate")
	CastingBar:SetAllPoints(frame)
	frame:SetMovable(true)
	frame:SetScale(sArenaDB.CastingBar.Scale)
	
	if ( sArenaDB.CastingBar.Point ) then
		frame:ClearAllPoints()
		frame:SetPoint(sArenaDB.CastingBar.Point, frame:GetParent(), sArenaDB.CastingBar.X, sArenaDB.CastingBar.Y)
	end
	
	self["arena"..id] = CastingBar
	_G["sArenaCastingBar"..id.."Icon"]:SetAllPoints(_G["ArenaEnemyFrame"..id.."CastingBarIcon"])
	
	if ( id == 1 ) then
		self.TitleBar = CreateFrame("Frame", nil, self["arena1"], "sArenaDragBarTemplate")
		self.TitleBar:SetPoint("BOTTOMLEFT", self["arena1"], "TOPLEFT")
		self.TitleBar:SetPoint("BOTTOMRIGHT", self["arena1"], "TOPRIGHT")
		self.TitleBar:SetHeight(16)
		
		self.TitleBar:SetScript("OnMouseDown", function(self, button)
			if ( button == "LeftButton" and not frame.isMoving ) then
				frame:StartMoving()
				frame.isMoving = true
			end
		end)
	
		self.TitleBar:SetScript("OnMouseUp", function(self, button)
			if ( button == "LeftButton" and frame.isMoving ) then
				frame:StopMovingOrSizing()
				frame:SetUserPlaced(false)
				frame.isMoving = false
				
				local sX, sY = frame:GetCenter()
				local pX, pY = frame:GetParent():GetCenter()
				local scale = frame:GetScale()
				sX, sY = floor(sX * scale), floor(sY * scale)
				pX, pY = floor(pX), floor(pY)
				sX, sY = floor((pX-sX)*(-1)), floor((pY-sY)*(-1))
				
				for i = 1, MAX_ARENA_ENEMIES do
					CastingBar = _G["ArenaEnemyFrame"..i.."CastingBar"]
					
					CastingBar:ClearAllPoints()
					CastingBar:SetPoint("CENTER", CastingBar:GetParent(), sX/scale, sY/scale)
				end
				
				sArenaDB.CastingBar.Point, _, _, sArenaDB.CastingBar.X, sArenaDB.CastingBar.Y = frame:GetPoint()
			end
		end)
	end
end
