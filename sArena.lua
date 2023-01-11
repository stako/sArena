sArenaMixin = {}
sArenaFrameMixin = {}
sArenaCastingBarExtensionMixin = {}
sArenaMixin.layouts = {}

sArenaMixin.defaultSettings = {
    profile = {
        currentLayout = "BlizzArena",
        classColors = true,
        showNames = true,
        statusText = {
            usePercentage = false,
            alwaysShow = true,
        },
        layoutSettings = {},
    },
}

local db
local auraList
local interruptList
local classIcons = {
    ["DRUID"] = 625999,
    ["HUNTER"] = 135495, -- 626000
    ["MAGE"] = 135150, -- 626001
    ["MONK"] = 626002,
    ["PALADIN"] = 626003,
    ["PRIEST"] = 626004,
    ["ROGUE"] = 626005,
    ["SHAMAN"] = 626006,
    ["WARLOCK"] = 626007,
    ["WARRIOR"] = 135328, -- 626008
    ["DEATHKNIGHT"] = 135771,
    ["DEMONHUNTER"] = 1260827,
	["EVOKER"] = 4574311,
}
local emptyLayoutOptionsTable = {
    notice = {
        name = "The selected layout doesn't appear to have any settings.",
        type = "description",
    },
}
local blizzFrame
local FEIGN_DEATH = GetSpellInfo(5384) -- Localized name for Feign Death

-- make local vars of globals that are used with high frequency
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitGUID = UnitGUID
local UnitChannelInfo = UnitChannelInfo
local GetTime = GetTime
local After = C_Timer.After
local UnitAura = UnitAura
local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local UnitPowerType = UnitPowerType
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local FindAuraByName = AuraUtil.FindAuraByName
local ceil = ceil
local AbbreviateLargeNumbers = AbbreviateLargeNumbers
local UnitFrameHealPredictionBars_Update = UnitFrameHealPredictionBars_Update

local function UpdateBlizzVisibility(instanceType)
    -- hide blizz arena frames while in arena
    if (InCombatLockdown()) then return end
    if (IsAddOnLoaded("ElvUI")) then return end

    if (not blizzFrame) then
        blizzFrame = CreateFrame("Frame", nil, UIParent)
        blizzFrame:SetSize(1, 1)
        blizzFrame:SetPoint("RIGHT", UIParent, "RIGHT", 500, 0)
        blizzFrame:Hide()
    end

    for i = 1, 5 do
        local arenaFrame = _G["ArenaEnemyMatchFrame" .. i]
        local prepFrame = _G["ArenaEnemyPrepFrame" .. i]

        arenaFrame:ClearAllPoints()
        prepFrame:ClearAllPoints()

        if (instanceType == "arena") then
            arenaFrame:SetParent(blizzFrame)
            arenaFrame:SetPoint("CENTER", blizzFrame, "CENTER")
            prepFrame:SetParent(blizzFrame)
            prepFrame:SetPoint("CENTER", blizzFrame, "CENTER")
        else
            arenaFrame:SetParent(ArenaEnemyFramesContainer)
            prepFrame:SetParent(ArenaEnemyPrepFramesContainer)

            if (i == 1) then
                arenaFrame:SetPoint("TOP", arenaFrame:GetParent(), "TOP")
                prepFrame:SetPoint("TOP", prepFrame:GetParent(), "TOP")
            else
                arenaFrame:SetPoint("TOP", "ArenaEnemyMatchFrame" .. i - 1, "BOTTOM", 0, -20)
                prepFrame:SetPoint("TOP", "ArenaEnemyPrepFrame" .. i - 1, "BOTTOM", 0, -20)
            end
        end
    end
end

-- Parent Frame

function sArenaMixin:OnLoad()
    auraList = self.auraList
    interruptList = self.interruptList

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function sArenaMixin:OnEvent(event)
    if (event == "PLAYER_LOGIN") then
        self:Initialize()
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif (event == "PLAYER_ENTERING_WORLD") then
        local _, instanceType = IsInInstance()
        UpdateBlizzVisibility(instanceType)
        self:SetMouseState(true)

        if (instanceType == "arena") then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        else
            self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local _, combatEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, auraType = CombatLogGetCurrentEventInfo()

        for i = 1, 3 do
            local ArenaFrame = self["arena" .. i]

            if (sourceGUID == UnitGUID("arena" .. i)) then
                ArenaFrame:FindRacial(combatEvent, spellID)
            end

            if (destGUID == UnitGUID("arena" .. i)) then
                ArenaFrame:FindInterrupt(combatEvent, spellID)

                if (auraType == "DEBUFF") then
                    ArenaFrame:FindDR(combatEvent, spellID)
                end

                return
            end
        end
    end
