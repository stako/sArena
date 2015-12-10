local AddonName, sArena = ...

sArena.AuraWatch = CreateFrame("Frame", nil, UIParent)
sArena.AuraWatch:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

-- Default Settings
sArena.AuraWatch.DefaultSettings = {
	Enabled = true,
	FontSize = 8,
	Alpha = 0.5,
}

local DEBUFF_MAX_DISPLAY = DEBUFF_MAX_DISPLAY
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY

function sArena.AuraWatch:ADDON_LOADED()
	if ( not sArenaDB.AuraWatch ) then
		sArenaDB.AuraWatch = CopyTable(sArena.AuraWatch.DefaultSettings)
	end
	
	-- Create prioritized aura list. We're simply swapping the keys and values from sArena.AuraWatch.Spells
	sArena.AuraWatch.AuraList = {}
	for k,v in ipairs(sArena.AuraWatch.Spells) do
		sArena.AuraWatch.AuraList[v] = k
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
	
		sArena.AuraWatch["arena"..i] = CreateFrame("Cooldown", "sArenaAuraWatch"..i, ArenaFrame, "CooldownFrameTemplate")
		
		sArena.AuraWatch["arena"..i]:SetSwipeColor(0, 0, 0, sArenaDB.AuraWatch.Alpha)
		sArena.AuraWatch["arena"..i]:SetDrawBling(false)
		sArena.AuraWatch["arena"..i]:ClearAllPoints()
		sArena.AuraWatch["arena"..i]:SetPoint("TOPLEFT", ArenaFrame.classPortrait, "TOPLEFT", 2, -2)
		sArena.AuraWatch["arena"..i]:SetPoint("BOTTOMRIGHT", ArenaFrame.classPortrait, "BOTTOMRIGHT", -2, 2)
		
		for _, region in next, {sArena.AuraWatch["arena"..i]:GetRegions()} do
			if ( region:GetObjectType() == "FontString" ) then
				sArena.AuraWatch["arena"..i].Text = region
			end
		end
		
		sArena.AuraWatch["arena"..i].Text:SetFont("Fonts\\FRIZQT__.TTF", sArenaDB.AuraWatch.FontSize, "OUTLINE")
		sArena.AuraWatch["arena"..i].Text:ClearAllPoints()
		sArena.AuraWatch["arena"..i].Text:SetPoint("CENTER", sArena.AuraWatch["arena"..i], "CENTER", 0, 1)
		
		sArena.AuraWatch["arena"..i].classPortrait = ArenaFrame.classPortrait
	end
end

function sArena.AuraWatch:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	
	if ( sArenaDB.AuraWatch.Enabled and instanceType == "arena" ) then
		sArena.AuraWatch:RegisterEvent("UNIT_AURA")
	elseif ( sArena.AuraWatch:IsEventRegistered("UNIT_AURA") ) then
		sArena.AuraWatch:UnregisterEvent("UNIT_AURA")
	end
end

function sArena.AuraWatch:UNIT_AURA(unitID)
	if ( sArena.AuraWatch[unitID] ) then
		local spellId, filter, buff, debuff
		
		-- Loop through unit's auras
		for i=1, BUFF_MAX_DISPLAY do
			buff = select(11, UnitAura(unitID, i, "HELPFUL"))
			-- See if buff exists in our table
			if ( buff and sArena.AuraWatch.AuraList[buff] ) then
				-- Compare with the previous buff found in the for loop (if it exists) and select the greatest priority buff
				if ( not spellId or spellId and sArena.AuraWatch.AuraList[buff] < sArena.AuraWatch.AuraList[spellId] ) then
					spellId = buff
					filter = "HELPFUL"
				end
			end
			
			if ( i <= DEBUFF_MAX_DISPLAY ) then debuff = select(11, UnitAura(unitID, i, "HARMFUL")) end
			-- Same as above, but with debuffs
			if ( debuff and sArena.AuraWatch.AuraList[debuff] ) then
				if ( not spellId or spellId and sArena.AuraWatch.AuraList[debuff] < sArena.AuraWatch.AuraList[spellId] ) then
					spellId = debuff
					filter = "HARMFUL"
				end
			end
			
			if ( buff == nil and debuff == nil ) then break end
		end
		
		-- If an aura is found, set spell texture and cooldown, else set class portrait
		if ( spellId ) then
			local name, rank = GetSpellInfo(spellId)
			local _, _, icon, _, _, duration, expires = UnitAura(unitID, name, rank, filter)
			CooldownFrame_SetTimer(sArena.AuraWatch[unitID], expires - duration, duration, 1, true)
			if ( sArena.AuraWatch[unitID].Icon == icon ) then return end
			SetPortraitToTexture(sArena.AuraWatch[unitID].classPortrait, icon)
			sArena.AuraWatch[unitID].Icon = icon
			sArena.AuraWatch[unitID].classPortrait:SetTexCoord(0,1,0,1)
		elseif ( UnitClass(unitID) ) then
			sArena.AuraWatch[unitID].Icon = nil
			sArena.AuraWatch[unitID].classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			sArena.AuraWatch[unitID].classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2, UnitClass(unitID))]))
			CooldownFrame_SetTimer(sArena.AuraWatch[unitID], 0, 0, 0, true)
		end
	end
end

function sArena.AuraWatch:TestMode()
	for i = 1, MAX_ARENA_ENEMIES do
		if ( sArenaDB.TestMode and sArenaDB.AuraWatch.Enabled ) then
			CooldownFrame_SetTimer(sArena.AuraWatch["arena"..i], GetTime(), 30, 1, true)
			SetPortraitToTexture(sArena.AuraWatch["arena"..i].classPortrait, "Interface\\Icons\\Spell_Nature_Polymorph")
			sArena.AuraWatch["arena"..i].classPortrait:SetTexCoord(0,1,0,1)
		else
			CooldownFrame_SetTimer(sArena.AuraWatch["arena"..i], 0, 0, 0, true)
			sArena.AuraWatch["arena"..i].classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			sArena.AuraWatch["arena"..i].classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2, UnitClass('player'))]))
		end
	end
end
