local sArena = LibStub("AceAddon-3.0"):GetAddon("sArena")

sArena.drtracker = {}
local MAX_ARENA_ENEMIES, UnitGUID, UnitDebuff, GetSpellInfo = MAX_ARENA_ENEMIES, UnitGUID, UnitDebuff, GetSpellInfo
local drTime = 18.5
local categories = {
	"incapacitate",
	"silence",
	"disorient",
	"stun",
	"root",
}
local severityColor = {
	[1] = { 0, 1, 0, 1},
	[2] = { 1, 1, 0, 1},
	[3] = { 1, 0, 0, 1},
}

sArena.options.plugins = sArena.options.plugins or {}
sArena.options.plugins["DR Tracker"] = {
	drtracker = {
		name = "DR Tracker",
		type = "group",
		desc = "Displays icons to indicate when a type of CC will have diminished effects",
		args = {
			enable = {
				name = "Enable",
				type = "toggle",
				order = 1,
				get = function() return sArena.db.profile.drtracker.enabled end,
				set = function(info, val) sArena.db.profile.drtracker.enabled = val sArena:RefreshConfig() end,
			},
			growRight = {
				name = "Grow Right",
				desc = "DR Icons will grow to the right",
				type = "toggle",
				order = 2,
				get = function() return sArena.db.profile.drtracker.growRight end,
				set = function(info, val) sArena.db.profile.drtracker.growRight = val sArena:RefreshConfig() end,
			},
			iconSize = {
				name = "Icon Size",
				type = "range",
				order = 3,
				min = 6,
				max = 102,
				softMin = 12,
				softMax = 48,
				step = 1,
				bigStep = 1,
				get = function() return sArena.db.profile.drtracker.iconSize end,
				set = function(info, val) sArena.db.profile.drtracker.iconSize = val sArena:RefreshConfig() end,
			},
			fontSize = {
				name = "Font Size",
				desc = "Font size of Blizzard's built-in cooldown count",
				type = "range",
				order = 4,
				min = 4,
				max = 32,
				softMin = 4,
				softMax = 32,
				step = 1,
				bigStep = 1,
				get = function() return sArena.db.profile.drtracker.fontSize end,
				set = function(info, val) sArena.db.profile.drtracker.fontSize = val sArena:RefreshConfig() end,
			},
		},
	},
}

sArena.defaults.profile.drtracker = {
	enabled = true,
	position = { "CENTER", nil, "CENTER", -70, 20 },
	growRight = false,
	iconSize = 24,
	fontSize = 16,
}

function sArena.drtracker:OnEnable()
	for i = 1, MAX_ARENA_ENEMIES do
		local arenaFrame = _G["ArenaEnemyFrame"..i]
		
		self["arena"..i] = {}
		
		for c = 1, #categories do
			local frame = CreateFrame("Frame", nil, arenaFrame, "sArenaDRTrackerTemplate")
			frame:SetAlpha(0)
			if c == 1 then frame:EnableMouse(true) end
			
			for _, region in next, { frame.Cooldown:GetRegions() } do
				if region:GetObjectType() == "FontString" then
					frame.Cooldown.Text = region
				end
			end
			
			frame.Cooldown:SetScript("OnShow", function(self)
				frame:SetAlpha(1)
				sArena.drtracker:UpdatePosition("arena"..i)
			end)
			
			frame.Cooldown:SetScript("OnHide", function(self)
				frame:SetAlpha(0)
				sArena.drtracker:UpdatePosition("arena"..i)
				frame.severity = 1
			end)
			
			frame.Cooldown:SetHideCountdownNumbers(false)
			
			self["arena"..i][categories[c]] = frame
		end
	end
end
sArena.RegisterCallback(sArena.drtracker, "sArena_OnEnable", "OnEnable")

function sArena.drtracker:RefreshConfig()
	for i = 1, MAX_ARENA_ENEMIES do
		self:UpdatePosition("arena"..i)
		for c = 1, #categories do
			local frame = self["arena"..i][categories[c]]
			
			if c == 1 then
				sArena:SetupDrag(frame, nil, sArena.db.profile.drtracker.position, true, true)
			end
			
			if sArena.db.profile.drtracker.enabled == false then
				CooldownFrame_Set(frame.Cooldown, 0, 0, 0, true)
			end
			frame:SetSize(sArena.db.profile.drtracker.iconSize, sArena.db.profile.drtracker.iconSize)
			frame.severity = 1
			local fontFace, _, fontFlags = frame.Cooldown.Text:GetFont()
			frame.Cooldown.Text:SetFont(fontFace, sArena.db.profile.drtracker.fontSize, fontFlags)
		end
	end
