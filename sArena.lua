sArenaMixin = {};
sArenaFrameMixin = {};

sArenaMixin.layouts = {};
sArenaMixin.portraitSpecIcon = true;

local ccList;

-- Parent Frame

function sArenaMixin:OnLoad()
    ccList = self.ccList;

    self:RegisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    self:RegisterEvent("UNIT_AURA");
end

function sArenaMixin:OnEvent(event, ...)
    if ( event == "PLAYER_LOGIN" ) then
        self:Initialize();
        self:UnregisterEvent("PLAYER_LOGIN");
    elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
        local _, combatEvent, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo();

        for i = 1, 3 do
            if destGUID == UnitGUID("arena"..i) then
                self["arena"..i]:FindInterrupt(combatEvent, spellID);
                return;
            end
        end
    elseif ( event == "UNIT_AURA" ) then
        local unit = ...;

        for i = 1, 3 do
            if ( unit == "arena"..i ) then
                self[unit]:FindCC();
                return;
            end
        end
    end
end

function sArenaMixin:Initialize()
    -- TODO: Setup the Ace DB here
end

function sArenaMixin:SetLayout(layout)
    for i = 1, 3 do
        self["arena"..i]:SetLayout(layout);
    end
end

-- Arena Frames

function sArenaFrameMixin:OnLoad()
    local unit = "arena"..self:GetID();

    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UNIT_NAME_UPDATE");
    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
    self:RegisterEvent("ARENA_OPPONENT_UPDATE");
    self:RegisterEvent("ARENA_COOLDOWNS_UPDATE");
    self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE");

    self:RegisterForClicks("AnyUp");
    self:SetAttribute("*type1", "target");
    self:SetAttribute("*type2", "focus");
    self:SetAttribute("unit", unit);
    self.unit = unit;
    self.unitChanging = true;

    CastingBarFrame_SetUnit(self.CastBar, unit, false, true);

    self.ccSpellID = nil;
    self.ccExpire = 0;
    self.interruptSpellID = nil;
    self.interruptExpire = 0;

    self.TrinketCooldown:SetAllPoints(self.TrinketIcon);

    self:SetLayout();

    self:SetMysteryPlayer();
end

function sArenaFrameMixin:OnEvent(event, ...)
    local eventUnit = ...;
    local unit = self.unit;

    if ( eventUnit and eventUnit == unit ) then
        if ( event == "UNIT_NAME_UPDATE" ) then
            self.Name:SetText(GetUnitName(unit));
        elseif ( event == "ARENA_OPPONENT_UPDATE" ) then
            local _, unitEvent = ...;
            self:UpdateVisible();
            self:UpdatePlayer(unitEvent);
        elseif ( event == "ARENA_COOLDOWNS_UPDATE" ) then
            self:UpdateTrinket();
        elseif ( event == "ARENA_CROWD_CONTROL_SPELL_UPDATE" ) then
            local _, spellID = ...;
            if (spellID ~= self.TrinketIcon.spellID) then
                local _, spellTextureNoOverride = GetSpellTexture(spellID);
                self.TrinketIcon.spellID = spellID;
                self.TrinketIcon:SetTexture(spellTextureNoOverride);
            end
        end
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self.Name:SetText("");
        self:UpdateVisible();
        self:UpdatePlayer();
        self:ResetTrinket();
    elseif ( event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" ) then
        self:UpdateVisible();
        self:UpdatePlayer();
    end
end

function sArenaFrameMixin:OnUpdate()
    if ( self.hideStatusOnTooltip ) then return end

    local unit = self.unit;

    self:SetBarMaxValue(self.HealthBar, UnitHealthMax(unit));
    self:SetBarValue(self.HealthBar, UnitHealth(unit));
    
    self:SetBarMaxValue(self.PowerBar, UnitPowerMax(unit));
    self:SetBarValue(self.PowerBar, UnitPower(unit));

    self:SetPowerType(select(2, UnitPowerType(unit)));

    self.unitChanging = false;

    if ( self.activeCCTexture ) then
        local now = GetTime();
        local timeLeft = self.activeCCExpire - now;

        if ( timeLeft > 0 ) then
            self.CCText:SetFormattedText("%.1f", timeLeft);
        end
    end
end

function sArenaFrameMixin:UpdateVisible()
    if ( InCombatLockdown() ) then return end

    local _, instanceType = IsInInstance();
    local id = self:GetID();
    if ( instanceType == "arena" and ( GetNumArenaOpponentSpecs() >= id or GetNumArenaOpponents() >= id ) ) then
        self:Show();
    else
        self:Hide();
    end
end

function sArenaFrameMixin:UpdatePlayer(unitEvent)
    local unit = self.unit;

    self:UpdateSpecIcon();

    if ( ( unitEvent and unitEvent ~= "seen" ) or not UnitExists(unit) ) then
            self:SetMysteryPlayer();
            return;
    end
    
    self.hideStatusOnTooltip = false;

    self.Name:SetText(GetUnitName(unit));

    local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))];

    if color then
        self.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1.0);
    else
        self.HealthBar:SetStatusBarColor(0, 1.0, 0, 1.0);
    end
end

function sArenaFrameMixin:SetMysteryPlayer()
    self.hideStatusOnTooltip = true;
    self.unitChanging = true;

    local f = self.HealthBar;
    f:SetMinMaxValues(0,100);
    f:ResetSmoothedValue(100);
    f:SetStatusBarColor(0.5, 0.5, 0.5);

    f = self.PowerBar;
    f:SetMinMaxValues(0,100);
    f:ResetSmoothedValue(100);
    f:SetStatusBarColor(0.5, 0.5, 0.5);
end

function sArenaFrameMixin:UpdateSpecIcon()
    local _, instanceType = IsInInstance();
    if ( instanceType ~= "arena" ) then
        self.specTexture = nil;
    elseif ( not self.specTexture ) then
        local id = self:GetID();
        if ( GetNumArenaOpponentSpecs() >= id ) then
            local specID = GetArenaOpponentSpec(id);
            if ( specID > 0 ) then
                self.specTexture = select(4, GetSpecializationInfoByID(specID));
            end
        end
    end

    local texture = self.activeBuffTexture and self.activeBuffTexture or self.specTexture and self.specTexture or 134400;
    if ( sArena.portraitSpecIcon ) then
        if ( texture == 134400 ) then
            texture = "Interface\\CharacterFrame\\TempPortrait";
        end
        SetPortraitToTexture(self.SpecIcon, texture)
    else
        self.SpecIcon:SetTexture(texture);
    end
end

function sArenaFrameMixin:UpdateTrinket()
    local spellID, startTime, duration = C_PvP.GetArenaCrowdControlInfo(self.unit);
    if ( spellID ) then
        if ( spellID ~= self.TrinketIcon.spellID ) then
            local _, spellTextureNoOverride = GetSpellTexture(spellID);
            self.TrinketIcon.spellID = spellID;
            self.TrinketIcon:SetTexture(spellTextureNoOverride);
        end
        if ( startTime ~= 0 and duration ~= 0 ) then
            self.TrinketCooldown:SetCooldown(startTime/1000.0, duration/1000.0);
        else
            self.TrinketCooldown:Clear();
        end
    end
end

function sArenaFrameMixin:ResetTrinket()
    self.TrinketIcon.spellID = nil;
    self.TrinketIcon:SetTexture(134400);
    self.TrinketCooldown:Clear();
    self:UpdateTrinket();
end

