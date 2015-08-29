-- Default Settings
local DefaultSettings = {
	Version = GetAddOnMetadata("sArena", "Version"),
	Lock = false,
	TestMode = false,
	Scale = 1,
	ClassColours = {
		Health = true,
		Name = true,
		Frame = false,
	},
	Trinket = {
		Enabled = true,
		CooldownFontSize = 7,
		AlwaysShow = true,
		Scale = 1,
	},
}

local function sArena_Settings()
		-- Copy Default Settings into SavedVariables table if necessary (never used sArena or new version)
		if ( not sArenaDB or sArenaDB.Version ~= DefaultSettings.Version ) then
			sArenaDB = CopyTable(DefaultSettings)
			print("First time using sArena? Type /sarena for options!")
		end
		sArenaDB.TestMode = false
end

function sArena_OnEvent(self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		sArena_Settings()
		
		self:SetScale(sArenaDB.Scale)
		
		sArena_Lock()
		
		for i = 1, MAX_ARENA_ENEMIES do
			local ArenaFrame = _G["ArenaEnemyFrame"..i]
			local ArenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
			local PrepFrame = _G["ArenaPrepFrame"..i]
			
			ArenaFrame:SetParent(self)
			ArenaPetFrame:SetParent(self)
			PrepFrame:SetParent(self)
			
			if ( i == 1 ) then
				ArenaFrame:SetPoint("TOP", self, "BOTTOM")
				PrepFrame:SetPoint("TOP", self, "BOTTOM")
			end
			
			ArenaFrame:SetPoint("RIGHT", -2)
			PrepFrame:SetPoint("RIGHT", -2)
			
			-- Improve positioning of class portraits
			ArenaFrame.classPortrait:SetSize(26, 26)
			ArenaFrame.classPortrait:ClearAllPoints()
			ArenaFrame.classPortrait:SetPoint("TOPRIGHT", ArenaFrame, -13, -6)
			PrepFrame.classPortrait:SetSize(26, 26)
			PrepFrame.classPortrait:ClearAllPoints()
			PrepFrame.classPortrait:SetPoint("TOPRIGHT", PrepFrame, -13, -6)
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		sArena_TestMode(false)
	end
end

function sArena_Lock(setting)
	if ( setting ) then sArenaDB.Lock = setting end
	
	if ( sArenaDB.Lock ) then
		sArenaTitleBar:Hide()
		sArenaTrinketTitleBar:Hide()
	else
		sArenaTitleBar:Show()
		sArenaTrinketTitleBar:Show()
	end
end

function sArena_TestMode(setting)
	if ( setting ~= nil ) then sArenaDB.TestMode = setting end
	
	local instanceType = select(2, IsInInstance())
	local showArenaEnemyPets = (SHOW_ARENA_ENEMY_PETS == "1")
	local _, class = UnitClass('player')
	local _, _, _, specIcon = GetSpecializationInfo(GetSpecialization() or 1)
	
		for i = 1, MAX_ARENA_ENEMIES do
			local ArenaFrame = _G["ArenaEnemyFrame"..i]
			local TrinketCooldown = sArena["Trinket"..i.."Cooldown"]
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
				CooldownFrame_SetTimer(TrinketCooldown, GetTime(), 120, 1, true)
			else
				if ( not instanceType == "pvp" or "arena" ) then
					ArenaFrame:Hide()
					_G["ArenaEnemyFrame"..i.."PetFrame"]:Hide()
				end
				CooldownFrame_SetTimer(TrinketCooldown, 0, 0, 0, true)
			end
		end
end

function sArena_Trinket_OnEvent(self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		sArena_Settings()
		
		self:GetParent():SetScale(sArenaDB.Trinket.Scale)
		
		for _, region in next, {self:GetRegions()} do
			if region:GetObjectType() == "FontString" then
				self.Text = region
			end
		end
		self.Text:SetFont("Fonts\\FRIZQT__.TTF", sArenaDB.Trinket.CooldownFontSize, "OUTLINE")
		self:GetParent():SetAlpha(sArenaDB.Trinket.AlwaysShow and 1 or 0)
		if ( sArenaDB.Trinket.Point ) then
			self:GetParent():ClearAllPoints()
			self:GetParent():SetPoint(sArenaDB.Trinket.Point, self:GetParent():GetParent(), sArenaDB.Trinket.X, sArenaDB.Trinket.Y)
		end
		
		hooksecurefunc(self, "SetCooldown", function() sArena_Trinket_AlwaysShow() end)
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		local instanceType = select(2, IsInInstance())
		if ( sArenaDB.Trinket.Enabled and instanceType == "arena" ) then
			self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		elseif ( self:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") ) then
			self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		end
		CooldownFrame_SetTimer(self, 0, 0, 0, true)
		
	elseif ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
		local unitID, spell = ...
		if ( unitID ~= "arena"..self:GetID() ) then return end
		
		if ( spell == GetSpellInfo(42292) or spell == GetSpellInfo(59752) )  then -- Trinket and EMFH
			CooldownFrame_SetTimer(self, GetTime(), 120, 1, true)
		elseif spell == GetSpellInfo(7744) then -- WOTF
			-- When WOTF is used, set cooldown timer to 30 seconds, but only if it's not already running or it has less than 30 seconds remaining
			local remainingTime = 120000 - ((GetTime() * 1000) - self:GetCooldownTimes())
			if remainingTime < 30000 then
				CooldownFrame_SetTimer(self, GetTime(), 30, 1, true)
			end
		end
	end
end

function sArena_Trinket_OnMouseDown(self, button)
	if ( button == "LeftButton" and not self:GetParent().isMoving ) then
		self:GetParent():StartMoving()
		self:GetParent().isMoving = true
	end
end

function sArena_Trinket_OnMouseUp(self, button)
	if ( button == "LeftButton" and self:GetParent().isMoving ) then
		self:GetParent():StopMovingOrSizing()
		self:GetParent():SetUserPlaced(false)
		self:GetParent().isMoving = false
		
		local sX, sY = self:GetParent():GetCenter()
		local pX, pY = self:GetParent():GetParent():GetCenter()
		local scale = self:GetParent():GetScale()
		sX, sY = floor(sX * scale), floor(sY * scale)
		pX, pY = floor(pX), floor(pY)
		sX, sY = floor((pX-sX)*(-1)), floor((pY-sY)*(-1))
		
		for i = 1, MAX_ARENA_ENEMIES do
			local Trinket = sArena["Trinket"..i]
			
			Trinket:ClearAllPoints()
			Trinket:SetPoint("CENTER", Trinket:GetParent(), sX/scale, sY/scale)
		end
		
		sArenaDB.Trinket.Point, _, _, sArenaDB.Trinket.X, sArenaDB.Trinket.Y = self:GetParent():GetPoint()
	end
end

function sArena_Trinket_OnShow(self)
	if not sArenaDB.Trinket.AlwaysShow then
		self:GetParent():SetAlpha(1)
	end
end

function sArena_Trinket_OnHide(self)
	if not sArenaDB.Trinket.AlwaysShow then
		self:GetParent():SetAlpha(0)
	end
end

function sArena_Trinket_AlwaysShow(setting)
	if ( setting ) then sArenaDB.Trinket.AlwaysShow = setting end
	for i = 1, MAX_ARENA_ENEMIES do
		local Trinket = sArena["Trinket"..i]
		local TrinketCooldown = sArena["Trinket"..i.."Cooldown"]
		
		local alpha = 0
		if ( sArenaDB.Trinket.AlwaysShow ) then
			if ( sArenaDB.Trinket.Enabled ) then
				alpha = 1
			end
		elseif ( sArenaDB.Trinket.Enabled and TrinketCooldown:IsShown() ) then
			alpha = 1
		end
		
		Trinket:SetAlpha(alpha)
	end
end

local HealthBars = {
	ArenaEnemyFrame1HealthBar = 1,
	ArenaEnemyFrame2HealthBar = 1,
	ArenaEnemyFrame3HealthBar = 1,
	ArenaEnemyFrame4HealthBar = 1,
	ArenaEnemyFrame5HealthBar = 1
}

local function sArena_ClassColours(self)
	if HealthBars[self:GetName()] then
		local texture = _G[self:GetParent():GetName() .. "Texture"]
		local petTexture = _G[self:GetParent():GetName() .. "PetFrameTexture"]
		local specBorder = _G[self:GetParent():GetName() .. "SpecBorder"]
		local name = _G[self:GetParent():GetName() .. "Name"]
		local dead = UnitIsDead(self.unit)
		
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
hooksecurefunc("HealthBar_OnValueChanged", function(self) sArena_ClassColours(self) end)
hooksecurefunc("UnitFrameHealthBar_Update", function(self) sArena_ClassColours(self) end)

function sArena_Options_OnLoad(self)
	self.name = "sArena"
	InterfaceOptions_AddCategory(self)
	SLASH_sArena1 = "/sarena"
	SlashCmdList["sArena"] = function(msg, editbox)
	if msg == '' then
		InterfaceOptionsFrame_OpenToCategory(sArena_Options)
		InterfaceOptionsFrame_OpenToCategory(sArena_Options)
	--[[elseif msg == 'test2' then sArena:Test(2)
	elseif msg == 'test3' then sArena:Test(3)
	elseif msg == 'test5' then sArena:Test(5)
	elseif msg == 'clear' then sArena:HideArenaEnemyFrames()]]
	end
end
end