end

local function ChatCommand(input)
    if not input or input:trim() == "" then
        LibStub("AceConfigDialog-3.0"):Open("sArena")
    else
        LibStub("AceConfigCmd-3.0").HandleCommand("sArena", "sarena", "sArena", input)
    end
end

function sArenaMixin:Initialize()
    if (db) then return end

    self.db = LibStub("AceDB-3.0"):New("sArena3DB", self.defaultSettings, true)
    db = self.db

    db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    self.optionsTable.handler = self
    self.optionsTable.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("sArena", self.optionsTable)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("sArena")
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("sArena", 700, 620)
    LibStub("AceConsole-3.0"):RegisterChatCommand("sarena", ChatCommand)

    self:SetLayout(nil, db.profile.currentLayout)
end

function sArenaMixin:RefreshConfig()
    self:SetLayout(nil, db.profile.currentLayout)
end

function sArenaMixin:SetLayout(_, layout)
    if (InCombatLockdown()) then return end

    layout = sArenaMixin.layouts[layout] and layout or "BlizzArena"

    db.profile.currentLayout = layout
    self.layoutdb = self.db.profile.layoutSettings[layout]

    for i = 1, 3 do
        local frame = self["arena" .. i]
        frame:ResetLayout()
        self.layouts[layout]:Initialize(frame)
        frame:UpdatePlayer()
    end

    self.optionsTable.args.layoutSettingsGroup.args = self.layouts[layout].optionsTable and
        self.layouts[layout].optionsTable or emptyLayoutOptionsTable
    LibStub("AceConfigRegistry-3.0"):NotifyChange("sArena")

    local _, instanceType = IsInInstance()
    if (instanceType ~= "arena" and self.arena1:IsShown()) then
        self:Test()
    end
end

function sArenaMixin:SetupDrag(frameToClick, frameToMove, settingsTable, updateMethod)
    frameToClick:HookScript("OnMouseDown", function()
        if (InCombatLockdown()) then return end

        if (IsShiftKeyDown() and IsControlKeyDown() and not frameToMove.isMoving) then
            frameToMove:StartMoving()
            frameToMove.isMoving = true
        end
    end)

    frameToClick:HookScript("OnMouseUp", function()
        if (InCombatLockdown()) then return end

        if (frameToMove.isMoving) then
            frameToMove:StopMovingOrSizing()
            frameToMove.isMoving = false

            local settings = db.profile.layoutSettings[db.profile.currentLayout]

            if (settingsTable) then
                settings = settings[settingsTable]
            end

            local parentX, parentY = frameToMove:GetParent():GetCenter()
            local frameX, frameY = frameToMove:GetCenter()
            local scale = frameToMove:GetScale()

            frameX = ((frameX * scale) - parentX) / scale
            frameY = ((frameY * scale) - parentY) / scale

            -- round to 1 decimal place
            frameX = floor(frameX * 10 + 0.5) / 10
            frameY = floor(frameY * 10 + 0.5) / 10

            settings.posX, settings.posY = frameX, frameY
            self[updateMethod](self, settings)
            LibStub("AceConfigRegistry-3.0"):NotifyChange("sArena")
        end
    end)
end

function sArenaMixin:SetMouseState(state)
    for i = 1, 3 do
        local frame = self["arena" .. i]
        frame.CastBar:EnableMouse(state)
        frame.Stun:EnableMouse(state)
        frame.SpecIcon:EnableMouse(state)
        frame.Trinket:EnableMouse(state)
        frame.Racial:EnableMouse(state)
    end
end

-- Arena Frames

local function ResetTexture(texturePool, t)
    if (texturePool) then
        t:SetParent(texturePool.parent)
    end

    t:SetTexture(nil)
    t:SetColorTexture(0, 0, 0, 0)
    t:SetVertexColor(1, 1, 1, 1)
    t:SetDesaturated()
    t:SetTexCoord(0, 1, 0, 1)
    t:ClearAllPoints()
    t:SetSize(0, 0)
    t:Hide()