function sArenaFrameMixin:SetLayout(layout)
    if ( InCombatLockdown() ) then return end

    if ( #sArenaMixin.layouts == 0 ) then
        return;
    end

    layout = sArenaMixin.layouts[layout] and layout or 1;

    self:ClearLayout();
    sArenaMixin.layouts[layout]:Initialize(self);

    self:UpdatePlayer();
end

local function ClearTexture(t)
    t:SetTexture(nil);
    t:SetColorTexture(0, 0, 0, 0);
    t:SetTexCoord(0, 1, 0, 1);
    t:ClearAllPoints();
    t:SetSize(0, 0);
    t:Hide();
end

local function ClearStatusBar(f)
    f:SetStatusBarTexture(nil);
    f:ClearAllPoints();
    f:SetSize(0, 0);
end

function sArenaFrameMixin:ClearLayout()
    ClearTexture(self.FrameUnderlay);
    ClearTexture(self.FrameTexture);
    ClearTexture(self.SpecIcon);
    ClearTexture(self.CCIcon);

    ClearStatusBar(self.HealthBar);
    ClearStatusBar(self.PowerBar);
    ClearStatusBar(self.CastBar);

    self.TrinketIcon:ClearAllPoints();
    self.TrinketIcon:SetSize(0, 0);
    self.TrinketIcon:SetTexCoord(0, 1, 0, 1);

    self.CCIconGlow:ClearAllPoints();
    self.CCIconGlow:SetSize(0, 0);
    self.CCIconGlow:SetTexCoord(0, 1, 0, 1);

    local n = self.Name;
    n:SetJustifyH("CENTER");
    n:SetJustifyV("MIDDLE");
    n:SetSize(0, 0);
    n:ClearAllPoints();
end

function sArenaFrameMixin:SetBarValue(bar, value)
    if ( self.unitChanging ) then
        bar:ResetSmoothedValue(value);
    else
        bar:SetSmoothedValue(value);
    end
end

function sArenaFrameMixin:SetBarMaxValue(bar, value)
    bar:SetMinMaxSmoothedValue(0, value);
    if ( self.unitChanging ) then
        bar:ResetSmoothedValue();
    end
end

function sArenaFrameMixin:SetPowerType(powerType)
    local color = PowerBarColor[powerType];
    if color then
        self.PowerBar:SetStatusBarColor(color.r, color.g, color.b);
    end
end

do
    local prioritizedCC = {
        spellID,
        texture,
        expire,
    };

    function sArenaFrameMixin:FindCC()
        local unit = self.unit;
        local _, texture, expire, spellID;
        prioritizedCC.spellID, prioritizedCC.texture, prioritizedCC.expire = nil, nil, nil;

        for i = 1, 30 do
            _, texture, _, _, _, expire, _, _, _, spellID = UnitAura(unit, i, "HARMFUL");

            if ( not spellID ) then break end

            if ( ccList[spellID] ) then
                if ( not prioritizedCC.spellID or ccList[spellID] < ccList[prioritizedCC.spellID] ) then
                    prioritizedCC.spellID = spellID;
                    prioritizedCC.texture = texture;
                    prioritizedCC.expire = expire;
                end
            end
        end

        if ( prioritizedCC.spellID ) then
            self.ccSpellID = prioritizedCC.spellID;
            self.ccTexture = prioritizedCC.texture;
            self.ccExpire = prioritizedCC.expire;
        else
            self.ccSpellID = nil
        end

        self:SetCC();
    end
end

function sArenaFrameMixin:FindInterrupt(event, spellID)
    local duration = sArena.interruptList[spellID];

    if ( not duration ) then return end
    if ( event ~= "SPELL_INTERRUPT" and event ~= "SPELL_CAST_SUCCESS" ) then return end

    local unit = self.unit;
    local _, _, _, _, _, _, notInterruptable = UnitChannelInfo(unit);

    if ( event == "SPELL_INTERRUPT" or notInterruptable == false ) then
        local _, _, texture = GetSpellInfo(spellID);
        local start = GetTime();

        self.interruptSpellID = spellID;
        self.interruptTexture = texture;
        self.interruptExpire = start + duration;

        C_Timer.After(duration, function() self:ClearInterrupt() end);

        self:SetCC();
    end
end

function sArenaFrameMixin:ClearInterrupt()
    self.interruptSpellID = nil;
    self:FindCC();
end

function sArenaFrameMixin:SetCC()
    if ( self.ccSpellID ) then
        if ( self.interruptSpellID and ccList[self.interruptSpellID] < ccList[self.ccSpellID] ) then
            self.activeCCTexture = self.interruptTexture;
            self.activeCCExpire = self.interruptExpire;
        else
            self.activeCCTexture = self.ccTexture;
            self.activeCCExpire = self.ccExpire;
        end
    elseif ( self.interruptSpellID ) then
        self.activeCCTexture = self.interruptTexture;
        self.activeCCExpire = self.interruptExpire;
    else
        self:ClearCC();
        return;
    end

    self.CCIcon:SetTexture(self.activeCCTexture);
    self.CCIconGlow:Show();
    self.CCIcon:Show();
end

function sArenaFrameMixin:ClearCC()
    self.CCText:SetText("");
    self.CCIcon:Hide();
    self.CCIconGlow:Hide();
    self.activeCCTexture = nil;
end

function sArenaMixin:Test()
    sArena:SetLayout(3);

    for i = 1, 2 do
        local f = sArena["arena"..i];
        f:Show()

        if i == 1 then f:SetScale(2); end

        f.CCIcon:SetTexture(134400);
        f.CCIcon:Show();
        f.CCIconGlow:Show();
        f.CCText:SetText("8.3");
        f.CCText:Show();
    end
end
