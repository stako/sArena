local AddonName, sArena = ...

sArena.DRTracker = CreateFrame("Frame", nil, UIParent)
sArena.DRTracker:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

local _
local select = select

-- Default Settings
sArena.DRTracker.DefaultSettings = {
	Enabled = true,
	CooldownFontSize = 7,
	Scale = 1,
	Position = { -70, 20 },
	GrowRight = false,
}

local DRTime = 18.5

local Severity = {
	[1] = { 0, 1, 0, 1},
	[2] = { 1, 1, 0, 1},
	[3] = { 1, 0, 0, 1},
}

local Categories = {
	"Incapacitate",
	"Silence",
	"Disorient",
	"Stun",
	"Root",
}

function sArena.DRTracker:ADDON_LOADED()
	if ( not sArenaDB.DRTracker ) then
		sArenaDB.DRTracker = CopyTable(sArena.DRTracker.DefaultSettings)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		
		sArena.DRTracker["arena"..i] = {}
		
		for _,v in ipairs(Categories) do
			sArena.DRTracker:CreateIcon(ArenaFrame, i, v)
		end		
	end
	
	sArena.DRTracker.TitleBar = CreateFrame("Frame", nil, sArena.DRTracker["arena1"]["Incapacitate"], "sArenaDragBarTemplate")
	sArena.DRTracker.TitleBar:SetSize(24, 16)
	sArena.DRTracker.TitleBar:SetPoint("BOTTOM", sArena.DRTracker["arena1"]["Incapacitate"], "TOP")
	
	sArena.DRTracker.TitleBar:SetScript("OnMouseDown", function(self, button)
		if ( button == "LeftButton" and not self:GetParent().isMoving ) then
			self:GetParent():StartMoving()
			self:GetParent().isMoving = true
		end
	end)
	
	sArena.DRTracker.TitleBar:SetScript("OnMouseUp", function(self, button)
		if ( button == "LeftButton" and self:GetParent().isMoving ) then
			self:GetParent():StopMovingOrSizing()
			self:GetParent():SetUserPlaced(false)
			self:GetParent().isMoving = false
			
			sArenaDB.DRTracker.Position[1], sArenaDB.DRTracker.Position[2] = sArena:CalcPoint(self:GetParent())
			
			for i = 1, MAX_ARENA_ENEMIES do
				sArena.DRTracker:Positioning("arena"..i)
			end
		end
	end)

end

function sArena.DRTracker:CreateIcon(ArenaFrame, id, category)
	sArena.DRTracker["arena"..id][category] = CreateFrame("Frame", "sArenaDRTracker"..id..category, ArenaFrame, "sArenaDRTrackerTemplate")
	sArena.DRTracker["arena"..id][category].Cooldown = _G["sArenaDRTracker"..id..category.."Cooldown"]
	sArena.DRTracker["arena"..id][category].Icon = _G["sArenaDRTracker"..id..category.."Icon"]
	sArena.DRTracker["arena"..id][category].Border = _G["sArenaDRTracker"..id..category.."Border"]
	sArena.DRTracker["arena"..id][category]:SetScale(sArenaDB.DRTracker.Scale)
	sArena.DRTracker["arena"..id][category].Severity = 1
	sArena.DRTracker["arena"..id][category]:SetAlpha(0)
	
	for _, region in next, {sArena.DRTracker["arena"..id][category].Cooldown:GetRegions()} do
		if ( region:GetObjectType() == "FontString" ) then
			sArena.DRTracker["arena"..id][category].Cooldown.Text = region
		end
	end
	
	sArena.DRTracker["arena"..id][category].Cooldown.Text:SetFont("Fonts\\FRIZQT__.TTF", sArenaDB.DRTracker.CooldownFontSize, "OUTLINE")
	
	sArena.DRTracker["arena"..id][category].Cooldown:SetScript("OnShow", function(self)
		sArena.DRTracker["arena"..id][category]:SetAlpha(1)
		sArena.DRTracker:Positioning("arena"..id)
	end)
	
	sArena.DRTracker["arena"..id][category].Cooldown:SetScript("OnHide", function(self)
		sArena.DRTracker["arena"..id][category]:SetAlpha(0)
		sArena.DRTracker:Positioning("arena"..id)
		sArena.DRTracker["arena"..id][category].Severity = 1
	end)
end

