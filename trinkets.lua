local AddonName, sArena = ...

sArena.Trinkets = CreateFrame("Frame", nil, UIParent)
sArena.Trinkets:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

-- Default Settings
sArena.Trinkets.DefaultSettings = {
	Enabled = true,
	CooldownFontSize = 7,
	AlwaysShow = true,
	Scale = 1,
}

function sArena.Trinkets:ADDON_LOADED()
	if ( not sArenaDB.Trinkets ) then
		sArenaDB.Trinkets = CopyTable(sArena.Trinkets.DefaultSettings)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
	
		sArena.Trinkets["arena"..i] = CreateFrame("Frame", "sArenaTrinket"..i, ArenaFrame, "sArenaTrinketTemplate")
		sArena.Trinkets["arena"..i].Cooldown = _G["sArenaTrinket"..i.."Cooldown"]
		sArena.Trinkets["arena"..i]:SetScale(sArenaDB.Trinkets.Scale)
		
		for _, region in next, {sArena.Trinkets["arena"..i].Cooldown:GetRegions()} do
			if ( region:GetObjectType() == "FontString" ) then
				sArena.Trinkets["arena"..i].Cooldown.Text = region
			end
		end
		
		sArena.Trinkets["arena"..i].Cooldown.Text:SetFont("Fonts\\FRIZQT__.TTF", sArenaDB.Trinkets.CooldownFontSize, "OUTLINE")
		
		if ( sArenaDB.Trinkets.Point ) then
			sArena.Trinkets["arena"..i]:ClearAllPoints()
			sArena.Trinkets["arena"..i]:SetPoint(sArenaDB.Trinkets.Point, sArena.Trinkets["arena"..i]:GetParent(), sArenaDB.Trinkets.X, sArenaDB.Trinkets.Y)
		end
		
		sArena.Trinkets["arena"..i]:SetAlpha(sArenaDB.Trinkets.AlwaysShow and 1 or 0)
		
		sArena.Trinkets["arena"..i].Cooldown:SetScript("OnShow", function(self) if not sArenaDB.Trinkets.AlwaysShow then self:GetParent():SetAlpha(1) end end)
		sArena.Trinkets["arena"..i].Cooldown:SetScript("OnHide", function(self) if not sArenaDB.Trinkets.AlwaysShow then self:GetParent():SetAlpha(0) end end)
		
		hooksecurefunc(sArena.Trinkets["arena"..i].Cooldown, "SetCooldown", function() sArena.Trinkets:AlwaysShow() end)
	end
	
	sArena.Trinkets.TitleBar = CreateFrame("Frame", nil, sArena.Trinkets["arena1"], "sArenaDragBarTemplate")
	sArena.Trinkets.TitleBar:SetSize(30, 16)
	sArena.Trinkets.TitleBar:SetPoint("BOTTOM", sArena.Trinkets["arena1"], "TOP")
	
	sArena.Trinkets.TitleBar:SetScript("OnMouseDown", function(self, button)
		if ( button == "LeftButton" and not self:GetParent().isMoving ) then
			self:GetParent():StartMoving()
			self:GetParent().isMoving = true
		end
	end)
	
	sArena.Trinkets.TitleBar:SetScript("OnMouseUp", function(self, button)
		if ( button == "LeftButton" and self:GetParent().isMoving ) then
			self:GetParent():StopMovingOrSizing()
			self:GetParent():SetUserPlaced(false)
			self:GetParent().isMoving = false
			
			local FrameX, FrameY = sArena:CalcPoint(self:GetParent())
			
			for i = 1, MAX_ARENA_ENEMIES do
				sArena.Trinkets["arena"..i]:ClearAllPoints()
				sArena.Trinkets["arena"..i]:SetPoint("CENTER", sArena.Trinkets["arena"..i]:GetParent(), FrameX, FrameY)
			end
			
			sArenaDB.Trinkets.Point, _, _, sArenaDB.Trinkets.X, sArenaDB.Trinkets.Y = self:GetParent():GetPoint()
		end
	end)
end

function sArena.Trinkets:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	
	if ( sArenaDB.Trinkets.Enabled and instanceType == "arena" ) then
		sArena.Trinkets:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	elseif ( sArena.Trinkets:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") ) then
		sArena.Trinkets:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end

function sArena.Trinkets:UNIT_SPELLCAST_SUCCEEDED(unitID, spell)
	if not sArena.Trinkets[unitID] then return end
	
	if ( spell == GetSpellInfo(42292) or spell == GetSpellInfo(59752) )  then -- Trinket and EMFH
		CooldownFrame_SetTimer(sArena.Trinkets[unitID].Cooldown, GetTime(), 120, 1, true)
	elseif ( spell == GetSpellInfo(7744) ) then -- WOTF
		-- When WOTF is used, set cooldown timer to 30 seconds, but only if it's not already running or it has less than 30 seconds remaining
		local remainingTime = 120000 - ((GetTime() * 1000) - sArena.Trinkets[unitID].Cooldown:GetCooldownTimes())
		if remainingTime < 30000 then
			CooldownFrame_SetTimer(sArena.Trinkets[unitID].Cooldown, GetTime(), 30, 1, true)
		end
	end
end

function sArena.Trinkets:Lock()
	if ( sArenaDB.Lock ) then
		sArena.Trinkets.TitleBar:Hide()
	else
		sArena.Trinkets.TitleBar:Show()
	end
end

function sArena.Trinkets:TestMode()
	for i = 1, MAX_ARENA_ENEMIES do
		if ( sArenaDB.TestMode ) then
			CooldownFrame_SetTimer(sArena.Trinkets["arena"..i].Cooldown, GetTime(), 120, 1, true)
		else
			CooldownFrame_SetTimer(sArena.Trinkets["arena"..i].Cooldown, 0, 0, 0, true)
		end
	end
end

function sArena.Trinkets:AlwaysShow(setting)
	if ( setting ~= nil ) then sArenaDB.Trinkets.AlwaysShow = setting end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local Trinket = sArena.Trinkets["arena"..i]
		local TrinketCooldown = sArena.Trinkets["arena"..i].Cooldown
		
		local alpha = 0
		if ( sArenaDB.Trinkets.AlwaysShow ) then
			if ( sArenaDB.Trinkets.Enabled ) then
				alpha = 1
			end
		elseif ( sArenaDB.Trinkets.Enabled and TrinketCooldown:IsShown() ) then
			alpha = 1
		end
		
		Trinket:SetAlpha(alpha)
	end
end