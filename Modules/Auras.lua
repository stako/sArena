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
    [351338] = 4,   -- Quell (Evoker)
}

sArenaMixin.auraList = tInvert({
    -- Higher up = higher priority

    -- CCs
    5211,   -- Mighty Bash (Stun)
    108194, -- Asphyxiate (Unholy) (Stun)
    221562, -- Asphyxiate (Blood) (Stun)
    377048, -- Absolute Zero (Frost) (Stun)
    91797,  -- Monstrous Blow (Mutated Ghoul) (Stun)
    287254, -- Dead of Winter (Stun)
    210141, -- Zombie Explosion (Stun)
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
    117526, -- Binding Shot (Stun)
	357021, -- Consecutive Concussion (Stun)
    211881, -- Fel Eruption (Stun)
    91800,  -- Gnaw (Stun)
    205630, -- Illidan's Grasp (Stun)
    208618, -- Illidan's Grasp (Stun)
    203123, -- Maim (Stun)
    202244, -- Overrun
    200200, -- Holy Word: Chastise, Censure Talent (Stun)
    22703,  -- Infernal Awakening (Stun)
    132168, -- Shockwave (Stun)
    20549,  -- War Stomp (Stun)
    199085, -- Warpath (Stun)
    305485, -- Lightning Lasso (Stun)
    64044,  -- Psychic Horror (Stun)
    255723, -- Bull Rush (Stun)
    202346, -- Double Barrel (Stun)
    213688, -- Fel Cleave (Stun)
    204399, -- Earthfury (Stun)
    118345, -- Pulverize (Stun)
    171017, -- Meteor Strike (Infernal) (Stun)
    171018, -- Meteor Strike (Abyssal) (Stun)
    46968,  -- Shockwave
    132168, -- Shockwave (Protection)
    287712, -- Haymaker (Stun)
    372245, -- Terror of the Skies (stun)
	389831, -- Snowdrift (Stun)

    33786,  -- Cyclone (Disorient)
    5246,   -- Intimidating Shout (Disorient)
	316593, -- Intimidating Shout (Menace Main Target) (Disorient)
	316595, -- Intimidating Shout (Menace Other Targets) (Disorient)
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
    1513,   -- Scare Beast (Disorient)
    10326,  -- Turn Evil (Disorient)
    6358,   -- Seduction (Disorient)
    261589, -- Seduction 2 (Disorient)
    115268, -- Mesmerize (Shivarra) (Disorient)
    87204,  -- Sin and Punishment (Disorient)
    2637,   -- Hibernate (Disorient)
    226943, -- Mind Bomb (Disorient)
    236748, -- Intimidating Roar (Disorient)
    331866, -- Agent of Chaos (Disorient)
    324263, -- Sulfuric Emission (Disorient)
    360806, -- Sleep Walk (Disorient)

    51514,  -- Hex (Incapacitate)
    211004, -- Hex: Spider (Incapacitate)
    210873, -- Hex: Raptor (Incapacitate)
    211015, -- Hex: Cockroach (Incapacitate)
    211010, -- Hex: Snake (Incapacitate)
    196942, -- Hex: Voodoo Totem (Incapacitate)
    277784, -- Hex: Wicker Mongrel (Incapacitate)
    277778, -- Hex: Zandalari Tendonripper (Incapacitate)
    269352, -- Hex: Skeletal Hatchling (Incapacitate)
    309328, -- Hex: Living Honey (Incapacitate)
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
	391622, -- Polymorph: Duck (Incapacitate)
	383121, -- Mass Polymorph (Incapacitate)
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
    9484,   -- Shackle Undead (Incapacitate)
    710,    -- Banish (Incapacitate)
    6789,   -- Mortal Coil (Incapacitate)

    -- Immunities
    642,    -- Divine Shield
    186265, -- Aspect of the Turtle
    45438,  -- Ice Block
    196555, -- Demon Hunter: Netherwalk
    47585,  -- Priest: Dispersion
    1022,   -- Blessing of Protection
    204018, -- Blessing of Spellwarding
    323524, -- Ultimate Form
    216113, -- Way of the Crane
    31224,  -- Cloak of Shadows
    212182, -- Smoke Bomb
    212183, -- Smoke Bomb
    8178,   -- Grounding Totem Effect
    199448, -- Blessing of Sacrifice
    236321, -- War Banner
    378441, -- Time Stop

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
    351338, -- Quell (Evoker)

    -- Anti CCs
    23920,  -- Spell Reflection
    213610, -- Priest: Holy Ward
    212295, -- Warlock: Nether Ward
    48707,  -- Death Knight: Anti-Magic Shell
    5384,   -- Hunter: Feign Death
    353319, -- Monk: Peaceweaver
    378464, -- Evoker: Nullifying Shroud

    -- Silences
    81261,  -- Solar Beam
    202933, -- Spider Sting
    356727, -- Spider Venom
    1330,   -- Garrote
    15487,  -- Silence
    199683, -- Last Word
    47476,  -- Strangulate
    31935,  -- Avenger's Shield
    204490, -- Sigil of Silence
    217824, -- Shield of Virtue
    43523,  -- Unstable Affliction Silence 1
    196364, -- Unstable Affliction Silence 2
    317589, -- Tormenting Backlash
    375901, -- Mindgames

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
    378760, -- Frostbite
    233395, -- Deathchill (Remorseless Winter)
	204085, -- Deathchill (Chains of Ice)
    241887, -- Landslide

    -- Offensive Buffs
    51271,  -- Death Knight: Pillar of Frost
    -- 47568,  -- Death Knight: Empower Rune Weapon
    207289, -- Death Knight: Unholy Assault
    162264, -- Demon Hunter: Metamorphosis
    194223, -- Druid: Celestial Alignment
	383410, -- Druid: Celestial Alignment (Orbital Strike)
    102560, -- Druid: Incarnation: Chosen of Elune
	390414, -- Druid: Incarnation: Chosen of Elune (Orbital Strike)
    102543, -- Druid: Incarnation: King of the Jungle
    19574,  -- Hunter: Bestial Wrath
    266779, -- Hunter: Coordinated Assault
    288613, -- Hunter: Trueshot
    -- 260402, -- Hunter: Double Tap
    365362, -- Mage: Arcane Surge
    190319, -- Mage: Combustion
    324220, -- Mage: Deathborne
    198144, -- Mage: Ice Form
    -- 12472,  -- Mage: Icy Veins
    80353,  -- Mage: Time Warp
    152173, -- Monk: Serenity
    137639, -- Monk: Storm, Earth, and Fire
    31884,  -- Paladin: Avenging Wrath (Retribution)
    152262, -- Paladin: Seraphim
    231895, -- Paladin: Crusade
    197871, -- Priest: Dark Archangel
    -- 10060,  -- Priest: Power Infusion
    194249, -- Priest: Voidform
    13750,  -- Rogue: Adrenaline Rush
    121471, -- Rogue: Shadow Blades
    114050, -- Shaman: Ascendance (Elemental)
    114051, -- Shaman: Ascendance (Enhancement)
    2825,   -- Shaman: Bloodlust
    204361, -- Shaman: Bloodlust (Honor Talent)
    32182,  -- Shaman: Heroism
    204362, -- Shaman: Heroism (Honor Talent)
    191634, -- Shaman: Stormkeeper
    204366, -- Shaman: Thundercharge
    113858, -- Warlock: Dark Soul: Instability
    113860, -- Warlock: Dark Soul: Misery
    107574, -- Warrior: Avatar
    227847, -- Warrior: Bladestorm (Arms)
    -- 260708, -- Warrior: Sweeping Strikes
    262228, -- Warrior: Deadly Calm
    1719,   -- Warrior: Recklessness
    375087, -- Evoker: Dragonrage
    370553, -- Evoker: Tip the Scales

    -- Defensive Buffs
    48792,  -- Death Knight: Icebound Fortitude
    49039,  -- Death Knight: Lichborne
    145629, -- Death Knight: Anti-Magic Zone
    81256,  -- Death Knight: Dancing Rune Weapon
    55233,  -- Death Knight: Vampiric Blood
    212800, -- Demon Hunter: Blur
    188499, -- Demon Hunter: Blade Dance
    209426, -- Demon Hunter: Darkness
	354610, -- Demon Hunter: Glimpse
    102342, -- Druid: Ironbark
    22812,  -- Druid: Barkskin
    61336,  -- Druid: Survival Instincts
    117679, -- Druid: Incarnation: Tree of Life
    236696, -- Druid: Thorns
    305497, -- Druid: Thorns
    53480,  -- Hunter: Roar of Sacrifice
    198111, -- Mage: Temporal Shield
    342246, -- Mage: Alter Time (Arcane)
    110909, -- Mage: Alter Time (Fire, Frost)
    125174, -- Monk: Touch of Karma
    116849, -- Monk: Life Cocoon
    120954, -- Monk: Fortifying Brew
    122783, -- Monk: Diffuse Magic
    228050, -- Paladin: Guardian of the Forgotten Queen
    86659,  -- Paladin: Guardian of Ancient Kings
    210256, -- Paladin: Blessing of Sanctuary
    6940,   -- Paladin: Blessing of Sacrifice
    184662, -- Paladin: Shield of Vengeance
    31850,  -- Paladin: Ardent Defender
    210294, -- Paladin: Divine Favor
    216331, -- Paladin: Avenging Crusader
    31842,  -- Paladin: Avenging Wrath (Holy)
    205191, -- Paladin: Eye for an Eye
    498,    -- Paladin: Divine Protection
    47788,  -- Priest: Guardian Spirit
    33206,  -- Priest: Pain Suppression
    232707, -- Priest: Ray of Hope
    81782,  -- Priest: Power Word: Barrier
    15286,  -- Priest: Vampiric Embrace
    19236,  -- Priest: Desperate Prayer
    197862, -- Priest: Archangel
    47536,  -- Priest: Rapture
    271466, -- Priest: Luminous Barrier
    207736, -- Rogue: Shadowy Duel
    5277,   -- Rogue: Evasion
    199754, -- Rogue: Riposte
    108271, -- Shaman: Astral Shift
    114052, -- Shaman: Ascendance (Restoration)
    104773, -- Warlock: Unending Resolve
    108416, -- Warlock: Dark Pact
    118038, -- Warrior: Die by the Sword
    12975,  -- Warrior: Last Stand
    871,    -- Warrior: Shield Wall
    213871, -- Warrior: Bodyguard
    345231, -- Trinket: Gladiator's Emblem
    197690, -- Warrior: Defensive Stance
    374348, -- Evoker: Renewing Blaze
    370960, -- Evoker: Emerald Communion
    363916, -- Evoker: Obsidian Scales
    357170, -- Evoker: Time Dilation

    -- Refreshments
    167152, -- Mage Food
    274914, -- Rockskip Mineral Water

    -- Miscellaneous
    199450, -- Ultimate Sacrifice
    320224, -- Podtender
    327140, -- Forgeborne
    188501, -- Spectral Sight
    305395, -- Blessing of Freedom (Unbound Freedom)
    1044,   -- Blessing of Freedom
    41425,  -- Hypothermia
    66,     -- Invisibility fade effect
    96243,  -- Invisibility invis effect?
    110960, -- Greater Invisibility
    198158, -- Mass Invisibility

    322459, -- Thoughtstolen (Shaman)
    322464, -- Thoughtstolen (Mage)
    322442, -- Thoughtstolen (Druid)
    322462, -- Thoughtstolen (Priest - Holy)
    322457, -- Thoughtstolen (Paladin)
    322463, -- Thoughtstolen (Warlock)
    322461, -- Thoughtstolen (Priest - Discipline)
    322458, -- Thoughtstolen (Monk)
	394902, -- Thoughtstolen (Evoker)
    322460, -- Thoughtstolen (Priest - Shadow)

    -- Druid Forms
    768,    -- Cat form
    783,    -- Travel form
    5487,   -- Bear form
})
