local AddonName, sArena = ...

sArena.AuraWatch = CreateFrame("Frame", nil, UIParent)
sArena.AuraWatch:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

-- Default Settings
sArena.AuraWatch.DefaultSettings = {
	Enabled = true,
	FontSize = 8,
	Alpha = 0.5,
}

function sArena.AuraWatch:ADDON_LOADED()
	if not sArenaDB.AuraWatch then
		sArenaDB.AuraWatch = CopyTable(self.DefaultSettings)
	end
	
	-- Create prioritized aura list. We're simply swapping the keys and values from sArena.AuraWatch.Spells
	self.AuraList = {}
	for k,v in ipairs(self.Spells) do
		self.AuraList[v] = k
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
	
		self["arena"..i] = CreateFrame("Cooldown", "sArenaAuraWatch"..i, ArenaFrame, "CooldownFrameTemplate")
		
		self["arena"..i]:SetSwipeColor(0, 0, 0, sArenaDB.AuraWatch.Alpha)
		self["arena"..i]:SetDrawBling(false)
		self["arena"..i]:ClearAllPoints()
		self["arena"..i]:SetPoint("TOPLEFT", ArenaFrame.classPortrait, "TOPLEFT", 2, -2)
		self["arena"..i]:SetPoint("BOTTOMRIGHT", ArenaFrame.classPortrait, "BOTTOMRIGHT", -2, 2)
		
		for _, region in next, {self["arena"..i]:GetRegions()} do
			if region:GetObjectType() == "FontString" then
				self["arena"..i].Text = region
			end
		end
		
		self["arena"..i].Text:SetFont("Fonts\\FRIZQT__.TTF", sArenaDB.AuraWatch.FontSize, "OUTLINE")
		self["arena"..i].Text:ClearAllPoints()
		self["arena"..i].Text:SetPoint("CENTER", self["arena"..i], "CENTER", 0, 1)
		
		self["arena"..i].classPortrait = ArenaFrame.classPortrait
	end
end

function sArena.AuraWatch:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	
	if sArenaDB.AuraWatch.Enabled and instanceType == "arena" then
		self:RegisterEvent("UNIT_AURA")
	elseif self:IsEventRegistered("UNIT_AURA") then
		self:UnregisterEvent("UNIT_AURA")
	end
end

function sArena.AuraWatch:UNIT_AURA(unitID)
	if self[unitID] then
		local spellId, filter, buff, debuff
		
		-- Loop through unit's auras
		for i=1, BUFF_MAX_DISPLAY do
			buff = select(11, UnitAura(unitID, i, "HELPFUL"))
			-- See if buff exists in our table
			if buff and self.AuraList[buff] then
				-- Compare with the previous buff found in the for loop (if it exists) and select the greatest priority buff
				if not spellId or spellId and self.AuraList[buff] < self.AuraList[spellId] then
					spellId = buff
					filter = "HELPFUL"
				end
			end
			
			if i <= DEBUFF_MAX_DISPLAY then debuff = select(11, UnitAura(unitID, i, "HARMFUL")) end
			-- Same as above, but with debuffs
			if debuff and self.AuraList[debuff] then
				if not spellId or spellId and self.AuraList[debuff] < self.AuraList[spellId] then
					spellId = debuff
					filter = "HARMFUL"
				end
			end
		end
		
		-- If an aura is found, set spell texture and cooldown, else set class portrait
		if spellId then
			local name, rank = GetSpellInfo(spellId)
			local _, _, icon, _, _, duration, expires = UnitAura(unitID, name, rank, filter)
			SetPortraitToTexture(self[unitID].classPortrait, icon)
			self[unitID].classPortrait:SetTexCoord(0,1,0,1)
			CooldownFrame_SetTimer(self[unitID], expires - duration, duration, 1, 0, 0, true)
		elseif UnitClass(unitID) then
			self[unitID].classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			self[unitID].classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2, UnitClass(unitID))]))
			CooldownFrame_SetTimer(self[unitID], 0, 0, 0, 0, 0, true)
		end
	end
end

function sArena.AuraWatch:TestMode()
	for i = 1, MAX_ARENA_ENEMIES do
		if ( sArenaDB.TestMode and sArenaDB.AuraWatch.Enabled ) then
			CooldownFrame_SetTimer(self["arena"..i], GetTime(), 30, 1, true)
			SetPortraitToTexture(self["arena"..i].classPortrait, "Interface\\Icons\\Spell_Nature_Polymorph")
			self["arena"..i].classPortrait:SetTexCoord(0,1,0,1)
		else
			CooldownFrame_SetTimer(self["arena"..i], 0, 0, 0, true)
			self["arena"..i].classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			self["arena"..i].classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2, UnitClass('player'))]))
		end
	end
end
