local layoutName = "Xaryu";
local layout = {};

layout.defaultSettings = {
    width = 180,
    height = 40,
    powerBarHeight = 8,
    specIconSize = 16;
    castBar = {
        posX = -6,
        posY = -25,
        scale = 1.2,
        width = 92,
    },
    dr = {
        posX = -106,
        posY = 0,
        size = 26,
        borderSize = 2,
        fontSize = 12,
        spacing = 6,
        growthDirection = 4;
    },
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
        frame.TrinketIcon:SetSize(layout.db.height, layout.db.height);
        frame.DeathIcon:SetSize(layout.db.height * 0.8, layout.db.height * 0.8);
        frame.SpecIcon:SetSize(layout.db.specIconSize, layout.db.specIconSize);
        frame.PowerBar:SetHeight(layout.db.powerBarHeight);
    end
end

local function setupOptionsTable(self)
    layout.optionsTable = {
        arenaFrames = {
            order = 1,
            name = "Arena Frames",
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
                specIconSize = {
                    order = 2,
                    name = "Spec Icon Size",
                    type = "range",
                    min = 2,
                    max = 64,
                    step = 0.1,
                    bigStep = 1,
                },
            },
        },
        castBar = self:OptionsTable_GetCastBar(layoutName, 2),
        dr = self:OptionsTable_GetDR(layoutName, 3),
    };
end

function layout:Initialize(frame)
    self.db = frame.parent.db.profile.layoutSettings[layoutName];

    if ( not self.optionsTable ) then
        setupOptionsTable(frame.parent);
    end

    frame.parent.portraitClassIcon = false;
    frame.parent.portraitSpecIcon = false;

    frame:SetSize(self.db.width, self.db.height);

    local f = frame.ClassIcon;
    f:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
    f:SetSize(self.db.height, self.db.height);
    f:Show();

    f = frame.TrinketIcon;
    f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
    f:SetSize(self.db.height, self.db.height);

    local f = frame.SpecIcon;
    f:SetPoint("BOTTOMLEFT", frame.HealthBar, "BOTTOMLEFT");
    f:SetSize(self.db.specIconSize, self.db.specIconSize);
    f:Show();

    f = frame.Name;
    f:SetJustifyH("LEFT");
    f:SetJustifyV("BOTTOM");
    f:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 0);
    f:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, 0);
    f:SetHeight(12);

    f = frame.HealthBar;
    f:SetPoint("TOPLEFT", frame.ClassIcon, "TOPRIGHT", 2, -1);
    f:SetPoint("TOPRIGHT", frame.TrinketIcon, "TOPLEFT", -2, -1);
    f:SetPoint("BOTTOM", frame.PowerBar, "TOP");
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    f = frame.PowerBar;
    f:SetPoint("BOTTOMLEFT", frame.ClassIcon, "BOTTOMRIGHT", 2, 1);
    f:SetPoint("BOTTOMRIGHT", frame.TrinketIcon, "BOTTOMLEFT", -2, 1);
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    f:SetHeight(self.db.powerBarHeight);

    f = frame.CastBar;
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    frame.parent:UpdateCastBarSettings(frame, self.db.castBar);

    frame.parent:UpdateDRSettings(frame, self.db.dr);

    f = frame.DeathIcon;
    f:ClearAllPoints();
    f:SetPoint("CENTER", frame, "CENTER");
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