end

function sArenaFrameMixin:OnLoad()
    local unit = "arena" .. self:GetID()
    self.parent = self:GetParent()

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_NAME_UPDATE")
    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    self:RegisterEvent("ARENA_OPPONENT_UPDATE")
    self:RegisterEvent("ARENA_COOLDOWNS_UPDATE")
    self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE")
    self:RegisterUnitEvent("UNIT_HEALTH", unit)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    self:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    self:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    self:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
    self:RegisterUnitEvent("UNIT_AURA", unit)
    self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
    self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)

    self:RegisterForClicks("AnyDown", "AnyUp") -- this is for WOW10, if sArena to support previous versions there would need to be a check to still catch only AnyUp
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "focus")
    self:SetAttribute("*typerelease1", "target") -- I do not know why this is treated as a typerelease, don't know how to remove it.
    self:SetAttribute("*typerelease2", "focus")
    self:SetAttribute("unit", unit)
    self.unit = unit

    self.CastBar:SetUnit(unit, false, true)

    self.healthbar = self.HealthBar

    self.myHealPredictionBar:ClearAllPoints()
    self.otherHealPredictionBar:ClearAllPoints()
    self.totalAbsorbBar:ClearAllPoints()
    self.overAbsorbGlow:ClearAllPoints()
    self.healAbsorbBar:ClearAllPoints()
    self.overHealAbsorbGlow:ClearAllPoints()
    self.healAbsorbBarLeftShadow:ClearAllPoints()
    self.healAbsorbBarRightShadow:ClearAllPoints()

    self.totalAbsorbBar.overlay = self.totalAbsorbBarOverlay
    self.totalAbsorbBarOverlay:SetAllPoints(self.totalAbsorbBar)
    self.totalAbsorbBarOverlay.tileSize = 32

    self.overAbsorbGlow:SetPoint("TOPLEFT", self.healthbar, "TOPRIGHT", -7, 0)
    self.overAbsorbGlow:SetPoint("BOTTOMLEFT", self.healthbar, "BOTTOMRIGHT", -7, 0)

    self.healAbsorbBar:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true)

    self.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", self.healthbar, "BOTTOMLEFT", 7, 0)
    self.overHealAbsorbGlow:SetPoint("TOPRIGHT", self.healthbar, "TOPLEFT", 7, 0)

    self.TexturePool = CreateTexturePool(self, "ARTWORK", nil, nil, ResetTexture)
end

function sArenaFrameMixin:OnEvent(event, eventUnit, arg1)
    local unit = self.unit

    if (eventUnit and eventUnit == unit) then
        if (event == "UNIT_NAME_UPDATE") then
            self.Name:SetText(GetUnitName(unit))
        elseif (event == "ARENA_OPPONENT_UPDATE") then
            -- arg1 == unitEvent ("seen", "unseen", etc)
            self:UpdateVisible()
            self:UpdatePlayer(arg1)
        elseif (event == "ARENA_COOLDOWNS_UPDATE") then
            self:UpdateTrinket()
        elseif (event == "ARENA_CROWD_CONTROL_SPELL_UPDATE") then
            -- arg1 == spellID
            if (arg1 ~= self.Trinket.spellID) then
                local _, spellTextureNoOverride = GetSpellTexture(arg1)
                self.Trinket.spellID = arg1
                self.Trinket.Texture:SetTexture(spellTextureNoOverride)
            end
        elseif (event == "UNIT_AURA") then
            self:FindAura()
        elseif (event == "UNIT_HEALTH") then
            self:SetLifeState()
            self:SetStatusText()
            local currHp = UnitHealth(unit)
            if (currHp ~= self.currHp) then
                self.HealthBar:SetValue(currHp)
                UnitFrameHealPredictionBars_Update(self)
                self.currHp = currHp
            end
        elseif (event == "UNIT_MAXHEALTH") then
            self.HealthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            self.HealthBar:SetValue(UnitHealth(unit))
            UnitFrameHealPredictionBars_Update(self)
        elseif (event == "UNIT_POWER_UPDATE") then
            self:SetStatusText()
            self.PowerBar:SetValue(UnitPower(unit))
        elseif (event == "UNIT_MAXPOWER") then
            self.PowerBar:SetMinMaxValues(0, UnitPowerMax(unit))
            self.PowerBar:SetValue(UnitPower(unit))
        elseif (event == "UNIT_DISPLAYPOWER") then
            local _, powerType = UnitPowerType(unit)
            self:SetPowerType(powerType)
            self.PowerBar:SetMinMaxValues(0, UnitPowerMax(unit))
            self.PowerBar:SetValue(UnitPower(unit))
        elseif (event == "UNIT_ABSORB_AMOUNT_CHANGED") then
            UnitFrameHealPredictionBars_Update(self)
        elseif (event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED") then
            UnitFrameHealPredictionBars_Update(self)
        end
    elseif (event == "PLAYER_LOGIN") then
        self:UnregisterEvent("PLAYER_LOGIN")

        if (not db) then
            self.parent:Initialize()
        end

        self:Initialize()
    elseif (event == "PLAYER_ENTERING_WORLD") or (event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS") then
        self.Name:SetText("")
        self.CastBar:Hide()
        self.specTexture = nil
        self.class = nil
        self.currentClassIconTexture = nil
        self.currentClassIconStartTime = 0
        self:UpdateVisible()
        self:UpdatePlayer()
        self:ResetTrinket()
        self:ResetRacial()
        self:ResetDR()
        UnitFrameHealPredictionBars_Update(self)
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")

        self:UpdateVisible()
    end
end

function sArenaFrameMixin:Initialize()
    self:SetMysteryPlayer()
    self.parent:SetupDrag(self, self.parent, nil, "UpdateFrameSettings")
    self.parent:SetupDrag(self.CastBar, self.CastBar, "castBar", "UpdateCastBarSettings")
    self.parent:SetupDrag(self.Stun, self.Stun, "dr", "UpdateDRSettings")
    self.parent:SetupDrag(self.SpecIcon, self.SpecIcon, "specIcon", "UpdateSpecIconSettings")
    self.parent:SetupDrag(self.Trinket, self.Trinket, "trinket", "UpdateTrinketSettings")
    self.parent:SetupDrag(self.Racial, self.Racial, "racial", "UpdateRacialSettings")
end

function sArenaFrameMixin:OnEnter()
    UnitFrame_OnEnter(self)

    self.HealthText:Show()
    self.PowerText:Show()
end

function sArenaFrameMixin:OnLeave()
    UnitFrame_OnLeave(self)

    self:UpdateStatusTextVisible()
end

function sArenaFrameMixin:UpdateVisible()
    if (InCombatLockdown()) then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local _, instanceType = IsInInstance()
    local id = self:GetID()
    if (instanceType == "arena" and (GetNumArenaOpponentSpecs() >= id or GetNumArenaOpponents() >= id)) then
        self:Show()
    else
        self:Hide()
    end
end

function sArenaFrameMixin:UpdatePlayer(unitEvent)
    local unit = self.unit

    self:GetClassAndSpec()
    self:FindAura()

    if ((unitEvent and unitEvent ~= "seen") or not UnitExists(unit)) then
        self:SetMysteryPlayer()
        return
    end

    C_PvP.RequestCrowdControlSpell(unit)

    self:UpdateRacial()

    -- prevent castbar and other frames from intercepting mouse clicks during a match
    if (unitEvent == "seen") then
        self.parent:SetMouseState(false)
    end

    self.hideStatusText = false

    self.Name:SetText(GetUnitName(unit))
    self.Name:SetShown(db.profile.showNames)

    self:UpdateStatusTextVisible()
    self:SetStatusText()

    self:OnEvent("UNIT_MAXHEALTH", unit)
    self:OnEvent("UNIT_HEALTH", unit)
    self:OnEvent("UNIT_MAXPOWER", unit)
    self:OnEvent("UNIT_POWER_UPDATE", unit)
    self:OnEvent("UNIT_DISPLAYPOWER", unit)

    local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]

    if (color and db.profile.classColors) then
        self.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1.0)
    else
        self.HealthBar:SetStatusBarColor(0, 1.0, 0, 1.0)
    end
end

function sArenaFrameMixin:SetMysteryPlayer()
    local f = self.HealthBar
    f:SetMinMaxValues(0, 100)
    f:SetValue(100)
    f:SetStatusBarColor(0.5, 0.5, 0.5)

    f = self.PowerBar
    f:SetMinMaxValues(0, 100)
    f:SetValue(100)
    f:SetStatusBarColor(0.5, 0.5, 0.5)

    self.hideStatusText = true
    self:SetStatusText()

    self.DeathIcon:Hide()
end

function sArenaFrameMixin:GetClassAndSpec()
    local _, instanceType = IsInInstance()

    if (instanceType ~= "arena") then
        self.specTexture = nil
        self.class = nil
        self.SpecIcon:Hide()
    elseif (not self.specTexture or not self.class) then
        local id = self:GetID()
        if (GetNumArenaOpponentSpecs() >= id) then
            local specID = GetArenaOpponentSpec(id)
            if (specID > 0) then
                self.SpecIcon:Show()
                self.specTexture = select(4, GetSpecializationInfoByID(specID))
                self.SpecIcon.Texture:SetTexture(self.specTexture)

                self.class = select(6, GetSpecializationInfoByID(specID))
            end
        end

        if (not self.class and UnitExists(self.unit)) then
            _, self.class = UnitClass(self.unit)
        end
    end

    if (not self.specTexture) then
        self.SpecIcon:Hide()
    end
end

function sArenaFrameMixin:UpdateClassIcon()
    if (
        self.currentAuraSpellID and self.currentAuraDuration > 0 and
            self.currentClassIconStartTime ~= self.currentAuraStartTime) then
        self.ClassIconCooldown:SetCooldown(self.currentAuraStartTime, self.currentAuraDuration)
        self.currentClassIconStartTime = self.currentAuraStartTime
    elseif (self.currentAuraDuration == 0) then
        self.ClassIconCooldown:Clear()
        self.currentClassIconStartTime = 0
    end

    local texture = self.currentAuraSpellID and self.currentAuraTexture or self.class and "class" or 134400

    if (self.currentClassIconTexture == texture) then return end

    self.currentClassIconTexture = texture
    if (texture == "class") then
        texture = classIcons[self.class]
    end
    self.ClassIcon:SetTexture(texture)
end

function sArenaFrameMixin:UpdateTrinket()
    local spellID, startTime, duration = C_PvP.GetArenaCrowdControlInfo(self.unit)
    local trinket = self.Trinket

    if (spellID) then
        if (spellID ~= trinket.spellID) then
            local _, spellTextureNoOverride = GetSpellTexture(spellID)
            trinket.spellID = spellID
            trinket.Texture:SetTexture(spellTextureNoOverride)
        end
        if (startTime ~= 0 and duration ~= 0 and trinket.Texture:GetTexture()) then
            trinket.Cooldown:SetCooldown(startTime / 1000.0, duration / 1000.0)
        else
            trinket.Cooldown:Clear()
        end
    end
end

function sArenaFrameMixin:ResetTrinket()
    self.Trinket.spellID = nil
    self.Trinket.Texture:SetTexture(nil)
    self.Trinket.Cooldown:Clear()
    self:UpdateTrinket()
end

local function ResetStatusBar(f)
    f:ClearAllPoints()
    f:SetSize(0, 0)
    f:SetScale(1)
end

local function ResetFontString(f)
    f:SetDrawLayer("OVERLAY", 1)
    f:SetJustifyH("CENTER")
    f:SetJustifyV("MIDDLE")
    f:SetTextColor(1, 0.82, 0, 1)
    f:SetShadowColor(0, 0, 0, 1)
    f:SetShadowOffset(1, -1)
    f:ClearAllPoints()
    f:Hide()
end

function sArenaFrameMixin:ResetLayout()
    self.currentClassIconTexture = nil
    self.currentClassIconStartTime = 0

    ResetTexture(nil, self.ClassIcon)
    ResetStatusBar(self.HealthBar)
    ResetStatusBar(self.PowerBar)
    ResetStatusBar(self.CastBar)
    self.CastBar:SetHeight(16)
    self.ClassIcon:RemoveMaskTexture(self.ClassIconMask)

    self.ClassIconCooldown:SetSwipeTexture(1)
    self.ClassIconCooldown:SetUseCircularEdge(false)

    local f = self.Trinket
    f:ClearAllPoints()
    f:SetSize(0, 0)
    f.Texture:SetTexCoord(0, 1, 0, 1)

    f = self.Racial
    f:ClearAllPoints()
    f:SetSize(0, 0)
    f.Texture:SetTexCoord(0, 1, 0, 1)

    f = self.SpecIcon
    f:ClearAllPoints()
    f:SetSize(0, 0)
    f:SetScale(1)
    f.Texture:RemoveMaskTexture(f.Mask)
    f.Texture:SetTexCoord(0, 1, 0, 1)

    f = self.Name
    ResetFontString(f)
    f:SetDrawLayer("ARTWORK", 2)
    f:SetFontObject("SystemFont_Shadow_Small2")

    f = self.HealthText
    ResetFontString(f)
    f:SetDrawLayer("ARTWORK", 2)
    f:SetFontObject("Game10Font_o1")
    f:SetTextColor(1, 1, 1, 1)

    f = self.PowerText
    ResetFontString(f)
    f:SetDrawLayer("ARTWORK", 2)
    f:SetFontObject("Game10Font_o1")
    f:SetTextColor(1, 1, 1, 1)

    f = self.CastBar
    f.Icon:SetTexCoord(0, 1, 0, 1)

    self.TexturePool:ReleaseAll()
end

function sArenaFrameMixin:SetPowerType(powerType)
    local color = PowerBarColor[powerType]
    if color then
        self.PowerBar:SetStatusBarColor(color.r, color.g, color.b)
    end
end

function sArenaFrameMixin:FindAura()
    local unit = self.unit
    local currentSpellID, currentDuration, currentExpirationTime, currentTexture = nil, 0, 0, nil

    if (self.currentInterruptSpellID) then
        currentSpellID = self.currentInterruptSpellID
        currentDuration = self.currentInterruptDuration
        currentExpirationTime = self.currentInterruptExpirationTime
        currentTexture = self.currentInterruptTexture
    end

    for i = 1, 2 do
        local filter = (i == 1 and "HELPFUL" or "HARMFUL")

        for n = 1, 30 do
            local _, texture, _, _, duration, expirationTime, _, _, _, spellID = UnitAura(unit, n, filter)

            if (not spellID) then break end

            if (auraList[spellID]) then
                if (not currentSpellID or auraList[spellID] < auraList[currentSpellID]) then
                    currentSpellID = spellID
                    currentDuration = duration
                    currentExpirationTime = expirationTime
                    currentTexture = texture
                end
            end
        end
    end

    if (currentSpellID) then
        self.currentAuraSpellID = currentSpellID
        self.currentAuraStartTime = currentExpirationTime - currentDuration
        self.currentAuraDuration = currentDuration
        self.currentAuraTexture = currentTexture
    else
        self.currentAuraSpellID = nil
        self.currentAuraStartTime = 0
        self.currentAuraDuration = 0
        self.currentAuraTexture = nil
    end

    self:UpdateClassIcon()
end

function sArenaFrameMixin:FindInterrupt(event, spellID)
    local interruptDuration = interruptList[spellID]

    if (not interruptDuration) then return end
    if (event ~= "SPELL_INTERRUPT" and event ~= "SPELL_CAST_SUCCESS") then return end

    local unit = self.unit
    local _, _, _, _, _, _, notInterruptable = UnitChannelInfo(unit)

    if (event == "SPELL_INTERRUPT" or notInterruptable == false) then
        self.currentInterruptSpellID = spellID
        self.currentInterruptDuration = interruptDuration
        self.currentInterruptExpirationTime = GetTime() + interruptDuration
        self.currentInterruptTexture = GetSpellTexture(spellID)
        self:FindAura()
        After(interruptDuration, function()
            self.currentInterruptSpellID = nil
            self.currentInterruptDuration = 0
            self.currentInterruptExpirationTime = 0
            self.currentInterruptTexture = nil
            self:FindAura()
        end)
    end
end

function sArenaFrameMixin:SetLifeState()
    local unit = self.unit
    local isDead = UnitIsDeadOrGhost(unit) and not FindAuraByName(FEIGN_DEATH, unit, "HELPFUL")

    self.DeathIcon:SetShown(isDead)
    self.hideStatusText = isDead
    if (isDead) then
        self:ResetDR()
    end
end

