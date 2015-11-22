local AddonName, sArena = ...

sArena.DRTracker = CreateFrame("Frame", nil, UIParent)
sArena.DRTracker:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

-- Default Settings
sArena.DRTracker.DefaultSettings = {
	Enabled = true,
	CooldownFontSize = 7,
	Scale = 1,
	Position = { -70, 20 },
	GrowRight = false,
}

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
	--"Knockback",
}

function sArena.DRTracker:ADDON_LOADED()
	if ( not sArenaDB.DRTracker ) then
		sArenaDB.DRTracker = CopyTable(sArena.DRTracker.DefaultSettings)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		
		sArena.DRTracker["arena"..i] = {}
		
		sArena.DRTracker:CreateIcon(ArenaFrame, i, "Incapacitate")
		sArena.DRTracker:CreateIcon(ArenaFrame, i, "Silence")
		sArena.DRTracker:CreateIcon(ArenaFrame, i, "Disorient")
		sArena.DRTracker:CreateIcon(ArenaFrame, i, "Stun")
		sArena.DRTracker:CreateIcon(ArenaFrame, i, "Root")
		--sArena.DRTracker:CreateIcon(ArenaFrame, i, "Knockback")		
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
	
	local duration = select(6, UnitDebuff(unitID, spellName))
	CooldownFrame_SetTimer(sArena.DRTracker[unitID][category].Cooldown, GetTime(), applied and 18.5+duration or 18.5, 1, true)
	
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
				CooldownFrame_SetTimer(sArena.DRTracker[unitID][v].Cooldown, GetTime(), 18.5, 1, true)
				sArena.DRTracker[unitID][v].Icon:SetTexture("Interface\\Icons\\Spell_Nature_Polymorph")
			else
				CooldownFrame_SetTimer(sArena.DRTracker[unitID][v].Cooldown, 0, 0, 0, true)
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
	--[[ INCAPACITATES ]]--
	-- Druid
	[    99] = "Incapacitate", -- Incapacitating Roar (talent)
	-- Hunter
	[  3355] = "Incapacitate", -- Freezing Trap
	[ 19386] = "Incapacitate", -- Wyvern Sting
	-- Mage
	[   118] = "Incapacitate", -- Polymorph
	[ 28272] = "Incapacitate", -- Polymorph (pig)
	[ 28271] = "Incapacitate", -- Polymorph (turtle)
	[ 61305] = "Incapacitate", -- Polymorph (black cat)
	[ 61025] = "Incapacitate", -- Polymorph (serpent) -- FIXME: gone ?
	[ 61721] = "Incapacitate", -- Polymorph (rabbit)
	[ 61780] = "Incapacitate", -- Polymorph (turkey)
	[ 82691] = "Incapacitate", -- Ring of Frost
	-- Monk
	[115078] = "Incapacitate", -- Paralysis
	[123393] = "Incapacitate", -- Breath of Fire (Glyphed)
	[137460] = "Incapacitate", -- Ring of Peace -- FIXME: correct spellIDs?
	-- Paladin
	[ 20066] = "Incapacitate", -- Repentance
	-- Priest
	[   605] = "Incapacitate", -- Dominate Mind
	[  9484] = "Incapacitate", -- Shackle Undead
	[ 64044] = "Incapacitate", -- Psychic Horror (Horror effect)
	[ 88625] = "Incapacitate", -- Holy Word: Chastise
	-- Rogue
	[  1776] = "Incapacitate", -- Gouge
	[  6770] = "Incapacitate", -- Sap
	-- Shaman
	[ 51514] = "Incapacitate", -- Hex
	-- Warlock
	[   710] = "Incapacitate", -- Banish
	[137143] = "Incapacitate", -- Blood Horror
	[  6789] = "Incapacitate", -- Mortal Coil
	-- Pandaren
	[107079] = "Incapacitate", -- Quaking Palm
	
	--[[ SILENCES ]]--
	-- Death Knight
	[108194] = "Silence", -- Asphyxiate (if target is immune to stun)
	[ 47476] = "Silence", -- Strangulate
	-- Druid
	[114237] = "Silence", -- Glyph of Fae Silence
	-- Mage
	[102051] = "Silence", -- Frostjaw
	-- Paladin
	[ 31935] = "Silence", -- Avenger's Shield
	-- Priest
	[ 15487] = "Silence", -- Silence
	-- Rogue
	[  1330] = "Silence", -- Garrote
	-- Blood Elf
	[ 25046] = "Silence", -- Arcane Torrent (Energy version)
	[ 28730] = "Silence", -- Arcane Torrent (Mana version)
	[ 50613] = "Silence", -- Arcane Torrent (Runic power version)
	[ 69179] = "Silence", -- Arcane Torrent (Rage version)
	[ 80483] = "Silence", -- Arcane Torrent (Focus version)
	
	--[[ DISORIENTS ]]--
	-- Druid
	[ 33786] = "Disorient", -- Cyclone
	-- Mage
	[ 31661] = "Disorient", -- Dragon's Breath
	-- Paladin
	[105421] = "Disorient", -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
	[ 10326] = "Disorient", -- Turn Evil
	-- Priest
	[  8122] = "Disorient", -- Psychic Scream
	-- Rogue
	[  2094] = "Disorient", -- Blind
	-- Warlock
	[  5782] = "Disorient", -- Fear -- probably unused
	[118699] = "Disorient", -- Fear -- new debuff ID since MoP
	[130616] = "Disorient", -- Fear (with Glyph of Fear)
	[  5484] = "Disorient", -- Howl of Terror (talent)
	[115268] = "Disorient", -- Mesmerize (Shivarra)
	[  6358] = "Disorient", -- Seduction (Succubus)
	-- Warrior
	[  5246] = "Disorient", -- Intimidating Shout (main target)
	
	--[[ STUNS ]]--
	-- Death Knight
	[108194] = "Stun", -- Asphyxiate
	[ 91800] = "Stun", -- Gnaw (Ghoul)
	[ 91797] = "Stun", -- Monstrous Blow (Dark Transformation Ghoul)
	[115001] = "Stun", -- Remorseless Winter
	-- Druid
	[ 22570] = "Stun", -- Maim
	[  5211] = "Stun", -- Mighty Bash
	[163505] = "Stun", -- Rake (Stun from Prowl)
	-- Hunter
	[117526] = "Stun", -- Binding Shot
	[ 24394] = "Stun", -- Intimidation
	-- Mage
	[ 44572] = "Stun", -- Deep Freeze
	-- Monk
	[119392] = "Stun", -- Charging Ox Wave
	[120086] = "Stun", -- Fists of Fury
	[119381] = "Stun", -- Leg Sweep
	-- Paladin
	[   853] = "Stun", -- Hammer of Justice
	[119072] = "Stun", -- Holy Wrath
	[105593] = "Stun", -- Fist of Justice
	-- Rogue
	[  1833] = "Stun", -- Cheap Shot
	[   408] = "Stun", -- Kidney Shot
	-- Shaman
	[118345] = "Stun", -- Pulverize (Primal Earth Elemental)
	[118905] = "Stun", -- Static Charge (Capacitor Totem)
	-- Warlock
	[ 89766] = "Stun", -- Axe Toss (Felguard)
	[ 30283] = "Stun", -- Shadowfury
	[ 22703] = "Stun", -- Summon Infernal
	-- Warrior
	[132168] = "Stun", -- Shockwave
	[132169] = "Stun", -- Storm Bolt
	-- Tauren
	[ 20549] = "Stun", -- War Stomp
	
	--[[ ROOTS ]]--
	-- Death Knight
	[ 96294] = "Root", -- Chains of Ice (Chilblains Root)
	-- Druid
	[   339] = "Root", -- Entangling Roots
	[102359] = "Root", -- Mass Entanglement (talent)
	[113770] = "Root", -- Entangling Roots (Treants)
	[170855] = "Root", -- Entangling Roots (Nature's Grasp)
	-- Hunter
	[ 53148] = "Root", -- Charge (Tenacity pet)
	[135373] = "Root", -- Entrapment (passive)
	[136634] = "Root", -- Narrow Escape (passive talent)
	-- Mage
	[   122] = "Root", -- Frost Nova
	[ 33395] = "Root", -- Freeze (Water Elemental)
	[111340] = "Root", -- Ice Ward
	-- Monk
	[116706] = "Root", -- Disable
	-- Priest
	[ 87194] = "Root", -- Glyph of Mind Blast
	[114404] = "Root", -- Void Tendrils
	-- Shaman
	[ 63685] = "Root", -- Freeze (Frozen Power talent)
	[ 64695] = "Root", -- Earthgrab Totem
	
	--[[ KNOCKBACK ]]--
	-- Death Knight
	--[108199] = "Knockback", -- Gorefiend's Grasp
	-- Druid
	--[102793] = "Knockback", -- Ursol's Vortex
	--[132469] = "Knockback", -- Typhoon
	-- Hunter
	--[ 13812] = "Knockback", -- Glyph of Explosive Trap [Missing CLEU event]
	-- Shaman
	--[ 51490] = "Knockback", -- Thunderstorm
	-- Warlock
	--[  6360] = "Knockback", -- Whiplash
	--[115770] = "Knockback", -- Fellash
}
