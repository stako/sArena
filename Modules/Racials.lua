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

function sArenaFrameMixin:FindRacial(event, spellID)
    if ( event ~= "SPELL_CAST_SUCCESS" ) then return end

    local duration = racialSpells[spellID]

    if ( duration and self.Racial.Texture:GetTexture() ) then
        self.Racial.Cooldown:SetCooldown(GetTime(), duration)
    elseif ( (spellID == 336126 or spellID == 336135) and self.Racial.Texture:GetTexture() ) then
        local activeStartTime, activeDuration = self.Racial.Cooldown:GetCooldownTimes()
        local currTime = GetTime()
        local sharedCD = racialData[self.race].sharedCD

        if ( sharedCD and (activeStartTime + activeDuration - currTime) <= racialData[self.race].sharedCD ) then
            self.Racial.Cooldown:SetCooldown(currTime, sharedCD)
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