function sArenaFrameMixin:SetStatusText(unit)
    if (self.hideStatusText) then
        self.HealthText:SetText("")
        self.PowerText:SetText("")
        return
    end

    if (not unit) then
        unit = self.unit
    end

    local hp = UnitHealth(unit)
    local hpMax = UnitHealthMax(unit)
    local pp = UnitPower(unit)
    local ppMax = UnitPowerMax(unit)

    if (db.profile.statusText.usePercentage) then
        self.HealthText:SetText(ceil((hp / hpMax) * 100) .. "%")
        self.PowerText:SetText(ceil((pp / ppMax) * 100) .. "%")
    else
        self.HealthText:SetText(AbbreviateLargeNumbers(hp))
        self.PowerText:SetText(AbbreviateLargeNumbers(pp))
    end
end

function sArenaFrameMixin:UpdateStatusTextVisible()
    self.HealthText:SetShown(db.profile.statusText.alwaysShow)
    self.PowerText:SetShown(db.profile.statusText.alwaysShow)
end

function sArenaMixin:Test()
    if (InCombatLockdown()) then return end

    local currTime = GetTime()

    for i = 1, 3 do
        local frame = self["arena" .. i]
        frame:Show()

        frame.HealthBar:SetMinMaxValues(0, 100)
        frame.HealthBar:SetValue(100)

        frame.PowerBar:SetMinMaxValues(0, 100)
        frame.PowerBar:SetValue(100)

        frame.ClassIcon:SetTexture(classIcons["MAGE"])

        frame.SpecIcon:Show()

        frame.SpecIcon.Texture:SetTexture(135846)

        frame.ClassIconCooldown:SetCooldown(GetTime(), math.random(20, 60))

        frame.Name:SetText("arena" .. i)
        frame.Name:SetShown(db.profile.showNames)

        frame.Trinket.Texture:SetTexture(1322720)
        frame.Trinket.Cooldown:SetCooldown(currTime, math.random(20, 60))

        frame.Racial.Texture:SetTexture(136129)
        frame.Racial.Cooldown:SetCooldown(currTime, math.random(20, 60))

        local color = RAID_CLASS_COLORS["MAGE"]
        if (db.profile.classColors) then
            frame.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1)
        else
            frame.HealthBar:SetStatusBarColor(0, 1, 0, 1)
        end
        frame.PowerBar:SetStatusBarColor(0, 0, 1, 1)

        for n = 1, #self.drCategories do
            local drFrame = frame[self.drCategories[n]]

            drFrame.Icon:SetTexture(136071)
            drFrame:Show()
            drFrame.Cooldown:SetCooldown(currTime, n == 1 and 60 or math.random(20, 50))

            if (n == 1) then
                drFrame.Border:SetVertexColor(1, 0, 0, 1)
            else
                drFrame.Border:SetVertexColor(0, 1, 0, 1)
            end
        end

        frame.CastBar.fadeOut = nil
        frame.CastBar:Show()
        frame.CastBar:SetAlpha(1)
        frame.CastBar.Icon:SetTexture(136071)
        frame.CastBar.Text:SetText("Polymorph")
        frame.CastBar:SetStatusBarColor(1, 0.7, 0, 1)

        frame.hideStatusText = false
        frame:SetStatusText("player")
        frame:UpdateStatusTextVisible()
    end
end

-- default bars, will get overwritten from layouts
local typeInfoTexture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill";
sArenaCastingBarExtensionMixin.typeInfo = {
    filling = typeInfoTexture,
    full = typeInfoTexture,
    glow = typeInfoTexture
}

local actionColors = {
    applyingcrafting = { 1.0, 0.7, 0.0, 1 },
    applyingtalents = { 1.0, 0.7, 0.0, 1 },
    filling = { 1.0, 0.7, 0.0, 1 },
    full = { 0.0, 1.0, 0.0, 1 },
    standard = { 1.0, 0.7, 0.0, 1 },
    empowered = { 1.0, 0.7, 0.0, 1 },
    channel = { 0.0, 1.0, 0.0, 1 },
    uninterruptable = { 0.7, 0.7, 0.7, 1 },
    interrupted = { 1.0, 0.0, 0.0, 1 }
}



function sArenaCastingBarExtensionMixin:GetTypeInfo(barType)
    barType = barType or "standard";
    self:SetStatusBarColor(unpack(actionColors[barType]));
    return self.typeInfo
end
