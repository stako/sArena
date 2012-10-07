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
	version = 4,
	position = {},
	lock = false,
	scale = 1,
	Trinkets = {
		enabled = true,
		size = 24,
	},
}

function sArena:Initialize()
	self.OptionsPanel:Initialize()
	
	self:SetPoint(sArenaDB.position.point or "RIGHT", _G["UIParent"], sArenaDB.position.relativePoint or "RIGHT", sArenaDB.position.x or -100, sArenaDB.position.y or 100)
	self.Frame:SetScale(sArenaDB.scale)
	
	if not sArenaDB.lock then
		self:Show()
	end
	
	self:SetScript("OnDragStart", function(s) s:StartMoving() end)
	self:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() sArenaDB.position.point, _, sArenaDB.position.relativePoint, sArenaDB.position.x, sArenaDB.position.y = s:GetPoint() end)
	
	-- Blizzard removed this feature from the options panel and SHOW_PARTY_BACKGROUND is always 0, but the CVar showPartyBackground still persists between sessions.
	ArenaEnemyBackground:SetParent(self.Frame) -- ArenaEnemyBackground functions with both variables(see Blizzard_ArenaUI.lua). What the hell?
	UpdateArenaEnemyBackground(GetCVarBool("showPartyBackground"))
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaFrame:SetParent(self.Frame)
		--ArenaFrame:SetPoint("RIGHT", ArenaFrame:GetParent(), "RIGHT", -2, 0)
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame, true)
		
		local ArenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
		ArenaPetFrame:SetParent(self.Frame)
		
		self.Trinkets:CreateIcon(ArenaFrame)
	end
	
	ArenaEnemyFrame1:SetPoint("TOP", ArenaEnemyFrame1:GetParent(), "BOTTOM", 0, -8)
	
	if sArenaDB.firstrun then
		sArenaDB.firstrun = false
		self:Test(3)
		print("Looks like this is your first time running this version of sArena! Type /sarena for options.")
	end
end

function sArena:CombatLockdown()
	if InCombatLockdown() then
		print("sArena: Must leave combat before doing that!")
		return true
	end
end

function sArena:HideArenaEnemyFrames()
	if self:CombatLockdown() then return end
	
	ArenaEnemyBackground:Hide()
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaEnemyFrame_OnEvent(ArenaFrame, "ARENA_OPPONENT_UPDATE", ArenaFrame.unit, "cleared")
		_G["ArenaEnemyFrame"..i.."PetFrame"]:Hide()
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame)
	end
	
	self.Trinkets:Clear()
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
	
	self.Trinkets:Test(numOpps)
end

function sArena:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == "arena" then
		if sArenaDB.Trinkets.enabled then -- Trinket icons will only be active in arenas, not battlegrounds
			self.Trinkets:Clear()
			self.Trinkets:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		end
	elseif self:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") then
		self.Trinkets:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end
sArena:RegisterEvent("PLAYER_ENTERING_WORLD")

function sArena:ADDON_LOADED(arg1)
	if arg1 == addonName then
		if not sArenaDB or sArenaDB.version < DBdefaults.version then
			sArenaDB = CopyTable(DBdefaults)
		end
		if not IsAddOnLoaded("Blizzard_ArenaUI") then
			LoadAddOn("Blizzard_ArenaUI")
		end
		self:Initialize()
	end
end
sArena:RegisterEvent("ADDON_LOADED")