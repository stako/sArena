local addonName = ...
local backdropLayout = { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = { left = 0, right = 0, top = 0, bottom = 0 } }
sArena = CreateFrame("Frame", nil, UIParent)
sArena:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

sArena.addonName = addonName

sArena:SetSize(200, 16)
sArena:SetBackdrop(backdropLayout)
sArena:SetBackdropColor(0, 0, 0, .8)
sArena:SetClampedToScreen(true)
sArena:EnableMouse(true)
sArena:SetMovable(true)
sArena:RegisterForDrag("LeftButton")
sArena:Hide()

sArena.Title = sArena:CreateFontString(nil, "BACKGROUND")
sArena.Title:SetFontObject("GameFontHighlight")
sArena.Title:SetText(addonName .. " (Click to drag)")
sArena.Title:SetPoint("CENTER", 0, 0)

sArena.Frame = CreateFrame("Frame", nil, UIParent)
sArena.Frame:SetSize(200, 1)
sArena.Frame:SetPoint("TOPLEFT", sArena, "BOTTOMLEFT", 0, 0)
sArena.Frame:SetPoint("TOPRIGHT", sArena, "BOTTOMRIGHT", 0, 0)

sArena:SetParent(sArena.Frame)

local DBdefaults = {
	firstrun = true,
	version = 2,
	position = {},
	lock = false,
	scale = 1,
}

function sArena:Initialize()
	sArena:SetPoint(sArenaDB.position.point or "RIGHT", _G["UIParent"], sArenaDB.position.relativePoint or "RIGHT", sArenaDB.position.x or -100, sArenaDB.position.y or 100)
	sArena.Frame:SetScale(sArenaDB.scale)
	
	if sArenaDB.firstrun then
		sArenaDB.firstrun = false
		self:Test(3)
		print("Looks like this is a new version of (or your first time running) sArena! Type /sarena for options.")
	end
	
	if not sArenaDB.lock then
		self:Show()
	end
	
	sArena:SetScript("OnDragStart", function(self, button) sArena:StartMoving() end)
	sArena:SetScript("OnDragStop", function(self, button) sArena:StopMovingOrSizing() sArenaDB.position.point, _, sArenaDB.position.relativePoint, sArenaDB.position.x, sArenaDB.position.y = sArena:GetPoint() end)
	
	-- Blizzard removed this feature from the options panel and SHOW_PARTY_BACKGROUND is always 0, but the CVar showPartyBackground still persists between sessions.
	ArenaEnemyBackground:SetParent(sArena.Frame) -- ArenaEnemyBackground functions with both variables(see Blizzard_ArenaUI.lua). What the hell?
	UpdateArenaEnemyBackground(GetCVarBool("showPartyBackground"))
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaFrame:SetParent(sArena.Frame)
		--ArenaFrame:SetPoint("RIGHT", ArenaFrame:GetParent(), "RIGHT", -2, 0)
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame, true)
		
		local ArenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
		ArenaPetFrame:SetParent(sArena.Frame)
	end
	
	ArenaEnemyFrame1:SetPoint("TOP", ArenaEnemyFrame1:GetParent(), "BOTTOM", 0, -8)
end

function sArena:CombatLockdown()
	if InCombatLockdown() then
		print("sArena: Must leave combat before doing that!")
		return true
	end
end

function sArena:HideArenaEnemyFrames()
	if self:CombatLockdown() then return end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaEnemyFrame_OnEvent(ArenaFrame, "ARENA_OPPONENT_UPDATE", ArenaFrame.unit, "cleared")
		_G["ArenaEnemyFrame"..i.."PetFrame"]:Hide()
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame)
	end
	ArenaEnemyBackground:Hide()
end

function sArena:Test(numOpps)
	if self:CombatLockdown() then return end
	if not numOpps or not (numOpps > 0 and numOpps < 6) then return end
	
	self:HideArenaEnemyFrames()
	
	local showArenaEnemyPets = (SHOW_ARENA_ENEMY_PETS == "1")
	local _, instanceType = IsInInstance()
	local factionGroup, _ = UnitFactionGroup('player')
	
	for i = 1, numOpps do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		local PVPIcon = _G["ArenaEnemyFrame"..i.."PVPIcon"]
		if instanceType ~= "pvp" then
			ArenaFrame:SetPoint("RIGHT", ArenaFrame:GetParent(), "RIGHT", -2, 0)
			PVPIcon:Hide()
		else
			ArenaFrame:SetPoint("RIGHT", ArenaFrame:GetParent(), "RIGHT", -18, 0)
			PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
			PVPIcon:Show()
		end
		ArenaEnemyFrame_SetMysteryPlayer(ArenaFrame)
		if showArenaEnemyPets then
			_G["ArenaEnemyFrame"..i.."PetFrame"]:Show()
			_G["ArenaEnemyFrame"..i.."PetFramePortrait"]:SetTexture("Interface\\CharacterFrame\\TempPortrait")
		end
	end
	
	if GetCVarBool("showPartyBackground") or (SHOW_PARTY_BACKGROUND == "1") then
		ArenaEnemyBackground:Show()
		ArenaEnemyBackground:SetPoint("BOTTOMLEFT", "ArenaEnemyFrame"..numOpps.."PetFrame", "BOTTOMLEFT", -15, -10)
	end
end

function sArena:ADDON_LOADED(arg1)
	if arg1 == addonName then
		if not sArenaDB or sArenaDB.version < DBdefaults.version then
			sArenaDB = CopyTable(DBdefaults)
		end
	elseif arg1 == "Blizzard_ArenaUI" then
		self:Initialize()
	end
end
sArena:RegisterEvent("ADDON_LOADED")