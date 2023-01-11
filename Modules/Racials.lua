local GetTime = GetTime

sArenaMixin.defaultSettings.profile.racialCategories = {
    ["Human"] = true,
    ["Scourge"] = true,
    ["Dwarf"] = true,
    ["NightElf"] = true,
    ["Gnome"] = true,
    ["Draenei"] = true,
    ["Worgen"] = true,
    ["Pandaren"] = true,
    ["Orc"] = true,
    ["Tauren"] = true,
    ["Troll"] = true,
    ["BloodElf"] = true,
    ["Goblin"] = true,
    ["LightforgedDraenei"] = true,
    ["HighmountainTauren"] = true,
    ["Nightborne"] = true,
    ["MagharOrc"] = true,
    ["DarkIronDwarf"] = true,
    ["ZandalariTroll"] = true,
    ["VoidElf"] = true,
    ["KulTiran"] = true,
    ["Mechagnome"] = true,
    ["Vulpera"] = true,
	["Dracthyr"] = true
}

local racialSpells = {
    [59752] = 180,  -- Will to Survive
    [7744] = 120,   -- Will of the Forsaken
    [20594] = 120, -- Stoneform
    [58984] = 120,  -- Shadowmeld
    [20589] = 60,   -- Escape Artist
    [59542] = 180,  -- Gift of the Naaru
    [68992] = 120,  -- Darkflight
    [107079] = 120, -- Quaking Palm
    [33697] = 120,  -- Blood Fury
    [20549] = 90,   -- War Stomp
    [26297] = 180,  -- Berserking
    [202719] = 90,  -- Arcane Torrent
    [69070] = 90,   -- Rocket Jump
    [255647] = 150, -- Light's Judgment
    [255654] = 120, -- Bull Rush
    [260364] = 180, -- Arcane Pulse
    [274738] = 120, -- Ancestral Call
    [265221] = 120, -- Fireblood
    [291944] = 160, -- Regeneratin'
    [256948] = 180, -- Spatial Rift
    [287712] = 160, -- Haymaker
    [312924] = 180, -- Hyper Organic Light Originator
    [312411] = 90,  -- Bag of Tricks
	[368970] = 90,  -- Tail Swipe
	[357214] = 90   -- Wing Buffet
}

local racialData = {
    ["Human"] = { texture = GetSpellTexture(59752), sharedCD = 90 },
    ["Scourge"] = { texture = GetSpellTexture(7744), sharedCD = 30 },
    ["Dwarf"] = { texture = GetSpellTexture(20594), sharedCD = 30 },
    ["NightElf"] = { texture = GetSpellTexture(58984), sharedCD = 0 },
    ["Gnome"] = { texture = GetSpellTexture(20589), sharedCD = 0 },
    ["Draenei"] = { texture = GetSpellTexture(59542), sharedCD = 0 },
    ["Worgen"] = { texture = GetSpellTexture(68992), sharedCD = 0 },
    ["Pandaren"] = { texture = GetSpellTexture(107079), sharedCD = 0 },
    ["Orc"] = { texture = GetSpellTexture(33697), sharedCD = 0 },
    ["Tauren"] = { texture = GetSpellTexture(20549), sharedCD = 0 },
    ["Troll"] = { texture = GetSpellTexture(26297), sharedCD = 0 },
    ["BloodElf"] = { texture = GetSpellTexture(202719), sharedCD = 0 },
    ["Goblin"] = { texture = GetSpellTexture(69070), sharedCD = 0 },
    ["LightforgedDraenei"] = { texture = GetSpellTexture(255647), sharedCD = 0 },
    ["HighmountainTauren"] = { texture = GetSpellTexture(255654), sharedCD = 0 },
    ["Nightborne"] = { texture = GetSpellTexture(260364), sharedCD = 0 },
    ["MagharOrc"] = { texture = GetSpellTexture(274738), sharedCD = 0 },
    ["DarkIronDwarf"] = { texture = GetSpellTexture(265221), sharedCD = 30 },
    ["ZandalariTroll"] = { texture = GetSpellTexture(291944), sharedCD = 0 },
    ["VoidElf"] = { texture = GetSpellTexture(256948), sharedCD = 0 },
    ["KulTiran"] = { texture = GetSpellTexture(287712), sharedCD = 0 },
    ["Mechagnome"] = { texture = GetSpellTexture(312924), sharedCD = 0 },
    ["Vulpera"] = { texture = GetSpellTexture(312411), sharedCD = 0 },
	["Dracthyr"] = { texture = GetSpellTexture(368970), sharedCD = 0 }
}

local function GetRemainingCD(frame)
    local startTime, duration = frame:GetCooldownTimes()
    if ( startTime == 0 ) then return 0 end

    local currTime = GetTime()

    return (startTime + duration) / 1000 - currTime
end

function sArenaFrameMixin:FindRacial(event, spellID)
    if ( event ~= "SPELL_CAST_SUCCESS" ) then return end

    local duration = racialSpells[spellID]

    if ( duration ) then
        local currTime = GetTime()

        if ( self.Racial.Texture:GetTexture() ) then
            self.Racial.Cooldown:SetCooldown(currTime, duration)
        end

        if ( self.Trinket.spellID == 336126 or self.Trinket.spellID == 336135 ) then
            local remainingCD = GetRemainingCD(self.Trinket.Cooldown)
            local sharedCD = racialData[self.race].sharedCD

            if ( sharedCD and remainingCD < sharedCD ) then
                self.Trinket.Cooldown:SetCooldown(currTime, sharedCD)
            end
        end
    elseif ( (spellID == 336126 or spellID == 336135) and self.Racial.Texture:GetTexture() ) then
        local remainingCD = GetRemainingCD(self.Racial.Cooldown)
        local sharedCD = racialData[self.race].sharedCD

        if ( sharedCD and remainingCD < sharedCD ) then
            self.Racial.Cooldown:SetCooldown(GetTime(), sharedCD)
        end
    end
end

function sArenaFrameMixin:UpdateRacial()
    if ( not self.race ) then
        self.race = select(2, UnitRace(self.unit))

        if ( self.parent.db.profile.racialCategories[self.race] ) then
            self.Racial.Texture:SetTexture(racialData[self.race].texture)
        end
    end
end

function sArenaFrameMixin:ResetRacial()
    self.race = nil
    self.Racial.Texture:SetTexture(nil)
    self.Racial.Cooldown:Clear()
    self:UpdateRacial()
end
