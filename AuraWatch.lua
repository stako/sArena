local AddonName, sArena = ...
sArena.AuraWatch = CreateFrame("Frame", nil, UIParent)

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY
local DEBUFF_MAX_DISPLAY = DEBUFF_MAX_DISPLAY

sArena.Defaults.AuraWatch = {
	enabled = true,
}

-- Called when addon is loaded
function sArena.AuraWatch:Initialize()
	if not sArenaDB.AuraWatch then
		sArenaDB.AuraWatch = CopyTable(sArena.Defaults.AuraWatch)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		self:CreateCooldownFrame(ArenaFrame)
	end
	
	-- Create prioritized aura list. We're simply swapping the keys and values from sArena.AuraWatch.Spells
	self.AuraList = {}
	for k,v in ipairs(self.Spells) do
		self.AuraList[v] = k
	end
	
	self:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
--hooksecurefunc(sArena, "Initialize", function() sArena.AuraWatch:Initialize() end)

function sArena.AuraWatch:CreateCooldownFrame(frame)
	local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	cooldown:SetSwipeColor(0, 0, 0, .5)
	cooldown:SetDrawBling(false)
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
	if sArenaDB.AuraWatch.enabled and instanceType == "arena" then
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
				-- Compare with the previous buff found in the for loop (if it exists) and select that with the greatest priority
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
