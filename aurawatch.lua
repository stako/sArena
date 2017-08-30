local sArena = LibStub("AceAddon-3.0"):GetAddon("sArena")

sArena.aurawatch = {}
local UnitAura, GetSpellInfo, SetPortraitToTexture = UnitAura, GetSpellInfo, SetPortraitToTexture

sArena.options.plugins = sArena.options.plugins or {}
sArena.options.plugins["AuraWatch"] = {
	aurawatch = {
		name = "AuraWatch",
		type = "group",
		desc = "Displays important buffs and debuffs on the class icon",
		args = {
			enable = {
				name = "Enable",
				type = "toggle",
				order = 1,
				get = function() return sArena.db.profile.aurawatch.enabled end,
				set = function(info, val) sArena.db.profile.aurawatch.enabled = val sArena:RefreshConfig() end,
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
				get = function() return sArena.db.profile.aurawatch.fontSize end,
				set = function(info, val) sArena.db.profile.aurawatch.fontSize = val sArena:RefreshConfig() end,
			},
		},
	},
}

sArena.defaults.profile.aurawatch = {
	enabled = true,
	fontSize = 12,
}

local spells = {
	-- Higher up = higher display priority
	
	-- CCs
	5211,	-- Mighty Bash (Stun)
	108194,	-- Asphyxiate (Stun)
	199804, -- Between the Eyes (Stun)
	118905,	-- Static Charge (Stun)
	1833,	-- Cheap Shot (Stun)
	853,	-- Hammer of Justice (Stun)
	117526,	-- Binding Shot (Stun)
	179057,	-- Chaos Nova (Stun)
	207171,	-- Winter is Coming (Stun)
	132169,	-- Storm Bolt (Stun)
	408,	-- Kidney Shot (Stun)
	163505,	-- Rake (Stun)
	119381,	-- Leg Sweep (Stun)
	232055,	-- Fists of Fury (Stun)
	89766,	-- Axe Toss (Stun)
	30283,	-- Shadowfury (Stun)
	200166,	-- Metamorphosis (Stun)
	226943,	-- Mind Bomb (Stun)
	24394,	-- Intimidation (Stun)
	211881,	-- Fel Eruption (Stun)
	221562,	-- Asphyxiate, Blood Spec (Stun)
	91800,	-- Gnaw (Stun)
	91797,	-- Monstrous Blow (Stun)
	205630,	-- Illidan's Grasp (Stun)
	208618,	-- Illidan's Grasp (Stun)
	203123,	-- Maim (Stun)
	200200,	-- Holy Word: Chastise, Censure Talent (Stun)
	118345,	-- Pulverize (Stun)
	22703,	-- Infernal Awakening (Stun)
	132168,	-- Shockwave (Stun)
	20549,	-- War Stomp (Stun)
	199085,	-- Warpath (Stun)

	33786,	-- Cyclone (Disorient)
	209753,	-- Cyclone, Honor Talent (Disorient)
	5246,	-- Intimidating Shout (Disorient)
	238559,	-- Bursting Shot (Disorient)
	224729,	-- Bursting Shot on NPC's (Disorient)
	8122,	-- Psychic Scream (Disorient)
	2094,	-- Blind (Disorient)
	5484,	-- Howl of Terror (Disorient)
	605,	-- Mind Control (Disorient)
	105421,	-- Blinding Light (Disorient)
	207167,	-- Blinding Sleet (Disorient)
	31661,	-- Dragon's Breath (Disorient)
	207685,	-- Sigil of Misery
	198909,	-- Song of Chi-ji
	202274,	-- Incendiary Brew
	5782,	-- Fear
	118699,	-- Fear
	130616,	-- Fear
	115268,	-- Mesmerize
	6358,	-- Seduction

	51514,	-- Hex (Incapacitate)
	211004,	-- Hex: Spider (Incapacitate)
	210873,	-- Hex: Raptor (Incapacitate)
	211015,	-- Hex: Cockroach (Incapacitate)
	211010,	-- Hex: Snake (Incapacitate)
	118,	-- Polymorph (Incapacitate)
	61305,	-- Polymorph: Black Cat (Incapacitate)
	28272,	-- Polymorph: Pig (Incapacitate)
	61721,	-- Polymorph: Rabbit (Incapacitate)
	61780,	-- Polymorph: Turkey (Incapacitate)
	28271,	-- Polymorph: Turtle (Incapacitate)
	161353,	-- Polymorph: Polar Bear Cub (Incapacitate)
	126819,	-- Polymorph: Porcupine (Incapacitate)
	161354,	-- Polymorph: Monkey (Incapacitate)
	161355,	-- Polymorph: Penguin (Incapacitate)
	161372,	-- Polymorph: Peacock (Incapacitate)
	3355,	-- Freezing Trap (Incapacitate)
	203337,	-- Freezing Trap, Diamond Ice Honor Talent (Incapacitate)
	115078,	-- Paralysis (Incapacitate)
	213691,	-- Scatter Shot (Incapacitate)
	6770,	-- Sap (Incapacitate)
	199743,	-- Parley (Incapacitate)
	20066,	-- Repentance (Incapacitate)
	19386,	-- Wyvern Sting (Incapacitate)
	6789,	-- Mortal Coil (Incapacitate)
	200196,	-- Holy Word: Chastise (Incapacitate)
	221527,	-- Imprison, Detainment Honor Talent (Incapacitate)
	217832,	-- Imprison (Incapacitate)
	99,		-- Incapacitating Roar (Incapacitate)
	82691,	-- Ring of Frost (Incapacitate)
	9484,	-- Shackle Undead (Incapacitate)
	64044,	-- Psychic Horror (Incapacitate)
	1776,	-- Gouge (Incapacitate)
	710,	-- Banish (Incapacitate)
	107079,	-- Quaking Palm (Incapacitate)
	236025,	-- Enraged Maim (Incapacitate)

	-- Immunities
	642,	-- Divine Shield
	186265, -- Aspect of the Turtle
	45438,	-- Ice Block
	47585,	-- Dispersion
	1022,	-- Blessing of Protection
	216113,	-- Way of the Crane
	31224,	-- Cloak of Shadows
	212182,	-- Smoke Bomb
	212183,	-- Smoke Bomb
	8178,	-- Grounding Totem Effect
	199448,	-- Blessing of Sacrifice

	-- Anti CCs
	23920,	-- Spell Reflection
	216890, -- Spell Reflection (Honor Talent)
	213610,	-- Holy Ward
	212295,	-- Nether Ward
	48707,	-- Anti-Magic Shell
	5384,	-- Feign Death
	213602,	-- Greater Fade
	
	-- Silences
	81261,	-- Solar Beam
	25046,	-- Arcane Torrent
	28730,	-- Arcane Torrent
	50613,	-- Arcane Torrent
	69179,	-- Arcane Torrent
	80483,	-- Arcane Torrent
	129597,	-- Arcane Torrent
	155145,	-- Arcane Torrent
	202719,	-- Arcane Torrent
	202933,	-- Spider Sting
	1330,	-- Garrote
	15487,	-- Silence
	199683,	-- Last Word
	47476,	-- Strangulate
	31935,	-- Avenger's Shield
	204490,	-- Sigil of Silence

	-- Roots
	339,	-- Entangling Roots
	122,	-- Frost Nova
	102359,	-- Mass Entanglement
	64695,	-- Earthgrab
	200108,	-- Ranger's Net
	212638,	-- Tracker's Net
	162480,	-- Steel Trap
	204085,	-- Deathchill
	233582,	-- Entrenched in Flame
	201158,	-- Super Sticky Tar
	33395,	-- Freeze
	228600,	-- Glacial Spike
	116706,	-- Disable

	236077,	-- Disarm
	209749,	-- Faerie Swarm (Disarm)

	-- Offensive Buffs
	186289,	-- Aspect of the Eagle
	193526, -- Trueshot
	19574,	-- Bestial Wrath
	121471, -- Shadow Blades
	102560,	-- Incarnation: Chosen of Elune
	194223,	-- Celestial Alignment
	1719,	-- Battle Cry
	162264,	-- Metamorphosis
	211048,	-- Chaos Blades
	190319,	-- Combustion
	194249,	-- Voidform
	51271,	-- Pillar of Frost
	114051,	-- Ascendance (Enhancement)
	114050,	-- Ascendance (Elemental)
	107574,	-- Avatar
	12292,	-- Bloodbath
	204945,	-- Doom Winds
	2825,	-- Bloodlust
	32182,	-- Heroism
	204361,	-- Bloodlust (Honor Talent)
	204362,	-- Heroism (Honor Talent)
	13750,	-- Adrenaline Rush
	102543,	-- Incarnation: King of the Jungle
	137639,	-- Storm, Earth, and Fire
	152173,	-- Serenity
	12042,	-- Arcane Power
	12472,	-- Icy Veins
	198144,	-- Ice Form
	31884,	-- Avenging Wrath (Retribution)
	196098,	-- Soul Harvest
	16166,	-- Elemental Mastery
	10060,	-- Power Infusion

	-- Defensive Buffs
	210256,	-- Blessing of Sanctuary
	6940,	-- Blessing of Sacrifice
	125174,	-- Touch of Karma
	47788,	-- Guardian Spirit
	197268,	-- Ray of Hope
	5277,	-- Evasion
	199754,	-- Riposte
	212800,	-- Blur
	102342,	-- Ironbark
	22812,	-- Barkskin
	117679,	-- Incarnation: Tree of Life
	198065,	-- Prismatic Cloak
	198111,	-- Temporal Shield
	108271,	-- Astral Shift
	114052,	-- Ascendance (Restoration)
	207319,	-- Corpse Shield
	104773,	-- Unending Resolve
	48792,	-- Icebound Fortitude
	55233,	-- Vampiric Blood
	61336,	-- Survival Instincts
	116849,	-- Life Cocoon
	33206,	-- Pain Suppression
	197862,	-- Archangel
	31850,	-- Ardent Defender
	120954,	-- Fortifying Brew
	108416,	-- Dark Pact
	216331,	-- Avenging Crusader
	31842,	-- Avenging Wrath (Holy)
	118038,	-- Die by the Sword
	12975,	-- Last Stand
	498,	-- Divine Protection
	871,	-- Shield Wall
	53480,	-- Roar of Sacrifice
	197690,	-- Defensive Stance

	-- Miscellaneous
	199450,	-- Ultimate Sacrifice
	1044,	-- Blessing of Freedom
}