function sArena.DRTracker:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	
	if ( sArenaDB.DRTracker.Enabled and instanceType == "arena" ) then
		sArena.DRTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	elseif ( sArena.DRTracker:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") ) then
		sArena.DRTracker:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function sArena.DRTracker:COMBAT_LOG_EVENT_UNFILTERED(_, eventType, _, _, _, _, _, destGUID, _, _, _, spellID, spellName, _, auraType)
	if ( auraType == "DEBUFF" ) then
		if ( eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_BROKEN" ) then
			sArena.DRTracker:TimerStart(destGUID, spellID, spellName, false)
		elseif ( eventType == "SPELL_AURA_APPLIED" ) then
			sArena.DRTracker:TimerStart(destGUID, spellID, spellName, true)
		end
	end
end

function sArena.DRTracker:Positioning(id)
	local Active = 0
	
	for _,v in ipairs(Categories) do
		if ( sArena.DRTracker[id][v]:GetAlpha() == 1 ) then
			sArena.DRTracker[id][v]:ClearAllPoints()
			if ( Active == 0 ) then
				sArena.DRTracker[id][v]:SetPoint("CENTER", sArena.DRTracker[id][v]:GetParent(), "CENTER", sArenaDB.DRTracker.Position[1], sArenaDB.DRTracker.Position[2])
			else
				sArena.DRTracker[id][v]:SetPoint("CENTER", sArena.DRTracker[id][v]:GetParent(), "CENTER", sArenaDB.DRTracker.Position[1] + (Active * (sArenaDB.DRTracker.GrowRight and 24 or -24)), sArenaDB.DRTracker.Position[2])
			end
			Active = Active + 1
		end
	end
end

function sArena.DRTracker:TimerStart(GUID, spellID, spellName, applied)
	local category = sArena.DRTracker.Spells[spellID]
	if ( not category ) then return end
	
	local unitID
	for i = 1, MAX_ARENA_ENEMIES do
		if ( UnitGUID("arena"..i) == GUID ) then
			unitID = "arena"..i
			break
		end
	end
	
	if ( not unitID ) then return end
	
	if ( applied ) then -- CC has been applied
		local auraDuration = select(6, UnitDebuff(unitID, spellName))
		CooldownFrame_Set(sArena.DRTracker[unitID][category].Cooldown, GetTime(), DRTime + auraDuration, 1, true)
	else -- CC has been removed (completed, dispelled, broken, etc.)
		-- Adjust timer for early CC breaks
		local startTime, startDuration = sArena.DRTracker[unitID][category].Cooldown:GetCooldownTimes()
		startTime, startDuration = startTime/1000, startDuration/1000
		
		local newDuration = DRTime / (1 - ((GetTime() - startTime) / startDuration))
		local newStartTime = DRTime + GetTime() - newDuration
		CooldownFrame_Set(sArena.DRTracker[unitID][category].Cooldown, newStartTime, newDuration, 1, true)
	end
	
	if ( not applied ) then return end
	
	local icon = select(3, GetSpellInfo(spellID))
	sArena.DRTracker[unitID][category].Icon:SetTexture(icon)
	
	sArena.DRTracker[unitID][category].Border:SetVertexColor(unpack(Severity[sArena.DRTracker[unitID][category].Severity]))
	
	sArena.DRTracker[unitID][category].Severity = sArena.DRTracker[unitID][category].Severity + 1
	if ( sArena.DRTracker[unitID][category].Severity > 3) then
		sArena.DRTracker[unitID][category].Severity = 3
	end
end

function sArena.DRTracker:TestMode()
	for i = 1, MAX_ARENA_ENEMIES do
		local unitID = "arena"..i
		for _,v in ipairs(Categories) do
			if ( sArenaDB.TestMode and sArenaDB.DRTracker.Enabled ) then
				CooldownFrame_Set(sArena.DRTracker[unitID][v].Cooldown, GetTime(), DRTime, 1, true)
				sArena.DRTracker[unitID][v].Icon:SetTexture("Interface\\Icons\\Spell_Nature_Polymorph")
			else
				CooldownFrame_Set(sArena.DRTracker[unitID][v].Cooldown, 0, 0, 0, true)
			end
		end
	end
end

function sArena.DRTracker:SetScale(scale)
	for i = 1, MAX_ARENA_ENEMIES do
		local unitID = "arena"..i
		for _,v in ipairs(Categories) do
				sArena.DRTracker[unitID][v]:SetScale(scale)
		end
	end
end

sArena.DRTracker.Spells = {
	[  5211] = "Stun",	-- Mighty Bash
	[108194] = "Stun",	-- Asphyxiate
	[199804] = "Stun",	-- Between the Eyes
	[118905] = "Stun",	-- Static Charge
	[  1833] = "Stun",	-- Cheap Shot
	[   853] = "Stun",	-- Hammer of Justice
	[117526] = "Stun",	-- Binding Shot
	[179057] = "Stun",	-- Chaos Nova
	[207171] = "Stun",	-- Winter is Coming
	[132169] = "Stun",	-- Storm Bolt
	[   408] = "Stun",	-- Kidney Shot
	[163505] = "Stun",	-- Rake
	[119381] = "Stun",	-- Leg Sweep UNCONFIRMED SPELLID & CATEGORY
	[232055] = "Stun",	-- Fists of Fury
	[ 89766] = "Stun",	-- Axe Toss
	[ 30283] = "Stun",	-- Shadowfury UNCONFIRMED SPELLID & CATEGORY
	[200166] = "Stun",	-- Metamorphosis Stun
	[226943] = "Stun",	-- Mind Bomb
	[ 24394] = "Stun",	-- Intimidation
	[211881] = "Stun",	-- Fel Eruption UNCONFIRMED SPELLID
	[221562] = "Stun",	-- Asphyxiate, Blood Spec UNCONFIRMED SPELLID
	[ 91800] = "Stun",	-- Gnaw UNCONFIRMED SPELLID
	[ 91797] = "Stun",	-- Monstrous Blow UNCONFIRMED SPELLID
	[205630] = "Stun",	-- Illidan's Grasp UNCONFIRMED SPELLID & CATEGORY
	[208618] = "Stun",	-- Illidan's Grasp UNCONFIRMED SPELLID & CATEGORY
	[203123] = "Stun",	-- Maim UNCONFIRMED SPELLID
	[200200] = "Stun",	-- Holy Word: Chastise, Censure Talent UNCONFIRMED CATEGORY
	[118345] = "Stun",	-- Pulverize UNCONFIRMED SPELLID
	[ 22703] = "Stun",	-- Infernal Awakening UNCONFIRMED SPELLID
	[132168] = "Stun",	-- Shockwave UNCONFIRMED SPELLID
	[ 20549] = "Stun",	-- War Stomp UNCONFIRMED SPELLID
	
	[ 33786] = "Disorient",	-- Cyclone
	[209753] = "Disorient",	-- Cyclone, Honor Talent
	[  5246] = "Disorient",	-- Intimidating Shout
	[238559] = "Disorient",	-- Bursting Shot
	[  8122] = "Disorient",	-- Psychic Scream
	[  2094] = "Disorient",	-- Blind
	[  5484] = "Disorient",	-- Howl of Terror UNCONFIRMED SPELLID
	[   605] = "Disorient",	-- Mind Control
	[105421] = "Disorient",	-- Blinding Light
	[207167] = "Disorient",	-- Blinding Sleet UNCONFIRMED SPELLID & CATEGORY
	[ 31661] = "Disorient",	-- Dragon's Breath UNCONFIRMED SPELLID & CATEGORY
	[207685] = "Disorient", -- Sigil of Misery UNCONFIRMED SPELLID & CATEGORY
	[198909] = "Disorient", -- Song of Chi-ji UNCONFIRMED SPELLID & CATEGORY
	[202274] = "Disorient", -- Incendiary Brew UNCONFIRMED SPELLID & CATEGORY
	[  5782] = "Disorient", -- Fear UNCONFIRMED SPELLID & CATEGORY
	[118699] = "Disorient", -- Fear UNCONFIRMED SPELLID & CATEGORY
	[130616] = "Disorient", -- Fear UNCONFIRMED SPELLID & CATEGORY
	[115268] = "Disorient", -- Mesmerize UNCONFIRMED SPELLID & CATEGORY
	[  6358] = "Disorient", -- Seduction UNCONFIRMED SPELLID & CATEGORY
	
	[ 51514] = "Incapacitate",	-- Hex UNCONFIRMED SPELLID
	[211004] = "Incapacitate",	-- Hex: Spider UNCONFIRMED SPELLID
	[210873] = "Incapacitate",	-- Hex: Raptor UNCONFIRMED SPELLID
	[211015] = "Incapacitate",	-- Hex: Cockroach UNCONFIRMED SPELLID
	[211010] = "Incapacitate",	-- Hex: Snake UNCONFIRMED SPELLID
	[   118] = "Incapacitate",	-- Polymorph
	[ 61305] = "Incapacitate",	-- Polymorph: Black Cat UNCONFIRMED SPELLID
	[ 28272] = "Incapacitate",	-- Polymorph: Pig UNCONFIRMED SPELLID
	[ 61721] = "Incapacitate",	-- Polymorph: Rabbit UNCONFIRMED SPELLID
	[ 61780] = "Incapacitate",	-- Polymorph: Turkey UNCONFIRMED SPELLID
	[ 28271] = "Incapacitate",	-- Polymorph: Turtle UNCONFIRMED SPELLID
	[161353] = "Incapacitate",	-- Polymorph: Polar Bear Cub UNCONFIRMED SPELLID
	[126819] = "Incapacitate",	-- Polymorph: Porcupine UNCONFIRMED SPELLID
	[161354] = "Incapacitate",	-- Polymorph: Monkey UNCONFIRMED SPELLID
	[161355] = "Incapacitate",	-- Polymorph: Penguin UNCONFIRMED SPELLID
	[161372] = "Incapacitate",	-- Polymorph: Peacock UNCONFIRMED SPELLID
	[  3355] = "Incapacitate",	-- Freezing Trap
	[203337] = "Incapacitate",	-- Freezing Trap, Diamond Ice Honor Talent UNCONFIRMED CATEGORY
	[115078] = "Incapacitate",	-- Paralysis
	[213691] = "Incapacitate",	-- Scatter Shot
	[  6770] = "Incapacitate",	-- Sap
	[199743] = "Incapacitate",	-- Parley UNCONFIRMED SPELLID
	[ 20066] = "Incapacitate",	-- Repentance
	[ 19386] = "Incapacitate",	-- Wyvern Sting
	[  6789] = "Incapacitate",	-- Mortal Coil UNCONFIRMED SPELLID & CATEGORY
	[200196] = "Incapacitate",	-- Holy Word: Chastise
	[221527] = "Incapacitate",	-- Imprison, Detainment Honor Talent UNCONFIRMED CATEGORY
	[217832] = "Incapacitate",	-- Imprison UNCONFIRMED CATEGORY
	[    99] = "Incapacitate",	-- Incapacitating Roar UNCONFIRMED SPELLID
	[ 82691] = "Incapacitate",	-- Ring of Frost UNCONFIRMED SPELLID
	[  9484] = "Incapacitate",	-- Shackle Undead UNCONFIRMED SPELLID
	[ 64044] = "Incapacitate",	-- Psychic Horror UNCONFIRMED SPELLID & CATEGORY
	[  1776] = "Incapacitate",	-- Gouge UNCONFIRMED SPELLID
	[   710] = "Incapacitate",	-- Banish UNCONFIRMED SPELLID & CATEGORY
	[107079] = "Incapacitate",	-- Quaking Palm UNCONFIRMED SPELLID & CATEGORY
	
	[   339] = "Root",	-- Entangling Roots
	[   122] = "Root",	-- Frost Nova
	[102359] = "Root",	-- Mass Entanglement
	[ 64695] = "Root",	-- Earthgrab
	[200108] = "Root",	-- Ranger's Net
	[212638] = "Root",	-- Tracker's Net
	[162480] = "Root",	-- Steel Trap
	[204085] = "Root",	-- Deathchill UNCONFIRMED IF THIS IS ON DR TABLE
	[233582] = "Root",	-- Entrenched in Flame UNCONFIRMED IF THIS IS ON DR TABLE
	[201158] = "Root",	-- Super Sticky Tar UNCONFIRMED SPELLID
	[ 33395] = "Root",	-- Freeze UNCONFIRMED SPELLID
	[228600] = "Root",	-- Glacial Spike UNCONFIRMED IF THIS IS ON DR TABLE
	[116706] = "Root",	-- Disable UNCONFIRMED SPELLID
	
	[ 81261] = "Silence",	-- Solar Beam
	[ 25046] = "Silence",	-- Arcane Torrent
	[ 28730] = "Silence",	-- Arcane Torrent
	[ 50613] = "Silence",	-- Arcane Torrent
	[ 69179] = "Silence",	-- Arcane Torrent
	[ 80483] = "Silence",	-- Arcane Torrent
	[129597] = "Silence",	-- Arcane Torrent
	[155145] = "Silence",	-- Arcane Torrent
	[202719] = "Silence",	-- Arcane Torrent
	[202933] = "Silence",	-- Spider Sting
	[  1330] = "Silence",	-- Garrote
	[ 15487] = "Silence",	-- Silence UNCONFIRMED SPELLID
	[199683] = "Silence",	-- Last Word UNCONFIRMED IF THIS IS ON DR TABLE
	[ 47476] = "Silence",	-- Strangulate UNCONFIRMED SPELLID
	[204490] = "Silence",	-- Sigil of Silence UNCONFIRMED SPELLID
}