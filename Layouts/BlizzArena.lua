local layoutName = "BlizzArena"
local layout = {}
layout.name = "|cff00b4ffBlizz|r Arena"

layout.defaultSettings = {
    posX = 300,
    posY = 100,
    scale = 1.4,
    classIconFontSize = 10,
    spacing = 20,
    growthDirection = 1,
    specIcon = {
        posX = 47,
        posY = -12,
        scale = 1,
    },
    trinket = {
        posX = -66,
        posY = -1,
        scale = 1,
        fontSize = 12,
    },
    racial = {
        posX = -90,
        posY = -1,
        scale = 1,
        fontSize = 12,
    },
    castBar = {
        posX = -148,
        posY = 0,
        scale = 1,
        width = 84,
    },
    dr = {
        posX = -74,
        posY = 24,
        size = 22,
        borderSize = 2.5,
        fontSize = 12,
        spacing = 6,
        growthDirection = 4,
    },

    -- custom layout settings
    mirrored = false,
}

local function getSetting(info)
    return layout.db[info[#info]]
end

local function setSetting(info, val)
    layout.db[info[#info]] = val

    for i = 1, 3 do
        local frame = info.handler["arena" .. i]
        layout:UpdateOrientation(frame)
    end
end

local function setupOptionsTable(self)
    layout.optionsTable = self:GetLayoutOptionsTable(layoutName)

    layout.optionsTable.arenaFrames.args.positioning.args.mirrored = {
        order = 5,
        name = "Mirrored Frames",
        type = "toggle",
        width = "full",
        get = getSetting,
        set = setSetting,
    }
end

function layout:Initialize(frame)
    self.db = frame.parent.db.profile.layoutSettings[layoutName]

    if (not self.optionsTable) then
        setupOptionsTable(frame.parent)
    end

    if (frame:GetID() == 3) then
        frame.parent:UpdateCastBarSettings(self.db.castBar)
        frame.parent:UpdateDRSettings(self.db.dr)
        frame.parent:UpdateFrameSettings(self.db)
        frame.parent:UpdateSpecIconSettings(self.db.specIcon)
        frame.parent:UpdateTrinketSettings(self.db.trinket)
        frame.parent:UpdateRacialSettings(self.db.racial)
    end

    frame.ClassIconCooldown:SetSwipeTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    frame.ClassIconCooldown:SetUseCircularEdge(true)

    frame:SetSize(102, 32)
    frame.SpecIcon:SetSize(14, 14)
    frame.SpecIcon.Texture:AddMaskTexture(frame.SpecIcon.Mask)
    frame.Trinket:SetSize(22, 22)
    frame.Racial:SetSize(22, 22)

    local healthBar = frame.HealthBar
    healthBar:SetSize(69, 7)
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    local powerBar = frame.PowerBar
    powerBar:SetSize(69, 8)
    powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
    powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    local f = frame.ClassIcon
    f:SetSize(24, 24)
    f:Show()
    f:AddMaskTexture(frame.ClassIconMask)
    frame.ClassIconMask:SetAllPoints(f)

    local specBorder = frame.TexturePool:Acquire()
    specBorder:SetParent(frame.SpecIcon)
    specBorder:SetDrawLayer("ARTWORK", 3)
    specBorder:SetTexture("Interface\\CHARACTERFRAME\\TotemBorder")
    specBorder:SetPoint("TOPLEFT", frame.SpecIcon, "TOPLEFT", -5, 5)
    specBorder:SetPoint("BOTTOMRIGHT", frame.SpecIcon, "BOTTOMRIGHT", 5, -5)
    specBorder:Show()

    f = frame.Name
    f:SetJustifyH("LEFT")
    f:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", 2, 2)
    f:SetPoint("BOTTOMRIGHT", healthBar, "TOPRIGHT", -2, 2)
    f:SetHeight(12)

    f = frame.CastBar
    local typeInfoTexture = "Interface\\TargetingFrame\\UI-StatusBar";
    f:SetStatusBarTexture(typeInfoTexture)
    f.typeInfo = {
        filling = typeInfoTexture,
        full = typeInfoTexture,
        glow = typeInfoTexture
    }

    f = frame.DeathIcon
    f:ClearAllPoints()
    f:SetPoint("CENTER", frame.HealthBar, "CENTER")
    f:SetSize(26, 26)

    frame.HealthText:SetPoint("CENTER", frame.HealthBar)
    frame.HealthText:SetShadowOffset(0, 0)

    frame.PowerText:SetPoint("CENTER", frame.PowerBar)
    frame.PowerText:SetShadowOffset(0, 0)

    local underlay = frame.TexturePool:Acquire()
    underlay:SetDrawLayer("BACKGROUND", 1)
    underlay:SetColorTexture(0, 0, 0, 0.5)
    underlay:SetPoint("TOPLEFT", healthBar)
    underlay:SetPoint("BOTTOMRIGHT", powerBar)
    underlay:Show()

    local id = frame:GetID()
    layout["frameTexture" .. id] = frame.TexturePool:Acquire()
    local frameTexture = layout["frameTexture" .. id]
    frameTexture:SetDrawLayer("ARTWORK", 2)
    frameTexture:SetAllPoints(frame)
    frameTexture:SetTexture("Interface\\ArenaEnemyFrame\\UI-ArenaTargetingFrame")
    frameTexture:Show()

    self:UpdateOrientation(frame)
end

function layout:UpdateOrientation(frame)
    local frameTexture = layout["frameTexture" .. frame:GetID()]
    local healthBar = frame.HealthBar
    local classIcon = frame.ClassIcon

    healthBar:ClearAllPoints()
    classIcon:ClearAllPoints()

    if (self.db.mirrored) then
        frameTexture:SetTexCoord(0.796, 0, 0, 0.5)
        healthBar:SetPoint("TOPRIGHT", -3, -9)
        classIcon:SetPoint("TOPLEFT", 4, -4)
    else
        frameTexture:SetTexCoord(0, 0.796, 0, 0.5)
        healthBar:SetPoint("TOPLEFT", 3, -9)
        classIcon:SetPoint("TOPRIGHT", -4, -4)
    end
end

sArenaMixin.layouts[layoutName] = layout
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings
