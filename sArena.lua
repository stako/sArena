sArenaMixin = {};
sArenaFrameMixin = {};

sArenaMixin.layouts = {};
sArenaMixin.portraitSpecIcon = true;

sArenaMixin.defaultSettings = {
    profile = {
        posX = 300,
        posY = 100,
        currentLayout = "BlizzArena",
        scale = 1.0,
        frameSpacing = 20;
        frameGrowthDirection = 1;
        classColors = true,
        showNames = true,
        dr = {
            posX = -74,
            posY = 24,
            size = 22,
            borderSize = 2.5,
            spacing = 6,
            growthDirection = 4;
            categories = {
                Stun = true,
                Incapacitate = true,
                Disorient = true,
                Silence = true,
                Root = true,
            },
        },
        layoutSettings = {},
    },
};

local db;
local auraList;
local interruptList;
local drList;
local drTime = 18.5;
local severityColor = {
    [1] = { 0, 1, 0, 1},
    [2] = { 1, 1, 0, 1},
    [3] = { 1, 0, 0, 1},
};
local drCategories = {
    "Stun",
    "Incapacitate",
    "Disorient",
    "Silence",
    "Root",
};
local emptyLayoutOptionsTable = {
    notice = {
        name = "The selected layout doesn't appear to have any settings.",
        type = "description",
    },
};
local FEIGN_DEATH = GetSpellInfo(5384); -- Localized name for Feign Death

local CombatLogGetCurrentEventInfo, UnitGUID, GetUnitName, GetSpellTexture, UnitHealthMax,
    UnitHealth, UnitPowerMax, UnitPower, UnitPowerType, GetTime, IsInInstance,
    GetNumArenaOpponentSpecs, GetArenaOpponentSpec, GetSpecializationInfoByID, select,
    SetPortraitToTexture, PowerBarColor, UnitAura, pairs, floor, FindAuraByName, AbbreviateLargeNumbers = 
    CombatLogGetCurrentEventInfo, UnitGUID, GetUnitName, GetSpellTexture, UnitHealthMax,
    UnitHealth, UnitPowerMax, UnitPower, UnitPowerType, GetTime, IsInInstance,
    GetNumArenaOpponentSpecs, GetArenaOpponentSpec, GetSpecializationInfoByID, select,
    SetPortraitToTexture, PowerBarColor, UnitAura, pairs, floor, AuraUtil.FindAuraByName, AbbreviateLargeNumbers;

-- Parent Frame

function sArenaMixin:OnLoad()
    auraList = self.auraList;
    interruptList = self.interruptList;
    drList = self.drList;

    self:RegisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function sArenaMixin:OnEvent(event)
    if ( event == "PLAYER_LOGIN" ) then
        self:Initialize();
        self:UnregisterEvent("PLAYER_LOGIN");
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        local _, instanceType = IsInInstance();
        if ( instanceType == "arena" ) then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        else
            self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        end
    elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
        local _, combatEvent, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, auraType = CombatLogGetCurrentEventInfo();

        for i = 1, 3 do
            if destGUID == UnitGUID("arena"..i) then
                self["arena"..i]:FindInterrupt(combatEvent, spellID);
                if ( auraType == "DEBUFF" ) then
                    self["arena"..i]:FindDR(combatEvent, spellID);
                end
                return;
            end
        end
    end
end

local function ChatCommand(input)
    if not input or input:trim() == "" then
        LibStub("AceConfigDialog-3.0"):Open("sArena");
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(sArena, "sarena", "sArena", input);
    end
end

local function HideBlizzFrames()
    -- can't set "showArenaEnemyFrames" cvar to 0, so we'll just anchor everything to a hidden frame
    local frame = CreateFrame("Frame", nil, UIParent);
    frame:Hide();

    for i = 1, 5 do
        local arenaFrame = _G["ArenaEnemyFrame"..i];
        local prepFrame = _G["ArenaPrepFrame"..i];

        arenaFrame:SetParent(frame);
        arenaFrame:ClearAllPoints();
        arenaFrame:SetPoint("CENTER", frame, center);
        prepFrame:SetParent(frame);
        prepFrame:ClearAllPoints();
        prepFrame:SetPoint("CENTER", frame, center);
    end
end

function sArenaMixin:Initialize()
    if ( db ) then return end

    self.db = LibStub("AceDB-3.0"):New("sArena3DB", self.defaultSettings, true)
    db = self.db;

    db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    self.optionsTable.handler = self;
    self.optionsTable.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("sArena", self.optionsTable);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("sArena");
    LibStub("AceConsole-3.0"):RegisterChatCommand("sarena", ChatCommand);

    self:UpdatePositioning();
    self:SetScale(db.profile.scale);

    SetCVar("showArenaEnemyFrames", 1); -- ARENA_CROWD_CONTROL_SPELL_UPDATE won't fire if this is set to 0
    HideBlizzFrames();
end

function sArenaMixin:RefreshConfig()
    self:UpdatePositioning();
    self:SetScale(db.profile.scale);
    self:SetLayout(nil, db.profile.currentLayout);

    for i = 1, 3 do
        local frame = self["arena"..i];
        frame:SetDRSize(db.profile.dr.size);
        frame:SetDRBorderSize(db.profile.dr.borderSize);
        frame:UpdateDRPositions();
    end
end

function sArenaMixin:UpdatePositioning()
    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "CENTER", db.profile.posX, db.profile.posY);
    local growthDirection = db.profile.frameGrowthDirection;
    local spacing = db.profile.frameSpacing;

    for i = 2, 3 do
        local frame = self["arena"..i];
        local prevFrame = self["arena"..i-1];
        frame:ClearAllPoints();
        if ( growthDirection == 1 ) then frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing);
        elseif ( growthDirection == 2 ) then frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, spacing);
        elseif ( growthDirection == 3 ) then frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0);
        elseif ( growthDirection == 4 ) then frame:SetPoint("RIGHT", prevFrame, "LEFT", -spacing, 0);
        end
    end
end

function sArenaMixin:SetLayout(info, layout)
    if ( InCombatLockdown() ) then return end

    layout = sArenaMixin.layouts[layout] and layout or "BlizzArena";

    db.profile.currentLayout = layout;
    self.optionsTable.args.layoutSettingsGroup.args = self.layouts[layout].optionsTable and self.layouts[layout].optionsTable or emptyLayoutOptionsTable;
    LibStub("AceConfigRegistry-3.0"):NotifyChange("sArena");

    for i = 1, 3 do
        local frame = self["arena"..i];
        frame:ResetLayout();
        self.layouts[layout]:Initialize(frame);
        frame:UpdatePlayer();
    end
end

-- Arena Frames

function sArenaFrameMixin:OnLoad()
    local unit = "arena"..self:GetID();
    self.parent = self:GetParent();

    self:RegisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UNIT_NAME_UPDATE");
    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
    self:RegisterEvent("ARENA_OPPONENT_UPDATE");
    self:RegisterEvent("ARENA_COOLDOWNS_UPDATE");
    self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE");
    self:RegisterUnitEvent("UNIT_HEALTH", unit);
    self:RegisterUnitEvent("UNIT_AURA", unit);

    self:RegisterForClicks("AnyUp");
    self:SetAttribute("*type1", "target");
    self:SetAttribute("*type2", "focus");
    self:SetAttribute("unit", unit);
    self.unit = unit;
    self.unitChanging = true;

    CastingBarFrame_SetUnit(self.CastBar, unit, false, true);

    self.TrinketCooldown:SetAllPoints(self.TrinketIcon);
    self.AuraText:SetPoint("CENTER", self.SpecIcon, "CENTER");

    self.TexturePool = CreateTexturePool(self, "ARTWORK");
end

