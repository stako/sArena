local layoutName = "BlizzTarget"
local layout = {}
layout.name = "|cff00b4ffBlizz|r Target"

layout.defaultSettings = {
    posX = 300,
    posY = 100,
    scale = 1,
    classIconFontSize = 20,
    spacing = 14,
    growthDirection = 1,
    specIcon = {
        posX = 82,
        posY = -25,
        scale = 1,
    },
    trinket = {
        posX = 80,
        posY = 0,
        scale = 1.5,
        fontSize = 12,
    },
    racial = {
        posX = 104,
        posY = 0,
        scale = 1.5,
        fontSize = 12,
    },
    castBar = {
        posX = -15,
        posY = -29,
        scale = 1.2,
        width = 82,
    },
    dr = {
        posX = -114,
        posY = 0,
        size = 28,
        borderSize = 2.5,
        fontSize = 12,
        spacing = 7,
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

    frame:SetSize(192, 76.8)
    frame.SpecIcon:SetSize(22, 22)
    frame.SpecIcon.Texture:AddMaskTexture(frame.SpecIcon.Mask)
    frame.Trinket:SetSize(22, 22)
    frame.Racial:SetSize(22, 22)

    local healthBar = frame.HealthBar
    healthBar:SetSize(118, 9)
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    local powerBar = frame.PowerBar
    powerBar:SetSize(118, 9)
    powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -2)
    powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    local f = frame.ClassIcon
    f:SetSize(64, 64)
    f:Show()
    f:AddMaskTexture(frame.ClassIconMask)

    frame.ClassIconMask:SetSize(64, 64)

    local specBorder = frame.TexturePool:Acquire()
    specBorder:SetParent(frame.SpecIcon)
    specBorder:SetDrawLayer("ARTWORK", 3)
    specBorder:SetTexture("Interface\\CHARACTERFRAME\\TotemBorder")
    specBorder:SetPoint("TOPLEFT", frame.SpecIcon, "TOPLEFT", -8, 8)
    specBorder:SetPoint("BOTTOMRIGHT", frame.SpecIcon, "BOTTOMRIGHT", 8, -8)
    specBorder:Show()

    f = frame.Name
    f:SetJustifyH("CENTER")
    f:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", 2, 4)
    f:SetPoint("BOTTOMRIGHT", healthBar, "TOPRIGHT", -2, 4)
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
    f:SetPoint("CENTER", frame.HealthBar, "TOP")
    f:SetSize(48, 48)

    frame.HealthText:SetPoint("CENTER", frame.HealthBar)
    frame.HealthText:SetShadowOffset(0, 0)

    frame.PowerText:SetPoint("CENTER", frame.PowerBar)
    frame.PowerText:SetShadowOffset(0, 0)

    local underlay = frame.TexturePool:Acquire()
    underlay:SetDrawLayer("BACKGROUND", 1)
    underlay:SetColorTexture(0, 0, 0, 0.75)
    underlay:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 19)
    underlay:SetPoint("BOTTOMRIGHT", powerBar)
    underlay:Show()

    local id = frame:GetID()
    layout["frameTexture" .. id] = frame.TexturePool:Acquire()
    local frameTexture = layout["frameTexture" .. id]
    frameTexture:SetDrawLayer("ARTWORK", 2)
    frameTexture:SetAllPoints(frame)
    frameTexture:SetTexture("Interface\\TARGETINGFRAME\\UI-TargetingFrame-NoLevel")
    frameTexture:Show()

    self:UpdateOrientation(frame)
end

function layout:UpdateOrientation(frame)
    local frameTexture = layout["frameTexture" .. frame:GetID()]
    local healthBar = frame.HealthBar
    local classIcon = frame.ClassIcon
    local classIconMask = frame.ClassIconMask

    healthBar:ClearAllPoints()
    classIcon:ClearAllPoints()
    classIconMask:ClearAllPoints()

    if (self.db.mirrored) then
        frameTexture:SetTexCoord(0.85, 0.1, 0.05, 0.65)
        healthBar:SetPoint("RIGHT", -5, -2)
        classIcon:SetPoint("LEFT", 5, 0)
        classIconMask:SetPoint("LEFT", 5, 0)
    else
        frameTexture:SetTexCoord(0.1, 0.85, 0.05, 0.65)
        healthBar:SetPoint("LEFT", 5, -2)
        classIcon:SetPoint("RIGHT", -5, 0)
        classIconMask:SetPoint("RIGHT", -5, 0)
    end
end

sArenaMixin.layouts[layoutName] = layout
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings
