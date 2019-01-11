sArenaMixin.interruptList = {
    [1766] = 5,     -- Kick (Rogue)
    [2139] = 6,     -- Counterspell (Mage)
    [6552] = 4,     -- Pummel (Warrior)
    [19647] = 6,    -- Spell Lock (Warlock)
    [47528] = 3,    -- Mind Freeze (Death Knight)
    [57994] = 3,    -- Wind Shear (Shaman)
    [91802] = 2,    -- Shambling Rush (Death Knight)
    [96231] = 4,    -- Rebuke (Paladin)
    [106839] = 4,   -- Skull Bash (Feral)
    [115781] = 6,   -- Optical Blast (Warlock)
    [116705] = 4,   -- Spear Hand Strike (Monk)
    [132409] = 6,   -- Spell Lock (Warlock)
    [147362] = 3,   -- Countershot (Hunter)
    [171138] = 6,   -- Shadow Lock (Warlock)
    [183752] = 3,   -- Consume Magic (Demon Hunter)
    [187707] = 3,   -- Muzzle (Hunter)
    [212619] = 6,   -- Call Felhunter (Warlock)
    [231665] = 3,   -- Avengers Shield (Paladin)
};

sArenaMixin.auraList = tInvert({
    -- Higher up = higher priority

    -- CCs
    5211,   -- Mighty Bash (Stun)
    108194, -- Asphyxiate (Stun)
    199804, -- Between the Eyes (Stun)
    118905, -- Static Charge (Stun)
    1833,   -- Cheap Shot (Stun)
    853,    -- Hammer of Justice (Stun)
    179057, -- Chaos Nova (Stun)
    132169, -- Storm Bolt (Stun)
    408,    -- Kidney Shot (Stun)
    163505, -- Rake (Stun)
    119381, -- Leg Sweep (Stun)
    89766,  -- Axe Toss (Stun)
    30283,  -- Shadowfury (Stun)
    24394,  -- Intimidation (Stun)
    211881, -- Fel Eruption (Stun)
    91800,  -- Gnaw (Stun)
    205630, -- Illidan's Grasp (Stun)
    203123, -- Maim (Stun)
    200200, -- Holy Word: Chastise, Censure Talent (Stun)
    22703,  -- Infernal Awakening (Stun)
    132168, -- Shockwave (Stun)
    20549,  -- War Stomp (Stun)
    199085, -- Warpath (Stun)
    204437, -- Lightning Lasso (Stun)
    64044,  -- Psychic Horror (Stun)
    255723, -- Bull Rush (Stun)
    202346, -- Double Barrel (Stun)
    213688, -- Fel Cleave (Stun)
    204399, -- Earthfury (Stun)
    91717,  -- Monstrous Blow (Stun)


    33786,  -- Cyclone (Disorient)
    209753, -- Cyclone Balance Talent (Disorient)
    5246,   -- Intimidating Shout (Disorient)
    8122,   -- Psychic Scream (Disorient)
    2094,   -- Blind (Disorient)
    605,    -- Mind Control (Disorient)
    105421, -- Blinding Light (Disorient)
    207167, -- Blinding Sleet (Disorient)
    31661,  -- Dragon's Breath (Disorient)
    207685, -- Sigil of Misery (Disorient)
    198909, -- Song of Chi-ji (Disorient)
    202274, -- Incendiary Brew (Disorient)
    118699, -- Fear (Disorient)
    6358,   -- Seduction (Disorient)
    261589, -- Seduction 2 (Disorient)
    87204,  -- Sin and Punishment (Disorient)
    2637,   -- Hibernate (Disorient)
    226943, -- Mind Bomb (Disorient)
    236748, -- Intimidating Roar (Disorient)

    51514,  -- Hex (Incapacitate)
    211004, -- Hex: Spider (Incapacitate)
    210873, -- Hex: Raptor (Incapacitate)
    211015, -- Hex: Cockroach (Incapacitate)
    211010, -- Hex: Snake (Incapacitate)
    196942, -- Hex: Voodoo Totem (Incapacitate)
    277784, -- Hex: Wicker Mongrel (Incapacitate)
    277778, -- Hex: Zandalari Tendonripper (Incapacitate)
    118,    -- Polymorph (Incapacitate)
    61305,  -- Polymorph: Black Cat (Incapacitate)
    28272,  -- Polymorph: Pig (Incapacitate)
    61721,  -- Polymorph: Rabbit (Incapacitate)
    61780,  -- Polymorph: Turkey (Incapacitate)
    28271,  -- Polymorph: Turtle (Incapacitate)
    161353, -- Polymorph: Polar Bear Cub (Incapacitate)
    126819, -- Polymorph: Porcupine (Incapacitate)
    161354, -- Polymorph: Monkey (Incapacitate)
    161355, -- Polymorph: Penguin (Incapacitate)
    161372, -- Polymorph: Peacock (Incapacitate)
    277792, -- Polymorph: Bumblebee (Incapacitate)
    277787, -- Polymorph: Baby Direhorn (Incapacitate)
    3355,   -- Freezing Trap (Incapacitate)
    203337, -- Freezing Trap, Diamond Ice Honor Talent (Incapacitate)
    115078, -- Paralysis (Incapacitate)
    213691, -- Scatter Shot (Incapacitate)
    6770,   -- Sap (Incapacitate)
    20066,  -- Repentance (Incapacitate)
    200196, -- Holy Word: Chastise (Incapacitate)
    221527, -- Imprison, Detainment Honor Talent (Incapacitate)
    217832, -- Imprison (Incapacitate)
    99,     -- Incapacitating Roar (Incapacitate)
    82691,  -- Ring of Frost (Incapacitate)
    1776,   -- Gouge (Incapacitate)
    107079, -- Quaking Palm (Incapacitate)
    236025, -- Enraged Maim (Incapacitate)
    197214, -- Sundering (Incapacitate)

    -- Immunities
    642,    -- Divine Shield
    186265, -- Aspect of the Turtle
    45438,  -- Ice Block
    47585,  -- Dispersion
    1022,   -- Blessing of Protection
    204018, -- Blessing of Spellwarding
    216113, -- Way of the Crane
    31224,  -- Cloak of Shadows
    212182, -- Smoke Bomb
    212183, -- Smoke Bomb
    8178,   -- Grounding Totem Effect
    199448, -- Blessing of Sacrifice

    -- Interrupts
    1766,   -- Kick (Rogue)
    2139,   -- Counterspell (Mage)
    6552,   -- Pummel (Warrior)
    19647,  -- Spell Lock (Warlock)
    47528,  -- Mind Freeze (Death Knight)
    57994,  -- Wind Shear (Shaman)
    91802,  -- Shambling Rush (Death Knight)
    96231,  -- Rebuke (Paladin)
    106839, -- Skull Bash (Feral)
    115781, -- Optical Blast (Warlock)
    116705, -- Spear Hand Strike (Monk)
    132409, -- Spell Lock (Warlock)
    147362, -- Countershot (Hunter)
    171138, -- Shadow Lock (Warlock)
    183752, -- Consume Magic (Demon Hunter)
    187707, -- Muzzle (Hunter)
    212619, -- Call Felhunter (Warlock)
    231665, -- Avengers Shield (Paladin)

    -- Anti CCs
    23920,  -- Spell Reflection
    216890, -- Spell Reflection (Honor Talent)
    213610, -- Holy Ward
    212295, -- Nether Ward
    48707,  -- Anti-Magic Shell
    5384,   -- Feign Death
    213602, -- Greater Fade

    -- Silences
    81261,  -- Solar Beam
    202933, -- Spider Sting
    233022, -- Spider Sting 2
    1330,   -- Garrote
    15487,  -- Silence
    199683, -- Last Word
    47476,  -- Strangulate
    31935,  -- Avenger's Shield
    204490, -- Sigil of Silence
    217824, -- Shield of Virtue
    43523,  -- Unstable Affliction Silence 1
    196364, -- Unstable Affliction Silence 2

    -- Disarms
    236077, -- Disarm
    236236, -- Disarm (Protection)
    209749, -- Faerie Swarm (Disarm)
    233759, -- Grapple Weapon
    207777, -- Dismantle

    -- Roots
    339,    -- Entangling Roots
    170855, -- Entangling Roots (Nature's Grasp)
    201589, -- Entangling Roots (Tree of Life)
    235963, -- Entangling Roots (Feral honor talent)
    122,    -- Frost Nova
    102359, -- Mass Entanglement
    64695,  -- Earthgrab
    200108, -- Ranger's Net
    212638, -- Tracker's Net
    162480, -- Steel Trap
    204085, -- Deathchill
    233395, -- Frozen Center
    233582, -- Entrenched in Flame
    201158, -- Super Sticky Tar
    33395,  -- Freeze
    228600, -- Glacial Spike
    116706, -- Disable
    45334,  -- Immobilized
    53148,  -- Charge (Hunter Pet)
    190927, -- Harpoon
    136634, -- Narrow Escape (unused?)
    198121, -- Frostbite
    117526, -- Binding Shot
    207171, -- Winter is Coming

    -- Offensive Buffs
    266779, -- Coordinated Assault
    193526, -- Trueshot
    19574,  -- Bestial Wrath
    121471, -- Shadow Blades
    102560, -- Incarnation: Chosen of Elune
    279648, -- Lively Spirit
    194223, -- Celestial Alignment
    1719,   -- Battle Cry
    162264, -- Metamorphosis
    211048, -- Chaos Blades
    190319, -- Combustion
    194249, -- Voidform
    51271,  -- Pillar of Frost
    114051, -- Ascendance (Enhancement)
    114050, -- Ascendance (Elemental)
    107574, -- Avatar
    12292,  -- Bloodbath
    204945, -- Doom Winds
    2825,   -- Bloodlust
    32182,  -- Heroism
    204361, -- Bloodlust (Honor Talent)
    204362, -- Heroism (Honor Talent)
    13750,  -- Adrenaline Rush
    102543, -- Incarnation: King of the Jungle
    137639, -- Storm, Earth, and Fire
    152173, -- Serenity
    12042,  -- Arcane Power
    12472,  -- Icy Veins
    198144, -- Ice Form
    31884,  -- Avenging Wrath (Retribution)
    196098, -- Soul Harvest
    16166,  -- Elemental Mastery
    10060,  -- Power Infusion

    -- Defensive Buffs
    210256, -- Blessing of Sanctuary
    6940,   -- Blessing of Sacrifice
    125174, -- Touch of Karma
    236696, -- Thorns
    47788,  -- Guardian Spirit
    197268, -- Ray of Hope
    5277,   -- Evasion
    199754, -- Riposte
    212800, -- Blur
    102342, -- Ironbark
    22812,  -- Barkskin
    117679, -- Incarnation: Tree of Life
    198065, -- Prismatic Cloak
    198111, -- Temporal Shield
    108271, -- Astral Shift
    114052, -- Ascendance (Restoration)
    207319, -- Corpse Shield
    104773, -- Unending Resolve
    48792,  -- Icebound Fortitude
    55233,  -- Vampiric Blood
    61336,  -- Survival Instincts
    116849, -- Life Cocoon
    33206,  -- Pain Suppression
    197862, -- Archangel
    31850,  -- Ardent Defender
    120954, -- Fortifying Brew
    108416, -- Dark Pact
    216331, -- Avenging Crusader
    31842,  -- Avenging Wrath (Holy)
    118038, -- Die by the Sword
    12975,  -- Last Stand
    205191, -- Eye for an Eye
    498,    -- Divine Protection
    871,    -- Shield Wall
    53480,  -- Roar of Sacrifice
    197690, -- Defensive Stance

    -- Miscellaneous
    199450, -- Ultimate Sacrifice
    188501, -- Spectral Sight
    1044,   -- Blessing of Freedom
    41425,  -- Hypothermia
    66,     -- Invisibility fade effect
    96243,  -- Invisibility invis effect?
    110960, -- Greater Invisibility
    198158, -- Mass Invisibility
});
