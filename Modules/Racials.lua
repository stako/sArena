local GetTime = GetTime

sArenaMixin.defaultSettings.profile.racialCategories = {
    ["Human"] = true,
    ["Scourge"] = false,
}

local racialSpells = {
    [59752] = 180,  -- Will to Survive
    [7744] = 120,   -- Will of the Forsaken
}

local racialData = {
    ["Human"] = { texture = GetSpellTexture(59752), sharedCD = 90 },
    ["Scourge"] = { texture = GetSpellTexture(7744), sharedCD = 30 },
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