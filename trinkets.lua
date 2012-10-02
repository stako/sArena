-- Starship/Spaceship from AJ has provided a lot of the code here.

sArena.Trinkets = {}

function sArena.Trinkets:CreateIcon(frame)
	local id = frame:GetID()
	local factionGroup, _ = UnitFactionGroup('player')
	--self.Trinkets["arena"..id] = CreateFrame("Cooldown", nil, frame)
	local Trinket = CreateFrame("Cooldown", nil, frame)
	if sArenaDB.Trinkets.point then
		Trinket:SetPoint(sArenaDB.Trinkets.point, frame, sArenaDB.Trinkets.x, sArenaDB.Trinkets.y)
	else
		Trinket:SetPoint("LEFT", frame, "RIGHT", 0, 0)
	end
	Trinket:SetSize(sArenaDB.Trinkets.size, sArenaDB.Trinkets.size)
	Trinket.Icon = Trinket:CreateTexture(nil, "BACKGROUND")
	Trinket.Icon:SetAllPoints()
	Trinket.Icon:SetTexture(factionGroup == "Horde" and "Interface\\Icons\\inv_jewelry_trinketpvp_02" or "Interface\\Icons\\inv_jewelry_trinketpvp_01")
	Trinket:Hide()
	Trinket:RegisterForDrag("LeftButton")
	Trinket:SetScript("OnDragStart", function(s) s:StartMoving() end)
	Trinket:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() self:DragStop(s) end)
	self["arena"..id] = Trinket
end

function sArena.Trinkets:Unlock()
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:SetCooldown(0, -1)
		self["arena"..i]:EnableMouse(true)
		self["arena"..i]:SetMovable(true)
	end
end

function sArena.Trinkets:Lock()
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:SetCooldown(0, 0)
		self["arena"..i]:Hide()
		self["arena"..i]:EnableMouse(false)
		self["arena"..i]:SetMovable(false)
	end
end

function sArena.Trinkets:DragStop(s)
	-- Zork/Rothar's hack to maintain relativity: Super Cool.
	local sX, sY = s:GetCenter()
	local pX, pY = s:GetParent():GetCenter()
	sX, sY = floor(sX), floor(sY)
	pX, pY = floor(pX), floor(pY)
	local fX, fY = floor((pX-sX)*(-1)), floor((pY-sY)*(-1))
	
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:ClearAllPoints()
		self["arena"..i]:SetPoint("CENTER",self["arena"..i]:GetParent(),fX,fY)
	end
	
	sArenaDB.Trinkets.point, _, _, sArenaDB.Trinkets.x, sArenaDB.Trinkets.y = s:GetPoint()
end

function sArena.Trinkets:Resize(size)
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:SetSize(size, size)
	end
end