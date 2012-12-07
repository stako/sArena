-- Credit to Starship/Spaceship from AJ for providing original concept.
sArena.Trinkets = CreateFrame("Frame", nil, sArena)

sArena.Defaults.Trinkets = {
	enabled = true,
		scale = 1,
		alwaysShow = true,
}

function sArena.Trinkets:Initialize()
	if ( not sArenaDB.Trinkets ) then
		sArenaDB.Trinkets = CopyTable(sArena.Defaults.Trinkets)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		self:CreateIcon(ArenaFrame)
	end
end
hooksecurefunc(sArena, "Initialize", function() sArena.Trinkets:Initialize() end)

function sArena.Trinkets:CreateIcon(frame)
	local trinket = CreateFrame("Cooldown", nil, frame)
	trinket:SetFrameLevel(frame:GetFrameLevel() + 3)
	if ( sArenaDB.Trinkets.point ) then
		trinket:SetPoint(sArenaDB.Trinkets.point, frame, sArenaDB.Trinkets.x, sArenaDB.Trinkets.y)
	else
		trinket:SetPoint("LEFT", frame, "RIGHT", 0, 0)
	end
	trinket:SetSize(18, 18)
	trinket:SetScale(sArenaDB.Trinkets.scale)
	
	trinket.Icon = CreateFrame("Frame", nil, trinket)
	trinket.Icon:SetFrameLevel(trinket:GetFrameLevel() - 1)
	trinket.Icon:SetAllPoints()
	trinket.Icon.Texture = trinket.Icon:CreateTexture(nil, "BORDER")
	trinket.Icon.Texture:SetAllPoints()
	SetPortraitToTexture(trinket.Icon.Texture, UnitFactionGroup('player') == "Horde" and "Interface\\Icons\\inv_jewelry_trinketpvp_02" or "Interface\\Icons\\inv_jewelry_trinketpvp_01")
	
	trinket.Icon.Border = CreateFrame("Frame", nil, trinket.Icon)
	trinket.Icon.Border:SetFrameLevel(trinket:GetFrameLevel() + 1)
	trinket.Icon.Border:SetAllPoints()
	trinket.Icon.Border.Texture = trinket.Icon.Border:CreateTexture(nil, "ARTWORK")
	trinket.Icon.Border.Texture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	trinket.Icon.Border.Texture:SetPoint("TOPLEFT", -6, 5)
	trinket.Icon.Border.Texture:SetSize(50, 50)
	
	trinket:Hide()
	trinket:RegisterForDrag("LeftButton")
	trinket:SetScript("OnDragStart", function(s) s:StartMoving() end)
	trinket:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() self:DragStop(s) end)
	
	self:AlwaysShow(sArenaDB.Trinkets.alwaysShow, trinket)
	
	local id = frame:GetID()
	self["arena"..id] = trinket
end

function sArena.Trinkets:Test(numOpps)
	if ( sArena:CombatLockdown() or not sArenaDB.Trinkets.enabled ) then return end
	for i = 1, numOpps do
		self["arena"..i]:SetCooldown(0, -1)
		self["arena"..i]:EnableMouse(true)
		self["arena"..i]:SetMovable(true)
	end
end
hooksecurefunc(sArena, "Test", function(obj, arg1) sArena.Trinkets:Test(arg1) end)

function sArena.Trinkets:HideTrinkets()
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:Hide()
		self["arena"..i]:SetCooldown(0, 0)
		self["arena"..i]:EnableMouse(false)
		self["arena"..i]:SetMovable(false)
	end
end

function sArena.Trinkets:DragStop(s)
	-- Zork/Rothar's hack to maintain relativity: Super Cool.
	local sX, sY = s:GetCenter()
	local pX, pY = s:GetParent():GetCenter()
	local scale = s:GetScale()
	sX, sY = floor(sX*scale), floor(sY*scale)
	pX, pY = floor(pX), floor(pY)
	local fX, fY = floor((pX-sX)*(-1)), floor((pY-sY)*(-1))
	
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:ClearAllPoints()
		self["arena"..i]:SetPoint("CENTER",self["arena"..i]:GetParent(),fX/scale,fY/scale)
	end
	
	local _
	sArenaDB.Trinkets.point, _, _, sArenaDB.Trinkets.x, sArenaDB.Trinkets.y = s:GetPoint()
end

function sArena.Trinkets:Scale(scale)
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:SetScale(scale)
		if ( sArenaDB.Trinkets.alwaysShow ) then
			self["arena"..i].Icon:SetScale(scale)
		else
			self["arena"..i].Icon:SetScale(1)
		end
	end
end

function sArena.Trinkets:AlwaysShow(alwaysShow, ...)
	local trinket = ...
	if ( trinket ) then
		if ( alwaysShow ) then
			trinket.Icon:SetParent(trinket:GetParent())
			trinket.Icon:SetFrameLevel(trinket:GetFrameLevel() - 1)
			trinket.Icon:SetScale(sArenaDB.Trinkets.scale)
		else
			trinket.Icon:SetParent(trinket)
			trinket.Icon:SetFrameLevel(trinket:GetFrameLevel() - 1)
			trinket.Icon:SetScale(1)
		end
	else
		for i = 1, MAX_ARENA_ENEMIES do
			trinket = self["arena"..i]
			if ( alwaysShow ) then
				trinket.Icon:SetParent(trinket:GetParent())
				trinket.Icon:SetFrameLevel(trinket:GetFrameLevel() - 1)
				trinket.Icon:SetScale(sArenaDB.Trinkets.scale)
			else
				trinket.Icon:SetParent(trinket)
				trinket.Icon:SetFrameLevel(trinket:GetFrameLevel() - 1)
				trinket.Icon:SetScale(1)
			end
		end
	end
end

sArena.Trinkets:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function sArena.Trinkets:UNIT_SPELLCAST_SUCCEEDED(unitID, spell)
	if not sArena.Trinkets[unitID] then return end
	
	if spell == GetSpellInfo(42292) or spell == GetSpellInfo(59752) then -- Trinket and EMFH
		CooldownFrame_SetTimer(self[unitID], GetTime(), 120, 1)
	--[[elseif spell == GetSpellInfo(7744) then -- WOTF
		CooldownFrame_SetTimer(self[unitID], GetTime(), 30, 1)]]
	end
end

function sArena.Trinkets:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	if ( sArenaDB.Trinkets.enabled and instanceType == "arena" ) then
		self:HideTrinkets()
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	elseif ( self:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") ) then
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end
sArena.Trinkets:RegisterEvent("PLAYER_ENTERING_WORLD")
