local AddonName, sArena = ...

sArena.AuraWatch.Spells = {
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
	119381,	-- Leg Sweep (Stun) UNCONFIRMED
	232055,	-- Fists of Fury (Stun)
	89766,	-- Axe Toss (Stun)
	30283,	-- Shadowfury (Stun) UNCONFIRMED
	200166,	-- Metamorphosis (Stun)
	226943,	-- Mind Bomb (Stun)
	24394,	-- Intimidation (Stun)
	211881,	-- Fel Eruption (Stun) UNCONFIRMED
	221562,	-- Asphyxiate, Blood Spec (Stun) UNCONFIRMED
	91800,	-- Gnaw (Stun) UNCONFIRMED
	91797,	-- Monstrous Blow (Stun) UNCONFIRMED
	205630,	-- Illidan's Grasp (Stun)
	208618,	-- Illidan's Grasp (Stun)
	203123,	-- Maim (Stun) UNCONFIRMED
	200200,	-- Holy Word: Chastise, Censure Talent (Stun)
	118345,	-- Pulverize (Stun)
	22703,	-- Infernal Awakening (Stun) UNCONFIRMED
	132168,	-- Shockwave (Stun) UNCONFIRMED
	20549,	-- War Stomp (Stun) UNCONFIRMED
	199085,	-- Warpath (Stun)
	
	33786,	-- Cyclone (Disorient)
	209753,	-- Cyclone, Honor Talent (Disorient)
	5246,	-- Intimidating Shout (Disorient)
	238559,	-- Bursting Shot (Disorient)
	224729,	-- Bursting Shot on NPC's (Disorient)
	8122,	-- Psychic Scream (Disorient)
	2094,	-- Blind (Disorient)
	5484,	-- Howl of Terror (Disorient) UNCONFIRMED
	605,	-- Mind Control (Disorient)
	105421,	-- Blinding Light (Disorient)
	207167,	-- Blinding Sleet (Disorient) UNCONFIRMED
	31661,	-- Dragon's Breath (Disorient) UNCONFIRMED
	207685,	-- Sigil of Misery
	198909,	-- Song of Chi-ji UNCONFIRMED
	202274,	-- Incendiary Brew UNCONFIRMED
	5782,	-- Fear UNCONFIRMED
	118699,	-- Fear UNCONFIRMED
	130616,	-- Fear UNCONFIRMED
	115268,	-- Mesmerize UNCONFIRMED
	6358,	-- Seduction UNCONFIRMED
	
	51514,	-- Hex (Incapacitate) UNCONFIRMED
	211004,	-- Hex: Spider (Incapacitate) UNCONFIRMED
	210873,	-- Hex: Raptor (Incapacitate) UNCONFIRMED
	211015,	-- Hex: Cockroach (Incapacitate) UNCONFIRMED
	211010,	-- Hex: Snake (Incapacitate) UNCONFIRMED
	118,	-- Polymorph (Incapacitate)
	61305,	-- Polymorph: Black Cat (Incapacitate) UNCONFIRMED
	28272,	-- Polymorph: Pig (Incapacitate) UNCONFIRMED
	61721,	-- Polymorph: Rabbit (Incapacitate) UNCONFIRMED
	61780,	-- Polymorph: Turkey (Incapacitate) UNCONFIRMED
	28271,	-- Polymorph: Turtle (Incapacitate) UNCONFIRMED
	161353,	-- Polymorph: Polar Bear Cub (Incapacitate) UNCONFIRMED
	126819,	-- Polymorph: Porcupine (Incapacitate) UNCONFIRMED
	161354,	-- Polymorph: Monkey (Incapacitate) UNCONFIRMED
	161355,	-- Polymorph: Penguin (Incapacitate) UNCONFIRMED
	161372,	-- Polymorph: Peacock (Incapacitate) UNCONFIRMED
	3355,	-- Freezing Trap (Incapacitate)
	203337,	-- Freezing Trap, Diamond Ice Honor Talent (Incapacitate)
	115078,	-- Paralysis (Incapacitate)
	213691,	-- Scatter Shot (Incapacitate)
	6770,	-- Sap (Incapacitate)
	199743,	-- Parley (Incapacitate) UNCONFIRMED
	20066,	-- Repentance (Incapacitate)
	19386,	-- Wyvern Sting (Incapacitate)
	6789,	-- Mortal Coil (Incapacitate) UNCONFIRMED
	200196,	-- Holy Word: Chastise (Incapacitate)
	221527,	-- Imprison, Detainment Honor Talent (Incapacitate)
	217832,	-- Imprison (Incapacitate)
	99,		-- Incapacitating Roar (Incapacitate) UNCONFIRMED
	82691,	-- Ring of Frost (Incapacitate) UNCONFIRMED
	9484,	-- Shackle Undead (Incapacitate) UNCONFIRMED
	64044,	-- Psychic Horror (Incapacitate) UNCONFIRMED
	1776,	-- Gouge (Incapacitate) UNCONFIRMED
	710,	-- Banish (Incapacitate) UNCONFIRMED
	107079,	-- Quaking Palm (Incapacitate) UNCONFIRMED
	236025,	-- Enraged Maim (Incapacitate) UNCONFIRMED
	
	-- Immunities
	642,	-- Divine Shield
	186265, -- Aspect of the Turtle
	45438,	-- Ice Block
	47585,	-- Dispersion
	1022,	-- Blessing of Protection
	216113,	-- Way of the Crane
	31224,	-- Cloak of Shadows UNCONFIRMED
	212182,	-- Smoke Bomb UNCONFIRMED
	212183,	-- Smoke Bomb UNCONFIRMED
	8178,	-- Grounding Totem Effect
	
	-- Anti CCs
	23920,	-- Spell Reflection
	213610,	-- Holy Ward
	212295,	-- Nether Ward
	48707,	-- Anti-Magic Shell
	5384,	-- Feign Death
	
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
	201158,	-- Super Sticky Tar UNCONFIRMED
	33395,	-- Freeze UNCONFIRMED
	228600,	-- Glacial Spike
	116706,	-- Disable UNCONFIRMED
	
	-- Silences
	81261,	-- Solar Beam
	25046,	-- Arcane Torrent UNCONFIRMED
	28730,	-- Arcane Torrent UNCONFIRMED
	50613,	-- Arcane Torrent UNCONFIRMED
	69179,	-- Arcane Torrent UNCONFIRMED
	80483,	-- Arcane Torrent UNCONFIRMED
	129597,	-- Arcane Torrent
	155145,	-- Arcane Torrent UNCONFIRMED
	202719,	-- Arcane Torrent UNCONFIRMED
	202933,	-- Spider Sting
	1330,	-- Garrote
	15487,	-- Silence UNCONFIRMED
	199683,	-- Last Word
	47476,	-- Strangulate UNCONFIRMED
	204490,	-- Sigil of Silence UNCONFIRMED
	
	-- Offensive Buffs
	186289,	-- Aspect of the Eagle
	193526, -- Trueshot
	19574,	-- Bestial Wrath
	121471, -- Shadow Blades
	102560,	-- Incarnation: Chosen of Elune
	194223,	-- Celestial Alignment
	1719,	-- Battle Cry
	162264,	-- Metamorphosis
	211048,	-- Chaos Blades UNCONFIRMED
	190319,	-- Combustion
	194249,	-- Voidform
	51271,	-- Pillar of Frost
	107574,	-- Avatar
	204945,	-- Doom Winds
	13750,	-- Adrenaline Rush
	102543,	-- Incarnation: King of the Jungle
	137639,	-- Storm, Earth, and Fire
	12042,	-- Arcane Power
	12472,	-- Icy Veins
	198144,	-- Ice Form
	31884,	-- Avenging Wrath (Retribution) UNCONFIRMED
	196098,	-- Soul Harvest
	
	-- Defensive Buffs
	210256,	-- Blessing of Sanctuary UNCONFIRMED
	6940,	-- Blessing of Sacrifice UNCONFIRMED
	122470,	-- Touch of Karma
	5277,	-- Evasion
	199754,	-- Riposte
	212800,	-- Blur
	102342,	-- Ironbark
	22812,	-- Barkskin
	198065,	-- Prismatic Cloak
	198111,	-- Temporal Shield
	108271,	-- Astral Shift
	114052,	-- Ascendance
	207319,	-- Corpse Shield
	104773,	-- Unending Resolve
	48792,	-- Icebound Fortitude
	55233,	-- Vampiric Blood UNCONFIRMED
	61336,	-- Survival Instincts
	116849,	-- Life Cocoon
	197862,	-- Archangel
	31850,	-- Ardent Defender
	120954,	-- Fortifying Brew
	108416,	-- Dark Pact
	216331,	-- Avenging Crusader UNCONFIRMED
	31842,	-- Avenging Wrath (Holy) UNCONFIRMED
	197690,	-- Defensive Stance
	
	-- Miscellaneous
	236077,	-- Disarm
	199450,	-- Ultimate Sacrifice
	1044,	-- Blessing of Freedom
	195901,	-- Adapted (Adaptation Honor Talent)
	195488,	-- Vim and Vigor
}
