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
	--CooldownFrame_Set(sArena.DRTracker[unitID][category].Cooldown, GetTime(), applied and DRTime+duration or DRTime, 1, true)
	if ( applied ) then
		sArena.DRTracker[unitID][category].fTime = GetTime() + DRTime + duration
		sArena.DRTracker[unitID][category].fDuration = DRTime + duration
		CooldownFrame_Set(sArena.DRTracker[unitID][category].Cooldown, GetTime(), DRTime+duration, 1, true)
	else
		local rDuration = sArena.DRTracker[unitID][category].fTime - GetTime()
		local fraction =  rDuration / sArena.DRTracker[unitID][category].fDuration
		local fDuration = rDuration / fraction
		local sTime = GetTime() + DRTime - fDuration
		CooldownFrame_Set(sArena.DRTracker[unitID][category].Cooldown, sTime, fDuration, 1, true)
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
	--[[ INCAPACITATES ]]--
	-- Druid
	[    99] = "Incapacitate", -- Incapacitating Roar (talent)
	[203126] = "Incapacitate", -- Maim (with blood trauma pvp talent)
	-- Hunter
	[  3355] = "Incapacitate", -- Freezing Trap
	[ 19386] = "Incapacitate", -- Wyvern Sting
	[209790] = "Incapacitate", -- Freezing Arrow
	-- Mage
	[   118] = "Incapacitate", -- Polymorph
	[ 28272] = "Incapacitate", -- Polymorph (pig)
	[ 28271] = "Incapacitate", -- Polymorph (turtle)
	[ 61305] = "Incapacitate", -- Polymorph (black cat)
	[ 61721] = "Incapacitate", -- Polymorph (rabbit)
	[ 61780] = "Incapacitate", -- Polymorph (turkey)
	[126819] = "Incapacitate", -- Polymorph (procupine)
	[161353] = "Incapacitate", -- Polymorph (bear cub)
	[161354] = "Incapacitate", -- Polymorph (monkey)
	[161355] = "Incapacitate", -- Polymorph (penguin)
	[161372] = "Incapacitate", -- Polymorph (peacock)
	[ 82691] = "Incapacitate", -- Ring of Frost
	-- Monk
	[115078] = "Incapacitate", -- Paralysis
	-- Paladin
	[ 20066] = "Incapacitate", -- Repentance
	-- Priest
	[   605] = "Incapacitate", -- Mind Control
	[  9484] = "Incapacitate", -- Shackle Undead
	[ 64044] = "Incapacitate", -- Psychic Horror (Horror effect)
	[ 88625] = "Incapacitate", -- Holy Word: Chastise
	-- Rogue
	[  1776] = "Incapacitate", -- Gouge
	[  6770] = "Incapacitate", -- Sap
	-- Shaman
	[ 51514] = "Incapacitate", -- Hex
	[211004] = "Incapacitate", -- Hex (spider)
	[210873] = "Incapacitate", -- Hex (raptor)
	[211015] = "Incapacitate", -- Hex (cockroach)
	[211010] = "Incapacitate", -- Hex (snake)
	-- Warlock
	[   710] = "Incapacitate", -- Banish
	[  6789] = "Incapacitate", -- Mortal Coil
	-- Pandaren
	[107079] = "Incapacitate", -- Quaking Palm
	
	--[[ SILENCES ]]--
	-- Death Knight
	[ 47476] = "Silence", -- Strangulate
	-- Demon Hunter
	[204490] = "Silence", -- Sigil of Silence
	-- Druid
	-- Hunter
	[202933] = "Silence", -- Spider Sting (pvp talent)
	-- Mage
	-- Paladin
	[ 31935] = "Silence", -- Avenger's Shield
	-- Priest
	[ 15487] = "Silence", -- Silence
	[199683] = "Silence", -- Last Word (SW: Death silence)
	-- Rogue
	[  1330] = "Silence", -- Garrote
	-- Blood Elf
	[ 25046] = "Silence", -- Arcane Torrent (Energy version)
	[ 28730] = "Silence", -- Arcane Torrent (Priest/Mage/Lock version)
	[ 50613] = "Silence", -- Arcane Torrent (Runic power version)
	[ 69179] = "Silence", -- Arcane Torrent (Rage version)
	[ 80483] = "Silence", -- Arcane Torrent (Focus version)
	[129597] = "Silence", -- Arcane Torrent (Monk version)
	[155145] = "Silence", -- Arcane Torrent (Paladin version)
	[202719] = "Silence", -- Arcane Torrent (DH version)
	
	--[[ DISORIENTS ]]--
	-- Death Knight
	[207167] = "Disorient", -- Blinding Sleet (talent) -- FIXME: is this the right category?
	-- Demon Hunter
	[207685] = "Disorient", -- Sigil of Misery
	-- Druid
	[ 33786] = "Disorient", -- Cyclone
	-- Hunter
	[213691] = "Disorient", -- Scatter Shot
	[186387] = "Disorient", -- Bursting Shot
	-- Mage
	[ 31661] = "Disorient", -- Dragon's Breath
	-- Monk
	[198909] = "Disorient", -- Song of Chi-ji -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
	[202274] = "Disorient", -- Incendiary Brew -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
	-- Paladin
	[105421] = "Disorient", -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
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
	-- Abomination's Might note: 207165 is the stun, but is never applied to players,
	-- so I haven't included it.
	[108194] = "Stun", -- Asphyxiate (talent for unholy)
	[221562] = "Stun", -- Asphyxiate (baseline for blood)
	[ 91800] = "Stun", -- Gnaw (Ghoul)
	[ 91797] = "Stun", -- Monstrous Blow (Dark Transformation Ghoul)
	[207171] = "Stun", -- Winter is Coming (Remorseless winter stun)
	-- Demon Hunter
	[179057] = "Stun", -- Chaos Nova
	[200166] = "Stun", -- Metamorphosis
	[205630] = "Stun", -- Illidan's Grasp, primary effect
	[208618] = "Stun", -- Illidan's Grasp, secondary effect
	[211881] = "Stun", -- Fel Eruption
	-- Druid
	[203123] = "Stun", -- Maim
	[  5211] = "Stun", -- Mighty Bash
	[163505] = "Stun", -- Rake (Stun from Prowl)
	-- Hunter
	[117526] = "Stun", -- Binding Shot
	[ 24394] = "Stun", -- Intimidation
	-- Mage

	-- Monk
	[119381] = "Stun", -- Leg Sweep
	-- Paladin
	[   853] = "Stun", -- Hammer of Justice
	-- Priest
	[200200] = "Stun", -- Holy word: Chastise
	[226943] = "Stun", -- Mind Bomb
	-- Rogue
	-- Shadowstrike note: 196958 is the stun, but it never applies to players,
	-- so I haven't included it.
	[  1833] = "Stun", -- Cheap Shot
	[   408] = "Stun", -- Kidney Shot
	[199804] = "Stun", -- Between the Eyes
	-- Shaman
	[118345] = "Stun", -- Pulverize (Primal Earth Elemental)
	[118905] = "Stun", -- Static Charge (Capacitor Totem)
	[204399] = "Stun", -- Earthfury (pvp talent)
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
	[204085] = "Root", -- Deathchill (pvp talent)
	-- Druid
	[   339] = "Root", -- Entangling Roots
	[102359] = "Root", -- Mass Entanglement (talent)
	[ 45334] = "Root", -- Immobilized (wild charge, bear form)
	-- Hunter
	[ 53148] = "Root", -- Charge (Tenacity pet)
	[162480] = "Root", -- Steel Trap
	[190927] = "Root", -- Harpoon
	[200108] = "Root", -- Ranger's Net
	[212638] = "Root", -- tracker's net
	[201158] = "Root", -- Super Sticky Tar (Expert Trapper, Hunter talent, Tar Trap effect)
	-- Mage
	[   122] = "Root", -- Frost Nova
	[ 33395] = "Root", -- Freeze (Water Elemental)
	-- [157997] = "Root", -- Ice Nova -- since 6.1, ice nova doesn't DR with anything
	[228600] = "Root", -- Glacial spike (talent)
	-- Monk
	[116706] = "Root", -- Disable
	-- Priest
	-- Shaman
	[ 64695] = "Root", -- Earthgrab Totem
	
	--[[ KNOCKBACK ]]--
	-- Death Knight
	--[108199] = "Knockback", -- Gorefiend's Grasp
	-- Druid
	--[102793] = "Knockback", -- Ursol's Vortex
	--[132469] = "Knockback", -- Typhoon
	-- Hunter
	-- Shaman
	--[ 51490] = "Knockback", -- Thunderstorm
	-- Warlock
	--[  6360] = "Knockback", -- Whiplash
	--[115770] = "Knockback", -- Fellash
}
