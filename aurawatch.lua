local sArena = LibStub("AceAddon-3.0"):GetAddon("sArena")

local AuraWatch = {}
LibStub("AceEvent-3.0"):Embed(AuraWatch)

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
	fontSize = 10,
}

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local GetSpellInfo = GetSpellInfo
local SetPortraitToTexture = SetPortraitToTexture
local UnitAura = UnitAura

local interruptReducers = {
	[221404] = 0.3, -- Burning Determination
	[221677] = 0.5, -- Calming Waters
	[221660] = 0.3, -- Holy Concentration
}

local interrupts = {
	[1766] = 5,	-- Kick (Rogue)
	[2139] = 6,	-- Counterspell (Mage)
	[6552] = 4,	-- Pummel (Warrior)
	[19647] = 6,	-- Spell Lock (Warlock)
	[47528] = 3,	-- Mind Freeze (Death Knight)
	[57994] = 3,	-- Wind Shear (Shaman)
	[91802] = 2,	-- Shambling Rush (Death Knight)
	[96231] = 4,	-- Rebuke (Paladin)
	[106839] = 4,	-- Skull Bash (Feral)
	[115781] = 6,	-- Optical Blast (Warlock)
	[116705] = 4,	-- Spear Hand Strike (Monk)
	[132409] = 6,	-- Spell Lock (Warlock)
	[147362] = 3,	-- Countershot (Hunter)
	[171138] = 6,	-- Shadow Lock (Warlock)
	[183752] = 3,	-- Consume Magic (Demon Hunter)
	[187707] = 3,	-- Muzzle (Hunter)
	[212619] = 6,	-- Call Felhunter (Warlock)
	[231665] = 3,	-- Avengers Shield (Paladin)
}

local spellList = {
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
	204437,	-- Lightning Lasso (Stun)

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
	207685,	-- Sigil of Misery (Disorient)
	198909,	-- Song of Chi-ji (Disorient)
	202274,	-- Incendiary Brew (Disorient)
	5782,	-- Fear (Disorient)
	118699,	-- Fear (Disorient)
	130616,	-- Fear (Disorient)
	115268,	-- Mesmerize (Disorient)
	6358,	-- Seduction (Disorient)
	87204,	-- Sin and Punishment (Disorient)

	51514,	-- Hex (Incapacitate)
	211004,	-- Hex: Spider (Incapacitate)
	210873,	-- Hex: Raptor (Incapacitate)
	211015,	-- Hex: Cockroach (Incapacitate)
	211010,	-- Hex: Snake (Incapacitate)
	196942,	-- Hex (Voodoo Totem)
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

	-- Interrupts
	1766,	-- Kick (Rogue)
	2139,	-- Counterspell (Mage)
	6552,	-- Pummel (Warrior)
	19647,	-- Spell Lock (Warlock)
	47528,	-- Mind Freeze (Death Knight)
	57994,	-- Wind Shear (Shaman)
	91802,	-- Shambling Rush (Death Knight)
	96231,	-- Rebuke (Paladin)
	106839,	-- Skull Bash (Feral)
	115781,	-- Optical Blast (Warlock)
	116705,	-- Spear Hand Strike (Monk)
	132409,	-- Spell Lock (Warlock)
	147362,	-- Countershot (Hunter)
	171138,	-- Shadow Lock (Warlock)
	183752,	-- Consume Magic (Demon Hunter)
	187707,	-- Muzzle (Hunter)
	212619,	-- Call Felhunter (Warlock)
	231665,	-- Avengers Shield (Paladin)

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
	205191,	-- Eye for an Eye
	498,	-- Divine Protection
	871,	-- Shield Wall
	53480,	-- Roar of Sacrifice
	197690,	-- Defensive Stance

	-- Miscellaneous
	199450,	-- Ultimate Sacrifice
	188501,	-- Spectral Sight
	1044,	-- Blessing of Freedom
	41425,	-- Hypothermia
}

local priorityList = {}

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

function AuraWatch:OnEnable()
	-- Create prioritized aura list. We're simply swapping the keys and values from spellList
	for k, v in ipairs(spellList) do
		priorityList[v] = k
	end

	for i = 1, 5 do
		local arenaFrame = _G["ArenaEnemyFrame"..i]

		local frame = CreateFrame("Cooldown", nil, arenaFrame, "CooldownFrameTemplate")
		--frame:SetSwipeColor(0, 0, 0, 0.6)
		frame:SetDrawBling(false)
		frame:SetReverse(true)
		frame:SetHideCountdownNumbers(false)
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
		frame.activeId = nil
		frame.aura = { spellId = nil, icon = nil, start = nil, expire = nil }
		frame.interrupt = { spellId = nil, icon = nil, start = nil, expire = nil }

		-- Check for auras when an interrupt lockout expires
		frame:HookScript("OnHide", function(self)
			AuraWatch:UNIT_AURA(nil, "arena"..i)
		end)

		self["arena"..i] = frame
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
sArena.RegisterCallback(AuraWatch, "sArena_OnEnable", "OnEnable")

function AuraWatch:RefreshConfig()
	for i = 1, 5 do
		local frame = self["arena"..i]

		local fontFace, _, fontFlags = frame.Text:GetFont()
		frame.Text:SetFont(fontFace, sArena.db.profile.aurawatch.fontSize, fontFlags)
	end
end
sArena.RegisterCallback(AuraWatch, "sArena_RefreshConfig", "RefreshConfig")

function AuraWatch:TestMode()
	for i = 1, 3 do
		local frame = self["arena"..i]
		if sArena.testMode and sArena.db.profile.aurawatch.enabled then
			CooldownFrame_Set(frame, GetTime(), 30, 1, true)
			frame.classPortrait:SetTexCoord(0, 1, 0, 1)
			if sArena.db.profile.simpleFrames then
				frame.classPortrait:SetTexture(136184)
			else
				SetPortraitToTexture(frame.classPortrait, 136184)
			end
		else
			CooldownFrame_Set(frame, 0, 0, 0, true)
		end
	end
end
sArena.RegisterCallback(AuraWatch, "sArena_TestMode", "TestMode")

function AuraWatch:ApplyAura(unitID)
	local frame = self[unitID]

	local spellId, icon, start, expire

	-- Check if an aura was found
	if frame.aura.spellId then
		spellId, icon, start, expire = frame.aura.spellId, frame.aura.icon, frame.aura.start, frame.aura.expire
	end

	-- Check if there's an interrupt lockout
	if frame.interrupt.spellId then
		-- Make sure the lockout is still active
		if frame.interrupt.expire < GetTime() then
			frame.interrupt.spellId = nil
		-- Select the greatest priority (aura or interrupt)
		elseif spellId and priorityList[frame.interrupt.spellId] < priorityList[spellId] or not spellId then
			spellId, icon, start, expire = frame.interrupt.spellId, frame.interrupt.icon, frame.interrupt.start, frame.interrupt.expire
		end
	end

	-- Set up the icon & cooldown
	if spellId then
		CooldownFrame_Set(frame, start, expire - start, 1, true)
		if spellId ~= frame.activeId then
			frame.activeId = spellId
			frame.classPortrait:SetTexCoord(0,1,0,1)
			if sArena.db.profile.simpleFrames then
				frame.classPortrait:SetTexture(icon)
			else
				SetPortraitToTexture(frame.classPortrait, icon)
			end
		end
	-- Remove cooldown & reset icon back to class icon
	elseif frame.activeId then
		frame.activeId = nil
		local _, class = UnitClass(unitID)
		if class then
			CooldownFrame_Set(frame, 0, 0, 0, true)
			if sArena.db.profile.simpleFrames then
				frame.classPortrait:SetTexture(classIcons[class])
				frame.classPortrait:SetTexCoord(0,1,0,1)
			else
				frame.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				frame.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			end
		end
	end
end

function AuraWatch:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:RegisterEvent("UNIT_AURA")
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:UnregisterEvent("UNIT_AURA")
	end
end

function AuraWatch:UNIT_AURA(_, unitID)
	if not sArena.db.profile.aurawatch.enabled then return end
	if not self[unitID] then return end

	local priorityAura = {
		icon = nil,
		spellId = nil,
		duration = nil,
		expires = nil,
	}
	local duration, icon, expires, spellId

	for _, filter in pairs({"HELPFUL", "HARMFUL"}) do
		for i = 1, 40 do
			_, icon, _, _, duration, expires, _, _, _, spellId = UnitAura(unitID, i, filter)
			if not spellId then break end

			if priorityList[spellId] then
				-- Select the greatest priority aura
				if not priorityAura.spellId or priorityList[spellId] < priorityList[priorityAura.spellId] then
					priorityAura.icon = icon
					priorityAura.spellId = spellId
					priorityAura.duration = duration
					priorityAura.expires = expires
				end
			end
		end
	end

	local frame = self[unitID]

	if priorityAura.spellId then
		frame.aura.spellId = priorityAura.spellId
		frame.aura.icon = priorityAura.icon
		frame.aura.start = priorityAura.expires - priorityAura.duration
		frame.aura.expire = priorityAura.expires
	else
		frame.aura.spellId = nil
	end

	self:ApplyAura(unitID)
end

function AuraWatch:COMBAT_LOG_EVENT_UNFILTERED()
	if not sArena.db.profile.aurawatch.enabled then return end

	local _, event, _, _, _, _, _, destGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo()

	-- Check if the spell is being tracked
	if not interrupts[spellId] then return end

	-- Apparently SPELL_INTERRUPT doesn't capture interrupts that are used on channelled abilities
	if event ~= "SPELL_INTERRUPT" or event ~= "SPELL_CAST_SUCCESS" then return end

	local unitID
	for i = 1, 5 do
		if UnitGUID("arena"..i) == destGUID then
			unitID = "arena"..i
			break
		end
	end

	-- Only track interrupts that are used on arena opponents
	if not unitID then return end

	local _, _, _, _, _, _, _, notInterruptable = UnitChannelInfo(unitID)
	if event == "SPELL_INTERRUPT" or notInterruptable == false then
		local frame = self[unitID]
		local duration = interrupts[spellId]
		local _, class = UnitClass(unitID)
		local _, _, icon = GetSpellInfo(spellId)
		local start = GetTime()

		-- Adjust the lockout duration for some classes
		if class == "PRIEST" or class == "SHAMAN" or class == "WARLOCK" then
			duration = duration * 0.7
		end

		-- Adjust the lockout duration for some talents
		if interruptReducers[spellId] then
			duration = duration * interruptReducers[spellId]
		end

		frame.interrupt.spellId = spellId
		frame.interrupt.icon = icon
		frame.interrupt.start = start
		frame.interrupt.expire = start + duration

		self:ApplyAura(unitID)
	end
end
