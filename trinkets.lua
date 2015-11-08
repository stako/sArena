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
	if not sArenaDB.Trinkets then
		sArenaDB.Trinkets = CopyTable(self.DefaultSettings)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
	
		self["arena"..i] = CreateFrame("Frame", "sArenaTrinket"..i, ArenaFrame, "sArenaTrinketTemplate")
		self["arena"..i].Cooldown = _G["sArenaTrinket"..i.."Cooldown"]
		self["arena"..i]:SetScale(sArenaDB.Trinkets.Scale)
		
		for _, region in next, {self["arena"..i].Cooldown:GetRegions()} do
			if region:GetObjectType() == "FontString" then
				self["arena"..i].Cooldown.Text = region
			end
		end
		
		self["arena"..i].Cooldown.Text:SetFont("Fonts\\FRIZQT__.TTF", sArenaDB.Trinkets.CooldownFontSize, "OUTLINE")
		
		if ( sArenaDB.Trinkets.Point ) then
			self["arena"..i]:ClearAllPoints()
			self["arena"..i]:SetPoint(sArenaDB.Trinkets.Point, self["arena"..i]:GetParent(), sArenaDB.Trinkets.X, sArenaDB.Trinkets.Y)
		end
		
		self["arena"..i]:SetAlpha(sArenaDB.Trinkets.AlwaysShow and 1 or 0)
		
		self["arena"..i].Cooldown:SetScript("OnShow", function(self) if not sArenaDB.Trinkets.AlwaysShow then self:GetParent():SetAlpha(1) end end)
		self["arena"..i].Cooldown:SetScript("OnHide", function(self) if not sArenaDB.Trinkets.AlwaysShow then self:GetParent():SetAlpha(0) end end)
		
		hooksecurefunc(self["arena"..i].Cooldown, "SetCooldown", function() self:AlwaysShow() end)
	end
	
	self.TitleBar = CreateFrame("Frame", nil, self["arena1"], "sArenaDragBarTemplate")
	self.TitleBar:SetSize(30, 16)
	self.TitleBar:SetPoint("BOTTOM", self["arena1"], "TOP")
	
	self.TitleBar:SetScript("OnMouseDown", function(self, button)
		if ( button == "LeftButton" and not self:GetParent().isMoving ) then
			self:GetParent():StartMoving()
			self:GetParent().isMoving = true
		end
	end)
	
	self.TitleBar:SetScript("OnMouseUp", function(self, button)
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
				local Trinket = sArena.Trinkets["arena"..i]
				
				Trinket:ClearAllPoints()
				Trinket:SetPoint("CENTER", Trinket:GetParent(), sX/scale, sY/scale)
			end
			
			sArenaDB.Trinkets.Point, _, _, sArenaDB.Trinkets.X, sArenaDB.Trinkets.Y = self:GetParent():GetPoint()
		end
	end)
end

function sArena.Trinkets:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	
	if ( sArenaDB.Trinkets.Enabled and instanceType == "arena" ) then
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	elseif ( sArena.Frame:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") ) then
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
	
	--[[for i = 1, MAX_ARENA_ENEMIES do
		CooldownFrame_SetTimer(self["arena"..i].Cooldown, 0, 0, 0, true)
	end]]
end

function sArena.Trinkets:UNIT_SPELLCAST_SUCCEEDED(unitID, spell)
	if not self[unitID] then return end
	
	if ( spell == GetSpellInfo(42292) or spell == GetSpellInfo(59752) )  then -- Trinket and EMFH
		CooldownFrame_SetTimer(self[unitID].Cooldown, GetTime(), 120, 1, true)
	elseif spell == GetSpellInfo(7744) then -- WOTF
		-- When WOTF is used, set cooldown timer to 30 seconds, but only if it's not already running or it has less than 30 seconds remaining
		local remainingTime = 120000 - ((GetTime() * 1000) - self[unitID].Cooldown:GetCooldownTimes())
		if remainingTime < 30000 then
			CooldownFrame_SetTimer(self[unitID].Cooldown, GetTime(), 30, 1, true)
		end
	end
end

function sArena.Trinkets:Lock()
	if ( sArenaDB.Lock ) then
		self.TitleBar:Hide()
	else
		self.TitleBar:Show()
	end
end

function sArena.Trinkets:TestMode()
	for i = 1, MAX_ARENA_ENEMIES do
		if ( sArenaDB.TestMode ) then
			CooldownFrame_SetTimer(self["arena"..i].Cooldown, GetTime(), 120, 1, true)
		else
			CooldownFrame_SetTimer(self["arena"..i].Cooldown, 0, 0, 0, true)
		end
	end
end

function sArena.Trinkets:AlwaysShow(setting)
	if ( setting ~= nil ) then sArenaDB.Trinkets.AlwaysShow = setting end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local Trinket = self["arena"..i]
		local TrinketCooldown = self["arena"..i].Cooldown
		
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