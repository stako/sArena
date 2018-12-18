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

sArenaMixin.ccList = tInvert({
    -- Higher up = higher priority

    5211,   -- Mighty Bash (Stun)
    108194, -- Asphyxiate (Stun)
    221562, -- Asphyxiate Blood (Stun)
    199804, -- Between the Eyes (Stun)
    118905, -- Static Charge (Stun)
    1833,   -- Cheap Shot (Stun)
    853,    -- Hammer of Justice (Stun)
    179057, -- Chaos Nova (Stun)
    132169, -- Storm Bolt (Stun)
    408,    -- Kidney Shot (Stun)
    163505, -- Rake (Stun)
    119381, -- Leg Sweep (Stun)
    232055, -- Fists of Fury (Stun)
    89766,  -- Axe Toss (Stun)
    30283,  -- Shadowfury (Stun)
    200166, -- Metamorphosis (Stun)
    24394,  -- Intimidation (Stun)
    211881, -- Fel Eruption (Stun)
    221562, -- Asphyxiate, Blood Spec (Stun)
    91800,  -- Gnaw (Stun)
    91797,  -- Monstrous Blow (Stun)
    205630, -- Illidan's Grasp (Stun)
    208618, -- Illidan's Grasp (Stun)
    203123, -- Maim (Stun)
    200200, -- Holy Word: Chastise, Censure Talent (Stun)
    118345, -- Pulverize (Stun)
    22703,  -- Infernal Awakening (Stun)
    132168, -- Shockwave (Stun)
    46968,  -- Shockwave 2 (Stun)
    20549,  -- War Stomp (Stun)
    199085, -- Warpath (Stun)
    204437, -- Lightning Lasso (Stun)
    210141, -- Zombie Explosion (Stun)
    212332, -- Gnaw (Stun)
    171017, -- Meteor Strike Infernal (Stun)
    171018, -- Meteor Strike Abyssal (Stun)
    64044,  -- Psychic Horror (Stun)
    255723, -- Bull Rush (Stun)
    202244, -- Overrun (Stun)
    202346, -- Double Barrel (Stun)


    33786,  -- Cyclone (Disorient)
    209753, -- Cyclone, Honor Talent (Disorient)
    5246,   -- Intimidating Shout (Disorient)
    238559, -- Bursting Shot (Disorient)
    224729, -- Bursting Shot on NPC's (Disorient)
    8122,   -- Psychic Scream (Disorient)
    2094,   -- Blind (Disorient)
    5484,   -- Howl of Terror (Disorient)
    605,    -- Mind Control (Disorient)
    105421, -- Blinding Light (Disorient)
    207167, -- Blinding Sleet (Disorient)
    31661,  -- Dragon's Breath (Disorient)
    207685, -- Sigil of Misery (Disorient)
    198909, -- Song of Chi-ji (Disorient)
    202274, -- Incendiary Brew (Disorient)
    5782,   -- Fear (Disorient)
    118699, -- Fear (Disorient)
    130616, -- Fear (Disorient)
    115268, -- Mesmerize (Disorient)
    6358,   -- Seduction (Disorient)
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
    212365, -- Freezing Trap 2 (Incapacitate)
    115078, -- Paralysis (Incapacitate)
    213691, -- Scatter Shot (Incapacitate)
    6770,   -- Sap (Incapacitate)
    199743, -- Parley (Incapacitate)
    20066,  -- Repentance (Incapacitate)
    19386,  -- Wyvern Sting (Incapacitate)
    6789,   -- Mortal Coil (Incapacitate)
    200196, -- Holy Word: Chastise (Incapacitate)
    221527, -- Imprison, Detainment Honor Talent (Incapacitate)
    217832, -- Imprison (Incapacitate)
    99,	    -- Incapacitating Roar (Incapacitate)
    82691,  -- Ring of Frost (Incapacitate)
    9484,   -- Shackle Undead (Incapacitate)
    1776,   -- Gouge (Incapacitate)
    710,    -- Banish (Incapacitate)
    107079, -- Quaking Palm (Incapacitate)
    236025, -- Enraged Maim (Incapacitate)
    197214, -- Sundering (Incapacitate)

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
});