local auraList = {}
local testModeClasses = { "ROGUE", "MAGE", "PRIEST" }
local classIcons = {
	["DRUID"] = 625999,
	["HUNTER"] = 626000,
	["MAGE"] = 626001,
	["MONK"] = 626002,
	["PALADIN"] = 626003,
	["PRIEST"] = 626004,
	["ROGUE"] = 626005,
	["SHAMAN"] = 626006,
	["WARLOCK"] = 626007,
	["WARRIOR"] = 626008,
	["DEATHKNIGHT"] = 135771,
	["DEMONHUNTER"] = 1260827,
}

function sArena.aurawatch:OnEnable()
	-- Create prioritized aura list. We're simply swapping the keys and values from sArena.AuraWatch.Spells
	for k, v in ipairs(spells) do
		auraList[v] = k
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local arenaFrame = _G["ArenaEnemyFrame"..i]
		
		local frame = CreateFrame("Cooldown", nil, arenaFrame, "CooldownFrameTemplate")
		frame:SetSwipeColor(0, 0, 0, 0.6)
		frame:SetDrawBling(false)
		frame:SetReverse(true)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", arenaFrame.classPortrait, "TOPLEFT", 2, -2)
		frame:SetPoint("BOTTOMRIGHT", arenaFrame.classPortrait, "BOTTOMRIGHT", -2, 2)
		
		for _, region in next, {frame:GetRegions()} do
			if ( region:GetObjectType() == "FontString" ) then
				frame.Text = region
			end
		end
		
		frame.Text:ClearAllPoints()
		frame.Text:SetPoint("CENTER", frame, "CENTER", 0, 1)
		
		frame.classPortrait = arenaFrame.classPortrait
		frame.currentSpellId = 0
		
		frame:SetHideCountdownNumbers(false)
		
		self["arena"..i] = frame
	end