end
sArena.RegisterCallback(sArena.drtracker, "sArena_RefreshConfig", "RefreshConfig")

function sArena.drtracker:TestMode()
	for i = 1, 3 do
		local unitID = "arena"..i
		for c = 1, #categories do
			local v = categories[c]
			if sArena.testMode == true and sArena.db.profile.drtracker.enabled == true then
				CooldownFrame_Set(self[unitID][v].Cooldown, GetTime(), drTime, 1, true)
				self[unitID][v].Icon:SetTexture(136071)
				if c == 1 then
					self[unitID][v].Border:SetVertexColor(1, 0.25, 0, 1)
				else
					self[unitID][v].Border:SetVertexColor(1, 1, 1, 1)
				end
			else
				CooldownFrame_Set(self[unitID][v].Cooldown, 0, 0, 0, true)
			end
		end
	end
end
sArena.RegisterCallback(sArena.drtracker, "sArena_TestMode", "TestMode")

function sArena.drtracker:UpdatePosition(id)
	local active = 0
	
	for i = 1, #categories do
		local frame = self[id][categories[i]]
		if frame:GetAlpha() == 1 then
			frame:ClearAllPoints()
			if active == 0 then
				frame:SetPoint("CENTER", frame:GetParent(), "CENTER", sArena.db.profile.drtracker.position[4], sArena.db.profile.drtracker.position[5])
			else
				frame:SetPoint("CENTER", frame:GetParent(), "CENTER", sArena.db.profile.drtracker.position[4] + (active * (sArena.db.profile.drtracker.growRight and sArena.db.profile.drtracker.iconSize or -sArena.db.profile.drtracker.iconSize)), sArena.db.profile.drtracker.position[5])
			end
			active = active + 1
		end
	end
end

function sArena.drtracker:COMBAT_LOG_EVENT_UNFILTERED(_, _, eventType, _, _, _, _, _, destGUID, _, _, _, spellID, spellName, _, auraType)
	if sArena.db.profile.drtracker.enabled == false then return end
	if auraType == "DEBUFF" then
		if eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_BROKEN" then
			self:ApplyDR(destGUID, spellID, spellName, false)
		elseif eventType == "SPELL_AURA_APPLIED" then
			self:ApplyDR(destGUID, spellID, spellName, true)
		end
	end
end
sArena.RegisterCallback(sArena.drtracker, "sArena_COMBAT_LOG_EVENT_UNFILTERED", "COMBAT_LOG_EVENT_UNFILTERED")

