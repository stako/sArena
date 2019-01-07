local layoutName = "Xaryu";
local layout = {};

layout.defaultSettings = {
    posX = 281,
    posY = 3,
    scale = 1,
    spacing = 35,
    growthDirection = 1,
    specIcon = {
        posX = -21,
        posY = -2,
        scale = 1,
    },
    trinket = {
        posX = 101,
        posY = 0,
        scale = 1,
        fontSize = 14,
    },
    castBar = {
        posX = 12,
        posY = -27,
        scale = 1.25,
        width = 98,
    },
    dr = {
        posX = -95,
        posY = 0,
        size = 28,
        borderSize = 2.5,
        fontSize = 12,
        spacing = 6,
        growthDirection = 4,
    },

    -- custom layout settings
    width = 152,
    height = 44,
    powerBarHeight = 9,
};

local function getSetting(info)
    return layout.db[info[#info]];
end

local function setSetting(info, val)
    layout.db[info[#info]] = val;

    for i = 1,3 do
        local frame = info.handler["arena"..i];
        frame:SetSize(layout.db.width, layout.db.height);
        frame.ClassIcon:SetSize(layout.db.height, layout.db.height);
        frame.DeathIcon:SetSize(layout.db.height * 0.8, layout.db.height * 0.8);
        frame.PowerBar:SetHeight(layout.db.powerBarHeight);
    end
end

local function setupOptionsTable(self)
    layout.optionsTable = self:GetLayoutOptionsTable(layoutName);
    
    layout.optionsTable.special = {
        order = 6,
        name = "Special",
        type = "group",
        get = getSetting,
        set = setSetting,
        args = {
            width = {
                order = 1,
                name = "Width",
                type = "range",
                min = 40,
                max = 400,
                step = 1,
            },
            height = {
                order = 2,
                name = "Height",
                type = "range",
                min = 2,
                max = 100,
                step = 1,
            },
            powerBarHeight = {
                order = 2,
                name = "Power Bar Height",
                type = "range",
                min = 1,
                max = 50,
                step = 1,
            },
        },
    };
end

function layout:Initialize(frame)
    self.db = frame.parent.db.profile.layoutSettings[layoutName];

    if ( not self.optionsTable ) then
        setupOptionsTable(frame.parent);
    end

    frame.parent.portraitClassIcon = false;
    frame.parent.portraitSpecIcon = false;

    if ( frame:GetID() == 3 ) then
        frame.parent:UpdateCastBarSettings(self.db.castBar);
        frame.parent:UpdateDRSettings(self.db.dr);
        frame.parent:UpdateFrameSettings(self.db);
        frame.parent:UpdateSpecIconSettings(self.db.specIcon);
        frame.parent:UpdateTrinketSettings(self.db.trinket);
    end

    frame:SetSize(self.db.width, self.db.height);
    frame.SpecIcon:SetSize(18, 18);
    frame.Trinket:SetSize(44, 44);

    local healthBar = frame.HealthBar;
    healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2);
    healthBar:SetPoint("BOTTOMLEFT", frame.PowerBar, "TOPLEFT");
    healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    local powerBar = frame.PowerBar;
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 2);
    powerBar:SetPoint("LEFT", frame.ClassIcon, "RIGHT", 2, 0);
    powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    powerBar:SetHeight(self.db.powerBarHeight);

    local f = frame.ClassIcon;
    f:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
    f:SetSize(self.db.height, self.db.height);
    f:Show();

    f = frame.Name;
    f:SetJustifyH("LEFT");
    f:SetJustifyV("BOTTOM");
    f:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 0);
    f:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, 0);
    f:SetHeight(12);

    f = frame.CastBar;
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    f = frame.DeathIcon;
    f:ClearAllPoints();
    f:SetPoint("CENTER", healthBar, "CENTER");
    f:SetSize(self.db.height * 0.8, self.db.height * 0.8);

    frame.AuraText:Show();
    frame.AuraText:SetPoint("CENTER", frame.ClassIcon);

    frame.HealthText:SetPoint("CENTER", frame.HealthBar);
    frame.HealthText:SetShadowOffset(0, 0);

    frame.PowerText:SetPoint("CENTER", frame.PowerBar);
    frame.PowerText:SetShadowOffset(0, 0);

    local underlay = frame.TexturePool:Acquire();
    underlay:SetDrawLayer("BACKGROUND", 1);
    underlay:SetColorTexture(0, 0, 0, 0.75);
    underlay:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT");
    underlay:SetPoint("BOTTOMRIGHT", frame.PowerBar, "BOTTOMRIGHT");
    underlay:Show();
end

sArenaMixin.layouts[layoutName] = layout;
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings;