end
sArena.RegisterCallback(sArena.aurawatch, "sArena_OnEnable", "OnEnable")

function sArena.aurawatch:RefreshConfig()
	for i = 1, MAX_ARENA_ENEMIES do
		local frame = self["arena"..i]
		
		local fontFace, _, fontFlags = frame.Text:GetFont()
		frame.Text:SetFont(fontFace, sArena.db.profile.aurawatch.fontSize, fontFlags)
	end
end
sArena.RegisterCallback(sArena.aurawatch, "sArena_RefreshConfig", "RefreshConfig")

function sArena.aurawatch:TestMode()
	for i = 1, 3 do
		local frame = self["arena"..i]
		if sArena.testMode == true and sArena.db.profile.aurawatch.enabled == true then
			CooldownFrame_Set(frame, GetTime(), 30, 1, true)
			frame.classPortrait:SetTexCoord(0, 1, 0, 1)
			if sArena.db.profile.simpleFrames == true then
				frame.classPortrait:SetTexture(136184)
			else
				SetPortraitToTexture(frame.classPortrait, 136184)
			end
		else
			CooldownFrame_Set(frame, 0, 0, 0, true)
		end
	end
end
sArena.RegisterCallback(sArena.aurawatch, "sArena_TestMode", "TestMode")

function sArena.aurawatch:UNIT_AURA(_, unitID)
	if sArena.db.profile.aurawatch.enabled == false then return end
	if not self[unitID] then return end
	
	local spellId, filter, buff, debuff
	
	-- Loop through unit's auras
	for i = 1, 32 do -- BUFF_MAX_DISPLAY = 32
		_, _, _, _, _, _, _, _, _, _, buff = UnitAura(unitID, i, "HELPFUL")
		-- See if buff exists in our table
		if buff and auraList[buff] then
			-- Compare with the previous buff found in the for loop (if it exists) and select the greatest priority buff
			if not spellId or auraList[buff] < auraList[spellId] then
				spellId = buff
				filter = "HELPFUL"
			end
		end
		
		if i <= 16 then -- DEBUFF_MAX_DISPLAY = 16
			_, _, _, _, _, _, _, _, _, _, debuff = UnitAura(unitID, i, "HARMFUL")
		end
		
		-- Same as above, but with debuffs
		if debuff and auraList[debuff] then
			if not spellId or auraList[debuff] < auraList[spellId] then
				spellId = debuff
				filter = "HARMFUL"
			end
		end
		
		if not buff and not debuff then break end
	end
	
	-- If an aura is found, set spell texture and cooldown, else set class portrait
	if spellId then
		local name, rank = GetSpellInfo(spellId)
		local _, _, icon, _, _, duration, expires = UnitAura(unitID, name, rank, filter)
		CooldownFrame_Set(self[unitID], expires - duration, duration, 1, true)
		if self[unitID].currentSpellId == spellId then return end
		self[unitID].classPortrait:SetTexCoord(0,1,0,1)
		self[unitID].currentSpellId = spellId
		if sArena.db.profile.simpleFrames == true then
			self[unitID].classPortrait:SetTexture(icon)
		else
			SetPortraitToTexture(self[unitID].classPortrait, icon)
		end
	else
		local _, class = UnitClass(unitID)
		if class then
			CooldownFrame_Set(self[unitID], 0, 0, 0, true)
			self[unitID].currentSpellId = 0
			if sArena.db.profile.simpleFrames == true then
				self[unitID].classPortrait:SetTexture(classIcons[class])
				self[unitID].classPortrait:SetTexCoord(0,1,0,1)
			else
				self[unitID].classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				self[unitID].classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			end
		end
	end
end
sArena.RegisterCallback(sArena.aurawatch, "sArena_UNIT_AURA", "UNIT_AURA")