function sArenaFrameMixin:OnEvent(event, eventUnit, arg1)
    local unit = self.unit;

    if ( eventUnit and eventUnit == unit ) then
        if ( event == "UNIT_NAME_UPDATE" ) then
            self.Name:SetText(GetUnitName(unit));
        elseif ( event == "ARENA_OPPONENT_UPDATE" ) then
            -- arg1 == unitEvent ("seen", "unseen", etc)
            self:UpdateVisible();
            self:UpdatePlayer(arg1);
        elseif ( event == "ARENA_COOLDOWNS_UPDATE" ) then
            self:UpdateTrinket();
        elseif ( event == "ARENA_CROWD_CONTROL_SPELL_UPDATE" ) then
            -- arg1 == spellID
            if (arg1 ~= self.TrinketIcon.spellID) then
                local _, spellTextureNoOverride = GetSpellTexture(arg1);
                self.TrinketIcon.spellID = arg1;
                self.TrinketIcon:SetTexture(spellTextureNoOverride);
            end
        elseif ( event == "UNIT_AURA" ) then
            self:FindAura();
        elseif ( event == "UNIT_HEALTH" ) then
            self:SetLifeState();
        end
    elseif ( event == "PLAYER_LOGIN" ) then
        self:UnregisterEvent("PLAYER_LOGIN");

        if ( not db ) then
            self.parent:Initialize();
        end

        self:Initialize();
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self.Name:SetText("");
        self:UpdateVisible();
        self:UpdatePlayer();
        self:ResetTrinket();
        self:ResetDR();
    elseif ( event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" ) then
        self:UpdateVisible();
        self:UpdatePlayer();
    end
end

function sArenaFrameMixin:Initialize()
    self.parent:SetLayout(nil, db.profile.currentLayout);
    self:SetMysteryPlayer();

    self:SetDRSize(db.profile.dr.size);
    self:SetDRBorderSize(db.profile.dr.borderSize);
end

function sArenaFrameMixin:OnEnter()
    UnitFrame_OnEnter(self);

    self.HealthText:Show();
    self.PowerText:Show();
end

function sArenaFrameMixin:OnLeave()
    UnitFrame_OnLeave(self);

    self.HealthText:Hide();
    self.PowerText:Hide();
end

function sArenaFrameMixin:OnUpdate()
    if ( self.hideStatusOnTooltip ) then return end

    local unit = self.unit;

    local hp = UnitHealth(unit);
    local hpMax = UnitHealthMax(unit);
    local pp = UnitPower(unit);
    local ppMax = UnitPowerMax(unit);

    self.HealthText:SetText(AbbreviateLargeNumbers(hp));
    self.PowerText:SetText(AbbreviateLargeNumbers(pp));

    self:SetBarMaxValue(self.HealthBar, hpMax);
    self:SetBarValue(self.HealthBar, hp);
    
    self:SetBarMaxValue(self.PowerBar, ppMax);
    self:SetBarValue(self.PowerBar, pp);

    self:SetPowerType(select(2, UnitPowerType(unit)));

    self.unitChanging = false;

    if ( self.currentAuraSpellID ) then
        local now = GetTime();
        local timeLeft = self.currentAuraExpirationTime - now;

        if ( timeLeft >= 10 ) then
            self.AuraText:SetFormattedText("%i", timeLeft);
        elseif (timeLeft > 0 ) then
            self.AuraText:SetFormattedText("%.1f", timeLeft);
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

    self:FindAura();

    if ( ( unitEvent and unitEvent ~= "seen" ) or not UnitExists(unit) ) then
            self:SetMysteryPlayer();
            return;
    end
    
    self.hideStatusOnTooltip = false;

    self.Name:SetText(GetUnitName(unit));
    self.Name:SetShown(db.profile.showNames);

    local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))];

    if ( color and db.profile.classColors ) then
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

    self.HealthText:SetText("");
    self.PowerText:SetText("");

    self.DeathIcon:Hide();
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

    local texture = self.currentAuraSpellID and GetSpellTexture(self.currentAuraSpellID) or self.specTexture and self.specTexture or 134400;

    if ( self.currentSpecTexture == texture ) then return end

    self.currentSpecTexture = texture;

    if ( self.parent.portraitSpecIcon ) then
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

local function ResetTexture(t)
    t:SetTexture(nil);
    t:SetColorTexture(0, 0, 0, 0);
    t:SetTexCoord(0, 1, 0, 1);
    t:ClearAllPoints();
    t:SetSize(0, 0);
    t:Hide();
end

local function ResetStatusBar(f)
    f:SetStatusBarTexture(nil);
    f:ClearAllPoints();
    f:SetSize(0, 0);
    f:SetScale(1);
end

local function ResetFontString(f)
    f:SetDrawLayer("OVERLAY", 1);
    f:SetJustifyH("CENTER");
    f:SetJustifyV("MIDDLE");
    f:SetTextColor(1, 0.82, 0, 1);
    f:SetShadowColor(0, 0, 0, 1);
    f:SetShadowOffset(1, -1);
    f:ClearAllPoints();
    f:Hide();
end

function sArenaFrameMixin:ResetLayout()
    self.currentSpecTexture = nil;

    ResetTexture(self.SpecIcon);
    ResetStatusBar(self.HealthBar);
    ResetStatusBar(self.PowerBar);
    ResetStatusBar(self.CastBar);
    self.CastBar:SetHeight(16);

    local f = self.TrinketIcon;
    f:ClearAllPoints();
    f:SetSize(0, 0);
    f:SetTexCoord(0, 1, 0, 1);

    f = self.Name;
    ResetFontString(f);
    f:SetDrawLayer("ARTWORK", 2);
    f:SetFont("Fonts\\FRIZQT__.TTF", 10, nil);

    f = self.AuraText;
    ResetFontString(f);
    f:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE");
    f:SetTextColor(1, 1, 1, 1);

    f = self.HealthText;
    ResetFontString(f);
    f:SetDrawLayer("ARTWORK", 2);
    f:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    f:SetTextColor(1, 1, 1, 1);

    f = self.PowerText;
    ResetFontString(f);
    f:SetDrawLayer("ARTWORK", 2);
    f:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
    f:SetTextColor(1, 1, 1, 1);

    self.TexturePool:ReleaseAll();
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

function sArenaFrameMixin:FindAura()
    local unit = self.unit;
    local currentSpellID, currentExpirationTime = nil, 0;

    if ( self.currentInterruptSpellID ) then
        currentSpellID = self.currentInterruptSpellID;
        currentExpirationTime = self.currentInterruptExpirationTime;
    end

    for i = 1, 2 do
        local filter = (i == 1 and "HELPFUL" or "HARMFUL");

        for i = 1, 30 do
            local _, _, _, _, _, expirationTime, _, _, _, spellID = UnitAura(unit, i, filter);

            if ( not spellID ) then break end

            if ( auraList[spellID] ) then
                if ( not currentSpellID or auraList[spellID] < auraList[currentSpellID] ) then
                    currentSpellID = spellID;
                    currentExpirationTime = expirationTime;
                end
            end
        end
    end

    if ( currentSpellID ) then
        self.currentAuraSpellID = currentSpellID;
        self.currentAuraExpirationTime = currentExpirationTime;
    else
        self.currentAuraSpellID = nil;
        self.currentAuraExpirationTime = 0;
    end

    if ( self.currentAuraExpirationTime == 0 ) then
        self.AuraText:SetText("");
    end

    self:UpdateSpecIcon();
end

function sArenaFrameMixin:FindInterrupt(event, spellID)
    local interruptDuration = interruptList[spellID];

    if ( not interruptDuration ) then return end
    if ( event ~= "SPELL_INTERRUPT" and event ~= "SPELL_CAST_SUCCESS" ) then return end

    local unit = self.unit;
    local _, _, _, _, _, _, notInterruptable = UnitChannelInfo(unit);

    if ( event == "SPELL_INTERRUPT" or notInterruptable == false ) then
        self.currentInterruptSpellID = spellID;
        self.currentInterruptExpirationTime = GetTime() + interruptDuration;
        self:FindAura();
        C_Timer.After(interruptDuration, function() self.currentInterruptSpellID = nil; self.currentInterruptExpirationTime = 0; self:FindAura(); end);
    end
end

function sArenaFrameMixin:SetLifeState()
    local unit = self.unit;
    local isFeigning = FindAuraByName(FEIGN_DEATH, unit, "HELPFUL");

    self.DeathIcon:SetShown(UnitIsDeadOrGhost(unit) and not isFeigning);
end

function sArenaFrameMixin:FindDR(combatEvent, spellID)
    local category = drList[spellID];
    if ( not category ) then return end
    if ( not db.profile.dr.categories[category] ) then return end

    local frame = self[category];
    local currTime = GetTime();

    if ( combatEvent == "SPELL_AURA_REMOVED" or combatEvent == "SPELL_AURA_BROKEN" ) then
        local startTime, startDuration = frame.Cooldown:GetCooldownTimes();
        startTime, startDuration = startTime/1000, startDuration/1000;

        local newDuration = drTime / (1 - ((currTime - startTime) / startDuration));
        local newStartTime = drTime + currTime - newDuration;

        frame.Cooldown:SetCooldown(newStartTime, newDuration);

        return;
    elseif ( combatEvent == "SPELL_AURA_APPLIED" or combatEvent == "SPELL_AURA_REFRESH" ) then
        local unit = self.unit;

        for i = 1, 30 do
            local _, _, _, _, duration, _, _, _, _, _spellID = UnitAura(unit, i, "HARMFUL");

            if ( not _spellID ) then break end

            if ( duration and spellID == _spellID ) then
                frame.Cooldown:SetCooldown(currTime, duration + drTime);
                break;
            end
        end
    end

    frame.Icon:SetTexture(GetSpellTexture(spellID));
    frame.Border:SetVertexColor(unpack(severityColor[frame.severity]));

    frame.severity = frame.severity + 1;
    if frame.severity > 3 then
        frame.severity = 3;
    end
end

function sArenaFrameMixin:UpdateDRPositions()
    local active = 0;
    local frame, prevFrame;
    local spacing = db.profile.dr.spacing;
    local growthDirection = db.profile.dr.growthDirection;

    for i = 1, #drCategories do
        frame = self[drCategories[i]];

        if ( frame:GetAlpha() == 1 ) then
            frame:ClearAllPoints();
            if ( active == 0 ) then
                frame:SetPoint("CENTER", self, "CENTER", db.profile.dr.posX, db.profile.dr.posY);
            else
                if ( growthDirection == 1 ) then frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing);
                elseif ( growthDirection == 2 ) then frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, spacing);
                elseif ( growthDirection == 3 ) then frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0);
                elseif ( growthDirection == 4 ) then frame:SetPoint("RIGHT", prevFrame, "LEFT", -spacing, 0);
                end
            end
            active = active + 1;
            prevFrame = frame;
        end
    end
end

function sArenaFrameMixin:ResetDR()
    for i = 1, #drCategories do
        self[drCategories[i]].Cooldown:SetCooldown(0, 0);
    end
end

function sArenaFrameMixin:SetDRSize(size)
    db.profile.dr.size = size;

    for i = 1, #drCategories do
        self[drCategories[i]]:SetSize(size, size);
    end
end

function sArenaFrameMixin:SetDRBorderSize(size)
    db.profile.dr.borderSize = size;

    for i = 1, #drCategories do
        local frame = self[drCategories[i]];
        frame.Border:SetPoint("TOPLEFT", frame, "TOPLEFT", -size, size);
        frame.Border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", size, -size);
    end
end

function sArenaMixin:Test()
    if ( InCombatLockdown() ) then return end

    local currTime = GetTime();

    for i = 1,3 do
        local frame = self["arena"..i];
        frame:Show();

        if ( frame.parent.portraitSpecIcon ) then
            SetPortraitToTexture(frame.SpecIcon, 136071);
        else
            frame.SpecIcon:SetTexture(136071);
        end

        frame.AuraText:SetText("5.3");
        frame.Name:SetText("arena"..i);
        frame.Name:SetShown(db.profile.showNames)

        for i = 1, #drCategories do
            local drFrame = frame[drCategories[i]];

            drFrame.Icon:SetTexture(136071);
            drFrame.Cooldown:SetCooldown(currTime, math.random(20, 60));

            if ( i == 1 ) then
                drFrame.Border:SetVertexColor(1, 0, 0, 1);
            else
                drFrame.Border:SetVertexColor(0, 1, 0, 1);
            end
        end

        frame.CastBar.fadeOut = nil;
        frame.CastBar:Show();
        frame.CastBar:SetAlpha(1);
        frame.CastBar.Icon:SetTexture(136071);
        frame.CastBar.Text:SetText("Polymorph");
        frame.CastBar:SetStatusBarColor(1, 0.7, 0, 1);

        frame.HealthText:SetText(AbbreviateLargeNumbers(UnitHealth('player')));
        frame.PowerText:SetText(AbbreviateLargeNumbers(UnitPower('player')));
    end
end
