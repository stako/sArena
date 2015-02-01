local AddonName, sArena = ...
sArena.AuraWatch = CreateFrame("Frame", nil, UIParent)

sArena.Defaults.AuraWatch = {
	enabled = true,
}

function sArena.AuraWatch:Initialize()
	if ( not sArenaDB.AuraWatch ) then
		sArenaDB.AuraWatch = CopyTable(sArena.Defaults.AuraWatch)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		self:CreateCooldownFrame(ArenaFrame)
	end
	
	self:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
hooksecurefunc(sArena, "Initialize", function() sArena.AuraWatch:Initialize() end)

function sArena.AuraWatch:CreateCooldownFrame(frame)
	local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	cooldown:ClearAllPoints()
	cooldown:SetPoint("TOPLEFT", frame.classPortrait, "TOPLEFT", 2, -2)
	cooldown:SetPoint("BOTTOMRIGHT", frame.classPortrait, "BOTTOMRIGHT", -2, 2)
	
	for _, region in next, {cooldown:GetRegions()} do
		if region:GetObjectType() == "FontString" then
			cooldown.Text = region
		end
	end
	cooldown.Text:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
	cooldown.Text:ClearAllPoints()
	cooldown.Text:SetPoint("CENTER", cooldown, "CENTER", 0, 1)
	
	cooldown.classPortrait = frame.classPortrait
	
	local id = frame:GetID()
	self["arena"..id] = cooldown
end

function sArena.AuraWatch:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	if ( sArenaDB.AuraWatch.enabled and instanceType == "arena" ) then
		self:RegisterEvent("UNIT_AURA")
	elseif ( self:IsEventRegistered("UNIT_AURA") ) then
		self:UnregisterEvent("UNIT_AURA")
	end
end

function sArena.AuraWatch:UNIT_AURA(unitID)
	if self[unitID] then
		local spellId, buffIndex, debuffIndex, filter
		
		for i, v in ipairs(self.Spells) do
			local name, rank = GetSpellInfo(v)
			if UnitAura(unitID, name, rank, "HELPFUL") and select(11, UnitAura(unitID, name, rank, "HELPFUL")) == tonumber(v) then
				buffIndex = i
				break
			end
		end
		
		for i, v in ipairs(self.Spells) do
			local name, rank = GetSpellInfo(v)
			if UnitAura(unitID, name, rank, "HARMFUL") and select(11, UnitAura(unitID, name, rank, "HARMFUL")) == tonumber(v) then
				debuffIndex = i
				break
			end
		end
		
		if buffIndex or debuffIndex then
			if (buffIndex and debuffIndex and buffIndex < debuffIndex) or (buffIndex and not debuffIndex) then
				spellId = tonumber(self.Spells[buffIndex])
				filter = "HELPFUL"
			else
				spellId = tonumber(self.Spells[debuffIndex])
				self.UnitAura = UnitDebuff
				filter = "HARMFUL"
			end
		end
		
		if spellId then
			local name, rank = GetSpellInfo(spellId)
			local _, _, icon, _, _, duration, expires = UnitAura(unitID, name, rank, filter)
			SetPortraitToTexture(self[unitID].classPortrait, icon)
			self[unitID].classPortrait:SetTexCoord(0,1,0,1)
			CooldownFrame_SetTimer(self[unitID], expires - duration, duration, 1, 0, 0, 1)
		elseif UnitClass(unitID) then
			self[unitID].classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			self[unitID].classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2, UnitClass(unitID))]))
			CooldownFrame_SetTimer(self[unitID], 0, 0, 0, 0, 0, true)
		end
	end
end