local spells = {
	[  5211] = "stun",	-- Mighty Bash
	[108194] = "stun",	-- Asphyxiate
	[199804] = "stun",	-- Between the Eyes
	[118905] = "stun",	-- Static Charge
	[  1833] = "stun",	-- Cheap Shot
	[   853] = "stun",	-- Hammer of Justice
	[117526] = "stun",	-- Binding Shot
	[179057] = "stun",	-- Chaos Nova
	[207171] = "stun",	-- Winter is Coming
	[132169] = "stun",	-- Storm Bolt
	[   408] = "stun",	-- Kidney Shot
	[163505] = "stun",	-- Rake
	[119381] = "stun",	-- Leg Sweep UNCONFIRMED SPELLID & CATEGORY
	[232055] = "stun",	-- Fists of Fury
	[ 89766] = "stun",	-- Axe Toss
	[ 30283] = "stun",	-- Shadowfury UNCONFIRMED SPELLID & CATEGORY
	[200166] = "stun",	-- Metamorphosis Stun
	[226943] = "stun",	-- Mind Bomb
	[ 24394] = "stun",	-- Intimidation
	[211881] = "stun",	-- Fel Eruption UNCONFIRMED SPELLID
	[221562] = "stun",	-- Asphyxiate, Blood Spec UNCONFIRMED SPELLID
	[ 91800] = "stun",	-- Gnaw UNCONFIRMED SPELLID
	[ 91797] = "stun",	-- Monstrous Blow UNCONFIRMED SPELLID
	[205630] = "stun",	-- Illidan's Grasp
	[208618] = "stun",	-- Illidan's Grasp
	[203123] = "stun",	-- Maim UNCONFIRMED SPELLID
	[200200] = "stun",	-- Holy Word: Chastise, Censure Talent
	[118345] = "stun",	-- Pulverize
	[ 22703] = "stun",	-- Infernal Awakening UNCONFIRMED SPELLID
	[132168] = "stun",	-- Shockwave UNCONFIRMED SPELLID
	[ 20549] = "stun",	-- War Stomp UNCONFIRMED SPELLID
	[199085] = "stun",	-- Warpath UNCONFIRMED CATEGORY (May not be on DR Table)
	
	[ 33786] = "disorient",	-- Cyclone
	[209753] = "disorient",	-- Cyclone, Honor Talent
	[  5246] = "disorient",	-- Intimidating Shout
	[238559] = "disorient",	-- Bursting Shot
	[  8122] = "disorient",	-- Psychic Scream
	[  2094] = "disorient",	-- Blind
	[  5484] = "disorient",	-- Howl of Terror UNCONFIRMED SPELLID
	[   605] = "disorient",	-- Mind Control
	[105421] = "disorient",	-- Blinding Light
	[207167] = "disorient",	-- Blinding Sleet UNCONFIRMED SPELLID & CATEGORY
	[ 31661] = "disorient",	-- Dragon's Breath UNCONFIRMED SPELLID & CATEGORY
	[207685] = "disorient", -- Sigil of Misery UNCONFIRMED CATEGORY
	[198909] = "disorient", -- Song of Chi-ji UNCONFIRMED SPELLID & CATEGORY
	[202274] = "disorient", -- Incendiary Brew UNCONFIRMED SPELLID & CATEGORY
	[  5782] = "disorient", -- Fear UNCONFIRMED SPELLID & CATEGORY
	[118699] = "disorient", -- Fear UNCONFIRMED SPELLID & CATEGORY
	[130616] = "disorient", -- Fear UNCONFIRMED SPELLID & CATEGORY
	[115268] = "disorient", -- Mesmerize UNCONFIRMED SPELLID & CATEGORY
	[  6358] = "disorient", -- Seduction UNCONFIRMED SPELLID & CATEGORY
	
	[ 51514] = "incapacitate",	-- Hex
	[211004] = "incapacitate",	-- Hex: Spider UNCONFIRMED SPELLID
	[210873] = "incapacitate",	-- Hex: Raptor UNCONFIRMED SPELLID
	[211015] = "incapacitate",	-- Hex: Cockroach UNCONFIRMED SPELLID
	[211010] = "incapacitate",	-- Hex: Snake UNCONFIRMED SPELLID
	[196942] = "incapacitate",	-- Hex
	[   118] = "incapacitate",	-- Polymorph
	[ 61305] = "incapacitate",	-- Polymorph: Black Cat UNCONFIRMED SPELLID
	[ 28272] = "incapacitate",	-- Polymorph: Pig UNCONFIRMED SPELLID
	[ 61721] = "incapacitate",	-- Polymorph: Rabbit UNCONFIRMED SPELLID
	[ 61780] = "incapacitate",	-- Polymorph: Turkey UNCONFIRMED SPELLID
	[ 28271] = "incapacitate",	-- Polymorph: Turtle UNCONFIRMED SPELLID
	[161353] = "incapacitate",	-- Polymorph: Polar Bear Cub UNCONFIRMED SPELLID
	[126819] = "incapacitate",	-- Polymorph: Porcupine UNCONFIRMED SPELLID
	[161354] = "incapacitate",	-- Polymorph: Monkey UNCONFIRMED SPELLID
	[161355] = "incapacitate",	-- Polymorph: Penguin UNCONFIRMED SPELLID
	[161372] = "incapacitate",	-- Polymorph: Peacock UNCONFIRMED SPELLID
	[  3355] = "incapacitate",	-- Freezing Trap
	[203337] = "incapacitate",	-- Freezing Trap, Diamond Ice Honor Talent UNCONFIRMED CATEGORY
	[115078] = "incapacitate",	-- Paralysis
	[213691] = "incapacitate",	-- Scatter Shot
	[  6770] = "incapacitate",	-- Sap
	[199743] = "incapacitate",	-- Parley UNCONFIRMED SPELLID
	[ 20066] = "incapacitate",	-- Repentance
	[ 19386] = "incapacitate",	-- Wyvern Sting
	[  6789] = "incapacitate",	-- Mortal Coil UNCONFIRMED SPELLID & CATEGORY
	[200196] = "incapacitate",	-- Holy Word: Chastise
	[221527] = "incapacitate",	-- Imprison, Detainment Honor Talent UNCONFIRMED CATEGORY
	[217832] = "incapacitate",	-- Imprison UNCONFIRMED CATEGORY
	[    99] = "incapacitate",	-- Incapacitating Roar UNCONFIRMED SPELLID
	[ 82691] = "incapacitate",	-- Ring of Frost UNCONFIRMED SPELLID
	[  9484] = "incapacitate",	-- Shackle Undead UNCONFIRMED SPELLID
	[  1776] = "incapacitate",	-- Gouge UNCONFIRMED SPELLID
	[   710] = "incapacitate",	-- Banish UNCONFIRMED SPELLID & CATEGORY
	[107079] = "incapacitate",	-- Quaking Palm UNCONFIRMED SPELLID & CATEGORY
	[236025] = "incapacitate",	-- Enraged Maim UNCONFIRMED CATEGORY
	
	[   339] = "root",	-- Entangling Roots
	[   122] = "root",	-- Frost Nova
	[102359] = "root",	-- Mass Entanglement
	[ 64695] = "root",	-- Earthgrab
	[200108] = "root",	-- Ranger's Net
	[212638] = "root",	-- Tracker's Net
	[162480] = "root",	-- Steel Trap
	[204085] = "root",	-- Deathchill UNCONFIRMED IF THIS IS ON DR TABLE
	[233582] = "root",	-- Entrenched in Flame UNCONFIRMED IF THIS IS ON DR TABLE
	[201158] = "root",	-- Super Sticky Tar UNCONFIRMED SPELLID
	[ 33395] = "root",	-- Freeze UNCONFIRMED SPELLID
	[116706] = "root",	-- Disable UNCONFIRMED SPELLID
	[198121] = "root",	-- Frostbite UNCONFIRMED IF THIS IS ON DR TABLE
	
	[ 81261] = "silence",	-- Solar Beam
	[ 25046] = "silence",	-- Arcane Torrent
	[ 28730] = "silence",	-- Arcane Torrent
	[ 50613] = "silence",	-- Arcane Torrent
	[ 69179] = "silence",	-- Arcane Torrent
	[ 80483] = "silence",	-- Arcane Torrent
	[129597] = "silence",	-- Arcane Torrent
	[155145] = "silence",	-- Arcane Torrent
	[202719] = "silence",	-- Arcane Torrent
	[202933] = "silence",	-- Spider Sting
	[  1330] = "silence",	-- Garrote
	[ 15487] = "silence",	-- Silence UNCONFIRMED SPELLID
	[199683] = "silence",	-- Last Word UNCONFIRMED IF THIS IS ON DR TABLE
	[ 47476] = "silence",	-- Strangulate UNCONFIRMED SPELLID
	[204490] = "silence",	-- Sigil of Silence UNCONFIRMED SPELLID
}

function sArena.drtracker:ApplyDR(GUID, spellID, spellName, applied)
	local category = spells[spellID]
	if not category then return end
	
	local unitID
	for i = 1, MAX_ARENA_ENEMIES do
		if UnitGUID("arena"..i) == GUID then
			unitID = "arena"..i
			break
		end
	end
	
	if not unitID then return end
	
	local frame = self[unitID][category]
	if not frame then
		sArena:Print("Unknown DR Category \""..category.."\" for Spell ID " .. spellID)
		return
	end
	
	if applied then -- CC has been applied
		local _, _, _, _, _, auraDuration = UnitDebuff(unitID, spellName)
		CooldownFrame_Set(frame.Cooldown, GetTime(), drTime + auraDuration, 1, true)
	else -- CC has been removed (completed, dispelled, broken, etc.)
		-- Adjust timer for early CC breaks
		local startTime, startDuration = frame.Cooldown:GetCooldownTimes()
		startTime, startDuration = startTime/1000, startDuration/1000
		
		local newDuration = drTime / (1 - ((GetTime() - startTime) / startDuration))
		local newStartTime = drTime + GetTime() - newDuration
		CooldownFrame_Set(frame.Cooldown, newStartTime, newDuration, 1, true)
	end
	
	if not applied then return end
	
	local _, _, icon = GetSpellInfo(spellID)
	frame.Icon:SetTexture(icon)
	
	frame.Border:SetVertexColor(unpack(severityColor[frame.severity]))
	
	frame.severity = frame.severity + 1
	if frame.severity > 3 then
		frame.severity = 3
	end
end
