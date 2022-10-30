local layoutName = "BlizzTourney"
local layout = {}
layout.name = "|cff00b4ffBlizz|r Tourney"

layout.defaultSettings = {
    posX = 300,
    posY = 100,
    scale = 1.2,
    classIconFontSize = 12,
    spacing = 20,
    growthDirection = 1,
    specIcon = {
        posX = 26,
        posY = 26,
        scale = 1,
    },
    trinket = {
        posX = 43,
        posY = -17,
        scale = 1,
        fontSize = 12,
    },
    racial = {
        posX = 74,
        posY = -17,
        scale = 1,
        fontSize = 12,
    },
    castBar = {
        posX = -110,
        posY = -14,
        scale = 1,
        width = 90,
    },
    dr = {
        posX = -79,
        posY = 13,
        size = 22,
        borderSize = 2.5,
        fontSize = 12,
        spacing = 6,
        growthDirection = 4,
    },

    -- custom layout settings
    mirrored = true,
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

    frame:SetSize(126, 66)
    frame.SpecIcon:SetSize(14, 14)
    frame.SpecIcon.Texture:AddMaskTexture(frame.SpecIcon.Mask)
    frame.Trinket:SetSize(25, 25)
    frame.Racial:SetSize(25, 25)

    local hp = frame.HealthBar
    hp:SetSize(87, 23)
    hp:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")

    local pp = frame.PowerBar
    pp:SetSize(87, 12)
    pp:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Fill")

    local f = frame.ClassIcon
    f:SetSize(34, 34)
    f:Show()
    f:AddMaskTexture(frame.ClassIconMask)

    frame.ClassIconMask:SetSize(34, 34)

    local specBorder = frame.TexturePool:Acquire()
    specBorder:SetParent(frame.SpecIcon)
    specBorder:SetDrawLayer("ARTWORK", 3)
    specBorder:SetTexture("Interface\\CHARACTERFRAME\\TotemBorder")
    specBorder:SetPoint("TOPLEFT", frame.SpecIcon, "TOPLEFT", -5, 5)
    specBorder:SetPoint("BOTTOMRIGHT", frame.SpecIcon, "BOTTOMRIGHT", 5, -5)
    -- specBorder:SetDesaturated(1)
    -- specBorder:SetVertexColor(0.9, 0.9, 0.9, 1)
    specBorder:Show()

    f = frame.CastBar
    local typeInfoTexture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill";
    f:SetStatusBarTexture(typeInfoTexture)
    f.typeInfo = {
        filling = typeInfoTexture,
        full = typeInfoTexture,
        glow = typeInfoTexture
    }

    f = frame.DeathIcon
    f:ClearAllPoints()
    f:SetPoint("CENTER", frame.HealthBar, "CENTER")
    f:SetSize(32, 32)

    frame.HealthText:SetPoint("CENTER", frame.HealthBar)
    frame.HealthText:SetShadowOffset(0, 0)

    frame.PowerText:SetPoint("CENTER", frame.PowerBar)
    frame.PowerText:SetShadowOffset(0, 0)

    local underlay = frame.TexturePool:Acquire()
    underlay:SetDrawLayer("BACKGROUND", 1)
    underlay:SetColorTexture(0, 0, 0, 0.75)
    underlay:SetPoint("TOPLEFT", hp, "TOPLEFT")
    underlay:SetPoint("BOTTOMRIGHT", pp, "BOTTOMRIGHT")
    underlay:Show()

    local id = frame:GetID()
    layout["frameTexture" .. id] = frame.TexturePool:Acquire()
    local frameTexture = layout["frameTexture" .. id]
    frameTexture:SetDrawLayer("ARTWORK", 2)
    frameTexture:SetSize(160, 80)
    frameTexture:SetAtlas("UnitFrame")
    frameTexture:Show()

    self:UpdateOrientation(frame)
end

function layout:UpdateOrientation(frame)
    local frameTexture = layout["frameTexture" .. frame:GetID()]
    local healthBar = frame.HealthBar
    local powerBar = frame.PowerBar
    local classIcon = frame.ClassIcon
    local classIconMask = frame.ClassIconMask
    local name = frame.Name

    healthBar:ClearAllPoints()
    powerBar:ClearAllPoints()
    classIcon:ClearAllPoints()
    classIconMask:ClearAllPoints()
    name:ClearAllPoints()

    if (self.db.mirrored) then
        frameTexture:SetTexCoord(1, 0, 0, 1)
        frameTexture:SetPoint("TOPLEFT", frame, "TOPLEFT", -26, 6)

        healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -30)
        powerBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -53)
        classIcon:SetPoint("TOPRIGHT", -2, -2)
        classIconMask:SetPoint("TOPRIGHT", -2, -2)

        name:SetJustifyH("RIGHT")
    else
        frameTexture:SetTexCoord(0, 1, 0, 1)
        frameTexture:SetPoint("TOPLEFT", frame, "TOPLEFT", -7, 6)

        healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -30)
        powerBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -53)
        classIcon:SetPoint("TOPLEFT", 3, -2)
        classIconMask:SetPoint("TOPLEFT", 3, -2)

        name:SetJustifyH("LEFT")
    end

    name:SetJustifyV("BOTTOM")
    name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 5, 5)
    name:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", -5, 5)
    name:SetHeight(12)
end

sArenaMixin.layouts[layoutName] = layout
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings
